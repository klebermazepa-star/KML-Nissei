&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input parameters:
      <none>

  Output parameters:
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

define input parameter pPDFFolder as character no-undo.
define input parameter pPDFFiles  as character no-undo.

/* Local Variable Definitions ---                     */
define variable printerSelect   as character no-undo.
define variable OriginalDefault as character no-undo.
define variable DriverAndPort   as character no-undo.
define variable ReturnValue     as integer   no-undo.

/* external Procs obtained from www.global-shared.com */

procedure GetProfileStringA external "kernel32" :
    define input  parameter lpAppName        as character.
    define input  parameter lpKeyName        as character.
    define input  parameter lpDefault        as character.
    define output parameter lpReturnedString as character.
    define input  parameter nSize            as long.
    define return parameter nReturnedChars   as long.
end procedure.

procedure GetPrivateProfileStringA external "kernel32" :
    define input  parameter lpszSection     as character.
    define input  parameter lpszEntry       as long.
    define input  parameter lpszDefault     as character.
    define input  parameter memBuffer       as long. /* memptr */
    define input  parameter cbReturnBuffer  as long.
    define input  parameter lpszFilename    as character.
    define return parameter cbReturnedChars as long.
end procedure.

procedure WritePrivateProfileStringA external "kernel32":
    define input  parameter lpszSection  as character.
    define input  parameter lpszEntry    as character.
    define input  parameter lpszString   as character.
    define input  parameter lpszFilename as character.
    define return parameter lpszValue    as long.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DDEFrame

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DDEFrame
     "  Aguarde... Imprimindo PDF..." VIEW-AS TEXT
          SIZE 36 BY 1.25 AT ROW 1 COL 1 WIDGET-ID 2
          BGCOLOR 12 FGCOLOR 15 FONT 0
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 36.14 BY 1.29
         FONT 4.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "PDFDirectPrint"
         HEIGHT             = 1.33
         WIDTH              = 36.14
         MAX-HEIGHT         = 16
         MAX-WIDTH          = 80
         VIRTUAL-HEIGHT     = 16
         VIRTUAL-WIDTH      = 80
         SMALL-TITLE        = yes
         SHOW-IN-TASKBAR    = yes
         CONTROL-BOX        = no
         MIN-BUTTON         = no
         MAX-BUTTON         = no
         ALWAYS-ON-TOP      = yes
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DDEFrame
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* PDFDirectPrint */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* PDFDirectPrint */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
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

assign frame DDEFrame:visible = true.
/*       frame DDEFrame:hidden  = true.*/

run GetOriginalDefaultPrinter.

PrinterSelect = session:printer-name.

run SetNewDefaultPrinter.
run PrintPDF.
run SetOriginalDefaultPrinter.

return.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  VIEW FRAME DDEFrame IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DDEFrame}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getKey C-Win 
PROCEDURE getKey :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter i-section  as character no-undo.
    define input  parameter i-key      as character no-undo.
    define input  parameter i-filename as character no-undo.
    define output parameter o-value    as character no-undo.

    define variable EntryPointer as integer no-undo.
    define variable mem1         as memptr  no-undo.
    define variable mem2         as memptr  no-undo.
    define variable mem1size     as integer no-undo.
    define variable mem2size     as integer no-undo.
    define variable i            as integer no-undo.
    define variable cbReturnSize as integer no-undo.

    set-size(mem1) = 4000.
    mem1size       = 4000.

    if i-key = "" then 
        EntryPointer = 0.
    else do:
        set-size(mem2)     = 128.
        mem2size           = 128.
        EntryPointer       = get-pointer-value(mem2).
        put-string(mem2,1) = i-key.
    end.

    run getprivateprofilestringA(i-section, EntryPointer, "",
                                 get-pointer-value(mem1),
                                 mem1size, i-filename,
                                 output cbReturnSize).

    do i = 1 to cbReturnSize:
        o-value = if (get-byte(mem1, i) = 0 and i ne cbReturnSize) 
                  then o-value + ","
                  else o-value + chr(get-byte(mem1, i)).
    end.

    set-size(mem1) = 0.
    set-size(mem2) = 0.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getOriginalDefaultPrinter C-Win 
PROCEDURE getOriginalDefaultPrinter :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    OriginalDefault = fill(" ",100).
    run GetProfileStringA("windows", "device", "-unknown-,", 
                          output OriginalDefault, 
                          length(OriginalDefault),
                          output ReturnValue).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE printPDF C-Win 
PROCEDURE printPDF :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable hAcro as com-handle no-undo.
    define variable viSys         as integer   no-undo.
    define variable idFile        as integer   no-undo.

    pPDFFolder    = trim(replace(pPDFFolder,'\','/')).

    if substring(pPDFFolder,length(pPDFFolder),1) <> '/' then
        pPDFFolder = pPDFFolder + '/'.

    do {&try}:
    
        create 'AcroExch.Document' hAcro.
    
        dde initiate viSys frame frame DDEFrame:handle 
            application "AcroView" topic "Control" no-error. 
    
        if viSys = 0 then do:
            pause 3 no-message.
            dde initiate viSys frame frame DDEFrame:handle
                application "AcroView" topic "Control" no-error.
        end.
    
        if viSys = 0 then
            message "Acrobat Reader n∆o encontrado." view-as alert-box.

        else do:    
            dde execute viSys command "[AppHide()]".
        
            do idFile = 1 to num-entries(pPDFFiles):
                dde execute viSys command "[FilePrintSilent(~"" + pPDFFolder + entry(idFile,pPDFFiles,',') + "~")]".
            end.
        end.
    end.

    if viSys <> 0 then
        dde terminate viSys.
    
    if valid-handle(hAcro) then
        release object hAcro
            no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE putKey C-Win 
PROCEDURE putKey :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter i-section  as character no-undo.
    define input parameter i-key      as character no-undo.
    define input parameter i-filename as character no-undo.
    define input parameter i-value    as character no-undo.
 
    define variable cbReturnSize as integer no-undo.
 
    run writeprivateprofilestringA(i-section, i-key, i-value, i-filename, output cbReturnSize ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setNewDefaultPrinter C-Win 
PROCEDURE setNewDefaultPrinter :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    run getkey ("devices", PrinterSelect, "win.ini", output DriverAndPort).
    run putkey ("windows", "device", "win.ini", PrinterSelect + "," + DriverAndPort).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setOriginalDefaultPrinter C-Win 
PROCEDURE setOriginalDefaultPrinter :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    run putkey ("windows", "device", "win.ini", OriginalDefault + "," + DriverAndPort).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

