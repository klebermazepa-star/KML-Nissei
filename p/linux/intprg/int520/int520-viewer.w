&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           PROGRESS
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
&Scoped-define EXTERNAL-TABLES int-ds-nota-entrada
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-nota-entrada


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-nota-entrada.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int-ds-nota-entrada.nen-chaveacesso-s ~
int-ds-nota-entrada.ped-codigo-n 
&Scoped-define ENABLED-TABLES int-ds-nota-entrada
&Scoped-define FIRST-ENABLED-TABLE int-ds-nota-entrada
&Scoped-Define ENABLED-OBJECTS rt-key RECT-1 RECT-3 RECT-4 RECT-5 RECT-6 ~
RECT-7 RECT-8 RECT-9 RECT-10 RECT-11 RECT-12 RECT-13 RECT-14 RECT-15 ~
RECT-16 RECT-17 RECT-18 RECT-19 RECT-20 RECT-21 RECT-23 c-mensagem 
&Scoped-Define DISPLAYED-FIELDS int-ds-nota-entrada.nen-chaveacesso-s ~
int-ds-nota-entrada.nen-cnpj-origem-s int-ds-nota-entrada.nen-notafiscal-n ~
int-ds-nota-entrada.nen-serie-s int-ds-nota-entrada.nen-dataemissao-d ~
int-ds-nota-entrada.ped-codigo-n int-ds-nota-entrada.nen-cfop-n ~
int-ds-nota-entrada.nen-baseicms-n int-ds-nota-entrada.nen-valoricms-n ~
int-ds-nota-entrada.nen-basest-n int-ds-nota-entrada.nen-icmsst-n ~
int-ds-nota-entrada.nen-frete-n int-ds-nota-entrada.nen-seguro-n ~
int-ds-nota-entrada.nen-despesas-n int-ds-nota-entrada.nen-valoripi-n ~
int-ds-nota-entrada.nen-desconto-n 
&Scoped-define DISPLAYED-TABLES int-ds-nota-entrada
&Scoped-define FIRST-DISPLAYED-TABLE int-ds-nota-entrada
&Scoped-Define DISPLAYED-OBJECTS i-cod-emitente cFornecedor cUF c-cod-estab ~
cEstabelec cNatureza data-emissao data-entrega cComprador c-mensagem ~
tot-nf-it vl-total-nf vl-desconto-itens vl-pis-itens vl-cofins-itens ~
vl-icms-des-itens 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
ep-codigo||y|emsesp.int-ds-nota-entrada.ep-codigo
</FOREIGN-KEYS> 
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = ,
     Keys-Supplied = "ep-codigo"':U).
/**************************
</EXECUTING-CODE> */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE c-mensagem AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 41.5 BY 5.6
     FONT 0 NO-UNDO.

DEFINE VARIABLE c-cod-estab AS CHARACTER FORMAT "x(8)" 
     LABEL "Filial" 
     VIEW-AS FILL-IN 
     SIZE 4.75 BY .87.

DEFINE VARIABLE cComprador AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 33 BY .8 NO-UNDO.

DEFINE VARIABLE cEstabelec AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 56.63 BY .87 NO-UNDO.

DEFINE VARIABLE cFornecedor AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 51 BY .87 NO-UNDO.

DEFINE VARIABLE cNatureza AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 56.38 BY .87 NO-UNDO.

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
     int-ds-nota-entrada.nen-chaveacesso-s AT ROW 1.2 COL 11.25 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 61.13 BY .87
     int-ds-nota-entrada.nen-cnpj-origem-s AT ROW 2.07 COL 103.63 COLON-ALIGNED WIDGET-ID 164
          LABEL "CNPJ"
          VIEW-AS FILL-IN 
          SIZE 16 BY .87
     i-cod-emitente AT ROW 2.13 COL 11.25 COLON-ALIGNED WIDGET-ID 4
     cFornecedor AT ROW 2.13 COL 21.63 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     cUF AT ROW 2.13 COL 80.63 COLON-ALIGNED WIDGET-ID 16
     c-cod-estab AT ROW 3.03 COL 11.25 COLON-ALIGNED WIDGET-ID 6
     cEstabelec AT ROW 3.03 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     int-ds-nota-entrada.nen-notafiscal-n AT ROW 3.03 COL 80.63 COLON-ALIGNED WIDGET-ID 8
          LABEL "Nota"
          VIEW-AS FILL-IN 
          SIZE 14.63 BY .87
     int-ds-nota-entrada.nen-serie-s AT ROW 3.03 COL 103.63 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 9.25 BY .87
     int-ds-nota-entrada.nen-dataemissao-d AT ROW 3.03 COL 126.63 COLON-ALIGNED WIDGET-ID 108
          LABEL "Emiss∆o"
          VIEW-AS FILL-IN 
          SIZE 11.25 BY .87
     int-ds-nota-entrada.ped-codigo-n AT ROW 4.77 COL 68.63 COLON-ALIGNED NO-LABEL WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 11.63 BY .87
     int-ds-nota-entrada.nen-cfop-n AT ROW 4.8 COL 2.63 NO-LABEL WIDGET-ID 20
          VIEW-AS FILL-IN 
          SIZE 10.25 BY .87
     cNatureza AT ROW 4.8 COL 10.63 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     data-emissao AT ROW 4.8 COL 81.63 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     data-entrega AT ROW 4.8 COL 94 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     cComprador AT ROW 4.8 COL 107.63 COLON-ALIGNED NO-LABEL WIDGET-ID 140
     c-mensagem AT ROW 6.33 COL 102.5 NO-LABEL WIDGET-ID 168
     int-ds-nota-entrada.nen-baseicms-n AT ROW 7.07 COL 1.25 COLON-ALIGNED NO-LABEL WIDGET-ID 44
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int-ds-nota-entrada.nen-valoricms-n AT ROW 7.07 COL 20.75 COLON-ALIGNED NO-LABEL WIDGET-ID 32
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int-ds-nota-entrada.nen-basest-n AT ROW 7.07 COL 40.75 COLON-ALIGNED NO-LABEL WIDGET-ID 46
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int-ds-nota-entrada.nen-icmsst-n AT ROW 7.07 COL 60.75 COLON-ALIGNED NO-LABEL WIDGET-ID 42
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     tot-nf-it AT ROW 7.07 COL 81.5 COLON-ALIGNED NO-LABEL WIDGET-ID 160
     int-ds-nota-entrada.nen-frete-n AT ROW 8.93 COL 3.25 NO-LABEL WIDGET-ID 30
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int-ds-nota-entrada.nen-seguro-n AT ROW 8.93 COL 20.75 COLON-ALIGNED NO-LABEL WIDGET-ID 40
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int-ds-nota-entrada.nen-despesas-n AT ROW 8.93 COL 40.75 COLON-ALIGNED NO-LABEL WIDGET-ID 38
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int-ds-nota-entrada.nen-valoripi-n AT ROW 8.93 COL 61.25 COLON-ALIGNED NO-LABEL WIDGET-ID 34
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     vl-total-nf AT ROW 9 COL 81.5 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     int-ds-nota-entrada.nen-desconto-n AT ROW 10.87 COL 1.25 COLON-ALIGNED NO-LABEL WIDGET-ID 110
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     vl-desconto-itens AT ROW 10.87 COL 20.75 COLON-ALIGNED NO-LABEL WIDGET-ID 118
     vl-pis-itens AT ROW 10.87 COL 41 COLON-ALIGNED NO-LABEL WIDGET-ID 154
     vl-cofins-itens AT ROW 10.87 COL 61 COLON-ALIGNED NO-LABEL WIDGET-ID 156
     vl-icms-des-itens AT ROW 10.87 COL 81.63 COLON-ALIGNED NO-LABEL WIDGET-ID 158
     "Descontos" VIEW-AS TEXT
          SIZE 10.63 BY .67 AT ROW 10.07 COL 2.75 WIDGET-ID 138
     "Natureza de Operaá∆o" VIEW-AS TEXT
          SIZE 20.63 BY .57 AT ROW 4.2 COL 3 WIDGET-ID 74
     "Desconto Itens" VIEW-AS TEXT
          SIZE 14.63 BY .67 AT ROW 10.07 COL 22.75 WIDGET-ID 132
     "Valor ICMS ST" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 6.27 COL 62.63 WIDGET-ID 66
     "ICMS Desonerado" VIEW-AS TEXT
          SIZE 17 BY .67 AT ROW 10.07 COL 83.25 WIDGET-ID 130
     "Base ICMS ST" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 6.27 COL 42.63 WIDGET-ID 62
     "Pedido" VIEW-AS TEXT
          SIZE 7 BY .43 AT ROW 4.3 COL 70.63 WIDGET-ID 78
     "Valor Total NF" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 8.13 COL 83.13 WIDGET-ID 96
     "Emiss∆o" VIEW-AS TEXT
          SIZE 8 BY .43 AT ROW 4.3 COL 83.63 WIDGET-ID 82
     "Base C†lculo" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 6.27 COL 2.63 WIDGET-ID 50
     "Valor ICMS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 6.27 COL 22.63 WIDGET-ID 58
     "Valor Produtos" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 6.27 COL 83.13 WIDGET-ID 70
     "Vl Frete" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 8.13 COL 2.63 WIDGET-ID 104
     "Vl Despesas" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 8.13 COL 42.63 WIDGET-ID 100
     "Comprador" VIEW-AS TEXT
          SIZE 10.88 BY .43 AT ROW 4.27 COL 109.63 WIDGET-ID 144
     "Vl PIS" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 10.07 COL 42.75 WIDGET-ID 134
     "Valor IPI" VIEW-AS TEXT
          SIZE 8.63 BY .67 AT ROW 8.13 COL 63.25 WIDGET-ID 102
     "Vl Seguro" VIEW-AS TEXT
          SIZE 9.63 BY .67 AT ROW 8.13 COL 22.63 WIDGET-ID 98
     "Entrega" VIEW-AS TEXT
          SIZE 8 BY .43 AT ROW 4.27 COL 96 WIDGET-ID 86
     "Vl COFINS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 10.07 COL 62.75 WIDGET-ID 136
     rt-key AT ROW 1 COL 1
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
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
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
   External Tables: emsesp.int-ds-nota-entrada
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
         HEIGHT             = 11.3
         WIDTH              = 143.13.
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
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-baseicms-n IN FRAME f-main
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-basest-n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-cfop-n IN FRAME f-main
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-cnpj-origem-s IN FRAME f-main
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-dataemissao-d IN FRAME f-main
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-desconto-n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-despesas-n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-frete-n IN FRAME f-main
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-icmsst-n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-notafiscal-n IN FRAME f-main
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-seguro-n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-serie-s IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-valoricms-n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-valoripi-n IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-nota-entrada.ped-codigo-n IN FRAME f-main
   EXP-LABEL                                                            */
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


&Scoped-define SELF-NAME int-ds-nota-entrada.nen-cfop-n
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-nota-entrada.nen-cfop-n V-table-Win
ON LEAVE OF int-ds-nota-entrada.nen-cfop-n IN FRAME f-main /* CFOP */
DO:
    
    for first cfop-natur fields (des-cfop)
        no-lock where 
        cfop-natur.cod-cfop = int-ds-nota-entrada.nen-cfop-n:screen-value in FRAME f-main:
        assign  cNatureza:screen-value in frame f-Main = cfop-natur.des-cfop.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-nota-entrada.ped-codigo-n
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-nota-entrada.ped-codigo-n V-table-Win
ON LEAVE OF int-ds-nota-entrada.ped-codigo-n IN FRAME f-main /* Pedido */
DO:
    for first pedido-compr no-lock where 
        pedido-compr.num-pedido = input frame f-main int-ds-nota-entrada.ped-codigo-n:
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
        for first emitente fields (cod-emitente) no-lock where 
            emitente.cod-emitente = pedido-compr.cod-emitente: end.
        if avail emitente and emitente.cod-emitente <> i-cod-emitente:input-value in frame f-Main then do:
            assign emsesp.int-ds-nota-entrada.ped-codigo-n:bgcolor in frame f-Main = 14.
            assign c-mensagem:screen-value in frame f-main = "Pedido n∆o Ç deste fornecedor!" + chr(32).
        end.
        else do:
            assign emsesp.int-ds-nota-entrada.ped-codigo-n:bgcolor in frame f-Main = ?.
        end.
    end.
    if not avail pedido-compr and 
       input frame f-main int-ds-nota-entrada.ped-codigo-n <> ? and
       input frame f-main int-ds-nota-entrada.ped-codigo-n <> 0 then do:
        assign c-mensagem:screen-value in frame f-main = "Pedido n∆o encontrado!" + chr(32).
        assign emsesp.int-ds-nota-entrada.ped-codigo-n:bgcolor in frame f-Main = 14.
    end.
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
  {src/adm/template/row-list.i "int-ds-nota-entrada"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int-ds-nota-entrada"}

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
    if adm-new-record = yes then
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
  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'row-available':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  if avail int-ds-nota-entrada then do:
      
      RUN pi-calcula-totais in this-procedure.

      if  tot-base-icms-it        = int-ds-nota-entrada.nen-baseicms-n 
          then int-ds-nota-entrada.nen-baseicms-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-baseicms-n:bgcolor in frame f-Main = 14.
      if  tot-base-icms-st-it     = int-ds-nota-entrada.nen-basest-n
          then int-ds-nota-entrada.nen-basest-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-basest-n:bgcolor in frame f-Main = 14.
      if  vl-desconto-itens       = int-ds-nota-entrada.nen-desconto-n
          then int-ds-nota-entrada.nen-desconto-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-desconto-n:bgcolor in frame f-Main = 14.
      if  tot-icms-it             = int-ds-nota-entrada.nen-valoricms-n
          then int-ds-nota-entrada.nen-valoricms-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-valoricms-n:bgcolor in frame f-Main = 14.
      if  tot-icms-st-it          = int-ds-nota-entrada.nen-icmsst-n
          then int-ds-nota-entrada.nen-icmsst-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-icmsst-n:bgcolor in frame f-Main = 14.
      if  tot-ipi-it              = int-ds-nota-entrada.nen-valoripi-n
          then int-ds-nota-entrada.nen-valoripi-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-valoripi-n:bgcolor in frame f-Main = 14.
      /* 
      if  tot-nf-it               = int-ds-nota-entrada.nen-valortotalprodutos-n 
          then int-ds-nota-entrada.nen-valortotalprodutos-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-valortotalprodutos-n:bgcolor in frame f-Main = 14.
          */

  end.
  assign c-mensagem:screen-value in frame f-main = "".

  assign vl-desconto-itens:screen-value in frame f-main = string(vl-desconto-itens).
  assign vl-pis-itens:screen-value in frame f-main = string(vl-pis-itens).
  assign vl-cofins-itens:screen-value in frame f-main = string(vl-cofins-itens).
  assign vl-icms-des-itens:screen-value in frame f-main = string(vl-icms-des-itens).
  assign vl-total-nf:screen-value in frame f-main = string(vl-total-nf).
  assign tot-nf-it:screen-value in frame f-main = string(tot-nf-it).

  i-cod-emitente = 0.
  for first emitente fields (cod-emitente) no-lock where 
      emitente.cgc = int-ds-nota-entrada.nen-cnpj-origem-s:
      i-cod-emitente = emitente.cod-emitente.
  end.
  c-cod-estab = "".
  for first estabelec fields (cod-estabel) no-lock where 
      estabelec.cgc = int-ds-nota-entrada.nen-cnpj-destino-s:
      c-cod-estab = estabelec.cod-estabel.
  end.

  display i-cod-emitente c-cod-estab with frame f-main.

  apply "leave":u to i-cod-emitente in frame f-main.
  apply "leave":u to c-cod-estab in frame f-main.
  apply "leave":u to int-ds-nota-entrada.nen-cfop-n in frame f-main.
  apply "leave":u to int-ds-nota-entrada.ped-codigo-n in frame f-main.

  for first int-ds-nota-entrada-dup no-lock of int-ds-nota-entrada: end.
  if not avail int-ds-nota-entrada-dup then do:
      assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main
                                                     + "N∆o encotradas duplicatas para o documento!" + chr(32).
  end.

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
   vl-total-nf             = 0. 


   for each int-ds-nota-entrada-produto no-lock where
       int-ds-nota-entrada-produto.nen-cnpj-origem-s  = int-ds-nota-entrada-produto.nen-cnpj-origem-s and 
       int-ds-nota-entrada-produto.nen-notafiscal-n   = int-ds-nota-entrada.nen-notafiscal-n       and 
       int-ds-nota-entrada-produto.nen-serie-s        = int-ds-nota-entrada.nen-serie-s:
       assign 
       tot-base-icms-it        = tot-base-icms-it       + int-ds-nota-entrada-produto.nep-baseicms-n
       tot-base-icms-st-it     = tot-base-icms-st-it    + int-ds-nota-entrada-produto.nep-basest-n
       tot-cofins-it           = tot-cofins-it          + int-ds-nota-entrada-produto.nep-valorcofins-n
       vl-desconto-itens       = vl-desconto-itens      + int-ds-nota-entrada-produto.nep-valordesconto-n
       tot-icms-it             = tot-icms-it            + int-ds-nota-entrada-produto.nep-valoricms-n
       tot-icms-st-it          = tot-icms-st-it         + int-ds-nota-entrada-produto.nep-icmsst-n
       tot-ipi-it              = tot-ipi-it             + int-ds-nota-entrada-produto.nep-valoripi-n
       tot-nf-it               = tot-nf-it              + int-ds-nota-entrada-produto.nep-valorBRUTO-n
                                                        - int-ds-nota-entrada-produto.nep-valordesconto-n
       tot-tot-pis-it          = tot-tot-pis-it         + int-ds-nota-entrada-produto.nep-valorpis-n
       tot-valor-it            = tot-valor-it           + int-ds-nota-entrada-produto.nep-valorliquido-n
       vl-cofins-itens         = vl-cofins-itens        + int-ds-nota-entrada-produto.nep-valorcofins-n 
       vl-pis-itens            = vl-pis-itens           + int-ds-nota-entrada-produto.nep-valorpis-n
       vl-total-nf             = vl-total-nf            + (int-ds-nota-entrada-produto.nep-valorbruto-n
                                                        +  int-ds-nota-entrada-produto.nep-valoripi-n
                                                        +  int-ds-nota-entrada-produto.nep-icmsst-n
                                                        +  int-ds-nota-entrada-produto.nep-valordespesa-n)
                                                        - int-ds-nota-entrada-produto.nep-valordesconto-n.
   end.
   for each int-ds-docto-xml no-lock where 
       int-ds-docto-xml.serie = int-ds-nota-entrada.nen-serie-s and
       int-ds-docto-xml.nNF   matches  "*" + string(int-ds-nota-entrada.nen-notafiscal-n) and
       int-ds-docto-xml.CNPJ  = int-ds-nota-entrada.nen-cnpj-origem-s:
       vl-icms-des-itens      = vl-icms-des-itens      + int-ds-docto-xml.valor-icms-des.
       vl-total-nf            = int-ds-docto-xml.vNF.
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
    if avail int-ds-nota-entrada then do:
        for first emitente fields (cod-emitente)
            no-lock where emitente.cgc = int-ds-nota-entrada.nen-cnpj-origem-s: end.
    
        c-cod-estabel = "".
        for each estabelec 
            fields (cod-estabel estado cidade 
                    cep pais endereco bairro ep-codigo) 
            no-lock where
            estabelec.cgc = int-ds-nota-entrada.nen-cnpj-destino-s,
            first cst-estabelec no-lock where 
            cst-estabelec.cod-estabel = estabelec.cod-estabel and
            cst-estabelec.dt-fim-operacao >= int-ds-nota-entrada.nen-dataemissao-d:
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
               tt-param.dt-emis-nota-fim = int-ds-nota-entrada.nen-dataemissao-d
               tt-param.dt-emis-nota-ini = int-ds-nota-entrada.nen-dataemissao-d
               tt-param.nro-docto-fim    = int-ds-nota-entrada.nen-notafiscal-n
               tt-param.nro-docto-ini    = int-ds-nota-entrada.nen-notafiscal-n
               tt-param.serie-docto-fim  = int-ds-nota-entrada.nen-serie-s
               tt-param.serie-docto-ini  = int-ds-nota-entrada.nen-serie-s.
    
        assign tt-param.arquivo = session:temp-directory + "INT520" + ".tmp":U.
        
        /* Executar do programa RP.P que ir† criar o relat¢rio */
        SESSION:SET-WAIT-STATE("GENERAL":U).
    
        raw-transfer tt-param to raw-param.
        
        run intprg/int012rp.p (input raw-param,
                               input table tt-raw-digita).
        
        SESSION:SET-WAIT-STATE("":U).
        
        {report/rptrm.i}
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
  {src/adm/template/snd-list.i "int-ds-nota-entrada"}

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

