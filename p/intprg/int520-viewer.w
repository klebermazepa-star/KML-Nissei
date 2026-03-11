&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i INT520-VIEWER 1.12.01.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/viewerd.w

/* global variable definitions */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var v-row-parent as rowid no-undo.

DEFINE VARIABLE tot-base-icms-it        AS DECIMAL INITIAL 0 NO-UNDO.
DEFINE VARIABLE tot-base-icms-st-it     AS DECIMAL INITIAL 0 NO-UNDO.
DEFINE VARIABLE tot-cofins-it           AS DECIMAL INITIAL 0 NO-UNDO.
DEFINE VARIABLE tot-icms-it             AS DECIMAL INITIAL 0 NO-UNDO. 
DEFINE VARIABLE tot-icms-st-it          AS DECIMAL INITIAL 0 NO-UNDO. 
DEFINE VARIABLE tot-ipi-it              AS DECIMAL INITIAL 0 NO-UNDO. 
DEFINE VARIABLE tot-tot-pis-it          AS DECIMAL INITIAL 0 NO-UNDO. 
DEFINE VARIABLE tot-valor-it            AS DECIMAL INITIAL 0 NO-UNDO.
DEFINE VARIABLE tot-despesas-it         AS DECIMAL INITIAL 0 NO-UNDO.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente-fim as integer
    field cod-emitente-ini as integer
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-emis-nota-fim as date
    field dt-emis-nota-ini as date
    field nro-docto-fim    as integer
    field nro-docto-ini    as integer
    field serie-docto-fim  as char
    field serie-docto-ini  as char.

def var raw-param        as raw no-undo.

def temp-table tt-raw-digita
    field raw-digita      as raw.

def var c-cod-estabel as char no-undo.

PROCEDURE WinExec EXTERNAL "kernel32.dll":U:
  DEF INPUT  PARAM prg_name                          AS CHARACTER.
  DEF INPUT  PARAM prg_style                         AS SHORT.
END PROCEDURE.

define temp-table tt-param-int520d no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    field r-rowid          as rowid.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-main

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int_ds_nota_entrada
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_nota_entrada


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_nota_entrada.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_nota_entrada.nen_datamovimentacao_d ~
int_ds_nota_entrada.nen_horamovimentacao_s ~
int_ds_nota_entrada.nen_chaveacesso_s int_ds_nota_entrada.ped_codigo_n 
&Scoped-define ENABLED-TABLES int_ds_nota_entrada
&Scoped-define FIRST-ENABLED-TABLE int_ds_nota_entrada
&Scoped-Define ENABLED-OBJECTS rt-key RECT-1 RECT-3 RECT-4 RECT-5 RECT-6 ~
RECT-7 RECT-8 RECT-9 RECT-10 RECT-11 RECT-12 RECT-13 RECT-14 RECT-15 ~
RECT-16 RECT-17 RECT-18 RECT-19 RECT-20 RECT-21 RECT-23 c-mensagem 
&Scoped-Define DISPLAYED-FIELDS int_ds_nota_entrada.nen_datamovimentacao_d ~
int_ds_nota_entrada.nen_horamovimentacao_s ~
int_ds_nota_entrada.nen_chaveacesso_s int_ds_nota_entrada.situacao ~
int_ds_nota_entrada.nen_conferida_n int_ds_nota_entrada.nen_dataemissao_d ~
int_ds_nota_entrada.nen_cnpj_origem_s int_ds_nota_entrada.nen_notafiscal_n ~
int_ds_nota_entrada.nen_serie_s int_ds_nota_entrada.ped_codigo_n ~
int_ds_nota_entrada.nen_cfop_n int_ds_nota_entrada.nen_baseicms_n ~
int_ds_nota_entrada.nen_valoricms_n int_ds_nota_entrada.nen_basest_n ~
int_ds_nota_entrada.nen_icmsst_n int_ds_nota_entrada.nen_frete_n ~
int_ds_nota_entrada.nen_seguro_n int_ds_nota_entrada.nen_despesas_n ~
int_ds_nota_entrada.nen_valoripi_n int_ds_nota_entrada.nen_desconto_n 
&Scoped-define DISPLAYED-TABLES int_ds_nota_entrada
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_nota_entrada
&Scoped-Define DISPLAYED-OBJECTS i-cod-emitente cFornecedor cUF c-cod-estab ~
cEstabelec cb-frete cNatureza c-nat-principal data-emissao data-entrega ~
cComprador c-mensagem tot-nf-it vl-total-nf vl-desconto-itens vl-pis-itens ~
vl-cofins-itens vl-icms-des-itens 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS cb-frete 
&Scoped-define ADM-MODIFY-FIELDS cb-frete 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
ep_codigo||y|custom.int_ds_nota_entrada.ep_codigo
</FOREIGN-KEYS> 
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = ,
     Keys-Supplied = "ep_codigo"':U).
/**************************
</EXECUTING-CODE> */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE cb-frete AS CHARACTER FORMAT "X(256)":U 
     LABEL "Frete" 
     VIEW-AS COMBO-BOX INNER-LINES 7
     LIST-ITEM-PAIRS "0-Por Conta do Emitente","0",
                     "1-Por Conta do Destinat†rio/Remetente","1",
                     "2-Por Conta de Terceiros","2",
                     "3-Nao Suportado","3",
                     "4-Nao Suportado","4",
                     "9-Sem Frete","9"
     DROP-DOWN-LIST
     SIZE 30.5 BY .93 NO-UNDO.

DEFINE VARIABLE c-mensagem AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 41.63 BY 5.57
     FONT 0 NO-UNDO.

DEFINE VARIABLE c-cod-estab AS CHARACTER FORMAT "x(8)" 
     LABEL "Filial" 
     VIEW-AS FILL-IN 
     SIZE 4.75 BY .87.

DEFINE VARIABLE c-nat-principal AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 7 BY .87 NO-UNDO.

DEFINE VARIABLE cComprador AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 33 BY .8 NO-UNDO.

DEFINE VARIABLE cEstabelec AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 56 BY .87 NO-UNDO.

DEFINE VARIABLE cFornecedor AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 50.38 BY .87 NO-UNDO.

DEFINE VARIABLE cNatureza AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 55 BY .87 NO-UNDO.

DEFINE VARIABLE cUF AS CHARACTER FORMAT "X(256)":U 
     LABEL "UF" 
     VIEW-AS FILL-IN 
     SIZE 3.63 BY .87 NO-UNDO.

DEFINE VARIABLE data-emissao AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 10.63 BY .87 NO-UNDO.

DEFINE VARIABLE data-entrega AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 11 BY .87 NO-UNDO.

DEFINE VARIABLE i-cod-emitente AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0 
     LABEL "Fornecedor":R10 
     VIEW-AS FILL-IN 
     SIZE 10.25 BY .87.

DEFINE VARIABLE tot-nf-it AS DECIMAL FORMAT "->>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 17.25 BY .87 NO-UNDO.

DEFINE VARIABLE vl-cofins-itens AS DECIMAL FORMAT "->>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 17.25 BY .87 NO-UNDO.

DEFINE VARIABLE vl-desconto-itens AS DECIMAL FORMAT "->>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 17.25 BY .87 NO-UNDO.

DEFINE VARIABLE vl-icms-des-itens AS DECIMAL FORMAT "->>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 17.25 BY .87 NO-UNDO.

DEFINE VARIABLE vl-pis-itens AS DECIMAL FORMAT "->>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 17.25 BY .87 NO-UNDO.

DEFINE VARIABLE vl-total-nf AS DECIMAL FORMAT "->>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 17.25 BY .87 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 12.63 BY 1.33.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-17
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-18
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-20
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 35.38 BY 1.33.

DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 142.88 BY 6.17.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.63 BY 1.57.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 68.63 BY 1.33.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 12.63 BY 1.33.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 12 BY 1.33.

DEFINE RECTANGLE rt-key
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 142.88 BY 3.2.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int_ds_nota_entrada.nen_datamovimentacao_d AT ROW 1.17 COL 98.63 COLON-ALIGNED WIDGET-ID 174
          LABEL "Conferància"
          VIEW-AS FILL-IN 
          SIZE 11.13 BY .87
     int_ds_nota_entrada.nen_horamovimentacao_s AT ROW 1.17 COL 109.88 COLON-ALIGNED NO-LABEL WIDGET-ID 176
          VIEW-AS FILL-IN 
          SIZE 12.13 BY .87
     int_ds_nota_entrada.nen_chaveacesso_s AT ROW 1.2 COL 11.25 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 60.75 BY .87
     int_ds_nota_entrada.situacao AT ROW 1.2 COL 77.63 COLON-ALIGNED WIDGET-ID 172
          VIEW-AS FILL-IN 
          SIZE 3 BY .87
     int_ds_nota_entrada.nen_conferida_n AT ROW 1.2 COL 80.63 COLON-ALIGNED NO-LABEL WIDGET-ID 170
          VIEW-AS FILL-IN 
          SIZE 3.13 BY .87
     int_ds_nota_entrada.nen_dataemissao_d AT ROW 2.07 COL 129.5 COLON-ALIGNED WIDGET-ID 108
          LABEL "Emiss∆o"
          VIEW-AS FILL-IN 
          SIZE 11.25 BY .87
     i-cod-emitente AT ROW 2.13 COL 11.25 COLON-ALIGNED WIDGET-ID 4
     cFornecedor AT ROW 2.13 COL 21.63 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     cUF AT ROW 2.13 COL 77.5 COLON-ALIGNED WIDGET-ID 16
     int_ds_nota_entrada.nen_cnpj_origem_s AT ROW 2.13 COL 98.63 COLON-ALIGNED WIDGET-ID 164
          LABEL "CNPJ"
          VIEW-AS FILL-IN 
          SIZE 16 BY .87
     c-cod-estab AT ROW 3.03 COL 11.25 COLON-ALIGNED WIDGET-ID 6
     cEstabelec AT ROW 3.03 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     int_ds_nota_entrada.nen_notafiscal_n AT ROW 3.03 COL 77.5 COLON-ALIGNED WIDGET-ID 8
          LABEL "Nota"
          VIEW-AS FILL-IN 
          SIZE 14.63 BY .87
     int_ds_nota_entrada.nen_serie_s AT ROW 3.03 COL 98.63 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 5.38 BY .87
     cb-frete AT ROW 3.07 COL 110.5 COLON-ALIGNED WIDGET-ID 180
     int_ds_nota_entrada.ped_codigo_n AT ROW 4.77 COL 68.63 COLON-ALIGNED NO-LABEL WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 11.63 BY .87
     int_ds_nota_entrada.nen_cfop_n AT ROW 4.8 COL 2.63 NO-LABEL WIDGET-ID 20
          VIEW-AS FILL-IN 
          SIZE 4.38 BY .87
     cNatureza AT ROW 4.8 COL 5 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     c-nat-principal AT ROW 4.8 COL 59.75 COLON-ALIGNED NO-LABEL WIDGET-ID 178
     data-emissao AT ROW 4.8 COL 81.63 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     data-entrega AT ROW 4.8 COL 94 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     cComprador AT ROW 4.8 COL 107.63 COLON-ALIGNED NO-LABEL WIDGET-ID 140
     c-mensagem AT ROW 6.33 COL 102.63 NO-LABEL WIDGET-ID 168
     int_ds_nota_entrada.nen_baseicms_n AT ROW 7.07 COL 1.25 COLON-ALIGNED NO-LABEL WIDGET-ID 44
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_nota_entrada.nen_valoricms_n AT ROW 7.07 COL 20.75 COLON-ALIGNED NO-LABEL WIDGET-ID 32
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_nota_entrada.nen_basest_n AT ROW 7.07 COL 40.75 COLON-ALIGNED NO-LABEL WIDGET-ID 46
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_nota_entrada.nen_icmsst_n AT ROW 7.07 COL 60.75 COLON-ALIGNED NO-LABEL WIDGET-ID 42
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     tot-nf-it AT ROW 7.07 COL 81.63 COLON-ALIGNED NO-LABEL WIDGET-ID 160
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     int_ds_nota_entrada.nen_frete_n AT ROW 8.93 COL 3.25 NO-LABEL WIDGET-ID 30
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_nota_entrada.nen_seguro_n AT ROW 8.93 COL 20.75 COLON-ALIGNED NO-LABEL WIDGET-ID 40
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_nota_entrada.nen_despesas_n AT ROW 8.93 COL 40.75 COLON-ALIGNED NO-LABEL WIDGET-ID 38
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_nota_entrada.nen_valoripi_n AT ROW 8.93 COL 61.25 COLON-ALIGNED NO-LABEL WIDGET-ID 34
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     vl-total-nf AT ROW 9 COL 81.63 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     int_ds_nota_entrada.nen_desconto_n AT ROW 10.87 COL 1.25 COLON-ALIGNED NO-LABEL WIDGET-ID 110
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     vl-desconto-itens AT ROW 10.87 COL 20.75 COLON-ALIGNED NO-LABEL WIDGET-ID 118
     vl-pis-itens AT ROW 10.87 COL 41 COLON-ALIGNED NO-LABEL WIDGET-ID 154
     vl-cofins-itens AT ROW 10.87 COL 61 COLON-ALIGNED NO-LABEL WIDGET-ID 156
     vl-icms-des-itens AT ROW 10.87 COL 81.63 COLON-ALIGNED NO-LABEL WIDGET-ID 158
     "Natureza de Operaá∆o" VIEW-AS TEXT
          SIZE 20.63 BY .57 AT ROW 4.2 COL 3 WIDGET-ID 74
     "Comprador" VIEW-AS TEXT
          SIZE 10.88 BY .43 AT ROW 4.27 COL 109.63 WIDGET-ID 144
     "Vl Seguro" VIEW-AS TEXT
          SIZE 9.63 BY .67 AT ROW 8.13 COL 22.63 WIDGET-ID 98
     "Vl Despesas" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 8.13 COL 42.63 WIDGET-ID 100
     "Base ICMS ST" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 6.27 COL 42.63 WIDGET-ID 62
     "Valor ICMS ST" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 6.27 COL 62.63 WIDGET-ID 66
     "Valor ICMS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 6.27 COL 22.63 WIDGET-ID 58
     "Base C†lculo" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 6.27 COL 2.63 WIDGET-ID 50
     "Descontos" VIEW-AS TEXT
          SIZE 10.63 BY .67 AT ROW 10.07 COL 2.75 WIDGET-ID 138
     "Valor Produtos" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 6.27 COL 83.13 WIDGET-ID 70
     "ICMS Desonerado" VIEW-AS TEXT
          SIZE 17 BY .67 AT ROW 10.07 COL 83.25 WIDGET-ID 130
     "Vl PIS" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 10.07 COL 42.75 WIDGET-ID 134
     "Desconto Itens" VIEW-AS TEXT
          SIZE 14.63 BY .67 AT ROW 10.07 COL 22.75 WIDGET-ID 132
     "Valor IPI" VIEW-AS TEXT
          SIZE 8.63 BY .67 AT ROW 8.13 COL 63.25 WIDGET-ID 102
     "Vl COFINS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 10.07 COL 62.75 WIDGET-ID 136
     "Pedido" VIEW-AS TEXT
          SIZE 7 BY .43 AT ROW 4.3 COL 70.63 WIDGET-ID 78
     "Emiss∆o" VIEW-AS TEXT
          SIZE 8 BY .43 AT ROW 4.3 COL 83.63 WIDGET-ID 82
     "Entrega" VIEW-AS TEXT
          SIZE 8 BY .43 AT ROW 4.27 COL 96 WIDGET-ID 86
     "Vl Frete" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 8.13 COL 2.63 WIDGET-ID 104
     "Valor Total NF" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 8.13 COL 83.13 WIDGET-ID 96
     rt-key AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     RECT-1 AT ROW 6.53 COL 1.75 WIDGET-ID 52
     RECT-3 AT ROW 6.53 COL 21.75 WIDGET-ID 56
     RECT-4 AT ROW 6.53 COL 41.75 WIDGET-ID 60
     RECT-5 AT ROW 6.53 COL 61.75 WIDGET-ID 64
     RECT-6 AT ROW 6.53 COL 82.25 WIDGET-ID 68
     RECT-7 AT ROW 4.53 COL 1 WIDGET-ID 72
     RECT-8 AT ROW 4.53 COL 70.13 WIDGET-ID 76
     RECT-9 AT ROW 4.53 COL 83 WIDGET-ID 80
     RECT-10 AT ROW 4.53 COL 95.63 WIDGET-ID 84
     RECT-11 AT ROW 8.47 COL 1.75 WIDGET-ID 88
     RECT-12 AT ROW 8.47 COL 21.75 WIDGET-ID 90
     RECT-13 AT ROW 8.47 COL 41.75 WIDGET-ID 92
     RECT-14 AT ROW 8.47 COL 82.25 WIDGET-ID 94
     RECT-15 AT ROW 8.47 COL 62.25 WIDGET-ID 106
     RECT-16 AT ROW 10.33 COL 1.75 WIDGET-ID 120
     RECT-17 AT ROW 10.33 COL 21.75 WIDGET-ID 122
     RECT-18 AT ROW 10.33 COL 41.75 WIDGET-ID 124
     RECT-19 AT ROW 10.33 COL 61.75 WIDGET-ID 126
     RECT-20 AT ROW 10.33 COL 82.25 WIDGET-ID 128
     RECT-21 AT ROW 4.53 COL 108.63 WIDGET-ID 142
     RECT-23 AT ROW 6.07 COL 1 WIDGET-ID 152
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: custom.int_ds_nota_entrada
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY COMPILE
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 11.93
         WIDTH              = 145.88.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}
{include/c-viewer.i}
{utp/ut-glob.i}
{include/i_dbtype.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME f-main:SCROLLABLE       = FALSE
       FRAME f-main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN c-cod-estab IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-nat-principal IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX cb-frete IN FRAME f-main
   NO-ENABLE 1 3                                                        */
/* SETTINGS FOR FILL-IN cComprador IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cEstabelec IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cFornecedor IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatureza IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cUF IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN data-emissao IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN data-entrega IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-cod-emitente IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_baseicms_n IN FRAME f-main
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_basest_n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_cfop_n IN FRAME f-main
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_cnpj_origem_s IN FRAME f-main
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_conferida_n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_dataemissao_d IN FRAME f-main
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_datamovimentacao_d IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_desconto_n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_despesas_n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_frete_n IN FRAME f-main
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_icmsst_n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_notafiscal_n IN FRAME f-main
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_seguro_n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_serie_s IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_valoricms_n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.nen_valoripi_n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.ped_codigo_n IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_nota_entrada.situacao IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-nf-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vl-cofins-itens IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vl-desconto-itens IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vl-icms-des-itens IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vl-pis-itens IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vl-total-nf IN FRAME f-main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-main
/* Query rebuild information for FRAME f-main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME f-main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME c-cod-estab
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estab V-table-Win
ON LEAVE OF c-cod-estab IN FRAME f-main /* Filial */
DO:
    for first estabelec fields (nome cod-emitente)
        no-lock where 
        estabelec.cod-estabel = input frame f-Main c-cod-estab:
        for first emitente fields (nome-abrev) no-lock where 
            emitente.cod-emitente = estabelec.cod-emitente:
            assign  cEstabelec:screen-value in frame f-Main = emitente.nome-abrev + "-" + estabelec.nome.
        end.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-cod-emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emitente V-table-Win
ON LEAVE OF i-cod-emitente IN FRAME f-main /* Fornecedor */
DO:
    for first emitente fields (nome-emit estado)
        no-lock where 
        emitente.cod-emitente = input frame f-Main i-cod-emitente:
        assign  cFornecedor:screen-value in frame f-Main = emitente.nome-emit
                cUF:screen-value in frame f-Main = emitente.estado.

    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_nota_entrada.nen_cfop_n
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_nota_entrada.nen_cfop_n V-table-Win
ON LEAVE OF int_ds_nota_entrada.nen_cfop_n IN FRAME f-main /* CFOP */
DO:
    
    for first cfop-natur fields (des-cfop)
        no-lock where 
        cfop-natur.cod-cfop = int_ds_nota_entrada.nen_cfop_n:screen-value in FRAME f-main:
        assign  cNatureza:screen-value in frame f-Main = cfop-natur.des-cfop.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_nota_entrada.ped_codigo_n
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_nota_entrada.ped_codigo_n V-table-Win
ON LEAVE OF int_ds_nota_entrada.ped_codigo_n IN FRAME f-main /* Pedido */
DO:
    assign custom.int_ds_nota_entrada.ped_codigo_n:bgcolor in frame f-Main = ?.
    for first pedido-compr no-lock where 
        pedido-compr.num-pedido = input frame f-main int_ds_nota_entrada.ped_codigo_n:
        assign data-emissao:screen-value in frame f-main = string(pedido-compr.data-pedido).
        for first ordem-compra fields (numero-ordem cod-comprado)
            no-lock where ordem-compra.num-pedido = pedido-compr.num-pedido:
            for first comprador fields (nome) no-lock where 
                comprador.cod-comprado = ordem-compra.cod-comprado:
                assign cComprador:screen-value in frame f-main = comprador.nome.
            end.
            for first prazo-compra fields (data-entrega)
                no-lock of ordem-compra:
                assign data-entrega:screen-value in frame f-main = string(prazo-compra.data-entrega).
            end.
        end.
        /*
        for first emitente fields (cod-emitente) no-lock where 
            emitente.cod-emitente = pedido-compr.cod-emitente: end.
        if avail emitente and emitente.cod-emitente <> i-cod-emitente:input-value in frame f-Main then do:
            assign custom.int_ds_nota_entrada.ped_codigo_n:bgcolor in frame f-Main = 14.
            assign c-mensagem:screen-value in frame f-main = "Pedido n∆o Ç deste fornecedor!" + chr(32).
        end.
        else do:
            assign custom.int_ds_nota_entrada.ped_codigo_n:bgcolor in frame f-Main = ?.
        end.
        */
    end.
    /*
    if not avail pedido-compr and 
       input frame f-main int_ds_nota_entrada.ped_codigo_n <> ? and
       input frame f-main int_ds_nota_entrada.ped_codigo_n <> 0 then do:
        assign c-mensagem:screen-value in frame f-main = "Pedido n∆o encontrado!" + chr(32).
        assign custom.int_ds_nota_entrada.ped_codigo_n:bgcolor in frame f-Main = 14.
    end.
    */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
  &ENDIF         
  
  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-find-using-key V-table-Win  adm/support/_key-fnd.p
PROCEDURE adm-find-using-key :
/*------------------------------------------------------------------------------
  Purpose:     Finds the current record using the contents of
               the 'Key-Name' and 'Key-Value' attributes.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* No Foreign keys are accepted by this SmartObject. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
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

  /* Create a list of all the tables that we need to get.            */
  {src/adm/template/row-list.i "int_ds_nota_entrada"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_nota_entrada"}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME f-main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record V-table-Win 
PROCEDURE local-assign-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

    /* Code placed here will execute PRIOR to standard behavior. */
    {include/i-valid.i}
    
    /*:T Ponha na pi-validate todas as validaá‰es */
    /*:T N∆o gravar nada no registro antes do dispatch do assign-record e 
       nem na PI-validate. */
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .
    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.

    if avail int_ds_nota_entrada then 
        assign int_ds_nota_entrada.nen_modalidade_frete_n = integer(cb-frete:screen-value in FRAME {&FRAME-NAME}).
    
    /*:T Todos os assignÔs n∆o feitos pelo assign-record devem ser feitos aqui */  
    /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-disable-fields V-table-Win 
PROCEDURE local-disable-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
    
    /* Code placed here will execute PRIOR to standard behavior. */
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'disable-fields':U ) .
    
    /* Code placed here will execute AFTER standard behavior.    */
    &if  defined(ADM-MODIFY-FIELDS) &then
        disable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
    &endif
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-enable-fields V-table-Win 
PROCEDURE local-enable-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
    
    /* Code placed here will execute PRIOR to standard behavior. */
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'enable-fields':U ) .
    
    /* Code placed here will execute AFTER standard behavior.    */
    &if  defined(ADM-MODIFY-FIELDS) &then
        enable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
    &endif
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-row-available V-table-Win 
PROCEDURE local-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
def var c-nat-operacao as char.
def var i-cfop as integer.
def var i-cst as integer.

  /* Code placed here will execute PRIOR to standard behavior. */
   
  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'row-available':U ) .

  /*
  if cb-frete:list-items in FRAME {&FRAME-NAME} = "" then do:
        cb-frete:ADD-LAST("0-Emitente","0").
        cb-frete:ADD-LAST("1-Destinat†rio/Remetente","1").
        cb-frete:ADD-LAST("2-Terceiros","2").
        cb-frete:ADD-LAST("3-Nao Suportado","3").
        cb-frete:ADD-LAST("4-Nao Suportado","4").
        cb-frete:ADD-LAST("9-Sem Frete","9").
  end.
  */

  /* Code placed here will execute AFTER standard behavior.    */
  if avail int_ds_nota_entrada then do:
      
      assign c-mensagem:screen-value in frame f-main = "".
      RUN pi-calcula-totais in this-procedure.

      if  tot-base-icms-it        = int_ds_nota_entrada.nen_baseicms_n 
          then int_ds_nota_entrada.nen_baseicms_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_baseicms_n:bgcolor in frame f-Main = 14.
      if  tot-base-icms-st-it     = int_ds_nota_entrada.nen_basest_n
          then int_ds_nota_entrada.nen_basest_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_basest_n:bgcolor in frame f-Main = 14.
      if  vl-desconto-itens       = int_ds_nota_entrada.nen_desconto_n
          then int_ds_nota_entrada.nen_desconto_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_desconto_n:bgcolor in frame f-Main = 14.
      if  tot-icms-it             = int_ds_nota_entrada.nen_valoricms_n
          then int_ds_nota_entrada.nen_valoricms_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_valoricms_n:bgcolor in frame f-Main = 14.
      if  tot-icms-st-it          = int_ds_nota_entrada.nen_icmsst_n
          then int_ds_nota_entrada.nen_icmsst_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_icmsst_n:bgcolor in frame f-Main = 14.
      if  tot-ipi-it              = int_ds_nota_entrada.nen_valoripi_n
          then int_ds_nota_entrada.nen_valoripi_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_valoripi_n:bgcolor in frame f-Main = 14.
      if  tot-despesas-it         = int_ds_nota_entrada.nen_despesas_n + int_ds_nota_entrada.nen_frete_n
          then int_ds_nota_entrada.nen_despesas_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_despesas_n:bgcolor in frame f-Main = 14.
      if  tot-nf-it               = int_ds_nota_entrada.nen_valortotalprodutos_n 
          then tot-nf-it:bgcolor in frame f-Main = ?. 
          else do: 
              tot-nf-it:bgcolor in frame f-Main = 14.
              assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main
                                                             + "Total bruto do documento n∆o bate com total bruto dos itens!" + chr(32).
          end.

      assign cb-frete:screen-value in FRAME {&FRAME-NAME} = string(int_ds_nota_entrada.nen_modalidade_frete_n).

      if  int_ds_nota_entrada.nen_modalidade_frete_n <> 0 /* Emitente */ and
          int_ds_nota_entrada.nen_modalidade_frete_n <> 1 /* Destinat†rio/Remetente */ and
          int_ds_nota_entrada.nen_modalidade_frete_n <> 2 /* Terceiros */ and
          int_ds_nota_entrada.nen_modalidade_frete_n <> 9 /* Sem Frete */ then do:
          assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main
                                                         + "Modalidade de frete n∆o suportada no Totvs!" + chr(32).

      end.        
  

      assign vl-desconto-itens:screen-value in frame f-main = string(vl-desconto-itens).
      assign vl-pis-itens:screen-value in frame f-main = string(vl-pis-itens).
      assign vl-cofins-itens:screen-value in frame f-main = string(vl-cofins-itens).
      assign vl-icms-des-itens:screen-value in frame f-main = string(vl-icms-des-itens).
      assign vl-total-nf:screen-value in frame f-main = string(vl-total-nf).
      assign tot-nf-it:screen-value in frame f-main = string(tot-nf-it).
    
      i-cod-emitente = 0.
      for first emitente fields (cod-emitente) no-lock where 
          emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s:
          i-cod-emitente = emitente.cod-emitente.
      end.
    
      c-cod-estab = "".
      for each estabelec 
          fields (cod-estabel estado cidade 
                  cep pais endereco bairro ep-codigo) 
          no-lock where
          estabelec.cgc = int_ds_nota_entrada.nen_cnpj_destino_s,
          first cst_estabelec no-lock where 
          cst_estabelec.cod_estabel = estabelec.cod-estabel and
          cst_estabelec.dt_fim_operacao >= int_ds_nota_entrada.nen_dataemissao_d:
          c-cod-estab = estabelec.cod-estabel.
          leave.
      end.
      display i-cod-emitente c-cod-estab with frame f-main.
    
      apply "leave":u to i-cod-emitente in frame f-main.
      apply "leave":u to c-cod-estab in frame f-main.
      apply "leave":u to int_ds_nota_entrada.nen_cfop_n in frame f-main.
      apply "leave":u to int_ds_nota_entrada.ped_codigo_n in frame f-main.
    
      c-nat-principal = "".
      for each int_ds_nota_entrada_produt no-lock of int_ds_nota_entrada:
    
          for each item no-lock where 
              item.it-codigo = trim(string(int_ds_nota_entrada_produt.nep_produto_n)):
        
              i-cfop = int_ds_nota_entrada_produt.nen_cfop_n.
              /* cfop vinda do PRS est† invertida */
              if trim(string(i-cfop)) begins "1" then do:
                  if int_ds_nota_entrada_produt.nep_cstb_icm_n = 70 and 
                     substring(trim(string(i-cfop)),2,1) <> "9"  then
                      i-cfop = 5403.
                  else
                      i-cfop = int("5" + trim(substring(string(i-cfop),2,3))).
              end.
              
              if trim(string(i-cfop)) begins "2" then do:
                  if int_ds_nota_entrada_produt.nep_cstb_icm_n = 70 and 
                     substring(trim(string(i-cfop)),2,1) <> "9"  then
                      i-cfop = 6403.
                  else
                      i-cfop = int("6" + trim(substring(string(i-cfop),2,3))).
              end.
    
    
              assign i-cst = int_ds_nota_entrada_produt.nep_cstb_icm_n.
              /* tratando CST incorreta vinda do PRS */
              if i-cfop = 5403 or i-cfop = 6403 and i-cst = 0 then
                  assign i-cst = 70.
        
              c-nat-operacao = "".
              RUN intprg/int013a.p( input i-cfop,
                                    input i-cst,
                                    input /*int_ds_nota_entrada_produt.nep-cstb-ipi-n*/ int(item.fm-codigo),
                                    input c-cod-estab,
                                    input i-cod-emitente,
                                    INPUT item.class-fiscal,
                                    input int_ds_nota_entrada.nen_dataemissao_d,
                                    output c-nat-operacao).
        
              for first natur-oper no-lock where 
                  natur-oper.nat-operacao = c-nat-operacao: 
                  if c-nat-principal = "" 
                    &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                      then do:
                    &else
                      or NOT natur-oper.log-contrib-st-antec then do:
                    &endif
                      assign c-nat-principal = c-nat-operacao.
                  end.
              end.
          end.
      end.
    
      for first int_ds_nota_entrada_dup no-lock of int_ds_nota_entrada: 
          if c-nat-principal <> "" then do:
              if not can-find (first natur-oper no-lock where natur-oper.nat-operacao = c-nat-principal and
                         natur-oper.emite-duplic) then do:
                  assign c-mensagem:screen-value in frame f-main = c-mensagem + 
                        "Duplicatas informadas e Natureza de operaá∆o n∆o emite duplicatas: " + c-nat-principal.
              end.
          end.
      end.
      if not avail int_ds_nota_entrada_dup then do:
          if c-nat-principal <> "" then do:
              if can-find (first natur-oper no-lock where natur-oper.nat-operacao = c-nat-principal and
                           natur-oper.emite-duplic) then do:
                  assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main
                                                                 + "N∆o encotradas duplicatas para o documento!" + chr(32).
              end.
          end.
      end.
      display c-nat-principal with frame f-main.
      
      assign int_ds_nota_entrada.nen_datamovimentacao_d:bgcolor in frame f-main = ?.
      if input frame f-main int_ds_nota_entrada.nen_datamovimentacao_d = ? then do:
          assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main
                                                         + "Data de conferància n∆o informada!" + chr(32).
          assign int_ds_nota_entrada.nen_datamovimentacao_d:bgcolor in frame f-main = 14.
      end.
    
      if input frame f-main int_ds_nota_entrada.nen_datamovimentacao_d < int_ds_nota_entrada.nen_dataemissao_d then do:
          assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main
                                                         + "Data de conferància menor que a data de emiss∆o!" + chr(32).
          assign int_ds_nota_entrada.nen_datamovimentacao_d:bgcolor in frame f-main = 14.
      end.
   END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualiza-parent V-table-Win 
PROCEDURE pi-atualiza-parent :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter v-row-parent-externo as rowid no-undo.
    
    assign v-row-parent = v-row-parent-externo.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-calcula-totais V-table-Win 
PROCEDURE pi-calcula-totais :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   tot-base-icms-it        = 0.
   tot-base-icms-st-it     = 0.
   tot-cofins-it           = 0.
   tot-icms-it             = 0. 
   tot-icms-st-it          = 0. 
   tot-ipi-it              = 0. 
   tot-nf-it               = 0. 
   tot-tot-pis-it          = 0. 
   tot-valor-it            = 0.
   vl-cofins-itens         = 0. 
   vl-desconto-itens       = 0. 
   vl-icms-des-itens       = 0. 
   vl-pis-itens            = 0. 
   vl-total-nf             = int_ds_nota_entrada.nen_frete_n.
   tot-despesas-it         = 0.


   for each int_ds_nota_entrada_produt no-lock where
       int_ds_nota_entrada_produt.nen_cnpj_origem_s  = int_ds_nota_entrada.nen_cnpj_origem_s and 
       int_ds_nota_entrada_produt.nen_notafiscal_n   = int_ds_nota_entrada.nen_notafiscal_n  and 
       int_ds_nota_entrada_produt.nen_serie_s        = int_ds_nota_entrada.nen_serie_s:
       assign 
       tot-base-icms-it        = tot-base-icms-it       + int_ds_nota_entrada_produt.nep_baseicms_n
       tot-base-icms-st-it     = tot-base-icms-st-it    + int_ds_nota_entrada_produt.nep_basest_n
       tot-cofins-it           = tot-cofins-it          + int_ds_nota_entrada_produt.nep_valorcofins_n
       vl-desconto-itens       = vl-desconto-itens      + int_ds_nota_entrada_produt.nep_valordesconto_n
       tot-icms-it             = tot-icms-it            + int_ds_nota_entrada_produt.nep_valoricms_n
       tot-icms-st-it          = tot-icms-st-it         + int_ds_nota_entrada_produt.nep_icmsst_n
       tot-ipi-it              = tot-ipi-it             + int_ds_nota_entrada_produt.nep_valoripi_n
       tot-nf-it               = tot-nf-it              + int_ds_nota_entrada_produt.nep_valorBRUTO_n
       tot-tot-pis-it          = tot-tot-pis-it         + int_ds_nota_entrada_produt.nep_valorpis_n
       tot-valor-it            = tot-valor-it           + int_ds_nota_entrada_produt.nep_valorliquido_n
       vl-cofins-itens         = vl-cofins-itens        + int_ds_nota_entrada_produt.nep_valorcofins_n 
       vl-pis-itens            = vl-pis-itens           + int_ds_nota_entrada_produt.nep_valorpis_n
       vl-total-nf             = vl-total-nf            + (int_ds_nota_entrada_produt.nep_valorbruto_n
                                                        +  int_ds_nota_entrada_produt.nep_valoripi_n
                                                        +  int_ds_nota_entrada_produt.nep_icmsst_n
                                                        +  int_ds_nota_entrada_produt.nep_valordespesa_n)
                                                        - int_ds_nota_entrada_produt.nep_valordesconto_n.
       tot-despesas-it          = tot-despesas-it       + int_ds_nota_entrada_produt.nep_valordespesa_n.

   end.
   for each int_ds_docto_xml no-lock where 
       int_ds_docto_xml.serie = int_ds_nota_entrada.nen_serie_s and
       int_ds_docto_xml.nNF   matches  "*" + string(int_ds_nota_entrada.nen_notafiscal_n) and
       int_ds_docto_xml.CNPJ  = int_ds_nota_entrada.nen_cnpj_origem_s:
       vl-icms-des-itens      = vl-icms-des-itens      + int_ds_docto_xml.valor_icms_des.
       vl-total-nf            = int_ds_docto_xml.vNF.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cancela-recebimento V-table-Win 
PROCEDURE pi-cancela-recebimento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define buffer b-int_ds_nota_entrada for int_ds_nota_entrada.
    if avail int_ds_nota_entrada then do:
        run utp/ut-msgs.p(input "show",
                          input 701,
                          input ("recusa do recebimento da nota fiscal")).

        if return-value = "yes" then
        do transaction:
            for first b-int_ds_nota_entrada exclusive-lock where 
                rowid (b-int_ds_nota_entrada) = rowid (int_ds_nota_entrada):
                assign b-int_ds_nota_entrada.situacao = 9.
            end.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-re1001 V-table-Win 
PROCEDURE pi-gera-re1001 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    if avail int_ds_nota_entrada then do:
        for first emitente fields (cod-emitente)
            no-lock where emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s: end.
    
        c-cod-estabel = "".
        for each estabelec 
            fields (cod-estabel estado cidade 
                    cep pais endereco bairro ep-codigo) 
            no-lock where
            estabelec.cgc = int_ds_nota_entrada.nen_cnpj_destino_s,
            first cst_estabelec no-lock where 
            cst_estabelec.cod_estabel = estabelec.cod-estabel and
            cst_estabelec.dt_fim_operacao >= int_ds_nota_entrada.nen_dataemissao_d:
            c-cod-estabel = estabelec.cod-estabel.
            leave.
        end.
    
        create tt-param.
        assign tt-param.usuario          = c-seg-usuario
               tt-param.destino          = 3
               tt-param.data-exec        = today
               tt-param.hora-exec        = time
               tt-param.cod-emitente-ini = emitente.cod-emitente
               tt-param.cod-emitente-fim = emitente.cod-emitente
               tt-param.cod-estabel-fim  = c-cod-estabel 
               tt-param.cod-estabel-ini  = c-cod-estabel
               tt-param.dt-emis-nota-fim = int_ds_nota_entrada.nen_dataemissao_d
               tt-param.dt-emis-nota-ini = int_ds_nota_entrada.nen_dataemissao_d
               tt-param.nro-docto-fim    = int_ds_nota_entrada.nen_notafiscal_n
               tt-param.nro-docto-ini    = int_ds_nota_entrada.nen_notafiscal_n
               tt-param.serie-docto-fim  = int_ds_nota_entrada.nen_serie_s
               tt-param.serie-docto-ini  = int_ds_nota_entrada.nen_serie_s.
    
        assign tt-param.arquivo = session:temp-directory + "INT520" + ".tmp":U.
        
        /* Executar do programa RP.P que ir† criar o relat¢rio */
        SESSION:SET-WAIT-STATE("GENERAL":U).
    
        raw-transfer tt-param to raw-param.
        
        for first cst_estabelec no-lock where 
            cst_estabelec.cod_estabel = c-cod-estabel:
            if cst_estabelec.dt_inicio_oper <= int_ds_nota_entrada.nen_datamovimentacao_d then do:
                /* Filial Procfit */
                run intprg/int112rp.p (input raw-param,
                                       input table tt-raw-digita).
            end.
            else do:
                /* Filial Oblak */
                run intprg/int012rp.p (input raw-param,
                                       input table tt-raw-digita).
            end.
        end.
        /* Oblak */
        SESSION:SET-WAIT-STATE("":U).
        
        {report/rptrm.i}
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-processa-xml V-table-Win 
PROCEDURE pi-processa-xml :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEF VAR cEditor     AS CHAR.
    DEF VAR vLog        AS LOGICAL.

    if avail int_ds_nota_entrada then do:
        empty temp-table tt-param-int520d.
        create tt-param-int520d.
        assign tt-param-int520d.usuario          = c-seg-usuario
               tt-param-int520d.destino          = 3
               tt-param-int520d.data-exec        = today
               tt-param-int520d.hora-exec        = time
               tt-param-int520d.r-rowid          = rowid(int_ds_nota_entrada).
    
        assign tt-param-int520d.arquivo = session:temp-directory + "INT520d" + ".tmp":U.
        
        /* Executar do programa RP.P que ir† criar o relat¢rio */
        SESSION:SET-WAIT-STATE("GENERAL":U).
    
        raw-transfer tt-param-int520d to raw-param.
        
        run intprg/int520d.p (input raw-param,
                              input table tt-raw-digita).
        
        SESSION:SET-WAIT-STATE("":U).
        
        GET-KEY-VALUE SECTION "Datasul_EMS2":U KEY "Show-Report-Program":U VALUE cEditor.

        IF  SEARCH(cEditor) = ? THEN DO:
            ASSIGN  cEditor = OS-GETENV("windir") + "~\notepad.exe"
                    vLog    = YES.
            IF  SEARCH(cEditor) = ? THEN DO:
                ASSIGN  cEditor = OS-GETENV("windir") + "~\write.exe".
                IF  SEARCH(cEditor) = ? THEN DO:
                    RUN utp/ut-msgs.p (INPUT "show",
                                       INPUT 27576,
                                       INPUT tt-param-int520d.arquivo).
                    ASSIGN  vLog    = NO.
                END.
            END.
        END.

        RUN winexec (INPUT cEditor + CHR(32) + tt-param-int520d.arquivo, INPUT 1).

        empty temp-table tt-param-int520d.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Pi-validate V-table-Win 
PROCEDURE Pi-validate :
/*:T------------------------------------------------------------------------------
  Purpose:Validar a viewer     
  Parameters:  <none>
  Notes: N∆o fazer assign aqui. Nesta procedure
  devem ser colocadas apenas validaá‰es, pois neste ponto do programa o registro 
  ainda n∆o foi criado.       
------------------------------------------------------------------------------*/
    {include/i-vldfrm.i} /*:T Validaá∆o de dicion†rio */
    
/*:T    Segue um exemplo de validaá∆o de programa */
/*       find tabela where tabela.campo1 = c-variavel and               */
/*                         tabela.campo2 > i-variavel no-lock no-error. */
      
      /*:T Este include deve ser colocado sempre antes do ut-msgs.p */
/*       {include/i-vldprg.i}                                             */
/*       run utp/ut-msgs.p (input "show":U, input 7, input return-value). */
/*       return 'ADM-ERROR':U.                                            */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "int_ds_nota_entrada"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

