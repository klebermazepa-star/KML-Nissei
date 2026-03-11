&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           ORACLE
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
{include/i-prgvrs.i int510-viewer 1.12.00.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/viewerd.w

/* global variable definitions */

DEFINE NEW GLOBAL SHARED VARIABLE v-row-docto-xml-nire003 AS ROWID       NO-UNDO.

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
DEFINE VARIABLE tot-base_guia_st        AS DECIMAL INITIAL 0 NO-UNDO.
DEFINE VARIABLE tot-valor_guia_st       AS DECIMAL INITIAL 0 NO-UNDO.

DEFINE VARIABLE de-base-st-calc  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-valor_st-calc AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-perc-st-calc  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE c-tabela-pauta   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE de-tabela-pauta  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-per-sub-tri   AS DECIMAL     NO-UNDO.

DEFINE VARIABLE c-motivo-aceite AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-seq-log       AS INTEGER     NO-UNDO.
DEFINE VARIABLE c-msg           AS CHARACTER   NO-UNDO.
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

define buffer b-int_ds_docto_xml for int_ds_docto_xml.
define buffer b-int_ds_it_docto_xml for int_ds_it_docto_xml.

define variable h-boin176 as handle.

define variable h_int510-browser-itens as handle.
define temp-table tt-int_ds_docto_xml_dup like int_ds_docto_xml_dup
    field dt-vencto as date
    field parcela as integer.

define buffer btt-int_ds_docto_xml_dup for tt-int_ds_docto_xml_dup.
DEF BUFFER b-int_ds_docto_xml-guia-st  FOR int_ds_docto_xml.

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
&Scoped-define EXTERNAL-TABLES int_ds_docto_xml
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_docto_xml


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_docto_xml.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_docto_xml.chnfe int_ds_docto_xml.cfop ~
int_ds_docto_xml.cod_estab int_ds_docto_xml.dEmi ~
int_ds_docto_xml.num_pedido int_ds_docto_xml.nat_operacao ~
int_ds_docto_xml.vbc int_ds_docto_xml.valor_icms int_ds_docto_xml.vbc_cst ~
int_ds_docto_xml.valor_st int_ds_docto_xml.valor_mercad ~
int_ds_docto_xml.valor_frete int_ds_docto_xml.valor_seguro ~
int_ds_docto_xml.valor_outras int_ds_docto_xml.valor_ipi ~
int_ds_docto_xml.vNF int_ds_docto_xml.tot_desconto ~
int_ds_docto_xml.valor_pis int_ds_docto_xml.valor_cofins ~
int_ds_docto_xml.valor_icms_des int_ds_docto_xml.valor_guia_st ~
int_ds_docto_xml.base_guia_st int_ds_docto_xml.dt_guia_st ~
int_ds_docto_xml.perc_red_icms 
&Scoped-define ENABLED-TABLES int_ds_docto_xml
&Scoped-define FIRST-ENABLED-TABLE int_ds_docto_xml
&Scoped-Define ENABLED-OBJECTS rt-key RECT-1 RECT-3 RECT-4 RECT-5 RECT-6 ~
RECT-7 RECT-8 RECT-9 RECT-10 RECT-11 RECT-12 RECT-13 RECT-14 RECT-15 ~
RECT-16 RECT-17 RECT-18 RECT-19 RECT-20 RECT-21 RECT-22 RECT-23 rt-key-2 ~
c-Mensagem bt-gnre bt-totais bt-natureza bt-ordem 
&Scoped-Define DISPLAYED-FIELDS int_ds_docto_xml.chnfe ~
int_ds_docto_xml.cod_emitente int_ds_docto_xml.cfop ~
int_ds_docto_xml.cod_estab int_ds_docto_xml.nNF int_ds_docto_xml.serie ~
int_ds_docto_xml.dEmi int_ds_docto_xml.num_pedido ~
int_ds_docto_xml.nat_operacao int_ds_docto_xml.vbc ~
int_ds_docto_xml.valor_icms int_ds_docto_xml.vbc_cst ~
int_ds_docto_xml.valor_st int_ds_docto_xml.valor_mercad ~
int_ds_docto_xml.valor_frete int_ds_docto_xml.valor_seguro ~
int_ds_docto_xml.valor_outras int_ds_docto_xml.valor_ipi ~
int_ds_docto_xml.vNF int_ds_docto_xml.tot_desconto ~
int_ds_docto_xml.valor_pis int_ds_docto_xml.valor_cofins ~
int_ds_docto_xml.valor_icms_des int_ds_docto_xml.valor_guia_st ~
int_ds_docto_xml.base_guia_st int_ds_docto_xml.dt_guia_st ~
int_ds_docto_xml.perc_red_icms 
&Scoped-define DISPLAYED-TABLES int_ds_docto_xml
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_docto_xml
&Scoped-Define DISPLAYED-OBJECTS i-situacao c-Situacao i-sit_re c-Sitre ~
cFornecedor cUF c-tipo_nota dt-movto cEstabelec cNatureza data-emissao ~
data-entrega cComprador c-Mensagem vl-desconto-itens 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS int_ds_docto_xml.cod_emitente ~
int_ds_docto_xml.nNF int_ds_docto_xml.serie 
&Scoped-define ADM-MODIFY-FIELDS bt-despesas bt-red-icms 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
ep_codigo||y|custom.int_ds_docto_xml.ep_codigo
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

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnTrataNuloDec V-table-Win 
FUNCTION fnTrataNuloDec RETURNS decimal (p-valor as decimal) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-despesas 
     IMAGE-UP FILE "image/im-sav":U
     IMAGE-INSENSITIVE FILE "image/ii-sav":U
     LABEL "OK" 
     SIZE 4 BY 1 TOOLTIP "Rateia despesas nos itens"
     FONT 4.

DEFINE BUTTON bt-gnre 
     LABEL "GNRE" 
     SIZE 17 BY 1.75 TOOLTIP "Atualiza valores ST Itens".

DEFINE BUTTON bt-guia-st 
     IMAGE-UP FILE "image/im-sav":U
     IMAGE-INSENSITIVE FILE "image/ii-sav":U
     LABEL "OK" 
     SIZE 4 BY 1 TOOLTIP "Atualiza valores ST Itens"
     FONT 4.

DEFINE BUTTON bt-natureza 
     LABEL "Preenche Natureza/PIS/COFINS" 
     SIZE 25 BY 1.75.

DEFINE BUTTON bt-ordem 
     LABEL "Preenche Ordem Compra" 
     SIZE 19 BY 1.75.

DEFINE BUTTON bt-red-icms 
     IMAGE-UP FILE "image/im-sav":U
     IMAGE-INSENSITIVE FILE "image/ii-sav":U
     LABEL "OK" 
     SIZE 4 BY 1 TOOLTIP "Atualiza % de Reduá∆o ICMS Itens"
     FONT 4.

DEFINE BUTTON bt-totais 
     LABEL "Copiar Totais dos Itens" 
     SIZE 17 BY 1.75.

DEFINE VARIABLE c-Mensagem AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 42 BY 5.5 NO-UNDO.

DEFINE VARIABLE c-Sitre AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 31 BY .88 NO-UNDO.

DEFINE VARIABLE c-Situacao AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 13.86 BY .88 NO-UNDO.

DEFINE VARIABLE c-tipo_nota AS CHARACTER FORMAT "X(256)":U 
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

DEFINE VARIABLE i-sit_re AS INTEGER FORMAT ">9" INITIAL 1 
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
     SIZE 14 BY 1.67.

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

DEFINE RECTANGLE rt-key-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 142.86 BY 3.21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int_ds_docto_xml.chnfe AT ROW 1.21 COL 11.29 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 61.14 BY .88
     i-situacao AT ROW 1.21 COL 82.86 COLON-ALIGNED WIDGET-ID 162
     c-Situacao AT ROW 1.21 COL 86.14 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     i-sit_re AT ROW 1.21 COL 105.72 COLON-ALIGNED HELP
          "Situaá∆o Atualizaá∆o" WIDGET-ID 160
     c-Sitre AT ROW 1.21 COL 109 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     int_ds_docto_xml.cod_emitente AT ROW 2.13 COL 11.29 COLON-ALIGNED WIDGET-ID 4
          LABEL "Fornecedor":R10
          VIEW-AS FILL-IN 
          SIZE 10.29 BY .88
     cFornecedor AT ROW 2.13 COL 21.57 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     cUF AT ROW 2.13 COL 72.72 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     int_ds_docto_xml.cfop AT ROW 2.13 COL 82.86 COLON-ALIGNED WIDGET-ID 156
          VIEW-AS FILL-IN 
          SIZE 7.14 BY .88
     c-tipo_nota AT ROW 2.13 COL 90.29 COLON-ALIGNED NO-LABEL WIDGET-ID 178
     dt-movto AT ROW 2.13 COL 128.57 COLON-ALIGNED WIDGET-ID 176
     int_ds_docto_xml.cod_estab AT ROW 3.04 COL 11.29 COLON-ALIGNED WIDGET-ID 6
          LABEL "Filial"
          VIEW-AS FILL-IN 
          SIZE 4.72 BY .88
     cEstabelec AT ROW 3.04 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     int_ds_docto_xml.nNF AT ROW 3.04 COL 82.86 COLON-ALIGNED WIDGET-ID 8
          LABEL "Nota"
          VIEW-AS FILL-IN 
          SIZE 14.57 BY .88
     int_ds_docto_xml.serie AT ROW 3.04 COL 105.57 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 9.29 BY .88
     int_ds_docto_xml.dEmi AT ROW 3.04 COL 128.57 COLON-ALIGNED WIDGET-ID 108
          LABEL "Emiss∆o"
          VIEW-AS FILL-IN 
          SIZE 11.29 BY .88
     int_ds_docto_xml.num_pedido AT ROW 4.75 COL 68.57 COLON-ALIGNED NO-LABEL WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 11.57 BY .88
     int_ds_docto_xml.nat_operacao AT ROW 4.79 COL 2.57 NO-LABEL WIDGET-ID 20
          VIEW-AS FILL-IN 
          SIZE 10.29 BY .88
     cNatureza AT ROW 4.79 COL 11 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     data-emissao AT ROW 4.79 COL 81.57 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     data-entrega AT ROW 4.79 COL 94 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     cComprador AT ROW 4.79 COL 107.57 COLON-ALIGNED NO-LABEL WIDGET-ID 140
     c-Mensagem AT ROW 6.5 COL 102 NO-LABEL WIDGET-ID 168
     int_ds_docto_xml.vbc AT ROW 7.08 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 44
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int_ds_docto_xml.valor_icms AT ROW 7.08 COL 20.72 COLON-ALIGNED NO-LABEL WIDGET-ID 32
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int_ds_docto_xml.vbc_cst AT ROW 7.08 COL 40.72 COLON-ALIGNED NO-LABEL WIDGET-ID 46
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int_ds_docto_xml.valor_st AT ROW 7.08 COL 60.72 COLON-ALIGNED NO-LABEL WIDGET-ID 42
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int_ds_docto_xml.valor_mercad AT ROW 7.08 COL 81.29 COLON-ALIGNED NO-LABEL WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     bt-despesas AT ROW 8.83 COL 57 HELP
          "Rateia despesas nos itens" WIDGET-ID 208
     int_ds_docto_xml.valor_frete AT ROW 8.92 COL 3 NO-LABEL WIDGET-ID 30
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     int_ds_docto_xml.valor_seguro AT ROW 8.92 COL 20.72 COLON-ALIGNED NO-LABEL WIDGET-ID 40
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int_ds_docto_xml.valor_outras AT ROW 8.92 COL 40.72 COLON-ALIGNED NO-LABEL WIDGET-ID 38
          VIEW-AS FILL-IN 
          SIZE 14.29 BY .88
     int_ds_docto_xml.valor_ipi AT ROW 8.92 COL 60.86 COLON-ALIGNED NO-LABEL WIDGET-ID 34
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int_ds_docto_xml.vNF AT ROW 8.92 COL 81.29 COLON-ALIGNED NO-LABEL WIDGET-ID 48
          VIEW-AS FILL-IN 
          SIZE 17.57 BY .88
     int_ds_docto_xml.tot_desconto AT ROW 10.88 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 110
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     vl-desconto-itens AT ROW 10.88 COL 20.72 COLON-ALIGNED NO-LABEL WIDGET-ID 118
     int_ds_docto_xml.valor_pis AT ROW 10.88 COL 40.72 COLON-ALIGNED NO-LABEL WIDGET-ID 116
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int_ds_docto_xml.valor_cofins AT ROW 10.88 COL 60.86 COLON-ALIGNED NO-LABEL WIDGET-ID 112
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int_ds_docto_xml.valor_icms_des AT ROW 10.88 COL 81.29 COLON-ALIGNED NO-LABEL WIDGET-ID 114
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     bt-gnre AT ROW 12.13 COL 66 WIDGET-ID 210
     bt-totais AT ROW 12.13 COL 83 WIDGET-ID 154
     bt-natureza AT ROW 12.13 COL 100 WIDGET-ID 200
     bt-ordem AT ROW 12.13 COL 125 WIDGET-ID 202
     bt-guia-st AT ROW 12.67 COL 47 WIDGET-ID 174
     bt-red-icms AT ROW 12.67 COL 61.43 HELP
          "Atualiza % de Reduá∆o ICMS Itens" WIDGET-ID 188
     int_ds_docto_xml.valor_guia_st AT ROW 12.75 COL 3 NO-LABEL WIDGET-ID 170
          VIEW-AS FILL-IN 
          SIZE 14 BY .88
     int_ds_docto_xml.base_guia_st AT ROW 12.75 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 194
          VIEW-AS FILL-IN 
          SIZE 17.29 BY .88
     int_ds_docto_xml.dt_guia_st AT ROW 12.75 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 196
          VIEW-AS FILL-IN 
          SIZE 11.14 BY .88
     int_ds_docto_xml.perc_red_icms AT ROW 12.75 COL 51.43 COLON-ALIGNED NO-LABEL WIDGET-ID 198
          VIEW-AS FILL-IN 
          SIZE 8.14 BY .88
     "Natureza de Operaá∆o" VIEW-AS TEXT
          SIZE 20.57 BY .58 AT ROW 4.21 COL 3 WIDGET-ID 74
     "% Red ICMS" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 12 COL 53 WIDGET-ID 186
     "Descontos" VIEW-AS TEXT
          SIZE 10.57 BY .67 AT ROW 10.08 COL 2.72 WIDGET-ID 138
     "Valor ICMS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 6.25 COL 22.57 WIDGET-ID 58
     "Pedido" VIEW-AS TEXT
          SIZE 7 BY .42 AT ROW 4.29 COL 70.57 WIDGET-ID 78
     "Vl PIS" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 10.08 COL 42.72 WIDGET-ID 134
     "Base ICMS ST" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 6.25 COL 42.57 WIDGET-ID 62
     "Vlr Guia ST" VIEW-AS TEXT
          SIZE 10.29 BY .67 AT ROW 11.92 COL 2.72 WIDGET-ID 150
     "Entrega" VIEW-AS TEXT
          SIZE 8 BY .42 AT ROW 4.25 COL 96 WIDGET-ID 86
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     "Valor IPI" VIEW-AS TEXT
          SIZE 8.57 BY .67 AT ROW 8.13 COL 62.57 WIDGET-ID 102
     "Vl COFINS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 10.08 COL 62.57 WIDGET-ID 136
     "Vencto ST" VIEW-AS TEXT
          SIZE 10 BY .67 AT ROW 12 COL 36 WIDGET-ID 182
     "Base Guia ST" VIEW-AS TEXT
          SIZE 13 BY .67 AT ROW 11.92 COL 18 WIDGET-ID 180
     "Emiss∆o" VIEW-AS TEXT
          SIZE 8 BY .42 AT ROW 4.29 COL 83.57 WIDGET-ID 82
     "Valor ICMS ST" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 6.25 COL 62.57 WIDGET-ID 66
     "Base C†lculo" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 6.25 COL 2.57 WIDGET-ID 50
     "Comprador" VIEW-AS TEXT
          SIZE 10.86 BY .42 AT ROW 4.25 COL 109.57 WIDGET-ID 144
     "Desconto Itens" VIEW-AS TEXT
          SIZE 14.57 BY .67 AT ROW 10.08 COL 22.72 WIDGET-ID 132
     "Valor Produtos" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 6.25 COL 83.14 WIDGET-ID 70
     "Vl Seguro" VIEW-AS TEXT
          SIZE 9.57 BY .67 AT ROW 8.13 COL 22.57 WIDGET-ID 98
     "Vl Despesas" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 8.13 COL 42.57 WIDGET-ID 100
     "Vl Frete" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 8.13 COL 2.57 WIDGET-ID 104
     "Valor Total NF" VIEW-AS TEXT
          SIZE 13.57 BY .67 AT ROW 8.13 COL 83.14 WIDGET-ID 96
     "ICMS Desonerado" VIEW-AS TEXT
          SIZE 17 BY .67 AT ROW 10.08 COL 83.29 WIDGET-ID 130
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
     rt-key-2 AT ROW 1 COL 1 WIDGET-ID 212
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: custom.int_ds_docto_xml
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

/* SETTINGS FOR BUTTON bt-despesas IN FRAME f-main
   NO-ENABLE 3                                                          */
/* SETTINGS FOR BUTTON bt-guia-st IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-red-icms IN FRAME f-main
   NO-ENABLE 3                                                          */
ASSIGN 
       c-Mensagem:READ-ONLY IN FRAME f-main        = TRUE.

/* SETTINGS FOR FILL-IN c-Sitre IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-Situacao IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-tipo_nota IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cComprador IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cEstabelec IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cFornecedor IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatureza IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.cod_emitente IN FRAME f-main
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.cod_estab IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN cUF IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN data-emissao IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN data-entrega IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.dEmi IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN dt-movto IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-sit_re IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-situacao IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.nat_operacao IN FRAME f-main
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.nNF IN FRAME f-main
   NO-ENABLE 1 EXP-LABEL                                                */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.num_pedido IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.serie IN FRAME f-main
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.valor_frete IN FRAME f-main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.valor_guia_st IN FRAME f-main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.vbc IN FRAME f-main
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

&Scoped-define SELF-NAME bt-despesas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-despesas V-table-Win
ON CHOOSE OF bt-despesas IN FRAME f-main /* OK */
DO:
    RUN pi-rateia-despesas.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-gnre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-gnre V-table-Win
ON CHOOSE OF bt-gnre IN FRAME f-main /* GNRE */
DO:
  /* Code placed here will execute AFTER standard behavior.    */
    IF  AVAIL int_ds_docto_xml AND 
              int_ds_docto_xml.situacao <> 3 
    THEN DO:
        IF  INPUT FRAME {&FRAME-NAME} int_ds_docto_xml.dt_guia_st = ?
        THEN DO:
            RUN utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Data Vencimento Inv†lida!" + "~~" + "A data de vencimento da Guia ST Ç inv†lida, est† em branco.")).
            RETURN NO-APPLY.
        END.


        RUN pi-valida-usuario-compras.
        if RETURN-VALUE = "ADM-ERROR"
        THEN  
            RETURN NO-APPLY.
    
        RUN pi-verifica-situacao.
        IF  RETURN-VALUE = "ADM-ERROR" 
        THEN  
            RETURN NO-APPLY.
    
        FOR FIRST param-re NO-LOCK 
            WHERE param-re.usuario = c-seg-usuario: 
        END.

        IF  NOT AVAIL param-re 
        THEN DO:
            RUN utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Fornecedor inv†lido!" + "~~" + "O fornecedor n∆o foi encontrado no cadastro com o c¢digo: " + string(int_ds_docto_xml.cod_emitente))).
            RETURN NO-APPLY.
        END.

        for first emitente fields (nome-abrev estado cidade pais)
            no-lock where 
            emitente.cod-emitente = int_ds_docto_xml.cod_emitente: end.

        if not avail emitente then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Fornecedor inv†lido!" + "~~" + "O fornecedor n∆o foi encontrado no cadastro com o c¢digo: " + string(int_ds_docto_xml.cod_emitente))).
            RETURN NO-APPLY.
        end.

        for first estabelec 
            fields (estado 
                    cidade 
                    pais)
            no-lock where 
            estabelec.cod-estabel = int_ds_docto_xml.cod_estab:
        end.
        if not avail estabelec then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Estabelecimento inv†lido!" + "~~" + "O estabelecimento n∆o foi encontrado no cadastro com o c¢digo: " + int_ds_docto_xml.cod_estab)).
            RETURN NO-APPLY.
        end.

        for first natur-oper no-lock where 
            natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao: end.
        if not avail natur-oper then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Natureza de Operaá∆o inv†lida!" + "~~" + "A natureza de operaá∆o n∆o foi encontrada no cadastro com o c¢digo: " + int_ds_docto_xml.nat_operacao)).
            RETURN NO-APPLY.
        end.


        run utp/ut-msgs.p(input "show",
                          input 701,
                          input ("c†lculo para icms ST (Os valores atuais ser∆o sobrepostos) ")).

        IF  RETURN-VALUE = "YES"
        THEN DO:
            RUN pi-total-guia-st (INPUT YES). /* Atualiza */
            RUN pi-avaliar-erros.
    
            DISP  int_ds_docto_xml.base_guia_st 
                  int_ds_docto_xml.valor_guia_st 
                  int_ds_docto_xml.vbc_cst 
                  int_ds_docto_xml.valor_st WITH FRAME {&FRAME-NAME}.
    
            IF  VALID-HANDLE(h_int510-browser-itens) 
            THEN 
                RUN pi-refresh in h_int510-browser-itens.
        END.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-guia-st
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-guia-st V-table-Win
ON CHOOSE OF bt-guia-st IN FRAME f-main /* OK */
DO:
    RUN pi-calcula-guia-st.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-natureza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-natureza V-table-Win
ON CHOOSE OF bt-natureza IN FRAME f-main /* Preenche Natureza/PIS/COFINS */
DO:
  /* Code placed here will execute AFTER standard behavior.    */
  if avail int_ds_docto_xml then do:

        RUN pi-nat-operacao.

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ordem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ordem V-table-Win
ON CHOOSE OF bt-ordem IN FRAME f-main /* Preenche Ordem Compra */
DO:
  /* Code placed here will execute AFTER standard behavior.    */
  if avail int_ds_docto_xml then do:
    RUN pi-ordem-compra.
    if VALID-HANDLE(h_int510-browser-itens) then do:
        RUN pi-refresh in h_int510-browser-itens.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-red-icms
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-red-icms V-table-Win
ON CHOOSE OF bt-red-icms IN FRAME f-main /* OK */
DO:
    RUN pi-copia-perc-red-icmst.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-totais
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-totais V-table-Win
ON CHOOSE OF bt-totais IN FRAME f-main /* Copiar Totais dos Itens */
DO:
  /* Code placed here will execute AFTER standard behavior.    */
  if avail int_ds_docto_xml and
     int_ds_docto_xml.situacao <> 3 then do:

      /*
      if int_ds_docto_xml.sit_re < 25 or 
         int_ds_docto_xml.sit_re = 60 then*/ do:
          RUN pi-calcula-totais.

          for each b-int_ds_docto_xml where rowid(b-int_ds_docto_xml) = rowid(int_ds_docto_xml):
              assign  int_ds_docto_xml.vbc            = tot-base-icms-it       
                      int_ds_docto_xml.vbc_cst        = tot-base-icms-st-it    
                      int_ds_docto_xml.valor_cofins   = tot-cofins-it          
                      int_ds_docto_xml.tot_desconto   = tot-desconto-it        
                      int_ds_docto_xml.valor_icms     = tot-icms-it            
                      int_ds_docto_xml.valor_st       = tot-icms-st-it         
                      int_ds_docto_xml.valor_ipi      = tot-ipi-it             
                      int_ds_docto_xml.vNF            = tot-nf-it              
                      int_ds_docto_xml.valor_pis      = tot-tot-pis-it         
                      int_ds_docto_xml.valor_mercad   = tot-valor-it
                      int_ds_docto_xml.valor_icms_des = tot-icms-des.
          end.
    
          display int_ds_docto_xml.vbc          
                  int_ds_docto_xml.vbc_cst      
                  int_ds_docto_xml.valor_cofins 
                  int_ds_docto_xml.tot_desconto 
                  int_ds_docto_xml.valor_icms   
                  int_ds_docto_xml.valor_st     
                  int_ds_docto_xml.valor_ipi    
                  int_ds_docto_xml.vNF          
                  int_ds_docto_xml.valor_pis    
                  int_ds_docto_xml.valor_mercad 
                  int_ds_docto_xml.valor_icms_des
              with frame f-main.
          RUN new-state("RefreshData").
      end.
      /*
      else do:
          run utp/ut-msgs.p(input "show",
                            input 17006,
                            input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi conferida no WMS. Alteraá‰es n∆o ser∆o permitidas.")).
          return "ADM-ERROR".
      end.
      */
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_docto_xml.chnfe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_docto_xml.chnfe V-table-Win
ON LEAVE OF int_ds_docto_xml.chnfe IN FRAME f-main /* Chave NFE */
DO:
    if int_ds_docto_xml.chnfe:SCREEN-VALUE in frame f-Main <> "" then do:
        if trim(int_ds_docto_xml.serie:screen-value in frame f-Main) = "" then do:
    
            assign int_ds_docto_xml.serie:screen-value in frame f-Main = trim(string(int(substring(trim(int_ds_docto_xml.chnfe:SCREEN-VALUE in frame f-Main),23,3)),">>9")).
    
        end.
        if trim(int_ds_docto_xml.nNF:screen-value in frame f-Main) = "" then do:
    
            assign int_ds_docto_xml.nNF:screen-value in frame f-Main = trim(string(int(substring(trim(int_ds_docto_xml.chnfe:SCREEN-VALUE in frame f-Main),26,9)),">>9999999")).
    
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_docto_xml.cod_emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_docto_xml.cod_emitente V-table-Win
ON LEAVE OF int_ds_docto_xml.cod_emitente IN FRAME f-main /* Fornecedor */
DO:
    assign int_ds_docto_xml.cod_emitente:bgcolor in frame f-Main = ?.
    for first emitente fields (nome-emit estado)
        no-lock where 
        emitente.cod-emitente = input frame f-Main int_ds_docto_xml.cod_emitente:
        assign  cFornecedor:screen-value in frame f-Main = emitente.nome-emit
                cUF:screen-value in frame f-Main = emitente.estado.
    end.
    if not avail emitente then do:
        assign int_ds_docto_xml.cod_emitente:bgcolor in frame f-Main = 14.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_docto_xml.cod_estab
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_docto_xml.cod_estab V-table-Win
ON LEAVE OF int_ds_docto_xml.cod_estab IN FRAME f-main /* Filial */
DO:
    assign int_ds_docto_xml.cod_estab:bgcolor in frame f-Main = ?.
    for first estabelec fields (nome cod-emitente)
        no-lock where 
        estabelec.cod-estabel = input frame f-Main int_ds_docto_xml.cod_estab:
        for first emitente fields (nome-abrev) no-lock where 
            emitente.cod-emitente = estabelec.cod-emitente:
            assign  cEstabelec:screen-value in frame f-Main = emitente.nome-abrev + "-" + estabelec.nome.
        end.
    end.  
    if not avail estabelec then do:
        assign int_ds_docto_xml.cod_estab:bgcolor in frame f-Main = 14.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-sit_re
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-sit_re V-table-Win
ON LEAVE OF i-sit_re IN FRAME f-main /* Fase */
DO:
    /*  
    Situaá∆o 0 (zero): N∆o deve ser gerado integraá∆o do Totvs para o sistema PRS. Adequaá∆o no processo Totvs.
    Situaá∆o 10 (um): Deve ser gerado integraá∆o do Totvs para o sistema PRS e liberado conferància no WMS. Adequaá∆o no processo Totvs e Tutorial.
    Situaá∆o 20 (dois): Deve ser gerado integraá∆o do PRS para o sistema Totvs indicando que a NF foi conferida pelo WMS.
    Situaá∆o 25 (dois): Deve ser gerado integraá∆o do PRS para o sistema Totvs indicando que a NF foi conferida pelo WMS.
    Situaá∆o 30 (tràs): Deve ser gerado integraá∆o do Totvs para o sistema PRS e liberando a movimentaá∆o de estoque no PRS. Adequaá∆o no processo Totvs e Tutorial.
    Situaá∆o 40 (quatro): Deve ser gerado integraá∆o do PRS para o sistema Totvs indicando que a NF foi movimentada no sistema PRS.
    Situaá∆o 55 (cinco): Deve ser gerado integraá∆o do Totvs para o sistema PRS indicando que todo o processo deve ser desfeito (cancelamento da movimentaá∆o). Adequaá∆o no processo Totvs e Tutorial.
    Situaá∆o 60 (seis): Deve ser gerado integraá∆o do PRS para o sistema Totvs indicando que a NF foi cancelada e que pode retornar a situaá∆o 0 (zero) para refazer todo o procedimento.
    */
    assign c-SitRe:screen-value in frame F-Main = "".
    assign c-SitRe:bgcolor in frame F-Main = ?.
    case input FRAME f-Main i-sit_re:
        when 0 then assign c-SitRe:screen-value in frame F-Main = "Pendente Liberaá∆o p/ WMS".
        when 3 then assign c-SitRe:screen-value in frame F-Main = "Recebimento Antigo INT002".
        when 10 then assign c-SitRe:screen-value in frame F-Main = "Liberada p/ WMS".
        when 15 then assign c-SitRe:screen-value in frame F-Main = "Integrada no WMS".
        when 20 then assign c-SitRe:screen-value in frame F-Main = "Agendada no WMS".
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
        when 50 OR when 55
            then assign c-SitRe:screen-value in frame F-Main = "Movto em reenvio".
        when 90 then do:
            assign c-SitRe:screen-value in frame F-Main = "Recusa Fiscal".
            assign c-SitRe:bgcolor in frame F-Main = 12.
        end.
        when 95 then do:
            assign c-SitRe:screen-value in frame F-Main = "Recusa Comercial".
            assign c-SitRe:bgcolor in frame F-Main = 12.
        end.
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


&Scoped-define SELF-NAME int_ds_docto_xml.nat_operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_docto_xml.nat_operacao V-table-Win
ON LEAVE OF int_ds_docto_xml.nat_operacao IN FRAME f-main /* Nat Oper. */
DO:
    assign int_ds_docto_xml.nat_operacao:bgcolor in frame f-Main = ?
           bt-gnre:SENSITIVE in FRAME {&FRAME-NAME}              = NO.
    for first natur-oper 
        no-lock where 
        natur-oper.nat-operacao = input frame f-Main int_ds_docto_xml.nat_operacao:
        assign  cNatureza:screen-value in frame f-Main = natur-oper.denominacao.

        IF  AVAIL int_ds_docto_xml                    AND 
                  int_ds_docto_xml.situacao      <> 3 AND
                  natur-oper.log-contrib-st-antec = YES
        THEN
            ASSIGN bt-gnre:SENSITIVE in FRAME {&FRAME-NAME} = YES.
    end.  
    if not avail natur-oper then do:
        assign int_ds_docto_xml.nat_operacao:bgcolor in frame f-Main = 14.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_docto_xml.num_pedido
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_docto_xml.num_pedido V-table-Win
ON LEAVE OF int_ds_docto_xml.num_pedido IN FRAME f-main /* Pedido */
DO:
    /*RUN pi-verifica-pedido.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_docto_xml.valor_guia_st
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_docto_xml.valor_guia_st V-table-Win
ON LEAVE OF int_ds_docto_xml.valor_guia_st IN FRAME f-main /* Guia ST */
DO:
    if int_ds_docto_xml.valor_guia_st:input-value in FRAME {&FRAME-NAME} > 0 then do:
        assign bt-guia-st:sensitive in FRAME {&FRAME-NAME} = yes.
    end.
    else do:
        assign bt-guia-st:sensitive in FRAME {&FRAME-NAME} = no.
    end.

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
  {src/adm/template/row-list.i "int_ds_docto_xml"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_docto_xml"}

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

    /* retornar para virada procfit AVB AVB
    if int_ds_docto_xml.situacao = 3 then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Alteraá∆o inv†lida!" + "~~" + "A nota fiscal j† foi integrada.")).
        return "ADM-ERROR".
    end.
    */
    

    if trim(int_ds_docto_xml.nNF:screen-value in frame f-Main) = "" or
       trim(int_ds_docto_xml.nNF:screen-value in frame f-Main) = ? then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Nota Fiscal inv†lida!" + "~~" + "O n£mero da nota fiscal deve ser informado.")).
        return "ADM-ERROR".
    end.
    if trim(int_ds_docto_xml.serie:screen-value in frame f-Main) = "" or
       trim(int_ds_docto_xml.serie:screen-value in frame f-Main) = ? then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("SÇrie Nota Fiscal inv†lida!" + "~~" + "A sÇrie da nota fiscal deve ser informada.")).
        return "ADM-ERROR".
    end.
    if trim(int_ds_docto_xml.cod_emitente:screen-value in frame f-Main) = "" or
       trim(int_ds_docto_xml.cod_emitente:screen-value in frame f-Main) = ? then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Emitente inv†lido!" + "~~" + "O c¢digo do fornecedor deve ser informado.")).
        return "ADM-ERROR".
    end.
    if trim(int_ds_docto_xml.cod_estab:screen-value in frame f-Main) = "" or
       trim(int_ds_docto_xml.cod_estab:screen-value in frame f-Main) = ? then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Estabelecimento inv†lido!" + "~~" + "O c¢digo do estabelcimento deve ser informado (973).")).
        return "ADM-ERROR".
    end.
    if trim(int_ds_docto_xml.dEmi:screen-value in frame f-Main) = "" or
       trim(int_ds_docto_xml.dEmi:screen-value in frame f-Main) = "/  /" or
       trim(int_ds_docto_xml.dEmi:screen-value in frame f-Main) = ? then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Emiss∆o inv†lida!" + "~~" + "A data da emiss∆o da nota deve ser informada.")).
        return "ADM-ERROR".
    end.

    if INPUT FRAME f-main dt-movto <> ? then
    for each int_ds_docto_wms 
        exclusive-lock where 
        int_ds_docto_wms.doc_numero_n = int(int_ds_docto_xml.nNF) and
        int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie and
        int_ds_docto_wms.cnpj_cpf     = int_ds_docto_xml.CNPJ
        by int_ds_docto_wms.id_sequencial desc
        query-tuning(no-lookahead):
        assign FRAME f-main dt-movto.
        ASSIGN int_ds_docto_wms.datamovimentacao_d = INPUT FRAME f-main dt-movto.
        release int_ds_docto_wms.
        leave.
    end.

    if avail int_ds_docto_xml then do:
        RUN pi-verifica-situacao.
        if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

        /* liberando para reaprovar se tiver alterado valores  
        if int_ds_docto_xml.situacao = 7 /* aprovado compras */ then do:
            for first b-int_ds_docto_xml exclusive-lock where 
                rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml): 
                assign i-situacao:screen-value in FRAME {&FRAME-NAME} = "1"
                       b-int_ds_docto_xml.situacao = 1.
                apply "leave":u to i-situacao in FRAME {&FRAME-NAME}.
            end.
        end.
        */
    end.


    if  input FRAME {&FRAME-NAME} int_ds_docto_xml.base_guia_st  <> 0 OR
        input FRAME {&FRAME-NAME} int_ds_docto_xml.valor_guia_st <> 0
    then do:
        RUN pi-total-guia-st (INPUT NO). /* N∆o Atualiza */
        
        IF  input FRAME {&FRAME-NAME} int_ds_docto_xml.base_guia_st  <> tot-base_guia_st  OR 
            input FRAME {&FRAME-NAME} int_ds_docto_xml.valor_guia_st <> tot-valor_guia_st
        THEN DO:

            ASSIGN c-msg = "Valor Guia ST divergente! Confirma?" + "~~" + "O valor da Guia ST ou de sua base est† divergente com o calculado pelo sistema." + CHR(13) + 
                           "Valor Informado: " + STRING(input FRAME {&FRAME-NAME} int_ds_docto_xml.valor_guia_st, ">,>>>,>>9.99") + CHR(13)  +
                           "Valor Calculado: " + STRING(tot-valor_guia_st, ">,>>>,>>9.99")                                        + CHR(13)  +
                           "Base Informada:  " + STRING(input FRAME {&FRAME-NAME} int_ds_docto_xml.base_guia_st, ">,>>>,>>9.99")  + CHR(13)  + 
                           "Base Calculada:  " + STRING(tot-base_guia_st, ">,>>>,>>9.99").

            run utp/ut-msgs.p(input "show",
                              input 27100,
                              input c-msg).

            IF  RETURN-VALUE = "NO"
            THEN
                return "ADM-ERROR".
        END.
    end.

    
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .


    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.



    /*:T Todos os assignÔs n∆o feitos pelo assign-record devem ser feitos aqui */  
    /* Code placed here will execute AFTER standard behavior.    */
    
    find b-int_ds_docto_xml exclusive-lock where 
        rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml) no-error no-wait.
    if avail b-int_ds_docto_xml then do:
        if trim(b-int_ds_docto_xml.cnpj_dest) = "" or 
           b-int_ds_docto_xml.cnpj_dest = ? then do:
            for first estabelec fields (cgc)
                no-lock where estabelec.cod-estabel = "973"
                query-tuning(no-lookahead):
                assign b-int_ds_docto_xml.cnpj_dest = estabelec.cgc.
            end.
        end.
        if b-int_ds_docto_xml.cnpj   = "" or 
           b-int_ds_docto_xml.cnpj   = ?  or 
           b-int_ds_docto_xml.xNome  = "" or
           b-int_ds_docto_xml.xNome  = ?  then do:
            for first emitente fields (cod-emitente nome-emit cgc) no-lock where 
                emitente.cod-emitente = b-int_ds_docto_xml.cod_emitente
                query-tuning(no-lookahead):
                assign b-int_ds_docto_xml.cod_emitente  = emitente.cod-emitente
                       b-int_ds_docto_xml.xNome         = emitente.nome-emit
                       b-int_ds_docto_xml.cnpj          = emitente.cgc.
            end.
        end.
        release b-int_ds_docto_xml.
    end.

   for each b-int_ds_it_docto_xml exclusive-lock where
       b-int_ds_it_docto_xml.tipo_nota      = int_ds_docto_xml.tipo_nota    and 
       b-int_ds_it_docto_xml.cod_emitente   = int_ds_docto_xml.cod_emitente and 
       b-int_ds_it_docto_xml.nNF            = int_ds_docto_xml.nNF          and 
       b-int_ds_it_docto_xml.serie          = int_ds_docto_xml.serie
       query-tuning(no-lookahead):    
       
       if b-int_ds_it_docto_xml.cod_emitente <> int_ds_docto_xml.cod_emitente then
           assign b-int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente.

       if b-int_ds_it_docto_xml.num_pedido <> int_ds_docto_xml.num_pedido then do:
            assign b-int_ds_it_docto_xml.num_pedido = int_ds_docto_xml.num_pedido.
            for first ordem-compra no-lock where 
                ordem-compra.num-pedido = b-int_ds_it_docto_xml.num_pedido and
                ordem-compra.it-codigo  = b-int_ds_it_docto_xml.it_codigo
                query-tuning(no-lookahead): 
                assign b-int_ds_it_docto_xml.numero_ordem = ordem-compra.numero-ordem.
            end.
       end.
       release b-int_ds_it_docto_xml.
   end.


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
  if int_ds_docto_xml.situacao = 3 then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Alteraá∆o inv†lida!" + "~~" + "A nota fiscal j† foi integrada.")).
      return "ADM-ERROR".
  end.

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'delete-record':U ).

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
    if adm-new-record = yes then do:
        enable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
        assign c-mensagem:screen-value in FRAME {&FRAME-NAME} = "".

        assign
            bt-guia-st  :sensitive in FRAME {&FRAME-NAME} = no
            bt-natureza :sensitive in FRAME {&FRAME-NAME} = no
            bt-red-icms :sensitive in FRAME {&FRAME-NAME} = no
            bt-totais   :sensitive in FRAME {&FRAME-NAME} = no
            bt-despesas :sensitive in FRAME {&FRAME-NAME} = no.
    end.
    &endif
    if can-find (first usuar_grp_usuar no-lock where 
                 usuar_grp_usuar.cod_usuario = c-seg-usuario and
                 usuar_grp_usuar.cod_grp_usuar = "TAX") then 
        assign int_ds_docto_xml.valor_cofins :sensitive in FRAME {&FRAME-NAME} = yes
               int_ds_docto_xml.valor_pis    :sensitive in FRAME {&FRAME-NAME} = yes.
    else 
        assign int_ds_docto_xml.valor_cofins :sensitive in FRAME {&FRAME-NAME} = no
               int_ds_docto_xml.valor_pis    :sensitive in FRAME {&FRAME-NAME} = no.

    RUN pi-busca-docto-wms.

    ASSIGN dt-movto:SENSITIVE IN FRAME f-main = NO.
    for first param-estoq no-lock query-tuning(no-lookahead): 
        if param-estoq.ult-fech-dia >= dt-movto or
           param-estoq.mensal-ate >= dt-movto then do:
            ASSIGN dt-movto:SENSITIVE IN FRAME f-main = YES.
        end.
    end.

    /*
    if i-sit_re >= 10 and i-sit_re <> 60 then do:
        assign int_ds_docto_xml.num_pedido:sensitive in FRAME {&FRAME-NAME} = no.
    end.
    */
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
  
  
  ASSIGN v-row-docto-xml-nire003 = ?.
  
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'row-available':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  if avail int_ds_docto_xml then do:

      IF  int_ds_docto_xml.tipo_nota <> 3                AND 
          int_ds_docto_xml.cnpj_dest  = "79430682025540" AND 
          int_ds_docto_xml.situacao  <> 9 
      THEN
          ASSIGN v-row-docto-xml-nire003 = ROWID(int_ds_docto_xml).

      assign bt-guia-st :sensitive in frame {&frame-name} = yes
             bt-natureza:sensitive in frame {&frame-name} = yes
             bt-ordem   :sensitive in frame {&frame-name} = yes
             bt-red-icms:sensitive in frame {&frame-name} = yes
             bt-despesas:sensitive in frame {&frame-name} = yes.

      for first natur-oper no-lock where 
          natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao
          query-tuning(no-lookahead):
      
          if substring(natur-oper.char-1,159,1) = "S" /* Nfe de Estorno */
          then do:
              run new-state("DisableBtIntegra").
              assign bt-guia-st :sensitive in frame {&frame-name} = no
                     bt-natureza:sensitive in frame {&frame-name} = no
                     bt-ordem   :sensitive in frame {&frame-name} = no
                     bt-red-icms:sensitive in frame {&frame-name} = no
                     bt-despesas:sensitive in frame {&frame-name} = no.
          end.
          else do:
              run new-state("EnableBtIntegra").
          end.
      end.
      
      RUN pi-busca-docto-wms.

      assign i-sit_re:screen-value in frame f-Main = string(i-sit_re).
      assign i-situacao:screen-value in frame f-Main = string(int_ds_docto_xml.situacao).
      assign c-tipo_nota:screen-value in frame {&frame-name} = {ininc/i01in089.i 04 int_ds_docto_xml.tipo_nota}.

      apply "leave":u to int_ds_docto_xml.cod_emitente in frame f-main.
      apply "leave":u to int_ds_docto_xml.cod_estab in frame f-main.
      apply "leave":u to int_ds_docto_xml.nat_operacao in frame f-main.
      apply "leave":u to int_ds_docto_xml.num_pedido in frame f-main.
      apply "leave":u to i-situacao in frame f-main.
      apply "leave":u to i-sit_re in frame f-main.
      apply "leave":U to int_ds_docto_xml.valor_guia_st in frame f-main.
      RUN pi-ordem-compra.
      RUN pi-avaliar-erros.
  end.
  else 
      run new-state("DisableBtIntegra").

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


    if avail int_ds_docto_xml then do:
        RUN pi-verifica-situacao.
        if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.


        if can-find (first usuar_grp_usuar no-lock where 
                      usuar_grp_usuar.cod_usuario = c-seg-usuario and
                     (usuar_grp_usuar.cod_grp_usuar = "X23" or
                      usuar_grp_usuar.cod_grp_usuar = "ZZZ")) then do:
            if int_ds_docto_xml.situacao = 5 then do transaction:
        

                run utp/ut-msgs.p(input "show",
                                  input 701,
                                  input ("aprovaá∆o de compras para a nota fiscal?")).

                if return-value = "yes" then do:
                    RUN pi-libera-nf-compras.
                end. /* if return-value */
            end.
            else do:
                if int_ds_docto_xml.situacao = 7 then do:
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

    if avail int_ds_docto_xml then do:
        RUN pi-busca-docto-wms.

        if /*
           (i-sit_re >= 25 /* conferida wms */ and
            i-sit_re <> 50 /* em cancelamento wms */ and
            i-sit_re <> 60 /* cancelada wms */ and
            i-sit_re <> 40 /* movimentada prs */) or*/
            int_ds_docto_xml.situacao = 3
        then do:
            return.
        end.
    end.

    assign c-mensagem:screen-value in frame f-Main = "".
    assign c-mensagem:bgcolor in frame f-main = ?.
    RUN pi-elimina-doc-erro.

    RUN pi-verifica-estorno.
    if RETURN-VALUE = "ADM-ERROR":U then return.

    RUN pi-verifica-pedido.

    RUN pi-calcula-totais.
    
    if  tot-base-icms-it        = fnTrataNuloDec(int_ds_docto_xml.vbc) 
        then int_ds_docto_xml.vbc:bgcolor in frame f-Main = ?. else int_ds_docto_xml.vbc:bgcolor in frame f-Main = 14.
    if  tot-base-icms-st-it     = int_ds_docto_xml.vbc_cst
        then int_ds_docto_xml.vbc_cst:bgcolor in frame f-Main = ?. else int_ds_docto_xml.vbc_cst:bgcolor in frame f-Main = 14.
    if  tot-cofins-it           = fnTrataNuloDec(int_ds_docto_xml.valor_cofins)
        then int_ds_docto_xml.valor_cofins:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_cofins:bgcolor in frame f-Main = 14.
    if  tot-desconto-it         = fnTrataNuloDec(int_ds_docto_xml.tot_desconto)
        then int_ds_docto_xml.tot_desconto:bgcolor in frame f-Main = ?. else int_ds_docto_xml.tot_desconto:bgcolor in frame f-Main = 14.
    if  tot-icms-it             = fnTrataNuloDec(int_ds_docto_xml.valor_icms)
        then int_ds_docto_xml.valor_icms:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_icms:bgcolor in frame f-Main = 14.
    if  tot-icms-st-it          = fnTrataNuloDec(int_ds_docto_xml.valor_st)
        then int_ds_docto_xml.valor_st:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_st:bgcolor in frame f-Main = 14.
    if  tot-ipi-it              = fnTrataNuloDec(int_ds_docto_xml.valor_ipi)
        then int_ds_docto_xml.valor_ipi:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_ipi:bgcolor in frame f-Main = 14.
    if  tot-nf-it               = fnTrataNuloDec(int_ds_docto_xml.vNF)
        then int_ds_docto_xml.vNF:bgcolor in frame f-Main = ?. else int_ds_docto_xml.vNF:bgcolor in frame f-Main = 14.
    if  tot-tot-pis-it          = fnTrataNuloDec(int_ds_docto_xml.valor_pis)
        then int_ds_docto_xml.valor_pis:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_pis:bgcolor in frame f-Main = 14.
    if  tot-valor-it            = fnTrataNuloDec(int_ds_docto_xml.valor_mercad)
        then int_ds_docto_xml.valor_mercad:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_mercad:bgcolor in frame f-Main = 14.

    if  tot-base-icms-it        <> fnTrataNuloDec(int_ds_docto_xml.vbc          ) or
        tot-base-icms-st-it     <> fnTrataNuloDec(int_ds_docto_xml.vbc_cst      ) or
        tot-cofins-it           <> fnTrataNuloDec(int_ds_docto_xml.valor_cofins ) or
        tot-desconto-it         <> fnTrataNuloDec(int_ds_docto_xml.tot_desconto ) or
        tot-icms-it             <> fnTrataNuloDec(int_ds_docto_xml.valor_icms   ) or
        tot-icms-st-it          <> fnTrataNuloDec(int_ds_docto_xml.valor_st     ) or
        tot-ipi-it              <> fnTrataNuloDec(int_ds_docto_xml.valor_ipi    ) or
        tot-nf-it               <> fnTrataNuloDec(int_ds_docto_xml.vNF          ) or
        tot-tot-pis-it          <> fnTrataNuloDec(int_ds_docto_xml.valor_pis    ) or
        tot-valor-it            <> fnTrataNuloDec(int_ds_docto_xml.valor_mercad ) then do:
        run pi-gera-erro(INPUT 23,
                         INPUT "Totais dos itens n∆o conferem com a nota").   
    end.
    assign vl-desconto-itens:screen-value in frame f-main = string(tot-desconto-it).


    for first serie no-lock where
               serie.serie = int_ds_docto_xml.serie
        query-tuning(no-lookahead): end.
    if not avail serie then do:
        run pi-gera-erro(INPUT 1,    
                         INPUT "SÇrie N∆o cadastrada").   
    end.

    /*
    for first natur-oper no-lock where
              natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao
        query-tuning(no-lookahead) : end.

    if not avail natur-oper 
    then do:
       run pi-gera-erro(INPUT 9,    
                        INPUT "Natureza de Operaá∆o nota" + string(int_ds_docto_xml.nat_operacao) + " n∆o cadastrada!"). 
    end.
    */

    for first emitente no-lock where
              emitente.cgc = int_ds_docto_xml.cnpj,
        first dist-emitente no-lock of emitente where dist-emitente.idi-sit-fornec = 1
        query-tuning(no-lookahead): 
        if avail int_ds_docto_xml and 
           int_ds_docto_xml.cod_emitente <> emitente.cod-emitente
        then do transaction:
            find b-int_ds_docto_xml exclusive-lock where 
                rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml) no-error no-wait.
            if avail b-int_ds_docto_xml then do:
                assign b-int_ds_docto_xml.cod_emitente = emitente.cod-emitente
                       b-int_ds_docto_xml.cnpj         = emitente.cgc.
                release b-int_ds_docto_xml.
            end.
        end.
    end.
    if not avail emitente or not avail dist-emitente then do:
        run pi-gera-erro(INPUT 2,    
                         INPUT "Fornecedor " + int_ds_docto_xml.xNome + " n∆o cadastrado ou inativo. CNPJ " + STRING(int_ds_docto_xml.CNPJ) + " C¢digo: " + string(int_ds_docto_xml.cod_emitente)).       
    end.

    for first estabelec no-lock where
        estabelec.cod-estabel = int_ds_docto_xml.cod_estab query-tuning(no-lookahead). end.
    if avail estabelec and int_ds_docto_xml.cod_estab <> estabelec.cod-estabel 
    then do transaction:
        find b-int_ds_docto_xml exclusive-lock where 
            rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml) no-error no-wait.
        if avail b-int_ds_docto_xml then do:
            assign b-int_ds_docto_xml.cod_estab = estabelec.cod-estabel
                   b-int_ds_docto_xml.ep_codigo = int(estabelec.ep-codigo). 
            release b-int_ds_docto_xml.
        end.
    end.
    if not avail estabelec then do:
       run pi-gera-erro(INPUT 3,    
                        INPUT "Estabelecimento n∆o cadastrado com o CNPJ " + STRING(int_ds_docto_xml.cnpj_dest)).
    end. 
    if avail estabelec and estabelec.cod-estabel <> "973" then do:
       run pi-gera-erro(INPUT 3,    
                        INPUT "Estabelecimento n∆o pode ter recebimento pelo INT510!").
    end. 
    /* AVB retirado 30/10/2017 - Projeto Procfit 
    if int_ds_docto_xml.tipo-docto   = 4 AND 
       int_ds_docto_xml.tot_desconto = 0  /* notas Pepsico */  
    then do:
       run pi-gera-erro(INPUT 11,    
                        INPUT "N∆o foi informado o desconto.").
    end.
    */
                                         
    for first natur-oper no-lock where natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao query-tuning(no-lookahead):
        if not natur-oper.denominacao matches "*transf*" and natur-oper.emite-duplic then do:
            for first int_ds_docto_xml_dup no-lock of int_ds_docto_xml query-tuning(no-lookahead): end.
            if not avail int_ds_docto_xml_dup then do:
                assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main
                                                               + "N∆o encontradas duplicatas para o documento!" + chr(32).
            end.
        end.
    end.

    if int_ds_docto_xml.cfop = ? or  
       int_ds_docto_xml.cfop = 0 then do:
        run pi-gera-erro(INPUT 34,    
                         INPUT "CFOP da nota" + string(int_ds_docto_xml.nat_operacao) + " n∆o preenchida!"). 
    end.


    if  int_ds_docto_xml.valor_guia_st <> 0 and
        int_ds_docto_xml.valor_guia_st <> ? and
        int_ds_docto_xml.valor_st <> int_ds_docto_xml.valor_guia_st 
    then do:
        run pi-gera-erro(INPUT 19,    
                         INPUT "Valor Guia ST divergente do ICMS ST : " + 
                               " Guia: " + string(int_ds_docto_xml.valor_guia_st) + 
                               " ICMS ST: " + string(int_ds_docto_xml.valor_st)).
    end.

    run pi-verifica-duplicatas.

    for first param-estoq no-lock query-tuning(no-lookahead): 
        if param-estoq.ult-fech-dia >= dt-movto or
           param-estoq.mensal-ate >= dt-movto then do:

            run pi-gera-erro(input 37,
                             input "Documento em per°odo fechado. Verifique data de movimento. " 
                             + " Data: "     + string(dt-movto,"99/99/9999")).
        end.
    end.

    for each int_ds_doc_erro no-lock where
        int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie       and 
        int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF         and
        int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota   and 
        int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ 
        query-tuning(no-lookahead):
        if c-mensagem:screen-value in frame f-main = "" then
            assign c-mensagem:screen-value in frame f-main = trim(int_ds_doc_erro.descricao).
        else 
            assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main + " / " 
                                                           + trim(int_ds_doc_erro.descricao).
    end.
    if c-mensagem:screen-value in frame f-Main <> "" and
       can-find(first int_ds_doc_erro no-lock WHERE 
                      int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie and 
                      int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF and 
                      int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota and 
                      int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ and 
                      int_ds_doc_erro.tipo_erro    <> "Aviso") then
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
    define buffer b-int_ds_docto_wms for int_ds_docto_wms.
    define variable dt-aux as date no-undo.

      i-sit_re = 0.
      for each int_ds_docto_wms no-lock where
          int_ds_docto_wms.doc_numero_n = int(int_ds_docto_xml.nNF) and
          int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie and
          int_ds_docto_wms.doc_origem_n = int_ds_docto_xml.cod_emitente
          by int_ds_docto_wms.id_sequencial desc
          query-tuning(no-lookahead):

          /* processo de reenvio realizado no Procfit - Volta para situaá∆o anterior */
          dt-aux = ?.
          i-sit_re = ?.
          if  int_ds_docto_wms.situacao = 55 and
              int_ds_docto_wms.envio_status = 2 then do:

              for each b-int_ds_docto_wms no-lock where 
                  b-int_ds_docto_wms.doc_numero_n  = int(int_ds_docto_xml.nNF) and
                  b-int_ds_docto_wms.doc_serie_s   = int_ds_docto_xml.serie and
                  b-int_ds_docto_wms.doc_origem_n  = int_ds_docto_xml.cod_emitente and
                  b-int_ds_docto_wms.ID_SEQUENCIAL <> int_ds_docto_wms.ID_SEQUENCIAL and
                  b-int_ds_docto_wms.situacao      <= 40
                  by b-int_ds_docto_wms.id_sequencial desc
                  query-tuning(no-lookahead):
                  assign dt-aux = b-int_ds_docto_wms.datamovimentacao_d
                         i-sit_re      = b-int_ds_docto_wms.situacao.
                  leave.
              end.
              if dt-aux <> ? or i-sit_re <> ? then do:
                  create b-int_ds_docto_wms.
                  buffer-copy int_ds_docto_wms 
                      except int_ds_docto_wms.ID_SEQUENCIAL
                      to b-int_ds_docto_wms
                      assign b-int_ds_docto_wms.situacao = i-sit_re
                             b-int_ds_docto_wms.datamovimentacao_d = dt-aux
                             b-int_ds_docto_wms.ENVIO_STATUS = 2
                             b-int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today)
                             /*b-int_ds_docto_wms.ID_SEQUENCIAL = next-value(seq-int-ds-docto-wms)*/ .
                  release b-int_ds_docto_wms.
              end.
          end.
          
          if  int_ds_docto_wms.situacao = 20 and
              int_ds_docto_wms.envio_status = 1 then do:
              find b-int_ds_docto_wms exclusive where 
                  rowid(b-int_ds_docto_wms) = rowid (int_ds_docto_wms) no-error no-wait.
              if avail b-int_ds_docto_wms then do:
                  assign b-int_ds_docto_wms.ENVIO_STATUS = 2.
                  release b-int_ds_docto_wms.
              end.
          end.
          
          if  int_ds_docto_wms.situacao = 10 and
              int_ds_docto_wms.envio_status = 2 then do:
              create b-int_ds_docto_wms.
              buffer-copy int_ds_docto_wms 
                  except int_ds_docto_wms.ID_SEQUENCIAL
                  to b-int_ds_docto_wms
                  assign b-int_ds_docto_wms.situacao = 15
                         b-int_ds_docto_wms.ENVIO_STATUS = 2
                         b-int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today)
                         /*b-int_ds_docto_wms.ID_SEQUENCIAL = next-value(seq-int-ds-docto-wms)*/ .
              assign i-sit_re = b-int_ds_docto_wms.situacao.
              release b-int_ds_docto_wms.
          end.

          /* foráar situacao = 3 - Recebida quando j† estiver em RE0701 */
          if int_ds_docto_xml.situacao <> 3 then
          for each docum-est no-lock where
              docum-est.serie-docto  = trim(int_ds_docto_xml.serie) and 
              docum-est.nro-docto    = trim(string(int(int_ds_docto_xml.nNF),">>>>9999999")) and 
              docum-est.cod-emitente = int_ds_docto_xml.cod_emitente
              query-tuning(no-lookahead):
              for each b-int_ds_docto_xml where 
                  rowid(b-int_ds_docto_xml) = rowid(int_ds_docto_xml):
                  assign b-int_ds_docto_xml.situacao = 3.
              end.
          end.

          if i-sit_re = ? then assign i-sit_re = int_ds_docto_wms.situacao.

          if i-sit_re = 3 then do:
              find b-int_ds_docto_wms exclusive where 
                  rowid(b-int_ds_docto_wms) = rowid (int_ds_docto_wms) no-error no-wait.
              if avail b-int_ds_docto_wms then do:
                  assign  /*b-int_ds_docto_wms.situacao = 40*/
                          b-int_ds_docto_wms.datamovimentacao_d = if b-int_ds_docto_wms.datamovimentacao_d = ? 
                                                                  then int_ds_docto_xml.dt_trans 
                                                                  else b-int_ds_docto_wms.datamovimentacao_d.
                  release b-int_ds_docto_wms.
              end.
          end.
          
          assign dt-movto = ?
                 dt-movto:screen-value in FRAME {&FRAME-NAME} = string(dt-movto).
          if i-sit_re = 40 then do:
              assign dt-movto = int_ds_docto_wms.datamovimentacao_d
                     dt-movto:screen-value in FRAME {&FRAME-NAME} = string(dt-movto).
              if int_ds_docto_xml.situacao = 1 then do:
                  for each b-int_ds_docto_xml where
                      rowid(b-int_ds_docto_xml) = rowid(int_ds_docto_xml)
                      query-tuning(no-lookahead):
                      assign b-int_ds_docto_xml.situacao = 2.
                  end.
              end.
          end.
          leave. /* usa apenas £ltimo sequencial e sai */    
      end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-calcula-guia-st V-table-Win 
PROCEDURE pi-calcula-guia-st :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    APPLY "CHOOSE" TO bt-gnre IN FRAME {&FRAME-NAME}.

END PROCEDURE.


procedure pi-gera-tt-docto:

    def var i-seq-docto as integer  no-undo.

    empty temp-table tt-docto.
    find last tt-docto use-index seq no-lock no-error.
    assign i-seq-docto = if avail tt-docto then tt-docto.seq-tt-docto + 1
                         else 1.

    create tt-docto.
    assign tt-docto.estado          = estabelec.estado
           tt-docto.cidade          = estabelec.cidade
           tt-docto.pais            = estabelec.pais.

    assign tt-docto.seq-tt-docto    = i-seq-docto
           tt-docto.cod-estabel     = int_ds_docto_xml.cod_estab
           tt-docto.serie           = int_ds_docto_xml.serie
           tt-docto.nr-nota         = int_ds_docto_xml.nNF
           tt-docto.cod-emitente    = int_ds_docto_xml.cod_emitente
           tt-docto.nat-operacao    = int_ds_docto_xml.nat_operacao  
           tt-docto.dt-emis-nota    = int_ds_docto_xml.dEmi
           tt-docto.dt-trans        = today
           tt-docto.nome-abrev      = emitente.nome-abrev
           tt-docto.usuario         = param-re.usuario  
           tt-docto.inc-seq         = param-re.inc-seq
           tt-docto.seq-item-um     = param-re.seq-item-um.


    assign tt-docto.cod-des-merc    = if natur-oper.consum-final then 2 else 1
           tt-docto.esp-docto       = if int_ds_docto_xml.tipo_nota = 1 then 21 /* NFE */ else 23 /* NFT */
           tt-docto.cod-msg         = natur-oper.cod-mensagem
           tt-docto.cod-portador    = 0
           tt-docto.modalidade      = 0
           tt-docto.ind-lib-nota    = yes
           tt-docto.ind-tip-nota    = 8
           tt-docto.vl-mercad       = fnTrataNuloDec(int_ds_docto_xml.valor_mercad  )
           tt-docto.vl-frete        = fnTrataNuloDec(int_ds_docto_xml.valor_frete   )
           tt-docto.vl-seguro       = fnTrataNuloDec(int_ds_docto_xml.valor_seguro  )
           /*tt-docto.vl-embalagem    = int_ds_docto_xml.valor-embal*/
           tt-docto.vl-outras       = fnTrataNuloDec(int_ds_docto_xml.valor_outras  )
           tt-docto.perc-desco1     = if fnTrataNuloDec(int_ds_docto_xml.tot_desconto) <> 0 then 1 else 0.

    if  natur-oper.tipo-compra = 3        /* Devolucao de Cliente */ 
    or (    avail natur-oper             
        and natur-oper.tipo = 1
        and natur-oper.tp-oper-terc = 5) /*Devolucao de Consignacao */ then
        assign tt-docto.estado = emitente.estado
               tt-docto.cidade = emitente.cidade
               tt-docto.pais   = emitente.pais.
end.

procedure pi-gera-tt-it-doc:

    def var de-qtd-aux  like item-doc-est.quantidade no-undo.
    def var i-seq-aux   as   integer                 no-undo.
    def var i-trib-icm  as integer no-undo.
    def var i-trib-ipi  as integer no-undo.
    empty temp-table tt-it-docto.
    empty temp-table tt-it-imposto.
    find last tt-it-docto use-index seq no-lock no-error.
    find last tt-docto use-index seq no-lock no-error.

    assign i-seq-aux = if  avail tt-it-docto 
                       then tt-it-docto.seq-tt-it-docto + 1
                       else 1. 

    for each int_ds_it_docto_xml no-lock where
        int_ds_it_docto_xml.serie       = int_ds_docto_xml.serie    and
        int_ds_it_docto_xml.nNF         = int_ds_docto_xml.nNF      and
        int_ds_it_docto_xml.cnpj        = int_ds_docto_xml.cnpj     and
        int_ds_it_docto_xml.tipo_nota   = int_ds_docto_xml.tipo_nota
        query-tuning(no-lookahead):

        assign de-qtd-aux = if  int_ds_it_docto_xml.qCom_Forn <> 0 then 
                                int_ds_it_docto_xml.qCom_Forn
                            else 1.

        create tt-it-docto.
        assign tt-it-docto.seq-tt-it-docto = i-seq-aux
               tt-it-docto.cod-emitente   = tt-docto.cod-emitente
               tt-it-docto.nr-nota        = tt-docto.nr-nota
               tt-it-docto.serie          = tt-docto.serie
               tt-it-docto.cod-estabel    = tt-docto.cod-estabel
               tt-it-docto.nat-operacao   = tt-docto.nat-operacao
               tt-it-docto.calcula        = yes
               tt-it-docto.alterado       = yes
               i-seq-aux                  = i-seq-aux + 1.

        for first natur-oper no-lock where 
            natur-oper.nat-operacao = int_ds_it_docto_xml.nat_operacao
            query-tuning(no-lookahead): end.
        if not avail natur-oper then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Natureza de Operaá∆o inv†lida!" + "~~" + "A natureza de operaá∆o do item sequància " + string(int_ds_it_docto_xml.sequencia) + "/" + 
                                     int_ds_it_docto_xml.it_codigo + "n∆o foi encontrada no cadastro com o c¢digo: " + int_ds_docto_xml.nat_operacao)).
            return "ADM-ERROR".
        end.

        if (natur-oper.terceiro and (natur-oper.tp-oper-terc = 2 or natur-oper.tp-oper-terc = 5)) or 
            natur-oper.tipo-compra = 3 then 
            assign de-qtd-aux = if int_ds_it_docto_xml.qCom <> 0 
                                then int_ds_it_docto_xml.qCom
                                else 1.

        assign tt-it-docto.nr-sequencia   = int_ds_it_docto_xml.sequencia.
        assign 
               tt-it-docto.quantidade[1]  = int_ds_it_docto_xml.qCom
               tt-it-docto.quantidade[2]  = int_ds_it_docto_xml.qCom_Forn

               /* Valor do Frete a Nivel de Item - Utilizado para Calculo Imposto */   
               tt-it-docto.vl-frete       = 0
               tt-it-docto.vl-despes-it   = fnTrataNuloDec(int_ds_it_docto_xml.vOutro)
               tt-it-docto.baixa-estoq    = yes
               tt-it-docto.calcula        = yes
               tt-it-docto.alterado       = no
               tt-it-docto.vl-cotacao[1]  = 1
               tt-it-docto.vl-cotacao[2]  = 1
               tt-it-docto.vl-unit-mob    = 0
               tt-it-docto.un[2]          = int_ds_it_docto_xml.uCom_forn
               tt-it-docto.nat-of         = int_ds_it_docto_xml.nat_operacao. /* busbcar int013 */

        for first item no-lock where 
            item.it-codigo = int_ds_it_docto_xml.it_codigo
            query-tuning(no-lookahead): 
            assign tt-it-docto.peso-liq-it = item.peso-liquido * tt-it-docto.quantidade[1].
        end.

        for first ordem-compra no-lock where 
            ordem-compra.numero-ordem = int_ds_it_docto_xml.numero_ordem
            query-tuning(no-lookahead): end.

        if  avail item 
            and item.tipo-contr = 4
            and avail ordem-compra  then do:

                for first prazo-compra no-lock where 
                    prazo-compra.numero-ordem = ordem-compra.numero-ordem
                    query-tuning(no-lookahead): end.

                assign tt-it-docto.un[1] = if avail prazo-compra then prazo-compra.un 
                                           else if avail item  then item.un else "".
                assign tt-it-docto.parcela = prazo-compra.parcela.
        end.
        else
            assign tt-it-docto.un[1] = if avail item then item.un else "".

        assign tt-it-docto.it-codigo      = int_ds_it_docto_xml.it_codigo
               tt-it-docto.class-fiscal   = string(int_ds_it_docto_xml.ncm)
               tt-it-docto.num-pedido     = int_ds_it_docto_xml.num_pedido
               tt-it-docto.numero-ordem   = int_ds_it_docto_xml.numero_ordem.

        assign tt-it-docto.desconto       = fnTrataNuloDec(int_ds_it_docto_xml.vDesc)
               tt-it-docto.per-des-item   = int(tt-it-docto.desconto > 0)
               tt-it-docto.vl-preuni      = (fnTrataNuloDec(int_ds_it_docto_xml.vProd)
                                          -  fnTrataNuloDec(int_ds_it_docto_xml.vDesc))
                                          /  de-qtd-aux
               tt-it-docto.vl-preori      = fnTrataNuloDec(int_ds_it_docto_xml.vProd)
                                          / de-qtd-aux

               tt-it-docto.vl-merc-liq    = (fnTrataNuloDec(int_ds_it_docto_xml.vProd)
                                          -  fnTrataNuloDec(int_ds_it_docto_xml.vDesc))
               tt-it-docto.calcula        = yes
               tt-it-docto.vl-merc-ori    = fnTrataNuloDec(int_ds_it_docto_xml.vProd)
               tt-it-docto.vl-merc-tab    = tt-it-docto.vl-merc-ori
               tt-it-docto.vl-pretab      = tt-it-docto.vl-preori.

        case int_ds_it_docto_xml.cst_icms:
            when 00 then i-trib-icm = 1 /* tributado */.
            when 10 then i-trib-icm = 1 /* tributado */.
            when 20 then i-trib-icm = 4 /* reduzido */ .
            when 30 then i-trib-icm = 2 /* isento */   .
            when 40 then i-trib-icm = 2 /* isento */   .
            when 41 then i-trib-icm = 2 /* isento */   .
            when 50 then i-trib-icm = 3 /* outros */   .
            when 60 then i-trib-icm = 1 /* tributado */.
            when 70 then i-trib-icm = 4 /* reduzido */ .
            when 90 then i-trib-icm = 3 /* outros */   .
            otherwise i-trib-icm = 3 /* outros */ .
        end.

        case int_ds_it_docto_xml.cst_ipi:
            when 00 then i-trib-ipi = 1 /* Entrada com Recuperaá∆o de CrÇdito */.
            when 01 then i-trib-ipi = 1 /* Entrada com Recuperaá∆o de CrÇdito */.
            when 02 then i-trib-ipi = 2 /* Entrada Isenta */   .
            when 03 then i-trib-ipi = 2 /* Entrada Isenta */ .
            when 04 then i-trib-ipi = 2 /* Entrada Isenta */   .
            when 05 then i-trib-ipi = 3 /* Entrada com Suspens∆o */   .
            when 49 then i-trib-ipi = 3 /* outros */   .
            otherwise i-trib-ipi = 3 /* outros */ .
        end.

        create tt-it-imposto.
        assign tt-it-imposto.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto.
        assign tt-it-imposto.ind-icm-ret     = /*int_ds_it_docto_xml.log-2*/ yes
               tt-it-imposto.cd-trib-icm     = i-trib-icm
               tt-it-imposto.aliquota-icm    = int_ds_it_docto_xml.picms

               tt-it-imposto.vl-bicms-it     = fnTrataNuloDec(int_ds_it_docto_xml.vbc_icms)
               tt-it-imposto.vl-icms-it      = fnTrataNuloDec(int_ds_it_docto_xml.vicms)

               tt-it-imposto.vl-icmsnt-it    = if i-trib-icm = 2     
                                               then tt-it-imposto.vl-bicms-it
                                               else 0 

               tt-it-imposto.vl-icmsou-it    = if (i-trib-icm = 3 or i-trib-icm = 5)
                                               then tt-it-imposto.vl-bicms-it
                                               else if i-trib-icm = 4 then
                                                    (tt-it-docto.vl-merc-ori - tt-it-imposto.vl-bicms-it)
                                               else 0

               tt-it-imposto.vl-bsubs-it     = fnTrataNuloDec(int_ds_it_docto_xml.vbcst)
               tt-it-imposto.vl-icmsub-it    = fnTrataNuloDec(int_ds_it_docto_xml.vicmsst)
               tt-it-imposto.icm-complem     = 0
               tt-it-imposto.perc-red-icm    = fnTrataNuloDec(int_ds_it_docto_xml.predBc)
            
               tt-it-imposto.aliquota-ipi    = fnTrataNuloDec(int_ds_it_docto_xml.pipi)
               tt-it-imposto.cd-trib-ipi     = i-trib-ipi
               tt-it-imposto.perc-red-ipi    = 0
               tt-it-imposto.vl-ipi-it       = fnTrataNuloDec(int_ds_it_docto_xml.vipi)
               tt-it-imposto.vl-bipi-it      = fnTrataNuloDec(int_ds_it_docto_xml.vbc_ipi)
               tt-it-imposto.vl-ipint-it     = if i-trib-ipi = 2
                                               then tt-it-imposto.vl-bipi-it
                                               else 0
               tt-it-imposto.vl-ipiou-it     = if i-trib-ipi = 3 
                                               then tt-it-imposto.vl-bipi-it
                                               else 0.

    end.
end.

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
   if i-situacao:screen-value in FRAME {&FRAME-NAME} = "5" and
      not can-find (first int_ds_docto_xml_compras no-lock of int_ds_docto_xml) then do:
       find b-int_ds_docto_xml exclusive-lock where 
            rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml) no-error no-wait.
       if avail b-int_ds_docto_xml then do:
           assign b-int_ds_docto_xml.situacao = 1
                  i-situacao:screen-value in FRAME {&FRAME-NAME} = "1".
           apply "leave":u to i-situacao in FRAME {&FRAME-NAME}.
           release b-int_ds_docto_xml.
       end.
   end.

   for each int_ds_it_docto_xml no-lock where
       int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF          and 
       int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie        and
       int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente and 
       int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota  
       query-tuning(no-lookahead):

       FIND FIRST ITEM NO-LOCK
           WHERE ITEM.it-codigo = int_ds_it_docto_xml.it_codigo NO-ERROR.

       IF AVAIL ITEM THEN DO:

           IF ITEM.cod-obsoleto = 4 THEN DO:

                run pi-gera-erro(INPUT 38,
                   INPUT "ITEM " + string(ITEM.it-codigo) + " esta totalmente obsoleto"). 
           END.


       END.

       if  int_ds_it_docto_xml.cfop <> ? and int_ds_it_docto_xml.cfop <> 0 and 
           int_ds_it_docto_xml.cfop > 5000 and 
          (int_ds_docto_xml.cfop = ? or int_ds_docto_xml.cfop < 5000) then do:
           find b-int_ds_docto_xml exclusive-lock where 
                rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml) no-error no-wait.
           if avail b-int_ds_docto_xml then do:
               assign b-int_ds_docto_xml.cfop = int(int_ds_it_docto_xml.cfop)
                      int_ds_docto_xml.cfop:screen-value in FRAME {&FRAME-NAME} = string(int_ds_it_docto_xml.cfop).
               release b-int_ds_docto_xml.
           end.
       end.

       if int_ds_it_docto_xml.tipo_nota <> 3 /* transferencia */ and
          not can-find (first estabelec no-lock where estabelec.cod-emitente = int_ds_docto_xml.cod_emitente) then do:

           assign  c-item-do-forn = int_ds_it_docto_xml.item_do_forn
                   c-un-forn = "".
           for first item-fornec no-lock where
                     item-fornec.cod-emitente = int_ds_docto_xml.cod_emitente and
                     item-fornec.item-do-forn = c-item-do-forn and 
                     item-fornec.ativo = yes
               query-tuning(no-lookahead): 
               assign c-un-forn = item-fornec.unid-med-for.
           end.
           if not avail item-fornec then do:
               c-item-do-forn = trim(c-item-do-forn).
               for first item-fornec no-lock where
                         item-fornec.cod-emitente = int_ds_docto_xml.cod_emitente and
                         item-fornec.item-do-forn = c-item-do-forn and 
                         item-fornec.ativo = yes
                   query-tuning(no-lookahead): 
                   assign c-un-forn = item-fornec.unid-med-for.
               end.

               for first item-fornec-umd where
                         item-fornec-umd.cod-emitente = int_ds_docto_xml.cod_emitente and
                         item-fornec-umd.cod-livre-1  = c-item-do-forn and  
                         item-fornec-umd.log-ativo no-lock
                         query-tuning(no-lookahead): 
                   assign c-un-forn = item-fornec-umd.unid-med-for.
               end.
               if avail item-fornec-umd 
               then do:
                  for first item-fornec no-lock where 
                            item-fornec.cod-emitente = int_ds_docto_xml.cod_emitente and
                            item-fornec.it-codigo    = item-fornec-umd.it-codigo and
                            item-fornec.ativo = YES query-tuning(no-lookahead): end.

               end.
               if not avail item-fornec then do:
                  run pi-gera-erro(INPUT 5,
                                   INPUT "Relacionamento item x fornecedor n∆o cadastrado. Item: " + 
                                         string(int_ds_it_docto_xml.item_do_forn) + 
                                         " Fornecedor: " + STRING(int_ds_docto_xml.cod_emitente)). 
               end.
           end.
           if avail item-fornec then do:
               find b-int_ds_it_docto_xml exclusive-lock where 
                    rowid (b-int_ds_it_docto_xml) = rowid (int_ds_it_docto_xml) no-error no-wait.
               if avail b-int_ds_it_docto_xml then do:

                   if c-un-forn <> "" /*and 
                      (int_ds_it_docto_xml.uCom_forn = "" or 
                       int_ds_it_docto_xml.uCom_forn = ? or 
                       trim(int_ds_it_docto_xml.uCom_forn) = "?")*/ then do:
                       assign b-int_ds_it_docto_xml.uCom_forn = c-un-forn.
                   end.

                   if b-int_ds_it_docto_xml.it_codigo = "" then
                       assign b-int_ds_it_docto_xml.it_codigo = item-fornec.it-codigo.
    
                   
                   run retornaIndiceConversao in h-boin176 (input int_ds_it_docto_xml.it_codigo,
                                                            input int_ds_it_docto_xml.cod_emitente,
                                                            input /*item-fornec.unid-med-for*/ c-un-forn,
                                                            output de-fator). 
                                                        
    /*
                   run pi-retorna-indice-conversao (input int_ds_it_docto_xml.it_codigo,
                                                    input int_ds_it_docto_xml.cod_emitente,
                                                    input /*item-fornec.unid-med-for*/ c-un-forn,
                                                    output de-fator). */
    
                   if de-fator = 0 or de-fator = ? then assign de-fator = 1. 
    
                   if int_ds_docto_xml.situacao <> 3 then do:
                       assign b-int_ds_it_docto_xml.qCom = round(b-int_ds_it_docto_xml.qCom_Forn / de-fator,0).

                       if b-int_ds_it_docto_xml.qCom <= 1 then assign b-int_ds_it_docto_xml.qCom = 1.
                    end.
                    release b-int_ds_it_docto_xml.
               end.
           end.
       end. /* tipo_nota <> 3 */

       if int_ds_it_docto_xml.qCom = ?  or
          int_ds_it_docto_xml.qCom = 0  or
          int_ds_it_docto_xml.uCom_forn = "" then do:
           run pi-gera-erro(INPUT 27,
                            INPUT "Quantidade Fornecedor/Unidade n∆o informados. Item: " + 
                                  string(int_ds_it_docto_xml.item_do_forn) + " Seq: " + string(int_ds_it_docto_xml.sequencia)). 
       end.
       for each item no-lock where  
           item.it-codigo = int_ds_it_docto_xml.it_codigo query-tuning(no-lookahead): 
           find b-int_ds_it_docto_xml exclusive-lock where 
                rowid (b-int_ds_it_docto_xml) = rowid (int_ds_it_docto_xml) no-error no-wait.
           if avail b-int_ds_it_docto_xml then do:
               assign b-int_ds_it_docto_xml.uCom   = if item.un <> b-int_ds_it_docto_xml.uCom then item.un else b-int_ds_it_docto_xml.uCom
                      b-int_ds_it_docto_xml.xprod  = substring(ITEM.desc-item,1,60)
                      b-int_ds_it_docto_xml.tipo_contr = 4.
               if int_ds_docto_xml.situacao <> 3 then do:
                  if item.tipo-contr < 3 then assign b-int_ds_it_docto_xml.tipo_contr = 1.
               end. 
               release b-int_ds_it_docto_xml.
           end.
       end.
       if not avail item then do:
           run pi-gera-erro(INPUT 7,    
                            INPUT "Item N∆o cadastrado " + string(int_ds_it_docto_xml.it_codigo)). 
       end.

       if int_ds_docto_xml.situacao <> 7 /* j† aprovado compras */ and
          not can-find(first int_ds_docto_xml_compras no-lock of int_ds_docto_xml) then do:
           
           /* AVB retirado 30/10/2017 - Projeto Procfit
           for first param-re no-lock where
               param-re.usuario = c-seg-usuario and
               not param-re.sem-pedido:
               for first pedido-compr no-lock where
                   pedido-compr.num-pedido = int_ds_it_docto_xml.num_pedido. end.
               if not avail pedido-compr and
                  c-seg-usuario <> "999909" then do:
                  run pi-gera-erro(INPUT 4,
                                   INPUT "Pedido " + string(int_ds_it_docto_xml.num_pedido) + " N∆o cadastrado").   
               end.
           end.
           */

           for first int_ds_param_re no-lock where 
               int_ds_param_re.cod_usuario = c-seg-usuario query-tuning(no-lookahead): end.
           if not avail int_ds_param_re then do:
               run pi-gera-erro(INPUT 16, 
                                INPUT "ParÉmetros do recebimento do usu†rio incompletos.").   
           end.
           else if int_ds_docto_xml.situacao <> 7 and
                  not can-find (first int_ds_docto_xml_compras no-lock of int_ds_docto_xml) 
           then do:
               if int_ds_docto_xml.num_pedido <> int_ds_it_docto_xml.num_pedido and
                  int_ds_docto_xml.num_pedido <> ? and
                  int_ds_docto_xml.num_pedido <> 0 and
                  int_ds_docto_xml.situacao <> 3 
               then do:
                   find b-int_ds_it_docto_xml exclusive-lock where 
                        rowid (b-int_ds_it_docto_xml) = rowid (int_ds_it_docto_xml) no-error no-wait.
                   if avail b-int_ds_it_docto_xml then do:
                       assign b-int_ds_it_docto_xml.num_pedido = int_ds_docto_xml.num_pedido.
                       release b-int_ds_it_docto_xml.
                   end.
               end.
               for first ordem-compra no-lock where 
                   ordem-compra.numero-ordem = int_ds_it_docto_xml.numero_ordem and
                   ordem-compra.it-codigo  = int_ds_it_docto_xml.it_codigo
                   query-tuning(no-lookahead): end.
               if not avail ordem-compra then do:
                   for first ordem-compra no-lock where 
                       ordem-compra.num-pedido = int_ds_it_docto_xml.num_pedido and
                       ordem-compra.it-codigo  = int_ds_it_docto_xml.it_codigo
                       query-tuning(no-lookahead): end.
               end.
               /* AVB retirado 30/10/2017 - Projeto Procfit
               if not avail ordem-compra and int_ds_param_re.vld-pedido 
                   
                   then do:
                   run pi-gera-erro(INPUT 14,    
                                    INPUT /*"Ordem de Compra " + string(int_ds_it_docto_xml.numero_ordem) + " N∆o cadastrada"*/
                                          "Produto n∆o consta no pedido de compra: " + trim(int_ds_it_docto_xml.it_codigo)).
               end.
               */

               /*
               for first item-mat fields (var-val-re-maior) no-lock where 
                   item-mat.it-codigo = int_ds_it_docto_xml.it_codigo: end.
               if not avail item-mat then do:
                   run pi-gera-erro(INPUT 35,
                                    INPUT "Item materiais n∆o cadastrado: " + int_ds_it_docto_xml.it_codigo).   
               end.
               */
               /* AVB retirado 30/10/2017 - Projeto Procfit
               if int_ds_docto_xml.situacao <> 3 and
                  avail ordem-compra and (
                 (ordem-compra.qt-acum-rec - ordem-compra.qt-acum-dev + int_ds_it_docto_xml.qCom) > ordem-compra.qt-solic or
                  ordem-compra.qt-solic < int_ds_it_docto_xml.qCom or
                  /*ordem-compra.pre-unit-for * 1.02 < fnTrataNuloDec(int_ds_it_docto_xml.vUnCom) or*/
                  ordem-compra.preco-unit * 1.02 < ((fnTrataNuloDec(int_ds_it_docto_xml.vProd) - fnTrataNuloDec(int_ds_it_docto_xml.vDesc)) / int_ds_it_docto_xml.qCom) /*or
                  ordem-compra.valor-descto < fnTrataNuloDec(int_ds_it_docto_xml.vDesc)*/) 
                  then do:
    
                   if int_ds_param_re.vld-pedido then do:
                       run pi-gera-erro(INPUT 15,
                                        INPUT "Qtde/Valor divergente da ordem de compra: " + string(int_ds_it_docto_xml.numero_ordem) + 
                                              " Item: " + int_ds_it_docto_xml.it_codigo + 
                                              " Seq: " + string(int_ds_it_docto_xml.sequencia) + ". Nota fiscal deve ser corrigida ou aprovada pelo depto de compras.").
                   end.
                   else do:
                       for first b-int_ds_docto_xml exclusive-lock where 
                           rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml):
                           assign b-int_ds_docto_xml.situacao = 5
                                  i-situacao:screen-value in FRAME {&FRAME-NAME} = "5".
                           apply "leave":u to i-situacao in FRAME {&FRAME-NAME}.
                           RUN pi-libera-nf-compras.
                       end.
                   end.
               end.
               */
           end.
       end.
       
       assign 
           tot-base-icms-it        = tot-base-icms-it       + fnTrataNuloDec(int_ds_it_docto_xml.vbc_icms)
           tot-base-icms-st-it     = tot-base-icms-st-it    + fnTrataNuloDec(int_ds_it_docto_xml.vbcst   )     
           tot-cofins-it           = tot-cofins-it          + fnTrataNuloDec(int_ds_it_docto_xml.vcofins )
           tot-desconto-it         = tot-desconto-it        + fnTrataNuloDec(int_ds_it_docto_xml.vDesc   )
           tot-icms-it             = tot-icms-it            + fnTrataNuloDec(int_ds_it_docto_xml.vicms   )
           tot-icms-st-it          = tot-icms-st-it         + fnTrataNuloDec(int_ds_it_docto_xml.vicmsst )
           tot-ipi-it              = tot-ipi-it             + fnTrataNuloDec(int_ds_it_docto_xml.vipi    )
           tot-nf-it               = tot-nf-it              + fnTrataNuloDec(int_ds_it_docto_xml.vProd   )
                                                            + fnTrataNuloDec(int_ds_it_docto_xml.vipi    )
                                                            + fnTrataNuloDec(int_ds_it_docto_xml.vicmsst )
                                                            - fnTrataNuloDec(int_ds_it_docto_xml.vDesc   )
                                                            - fnTrataNuloDec(int_ds_it_docto_xml.vicmsdeson)
           tot-tot-pis-it          = tot-tot-pis-it         + fnTrataNuloDec(int_ds_it_docto_xml.vpis    )
           tot-valor-it            = tot-valor-it           + fnTrataNuloDec(int_ds_it_docto_xml.vProd   )
           tot-icms-des            = tot-icms-des           + fnTrataNuloDec(int_ds_it_docto_xml.vicmsdeson).
   end.
   tot-nf-it = tot-nf-it + fnTrataNuloDec(int_ds_docto_xml.valor_frete )
                         + fnTrataNuloDec(int_ds_docto_xml.valor_seguro)
                         + fnTrataNuloDec(int_ds_docto_xml.valor_outras).
   tot-nf-it = round(tot-nf-it,2).
   
   if valid-handle(h-boin176) then delete procedure h-boin176.

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

    RUN pi-valida-usuario-compras.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

    if avail int_ds_docto_xml then do:
        RUN pi-busca-docto-wms.

        /*
        if i-situacao >= 10 and
           i-situacao <> 60 then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Movimentaá‰es bloqueadas!" + "~~" + "A nota fiscal j† est† em conferància no WMS." + 
                                     " Cancelamento/recusa somente ap¢s cancelamento da movimentaá∆o anterior.")).
            return "ADM-ERROR".
        end.
        */
        run utp/ut-msgs.p(input "show",
                          input 701,
                          input ("recusa do recebimento da nota fiscal")).

        if return-value = "yes" then
        do transaction:
            ASSIGN c-motivo-aceite = "".

            RUN intprg\int510d3.w (OUTPUT c-motivo-aceite).

            IF  c-motivo-aceite <> ""
            THEN DO:
                ASSIGN i-seq-log = 1.

                FOR LAST  int_ds_log_recusa_docto_xml NO-LOCK
                    WHERE int_ds_log_recusa_docto_xml.serie        = int_ds_docto_xml.serie
                      AND int_ds_log_recusa_docto_xml.nnf          = int_ds_docto_xml.nnf
                      AND int_ds_log_recusa_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente
                      AND int_ds_log_recusa_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota:

                    ASSIGN i-seq-log = int_ds_log_recusa_docto_xml.sequencia + 1.
                END.

                CREATE int_ds_log_recusa_docto_xml.
                ASSIGN int_ds_log_recusa_docto_xml.serie           = int_ds_docto_xml.serie       
                       int_ds_log_recusa_docto_xml.nnf             = int_ds_docto_xml.nnf        
                       int_ds_log_recusa_docto_xml.cod_emitente    = int_ds_docto_xml.cod_emitente
                       int_ds_log_recusa_docto_xml.tipo_nota       = int_ds_docto_xml.tipo_nota
                       int_ds_log_recusa_docto_xml.sequencia       = i-seq-log
                       int_ds_log_recusa_docto_xml.log_recusa      = YES
                       int_ds_log_recusa_docto_xml.dt_ocorrencia   = TODAY
                       int_ds_log_recusa_docto_xml.hr_ocorrencia   = STRING(TIME,"hh:mm:ss")
                       int_ds_log_recusa_docto_xml.cod_usuario     = c-seg-usuario
                       int_ds_log_recusa_docto_xml.desc_ocorrencia = c-motivo-aceite.

                RELEASE int_ds_log_recusa_docto_xml.
            
                find b-int_ds_docto_xml exclusive-lock where 
                     rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml) no-error no-wait.
                if avail b-int_ds_docto_xml then do:
                    assign b-int_ds_docto_xml.situacao = 9.
                    assign i-situacao = b-int_ds_docto_xml.sit_re.
                    assign i-situacao:screen-value in frame f-Main = string(i-situacao).
                    apply "leave":U to i-situacao in frame f-Main.

                    create  int_ds_docto_wms.
                    assign  int_ds_docto_wms.doc_numero_n = int(int_ds_docto_xml.nNF)
                            int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie
                            int_ds_docto_wms.cnpj_cpf     = int_ds_docto_xml.CNPJ
                            int_ds_docto_wms.doc_origem_n = int_ds_docto_xml.cod_emitente
                            int_ds_docto_wms.situacao     = 90
                            int_ds_docto_wms.ENVIO_STATUS = 1
                            int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today)
                            int_ds_docto_wms.tipo_nota       = int_ds_docto_xml.tipo_nota
                            /*int_ds_docto_wms.ID_SEQUENCIAL   = next-value(seq-int-ds-docto-wms)*/ .
                    for first emitente fields (emitente.natureza) no-lock where 
                        emitente.cgc = int_ds_docto_xml.CNPJ: 
                        assign  int_ds_docto_wms.tipo_fornecedor = if emitente.natureza = 1 then "F" else "J".
                    end.
                    release int_ds_docto_wms.
                    release b-int_ds_docto_xml.
                end.
            END.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cancelar-wms V-table-Win 
PROCEDURE pi-cancelar-wms :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    RUN pi-valida-usuario-compras.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

    if avail int_ds_docto_xml then do:
        RUN pi-busca-docto-wms.
        /*
        if i-sit_re  >= 50 
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input "Movimentaá‰es bloqueadas!" + "~~" + "A nota fiscal j† est† em processo de cancelamento.").
            return "ADM-ERROR".
        end.
        */
        if i-sit_re < 10 
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input "Reenvio bloqueado!" + "~~" + "A nota fiscal precisa ser enviada uma vez primeiro.").
            return "ADM-ERROR".
        end.

        if i-sit_re  >= 30 and i-sit_re < 55 and
           not can-find (first usuar_grp_usuar no-lock where 
               usuar_grp_usuar.cod_usuario = c-seg-usuario and
               (usuar_grp_usuar.cod_grp_usuar = "TAX"))
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input "Reenvio bloqueado!" + "~~" + "A nota fiscal j† est† conferida.").
            return "ADM-ERROR".
        end.
        run utp/ut-msgs.p(input "show",
                          input 701,
                          input ("reenvio da nota fiscal para o WMS")).

        if return-value = "yes" then do:
            create int_ds_docto_wms.
            assign int_ds_docto_wms.doc_numero_n    = int(int_ds_docto_xml.nNF) 
                   int_ds_docto_wms.doc_serie_s     = int_ds_docto_xml.serie 
                   int_ds_docto_wms.cnpj_cpf        = int_ds_docto_xml.CNPJ
                   int_ds_docto_wms.situacao        = 55
                   int_ds_docto_wms.ENVIO_STATUS    = 1
                   int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today)
                   int_ds_docto_wms.tipo_nota       = int_ds_docto_xml.tipo_nota
                   /*int_ds_docto_wms.ID_SEQUENCIAL   = NEXT-VALUE(seq-int-ds-docto-wms)*/ .
            for first emitente no-lock where emitente.cgc = int_ds_docto_xml.CNPJ: 
                assign  int_ds_docto_wms.doc_origem_n     = emitente.cod-emitente.
                        int_ds_docto_wms.tipo_fornecedor  = if emitente.natureza = 1 then "F" else "J".
            end.

            find b-int_ds_docto_xml exclusive-lock
                where rowid(b-int_ds_docto_xml) = rowid(int_ds_docto_xml) no-error no-wait.
            if avail b-int_ds_docto_xml then do:
                assign b-int_ds_docto_xml.sit_re = int_ds_docto_wms.situacao.
                assign i-sit_re = b-int_ds_docto_xml.sit_re.
                assign i-sit_re:screen-value in frame f-Main = string(i-sit_re).
                apply "leave":U to i-sit_re in frame f-Main.
                release b-int_ds_docto_xml.
            end.
            release int_ds_docto_wms.
        end. /* return-value */
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-copia-perc-red-icmst V-table-Win 
PROCEDURE pi-copia-perc-red-icmst :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    
    RUN pi-valida-usuario-compras.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

    if avail int_ds_docto_xml then do:
        RUN pi-verifica-situacao.
        if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.
    end.

    if avail int_ds_docto_xml  and
       int_ds_docto_xml.situacao <> 3 then do:

        if input FRAME {&FRAME-NAME} int_ds_docto_xml.perc_red_icms <= 0 or
           input FRAME {&FRAME-NAME} int_ds_docto_xml.perc_red_icms = ? then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Percentual Redutor inv†lido!" + "~~" + "O percentual redutor de ICMS para rateio deve ser maior que zero."))).
            return "ADM-ERROR".
        end.

        RUN pi-verifica-situacao.
        if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.
        run utp/ut-msgs.p(input "show",
                          input 701,
                          input ("c¢pia do percentual de recuá∆o de ICMS da capa da nota fiscal para os itens")).

        if return-value = "yes" then do:
            for each int_ds_it_docto_xml exclusive-lock where
                int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota       and 
                int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente    and 
                int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF             and 
                int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie
                query-tuning(no-lookahead):
                assign int_ds_it_docto_xml.predBc = input FRAME {&FRAME-NAME} int_ds_docto_xml.perc_red_icms.
                release int_ds_it_docto_xml.
            end.
            RUN new-state("RefreshData").
        end.    
    end.
    
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

    delete from int_ds_doc_erro where
        int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie        and
        int_ds_doc_erro.nro_docto    = int_ds_docto_xml.NNF          and 
        int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota    and
        int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ.

    /*                                                             
    for each int_ds_doc_erro exclusive-lock use-index idx_docto_xml where
        int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie        and
        int_ds_doc_erro.nro_docto    = int_ds_docto_xml.NNF          and 
        int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota    and
        int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ
        query-tuning(no-lookahead):
        delete int_ds_doc_erro.
    end.
    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-erro V-table-Win 
PROCEDURE pi-gera-erro :
DEF INPUT PARAM p-cod-erro     LIKE int_ds_doc_erro.cod_erro.
DEF INPUT PARAM p-desc-erro    LIKE int_ds_doc_erro.descricao.


     if int_ds_docto_xml.situacao <> 3 and
        int_ds_docto_xml.situacao <> 7 /*and
        not can-find (first int_ds_docto_xml_compras no-lock of int_ds_docto_xml) */ and
        int_ds_docto_xml.sit_re <> 3 then do:
         FOR  FIRST int_ds_doc_erro NO-LOCK WHERE
                    int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie       AND 
                    int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF         AND 
                    int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota   AND
                    int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ        AND 
                    int_ds_doc_erro.descricao    = p-desc-erro 
             query-tuning(no-lookahead) : END.

         IF NOT AVAIL int_ds_doc_erro 
         THEN DO:
            CREATE int_ds_doc_erro.
            ASSIGN int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie       
                   int_ds_doc_erro.cod_emitente = int_ds_docto_xml.cod_emitente
                   int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ 
                   int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF   
                   int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota  
                   int_ds_doc_erro.tipo_erro    = if p-cod-erro = 35 then "Aviso" else "ErroXML"   
                   int_ds_doc_erro.cod_erro     = p-cod-erro
                   int_ds_doc_erro.descricao    = IF p-desc-erro = ? THEN "" ELSE p-desc-erro.

            IF AVAIL int_ds_it_docto_xml THEN 
               ASSIGN int_ds_doc_erro.sequencia = int_ds_it_docto_xml.sequencia.

         END.

         find b-int_ds_docto_xml exclusive-lock where 
             rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml) no-error no-wait.
         if avail b-int_ds_docto_xml then do:

             if (p-cod-erro = 15 or  /**/
                 p-cod-erro = 14 or  /**/
                 p-cod-erro = 20 or  /**/ 
                 p-cod-erro = 21 or  /**/ 
                 p-cod-erro = 22 or  /**/ 
                 p-cod-erro = 4) and /**/ 
                 not can-find(first int_ds_doc_erro no-lock where 
                              int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie         and
                              int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF           and
                              int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota     and
                              int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ          and
                              int_ds_doc_erro.tipo_erro    = "ErroXML"                      and
                              int_ds_doc_erro.cod_erro    <> 15 and
                              int_ds_doc_erro.cod_erro    <> 20 and
                              int_ds_doc_erro.cod_erro    <> 14 and
                              int_ds_doc_erro.cod_erro    <> 21 and
                              int_ds_doc_erro.cod_erro    <> 22 and
                              int_ds_doc_erro.cod_erro    <> 4) then do:
                     assign b-int_ds_docto_xml.situacao = 5
                            i-situacao:screen-value in FRAME {&FRAME-NAME} = "5".
                     assign int_ds_doc_erro.tipo_erro    = "Compras".
             end.
             else do:
                  assign b-int_ds_docto_xml.situacao = 1
                         i-situacao:screen-value in FRAME {&FRAME-NAME} = "1".
             end.
             apply "leave":u to i-situacao in FRAME {&FRAME-NAME}.
         end.
     end.
     else do:

         IF p-cod-erro = 38 THEN DO:   /* erro de item obsoleto */
         
             FOR  FIRST int_ds_doc_erro NO-LOCK WHERE
                     int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie      AND 
                     int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF        AND 
                     int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota  AND
                     int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ       AND 
                     int_ds_doc_erro.descricao    = p-desc-erro 
             query-tuning(no-lookahead) : END.
    
             IF NOT AVAIL int_ds_doc_erro 
             THEN DO:
                CREATE int_ds_doc_erro.
                ASSIGN int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie       
                       int_ds_doc_erro.cod_emitente = int_ds_docto_xml.cod_emitente
                       int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ 
                       int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF   
                       int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota  
                       int_ds_doc_erro.tipo_erro    = if p-cod-erro = 35 then "Aviso" else "ErroXML"   
                       int_ds_doc_erro.cod_erro     = p-cod-erro
                       int_ds_doc_erro.descricao    = IF p-desc-erro = ? THEN "" ELSE p-desc-erro.
    
                IF AVAIL int_ds_it_docto_xml THEN 
                   ASSIGN int_ds_doc_erro.sequencia = int_ds_it_docto_xml.sequencia.
    
             END.

         END.
     END.


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
    define input parameter h_p-navega as handle.

    RUN pi-valida-usuario-compras.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

    RUN pi-verifica-estorno.
    if RETURN-VALUE = "ADM-ERROR":U then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Atualizaá∆o inv†lida!" + "~~" + "Nota fiscail de estorno j† est∆o no RE1001.")).
        return "ADM-ERROR".
    end.

    if avail int_ds_docto_xml then do:
        RUN pi-avaliar-erros.

        if  int_ds_docto_xml.situacao = 5 or /* falta aprovar compras */
            int_ds_docto_xml.situacao = 3 /* j† importada */ or
            can-find(first int_ds_doc_erro where
            int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie        and 
            int_ds_doc_erro.nro_docto    = int_ds_docto_xml.NNF          and  
            int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota    and
            int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ         and     
            int_ds_doc_erro.tipo_erro    <> "Aviso")
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Atualizaá∆o inv†lida!" + "~~" + "A nota fiscal n∆o est† dispon°vel para importaá∆o no Totvs. Verifique a situaá∆o da nota e os erros apontados.")).
            return "ADM-ERROR".
        end.
        if  i-sit_re <> 40 /* movimentada WMS */ and
            i-sit_re <> 3 /* recebimento antigo */ then do:
    
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Atualizaá∆o inv†lida!" + "~~" + "A nota fiscal ainda n∆o est† dispon°vel para importaá∆o no Totvs. Verifique a fase de recebimento no WMS.")).
            return "ADM-ERROR".
    
        end.

        run utp/ut-msgs.p(input "show",
                          input 701,
                          input ("atualizaá∆o da nota fiscal no RE1001?")).

        if return-value = "yes" then do:
            create tt-param.
            assign tt-param.usuario          = c-seg-usuario
                   tt-param.destino          = 3
                   tt-param.data-exec        = today
                   tt-param.hora-exec        = time
                   tt-param.cod-emitente-ini = int_ds_docto_xml.cod_emitente
                   tt-param.cod-emitente-fim = int_ds_docto_xml.cod_emitente
                   tt-param.cod-estabel-fim  = int_ds_docto_xml.cod_estab
                   tt-param.cod-estabel-ini  = int_ds_docto_xml.cod_estab
                   tt-param.dt-emis-nota-fim = int_ds_docto_xml.dEmi
                   tt-param.dt-emis-nota-ini = int_ds_docto_xml.dEmi
                   tt-param.nro-docto-fim    = trim(int_ds_docto_xml.nNF)
                   tt-param.nro-docto-ini    = trim(int_ds_docto_xml.nNF)
                   tt-param.serie-docto-fim  = trim(int_ds_docto_xml.serie)
                   tt-param.serie-docto-ini  = trim(int_ds_docto_xml.serie).
        
            assign tt-param.arquivo = session:temp-directory + "INT510" + ".tmp":U.
            
            /* Executar do programa RP.P que ir† criar o relat¢rio */
            SESSION:SET-WAIT-STATE("GENERAL":U).
        
            raw-transfer tt-param to raw-param.
            if int_ds_docto_xml.tipo_nota <> 3  then do:
                os-command silent del value(session:temp-directory + "int072-re1005.txt") no-error.

                run intprg/int072rp.p (input raw-param,
                                       input table tt-raw-digita).
                if search ("int072-re1005.txt") <> ? then
                    RUN winexec (INPUT "Notepad.exe" + CHR(32) + session:temp-directory + "int072-re1005.txt", input 1).
            end.
            else do:
                os-command silent del value(session:temp-directory + "int052-re1005.txt") no-error.
                run intprg/int052rp.p (input raw-param,
                                       input table tt-raw-digita).
                if search ("int052-re1005.txt") <> ? then
                    RUN winexec (INPUT "Notepad.exe" + CHR(32) + session:temp-directory + "int052-re1005.txt", input 1).
            end.

            SESSION:SET-WAIT-STATE("":U).
            
            {report/rptrm.i}

            find current int_ds_docto_xml no-lock no-error.
            if available int_ds_docto_xml and int_ds_docto_xml.situacao = 3 then
                run notify in h_p-navega ('GET-NEXT':U).


        end. /* return-value */
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
    if avail int_ds_docto_xml 
    then
        RUN intprg\int510d4.w (INPUT ROWID(int_ds_docto_xml)).
    ELSE
        RUN intprg\int510d4.w (INPUT ?).

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
    define buffer b-int_ds_it_docto_xml for int_ds_it_docto_xml.


    if int_ds_docto_xml.situacao <> 3 and
       int_ds_docto_xml.situacao <> 9 and
       int_ds_docto_xml.sit_re <> 3 and
       int_ds_docto_xml.cod_emitente <> ? and  
       int_ds_docto_xml.cod_emitente <> 0 then do:
        for first int_ds_docto_xml_compras exclusive of int_ds_docto_xml: end.
        if not avail int_ds_docto_xml_compras then do:
            create  int_ds_docto_xml_compras.
            assign  int_ds_docto_xml_compras.serie          = int_ds_docto_xml.serie
                    int_ds_docto_xml_compras.nNF            = int_ds_docto_xml.nNF
                    int_ds_docto_xml_compras.cod_emitente   = int_ds_docto_xml.cod_emitente
                    int_ds_docto_xml_compras.tipo_nota      = int_ds_docto_xml.tipo_nota.
        end.
        assign  int_ds_docto_xml_compras.data_aprovacao = today
                int_ds_docto_xml_compras.hora_aprovacao = time
                int_ds_docto_xml_compras.usuario_aprovacao = c-seg-usuario.

        for each int_ds_docto_xml_log_compras EXCLUSIVE of int_ds_docto_xml_compras
            query-tuning(no-lookahead):
            delete int_ds_docto_xml_log_compras.
        end.
        for each int_ds_doc_erro no-lock where
            int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie        and 
            int_ds_doc_erro.nro_docto    = int_ds_docto_xml.NNF          and  
            int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota    and     
            int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ         
            query-tuning(no-lookahead):
            if not can-find(int_ds_docto_xml_log_compras no-lock where 
                int_ds_docto_xml_log_compras.serie          = int_ds_docto_xml_compras.serie        and
                int_ds_docto_xml_log_compras.nNF            = int_ds_docto_xml_compras.nNF          and
                int_ds_docto_xml_log_compras.cod_emitente   = int_ds_docto_xml_compras.cod_emitente and
                int_ds_docto_xml_log_compras.tipo_nota      = int_ds_docto_xml_compras.tipo_nota    and
                int_ds_docto_xml_log_compras.cod_erro       = int_ds_doc_erro.cod_erro)
            then do:
                create  int_ds_docto_xml_log_compras.
                assign  int_ds_docto_xml_log_compras.serie          = int_ds_docto_xml_compras.serie       
                        int_ds_docto_xml_log_compras.nNF            = int_ds_docto_xml_compras.nNF         
                        int_ds_docto_xml_log_compras.cod_emitente   = int_ds_docto_xml_compras.cod_emitente
                        int_ds_docto_xml_log_compras.tipo_nota      = int_ds_docto_xml_compras.tipo_nota   
                        int_ds_docto_xml_log_compras.cod_erro       = int_ds_doc_erro.cod_erro.
                assign  int_ds_docto_xml_log_compras.descricao      = int_ds_doc_erro.descricao
                        int_ds_docto_xml_log_compras.tipo_erro      = int_ds_doc_erro.tipo_erro.
            end.
        end.

        /* armazenar valores */
        for each b-int_ds_it_docto_xml 
            fields (qCom qCom_Forn vProd numero_ordem)
            no-lock where
            b-int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie and
            b-int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF and
            b-int_ds_it_docto_xml.CNPJ         = int_ds_docto_xml.CNPJ and
            b-int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota
            query-tuning(no-lookahead):
    
            assign de-qtde-entregue  = de-qtde-entregue + fnTrataNuloDec(b-int_ds_it_docto_xml.qCom).
            assign de-valor-entregue = de-valor-entregue + fnTrataNuloDec(b-int_ds_it_docto_xml.vProd / b-int_ds_it_docto_xml.qCom_Forn).
    
            for each ordem-compra no-lock where 
                ordem-compra.numero-ordem = b-int_ds_it_docto_xml.numero_ordem
                query-tuning(no-lookahead):
                
                assign de-valor-original = de-valor-original + ordem-compra.pre-unit-for.
                assign de-qtde-original  = de-qtde-original + ordem-compra.qt-solic.
    
            end.
        end.
    
        assign  int_ds_docto_xml_compras.valor_original = de-valor-original
                int_ds_docto_xml_compras.qtde_original  = de-qtde-original.
        assign  int_ds_docto_xml_compras.valor_etregue  = de-valor-entregue
                int_ds_docto_xml_compras.qtde_entregue  = de-qtde-entregue.
        for each b-int_ds_docto_xml exclusive-lock where 
            rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml)
            query-tuning(no-lookahead): 
            assign b-int_ds_docto_xml.situacao = 7.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-liberar-wms V-table-Win 
PROCEDURE pi-liberar-wms :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter p-situacao as integer no-undo.

    RUN pi-valida-usuario-compras.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

    if avail int_ds_docto_xml then do:
        RUN pi-verifica-situacao.
        if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

        RUN pi-busca-docto-wms.
        if p-situacao = 10 and 
           i-sit_re  >= 10 and
           i-sit_re  <= 20
        then do:
            /*
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Movimentaá‰es bloqueadas!" + "~~" + "A nota fiscal j† est† em conferància no WMS." + 
                                     " Reenvio de conferància somente ap¢s cancelamento da movimentaá∆o anterior.")).
                                     */
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Movimentaá‰es bloqueadas!" + "~~" + "A nota fiscal j† est† em agendamento no WMS." + 
                                     " Utilize o reenvio de valores de tributos.")).

            return "ADM-ERROR".
        end.
        if p-situacao = 10 and 
           i-sit_re  >= 20 and
           i-sit_re  <= 26 and
           i-sit_re  <> 60 
        then do:
            /*
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Movimentaá‰es bloqueadas!" + "~~" + "A nota fiscal j† est† conferida no WMS." + 
                                     " Reenvio de conferància somente ap¢s cancelamento da movimentaá∆o anterior.")).
                                     */
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Movimentaá‰es bloqueadas!" + "~~" + "A nota fiscal j† est† em agendamento no WMS." + 
                                     " Utilize o reenvio de valores de tributos.")).
            return "ADM-ERROR".
        end.

        if  p-situacao = 30 and /* conferida wms Oblak */
            i-sit_re   = 30
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Movimentaá‰es bloqueadas!" + "~~" + "A movimentaá∆o da nota fiscal j† foi enviada p/o PRS. Movimentaá∆o n∆o ser† permitida.")).
            return "ADM-ERROR".
        end.

        if  p-situacao = 30 and /* conferida wms Oblak */
            i-sit_re   = 40
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Movimentaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi movimentada no PRS. Movimentaá∆o n∆o ser† permitida.")).
            return "ADM-ERROR".
        end.

        if  p-situacao = 30 and /* conferida wms */
            i-sit_re  <> 25 and
            i-sit_re  <> 26 
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Movimentaá‰es bloqueadas!" + "~~" + "A nota fiscal ainda n∆o foi conferida no WMS. Movimentaá∆o n∆o ser† permitida.")).
            return "ADM-ERROR".
        end.

        if  int_ds_docto_xml.situacao = 5 
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Movimentaá‰es bloqueadas!" + "~~" + "A nota fiscal est† aguardando aprovaá∆o de compras. Conferància e movimentaá∆o n∆o ser∆o permitidas.")).
            return "ADM-ERROR".
        end.
        
        if i-sit_re <= /*26*/ 10 or
           i-sit_re  = 60 then do:

            RUN pi-avaliar-erros.
            for first int_ds_doc_erro no-lock where 
                int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie        and 
                int_ds_doc_erro.nro_docto    = int_ds_docto_xml.NNF          and  
                int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota    and
                int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ         and     
                int_ds_doc_erro.tipo_erro   <> "Aviso":  
                run utp/ut-msgs.p(input "show",
                                  input 17006,
                                  input ("Nota fiscal com ERROS!" + "~~" + "A nota fiscal possui erros. ê necess†rio acert†-los primeiro.")).
                return "ADM-ERROR".                
            end.

            run utp/ut-msgs.p(input "show",
                              input 701,
                              input ("liberaá∆o da nota fiscal para " +
                                     if p-situacao = 10 then /*'conferància no WMS' */ 'agendamento no WMS'
                                     else 'movimentaá∆o no PRS')).

            if return-value = "yes" then
            do transaction:
                /*
                for first int_ds_docto_wms where 
                    int_ds_docto_wms.doc_numero_n = int(int_ds_docto_xml.nNF) and
                    int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie and
                    int_ds_docto_wms.cnpj_cpf     = int_ds_docto_xml.CNPJ: end.
                if not avail int_ds_docto_wms then*/ do:
                    create int_ds_docto_wms.
                    assign int_ds_docto_wms.doc_numero_n  = int(int_ds_docto_xml.nNF) 
                           int_ds_docto_wms.doc_serie_s   = trim(int_ds_docto_xml.serie)
                           int_ds_docto_wms.cnpj_cpf      = trim(int_ds_docto_xml.CNPJ)
                           int_ds_docto_wms.tipo_nota     = int_ds_docto_xml.tipo_nota
                           /*int_ds_docto_wms.ID_SEQUENCIAL = next-value(seq-int-ds-docto-wms)*/  .

                end.
                for first emitente no-lock where emitente.cgc = int_ds_docto_xml.CNPJ: end.
                assign  int_ds_docto_wms.tipo_fornecedor = if emitente.natureza = 1 then "F" else "J"
                        int_ds_docto_wms.doc_origem_n    = emitente.cod-emitente.
                assign  int_ds_docto_wms.situacao        = ?.
                assign  int_ds_docto_wms.situacao        = p-situacao.
                for first b-int_ds_docto_xml exclusive-lock
                    where rowid(b-int_ds_docto_xml) = rowid(int_ds_docto_xml):
                    assign b-int_ds_docto_xml.sit_re = p-situacao.
                    assign i-sit_re = p-situacao.
                    assign i-sit_re:screen-value in frame f-Main = string(i-sit_re).
                end.
                assign int_ds_docto_wms.situacao        = 10
                       int_ds_docto_wms.ENVIO_STATUS    = 1
                       int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today).

                release int_ds_docto_wms.
                apply "leave":U to i-sit_re in frame f-Main.
                run utp/ut-msgs.p(input "show",
                                  input 17006,
                                  input ("Nota fiscal Liberada!" + "~~" + "A nota fiscal foi enviada para o " + 
                                         if p-situacao = 10 then 'WMS' else 'PRS')).
            end.

        end.
        else do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi conferida ou movimentada. Alteraá‰es n∆o ser∆o permitidas.")).
            return "ADM-ERROR".
        end.
    end.
    return "OK":U.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-nat-operacao V-table-Win 
PROCEDURE pi-nat-operacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable c-nat-operacao as char no-undo.
    define variable de-aliq-pis as decimal decimals 2.
    define variable de-aliq-cofins as decimal decimals 2.
    define variable de-base-pis as decimal decimals 2.
    define variable de-base-cofins as decimal decimals 2.
    define variable de-valor-pis as decimal decimals 2.
    define variable de-valor-cofins as decimal decimals 2.
    define variable i-pis as integer.
    define variable i-cofins as integer.

    assign i-pis = 2.
    assign i-cofins = 2.
    assign de-base-pis = 0.
    assign de-base-cofins = 0.
    assign de-valor-pis = 0.
    assign de-valor-cofins = 0.
    assign de-aliq-pis = 0.
    assign de-aliq-cofins = 0.

   if avail int_ds_docto_xml and
      int_ds_docto_xml.situacao <> 3 then
   for each int_ds_it_docto_xml no-lock where
       int_ds_it_docto_xml.tipo_nota  = int_ds_docto_xml.tipo_nota and 
       int_ds_it_docto_xml.CNPJ       = int_ds_docto_xml.CNPJ      and 
       int_ds_it_docto_xml.nNF        = int_ds_docto_xml.nNF       and 
       int_ds_it_docto_xml.serie      = int_ds_docto_xml.serie
       query-tuning(no-lookahead):

       for first ITEM no-lock where ITEM.it-codigo = int_ds_it_docto_xml.it_codigo: end.

       if not can-find(first cfop-natur no-lock where 
           cfop-natur.cod-cfop = trim(string(int_ds_it_docto_xml.cfop,"9999"))) 
       then do:
           run pi-gera-erro(INPUT 31,
                            INPUT "CFOP " + trim(string(int_ds_it_docto_xml.cfop,"9999")) + " do item seq: " + trim(string(int_ds_it_docto_xml.sequencia,">>>>>>9")) + " n∆o cadastrada!"). 
           
           find b-int_ds_it_docto_xml exclusive-lock where 
               rowid(b-int_ds_it_docto_xml) = rowid(int_ds_it_docto_xml) no-error no-wait.
           if avail b-int_ds_it_docto_xml then do:
               assign b-int_ds_it_docto_xml.situacao = 1 /* Pendente */.
               release b-int_ds_it_docto_xml.
           end.
       end.

       if trim(string(int_ds_it_docto_xml.cfop,"9999")) begins "1" or
          trim(string(int_ds_it_docto_xml.cfop,"9999")) begins "2" or
          trim(string(int_ds_it_docto_xml.cfop,"9999")) begins "3" then do:
           run pi-gera-erro(INPUT 32,
                            INPUT "CFOP " + trim(string(int_ds_it_docto_xml.cfop,"9999")) + " do item seq: " + trim(string(int_ds_it_docto_xml.sequencia,">>>>>>9")) + " deve ser a de sa°da do fornecedor!"). 
           find b-int_ds_it_docto_xml exclusive-lock where 
               rowid(b-int_ds_it_docto_xml) = rowid(int_ds_it_docto_xml) no-error no-wait.
           if avail b-int_ds_it_docto_xml then do:
               assign b-int_ds_it_docto_xml.situacao = 1 /* Pendente */.
               release b-int_ds_it_docto_xml.
           end.
       end.

        /* tratar natur-oper */
        c-nat-operacao = "".
        IF  int_ds_it_docto_xml.nat_operacao <> "" AND
            CAN-FIND (natur-oper NO-LOCK WHERE natur-oper.nat-operacao = int_ds_it_docto_xml.nat_operacao) THEN
            ASSIGN c-nat-operacao = int_ds_it_docto_xml.nat_operacao.
        ELSE
            RUN intprg/int013a.p( input int_ds_it_docto_xml.cfop,
                                  input int_ds_it_docto_xml.cst_icms,
                                  input /*int_ds_it_docto_xml.nep-cstb-ipi-n*/ int(item.fm-codigo),
                                  input int_ds_docto_xml.cod_estab,
                                  input int_ds_docto_xml.cod_emitente,
                                  input int_ds_docto_xml.dEmi,
                                  output c-nat-operacao).
        if c-nat-operacao = "" then do:
            run pi-gera-erro(INPUT 18,    
                             INPUT "N∆o encontrada natureza de operaá∆o para entrada. " + 
                                   "CFOP Nota: " + string(int_ds_it_docto_xml.cfop) + 
                                   " CSTB ICMS: " + string(int_ds_it_docto_xml.cst_icms) + 
                                   " Fam°lia: " + item.fm-codigo + " Estab.: " + int_ds_docto_xml.cod_estab). 
        end.
        for first natur-oper no-lock where
                  natur-oper.nat-operacao = c-nat-operacao
            query-tuning(no-lookahead) : end.

        if not avail natur-oper 
        then do:
            run pi-gera-erro(INPUT 8,
                             INPUT "Natureza de Operaá∆o " + int_ds_it_docto_xml.nat_operacao + " do item seq: " + trim(string(int_ds_it_docto_xml.sequencia,">>>>>>9"))
                             + " n∆o cadastrada!"). 
        end. 

        /* setando natureza principal do documento para a mais baixa evitendo erro de api quando ST na natureza principal 
           come itens sem st na nota */
        if avail natur-oper then do:

            if c-nat-operacao <> "" and int_ds_docto_xml.nat_operacao = "" 
               &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                then do:
               &else
                or NOT natur-oper.log-contrib-st-antec then do:
            &endif
            
                find b-int_ds_docto_xml exclusive-lock
                    where rowid(b-int_ds_docto_xml) = rowid(int_ds_docto_xml) no-error no-wait.
                if avail b-int_ds_docto_xml then do:
                    assign int_ds_docto_xml.cfop = int(natur-oper.cod-cfop)
                           int_ds_docto_xml.cfop:screen-value in FRAME {&FRAME-NAME} = natur-oper.cod-cfop.
                    assign b-int_ds_docto_xml.nat_operacao = c-nat-operacao.
                    assign int_ds_docto_xml.nat_operacao:screen-value in FRAME {&FRAME-NAME} = b-int_ds_docto_xml.nat_operacao.
                    apply "leave":u to int_ds_docto_xml.nat_operacao in FRAME {&FRAME-NAME} .
                    release b-int_ds_docto_xml.
                end.
            end.

            if int_ds_it_docto_xml.nat_operacao <> c-nat-operacao and c-nat-operacao <> "" then do:
                find b-int_ds_it_docto_xml exclusive-lock where 
                    rowid(b-int_ds_it_docto_xml) = rowid(int_ds_it_docto_xml) no-error no-wait.
                if avail b-int_ds_it_docto_xml then do:
                    assign b-int_ds_it_docto_xml.nat_operacao = c-nat-operacao.
                    release b-int_ds_it_docto_xml.
                end.
            end.
            if avail item then do: 
                assign i-pis     = int(substr(natur-oper.char-1,86,1)).
                if i-pis = 1 /* tributado */ then do:
                    de-aliq-pis       = if substr(item.char-2,52,1) = "1" 
                                        /* Al°quota do Item */
                                        then dec(substr(item.char-2,31,5))
                                        /* Al°quota da natureza */
                                        else natur-oper.perc-pis[1].
                    if de-aliq-pis <> 0 then do:
                        de-base-pis           = fnTrataNuloDec(int_ds_it_docto_xml.vProd)
                                              - fnTrataNuloDec(int_ds_it_docto_xml.vDesc)
                                              + fnTrataNuloDec(int_ds_it_docto_xml.vOutro).
                        de-valor-pis          = de-base-pis * de-aliq-pis / 100.
                    end.
                    else do:
                        i-pis = 2.
                        de-base-pis    = 0.
                        de-valor-pis   = 0.
                    end.
                end.
                assign i-cofins  = int(substr(natur-oper.char-1,87,1)).
                if i-cofins = 1 /* tributado */ then do:
                    de-aliq-cofins    = if substr(item.char-2,53,1) = "1"
                                          then dec(substr(item.char-2,36,5))
                                          else natur-oper.per-fin-soc[1].
                    if de-aliq-cofins <> 0 then do:
                        de-base-cofins        = fnTrataNuloDec(int_ds_it_docto_xml.vProd)
                                              - fnTrataNuloDec(int_ds_it_docto_xml.vDesc)
                                              + fnTrataNuloDec(int_ds_it_docto_xml.vOutro).                                                                        
                        de-valor-cofins       = de-aliq-cofins * de-base-cofins / 100.
                    end.
                    else do:
                        de-base-cofins        = 0.
                        de-valor-cofins       = 0.
                        i-cofins     = 2.
                    end.
                end.

                if  fnTrataNuloDec(int_ds_it_docto_xml.vbc_pis   ) <> de-base-pis    or
                    fnTrataNuloDec(int_ds_it_docto_xml.vpis      ) <> de-valor-pis   or
                    fnTrataNuloDec(int_ds_it_docto_xml.cst_pis   ) <> i-pis          or
                    fnTrataNuloDec(int_ds_it_docto_xml.ppis      ) <> de-aliq-pis    or
                    fnTrataNuloDec(int_ds_it_docto_xml.pcofins   ) <> de-aliq-cofins or
                    fnTrataNuloDec(int_ds_it_docto_xml.vbc_cofins) <> de-base-cofins or
                    fnTrataNuloDec(int_ds_it_docto_xml.vcofins   ) <> de-valor-cofins  or
                    fnTrataNuloDec(int_ds_it_docto_xml.cst_cofins) <> i-cofins then do:

                    find b-int_ds_it_docto_xml exclusive-lock where 
                        rowid(b-int_ds_it_docto_xml) = rowid(int_ds_it_docto_xml) no-error no-wait.
                    if avail b-int_ds_it_docto_xml then do:
                        if de-aliq-pis <> 0 and i-pis <> 2 then do:
                            assign b-int_ds_it_docto_xml.ppis    = de-aliq-pis
                                   b-int_ds_it_docto_xml.vbc_pis = de-base-pis.
                            assign b-int_ds_it_docto_xml.vpis    = de-valor-pis
                                   b-int_ds_it_docto_xml.cst_pis = i-pis.
                        end.
                        else do:
                            assign b-int_ds_it_docto_xml.vpis    = 0
                                   b-int_ds_it_docto_xml.ppis    = 0
                                   b-int_ds_it_docto_xml.vbc_pis = 0
                                   b-int_ds_it_docto_xml.cst_pis = 2.
                        end.

                        if de-aliq-cofins <> 0 and i-cofins <> 2 then do:
                            assign b-int_ds_it_docto_xml.pcofins    = de-aliq-cofins
                                   b-int_ds_it_docto_xml.vbc_cofins = de-base-cofins.
                            assign b-int_ds_it_docto_xml.vcofins    = de-valor-cofins
                                   b-int_ds_it_docto_xml.cst_cofins = 1.
                        end.
                        else do:
                            assign b-int_ds_it_docto_xml.pcofins    = 0
                                   b-int_ds_it_docto_xml.vbc_cofins = 0
                                   b-int_ds_it_docto_xml.vcofins    = 0
                                   b-int_ds_it_docto_xml.cst_cofins = 2.
                        end.
                        release b-int_ds_it_docto_xml.
                    end.


                end.
            end. /* avail item */
        end. /* avail natur-oper */
        if not can-find(first classif-fisc no-lock where 
            classif-fisc.class-fiscal = trim(string(int_ds_it_docto_xml.ncm,"99999999"))) then do:
            run pi-gera-erro(INPUT 27,
                             INPUT "NCM " + trim(string(int_ds_it_docto_xml.ncm,"99999999")) + " do item seq: " + trim(string(int_ds_it_docto_xml.sequencia,">>>>>>9")) + " n∆o cadastrada!"). 
        end.
        RUN new-state("RefreshData").
    end. /* avail int_ds_it_docto_xml */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-ordem-compra V-table-Win 
PROCEDURE pi-ordem-compra :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    if avail int_ds_docto_xml and
       int_ds_docto_xml.situacao <> 3 then do:
       for each int_ds_it_docto_xml no-lock where
           int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF          and 
           int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie        and 
           int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente and 
           int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota    
           query-tuning(no-lookahead):
           for first ordem-compra no-lock where 
               ordem-compra.numero-ordem = int_ds_it_docto_xml.numero_ordem and
               ordem-compra.it-codigo  = int_ds_it_docto_xml.it_codigo and
               ordem-compra.num-pedido <> 0 query-tuning(no-lookahead): end.
           if not avail ordem-compra then do:
               for first ordem-compra no-lock where 
                   ordem-compra.num-pedido = int_ds_docto_xml.num_pedido and
                   ordem-compra.it-codigo  = int_ds_it_docto_xml.it_codigo and
                   ordem-compra.num-pedido <> 0 query-tuning(no-lookahead): 
                   find b-int_ds_it_docto_xml exclusive-lock where 
                       rowid(b-int_ds_it_docto_xml) = rowid(int_ds_it_docto_xml) no-error no-wait.
                   if avail b-int_ds_it_docto_xml then do:
                       assign b-int_ds_it_docto_xml.numero_ordem = ordem-compra.numero-ordem.
                       release b-int_ds_it_docto_xml.
                   end.
               end.
           end.
        end.
        /*RUN new-state("RefreshData").*/
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-rateia-despesas V-table-Win 
PROCEDURE pi-rateia-despesas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    RUN pi-verifica-situacao.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

    if  avail int_ds_docto_xml then do:
        
        if int_ds_docto_xml.valor_outras:input-value in FRAME {&FRAME-NAME} <= 0 then  do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Valor Despesas inv†lido!" + "~~" + "O valor das despesas para rateio deve ser maior que zero."))).
            return "ADM-ERROR".
        end.
        if  fnTrataNuloDec(int_ds_docto_xml.valor_mercad) <= 0 then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Valor Mercadorias inv†lido!" + "~~" + "O valor das mercadorias da nota para c†lculo do rateio deve ser maior que zero."))).
            return "ADM-ERROR".
        end.
        if tot-valor-it <> fnTrataNuloDec(int_ds_docto_xml.valor_mercad) then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Valor Itens inv†lido!" + "~~" + "O valor das mercadorias da nota deve ser igiual ao total dos itens para c†lculo do rateio."))).
            return "ADM-ERROR".
        end.
        for each int_ds_it_docto_xml exclusive-lock where
            int_ds_it_docto_xml.tipo_nota  = int_ds_docto_xml.tipo_nota and 
            int_ds_it_docto_xml.CNPJ       = int_ds_docto_xml.CNPJ      and 
            int_ds_it_docto_xml.nNF        = int_ds_docto_xml.nNF       and 
            int_ds_it_docto_xml.serie      = int_ds_docto_xml.serie
            query-tuning(no-lookahead):
            assign int_ds_it_docto_xml.vOutro = int_ds_docto_xml.valor_outras * 
                (fnTrataNuloDec(int_ds_it_docto_xml.vProd) / fnTrataNuloDec(int_ds_docto_xml.valor_mercad)).
        end.
        RUN new-state("RefreshData"). 
    end.

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
define input parameter p_int510-browser-itens as handle.
assign h_int510-browser-itens = p_int510-browser-itens.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-retorna-indice-conversao V-table-Win 
PROCEDURE pi-retorna-indice-conversao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define input  param pc-item         like item-doc-est.it-codigo  no-undo.
    define input  param pi-emitente     like emitente.cod-emitente   no-undo.
    define input  param p-un-fornec     like item-doc-est.un         no-undo.
    define output param p-de-indice     as decimal                   no-undo.

    define variable de-indice as decimal no-undo.
    if not avail item then
        find item no-lock where item.it-codigo = pc-item no-error.
    
    if not avail item then return.

    find first param-compra no-lock no-error.

    if  item.it-codigo <> "" and item.it-codigo <> ? then 
        find item-fornec 
            where item-fornec.it-codigo    = item.it-codigo 
              and item-fornec.cod-emitente = pi-emitente            
              and item-fornec.ativo        = yes
            no-lock no-error.

    if  available item-fornec then do:
        if avail param-compra 
             and param-compra.log-multi-unid-medid
             and item-fornec.unid-med-for <> p-un-fornec then do:
            /*Utiliza M£ltiplas Unidades de Medida
            Se unidade da item-fornec <> unidade da cotaá∆o, busca fator de convers∆o conforme a unidade da cotaá∆o*/
            FOR FIRST item-fornec-umd FIELDS(fator-conver num-casa-dec)
                WHERE item-fornec-umd.it-codigo = item-fornec.it-codigo
                  AND item-fornec-umd.cod-emitente = item-fornec.cod-emitente
                  AND item-fornec-umd.unid-med-for = p-un-fornec
                  AND item-fornec-umd.log-ativo no-lock query-tuning(no-lookahead): END.
            IF AVAIL item-fornec-umd THEN
                assign de-indice = item-fornec-umd.fator-conver / 
                                   if  item-fornec-umd.num-casa-dec = 0 then 1
                                   else exp(10,item-fornec-umd.num-casa-dec).
            else 
                assign de-indice = 1.
        end.
        else
            assign de-indice = item-fornec.fator-conver / 
                               if  item-fornec.num-casa-dec = 0 then 1
                               else exp(10,item-fornec.num-casa-dec).   
    end.
    else do:
        find tab-conv-un 
            where tab-conv-un.un           = item.un      
              and tab-conv-un.unid-med-for = ( if avail cotacao-item
                                               and p-un-fornec = " "   then
                                                  cotacao-item.un
                                               else p-un-fornec )
                 no-lock no-error.

        if available tab-conv-un then do:
            assign de-indice = tab-conv-un.fator-conver /
                               if tab-conv-un.num-casa-dec = 0 then 1
                               else exp(10,tab-conv-un.num-casa-dec). 
        end.
        else 
            assign de-indice = 1.

    end.
       
    assign p-de-indice = de-indice.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-total-guia-st V-table-Win 
PROCEDURE pi-total-guia-st:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define input param p-log-atualiza as log no-undo.

    if avail int_ds_docto_xml then do:
        RUN pi-verifica-situacao.
        if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.
    end.

    find b-int_ds_docto_xml-guia-st exclusive where 
        rowid(b-int_ds_docto_xml-guia-st) = rowid(int_ds_docto_xml) no-error.

    assign tot-base_guia_st  = 0
           tot-valor_guia_st = 0.

    for each  int_ds_it_docto_xml no-lock
        where int_ds_it_docto_xml.tipo_nota  = b-int_ds_docto_xml-guia-st.tipo_nota 
          and int_ds_it_docto_xml.CNPJ       = b-int_ds_docto_xml-guia-st.CNPJ      
          and int_ds_it_docto_xml.nNF        = b-int_ds_docto_xml-guia-st.nNF       
          and int_ds_it_docto_xml.serie      = b-int_ds_docto_xml-guia-st.serie
        break by int_ds_it_docto_xml.sequencia
        query-tuning(no-lookahead):

        if  first(int_ds_it_docto_xml.sequencia) and
            p-log-atualiza
        then
            assign b-int_ds_docto_xml-guia-st.base_guia_st  = 0
                   b-int_ds_docto_xml-guia-st.valor_guia_st = 0.

        FOR FIRST natur-oper NO-LOCK 
            WHERE natur-oper.nat-operacao = int_ds_it_docto_xml.nat_operacao
            query-tuning(no-lookahead): 

            IF  natur-oper.log-contrib-st-antec
            THEN DO:
                assign de-base-st-calc   = 0
                       de-valor_st-calc  = 0
                       de-perc-st-calc   = 0
                       de-tabela-pauta   = 0
                       de-per-sub-tri    = 0
                       c-tabela-pauta    = "".

                run intprg\int510-icms-st.p (INPUT int_ds_it_docto_xml.cod_emitente,
                                             INPUT int_ds_it_docto_xml.it_codigo,   
                                             INPUT int_ds_it_docto_xml.nat_operacao,
                                             INPUT b-int_ds_docto_xml-guia-st.cod_estab,        
                                             INPUT int_ds_it_docto_xml.qCom,        
                                             INPUT int_ds_it_docto_xml.vprod,    
                                             INPUT int_ds_it_docto_xml.vdesc, 
                                             INPUT int_ds_it_docto_xml.vipi,
                                             OUTPUT de-base-st-calc, 
                                             OUTPUT de-valor_st-calc, 
                                             OUTPUT de-perc-st-calc,
                                             OUTPUT c-tabela-pauta,
                                             OUTPUT de-tabela-pauta,
                                             OUTPUT de-per-sub-tri).

                if  p-log-atualiza
                then do:
                    assign b-int_ds_docto_xml-guia-st.base_guia_st  = int_ds_docto_xml.base_guia_st  + de-base-st-calc
                           b-int_ds_docto_xml-guia-st.valor_guia_st = int_ds_docto_xml.valor_guia_st + de-valor_st-calc - int_ds_it_docto_xml.vicms
                           b-int_ds_docto_xml-guia-st.vbc_cst       = b-int_ds_docto_xml-guia-st.base_guia_st 
                           b-int_ds_docto_xml-guia-st.valor_st      = b-int_ds_docto_xml-guia-st.valor_guia_st.
                    find b-int_ds_it_docto_xml exclusive-lock where 
                        rowid(b-int_ds_it_docto_xml) = rowid(int_ds_it_docto_xml) no-error no-wait.
                    if avail b-int_ds_it_docto_xml then do:
                        assign b-int_ds_it_docto_xml.vicmsst   = de-valor_st-calc - int_ds_it_docto_xml.vicms
                               b-int_ds_it_docto_xml.vbcst     = de-base-st-calc.
                        release b-int_ds_it_docto_xml.
                    end.
                end.
                else
                    assign tot-base_guia_st  = tot-base_guia_st  + de-base-st-calc
                           tot-valor_guia_st = tot-valor_guia_st + de-valor_st-calc - int_ds_it_docto_xml.vicms.
            end.
        end.
    end.

    IF  p-log-atualiza
    THEN DO:
        FOR FIRST int_ds_docto_xml_dup OF int_ds_docto_xml EXCLUSIVE-LOCK 
            WHERE int_ds_docto_xml_dup.ndup  = "GNRE" query-tuning(no-lookahead):
        END.

        IF  NOT AVAIL int_ds_docto_xml_dup 
        THEN DO: 
            CREATE int_ds_docto_xml_dup.
            ASSIGN int_ds_docto_xml_dup.tipo_nota    = int_ds_docto_xml.tipo_nota 
                   int_ds_docto_xml_dup.cod_emitente = int_ds_docto_xml.cod_emitente 
                   int_ds_docto_xml_dup.serie        = int_ds_docto_xml.serie 
                   int_ds_docto_xml_dup.nNF          = int_ds_docto_xml.nNF 
                   int_ds_docto_xml_dup.nDup         = "GNRE".
        END.

        ASSIGN int_ds_docto_xml_dup.dVenc = INPUT FRAME {&FRAME-NAME} int_ds_docto_xml.dt_guia_st.
               int_ds_docto_xml_dup.vDup  = b-int_ds_docto_xml-guia-st.valor_guia_st.
            
        RUN new-state("RefreshData").
    END.

    RELEASE b-int_ds_docto_xml-guia-st.
    RELEASE int_ds_it_docto_xml.
    RELEASE int_ds_docto_xml_dup.
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
                 usuar_grp_usuar.cod_grp_usuar = "X23" and c-seg-usuario <> "999909") then do:
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

    if avail int_ds_docto_xml then do:

        for first natur-oper no-lock where natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao query-tuning(no-lookahead): end.
        if avail natur-oper and not natur-oper.emite-duplic then do:

            if can-find (first int_ds_docto_xml_dup no-lock of int_ds_docto_xml) then do:
                run pi-gera-erro(INPUT 29,
                                 INPUT "Natureza de bonificaá∆o e duplicatas informadas.").
            end.
            return.
        end.


        /* validaá∆o de totais com ST */
        assign de-vl-docto = fnTrataNuloDec(int_ds_docto_xml.valor_mercad )
                           + fnTrataNuloDec(int_ds_docto_xml.valor_st     )
                           + fnTrataNuloDec(int_ds_docto_xml.despesa_nota )
                           + fnTrataNuloDec(int_ds_docto_xml.valor_outras )
                           + fnTrataNuloDec(int_ds_docto_xml.valor_ipi    )
                           - fnTrataNuloDec(int_ds_docto_xml.tot_desconto )
                           - fnTrataNuloDec(int_ds_docto_xml.valor_icms_des).

        de-tot-dupnf = 0.
        for each int_ds_docto_xml_dup no-lock of int_ds_docto_xml query-tuning(no-lookahead):
            de-tot-dupnf = de-tot-dupnf + fnTrataNuloDec(int_ds_docto_xml_dup.vDup).
        end.
        if round(de-vl-docto,2) <> round(de-tot-dupnf,2) then do:
            run pi-gera-erro(INPUT 28,
                             INPUT "Valor das duplicatas informadas difere do valor total da nota: " + 
                                   " Valor Dupl: " + trim(string(de-tot-dupnf)) + 
                                   " Valor Nota: " + trim(string(de-vl-docto)) ).
            return.
        end.
        de-tot-dupnf = 0.


        /* validacoes compras */
        for first natur-oper no-lock where 
            natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao query-tuning(no-lookahead): end.
        if  not avail natur-oper or 
            not natur-oper.emite-duplic then return "OK":U.

        assign de-vl-docto = fnTrataNuloDec(int_ds_docto_xml.valor_mercad )
                           /*+ fnTrataNuloDec(int_ds_docto_xml.valor_st     )*/
                           + fnTrataNuloDec(int_ds_docto_xml.despesa_nota )
                           + fnTrataNuloDec(int_ds_docto_xml.valor_ipi    )
                           - fnTrataNuloDec(int_ds_docto_xml.tot_desconto ).

        for first pedido-compr fields (cod-cond-pag)
            no-lock where 
            pedido-compr.num-pedido = int_ds_docto_xml.num_pedido query-tuning(no-lookahead): end.
        for first cond-pagto no-lock where 
            cond-pagto.cod-cond-pag = pedido-compr.cod-cond-pag query-tuning(no-lookahead): end.
        /*if not avail cond-pagto then return.*/
        for first ordem-compra fields (tp-despesa)
            no-lock of pedido-compr where ordem-compra.tp-despesa <> 0
            query-tuning(no-lookahead): 
            for first emitente fields (tp-desp-padrao) no-lock where 
                emitente.cod-emitente = int_ds_docto_xml.cod_emitente
                query-tuning(no-lookahead): 

                assign da-data    = today
                       da-partida = int_ds_docto_xml.dEmi.

                {cdp/cd9020.i7 int_ds_docto_xml.cod_estab}

                do i-ind = 1 to cond-pagto.num-parcelas:

                    create tt-dupli.
                    assign tt-dupli.parcela    = i-ind
                           tt-dupli.dt-vencim  = da-data[i-ind]
                           tt-dupli.vl-apagar  = round(de-vl-docto * cond-pagto.per-pg-dup[i-ind] / 100,2). 
                    /*                                        
                    if i-ind = 1 and fnTrataNuloDec(int_ds_docto_xml.valor_st) > 0 and
                       not can-find (first int_ds_docto_xml_dup no-lock of int_ds_docto_xml where
                                     int_ds_docto_xml_dup.nDup matches "*GNRE*") then
                        assign tt-dupli.vl-apagar  = tt-dupli.vl-apagar + fnTrataNuloDec(int_ds_docto_xml.valor_st).
                    */

                    c-venctos = c-venctos + " - " + string(tt-dupli.dt-vencim,"99/99/9999").
                    de-tot-dupli = de-tot-dupli + truncate(tt-dupli.vl-apagar,2).

                    if i-ind = cond-pagto.num-parcelas and
                       de-tot-dupli < de-vl-docto then
                        assign tt-dupli.vl-apagar = tt-dupli.vl-apagar + (de-vl-docto - de-tot-dupli)
                               de-tot-dupli = de-tot-dupli + (de-vl-docto - de-tot-dupli).


                end.
            end.
        end.


        if de-tot-dupli = 0 then de-tot-dupli = de-vl-docto.
        for first int_ds_param_re no-lock where 
            int_ds_param_re.cod_usuario = c-seg-usuario: end.

        empty temp-table tt-int_ds_docto_xml_dup.
        i-ind = 0.
        for each int_ds_docto_xml_dup no-lock of int_ds_docto_xml where
            not int_ds_docto_xml_dup.nDup matches "*GNRE*" and
            not int_ds_docto_xml_dup.nDup matches "*REEMB*"
            by int(int_ds_docto_xml_dup.nDup)
            query-tuning(no-lookahead):

            i-ind = i-ind + 1.
            create tt-int_ds_docto_xml_dup.
            buffer-copy int_ds_docto_xml_dup to tt-int_ds_docto_xml_dup.
            /*
            if i-ind = 1 then do:
                for first btt-int_ds_docto_xml_dup no-lock of int_ds_docto_xml where
                    btt-int_ds_docto_xml_dup.nDup matches "*GNRE*":
                    assign tt-int_ds_docto_xml_dup.vDup = tt-int_ds_docto_xml_dup.vDup 
                                                        + btt-int_ds_docto_xml_dup.vDup.
                end.
            end.
            */
            assign tt-int_ds_docto_xml_dup.dt-vencto = 
                                    date(int(entry(2,int_ds_docto_xml_dup.dVenc,"/")),
                                         int(entry(1,int_ds_docto_xml_dup.dVenc,"/")),
                                          int(entry(3,int_ds_docto_xml_dup.dVenc,"/")))
                   tt-int_ds_docto_xml_dup.parcela = i-ind.
        end.
        /*if can-find (first tt-dupli) then*/
        for each tt-int_ds_docto_xml_dup no-lock 
            by tt-int_ds_docto_xml_dup.parcela
            query-tuning(no-lookahead):

            if tt-int_ds_docto_xml_dup.nDup matches "*GNRE*" then next.
            if tt-int_ds_docto_xml_dup.nDup matches "*REEMB*" then next.

            de-tot-dupnf = de-tot-dupnf + fnTrataNuloDec(tt-int_ds_docto_xml_dup.vDup).

            /* AVB retirado 30/10/2017 - Projeto Procfit 
            if avail int_ds_param_re and int_ds_param_re.vld-pedido and 
               int_ds_docto_xml.situacao <> 7 /* j† aprovada compras */ and 
               not can-find (first int_ds_docto_xml_compras no-lock of int_ds_docto_xml)
            then do:
                for first tt-dupli no-lock where /*
                    tt-dupli.dt-vencim = date(int(entry(2,int_ds_docto_xml_dup.dVenc,"/")),
                                              int(entry(1,int_ds_docto_xml_dup.dVenc,"/")),
                                              int(entry(3,int_ds_docto_xml_dup.dVenc,"/")))*/
                    tt-dupli.parcela = tt-int_ds_docto_xml_dup.parcela:

                    if  available cond-pagto and cond-pagto.num-parcelas > 1 and
                        tt-int_ds_docto_xml_dup.vDup > (tt-dupli.vl-apagar * 1.002) and
                        tt-int_ds_docto_xml_dup.vDup > ((tt-dupli.vl-apagar + fnTrataNuloDec(int_ds_docto_xml.valor_st)) * 1.002) 
                    then do:
                        run pi-gera-erro(INPUT 20,    
                                         INPUT "Valor da duplicata vencto " + trim(tt-int_ds_docto_xml_dup.dVenc) + 
                                               " divergente com a condiá∆o de pagto. Valor Dup: " + 
                                               trim(string(tt-int_ds_docto_xml_dup.vDup)) + 
                                               " Valor Cond: " + trim(string(tt-dupli.vl-apagar))).
                        return.
                    end.
                    if tt-int_ds_docto_xml_dup.dt-vencto < tt-dupli.dt-vencim then do:
                        run pi-gera-erro(INPUT 21,    
                                         INPUT "Vencimentos da duplicata no. " + 
                                         string(tt-int_ds_docto_xml_dup.parcela) + 
                                         " Vencto: " +  string(tt-int_ds_docto_xml_dup.dt-vencto,"99/99/9999") + 
                                         " n∆o confere com condiá∆o de pagto: " +  string(tt-dupli.dt-vencim,"99/99/9999")).
                        return.
                    end.
                end.

                if not avail tt-dupli then do:
                    run pi-gera-erro(INPUT 22,    
                                     INPUT "Vencimentos das duplicatas n∆o confere com condiá∆o de pagto " + c-venctos ).
                    return.
                end.
            end.
            */
        end.
        /* AVB retirado 30/10/2017 - Projeto Procfit 
        if de-tot-dupli < de-tot-dupnf and
           de-tot-dupli + fnTrataNuloDec(int_ds_docto_xml.valor_st) < de-tot-dupnf 
        then do:
            run pi-gera-erro(INPUT 33,
                             INPUT "Valor das duplicatas informadas difere do valor calculado pela condiá∆o de pagto do pedido: " + 
                                   " Valor Dupl: " + trim(string(de-tot-dupnf)) + 
                                   " Valor Cond: " + trim(string(de-tot-dupli)) ).
            return.
        end.
        */
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-verifica-estorno V-table-Win 
PROCEDURE pi-verifica-estorno :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    for first natur-oper fields (char-1) no-lock where 
        natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao query-tuning(no-lookahead):
        if substring(natur-oper.char-1,159,1) = "S" /* Nfe de Estorno */
        then do:
            return "ADM-ERROR":U.
        end.
    end.
    return "".
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
    assign int_ds_docto_xml.num_pedido:bgcolor in frame f-Main = ?.
    assign c-mensagem:screen-value in frame f-main = "".

    /* AVB retirado 30/10/2017 - Projeto Procfit 
    if input frame f-main int_ds_docto_xml.num_pedido = 0 or 
       input frame f-main int_ds_docto_xml.num_pedido = ? then do:
        run pi-gera-erro(INPUT /*23*/ 37,
                         INPUT "Pedido n∆o informado!").  
        assign c-mensagem:screen-value in frame f-main = "Pedido deve ser informado!".
    end.
    */
    for first pedido-compr no-lock where 
        pedido-compr.num-pedido = input frame f-main int_ds_docto_xml.num_pedido query-tuning(no-lookahead):
        assign data-emissao:screen-value in frame f-main = string(pedido-compr.data-pedido).

        for first ordem-compra fields (numero-ordem cod-comprado)
            no-lock where ordem-compra.num-pedido = pedido-compr.num-pedido
            query-tuning(no-lookahead):
            for first comprador fields (nome) no-lock where 
                comprador.cod-comprado = ordem-compra.cod-comprado
                query-tuning(no-lookahead):
                assign cComprador:screen-value in frame f-main = comprador.nome.
            end.
            for first prazo-compra fields (data-entrega)
                no-lock of ordem-compra
                query-tuning(no-lookahead):
                assign data-entrega:screen-value in frame f-main = string(prazo-compra.data-entrega).
            end.
        end.

        /*AVB retirado 30/10/2017 - Projeto Procfit 
        if /*int_ds_docto_xml.situacao <> 7 and not can-find (first int_ds_docto_xml_compras no-lock of int_ds_docto_xml)*/
           int_ds_docto_xml.situacao <> 3 then do:
            for each int_ds_doc_erro exclusive-lock where
                int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie        and 
                int_ds_doc_erro.cod_emitente = int_ds_docto_xml.cod_emitente and 
                int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ         and     
                int_ds_doc_erro.nro_docto    = int_ds_docto_xml.NNF          and  
                int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota    and
               (int_ds_doc_erro.cod_erro     = 24 or
                int_ds_doc_erro.cod_erro     = 26 or
                int_ds_doc_erro.cod_erro     = 25)
                query-tuning(no-lookahead):
                delete int_ds_doc_erro.
            end.
        end.
        for first emitente fields (cod-emitente) no-lock where 
            emitente.cod-emitente = pedido-compr.cod-emitente: end.
        for first param-re no-lock where param-re.usuario = c-seg-usuario: 
            if avail emitente and emitente.cod-emitente <> int_ds_docto_xml.cod_emitente:input-value in frame f-Main and not param-re.rec-out-for then do:
                assign int_ds_docto_xml.num_pedido:bgcolor in frame f-Main = 14.

                run pi-gera-erro(INPUT 26,    
                                 INPUT "Pedido n∆o Ç deste fornecedor!").  
                assign c-mensagem:screen-value in frame f-main = "Pedido n∆o Ç deste fornecedor!".
            end.
            else do:
                assign int_ds_docto_xml.num_pedido:bgcolor in frame f-Main = ?.
            end.
        end.
        */
    end.
    /* AVB retirado 30/10/2017 - Projeto Procfit 
    if not avail pedido-compr /*and i-sit_re < 10*/ and
       /*int_ds_docto_xml.situacao <> 7 and not can-find (first int_ds_docto_xml_compras no-lock of int_ds_docto_xml) and */
       int_ds_docto_xml.situacao <> 3 
    then do:
        assign int_ds_docto_xml.num_pedido:bgcolor in frame f-Main = 14.
        for first param-re no-lock where param-re.usuario = c-seg-usuario and
            not param-re.sem-pedido:

            for first int-ds-ped-compra no-lock where 
                      int-ds-ped-compra.num-pedido-orig = input frame f-main int_ds_docto_xml.num_pedido:
                
                if int-ds-ped-compra.situacao = 1 or
                   int-ds-ped-compra.situacao = 9 then do:
                    run pi-gera-erro(INPUT 24,
                                     INPUT "Pedido pendente de integracao!").  
                    assign c-mensagem:screen-value in frame f-main = "Pedido pendente de integracao!".
                end.
            end.
            if not avail int-ds-ped-compra then do:
                run pi-gera-erro(INPUT 25,
                                 INPUT "Pedido n∆o encontrado!").  
                assign c-mensagem:screen-value in frame f-main = "Pedido n∆o encontrado!".
            end.
        end.
    end.
    if int_ds_docto_xml.num_pedido <> 0 and 
       int_ds_docto_xml.num_pedido <> ? then
    for each b-int_ds_docto_xml no-lock where 
        b-int_ds_docto_xml.num_pedido = int_ds_docto_xml.num_pedido and
        b-int_ds_docto_xml.nNf <> int_ds_docto_xml.nNF and
        rowid (b-int_ds_docto_xml) <> rowid (int_ds_docto_xml):

        if trim(b-int_ds_docto_xml.nNf) = trim(int_ds_docto_xml.nNF) and
           trim(b-int_ds_docto_xml.serie) = trim(int_ds_docto_xml.serie) then next.
        run pi-gera-erro(INPUT 36,
                         INPUT "Pedido j† utilizado na nota fiscal: " + b-int_ds_docto_xml.nNF + "/" + b-int_ds_docto_xml.serie).  
        assign c-mensagem:screen-value in frame f-main = "Pedido j† utilizado na nota fiscal: " + b-int_ds_docto_xml.nNF.
    end.
    */
    
    
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
        /*
        if avail int_ds_docto_xml and
           int_ds_docto_xml.situacao = 7
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi aprovada pelo departamento de compras.")).
            return "ADM-ERROR".
        end.
        */

        if i-sit_re  = 90 or i-sit_re = 95 then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input "Movimentaá‰es bloqueadas!" + "~~" + "A nota fiscal foi recusada.").
            return "ADM-ERROR".
        end.
        /*
        if (i-sit_re >= 20 /* agendada wms */ and
            i-sit_re <> 60 /* cancelada wms */)
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi conferida no WMS. Alteraá‰es n∆o ser∆o permitidas.")).
            return "ADM-ERROR".
        end.
        */

        /* voltar para a virada procfit AVB AVB
        if (i-sit_re >= 20 /* agendada wms */ and
            i-sit_re <> 60 /* cancelada wms */)
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi conferida no WMS. Alteraá‰es n∆o ser∆o permitidas.")).
            return "ADM-ERROR".
        end.
        if avail int_ds_docto_xml and
           int_ds_docto_xml.situacao = 3
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi integrada no RE1001.")).
            return "ADM-ERROR".
        end.
        */

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
  {src/adm/template/sndkycas.i "ep_codigo" "int_ds_docto_xml" "ep_codigo"}

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
  {src/adm/template/snd-list.i "int_ds_docto_xml"}

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

