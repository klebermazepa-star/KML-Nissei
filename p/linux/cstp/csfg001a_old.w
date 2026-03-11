&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
{system/Error.i}
{system/InstanceManagerDef.i}

define temp-table ttRateio no-undo
    like cst_rateio_lojas
    field valor as decimal.

/* Parameters Definitions ---                                           */
define input parameter valorLancamento as decimal no-undo.
define output parameter doRateio as logical    no-undo.
define output parameter table for ttRateio.

/* Local Variable Definitions ---                                       */

define variable item as handle    no-undo.
define variable estabelecimento as handle    no-undo.

define variable nomeEstabelecimento as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME brRateio

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttRateio

/* Definitions for BROWSE brRateio                                      */
&Scoped-define FIELDS-IN-QUERY-brRateio ttRateio.cod_estab getNomeEstabelecimento(ttRateio.cod_estab) @ nomeEstabelecimento ttRateio.valor   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brRateio   
&Scoped-define SELF-NAME brRateio
&Scoped-define QUERY-STRING-brRateio FOR EACH ttRateio NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brRateio OPEN QUERY {&SELF-NAME} FOR EACH ttRateio NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brRateio ttRateio
&Scoped-define FIRST-TABLE-IN-QUERY-brRateio ttRateio


/* Definitions for FRAME DEFAULT-FRAME                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME ~
    ~{&OPEN-QUERY-brRateio}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-16 RECT-43 Loja valorLoja btIncluir ~
brRateio btOK btCancel 
&Scoped-Define DISPLAYED-OBJECTS Loja descEstabelecimento valorLoja 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getNomeEstabelecimento C-Win 
FUNCTION getNomeEstabelecimento RETURNS CHARACTER
  ( input codigoEstabelecimento as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel AUTO-GO 
     LABEL "Cancelar" 
     SIZE 10.57 BY 1 TOOLTIP "Cancela"
     FONT 1.

DEFINE BUTTON btExcluir 
     IMAGE-UP FILE "image/im-can.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-can.bmp":U
     LABEL "Incluir" 
     SIZE 4 BY 1.

DEFINE BUTTON btIncluir 
     IMAGE-UP FILE "image/im-sav.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-add.bmp":U
     LABEL "Incluir" 
     SIZE 4 BY 1.

DEFINE BUTTON btOK AUTO-GO 
     LABEL "OK" 
     SIZE 10.57 BY 1 TOOLTIP "Cancela"
     FONT 1.

DEFINE VARIABLE descEstabelecimento AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 53.29 BY .79 NO-UNDO.

DEFINE VARIABLE Loja AS CHARACTER FORMAT "X(256)":U 
     LABEL "Loja" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE valorLoja AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Valor" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 1 GRAPHIC-EDGE    
     SIZE 79 BY 1.5
     BGCOLOR 18 FGCOLOR 19 .

DEFINE RECTANGLE RECT-43
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL   
     SIZE 79 BY 2.75
     FGCOLOR 19 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brRateio FOR 
      ttRateio SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brRateio
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brRateio C-Win _FREEFORM
  QUERY brRateio NO-LOCK DISPLAY
      ttRateio.cod_estab COLUMN-LABEL "Loja"
          width 15
      getNomeEstabelecimento(ttRateio.cod_estab) @ nomeEstabelecimento
           format 'x(60)' WIDTH 50 column-label 'Nome'
      ttRateio.valor COLUMN-LABEL "Valor"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 79 BY 8.54
         FONT 1 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     Loja AT ROW 1.75 COL 8.29 COLON-ALIGNED WIDGET-ID 18
     descEstabelecimento AT ROW 1.75 COL 14.72 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     valorLoja AT ROW 2.75 COL 8.29 COLON-ALIGNED WIDGET-ID 16
     btIncluir AT ROW 2.75 COL 22 WIDGET-ID 14
     btExcluir AT ROW 2.75 COL 26.72 WIDGET-ID 24
     brRateio AT ROW 4.21 COL 1.43 WIDGET-ID 200
     btOK AT ROW 13.17 COL 57.86 WIDGET-ID 26
     btCancel AT ROW 13.17 COL 69 WIDGET-ID 4
     RECT-16 AT ROW 12.92 COL 1.43 WIDGET-ID 6
     RECT-43 AT ROW 1.25 COL 1.43 WIDGET-ID 10
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80 BY 13.63
         BGCOLOR 17 FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Grade de rateio entre lojas"
         HEIGHT             = 13.63
         WIDTH              = 80
         MAX-HEIGHT         = 17.75
         MAX-WIDTH          = 80
         VIRTUAL-HEIGHT     = 17.75
         VIRTUAL-WIDTH      = 80
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
/* BROWSE-TAB brRateio btExcluir DEFAULT-FRAME */
ASSIGN 
       brRateio:COLUMN-RESIZABLE IN FRAME DEFAULT-FRAME       = TRUE
       brRateio:COLUMN-MOVABLE IN FRAME DEFAULT-FRAME         = TRUE.

/* SETTINGS FOR BUTTON btExcluir IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN descEstabelecimento IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brRateio
/* Query rebuild information for BROWSE brRateio
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttRateio NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE brRateio */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Grade de rateio entre lojas */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Grade de rateio entre lojas */
DO:
  run deleteInstance in ghInstanceManager(this-procedure).
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brRateio
&Scoped-define SELF-NAME brRateio
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brRateio C-Win
ON MOUSE-SELECT-CLICK OF brRateio IN FRAME DEFAULT-FRAME
DO:
    run enableUpdate.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel C-Win
ON CHOOSE OF btCancel IN FRAME DEFAULT-FRAME /* Cancelar */
DO:
    apply "close" to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btExcluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExcluir C-Win
ON CHOOSE OF btExcluir IN FRAME DEFAULT-FRAME /* Incluir */
DO:
    run delete.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btIncluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btIncluir C-Win
ON CHOOSE OF btIncluir IN FRAME DEFAULT-FRAME /* Incluir */
DO:
    run save.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK C-Win
ON CHOOSE OF btOK IN FRAME DEFAULT-FRAME /* OK */
DO:
    run confirmate.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Loja
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Loja C-Win
ON LEAVE OF Loja IN FRAME DEFAULT-FRAME /* Loja */
DO:
    /*{support/ddkgui/leave.i
        &leave=self
        &instance=estabelecimento
        &property=NomeAbreviado
        &widget=descEstabelecimento
        &class= dtsl/ems5/common/Estabelecimento.p}*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  run startup.
  run load.

  apply 'leave' to loja in frame {&frame-name}.

  RUN enable_UI.

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearFields C-Win 
PROCEDURE clearFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do with frame {&frame-name}
        {&throws}:
        enable
            loja.

        disable
            btExcluir.
           
        assign
            loja:screen-value = ''
            valorLoja:screen-value = ''
            descEstabelecimento:screen-value = ''.

        apply 'entry' to loja.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE confirmate C-Win 
PROCEDURE confirmate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&try}:
        run emptyErrors.

        run validate.

        assign
            doRateio = true.

        apply 'close' to this-procedure.
    end.

    run showErrors.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete C-Win 
PROCEDURE delete :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable i as integer   no-undo.

    do with frame {&frame-name}:
        do i = 1 to brRateio:num-selected-rows:

            brRateio:fetch-selected-row(i).

            delete ttRateio.
        end.

        {&OPEN-QUERY-brRateio}

        run clearFields.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enableUpdate C-Win 
PROCEDURE enableUpdate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    if avail ttRateio then do
        with frame {&frame-name}:
        assign
            loja:screen-value = ttRateio.cod_estab
            valorLoja:screen-value = string(ttRateio.valor).

        assign
            descEstabelecimento:screen-value = 
                getNomeEstabelecimento(ttRateio.cod_estab).

        enable
            btExcluir.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
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
  DISPLAY Loja descEstabelecimento valorLoja 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE RECT-16 RECT-43 Loja valorLoja btIncluir brRateio btOK btCancel 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load C-Win 
PROCEDURE load :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    for each cst_rateio_lojas
        no-lock:
        create ttRateio.
        buffer-copy cst_rateio_lojas to ttRateio
            assign
                ttRateio.valor = 
                    valorLancamento * cst_rateio_lojas.val_percentual / 100.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save C-Win 
PROCEDURE save :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do with frame {&frame-name}:
        find first ttRateio
            where ttRateio.cod_estab = loja:input-value
            no-lock no-error.

        if not avail ttRateio then
            create ttRateio.

        assign
            ttRateio.cod_estab = loja:input-value
            ttRateio.valor = valorLoja:input-value.

        {&OPEN-QUERY-brRateio}
        run clearFields.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup C-Win 
PROCEDURE startup :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    {system/InstanceManager.i}
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate C-Win 
PROCEDURE validate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable valorTotal as decimal   no-undo.
    
    do {&throws}:
        for each ttRateio
            no-lock
            {&throws}:
            assign
                valorTotal = valorTotal + ttRateio.valor.
        end.

        if valorTotal <> valorLancamento then do:
            run insertError(524, 'Valor total do rateio ‚ diferente do valor do lan‡amento',
                substitute('Valor total &1 do rateio ‚ diferente do valor do lan‡amento &2',
                valorTotal, valorLancamento)).
            return error.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyInstanceEstabelecimento C-Win 
PROCEDURE verifyInstanceEstabelecimento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if not valid-handle(estabelecimento) then
            run createInstance in ghInstanceManager (this-procedure,
                'dtsl/ems5/common/Estabelecimento.p':u, output estabelecimento).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getNomeEstabelecimento C-Win 
FUNCTION getNomeEstabelecimento RETURNS CHARACTER
  ( input codigoEstabelecimento as character ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    define variable nome as character no-undo.
    define variable found as logical   no-undo.

    run verifyInstanceEstabelecimento.

    run canFind in estabelecimento(codigoEstabelecimento, output found).

    if found then do:
        run find in estabelecimento(codigoEstabelecimento).
        run getNomeAbreviado in estabelecimento(output nome).
    end.

    return nome.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

