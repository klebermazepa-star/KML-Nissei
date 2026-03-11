&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
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
{include/i-prgvrs.i int510d-browser-itens 1.12.00.AVB}

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
&Scoped-define EXTERNAL-TABLES int-ds-docto-xml
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-docto-xml


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-docto-xml.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES int-ds-it-docto-xml

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table int-ds-it-docto-xml.sequencia ~
int-ds-it-docto-xml.it-codigo int-ds-it-docto-xml.item-do-forn ~
int-ds-it-docto-xml.xProd int-ds-it-docto-xml.ncm int-ds-it-docto-xml.cfop ~
int-ds-it-docto-xml.cst-icms int-ds-it-docto-xml.nat-operacao ~
int-ds-it-docto-xml.numero-ordem int-ds-it-docto-xml.Lote ~
int-ds-it-docto-xml.qCom-forn int-ds-it-docto-xml.uCom-forn ~
int-ds-it-docto-xml.vUnCom int-ds-it-docto-xml.qCom ~
int-ds-it-docto-xml.uCom int-ds-it-docto-xml.vDesc ~
int-ds-it-docto-xml.vbc-ipi int-ds-it-docto-xml.pipi ~
int-ds-it-docto-xml.vipi int-ds-it-docto-xml.vbc-icms ~
int-ds-it-docto-xml.predBc int-ds-it-docto-xml.picms ~
int-ds-it-docto-xml.vicms int-ds-it-docto-xml.vicmsdeson ~
int-ds-it-docto-xml.vbcst int-ds-it-docto-xml.picmsst ~
int-ds-it-docto-xml.vicmsst int-ds-it-docto-xml.vPMC ~
int-ds-it-docto-xml.pmvast int-ds-it-docto-xml.vbc-pis ~
int-ds-it-docto-xml.ppis int-ds-it-docto-xml.vpis ~
int-ds-it-docto-xml.vbc-cofins int-ds-it-docto-xml.pcofins ~
int-ds-it-docto-xml.vcofins int-ds-it-docto-xml.vOutro ~
int-ds-it-docto-xml.vProd 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table 
&Scoped-define QUERY-STRING-br-table FOR EACH int-ds-it-docto-xml WHERE int-ds-it-docto-xml.cnpj = int-ds-docto-xml.cnpj ~
  AND int-ds-it-docto-xml.serie = int-ds-docto-xml.serie ~
  AND int-ds-it-docto-xml.nNF = int-ds-docto-xml.nNF ~
  AND int-ds-it-docto-xml.tipo-nota = int-ds-docto-xml.tipo-nota NO-LOCK ~
    ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH int-ds-it-docto-xml WHERE int-ds-it-docto-xml.cnpj = int-ds-docto-xml.cnpj ~
  AND int-ds-it-docto-xml.serie = int-ds-docto-xml.serie ~
  AND int-ds-it-docto-xml.nNF = int-ds-docto-xml.nNF ~
  AND int-ds-it-docto-xml.tipo-nota = int-ds-docto-xml.tipo-nota NO-LOCK ~
    ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-br-table int-ds-it-docto-xml
&Scoped-define FIRST-TABLE-IN-QUERY-br-table int-ds-it-docto-xml


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br-table bt-det 

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
DEFINE BUTTON bt-det 
     LABEL "&Detalhar" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      int-ds-it-docto-xml SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      int-ds-it-docto-xml.sequencia FORMAT ">>>,>>9":U WIDTH 3.29
      int-ds-it-docto-xml.it-codigo FORMAT "x(16)":U WIDTH 13.57
      int-ds-it-docto-xml.item-do-forn FORMAT "x(60)":U WIDTH 11.86
      int-ds-it-docto-xml.xProd FORMAT "x(60)":U WIDTH 40
      int-ds-it-docto-xml.ncm FORMAT ">>>>>>>>9":U
      int-ds-it-docto-xml.cfop FORMAT ">>>>>9":U
      int-ds-it-docto-xml.cst-icms FORMAT ">9":U WIDTH 7.86
      int-ds-it-docto-xml.nat-operacao FORMAT "x(6)":U WIDTH 6.43
      int-ds-it-docto-xml.numero-ordem FORMAT "zzzzz9,99":U
      int-ds-it-docto-xml.Lote FORMAT "x(20)":U WIDTH 7.43
      int-ds-it-docto-xml.qCom-forn COLUMN-LABEL "Qtde" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 6.29
      int-ds-it-docto-xml.uCom-forn FORMAT "x(03)":U WIDTH 2.57
      int-ds-it-docto-xml.vUnCom FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 7.43
      int-ds-it-docto-xml.qCom FORMAT ">>>>,>>>,>>9.99999":U
      int-ds-it-docto-xml.uCom FORMAT "x(03)":U
      int-ds-it-docto-xml.vDesc FORMAT ">>>>,>>>,>>9.99999":U WIDTH 9.57
      int-ds-it-docto-xml.vbc-ipi COLUMN-LABEL "Base IPI" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 10.29
      int-ds-it-docto-xml.pipi COLUMN-LABEL "% IPI" FORMAT ">>9.99":U
            WIDTH 4
      int-ds-it-docto-xml.vipi COLUMN-LABEL "Vlr IPI" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 5.14
      int-ds-it-docto-xml.vbc-icms COLUMN-LABEL "Base ICMS" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 8.86
      int-ds-it-docto-xml.predBc COLUMN-LABEL "Red. BC" FORMAT ">>9.9999":U
            WIDTH 8.29
      int-ds-it-docto-xml.picms COLUMN-LABEL "% ICMS" FORMAT ">>9.99":U
            WIDTH 5.43
      int-ds-it-docto-xml.vicms COLUMN-LABEL "Vlr ICMS" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 7.43
      int-ds-it-docto-xml.vicmsdeson COLUMN-LABEL "Vlr ICMS Deson" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 10.72
      int-ds-it-docto-xml.vbcst COLUMN-LABEL "Base ST" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 10
      int-ds-it-docto-xml.picmsst COLUMN-LABEL "% ST" FORMAT ">>9.99":U
            WIDTH 4.57
      int-ds-it-docto-xml.vicmsst COLUMN-LABEL "Vlr ST" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 7.43
      int-ds-it-docto-xml.vPMC FORMAT ">>>>,>>>,>>9.99999":U
      int-ds-it-docto-xml.pmvast COLUMN-LABEL "% VaST" FORMAT ">>>9.99":U
            WIDTH 7
      int-ds-it-docto-xml.vbc-pis COLUMN-LABEL "Vlr Base PIS" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 8.43
      int-ds-it-docto-xml.ppis COLUMN-LABEL "% PIS" FORMAT ">>9.99":U
            WIDTH 4.86
      int-ds-it-docto-xml.vpis COLUMN-LABEL "Vlr PIS" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 8.57
      int-ds-it-docto-xml.vbc-cofins COLUMN-LABEL "Base Cofins" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 10.86
      int-ds-it-docto-xml.pcofins COLUMN-LABEL "% Cofins" FORMAT ">>9.99":U
            WIDTH 6.43
      int-ds-it-docto-xml.vcofins COLUMN-LABEL "Vlr Cofins" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 9
      int-ds-it-docto-xml.vOutro FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 11.57
      int-ds-it-docto-xml.vProd FORMAT ">>>>,>>>,>>9.99999":U WIDTH 13.72
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 142.57 BY 10
         FONT 1 ROW-HEIGHT-CHARS .5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     br-table AT ROW 1 COL 1
     bt-det AT ROW 11 COL 1.29
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: BrowserCadastro2
   External Tables: emsesp.int-ds-docto-xml
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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "emsesp.int-ds-it-docto-xml WHERE emsesp.int-ds-docto-xml <external> ..."
     _Options          = "NO-LOCK KEY-PHRASE SORTBY-PHRASE"
     _JoinCode[1]      = "emsesp.int-ds-it-docto-xml.cnpj = emsesp.int-ds-docto-xml.cnpj
  AND emsesp.int-ds-it-docto-xml.serie = emsesp.int-ds-docto-xml.serie
  AND emsesp.int-ds-it-docto-xml.nNF = emsesp.int-ds-docto-xml.nNF
  AND emsesp.int-ds-it-docto-xml.tipo-nota = emsesp.int-ds-docto-xml.tipo-nota"
     _FldNameList[1]   > emsesp.int-ds-it-docto-xml.sequencia
"int-ds-it-docto-xml.sequencia" ? ? "integer" ? ? ? ? ? ? no ? no no "3.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > emsesp.int-ds-it-docto-xml.it-codigo
"int-ds-it-docto-xml.it-codigo" ? ? "character" ? ? ? ? ? ? no ? no no "13.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > emsesp.int-ds-it-docto-xml.item-do-forn
"int-ds-it-docto-xml.item-do-forn" ? ? "character" ? ? ? ? ? ? no ? no no "11.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > emsesp.int-ds-it-docto-xml.xProd
"int-ds-it-docto-xml.xProd" ? ? "character" ? ? ? ? ? ? no ? no no "40" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > emsesp.int-ds-it-docto-xml.ncm
"int-ds-it-docto-xml.ncm" ? ">>>>>>>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = emsesp.int-ds-it-docto-xml.cfop
     _FldNameList[7]   > emsesp.int-ds-it-docto-xml.cst-icms
"int-ds-it-docto-xml.cst-icms" ? ? "integer" ? ? ? ? ? ? no ? no no "7.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > emsesp.int-ds-it-docto-xml.nat-operacao
"int-ds-it-docto-xml.nat-operacao" ? ? "character" ? ? ? ? ? ? no ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   = emsesp.int-ds-it-docto-xml.numero-ordem
     _FldNameList[10]   > emsesp.int-ds-it-docto-xml.Lote
"int-ds-it-docto-xml.Lote" ? ? "character" ? ? ? ? ? ? no ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > emsesp.int-ds-it-docto-xml.qCom-forn
"int-ds-it-docto-xml.qCom-forn" "Qtde" ? "decimal" ? ? ? ? ? ? no ? no no "6.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > emsesp.int-ds-it-docto-xml.uCom-forn
"int-ds-it-docto-xml.uCom-forn" ? ? "character" ? ? ? ? ? ? no ? no no "2.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   > emsesp.int-ds-it-docto-xml.vUnCom
"int-ds-it-docto-xml.vUnCom" ? ? "decimal" ? ? ? ? ? ? no ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[14]   = emsesp.int-ds-it-docto-xml.qCom
     _FldNameList[15]   = emsesp.int-ds-it-docto-xml.uCom
     _FldNameList[16]   > emsesp.int-ds-it-docto-xml.vDesc
"int-ds-it-docto-xml.vDesc" ? ? "decimal" ? ? ? ? ? ? no ? no no "9.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[17]   > emsesp.int-ds-it-docto-xml.vbc-ipi
"int-ds-it-docto-xml.vbc-ipi" "Base IPI" ? "decimal" ? ? ? ? ? ? no ? no no "10.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[18]   > emsesp.int-ds-it-docto-xml.pipi
"int-ds-it-docto-xml.pipi" "% IPI" ? "decimal" ? ? ? ? ? ? no ? no no "4" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[19]   > emsesp.int-ds-it-docto-xml.vipi
"int-ds-it-docto-xml.vipi" "Vlr IPI" ? "decimal" ? ? ? ? ? ? no ? no no "5.14" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[20]   > emsesp.int-ds-it-docto-xml.vbc-icms
"int-ds-it-docto-xml.vbc-icms" "Base ICMS" ? "decimal" ? ? ? ? ? ? no ? no no "8.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[21]   > emsesp.int-ds-it-docto-xml.predBc
"int-ds-it-docto-xml.predBc" "Red. BC" ? "decimal" ? ? ? ? ? ? no ? no no "8.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[22]   > emsesp.int-ds-it-docto-xml.picms
"int-ds-it-docto-xml.picms" "% ICMS" ? "decimal" ? ? ? ? ? ? no ? no no "5.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[23]   > emsesp.int-ds-it-docto-xml.vicms
"int-ds-it-docto-xml.vicms" "Vlr ICMS" ? "decimal" ? ? ? ? ? ? no ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[24]   > emsesp.int-ds-it-docto-xml.vicmsdeson
"int-ds-it-docto-xml.vicmsdeson" "Vlr ICMS Deson" ? "decimal" ? ? ? ? ? ? no ? no no "10.72" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[25]   > emsesp.int-ds-it-docto-xml.vbcst
"int-ds-it-docto-xml.vbcst" "Base ST" ? "decimal" ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[26]   > emsesp.int-ds-it-docto-xml.picmsst
"int-ds-it-docto-xml.picmsst" "% ST" ? "decimal" ? ? ? ? ? ? no ? no no "4.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[27]   > emsesp.int-ds-it-docto-xml.vicmsst
"int-ds-it-docto-xml.vicmsst" "Vlr ST" ? "decimal" ? ? ? ? ? ? no ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[28]   = emsesp.int-ds-it-docto-xml.vPMC
     _FldNameList[29]   > emsesp.int-ds-it-docto-xml.pmvast
"int-ds-it-docto-xml.pmvast" "% VaST" ? "decimal" ? ? ? ? ? ? no ? no no "7" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[30]   > emsesp.int-ds-it-docto-xml.vbc-pis
"int-ds-it-docto-xml.vbc-pis" "Vlr Base PIS" ? "decimal" ? ? ? ? ? ? no ? no no "8.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[31]   > emsesp.int-ds-it-docto-xml.ppis
"int-ds-it-docto-xml.ppis" "% PIS" ? "decimal" ? ? ? ? ? ? no ? no no "4.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[32]   > emsesp.int-ds-it-docto-xml.vpis
"int-ds-it-docto-xml.vpis" "Vlr PIS" ? "decimal" ? ? ? ? ? ? no ? no no "8.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[33]   > emsesp.int-ds-it-docto-xml.vbc-cofins
"int-ds-it-docto-xml.vbc-cofins" "Base Cofins" ? "decimal" ? ? ? ? ? ? no ? no no "10.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[34]   > emsesp.int-ds-it-docto-xml.pcofins
"int-ds-it-docto-xml.pcofins" "% Cofins" ? "decimal" ? ? ? ? ? ? no ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[35]   > emsesp.int-ds-it-docto-xml.vcofins
"int-ds-it-docto-xml.vcofins" "Vlr Cofins" ? "decimal" ? ? ? ? ? ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[36]   > emsesp.int-ds-it-docto-xml.vOutro
"int-ds-it-docto-xml.vOutro" ? ? "decimal" ? ? ? ? ? ? no ? no no "11.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[37]   > emsesp.int-ds-it-docto-xml.vProd
"int-ds-it-docto-xml.vProd" ? ? "decimal" ? ? ? ? ? ? no ? no no "13.72" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
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
    APPLY "CHOOSE" TO BT-DET IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-DISPLAY OF br-table IN FRAME F-Main
DO:
  
    if int-ds-it-docto-xml.numero-ordem = 0 then
        int-ds-it-docto-xml.numero-ordem:bgcolor in browse br-table = 14.
    else 
        int-ds-it-docto-xml.numero-ordem:bgcolor in browse br-table = ?.

    if not can-find(first classif-fisc no-lock where 
        classif-fisc.class-fiscal = trim(string(int-ds-it-docto-xml.ncm,"99999999"))) then
        int-ds-it-docto-xml.ncm:bgcolor in browse br-table = 14.
    else 
        int-ds-it-docto-xml.ncm:bgcolor in browse br-table = ?.

    if not can-find(first cfop-natur no-lock where 
        cfop-natur.cod-cfop = trim(string(int-ds-it-docto-xml.cfop,"9999"))) then
        int-ds-it-docto-xml.cfop:bgcolor in browse br-table = 14.
    else 
        int-ds-it-docto-xml.cfop:bgcolor in browse br-table = ?.

    if trim(string(int-ds-it-docto-xml.cfop,"9999")) begins "1" or
       trim(string(int-ds-it-docto-xml.cfop,"9999")) begins "2" or
       trim(string(int-ds-it-docto-xml.cfop,"9999")) begins "3" then
        int-ds-it-docto-xml.cfop:bgcolor in browse br-table = 14.
    else 
        int-ds-it-docto-xml.cfop:bgcolor in browse br-table = ?.

    if not can-find(first natur-oper no-lock where 
        natur-oper.nat-operacao = trim(int-ds-it-docto-xml.nat-operacao)) then
        int-ds-it-docto-xml.nat-operacao:bgcolor in browse br-table = 14.
    else 
        int-ds-it-docto-xml.nat-operacao:bgcolor in browse br-table = ?.

    if int-ds-it-docto-xml.uCom-forn = "" or
       int-ds-it-docto-xml.uCom-forn = ? or
       trim(string(int-ds-it-docto-xml.uCom-forn)) = "?" then
        int-ds-it-docto-xml.uCom-forn:bgcolor in browse br-table = 14.
    else 
        int-ds-it-docto-xml.uCom-forn:bgcolor in browse br-table = ?.

    if int-ds-it-docto-xml.uCom = "" or
       int-ds-it-docto-xml.uCom = ? or
       trim(string(int-ds-it-docto-xml.uCom)) = "?" then
        int-ds-it-docto-xml.uCom:bgcolor in browse br-table = 14.
    else 
        int-ds-it-docto-xml.uCom:bgcolor in browse br-table = ?.

    if int-ds-it-docto-xml.cst-icms = ? then
        int-ds-it-docto-xml.cst-icms:bgcolor in browse br-table = 14.
    else 
        int-ds-it-docto-xml.cst-icms:bgcolor in browse br-table = ?.

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
ON VALUE-CHANGED OF br-table IN FRAME F-Main
DO:
  /* This ADM trigger code must be preserved in order to notify other
     objects when the browser's current row changes. */
  {src/adm/template/brschnge.i}
  /* run new-state('New-Line|':U + string(rowid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}))). */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-det
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-det B-table-Win
ON CHOOSE OF bt-det IN FRAME F-Main /* Detalhar */
DO:
   IF  AVAIL int-ds-it-docto-xml
   THEN
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

  assign bt-det:sensitive in FRAME {&FRAME-NAME} = YES.


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
      for first int-ds-docto-wms fields (situacao datamovimentacao_d) no-lock where 
          int-ds-docto-wms.doc_numero_n = int(int-ds-docto-xml.nNF) and
          int-ds-docto-wms.doc_serie_s  = int-ds-docto-xml.serie and
          int-ds-docto-wms.cnpj_cpf     = int-ds-docto-xml.CNPJ: 
          assign i-sit-re = int-ds-docto-wms.situacao.
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
        if avail int-ds-it-docto-xml then do:
            assign 
                int-ds-it-docto-xml.cfop         :screen-value in browse br-table = string(int-ds-it-docto-xml.cfop         )
                int-ds-it-docto-xml.cst-icms     :screen-value in browse br-table = string(int-ds-it-docto-xml.cst-icms     )
                int-ds-it-docto-xml.nat-operacao :screen-value in browse br-table = string(int-ds-it-docto-xml.nat-operacao )
                int-ds-it-docto-xml.ncm          :screen-value in browse br-table = string(int-ds-it-docto-xml.ncm          )
                int-ds-it-docto-xml.numero-ordem :screen-value in browse br-table = string(int-ds-it-docto-xml.numero-ordem )
                int-ds-it-docto-xml.pcofins      :screen-value in browse br-table = string(int-ds-it-docto-xml.pcofins      )
                int-ds-it-docto-xml.picms        :screen-value in browse br-table = string(int-ds-it-docto-xml.picms        )
                int-ds-it-docto-xml.picmsst      :screen-value in browse br-table = string(int-ds-it-docto-xml.picmsst      )
                int-ds-it-docto-xml.pipi         :screen-value in browse br-table = string(int-ds-it-docto-xml.pipi         )
                int-ds-it-docto-xml.pmvast       :screen-value in browse br-table = string(int-ds-it-docto-xml.pmvast       ) 
                int-ds-it-docto-xml.ppis         :screen-value in browse br-table = string(int-ds-it-docto-xml.ppis         ) 
                int-ds-it-docto-xml.predBc       :screen-value in browse br-table = string(int-ds-it-docto-xml.predBc       ) 
                int-ds-it-docto-xml.qCom         :screen-value in browse br-table = string(int-ds-it-docto-xml.qCom         ) 
                int-ds-it-docto-xml.qCom-forn    :screen-value in browse br-table = string(int-ds-it-docto-xml.qCom-forn    ) 
                int-ds-it-docto-xml.uCom         :screen-value in browse br-table = string(int-ds-it-docto-xml.uCom         ) 
                int-ds-it-docto-xml.uCom-forn    :screen-value in browse br-table = string(int-ds-it-docto-xml.uCom-forn    ) 
                int-ds-it-docto-xml.vbc-cofins   :screen-value in browse br-table = string(int-ds-it-docto-xml.vbc-cofins   ) 
                int-ds-it-docto-xml.vbc-icms     :screen-value in browse br-table = string(int-ds-it-docto-xml.vbc-icms     ) 
                int-ds-it-docto-xml.vbc-ipi      :screen-value in browse br-table = string(int-ds-it-docto-xml.vbc-ipi      ) 
                int-ds-it-docto-xml.vbc-pis      :screen-value in browse br-table = string(int-ds-it-docto-xml.vbc-pis      ) 
                int-ds-it-docto-xml.vbcst        :screen-value in browse br-table = string(int-ds-it-docto-xml.vbcst        ) 
                int-ds-it-docto-xml.vcofins      :screen-value in browse br-table = string(int-ds-it-docto-xml.vcofins      ) 
                int-ds-it-docto-xml.vDesc        :screen-value in browse br-table = string(int-ds-it-docto-xml.vDesc        ) 
                int-ds-it-docto-xml.vicms        :screen-value in browse br-table = string(int-ds-it-docto-xml.vicms        ) 
                int-ds-it-docto-xml.vicmsdeson   :screen-value in browse br-table = string(int-ds-it-docto-xml.vicmsdeson   ) 
                int-ds-it-docto-xml.vicmsst      :screen-value in browse br-table = string(int-ds-it-docto-xml.vicmsst      ) 
                int-ds-it-docto-xml.vipi         :screen-value in browse br-table = string(int-ds-it-docto-xml.vipi         ) 
                int-ds-it-docto-xml.vOutro       :screen-value in browse br-table = string(int-ds-it-docto-xml.vOutro       ) 
                int-ds-it-docto-xml.vpis         :screen-value in browse br-table = string(int-ds-it-docto-xml.vpis         ) 
                int-ds-it-docto-xml.vPMC         :screen-value in browse br-table = string(int-ds-it-docto-xml.vPMC         ) 
                int-ds-it-docto-xml.vProd        :screen-value in browse br-table = string(int-ds-it-docto-xml.vProd        ) 
                int-ds-it-docto-xml.vUnCom       :screen-value in browse br-table = string(int-ds-it-docto-xml.vUnCom       ) 
                int-ds-it-docto-xml.xProd        :screen-value in browse br-table = string(int-ds-it-docto-xml.xProd        ).

            /*
            display int-ds-it-docto-xml.cfop         
                    int-ds-it-docto-xml.cst-icms     
                    int-ds-it-docto-xml.nat-operacao 
                    int-ds-it-docto-xml.ncm          
                    /*int-ds-it-docto-xml.numero-ordem */
                    int-ds-it-docto-xml.pcofins      
                    int-ds-it-docto-xml.picms        
                    int-ds-it-docto-xml.picmsst      
                    int-ds-it-docto-xml.pipi         
                    int-ds-it-docto-xml.pmvast       
                    int-ds-it-docto-xml.ppis         
                    int-ds-it-docto-xml.predBc       
                    int-ds-it-docto-xml.qCom         
                    int-ds-it-docto-xml.qCom-forn    
                    int-ds-it-docto-xml.uCom         
                    int-ds-it-docto-xml.uCom-forn    
                    int-ds-it-docto-xml.vbc-cofins   
                    int-ds-it-docto-xml.vbc-icms     
                    int-ds-it-docto-xml.vbc-ipi      
                    int-ds-it-docto-xml.vbc-pis      
                    int-ds-it-docto-xml.vbcst        
                    int-ds-it-docto-xml.vcofins      
                    int-ds-it-docto-xml.vDesc        
                    int-ds-it-docto-xml.vicms        
                    int-ds-it-docto-xml.vicmsdeson   
                    int-ds-it-docto-xml.vicmsst      
                    int-ds-it-docto-xml.vipi         
                    int-ds-it-docto-xml.vOutro       
                    int-ds-it-docto-xml.vpis         
                    int-ds-it-docto-xml.vPMC         
                    int-ds-it-docto-xml.vProd        
                    int-ds-it-docto-xml.vUnCom       
                    int-ds-it-docto-xml.xProd    
                with browse br-table.
                */
            apply "row-display":u to br-table.
        end.
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
  {src/adm/template/snd-list.i "int-ds-docto-xml"}
  {src/adm/template/snd-list.i "int-ds-it-docto-xml"}

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

