&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           PROGRESS
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
{include/i-prgvrs.i int520-browser-itens 1.12.01.AVB}

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

/*:T v ri veis de uso globla */
def  var v-row-parent    as rowid no-undo.

/*:T vari veis de uso local */
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
&Scoped-define EXTERNAL-TABLES int-ds-nota-entrada
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-nota-entrada


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-nota-entrada.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES int-ds-nota-entrada-produto

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table ~
int-ds-nota-entrada-produto.nep-sequencia-n ~
int-ds-nota-entrada-produto.alternativo-fornecedor ~
int-ds-nota-entrada-produto.nep-produto-n ~
int-ds-nota-entrada-produto.nep-lote-s ~
int-ds-nota-entrada-produto.nep-quantidade-n ~
int-ds-nota-entrada-produto.nep-valoripi-n ~
int-ds-nota-entrada-produto.nep-baseicms-n ~
int-ds-nota-entrada-produto.nep-valoricms-n ~
int-ds-nota-entrada-produto.nep-basest-n ~
int-ds-nota-entrada-produto.nep-icmsst-n ~
int-ds-nota-entrada-produto.nep-valorpis-n ~
int-ds-nota-entrada-produto.nep-valorcofins-n ~
int-ds-nota-entrada-produto.nep-valordesconto-n ~
int-ds-nota-entrada-produto.nep-valorliquido-n 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table 
&Scoped-define QUERY-STRING-br-table FOR EACH int-ds-nota-entrada-produto WHERE int-ds-nota-entrada-produto.nen-cnpj-origem = int-ds-nota-entrada.nen-cnpj-origem ~
  AND int-ds-nota-entrada-produto.nen-serie-s = int-ds-nota-entrada.nen-serie-s ~
  AND int-ds-nota-entrada-produto.nen-notafiscal-n = int-ds-nota-entrada.nen-notafiscal-n NO-LOCK ~
    ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH int-ds-nota-entrada-produto WHERE int-ds-nota-entrada-produto.nen-cnpj-origem = int-ds-nota-entrada.nen-cnpj-origem ~
  AND int-ds-nota-entrada-produto.nen-serie-s = int-ds-nota-entrada.nen-serie-s ~
  AND int-ds-nota-entrada-produto.nen-notafiscal-n = int-ds-nota-entrada.nen-notafiscal-n NO-LOCK ~
    ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-br-table int-ds-nota-entrada-produto
&Scoped-define FIRST-TABLE-IN-QUERY-br-table int-ds-nota-entrada-produto


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


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      int-ds-nota-entrada-produto SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      int-ds-nota-entrada-produto.nep-sequencia-n COLUMN-LABEL "Seq" FORMAT ">>>,>>>,>>9":U
            WIDTH 3.25
      int-ds-nota-entrada-produto.alternativo-fornecedor COLUMN-LABEL "Item Fornecedor" FORMAT "x(20)":U
      int-ds-nota-entrada-produto.nep-produto-n FORMAT ">>>>>>>>9":U
            WIDTH 7.88
      int-ds-nota-entrada-produto.nep-lote-s FORMAT "x(20)":U WIDTH 11.63
      int-ds-nota-entrada-produto.nep-quantidade-n COLUMN-LABEL "Qtde" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 6.25
      int-ds-nota-entrada-produto.nep-valoripi-n FORMAT ">>>,>>>,>>>,>>9.99999":U
            WIDTH 5.13
      int-ds-nota-entrada-produto.nep-baseicms-n FORMAT ">>>,>>>,>>>,>>9.99999":U
            WIDTH 8.88
      int-ds-nota-entrada-produto.nep-valoricms-n FORMAT ">>>,>>>,>>>,>>9.99999":U
            WIDTH 7.38
      int-ds-nota-entrada-produto.nep-basest-n FORMAT ">>>,>>>,>>>,>>9.99999":U
            WIDTH 10
      int-ds-nota-entrada-produto.nep-icmsst-n FORMAT ">>>,>>>,>>>,>>9.99999":U
            WIDTH 6.88
      int-ds-nota-entrada-produto.nep-valorpis-n FORMAT ">>>,>>>,>>>,>>9.99999":U
            WIDTH 8.63
      int-ds-nota-entrada-produto.nep-valorcofins-n COLUMN-LABEL "Vlr Cofins" FORMAT ">>>,>>>,>>>,>>9.99999":U
            WIDTH 9
      int-ds-nota-entrada-produto.nep-valordesconto-n FORMAT ">>>,>>>,>>>,>>9.99999":U
            WIDTH 9.75
      int-ds-nota-entrada-produto.nep-valorliquido-n FORMAT ">>>,>>>,>>>,>>9.99999":U
            WIDTH 11
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 142.63 BY 10.77
         FONT 1 ROW-HEIGHT-CHARS .5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     br-table AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: BrowserCadastro2
   External Tables: emsesp.int-ds-nota-entrada
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
         HEIGHT             = 11.07
         WIDTH              = 142.63.
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
       br-table:COLUMN-RESIZABLE IN FRAME F-Main       = TRUE
       br-table:COLUMN-MOVABLE IN FRAME F-Main         = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "emsesp.int-ds-nota-entrada-produto WHERE emsesp.int-ds-nota-entrada <external> ..."
     _Options          = "NO-LOCK KEY-PHRASE SORTBY-PHRASE"
     _JoinCode[1]      = "emsesp.int-ds-nota-entrada-produto.nen-cnpj-origem = emsesp.int-ds-nota-entrada.nen-cnpj-origem
  AND emsesp.int-ds-nota-entrada-produto.nen-serie-s = emsesp.int-ds-nota-entrada.nen-serie-s
  AND emsesp.int-ds-nota-entrada-produto.nen-notafiscal-n = emsesp.int-ds-nota-entrada.nen-notafiscal-n
  AND emsesp.int-ds-nota-entrada-produto.nen-cfop = emsesp.int-ds-nota-entrada.nen-cfop"
     _FldNameList[1]   > emsesp.int-ds-nota-entrada-produto.nep-sequencia-n
"int-ds-nota-entrada-produto.nep-sequencia-n" "Seq" ? "integer" ? ? ? ? ? ? no ? no no "3.25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > emsesp.int-ds-nota-entrada-produto.alternativo-fornecedor
"int-ds-nota-entrada-produto.alternativo-fornecedor" "Item Fornecedor" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > emsesp.int-ds-nota-entrada-produto.nep-produto-n
"int-ds-nota-entrada-produto.nep-produto-n" ? ? "character" ? ? ? ? ? ? no ? no no "7.88" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > emsesp.int-ds-nota-entrada-produto.nep-lote-s
"int-ds-nota-entrada-produto.nep-lote-s" ? ? "character" ? ? ? ? ? ? no ? no no "11.63" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > emsesp.int-ds-nota-entrada-produto.nep-quantidade-n
"int-ds-nota-entrada-produto.nep-quantidade-n" "Qtde" ? "decimal" ? ? ? ? ? ? no ? no no "6.25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > emsesp.int-ds-nota-entrada-produto.nep-valoripi-n
"int-ds-nota-entrada-produto.nep-valoripi-n" ? ? "decimal" ? ? ? ? ? ? no ? no no "5.13" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > emsesp.int-ds-nota-entrada-produto.nep-baseicms-n
"int-ds-nota-entrada-produto.nep-baseicms-n" ? ? "decimal" ? ? ? ? ? ? no ? no no "8.88" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > emsesp.int-ds-nota-entrada-produto.nep-valoricms-n
"int-ds-nota-entrada-produto.nep-valoricms-n" ? ? "decimal" ? ? ? ? ? ? no ? no no "7.38" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > emsesp.int-ds-nota-entrada-produto.nep-basest-n
"int-ds-nota-entrada-produto.nep-basest-n" ? ? "decimal" ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > emsesp.int-ds-nota-entrada-produto.nep-icmsst-n
"int-ds-nota-entrada-produto.nep-icmsst-n" ? ? "decimal" ? ? ? ? ? ? no ? no no "6.88" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > emsesp.int-ds-nota-entrada-produto.nep-valorpis-n
"int-ds-nota-entrada-produto.nep-valorpis-n" ? ? "decimal" ? ? ? ? ? ? no ? no no "8.63" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > emsesp.int-ds-nota-entrada-produto.nep-valorcofins-n
"int-ds-nota-entrada-produto.nep-valorcofins-n" "Vlr Cofins" ? "decimal" ? ? ? ? ? ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   > emsesp.int-ds-nota-entrada-produto.nep-valordesconto-n
"int-ds-nota-entrada-produto.nep-valordesconto-n" ? ? "decimal" ? ? ? ? ? ? no ? no no "9.75" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[14]   > emsesp.int-ds-nota-entrada-produto.nep-valorliquido-n
"int-ds-nota-entrada-produto.nep-valorliquido-n" ? ? "decimal" ? ? ? ? ? ? no ? no no "11" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
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
  {src/adm/template/snd-list.i "int-ds-nota-entrada"}
  {src/adm/template/snd-list.i "int-ds-nota-entrada-produto"}

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

