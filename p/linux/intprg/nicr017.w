&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME W-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS W-Win 
/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
DEFINE BUFFER cliente  FOR ems5.cliente.
DEFINE BUFFER portador FOR ems5.portador.

/*------------------------------------------------------------------------

  File: 

  Description: from cntnrwin.w - ADM SmartWindow Template

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  History: 
          
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
def new global shared var v_rec_clien_financ
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.

def new Global shared var c-gerou-erro         as LOGICAL format "Sim/N∆o" no-undo.
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE TEMP-TABLE tt-tit-acr     LIKE tit_acr
    FIELD marca  AS LOGICAL FORMAT "*/ "
    FIELD mostra AS LOGICAL FORMAT "Sim/N∆o"
    FIELD filtro AS LOGICAL FORMAT "Sim/N∆o"
    FIELD razao-social AS CHAR FORMAT "x(50)" COLUMN-LABEL "Nome Cliente".
DEFINE TEMP-TABLE tt-tit-acr-sel LIKE tit_acr
    FIELD marca AS LOGICAL FORMAT "*/ "
    FIELD r-rowid AS ROWID
    FIELD filtro AS LOGICAL FORMAT "Sim/N∆o"
    FIELD razao-social AS CHAR FORMAT "x(50)" COLUMN-LABEL "Nome Cliente".

DEFINE TEMP-TABLE tt-tit-criados  
    FIELD cod_estab           LIKE tit_acr.cod_estab         
    FIELD cod_espec_docto     LIKE tit_acr.cod_espec_docto   
    FIELD cod_ser_docto       LIKE tit_acr.cod_ser_docto     
    FIELD cod_tit_acr         LIKE tit_acr.cod_tit_acr     
    FIELD cod_parcela         LIKE tit_acr.cod_parcela       
    FIELD cdn_cliente         LIKE tit_acr.cdn_cliente       
    FIELD cod_portador        LIKE tit_acr.cod_portador      
    FIELD dat_transacao       LIKE tit_acr.dat_transacao     
    FIELD dat_emis_docto      LIKE tit_acr.dat_emis_docto    
    FIELD dat_vencto_tit_acr  LIKE tit_acr.dat_vencto_tit_acr
    FIELD val_origin_tit_acr  LIKE tit_acr.val_origin_tit_acr
    FIELD situacao            AS CHAR FORMAT "x(20)".


DEFINE VARIABLE c-cod-refer      AS CHARACTER                NO-UNDO.
DEFINE VARIABLE h-acomp          AS HANDLE                   NO-UNDO.
DEFINE VARIABLE c_cod_table      AS CHARACTER                NO-UNDO.
DEFINE VARIABLE v_log_refer_uni  AS LOGICAL                  NO-UNDO.

{intprg\int021.i}

DEFINE BUFFER bf-emitente FOR emitente.
DEFINE BUFFER b_estabelecimento FOR ems5.estabelecimento.

define temp-table tt-param-nicr003a no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field modelo-rtf       as char format "x(35)"
    field l-habilitaRtf    as LOG
    FIELD c-estab          AS CHAR FORMAT "x(05)"
    FIELD c-cliente-ini    LIKE emitente.cod-emitente
    FIELD c-cliente-fim    LIKE emitente.cod-emitente
    FIELD c-dt-emissao     AS DATE FORMAT "99/99/9999"
    FIELD c-convenio       AS CHAR FORMAT "999999"
    .

define temp-table tt-digita-nicr003a no-undo
    field cod_estab          LIKE tit_acr.cod_estab
    field cod_espec_docto    LIKE tit_acr.cod_espec_docto
    FIELD cod_ser_docto      LIKE tit_acr.cod_ser_docto
    FIELD cod_tit_acr        LIKE tit_acr.cod_tit_acr
    FIELD cod_parcela        LIKE tit_acr.cod_parcela
    index id cod_estab      
             cod_espec_docto
             cod_ser_docto  
             cod_tit_acr    
             cod_parcela  .

def var raw-param-nicr003a   as raw no-undo.

def temp-table tt-raw-digita-nicr003a
   field raw-digita   as raw.

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

{cdp/cd0666.i}
DEFINE TEMP-TABLE tt-erro-aux LIKE tt-erro.

DEFINE VARIABLE c-estab-ini    AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-estab-fim    AS CHARACTER INITIAL "ZZZZZ"         NO-UNDO.
DEFINE VARIABLE c-especie-ini  AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-especie-fim  AS CHARACTER INITIAL "ZZZ"           NO-UNDO.
DEFINE VARIABLE c-serie-ini    AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-serie-fim    AS CHARACTER INITIAL "ZZZZZ"         NO-UNDO.
DEFINE VARIABLE c-titulo-ini   AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-titulo-fim   AS CHARACTER INITIAL "ZZZZZZZZZZZZ"  NO-UNDO.
DEFINE VARIABLE c-data-ini     AS DATE      INITIAL "01/01/2010"    NO-UNDO.
DEFINE VARIABLE c-data-fim     AS DATE      INITIAL "12/31/2999"    NO-UNDO.
DEFINE VARIABLE c-venc-ini     AS DATE      INITIAL "01/01/2010"    NO-UNDO.
DEFINE VARIABLE c-venc-fim     AS DATE      INITIAL "12/31/2999"    NO-UNDO.

DEFINE VARIABLE c-estab-ini-sel    AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-estab-fim-sel    AS CHARACTER INITIAL "ZZZZZ"         NO-UNDO.
DEFINE VARIABLE c-especie-ini-sel  AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-especie-fim-sel  AS CHARACTER INITIAL "ZZZ"           NO-UNDO.
DEFINE VARIABLE c-serie-ini-sel    AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-serie-fim-sel    AS CHARACTER INITIAL "ZZZZZ"         NO-UNDO.
DEFINE VARIABLE c-titulo-ini-sel   AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-titulo-fim-sel   AS CHARACTER INITIAL "ZZZZZZZZZZZZ"  NO-UNDO.
DEFINE VARIABLE c-data-ini-sel     AS DATE      INITIAL "01/01/2010"    NO-UNDO.
DEFINE VARIABLE c-data-fim-sel     AS DATE      INITIAL "12/31/2999"    NO-UNDO.
DEFINE VARIABLE c-venc-ini-sel     AS DATE      INITIAL "01/01/2010"    NO-UNDO.
DEFINE VARIABLE c-venc-fim-sel     AS DATE      INITIAL "12/31/2999"    NO-UNDO.

DEFINE VARIABLE cCodCliente LIKE tit_acr.cdn_cliente                    NO-UNDO. 
DEFINE VARIABLE cNumRenegoc LIKE tit_acr.num_renegoc_cobr_acr           NO-UNDO. 
DEFINE VARIABLE dDatEmissao LIKE tit_acr.dat_emis_docto                 NO-UNDO. 
DEFINE VARIABLE dDatVencto  LIKE tit_acr.dat_vencto_tit_acr             NO-UNDO. 
DEFINE VARIABLE cCodEspec   LIKE tit_acr.cod_espec_docto                NO-UNDO. 
DEFINE VARIABLE cSerDocto   LIKE tit_acr.cod_ser_docto                  NO-UNDO. 



/* INICIO - Variaveis EMS5 */
def new global shared var v_cod_empres_usuar
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.
def new global shared var v_rec_espec_docto_financ_acr
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_rec_estabelecimento
    as recid
    format ">>>>>>9":U
    no-undo.
def new global shared var v_rec_ser_fisc_nota
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_cod_dwb_user
    as character
    format "x(21)":U
    label "Usuˇrio"
    column-label "Usuˇrio"
    no-undo.
def new global shared var v_rec_tit_acr
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_table
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
/* FIM    - Variaveis EMS5 */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartWindow
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br-tit-acr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-tit-acr tt-tit-acr-sel

/* Definitions for BROWSE br-tit-acr                                    */
&Scoped-define FIELDS-IN-QUERY-br-tit-acr tt-tit-acr.marca tt-tit-acr.cod_estab tt-tit-acr.cdn_cliente tt-tit-acr.razao-social tt-tit-acr.cod_espec_docto tt-tit-acr.cod_ser_docto tt-tit-acr.cod_tit_acr tt-tit-acr.cod_parcela tt-tit-acr.dat_emis_docto tt-tit-acr.dat_vencto_origin_tit_acr tt-tit-acr.val_origin_tit_acr   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-tit-acr   
&Scoped-define SELF-NAME br-tit-acr
&Scoped-define QUERY-STRING-br-tit-acr FOR EACH tt-tit-acr WHERE tt-tit-acr.mostra = YES                                               AND tt-tit-acr.filtro = YES
&Scoped-define OPEN-QUERY-br-tit-acr OPEN QUERY {&SELF-NAME} FOR EACH tt-tit-acr WHERE tt-tit-acr.mostra = YES                                               AND tt-tit-acr.filtro = YES.
&Scoped-define TABLES-IN-QUERY-br-tit-acr tt-tit-acr
&Scoped-define FIRST-TABLE-IN-QUERY-br-tit-acr tt-tit-acr


/* Definitions for BROWSE br-tit-acr-sel                                */
&Scoped-define FIELDS-IN-QUERY-br-tit-acr-sel tt-tit-acr-sel.marca tt-tit-acr-sel.cod_estab tt-tit-acr-sel.cdn_cliente tt-tit-acr-sel.razao-social tt-tit-acr-sel.cod_espec_docto tt-tit-acr-sel.cod_ser_docto tt-tit-acr-sel.cod_tit_acr tt-tit-acr-sel.cod_parcela tt-tit-acr-sel.dat_emis_docto tt-tit-acr-sel.dat_vencto_origin_tit_acr tt-tit-acr-sel.val_origin_tit_acr   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-tit-acr-sel   
&Scoped-define SELF-NAME br-tit-acr-sel
&Scoped-define QUERY-STRING-br-tit-acr-sel FOR EACH tt-tit-acr-sel                            WHERE tt-tit-acr-sel.filtro = YES
&Scoped-define OPEN-QUERY-br-tit-acr-sel OPEN QUERY {&SELF-NAME} FOR EACH tt-tit-acr-sel                            WHERE tt-tit-acr-sel.filtro = YES.
&Scoped-define TABLES-IN-QUERY-br-tit-acr-sel tt-tit-acr-sel
&Scoped-define FIRST-TABLE-IN-QUERY-br-tit-acr-sel tt-tit-acr-sel


/* Definitions for FRAME F-Main                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-F-Main ~
    ~{&OPEN-QUERY-br-tit-acr}~
    ~{&OPEN-QUERY-br-tit-acr-sel}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 rt-button RECT-3 c-cod-estab ~
bt-zoom-estab c-cod-espec-docto bt-zoom-espec c-cod-ser-docto bt-zoom-ser ~
c-cod-tit-acr c-cod-parcela bt-zoom-ser-2 BUTTON-4 fi-data-emis ~
fi-data-vencto br-tit-acr bt-filtro bt-incluir br-tit-acr-sel bt-filtro-sel ~
bt-marca-sel bt-desmarca-sel bt-excluir bt-soma bt-executar bt-cancelar 
&Scoped-Define DISPLAYED-OBJECTS c-cod-estab c-cod-espec-docto ~
c-cod-ser-docto c-cod-tit-acr c-cod-parcela c-cod-cliente fi-nome-cliente ~
c-num-renegoc fi-convenio c-saldo-tit-acr fi-data-emis fi-data-vencto 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR W-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-cancelar AUTO-END-KEY 
     LABEL "Fechar" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-desmarca-sel 
     IMAGE-UP FILE "image/im-ran_n.bmp":U
     IMAGE-INSENSITIVE FILE "image/im-ran5i.bmp":U
     LABEL "Button 7" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-excluir 
     IMAGE-UP FILE "image/im-up2.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-up2.bmp":U
     LABEL "Button 8" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-executar 
     LABEL "Executar" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-filtro 
     IMAGE-UP FILE "image/im-ran.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-ran.bmp":U
     LABEL "Button 1" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-filtro-sel 
     IMAGE-UP FILE "image/im-ran.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-ran.bmp":U
     LABEL "bt filtro 2" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-incluir 
     IMAGE-UP FILE "image/im-down2.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-down2.bmp":U
     LABEL "Button 5" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-marca-sel 
     IMAGE-UP FILE "image/im-ran_a.bmp":U
     IMAGE-INSENSITIVE FILE "image/im-ran5i.bmp":U
     LABEL "Button 6" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-soma 
     IMAGE-UP FILE "image/im-tot.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-total.bmp":U
     LABEL "bt excluir 2" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-zoom-espec 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "Button 2" 
     SIZE 4 BY .88.

DEFINE BUTTON bt-zoom-estab 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "Button 1" 
     SIZE 4 BY .88.

DEFINE BUTTON bt-zoom-ser 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "Button 3" 
     SIZE 4 BY .88.

DEFINE BUTTON bt-zoom-ser-2 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "bt zoom ser 2" 
     SIZE 4 BY .88.

DEFINE BUTTON BUTTON-4 
     IMAGE-UP FILE "image/im-enter":U
     IMAGE-INSENSITIVE FILE "image/ii-enter":U
     LABEL "Button 4" 
     SIZE 4 BY .88.

DEFINE VARIABLE c-cod-cliente AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Cliente" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE c-cod-espec-docto AS CHARACTER FORMAT "X(3)":U INITIAL "CF" 
     LABEL "EspÇcie" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE c-cod-estab AS CHARACTER FORMAT "X(5)":U INITIAL "973" 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE c-cod-parcela AS CHARACTER FORMAT "x(02)":U 
     VIEW-AS FILL-IN 
     SIZE 3.57 BY .88 NO-UNDO.

DEFINE VARIABLE c-cod-ser-docto AS CHARACTER FORMAT "X(5)":U 
     LABEL "SÇrie" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE c-cod-tit-acr AS CHARACTER FORMAT "X(256)":U 
     LABEL "T°tulo" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE c-num-renegoc AS INTEGER FORMAT ">>>>,>>9":U INITIAL 0 
     LABEL "Num. Renegoc." 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE c-saldo-tit-acr AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Saldo T°tulo" 
     VIEW-AS FILL-IN 
     SIZE 17.14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-convenio AS CHARACTER FORMAT "X(256)":U 
     LABEL "Convànio" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE fi-data-emis AS DATE FORMAT "99/99/9999":U 
     LABEL "Estorno/Emiss∆o" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE fi-data-vencto AS DATE FORMAT "99/99/9999":U 
     LABEL "Vencimento" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nome-cliente AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 65 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 108.57 BY 3.75.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 108.57 BY 19.54.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 108.57 BY 1.67.

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 108.72 BY 1.42
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-tit-acr FOR 
      tt-tit-acr SCROLLING.

DEFINE QUERY br-tit-acr-sel FOR 
      tt-tit-acr-sel SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-tit-acr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-tit-acr W-Win _FREEFORM
  QUERY br-tit-acr DISPLAY
      tt-tit-acr.marca COLUMN-LABEL " * "
 tt-tit-acr.cod_estab WIDTH 3
 tt-tit-acr.cdn_cliente 
 tt-tit-acr.razao-social  WIDTH 30
 tt-tit-acr.cod_espec_docto 
 tt-tit-acr.cod_ser_docto 
 tt-tit-acr.cod_tit_acr 
 tt-tit-acr.cod_parcela
 tt-tit-acr.dat_emis_docto            WIDTH 10
 tt-tit-acr.dat_vencto_origin_tit_acr WIDTH 10 COLUMN-LABEL "Dat Vencto"
 tt-tit-acr.val_origin_tit_acr                 COLUMN-LABEL "Valor Original"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 102.72 BY 10.46
         TITLE "Cupons da Fatura" ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.

DEFINE BROWSE br-tit-acr-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-tit-acr-sel W-Win _FREEFORM
  QUERY br-tit-acr-sel DISPLAY
      tt-tit-acr-sel.marca COLUMN-LABEL " * "
 tt-tit-acr-sel.cod_estab WIDTH 3 
 tt-tit-acr-sel.cdn_cliente 
 tt-tit-acr-sel.razao-social  WIDTH 30
 tt-tit-acr-sel.cod_espec_docto 
 tt-tit-acr-sel.cod_ser_docto 
 tt-tit-acr-sel.cod_tit_acr 
 tt-tit-acr-sel.cod_parcela 
 tt-tit-acr-sel.dat_emis_docto            WIDTH 10
 tt-tit-acr-sel.dat_vencto_origin_tit_acr WIDTH 10 COLUMN-LABEL "Dat Vencto"
 tt-tit-acr-sel.val_origin_tit_acr                 COLUMN-LABEL "Valor Original"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 102.72 BY 8.63
         TITLE "Cupons Ö Estornar" ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     c-cod-estab AT ROW 1.92 COL 16.86 COLON-ALIGNED WIDGET-ID 58
     bt-zoom-estab AT ROW 1.92 COL 25.86 WIDGET-ID 76
     c-cod-espec-docto AT ROW 1.92 COL 38.72 COLON-ALIGNED WIDGET-ID 64
     bt-zoom-espec AT ROW 1.92 COL 45.72 WIDGET-ID 78
     c-cod-ser-docto AT ROW 1.92 COL 54.43 COLON-ALIGNED WIDGET-ID 66
     bt-zoom-ser AT ROW 1.92 COL 63.43 WIDGET-ID 80
     c-cod-tit-acr AT ROW 1.92 COL 73.43 COLON-ALIGNED WIDGET-ID 68
     c-cod-parcela AT ROW 1.92 COL 87.57 COLON-ALIGNED NO-LABEL WIDGET-ID 70
     bt-zoom-ser-2 AT ROW 1.92 COL 93.29 WIDGET-ID 84
     c-cod-cliente AT ROW 2.88 COL 16.86 COLON-ALIGNED WIDGET-ID 60
     fi-nome-cliente AT ROW 2.88 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     c-num-renegoc AT ROW 3.83 COL 16.86 COLON-ALIGNED WIDGET-ID 62
     fi-convenio AT ROW 3.83 COL 44.43 COLON-ALIGNED WIDGET-ID 94
     c-saldo-tit-acr AT ROW 3.83 COL 77.86 COLON-ALIGNED WIDGET-ID 74
     BUTTON-4 AT ROW 3.92 COL 105 WIDGET-ID 82
     fi-data-emis AT ROW 5.75 COL 21.43 COLON-ALIGNED WIDGET-ID 90
     fi-data-vencto AT ROW 5.75 COL 62.29 COLON-ALIGNED WIDGET-ID 96
     br-tit-acr AT ROW 7.21 COL 2.14 WIDGET-ID 200
     bt-filtro AT ROW 7.25 COL 105.14 WIDGET-ID 28
     bt-incluir AT ROW 8.25 COL 105.14 WIDGET-ID 40
     br-tit-acr-sel AT ROW 17.75 COL 2.14 WIDGET-ID 300
     bt-filtro-sel AT ROW 17.75 COL 105.14 WIDGET-ID 54
     bt-marca-sel AT ROW 18.75 COL 105.14 WIDGET-ID 44
     bt-desmarca-sel AT ROW 19.75 COL 105.14 WIDGET-ID 46
     bt-excluir AT ROW 20.75 COL 105.14 WIDGET-ID 48
     bt-soma AT ROW 25.38 COL 105.14 WIDGET-ID 56
     bt-executar AT ROW 26.88 COL 2 HELP
          "Dispara a execuá∆o do relat¢rio" WIDGET-ID 32
     bt-cancelar AT ROW 26.88 COL 13 HELP
          "Fechar" WIDGET-ID 30
     "Data para Geraá∆o" VIEW-AS TEXT
          SIZE 15.72 BY .67 AT ROW 5 COL 2.29 WIDGET-ID 88
     "Fatura a ser Estornada Parcial" VIEW-AS TEXT
          SIZE 28.57 BY .67 AT ROW 1.04 COL 2.43 WIDGET-ID 8
     RECT-1 AT ROW 1.25 COL 1.43 WIDGET-ID 2
     RECT-2 AT ROW 7 COL 1.43 WIDGET-ID 4
     rt-button AT ROW 26.67 COL 1.29 WIDGET-ID 6
     RECT-3 AT ROW 5.21 COL 1.57 WIDGET-ID 86
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 109.72 BY 27.25 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartWindow
   Allow: Basic,Browse,DB-Fields,Query,Smart,Window
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW W-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Estorno Parcial Fatura Convànio"
         HEIGHT             = 27.25
         WIDTH              = 109.72
         MAX-HEIGHT         = 34.88
         MAX-WIDTH          = 228.57
         VIRTUAL-HEIGHT     = 34.88
         VIRTUAL-WIDTH      = 228.57
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB W-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW W-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   FRAME-NAME                                                           */
/* BROWSE-TAB br-tit-acr fi-data-vencto F-Main */
/* BROWSE-TAB br-tit-acr-sel bt-incluir F-Main */
/* SETTINGS FOR FILL-IN c-cod-cliente IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-num-renegoc IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-saldo-tit-acr IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-convenio IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-nome-cliente IN FRAME F-Main
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(W-Win)
THEN W-Win:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-tit-acr
/* Query rebuild information for BROWSE br-tit-acr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-tit-acr WHERE tt-tit-acr.mostra = YES
                                              AND tt-tit-acr.filtro = YES.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-tit-acr */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-tit-acr-sel
/* Query rebuild information for BROWSE br-tit-acr-sel
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-tit-acr-sel
                           WHERE tt-tit-acr-sel.filtro = YES.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-tit-acr-sel */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME W-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL W-Win W-Win
ON END-ERROR OF W-Win /* Estorno Parcial Fatura Convànio */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL W-Win W-Win
ON WINDOW-CLOSE OF W-Win /* Estorno Parcial Fatura Convànio */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-tit-acr
&Scoped-define SELF-NAME br-tit-acr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tit-acr W-Win
ON MOUSE-SELECT-DBLCLICK OF br-tit-acr IN FRAME F-Main /* Cupons da Fatura */
DO:
  IF tt-tit-acr.marca = YES THEN
       ASSIGN tt-tit-acr.marca  = NO.
  ELSE ASSIGN tt-tit-acr.marca  = YES.

  br-tit-acr:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-tit-acr-sel
&Scoped-define SELF-NAME br-tit-acr-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tit-acr-sel W-Win
ON MOUSE-SELECT-DBLCLICK OF br-tit-acr-sel IN FRAME F-Main /* Cupons Ö Estornar */
DO:
  IF tt-tit-acr-sel.marca = YES THEN
       ASSIGN tt-tit-acr-sel.marca  = NO.
  ELSE ASSIGN tt-tit-acr-sel.marca  = YES.

  br-tit-acr-sel:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar W-Win
ON CHOOSE OF bt-cancelar IN FRAME F-Main /* Fechar */
DO:
   apply "close":U to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-desmarca-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-desmarca-sel W-Win
ON CHOOSE OF bt-desmarca-sel IN FRAME F-Main /* Button 7 */
DO:
  FOR EACH tt-tit-acr-sel:
      ASSIGN tt-tit-acr-sel.marca = NO.
  END.
  br-tit-acr-sel:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-excluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-excluir W-Win
ON CHOOSE OF bt-excluir IN FRAME F-Main /* Button 8 */
DO:
    IF CAN-FIND(FIRST tt-tit-acr-sel
                WHERE tt-tit-acr-sel.marca  = YES
                  AND tt-tit-acr-sel.filtro = YES) THEN DO:
        FOR EACH tt-tit-acr-sel
         WHERE tt-tit-acr-sel.marca  = YES
           AND tt-tit-acr-sel.filtro = YES :
    
         FIND FIRST tt-tit-acr 
              WHERE ROWID(tt-tit-acr)  = tt-tit-acr-sel.r-rowid NO-ERROR.
         IF AVAIL tt-tit-acr THEN DO:
             ASSIGN tt-tit-acr.marca  = NO
                    tt-tit-acr.mostra = YES.
    
             DELETE tt-tit-acr-sel.
         END.
        END.

        FOR EACH tt-tit-acr-sel:
            ASSIGN tt-tit-acr-sel.filtro = YES.
        END.

        {&OPEN-QUERY-br-tit-acr}
        {&OPEN-QUERY-br-tit-acr-sel}

    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-executar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-executar W-Win
ON CHOOSE OF bt-executar IN FRAME F-Main /* Executar */
DO:
    IF INPUT FRAME {&FRAME-NAME} fi-data-emis   = ? OR
       INPUT FRAME {&FRAME-NAME} fi-data-vencto = ? OR
       INPUT FRAME {&FRAME-NAME} fi-data-vencto < INPUT FRAME {&FRAME-NAME} fi-data-emis THEN DO:
        RUN utp/ut-msgs.p (INPUT "show":U, 
                           INPUT 17006, 
                           INPUT "Favor verificar as datas de estorno/emiss∆o e/ou de vencimento.").
        RETURN "NOK".

    END.
    ELSE DO:
        RUN utp/ut-msgs.p (INPUT "show":U, 
                           INPUT 27702, 
                           INPUT "Deseja realizar o estorno parcial da Fatura?~~ Foi verificada as datas de estorno/emiss∆o(" + STRING(fi-data-emis:SCREEN-VALUE IN FRAME {&FRAME-NAME}) 
                                                                                                                            + ") e de vencimento(" + STRING(fi-data-vencto:SCREEN-VALUE IN FRAME {&FRAME-NAME}) + ") ?").
        IF RETURN-VALUE = "YES" THEN DO:
            /*  */
            do  on error undo, return no-apply:
                EMPTY TEMP-TABLE tt-erro-aux.
    
                run pi-executar.
            END.
        END.
    END.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-filtro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-filtro W-Win
ON CHOOSE OF bt-filtro IN FRAME F-Main /* Button 1 */
DO:
    DEFINE VARIABLE opcao AS LOGICAL   NO-UNDO.

    RUN intprg/nicr003f.w(INPUT-OUTPUT c-estab-ini,
                          INPUT-OUTPUT c-estab-fim,
                          INPUT-OUTPUT c-especie-ini,
                          INPUT-OUTPUT c-especie-fim,
                          INPUT-OUTPUT c-serie-ini,
                          INPUT-OUTPUT c-serie-fim,
                          INPUT-OUTPUT c-titulo-ini,
                          INPUT-OUTPUT c-titulo-fim,
                          INPUT-OUTPUT c-data-ini,
                          INPUT-OUTPUT c-data-fim,
                          INPUT-OUTPUT c-venc-ini,
                          INPUT-OUTPUT c-venc-fim,
                          OUTPUT opcao).

    IF opcao = YES THEN DO:
        RUN pi-carrega-titulo-filtro.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-filtro-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-filtro-sel W-Win
ON CHOOSE OF bt-filtro-sel IN FRAME F-Main /* bt filtro 2 */
DO:
    DEFINE VARIABLE opcao AS LOGICAL     NO-UNDO.

    RUN intprg/nicr003f.w(INPUT-OUTPUT c-estab-ini-sel,
                          INPUT-OUTPUT c-estab-fim-sel,
                          INPUT-OUTPUT c-especie-ini-sel,
                          INPUT-OUTPUT c-especie-fim-sel,
                          INPUT-OUTPUT c-serie-ini-sel,
                          INPUT-OUTPUT c-serie-fim-sel,
                          INPUT-OUTPUT c-titulo-ini-sel,
                          INPUT-OUTPUT c-titulo-fim-sel,
                          INPUT-OUTPUT c-data-ini-sel,
                          INPUT-OUTPUT c-data-fim-sel,
                          INPUT-OUTPUT c-venc-ini-sel,
                          INPUT-OUTPUT c-venc-fim-sel,
                          OUTPUT opcao).

    IF opcao = YES THEN DO:
        RUN pi-carrega-titulo-sel-filtro.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-incluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-incluir W-Win
ON CHOOSE OF bt-incluir IN FRAME F-Main /* Button 5 */
DO:
    IF CAN-FIND(FIRST tt-tit-acr
                WHERE tt-tit-acr.marca  = YES
                  AND tt-tit-acr.mostra = YES
                  AND tt-tit-acr.filtro = YES) THEN DO:

        FOR EACH tt-tit-acr
           WHERE tt-tit-acr.marca  = YES
             AND tt-tit-acr.mostra = YES
             AND tt-tit-acr.filtro = YES:
    
           CREATE tt-tit-acr-sel.
           BUFFER-COPY tt-tit-acr TO tt-tit-acr-sel.
           ASSIGN tt-tit-acr-sel.marca   = YES
                  tt-tit-acr-sel.filtro  = YES
                  tt-tit-acr-sel.r-rowid = ROWID(tt-tit-acr).
    
           ASSIGN tt-tit-acr.mostra = NO.
    
        END.

        {&OPEN-QUERY-br-tit-acr}
        {&OPEN-QUERY-br-tit-acr-sel}

    END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-marca-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-marca-sel W-Win
ON CHOOSE OF bt-marca-sel IN FRAME F-Main /* Button 6 */
DO:
  FOR EACH tt-tit-acr-sel:
      ASSIGN tt-tit-acr-sel.marca = YES.
  END.
  br-tit-acr-sel:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-soma
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-soma W-Win
ON CHOOSE OF bt-soma IN FRAME F-Main /* bt excluir 2 */
DO:
    DEFINE VARIABLE vSomaTitulo LIKE tit_acr.val_sdo_tit.
   
    IF CAN-FIND(FIRST tt-tit-acr-sel
                WHERE tt-tit-acr-sel.marca  = YES
                  AND tt-tit-acr-sel.filtro = YES) THEN DO:

        FOR EACH tt-tit-acr-sel
           WHERE tt-tit-acr-sel.marca  = YES
             AND tt-tit-acr-sel.filtro = YES NO-LOCK:

            ASSIGN vSomaTitulo = vSomaTitulo + tt-tit-acr-sel.val_origin_tit_acr.

        END.

        RUN intprg/nicr003b.w(INPUT vSomaTitulo).
       
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-zoom-espec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-zoom-espec W-Win
ON CHOOSE OF bt-zoom-espec IN FRAME F-Main /* Button 2 */
DO:
/* fn_generic_zoom */
    if  search("prgfin/acr/acr030ka.r") = ? and search("prgfin/acr/acr030ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa executˇvel nío foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr030ka.p".
        else do:
            message "Programa executˇvel nío foi encontrado:" /*l_programa_nao_encontrado*/  "prgfin/acr/acr030ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgfin/acr/acr030ka.p /*prg_sea_espec_docto_financ_acr*/.
    if  v_rec_espec_docto_financ_acr <> ?
    then do:
        find espec_docto_financ_acr where recid(espec_docto_financ_acr) = v_rec_espec_docto_financ_acr no-lock no-error.
        assign c-cod-espec-docto:screen-value in frame {&FRAME-NAME} =
               string(espec_docto_financ_acr.cod_espec_docto).

    end /* if */.
    apply "entry" to c-cod-espec-docto in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-zoom-estab
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-zoom-estab W-Win
ON CHOOSE OF bt-zoom-estab IN FRAME F-Main /* Button 1 */
DO:
      /* fn_generic_zoom */
    if  search("prgint/utb/utb071na.r") = ? and search("prgint/utb/utb071na.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa executˇvel nío foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb071na.p".
        else do:
            message "Programa executˇvel nío foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/utb/utb071na.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb071na.p (Input v_cod_empres_usuar) /*prg_see_estabelecimento_empresa*/.
    if  v_rec_estabelecimento <> ?
    then do:
        find estabelecimento where recid(estabelecimento) = v_rec_estabelecimento no-lock no-error.
        assign c-cod-estab:screen-value in frame {&FRAME-NAME} =
               string(estabelecimento.cod_estab).

    end /* if */.
    apply "entry" to c-cod-estab in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-zoom-ser
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-zoom-ser W-Win
ON CHOOSE OF bt-zoom-ser IN FRAME F-Main /* Button 3 */
DO:
    /* fn_generic_zoom */
    if  search("prgint/utb/utb113ka.r") = ? and search("prgint/utb/utb113ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa executˇvel nío foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb113ka.p".
        else do:
            message "Programa executˇvel nío foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/utb/utb113ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb113ka.p /*prg_sea_ser_fisc_nota*/.
    if  v_rec_ser_fisc_nota <> ?
    then do:
        find ser_fisc_nota where recid(ser_fisc_nota) = v_rec_ser_fisc_nota no-lock no-error.
        assign c-cod-ser-docto:screen-value in frame {&FRAME-NAME} =
               string(ser_fisc_nota.cod_ser_fisc_nota).

    end /* if */.
    apply "entry" to c-cod-ser-docto in frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-zoom-ser-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-zoom-ser-2 W-Win
ON CHOOSE OF bt-zoom-ser-2 IN FRAME F-Main /* bt zoom ser 2 */
DO:
    assign v_rec_tit_acr = v_rec_table.
    if  search("prgfin/acr/acr212ka.r") = ? and search("prgfin/acr/acr212ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr212ka.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgfin/acr/acr212ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgfin/acr/acr212ka.p /*prg_sea_tit_acr*/.
    if  v_rec_tit_acr <> ?
    then do:
        assign v_rec_table = v_rec_tit_acr.
        run pi_disp_fields /*pi_disp_fields*/.
    end /* if */.
    else do:
        assign v_rec_tit_acr = v_rec_table
               v_rec_table   = ?.
    end /* else */.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-4 W-Win
ON CHOOSE OF BUTTON-4 IN FRAME F-Main /* Button 4 */
DO:
    FIND tit_acr WHERE RECID(tit_acr) = v_rec_table NO-LOCK NO-ERROR.

    IF AVAILABLE tit_acr THEN DO:

        ASSIGN fi-data-emis:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = STRING(TODAY,"99/99/9999").
        ASSIGN fi-data-vencto:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(TODAY,"99/99/9999").

        IF tit_acr.num_renegoc_cobr_acr = 0 THEN DO:

            RETURN "NOK".
        END.
        
        RUN piCarregaTitulosRenegociados.
        
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-cod-espec-docto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-espec-docto W-Win
ON F5 OF c-cod-espec-docto IN FRAME F-Main /* EspÇcie */
DO:
  APPLY "CHOOSE" TO bt-zoom-espec IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-espec-docto W-Win
ON MOUSE-SELECT-DBLCLICK OF c-cod-espec-docto IN FRAME F-Main /* EspÇcie */
DO:
  APPLY "CHOOSE" TO bt-zoom-espec IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-cod-estab
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estab W-Win
ON ENTRY OF c-cod-estab IN FRAME F-Main /* Estab */
DO:
  ASSIGN fi-data-emis:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = STRING(TODAY,"99/99/9999").
  ASSIGN fi-data-vencto:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(TODAY,"99/99/9999").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estab W-Win
ON F5 OF c-cod-estab IN FRAME F-Main /* Estab */
DO:
  APPLY "CHOOSE" TO bt-zoom-estab IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estab W-Win
ON MOUSE-SELECT-DBLCLICK OF c-cod-estab IN FRAME F-Main /* Estab */
DO:
  APPLY "CHOOSE" TO bt-zoom-estab IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-cod-parcela
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-parcela W-Win
ON LEAVE OF c-cod-parcela IN FRAME F-Main
DO:
    DEFINE BUFFER b_tit_acr_enter FOR tit_acr.

    find b_tit_acr_enter no-lock
         where b_tit_acr_enter.cod_estab       = input frame {&FRAME-NAME} c-cod-estab
           and b_tit_acr_enter.cod_espec_docto = input frame {&FRAME-NAME} c-cod-espec-docto
           and b_tit_acr_enter.cod_ser_docto   = input frame {&FRAME-NAME} c-cod-ser-docto
           and b_tit_acr_enter.cod_tit_acr     = input frame {&FRAME-NAME} c-cod-tit-acr
           and b_tit_acr_enter.cod_parcela     = input frame {&FRAME-NAME} c-cod-parcela

    &if '{&emsfin_version}' >= "5.01" &then
         use-index titacr_id
    &endif
          /* cl_key_enter of b_tit_acr_enter*/ no-error.
    if  avail b_tit_acr_enter then do:
        assign v_rec_table = recid(b_tit_acr_enter).
        run pi_disp_fields /*pi_disp_fields*/.
    END.
    ELSE DO:
        assign v_rec_table = ?.
        run pi_disp_fields.
    END.

    EMPTY TEMP-TABLE tt-tit-acr.
    EMPTY TEMP-TABLE tt-tit-acr-sel.

    {&OPEN-QUERY-BR-TIT-ACR}
    {&OPEN-QUERY-BR-TIT-ACR-SEL}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-cod-ser-docto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-ser-docto W-Win
ON F5 OF c-cod-ser-docto IN FRAME F-Main /* SÇrie */
DO:
  APPLY "CHOOSE" TO bt-zoom-ser IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-ser-docto W-Win
ON MOUSE-SELECT-DBLCLICK OF c-cod-ser-docto IN FRAME F-Main /* SÇrie */
DO:
  APPLY "CHOOSE" TO bt-zoom-ser IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-cod-tit-acr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-tit-acr W-Win
ON LEAVE OF c-cod-tit-acr IN FRAME F-Main /* T°tulo */
DO:
    DEFINE BUFFER b_tit_acr_enter FOR tit_acr.

    IF  input frame {&FRAME-NAME} c-cod-estab        <> "" AND
        input frame {&FRAME-NAME} c-cod-espec-docto  <> "" AND
        input frame {&FRAME-NAME} c-cod-ser-docto    <> "" AND
        input frame {&FRAME-NAME} c-cod-tit-acr      <> "" AND
        input frame {&FRAME-NAME} c-cod-parcela      <> "" THEN DO:


        find b_tit_acr_enter no-lock
             where b_tit_acr_enter.cod_estab       = input frame {&FRAME-NAME} c-cod-estab
               and b_tit_acr_enter.cod_espec_docto = input frame {&FRAME-NAME} c-cod-espec-docto
               and b_tit_acr_enter.cod_ser_docto   = input frame {&FRAME-NAME} c-cod-ser-docto
               and b_tit_acr_enter.cod_tit_acr     = input frame {&FRAME-NAME} c-cod-tit-acr
               and b_tit_acr_enter.cod_parcela     = input frame {&FRAME-NAME} c-cod-parcela
    
        &if '{&emsfin_version}' >= "5.01" &then
             use-index titacr_id
        &endif
              /* cl_key_enter of b_tit_acr_enter*/ no-error.
        if  avail b_tit_acr_enter then do:
            assign v_rec_table = recid(b_tit_acr_enter).
            run pi_disp_fields /*pi_disp_fields*/.
        END.
        ELSE DO:
            assign v_rec_table = ?.
            run pi_disp_fields.
        END.
    
        EMPTY TEMP-TABLE tt-tit-acr.
        EMPTY TEMP-TABLE tt-tit-acr-sel.
    
        {&OPEN-QUERY-BR-TIT-ACR}
        {&OPEN-QUERY-BR-TIT-ACR-SEL}
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-tit-acr
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK W-Win 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

ASSIGN fi-data-emis:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = STRING(TODAY,"99/99/9999").
ASSIGN fi-data-vencto:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(TODAY,"99/99/9999").

RUN pi-inicializar.

/* ASSIGN fi-dt-emis:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(TODAY,"99/99/9999"). */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects W-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available W-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI W-Win  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(W-Win)
  THEN DELETE WIDGET W-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI W-Win  _DEFAULT-ENABLE
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
  DISPLAY c-cod-estab c-cod-espec-docto c-cod-ser-docto c-cod-tit-acr 
          c-cod-parcela c-cod-cliente fi-nome-cliente c-num-renegoc fi-convenio 
          c-saldo-tit-acr fi-data-emis fi-data-vencto 
      WITH FRAME F-Main IN WINDOW W-Win.
  ENABLE RECT-1 RECT-2 rt-button RECT-3 c-cod-estab bt-zoom-estab 
         c-cod-espec-docto bt-zoom-espec c-cod-ser-docto bt-zoom-ser 
         c-cod-tit-acr c-cod-parcela bt-zoom-ser-2 BUTTON-4 fi-data-emis 
         fi-data-vencto br-tit-acr bt-filtro bt-incluir br-tit-acr-sel 
         bt-filtro-sel bt-marca-sel bt-desmarca-sel bt-excluir bt-soma 
         bt-executar bt-cancelar 
      WITH FRAME F-Main IN WINDOW W-Win.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
  VIEW W-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit W-Win 
PROCEDURE local-exit :
/* -----------------------------------------------------------
  Purpose:  Starts an "exit" by APPLYing CLOSE event, which starts "destroy".
  Parameters:  <none>
  Notes:    If activated, should APPLY CLOSE, *not* dispatch adm-exit.   
-------------------------------------------------------------*/
   APPLY "CLOSE":U TO THIS-PROCEDURE.
   
   RETURN.
       
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carrega-titulo-filtro W-Win 
PROCEDURE pi-carrega-titulo-filtro :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FOR EACH tt-tit-acr:
    ASSIGN tt-tit-acr.filtro = NO
           .
END.

FOR EACH tt-tit-acr
   WHERE tt-tit-acr.cod_estab          >= c-estab-ini  
     AND tt-tit-acr.cod_estab          <= c-estab-fim  
     AND tt-tit-acr.cod_espec_docto    >= c-especie-ini
     AND tt-tit-acr.cod_espec_docto    <= c-especie-fim
     AND tt-tit-acr.cod_ser_docto      >= c-serie-ini  
     AND tt-tit-acr.cod_ser_docto      <= c-serie-fim  
     AND tt-tit-acr.cod_tit_acr        >= c-titulo-ini 
     AND tt-tit-acr.cod_tit_acr        <= c-titulo-fim 
     AND tt-tit-acr.dat_emis           >= c-data-ini   
     AND tt-tit-acr.dat_emis           <= c-data-fim 
     AND tt-tit-acr.dat_vencto_tit_acr >= c-venc-ini 
     AND tt-tit-acr.dat_vencto_tit_acr <= c-venc-fim    NO-LOCK:

    ASSIGN tt-tit-acr.filtro = YES.

END.

{&OPEN-QUERY-br-tit-acr}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carrega-titulo-sel-filtro W-Win 
PROCEDURE pi-carrega-titulo-sel-filtro :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FOR EACH tt-tit-acr-sel:
    ASSIGN tt-tit-acr-sel.filtro = NO
           .
END.

FOR EACH tt-tit-acr-sel
   WHERE tt-tit-acr-sel.cod_estab          >= c-estab-ini-sel
     AND tt-tit-acr-sel.cod_estab          <= c-estab-fim-sel  
     AND tt-tit-acr-sel.cod_espec_docto    >= c-especie-ini-sel
     AND tt-tit-acr-sel.cod_espec_docto    <= c-especie-fim-sel
     AND tt-tit-acr-sel.cod_ser_docto      >= c-serie-ini-sel  
     AND tt-tit-acr-sel.cod_ser_docto      <= c-serie-fim-sel  
     AND tt-tit-acr-sel.cod_tit_acr        >= c-titulo-ini-sel 
     AND tt-tit-acr-sel.cod_tit_acr        <= c-titulo-fim-sel 
     AND tt-tit-acr-sel.dat_emis           >= c-data-ini-sel   
     AND tt-tit-acr-sel.dat_emis           <= c-data-fim-sel
     AND tt-tit-acr-sel.dat_vencto_tit_acr >= c-venc-ini-sel 
     AND tt-tit-acr-sel.dat_vencto_tit_acr <= c-venc-fim-sel   NO-LOCK:

    ASSIGN tt-tit-acr-sel.filtro = YES.

END.

{&OPEN-QUERY-br-tit-acr-sel}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carrega-titulos W-Win 
PROCEDURE pi-carrega-titulos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* EMPTY TEMP-TABLE tt-tit-acr.                                                         */
/* EMPTY TEMP-TABLE tt-tit-acr-sel.                                                     */
/*                                                                                      */
/* {&OPEN-QUERY-BR-TIT-ACR}                                                             */
/* {&OPEN-QUERY-BR-TIT-ACR-SEL}                                                         */
/*                                                                                      */
/* FOR EACH tit_acr NO-LOCK USE-INDEX titacr_cliente                                    */
/*    WHERE tit_acr.cdn_cliente = INPUT FRAME {&FRAME-NAME} fi-cliente                  */
/*      AND tit_acr.cod_espec_docto = "CV"                                              */
/*      AND tit_acr.log_sdo_tit_acr = YES,                                              */
/*    FIRST cst_nota_fiscal NO-LOCK                                                     */
/*    WHERE cst_nota_fiscal.cod-estabel = tit_acr.cod_estab                             */
/*      AND cst_nota_fiscal.serie       = tit_acr.cod_ser_docto                         */
/*      AND cst_nota_fiscal.nr-nota-fis = tit_acr.cod_tit_acr                           */
/*      AND cst_nota_fiscal.convenio    = INPUT FRAME {&FRAME-NAME} cb-convenio:        */
/*                                                                                      */
/*                                                                                      */
/*     FIND FIRST tt-tit-acr NO-LOCK                                                    */
/*          WHERE tt-tit-acr.cod_estab       = tit_acr.cod_estab                        */
/*            AND tt-tit-acr.cod_espec_docto = tit_acr.cod_espec_docto                  */
/*            AND tt-tit-acr.cod_ser_docto   = tit_acr.cod_ser_docto                    */
/*            AND tt-tit-acr.cod_tit_acr     = tit_acr.cod_tit_acr                      */
/*            AND tt-tit-acr.cod_parcela     = tit_acr.cod_parcela   NO-ERROR.          */
/*     IF NOT AVAIL tt-tit-acr THEN DO:                                                 */
/*         CREATE tt-tit-acr.                                                           */
/*         BUFFER-COPY tit_acr TO tt-tit-acr.                                           */
/*         ASSIGN tt-tit-acr.mostra = YES                                               */
/*                tt-tit-acr.filtro = YES.                                              */
/*                                                                                      */
/*         FIND FIRST emitente NO-LOCK                                                  */
/*              WHERE emitente.cod-emitente = tit_acr.cdn_cliente NO-ERROR.             */
/*         IF AVAIL emitente THEN DO:                                                   */
/*             ASSIGN tt-tit-acr.razao-social = emitente.nome-emit.                     */
/*         END.                                                                         */
/*     END.                                                                             */
/*                                                                                      */
/* END.                                                                                 */
/*                                                                                      */
/* FIND FIRST bf-emitente NO-LOCK                                                       */
/*      WHERE bf-emitente.cod-emitente = INPUT FRAME {&FRAME-NAME} fi-cliente NO-ERROR. */
/* IF AVAIL bf-emitente THEN DO:                                                        */
/*                                                                                      */
/*     FOR EACH tit_acr NO-LOCK USE-INDEX titacr_cliente                                */
/*        WHERE tit_acr.cod_espec_docto = "CV"                                          */
/*          AND tit_acr.log_sdo_tit_acr = YES,                                          */
/*        FIRST cst_nota_fiscal NO-LOCK                                                 */
/*        WHERE cst_nota_fiscal.cod-estabel = tit_acr.cod_estab                         */
/*          AND cst_nota_fiscal.serie       = tit_acr.cod_ser_docto                     */
/*          AND cst_nota_fiscal.nr-nota-fis = tit_acr.cod_tit_acr                       */
/*          AND cst_nota_fiscal.convenio    = INPUT FRAME {&FRAME-NAME} cb-convenio,    */
/*        FIRST emitente                                                                */
/*        WHERE emitente.cod-emitente = tit_acr.cdn_cliente                             */
/* /*          AND emitente.nome-matriz = bf-emitente.nome-abrev */                     */
/*         :                                                                            */
/*                                                                                      */
/*         FIND FIRST tt-tit-acr NO-LOCK                                                */
/*          WHERE tt-tit-acr.cod_estab       = tit_acr.cod_estab                        */
/*            AND tt-tit-acr.cod_espec_docto = tit_acr.cod_espec_docto                  */
/*            AND tt-tit-acr.cod_ser_docto   = tit_acr.cod_ser_docto                    */
/*            AND tt-tit-acr.cod_tit_acr     = tit_acr.cod_tit_acr                      */
/*            AND tt-tit-acr.cod_parcela     = tit_acr.cod_parcela   NO-ERROR.          */
/*         IF NOT AVAIL tt-tit-acr THEN DO:                                             */
/*             CREATE tt-tit-acr.                                                       */
/*             BUFFER-COPY tit_acr TO tt-tit-acr.                                       */
/*             ASSIGN tt-tit-acr.mostra = YES                                           */
/*                    tt-tit-acr.filtro = YES.                                          */
/*             ASSIGN tt-tit-acr.razao-social = emitente.nome-emit.                     */
/*         END.                                                                         */
/*                                                                                      */
/*     END.                                                                             */
/* END.                                                                                 */
/*                                                                                      */
/*                                                                                      */
/* {&OPEN-QUERY-BR-TIT-ACR}                                                             */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cria-titulo-acr W-Win 
PROCEDURE pi-cria-titulo-acr :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* DEFINE BUFFER b_tit_acr FOR tit_acr.                                                                                      */
/*                                                                                                                           */
/* DEFINE VARIABLE i-cod-titulo AS INTEGER     NO-UNDO.                                                                      */
/*                                                                                                                           */
/* DO TRANSACTION:                                                                                                           */
/*                                                                                                                           */
/*         RUN utp/ut-acomp.p PERSISTENT SET h-acomp.                                                                        */
/*                                                                                                                           */
/*         RUN pi-inicializar IN h-acomp ("Aguarde, Gerando T≠tulo...").                                                     */
/*                                                                                                                           */
/*         EMPTY TEMP-TABLE tt_integr_acr_lote_impl        NO-ERROR.                                                         */
/*         EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl_4 NO-ERROR.                                                         */
/*         EMPTY TEMP-TABLE tt_log_erros_atualiz           NO-ERROR.                                                         */
/*         EMPTY TEMP-TABLE tt_integr_acr_aprop_ctbl_pend  NO-ERROR.                                                         */
/*                                                                                                                           */
/*         ASSIGN c_cod_table = "lote_impl_tit_acr".                                                                         */
/*         RUN pi-retorna-sugestao-referencia (INPUT  "ACR",                                                                 */
/*                                             INPUT  TODAY,                                                                 */
/*                                             OUTPUT c-cod-refer,                                                           */
/*                                             INPUT  c_cod_table,                                                           */
/*                                             INPUT  INPUT FRAME {&FRAME-NAME} fi-estab).                                   */
/*                                                                                                                           */
/*         FIND LAST b_tit_acr NO-LOCK                                                                                       */
/*             WHERE b_tit_acr.cod_estab       = INPUT FRAME {&FRAME-NAME} fi-estab                                          */
/*               AND b_tit_acr.cod_espec_docto = "CF"                                                                        */
/*               AND b_tit_acr.cod_ser_docto   = "015" NO-ERROR.                                                             */
/*         IF AVAIL b_tit_acr THEN                                                                                           */
/*             ASSIGN i-cod-titulo = i-cod-titulo + (INT(b_tit_acr.cod_tit_acr) + 1).                                        */
/*         ELSE                                                                                                              */
/*             ASSIGN i-cod-titulo = 1.                                                                                      */
/*                                                                                                                           */
/*         CREATE tt_integr_acr_item_lote_impl_4.                                                                            */
/*         ASSIGN tt_integr_acr_item_lote_impl_4.ttv_rec_lote_impl_tit_acr        = RECID(tt_integr_acr_lote_impl)           */
/*                tt_integr_acr_item_lote_impl_4.tta_num_seq_refer                = 10                                       */
/*                tt_integr_acr_item_lote_impl_4.tta_cdn_cliente                  = INPUT FRAME {&FRAME-NAME} fi-cliente     */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_espec_docto              = "CF"                                     */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_ser_docto                = "015"                                    */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_tit_acr                  = STRING(i-cod-titulo)                     */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_parcela                  = "1"                                      */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_indic_econ               = "Real"                                   */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_portador                 = "99501"                                  */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_cart_bcia                = "COB"                                    */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_cond_cobr                = ""                                       */
/*                tt_integr_acr_item_lote_impl_4.tta_cdn_repres                   = 0                                        */
/*                tt_integr_acr_item_lote_impl_4.tta_dat_vencto_tit_acr           = TODAY                                    */
/*                tt_integr_acr_item_lote_impl_4.tta_dat_prev_liquidac            = TODAY                                    */
/*                tt_integr_acr_item_lote_impl_4.tta_dat_desconto                 = ?                                        */
/*                tt_integr_acr_item_lote_impl_4.tta_dat_emis_docto               = TODAY.                                   */
/*          ASSIGN      tt_integr_acr_item_lote_impl_4.tta_val_perc_desc                = 0                                  */
/*                tt_integr_acr_item_lote_impl_4.tta_val_perc_juros_dia_atraso    = 0                                        */
/*                tt_integr_acr_item_lote_impl_4.tta_val_perc_multa_atraso        = 0                                        */
/*                tt_integr_acr_item_lote_impl_4.tta_qtd_dias_carenc_multa_acr    = 0                                        */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_banco                    = /*tit_acr.cod_banco*/ ""                 */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_agenc_bcia               = /*tit_acr.cod_agenc_bcia   */ ""         */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_cta_corren_bco           = /*tit_acr.cod_cta_corren_bco*/ ""        */
/*                tt_integr_acr_item_lote_impl_4.tta_cod_digito_cta_corren        = /*tit_acr.cod_digito_cta_corren   */ ""  */
/*                tt_integr_acr_item_lote_impl_4.tta_qtd_dias_carenc_juros_acr    = 0                                        */
/*                tt_integr_acr_item_lote_impl_4.tta_ind_tip_espec_docto          = "".                                      */
/*                                                                                                                           */
/*         FIND FIRST tt_integr_acr_lote_impl        NO-ERROR.                                                               */
/*         FIND FIRST tt_integr_acr_item_lote_impl_4 NO-ERROR.                                                               */
/*         FIND FIRST tt_integr_acr_aprop_ctbl_pend  NO-ERROR.                                                               */
/*         FIND FIRST tt_integr_acr_repres_pend      NO-ERROR.                                                               */
/*         RUN prgfin/acr/acr900zf.py (INPUT 6,                                                                              */
/*                                     INPUT "",                                                                             */
/*                                     INPUT YES,                                                                            */
/*                                     INPUT NO,                                                                             */
/*                                     INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl_4).                                   */
/*                                                                                                                           */
/*         RUN pi-finalizar IN h-acomp.                                                                                      */
/*                                                                                                                           */
/*         EMPTY TEMP-TABLE tt-log NO-ERROR.                                                                                 */
/*         FIND FIRST tt_log_erros_atualiz NO-ERROR.                                                                         */
/*         IF AVAIL tt_log_erros_atualiz THEN DO:                                                                            */
/*                                                                                                                           */
/*             FIND FIRST tt_integr_acr_item_lote_impl_4 NO-ERROR.                                                           */
/*             FOR EACH tt_log_erros_atualiz:                                                                                */
/*                                                                                                                           */
/*                  CREATE tt-log.                                                                                           */
/*                  ASSIGN tt-log.cod_estab       = tit_acr.cod_estab                                                        */
/*                         tt-log.cod_espec_docto = tt_integr_acr_item_lote_impl_4.tta_cod_espec_docto                       */
/*                         tt-log.cod_ser_docto   = tt_integr_acr_item_lote_impl_4.tta_cod_ser_docto                         */
/*                         tt-log.cod_tit_acr     = tt_integr_acr_item_lote_impl_4.tta_cod_tit_acr                           */
/*                         tt-log.cod_parcela     = tt_integr_acr_item_lote_impl_4.tta_cod_parcela                           */
/*                         tt-log.val_receber     = tit_acr.val_sdo_tit_acr                                                  */
/*                         tt-log.num_erro_log    = tt_log_erros_atualiz.ttv_num_relacto                                     */
/*                         tt-log.des_msg_erro    = tt_log_erros_atualiz.ttv_des_msg_ajuda.                                  */
/*                                                                                                                           */
/*                  MESSAGE tt-log.num_erro_log " - " tt-log.des_msg_erro                                                    */
/*                      VIEW-AS ALERT-BOX INFO BUTTONS OK.                                                                   */
/*             END.                                                                                                          */
/*         END.                                                                                                              */
/*         ELSE DO:                                                                                                          */
/* /*              RUN pi-acerto-valores (INPUT TABLE tt-gera-movto, */                                                      */
/* /*                                    OUTPUT TABLE tt-log).       */                                                      */
/*             FIND FIRST tt-log NO-ERROR.                                                                                   */
/*              IF AVAIL tt-log THEN                                                                                         */
/*                  UNDO, LEAVE.                                                                                             */
/*              ELSE DO:                                                                                                     */
/*                  FIND FIRST tt_integr_acr_item_lote_impl_4 NO-ERROR.                                                      */
/*                                                                                                                           */
/*                  MESSAGE "Titulo Criado com Sucesso" SKIP                                                                 */
/*                          tt_integr_acr_item_lote_impl_4.tta_cod_espec_docto SKIP                                          */
/*                          tt_integr_acr_item_lote_impl_4.tta_cod_ser_docto   SKIP                                          */
/*                          tt_integr_acr_item_lote_impl_4.tta_cod_tit_acr     SKIP                                          */
/*                          tt_integr_acr_item_lote_impl_4.tta_cod_parcela                                                   */
/*                      VIEW-AS ALERT-BOX INFO BUTTONS OK.                                                                   */
/*              END.                                                                                                         */
/*                                                                                                                           */
/*                                                                                                                           */
/*         END.                                                                                                              */
/*                                                                                                                           */
/* END.                                                                                                                      */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cria-tt-erro-aux W-Win 
PROCEDURE pi-cria-tt-erro-aux :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER p-i-sequen    AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER p-cd-erro     AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER p-mensagem    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER p-ajuda       AS CHARACTER NO-UNDO.

    CREATE tt-erro-aux.
    ASSIGN tt-erro-aux.i-sequen    = p-i-sequen
           tt-erro-aux.cd-erro     = p-cd-erro 
           tt-erro-aux.mensagem    = p-mensagem
           .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-executar W-Win 
PROCEDURE pi-executar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    RUN piValidaInformacoes.

    EMPTY TEMP-TABLE tt-tit-criados.

    IF RETURN-VALUE <> "NOK" THEN DO:
        RUN piSalvaInformacoes.
        RUN piEstonaFaturaAtual.

        IF RETURN-VALUE <> "NOK" THEN DO:
            RUN piGeraFaturaConvenio.
        END.
    END.

    IF CAN-FIND(FIRST  tt-erro-aux) THEN DO: 
        RUN cdp/cd0666.w (INPUT TABLE tt-erro-aux). 
    END.
    ELSE DO:
        IF CAN-FIND(FIRST tt-tit-criados) THEN DO:
            FOR EACH tt-tit-criados :
                RUN utp/ut-msgs.p (INPUT "show":U,
                                   INPUT 15825,
                                   INPUT "Fatura foi gerada com sucesso.Foi gerado o t°tulo abaixo:~~" + 
                                         "Estab/Especie/Serie/Titulo/Parcela/Cliente/Valor : " +  STRING(tt-tit-criados.cod_estab) + "/" +
                                                                                                  STRING(tt-tit-criados.cod_espec_docto) + "/" +
                                                                                                  STRING(tt-tit-criados.cod_ser_docto) + "/" +
                                                                                                  STRING(tt-tit-criados.cod_tit_acr) + "/" +
                                                                                                  STRING(tt-tit-criados.cod_parcela) + "/" +
                                                                                                  STRING(tt-tit-criados.cdn_cliente) + "/" +
                                                                                                  STRING(tt-tit-criados.val_origin_tit_acr)).
            END.

            EMPTY TEMP-TABLE tt-tit-acr.
            EMPTY TEMP-TABLE tt-tit-acr-sel.
            
            {&OPEN-QUERY-BR-TIT-ACR}
            {&OPEN-QUERY-BR-TIT-ACR-SEL}
        END.
    END.



/*     EMPTY TEMP-TABLE tt-param-nicr003a.                                                      */
/*     EMPTY TEMP-TABLE tt-digita-nicr003a.                                                     */
/*                                                                                              */
/*     CREATE tt-param-nicr003a.                                                                */
/*     ASSIGN tt-param-nicr003a.destino       = 3                                               */
/*            tt-param-nicr003a.arquivo       = session:temp-directory + "NICR003A":U + ".tmp"  */
/*            tt-param-nicr003a.usuario       = c-seg-usuario                                   */
/*            tt-param-nicr003a.data-exec     = TODAY                                           */
/*            tt-param-nicr003a.hora-exec     = TIME.                                           */
/*                                                                                              */
/*     ASSIGN tt-param-nicr003a.c-estab       = INPUT FRAME {&FRAME-NAME} fi-estab              */
/*            tt-param-nicr003a.c-dt-emissao  = INPUT FRAME {&FRAME-NAME} fi-dt-emis.           */
/*                                                                                              */
/*     IF INPUT FRAME {&FRAME-NAME} tg-escolhe = YES THEN DO:                                   */
/*         ASSIGN tt-param-nicr003a.c-cliente-ini = INPUT FRAME {&FRAME-NAME} fi-cliente        */
/*                tt-param-nicr003a.c-cliente-fim = INPUT FRAME {&FRAME-NAME} fi-cliente.       */
/*     END.                                                                                     */
/*     ELSE DO:                                                                                 */
/*         ASSIGN tt-param-nicr003a.c-cliente-ini = INPUT FRAME {&FRAME-NAME} fi-cliente-ini    */
/*                tt-param-nicr003a.c-cliente-fim = INPUT FRAME {&FRAME-NAME} fi-cliente-fim.   */
/*     END.                                                                                     */
/*                                                                                              */
/*     ASSIGN tt-param-nicr003a.c-convenio = INPUT FRAME {&FRAME-NAME} cb-convenio.             */
/*                                                                                              */
/*     IF CAN-FIND(FIRST tt-tit-acr-sel) THEN DO:                                               */
/*         FOR EACH tt-tit-acr-sel NO-LOCK:                                                     */
/*                                                                                              */
/*             CREATE tt-digita-nicr003a.                                                       */
/*             ASSIGN tt-digita-nicr003a.cod_estab       =  tt-tit-acr-sel.cod_estab            */
/*                    tt-digita-nicr003a.cod_espec_docto =  tt-tit-acr-sel.cod_espec_docto      */
/*                    tt-digita-nicr003a.cod_ser_docto   =  tt-tit-acr-sel.cod_ser_docto        */
/*                    tt-digita-nicr003a.cod_tit_acr     =  tt-tit-acr-sel.cod_tit_acr          */
/*                    tt-digita-nicr003a.cod_parcela     =  tt-tit-acr-sel.cod_parcela.         */
/*         END.                                                                                 */
/*     END.                                                                                     */
/*                                                                                              */
/*     RAW-TRANSFER tt-param-nicr003a    to raw-param-nicr003a.                                 */
/*                                                                                              */
/*     FOR EACH tt-raw-digita-nicr003a:                                                         */
/*         DELETE tt-raw-digita-nicr003a.                                                       */
/*     END.                                                                                     */
/*                                                                                              */
/*     FOR EACH tt-digita-nicr003a:                                                             */
/*         CREATE tt-raw-digita-nicr003a.                                                       */
/*         RAW-TRANSFER tt-digita-nicr003a TO tt-raw-digita-nicr003a.raw-digita.                */
/*     END.                                                                                     */
/*                                                                                              */
/*     RUN intprg/nicr003arp.p(INPUT raw-param-nicr003a,                                        */
/*                             INPUT TABLE tt-raw-digita-nicr003a).                             */
/*                                                                                              */
/*                                                                                              */
/*     IF c-gerou-erro = NO THEN DO:                                                            */
/*         ASSIGN tg-escolhe:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "NO".                        */
/*         APPLY "VALUE-CHANGED" TO tg-escolhe IN FRAME {&FRAME-NAME}.                          */
/*     END.                                                                                     */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-convenio-cliente W-Win 
PROCEDURE pi-gera-convenio-cliente :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* IF INPUT FRAME {&FRAME-NAME} fi-dt-emis = ? THEN DO:                                                        */
/*             run utp/ut-msgs.p (input "show":U,                                                              */
/*                                input 17006,                                                                 */
/*                                input "Data Emiss∆o Inv†lida!~~Favor informar uma data de Emiss∆o V†lida!"). */
/*             apply "ENTRY":U to fi-dt-emis in frame {&FRAME-NAME}.                                           */
/*             return error.                                                                                   */
/* END.                                                                                                        */
/*                                                                                                             */
/* RUN pi-cria-titulo-acr.                                                                                     */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-inicializar W-Win 
PROCEDURE pi-inicializar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* ASSIGN tg-escolhe:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "NO". */
/*                                                               */
/* APPLY "VALUE-CHANGED" TO tg-escolhe IN FRAME {&FRAME-NAME}.   */
ASSIGN fi-data-emis:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = STRING(TODAY,"99/99/9999").
ASSIGN fi-data-vencto:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(TODAY,"99/99/9999").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-retorna-digito-verificador-bradesco W-Win 
PROCEDURE pi-retorna-digito-verificador-bradesco :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEF INPUT  PARAM p-carteira           AS CHAR.
    DEF INPUT  PARAM p-nosso-numero       AS CHAR.
    DEF OUTPUT PARAM p-digito-verificador AS CHAR.

    DEF VAR i-valor01          AS INTEGER NO-UNDO.
    DEF VAR i-valor02          AS INTEGER NO-UNDO.
    DEF VAR i-valor03          AS INTEGER NO-UNDO.
    DEF VAR i-valor04          AS INTEGER NO-UNDO.
    DEF VAR i-valor05          AS INTEGER NO-UNDO.
    DEF VAR i-valor06          AS INTEGER NO-UNDO.
    DEF VAR i-valor07          AS INTEGER NO-UNDO.
    DEF VAR i-valor08          AS INTEGER NO-UNDO.
    DEF VAR i-valor09          AS INTEGER NO-UNDO.
    DEF VAR i-valor10          AS INTEGER NO-UNDO.
    DEF VAR i-valor11          AS INTEGER NO-UNDO.
    DEF VAR i-valor12          AS INTEGER NO-UNDO.
    DEF VAR i-valor13          AS INTEGER NO-UNDO.
    DEF VAR i-soma             AS INTEGER NO-UNDO.
    DEF VAR i-resto            AS INTEGER NO-UNDO.
    
    ASSIGN i-valor01 = 2 * INTEGER(SUBSTRING(p-carteira    ,01,1))
           i-valor02 = 7 * INTEGER(SUBSTRING(p-carteira    ,02,1))
           i-valor03 = 6 * INTEGER(SUBSTRING(p-nosso-numero,01,1))
           i-valor04 = 5 * INTEGER(SUBSTRING(p-nosso-numero,02,1))
           i-valor05 = 4 * INTEGER(SUBSTRING(p-nosso-numero,03,1))
           i-valor06 = 3 * INTEGER(SUBSTRING(p-nosso-numero,04,1))
           i-valor07 = 2 * INTEGER(SUBSTRING(p-nosso-numero,05,1))
           i-valor08 = 7 * INTEGER(SUBSTRING(p-nosso-numero,06,1))
           i-valor09 = 6 * INTEGER(SUBSTRING(p-nosso-numero,07,1))
           i-valor10 = 5 * INTEGER(SUBSTRING(p-nosso-numero,08,1))
           i-valor11 = 4 * INTEGER(SUBSTRING(p-nosso-numero,09,1))
           i-valor12 = 3 * INTEGER(SUBSTRING(p-nosso-numero,10,1))
           i-valor13 = 2 * INTEGER(SUBSTRING(p-nosso-numero,11,1)).

    ASSIGN i-soma = i-valor01 + i-valor02 + i-valor03 + i-valor04 + i-valor05 + i-valor06 + i-valor07 + 
                    i-valor08 + i-valor09 + i-valor10 + i-valor11 + i-valor12 + i-valor13.

    /* fut1074 - 08/06/2004 */
    /* Validar antes se resto da divisao for zero, entao considera 0 como digito */

    IF (i-soma MODULO 11) = 0 THEN DO:
        ASSIGN p-digito-verificador = "0".
    END.
    ELSE DO:
        ASSIGN i-resto = 11 - (i-soma MODULO 11).
        
        IF i-resto = 10 THEN
           ASSIGN p-digito-verificador = 'P'.
        ELSE
           ASSIGN p-digito-verificador = STRING(i-resto).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-retorna-sugestao-referencia W-Win 
PROCEDURE pi-retorna-sugestao-referencia :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /************************ Parameter Definition Begin ************************/
    DEF INPUT  PARAM p_ind_tip_atualiz AS CHAR FORMAT "X(08)"      NO-UNDO.
    DEF INPUT  PARAM p_dat_refer       AS DATE FORMAT "99/99/9999" NO-UNDO.
    DEF OUTPUT PARAM p_cod_refer       AS CHAR FORMAT "x(10)"      NO-UNDO.
    DEF INPUT  PARAM p_cod_table       AS CHAR FORMAT "x(8)"       NO-UNDO.
    DEF INPUT  PARAM p_estabel         AS CHAR FORMAT "x(3)"       NO-UNDO.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    DEF VAR v_des_dat   AS CHAR NO-UNDO. /*local*/
    DEF VAR v_num_aux   AS INT  NO-UNDO. /*local*/
    DEF VAR v_num_aux_2 AS INT  NO-UNDO. /*local*/
    DEF VAR v_num_cont  AS INT  NO-UNDO. /*local*/

    /************************** Variable Definition End *************************/

    ASSIGN v_des_dat   = STRING(p_dat_refer,"99999999")
           p_cod_refer = SUBSTRING(p_ind_tip_atualiz,1,2) + SUBSTRING(v_des_dat,7,2)
                       + SUBSTRING(v_des_dat,3,2) + SUBSTRING(v_des_dat,1,2)
           v_num_aux_2 = INT(this-PROCEDURE:HANDLE).

    DO v_num_cont = 1 TO 2:
        ASSIGN v_num_aux   = (RANDOM(0,v_num_aux_2) MOD 26) + 97
               p_cod_refer = p_cod_refer + CHR(v_num_aux).
    END.
    
    RUN pi-verifica-refer-unica-acr (INPUT p_estabel,
                                     INPUT p_cod_refer,
                                     INPUT p_cod_table,
                                     INPUT ?,
                                     OUTPUT v_log_refer_uni) /*pi-verifica-refer-unica-acr*/.

    IF v_log_refer_uni = NO THEN
            RUN pi-retorna-sugestao-referencia (INPUT  "BP",
                                                INPUT  TODAY,
                                                OUTPUT p_cod_refer,
                                                INPUT  p_cod_table,
                                                INPUT  p_estabel).
    
END PROCEDURE. /* pi_retorna_sugestao_referencia */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-verifica-refer-unica-acr W-Win 
PROCEDURE pi-verifica-refer-unica-acr :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    /************************ Parameter Definition Begin ************************/

    DEF INPUT  PARAM p_cod_estab     AS CHAR FORMAT "x(3)"    NO-UNDO.
    DEF INPUT  PARAM p_cod_refer     AS CHAR FORMAT "x(10)"   NO-UNDO.
    DEF INPUT  PARAM p_cod_table     AS CHAR FORMAT "x(8)"    NO-UNDO.
    DEF INPUT  PARAM p_rec_tabela    AS RECID     FORMAT ">>>>>>9" NO-UNDO.
    DEF OUTPUT PARAM p_log_refer_uni AS LOGICAL   FORMAT "Sim/Nao" NO-UNDO.

    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    DEF BUFFER b_cobr_especial_acr FOR cobr_especial_acr.
    DEF BUFFER b_lote_impl_tit_acr FOR lote_impl_tit_acr.
    DEF BUFFER b_lote_liquidac_acr FOR lote_liquidac_acr.
    DEF BUFFER b_movto_tit_acr     FOR movto_tit_acr.
    DEF BUFFER b_renegoc_acr       FOR renegoc_acr.

    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    DEF VAR v_cod_return AS CHAR FORMAT "x(40)" NO-UNDO.

    /************************** Variable Definition End *************************/

    ASSIGN p_log_refer_uni = YES.

    IF p_cod_table <> "lote_impl_tit_acr" /*l_lote_impl_tit_acr*/  THEN DO:
        FIND FIRST b_lote_impl_tit_acr NO-LOCK USE-INDEX ltmplttc_id
             WHERE b_lote_impl_tit_acr.cod_estab = p_cod_estab
               AND b_lote_impl_tit_acr.cod_refer = p_cod_refer
               AND RECID( b_lote_impl_tit_acr ) <> p_rec_tabela NO-ERROR.
        IF AVAIL b_lote_impl_tit_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_cod_table <> "lote_liquidac_acr" /*l_lote_liquidac_acr*/  THEN DO:
        FIND FIRST b_lote_liquidac_acr NO-LOCK USE-INDEX ltlqdccr_id
             where b_lote_liquidac_acr.cod_estab_refer = p_cod_estab
               and b_lote_liquidac_acr.cod_refer       = p_cod_refer
               and recid( b_lote_liquidac_acr )       <> p_rec_tabela NO-ERROR.
        IF AVAIL b_lote_liquidac_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_cod_table = 'cobr_especial_acr' THEN DO:
        FIND FIRST b_cobr_especial_acr NO-LOCK USE-INDEX cbrspclc_id
             WHERE b_cobr_especial_acr.cod_estab = p_cod_estab
               AND b_cobr_especial_acr.cod_refer = p_cod_refer
               AND RECID( b_cobr_especial_acr ) <> p_rec_tabela NO-ERROR.
        IF AVAIL b_cobr_especial_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_log_refer_uni = YES THEN DO:
        FIND FIRST b_renegoc_acr NO-LOCK
             WHERE b_renegoc_acr.cod_estab = p_cod_estab
               AND b_renegoc_acr.cod_refer = p_cod_refer
               AND RECID(b_renegoc_acr)   <> p_rec_tabela NO-ERROR.
        IF AVAIL b_renegoc_acr THEN
            ASSIGN p_log_refer_uni = NO.
        ELSE DO:
            FIND FIRST b_movto_tit_acr NO-LOCK USE-INDEX mvtttcr_refer
                 WHERE b_movto_tit_acr.cod_estab = p_cod_estab
                   AND b_movto_tit_acr.cod_refer = p_cod_refer
                   AND RECID(b_movto_tit_acr)   <> p_rec_tabela NO-ERROR.
            IF AVAIL b_movto_tit_acr THEN
                ASSIGN p_log_refer_uni = NO.
        END.
    END.

END PROCEDURE. /* pi_verifica_refer_unica_acr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piCarregaTitulosRenegociados W-Win 
PROCEDURE piCarregaTitulosRenegociados :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
EMPTY TEMP-TABLE tt-tit-acr.
EMPTY TEMP-TABLE tt-tit-acr-sel.

{&OPEN-QUERY-BR-TIT-ACR}
{&OPEN-QUERY-BR-TIT-ACR-SEL}

    FIND tit_acr WHERE RECID(tit_acr) = v_rec_table NO-LOCK NO-ERROR.

    IF AVAILABLE tit_acr THEN DO:

        FOR FIRST renegoc_acr
            WHERE renegoc_acr.num_renegoc_cobr = tit_acr.num_renegoc_cobr_acr NO-LOCK :
        
            FOR each estabelecimento no-lock
               where estabelecimento.cod_empresa = v_cod_empres_usuar,
                each movto_tit_acr no-lock
               where movto_tit_acr.cod_estab            = estabelecimento.cod_estab
                 and movto_tit_acr.cod_refer            = renegoc_acr.cod_refer
                 and movto_tit_acr.ind_trans_acr_abrev  = "LQRN" /*l_lqrn*/ 
                 and movto_tit_acr.cod_estab_proces_bxa = renegoc_acr.cod_estab,
               first tit_acr no-lock
               where tit_acr.cod_estab      = movto_tit_acr.cod_estab
                 AND tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr:

                FIND FIRST tt-tit-acr NO-LOCK
                     WHERE tt-tit-acr.cod_estab       = tit_acr.cod_estab
                       AND tt-tit-acr.cod_espec_docto = tit_acr.cod_espec_docto
                       AND tt-tit-acr.cod_ser_docto   = tit_acr.cod_ser_docto
                       AND tt-tit-acr.cod_tit_acr     = tit_acr.cod_tit_acr
                       AND tt-tit-acr.cod_parcela     = tit_acr.cod_parcela   NO-ERROR.
                IF NOT AVAIL tt-tit-acr THEN DO:

                    /* INICIO - Busca Codigo do Convànio */
                    FIND FIRST cst_nota_fiscal NO-LOCK
                         WHERE cst_nota_fiscal.cod_estabel = tit_acr.cod_estab
                           AND cst_nota_fiscal.serie       = tit_acr.cod_ser_docto
                           AND cst_nota_fiscal.nr_nota_fis = tit_acr.cod_tit_acr   NO-ERROR.
                    IF AVAIL cst_nota_fiscal THEN DO:
                        ASSIGN fi-convenio:SCREEN-VALUE IN FRAME {&FRAME-NAME} = cst_nota_fiscal.convenio.
                    END.
                    /* FIM    - Busca Codigo do Convànio */

                    CREATE tt-tit-acr.
                    BUFFER-COPY tit_acr TO tt-tit-acr.
                    ASSIGN tt-tit-acr.mostra = YES
                           tt-tit-acr.filtro = YES.
            
                    FIND FIRST emitente NO-LOCK
                         WHERE emitente.cod-emitente = tit_acr.cdn_cliente NO-ERROR.
                    IF AVAIL emitente THEN DO:
                        ASSIGN tt-tit-acr.razao-social = emitente.nome-emit.
                    END.
                END.
            END.
        END.
        /* Carrega Browse */
        {&OPEN-QUERY-BR-TIT-ACR}


    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piEstonaFaturaAtual W-Win 
PROCEDURE piEstonaFaturaAtual :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
IF cNumRenegoc <> 0 AND cNumRenegoc<> ? THEN DO:

    FIND FIRST renegoc_acr NO-LOCK
         WHERE renegoc_acr.num_renegoc_cobr_acr = cNumRenegoc NO-ERROR.
    IF AVAIL renegoc_acr THEN DO:

        RUN pi-retorna-sugestao-referencia(INPUT  "RE",
                                           INPUT  INPUT FRAME {&FRAME-NAME} fi-data-emis,
                                           OUTPUT c-cod-refer,
                                           INPUT  "renegociacao_acr",
                                           INPUT  STRING(renegoc_acr.cod_estab)).
    
        RUN prgfin/acr/acr718za.py (INPUT RECID(renegoc_acr),
                                    INPUT  TODAY,
                                    INPUT  c-cod-refer,
                                    INPUT  "Estorno Parcial da Fatura pelo NICR017.",
                                    OUTPUT table tt_log_erros_estorn_cancel).

        IF CAN-FIND(FIRST tt_log_erros_estorn_cancel) THEN DO:

            FOR EACH tt_log_erros_estorn_cancel:
                
                RUN pi-cria-tt-erro-aux(INPUT tt_log_erros_estorn_cancel.tta_num_id_tit_acr,
                                        INPUT tt_log_erros_estorn_cancel.ttv_num_mensagem,
                                        INPUT tt_log_erros_estorn_cancel.ttv_des_msg_erro + " " + tt_log_erros_estorn_cancel.ttv_des_msg_ajuda,
                                        INPUT tt_log_erros_estorn_cancel.ttv_des_msg_ajuda).
            END.

            RETURN "NOK".
        END.
        ELSE DO:
            FIND FIRST int_ds_fat_convenio EXCLUSIVE-LOCK
                 WHERE int_ds_fat_convenio.nro_fatura   = INPUT FRAME {&FRAME-NAME} c-cod-tit-acr  NO-ERROR.
            IF  AVAIL int_ds_fat_convenio THEN DO:
                ASSIGN int_ds_fat_convenio.tipo_movto         = 3 
                       int_ds_fat_convenio.situacao           = 1.
            END.
            RELEASE int_ds_fat_convenio.
        END.
    END.    

END.
ELSE DO:
    RUN pi-cria-tt-erro-aux(INPUT 1,
                            INPUT 17006,
                            INPUT "Numero da Renegociaá∆o Ç inv†lido!" + "Favor verificar o titulo informado pois o numero da renegociaá∆o Ç inv†lido",
                            INPUT "Favor verificar o titulo informado pois o numero da renegociaá∆o Ç inv†lido").
    RETURN "NOK".
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piGeraFaturaConvenio W-Win 
PROCEDURE piGeraFaturaConvenio :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE BUFFER b_renegoc_acr FOR renegoc_acr.
    DEFINE BUFFER bf_tit_acr FOR tit_acr.

    DEFINE VARIABLE iSeq        AS INTEGER     NO-UNDO.
    DEFINE VARIABLE codConvenio AS INTEGER     NO-UNDO.

    DEFINE VARIABLE i-num-reneg AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cod-refer AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE d-vl-total  AS DECIMAL     NO-UNDO.

    DEFINE VARIABLE digNossoNumero AS CHARACTER   NO-UNDO.

    EMPTY TEMP-TABLE tt_integr_acr_renegoc.      
    EMPTY TEMP-TABLE tt_integr_acr_item_renegoc.
    EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl.
    EMPTY TEMP-TABLE tt_integr_acr_fiador_renegoc.
    EMPTY TEMP-TABLE tt_pessoa_fisic_integr.     
    EMPTY TEMP-TABLE tt_pessoa_jurid_integr.
    EMPTY TEMP-TABLE tt_log_erros_renegoc_acr. 

    FIND FIRST int_ds_convenio NO-LOCK
         WHERE int_ds_convenio.cod_convenio = INT(INPUT FRAME {&FRAME-NAME} fi-convenio) NO-ERROR.

    FIND estabelecimento where estabelecimento.cod_estab = INPUT FRAME {&FRAME-NAME} c-cod-estab NO-LOCK NO-ERROR.
    IF AVAIL estabelecimento THEN DO:
        FIND LAST b_renegoc_acr USE-INDEX rngccr_id
            WHERE b_renegoc_acr.cod_estab = estabelecimento.cod_estab NO-LOCK NO-ERROR.
        IF AVAIL b_renegoc_acr THEN
             ASSIGN i-num-reneg = b_renegoc_acr.num_renegoc_cobr_acr + 1.
        ELSE ASSIGN i-num-reneg = 1.
    END.

    RUN pi-retorna-sugestao-referencia(Input  "RE",
                                       Input  TODAY,
                                       output c-cod-refer,
                                       Input  "renegociacao_acr",
                                       input  STRING(INPUT FRAME {&FRAME-NAME} c-cod-estab)).

    CREATE tt_integr_acr_renegoc.
    ASSIGN tt_integr_acr_renegoc.tta_cod_empresa                 = estabelecimento.cod_empresa
           tt_integr_acr_renegoc.tta_cod_estab                   = STRING(INPUT FRAME {&FRAME-NAME} c-cod-estab)
           tt_integr_acr_renegoc.tta_cod_refer                   = c-cod-refer
           tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr        = i-num-reneg
           tt_integr_acr_renegoc.tta_dat_transacao               = INPUT FRAME {&FRAME-NAME} fi-data-emis
           tt_integr_acr_renegoc.tta_cdn_cliente                 = INPUT FRAME {&FRAME-NAME} c-cod-cliente
           tt_integr_acr_renegoc.tta_cod_ser_docto               = INPUT FRAME {&FRAME-NAME} c-cod-ser-docto
           tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc   = INPUT FRAME {&FRAME-NAME} fi-data-vencto
           tt_integr_acr_renegoc.tta_cod_espec_docto             = "CF"
           tt_integr_acr_renegoc.tta_cod_indic_econ_val_pres     = "REAL"
           tt_integr_acr_renegoc.tta_cod_indic_econ              = "REAL"
           tt_integr_acr_renegoc.tta_cod_indic_econ_reaj_renegoc = "REAL"
           tt_integr_acr_renegoc.tta_cod_portador                = '99501'
           tt_integr_acr_renegoc.tta_cod_cart_bcia               = "CAR"
           tt_integr_acr_renegoc.tta_ind_vencto_renegoc          = "Mensal"
           tt_integr_acr_renegoc.tta_cdn_repres                  = 1
           tt_integr_acr_renegoc.ttv_log_atualiza_renegoc        = YES.

        .
    ASSIGN d-vl-total = 0.

    FOR EACH tt-tit-acr
       WHERE tt-tit-acr.mostra = YES:

        FIND FIRST tit_acr NO-LOCK  
             WHERE tit_acr.cod_estab        = tt-tit-acr.cod_estab       
               AND tit_acr.cod_espec_docto  = tt-tit-acr.cod_espec_docto 
               AND tit_acr.cod_ser_docto    = tt-tit-acr.cod_ser_docto   
               AND tit_acr.cod_tit_acr      = tt-tit-acr.cod_tit_acr     
               AND tit_acr.cod_parcela      = tt-tit-acr.cod_parcela      NO-ERROR.
        IF AVAIL tit_acr THEN DO:
            CREATE tt_integr_acr_item_renegoc.
            ASSIGN tt_integr_acr_item_renegoc.tta_cod_estab               = tit_acr.cod_estab
                   tt_integr_acr_item_renegoc.tta_num_renegoc_cobr_acr    = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr
                   tt_integr_acr_item_renegoc.tta_cod_estab_tit_acr       = tit_acr.cod_estab
                   tt_integr_acr_item_renegoc.tta_num_id_tit_acr          = tit_acr.num_id_tit_acr
                   tt_integr_acr_item_renegoc.tta_dat_novo_vencto_tit_acr = INPUT FRAME {&FRAME-NAME} fi-data-vencto.
                .

            ASSIGN d-vl-total = d-vl-total + tit_acr.val_sdo_tit_acr.
        END.
    END.

    CREATE tt_integr_acr_item_lote_impl.
    ASSIGN tt_integr_acr_item_lote_impl.tta_num_seq_refer      = 1
           tt_integr_acr_item_lote_impl.tta_cdn_cliente        = INPUT FRAME {&FRAME-NAME} c-cod-cliente
           tt_integr_acr_item_lote_impl.tta_cod_espec_docto    = "CF"
           tt_integr_acr_item_lote_impl.tta_cod_ser_docto      = INPUT FRAME {&FRAME-NAME} c-cod-ser-docto
           tt_integr_acr_item_lote_impl.tta_cod_tit_acr        = STRING(NEXT-VALUE(seq-num-fat-convenio),"9999999999")
           tt_integr_acr_item_lote_impl.tta_cod_parcela        = "01"
           tt_integr_acr_item_lote_impl.tta_dat_emis_docto     = INPUT FRAME {&FRAME-NAME} fi-data-emis
           tt_integr_acr_item_lote_impl.tta_dat_vencto_tit_acr = INPUT FRAME {&FRAME-NAME} fi-data-vencto
           tt_integr_acr_item_lote_impl.tta_cod_indic_econ     = "REAL"
           tt_integr_acr_item_lote_impl.tta_cod_portador       = "99501"
           tt_integr_acr_item_lote_impl.tta_cod_cart_bcia      = "CAR"
           tt_integr_acr_item_lote_impl.tta_dat_prev_liquidac  = INPUT FRAME {&FRAME-NAME} fi-data-vencto
           tt_integr_acr_item_lote_impl.tta_val_tit_acr        = d-vl-total
           tt_integr_acr_item_lote_impl.tta_cdn_repres         = 1
           tt_integr_acr_item_lote_impl.tta_cod_tit_acr_bco    = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999")
        .

    ASSIGN digNossoNumero = "".
    RUN pi-retorna-digito-verificador-bradesco(INPUT "02",
                                               INPUT "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999"),
                                               OUTPUT digNossoNumero).
    ASSIGN tt_integr_acr_item_lote_impl.tta_cod_tit_acr_bco   = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999") + digNossoNumero.

    ASSIGN digNossoNumero = "".
    RUN pi-retorna-digito-verificador-bradesco(INPUT "02",
                                               INPUT "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999"),
                                               OUTPUT digNossoNumero).
    ASSIGN tt_integr_acr_item_lote_impl.tta_cod_tit_acr_bco   = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999") + digNossoNumero.


    Run prgfin/acr/acr902za.py(1,
                               INPUT-OUTPUT TABLE tt_integr_acr_renegoc,
                               INPUT-OUTPUT TABLE tt_integr_acr_item_renegoc,
                               INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl,
                               INPUT-OUTPUT TABLE tt_integr_acr_fiador_renegoc,
                               INPUT TABLE        tt_pessoa_fisic_integr,
                               INPUT TABLE        tt_pessoa_jurid_integr,
                               INPUT "EMS",
                               OUTPUT TABLE       tt_log_erros_renegoc_acr).

    IF CAN-FIND(FIRST tt_log_erros_renegoc_acr) THEN DO:
        FOR EACH tt_log_erros_renegoc_acr NO-LOCK:
            FIND FIRST tt_integr_acr_item_lote_impl NO-LOCK NO-ERROR.
            IF AVAIL tt_integr_acr_item_lote_impl THEN DO:
                RUN pi-cria-tt-erro-aux(INPUT tt_integr_acr_item_lote_impl.tta_num_seq_refer,
                                    INPUT 17006, 
                                    INPUT "Houve erro na criaá∆o do titulo abaixo, favor verificar." +
                                          "Estab/Especie/Serie/Titulo/Parcela/Cliente : " +  STRING(INPUT FRAME {&FRAME-NAME} c-cod-estab) + "/" +
                                                                                             STRING(tt_integr_acr_item_lote_impl.tta_cod_espec_docto) + "/" +
                                                                                             STRING(tt_integr_acr_item_lote_impl.tta_cod_ser_docto) + "/" +
                                                                                             STRING(tt_integr_acr_item_lote_impl.tta_cod_tit_acr) + "/" +
                                                                                             STRING(tt_integr_acr_item_lote_impl.tta_cod_parcela) + "/" +
                                                                                             STRING(tt_integr_acr_item_lote_impl.tta_cdn_cliente),
                                    INPUT ""). 
            END.

            RUN pi-cria-tt-erro-aux(INPUT tt_log_erros_renegoc_acr.tta_num_renegoc_cobr_acr,
                                    INPUT tt_log_erros_renegoc_acr.tta_num_mensagem,
                                    INPUT tt_log_erros_renegoc_acr.ttv_des_msg,
                                    INPUT tt_log_erros_renegoc_acr.ttv_des_msg).
        END.
   END.
   ELSE DO:
       FOR EACH tt_integr_acr_item_lote_impl:
           CREATE tt-tit-criados.
           ASSIGN tt-tit-criados.cod_estab          = STRING(INPUT FRAME {&FRAME-NAME} c-cod-estab)
                  tt-tit-criados.cod_espec_docto    = tt_integr_acr_item_lote_impl.tta_cod_espec_docto
                  tt-tit-criados.cod_ser_docto      = tt_integr_acr_item_lote_impl.tta_cod_ser_docto
                  tt-tit-criados.cod_tit_acr        = tt_integr_acr_item_lote_impl.tta_cod_tit_acr
                  tt-tit-criados.cod_parcela        = tt_integr_acr_item_lote_impl.tta_cod_parcela              
                  tt-tit-criados.cdn_cliente        = tt_integr_acr_item_lote_impl.tta_cdn_cliente
                  tt-tit-criados.cod_portador       = tt_integr_acr_item_lote_impl.tta_cod_portad_ext
                  tt-tit-criados.val_origin_tit_acr = tt_integr_acr_item_lote_impl.tta_val_tit_acr
                  tt-tit-criados.dat_transacao      = tt_integr_acr_item_lote_impl.tta_dat_emis_docto    
                  tt-tit-criados.dat_emis_docto     = tt_integr_acr_item_lote_impl.tta_dat_emis_docto    
                  tt-tit-criados.dat_vencto_tit_acr = tt_integr_acr_item_lote_impl.tta_dat_vencto_tit_acr
                  tt-tit-criados.situacao           = "T°tulo Gerado"
                        .

           FIND FIRST tit_acr EXCLUSIVE-LOCK
                WHERE tit_acr.cod_estab          = STRING(INPUT FRAME {&FRAME-NAME} c-cod-estab)                        
                  AND tit_acr.cod_espec_docto    = tt_integr_acr_item_lote_impl.tta_cod_espec_docto
                  AND tit_acr.cod_ser_docto      = tt_integr_acr_item_lote_impl.tta_cod_ser_docto  
                  AND tit_acr.cod_tit_acr        = tt_integr_acr_item_lote_impl.tta_cod_tit_acr    
                  AND tit_acr.cod_parcela        = tt_integr_acr_item_lote_impl.tta_cod_parcela      NO-ERROR.
           IF AVAIL tit_acr THEN DO:
               ASSIGN digNossoNumero = "".
               RUN pi-retorna-digito-verificador-bradesco(INPUT "02",
                                                          INPUT "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999"),
                                                          OUTPUT digNossoNumero).

               ASSIGN tit_acr.cod_tit_acr_bco    = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999") + digNossoNumero.
           END.

           FIND FIRST renegoc_acr NO-LOCK
             WHERE renegoc_acr.num_renegoc_cobr_acr = tit_acr.num_renegoc_cobr_acr NO-ERROR.
            IF AVAIL renegoc_acr THEN DO:
    
                FOR EACH estabelecimento NO-LOCK
                   WHERE estabelecimento.cod_empresa = v_cod_empres_usuar
                    query-tuning(no-lookahead):
    
                    movto_tit_block:
                    FOR EACH movto_tit_acr no-lock 
                       WHERE movto_tit_acr.cod_estab           = estabelecimento.cod_estab
                         AND movto_tit_acr.cod_refer           = renegoc_acr.cod_refer
                         AND movto_tit_acr.ind_trans_acr_abrev = "LQRN" /*l_lqrn*/ 
                   USE-INDEX mvtttcr_refer
                        query-tuning(no-lookahead):
    
                        IF movto_tit_acr.cod_estab_proces_bxa <> renegoc_acr.cod_estab THEN NEXT.
    
                        FIND FIRST bf_tit_acr USE-INDEX titacr_token 
                             WHERE bf_tit_acr.cod_estab      = movto_tit_acr.cod_estab 
                               AND bf_tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr NO-ERROR.
                        IF AVAIL bf_tit_acr THEN DO:
                            ASSIGN iSeq = 0.
                            FOR LAST int_ds_fat_conv_site NO-LOCK
                                  BY int_ds_fat_conv_site.id_fat_conv_site
                                query-tuning(no-lookahead):
                                ASSIGN iSeq = int_ds_fat_conv_site.id_fat_conv_site + 1.
                            END.
    
                            IF iSeq = 0 THEN ASSIGN iSeq = 1.
    
                            FIND FIRST int_ds_fat_conv_site NO-LOCK
                                 WHERE int_ds_fat_conv_site.id_fat_conv_site = iSeq  NO-ERROR.    
                            IF NOT AVAIL int_ds_fat_conv_site THEN DO:
                                FIND FIRST cliente NO-LOCK
                                     WHERE cliente.cdn_cliente = tit_acr.cdn_cliente NO-ERROR.
    
                                FOR FIRST cst_nota_fiscal NO-LOCK                                              
                                    WHERE cst_nota_fiscal.cod_estabel = bf_tit_acr.cod_estab           
                                      AND cst_nota_fiscal.serie       = bf_tit_acr.cod_ser_docto 
                                      AND cst_nota_fiscal.nr_nota_fis = bf_tit_acr.cod_tit_acr
                                    QUERY-TUNING(NO-LOOKAHEAD):
                                    
                                    ASSIGN codConvenio = INT(cst_nota_fiscal.convenio).

                                    FIND FIRST b_estabelecimento
                                         WHERE b_estabelecimento.cod_empresa = bf_tit_acr.cod_empresa 
                                           AND b_estabelecimento.cod_estab   = bf_tit_acr.cod_estab   NO-LOCK NO-ERROR.
    
                                    CREATE int_ds_fat_conv_site.
                                    ASSIGN int_ds_fat_conv_site.id_fat_conv_site = iSeq.
                                    ASSIGN int_ds_fat_conv_site.cnpj               = IF AVAIL cliente THEN cliente.cod_id_feder ELSE ""
                                           int_ds_fat_conv_site.cod_convenio       = INT(cst_nota_fiscal.convenio)
                                           int_ds_fat_conv_site.cod_estabel        = bf_tit_acr.cod_estab 
                                           int_ds_fat_conv_site.dat_cupom          = bf_tit_acr.dat_emis_docto
                                           int_ds_fat_conv_site.nosso_numero_banc  = tit_acr.cod_tit_acr_bco
                                           int_ds_fat_conv_site.nro_cupom          = bf_tit_acr.cod_tit_acr
                                           int_ds_fat_conv_site.parcela            = bf_tit_acr.cod_parcela
                                           int_ds_fat_conv_site.nro_fatura         = tit_acr.cod_tit_acr
                                           int_ds_fat_conv_site.situacao           = 1.

                                    /* Integraá∆o Procfit */
                                    ASSIGN int_ds_fat_conv_site.indterminal        = cst_nota_fiscal.indterminal
                                           int_ds_fat_conv_site.serie              = bf_tit_acr.cod_ser_docto
                                           int_ds_fat_conv_site.cnpj_filial        = b_estabelecimento.cod_id_feder.

                                    IF cst_nota_fiscal.id_pedido_convenio <> 0 AND cst_nota_fiscal.id_pedido_convenio <> ?  THEN DO:
                                        ASSIGN int_ds_fat_conv_site.nro_cupom = STRING(cst_nota_fiscal.id_pedido_convenio).
                                    END.

                                END.
                            END.
                        END.
                    END.
                END.
    
                /* INICIO - Grava a tabela pai do convànio */
                FIND FIRST int_ds_fat_convenio
                     WHERE int_ds_fat_convenio.cod_convenio = codConvenio
                       AND int_ds_fat_convenio.nro_fatura   = tit_acr.cod_tit_acr  NO-ERROR.
                IF NOT AVAIL int_ds_fat_convenio THEN DO:

                    FIND FIRST b_estabelecimento
                         WHERE b_estabelecimento.cod_empresa = tit_acr.cod_empresa 
                           AND b_estabelecimento.cod_estab   = tit_acr.cod_estab   NO-LOCK NO-ERROR.

                    CREATE int_ds_fat_convenio.
                    ASSIGN int_ds_fat_convenio.cod_convenio       = codConvenio
                           int_ds_fat_convenio.cod_estabel        = tit_acr.cod_estab
                           int_ds_fat_convenio.dat_emissao        = tit_acr.dat_emis_docto 
                           int_ds_fat_convenio.dat_vencto         = tit_acr.dat_vencto_tit_acr
                           int_ds_fat_convenio.dig_nosso_num_banc = SUBSTRING(tit_acr.cod_tit_acr_bco,12,1)
                           int_ds_fat_convenio.nosso_numero_banc  = SUBSTRING(tit_acr.cod_tit_acr_bco,1,11)
                           int_ds_fat_convenio.nro_fatura         = tit_acr.cod_tit_acr
                           int_ds_fat_convenio.situacao           = 1
                           int_ds_fat_convenio.vl_original        = tit_acr.val_origin_tit_acr 
                           int_ds_fat_convenio.vl_saldo           = tit_acr.val_sdo_tit_acr  
                           int_ds_fat_convenio.tipo_movto         = 1                       
                        .
                    /* Integraá∆o Procfit */
                    ASSIGN int_ds_fat_convenio.cnpj_filial        = b_estabelecimento.cod_id_feder
                           int_ds_fat_convenio.ENVIO_STATUS       = 1.

                    FIND FIRST cliente
                         WHERE cliente.cdn_cliente = tit_acr.cdn_cliente NO-ERROR.
                    IF AVAIL cliente THEN
                        ASSIGN int_ds_fat_convenio.cnpj           = cliente.cod_id_feder.
                END.
                ELSE DO:   
                    ASSIGN int_ds_fat_convenio.dat_vencto         = tit_acr.dat_vencto_tit_acr 
                           int_ds_fat_convenio.vl_original        = tit_acr.val_origin_tit_acr    
                           int_ds_fat_convenio.vl_saldo           = tit_acr.val_sdo_tit_acr.
                           
                    IF int_ds_fat_convenio.situacao  = 1  THEN DO:
                        ASSIGN int_ds_fat_convenio.tipo_movto         = 1 
                               int_ds_fat_convenio.situacao           = 1
                               int_ds_fat_convenio.ENVIO_STATUS       = 1. 
                    END.
                    ELSE DO:
                        ASSIGN int_ds_fat_convenio.tipo_movto         = 2 
                               int_ds_fat_convenio.situacao           = 1
                               int_ds_fat_convenio.ENVIO_STATUS       = 1.
                    END.
                END.
                /* FIM    - Grava a tabela pai do convànio */
            END.
       END.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piSalvaInformacoes W-Win 
PROCEDURE piSalvaInformacoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

   ASSIGN cCodCliente = 0
          cNumRenegoc = 0
          dDatEmissao = ?
          dDatVencto  = ?
          cCodEspec   = ""
          cSerDocto   = "".

   FIND FIRST tit_acr NO-LOCK
        WHERE tit_acr.cod_estab        = INPUT FRAME {&FRAME-NAME} c-cod-estab
          AND tit_acr.cod_espec_docto  = INPUT FRAME {&FRAME-NAME} c-cod-espec-docto
          AND tit_acr.cod_ser_docto    = INPUT FRAME {&FRAME-NAME} c-cod-ser-docto
          AND tit_acr.cod_tit_acr      = INPUT FRAME {&FRAME-NAME} c-cod-tit-acr
          AND tit_acr.cod_parcela      = INPUT FRAME {&FRAME-NAME} c-cod-parcela NO-ERROR.
   IF AVAIL tit_acr THEN DO:
       ASSIGN cCodCliente = tit_acr.cdn_cliente
              cNumRenegoc = tit_acr.num_renegoc_cobr_acr
              dDatEmissao = tit_acr.dat_emis_docto 
              dDatVencto  = tit_acr.dat_vencto_tit_acr
              cCodEspec   = tit_acr.cod_espec_docto
              cSerDocto   = tit_acr.cod_ser_docto
           .
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piValidaInformacoes W-Win 
PROCEDURE piValidaInformacoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   FIND FIRST tit_acr NO-LOCK
        WHERE tit_acr.cod_estab        = INPUT FRAME {&FRAME-NAME} c-cod-estab
          AND tit_acr.cod_espec_docto  = INPUT FRAME {&FRAME-NAME} c-cod-espec-docto
          AND tit_acr.cod_ser_docto    = INPUT FRAME {&FRAME-NAME} c-cod-ser-docto
          AND tit_acr.cod_tit_acr      = INPUT FRAME {&FRAME-NAME} c-cod-tit-acr
          AND tit_acr.cod_parcela      = INPUT FRAME {&FRAME-NAME} c-cod-parcela NO-ERROR.
   IF NOT AVAIL tit_acr THEN DO:
       RUN pi-cria-tt-erro-aux(INPUT 1,
                               INPUT 17006,
                               INPUT "T°tulo informado n∆o encontrado.~~ O t°tulo informado n∆o foi encontrado, favor verificar",
                               INPUT "T°tulo informado n∆o encontrado.~~ O t°tulo informado n∆o foi encontrado, favor verificar").
       RETURN "NOK".
   END.

   IF NOT CAN-FIND(FIRST tt-tit-acr WHERE tt-tit-acr.mostra = YES) THEN DO:
       RUN pi-cria-tt-erro-aux(INPUT 1,
                               INPUT 17006,
                               INPUT "Deve conter ao menos um cupom para fazer o estorno parcial da Fatura.Caso deseje estornar a fatura por completa deve utilizar o produto padr∆o.",
                               INPUT "Deve conter ao menos um cupom para fazer o estorno parcial da Fatura.Caso deseje estornar a fatura por completa deve utilizar o produto padr∆o.").
       RETURN "NOK".
   END.
                                              

   IF NOT CAN-FIND(FIRST tt-tit-acr-sel) THEN DO:
       RUN pi-cria-tt-erro-aux(INPUT 1,
                               INPUT 17006,
                               INPUT "N∆o foi selecionado nenhum cupom de convànio que ser† estornado na Fatura a ser gerada, favor verificar",
                               INPUT "N∆o foi selecionado nenhum cupom de convànio que ser† estornado na Fatura a ser gerada, favor verificar").
       RETURN "NOK".
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_disp_fields W-Win 
PROCEDURE pi_disp_fields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    FIND tit_acr WHERE RECID(tit_acr) = v_rec_table NO-LOCK NO-ERROR.

    IF AVAILABLE tit_acr THEN DO:

        FIND estabelecimento NO-LOCK WHERE estabelecimento.cod_estab = tit_acr.cod_estab NO-ERROR.
        FIND cliente NO-LOCK         WHERE cliente.cod_empresa = tit_acr.cod_empresa
                                       AND   cliente.cdn_cliente = tit_acr.cdn_cliente   NO-ERROR.
        FIND portador NO-LOCK        WHERE portador.cod_portador = tit_acr.cod_portador  NO-ERROR.

        ASSIGN c-cod-estab:SCREEN-VALUE       IN FRAME {&FRAME-NAME} = tit_acr.cod_estab      
               c-cod-espec-docto:SCREEN-VALUE IN FRAME {&FRAME-NAME} = tit_acr.cod_espec_docto
               c-cod-ser-docto:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = tit_acr.cod_ser_docto  
               c-cod-tit-acr:SCREEN-VALUE     IN FRAME {&FRAME-NAME} = tit_acr.cod_tit_acr    
               c-cod-parcela:SCREEN-VALUE     IN FRAME {&FRAME-NAME} = tit_acr.cod_parcela  .  

        IF AVAIL cliente THEN DO:
            ASSIGN c-cod-cliente:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = STRING(cliente.cdn_cliente)
                   fi-nome-cliente:SCREEN-VALUE IN FRAME {&FRAME-NAME} = cliente.nom_pessoa.
        END.

        ASSIGN c-num-renegoc:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = STRING(tit_acr.num_renegoc_cobr_acr) 
               c-saldo-tit-acr:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(tit_acr.val_sdo_tit_acr).
    END.
    ELSE DO:
        ASSIGN c-cod-estab:SCREEN-VALUE       IN FRAME {&FRAME-NAME} = ""      
               c-cod-espec-docto:SCREEN-VALUE IN FRAME {&FRAME-NAME} = ""
               c-cod-ser-docto:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = ""
               c-cod-tit-acr:SCREEN-VALUE     IN FRAME {&FRAME-NAME} = ""
               c-cod-parcela:SCREEN-VALUE     IN FRAME {&FRAME-NAME} = "".  

        ASSIGN c-cod-cliente:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = STRING(0)
               fi-nome-cliente:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "".

        ASSIGN c-num-renegoc:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = STRING(0) 
               c-saldo-tit-acr:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(0).
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records W-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-tit-acr-sel"}
  {src/adm/template/snd-list.i "tt-tit-acr"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed W-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

