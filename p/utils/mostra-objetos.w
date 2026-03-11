&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          mgadm            PROGRESS
*/
&Scoped-define WINDOW-NAME W-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS W-Win 
/*------------------------------------------------------------------------

  File: 

  Description: from cntnrwin.w - ADM SmartWindow Template

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  History: 
          
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEF VAR c-nome-arq AS CHAR NO-UNDO.
DEF VAR l-ok       AS LOG  NO-UNDO.

/*----- DEFINICAO DE STREAM -----*/
DEF STREAM S-SAIDA.

/*----- DEFINICAO DE TEMP-TABLES -----*/
DEF TEMP-TABLE tt-resultado
    FIELD nome         AS CHAR FORMAT "x(50)"
    FIELD tipo         AS CHAR FORMAT "x(20)"
    FIELD linha        AS dec FORMAT ">>9.999"
    FIELD coluna       AS dec FORMAT ">>9.999"
    FIELD formato      AS CHAR FORMAT "x(10)"
    FIELD altura       AS DEC FORMAT ">>9.999"
    FIELD largura      AS DEC FORMAT ">>9.999"
    FIELD tipo-inf     AS CHAR FORMAT "x(16)"
    FIELD nome-frame   AS CHAR FORMAT "x(10)"
    FIELD tabela       AS CHAR FORMAT "x(50)"
    FIELD wh-handle    AS WIDGET-HANDLE
    INDEX id-01 nome.


/*----- Definicao de parametros de entrada -----*/
DEF INPUT PARAMETER    p-wh-objeto AS WIDGET-HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartWindow
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br-resultado

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-resultado

/* Definitions for BROWSE br-resultado                                  */
&Scoped-define FIELDS-IN-QUERY-br-resultado tt-resultado.nome tt-resultado.tipo tt-resultado.linha tt-resultado.coluna tt-resultado.tipo-inf tt-resultado.formato tt-resultado.altura tt-resultado.largura tt-resultado.nome-frame tt-resultado.tabela   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-resultado   
&Scoped-define SELF-NAME br-resultado
&Scoped-define OPEN-QUERY-br-resultado OPEN QUERY {&SELF-NAME} FOR EACH tt-resultado.
&Scoped-define TABLES-IN-QUERY-br-resultado tt-resultado
&Scoped-define FIRST-TABLE-IN-QUERY-br-resultado tt-resultado


/* Definitions for FRAME F-Main                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-F-Main ~
    ~{&OPEN-QUERY-br-resultado}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS bt-exporta br-resultado bt-fechar bt-df 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-cria-campos W-Win 
FUNCTION fc-cria-campos RETURNS LOGICAL
  ( p-fc-wh-objeto AS widget-handle )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-cria-tabela W-Win 
FUNCTION fc-cria-tabela RETURNS CHARACTER
  ( p-wh-objeto AS widget-handle )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR W-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-df 
     IMAGE-UP FILE "adm2/image/commit.bmp":U
     LABEL "Exporta DF" 
     SIZE 4.72 BY 1 TOOLTIP "Exporta para arquivo".

DEFINE BUTTON bt-exporta 
     IMAGE-UP FILE "adm2/image/saverec.bmp":U
     LABEL "Button 4" 
     SIZE 4.72 BY 1 TOOLTIP "Exporta Linhas para arquivo".

DEFINE BUTTON bt-fechar DEFAULT 
     LABEL "&Fechar" 
     SIZE 10 BY 1 TOOLTIP "Fecha Programa"
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-resultado FOR 
      tt-resultado SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-resultado
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-resultado W-Win _FREEFORM
  QUERY br-resultado DISPLAY
      tt-resultado.nome   COLUMN-LABEL "Nome" WIDTH 25
 tt-resultado.tipo  COLUMN-LABEL "Tipo"
 tt-resultado.linha   COLUMN-LABEL "Linha"
 tt-resultado.coluna    COLUMN-LABEL "Coluna"
tt-resultado.tipo-inf COLUMN-LABEL "Data Type"
tt-resultado.formato COLUMN-LABEL "Formato"
tt-resultado.altura COLUMN-LABEL "Altura"
tt-resultado.largura COLUMN-LABEL "Largura"
tt-resultado.nome-frame COLUMN-LABEL "Nome Frame"
tt-resultado.tabela COLUMN-LABEL "Nome Tabela"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 68 BY 7
         FONT 1 ROW-HEIGHT-CHARS .54.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     bt-exporta AT ROW 1.25 COL 71 HELP
          "Exporta para arquivo"
     br-resultado AT ROW 1.25 COL 2
     bt-fechar AT ROW 9 COL 2 HELP
          "Fecha Programa"
     bt-df AT ROW 2.25 COL 71 HELP
          "Exporta para arquivo"
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 75.29 BY 9.46
         FONT 1
         DEFAULT-BUTTON bt-fechar.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartWindow
   Allow: Basic,Browse,DB-Fields,Query,Smart,Window
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW W-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "MOSTRA-OBJETOS - Mostra objetos do Frame"
         HEIGHT             = 9.46
         WIDTH              = 75.29
         MAX-HEIGHT         = 17
         MAX-WIDTH          = 80
         VIRTUAL-HEIGHT     = 17
         VIRTUAL-WIDTH      = 80
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB W-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW W-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   Custom                                                               */
/* BROWSE-TAB br-resultado bt-exporta F-Main */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(W-Win)
THEN W-Win:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-resultado
/* Query rebuild information for BROWSE br-resultado
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-resultado.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-resultado */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME W-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL W-Win W-Win
ON END-ERROR OF W-Win /* MOSTRA-OBJETOS - Mostra objetos do Frame */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL W-Win W-Win
ON WINDOW-CLOSE OF W-Win /* MOSTRA-OBJETOS - Mostra objetos do Frame */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-df
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-df W-Win
ON CHOOSE OF bt-df IN FRAME F-Main /* Exporta DF */
DO:
    /*----- SOMENTE PARA OBJETOS BROWSE -----*/
    IF NOT AVAIL tt-resultado OR
       tt-resultado.tipo <> "Browse" THEN
        RETURN NO-APPLY.


    SYSTEM-DIALOG GET-FILE c-nome-arq
        TITLE      "Arquivo para exportar..."
        FILTERS    "(*.df)"   "*.df",
                   "(*.txt)" "*.txt"
        INITIAL-DIR SESSION:TEMP-DIRECTORY
        USE-FILENAME
        UPDATE l-ok.

    IF l-ok = TRUE THEN
        RUN pi-exporta-df.
    ELSE      
        RETURN no-apply.            
  
        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-exporta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-exporta W-Win
ON CHOOSE OF bt-exporta IN FRAME F-Main /* Button 4 */
DO:

    SYSTEM-DIALOG GET-FILE c-nome-arq
        TITLE      "Arquivo para exportar..."
        FILTERS    "(*.d)"   "*.d",
                   "(*.txt)" "*.txt"
        INITIAL-DIR SESSION:TEMP-DIRECTORY
        USE-FILENAME
        UPDATE l-ok.

    IF l-ok = TRUE THEN
        RUN pi-exporta.
    ELSE      
        RETURN no-apply.            
  
        
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-fechar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-fechar W-Win
ON CHOOSE OF bt-fechar IN FRAME F-Main /* Fechar */
DO:
  &IF DEFINED (adm-panel) <> 0 &THEN
      RUN dispatch IN THIS-PROCEDURE ('exit').
  &ELSE
      APPLY "CLOSE":U TO THIS-PROCEDURE.
  &ENDIF
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-resultado
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK W-Win 


/* ***************************  Main Block  *************************** */
/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects W-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available W-Win  _ADM-ROW-AVAILABLE
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

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI W-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(W-Win)
  THEN DELETE WIDGET W-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI W-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  ENABLE bt-exporta br-resultado bt-fechar bt-df 
      WITH FRAME F-Main IN WINDOW W-Win.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
  VIEW W-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit W-Win 
PROCEDURE local-exit :
/* -----------------------------------------------------------
  Purpose:  Starts an "exit" by APPLYing CLOSE event, which starts "destroy".
  Parameters:  <none>
  Notes:    If activated, should APPLY CLOSE, *not* dispatch adm-exit.   
-------------------------------------------------------------*/
   APPLY "CLOSE":U TO THIS-PROCEDURE.
   
   RETURN.
       
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize W-Win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
  /* Code placed here will execute PRIOR to standard behavior. */
  RUN pi-cria-campos.  

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cria-campos W-Win 
PROCEDURE pi-cria-campos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

EMPTY TEMP-TABLE tt-resultado.

fc-cria-campos(p-wh-objeto).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-exporta W-Win 
PROCEDURE pi-exporta :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

SESSION:SET-WAIT("general").

OUTPUT STREAM s-saida TO value(c-nome-arq).

FOR EACH tt-resultado:
    EXPORT STREAM s-saida tt-resultado EXCEPT wh-handle.
END.

OUTPUT STREAM s-saida CLOSE.

SESSION:SET-WAIT("").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-exporta-df W-Win 
PROCEDURE pi-exporta-df :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF VAR wh-query   AS WIDGET-HANDLE NO-UNDO.
DEF VAR wh-buffer  AS WIDGET-HANDLE NO-UNDO.
DEF VAR wh-field   AS WIDGET-HANDLE NO-UNDO.
DEF VAR ct-buffer  AS INTEGER       NO-UNDO.
DEF VAR ct-field   AS INTEGER       NO-UNDO.

SESSION:SET-WAIT("general").

OUTPUT STREAM s-saida TO value(c-nome-arq).

wh-query = tt-resultado.wh-handle:QUERY.

DO ct-buffer = 1 TO wh-query:NUM-BUFFERS:

    wh-buffer = wh-query:GET-BUFFER-HANDLE(ct-buffer).

    PUT STREAM s-saida
        "DEF TEMP-TABLE " wh-buffer:NAME FORMAT "x(15)" SKIP.

    DO ct-field = 1 TO wh-buffer:NUM-FIELDS:

        wh-field = wh-buffer:BUFFER-FIELD(ct-field).

        PUT STREAM s-saida
            "   FIELD " wh-field:NAME FORMAT "x(20)" " as " wh-field:DATA-TYPE FORMAT "x(15)".

        IF wh-field:decimals > 2 THEN
            PUT STREAM s-saida
                " decimals " wh-field:EXTENT.
        
        IF wh-field:EXTENT > 1 THEN
            PUT STREAM s-saida
                " extent " wh-field:EXTENT.

        PUT STREAM s-saida 
            SKIP.

    END.

    PUT STREAM s-saida "." SKIP(2).

END.






OUTPUT STREAM s-saida CLOSE.

SESSION:SET-WAIT("").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records W-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-resultado"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed W-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-cria-campos W-Win 
FUNCTION fc-cria-campos RETURNS LOGICAL
  ( p-fc-wh-objeto AS widget-handle ) :

def var wh-objeto as widget-handle no-undo.
DEF VAR wh-frame  AS WIDGET-HANDLE NO-UNDO.

wh-objeto = p-fc-wh-objeto:first-child.


do while valid-handle(wh-objeto):

   if wh-objeto:type = "field-group" then do:
      fc-cria-campos(wh-objeto).
   end. 
   
   if wh-objeto:type = "frame" then do:
      fc-cria-campos(wh-objeto).
   end. 
   
   if wh-objeto:type = "window" then do:
      fc-cria-campos(wh-objeto).
   end. 

   wh-frame = wh-objeto:FRAME NO-ERROR.

   CREATE tt-resultado.
   ASSIGN tt-resultado.nome   = wh-objeto:NAME
          tt-resultado.tipo   = wh-objeto:TYPE 
          tt-resultado.linha  = wh-objeto:ROW
          tt-resultado.coluna = wh-objeto:COL
          tt-resultado.formato = wh-objeto:FORMAT
          tt-resultado.altura  = wh-objeto:HEIGHT
          tt-resultado.largura = wh-objeto:WIDTH
          tt-resultado.tipo-inf = wh-objeto:DATA-TYPE
          tt-resultado.nome-frame = wh-frame:NAME
          tt-resultado.tabela = wh-frame:TABLE 
          tt-resultado.wh-handle = wh-objeto
          NO-ERROR.
     
   IF tt-resultado.tipo = "browse" THEN
       tt-resultado.tabela = fc-cria-tabela(wh-objeto).

   wh-objeto = wh-objeto:next-sibling.

end.
    
RETURN TRUE.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-cria-tabela W-Win 
FUNCTION fc-cria-tabela RETURNS CHARACTER
  ( p-wh-objeto AS widget-handle ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR fc-tabelas AS CHAR          NO-UNDO.
DEF VAR fc-query   AS WIDGET-HANDLE NO-UNDO.
DEF VAR fc-buffer  AS WIDGET-HANDLE NO-UNDO.
DEF VAR fc-ct      AS INT           NO-UNDO.

fc-query = p-wh-objeto:QUERY.

DO fc-ct = 1 TO fc-query:NUM-BUFFERS:

    fc-buffer = fc-query:GET-BUFFER-HANDLE(fc-ct).
    fc-tabelas = fc-tabelas + (IF fc-tabelas = "" THEN "" ELSE ",") +
                 fc-buffer:NAME.

END.


RETURN fc-tabelas.
   

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

