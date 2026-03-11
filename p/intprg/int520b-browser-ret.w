&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r11 GUI ADM1
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
{include/i-prgvrs.i int520b-browser-ret 1.12.01.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var c-item as char no-undo.
def buffer b-int-ds-nota-entrada-produto for int-ds-nota-entrada-produto.
def buffer b-int-ds-ret-nota-entrada-prod for int-ds-retorno-nota-entrada-prod.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartBrowser
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br_table

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int-ds-nota-entrada-produto
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-nota-entrada-produto


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-nota-entrada-produto.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES int-ds-retorno-nota-entrada ~
int-ds-retorno-nota-entrada-prod

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br_table                                      */
&Scoped-define FIELDS-IN-QUERY-br_table int-ds-retorno-nota-entrada-prod.RNP-ALTERNATIVO-S int-ds-retorno-nota-entrada-prod.RNP-CODIGOBARRAS-N int-ds-retorno-nota-entrada-prod.RNP-PRODUTO-N int-ds-retorno-nota-entrada-prod.RNP-QUANTIDADE-N fnItem(int-ds-retorno-nota-entrada-prod.RNP-PRODUTO-N) @ c-item   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br_table   
&Scoped-define SELF-NAME br_table
&Scoped-define QUERY-STRING-br_table FOR EACH int-ds-retorno-nota-entrada no-lock where     int-ds-retorno-nota-entrada.RNE-CNPJ-ORIGEM-S = int-ds-nota-entrada-produto.nen-cnpj-origem-s and     int-ds-retorno-nota-entrada.RNE-NOTAFISCAL-N  = int-ds-nota-entrada-produto.nen-notafiscal-n and     int-ds-retorno-nota-entrada.RNE-SERIE-S       = int-ds-nota-entrada-produto.nen-serie-s, ~
           each int-ds-retorno-nota-entrada-prod no-lock where     int-ds-retorno-nota-entrada-prod.RNP-RETORNONOTAENTRADA-N = int-ds-retorno-nota-entrada.RNE-CODIGO-N and     int-ds-retorno-nota-entrada-prod.RNP-MATCH-S = "N"     ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-br_table OPEN QUERY {&SELF-NAME} FOR EACH int-ds-retorno-nota-entrada no-lock where     int-ds-retorno-nota-entrada.RNE-CNPJ-ORIGEM-S = int-ds-nota-entrada-produto.nen-cnpj-origem-s and     int-ds-retorno-nota-entrada.RNE-NOTAFISCAL-N  = int-ds-nota-entrada-produto.nen-notafiscal-n and     int-ds-retorno-nota-entrada.RNE-SERIE-S       = int-ds-nota-entrada-produto.nen-serie-s, ~
           each int-ds-retorno-nota-entrada-prod no-lock where     int-ds-retorno-nota-entrada-prod.RNP-RETORNONOTAENTRADA-N = int-ds-retorno-nota-entrada.RNE-CODIGO-N and     int-ds-retorno-nota-entrada-prod.RNP-MATCH-S = "N"     ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-br_table int-ds-retorno-nota-entrada ~
int-ds-retorno-nota-entrada-prod
&Scoped-define FIRST-TABLE-IN-QUERY-br_table int-ds-retorno-nota-entrada
&Scoped-define SECOND-TABLE-IN-QUERY-br_table int-ds-retorno-nota-entrada-prod


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br_table btSeleciona 

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
</FILTER-ATTRIBUTES> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnItem B-table-Win 
FUNCTION fnItem RETURNS CHARACTER
  ( p-it-codigo as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON btSeleciona 
     LABEL "Seleciona Produto" 
     SIZE 18 BY 1.13.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br_table FOR 
      int-ds-retorno-nota-entrada, 
      int-ds-retorno-nota-entrada-prod SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br_table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br_table B-table-Win _FREEFORM
  QUERY br_table NO-LOCK DISPLAY
      int-ds-retorno-nota-entrada-prod.RNP-ALTERNATIVO-S FORMAT "x(20)":U label "Item do Forn"
      int-ds-retorno-nota-entrada-prod.RNP-CODIGOBARRAS-N FORMAT "->>>>>>>>>>>9":U label "EAN"
      int-ds-retorno-nota-entrada-prod.RNP-PRODUTO-N FORMAT "->>>>>>>>9":U label "Produto"
      int-ds-retorno-nota-entrada-prod.RNP-QUANTIDADE-N FORMAT "->>>>>>>>9":U label "Qtde"
      fnItem(int-ds-retorno-nota-entrada-prod.RNP-PRODUTO-N) @ c-item FORMAT "X(65)" label "Descri‡Æo"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS NO-SCROLLBAR-VERTICAL SIZE 89 BY 9 ROW-HEIGHT-CHARS .5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     br_table AT ROW 1 COL 1
     btSeleciona AT ROW 9.96 COL 1 WIDGET-ID 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartBrowser
   External Tables: emsesp.int-ds-nota-entrada-produto
   Allow: Basic,Browse
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
  CREATE WINDOW B-table-Win ASSIGN
         HEIGHT             = 10.08
         WIDTH              = 89.86.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB B-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/browser.i}
{include/c-browse.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW B-table-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
/* BROWSE-TAB br_table 1 F-Main */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN 
       br_table:COLUMN-RESIZABLE IN FRAME F-Main       = TRUE
       br_table:COLUMN-MOVABLE IN FRAME F-Main         = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br_table
/* Query rebuild information for BROWSE br_table
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH int-ds-retorno-nota-entrada no-lock where
    int-ds-retorno-nota-entrada.RNE-CNPJ-ORIGEM-S = int-ds-nota-entrada-produto.nen-cnpj-origem-s and
    int-ds-retorno-nota-entrada.RNE-NOTAFISCAL-N  = int-ds-nota-entrada-produto.nen-notafiscal-n and
    int-ds-retorno-nota-entrada.RNE-SERIE-S       = int-ds-nota-entrada-produto.nen-serie-s,
    each int-ds-retorno-nota-entrada-prod no-lock where
    int-ds-retorno-nota-entrada-prod.RNP-RETORNONOTAENTRADA-N = int-ds-retorno-nota-entrada.RNE-CODIGO-N and
    int-ds-retorno-nota-entrada-prod.RNP-MATCH-S = "N"
    ~{&SORTBY-PHRASE}.
     _END_FREEFORM
     _Options          = "NO-LOCK KEY-PHRASE SORTBY-PHRASE"
     _Query            is NOT OPENED
*/  /* BROWSE br_table */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME br_table
&Scoped-define SELF-NAME br_table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON MOUSE-SELECT-DBLCLICK OF br_table IN FRAME F-Main
DO:
    RUN pi-seleciona-produto.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON ROW-ENTRY OF br_table IN FRAME F-Main
DO:
  /* This code displays initial values for newly added or copied rows. */
  {src/adm/template/brsentry.i}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON ROW-LEAVE OF br_table IN FRAME F-Main
DO:
    /* Do not disable this code or no updates will take place except
     by pressing the Save button on an Update SmartPanel. */
   {src/adm/template/brsleave.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_table B-table-Win
ON VALUE-CHANGED OF br_table IN FRAME F-Main
DO:
  /* This ADM trigger code must be preserved in order to notify other
     objects when the browser's current row changes. */
  {src/adm/template/brschnge.i}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSeleciona
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSeleciona B-table-Win
ON CHOOSE OF btSeleciona IN FRAME F-Main /* Seleciona Produto */
DO:
  RUN pi-seleciona-produto.
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
  {src/adm/template/row-list.i "int-ds-nota-entrada-produto"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int-ds-nota-entrada-produto"}

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-seleciona-produto B-table-Win 
PROCEDURE pi-seleciona-produto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    if  avail int-ds-retorno-nota-entrada-prod and
        avail int-ds-nota-entrada-produto and
        avail int-ds-retorno-nota-entrada then do:

        message "Confirma sele‡Æo do item " 
            string(int-ds-retorno-nota-entrada-prod.RNP-PRODUTO-N) + " ? "
            view-as alert-box question buttons yes-no update l-resp as logical.

        if l-resp then do transaction:
            for first b-int-ds-ret-nota-entrada-prod where
                rowid(b-int-ds-ret-nota-entrada-prod) = rowid(int-ds-retorno-nota-entrada-prod):
                if b-int-ds-ret-nota-entrada-prod.RNP-MATCH-S = "S" then
                    assign  b-int-ds-ret-nota-entrada-prod.RNP-MATCH-S = "N".
                else
                    assign b-int-ds-ret-nota-entrada-prod.RNP-MATCH-S = "S".
            end.
            for first b-int-ds-nota-entrada-produto where
                rowid (b-int-ds-nota-entrada-produto) = rowid(int-ds-nota-entrada-produto)
                exclusive-lock:
                if b-int-ds-ret-nota-entrada-prod.RNP-MATCH-S = "S" then
                    assign  b-int-ds-nota-entrada-produto.nep-produto-n    = int-ds-retorno-nota-entrada-prod.RNP-PRODUTO-N
                            b-int-ds-nota-entrada-produto.nep-quantidade-n = int-ds-retorno-nota-entrada-prod.RNP-QUANTIDADE-N.
                else
                    assign  b-int-ds-nota-entrada-produto.nep-produto-n    = 0
                            b-int-ds-nota-entrada-produto.nep-quantidade-n = 0.
            end.
            release b-int-ds-nota-entrada-produto.
            release b-int-ds-ret-nota-entrada-prod.
            RUN notify ("row-available").
            if not can-find (first int-ds-retorno-nota-entrada-prod no-lock where
                             int-ds-retorno-nota-entrada-prod.RNP-RETORNONOTAENTRADA-N = int-ds-retorno-nota-entrada.RNE-CODIGO-N and
                             int-ds-retorno-nota-entrada-prod.RNP-MATCH-S = "N") then do:
                for first int-ds-nota-entrada EXCLUSIVE of int-ds-nota-entrada-produto:
                    assign  int-ds-nota-entrada.situacao = 2
                            int-ds-nota-entrada.nen-conferida-n = 1
                            int-ds-nota-entrada.nen-datamovimentacao-d = int-ds-retorno-nota-entrada.RNE-DATAMOVIMENTACAO-D.
                end.
            end.
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
  {src/adm/template/snd-list.i "int-ds-nota-entrada-produto"}
  {src/adm/template/snd-list.i "int-ds-retorno-nota-entrada"}
  {src/adm/template/snd-list.i "int-ds-retorno-nota-entrada-prod"}

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
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnItem B-table-Win 
FUNCTION fnItem RETURNS CHARACTER
  ( p-it-codigo as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    for first ITEM field (desc-item)
        no-lock where ITEM.it-codigo = trim(string(dec(p-it-codigo))):
        RETURN item.desc-item.    
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

