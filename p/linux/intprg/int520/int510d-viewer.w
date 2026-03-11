&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
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
{include/i-prgvrs.i int510d-viewer 1.12.00.AVB}

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

DEFINE VARIABLE c-motivo-aceite AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-seq-log       AS INTEGER     NO-UNDO.

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

define variable h_int510d-browser-itens as handle.
define temp-table tt-int-ds-docto-xml-dup like int-ds-docto-xml-dup
    field dt-vencto as date
    field parcela as integer.

define buffer btt-int-ds-docto-xml-dup for tt-int-ds-docto-xml-dup.

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
int-ds-docto-xml.valor-icms-des int-ds-docto-xml.valor-guia-st ~
int-ds-docto-xml.base-guia-st int-ds-docto-xml.dt-guia-st ~
int-ds-docto-xml.perc-red-icms 
&Scoped-define ENABLED-TABLES int-ds-docto-xml
&Scoped-define FIRST-ENABLED-TABLE int-ds-docto-xml
&Scoped-Define ENABLED-OBJECTS rt-key RECT-1 RECT-3 RECT-4 RECT-5 RECT-6 ~
RECT-7 RECT-8 RECT-9 RECT-10 RECT-11 RECT-12 RECT-13 RECT-14 RECT-15 ~
RECT-16 RECT-17 RECT-18 RECT-19 RECT-20 RECT-21 RECT-22 RECT-23 c-Mensagem 
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
int-ds-docto-xml.valor-icms-des int-ds-docto-xml.valor-guia-st ~
int-ds-docto-xml.base-guia-st int-ds-docto-xml.dt-guia-st ~
int-ds-docto-xml.perc-red-icms 
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

DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 50 BY 1.67.

DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 14.43 BY 1.67.

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
          SIZE 14.29 BY .88
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
     int-ds-docto-xml.valor-guia-st AT ROW 12.75 COL 3 NO-LABEL WIDGET-ID 170
          VIEW-AS FILL-IN 
          SIZE 14 BY .88
     int-ds-docto-xml.base-guia-st AT ROW 12.75 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 194
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int-ds-docto-xml.dt-guia-st AT ROW 12.75 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 196
          VIEW-AS FILL-IN 
          SIZE 11.14 BY .88
     int-ds-docto-xml.perc-red-icms AT ROW 12.75 COL 51.43 COLON-ALIGNED NO-LABEL WIDGET-ID 198
          VIEW-AS FILL-IN 
          SIZE 8.14 BY .88
     "Emiss∆o" VIEW-AS TEXT
          SIZE 8 BY .42 AT ROW 4.29 COL 83.57 WIDGET-ID 82
     "Valor IPI" VIEW-AS TEXT
          SIZE 8.57 BY .67 AT ROW 8.13 COL 62.57 WIDGET-ID 102
     "Vencto ST" VIEW-AS TEXT
          SIZE 10 BY .67 AT ROW 12 COL 36 WIDGET-ID 182
     "Vl Seguro" VIEW-AS TEXT
          SIZE 9.57 BY .67 AT ROW 8.13 COL 22.57 WIDGET-ID 98
     "Desconto Itens" VIEW-AS TEXT
          SIZE 14.57 BY .67 AT ROW 10.08 COL 22.72 WIDGET-ID 132
     "Vl Despesas" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 8.13 COL 42.57 WIDGET-ID 100
     "Base C†lculo" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 6.25 COL 2.57 WIDGET-ID 50
     "Valor Produtos" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 6.25 COL 83.14 WIDGET-ID 70
     "Base Guia ST" VIEW-AS TEXT
          SIZE 13 BY .67 AT ROW 11.92 COL 18 WIDGET-ID 180
     "Vl Frete" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 8.13 COL 2.57 WIDGET-ID 104
     "Natureza de Operaá∆o" VIEW-AS TEXT
          SIZE 20.57 BY .58 AT ROW 4.21 COL 3 WIDGET-ID 74
     "Entrega" VIEW-AS TEXT
          SIZE 8 BY .42 AT ROW 4.25 COL 96 WIDGET-ID 86
     "Vl COFINS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 10.08 COL 62.57 WIDGET-ID 136
     "Valor Total NF" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 8.13 COL 83.14 WIDGET-ID 96
     "ICMS Desonerado" VIEW-AS TEXT
          SIZE 17 BY .67 AT ROW 10.08 COL 83.29 WIDGET-ID 130
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     "Valor ICMS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 6.25 COL 22.57 WIDGET-ID 58
     "Valor ICMS ST" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 6.25 COL 62.57 WIDGET-ID 66
     "Vlr Guia ST" VIEW-AS TEXT
          SIZE 10.29 BY .67 AT ROW 11.92 COL 2.72 WIDGET-ID 150
     "Pedido" VIEW-AS TEXT
          SIZE 7 BY .42 AT ROW 4.29 COL 70.57 WIDGET-ID 78
     "Vl PIS" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 10.08 COL 42.72 WIDGET-ID 134
     "% Red ICMS" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 12 COL 53 WIDGET-ID 186
     "Descontos" VIEW-AS TEXT
          SIZE 10.57 BY .67 AT ROW 10.08 COL 2.72 WIDGET-ID 138
     "Base ICMS ST" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 6.25 COL 42.57 WIDGET-ID 62
     "Comprador" VIEW-AS TEXT
          SIZE 10.86 BY .42 AT ROW 4.25 COL 109.57 WIDGET-ID 144
     rt-key AT ROW 1 COL 1
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
     RECT-22 AT ROW 12.17 COL 2 WIDGET-ID 148
     RECT-23 AT ROW 12.17 COL 52 WIDGET-ID 184
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
         HEIGHT             = 13
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
/* SETTINGS FOR FILL-IN int-ds-docto-xml.valor-guia-st IN FRAME f-main
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
    assign c-Situacao:bgcolor in frame F-Main = ?.
    case input frame f-Main i-situacao:
        when 1 then assign c-Situacao:screen-value in frame F-Main = "Pendente".
        when 2 then assign c-Situacao:screen-value in frame F-Main = "Movimentada".
        when 3 then assign c-Situacao:screen-value in frame F-Main = "Integrada RE".
        when 5 then do:
            assign c-Situacao:screen-value in frame F-Main = "Bloqueada".
            assign c-Situacao:bgcolor in frame F-Main = 14.
        end.
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
    /*RUN pi-verifica-pedido.*/
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


/*     RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .  */


    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.

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

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
/*   RUN dispatch IN THIS-PROCEDURE ( INPUT 'delete-record':U ).  */

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

    RUN pi-busca-docto-wms.


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
      apply "leave":U to int-ds-docto-xml.valor-guia-st in frame f-main.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-aceita-recebimento V-table-Win 
PROCEDURE pi-aceita-recebimento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    if avail int-ds-docto-xml then do:

        run utp/ut-msgs.p(input "show",
                          input 701,
                          input ("aceite do recebimento da nota fiscal")).

        if return-value = "yes" then
        do transaction:

            ASSIGN c-motivo-aceite = "".

            RUN intprg\int510d3.w (OUTPUT c-motivo-aceite).

            IF  c-motivo-aceite <> ""
            THEN DO:
                ASSIGN i-seq-log = 1.

                FOR LAST  int-ds-log-recusa-docto-xml NO-LOCK
                    WHERE int-ds-log-recusa-docto-xml.serie        = int-ds-docto-xml.serie
                      AND int-ds-log-recusa-docto-xml.nnf          = int-ds-docto-xml.nnf
                      AND int-ds-log-recusa-docto-xml.cod-emitente = int-ds-docto-xml.cod-emitente
                      AND int-ds-log-recusa-docto-xml.tipo-nota    = int-ds-docto-xml.tipo-nota:

                    ASSIGN i-seq-log = int-ds-log-recusa-docto-xml.sequencia + 1.
                END.

                CREATE int-ds-log-recusa-docto-xml.
                ASSIGN int-ds-log-recusa-docto-xml.serie           = int-ds-docto-xml.serie       
                       int-ds-log-recusa-docto-xml.nnf             = int-ds-docto-xml.nnf        
                       int-ds-log-recusa-docto-xml.cod-emitente    = int-ds-docto-xml.cod-emitente
                       int-ds-log-recusa-docto-xml.tipo-nota       = int-ds-docto-xml.tipo-nota
                       int-ds-log-recusa-docto-xml.sequencia       = i-seq-log
                       int-ds-log-recusa-docto-xml.log-recusa      = NO
                       int-ds-log-recusa-docto-xml.dt-ocorrencia   = TODAY
                       int-ds-log-recusa-docto-xml.hr-ocorrencia   = STRING(TIME,"hh:mm:ss")
                       int-ds-log-recusa-docto-xml.cod-usuario     = c-seg-usuario
                       int-ds-log-recusa-docto-xml.desc-ocorrencia = c-motivo-aceite.

                RELEASE int-ds-log-recusa-docto-xml.

                for first b-int-ds-docto-xml exclusive-lock where 
                    rowid (b-int-ds-docto-xml) = rowid (int-ds-docto-xml):
                    assign b-int-ds-docto-xml.situacao = 1.
                    assign i-situacao = b-int-ds-docto-xml.sit-re.
                    assign i-situacao:screen-value in frame f-Main = string(i-situacao).
                    apply "leave":U to i-situacao in frame f-Main.
                end.
            END.
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

          if i-sit-re = 3 then do:
              for first b-int-ds-docto-wms exclusive where 
                  rowid(b-int-ds-docto-wms) = rowid(int-ds-docto-wms):
                  assign  /*b-int-ds-docto-wms.situacao = 40*/
                          b-int-ds-docto-wms.datamovimentacao_d = if b-int-ds-docto-wms.datamovimentacao_d = ? 
                                                                  then int-ds-docto-xml.dt-trans 
                                                                  else b-int-ds-docto-wms.datamovimentacao_d.
              end.
          end.
          
          if i-sit-re = 40 then do:
              assign dt-movto = int-ds-docto-wms.datamovimentacao_d
                     dt-movto:screen-value in FRAME {&FRAME-NAME} = string(dt-movto).
          end.
          
          assign i-sit-re = int-ds-docto-wms.situacao.
      end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-historico V-table-Win 
PROCEDURE pi-historico :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    if avail int-ds-docto-xml 
    then
        RUN intprg\int510d4.w (INPUT ROWID(int-ds-docto-xml)).
    ELSE
        RUN intprg\int510d4.w (INPUT ?).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-recebe-handle V-table-Win 
PROCEDURE pi-recebe-handle :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define input parameter p_int510d-browser-itens as handle.
assign h_int510d-browser-itens = p_int510d-browser-itens.
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

