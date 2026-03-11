&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Programa: int550- Monitor de Arquivos Pendentes NDD
**
** Versao : 12 - 20/09/2018 - Alessandro V Baccin
**
********************************************************************************/
{include/i-prgvrs.i int550 2.12.02.AVB}
{cdp/cdcfgdis.i}
{utp/ut-glob.i}

/* Variaveis e procedures para tratamento de XML - NDD Web */
{xmlinc/xmlndd.i}

/* Carrega API auxiliar processamento de XML */
{xmlinc/xmlloadgenxml.i &GenXml="hGenXML" &GXReturnValue="cReturnValue"}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        int550
&GLOBAL-DEFINE Version        2.12.02.AVB

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         YES
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Arquivos, XML

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK btCancel btHelp2 btSelecao c-intervalo btAtualiza rs-consulta
&GLOBAL-DEFINE page1Widgets   brArquivos brNotas
&GLOBAL-DEFINE page2Widgets   

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define temp-table tt-arquivos
    field arquivo as char format "X(256)" label "Arquivo"
    index chave is unique
    arquivo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brArquivos

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-arquivos tt-NDD_ENTRYINTEGRATION

/* Definitions for BROWSE brArquivos                                    */
&Scoped-define FIELDS-IN-QUERY-brArquivos tt-arquivos.arquivo   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brArquivos   
&Scoped-define SELF-NAME brArquivos
&Scoped-define QUERY-STRING-brArquivos FOR EACH tt-arquivos NO-LOCK     BY tt-arquivos.ARQUIVO
&Scoped-define OPEN-QUERY-brArquivos OPEN QUERY {&SELF-NAME} FOR EACH tt-arquivos NO-LOCK     BY tt-arquivos.ARQUIVO.
&Scoped-define TABLES-IN-QUERY-brArquivos tt-arquivos
&Scoped-define FIRST-TABLE-IN-QUERY-brArquivos tt-arquivos


/* Definitions for BROWSE brNotas                                       */
&Scoped-define FIELDS-IN-QUERY-brNotas tt-NDD_ENTRYINTEGRATION.CNPJDEST tt-NDD_ENTRYINTEGRATION.CNPJEMIT tt-NDD_ENTRYINTEGRATION.EMISSIONDATE tt-NDD_ENTRYINTEGRATION.SERIE tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brNotas   
&Scoped-define SELF-NAME brNotas
&Scoped-define QUERY-STRING-brNotas FOR EACH tt-NDD_ENTRYINTEGRATION NO-LOCK     BY tt-NDD_ENTRYINTEGRATION.CNPJDEST      BY tt-NDD_ENTRYINTEGRATION.CNPJEMIT       BY tt-NDD_ENTRYINTEGRATION.EMISSIONDATE        BY tt-NDD_ENTRYINTEGRATION.SERIE         BY tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER
&Scoped-define OPEN-QUERY-brNotas OPEN QUERY {&SELF-NAME} FOR EACH tt-NDD_ENTRYINTEGRATION NO-LOCK     BY tt-NDD_ENTRYINTEGRATION.CNPJDEST      BY tt-NDD_ENTRYINTEGRATION.CNPJEMIT       BY tt-NDD_ENTRYINTEGRATION.EMISSIONDATE        BY tt-NDD_ENTRYINTEGRATION.SERIE         BY tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER.
&Scoped-define TABLES-IN-QUERY-brNotas tt-NDD_ENTRYINTEGRATION
&Scoped-define FIRST-TABLE-IN-QUERY-brNotas tt-NDD_ENTRYINTEGRATION


/* Definitions for FRAME fPage1                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 rtToolBar RECT-consulta ~
btSelecao btQueryJoins btReportsJoins btExit btHelp rs-consulta btAtualiza ~
btOK btCancel btHelp2 
&Scoped-Define DISPLAYED-OBJECTS rs-consulta c-intervalo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnCod-Emitente wWindow 
FUNCTION fnCod-Emitente RETURNS integer
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnCod-Estabel wWindow 
FUNCTION fnCod-Estabel RETURNS CHARACTER
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnItem wWindow 
FUNCTION fnItem RETURNS CHARACTER
  ( pcod-produto as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnNome-Abrev wWindow 
FUNCTION fnNome-Abrev RETURNS CHARACTER
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnRefresh wWindow 
FUNCTION fnRefresh returns logical ( )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miQueryJoins   LABEL "&Consultas"    
       MENU-ITEM miReportsJoins LABEL "&Relat¢rios"   
       RULE
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btAtualiza 
     IMAGE-UP FILE "image/im-relo.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-relo.bmp":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.27
     FONT 4.

DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.27
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.27
     FONT 4.

DEFINE BUTTON btHelp2 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE BUTTON btQueryJoins 
     IMAGE-UP FILE "image\im-joi":U
     IMAGE-INSENSITIVE FILE "image\ii-joi":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.27
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.27
     FONT 4.

DEFINE BUTTON btSelecao 
     IMAGE-UP FILE "image\im-ran":U
     IMAGE-INSENSITIVE FILE "image\ii-ran":U
     LABEL "Sele‡Æo" 
     SIZE 4 BY 1.27
     FONT 4.

DEFINE VARIABLE c-intervalo AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 60 
     VIEW-AS FILL-IN 
     SIZE 4.75 BY .8 NO-UNDO.

DEFINE VARIABLE rs-consulta AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Manual", 1,
"Autom tico", 2
     SIZE 11.63 BY 1.5 NO-UNDO.

DEFINE RECTANGLE RECT-consulta
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 32.75 BY 2.37.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 135 BY 1.43
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 135 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brArquivos FOR 
      tt-arquivos SCROLLING.

DEFINE QUERY brNotas FOR 
      tt-NDD_ENTRYINTEGRATION SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brArquivos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brArquivos wWindow _FREEFORM
  QUERY brArquivos NO-LOCK DISPLAY
      tt-arquivos.arquivo COLUMN-LABEL "Arquivo"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS NO-SCROLLBAR-VERTICAL SIZE 130.5 BY 8.8
         FONT 1 ROW-HEIGHT-CHARS .53.

DEFINE BROWSE brNotas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brNotas wWindow _FREEFORM
  QUERY brNotas NO-LOCK DISPLAY
      tt-NDD_ENTRYINTEGRATION.CNPJDEST COLUMN-LABEL "Destino" FORMAT ">>>>>>>>>>>>>>9":U
            WIDTH 15
      tt-NDD_ENTRYINTEGRATION.CNPJEMIT COLUMN-LABEL "Emitente" FORMAT ">>>>>>>>>>>>>>9":U
            WIDTH 14.5
      tt-NDD_ENTRYINTEGRATION.EMISSIONDATE COLUMN-LABEL "Emissao" FORMAT "99/99/9999":U
            WIDTH 12.5
      tt-NDD_ENTRYINTEGRATION.SERIE COLUMN-LABEL "Ser" FORMAT ">>>>9":U
            WIDTH 3
      tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER COLUMN-LABEL "Nota" FORMAT ">>>>>>>>9":U
            WIDTH 8
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS NO-SCROLLBAR-VERTICAL SIZE 130.5 BY 8.8
         FONT 1 ROW-HEIGHT-CHARS .53.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btSelecao AT ROW 1.07 COL 1.63 HELP
          "Relat¢rios relacionados" WIDGET-ID 2
     btQueryJoins AT ROW 1.13 COL 119.38 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 123.38 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 127.38 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 131.38 HELP
          "Ajuda"
     rs-consulta AT ROW 3.43 COL 104 NO-LABEL WIDGET-ID 10
     btAtualiza AT ROW 3.57 COL 129 HELP
          "Consultas relacionadas" WIDGET-ID 4
     c-intervalo AT ROW 3.93 COL 115 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     btOK AT ROW 23.63 COL 2
     btCancel AT ROW 23.63 COL 13
     btHelp2 AT ROW 23.63 COL 125.38
     "seg" VIEW-AS TEXT
          SIZE 4.25 BY .53 AT ROW 4.07 COL 122.63 WIDGET-ID 16
     "Consulta" VIEW-AS TEXT
          SIZE 8 BY .53 AT ROW 2.57 COL 105 WIDGET-ID 14
     rtToolBar-2 AT ROW 1 COL 1
     rtToolBar AT ROW 23.43 COL 1
     RECT-consulta AT ROW 2.87 COL 102.63 WIDGET-ID 8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 135.13 BY 24.03
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brArquivos AT ROW 1 COL 1 WIDGET-ID 1000
     brNotas AT ROW 9.8 COL 1 WIDGET-ID 800
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.25 ROW 5.27
         SIZE 132.5 BY 17.87
         FONT 1 WIDGET-ID 700.

DEFINE FRAME fPage2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.25 ROW 5.27
         SIZE 132.5 BY 17.87
         FONT 1 WIDGET-ID 900.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 24.03
         WIDTH              = 135.13
         MAX-HEIGHT         = 24.03
         MAX-WIDTH          = 135.13
         VIRTUAL-HEIGHT     = 24.03
         VIRTUAL-WIDTH      = 135.13
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

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU mbMain:HANDLE.
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
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE
       FRAME fPage2:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN c-intervalo IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brArquivos 1 fPage1 */
/* BROWSE-TAB brNotas brArquivos fPage1 */
/* SETTINGS FOR FRAME fPage2
                                                                        */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brArquivos
/* Query rebuild information for BROWSE brArquivos
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-arquivos NO-LOCK
    BY tt-arquivos.ARQUIVO
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "Temp-Tables.tt-NDD_ENTRYINTEGRATION.CNPJDEST|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.CNPJEMIT|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.EMISSIONDATE|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.SERIE|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER|yes"
     _Query            is NOT OPENED
*/  /* BROWSE brArquivos */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brNotas
/* Query rebuild information for BROWSE brNotas
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-NDD_ENTRYINTEGRATION NO-LOCK
    BY tt-NDD_ENTRYINTEGRATION.CNPJDEST
     BY tt-NDD_ENTRYINTEGRATION.CNPJEMIT
      BY tt-NDD_ENTRYINTEGRATION.EMISSIONDATE
       BY tt-NDD_ENTRYINTEGRATION.SERIE
        BY tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "Temp-Tables.tt-NDD_ENTRYINTEGRATION.CNPJDEST|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.CNPJEMIT|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.EMISSIONDATE|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.SERIE|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER|yes"
     _Query            is NOT OPENED
*/  /* BROWSE brNotas */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage1
/* Query rebuild information for FRAME fPage1
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage2
/* Query rebuild information for FRAME fPage2
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage2 */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME fpage0:HANDLE
       ROW             = 1
       COLUMN          = 112.63
       HEIGHT          = 1.5
       WIDTH           = 6
       WIDGET-ID       = 18
       HIDDEN          = yes
       SENSITIVE       = yes.
/* CtrlFrame OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: PSTimer */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


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


&Scoped-define BROWSE-NAME brArquivos
&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME brArquivos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brArquivos wWindow
ON VALUE-CHANGED OF brArquivos IN FRAME fPage1
DO:

    assign cFile = cCaminhoNDD + "\" + tt-arquivos.arquivo.
    copy-lob FILE cFile TO cReturnValue.
    run pi-processa-retorno (input no).
    RUN pi-openQueryNotas.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brNotas
&Scoped-define SELF-NAME brNotas
&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btAtualiza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAtualiza wWindow
ON CHOOSE OF btAtualiza IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF btAtualiza DO:
    def var l-frame1 as logical.
    fnRefresh().

    assign l-frame1 = frame fPage1:visible.
    RUN pi-openQueryArquivos.
    RUN pi-openQueryNotas.
    if l-frame1 then
        run SetFolder in hFolder (input 1).
    else
        run SetFolder in hFolder (input 2).

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


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp2 wWindow
ON CHOOSE OF btHelp2 IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wWindow
ON CHOOSE OF btQueryJoins IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fpage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSelecao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSelecao wWindow
ON CHOOSE OF btSelecao IN FRAME fpage0 /* Sele‡Æo */
OR CHOOSE OF btSelecao DO:
   fnRefresh().
   DEF VAR l-openquery AS LOG NO-UNDO.

   RUN intprg/int550a.w ( INPUT-OUTPUT cCaminhoNDD,
                          OUTPUT l-openquery ).

    if l-openquery and rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" then do:
        RUN pi-openQueryProg.
        RUN pi-openQueryHist.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-intervalo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-intervalo wWindow
ON LEAVE OF c-intervalo IN FRAME fpage0
DO: 
  IF INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) <> 0 THEN
      chCtrlFrame:PSTimer:interval = INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) * 1000.
  ELSE
      run utp/ut-msgs.p (input "show", 
                         input 17006, 
                         input "O intervalo de atualiza‡Æo deve ser informado!").    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CtrlFrame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CtrlFrame wWindow OCX.Tick
PROCEDURE CtrlFrame.PSTimer.Tick .
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  None required for OCX.
  Notes:       
------------------------------------------------------------------------------*/
    APPLY "CHOOSE" TO btAtualiza IN FRAME fPage0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-consulta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-consulta wWindow
ON VALUE-CHANGED OF rs-consulta IN FRAME fpage0
DO:
  IF rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" THEN DO:
      ENABLE c-intervalo WITH FRAME fPage0.
      DISABLE btAtualiza WITH FRAME fPage0.
      display c-intervalo WITH FRAME fPage0.
      chCtrlFrame:PSTimer:interval = INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) * 1000.
  END.
  ELSE DO:
      DISABLE c-intervalo WITH FRAME fPage0. 
      ENABLE btAtualiza WITH FRAME fPage0.
      ASSIGN chCtrlFrame:PSTimer:interval = 0
             c-intervalo:SCREEN-VALUE IN FRAME fPage0 = "".
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brArquivos
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*--- L¢gica para inicializa‡Æo do programam ---*/
{window/MainBlock.i}

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

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInitializeInterface wWindow 
PROCEDURE beforeInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    cCaminhoNDD = cCaminhoNDD + "\tmp".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load wWindow  _CONTROL-LOAD
PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs    
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the 
               OCXs in the interface.                        
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.

OCXFile = SEARCH( "int550.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame = CtrlFrame:COM-HANDLE
    UIB_S = chCtrlFrame:LoadControls( OCXFile, "CtrlFrame":U)
    CtrlFrame:NAME = "CtrlFrame":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "int550.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryArquivos wWindow 
PROCEDURE pi-openQueryArquivos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
empty temp-table tt-arquivos.
empty temp-table tt-ndd_entryintegration.

os-command silent "dir /b" value(cCaminhoNDD + "eformsConsultarColdDFeRetorno*.xml") > value(cCaminhoNDD + c-seg-usuario + ".inp").
input from value(cCaminhoNDD + c-seg-usuario + ".inp").
repeat:
    import cFile.
    create tt-arquivos.
    assign tt-arquivos.arquivo = cFile.
end.

if can-find (first tt-arquivos) then do:
    open query brArquivos for each tt-arquivos no-lock.
    run setEnabled in hFolder (input 1, input true).
    enable all with frame fPage1.
    if brArquivos:num-entries > 0 then do:
        brArquivos:SELECT-ROW(1) in frame fPage1.
        apply "VALUE-CHANGED":U to brArquivos in frame fPage1.
    end.
end.
else do:
    run setEnabled in hFolder (input 1, input false).
    close query brArquivos.
    disable all with frame fPage1.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryNotas wWindow 
PROCEDURE pi-openQueryNotas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
empty temp-table tt-ndd_entryintegration.
session:SET-WAIT-STATE("GENERAL").

session:SET-WAIT-STATE("").

/*
if can-find (first int-ds-prog-rpw) then do:
    open query brPedExec 
        for each tt-ped_exec_hist USE-INDEX ordem.
            /*
            by tt-ped_exec_hist.cod_prog_dtsul
              by tt-ped_exec.num_ped_exec desc
                by tt-ped_exec.dat_inic_exec_servid_exec
                  by tt-ped_exec_hist.hra_inic_exec_servid_exec.
*/
    run setEnabled in hFolder (input 2, input true).
    enable all with frame fPage2.
    /*
    if brPedExec:num-entries > 0 then do:
        brPedExec:SELECT-ROW(1) in frame fPage2.
        apply "VALUE-CHANGED":U to brPedExec in frame fPage2.
    end.
    */
end.
else do:
    run setEnabled in hFolder (input 2, input false).
    close query brPedExec.
    disable all with frame fPage2.
end.
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnCod-Emitente wWindow 
FUNCTION fnCod-Emitente RETURNS integer
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first emitente fields (cod-emitente)
        no-lock where emitente.cgc begins pcnpj:
        RETURN emitente.cod-emitente.
    end.

  RETURN ?.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnCod-Estabel wWindow 
FUNCTION fnCod-Estabel RETURNS CHARACTER
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first estabelec fields (cod-estabel)
        no-lock where estabelec.cgc begins pcnpj:
        RETURN estabelec.cod-estabel.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnItem wWindow 
FUNCTION fnItem RETURNS CHARACTER
  ( pcod-produto as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first ITEM fields (desc-item)
        no-lock where item.it-codigo = string(pcod-produto):
        RETURN item.desc-item.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnNome-Abrev wWindow 
FUNCTION fnNome-Abrev RETURNS CHARACTER
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first emitente fields (nome-abrev)
        no-lock where emitente.cgc = pcnpj:
        RETURN emitente.nome-abrev.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnRefresh wWindow 
FUNCTION fnRefresh returns logical ( ) :
    IF rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" THEN DO:
        chCtrlFrame:PSTimer:interval = 0.
        APPLY "LEAVE" TO c-intervalo IN FRAME fPage0.
    END.

    RETURN FALSE.   

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

