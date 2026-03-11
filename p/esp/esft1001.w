&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ESFT1001 2.00.01.GCJ}

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        ESFT1001
&GLOBAL-DEFINE Version        2.00.01.GCJ

&GLOBAL-DEFINE WindowType     Master
&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   

&GLOBAL-DEFINE page0Widgets   c-diretorio-processar c-diretorio-processado btOK btCancel btFile2 btFile3 ~
                              
&GLOBAL-DEFINE page1Widgets   
&GLOBAL-DEFINE page2Widgets   

&GLOBAL-DEFINE EXCLUDE-translate     YES
&GLOBAL-DEFINE EXCLUDE-translateMenu YES


/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar RECT-1 c-diretorio-processar ~
btFile2 btFile3 c-diretorio-processado btOK btCancel 
&Scoped-Define DISPLAYED-OBJECTS c-diretorio-processar ~
c-diretorio-processado 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btFile2 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON btFile3 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-diretorio-processado AS CHARACTER FORMAT "X(256)":U 
     LABEL "Dir. Processados" 
     VIEW-AS FILL-IN 
     SIZE 68 BY .88 NO-UNDO.

DEFINE VARIABLE c-diretorio-processar AS CHARACTER FORMAT "X(256)":U 
     LABEL "Dir. A Processar" 
     VIEW-AS FILL-IN 
     SIZE 68 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 87 BY 4.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     c-diretorio-processar AT ROW 2.71 COL 13.14 COLON-ALIGNED WIDGET-ID 26
     btFile2 AT ROW 2.75 COL 84 HELP
          "Escolha do nome do arquivo" WIDGET-ID 42
     btFile3 AT ROW 3.75 COL 84 HELP
          "Escolha do nome do arquivo" WIDGET-ID 44
     c-diretorio-processado AT ROW 3.83 COL 13.14 COLON-ALIGNED WIDGET-ID 36
     btOK AT ROW 6.71 COL 2 WIDGET-ID 4
     btCancel AT ROW 6.71 COL 13 WIDGET-ID 2
     rtToolBar AT ROW 6.5 COL 1 WIDGET-ID 6
     RECT-1 AT ROW 1.75 COL 2 WIDGET-ID 38
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 7.08
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 7.42
         WIDTH              = 90
         MAX-HEIGHT         = 17
         MAX-WIDTH          = 90
         VIRTUAL-HEIGHT     = 17
         VIRTUAL-WIDTH      = 90
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wWindow 
/* ************************* Included-Libraries *********************** */

{window/window.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON END-ERROR OF wWindow
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFile2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFile2 wWindow
ON CHOOSE OF btFile2 IN FRAME fpage0
DO:
  /*  {report/rparq.i} */

    DEFINE VARIABLE c-dir AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE l-cancelado AS LOGICAL     NO-UNDO.

    run utp/ut-dir.r (input "Selecione o diret¢rio.",
                      output c-dir,
                      output l-cancelado).
       if not l-cancelado then
           assign c-diretorio-processar:SCREEN-VALUE IN FRAME fPage0 = /* campo de destino da tela */
                if length (c-dir) > 3 
                and substr(c-dir, length(c-dir), 1) <> "~\"
                then (c-dir + "~\") 
                else c-dir.


    /*
    def var cArqConv  as char no-undo.

    assign cArqConv = replace(input frame fPage2 c-diretorio, "/":U, "~\":U).
    SYSTEM-DIALOG GET-FILE cArqConv
       FILTERS "*.csv":U "*.csv":U,
               "*.*":U "*.*":U
       ASK-OVERWRITE 
       DEFAULT-EXTENSION "csv":U
       INITIAL-DIR session:temp-directory
       SAVE-AS
       USE-FILENAME
       UPDATE l-ok.
    if  l-ok = yes then do:
        assign c-diretorio = replace(cArqConv, "~\":U, "/":U).
        display c-diretorio with frame fPage2.
    end.
    
    */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFile3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFile3 wWindow
ON CHOOSE OF btFile3 IN FRAME fpage0
DO:
  /*  {report/rparq.i} */

    DEFINE VARIABLE c-dir AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE l-cancelado AS LOGICAL     NO-UNDO.

    run utp/ut-dir.r (input "Selecione o diret¢rio.",
                      output c-dir,
                      output l-cancelado).
       if not l-cancelado then
           assign c-diretorio-processado:SCREEN-VALUE IN FRAME fPage0 = /* campo de destino da tela */
                if length (c-dir) > 3 
                and substr(c-dir, length(c-dir), 1) <> "~\"
                then (c-dir + "~\") 
                else c-dir.


    /*
    def var cArqConv  as char no-undo.

    assign cArqConv = replace(input frame fPage2 c-diretorio, "/":U, "~\":U).
    SYSTEM-DIALOG GET-FILE cArqConv
       FILTERS "*.csv":U "*.csv":U,
               "*.*":U "*.*":U
       ASK-OVERWRITE 
       DEFAULT-EXTENSION "csv":U
       INITIAL-DIR session:temp-directory
       SAVE-AS
       USE-FILENAME
       UPDATE l-ok.
    if  l-ok = yes then do:
        assign c-diretorio = replace(cArqConv, "~\":U, "/":U).
        display c-diretorio with frame fPage2.
    end.
    
    */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    DEFINE VARIABLE c-diretorio AS CHARACTER   NO-UNDO.

    ASSIGN c-diretorio = INPUT FRAME fPage0 c-diretorio-processar.


   ASSIGN file-info:file-name = c-diretorio.
   if  file-info:pathname = ? THEN DO:

       RUN utp\ut-msgs.p (INPUT "SHOW",
                          INPUT 25997,
                          INPUT "Diretorio Arquivo a Processar  invalido!!").

       APPLY "ENTRY" TO c-diretorio-processar IN FRAME fpage0.

       RETURN NO-APPLY.
   END.

   ASSIGN c-diretorio = INPUT FRAME fPage0 c-diretorio-processado.


    ASSIGN file-info:file-name = c-diretorio.
    if  file-info:pathname = ? THEN DO:

        RUN utp\ut-msgs.p (INPUT "SHOW",
                           INPUT 25997,
                           INPUT "Diretorio Arquivo Processador  invalido!!").

        APPLY "ENTRY" TO c-diretorio-processado IN FRAME fpage0.

        RETURN NO-APPLY.
    END.

    
    
    
  FIND FIRST es-diretorio-nexxera EXCLUSIVE-LOCK NO-ERROR.

  IF NOT AVAIL es-diretorio-nexxera  THEN DO:

      CREATE es-diretorio-nexxera.
  END.


  ASSIGN es-diretorio-nexxera.diretorio-processar  = input frame fPage0 c-diretorio-processar
         es-diretorio-nexxera.diretorio-processado =  input frame fPage0 c-diretorio-processado.
         

    
    
    
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{window/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wWindow 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

 FIND FIRST es-diretorio-nexxera NO-LOCK NO-ERROR.

 IF AVAIL es-diretorio-nexxera THEN
     DISP es-diretorio-nexxera.diretorio-processar @ c-diretorio-processar
          es-diretorio-nexxera.diretorio-processado @ c-diretorio-processado
          WITH FRAME fPage0.
 ELSE 
     DISP "" @ c-diretorio-processar
          "" @ c-diretorio-processado
          WITH FRAME fPage0.


RETURN "OK".



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Translate wWindow 
PROCEDURE Translate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


 RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

