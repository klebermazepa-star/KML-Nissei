&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME w-livre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-livre 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
**
** AUTOR.....: Odair Batista
** DATA......: 15/07/2008
** FINALIDADE: Visualizar acessors de classes baseadas em PROOF
*******************************************************************************/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

{system\error.i}
{system\InstanceManagerDef.i}

define temp-table ttAttributesDSel no-undo
    field attributeName as character
    field attributeType as integer.

define temp-table ttAttributesSel no-undo like ttAttributesDSel.

define temp-table ttParameter no-undo
    field attributeName   as character
    field parameterIndex  as integer
    field parameterName   as character
    field parameterAction as character
    field parameterType   as character
    index attribute is primary attributeName parameterIndex ascending.

define stream stmClassFile.
define stream stmClipBoard.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-livre
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-cad
&Scoped-define BROWSE-NAME browserAttributesDSel

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttAttributesDSel ttAttributesSel

/* Definitions for BROWSE browserAttributesDSel                         */
&Scoped-define FIELDS-IN-QUERY-browserAttributesDSel ttAttributesDSel.attributeName   
&Scoped-define ENABLED-FIELDS-IN-QUERY-browserAttributesDSel   
&Scoped-define SELF-NAME browserAttributesDSel
&Scoped-define QUERY-STRING-browserAttributesDSel FOR EACH ttAttributesDSel where                                  frame {&frame-name} rsAttributes = 3 or                                  frame {&frame-name} rsAttributes = ttAttributesDSel.attributeType
&Scoped-define OPEN-QUERY-browserAttributesDSel OPEN QUERY {&SELF-NAME} FOR EACH ttAttributesDSel where                                  frame {&frame-name} rsAttributes = 3 or                                  frame {&frame-name} rsAttributes = ttAttributesDSel.attributeType.
&Scoped-define TABLES-IN-QUERY-browserAttributesDSel ttAttributesDSel
&Scoped-define FIRST-TABLE-IN-QUERY-browserAttributesDSel ttAttributesDSel


/* Definitions for BROWSE browserAttributesSel                          */
&Scoped-define FIELDS-IN-QUERY-browserAttributesSel ttAttributesSel.attributeName   
&Scoped-define ENABLED-FIELDS-IN-QUERY-browserAttributesSel   
&Scoped-define SELF-NAME browserAttributesSel
&Scoped-define QUERY-STRING-browserAttributesSel FOR EACH ttAttributesSel
&Scoped-define OPEN-QUERY-browserAttributesSel OPEN QUERY {&SELF-NAME} FOR EACH ttAttributesSel.
&Scoped-define TABLES-IN-QUERY-browserAttributesSel ttAttributesSel
&Scoped-define FIRST-TABLE-IN-QUERY-browserAttributesSel ttAttributesSel


/* Definitions for FRAME f-cad                                          */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-cad ~
    ~{&OPEN-QUERY-browserAttributesDSel}~
    ~{&OPEN-QUERY-browserAttributesSel}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS tgAdapter classFile btFile rsAttributes ~
handleName browserAttributesDSel browserAttributesSel btAdd btDel btAddAll ~
btDelAll btCopy btNew RECT-1 
&Scoped-Define DISPLAYED-OBJECTS tgAdapter classFile rsAttributes ~
handleName 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-livre AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btAdd 
     LABEL "Adicionar >>" 
     SIZE 25 BY 1.

DEFINE BUTTON btAddAll 
     LABEL "Adicionar Todos >>" 
     SIZE 25 BY 1.

DEFINE BUTTON btCopy 
     LABEL "Copiar para o Clipboard" 
     SIZE 25 BY 1.

DEFINE BUTTON btDel 
     LABEL "<< Remover" 
     SIZE 25 BY 1.

DEFINE BUTTON btDelAll 
     LABEL "<< Remover Todos" 
     SIZE 25 BY 1.

DEFINE BUTTON btFile 
     LABEL "Arquivo" 
     SIZE 9.72 BY 1.

DEFINE BUTTON btNew 
     LABEL "Nova Classe" 
     SIZE 25 BY 1.

DEFINE VARIABLE classFile AS CHARACTER FORMAT "X(256)":U 
     LABEL "Classe" 
     VIEW-AS FILL-IN 
     SIZE 70 BY .88 NO-UNDO.

DEFINE VARIABLE handleName AS CHARACTER FORMAT "X(256)":U 
     LABEL "Handle" 
     VIEW-AS FILL-IN 
     SIZE 28 BY .88 NO-UNDO.

DEFINE VARIABLE rsAttributes AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Set's", 1,
"Get's", 2,
"Todos", 3
     SIZE 25.72 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 102 BY 3.13.

DEFINE VARIABLE tgAdapter AS LOGICAL INITIAL no 
     LABEL "Gerar Set's para adapter's" 
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY browserAttributesDSel FOR 
      ttAttributesDSel SCROLLING.

DEFINE QUERY browserAttributesSel FOR 
      ttAttributesSel SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE browserAttributesDSel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browserAttributesDSel w-livre _FREEFORM
  QUERY browserAttributesDSel DISPLAY
      ttAttributesDSel.attributeName format 'x(32)' width 32 column-label 'Atributo'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 35.57 BY 21
         TITLE "Atributos Dispon¡veis".

DEFINE BROWSE browserAttributesSel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browserAttributesSel w-livre _FREEFORM
  QUERY browserAttributesSel DISPLAY
      ttAttributesSel.attributeName format 'x(32)' width 32 column-label 'Atributo'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 35.57 BY 21
         TITLE "Atributos Selecionados".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-cad
     tgAdapter AT ROW 7.5 COL 40.43 WIDGET-ID 70
     classFile AT ROW 1.67 COL 13.57 COLON-ALIGNED WIDGET-ID 6
     btFile AT ROW 1.63 COL 85.86 WIDGET-ID 64
     rsAttributes AT ROW 2.67 COL 15.29 NO-LABEL WIDGET-ID 48
     handleName AT ROW 2.67 COL 55.57 COLON-ALIGNED WIDGET-ID 66
     browserAttributesDSel AT ROW 4.5 COL 1.72 WIDGET-ID 200
     browserAttributesSel AT ROW 4.5 COL 68 WIDGET-ID 300
     btAdd AT ROW 12.25 COL 40 WIDGET-ID 54
     btDel AT ROW 13.5 COL 40 WIDGET-ID 56
     btAddAll AT ROW 14.75 COL 40 WIDGET-ID 58
     btDelAll AT ROW 16 COL 40 WIDGET-ID 60
     btCopy AT ROW 17.25 COL 40 WIDGET-ID 52
     btNew AT ROW 18.5 COL 40 WIDGET-ID 68
     RECT-1 AT ROW 1.13 COL 1.72 WIDGET-ID 42
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 103.5 BY 25 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-livre
   Allow: Basic,Browse,DB-Fields,Smart,Window,Query
   Container Links: 
   Add Fields to: Neither
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-livre ASSIGN
         HIDDEN             = YES
         TITLE              = "Gerador de Estrutura para Adapter e Classes de Neg¢cio"
         HEIGHT             = 25
         WIDTH              = 103.57
         MAX-HEIGHT         = 25
         MAX-WIDTH          = 103.57
         VIRTUAL-HEIGHT     = 25
         VIRTUAL-WIDTH      = 103.57
         RESIZE             = yes
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-livre 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-livre
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-cad
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB browserAttributesDSel handleName f-cad */
/* BROWSE-TAB browserAttributesSel browserAttributesDSel f-cad */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-livre)
THEN w-livre:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browserAttributesDSel
/* Query rebuild information for BROWSE browserAttributesDSel
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttAttributesDSel where
                                 frame {&frame-name} rsAttributes = 3 or
                                 frame {&frame-name} rsAttributes = ttAttributesDSel.attributeType
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE browserAttributesDSel */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browserAttributesSel
/* Query rebuild information for BROWSE browserAttributesSel
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttAttributesSel.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE browserAttributesSel */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-livre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-livre w-livre
ON END-ERROR OF w-livre /* Gerador de Estrutura para Adapter e Classes de Neg¢cio */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-livre w-livre
ON WINDOW-CLOSE OF w-livre /* Gerador de Estrutura para Adapter e Classes de Neg¢cio */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browserAttributesDSel
&Scoped-define SELF-NAME browserAttributesDSel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browserAttributesDSel w-livre
ON MOUSE-SELECT-DBLCLICK OF browserAttributesDSel IN FRAME f-cad /* Atributos Dispon¡veis */
DO:
    apply 'choose':U to btAdd in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browserAttributesSel
&Scoped-define SELF-NAME browserAttributesSel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browserAttributesSel w-livre
ON MOUSE-SELECT-DBLCLICK OF browserAttributesSel IN FRAME f-cad /* Atributos Selecionados */
DO:
    apply 'choose':U to btDel in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd w-livre
ON CHOOSE OF btAdd IN FRAME f-cad /* Adicionar >> */
DO:
  if available ttAttributesDSel then do:
      find current ttAttributesDSel exclusive-lock no-error.

      create ttAttributesSel.
      buffer-copy ttAttributesDSel to ttAttributesSel.
      delete ttAttributesDSel.

      run atualizaBrowsers.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAddAll
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddAll w-livre
ON CHOOSE OF btAddAll IN FRAME f-cad /* Adicionar Todos >> */
DO:
    for each ttAttributesDSel exclusive-lock where
             frame {&frame-name} rsAttributes = 3 or
             frame {&frame-name} rsAttributes = ttAttributesDSel.attributeType:
        create ttAttributesSel.
        buffer-copy ttAttributesDSel to ttAttributesSel.
        delete ttAttributesDSel.
    end.

    run atualizaBrowsers.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCopy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCopy w-livre
ON CHOOSE OF btCopy IN FRAME f-cad /* Copiar para o Clipboard */
DO:
    define variable methodParameter_    as character no-undo.
    define variable attributeParameter_ as character no-undo.
    define variable nameParameter_      as character no-undo.
    define variable typeParameter_      as character no-undo.
    define variable numberParameter_    as integer   no-undo.
    define variable typeParameterCompl_ as character no-undo.

    if handleName:screen-value in frame {&frame-name} = '' then
        handleName:screen-value in frame {&frame-name} = '<objectHandle>'.

    output stream stmClipBoard to "clipboard".
    for each ttAttributesSel:
        attributeParameter_ = ''.
        numberParameter_    = 0.
        for each ttParameter where
                 ttParameter.attributeName = ttAttributesSel.attributeName
            break by ttParameter.attributeName:

            if not first-of(ttParameter.attributeName) then
                assign attributeParameter_ = attributeParameter_ + ', '.

            numberParameter_ = numberParameter_ + 1.

            assign attributeParameter_ = if ttParameter.parameterAction = 'input'
                                         then attributeParameter_
                                         else attributeParameter_ + ttParameter.parameterAction + ' '.

            if not tgAdapter:checked in frame {&frame-name} then
                assign attributeParameter_ = attributeParameter_ + ttParameter.parameterName.
            else do:
                nameParameter_ = ttParameter.parameterName.
                if substring(nameParameter_,length(nameParameter_),1) = '_' then
                    nameParameter_ = substring(nameParameter_,1,(length(nameParameter_) - 1)).

                case ttParameter.parameterType:
                    when 'character' or when 'char' then
                        typeParameter_ = 'Val'.
                    when 'integer' or when 'int' then
                        typeParameter_ = 'Dec'.
                    when 'decimal' or when 'dec' then
                        typeParameter_ = 'Dec'.
                    when 'logical' or when 'log' then
                        typeParameter_ = 'Log'.
                    when 'date' or when 'dat' then
                        typeParameter_ = 'Date'.
                end case.

                if numberParameter_ <= 1 then
                    typeParameterCompl_ = ''.
                else
                    typeParameterCompl_ = trim(string(numberParameter_)).

                put stream stmClipBoard unformatted right-trim('run ' 
                                                               + 'getSon'
                                                               + typeParameter_
                                                               + ' in '
                                                               + "hGenXml(getStack(), '"
                                                               + nameParameter_
                                                               + "', "
                                                               + 'output return'
                                                               + typeParameter_
                                                               + typeParameterCompl_
                                                               + ').') skip.

                assign attributeParameter_ = attributeParameter_ + 'null' 
                                                                 + typeParameter_  
                                                                 + '(return'
                                                                 + typeParameter_
                                                                 + typeParameterCompl_
                                                                 + ')'.
            end.
        end.

        put stream stmClipBoard unformatted right-trim('run ' 
                                                       + trim(ttAttributesSel.attributeName)
                                                       + ' in '
                                                       + handleName:screen-value in frame {&frame-name}
                                                       + '('
                                                       + attributeParameter_ 
                                                       + ').') skip.

        if tgAdapter:checked in frame {&frame-name} then
            put stream stmClipBoard unformatted skip(1). 
    end.
    output stream stmClipBoard close.

    message
        "Copiado com sucesso!"
        view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDel w-livre
ON CHOOSE OF btDel IN FRAME f-cad /* << Remover */
DO:
    if available ttAttributesSel then do:
        find current ttAttributesSel exclusive-lock no-error.

        create ttAttributesDSel.
        buffer-copy ttAttributesSel to ttAttributesDSel.
        delete ttAttributesSel.

        run atualizaBrowsers.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDelAll
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelAll w-livre
ON CHOOSE OF btDelAll IN FRAME f-cad /* << Remover Todos */
DO:
    for each ttAttributesSel exclusive-lock:
        create ttAttributesDSel.
        buffer-copy ttAttributesSel to ttAttributesDSel.
        delete ttAttributesSel.
    end.

    run atualizaBrowsers.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFile w-livre
ON CHOOSE OF btFile IN FRAME f-cad /* Arquivo */
DO:
    define variable fileClass as character no-undo.
    define variable returnOK  as logical   no-undo initial false.

    system-dialog get-file fileClass
        title      "Localize a classe"
        filters    "Arquivo fonte (*.p)"       "*.p",
                   "Todos os arquivos (*.*)"   "*.*"
        must-exist
        use-filename
        update returnOK.
      
    if not returnOK then
        return no-apply.

    classFile:screen-value in frame {&frame-name} = fileClass.

    run readClassFile.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btNew
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btNew w-livre
ON CHOOSE OF btNew IN FRAME f-cad /* Nova Classe */
DO:
    run clear.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsAttributes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsAttributes w-livre
ON VALUE-CHANGED OF rsAttributes IN FRAME f-cad
DO:
    if self:screen-value = '1' then 
        assign tgAdapter:sensitive in frame {&frame-name} = true.
    else
        assign tgAdapter:checked   in frame {&frame-name} = false
               tgAdapter:sensitive in frame {&frame-name} = false.
    run atualizaBrowsers.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browserAttributesDSel
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-livre 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-livre  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-livre  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE atualizaBrowsers w-livre 
PROCEDURE atualizaBrowsers :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        {&OPEN-QUERY-browserAttributesDSel}
        {&OPEN-QUERY-browserAttributesSel}
        run setButtons.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear w-livre 
PROCEDURE clear :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do with frame {&frame-name} {&throws}:
        classFile:screen-value    = ''.
        rsAttributes:screen-value = '1'.

        empty temp-table ttAttributesDSel.
        empty temp-table ttAttributesSel.
        empty temp-table ttParameter.

        run atualizaBrowsers.

        apply 'entry':U to classFile.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-livre  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-livre)
  THEN DELETE WIDGET w-livre.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-livre  _DEFAULT-ENABLE
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
  DISPLAY tgAdapter classFile rsAttributes handleName 
      WITH FRAME f-cad IN WINDOW w-livre.
  ENABLE tgAdapter classFile btFile rsAttributes handleName 
         browserAttributesDSel browserAttributesSel btAdd btDel btAddAll 
         btDelAll btCopy btNew RECT-1 
      WITH FRAME f-cad IN WINDOW w-livre.
  {&OPEN-BROWSERS-IN-QUERY-f-cad}
  VIEW w-livre.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy w-livre 
PROCEDURE local-destroy :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'destroy':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  run deleteInstance in ghInstanceManager(this-procedure).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-livre 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize w-livre 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
  run pi-before-initialize.

  {include/win-size.i}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

  run pi-after-initialize.
  run startup.
  run clear.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-after-initialize w-livre 
PROCEDURE pi-after-initialize :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-before-initialize w-livre 
PROCEDURE pi-before-initialize :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-trata-state w-livre 
PROCEDURE pi-trata-state :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter p-state as character no-undo.
  define input parameter p-new   as character no-undo.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE readClassFile w-livre 
PROCEDURE readClassFile :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable lineClassFile_     as character no-undo.
    define variable attributeName_     as character no-undo.
    define variable attributeType_     as integer   no-undo initial 0.
    define variable indexParameter_    as integer   no-undo.
    define variable positionParameter_ as integer   no-undo.
    define variable parameterName_     as character no-undo.
    define variable parameterAction_   as character no-undo.
    define variable parameterType_     as character no-undo.

    do {&throws}:
        empty temp-table ttAttributesDSel.
        empty temp-table ttAttributesSel.
        empty temp-table ttParameter.

        input stream stmClassFile from value(classFile:screen-value in frame {&frame-name}).
        repeat:
            import stream stmClassFile unformatted lineClassFile_.
            if index(lineClassFile_,'&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE') <> 0 then do:
                import stream stmClassFile unformatted lineClassFile_.
                assign attributename_ = substring(trim(lineClassFile_),11)
                       attributename_ = trim(replace(attributename_,':',''))
                       attributename_ = trim(replace(attributename_,'private','')).

                attributeType_ = 0.
                case substring(attributename_,1,3):
                    when 'set' then attributeType_ = 1.
                    when 'get' then attributeType_ = 2.
                    otherwise do:
                        if substring(attributename_,1,2) = 'is':U then
                            attributeType_ = 2.
                    end.
                end case.

                create ttAttributesDSel.
                assign ttAttributesDSel.attributeName = attributeName_
                       ttAttributesDSel.attributeType = attributeType_.

                if available ttAttributesDSel then do:
                    indexParameter_ = 0.
                    repeat:
                        import stream stmClassFile unformatted lineClassFile_.
                        if index(lineClassFile_, 'end procedure') <> 0 then
                            leave.
                        else if ((index(lineClassFile_, 'define') <> 0 or
                                  index(lineClassFile_, 'def') <> 0) and
                                 (index(lineClassFile_, 'input') <> 0 or
                                  index(lineClassFile_, 'output') <> 0) and
                                 (index(lineClassFile_, 'parameter') <> 0 or
                                  index(lineClassFile_, 'param') <> 0)) then do:
                            positionParameter_ = index(lineClassFile_,'param').
                            if positionParameter_ <= 0 then
                                positionParameter_ = index(lineClassFile_,'parameter').

                            parameterName_ = ''.
                            if positionParameter_ > 0 then
                                assign parameterName_ = entry(2,trim(substring(lineClassFile_,positionParameter_)),' ')
                                       parameterType_ = entry(4,trim(substring(lineClassFile_,positionParameter_)),' ').

                            if parameterName_ <> '' then do:
                                indexParameter_ = indexParameter_ + 1.

                                if index(lineClassFile_, 'input-output') <> 0 then
                                    parameterAction_ = 'input-output'.
                                else if index(lineClassFile_, 'input') <> 0 then
                                    parameterAction_ = 'input'.
                                else if index(lineClassFile_, 'output') <> 0 then
                                    parameterAction_ = 'output'.

                                create ttParameter.
                                assign ttParameter.attributeName   = attributeName_ 
                                       ttParameter.parameterIndex  = indexParameter_
                                       ttParameter.parameterName   = parameterName_
                                       ttParameter.parameterType   = parameterType_ 
                                       ttParameter.parameterAction = parameterAction_.
                            end.
                        end.
                    end.
                end.
            end.
        end.
        input stream stmClassFile close.
    end.

    run atualizaBrowsers.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-livre  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "ttAttributesSel"}
  {src/adm/template/snd-list.i "ttAttributesDSel"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setButtons w-livre 
PROCEDURE setButtons :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do with frame {&frame-name} {&throws}:
        if can-find(first ttAttributesDSel where
                          frame {&frame-name} rsAttributes = 3 or
                          frame {&frame-name} rsAttributes = ttAttributesDSel.attributeType) then
            enable btAdd btAddAll.
        else 
            disable btAdd btAddAll.

        if can-find(first ttAttributesSel) then
            enable btDel btDelAll btCopy.
        else 
            disable btDel btDelAll btCopy.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup w-livre 
PROCEDURE startup :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  {system\InstanceManager.i}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-livre 
PROCEDURE state-changed :
/*:T -----------------------------------------------------------
  Purpose:     Manuseia trocas de estado dos SmartObjects
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.

  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

