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
** AUTOR.....: Odair Batista / Leandro Johann
** DATA......: 13/07/2008
** FINALIDADE: Gerar adapter's (EAI) e classes baseadas em PROOF
** OBSERVAÇÃO: Este aplicativo foi desenvolvido com base no gerador anteriormente 
**             criado por Richard Edgar da Cruz
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

define variable inclusao     as logical no-undo.
define variable classeHandle as handle  no-undo.

{utils/class/classGeneratorDefine.i}

define variable c-arq-digita as character no-undo.
define variable l-ok         as logical   no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-livre
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-cad
&Scoped-define BROWSE-NAME browserFields

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttAttributes

/* Definitions for BROWSE browserFields                                 */
&Scoped-define FIELDS-IN-QUERY-browserFields ttAttributes.fieldName ttAttributes.attributeName ttAttributes.labelField ttAttributes.numExtent ttAttributes.typeField   
&Scoped-define ENABLED-FIELDS-IN-QUERY-browserFields ttAttributes.fieldName ~
 ttAttributes.attributeName ~
 ttAttributes.labelField ~
 ttAttributes.numExtent ~
 ttAttributes.typeField   
&Scoped-define ENABLED-TABLES-IN-QUERY-browserFields ttAttributes
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-browserFields ttAttributes
&Scoped-define SELF-NAME browserFields
&Scoped-define QUERY-STRING-browserFields FOR EACH ttAttributes
&Scoped-define OPEN-QUERY-browserFields OPEN QUERY {&SELF-NAME} FOR EACH ttAttributes.
&Scoped-define TABLES-IN-QUERY-browserFields ttAttributes
&Scoped-define FIRST-TABLE-IN-QUERY-browserFields ttAttributes


/* Definitions for FRAME f-cad                                          */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-cad ~
    ~{&OPEN-QUERY-browserFields}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS productName moduleName transactionName ~
productType productVersion transactionVersion generateAdapter useDBO ~
folderTarget browserFields btAdd btDel btGen btRead btClear btSave ~
btRestore fi-arquivo-destino btFechar RECT-1 
&Scoped-Define DISPLAYED-OBJECTS productName moduleName transactionName ~
productType productVersion transactionVersion generateAdapter useDBO ~
DBOFile folderTarget fi-arquivo-destino 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-livre AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btAdd 
     LABEL "Incluir Campo" 
     SIZE 12.29 BY 1.

DEFINE BUTTON btClear 
     LABEL "Limpar Campos" 
     SIZE 13 BY 1.

DEFINE BUTTON btDel 
     LABEL "Eliminar Campo" 
     SIZE 13 BY 1.

DEFINE BUTTON btFechar 
     LABEL "Fechar" 
     SIZE 10.14 BY 1.

DEFINE BUTTON btGen 
     LABEL "Gerar Codigo" 
     SIZE 11.72 BY 1.

DEFINE BUTTON btRead 
     LABEL "Ler Tabela" 
     SIZE 9.86 BY 1.

DEFINE BUTTON btRestore 
     LABEL "Recuperar" 
     SIZE 10.14 BY 1.

DEFINE BUTTON btSave 
     LABEL "Salvar" 
     SIZE 7.72 BY 1.

DEFINE VARIABLE DBOFile AS CHARACTER FORMAT "X(256)":U 
     LABEL "DBO" 
     VIEW-AS FILL-IN 
     SIZE 38 BY .88 NO-UNDO.

DEFINE VARIABLE fi-arquivo-destino AS CHARACTER FORMAT "X(256)":U 
     LABEL "Arquivo destino" 
     VIEW-AS FILL-IN 
     SIZE 70 BY .88 NO-UNDO.

DEFINE VARIABLE folderTarget AS CHARACTER FORMAT "X(256)":U INITIAL "C:~\Datasul~\Clientes" 
     LABEL "Pasta Saida" 
     VIEW-AS FILL-IN 
     SIZE 70 BY .88 NO-UNDO.

DEFINE VARIABLE moduleName AS CHARACTER FORMAT "X(256)":U 
     LABEL "M¢dulo" 
     VIEW-AS FILL-IN 
     SIZE 21 BY .88 NO-UNDO.

DEFINE VARIABLE productName AS CHARACTER FORMAT "X(256)":U INITIAL "Integracao" 
     LABEL "Produto" 
     VIEW-AS FILL-IN 
     SIZE 21 BY .88 NO-UNDO.

DEFINE VARIABLE productVersion AS CHARACTER FORMAT "X(3)":U INITIAL "206" 
     LABEL "VersÆo" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE transactionName AS CHARACTER FORMAT "X(256)":U 
     LABEL "Transa‡Æo/Classe" 
     VIEW-AS FILL-IN 
     SIZE 21 BY .88 NO-UNDO.

DEFINE VARIABLE transactionVersion AS CHARACTER FORMAT "X(7)":U INITIAL "206.000" 
     LABEL "VersÆo" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE productType AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "EMS2", 1,
"EMS5", 2,
"Nenhum", 3
     SIZE 29 BY .75 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 112.29 BY 6.25.

DEFINE VARIABLE generateAdapter AS LOGICAL INITIAL no 
     LABEL "Gerar Adapter" 
     VIEW-AS TOGGLE-BOX
     SIZE 17.14 BY .83 NO-UNDO.

DEFINE VARIABLE useDBO AS LOGICAL INITIAL no 
     LABEL "Usar BO na Classe" 
     VIEW-AS TOGGLE-BOX
     SIZE 21.29 BY .83 NO-UNDO.

DEFINE BUTTON btOk 
     LABEL "OK" 
     SIZE 5 BY 1.

DEFINE VARIABLE nomeTabela AS CHARACTER FORMAT "X(256)":U 
     LABEL "Tabela" 
     VIEW-AS FILL-IN 
     SIZE 36.57 BY .88 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY browserFields FOR 
      ttAttributes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE browserFields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browserFields w-livre _FREEFORM
  QUERY browserFields DISPLAY
      ttAttributes.fieldName     format 'x(28)'  width 30 column-label 'Campo'
      ttAttributes.attributeName format 'x(29)'  width 30 column-label 'Atributo'
      ttAttributes.labelField    format 'x(40)'  width 40 column-label 'Label'
      ttAttributes.numExtent     format '>>9'    width 5  column-label 'Extent'
      ttAttributes.typeField     format 'x(10)'  width 8  column-label 'Tipo'
    enable
        ttAttributes.fieldName
        ttAttributes.attributeName
        ttAttributes.labelField
        ttAttributes.numExtent
        ttAttributes.typeField
    help 'Digite as inicias do tipo de campo: in,ch,de,da,lo'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 112.29 BY 17
         FONT 1
         TITLE "Rela‡Æo de campos para a Classe".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-cad
     productName AT ROW 1.25 COL 23 COLON-ALIGNED
     moduleName AT ROW 2.25 COL 23 COLON-ALIGNED
     transactionName AT ROW 3.25 COL 23 COLON-ALIGNED
     productType AT ROW 1.25 COL 78 NO-LABEL
     productVersion AT ROW 1.25 COL 55 COLON-ALIGNED
     transactionVersion AT ROW 3.25 COL 55 COLON-ALIGNED
     generateAdapter AT ROW 3.25 COL 78
     useDBO AT ROW 4.25 COL 25
     DBOFile AT ROW 4.25 COL 55 COLON-ALIGNED
     folderTarget AT ROW 5.25 COL 23 COLON-ALIGNED
     browserFields AT ROW 7.5 COL 1.72
     btAdd AT ROW 24.83 COL 1.86
     btDel AT ROW 24.83 COL 14.72
     btGen AT ROW 24.83 COL 28.29
     btRead AT ROW 24.83 COL 40.57
     btClear AT ROW 24.83 COL 51
     btSave AT ROW 24.83 COL 64.57
     btRestore AT ROW 24.83 COL 73
     fi-arquivo-destino AT ROW 6.25 COL 23 COLON-ALIGNED
     btFechar AT ROW 24.83 COL 103.86
     RECT-1 AT ROW 1 COL 1.72
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 114.29 BY 25
         FONT 1.

DEFINE FRAME opcTabela
     btOk AT ROW 1.21 COL 46.29
     nomeTabela AT ROW 1.25 COL 7 COLON-ALIGNED
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 30 ROW 14.25
         SIZE 51 BY 2.25
         TITLE "Op‡äes de Tabela".


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
         WIDTH              = 114.29
         MAX-HEIGHT         = 25
         MAX-WIDTH          = 114.29
         VIRTUAL-HEIGHT     = 25
         VIRTUAL-WIDTH      = 114.29
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
/* REPARENT FRAME */
ASSIGN FRAME opcTabela:FRAME = FRAME f-cad:HANDLE.

/* SETTINGS FOR FRAME f-cad
   FRAME-NAME Custom                                                    */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME opcTabela:MOVE-BEFORE-TAB-ITEM (productName:HANDLE IN FRAME f-cad)
/* END-ASSIGN-TABS */.

/* BROWSE-TAB browserFields folderTarget f-cad */
/* SETTINGS FOR FILL-IN DBOFile IN FRAME f-cad
   NO-ENABLE                                                            */
ASSIGN 
       fi-arquivo-destino:READ-ONLY IN FRAME f-cad        = TRUE.

/* SETTINGS FOR FRAME opcTabela
   NOT-VISIBLE                                                          */
ASSIGN 
       FRAME opcTabela:HIDDEN           = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-livre)
THEN w-livre:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browserFields
/* Query rebuild information for BROWSE browserFields
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttAttributes.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE browserFields */
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


&Scoped-define BROWSE-NAME browserFields
&Scoped-define SELF-NAME browserFields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browserFields w-livre
ON ENTER OF browserFields IN FRAME f-cad /* Rela‡Æo de campos para a Classe */
ANYWHERE
DO:
  apply 'tab':U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browserFields w-livre
ON OFF-END OF browserFields IN FRAME f-cad /* Rela‡Æo de campos para a Classe */
DO:
    if inclusao = true then do:
        assign inclusao = false.
        apply 'choose' to btAdd in frame {&frame-name}.
    end.
    else do:
        apply 'entry' to btAdd in frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browserFields w-livre
ON ROW-LEAVE OF browserFields IN FRAME f-cad /* Rela‡Æo de campos para a Classe */
DO:
    if browserFields:NEW-ROW in frame {&frame-name} then 
    do transaction on error undo, return no-apply:
        create ttAttributes.
        assign input browse browserFields ttAttributes.fieldName
               input browse browserFields ttAttributes.attributeName
               input browse browserFields ttAttributes.numExtent
               input browse browserFields ttAttributes.typeField
               input browse browserFields ttAttributes.labelField.
    
        browserFields:CREATE-RESULT-LIST-ENTRY() in frame {&frame-name}.
    end.
    else do transaction on error undo, return no-apply:
        assign input browse browserFields ttAttributes.fieldName
               input browse browserFields ttAttributes.attributeName
               input browse browserFields ttAttributes.numExtent
               input browse browserFields ttAttributes.typeField
               input browse browserFields ttAttributes.labelField.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd w-livre
ON CHOOSE OF btAdd IN FRAME f-cad /* Incluir Campo */
DO:
  inclusao = true.
  if num-results("browserFields":U) > 0 then
    browserFields:INSERT-ROW("after":U) in frame {&frame-name}.
  else do transaction:
    create ttAttributes.
    open query browserFields for each ttAttributes.
    apply "entry":U to ttAttributes.fieldName in browse browserFields. 
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btClear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btClear w-livre
ON CHOOSE OF btClear IN FRAME f-cad /* Limpar Campos */
DO:
  frame opcTabela:hidden = true.
  empty temp-table ttAttributes.
  open query browserFields for each ttAttributes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDel w-livre
ON CHOOSE OF btDel IN FRAME f-cad /* Eliminar Campo */
DO:
  if browserFields:num-selected-rows > 0 then do on error undo, return no-apply:
    get current browserFields.
    delete ttAttributes.
    if browserFields:delete-current-row() in frame {&frame-name} then.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFechar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFechar w-livre
ON CHOOSE OF btFechar IN FRAME f-cad /* Fechar */
DO:
    apply 'close':u to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGen w-livre
ON CHOOSE OF btGen IN FRAME f-cad /* Gerar Codigo */
DO:
    do {&try}:
        run emptyErrors.

        for each ttAttributes:
            if trim(ttAttributes.tableName)     = '' and
               trim(ttAttributes.fieldName)     = '' and
               trim(ttAttributes.attributeName) = '' and
               trim(ttAttributes.typeField)     = '' then
                delete ttAttributes.
            else do:
              if trim(ttAttributes.fieldName)        = '' and
                 trim(ttAttributes.attributeName) <> '' then
                  assign ttAttributes.fieldName = ttAttributes.attributeName.
            end.
        end.

        run showArquivoDestino.

        run outputFiles in classeHandle (input table ttAttributes).

        empty temp-table ttAttributes.
        open query browserFields for each ttAttributes.
    end.
  
    run showErrors.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME opcTabela
&Scoped-define SELF-NAME btOk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOk w-livre
ON CHOOSE OF btOk IN FRAME opcTabela /* OK */
DO:
  run lerTabela.
  frame opcTabela:hidden = true.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-cad
&Scoped-define SELF-NAME btRead
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btRead w-livre
ON CHOOSE OF btRead IN FRAME f-cad /* Ler Tabela */
DO:
  empty temp-table ttAttributes.
  frame opcTabela:hidden = false.
  apply 'entry' to nomeTabela in frame opcTabela.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btRestore
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btRestore w-livre
ON CHOOSE OF btRestore IN FRAME f-cad /* Recuperar */
DO:
    define variable fileBackup as character no-undo.
    define variable returnOK   as logical   no-undo initial false.

    system-dialog get-file fileBackup
       filters "*.dig" "*.dig",
               "*.*" "*.*"
       default-extension "*.dig"
       must-exist
       use-filename
       update returnOK.

    if returnOK then do:
        empty temp-table ttAttributes.

        input from value(fileBackup) no-echo.
        repeat:             
            create ttAttributes.
            import ttAttributes.
        end.    
        input close. 

        delete ttAttributes.

        open query browserFields for each ttAttributes.

        if num-results("browserFields":U) > 0 then 
            assign btDel:sensitive  in frame {&frame-name} = true
                   btSave:sensitive in frame {&frame-name} = true.
        else
            assign btDel:sensitive  in frame {&frame-name} = false
                   btSave:sensitive in frame {&frame-name} = false.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSave w-livre
ON CHOOSE OF btSave IN FRAME f-cad /* Salvar */
DO:
    define variable rowTtAttributes as rowid no-undo.
    define variable fileBackup      as character no-undo.
    define variable returnOK        as logical   no-undo initial false.

    system-dialog get-file fileBackup
        filters "*.dig" "*.dig",
                "*.*" "*.*"
        ask-overwrite 
        default-extension "*.dig"
        save-as             
        create-test-file
        use-filename
        update returnOK.

    if available ttAttributes then 
        rowTtAttributes = rowid(ttAttributes).

    if returnOK then do:
        output to value(fileBackup).
        for each ttAttributes:
            export ttAttributes.
        end.
        output close. 

        reposition browserFields to rowid(rowTtAttributes) no-error.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME folderTarget
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL folderTarget w-livre
ON LEAVE OF folderTarget IN FRAME f-cad /* Pasta Saida */
DO:
    run showArquivoDestino.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME moduleName
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL moduleName w-livre
ON LEAVE OF moduleName IN FRAME f-cad /* M¢dulo */
DO:
    run showArquivoDestino.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME opcTabela
&Scoped-define SELF-NAME nomeTabela
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL nomeTabela w-livre
ON RETURN OF nomeTabela IN FRAME opcTabela /* Tabela */
DO:
  apply 'choose' to btOk in frame opcTabela.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-cad
&Scoped-define SELF-NAME productName
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL productName w-livre
ON LEAVE OF productName IN FRAME f-cad /* Produto */
DO:
    run showArquivoDestino.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME productType
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL productType w-livre
ON VALUE-CHANGED OF productType IN FRAME f-cad
DO:
  if  input frame f-cad productType = 1 then
    assign productVersion  :screen-value in frame f-cad = "206"
           transactionVersion:screen-value in frame f-cad = "206.000".
  else
  if  input frame f-cad productType = 2 then
    assign productVersion  :screen-value in frame f-cad = "506"
           transactionVersion:screen-value in frame f-cad = "506.000".

    run showArquivoDestino.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME transactionName
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL transactionName w-livre
ON LEAVE OF transactionName IN FRAME f-cad /* Transa‡Æo/Classe */
DO:
    run showArquivoDestino.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME useDBO
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL useDBO w-livre
ON VALUE-CHANGED OF useDBO IN FRAME f-cad /* Usar BO na Classe */
DO:
  DBOFile:sensitive = self:checked.
  if not self:checked then
      DBOFile:screen-value = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-livre 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}


  on value-changed of ttAttributes.typeField in browse browserFields do:
      case substring(ttAttributes.typeField:screen-value in browse browserFields,1,2):
          when 'in' then assign ttAttributes.typeField:screen-value in browse browserFields = 'integer'.
          when 'CH' then assign ttAttributes.typeField:screen-value in browse browserFields = 'character'.
          when 'DE' then assign ttAttributes.typeField:screen-value in browse browserFields = 'decimal'.
          when 'DA' then assign ttAttributes.typeField:screen-value in browse browserFields = 'date'.
          when 'HA' then assign ttAttributes.typeField:screen-value in browse browserFields = 'handle'.
          when 'LO' then assign ttAttributes.typeField:screen-value in browse browserFields = 'logical'.
          otherwise
              if length(trim(ttAttributes.typeField:screen-value in browse browserFields)) > 2 then
                  assign ttAttributes.typeField:screen-value in browse browserFields = ''.
      end case.
  end.

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
  DISPLAY productName moduleName transactionName productType productVersion 
          transactionVersion generateAdapter useDBO DBOFile folderTarget 
          fi-arquivo-destino 
      WITH FRAME f-cad IN WINDOW w-livre.
  ENABLE productName moduleName transactionName productType productVersion 
         transactionVersion generateAdapter useDBO folderTarget browserFields 
         btAdd btDel btGen btRead btClear btSave btRestore fi-arquivo-destino 
         btFechar RECT-1 
      WITH FRAME f-cad IN WINDOW w-livre.
  {&OPEN-BROWSERS-IN-QUERY-f-cad}
  DISPLAY nomeTabela 
      WITH FRAME opcTabela IN WINDOW w-livre.
  ENABLE btOk nomeTabela 
      WITH FRAME opcTabela IN WINDOW w-livre.
  {&OPEN-BROWSERS-IN-QUERY-opcTabela}
  VIEW w-livre.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lerTabela w-livre 
PROCEDURE lerTabela :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define variable tabela      as handle  no-undo.
  define variable campoTabela as handle  no-undo.
  define variable contador    as integer no-undo.

  do {&throws}:
      create buffer tabela for table nomeTabela:screen-value in frame opcTabela no-error.
      if valid-handle(tabela) then do:
          contador = 1.

          repeat:
              campoTabela = tabela:buffer-field(contador) no-error.
              if not valid-handle(campoTabela) then 
                  leave.
              else do:
                  if not can-find(first ttAttributes no-lock where
                                        ttAttributes.tableName = nomeTabela:screen-value in frame opcTabela and
                                        ttAttributes.fieldName = campoTabela:name) then do:
                      create ttAttributes.
                      assign ttAttributes.dbaseName     = tabela:dbname
                             ttAttributes.tableName     = nomeTabela:screen-value in frame opcTabela
                             ttAttributes.fieldName     = substring(campoTabela:name,1,28)
                             ttAttributes.attributeName = substring(campoTabela:name,1,29)
                             ttAttributes.typeField     = campoTabela:data-type
                             ttAttributes.labelField    = campoTabela:label
                             ttAttributes.numExtent     = campoTabela:extent.
                  end.
              end.

              contador = contador + 1.
          end.
      end.

      open query browserFields for each ttAttributes.
  end.
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

  run showArquivoDestino.  

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
  {src/adm/template/snd-list.i "ttAttributes"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setsInClasse w-livre 
PROCEDURE setsInClasse PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do with frame {&frame-name}
        {&throws}:

        run setProduct in classeHandle
            (productName:screen-value,
             productVersion:screen-value,
             productType:screen-value).

        run setTransaction in classeHandle
            (moduleName:screen-value,
             transactionName:screen-value,
             transactionVersion:screen-value).

        run setGenerateAdapter in classeHandle (generateAdapter:checked).

        run setDBO in classeHandle
            (useDBO:checked,
             DBOFile:screen-value).

        run setOutputFiles in classeHandle (folderTarget:screen-value).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE showArquivoDestino w-livre 
PROCEDURE showArquivoDestino PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do with frame {&frame-name}
        {&throws}:

        run setsInClasse.

        run getClassFile in classeHandle(false, output fi-arquivo-destino).

        assign
            fi-arquivo-destino = replace(fi-arquivo-destino, '/':u, '\':u).

        display
            fi-arquivo-destino.
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

  run createInstance in ghInstanceManager(this-procedure,
                                          'utils/class/classGeneratorLibrary.p',
                                          output classeHandle).
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

