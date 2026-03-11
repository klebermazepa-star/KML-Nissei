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
{include/i-prgvrs.i INT540a-viewer 1.12.00.AVB}

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

define buffer b-int_ds_docto_xml for int_ds_docto_xml.
define buffer b-int_ds_it_docto_xml for int_ds_it_docto_xml.

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
&Scoped-define EXTERNAL-TABLES int_ds_docto_xml
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_docto_xml


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_docto_xml.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_docto_xml.chnfe ~
int_ds_docto_xml.dt_trans int_ds_docto_xml.cod_emitente ~
int_ds_docto_xml.cfop int_ds_docto_xml.cod_estab int_ds_docto_xml.dEmi ~
int_ds_docto_xml.num_pedido int_ds_docto_xml.nat_operacao ~
int_ds_docto_xml.vbc int_ds_docto_xml.valor_icms int_ds_docto_xml.vbc_cst ~
int_ds_docto_xml.valor_st int_ds_docto_xml.valor_mercad ~
int_ds_docto_xml.valor_frete int_ds_docto_xml.valor_seguro ~
int_ds_docto_xml.valor_outras int_ds_docto_xml.valor_ipi ~
int_ds_docto_xml.vNF int_ds_docto_xml.tot_desconto ~
int_ds_docto_xml.valor_pis int_ds_docto_xml.valor_cofins ~
int_ds_docto_xml.valor_icms_des int_ds_docto_xml.modFrete ~
int_ds_docto_xml.valor_guia_st int_ds_docto_xml.base_guia_st ~
int_ds_docto_xml.dt_guia_st int_ds_docto_xml.perc_red_icms 
&Scoped-define ENABLED-TABLES int_ds_docto_xml
&Scoped-define FIRST-ENABLED-TABLE int_ds_docto_xml
&Scoped-Define ENABLED-OBJECTS rt-key RECT-1 RECT-3 RECT-4 RECT-5 RECT-6 ~
RECT-7 RECT-8 RECT-9 RECT-10 RECT-11 RECT-12 RECT-13 RECT-14 RECT-15 ~
RECT-16 RECT-17 RECT-18 RECT-19 RECT-20 RECT-21 RECT-22 RECT-23 RECT-24 ~
c-Mensagem 
&Scoped-Define DISPLAYED-FIELDS int_ds_docto_xml.chnfe ~
int_ds_docto_xml.dt_trans int_ds_docto_xml.cod_emitente ~
int_ds_docto_xml.cfop int_ds_docto_xml.cod_estab int_ds_docto_xml.nNF ~
int_ds_docto_xml.serie int_ds_docto_xml.dEmi int_ds_docto_xml.num_pedido ~
int_ds_docto_xml.nat_operacao int_ds_docto_xml.vbc ~
int_ds_docto_xml.valor_icms int_ds_docto_xml.vbc_cst ~
int_ds_docto_xml.valor_st int_ds_docto_xml.valor_mercad ~
int_ds_docto_xml.valor_frete int_ds_docto_xml.valor_seguro ~
int_ds_docto_xml.valor_outras int_ds_docto_xml.valor_ipi ~
int_ds_docto_xml.vNF int_ds_docto_xml.tot_desconto ~
int_ds_docto_xml.valor_pis int_ds_docto_xml.valor_cofins ~
int_ds_docto_xml.valor_icms_des int_ds_docto_xml.modFrete ~
int_ds_docto_xml.valor_guia_st int_ds_docto_xml.base_guia_st ~
int_ds_docto_xml.dt_guia_st int_ds_docto_xml.perc_red_icms 
&Scoped-define DISPLAYED-TABLES int_ds_docto_xml
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_docto_xml
&Scoped-Define DISPLAYED-OBJECTS i-situacao c-Situacao cFornecedor cUF ~
c-tipo_nota cEstabelec cNatureza data-emissao data-entrega cComprador ~
c-Mensagem vl-desconto-itens cFrete 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS int_ds_docto_xml.nNF ~
int_ds_docto_xml.serie 
&Scoped-define ADM-MODIFY-FIELDS int_ds_docto_xml.cod_emitente bt-despesas ~
bt-red-icms 

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

DEFINE BUTTON bt-guia-st 
     IMAGE-UP FILE "image/im-sav":U
     IMAGE-INSENSITIVE FILE "image/ii-sav":U
     LABEL "OK" 
     SIZE 4 BY 1 TOOLTIP "Atualiza valores ST Itens"
     FONT 4.

DEFINE BUTTON bt-red-icms 
     IMAGE-UP FILE "image/im-sav":U
     IMAGE-INSENSITIVE FILE "image/ii-sav":U
     LABEL "OK" 
     SIZE 4 BY 1 TOOLTIP "Atualiza % de Reduá∆o ICMS Itens"
     FONT 4.

DEFINE VARIABLE c-Mensagem AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 42 BY 3.5 NO-UNDO.

DEFINE VARIABLE c-Situacao AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 18.88 BY .87 NO-UNDO.

DEFINE VARIABLE c-tipo_nota AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 49.75 BY .87 NO-UNDO.

DEFINE VARIABLE cComprador AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 33 BY .8 NO-UNDO.

DEFINE VARIABLE cEstabelec AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 56.63 BY .87 NO-UNDO.

DEFINE VARIABLE cFornecedor AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 51 BY .87 NO-UNDO.

DEFINE VARIABLE cFrete AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 39.63 BY .87 NO-UNDO.

DEFINE VARIABLE cNatureza AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 56 BY .87 NO-UNDO.

DEFINE VARIABLE cUF AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 3.63 BY .87 NO-UNDO.

DEFINE VARIABLE data-emissao AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 10.63 BY .87 NO-UNDO.

DEFINE VARIABLE data-entrega AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY .87 NO-UNDO.

DEFINE VARIABLE i-situacao AS INTEGER FORMAT ">9" INITIAL 1 
     LABEL "Situaá∆o":R10 
     VIEW-AS FILL-IN NATIVE 
     SIZE 3.13 BY .87.

DEFINE VARIABLE vl-desconto-itens AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
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

DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 1.67.

DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 12.25 BY 1.67.

DEFINE RECTANGLE RECT-24
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 42 BY 1.57.

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
     int_ds_docto_xml.chnfe AT ROW 1.2 COL 11.25 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 61.13 BY .87
     i-situacao AT ROW 1.2 COL 82.88 COLON-ALIGNED WIDGET-ID 162
     c-Situacao AT ROW 1.2 COL 86.13 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     int_ds_docto_xml.dt_trans AT ROW 1.2 COL 128.75 COLON-ALIGNED WIDGET-ID 176
          VIEW-AS FILL-IN 
          SIZE 11.25 BY .87
     int_ds_docto_xml.cod_emitente AT ROW 2.13 COL 11.25 COLON-ALIGNED WIDGET-ID 4
          LABEL "Fornecedor":R10
          VIEW-AS FILL-IN 
          SIZE 10.25 BY .87
     cFornecedor AT ROW 2.13 COL 21.63 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     cUF AT ROW 2.13 COL 72.75 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     int_ds_docto_xml.cfop AT ROW 2.13 COL 82.88 COLON-ALIGNED WIDGET-ID 156
          VIEW-AS FILL-IN 
          SIZE 7.13 BY .87
     c-tipo_nota AT ROW 2.13 COL 90.25 COLON-ALIGNED NO-LABEL WIDGET-ID 178
     int_ds_docto_xml.cod_estab AT ROW 3.03 COL 11.25 COLON-ALIGNED WIDGET-ID 6
          LABEL "Filial"
          VIEW-AS FILL-IN 
          SIZE 4.75 BY .87
     cEstabelec AT ROW 3.03 COL 16 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     int_ds_docto_xml.nNF AT ROW 3.03 COL 82.88 COLON-ALIGNED WIDGET-ID 8
          LABEL "Nota"
          VIEW-AS FILL-IN 
          SIZE 14.63 BY .87
     int_ds_docto_xml.serie AT ROW 3.03 COL 104 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 7 BY .87
     int_ds_docto_xml.dEmi AT ROW 3.03 COL 128.75 COLON-ALIGNED WIDGET-ID 108
          LABEL "Emiss∆o"
          VIEW-AS FILL-IN 
          SIZE 11.25 BY .87
     int_ds_docto_xml.num_pedido AT ROW 4.77 COL 68.63 COLON-ALIGNED NO-LABEL WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 11.63 BY .87
     int_ds_docto_xml.nat_operacao AT ROW 4.8 COL 2.63 NO-LABEL WIDGET-ID 20
          VIEW-AS FILL-IN 
          SIZE 10.25 BY .87
     cNatureza AT ROW 4.8 COL 11 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     data-emissao AT ROW 4.8 COL 81.63 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     data-entrega AT ROW 4.8 COL 94 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     cComprador AT ROW 4.8 COL 107.63 COLON-ALIGNED NO-LABEL WIDGET-ID 140
     c-Mensagem AT ROW 6.5 COL 102 NO-LABEL WIDGET-ID 168
     int_ds_docto_xml.vbc AT ROW 7.07 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 44
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_docto_xml.valor_icms AT ROW 7.07 COL 20.75 COLON-ALIGNED NO-LABEL WIDGET-ID 32
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_docto_xml.vbc_cst AT ROW 7.07 COL 40.75 COLON-ALIGNED NO-LABEL WIDGET-ID 46
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_docto_xml.valor_st AT ROW 7.07 COL 60.75 COLON-ALIGNED NO-LABEL WIDGET-ID 42
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_docto_xml.valor_mercad AT ROW 7.07 COL 81.25 COLON-ALIGNED NO-LABEL WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     bt-despesas AT ROW 8.83 COL 57 HELP
          "Rateia despesas nos itens" WIDGET-ID 208
     int_ds_docto_xml.valor_frete AT ROW 8.93 COL 3 NO-LABEL WIDGET-ID 30
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_docto_xml.valor_seguro AT ROW 8.93 COL 20.75 COLON-ALIGNED NO-LABEL WIDGET-ID 40
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     int_ds_docto_xml.valor_outras AT ROW 8.93 COL 40.75 COLON-ALIGNED NO-LABEL WIDGET-ID 38
          VIEW-AS FILL-IN 
          SIZE 14.25 BY .87
     int_ds_docto_xml.valor_ipi AT ROW 8.93 COL 60.88 COLON-ALIGNED NO-LABEL WIDGET-ID 34
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_docto_xml.vNF AT ROW 8.93 COL 81.25 COLON-ALIGNED NO-LABEL WIDGET-ID 48
          VIEW-AS FILL-IN 
          SIZE 17.63 BY .87
     int_ds_docto_xml.tot_desconto AT ROW 10.87 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 110
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     vl-desconto-itens AT ROW 10.87 COL 20.75 COLON-ALIGNED NO-LABEL WIDGET-ID 118
     int_ds_docto_xml.valor_pis AT ROW 10.87 COL 40.75 COLON-ALIGNED NO-LABEL WIDGET-ID 116
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_docto_xml.valor_cofins AT ROW 10.87 COL 60.88 COLON-ALIGNED NO-LABEL WIDGET-ID 112
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_docto_xml.valor_icms_des AT ROW 10.87 COL 81.25 COLON-ALIGNED NO-LABEL WIDGET-ID 114
          VIEW-AS FILL-IN 
          SIZE 17.25 BY .87
     int_ds_docto_xml.modFrete AT ROW 10.87 COL 100.38 COLON-ALIGNED NO-LABEL WIDGET-ID 210
          VIEW-AS FILL-IN 
          SIZE 2.13 BY .87
     cFrete AT ROW 10.87 COL 102.38 COLON-ALIGNED NO-LABEL WIDGET-ID 216
     bt-red-icms AT ROW 12.67 COL 56.63 HELP
          "Atualiza % de Reduá∆o ICMS Itens" WIDGET-ID 188
     int_ds_docto_xml.valor_guia_st AT ROW 12.77 COL 3 NO-LABEL WIDGET-ID 170
          VIEW-AS FILL-IN 
          SIZE 12 BY .87
     int_ds_docto_xml.base_guia_st AT ROW 12.77 COL 14 COLON-ALIGNED NO-LABEL WIDGET-ID 194
          VIEW-AS FILL-IN 
          SIZE 15 BY .87
     int_ds_docto_xml.dt_guia_st AT ROW 12.77 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 196
          VIEW-AS FILL-IN 
          SIZE 11 BY .87
     bt-guia-st AT ROW 12.77 COL 43.25 HELP
          "Confirma valor da guia ST e calcula ST itens" WIDGET-ID 174
     int_ds_docto_xml.perc_red_icms AT ROW 12.77 COL 48 COLON-ALIGNED NO-LABEL WIDGET-ID 198
          VIEW-AS FILL-IN 
          SIZE 5.88 BY .87
     "Desconto Itens" VIEW-AS TEXT
          SIZE 14.63 BY .67 AT ROW 10.07 COL 22.75 WIDGET-ID 132
     "Vl Despesas" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 8.13 COL 42.63 WIDGET-ID 100
     "Pedido" VIEW-AS TEXT
          SIZE 7 BY .43 AT ROW 4.3 COL 70.63 WIDGET-ID 78
     "ICMS Desonerado" VIEW-AS TEXT
          SIZE 17 BY .67 AT ROW 10.07 COL 83.25 WIDGET-ID 130
     "Valor ICMS ST" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 6.27 COL 62.63 WIDGET-ID 66
     "Base ICMS ST" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 6.27 COL 42.63 WIDGET-ID 62
     "Valor Produtos" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 6.27 COL 83.13 WIDGET-ID 70
     "Mod Frete" VIEW-AS TEXT
          SIZE 9 BY .67 AT ROW 10 COL 103.13 WIDGET-ID 214
     "Vl PIS" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 10.07 COL 42.75 WIDGET-ID 134
     "Vencto ST" VIEW-AS TEXT
          SIZE 10 BY .67 AT ROW 11.93 COL 31.75 WIDGET-ID 182
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     "Comprador" VIEW-AS TEXT
          SIZE 10.88 BY .43 AT ROW 4.27 COL 109.63 WIDGET-ID 144
     "Entrega" VIEW-AS TEXT
          SIZE 8 BY .43 AT ROW 4.27 COL 96 WIDGET-ID 86
     "Emiss∆o" VIEW-AS TEXT
          SIZE 8 BY .43 AT ROW 4.3 COL 83.63 WIDGET-ID 82
     "Vl Frete" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 8.13 COL 2.63 WIDGET-ID 104
     "Descontos" VIEW-AS TEXT
          SIZE 10.63 BY .67 AT ROW 10.07 COL 2.75 WIDGET-ID 138
     "Base Guia ST" VIEW-AS TEXT
          SIZE 13 BY .67 AT ROW 11.93 COL 16.38 WIDGET-ID 180
     "Vl COFINS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 10.07 COL 62.63 WIDGET-ID 136
     "Natureza de Operaá∆o" VIEW-AS TEXT
          SIZE 20.63 BY .57 AT ROW 4.2 COL 3 WIDGET-ID 74
     "Base C†lculo" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 6.27 COL 2.63 WIDGET-ID 50
     "Vl Seguro" VIEW-AS TEXT
          SIZE 9.63 BY .67 AT ROW 8.13 COL 22.63 WIDGET-ID 98
     "%Red ICMS" VIEW-AS TEXT
          SIZE 10.88 BY .67 AT ROW 11.93 COL 49.63 WIDGET-ID 186
     "Valor Total NF" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 8.13 COL 83.13 WIDGET-ID 96
     "Valor ICMS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 6.27 COL 22.63 WIDGET-ID 58
     "Vlr Guia ST" VIEW-AS TEXT
          SIZE 10.25 BY .67 AT ROW 11.93 COL 2.75 WIDGET-ID 150
     "Valor IPI" VIEW-AS TEXT
          SIZE 8.63 BY .67 AT ROW 8.13 COL 62.63 WIDGET-ID 102
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
     RECT-15 AT ROW 8.47 COL 61.88 WIDGET-ID 106
     RECT-16 AT ROW 10.33 COL 1.75 WIDGET-ID 120
     RECT-17 AT ROW 10.33 COL 21.75 WIDGET-ID 122
     RECT-18 AT ROW 10.33 COL 41.75 WIDGET-ID 124
     RECT-19 AT ROW 10.33 COL 61.75 WIDGET-ID 126
     RECT-20 AT ROW 10.33 COL 82.25 WIDGET-ID 128
     RECT-21 AT ROW 4.53 COL 108.63 WIDGET-ID 142
     RECT-22 AT ROW 12.17 COL 2 WIDGET-ID 148
     RECT-23 AT ROW 12.17 COL 48.88 WIDGET-ID 184
     RECT-24 AT ROW 10.33 COL 102 WIDGET-ID 212
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

/* SETTINGS FOR BUTTON bt-despesas IN FRAME f-main
   NO-ENABLE 3                                                          */
/* SETTINGS FOR BUTTON bt-guia-st IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-red-icms IN FRAME f-main
   NO-ENABLE 3                                                          */
ASSIGN 
       c-Mensagem:READ-ONLY IN FRAME f-main        = TRUE.

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
/* SETTINGS FOR FILL-IN cFrete IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatureza IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.cod_emitente IN FRAME f-main
   3 EXP-LABEL                                                          */
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


&Scoped-define SELF-NAME bt-guia-st
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-guia-st V-table-Win
ON CHOOSE OF bt-guia-st IN FRAME f-main /* OK */
DO:
    RUN pi-calcula-guia-st.
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


&Scoped-define SELF-NAME i-situacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-situacao V-table-Win
ON LEAVE OF i-situacao IN FRAME f-main /* Situaá∆o */
DO:
  
    case input frame f-Main i-situacao:
        when 1 then assign c-Situacao:screen-value in frame F-Main = "Pendente".
        when 2 then assign c-Situacao:screen-value in frame F-Main = "Liberada".
        when 3 then assign c-Situacao:screen-value in frame F-Main = "Integrada RE".
        when 5 then assign c-Situacao:screen-value in frame F-Main = "Bloqueada".
        when 7 then assign c-Situacao:screen-value in frame F-Main = "Liberada".
        when 9 then assign c-Situacao:screen-value in frame F-Main = "Recusada".
    end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_docto_xml.modFrete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_docto_xml.modFrete V-table-Win
ON LEAVE OF int_ds_docto_xml.modFrete IN FRAME f-main /* Mod. Frete */
DO:
    for FIRST ems2dis.modalid-frete no-lock where 
        modalid-frete.cod-modalid-frete = input FRAME {&FRAME-NAME} int_ds_docto_xml.modFrete:
        assign cFrete:screen-value in FRAME {&FRAME-NAME} = modalid-frete.des-modalid-frete.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_docto_xml.nat_operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_docto_xml.nat_operacao V-table-Win
ON LEAVE OF int_ds_docto_xml.nat_operacao IN FRAME f-main /* Nat Oper. */
DO:
    assign int_ds_docto_xml.nat_operacao:bgcolor in frame f-Main = ?.
    for first natur-oper 
        no-lock where 
        natur-oper.nat-operacao = input frame f-Main int_ds_docto_xml.nat_operacao:
        assign  cNatureza:screen-value in frame f-Main = natur-oper.denominacao.
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
    RUN pi-verifica-pedido.
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
    for first grp_usuar no-lock where grp_usuar.cod_grp_usuar = "IBB":
        assign c-aux = "IBB - " + trim(grp_usuar.des_grp_usuar) + " e ".
    end.

    for first grp_usuar no-lock where grp_usuar.cod_grp_usuar = "CCT":
        assign c-aux = "CCT - " + trim(grp_usuar.des_grp_usuar).
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

    RUN pi-verifica-situacao.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

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
                          input ("Estabelecimento inv†lido!" + "~~" + "O c¢digo do estabelcimento deve ser informado.")).
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

    RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .


    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.


    /*:T Todos os assignÔs n∆o feitos pelo assign-record devem ser feitos aqui */  
    /* Code placed here will execute AFTER standard behavior.    */
    
    for first b-int_ds_docto_xml exclusive-lock where 
        rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml): 
        if trim(b-int_ds_docto_xml.cnpj_dest) = "" or 
           b-int_ds_docto_xml.cnpj_dest = ? then do:
            for first estabelec fields (cgc)
                no-lock where 
                estabelec.cod-estabel = int_ds_docto_xml.cod_estab:screen-value in frame {&FRAME-NAME}:
                assign b-int_ds_docto_xml.cnpj_dest = estabelec.cgc.
            end.
        end.
        for first emitente fields (cod-emitente nome-emit cgc)
            no-lock where 
            emitente.cod-emitente = b-int_ds_docto_xml.cod_emitente:
            if b-int_ds_docto_xml.cnpj   = "" or
               b-int_ds_docto_xml.cnpj   = ?  or
               b-int_ds_docto_xml.xNome  = "" or
               b-int_ds_docto_xml.xNome  = ?  or
               b-int_ds_docto_xml.cnpj  <> emitente.cgc then do:
                for each int_ds_it_docto_xml exclusive-lock where
                    int_ds_it_docto_xml.tipo_nota  = int_ds_docto_xml.tipo_nota and 
                    int_ds_it_docto_xml.CNPJ       = int_ds_docto_xml.CNPJ      and 
                    int_ds_it_docto_xml.nNF        = int_ds_docto_xml.nNF       and 
                    int_ds_it_docto_xml.serie      = int_ds_docto_xml.serie:
                    assign int_ds_it_docto_xml.CNPJ = emitente.cgc
                           int_ds_it_docto_xml.cod_emitente = emitente.cod-emitente.
                end.
                assign /*b-int_ds_docto_xml.cod_emitente = emitente.cod-emitente*/
                       b-int_ds_docto_xml.xNome = emitente.nome-emit
                       b-int_ds_docto_xml.cnpj = emitente.cgc.
            end.
        end.
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
    RUN pi-verifica-situacao.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

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
            bt-red-icms :sensitive in FRAME {&FRAME-NAME} = no
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
  if avail int_ds_docto_xml then do:
      
      assign i-situacao:screen-value in frame f-Main = string(int_ds_docto_xml.situacao).
      assign c-tipo_nota:screen-value in frame {&frame-name} = {ininc/i01in089.i 04 int_ds_docto_xml.tipo_nota}.

      assign bt-guia-st :sensitive in frame {&frame-name} = yes.

      apply "leave":u to int_ds_docto_xml.cod_emitente in frame f-main.
      apply "leave":u to int_ds_docto_xml.cod_estab in frame f-main.
      apply "leave":u to int_ds_docto_xml.nat_operacao in frame f-main.
      apply "leave":u to int_ds_docto_xml.num_pedido in frame f-main.
      apply "leave":u to i-situacao in frame f-main.
      apply "leave":U to int_ds_docto_xml.valor_guia_st in frame f-main.
      apply "leave":U to int_ds_docto_xml.modFrete in frame f-main.

      if int_ds_docto_xml.situacao <> 3 and
         can-find (first int_ds_nota_entrada no-lock where 
                   int_ds_nota_entrada.nen_cnpj_origem_s = int_ds_docto_xml.CNPJ and
                   int_ds_nota_entrada.nen_notafiscal_n  = int64(int_ds_docto_xml.nNF) and
                   int_ds_nota_entrada.nen_serie_s       = int_ds_docto_xml.serie) then
          for first b-int_ds_docto_xml exclusive-lock where 
              rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml):
              assign b-int_ds_docto_xml.situacao = 9.
          end.
      /*
      for each int-ds-docto-wms exclusive where 
          int-ds-docto-wms.doc_numero_n = int(int_ds_docto_xml.nNF) and
          int-ds-docto-wms.doc_serie_s  = int_ds_docto_xml.serie and
          int-ds-docto-wms.cnpj_cpf     = int_ds_docto_xml.CNPJ:
          delete int-ds-docto-wms.
      end.
      */
      RUN pi-avaliar-erros.
                           
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-altera-chave-nf V-table-Win 
PROCEDURE pi-altera-chave-nf :
RUN pi-verifica-situacao.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

    if avail int_ds_docto_xml then do:
        RUN intprg/int540d.w (rowid(int_ds_docto_xml)).
        find current int_ds_docto_xml no-lock no-error.
        if avail int_ds_docto_xml then do:
            assign  int_ds_docto_xml.serie:screen-value in FRAME {&FRAME-NAME} = int_ds_docto_xml.serie
                    int_ds_docto_xml.nnf:screen-value in FRAME {&FRAME-NAME} = int_ds_docto_xml.nnf.
        end.
        RUN notify ("row-available":U).
        RUN pi-avaliar-erros.
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

    assign c-mensagem:screen-value in frame f-Main = "".
    assign c-mensagem:bgcolor in frame f-main = ?.

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
               serie.serie = int_ds_docto_xml.serie: end.
    if not avail serie then do:
        run pi-gera-erro(INPUT 1,    
                         INPUT "SÇrie N∆o cadastrada").   
    end.

    for first natur-oper no-lock where
              natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao
        query-tuning(no-lookahead) : end.

    if not avail natur-oper 
    then do:
       run pi-gera-erro(INPUT 9,    
                        INPUT "Natureza de Operaá∆o nota" + string(int_ds_docto_xml.nat_operacao) + " n∆o cadastrada!"). 
    end.
    
    if int_ds_docto_xml.cfop = ? or  
       int_ds_docto_xml.cfop = 0 then do:
        run pi-gera-erro(INPUT 34,    
                         INPUT "CFOP da nota" + string(int_ds_docto_xml.nat_operacao) + " n∆o preenchida!"). 
    end.

    for first emitente no-lock where
              emitente.cod-emitente = int_ds_docto_xml.cod_emitente,
        first dist-emitente no-lock of emitente where dist-emitente.idi-sit-fornec = 1
        query-tuning(no-lookahead): 
    end.
    if not avail emitente or not avail dist-emitente then do:
        run pi-gera-erro(INPUT 2,    
                         INPUT "Fornecedor " + int_ds_docto_xml.xNome + " n∆o cadastrado ou inativo. CNPJ " + STRING(int_ds_docto_xml.CNPJ) + " C¢digo: " + string(int_ds_docto_xml.cod_emitente)).       
    end.

    for first estabelec no-lock where
               estabelec.cod-estabel = int_ds_docto_xml.cod_estab. end.
    if not avail estabelec then do:
       run pi-gera-erro(INPUT 3,    
                        INPUT "Estabelecimento n∆o cadastrado com o CNPJ " + STRING(int_ds_docto_xml.cnpj_dest)).
    end. 
    if avail estabelec and estabelec.cod-estabel = "973" then do:
       run pi-gera-erro(INPUT 3,    
                        INPUT "Estabelecimento n∆o pode ter recebimento pelo INT540!").
    end. 
    
    if int_ds_docto_xml.tipo_docto   = 4 AND 
       int_ds_docto_xml.tot_desconto = 0  /* notas Pepsico */  
    then do:
       run pi-gera-erro(INPUT 11,    
                        INPUT "N∆o foi informado o desconto.").
    end.

                                         
    for first natur-oper no-lock where natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao:
        if not natur-oper.denominacao matches "*transf*" and natur-oper.emite-duplic then do:
            for first int_ds_docto_xml_dup no-lock of int_ds_docto_xml: end.
            if not avail int_ds_docto_xml_dup then do:
                assign c-mensagem:screen-value in frame f-main = c-mensagem:screen-value in frame f-main
                                                               + "N∆o encontradas duplicatas para o documento!" + chr(32).
            end.
        end.
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

    RUN pi-verifica-pedido.

    for each int_ds_doc_erro no-lock where
      int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie AND
      int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF AND
      int_ds_doc_erro.cod_emitente = int_ds_docto_xml.cod_emitente:
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
                      int_ds_doc_erro.cod_emitente = int_ds_docto_xml.cod_emitente and 
                      int_ds_doc_erro.tipo_erro    <> "Aviso") then
         assign c-mensagem:bgcolor in frame f-main = 14.

end PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-calcula-guia-st V-table-Win 
PROCEDURE pi-calcula-guia-st :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    def var de-base-subs            like item-doc-est.base-subs   extent 0.
    def var de-vl-subs              like item-doc-est.vl-subs     extent 0.

    RUN pi-verifica-situacao.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

    for first param-re no-lock where param-re.usuario = c-seg-usuario: end.
    if not avail param-re then do:
        return.
    end.

    if  avail int_ds_docto_xml and 
        int_ds_docto_xml.valor_guia_st:input-value in FRAME {&FRAME-NAME} > 0 then  do:
        for first emitente fields (nome-abrev estado cidade pais cgc)
            no-lock where 
            emitente.cod-emitente = int_ds_docto_xml.cod_emitente: end.

        if not avail emitente then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Fornecedor inv†lido!" + "~~" + "O fornecedor n∆o foi encontrado no cadastro com o c¢digo: " + string(int_ds_docto_xml.cod_emitente))).
            return "ADM-ERROR".
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
            return "ADM-ERROR".
        end.

        for first natur-oper no-lock where 
            natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao: end.
        if not avail natur-oper then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Natureza de Operaá∆o inv†lida!" + "~~" + "A natureza de operaá∆o n∆o foi encontrada no cadastro com o c¢digo: " + int_ds_docto_xml.nat_operacao)).
            return "ADM-ERROR".
        end.


        run utp/ut-msgs.p(input "show",
                          input 701,
                          input ("c†lculo para icms ST (Os valores atuais ser∆o sobrepostos) ")).
    
        if return-value = "yes" then do:
            find b-int_ds_docto_xml exclusive-lock where 
                rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml) no-error no-wait.
            if avail b-int_ds_docto_xml then do:
                assign b-int_ds_docto_xml.valor_guia_st = input FRAME {&FRAME-NAME} int_ds_docto_xml.valor_guia_st.
            end.
            run pi-gera-tt-docto.                  
            run pi-gera-tt-it-doc.        
            if return-value = "ADM-ERROR":U then return "ADM-ERROR".
        
            find first tt-docto no-error.
        
            /* CALCULO DE ICMS, SUBST.TRIBUTARIA e ICMS COMPLEMENTAR */
            run rep/re1906.p ( tt-docto.seq-tt-docto,
                               yes,                              /* ICMS */
                               yes,                              /* Subst. Tributaria */
                               yes,                              /* ICMS Complementar */
                               input        table tt-docto,
                               input        table tt-it-docto,
                               input-output table tt-it-imposto).
        
            assign de-base-subs        = 0
                   de-vl-subs          = 0.
            for each tt-it-docto fields (seq-tt-it-docto nr-sequencia)
                where tt-it-docto.cod-estabel  = int_ds_docto_xml.cod_estab
                  and tt-it-docto.serie        = int_ds_docto_xml.serie
                  and tt-it-docto.nr-nota      = int_ds_docto_xml.nNF
                  and tt-it-docto.cod-emitente = int_ds_docto_xml.cod_emitente
                  and tt-it-docto.nat-operacao = int_ds_docto_xml.nat_operacao  exclusive-lock:
        
                find tt-it-imposto
                    where tt-it-imposto.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto
                    exclusive-lock no-error.
        
                for each b-int_ds_it_docto_xml where 
                    b-int_ds_it_docto_xml.serie        = tt-it-docto.serie        and
                    b-int_ds_it_docto_xml.nNF          = tt-it-docto.nr-nota      and
                    b-int_ds_it_docto_xml.cod_emitente = tt-it-docto.cod-emitente and
                    b-int_ds_it_docto_xml.nat_operacao = tt-it-docto.nat-operacao and 
                    b-int_ds_it_docto_xml.sequencia    = tt-it-docto.nr-sequencia:
                    assign b-int_ds_it_docto_xml.vbcst   = tt-it-imposto.vl-bsubs-it
                           b-int_ds_it_docto_xml.vicmsst = tt-it-imposto.vl-icmsub-it.
                    assign de-base-subs  = de-base-subs + fnTrataNuloDec(b-int_ds_it_docto_xml.vbcst)
                           de-vl-subs    = de-vl-subs   + fnTrataNuloDec(b-int_ds_it_docto_xml.vicmsst).
                end.
            end.
            assign b-int_ds_docto_xml.vbc_cst = de-base-subs
                   b-int_ds_docto_xml.valor_st = de-vl-subs. 
            assign int_ds_docto_xml.vbc_cst :screen-value in FRAME {&FRAME-NAME} = string(de-base-subs)
                   int_ds_docto_xml.valor_st:screen-value in FRAME {&FRAME-NAME} = string(de-vl-subs). 

            for first int_ds_docto_xml_dup exclusive where 
                int_ds_docto_xml_dup.tipo_nota = int_ds_docto_xml.tipo_nota and
                int_ds_docto_xml_dup.cod_emitente = int_ds_docto_xml.cod_emitente and
                int_ds_docto_xml_dup.serie = int_ds_docto_xml.serie and
                int_ds_docto_xml_dup.nNF = int_ds_docto_xml.nNF and
                int_ds_docto_xml_dup.nDup = "GNRE": end.

            if not avail int_ds_docto_xml_dup then do:
                create  int_ds_docto_xml_dup.
                assign  int_ds_docto_xml_dup.tipo_nota    = int_ds_docto_xml.tipo_nota 
                        int_ds_docto_xml_dup.cod_emitente = int_ds_docto_xml.cod_emitente 
                        int_ds_docto_xml_dup.serie        = int_ds_docto_xml.serie 
                        int_ds_docto_xml_dup.nNF          = int_ds_docto_xml.nNF 
                        int_ds_docto_xml_dup.nDup         = "GNRE"
                        int_ds_docto_xml_dup.cnpj_cpf     = emitente.cgc.
            end.
            assign int_ds_docto_xml_dup.dVenc = input FRAME {&FRAME-NAME} int_ds_docto_xml.dt_guia_st.
            assign int_ds_docto_xml_dup.vDup  = de-vl-subs.

            RUN new-state ('RefreshData').
        end. /* return-value */
    end. /* if avail */
END PROCEDURE.


procedure pi-gera-tt-docto:

    def var i-seq-docto as integer  no-undo.

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

    find last tt-it-docto use-index seq no-lock no-error.

    assign i-seq-aux = if  avail tt-it-docto 
                       then tt-it-docto.seq-tt-it-docto + 1
                       else 1. 

    for each int_ds_it_docto_xml no-lock where
        int_ds_it_docto_xml.serie   = int_ds_docto_xml.serie  and
        int_ds_it_docto_xml.nNF     = int_ds_docto_xml.nNF    and
        int_ds_it_docto_xml.cod_emitente  = int_ds_docto_xml.cod_emitente and
        int_ds_it_docto_xml.nat_operacao  = int_ds_docto_xml.nat_operacao:

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
            natur-oper.nat-operacao = int_ds_it_docto_xml.nat_operacao: end.
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
        assign tt-it-docto.quantidade[1]  = int_ds_it_docto_xml.qCom
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
            item.it-codigo = int_ds_it_docto_xml.it_codigo: 
            assign tt-it-docto.peso-liq-it = item.peso-liquido * tt-it-docto.quantidade[1].
        end.

        for first ordem-compra no-lock where 
            ordem-compra.numero-ordem = int_ds_it_docto_xml.numero_ordem: end.

        if  avail item 
            and item.tipo-contr = 4
            and avail ordem-compra  then do:

                for first prazo-compra no-lock where 
                    prazo-compra.numero-ordem = ordem-compra.numero-ordem: end.

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

        i-trib-icm = natur-oper.cd-trib-icm.
        /*
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
        */

        case int_ds_it_docto_xml.cst_ipi:
            /*
            when 00 then i-trib-ipi = 1 /* Entrada com Recuperaá∆o de CrÇdito */.
            when 01 then i-trib-ipi = 1 /* Entrada com Recuperaá∆o de CrÇdito */.
            */
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
   /* Pepsico */
   for first int_ds_ext_emitente no-lock where 
             int_ds_ext_emitente.cod_emitente = int_ds_docto_xml.cod_emitente
       query-tuning(no-lookahead) : end.

   for each int_ds_it_docto_xml no-lock where
       int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota    and 
       int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente and 
       int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF          and 
       int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie:

       if int_ds_it_docto_xml.tipo_nota <> 3 /* transferencia */ and
          not can-find (first estabelec no-lock where estabelec.cod-emitente = int_ds_it_docto_xml.cod_emitente) then do:

           /* PEPSICO */
           if  (avail int_ds_ext_emitente and int_ds_ext_emitente.gera_nota) or
                     int_ds_docto_xml.tipo_docto = 0
           then do:
               c-item-do-forn = int_ds_it_docto_xml.it_codigo.
               for first item-fornec no-lock where
                         item-fornec.cod-emitente = int_ds_docto_xml.cod_emitente and
                         item-fornec.it-codigo    = c-item-do-forn and
                         item-fornec.ativo = yes:
                   assign c-un-forn = item-fornec.unid-med-for.
               end.
           end.
       end. /* tipo_nota <> 3 */

       if int_ds_it_docto_xml.qCom = ?  or
          int_ds_it_docto_xml.qCom = 0  or
          int_ds_it_docto_xml.uCom_forn = "" then do:
           run pi-gera-erro(INPUT 27,
                            INPUT "Quantidade Fornecedor/Unidade n∆o informados. Item: " + 
                                  string(if int_ds_it_docto_xml.item_do_forn <> ? then int_ds_it_docto_xml.item_do_forn else "?") + " Seq: " + string(int_ds_it_docto_xml.sequencia)). 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-calcula-tributos V-table-Win 
PROCEDURE pi-calcula-tributos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
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

    RUN pi-verifica-situacao.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.
    if avail int_ds_docto_xml then do:
        for first param-re no-lock where param-re.usuario = c-seg-usuario: end.
        if not avail param-re then do:
            return.
        end.

        run pi-gera-tt-docto.                  
        run pi-gera-tt-it-doc.        
        if return-value = "ADM-ERROR":U then return "ADM-ERROR".
    
        find first tt-docto no-error.
    
        /* CALCULO DE ICMS, SUBST.TRIBUTARIA e ICMS COMPLEMENTAR */
        run rep/re1906.p ( tt-docto.seq-tt-docto,
                           yes,                              /* ICMS */
                           yes,                              /* Subst. Tributaria */
                           yes,                              /* ICMS Complementar */
                           input        table tt-docto,
                           input        table tt-it-docto,
                           input-output table tt-it-imposto).
    
        assign b-int_ds_docto_xml.vbc_cst    = 0
               b-int_ds_docto_xml.valor_st   = 0
               b-int_ds_docto_xml.valor_icms = 0
               b-int_ds_docto_xml.vbc        = 0
               b-int_ds_docto_xml.valor_ipi  = 0. 

        for each tt-it-docto fields (seq-tt-it-docto nr-sequencia)
            where tt-it-docto.cod-estabel  = int_ds_docto_xml.cod_estab
              and tt-it-docto.serie        = int_ds_docto_xml.serie
              and tt-it-docto.nr-nota      = int_ds_docto_xml.nNF
              and tt-it-docto.cod-emitente = int_ds_docto_xml.cod_emitente
              and tt-it-docto.nat-operacao = int_ds_docto_xml.nat_operacao  exclusive-lock:
    
            find tt-it-imposto
                where tt-it-imposto.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto
                exclusive-lock no-error.
    
            for each b-int_ds_it_docto_xml where 
                b-int_ds_it_docto_xml.serie        = tt-it-docto.serie        and
                b-int_ds_it_docto_xml.nNF          = tt-it-docto.nr-nota      and
                b-int_ds_it_docto_xml.cod_emitente = tt-it-docto.cod-emitente and
                b-int_ds_it_docto_xml.nat_operacao = tt-it-docto.nat-operacao and 
                b-int_ds_it_docto_xml.sequencia    = tt-it-docto.nr-sequencia:
                assign  b-int_ds_it_docto_xml.vbcst      = tt-it-imposto.vl-bsubs-it
                        b-int_ds_it_docto_xml.vicmsst    = tt-it-imposto.vl-icmsub-it
                        /*b-int_ds_it_docto_xml.cst_icms   =  */
                        b-int_ds_it_docto_xml.vbc_icms   = if tt-it-imposto.vl-bicms-it > 0 then tt-it-imposto.vl-bicms-it else
                                                           if tt-it-imposto.vl-icmsou-it > 0 then tt-it-imposto.vl-icmsou-it else
                                                           if tt-it-imposto.vl-icmsnt-it > 0 then tt-it-imposto.vl-icmsnt-it 
                                                           else 0
                        b-int_ds_it_docto_xml.picms      = tt-it-imposto.aliquota-icm
                        b-int_ds_it_docto_xml.vicms      = tt-it-imposto.vl-icms-it
                        b-int_ds_it_docto_xml.predBc     = tt-it-imposto.perc-red-icm.

                assign  /*b-int_ds_it_docto_xml.cst_ipi    = */
                        b-int_ds_it_docto_xml.vbc_ipi    = if tt-it-imposto.vl-bipi-it > 0 then tt-it-imposto.vl-bipi-it else
                                                           if tt-it-imposto.vl-ipiou-it > 0 then tt-it-imposto.vl-ipiou-it else
                                                           if tt-it-imposto.vl-ipint-it > 0 then tt-it-imposto.vl-ipint-it 
                                                           else 0
                        b-int_ds_it_docto_xml.pipi       = tt-it-imposto.aliquota-ipi
                        b-int_ds_it_docto_xml.vipi       = tt-it-imposto.vl-ipi-it.

                assign b-int_ds_docto_xml.vbc_cst    = b-int_ds_docto_xml.vbc_cst    + fnTrataNuloDec(b-int_ds_it_docto_xml.vbcst)
                       b-int_ds_docto_xml.valor_st   = b-int_ds_docto_xml.valor_st   + fnTrataNuloDec(b-int_ds_it_docto_xml.vicmsst)
                       b-int_ds_docto_xml.valor_icms = b-int_ds_docto_xml.valor_icms + fnTrataNuloDec(b-int_ds_it_docto_xml.vicms)
                       b-int_ds_docto_xml.vbc        = b-int_ds_docto_xml.vbc        + fnTrataNuloDec(b-int_ds_it_docto_xml.vbc_icms)
                       b-int_ds_docto_xml.valor_ipi  = b-int_ds_docto_xml.valor_ipi  + fnTrataNuloDec(b-int_ds_it_docto_xml.vipi).
            end.
        end.
        display b-int_ds_docto_xml.vbc_cst    @ int_ds_docto_xml.vbc_cst   
                b-int_ds_docto_xml.valor_st   @ int_ds_docto_xml.valor_st  
                b-int_ds_docto_xml.valor_icms @ int_ds_docto_xml.valor_icms
                b-int_ds_docto_xml.vbc        @ int_ds_docto_xml.vbc       
                b-int_ds_docto_xml.valor_ipi  @ int_ds_docto_xml.valor_ipi 
            with FRAME {&FRAME-NAME}.

        for each int_ds_it_docto_xml exclusive-lock where
            int_ds_it_docto_xml.tipo_nota       = int_ds_docto_xml.tipo_nota    and 
            int_ds_it_docto_xml.cod_emitente    = int_ds_docto_xml.cod_emitente and 
            int_ds_it_docto_xml.nNF             = int_ds_docto_xml.nNF          and 
            int_ds_it_docto_xml.serie           = int_ds_docto_xml.serie:

            for first natur-oper no-lock where natur-oper.nat-operacao = int_ds_it_docto_xml.nat_operacao: end.
            if not avail natur-oper then return.

            for first ITEM no-lock where ITEM.it-codigo = int_ds_it_docto_xml.it_codigo: 
                
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

                    if de-aliq-pis <> 0 and i-pis <> 2 then do:
                        assign int_ds_it_docto_xml.ppis    = de-aliq-pis
                               int_ds_it_docto_xml.vbc_pis = de-base-pis.
                        assign int_ds_it_docto_xml.vpis    = de-valor-pis
                               int_ds_it_docto_xml.cst_pis = i-pis.
                    end.
                    else do:
                        assign int_ds_it_docto_xml.vpis    = 0
                               int_ds_it_docto_xml.ppis    = 0
                               int_ds_it_docto_xml.vbc_pis = 0
                               int_ds_it_docto_xml.cst_pis = 2.
                    end.

                    if de-aliq-cofins <> 0 and i-cofins <> 2 then do:
                        assign int_ds_it_docto_xml.pcofins    = de-aliq-cofins
                               int_ds_it_docto_xml.vbc_cofins = de-base-cofins.
                        assign int_ds_it_docto_xml.vcofins    = de-valor-cofins
                               int_ds_it_docto_xml.cst_cofins = 1.
                    end.
                    else do:
                        assign int_ds_it_docto_xml.pcofins    = 0
                               int_ds_it_docto_xml.vbc_cofins = 0
                               int_ds_it_docto_xml.vcofins    = 0
                               int_ds_it_docto_xml.cst_cofins = 2.
                    end.
                end.
            end.
        end.
        RUN new-state ('RefreshData').
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

    
    RUN pi-verifica-situacao.
    if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.

    if avail int_ds_docto_xml then do:

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
               int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota    and 
               int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente and 
               int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF          and 
               int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie:

               assign int_ds_it_docto_xml.predBc = input FRAME {&FRAME-NAME} int_ds_docto_xml.perc_red_icms.

            end.
            RUN new-state ('RefreshData').
        end.    
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-erro V-table-Win 
PROCEDURE pi-gera-erro :
DEF INPUT PARAM p-cod-erro     LIKE int_ds_doc_erro.cod_erro.
    DEF INPUT PARAM p-desc-erro    LIKE int_ds_doc_erro.descricao.
      
     FOR  FIRST int_ds_doc_erro NO-LOCK WHERE
                int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie  AND 
                int_ds_doc_erro.nro_docto    = int_ds_docto_xml.nNF   AND 
                int_ds_doc_erro.cod_emitente = int_ds_docto_xml.cod_emitente AND
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
    
        if avail int_ds_it_docto_xml then
            assign  int_ds_doc_erro.sequencia = int_ds_it_docto_xml.sequencia
                    int_ds_it_docto_xml.situacao = 1.
    
     END.

     if avail int_ds_docto_xml and int_ds_docto_xml.situacao <> 1 then do:
         find b-int_ds_docto_xml exclusive-lock where 
             rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml) no-error no-wait.
         if avail b-int_ds_docto_xml then do:
            assign b-int_ds_docto_xml.situacao = 1.
        end.
     end.
        
    

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
   def var c-nat-operacao as char no-undo.
   RUN pi-verifica-situacao.
   if RETURN-VALUE = "ADM-ERROR":U then return "ADM-ERROR":U.


   for each int_ds_it_docto_xml exclusive-lock where
       int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota    and 
       int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente and 
       int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF          and 
       int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie:

       c-nat-operacao = "".
       for first item fields (it-codigo fm-codigo class-fiscal) no-lock where 
           item.it-codigo = int_ds_it_docto_xml.it_codigo: 
           /* tratar natur-oper */
           RUN intprg/int013a.p( input int_ds_it_docto_xml.cfop,
                                 input int_ds_it_docto_xml.cst_icms,
                                 input /*int_ds_it_docto_xml.nep-cstb-ipi-n*/ int(item.fm-codigo),
                                 input int_ds_docto_xml.cod_estab,
                                 input int_ds_docto_xml.cod_emitente,
                                 INPUT item.class-fiscal,
                                 input int_ds_docto_xml.dEmi,
                                 output c-nat-operacao).
       end.

        /*
        if c-nat-operacao = "" then do:
            run pi-gera-erro(INPUT 18,    
                             INPUT "N∆o encontrada natureza de operaá∆o para entrada. " + 
                                   "CFOP Nota: " + string(int_ds_it_docto_xml.cfop) + 
                                   " CSTB ICMS: " + string(int_ds_it_docto_xml.cst_icms) + 
                                   " Fam°lia: " + item.fm-codigo + " Estab.: " + int_ds_docto_xml.cod_estab). 
            assign int_ds_it_docto_xml.situacao = 1 /* Pendente */.
        end.
        */

        for first natur-oper no-lock where
                  natur-oper.nat-operacao = c-nat-operacao
            query-tuning(no-lookahead) : end.
                        
        /* setando natureza principal do documento para a mais baixa evitendo erro de api quando ST na natureza principal 
           come itens sem st na nota */
        if avail natur-oper then do:

            if c-nat-operacao <> "" 
               &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                then do:
               &else
                or NOT natur-oper.log-contrib-st-antec then do:
            &endif
            
                find b-int_ds_docto_xml exclusive-lock where 
                    rowid (b-int_ds_docto_xml) = rowid (int_ds_docto_xml) no-error no-wait.
                if avail b-int_ds_docto_xml then do:
                    assign b-int_ds_docto_xml.nat_operacao = c-nat-operacao.
                    assign int_ds_docto_xml.nat_operacao:screen-value in FRAME {&FRAME-NAME} = b-int_ds_docto_xml.nat_operacao.
                    apply "leave":u to int_ds_docto_xml.nat_operacao in FRAME {&FRAME-NAME} .
                end.
            end.

            if int_ds_it_docto_xml.nat_operacao <> c-nat-operacao and c-nat-operacao <> "" then do:
                assign int_ds_it_docto_xml.nat_operacao = c-nat-operacao.
            end.
        end. /* avail natur-oper */
        RUN new-state ('RefreshData').
    end. /* avail int_ds_it_docto_xml */

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
            int_ds_it_docto_xml.tipo_nota       = int_ds_docto_xml.tipo_nota    and 
            int_ds_it_docto_xml.cod_emitente    = int_ds_docto_xml.cod_emitente and 
            int_ds_it_docto_xml.nNF             = int_ds_docto_xml.nNF          and 
            int_ds_it_docto_xml.serie           = int_ds_docto_xml.serie:
            assign int_ds_it_docto_xml.vOutro = int_ds_docto_xml.valor_outras * 
                (fnTrataNuloDec(int_ds_it_docto_xml.vProd) / fnTrataNuloDec(int_ds_docto_xml.valor_mercad)).
        end.
        RUN new-state("RefreshData").
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
    DEFINE VARIABLE de-vl-docto        AS   DECIMAL                 NO-UNDO.
    DEFINE VARIABLE de-tot-dupnf       AS   DECIMAL                 NO-UNDO.
    DEFINE VARIABLE i-ind              AS   integer                 NO-UNDO.
    
    if avail int_ds_docto_xml then do:

        for first natur-oper no-lock where natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao: end.
        if avail natur-oper and not natur-oper.emite-duplic then do:

            if can-find (first int_ds_docto_xml_dup no-lock of int_ds_docto_xml) then do:
                run pi-gera-erro(INPUT 29,
                                 INPUT "Natureza de bonificaá∆o e duplicatas informadas.").
            end.
            return.
        end.

        for first natur-oper no-lock where 
            natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao: end.
        if  not avail natur-oper or 
            not natur-oper.emite-duplic then return "OK":U.

        assign de-vl-docto = fnTrataNuloDec(int_ds_docto_xml.valor_mercad )
                           + fnTrataNuloDec(int_ds_docto_xml.valor_st     )
                           + fnTrataNuloDec(int_ds_docto_xml.despesa_nota )
                           + fnTrataNuloDec(int_ds_docto_xml.valor_outras )
                           + fnTrataNuloDec(int_ds_docto_xml.valor_ipi    )
                           - fnTrataNuloDec(int_ds_docto_xml.tot_desconto ).

        for each int_ds_docto_xml_dup no-lock of int_ds_docto_xml:
            de-tot-dupnf = de-tot-dupnf + fnTrataNuloDec(int_ds_docto_xml_dup.vDup).

            if int_ds_docto_xml.dEmi > date(int(entry(2,int_ds_docto_xml_dup.dVenc,"/")),
                                            int(entry(1,int_ds_docto_xml_dup.dVenc,"/")),
                                            int(entry(3,int_ds_docto_xml_dup.dVenc,"/"))) then do:
                run pi-gera-erro(INPUT 36,
                                 INPUT "Data de Vencimento das duplicatas deve ser maior ou igual que Data de Emiss∆o do Documento!").
                return.
            end.
        end.
        if de-vl-docto <> de-tot-dupnf and
           int_ds_docto_xml.vNF <> de-tot-dupnf then do:
            run pi-gera-erro(INPUT 22,
                             INPUT "Valor das duplicatas informadas difere do valor valor total da nota: " + 
                                   " Valor Dupl: " + trim(string(de-tot-dupnf)) + 
                                   " Valor Nota: " + trim(string(de-vl-docto)) ).
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
    assign int_ds_docto_xml.num_pedido:bgcolor in frame f-Main = ?.
    assign c-mensagem:screen-value in frame f-main = "".
    
    /*
    if input frame f-main int_ds_docto_xml.num_pedido = 0 or 
       input frame f-main int_ds_docto_xml.num_pedido = ? then do:
        run pi-gera-erro(INPUT 24,
                         INPUT "Pedido n∆o informado!").  
        assign c-mensagem:screen-value in frame f-main = "Pedido deve ser informado!".
    end.
    */

    for first pedido-compr no-lock where 
        pedido-compr.num-pedido = input frame f-main int_ds_docto_xml.num_pedido:
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
    end.

    if int_ds_docto_xml.num_pedido <> 0 and 
       int_ds_docto_xml.num_pedido <> ? then
    for each b-int_ds_docto_xml no-lock USE-INDEX emitente where 
        b-int_ds_docto_xml.num_pedido = int_ds_docto_xml.num_pedido and
         b-int_ds_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente and
        b-int_ds_docto_xml.nNf <> int_ds_docto_xml.nNF and
        rowid (b-int_ds_docto_xml) <> rowid (int_ds_docto_xml):

        if trim(b-int_ds_docto_xml.nNf) = trim(int_ds_docto_xml.nNF) and
           trim(b-int_ds_docto_xml.serie) = trim(int_ds_docto_xml.serie) then next.
        run pi-gera-erro(INPUT 35,
                         INPUT "Pedido j† utilizado na nota fiscal: " + b-int_ds_docto_xml.nNF + "/" + b-int_ds_docto_xml.serie).  
        assign c-mensagem:screen-value in frame f-main = "Pedido j† utilizado na nota fiscal: " + b-int_ds_docto_xml.nNF + "/" + b-int_ds_docto_xml.serie.
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

    if (i-situacao = 3 /* integrada */)
    then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi integrada no RE1001")).
        return "ADM-ERROR".
    end.
    if (i-situacao > 3 /* integrada */)
    then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal foi bloqueada ou recusada.")).
        return "ADM-ERROR".
    end.

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

