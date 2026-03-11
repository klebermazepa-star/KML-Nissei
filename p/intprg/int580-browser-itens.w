&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          custom           Progress
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS B-table-Win 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int580-browser-itens 1.12.00.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/browserd.w

/* Parameters Definitions ---                                           */
 
/* Local Variable Definitions ---                                       */

/*:T Variaveis usadas internamente pelo estilo, favor nao elimina-las     */

/*:T v†ri†veis de uso globla */
def  var v-row-parent    as rowid no-undo.

/*:T vari†veis de uso local */
def var v-row-table  as rowid no-undo.

/*:T fim das variaveis utilizadas no estilo */

def var i-sit-re as integer no-undo.

DEFINE VARIABLE de-base-st-calc  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-valor-st-calc AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-perc-st-calc  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE c-tabela-pauta   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE de-tabela-pauta  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-per-sub-tri   AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-per-va-st     AS DECIMAL     NO-UNDO.
DEFINE VARIABLE c-cod-obsoleto   AS CHARACTER  LABEL "Status Item" NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE BrowserCadastro2
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br-table

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int_ds_docto_xml
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_docto_xml


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_docto_xml.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES int_ds_it_docto_xml

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table int_ds_it_docto_xml.sequencia ~
int_ds_it_docto_xml.it_codigo int_ds_it_docto_xml.item_do_forn ~
fnObsoleto(int_ds_it_docto_xml.it_codigo) @ c-cod-obsoleto ~
int_ds_it_docto_xml.xProd int_ds_it_docto_xml.ncm int_ds_it_docto_xml.cfop ~
int_ds_it_docto_xml.cst_icms int_ds_it_docto_xml.nat_operacao ~
int_ds_it_docto_xml.numero_ordem int_ds_it_docto_xml.Lote ~
int_ds_it_docto_xml.qCom_forn int_ds_it_docto_xml.uCom_forn ~
int_ds_it_docto_xml.vUnCom int_ds_it_docto_xml.qCom ~
int_ds_it_docto_xml.uCom int_ds_it_docto_xml.vDesc ~
int_ds_it_docto_xml.vbc_ipi int_ds_it_docto_xml.pipi ~
int_ds_it_docto_xml.vipi int_ds_it_docto_xml.vbc_icms ~
int_ds_it_docto_xml.picms int_ds_it_docto_xml.predBc ~
int_ds_it_docto_xml.vicms int_ds_it_docto_xml.vicmsdeson ~
int_ds_it_docto_xml.vbcst int_ds_it_docto_xml.picmsst ~
int_ds_it_docto_xml.vicmsst int_ds_it_docto_xml.vPMC ~
int_ds_it_docto_xml.pmvast de-base-st-calc @ de-base-st-calc ~
de-perc-st-calc @ de-perc-st-calc de-valor-st-calc @ de-valor-st-calc ~
c-tabela-pauta @ c-tabela-pauta de-tabela-pauta @ de-tabela-pauta ~
de-per-sub-tri @ de-per-sub-tri de-per-va-st @ de-per-va-st ~
int_ds_it_docto_xml.vbc_pis int_ds_it_docto_xml.ppis ~
int_ds_it_docto_xml.vpis int_ds_it_docto_xml.vbc_cofins ~
int_ds_it_docto_xml.pcofins int_ds_it_docto_xml.vcofins ~
int_ds_it_docto_xml.vOutro int_ds_it_docto_xml.vProd 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table int_ds_it_docto_xml.ncm ~
int_ds_it_docto_xml.cfop int_ds_it_docto_xml.cst_icms ~
int_ds_it_docto_xml.nat_operacao int_ds_it_docto_xml.numero_ordem ~
int_ds_it_docto_xml.Lote int_ds_it_docto_xml.qCom_forn ~
int_ds_it_docto_xml.vUnCom int_ds_it_docto_xml.vDesc ~
int_ds_it_docto_xml.vbc_ipi int_ds_it_docto_xml.pipi ~
int_ds_it_docto_xml.vipi int_ds_it_docto_xml.vbc_icms ~
int_ds_it_docto_xml.picms int_ds_it_docto_xml.predBc ~
int_ds_it_docto_xml.vicms int_ds_it_docto_xml.vicmsdeson ~
int_ds_it_docto_xml.vbcst int_ds_it_docto_xml.vicmsst ~
int_ds_it_docto_xml.vbc_pis int_ds_it_docto_xml.ppis ~
int_ds_it_docto_xml.vpis int_ds_it_docto_xml.vbc_cofins ~
int_ds_it_docto_xml.pcofins int_ds_it_docto_xml.vcofins ~
int_ds_it_docto_xml.vOutro int_ds_it_docto_xml.vProd 
&Scoped-define ENABLED-TABLES-IN-QUERY-br-table int_ds_it_docto_xml
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-table int_ds_it_docto_xml
&Scoped-define QUERY-STRING-br-table FOR EACH int_ds_it_docto_xml WHERE int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente ~
  AND int_ds_it_docto_xml.serie = int_ds_docto_xml.serie ~
  AND int_ds_it_docto_xml.nNF = int_ds_docto_xml.nNF ~
  AND int_ds_it_docto_xml.tipo_nota = int_ds_docto_xml.tipo_nota NO-LOCK ~
    ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH int_ds_it_docto_xml WHERE int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente ~
  AND int_ds_it_docto_xml.serie = int_ds_docto_xml.serie ~
  AND int_ds_it_docto_xml.nNF = int_ds_docto_xml.nNF ~
  AND int_ds_it_docto_xml.tipo_nota = int_ds_docto_xml.tipo_nota NO-LOCK ~
    ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-br-table int_ds_it_docto_xml
&Scoped-define FIRST-TABLE-IN-QUERY-br-table int_ds_it_docto_xml


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br-table

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" B-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS
><EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Advanced Query Options" B-table-Win _INLINE
/* Actions: ? adm/support/advqedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<SORTBY-OPTIONS>
</SORTBY-OPTIONS>
<SORTBY-RUN-CODE>
************************
* Set attributes related to SORTBY-OPTIONS */
RUN set-attribute-list (
    'SortBy-Options = ""':U).
/************************
</SORTBY-RUN-CODE>
<FILTER-ATTRIBUTES>
************************
* Initialize Filter Attributes */
RUN set-attribute-list IN THIS-PROCEDURE ('
  Filter-Value=':U).
/************************
</FILTER-ATTRIBUTES> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-base-st-nf B-table-Win 
FUNCTION fn-base-st-nf RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-perc-va-st B-table-Win 
FUNCTION fn-perc-va-st RETURNS DECIMAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnObsoleto B-table-Win 
FUNCTION fnObsoleto RETURNS CHARACTER
  ( c-it-codigo AS CHAR )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-altera-browse 
     LABEL "&Alterar no Grid" 
     SIZE 16 BY 1.

DEFINE BUTTON bt-eliminar 
     LABEL "&Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-incluir 
     LABEL "&Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-modificar 
     LABEL "&Modificar" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      int_ds_it_docto_xml SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      int_ds_it_docto_xml.sequencia FORMAT ">>>,>>9":U WIDTH 3.29
      int_ds_it_docto_xml.it_codigo FORMAT "x(16)":U WIDTH 8.57
      int_ds_it_docto_xml.item_do_forn FORMAT "x(60)":U WIDTH 11.86
      fnObsoleto(int_ds_it_docto_xml.it_codigo) @ c-cod-obsoleto FORMAT "x(16)":U WIDTH 8.57
      int_ds_it_docto_xml.xProd FORMAT "x(60)":U WIDTH 40
      int_ds_it_docto_xml.ncm FORMAT ">>>>>>>>9":U
      int_ds_it_docto_xml.cfop FORMAT ">>>>>9":U
      int_ds_it_docto_xml.cst_icms FORMAT ">9":U WIDTH 7.86
      int_ds_it_docto_xml.nat_operacao FORMAT "x(6)":U WIDTH 6.43
      int_ds_it_docto_xml.numero_ordem FORMAT "zzzzz9,99":U
      int_ds_it_docto_xml.Lote FORMAT "x(20)":U WIDTH 7.43
      int_ds_it_docto_xml.qCom_forn COLUMN-LABEL "Qtde" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 6.29
      int_ds_it_docto_xml.uCom_forn FORMAT "x(03)":U WIDTH 2.57
      int_ds_it_docto_xml.vUnCom FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 7.43
      int_ds_it_docto_xml.qCom FORMAT ">>>>,>>>,>>9.99999":U
      int_ds_it_docto_xml.uCom FORMAT "x(03)":U
      int_ds_it_docto_xml.vDesc FORMAT ">>>>,>>>,>>9.99":U WIDTH 9.57
      int_ds_it_docto_xml.vbc_ipi COLUMN-LABEL "Base IPI" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 10.29
      int_ds_it_docto_xml.pipi COLUMN-LABEL "% IPI" FORMAT ">>9.99":U
            WIDTH 4
      int_ds_it_docto_xml.vipi COLUMN-LABEL "Vlr IPI" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 5.14
      int_ds_it_docto_xml.vbc_icms COLUMN-LABEL "Base ICMS" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 8.86
      int_ds_it_docto_xml.picms COLUMN-LABEL "% ICMS" FORMAT ">>9.99":U
            WIDTH 5.43
      int_ds_it_docto_xml.predBc COLUMN-LABEL "% Red BC" FORMAT ">>9.99":U
            WIDTH 7
      int_ds_it_docto_xml.vicms COLUMN-LABEL "Vlr ICMS" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 7.43
      int_ds_it_docto_xml.vicmsdeson COLUMN-LABEL "Vlr ICMS Deson" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 10.72
      int_ds_it_docto_xml.vbcst COLUMN-LABEL "Base ST NF" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 10 LABEL-FGCOLOR 9
      int_ds_it_docto_xml.picmsst COLUMN-LABEL "Aliq ST NF" FORMAT ">>9.99":U
            WIDTH 9 LABEL-FGCOLOR 9
      int_ds_it_docto_xml.vicmsst COLUMN-LABEL "Vlr ST NF" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 7.43 LABEL-FGCOLOR 9
      int_ds_it_docto_xml.vPMC COLUMN-LABEL "Vlr PMC NF" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 10 LABEL-FGCOLOR 9
      int_ds_it_docto_xml.pmvast COLUMN-LABEL "%MVA NF" FORMAT ">>>9.99":U
            WIDTH 7 LABEL-FGCOLOR 9
      de-base-st-calc @ de-base-st-calc COLUMN-LABEL "Base ST Cad" FORMAT ">>>>,>>>,>>9.99":U
            LABEL-FGCOLOR 2
      de-perc-st-calc @ de-perc-st-calc COLUMN-LABEL "Aliq ST Cad" FORMAT ">>9.99":U
            WIDTH 9 LABEL-FGCOLOR 2
      de-valor-st-calc @ de-valor-st-calc COLUMN-LABEL "Vlr ST Cad" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 11.43 LABEL-FGCOLOR 2
      c-tabela-pauta @ c-tabela-pauta COLUMN-LABEL "Tabela Pauta" FORMAT "x(15)":U
            WIDTH 12 LABEL-FGCOLOR 2
      de-tabela-pauta @ de-tabela-pauta COLUMN-LABEL "Vlr PMC Cad" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 9 LABEL-FGCOLOR 2
      de-per-sub-tri @ de-per-sub-tri COLUMN-LABEL "%MVA Cad" FORMAT ">>9.99":U
            WIDTH 8 LABEL-FGCOLOR 2
      de-per-va-st @ de-per-va-st COLUMN-LABEL "% Red Cad" FORMAT ">>>9.99":U
            LABEL-FGCOLOR 2
      int_ds_it_docto_xml.vbc_pis COLUMN-LABEL "Vlr Base PIS" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 8.43
      int_ds_it_docto_xml.ppis COLUMN-LABEL "% PIS" FORMAT ">>9.99":U
            WIDTH 4.86
      int_ds_it_docto_xml.vpis COLUMN-LABEL "Vlr PIS" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 8.57
      int_ds_it_docto_xml.vbc_cofins COLUMN-LABEL "Base Cofins" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 10.86
      int_ds_it_docto_xml.pcofins COLUMN-LABEL "% Cofins" FORMAT ">>9.99":U
            WIDTH 6.43
      int_ds_it_docto_xml.vcofins COLUMN-LABEL "Vlr Cofins" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 9
      int_ds_it_docto_xml.vOutro FORMAT ">>>>,>>>,>>9.99":U
      int_ds_it_docto_xml.vProd FORMAT ">>>>,>>>,>>9.99":U WIDTH 13.72
  ENABLE
      int_ds_it_docto_xml.ncm
      int_ds_it_docto_xml.cfop
      int_ds_it_docto_xml.cst_icms
      int_ds_it_docto_xml.nat_operacao
      int_ds_it_docto_xml.numero_ordem
      int_ds_it_docto_xml.Lote
      int_ds_it_docto_xml.qCom_forn
      int_ds_it_docto_xml.vUnCom
      int_ds_it_docto_xml.vDesc
      int_ds_it_docto_xml.vbc_ipi
      int_ds_it_docto_xml.pipi
      int_ds_it_docto_xml.vipi
      int_ds_it_docto_xml.vbc_icms
      int_ds_it_docto_xml.picms
      int_ds_it_docto_xml.predBc
      int_ds_it_docto_xml.vicms
      int_ds_it_docto_xml.vicmsdeson
      int_ds_it_docto_xml.vbcst
      int_ds_it_docto_xml.vicmsst
      int_ds_it_docto_xml.vbc_pis
      int_ds_it_docto_xml.ppis
      int_ds_it_docto_xml.vpis
      int_ds_it_docto_xml.vbc_cofins
      int_ds_it_docto_xml.pcofins
      int_ds_it_docto_xml.vcofins
      int_ds_it_docto_xml.vOutro
      int_ds_it_docto_xml.vProd
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 142.57 BY 10
         FONT 1 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     br-table AT ROW 1 COL 1
 //   bt-incluir AT ROW 11 COL 2 WIDGET-ID 4
 //    bt-modificar AT ROW 11 COL 13
 //    bt-altera-browse AT ROW 11 COL 24 WIDGET-ID 2
 //    bt-eliminar AT ROW 11 COL 41 WIDGET-ID 6
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: BrowserCadastro2
   External Tables: custom.int_ds_docto_xml
   Allow: Basic,Browse
   Frames: 1
   Add Fields to: External-Tables
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW B-table-Win ASSIGN
         HEIGHT             = 11.08
         WIDTH              = 142.57.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB B-table-Win 
/* ************************* Included-Libraries *********************** */

{utp/ut-glob.i}
{src/adm/method/browser.i}
{include/c-brows3.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW B-table-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit L-To-R                            */
/* BROWSE-TAB br-table 1 F-Main */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN 
       br-table:NUM-LOCKED-COLUMNS IN FRAME F-Main     = 5
       br-table:COLUMN-RESIZABLE IN FRAME F-Main       = TRUE
       br-table:COLUMN-MOVABLE IN FRAME F-Main         = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "custom.int_ds_it_docto_xml WHERE custom.int_ds_docto_xml <external> ..."
     _Options          = "NO-LOCK KEY-PHRASE SORTBY-PHRASE"
     _JoinCode[1]      = "custom.int_ds_it_docto_xml.cod_emitente = custom.int_ds_docto_xml.cod_emitente
  AND custom.int_ds_it_docto_xml.serie = custom.int_ds_docto_xml.serie
  AND custom.int_ds_it_docto_xml.nNF = custom.int_ds_docto_xml.nNF
  AND custom.int_ds_it_docto_xml.tipo_nota = custom.int_ds_docto_xml.tipo_nota"
     _FldNameList[1]   > custom.int_ds_it_docto_xml.sequencia
"int_ds_it_docto_xml.sequencia" ? ? "integer" ? ? ? ? ? ? no ? no no "3.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > custom.int_ds_it_docto_xml.it-codigo
"int_ds_it_docto_xml.it-codigo" ? ? "character" ? ? ? ? ? ? no ? no no "8.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > custom.int_ds_it_docto_xml.item-do-forn
"int_ds_it_docto_xml.item-do-forn" ? ? "character" ? ? ? ? ? ? no ? no no "11.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"fnObsoleto(int_ds_it_docto_xml.it-codigo) @ c-cod-obsoleto" ? ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > custom.int_ds_it_docto_xml.xProd
"int_ds_it_docto_xml.xProd" ? ? "character" ? ? ? ? ? ? no ? no no "40" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > custom.int_ds_it_docto_xml.ncm
"int_ds_it_docto_xml.ncm" ? ">>>>>>>>9" "integer" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > custom.int_ds_it_docto_xml.cfop
"int_ds_it_docto_xml.cfop" ? ? "integer" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > custom.int_ds_it_docto_xml.cst-icms
"int_ds_it_docto_xml.cst-icms" ? ? "integer" ? ? ? ? ? ? yes ? no no "7.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > custom.int_ds_it_docto_xml.nat-operacao
"int_ds_it_docto_xml.nat-operacao" ? ? "character" ? ? ? ? ? ? yes ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > custom.int_ds_it_docto_xml.numero-ordem
"int_ds_it_docto_xml.numero-ordem" ? ? "integer" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > custom.int_ds_it_docto_xml.Lote
"int_ds_it_docto_xml.Lote" ? ? "character" ? ? ? ? ? ? yes ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > custom.int_ds_it_docto_xml.qCom-forn
"int_ds_it_docto_xml.qCom-forn" "Qtde" ? "decimal" ? ? ? ? ? ? yes ? no no "6.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   > custom.int_ds_it_docto_xml.uCom-forn
"int_ds_it_docto_xml.uCom-forn" ? ? "character" ? ? ? ? ? ? no ? no no "2.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[14]   > custom.int_ds_it_docto_xml.vUnCom
"int_ds_it_docto_xml.vUnCom" ? ? "decimal" ? ? ? ? ? ? yes ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[15]   = custom.int_ds_it_docto_xml.qCom
     _FldNameList[16]   = custom.int_ds_it_docto_xml.uCom
     _FldNameList[17]   > custom.int_ds_it_docto_xml.vDesc
"int_ds_it_docto_xml.vDesc" ? ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "9.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[18]   > custom.int_ds_it_docto_xml.vbc-ipi
"int_ds_it_docto_xml.vbc-ipi" "Base IPI" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "10.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[19]   > custom.int_ds_it_docto_xml.pipi
"int_ds_it_docto_xml.pipi" "% IPI" ? "decimal" ? ? ? ? ? ? yes ? no no "4" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[20]   > custom.int_ds_it_docto_xml.vipi
"int_ds_it_docto_xml.vipi" "Vlr IPI" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "5.14" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[21]   > custom.int_ds_it_docto_xml.vbc-icms
"int_ds_it_docto_xml.vbc-icms" "Base ICMS" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "8.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[22]   > custom.int_ds_it_docto_xml.picms
"int_ds_it_docto_xml.picms" "% ICMS" ? "decimal" ? ? ? ? ? ? yes ? no no "5.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[23]   > custom.int_ds_it_docto_xml.predBc
"int_ds_it_docto_xml.predBc" "% Red BC" ">>9.99" "decimal" ? ? ? ? ? ? yes ? no no "7" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[24]   > custom.int_ds_it_docto_xml.vicms
"int_ds_it_docto_xml.vicms" "Vlr ICMS" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[25]   > custom.int_ds_it_docto_xml.vicmsdeson
"int_ds_it_docto_xml.vicmsdeson" "Vlr ICMS Deson" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "10.72" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[26]   > custom.int_ds_it_docto_xml.vbcst
"int_ds_it_docto_xml.vbcst" "Base ST NF" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? yes ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[27]   > custom.int_ds_it_docto_xml.picmsst
"int_ds_it_docto_xml.picmsst" "Aliq ST NF" ? "decimal" ? ? ? ? 9 ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[28]   > custom.int_ds_it_docto_xml.vicmsst
"int_ds_it_docto_xml.vicmsst" "Vlr ST NF" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? yes ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[29]   > custom.int_ds_it_docto_xml.vPMC
"int_ds_it_docto_xml.vPMC" "Vlr PMC NF" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[30]   > custom.int_ds_it_docto_xml.pmvast
"int_ds_it_docto_xml.pmvast" "%MVA NF" ? "decimal" ? ? ? ? 9 ? no ? no no "7" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[31]   > "_<CALC>"
"de-base-st-calc @ de-base-st-calc" "Base ST Cad" ">>>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[32]   > "_<CALC>"
"de-perc-st-calc @ de-perc-st-calc" "Aliq ST Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[33]   > "_<CALC>"
"de-valor-st-calc @ de-valor-st-calc" "Vlr ST Cad" ">>>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "11.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[34]   > "_<CALC>"
"c-tabela-pauta @ c-tabela-pauta" "Tabela Pauta" "x(15)" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[35]   > "_<CALC>"
"de-tabela-pauta @ de-tabela-pauta" "Vlr PMC Cad" ">>>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[36]   > "_<CALC>"
"de-per-sub-tri @ de-per-sub-tri" "%MVA Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[37]   > "_<CALC>"
"de-per-va-st @ de-per-va-st" "% Red Cad" ">>>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[38]   > custom.int_ds_it_docto_xml.vbc-pis
"int_ds_it_docto_xml.vbc-pis" "Vlr Base PIS" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "8.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[39]   > custom.int_ds_it_docto_xml.ppis
"int_ds_it_docto_xml.ppis" "% PIS" ? "decimal" ? ? ? ? ? ? yes ? no no "4.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[40]   > custom.int_ds_it_docto_xml.vpis
"int_ds_it_docto_xml.vpis" "Vlr PIS" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "8.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[41]   > custom.int_ds_it_docto_xml.vbc-cofins
"int_ds_it_docto_xml.vbc-cofins" "Base Cofins" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "10.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[42]   > custom.int_ds_it_docto_xml.pcofins
"int_ds_it_docto_xml.pcofins" "% Cofins" ? "decimal" ? ? ? ? ? ? yes ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[43]   > custom.int_ds_it_docto_xml.vcofins
"int_ds_it_docto_xml.vcofins" "Vlr Cofins" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[44]   > custom.int_ds_it_docto_xml.vOutro
"int_ds_it_docto_xml.vOutro" ? ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[45]   > custom.int_ds_it_docto_xml.vProd
"int_ds_it_docto_xml.vProd" ? ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? yes ? no no "13.72" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON MOUSE-SELECT-DBLCLICK OF br-table IN FRAME F-Main
DO:
    RUN New-State("DblClick, SELF":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-DISPLAY OF br-table IN FRAME F-Main
DO:
    ASSIGN c-tabela-pauta = fn-base-st-nf()
           de-per-va-st   = fn-perc-va-st().
    
    ASSIGN de-base-st-calc :SCREEN-VALUE IN BROWSE br-table = STRING(de-base-st-calc )
           c-tabela-pauta  :SCREEN-VALUE IN BROWSE br-table = STRING(c-tabela-pauta  )
           de-valor-st-calc:SCREEN-VALUE IN BROWSE br-table = STRING(de-valor-st-calc)
           de-tabela-pauta :SCREEN-VALUE IN BROWSE br-table = STRING(de-tabela-pauta )
           de-per-sub-tri  :SCREEN-VALUE IN BROWSE br-table = STRING(de-per-sub-tri  ).

    if int_ds_it_docto_xml.numero_ordem = 0 then
        int_ds_it_docto_xml.numero_ordem:bgcolor in browse br-table = 14.
    else 
        int_ds_it_docto_xml.numero_ordem:bgcolor in browse br-table = ?.

    if not can-find(first classif-fisc no-lock where 
        classif-fisc.class-fiscal = trim(string(int_ds_it_docto_xml.ncm,"99999999"))) then
        int_ds_it_docto_xml.ncm:bgcolor in browse br-table = 14.
    else 
        int_ds_it_docto_xml.ncm:bgcolor in browse br-table = ?.

    if not can-find(first cfop-natur no-lock where 
        cfop-natur.cod-cfop = trim(string(int_ds_it_docto_xml.cfop,"9999"))) then
        int_ds_it_docto_xml.cfop:bgcolor in browse br-table = 14.
    else 
        int_ds_it_docto_xml.cfop:bgcolor in browse br-table = ?.

    if trim(string(int_ds_it_docto_xml.cfop,"9999")) begins "1" or
       trim(string(int_ds_it_docto_xml.cfop,"9999")) begins "2" or
       trim(string(int_ds_it_docto_xml.cfop,"9999")) begins "3" then
        int_ds_it_docto_xml.cfop:bgcolor in browse br-table = 14.
    else 
        int_ds_it_docto_xml.cfop:bgcolor in browse br-table = ?.

    if not can-find(first natur-oper no-lock where 
        natur-oper.nat-operacao = trim(int_ds_it_docto_xml.nat_operacao)) then
        int_ds_it_docto_xml.nat_operacao:bgcolor in browse br-table = 14.
    else 
        int_ds_it_docto_xml.nat_operacao:bgcolor in browse br-table = ?.

    if int_ds_it_docto_xml.uCom_forn = "" or
       int_ds_it_docto_xml.uCom_forn = ? or
       trim(string(int_ds_it_docto_xml.uCom_forn)) = "?" then
        int_ds_it_docto_xml.uCom_forn:bgcolor in browse br-table = 14.
    else 
        int_ds_it_docto_xml.uCom_forn:bgcolor in browse br-table = ?.

    if int_ds_it_docto_xml.uCom = "" or
       int_ds_it_docto_xml.uCom = ? or
       trim(string(int_ds_it_docto_xml.uCom)) = "?" then
        int_ds_it_docto_xml.uCom:bgcolor in browse br-table = 14.
    else 
        int_ds_it_docto_xml.uCom:bgcolor in browse br-table = ?.

    if int_ds_it_docto_xml.cst_icms = ? then
        int_ds_it_docto_xml.cst_icms:bgcolor in browse br-table = 14.
    else 
        int_ds_it_docto_xml.cst_icms:bgcolor in browse br-table = ?.

    ASSIGN int_ds_it_docto_xml.vbcst  :BGCOLOR   IN BROWSE br-table = ?
           int_ds_it_docto_xml.picmsst:BGCOLOR   IN BROWSE br-table = ?
           int_ds_it_docto_xml.vicmsst:BGCOLOR   IN BROWSE br-table = ?
           int_ds_it_docto_xml.vpmc   :BGCOLOR   IN BROWSE br-table = ?
           int_ds_it_docto_xml.pmvast :BGCOLOR   IN BROWSE br-table = ?
           int_ds_it_docto_xml.predbc :BGCOLOR   IN BROWSE br-table = ?
           de-base-st-calc            :BGCOLOR   IN BROWSE br-table = ?
           de-perc-st-calc            :BGCOLOR   IN BROWSE br-table = ?
           de-valor-st-calc           :BGCOLOR   IN BROWSE br-table = ?
           c-tabela-pauta             :BGCOLOR   IN BROWSE br-table = ?
           de-tabela-pauta            :BGCOLOR   IN BROWSE br-table = ?
           de-per-sub-tri             :BGCOLOR   IN BROWSE br-table = ?
           de-per-va-st               :BGCOLOR   IN BROWSE br-table = ?.

    FOR FIRST natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = int_ds_it_docto_xml.nat_operacao QUERY-TUNING(NO-LOOKAHEAD):

        IF  natur-oper.subs-trib
        THEN DO:
            IF  int_ds_it_docto_xml.vbcst <> de-base-st-calc
            THEN
                ASSIGN int_ds_it_docto_xml.vbcst:bgcolor in browse br-table = 14
                       de-base-st-calc          :bgcolor in browse br-table = 14.

            IF  int_ds_it_docto_xml.picmsst <> de-perc-st-calc
            THEN
                ASSIGN int_ds_it_docto_xml.picmsst:bgcolor in browse br-table = 14
                       de-perc-st-calc            :BGCOLOR in browse br-table = 14.

            IF  int_ds_it_docto_xml.vicmsst <> de-valor-st-calc
            THEN
                ASSIGN int_ds_it_docto_xml.vicmsst:bgcolor in browse br-table = 14
                       de-valor-st-calc           :bgcolor in browse br-table = 14.

            IF  c-tabela-pauta           <> "" AND 
                int_ds_it_docto_xml.vpmc <> de-tabela-pauta
            THEN
                ASSIGN int_ds_it_docto_xml.vpmc:bgcolor in browse br-table = 14
                       de-tabela-pauta         :bgcolor in browse br-table = 14
                       c-tabela-pauta          :bgcolor in browse br-table = 14.

            IF  int_ds_it_docto_xml.pmvast <> de-per-sub-tri
            THEN
                ASSIGN int_ds_it_docto_xml.pmvast:bgcolor in browse br-table = 14
                       de-per-sub-tri            :bgcolor in browse br-table = 14.

/*             IF  int_ds_it_docto_xml.predbc <> de-per-va-st                         */
/*             THEN                                                                   */
/*                 ASSIGN int_ds_it_docto_xml.predbc:bgcolor in browse br-table = 14  */
/*                        de-per-va-st              :bgcolor in browse br-table = 14. */
        END.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-ENTRY OF br-table IN FRAME F-Main
DO:
  /* This code displays initial values for newly added or copied rows. */
  {src/adm/template/brsentry.i}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-LEAVE OF br-table IN FRAME F-Main
DO:
    /* Do not disable this code or no updates will take place except
     by pressing the Save button on an Update SmartPanel. */
   {src/adm/template/brsleave.i}
    define buffer b-int_ds_it_docto_xml for int_ds_it_docto_xml.

    if avail int_ds_it_docto_xml and 
       avail int_ds_docto_xml and
       not browse br-table:read-only then do:

       for each b-int_ds_it_docto_xml exclusive-lock where
           rowid(b-int_ds_it_docto_xml) = rowid(int_ds_docto_xml) QUERY-TUNING(NO-LOOKAHEAD):
            assign  b-int_ds_it_docto_xml.cfop            = input browse br-table int_ds_it_docto_xml.cfop         
                    b-int_ds_it_docto_xml.cst_icms        = input browse br-table int_ds_it_docto_xml.cst_icms     
                    b-int_ds_it_docto_xml.nat_operacao    = input browse br-table int_ds_it_docto_xml.nat_operacao 
                    b-int_ds_it_docto_xml.pcofins         = input browse br-table int_ds_it_docto_xml.pcofins      
                    b-int_ds_it_docto_xml.picms           = input browse br-table int_ds_it_docto_xml.picms        
                    b-int_ds_it_docto_xml.pipi            = input browse br-table int_ds_it_docto_xml.pipi         
/*                     b-int_ds_it_docto_xml.pmvast          = input browse br-table int_ds_it_docto_xml.pmvast  */
                    b-int_ds_it_docto_xml.ppis            = input browse br-table int_ds_it_docto_xml.ppis         
                    b-int_ds_it_docto_xml.predBc          = input browse br-table int_ds_it_docto_xml.predBc       
                    b-int_ds_it_docto_xml.qCom_forn       = input browse br-table int_ds_it_docto_xml.qCom_forn    
                    b-int_ds_it_docto_xml.uCom_forn       = input browse br-table int_ds_it_docto_xml.uCom_forn    
                    b-int_ds_it_docto_xml.vbc_cofins      = input browse br-table int_ds_it_docto_xml.vbc_cofins   
                    b-int_ds_it_docto_xml.vbc_icms        = input browse br-table int_ds_it_docto_xml.vbc_icms     
                    b-int_ds_it_docto_xml.vbc_ipi         = input browse br-table int_ds_it_docto_xml.vbc_ipi      
                    b-int_ds_it_docto_xml.vbc_pis         = input browse br-table int_ds_it_docto_xml.vbc_pis      
                    b-int_ds_it_docto_xml.vbcst           = input browse br-table int_ds_it_docto_xml.vbcst  
                    b-int_ds_it_docto_xml.numero_ordem    = input browse br-table int_ds_it_docto_xml.numero_ordem

                    /*b-int_ds_it_docto_xml.vbcstret        = input browse br-table int_ds_it_docto_xml.vbcstret     */
                    b-int_ds_it_docto_xml.vcofins         = input browse br-table int_ds_it_docto_xml.vcofins      
                    b-int_ds_it_docto_xml.vDesc           = input browse br-table int_ds_it_docto_xml.vDesc        
                    b-int_ds_it_docto_xml.vicms           = input browse br-table int_ds_it_docto_xml.vicms        
                    b-int_ds_it_docto_xml.vicmsdeson      = input browse br-table int_ds_it_docto_xml.vicmsdeson   
                    b-int_ds_it_docto_xml.vicmsst         = input browse br-table int_ds_it_docto_xml.vicmsst      
                    /*b-int_ds_it_docto_xml.vicmsstret      = input browse br-table int_ds_it_docto_xml.vicmsstret   */
                    b-int_ds_it_docto_xml.vipi            = input browse br-table int_ds_it_docto_xml.vipi         
                    b-int_ds_it_docto_xml.vOutro          = input browse br-table int_ds_it_docto_xml.vOutro       
                    b-int_ds_it_docto_xml.vpis            = input browse br-table int_ds_it_docto_xml.vpis         
                    b-int_ds_it_docto_xml.vPMC            = input browse br-table de-tabela-pauta         
                    b-int_ds_it_docto_xml.vProd           = input browse br-table int_ds_it_docto_xml.vProd        
                    b-int_ds_it_docto_xml.vUnCom          = input browse br-table int_ds_it_docto_xml.vUnCom
                    b-int_ds_it_docto_xml.NCM             = input browse br-table int_ds_it_docto_xml.NCM.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON VALUE-CHANGED OF br-table IN FRAME F-Main
DO:
  /* This ADM trigger code must be preserved in order to notify other
     objects when the browser's current row changes. */
  {src/adm/template/brschnge.i}
  /* run new-state('New-Line|':U + string(rowid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}))). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*
&Scoped-define SELF-NAME bt-altera-browse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-altera-browse B-table-Win
ON CHOOSE OF bt-altera-browse IN FRAME F-Main /* Alterar no Grid */
DO:
    RUN pi-valida-usuario.
    if return-value = "ADM-ERROR":U then do:
        assign browse br-table:read-only = yes.
        return no-apply.
    end.
  
    RUN pi-valida-situacao.
    if return-value = "ADM-ERROR":U then do:
        assign browse br-table:read-only = yes.
        return no-apply.
    end.

    assign browse br-table:read-only = no.
    if can-find (first usuar_grp_usuar no-lock where 
                 usuar_grp_usuar.cod_usuario = c-seg-usuario and
                 usuar_grp_usuar.cod_grp_usuar = "TAX") then 
        assign int_ds_it_docto_xml.pcofins   :read-only in browse br-table = no
               int_ds_it_docto_xml.ppis      :read-only in browse br-table = no
               int_ds_it_docto_xml.vbc_cofins:read-only in browse br-table = no
               int_ds_it_docto_xml.vbc_pis   :read-only in browse br-table = no
               int_ds_it_docto_xml.vcofins   :read-only in browse br-table = no
               int_ds_it_docto_xml.vpis      :read-only in browse br-table = no.
    else 
        assign int_ds_it_docto_xml.pcofins   :read-only in browse br-table = yes
               int_ds_it_docto_xml.ppis      :read-only in browse br-table = yes
               int_ds_it_docto_xml.vbc_cofins:read-only in browse br-table = yes
               int_ds_it_docto_xml.vbc_pis   :read-only in browse br-table = yes
               int_ds_it_docto_xml.vcofins   :read-only in browse br-table = yes
               int_ds_it_docto_xml.vpis      :read-only in browse br-table = yes.

    if i-sit-re >= 10 and i-sit-re <> 60 then do:

        assign  int_ds_it_docto_xml.qCom_forn:read-only in browse br-table = yes.
        
        if i-sit-re = 40 then do:
            assign 
                int_ds_it_docto_xml.pcofins     :read-only in browse br-table = yes
                int_ds_it_docto_xml.picms       :read-only in browse br-table = yes
                int_ds_it_docto_xml.pipi        :read-only in browse br-table = yes
                int_ds_it_docto_xml.ppis        :read-only in browse br-table = yes
                int_ds_it_docto_xml.predBc      :read-only in browse br-table = yes
                int_ds_it_docto_xml.vbc_cofins  :read-only in browse br-table = yes
                int_ds_it_docto_xml.vbc_icms    :read-only in browse br-table = yes
                int_ds_it_docto_xml.vbc_ipi     :read-only in browse br-table = yes
                int_ds_it_docto_xml.vbc_pis     :read-only in browse br-table = yes
                int_ds_it_docto_xml.vbcst       :read-only in browse br-table = yes
                int_ds_it_docto_xml.vcofins     :read-only in browse br-table = yes
                int_ds_it_docto_xml.vDesc       :read-only in browse br-table = yes
                int_ds_it_docto_xml.vicms       :read-only in browse br-table = yes
                int_ds_it_docto_xml.vicmsdeson  :read-only in browse br-table = yes
                int_ds_it_docto_xml.vicmsst     :read-only in browse br-table = yes
                int_ds_it_docto_xml.vipi        :read-only in browse br-table = yes
                int_ds_it_docto_xml.vOutro      :read-only in browse br-table = yes
                int_ds_it_docto_xml.vpis        :read-only in browse br-table = yes
                int_ds_it_docto_xml.vProd       :read-only in browse br-table = yes.
        end.                                    
    end.
    apply "entry":u to int_ds_it_docto_xml.ncm in browse br-table.
END.
*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*
&Scoped-define SELF-NAME bt-eliminar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-eliminar B-table-Win
ON CHOOSE OF bt-eliminar IN FRAME F-Main /* Eliminar */
DO:
    RUN pi-valida-usuario.
    if return-value = "ADM-ERROR":U then do:
        assign browse br-table:read-only = yes.
        return no-apply.
    end.
  
    RUN pi-valida-situacao.
    if return-value = "ADM-ERROR":U then do:
        assign browse br-table:read-only = yes.
        return no-apply.
    end.
    if i-sit-re >= 10 and i-sit-re <> 60 then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi enviada para conferància no WMS. Inclus∆o de itens n∆o ser† permitida.")).
        return "ADM-ERROR":U.
    end.
    RUN pi-eliminar.
END.
*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*
&Scoped-define SELF-NAME bt-incluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-incluir B-table-Win
ON CHOOSE OF bt-incluir IN FRAME F-Main /* Incluir */
DO:
  
    RUN pi-valida-usuario.
    if return-value = "ADM-ERROR":U then do:
        assign browse br-table:read-only = yes.
        return no-apply.
    end.
  
    RUN pi-valida-situacao.
    if return-value = "ADM-ERROR":U then do:
        assign browse br-table:read-only = yes.
        return no-apply.
    end.
    if i-sit-re >= 10 and i-sit-re <> 60 then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi enviada para conferància no WMS. Inclus∆o de itens n∆o ser† permitida.")).
        return "ADM-ERROR":U.
    end.
    RUN pi-Incmod ('incluir':U).
END.
*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*
&Scoped-define SELF-NAME bt-modificar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-modificar B-table-Win
ON CHOOSE OF bt-modificar IN FRAME F-Main /* Modificar */
DO:
    RUN pi-valida-usuario.
    if return-value = "ADM-ERROR":U then do:
        assign browse br-table:read-only = yes.
        return no-apply.
    end.
  
    /*
    RUN pi-valida-situacao.
    if return-value = "ADM-ERROR":U then do:
        assign browse br-table:read-only = yes.
        return no-apply.
    end.
    */

    RUN pi-Incmod ('modificar':U).
END.
*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK B-table-Win 


/* ***************************  Main Block  *************************** */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
RUN dispatch IN THIS-PROCEDURE ('initialize':U). 

ASSIGN de-base-st-calc  = 0
       de-valor-st-calc = 0
       de-perc-st-calc  = 0
       de-tabela-pauta  = 0
       de-per-sub-tri   = 0
       de-per-va-st     = 0
       c-tabela-pauta   = "".

&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available B-table-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI B-table-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-row-available B-table-Win 
PROCEDURE local-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'row-available':U ) .

  apply "LEAVE":U to browse br-table.
  //apply "FOCUS":U to bt-altera-browse in frame {&frame-name}.
  assign browse br-table:read-only = yes.
 // assign bt-altera-browse:sensitive = bt-modificar:sensitive.
  RUN pi-refresh.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-view B-table-Win 
PROCEDURE local-view :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'view':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  apply 'value-changed':U to {&browse-name} in frame {&frame-name}.

  /* compras n∆o pode alterar documento */
  if can-find (first usuar_grp_usuar no-lock where 
               usuar_grp_usuar.cod_usuario = c-seg-usuario and
               usuar_grp_usuar.cod_grp_usuar = "X23" and
               c-seg-usuario <> "999909") then do:
      //assign bt-modificar:sensitive in FRAME {&FRAME-NAME} = no.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-busca-docto-wms B-table-Win 
PROCEDURE pi-busca-docto-wms :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

      i-sit-re = 0.
      for each int_ds_docto_wms no-lock where
          int_ds_docto_wms.doc_numero_n = int_ds_docto_xml.nNF and
          int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie and
          int_ds_docto_wms.doc_origem_n = int_ds_docto_xml.cod_emitente
          by int_ds_docto_wms.id_sequencial desc
          query-tuning(no-lookahead):
          assign i-sit-re = int_ds_docto_wms.situacao.
          leave.
      end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-refresh B-table-Win 
PROCEDURE pi-refresh :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    def var i-ind as integer no-undo.
    if br-table:num-entries in frame {&frame-name} > 0 then
    do i-ind = 1 to browse br-table:NUM-ENTRIES:
        browse br-table:SELECT-ROW(i-ind).
        browse br-table:FETCH-SELECTED-ROW(1).
        if avail int_ds_it_docto_xml then do:
            assign 
                int_ds_it_docto_xml.cfop         :screen-value in browse br-table = string(int_ds_it_docto_xml.cfop         )
                int_ds_it_docto_xml.cst_icms     :screen-value in browse br-table = string(int_ds_it_docto_xml.cst_icms     )
                int_ds_it_docto_xml.nat_operacao :screen-value in browse br-table = string(int_ds_it_docto_xml.nat_operacao )
                int_ds_it_docto_xml.ncm          :screen-value in browse br-table = string(int_ds_it_docto_xml.ncm          )
                int_ds_it_docto_xml.numero_ordem :screen-value in browse br-table = string(int_ds_it_docto_xml.numero_ordem )
                int_ds_it_docto_xml.pcofins      :screen-value in browse br-table = string(int_ds_it_docto_xml.pcofins      )
                int_ds_it_docto_xml.picms        :screen-value in browse br-table = string(int_ds_it_docto_xml.picms        )
                int_ds_it_docto_xml.pipi         :screen-value in browse br-table = string(int_ds_it_docto_xml.pipi         )
/*                 int_ds_it_docto_xml.pmvast       :screen-value in browse br-table = string(int_ds_it_docto_xml.pmvast       )  */
                int_ds_it_docto_xml.ppis         :screen-value in browse br-table = string(int_ds_it_docto_xml.ppis         ) 
                int_ds_it_docto_xml.predBc       :screen-value in browse br-table = string(int_ds_it_docto_xml.predBc       ) 
                int_ds_it_docto_xml.qCom         :screen-value in browse br-table = string(int_ds_it_docto_xml.qCom         ) 
                int_ds_it_docto_xml.qCom_forn    :screen-value in browse br-table = string(int_ds_it_docto_xml.qCom_forn    ) 
                int_ds_it_docto_xml.uCom         :screen-value in browse br-table = string(int_ds_it_docto_xml.uCom         ) 
                int_ds_it_docto_xml.uCom_forn    :screen-value in browse br-table = string(int_ds_it_docto_xml.uCom_forn    ) 
                int_ds_it_docto_xml.vbc_cofins   :screen-value in browse br-table = string(int_ds_it_docto_xml.vbc_cofins   ) 
                int_ds_it_docto_xml.vbc_icms     :screen-value in browse br-table = string(int_ds_it_docto_xml.vbc_icms     ) 
                int_ds_it_docto_xml.vbc_ipi      :screen-value in browse br-table = string(int_ds_it_docto_xml.vbc_ipi      ) 
                int_ds_it_docto_xml.vbc_pis      :screen-value in browse br-table = string(int_ds_it_docto_xml.vbc_pis      ) 
                int_ds_it_docto_xml.vbcst        :screen-value in browse br-table = string(int_ds_it_docto_xml.vbcst        ) 
                int_ds_it_docto_xml.vcofins      :screen-value in browse br-table = string(int_ds_it_docto_xml.vcofins      ) 
                int_ds_it_docto_xml.vDesc        :screen-value in browse br-table = string(int_ds_it_docto_xml.vDesc        ) 
                int_ds_it_docto_xml.vicms        :screen-value in browse br-table = string(int_ds_it_docto_xml.vicms        ) 
                int_ds_it_docto_xml.vicmsdeson   :screen-value in browse br-table = string(int_ds_it_docto_xml.vicmsdeson   ) 
                int_ds_it_docto_xml.vicmsst      :screen-value in browse br-table = string(int_ds_it_docto_xml.vicmsst      ) 
                int_ds_it_docto_xml.vipi         :screen-value in browse br-table = string(int_ds_it_docto_xml.vipi         ) 
                int_ds_it_docto_xml.vOutro       :screen-value in browse br-table = string(int_ds_it_docto_xml.vOutro       ) 
                int_ds_it_docto_xml.vpis         :screen-value in browse br-table = string(int_ds_it_docto_xml.vpis         ) 
/*                 de-tabela-pauta                  :screen-value in browse br-table = string(de-tabela-pauta                  )  */
                int_ds_it_docto_xml.vProd        :screen-value in browse br-table = string(int_ds_it_docto_xml.vProd        ) 
                int_ds_it_docto_xml.vUnCom       :screen-value in browse br-table = string(int_ds_it_docto_xml.vUnCom       ) 
                int_ds_it_docto_xml.xProd        :screen-value in browse br-table = string(int_ds_it_docto_xml.xProd        ).

            /*
            display int_ds_it_docto_xml.cfop         
                    int_ds_it_docto_xml.cst-icms     
                    int_ds_it_docto_xml.nat-operacao 
                    int_ds_it_docto_xml.ncm          
                    /*int_ds_it_docto_xml.numero-ordem */
                    int_ds_it_docto_xml.pcofins      
                    int_ds_it_docto_xml.picms        
                    int_ds_it_docto_xml.picmsst      
                    int_ds_it_docto_xml.pipi         
                    int_ds_it_docto_xml.pmvast       
                    int_ds_it_docto_xml.ppis         
                    int_ds_it_docto_xml.predBc       
                    int_ds_it_docto_xml.qCom         
                    int_ds_it_docto_xml.qCom-forn    
                    int_ds_it_docto_xml.uCom         
                    int_ds_it_docto_xml.uCom-forn    
                    int_ds_it_docto_xml.vbc-cofins   
                    int_ds_it_docto_xml.vbc-icms     
                    int_ds_it_docto_xml.vbc-ipi      
                    int_ds_it_docto_xml.vbc-pis      
                    int_ds_it_docto_xml.vbcst        
                    int_ds_it_docto_xml.vcofins      
                    int_ds_it_docto_xml.vDesc        
                    int_ds_it_docto_xml.vicms        
                    int_ds_it_docto_xml.vicmsdeson   
                    int_ds_it_docto_xml.vicmsst      
                    int_ds_it_docto_xml.vipi         
                    int_ds_it_docto_xml.vOutro       
                    int_ds_it_docto_xml.vpis         
                    int_ds_it_docto_xml.vPMC         
                    int_ds_it_docto_xml.vProd        
                    int_ds_it_docto_xml.vUnCom       
                    int_ds_it_docto_xml.xProd    
                with browse br-table.
                */
            apply "row-display":u to br-table.
        end.
    end.
                              
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-valida-situacao B-table-Win 
PROCEDURE pi-valida-situacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    RUN pi-busca-docto-wms. 
    /*
    if (i-sit-re >= 25 /* conferida wms */ and
        i-sit-re <> 60 /* cancelada wms */)
    then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi conferida no WMS. Alteraá‰es n∆o ser∆o permitidas.")).
        return "ADM-ERROR":U.
    end.
    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-valida-usuario B-table-Win 
PROCEDURE pi-valida-usuario :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    if can-find (first usuar_grp_usuar no-lock where 
                 usuar_grp_usuar.cod_grp_usuar = "ZZZ") then return "OK":U.


    /* compras n∆o pode alterar documento */
    if can-find (first usuar_grp_usuar no-lock where 
                 usuar_grp_usuar.cod_usuario = c-seg-usuario and
                 usuar_grp_usuar.cod_grp_usuar = "X23")
    then do:
        return "ADM-ERROR":U.
    end.  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records B-table-Win  _ADM-SEND-RECORDS
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
  {src/adm/template/snd-list.i "int_ds_it_docto_xml"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed B-table-Win 
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
      {src/adm/template/bstates.i}
  END CASE.
  run pi-trata-state (p-issuer-hdl, p-state).

  IF  p-state = "record-available"
  THEN
      RUN pi-refresh.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-base-st-nf B-table-Win 
FUNCTION fn-base-st-nf RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    ASSIGN de-base-st-calc  = 0
           de-valor-st-calc = 0
           de-perc-st-calc  = 0
           de-tabela-pauta  = 0
           de-per-sub-tri   = 0
           c-tabela-pauta   = "".

    IF  AVAIL int_ds_it_docto_xml
    THEN DO:
        ASSIGN de-tabela-pauta = int_ds_it_docto_xml.vpmc.

        FOR FIRST natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao = int_ds_it_docto_xml.nat_operacao QUERY-TUNING(NO-LOOKAHEAD):

            IF  natur-oper.subs-trib = YES 
            THEN DO:
                RUN intprg/int580-icms-st.p (INPUT int_ds_it_docto_xml.cod_emitente,
                                             INPUT int_ds_it_docto_xml.it_codigo,   
                                             INPUT int_ds_it_docto_xml.nat_operacao,
                                             INPUT int_ds_docto_xml.cod_estab,        
                                             INPUT int_ds_it_docto_xml.qCom,        
                                             INPUT int_ds_it_docto_xml.vprod,    
                                             INPUT int_ds_it_docto_xml.vdesc,       
                                             INPUT int_ds_it_docto_xml.vipi,
                                             OUTPUT de-base-st-calc, 
                                             OUTPUT de-valor-st-calc, 
                                             OUTPUT de-perc-st-calc,
                                             OUTPUT c-tabela-pauta,
                                             OUTPUT de-tabela-pauta,
                                             OUTPUT de-per-sub-tri).

                ASSIGN de-valor-st-calc = de-valor-st-calc - int_ds_it_docto_xml.vicms.

                IF  c-tabela-pauta = ""
                THEN
                    ASSIGN de-tabela-pauta = int_ds_it_docto_xml.vpmc.
            END.
        END.

        RETURN c-tabela-pauta.
    END.
    ELSE
        RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-perc-va-st B-table-Win 
FUNCTION fn-perc-va-st RETURNS DECIMAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    DEFINE VARIABLE c-uf-orig AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-uf-dest AS CHARACTER   NO-UNDO.

    ASSIGN de-per-va-st = 0.

    IF  AVAIL int_ds_it_docto_xml
    THEN DO:
        FOR FIRST emitente NO-LOCK
            WHERE emitente.cod-emitente = int_ds_it_docto_xml.cod_emitente QUERY-TUNING(NO-LOOKAHEAD):
            ASSIGN c-uf-orig = emitente.estado.
        END.

        FOR FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = int_ds_docto_xml.cod_estab QUERY-TUNING(NO-LOOKAHEAD):
            ASSIGN c-uf-dest = estabelec.estado.
        END.

        IF  c-uf-orig <> "SP" AND
            c-uf-orig <> "PR" AND
            c-uf-orig <> "SC"
        THEN
            ASSIGN c-uf-orig = "SP"
                   c-uf-dest = "PR".

        FOR FIRST item-uf NO-LOCK
            WHERE item-uf.it-codigo       = int_ds_it_docto_xml.it_codigo
              AND item-uf.cod-estado-orig = c-uf-orig 
              AND item-uf.estado          = c-uf-dest QUERY-TUNING(NO-LOOKAHEAD):

            IF  c-tabela-pauta = ""
            THEN
                RETURN item-uf.perc-red-sub.
            ELSE
            &IF '{&bf_dis_versao_ems}' >= '2.08' &THEN
                return item-uf.val-perc-reduc-tab-pauta.
            &ELSE
                return decimal(substring(item-uf.char-1,1,8)).
            &ENDIF         
        END.
    END.

    RETURN 0.00.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnObsoleto B-table-Win 
FUNCTION fnObsoleto RETURNS CHARACTER
  ( c-it-codigo AS CHAR ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    IF c-it-codigo = "" THEN RETURN "".
           
    FIND FIRST ITEM
        WHERE ITEM.it-codigo = c-it-codigo NO-LOCK NO-ERROR.

    IF NOT AVAIL ITEM THEN RETURN "".

    CASE ITEM.cod-obsoleto:
                 WHEN 1 THEN RETURN "Ativo".
                 WHEN 2 THEN RETURN "Obsoleto Ordens Autom.".
                 WHEN 3 THEN RETURN "Obsoleto Todas as Ordens".
                 WHEN 4 THEN RETURN "Totalmente Obsoleto". 
                 OTHERWISE RETURN "".
               END.
    
    RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

