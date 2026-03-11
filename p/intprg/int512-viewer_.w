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
{include/i-prgvrs.i int512-viewer 1.12.00.AVB}

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
def var c-aux as char no-undo.

DEFINE VARIABLE tot-base-icms-it        AS DECIMAL INITIAL 0 NO-UNDO.
DEFINE VARIABLE tot-base-icms-st-it     AS DECIMAL INITIAL 0 NO-UNDO.
DEFINE VARIABLE tot-cofins-it           AS DECIMAL INITIAL 0 NO-UNDO.
DEFINE VARIABLE tot-desconto-it         AS DECIMAL INITIAL 0 NO-UNDO.
DEFINE VARIABLE tot-icms-it             AS DECIMAL INITIAL 0 NO-UNDO. 
DEFINE VARIABLE tot-icms-st-it          AS DECIMAL INITIAL 0 NO-UNDO. 
DEFINE VARIABLE tot-ipi-it              AS DECIMAL INITIAL 0 NO-UNDO. 
DEFINE VARIABLE tot-nf-it               AS DECIMAL INITIAL 0 NO-UNDO. 
DEFINE VARIABLE tot-tot-pis-it          AS DECIMAL INITIAL 0 NO-UNDO. 
DEFINE VARIABLE tot-valor-it            AS DECIMAL INITIAL 0 NO-UNDO.
DEFINE VARIABLE tot-icms-des            AS DECIMAL INITIAL 0 NO-UNDO.

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
    field nro-docto-fim    as char
    field nro-docto-ini    as char
    field serie-docto-fim  as char
    field serie-docto-ini  as char.

def var raw-param        as raw no-undo.

def temp-table tt-raw-digita
    field raw-digita      as raw.

PROCEDURE WinExec EXTERNAL "kernel32.dll":U:
  DEF INPUT  PARAM prg_name                          AS CHARACTER.
  DEF INPUT  PARAM prg_style                         AS SHORT.
END PROCEDURE.

{cdp/cd4305.i1}  /* Definicao TT-DOCTO, TT-IT-DOCTO p/ calculo dos tributos */

def temp-table tt-dupli no-undo
      field parcela          as integer
      field dt-vencimen      like dupli-apagar.dt-vencim
      field vl-apagar        like dupli-apagar.vl-a-pagar.

define buffer b-int-ds-docto-xml for int-ds-docto-xml.
define buffer b-int-ds-it-docto-xml for int-ds-it-docto-xml.

define variable h-boin176 as handle.

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
&Scoped-define EXTERNAL-TABLES int-ds-docto-xml
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-docto-xml


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-docto-xml.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int-ds-docto-xml.chnfe int-ds-docto-xml.cfop ~
int-ds-docto-xml.cod-estab int-ds-docto-xml.dEmi ~
int-ds-docto-xml.num-pedido int-ds-docto-xml.nat-operacao ~
int-ds-docto-xml.vbc int-ds-docto-xml.valor-icms int-ds-docto-xml.vbc-cst ~
int-ds-docto-xml.valor-st int-ds-docto-xml.valor-mercad ~
int-ds-docto-xml.valor-frete int-ds-docto-xml.valor-seguro ~
int-ds-docto-xml.valor-outras int-ds-docto-xml.valor-ipi ~
int-ds-docto-xml.vNF int-ds-docto-xml.tot-desconto ~
int-ds-docto-xml.valor-pis int-ds-docto-xml.valor-cofins ~
int-ds-docto-xml.valor-icms-des 
&Scoped-define ENABLED-TABLES int-ds-docto-xml
&Scoped-define FIRST-ENABLED-TABLE int-ds-docto-xml
&Scoped-Define ENABLED-OBJECTS rt-key RECT-1 RECT-3 RECT-4 RECT-5 RECT-6 ~
RECT-7 RECT-8 RECT-9 RECT-10 RECT-11 RECT-12 RECT-13 RECT-14 RECT-15 ~
RECT-16 RECT-17 RECT-18 RECT-19 RECT-20 RECT-21 c-Mensagem 
&Scoped-Define DISPLAYED-FIELDS int-ds-docto-xml.chnfe ~
int-ds-docto-xml.cod-emitente int-ds-docto-xml.cfop ~
int-ds-docto-xml.cod-estab int-ds-docto-xml.nNF int-ds-docto-xml.serie ~
int-ds-docto-xml.dEmi int-ds-docto-xml.num-pedido ~
int-ds-docto-xml.nat-operacao int-ds-docto-xml.vbc ~
int-ds-docto-xml.valor-icms int-ds-docto-xml.vbc-cst ~
int-ds-docto-xml.valor-st int-ds-docto-xml.valor-mercad ~
int-ds-docto-xml.valor-frete int-ds-docto-xml.valor-seguro ~
int-ds-docto-xml.valor-outras int-ds-docto-xml.valor-ipi ~
int-ds-docto-xml.vNF int-ds-docto-xml.tot-desconto ~
int-ds-docto-xml.valor-pis int-ds-docto-xml.valor-cofins ~
int-ds-docto-xml.valor-icms-des 
&Scoped-define DISPLAYED-TABLES int-ds-docto-xml
&Scoped-define FIRST-DISPLAYED-TABLE int-ds-docto-xml
&Scoped-Define DISPLAYED-OBJECTS i-situacao c-Situacao i-sit-re c-Sitre ~
cFornecedor cUF c-tipo-nota dt-movto cEstabelec cNatureza data-emissao ~
data-entrega cComprador c-Mensagem vl-desconto-itens 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS int-ds-docto-xml.cod-emitente ~
int-ds-docto-xml.nNF int-ds-docto-xml.serie 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
ep-codigo||y|emsesp.int-ds-docto-xml.ep-codigo
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

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnTrataNuloDec V-table-Win 
FUNCTION fnTrataNuloDec RETURNS decimal (p-valor as decimal) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE c-Mensagem AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 42 BY 5.5 NO-UNDO.

DEFINE VARIABLE c-Sitre AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 31 BY .88 NO-UNDO.

DEFINE VARIABLE c-Situacao AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 13.86 BY .88 NO-UNDO.

DEFINE VARIABLE c-tipo-nota AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 24.72 BY .88 NO-UNDO.

DEFINE VARIABLE cComprador AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 33 BY .79 NO-UNDO.

DEFINE VARIABLE cEstabelec AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 56.57 BY .88 NO-UNDO.

DEFINE VARIABLE cFornecedor AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 51 BY .88 NO-UNDO.

DEFINE VARIABLE cNatureza AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 56 BY .88 NO-UNDO.

DEFINE VARIABLE cUF AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 3.57 BY .88 NO-UNDO.

DEFINE VARIABLE data-emissao AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 10.57 BY .88 NO-UNDO.

DEFINE VARIABLE data-entrega AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE dt-movto AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Movto" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11.29 BY .88 NO-UNDO.

DEFINE VARIABLE i-sit-re AS INTEGER FORMAT ">9" INITIAL 1 
     LABEL "Fase":R5 
     VIEW-AS FILL-IN NATIVE 
     SIZE 3.14 BY .88.

DEFINE VARIABLE i-situacao AS INTEGER FORMAT ">9" INITIAL 1 
     LABEL "Situaá∆o":R10 
     VIEW-AS FILL-IN NATIVE 
     SIZE 3.14 BY .88.

DEFINE VARIABLE vl-desconto-itens AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 17.29 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 12.57 BY 1.33.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-17
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-18
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-20
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 35.43 BY 1.33.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 19.57 BY 1.58.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 68.57 BY 1.33.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 12.57 BY 1.33.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 12 BY 1.33.

DEFINE RECTANGLE rt-key
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 142.86 BY 3.21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int-ds-docto-xml.chnfe AT ROW 1.21 COL 11.29 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 61.14 BY .88
     i-situacao AT ROW 1.21 COL 82.86 COLON-ALIGNED WIDGET-ID 162
     c-Situacao AT ROW 1.21 COL 86.14 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     i-sit-re AT ROW 1.21 COL 105.72 COLON-ALIGNED HELP
          "Situaá∆o Atualizaá∆o" WIDGET-ID 160
     c-Sitre AT ROW 1.21 COL 109 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     int-ds-docto-xml.cod-emitente AT ROW 2.13 COL 11.29 COLON-ALIGNED WIDGET-ID 4
          LABEL "Fornecedor":R10
          VIEW-AS FILL-IN 
          SIZE 10.29 BY .88
     cFornecedor AT ROW 2.13 COL 21.57 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     cUF AT ROW 2.13 COL 72.72 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     int-ds-docto-xml.cfop AT ROW 2.13 COL 82.86 COLON-ALIGNED WIDGET-ID 156
          VIEW-AS FILL-IN 
          SIZE 7.14 BY .88
     c-tipo-nota AT ROW 2.13 COL 90.29 COLON-ALIGNED NO-LABEL WIDGET-ID 178
     dt-movto AT ROW 2.13 COL 128.57 COLON-ALIGNED WIDGET-ID 176
     int-ds-docto-xml.cod-estab AT ROW 3.04 COL 11.29 COLON-ALIGNED WIDGET-ID 6
          LABEL "Filial"
          VIEW-AS FILL-IN 
          SIZE 4.72 BY .88
     cEstabelec AT ROW 3.04 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     int-ds-docto-xml.nNF AT ROW 3.04 COL 82.86 COLON-ALIGNED WIDGET-ID 8
          LABEL "Nota"
          VIEW-AS FILL-IN 
          SIZE 14.57 BY .88
     int-ds-docto-xml.serie AT ROW 3.04 COL 105.57 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 9.29 BY .88
     int-ds-docto-xml.dEmi AT ROW 3.04 COL 128.57 COLON-ALIGNED WIDGET-ID 108
          LABEL "Emiss∆o"
          VIEW-AS FILL-IN 
          SIZE 11.29 BY .88
     int-ds-docto-xml.num-pedido AT ROW 4.75 COL 68.57 COLON-ALIGNED NO-LABEL WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 11.57 BY .88
     int-ds-docto-xml.nat-operacao AT ROW 4.79 COL 2.57 NO-LABEL WIDGET-ID 20
          VIEW-AS FILL-IN 
          SIZE 10.29 BY .88
     cNatureza AT ROW 4.79 COL 11 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     data-emissao AT ROW 4.79 COL 81.57 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     data-entrega AT ROW 4.79 COL 94 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     cComprador AT ROW 4.79 COL 107.57 COLON-ALIGNED NO-LABEL WIDGET-ID 140
     c-Mensagem AT ROW 6.5 COL 102 NO-LABEL WIDGET-ID 168
     int-ds-docto-xml.vbc AT ROW 7.08 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 44
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.valor-icms AT ROW 7.08 COL 20.72 COLON-ALIGNED NO-LABEL WIDGET-ID 32
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.vbc-cst AT ROW 7.08 COL 40.72 COLON-ALIGNED NO-LABEL WIDGET-ID 46
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.valor-st AT ROW 7.08 COL 60.72 COLON-ALIGNED NO-LABEL WIDGET-ID 42
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.valor-mercad AT ROW 7.08 COL 81.29 COLON-ALIGNED NO-LABEL WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.valor-frete AT ROW 8.92 COL 3 NO-LABEL WIDGET-ID 30
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.valor-seguro AT ROW 8.92 COL 20.72 COLON-ALIGNED NO-LABEL WIDGET-ID 40
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     int-ds-docto-xml.valor-outras AT ROW 8.92 COL 40.72 COLON-ALIGNED NO-LABEL WIDGET-ID 38
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.valor-ipi AT ROW 8.92 COL 60.86 COLON-ALIGNED NO-LABEL WIDGET-ID 34
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.vNF AT ROW 8.92 COL 81.29 COLON-ALIGNED NO-LABEL WIDGET-ID 48
          VIEW-AS FILL-IN 
          SIZE 17.57 BY .88
     int-ds-docto-xml.tot-desconto AT ROW 10.88 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 110
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     vl-desconto-itens AT ROW 10.88 COL 20.72 COLON-ALIGNED NO-LABEL WIDGET-ID 118
     int-ds-docto-xml.valor-pis AT ROW 10.88 COL 40.72 COLON-ALIGNED NO-LABEL WIDGET-ID 116
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.valor-cofins AT ROW 10.88 COL 60.86 COLON-ALIGNED NO-LABEL WIDGET-ID 112
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.valor-icms-des AT ROW 10.88 COL 81.29 COLON-ALIGNED NO-LABEL WIDGET-ID 114
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     "Vl PIS" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 10.08 COL 42.72 WIDGET-ID 134
     "Vl Seguro" VIEW-AS TEXT
          SIZE 9.57 BY .67 AT ROW 8.13 COL 22.57 WIDGET-ID 98
     "Vl Frete" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 8.13 COL 2.57 WIDGET-ID 104
     "Comprador" VIEW-AS TEXT
          SIZE 10.86 BY .42 AT ROW 4.25 COL 109.57 WIDGET-ID 144
     "Base C†lculo" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 6.25 COL 2.57 WIDGET-ID 50
     "Vl Despesas" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 8.13 COL 42.57 WIDGET-ID 100
     "Vl COFINS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 10.08 COL 62.57 WIDGET-ID 136
     "ICMS Desonerado" VIEW-AS TEXT
          SIZE 17 BY .67 AT ROW 10.08 COL 83.29 WIDGET-ID 130
     "Valor ICMS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 6.25 COL 22.57 WIDGET-ID 58
     "Emiss∆o" VIEW-AS TEXT
          SIZE 8 BY .42 AT ROW 4.29 COL 83.57 WIDGET-ID 82
     "Natureza de Operaá∆o" VIEW-AS TEXT
          SIZE 20.57 BY .58 AT ROW 4.21 COL 3 WIDGET-ID 74
     "Descontos" VIEW-AS TEXT
          SIZE 10.57 BY .67 AT ROW 10.08 COL 2.72 WIDGET-ID 138
     "Base ICMS ST" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 6.25 COL 42.57 WIDGET-ID 62
     "Valor Produtos" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 6.25 COL 83.14 WIDGET-ID 70
     "Pedido" VIEW-AS TEXT
          SIZE 7 BY .42 AT ROW 4.29 COL 70.57 WIDGET-ID 78
     "Valor ICMS ST" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 6.25 COL 62.57 WIDGET-ID 66
     "Valor IPI" VIEW-AS TEXT
          SIZE 8.57 BY .67 AT ROW 8.13 COL 62.57 WIDGET-ID 102
     "Entrega" VIEW-AS TEXT
          SIZE 8 BY .42 AT ROW 4.25 COL 96 WIDGET-ID 86
     "Desconto Itens" VIEW-AS TEXT
          SIZE 14.57 BY .67 AT ROW 10.08 COL 22.72 WIDGET-ID 132
     "Valor Total NF" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 8.13 COL 83.14 WIDGET-ID 96
     rt-key AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     RECT-1 AT ROW 6.54 COL 1.72 WIDGET-ID 52
     RECT-3 AT ROW 6.54 COL 21.72 WIDGET-ID 56
     RECT-4 AT ROW 6.54 COL 41.72 WIDGET-ID 60
     RECT-5 AT ROW 6.54 COL 61.72 WIDGET-ID 64
     RECT-6 AT ROW 6.54 COL 82.29 WIDGET-ID 68
     RECT-7 AT ROW 4.54 COL 1 WIDGET-ID 72
     RECT-8 AT ROW 4.54 COL 70.14 WIDGET-ID 76
     RECT-9 AT ROW 4.54 COL 83 WIDGET-ID 80
     RECT-10 AT ROW 4.54 COL 95.57 WIDGET-ID 84
     RECT-11 AT ROW 8.46 COL 1.72 WIDGET-ID 88
     RECT-12 AT ROW 8.46 COL 21.72 WIDGET-ID 90
     RECT-13 AT ROW 8.46 COL 41.72 WIDGET-ID 92
     RECT-14 AT ROW 8.46 COL 82.29 WIDGET-ID 94
     RECT-15 AT ROW 8.46 COL 61.86 WIDGET-ID 106
     RECT-16 AT ROW 10.33 COL 1.72 WIDGET-ID 120
     RECT-17 AT ROW 10.33 COL 21.72 WIDGET-ID 122
     RECT-18 AT ROW 10.33 COL 41.72 WIDGET-ID 124
     RECT-19 AT ROW 10.33 COL 61.72 WIDGET-ID 126
     RECT-20 AT ROW 10.33 COL 82.29 WIDGET-ID 128
     RECT-21 AT ROW 4.54 COL 108.57 WIDGET-ID 142
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: emsesp.int-ds-docto-xml
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
         HEIGHT             = 11.29
         WIDTH              = 143.14.
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

ASSIGN 
       c-Mensagem:READ-ONLY IN FRAME f-main        = TRUE.

/* SETTINGS FOR FILL-IN c-Sitre IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-Situacao IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-tipo-nota IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cComprador IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cEstabelec IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cFornecedor IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatureza IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-docto-xml.cod-emitente IN FRAME f-main
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN int-ds-docto-xml.cod-estab IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN cUF IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN data-emissao IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN data-entrega IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-docto-xml.dEmi IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN dt-movto IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-sit-re IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-situacao IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-docto-xml.nat-operacao IN FRAME f-main
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN int-ds-docto-xml.nNF IN FRAME f-main
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN int-ds-docto-xml.num-pedido IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-docto-xml.serie IN FRAME f-main
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN int-ds-docto-xml.valor-frete IN FRAME f-main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN int-ds-docto-xml.vbc IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN vl-desconto-itens IN FRAME f-main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-main
/* Query rebuild information for FRAME f-main
     _Query            is NOT OPENED
*/  /* FRAME f-main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME int-ds-docto-xml.chnfe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-docto-xml.chnfe V-table-Win
ON LEAVE OF int-ds-docto-xml.chnfe IN FRAME f-main /* Chave NFE */
DO:
    if int-ds-docto-xml.chnfe:SCREEN-VALUE in frame f-Main <> "" then do:
        if trim(int-ds-docto-xml.serie:screen-value in frame f-Main) = "" then do:
    
            assign int-ds-docto-xml.serie:screen-value in frame f-Main = trim(string(int(substring(trim(int-ds-docto-xml.chnfe:SCREEN-VALUE in frame f-Main),23,3)),">>9")).
    
        end.
        if trim(int-ds-docto-xml.nNF:screen-value in frame f-Main) = "" then do:
    
            assign int-ds-docto-xml.nNF:screen-value in frame f-Main = trim(string(int(substring(trim(int-ds-docto-xml.chnfe:SCREEN-VALUE in frame f-Main),26,9)),">>9999999")).
    
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-docto-xml.cod-emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-docto-xml.cod-emitente V-table-Win
ON LEAVE OF int-ds-docto-xml.cod-emitente IN FRAME f-main /* Fornecedor */
DO:
    assign int-ds-docto-xml.cod-emitente:bgcolor in frame f-Main = ?.
    for first emitente fields (nome-emit estado)
        no-lock where 
        emitente.cod-emitente = input frame f-Main int-ds-docto-xml.cod-emitente:
        assign  cFornecedor:screen-value in frame f-Main = emitente.nome-emit
                cUF:screen-value in frame f-Main = emitente.estado.
    end.
    if not avail emitente then do:
        assign int-ds-docto-xml.cod-emitente:bgcolor in frame f-Main = 14.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-docto-xml.cod-estab
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-docto-xml.cod-estab V-table-Win
ON LEAVE OF int-ds-docto-xml.cod-estab IN FRAME f-main /* Filial */
DO:
    assign int-ds-docto-xml.cod-estab:bgcolor in frame f-Main = ?.
    for first estabelec fields (nome cod-emitente)
        no-lock where 
        estabelec.cod-estabel = input frame f-Main int-ds-docto-xml.cod-estab:
        for first emitente fields (nome-abrev) no-lock where 
            emitente.cod-emitente = estabelec.cod-emitente:
            assign  cEstabelec:screen-value in frame f-Main = emitente.nome-abrev + "-" + estabelec.nome.
        end.
    end.  
    if not avail estabelec then do:
        assign int-ds-docto-xml.cod-estab:bgcolor in frame f-Main = 14.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-sit-re
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-sit-re V-table-Win
ON LEAVE OF i-sit-re IN FRAME f-main /* Fase */
DO:
    /*  
    Situaá∆o 0 (zero): N∆o deve ser gerado integraá∆o do Totvs para o sistema PRS. Adequaá∆o no processo Totvs.
    Situaá∆o 10 (um): Deve ser gerado integraá∆o do Totvs para o sistema PRS e liberado conferància no WMS. Adequaá∆o no processo Totvs e Tutorial.
    Situaá∆o 20 (dois): Deve ser gerado integraá∆o do PRS para o sistema Totvs indicando que a NF foi conferida pelo WMS.
    Situaá∆o 25 (dois): Deve ser gerado integraá∆o do PRS para o sistema Totvs indicando que a NF foi conferida pelo WMS.
    Situaá∆o 30 (tràs): Deve ser gerado integraá∆o do Totvs para o sistema PRS e liberando a movimentaá∆o de estoque no PRS. Adequaá∆o no processo Totvs e Tutorial.
    Situaá∆o 40 (quatro): Deve ser gerado integraá∆o do PRS para o sistema Totvs indicando que a NF foi movimentada no sistema PRS.
    Situaá∆o 50 (cinco): Deve ser gerado integraá∆o do Totvs para o sistema PRS indicando que todo o processo deve ser desfeito (cancelamento da movimentaá∆o). Adequaá∆o no processo Totvs e Tutorial.
    Situaá∆o 60 (seis): Deve ser gerado integraá∆o do PRS para o sistema Totvs indicando que a NF foi cancelada e que pode retornar a situaá∆o 0 (zero) para refazer todo o procedimento.
    */
    assign c-SitRe:screen-value in frame F-Main = "".
    assign c-SitRe:bgcolor in frame F-Main = ?.
    case input FRAME f-Main i-sit-re:
        when 0 then assign c-SitRe:screen-value in frame F-Main = "Pendente Liberaá∆o p/ WMS".
        when 3 then assign c-SitRe:screen-value in frame F-Main = "Recebimento Antigo INT002".
        when 10 then assign c-SitRe:screen-value in frame F-Main = "Liberada p/ WMS".
        when 20 then assign c-SitRe:screen-value in frame F-Main = "Integrada no WMS".
        when 25 then do:
            assign c-SitRe:screen-value in frame F-Main = "Conferida no WMS".
            assign c-SitRe:bgcolor in frame F-Main = 9.
        end.
        when 26 then do:
            assign c-SitRe:screen-value in frame F-Main = "Conferida com divergància no WMS".
            assign c-SitRe:bgcolor in frame F-Main = 14.
        end.
        when 30 then assign c-SitRe:screen-value in frame F-Main = "Movimentaá∆o liberada p/o PRS".
        when 40 then do:
            assign c-SitRe:screen-value in frame F-Main = "Liberada p/ RE1001".
            assign c-SitRe:bgcolor in frame F-Main = 10.
        end.
        when 50 then assign c-SitRe:screen-value in frame F-Main = "Movto em cancelamento".
        when 60 then assign c-SitRe:screen-value in frame F-Main = "Movto Cancelado".
    end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-situacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-situacao V-table-Win
ON LEAVE OF i-situacao IN FRAME f-main /* Situaá∆o */
DO:
  
    case input frame f-Main i-situacao:
        when 1 then assign c-Situacao:screen-value in frame F-Main = "Pendente".
        when 2 then assign c-Situacao:screen-value in frame F-Main = "Movimentada".
        when 3 then assign c-Situacao:screen-value in frame F-Main = "Integrada RE".
        when 5 then assign c-Situacao:screen-value in frame F-Main = "Bloqueada".
        when 7 then assign c-Situacao:screen-value in frame F-Main = "Liberada".
        when 9 then assign c-Situacao:screen-value in frame F-Main = "Recusada".
    end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-docto-xml.nat-operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-docto-xml.nat-operacao V-table-Win
ON LEAVE OF int-ds-docto-xml.nat-operacao IN FRAME f-main /* Nat Oper. */
DO:
    assign int-ds-docto-xml.nat-operacao:bgcolor in frame f-Main = ?.
    for first natur-oper 
        no-lock where 
        natur-oper.nat-operacao = input frame f-Main int-ds-docto-xml.nat-operacao:
        assign  cNatureza:screen-value in frame f-Main = natur-oper.denominacao.
    end.  
    if not avail natur-oper then do:
        assign int-ds-docto-xml.nat-operacao:bgcolor in frame f-Main = 14.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-docto-xml.num-pedido
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-docto-xml.num-pedido V-table-Win
ON LEAVE OF int-ds-docto-xml.num-pedido IN FRAME f-main /* Pedido */
DO:
    RUN pi-verifica-pedido.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */
    assign c-aux = "".
    for first grp_usuar no-lock where grp_usuar.cod_grp_usuar = "X23":
        assign c-aux = "X23 - " + trim(grp_usuar.des_grp_usuar).
    end.


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
  {src/adm/template/row-list.i "int-ds-docto-xml"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int-ds-docto-xml"}

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
    /* Dispatch standard ADM method.  */

    /*
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .

    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.
    */



    /*:T Todos os assignÔs n∆o feitos pelo assign-record devem ser feitos aqui */  
    /* Code placed here will execute AFTER standard behavior.    */
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record V-table-Win 
PROCEDURE local-delete-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
  /*
  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'delete-record':U ).

  /* Code placed here will execute AFTER standard behavior.    */
  */
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
    if adm-new-record = yes then do:
        enable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
        assign c-mensagem:screen-value in FRAME {&FRAME-NAME} = "".
    end.
    &endif
    assign int-ds-docto-xml.valor-cofins :sensitive in FRAME {&FRAME-NAME} = no
           int-ds-docto-xml.valor-pis    :sensitive in FRAME {&FRAME-NAME} = no
           int-ds-docto-xml.num-pedido   :sensitive in FRAME {&FRAME-NAME} = no.

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
  if avail int-ds-docto-xml then do:
      
      RUN pi-busca-docto-wms.

      assign i-sit-re:screen-value in frame f-Main = string(i-sit-re).
      assign i-situacao:screen-value in frame f-Main = string(int-ds-docto-xml.situacao).
      assign c-tipo-nota:screen-value in frame {&frame-name} = {ininc/i01in089.i 04 int-ds-docto-xml.tipo-nota}.

      apply "leave":u to int-ds-docto-xml.cod-emitente in frame f-main.
      apply "leave":u to int-ds-docto-xml.cod-estab in frame f-main.
      apply "leave":u to int-ds-docto-xml.nat-operacao in frame f-main.
      apply "leave":u to int-ds-docto-xml.num-pedido in frame f-main.
      apply "leave":u to i-situacao in frame f-main.
      apply "leave":u to i-sit-re in frame f-main.

      RUN pi-avaliar-erros.
                           
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-aprovar-compras V-table-Win 
PROCEDURE pi-aprovar-compras :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    if avail int-ds-docto-xml then do:
        RUN pi-verifica-situacao.
        if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.


        if can-find (first usuar_grp_usuar no-lock where 
                     usuar_grp_usuar.cod_usuario = c-seg-usuario and
                     usuar_grp_usuar.cod_grp_usuar = "X23" or
                     usuar_grp_usuar.cod_grp_usuar = "ZZZ") then do:
            if int-ds-docto-xml.situacao = 5 then do transaction:

                run utp/ut-msgs.p(input "show",
                                  input 701,
                                  input ("aprovaá∆o de compras para a nota fiscal?")).

                if return-value = "yes" then do:
                    RUN pi-libera-nf-compras.
                end. /* if return-value */
            end.
            else do:
                if int-ds-docto-xml.situacao = 7 then do:
                    run utp/ut-msgs.p(input "show",
                                      input 17006,
                                      input ("Situaá∆o inv†lida!" + "~~" + "A nota fiscal j† possui aprovaá∆o para as diferenáas contra o pedido. Tente reavaliar erros.")).
                    return "ADM-ERROR".
                end.
                else do:
                    run utp/ut-msgs.p(input "show",
                                      input 17006,
                                      input ("Situaá∆o inv†lida!" + "~~" + "A nota fiscal n∆o possui diferenáas contra o pedido para aprovaá∆o. Tente reavaliar erros.")).
                    return "ADM-ERROR".
                end.
            end.    
        end.
        else do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Usu†rio inv†lido!" + "~~" + "Aprovaá‰es de compras permitidas somente a usu†rios dos grupos: " + c-aux)).
            return "ADM-ERROR".
        end.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-avaliar-erros V-table-Win 
PROCEDURE pi-avaliar-erros :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  notes:       
------------------------------------------------------------------------------*/

    if avail int-ds-docto-xml then do:
        RUN pi-busca-docto-wms.

        if (i-sit-re >= 25 /* conferida wms */ and
            i-sit-re <> 50 /* em cancelamento wms */ and
            i-sit-re <> 60 /* cancelada wms */ and
            i-sit-re <> 40 /* movimentada prs */)
        then do:
            return.
        end.
    end.

    assign c-mensagem:screen-value in frame f-Main = "".
    assign c-mensagem:bgcolor in frame f-main = ?.

    RUN pi-elimina-doc-erro.

    RUN pi-calcula-totais.

    if  tot-base-icms-it        = fnTrataNuloDec(int-ds-docto-xml.vbc) 
        then int-ds-docto-xml.vbc:bgcolor in frame f-Main = ?. else int-ds-docto-xml.vbc:bgcolor in frame f-Main = 14.
    if  tot-base-icms-st-it     = int-ds-docto-xml.vbc-cst
        then int-ds-docto-xml.vbc-cst:bgcolor in frame f-Main = ?. else int-ds-docto-xml.vbc-cst:bgcolor in frame f-Main = 14.
    if  tot-cofins-it           = fnTrataNuloDec(int-ds-docto-xml.valor-cofins)
        then int-ds-docto-xml.valor-cofins:bgcolor in frame f-Main = ?. else int-ds-docto-xml.valor-cofins:bgcolor in frame f-Main = 14.
    if  tot-desconto-it         = fnTrataNuloDec(int-ds-docto-xml.tot-desconto)
        then int-ds-docto-xml.tot-desconto:bgcolor in frame f-Main = ?. else int-ds-docto-xml.tot-desconto:bgcolor in frame f-Main = 14.
    if  tot-icms-it             = fnTrataNuloDec(int-ds-docto-xml.valor-icms)
        then int-ds-docto-xml.valor-icms:bgcolor in frame f-Main = ?. else int-ds-docto-xml.valor-icms:bgcolor in frame f-Main = 14.
    if  tot-icms-st-it          = fnTrataNuloDec(int-ds-docto-xml.valor-st)
        then int-ds-docto-xml.valor-st:bgcolor in frame f-Main = ?. else int-ds-docto-xml.valor-st:bgcolor in frame f-Main = 14.
    if  tot-ipi-it              = fnTrataNuloDec(int-ds-docto-xml.valor-ipi)
        then int-ds-docto-xml.valor-ipi:bgcolor in frame f-Main = ?. else int-ds-docto-xml.valor-ipi:bgcolor in frame f-Main = 14.
    if  tot-nf-it               = fnTrataNuloDec(int-ds-docto-xml.vNF)
        then int-ds-docto-xml.vNF:bgcolor in frame f-Main = ?. else int-ds-docto-xml.vNF:bgcolor in frame f-Main = 14.
    if  tot-tot-pis-it          = fnTrataNuloDec(int-ds-docto-xml.valor-pis)
        then int-ds-docto-xml.valor-pis:bgcolor in frame f-Main = ?. else int-ds-docto-xml.valor-pis:bgcolor in frame f-Main = 14.
    if  tot-valor-it            = fnTrataNuloDec(int-ds-docto-xml.valor-mercad)
        then int-ds-docto-xml.valor-mercad:bgcolor in frame f-Main = ?. else int-ds-docto-xml.valor-mercad:bgcolor in frame f-Main = 14.

    if  tot-base-icms-it        <> fnTrataNuloDec(int-ds-docto-xml.vbc          ) or
        tot-base-icms-st-it     <> fnTrataNuloDec(int-ds-docto-xml.vbc-cst      ) or
        tot-cofins-it           <> fnTrataNuloDec(int-ds-docto-xml.valor-cofins ) or
        tot-desconto-it         <> fnTrataNuloDec(int-ds-docto-xml.tot-desconto ) or
        tot-icms-it             <> fnTrataNuloDec(int-ds-docto-xml.valor-icms   ) or
        tot-icms-st-it          <> fnTrataNuloDec(int-ds-docto-xml.valor-st     ) or
        tot-ipi-it              <> fnTrataNuloDec(int-ds-docto-xml.valor-ipi    ) or
        tot-nf-it               <> fnTrataNuloDec(int-ds-docto-xml.vNF          ) or
        tot-tot-pis-it          <> fnTrataNuloDec(int-ds-docto-xml.valor-pis    ) or
        tot-valor-it            <> fnTrataNuloDec(int-ds-docto-xml.valor-mercad ) then do:
        run pi-gera-erro(INPUT 23,
                         INPUT "Totais dos itens n∆o conferem com a nota").   
    end.
    assign vl-desconto-itens:screen-value in frame f-main = string(tot-desconto-it).

    for first serie no-lock where
               serie.serie = int-ds-docto-xml.serie: end.
    if not avail serie then do:
        run pi-gera-erro(INPUT 1,    
                         INPUT "SÇrie N∆o cadastrada").   
    end.

    /*
    for first natur-oper no-lock where
              natur-oper.nat-operacao = int-ds-docto-xml.nat-operacao
        query-tuning(no-lookahead) : end.

    if not avail natur-oper 
    then do:
       run pi-gera-erro(INPUT 9,    
                        INPUT "Natureza de Operaá∆o nota" + string(int-ds-docto-xml.nat-operacao) + " n∆o cadastrada!"). 
    end.
    */

    for first emitente no-lock where
              emitente.cgc = int-ds-docto-xml.CNPJ query-tuning(no-lookahead): end.
    if not avail emitente then do:
        run pi-gera-erro(INPUT 2,    
                         INPUT "Fornecedor " + int-ds-docto-xml.xNome + ".N∆o cadastrado com o CNPJ " + STRING(int-ds-docto-xml.CNPJ)).       
    end.

    for first estabelec no-lock where
               estabelec.cod-estabel = int-ds-docto-xml.cod-estab. end.
    if not avail estabelec then do:
       run pi-gera-erro(INPUT 3,    
                        INPUT "Estabelecimento n∆o cadastrado com o CNPJ " + STRING(int-ds-docto-xml.CNPJ-dest)).
    end. 
    if avail estabelec and estabelec.cod-estabel <> "973" then do:
       run pi-gera-erro(INPUT 3,    
                        INPUT "Estabelecimento n∆o pode ter recebimento pelo INT512!").
    end. 
    
    if int-ds-docto-xml.tipo-docto   = 4 AND 
       int-ds-docto-xml.tot-desconto = 0  /* notas Pepsico */  
    then do:
       run pi-gera-erro(INPUT 11,    
                        INPUT "N∆o foi informado o desconto.").
    end.
    for first natur-oper no-lock where natur-oper.nat-operacao = int-ds-docto-xml.nat-operacao:
        if not natur-oper.denominacao matches "*transf*" and natur-oper.emite-duplic then do:
            for first int-ds-docto-xml-dup no-lock of int-ds-docto-xml: end.
            if not avail int-ds-docto-xml-dup then do:
                assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main
                                                               + "N∆o encontradas duplicatas para o documento!" + chr(32).
            end.
        end.
    end.

    if  int-ds-docto-xml.valor-guia-st <> 0 and
        int-ds-docto-xml.valor-guia-st <> ? and
        int-ds-docto-xml.valor-st <> int-ds-docto-xml.valor-guia-st 
    then do:
        run pi-gera-erro(INPUT 19,    
                         INPUT "Valor Guia ST divergente do ICMS ST : " + 
                               " Guia: " + string(int-ds-docto-xml.valor-guia-st) + 
                               " ICMS ST: " + string(int-ds-docto-xml.valor-st)).
    end.

    run pi-verifica-duplicatas.

    RUN pi-verifica-pedido.

    for each int-ds-doc-erro no-lock where
      int-ds-doc-erro.serie-docto  = int-ds-docto-xml.serie AND
      int-ds-doc-erro.cod-emitente = int-ds-docto-xml.cod-emitente AND
      int-ds-doc-erro.CNPJ         = int-ds-docto-xml.CNPJ AND
      int-ds-doc-erro.nro-docto    = int-ds-docto-xml.nNF AND
      int-ds-doc-erro.tipo-nota    = int-ds-docto-xml.tipo-nota:
        if c-mensagem:screen-value in frame f-main = "" then
            assign c-mensagem:screen-value in frame f-main = trim(int-ds-doc-erro.descricao).
        else 
            assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main + " / " 
                                                           + trim(int-ds-doc-erro.descricao).

    end.
    if c-mensagem:screen-value in frame f-Main <> "" then
         assign c-mensagem:bgcolor in frame f-main = 14.


end PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-busca-docto-wms V-table-Win 
PROCEDURE pi-busca-docto-wms :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define buffer b-int-ds-docto-wms for int-ds-docto-wms.

      i-sit-re = 0.
      for first int-ds-docto-wms fields (situacao datamovimentacao_d) no-lock where 
          int-ds-docto-wms.doc_numero_n = int(int-ds-docto-xml.nNF) and
          int-ds-docto-wms.doc_serie_s  = int-ds-docto-xml.serie and
          int-ds-docto-wms.cnpj_cpf     = int-ds-docto-xml.CNPJ:
          assign i-sit-re = int-ds-docto-wms.situacao.
      end.

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

   def var c-item-do-forn as character no-undo.
   def var c-un-forn as char no-undo.
   def var de-fator as decimal no-undo.

   tot-base-icms-it        = 0.
   tot-base-icms-st-it     = 0.
   tot-cofins-it           = 0.
   tot-desconto-it         = 0.
   tot-icms-it             = 0. 
   tot-icms-st-it          = 0. 
   tot-ipi-it              = 0. 
   tot-nf-it               = 0. 
   tot-tot-pis-it          = 0. 
   tot-valor-it            = 0.
   tot-icms-des            = 0.

   /*  calcular fator de convers∆o */
   run inbo/boin176.p persistent set h-boin176. 

   for each int-ds-it-docto-xml exclusive-lock where
       int-ds-it-docto-xml.tipo-nota  = int-ds-docto-xml.tipo-nota and 
       int-ds-it-docto-xml.CNPJ       = int-ds-docto-xml.CNPJ      and 
       int-ds-it-docto-xml.nNF        = int-ds-docto-xml.nNF       and 
       int-ds-it-docto-xml.serie      = int-ds-docto-xml.serie:

       if int-ds-it-docto-xml.tipo-nota <> 3 /* transferencia */ and
          not can-find (first estabelec no-lock where estabelec.cod-emitente = int-ds-it-docto-xml.cod-emitente) then do:

           assign  c-item-do-forn = int-ds-it-docto-xml.item-do-forn
                   c-un-forn = "".
           for first item-fornec no-lock where
                     item-fornec.cod-emitente = int-ds-it-docto-xml.cod-emitente and
                     item-fornec.item-do-forn = c-item-do-forn and 
                     item-fornec.ativo = yes
               query-tuning(no-lookahead): 
               assign c-un-forn = item-fornec.unid-med-for.
           end.
           if not avail item-fornec then do:
               c-item-do-forn = trim(c-item-do-forn).
               for first item-fornec no-lock where
                         item-fornec.cod-emitente = int-ds-it-docto-xml.cod-emitente and
                         item-fornec.item-do-forn = c-item-do-forn and 
                         item-fornec.ativo = yes
                   query-tuning(no-lookahead): 
                   assign c-un-forn = item-fornec.unid-med-for.
               end.

               for first item-fornec-umd where
                         item-fornec-umd.cod-emitente = int-ds-it-docto-xml.cod-emitente and
                         item-fornec-umd.cod-livre-1  = c-item-do-forn and  
                         item-fornec-umd.log-ativo no-lock: 
                   assign c-un-forn = item-fornec-umd.unid-med-for.
               end.
               if avail item-fornec-umd 
               then do:
                  for first item-fornec no-lock where 
                            item-fornec.cod-emitente = int-ds-it-docto-xml.cod-emitente and
                            item-fornec.it-codigo    = item-fornec-umd.it-codigo and
                            item-fornec.ativo = YES query-tuning(no-lookahead): end.

               end.
               if not avail item-fornec then do:
                  run pi-gera-erro(INPUT 5,
                                   INPUT "Relacionamento item x fornecedor n∆o cadastrado. Item: " + 
                                         string(int-ds-it-docto-xml.item-do-forn) + 
                                         " Fornecedor: " + STRING(int-ds-docto-xml.cod-emitente)). 
               end.
           end. /* else */
           if avail item-fornec then do:
               if int-ds-it-docto-xml.it-codigo = "" then
                   assign int-ds-it-docto-xml.it-codigo = item-fornec.it-codigo.

               run retornaIndiceConversao in h-boin176 (input int-ds-it-docto-xml.it-codigo,
                                                        input int-ds-it-docto-xml.cod-emitente,
                                                        input /*item-fornec.unid-med-for*/ c-un-forn,
                                                        output de-fator). 

               if de-fator = 0 or de-fator = ? then assign de-fator = 1. 

               assign int-ds-it-docto-xml.qCom = round(int-ds-it-docto-xml.qCom-forn / de-fator,0).

               if int-ds-it-docto-xml.qCom <= 1 then 
                  assign int-ds-it-docto-xml.qCom = 1.

           end.
       end. /* tipo-nota <> 3 */

       if int-ds-it-docto-xml.qCom = ?  or
          int-ds-it-docto-xml.qCom = 0  or
          int-ds-it-docto-xml.uCom-forn = "" then do:
           run pi-gera-erro(INPUT 27,
                            INPUT "Quantidade Fornecedor/Unidade n∆o informados. Item: " + 
                                  string(int-ds-it-docto-xml.item-do-forn) + " Seq: " + string(int-ds-it-docto-xml.sequencia)). 
       end.
       for first item no-lock where  
           item.it-codigo = int-ds-it-docto-xml.it-codigo: 
           assign int-ds-it-docto-xml.uCom   = if item.un <> int-ds-it-docto-xml.uCom then item.un else int-ds-it-docto-xml.uCom
                  int-ds-it-docto-xml.xprod  = substring(ITEM.desc-item,1,60)
                  int-ds-it-docto-xml.tipo-contr = 4.

           if item.tipo-contr < 3 then 
               assign int-ds-it-docto-xml.tipo-contr = 1.
       end.
       if not avail item then do:
           run pi-gera-erro(INPUT 7,    
                            INPUT "Item N∆o cadastrado " + string(int-ds-it-docto-xml.it-codigo)). 
       end.

       if int-ds-docto-xml.situacao <> 7 /* j† aprovado compras */ and
          int-ds-docto-xml.situacao <> 3 then do:
           
           for first param-re no-lock where
               param-re.usuario = c-seg-usuario and
               not param-re.sem-pedido:
               for first pedido-compr no-lock where
                   pedido-compr.num-pedido = int-ds-it-docto-xml.num-pedido. end.
               if not avail pedido-compr and
                  c-seg-usuario <> "999909" then do:
                  run pi-gera-erro(INPUT 4,    
                                   INPUT "Pedido " + string(int-ds-it-docto-xml.num-pedido) + " N∆o cadastrado").   
               end.
           end.

           for first int-ds-param-re no-lock where 
               int-ds-param-re.cod-usuario = c-seg-usuario: end.
           if not avail int-ds-param-re then do:
               run pi-gera-erro(INPUT 25, 
                                INPUT "ParÉmetros do recebimento do usu†rio incompletos.").   
           end.
           else if i-sit-re < 10 then do:
               if int-ds-docto-xml.num-pedido <> int-ds-it-docto-xml.num-pedido and
                  int-ds-docto-xml.num-pedido <> ? and
                  int-ds-docto-xml.num-pedido <> 0
               then do:
                   assign int-ds-it-docto-xml.num-pedido = int-ds-docto-xml.num-pedido.
               end.
               for first ordem-compra no-lock where 
                   ordem-compra.numero-ordem = int-ds-it-docto-xml.numero-ordem and
                   ordem-compra.it-codigo  = int-ds-it-docto-xml.it-codigo: end.
               if not avail ordem-compra then do:
                   for first ordem-compra no-lock where 
                       ordem-compra.num-pedido = int-ds-it-docto-xml.num-pedido and
                       ordem-compra.it-codigo  = int-ds-it-docto-xml.it-codigo: 
                       /*assign int-ds-it-docto-xml.numero-ordem = ordem-compra.numero-ordem.*/
                   end.
               end.
               if not avail ordem-compra and int-ds-param-re.vld-pedido then do:
                   run pi-gera-erro(INPUT 14,    
                                    INPUT "Ordem de Compra " + string(int-ds-it-docto-xml.numero-ordem) + " N∆o cadastrada").   
               end.
               if int-ds-docto-xml.situacao <> 3 and
                  avail ordem-compra and
                  avail item-mat and (
                 (ordem-compra.qt-acum-nec + int-ds-it-docto-xml.qCom) > ordem-compra.qt-solic or
                  ordem-compra.qt-solic < int-ds-it-docto-xml.qCom or
                  ordem-compra.preco-unit * 1.02 < fnTrataNuloDec(int-ds-it-docto-xml.vUnCom) or
                  ordem-compra.preco-unit * 1.02 < (fnTrataNuloDec(int-ds-it-docto-xml.vProd) / int-ds-it-docto-xml.qCom) /*or
                  ordem-compra.valor-descto < fnTrataNuloDec(int-ds-it-docto-xml.vDesc)*/) 
                  then do:
    
                   run pi-gera-erro(INPUT 15,
                                    INPUT "Qtde/Valor divergente da ordem de compra: " + string(int-ds-it-docto-xml.numero-ordem) + 
                                          " Item: " + int-ds-it-docto-xml.it-codigo + 
                                          " Seq: " + string(int-ds-it-docto-xml.sequencia) + ". Nota fiscal deve ser corrigida ou aprovada pelo depto de compras.").
               end.
           end.
       end.
       
       assign 
           tot-base-icms-it        = tot-base-icms-it       + fnTrataNuloDec(int-ds-it-docto-xml.vbc-icms)
           tot-base-icms-st-it     = tot-base-icms-st-it    + fnTrataNuloDec(int-ds-it-docto-xml.vbcst   )     
           tot-cofins-it           = tot-cofins-it          + fnTrataNuloDec(int-ds-it-docto-xml.vcofins )
           tot-desconto-it         = tot-desconto-it        + fnTrataNuloDec(int-ds-it-docto-xml.vDesc   )
           tot-icms-it             = tot-icms-it            + fnTrataNuloDec(int-ds-it-docto-xml.vicms   )
           tot-icms-st-it          = tot-icms-st-it         + fnTrataNuloDec(int-ds-it-docto-xml.vicmsst )
           tot-ipi-it              = tot-ipi-it             + fnTrataNuloDec(int-ds-it-docto-xml.vipi    )
           tot-nf-it               = tot-nf-it              + fnTrataNuloDec(int-ds-it-docto-xml.vProd   )
                                                            + fnTrataNuloDec(int-ds-it-docto-xml.vipi    )
                                                            + fnTrataNuloDec(int-ds-it-docto-xml.vicmsst )
                                                            - fnTrataNuloDec(int-ds-it-docto-xml.vDesc   )
                                                            - fnTrataNuloDec(int-ds-it-docto-xml.vicmsdeson)
           tot-tot-pis-it          = tot-tot-pis-it         + fnTrataNuloDec(int-ds-it-docto-xml.vpis    )
           tot-valor-it            = tot-valor-it           + fnTrataNuloDec(int-ds-it-docto-xml.vProd   )
           tot-icms-des            = tot-icms-des           + fnTrataNuloDec(int-ds-it-docto-xml.vicmsdeson).
   end.
   tot-nf-it = tot-nf-it + fnTrataNuloDec(int-ds-docto-xml.valor-frete )
                         + fnTrataNuloDec(int-ds-docto-xml.valor-seguro)
                         + fnTrataNuloDec(int-ds-docto-xml.valor-outras).
   tot-nf-it = round(tot-nf-it,2).
   
   if valid-handle(h-boin176) then delete procedure h-boin176.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-elimina-doc-erro V-table-Win 
PROCEDURE pi-elimina-doc-erro :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    for each int-ds-doc-erro exclusive-lock where
        int-ds-doc-erro.serie-docto  = int-ds-docto-xml.serie        and 
        int-ds-doc-erro.cod-emitente = int-ds-docto-xml.cod-emitente and 
        int-ds-doc-erro.CNPJ         = int-ds-docto-xml.CNPJ         and     
        int-ds-doc-erro.nro-docto    = int-ds-docto-xml.NNF          and  
        int-ds-doc-erro.tipo-nota    = int-ds-docto-xml.tipo-nota
        query-tuning(no-lookahead):
        delete int-ds-doc-erro.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-erro V-table-Win 
PROCEDURE pi-gera-erro :
DEF INPUT PARAM p-cod-erro     LIKE int-ds-doc-erro.cod-erro.
    DEF INPUT PARAM p-desc-erro    LIKE int-ds-doc-erro.descricao.
      
     FOR  FIRST int-ds-doc-erro NO-LOCK WHERE
                int-ds-doc-erro.serie-docto  = int-ds-docto-xml.serie  AND 
                int-ds-doc-erro.cod-emitente = int-ds-docto-xml.cod-emitente AND
                int-ds-doc-erro.CNPJ         = int-ds-docto-xml.CNPJ  AND 
                int-ds-doc-erro.nro-docto    = int-ds-docto-xml.nNF   AND 
                int-ds-doc-erro.tipo-nota    = int-ds-docto-xml.tipo-nota  AND
                int-ds-doc-erro.descricao    = p-desc-erro 
         query-tuning(no-lookahead) : END.

     IF NOT AVAIL int-ds-doc-erro 
     THEN DO:
        CREATE int-ds-doc-erro.
        ASSIGN int-ds-doc-erro.serie-docto  = int-ds-docto-xml.serie       
               int-ds-doc-erro.cod-emitente = int-ds-docto-xml.cod-emitente
               int-ds-doc-erro.CNPJ         = int-ds-docto-xml.CNPJ 
               int-ds-doc-erro.nro-docto    = int-ds-docto-xml.nNF   
               int-ds-doc-erro.tipo-nota    = int-ds-docto-xml.tipo-nota  
               int-ds-doc-erro.tipo-erro    = "ErroXML"   
               int-ds-doc-erro.cod-erro     = p-cod-erro       
               int-ds-doc-erro.descricao    = IF p-desc-erro = ? THEN "" ELSE p-desc-erro.
    
        IF AVAIL int-ds-it-docto-xml THEN 
           ASSIGN int-ds-doc-erro.sequencia = int-ds-it-docto-xml.sequencia.
    
     END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-libera-nf-compras V-table-Win 
PROCEDURE pi-libera-nf-compras :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    def var de-qtde-entregue as decimal no-undo.
    def var de-qtde-original as decimal no-undo.

    def var de-valor-entregue as decimal no-undo.
    def var de-valor-original as decimal no-undo.
    define buffer b-int-ds-it-docto-xml for int-ds-it-docto-xml.


    if int-ds-docto-xml.situacao <> 3 and
       int-ds-docto-xml.situacao <> 9 and
       int-ds-docto-xml.cod-emitente <> ? and  
       int-ds-docto-xml.cod-emitente <> 0 then do:
        for first int-ds-docto-xml-compras exclusive of int-ds-docto-xml: end.
        if not avail int-ds-docto-xml-compras then do:
            create  int-ds-docto-xml-compras.
            assign  int-ds-docto-xml-compras.serie          = int-ds-docto-xml.serie
                    int-ds-docto-xml-compras.nNF            = int-ds-docto-xml.nNF
                    int-ds-docto-xml-compras.cod-emitente   = int-ds-docto-xml.cod-emitente
                    int-ds-docto-xml-compras.tipo-nota      = int-ds-docto-xml.tipo-nota.
        end.
        assign  int-ds-docto-xml-compras.data-aprovacao = today
                int-ds-docto-xml-compras.hora-aprovacao = time
                int-ds-docto-xml-compras.usuario-aprovacao = c-seg-usuario.
    
        /* armazenar valores */
        for each b-int-ds-it-docto-xml 
            fields (qCom qCom-Forn vProd numero-ordem)
            no-lock where
            b-int-ds-it-docto-xml.serie        = int-ds-docto-xml.serie and
            b-int-ds-it-docto-xml.nNF          = int-ds-docto-xml.nNF and
            b-int-ds-it-docto-xml.cod-emitente = int-ds-docto-xml.cod-emitente and
            b-int-ds-it-docto-xml.tipo-nota    = int-ds-docto-xml.tipo-nota:
    
            assign de-qtde-entregue = de-qtde-entregue + fnTrataNuloDec(b-int-ds-it-docto-xml.qCom).
            assign de-valor-entregue = de-valor-entregue + fnTrataNuloDec(b-int-ds-it-docto-xml.vProd / b-int-ds-it-docto-xml.qCom-forn).
    
            for first ordem-compra no-lock where 
                ordem-compra.numero-ordem = b-int-ds-it-docto-xml.numero-ordem:
                
                assign de-valor-original = de-valor-original + ordem-compra.pre-unit-for.
                assign de-qtde-original = de-qtde-original + ordem-compra.qt-solic.
    
            end.
        end.
    
        assign  int-ds-docto-xml-compras.valor-original = de-valor-original
                int-ds-docto-xml-compras.qtde-original  = de-qtde-original.
        assign  int-ds-docto-xml-compras.valor-etregue = de-valor-entregue
                int-ds-docto-xml-compras.qtde-entregue  = de-qtde-entregue.
        for first b-int-ds-docto-xml exclusive-lock where 
            rowid (b-int-ds-docto-xml) = rowid (int-ds-docto-xml): 
            assign b-int-ds-docto-xml.situacao = 7.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-valida-usuario-compras V-table-Win 
PROCEDURE pi-valida-usuario-compras :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    if can-find (first usuar_grp_usuar no-lock where 
                 usuar_grp_usuar.cod_usuario = c-seg-usuario and
                 usuar_grp_usuar.cod_grp_usuar = "ZZZ") then do:
        return "OK".
    end.
    /* compras n∆o deve movimentar o documento, apenas aprova */
    if can-find (first usuar_grp_usuar no-lock where 
                 usuar_grp_usuar.cod_usuario = c-seg-usuario and
                 usuar_grp_usuar.cod_grp_usuar = "X23" and
                 c-seg-usuario <> "999909") then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Usu†rio inv†lido!" + "~~" + "Usu†rios de compras permitidas somente podem aprovar o documento. Alteraá‰es n∆o ser∆o permitidas.")).
        return "ADM-ERROR".
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-verifica-duplicatas V-table-Win 
PROCEDURE pi-verifica-duplicatas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE da-data            AS   DATE    EXTENT 12       NO-UNDO.
    DEFINE VARIABLE da-partida         AS   DATE                    NO-UNDO.
    DEFINE VARIABLE de-vl-docto        AS   DECIMAL                 NO-UNDO.
    DEFINE VARIABLE de-tot-dupli       AS   DECIMAL                 NO-UNDO.
    DEFINE VARIABLE de-tot-dupnf       AS   DECIMAL                 NO-UNDO.
    DEFINE VARIABLE i-ind              AS   integer                 NO-UNDO.
    DEFINE VARIABLE c-venctos          AS   char                    NO-UNDO.
    
    empty temp-table tt-dupli.

    if avail int-ds-docto-xml then do:

        for first natur-oper no-lock where 
            natur-oper.nat-operacao = int-ds-docto-xml.nat-operacao: end.
        if  not avail natur-oper or 
            not natur-oper.emite-duplic then return "OK":U.

        assign de-vl-docto = fnTrataNuloDec(int-ds-docto-xml.valor-mercad )
                           /*+ fnTrataNuloDec(int-ds-docto-xml.valor-st     )*/
                           + fnTrataNuloDec(int-ds-docto-xml.despesa-nota )
                           + fnTrataNuloDec(int-ds-docto-xml.valor-ipi    )
                           - fnTrataNuloDec(int-ds-docto-xml.tot-desconto ).

        for first pedido-compr fields (cod-cond-pag)
            no-lock where 
            pedido-compr.num-pedido = int-ds-docto-xml.num-pedido: end.
        for first cond-pagto no-lock where 
            cond-pagto.cod-cond-pag = pedido-compr.cod-cond-pag: end.
        /*if not avail cond-pagto then return.*/
        for first ordem-compra fields (tp-despesa)
            no-lock of pedido-compr where ordem-compra.tp-despesa <> 0: 
            for first emitente fields (tp-desp-padrao) no-lock where 
                emitente.cod-emitente = int-ds-docto-xml.cod-emitente: 

                assign da-data    = today
                       da-partida = int-ds-docto-xml.dEmi.

                {cdp/cd9020.i7 int-ds-docto-xml.cod-estab}


                do i-ind = 1 to cond-pagto.num-parcelas:

                    create tt-dupli.
                    assign tt-dupli.parcela    = i-ind
                           tt-dupli.dt-vencim  = da-data[i-ind]
                           tt-dupli.vl-apagar  = round(de-vl-docto * cond-pagto.per-pg-dup[i-ind] / 100,2). 

                    if i-ind = 1 then
                        assign tt-dupli.vl-apagar  = tt-dupli.vl-apagar + fnTrataNuloDec(int-ds-docto-xml.valor-st).

                    c-venctos = c-venctos + " - " + string(tt-dupli.dt-vencim,"99/99/9999").
                    de-tot-dupli = de-tot-dupli + truncate(tt-dupli.vl-apagar,2).

                end.
            end.
        end.
        if de-tot-dupli = 0 then de-tot-dupli = de-vl-docto.

        /*if can-find (first tt-dupli) then*/
        for each int-ds-docto-xml-dup no-lock of int-ds-docto-xml:
            de-tot-dupnf = de-tot-dupnf + fnTrataNuloDec(int-ds-docto-xml-dup.vDup).
            /* retirado por causa das duplicatas separadas de ST
            for first tt-dupli no-lock where 
                tt-dupli.dt-vencim = date(int(entry(2,int-ds-docto-xml-dup.dVenc,"/")),
                                          int(entry(1,int-ds-docto-xml-dup.dVenc,"/")),
                                          int(entry(3,int-ds-docto-xml-dup.dVenc,"/"))):
                if int-ds-docto-xml-dup.vDup <> tt-dupli.vl-apagar then do:
                    run pi-gera-erro(INPUT 20,    
                                     INPUT "Valor da duplicata vencto " + trim(int-ds-docto-xml-dup.dVenc) + 
                                           " divergente com a condiá∆o de pagto. Valor Dup: " + 
                                           trim(string(int-ds-docto-xml-dup.vDup)) + 
                                           " Valor Cond: " + trim(string(tt-dupli.vl-apagar)) ).
                    return.
                end.
            end.
            if not avail tt-dupli then do:
                run pi-gera-erro(INPUT 21,    
                                 INPUT "Vencimentos das duplicatas n∆o confere com condiá∆o de pagto " + c-venctos ).
                return.
            end.
            */
        end.
        if de-tot-dupli <> de-tot-dupnf and
           int-ds-docto-xml.vNF <> de-tot-dupnf then do:
            run pi-gera-erro(INPUT 22,
                             INPUT "Valor das duplicatas informadas difere do valor calculado pela condiá∆o de pagto do pedido: " + 
                                   " Valor Dupl: " + trim(string(de-tot-dupnf)) + 
                                   " Valor Cond: " + trim(string(de-tot-dupli)) ).
            return.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-verifica-pedido V-table-Win 
PROCEDURE pi-verifica-pedido :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    assign int-ds-docto-xml.num-pedido:bgcolor in frame f-Main = ?.
    assign c-mensagem:screen-value in frame f-main = "".
    
    if input frame f-main int-ds-docto-xml.num-pedido = 0 or 
       input frame f-main int-ds-docto-xml.num-pedido = ? then do:
        run pi-gera-erro(INPUT 24,
                         INPUT "Pedido n∆o informado!").  
        assign c-mensagem:screen-value in frame f-main = "Pedido deve ser informado!".
    end.
    for first pedido-compr no-lock where 
        pedido-compr.num-pedido = input frame f-main int-ds-docto-xml.num-pedido:
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
        for first param-re no-lock where param-re.usuario = c-seg-usuario: 
            if avail emitente and emitente.cod-emitente <> int-ds-docto-xml.cod-emitente:input-value in frame f-Main and not param-re.rec-out-for then do:
                assign int-ds-docto-xml.num-pedido:bgcolor in frame f-Main = 14.

                run pi-gera-erro(INPUT 22,    
                                 INPUT "Pedido n∆o Ç deste fornecedor!").  
                assign c-mensagem:screen-value in frame f-main = "Pedido n∆o Ç deste fornecedor!".
            end.
            else do:
                assign int-ds-docto-xml.num-pedido:bgcolor in frame f-Main = ?.
            end.
        end.
    end.

    if not avail pedido-compr and i-sit-re < 10 and
       int-ds-docto-xml.situacao <> 3 and int-ds-docto-xml.situacao <> 7 then do:
        assign int-ds-docto-xml.num-pedido:bgcolor in frame f-Main = 14.
        for first param-re no-lock where param-re.usuario = c-seg-usuario and
            not param-re.sem-pedido:
            run pi-gera-erro(INPUT 21,    
                             INPUT "Pedido n∆o encontrado!").  
            assign c-mensagem:screen-value in frame f-main = "Pedido n∆o encontrado!".
        end.
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-verifica-situacao V-table-Win 
PROCEDURE pi-verifica-situacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
        RUN pi-busca-docto-wms.

        
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-key V-table-Win  adm/support/_key-snd.p
PROCEDURE send-key :
/*------------------------------------------------------------------------------
  Purpose:     Sends a requested KEY value back to the calling
               SmartObject.
  Parameters:  <see adm/template/sndkytop.i>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/sndkytop.i}

  /* Return the key value associated with each key case.             */
  {src/adm/template/sndkycas.i "ep-codigo" "int-ds-docto-xml" "ep-codigo"}

  /* Close the CASE statement and end the procedure.                 */
  {src/adm/template/sndkyend.i}

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
  {src/adm/template/snd-list.i "int-ds-docto-xml"}

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

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnTrataNuloDec V-table-Win 
FUNCTION fnTrataNuloDec RETURNS decimal (p-valor as decimal):

    if p-valor = ? then return 0.
    else return p-valor.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

