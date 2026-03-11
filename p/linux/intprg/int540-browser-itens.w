&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          custom           ORACLE
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
{include/i-prgvrs.i INT540-browser-itens 1.12.00.AVB}

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
int_ds_it_docto_xml.xProd int_ds_it_docto_xml.ncm int_ds_it_docto_xml.cfop ~
int_ds_it_docto_xml.cst_icms int_ds_it_docto_xml.nat_operacao ~
int_ds_it_docto_xml.qCom_forn int_ds_it_docto_xml.uCom_forn ~
int_ds_it_docto_xml.vUnCom int_ds_it_docto_xml.qCom ~
int_ds_it_docto_xml.uCom int_ds_it_docto_xml.vDesc ~
int_ds_it_docto_xml.vbc_ipi int_ds_it_docto_xml.pipi ~
int_ds_it_docto_xml.vipi int_ds_it_docto_xml.vbc_icms ~
int_ds_it_docto_xml.predBc int_ds_it_docto_xml.picms ~
int_ds_it_docto_xml.vicms int_ds_it_docto_xml.vicmsdeson ~
int_ds_it_docto_xml.vbcst int_ds_it_docto_xml.picmsst ~
int_ds_it_docto_xml.vicmsst int_ds_it_docto_xml.vPMC ~
int_ds_it_docto_xml.pmvast int_ds_it_docto_xml.vbc_pis ~
int_ds_it_docto_xml.ppis int_ds_it_docto_xml.vpis ~
int_ds_it_docto_xml.vbc_cofins int_ds_it_docto_xml.pcofins ~
int_ds_it_docto_xml.vcofins int_ds_it_docto_xml.vOutro ~
int_ds_it_docto_xml.vProd int_ds_it_docto_xml.Lote 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table int_ds_it_docto_xml.cfop ~
int_ds_it_docto_xml.cst_icms int_ds_it_docto_xml.nat_operacao ~
int_ds_it_docto_xml.qCom_forn int_ds_it_docto_xml.vUnCom ~
int_ds_it_docto_xml.vDesc int_ds_it_docto_xml.vbc_ipi ~
int_ds_it_docto_xml.pipi int_ds_it_docto_xml.vipi ~
int_ds_it_docto_xml.vbc_icms int_ds_it_docto_xml.predBc ~
int_ds_it_docto_xml.picms int_ds_it_docto_xml.vicms ~
int_ds_it_docto_xml.vicmsdeson int_ds_it_docto_xml.vbcst ~
int_ds_it_docto_xml.picmsst int_ds_it_docto_xml.vicmsst ~
int_ds_it_docto_xml.vbc_pis int_ds_it_docto_xml.ppis ~
int_ds_it_docto_xml.vpis int_ds_it_docto_xml.vbc_cofins ~
int_ds_it_docto_xml.pcofins int_ds_it_docto_xml.vcofins ~
int_ds_it_docto_xml.vOutro int_ds_it_docto_xml.vProd ~
int_ds_it_docto_xml.Lote 
&Scoped-define ENABLED-TABLES-IN-QUERY-br-table int_ds_it_docto_xml
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-table int_ds_it_docto_xml
&Scoped-define QUERY-STRING-br-table FOR EACH int_ds_it_docto_xml WHERE int_ds_it_docto_xml.cnpj = int_ds_docto_xml.cnpj ~
  AND int_ds_it_docto_xml.serie = int_ds_docto_xml.serie ~
  AND int_ds_it_docto_xml.nNF = int_ds_docto_xml.nNF ~
  AND int_ds_it_docto_xml.tipo_nota = int_ds_docto_xml.tipo_nota NO-LOCK ~
    ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH int_ds_it_docto_xml WHERE int_ds_it_docto_xml.cnpj = int_ds_docto_xml.cnpj ~
  AND int_ds_it_docto_xml.serie = int_ds_docto_xml.serie ~
  AND int_ds_it_docto_xml.nNF = int_ds_docto_xml.nNF ~
  AND int_ds_it_docto_xml.tipo_nota = int_ds_docto_xml.tipo_nota NO-LOCK ~
    ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-br-table int_ds_it_docto_xml
&Scoped-define FIRST-TABLE-IN-QUERY-br-table int_ds_it_docto_xml


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br-table bt-incluir bt-modificar ~
bt-altera-browse bt-eliminar 

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
      int_ds_it_docto_xml.it_codigo FORMAT "x(16)":U WIDTH 9
      int_ds_it_docto_xml.item_do_forn FORMAT "x(60)":U WIDTH 11.86
      int_ds_it_docto_xml.xProd FORMAT "x(60)":U WIDTH 40
      int_ds_it_docto_xml.ncm FORMAT ">>>>>>>>9":U WIDTH 7
      int_ds_it_docto_xml.cfop FORMAT ">>>>>9":U
      int_ds_it_docto_xml.cst_icms FORMAT ">9":U WIDTH 7.86
      int_ds_it_docto_xml.nat_operacao FORMAT "x(6)":U WIDTH 6.43
      int_ds_it_docto_xml.qCom_forn COLUMN-LABEL "Qtde" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 6.29
      int_ds_it_docto_xml.uCom_forn FORMAT "x(03)":U WIDTH 2.57
      int_ds_it_docto_xml.vUnCom FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 7.43
      int_ds_it_docto_xml.qCom FORMAT ">>>>,>>>,>>9.99999":U WIDTH 11
      int_ds_it_docto_xml.uCom FORMAT "x(03)":U
      int_ds_it_docto_xml.vDesc FORMAT ">>>>,>>>,>>9.99999":U WIDTH 9
      int_ds_it_docto_xml.vbc_ipi COLUMN-LABEL "Base IPI" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 10
      int_ds_it_docto_xml.pipi COLUMN-LABEL "% IPI" FORMAT ">>9.99":U
            WIDTH 4
      int_ds_it_docto_xml.vipi COLUMN-LABEL "Vlr IPI" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 5.14
      int_ds_it_docto_xml.vbc_icms COLUMN-LABEL "Base ICMS" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 10
      int_ds_it_docto_xml.predBc COLUMN-LABEL "Red. BC" FORMAT ">>9.9999":U
            WIDTH 8.29
      int_ds_it_docto_xml.picms COLUMN-LABEL "% ICMS" FORMAT ">>9.99":U
            WIDTH 5.43
      int_ds_it_docto_xml.vicms COLUMN-LABEL "Vlr ICMS" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 7.43
      int_ds_it_docto_xml.vicmsdeson COLUMN-LABEL "Vlr ICMS Deson" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 10
      int_ds_it_docto_xml.vbcst COLUMN-LABEL "Base ST" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 10
      int_ds_it_docto_xml.picmsst COLUMN-LABEL "% ST" FORMAT ">>9.99":U
            WIDTH 4.57
      int_ds_it_docto_xml.vicmsst COLUMN-LABEL "Vlr ST" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 7.43
      int_ds_it_docto_xml.vPMC FORMAT ">>>>,>>>,>>9.99999":U WIDTH 10
      int_ds_it_docto_xml.pmvast COLUMN-LABEL "% VaST" FORMAT ">>>9.99":U
            WIDTH 7
      int_ds_it_docto_xml.vbc_pis COLUMN-LABEL "Vlr Base PIS" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 8.43
      int_ds_it_docto_xml.ppis COLUMN-LABEL "% PIS" FORMAT ">>9.99":U
            WIDTH 4.86
      int_ds_it_docto_xml.vpis COLUMN-LABEL "Vlr PIS" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 8.57
      int_ds_it_docto_xml.vbc_cofins COLUMN-LABEL "Base Cofins" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 10.86
      int_ds_it_docto_xml.pcofins COLUMN-LABEL "% Cofins" FORMAT ">>9.99":U
            WIDTH 6.43
      int_ds_it_docto_xml.vcofins COLUMN-LABEL "Vlr Cofins" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 9
      int_ds_it_docto_xml.vOutro FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 11.57
      int_ds_it_docto_xml.vProd FORMAT ">>>>,>>>,>>9.99999":U WIDTH 13.72
      int_ds_it_docto_xml.Lote FORMAT "x(20)":U WIDTH 7.43
  ENABLE
      int_ds_it_docto_xml.cfop
      int_ds_it_docto_xml.cst_icms
      int_ds_it_docto_xml.nat_operacao
      int_ds_it_docto_xml.qCom_forn
      int_ds_it_docto_xml.vUnCom
      int_ds_it_docto_xml.vDesc
      int_ds_it_docto_xml.vbc_ipi
      int_ds_it_docto_xml.pipi
      int_ds_it_docto_xml.vipi
      int_ds_it_docto_xml.vbc_icms
      int_ds_it_docto_xml.predBc
      int_ds_it_docto_xml.picms
      int_ds_it_docto_xml.vicms
      int_ds_it_docto_xml.vicmsdeson
      int_ds_it_docto_xml.vbcst
      int_ds_it_docto_xml.picmsst
      int_ds_it_docto_xml.vicmsst
      int_ds_it_docto_xml.vbc_pis
      int_ds_it_docto_xml.ppis
      int_ds_it_docto_xml.vpis
      int_ds_it_docto_xml.vbc_cofins
      int_ds_it_docto_xml.pcofins
      int_ds_it_docto_xml.vcofins
      int_ds_it_docto_xml.vOutro
      int_ds_it_docto_xml.vProd
      int_ds_it_docto_xml.Lote
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 142.57 BY 10
         FONT 1 ROW-HEIGHT-CHARS .5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     br-table AT ROW 1 COL 1
     bt-incluir AT ROW 11 COL 2 WIDGET-ID 4
     bt-modificar AT ROW 11 COL 13
     bt-altera-browse AT ROW 11 COL 24 WIDGET-ID 2
     bt-eliminar AT ROW 11 COL 41 WIDGET-ID 6
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
       br-table:NUM-LOCKED-COLUMNS IN FRAME F-Main     = 4
       br-table:COLUMN-RESIZABLE IN FRAME F-Main       = TRUE
       br-table:COLUMN-MOVABLE IN FRAME F-Main         = TRUE.

ASSIGN 
       int_ds_it_docto_xml.cst_icms:VISIBLE IN BROWSE br-table = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "custom.int_ds_it_docto_xml WHERE custom.int_ds_docto_xml <external> ..."
     _Options          = "NO-LOCK KEY-PHRASE SORTBY-PHRASE"
     _JoinCode[1]      = "custom.int_ds_it_docto_xml.cnpj = custom.int_ds_docto_xml.cnpj
  AND custom.int_ds_it_docto_xml.serie = custom.int_ds_docto_xml.serie
  AND custom.int_ds_it_docto_xml.nNF = custom.int_ds_docto_xml.nNF
  AND int_ds_it_docto_xml.tipo_nota = int_ds_docto_xml.tipo_nota"
     _FldNameList[1]   > custom.int_ds_it_docto_xml.sequencia
"int_ds_it_docto_xml.sequencia" ? ? "integer" ? ? ? ? ? ? no ? no no "3.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > custom.int_ds_it_docto_xml.it_codigo
"int_ds_it_docto_xml.it_codigo" ? ? "character" ? ? ? ? ? ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > custom.int_ds_it_docto_xml.item_do_forn
"int_ds_it_docto_xml.item_do_forn" ? ? "character" ? ? ? ? ? ? no ? no no "11.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > custom.int_ds_it_docto_xml.xProd
"int_ds_it_docto_xml.xProd" ? ? "character" ? ? ? ? ? ? no ? no no "40" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > custom.int_ds_it_docto_xml.ncm
"int_ds_it_docto_xml.ncm" ? ">>>>>>>>9" "integer" ? ? ? ? ? ? no ? no no "7" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > custom.int_ds_it_docto_xml.cfop
"int_ds_it_docto_xml.cfop" ? ? "integer" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > custom.int_ds_it_docto_xml.cst_icms
"int_ds_it_docto_xml.cst_icms" ? ? "integer" ? ? ? ? ? ? yes ? no no "7.86" no no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > custom.int_ds_it_docto_xml.nat_operacao
"int_ds_it_docto_xml.nat_operacao" ? ? "character" ? ? ? ? ? ? yes ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > custom.int_ds_it_docto_xml.qCom_forn
"int_ds_it_docto_xml.qCom_forn" "Qtde" ? "decimal" ? ? ? ? ? ? yes ? no no "6.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > custom.int_ds_it_docto_xml.uCom_forn
"int_ds_it_docto_xml.uCom_forn" ? ? "character" ? ? ? ? ? ? no ? no no "2.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > custom.int_ds_it_docto_xml.vUnCom
"int_ds_it_docto_xml.vUnCom" ? ? "decimal" ? ? ? ? ? ? yes ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > custom.int_ds_it_docto_xml.qCom
"int_ds_it_docto_xml.qCom" ? ? "decimal" ? ? ? ? ? ? no ? no no "11" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   = custom.int_ds_it_docto_xml.uCom
     _FldNameList[14]   > custom.int_ds_it_docto_xml.vDesc
"int_ds_it_docto_xml.vDesc" ? ? "decimal" ? ? ? ? ? ? yes ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[15]   > custom.int_ds_it_docto_xml.vbc_ipi
"int_ds_it_docto_xml.vbc_ipi" "Base IPI" ? "decimal" ? ? ? ? ? ? yes ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[16]   > custom.int_ds_it_docto_xml.pipi
"int_ds_it_docto_xml.pipi" "% IPI" ? "decimal" ? ? ? ? ? ? yes ? no no "4" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[17]   > custom.int_ds_it_docto_xml.vipi
"int_ds_it_docto_xml.vipi" "Vlr IPI" ? "decimal" ? ? ? ? ? ? yes ? no no "5.14" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[18]   > custom.int_ds_it_docto_xml.vbc_icms
"int_ds_it_docto_xml.vbc_icms" "Base ICMS" ? "decimal" ? ? ? ? ? ? yes ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[19]   > custom.int_ds_it_docto_xml.predBc
"int_ds_it_docto_xml.predBc" "Red. BC" ? "decimal" ? ? ? ? ? ? yes ? no no "8.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[20]   > custom.int_ds_it_docto_xml.picms
"int_ds_it_docto_xml.picms" "% ICMS" ? "decimal" ? ? ? ? ? ? yes ? no no "5.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[21]   > custom.int_ds_it_docto_xml.vicms
"int_ds_it_docto_xml.vicms" "Vlr ICMS" ? "decimal" ? ? ? ? ? ? yes ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[22]   > custom.int_ds_it_docto_xml.vicmsdeson
"int_ds_it_docto_xml.vicmsdeson" "Vlr ICMS Deson" ? "decimal" ? ? ? ? ? ? yes ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[23]   > custom.int_ds_it_docto_xml.vbcst
"int_ds_it_docto_xml.vbcst" "Base ST" ? "decimal" ? ? ? ? ? ? yes ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[24]   > custom.int_ds_it_docto_xml.picmsst
"int_ds_it_docto_xml.picmsst" "% ST" ? "decimal" ? ? ? ? ? ? yes ? no no "4.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[25]   > custom.int_ds_it_docto_xml.vicmsst
"int_ds_it_docto_xml.vicmsst" "Vlr ST" ? "decimal" ? ? ? ? ? ? yes ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[26]   > custom.int_ds_it_docto_xml.vPMC
"int_ds_it_docto_xml.vPMC" ? ? "decimal" ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[27]   > custom.int_ds_it_docto_xml.pmvast
"int_ds_it_docto_xml.pmvast" "% VaST" ? "decimal" ? ? ? ? ? ? no ? no no "7" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[28]   > custom.int_ds_it_docto_xml.vbc_pis
"int_ds_it_docto_xml.vbc_pis" "Vlr Base PIS" ? "decimal" ? ? ? ? ? ? yes ? no no "8.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[29]   > custom.int_ds_it_docto_xml.ppis
"int_ds_it_docto_xml.ppis" "% PIS" ? "decimal" ? ? ? ? ? ? yes ? no no "4.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[30]   > custom.int_ds_it_docto_xml.vpis
"int_ds_it_docto_xml.vpis" "Vlr PIS" ? "decimal" ? ? ? ? ? ? yes ? no no "8.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[31]   > custom.int_ds_it_docto_xml.vbc_cofins
"int_ds_it_docto_xml.vbc_cofins" "Base Cofins" ? "decimal" ? ? ? ? ? ? yes ? no no "10.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[32]   > custom.int_ds_it_docto_xml.pcofins
"int_ds_it_docto_xml.pcofins" "% Cofins" ? "decimal" ? ? ? ? ? ? yes ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[33]   > custom.int_ds_it_docto_xml.vcofins
"int_ds_it_docto_xml.vcofins" "Vlr Cofins" ? "decimal" ? ? ? ? ? ? yes ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[34]   > custom.int_ds_it_docto_xml.vOutro
"int_ds_it_docto_xml.vOutro" ? ? "decimal" ? ? ? ? ? ? yes ? no no "11.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[35]   > custom.int_ds_it_docto_xml.vProd
"int_ds_it_docto_xml.vProd" ? ? "decimal" ? ? ? ? ? ? yes ? no no "13.72" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[36]   > custom.int_ds_it_docto_xml.Lote
"int_ds_it_docto_xml.Lote" ? ? "character" ? ? ? ? ? ? yes ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
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
  
    /*
    if int_ds_it_docto_xml.numero-ordem = 0 then
        int_ds_it_docto_xml.numero-ordem:bgcolor in browse br-table = 14.
    else 
        int_ds_it_docto_xml.numero-ordem:bgcolor in browse br-table = ?.
    */
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

    if not can-find(first classif-fisc no-lock where 
        classif-fisc.class-fiscal = trim(string(int_ds_it_docto_xml.ncm,"99999999"))) then
        int_ds_it_docto_xml.ncm:bgcolor in browse br-table = 14.
    else 
        int_ds_it_docto_xml.ncm:bgcolor in browse br-table = ?.

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
           b-int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota    and 
           b-int_ds_it_docto_xml.CNPJ         = int_ds_docto_xml.CNPJ         and 
           b-int_ds_it_docto_xml.nNF          = int_ds_docto_xml.nNF          and 
           b-int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie        and
           b-int_ds_it_docto_xml.sequencia    = int_ds_it_docto_xml.sequencia and
           b-int_ds_it_docto_xml.it_codigo    = int_ds_it_docto_xml.it_codigo and
           b-int_ds_it_docto_xml.item_do_forn = int_ds_it_docto_xml.item_do_forn:
            assign  b-int_ds_it_docto_xml.cfop            = input browse br-table int_ds_it_docto_xml.cfop         
                    b-int_ds_it_docto_xml.cst_icms        = input browse br-table int_ds_it_docto_xml.cst_icms     
                    b-int_ds_it_docto_xml.nat_operacao    = input browse br-table int_ds_it_docto_xml.nat_operacao 
                    b-int_ds_it_docto_xml.pcofins         = input browse br-table int_ds_it_docto_xml.pcofins      
                    b-int_ds_it_docto_xml.picms           = input browse br-table int_ds_it_docto_xml.picms        
                    b-int_ds_it_docto_xml.picmsst         = input browse br-table int_ds_it_docto_xml.picmsst      
                    b-int_ds_it_docto_xml.pipi            = input browse br-table int_ds_it_docto_xml.pipi         
                    b-int_ds_it_docto_xml.pmvast          = input browse br-table int_ds_it_docto_xml.pmvast       
                    b-int_ds_it_docto_xml.ppis            = input browse br-table int_ds_it_docto_xml.ppis         
                    b-int_ds_it_docto_xml.predBc          = input browse br-table int_ds_it_docto_xml.predBc       
                    b-int_ds_it_docto_xml.qCom_forn       = input browse br-table int_ds_it_docto_xml.qCom_forn    
                    b-int_ds_it_docto_xml.uCom_forn       = input browse br-table int_ds_it_docto_xml.uCom_forn    
                    b-int_ds_it_docto_xml.vbc_cofins      = input browse br-table int_ds_it_docto_xml.vbc_cofins   
                    b-int_ds_it_docto_xml.vbc_icms        = input browse br-table int_ds_it_docto_xml.vbc_icms     
                    b-int_ds_it_docto_xml.vbc_ipi         = input browse br-table int_ds_it_docto_xml.vbc_ipi      
                    b-int_ds_it_docto_xml.vbc_pis         = input browse br-table int_ds_it_docto_xml.vbc_pis      
                    b-int_ds_it_docto_xml.vbcst           = input browse br-table int_ds_it_docto_xml.vbcst  
                    /*b-int_ds_it_docto_xml.numero-ordem    = input browse br-table int_ds_it_docto_xml.numero-ordem*/

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
                    b-int_ds_it_docto_xml.vPMC            = input browse br-table int_ds_it_docto_xml.vPMC         
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
    /*
    if i-sit-re >= 10 and i-sit-re <> 60 then do:

        assign  int_ds_it_docto_xml.qCom_forn:read-only in browse br-table = yes.
        
        if i-sit-re = 40 then do:
            assign 
                int_ds_it_docto_xml.pcofins     :read-only in browse br-table = yes
                int_ds_it_docto_xml.picms       :read-only in browse br-table = yes
                int_ds_it_docto_xml.picmsst     :read-only in browse br-table = yes
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
    */
    apply "entry":u to int_ds_it_docto_xml.ncm in browse br-table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
    RUN pi-eliminar.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
    RUN pi-Incmod ('incluir':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-modificar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-modificar B-table-Win
ON CHOOSE OF bt-modificar IN FRAME F-Main /* Modificar */
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

    RUN pi-Incmod ('modificar':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK B-table-Win 


/* ***************************  Main Block  *************************** */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
RUN dispatch IN THIS-PROCEDURE ('initialize':U). 
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
  apply "FOCUS":U to bt-altera-browse in frame {&frame-name}.
  assign browse br-table:read-only = yes.
  assign bt-altera-browse:sensitive = bt-modificar:sensitive.  
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
                /*int_ds_it_docto_xml.numero-ordem :screen-value in browse br-table = string(int_ds_it_docto_xml.numero-ordem )*/
                int_ds_it_docto_xml.pcofins      :screen-value in browse br-table = string(int_ds_it_docto_xml.pcofins      )
                int_ds_it_docto_xml.picms        :screen-value in browse br-table = string(int_ds_it_docto_xml.picms        )
                int_ds_it_docto_xml.picmsst      :screen-value in browse br-table = string(int_ds_it_docto_xml.picmsst      )
                int_ds_it_docto_xml.pipi         :screen-value in browse br-table = string(int_ds_it_docto_xml.pipi         )
                int_ds_it_docto_xml.pmvast       :screen-value in browse br-table = string(int_ds_it_docto_xml.pmvast       ) 
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
                int_ds_it_docto_xml.vPMC         :screen-value in browse br-table = string(int_ds_it_docto_xml.vPMC         ) 
                int_ds_it_docto_xml.vProd        :screen-value in browse br-table = string(int_ds_it_docto_xml.vProd        ) 
                int_ds_it_docto_xml.vUnCom       :screen-value in browse br-table = string(int_ds_it_docto_xml.vUnCom       ) 
                int_ds_it_docto_xml.xProd        :screen-value in browse br-table = string(int_ds_it_docto_xml.xProd        ).

            /*
            display int_ds_it_docto_xml.cfop         
                    int_ds_it_docto_xml.cst_icms     
                    int_ds_it_docto_xml.nat_operacao 
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
                    int_ds_it_docto_xml.qCom_forn    
                    int_ds_it_docto_xml.uCom         
                    int_ds_it_docto_xml.uCom_forn    
                    int_ds_it_docto_xml.vbc_cofins   
                    int_ds_it_docto_xml.vbc_icms     
                    int_ds_it_docto_xml.vbc_ipi      
                    int_ds_it_docto_xml.vbc_pis      
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
                  (usuar_grp_usuar.cod_grp_usuar = "CCT" or usuar_grp_usuar.cod_grp_usuar = "IBB"))
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
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

