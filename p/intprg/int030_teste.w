&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wWindow


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int-ds-log NO-UNDO LIKE int-ds-log
       field r-rowid as rowid
       index ocorrencia desc-ocorrencia.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
/********************************************************************************
** Programa: int030 - Monitor de Integraá∆o Tutorial/PRS X Datasul
**
** Versao : 12 - 07/04/2016 - Alessandro V Baccin
**
********************************************************************************/
{include/i-prgvrs.i INT030 2.12.01.AVB}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT030
&GLOBAL-DEFINE Version        2.12.01.AVB

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         YES
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Integraá‰es

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK btCancel btHelp2 btSelecao c-intervalo btAtualiza rs-consulta
&GLOBAL-DEFINE page1Widgets   brLog

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEF VAR d-dt-ocorrencia-ini                 LIKE int-ds-log.dt-ocorrencia    INITIAL TODAY NO-UNDO.
DEF VAR d-dt-ocorrencia-fim                 LIKE int-ds-log.dt-ocorrencia    INITIAL TODAY NO-UNDO.
DEF VAR d-dt-movto-ini                      LIKE int-ds-log.dt-movto         INITIAL 01/01/2000 NO-UNDO.
DEF VAR d-dt-movto-fim                      LIKE int-ds-log.dt-movto         INITIAL 12/31/9999 NO-UNDO.
DEF VAR c-origem-ini                        LIKE int-ds-log.origem           INITIAL "" NO-UNDO.
DEF VAR c-origem-fim                        LIKE int-ds-log.origem           INITIAL "ZZZZZZZZ" NO-UNDO.
DEF VAR i-situacao                          as integer initial 0 no-undo.
DEF VAR c-chave                             like int-ds-log.chave no-undo.
DEF VAR c-cod-usuario                       LIKE usuar_mestre.cod_usuario    NO-UNDO.

DEF NEW GLOBAL SHARED VAR c-seg-usuario        LIKE usuar_mestre.cod_usuario NO-UNDO.

def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def var raw-param          as raw no-undo.

DEFINE TEMP-TABLE tt-origem
    FIELD origem   AS CHAR FORMAT "x(12)" COLUMN-LABEL "Origem"
    FIELD qtd-int  AS INT64               COLUMN-LABEL "Integradas"
    FIELD qtd-pen  AS INT64               COLUMN-LABEL "Pendentes".

DEFINE TEMP-TABLE tt-int-ds-msg-usuario LIKE int-ds-msg-usuario
    FIELD tamanho AS INT.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brLog

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int-ds-log

/* Definitions for BROWSE brLog                                         */
&Scoped-define FIELDS-IN-QUERY-brLog tt-int-ds-log.origem ~
tt-int-ds-log.chave tt-int-ds-log.situacao tt-int-ds-log.dt-ocorrencia ~
tt-int-ds-log.hr-ocorrencia tt-int-ds-log.dt-movto ~
tt-int-ds-log.cod-usuario tt-int-ds-log.cod-usuario-msg ~
tt-int-ds-log.desc-ocorrencia 
&Scoped-define ENABLED-FIELDS-IN-QUERY-brLog 
&Scoped-define QUERY-STRING-brLog FOR EACH tt-int-ds-log NO-LOCK
&Scoped-define OPEN-QUERY-brLog OPEN QUERY brLog FOR EACH tt-int-ds-log NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brLog tt-int-ds-log
&Scoped-define FIRST-TABLE-IN-QUERY-brLog tt-int-ds-log


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brLog}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 rtToolBar RECT-consulta RECT-1 ~
btSelecao btQueryJoins btReportsJoins btExit btHelp bt-qtd-erros ~
rs-consulta btAtualiza btOK btCancel btHelp2 
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
       MENU-ITEM miReportsJoins LABEL "&RelatΩrios"   
       RULE
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conteúdo"     
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-qtd-erros 
     IMAGE-UP FILE "image/im-gmat.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-gmat.bmp":U
     LABEL "Button 1" 
     SIZE 4 BY 1.13 TOOLTIP "Mostrar quantidade de erros por Origem".

DEFINE BUTTON btAtualiza 
     IMAGE-UP FILE "image/im-relo.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-relo.bmp":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
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
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btSelecao 
     IMAGE-UP FILE "image\im-ran":U
     IMAGE-INSENSITIVE FILE "image\ii-ran":U
     LABEL "Seleªío" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE VARIABLE c-intervalo AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 60 
     VIEW-AS FILL-IN 
     SIZE 4.72 BY .79 NO-UNDO.

DEFINE VARIABLE rs-consulta AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Manual", 1,
"Autom†tico", 2
     SIZE 11.57 BY 1.5 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 17 BY 2.17.

DEFINE RECTANGLE RECT-consulta
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 32.72 BY 2.17.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 135 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 135 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brLog FOR 
      tt-int-ds-log
    FIELDS(tt-int-ds-log.origem
      tt-int-ds-log.chave
      tt-int-ds-log.situacao
      tt-int-ds-log.dt-ocorrencia
      tt-int-ds-log.hr-ocorrencia
      tt-int-ds-log.dt-movto
      tt-int-ds-log.cod-usuario
      tt-int-ds-log.cod-usuario-msg
      tt-int-ds-log.desc-ocorrencia) SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brLog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brLog wWindow _STRUCTURED
  QUERY brLog NO-LOCK DISPLAY
      tt-int-ds-log.origem FORMAT "x(8)":U WIDTH 9.43
      tt-int-ds-log.chave FORMAT "x(50)":U WIDTH 14.43
      tt-int-ds-log.situacao FORMAT "9":U
      tt-int-ds-log.dt-ocorrencia FORMAT "99/99/9999":U
      tt-int-ds-log.hr-ocorrencia FORMAT "x(8)":U
      tt-int-ds-log.dt-movto FORMAT "99/99/9999":U
      tt-int-ds-log.cod-usuario FORMAT "x(12)":U
      tt-int-ds-log.cod-usuario-msg COLUMN-LABEL "Usu†rio Respons†vel" FORMAT "x(12)":U
            WIDTH 15
      tt-int-ds-log.desc-ocorrencia FORMAT "x(500)":U WIDTH 200
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 132 BY 17.75
         FONT 1 NO-EMPTY-SPACE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btSelecao AT ROW 1.08 COL 1.57 HELP
          "RelatΩrios relacionados" WIDGET-ID 2
     btQueryJoins AT ROW 1.13 COL 119.43 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 123.43 HELP
          "RelatΩrios relacionados"
     btExit AT ROW 1.13 COL 127.43 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 131.43 HELP
          "Ajuda"
     bt-qtd-erros AT ROW 1.17 COL 115.43 WIDGET-ID 28
     rs-consulta AT ROW 3.42 COL 104 NO-LABEL WIDGET-ID 10
     btAtualiza AT ROW 3.58 COL 129 HELP
          "Consultas relacionadas" WIDGET-ID 4
     c-intervalo AT ROW 3.92 COL 115 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     btOK AT ROW 23.63 COL 2
     btCancel AT ROW 23.63 COL 13
     btHelp2 AT ROW 23.63 COL 125.43
     "Consulta" VIEW-AS TEXT
          SIZE 8 BY .54 AT ROW 2.58 COL 105 WIDGET-ID 14
     "1 - Pendente" VIEW-AS TEXT
          SIZE 10 BY .54 AT ROW 3.25 COL 89 WIDGET-ID 20
     "Situaªá∆o Integraªá∆o" VIEW-AS TEXT
          SIZE 15.43 BY .54 AT ROW 2.63 COL 86.43 WIDGET-ID 26
     "2 - Integrado" VIEW-AS TEXT
          SIZE 10 BY .54 AT ROW 4 COL 89 WIDGET-ID 22
     "seg" VIEW-AS TEXT
          SIZE 4.29 BY .54 AT ROW 4.08 COL 122.57 WIDGET-ID 16
     rtToolBar-2 AT ROW 1 COL 1
     rtToolBar AT ROW 23.42 COL 1
     RECT-consulta AT ROW 2.88 COL 102.57 WIDGET-ID 8
     RECT-1 AT ROW 2.88 COL 85.57 WIDGET-ID 24
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 135.14 BY 24.04
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brLog AT ROW 1 COL 1 WIDGET-ID 600
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.25 ROW 5.27
         SIZE 132.5 BY 17.87
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int-ds-log T "?" NO-UNDO emsesp int-ds-log
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
          index ocorrencia desc-ocorrencia
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 24.04
         WIDTH              = 135.14
         MAX-HEIGHT         = 33
         MAX-WIDTH          = 228.57
         VIRTUAL-HEIGHT     = 33
         VIRTUAL-WIDTH      = 228.57
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
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN c-intervalo IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brLog 1 fPage1 */
ASSIGN 
       brLog:NUM-LOCKED-COLUMNS IN FRAME fPage1     = 2
       brLog:MAX-DATA-GUESS IN FRAME fPage1         = 2000.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brLog
/* Query rebuild information for BROWSE brLog
     _TblList          = "Temp-Tables.tt-int-ds-log"
     _Options          = "NO-LOCK"
     _TblOptList       = "USED"
     _FldNameList[1]   > Temp-Tables.tt-int-ds-log.origem
"tt-int-ds-log.origem" ? ? "character" ? ? ? ? ? ? no ? no no "9.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-int-ds-log.chave
"tt-int-ds-log.chave" ? ? "character" ? ? ? ? ? ? no ? no no "14.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = Temp-Tables.tt-int-ds-log.situacao
     _FldNameList[4]   = Temp-Tables.tt-int-ds-log.dt-ocorrencia
     _FldNameList[5]   = Temp-Tables.tt-int-ds-log.hr-ocorrencia
     _FldNameList[6]   = Temp-Tables.tt-int-ds-log.dt-movto
     _FldNameList[7]   = Temp-Tables.tt-int-ds-log.cod-usuario
     _FldNameList[8]   > Temp-Tables.tt-int-ds-log.cod-usuario-msg
"tt-int-ds-log.cod-usuario-msg" "Usu†rio Respons†vel" ? "character" ? ? ? ? ? ? no ? no no "15" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > Temp-Tables.tt-int-ds-log.desc-ocorrencia
"tt-int-ds-log.desc-ocorrencia" ? ? "character" ? ? ? ? ? ? no ? no no "200" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE brLog */
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

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME fpage0:HANDLE
       ROW             = 1
       COLUMN          = 106.72
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


&Scoped-define SELF-NAME bt-qtd-erros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-qtd-erros wWindow
ON CHOOSE OF bt-qtd-erros IN FRAME fpage0 /* Button 1 */
DO:
  IF AVAIL tt-int-ds-log THEN DO:
      RUN pi-QuantidadeErrosOrigem.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAtualiza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAtualiza wWindow
ON CHOOSE OF btAtualiza IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF btAtualiza DO:
    fnRefresh().

    RUN pi-openQueryLog.
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
ON CHOOSE OF btSelecao IN FRAME fpage0 /* Seleªío */
OR CHOOSE OF btSelecao DO:
   fnRefresh().
   DEF VAR l-openquery AS LOG NO-UNDO.

   RUN intprg/int030a.w ( INPUT-OUTPUT c-origem-ini, 
                          INPUT-OUTPUT c-origem-fim, 
                          INPUT-OUTPUT d-dt-ocorrencia-ini, 
                          INPUT-OUTPUT d-dt-ocorrencia-fim, 
                          INPUT-OUTPUT d-dt-movto-ini, 
                          INPUT-OUTPUT d-dt-movto-fim, 
                          INPUT-OUTPUT c-chave,
                          INPUT-OUTPUT c-cod-usuario,
                          INPUT-OUTPUT i-situacao,
                          OUTPUT l-openquery ).

    if l-openquery and rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" then do:
        RUN pi-OpenQueryLog.
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
                         input "O intervalo de atualizaªío deve ser informado!").    
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
  ENABLE bt-qtd-erros WITH FRAME fPage0.

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


&Scoped-define BROWSE-NAME brLog
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*--- LΩgica para inicializaªío do programam ---*/
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
    apply "VALUE-CHANGED":U to rs-consulta in frame fPage0.
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
    ASSIGN d-dt-ocorrencia-ini = today
           d-dt-ocorrencia-fim = today
           d-dt-movto-ini      = today
           d-dt-movto-fim      = today
           i-situacao          = 1
           c-chave             = ""
           c-origem-ini        = "CLI"
           c-origem-fim        = "WMS".

    ASSIGN c-cod-usuario = c-seg-usuario.

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

OCXFile = SEARCH( "int030_teste.wrx":U ).
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
ELSE MESSAGE "int030_teste.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-buscaUsuarioResposavel wWindow 
PROCEDURE pi-buscaUsuarioResposavel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT  PARAMETER pi-cod-usuario      LIKE int-ds-msg-usuario.cod-usuario.
DEFINE INPUT  PARAMETER pi-origem           LIKE int-ds-msg-usuario.origem     .
DEFINE INPUT  PARAMETER pi-desc-ocorrencia  LIKE int-ds-log.desc-ocorrencia    .
DEFINE OUTPUT PARAMETER po-cod-usuario      LIKE int-ds-msg-usuario.cod-usuario.

DEFINE VARIABLE l-achou-usuario AS LOGICAL  INITIAL NO   NO-UNDO.

EMPTY TEMP-TABLE tt-int-ds-msg-usuario.
FOR EACH tt-int-ds-msg-usuario: DELETE tt-int-ds-msg-usuario. END.


IF TRIM(pi-cod-usuario) = "*" OR TRIM(pi-cod-usuario) = "" THEN DO:

    FOR EACH  int-ds-msg-usuario NO-LOCK
       WHERE  int-ds-msg-usuario.origem          = int-ds-log.origem
         AND  int-ds-msg-usuario.mensagem       <> "*"
         AND (REPLACE(int-ds-log.desc-ocorrencia,CHR(10)," ") MATCHES "*" + TRIM(int-ds-msg-usuario.mensagem) + "*"
          OR  REPLACE(int-ds-log.desc-ocorrencia,CHR(10)," ") BEGINS        TRIM(int-ds-msg-usuario.mensagem)):

        CREATE tt-int-ds-msg-usuario.
        BUFFER-COPY int-ds-msg-usuario TO tt-int-ds-msg-usuario.
        ASSIGN tt-int-ds-msg-usuario.tamanho = LENGTH(TRIM(int-ds-msg-usuario.mensagem)).

        ASSIGN l-achou-usuario = YES.

    END.

    IF l-achou-usuario = NO THEN DO:
        FOR EACH int-ds-msg-usuario NO-LOCK
           WHERE  int-ds-msg-usuario.origem          = int-ds-log.origem
             AND  int-ds-msg-usuario.mensagem        = "*" :

            CREATE tt-int-ds-msg-usuario.
            BUFFER-COPY int-ds-msg-usuario TO tt-int-ds-msg-usuario.
            ASSIGN tt-int-ds-msg-usuario.tamanho = LENGTH(TRIM(int-ds-msg-usuario.mensagem)).

            ASSIGN l-achou-usuario = YES.
        END.
    END.
END.
ELSE DO:
    FOR EACH  int-ds-msg-usuario NO-LOCK
       WHERE  int-ds-msg-usuario.origem          = int-ds-log.origem
         AND  int-ds-msg-usuario.cod-usuario     =  pi-cod-usuario
         AND (REPLACE(int-ds-log.desc-ocorrencia,CHR(10)," ") MATCHES "*" + TRIM(int-ds-msg-usuario.mensagem) + "*" 
          OR  REPLACE(int-ds-log.desc-ocorrencia,CHR(10)," ") BEGINS        TRIM(int-ds-msg-usuario.mensagem)):

        CREATE tt-int-ds-msg-usuario.
        BUFFER-COPY int-ds-msg-usuario TO tt-int-ds-msg-usuario.
        ASSIGN tt-int-ds-msg-usuario.tamanho = LENGTH(TRIM(int-ds-msg-usuario.mensagem)).

        ASSIGN l-achou-usuario = YES.
    END.

    IF l-achou-usuario = NO THEN DO:

        FOR EACH  int-ds-msg-usuario NO-LOCK
           WHERE  int-ds-msg-usuario.origem          = int-ds-log.origem
             AND (REPLACE(int-ds-log.desc-ocorrencia,CHR(10)," ") MATCHES "*" + TRIM(int-ds-msg-usuario.mensagem) + "*"
              OR  REPLACE(int-ds-log.desc-ocorrencia,CHR(10)," ") BEGINS        TRIM(int-ds-msg-usuario.mensagem))     :

/*             /* INICIO - Caso o usu†rio encontrado n∆o seja igual usu†rio selecionado n∆o mostra a mensagem */ */
/*             IF int-ds-msg-usuario.cod-usuario <> "*" AND                                                      */
/*                int-ds-msg-usuario.cod-usuario <> pi-cod-usuario THEN NEXT.                                    */
/*             /* FIM    - Caso o usu†rio encontrado n∆o seja igual usu†rio selecionado n∆o mostra a mensagem */ */

            CREATE tt-int-ds-msg-usuario.
            BUFFER-COPY int-ds-msg-usuario TO tt-int-ds-msg-usuario.
            ASSIGN tt-int-ds-msg-usuario.tamanho = LENGTH(TRIM(int-ds-msg-usuario.mensagem)).
    
            ASSIGN l-achou-usuario = YES.
        END.

        IF l-achou-usuario = NO THEN DO:
            FOR EACH int-ds-msg-usuario NO-LOCK
               WHERE  int-ds-msg-usuario.origem          = int-ds-log.origem
                 AND  int-ds-msg-usuario.cod-usuario     = c-cod-usuario
                 AND  TRIM(int-ds-msg-usuario.mensagem)  = "*"  :

                CREATE tt-int-ds-msg-usuario.
                BUFFER-COPY int-ds-msg-usuario TO tt-int-ds-msg-usuario.
                ASSIGN tt-int-ds-msg-usuario.tamanho = LENGTH(TRIM(int-ds-msg-usuario.mensagem)).

                ASSIGN l-achou-usuario = YES.
            END.

            IF l-achou-usuario = NO THEN DO:
                FOR EACH int-ds-msg-usuario NO-LOCK
                   WHERE int-ds-msg-usuario.origem            = int-ds-log.origem
                     AND TRIM(int-ds-msg-usuario.mensagem)    = "*"
                     AND TRIM(int-ds-msg-usuario.cod-usuario) = "*" :
                    
                    CREATE tt-int-ds-msg-usuario.
                    BUFFER-COPY int-ds-msg-usuario TO tt-int-ds-msg-usuario.
                    ASSIGN tt-int-ds-msg-usuario.tamanho = LENGTH(TRIM(int-ds-msg-usuario.mensagem)).

                    ASSIGN l-achou-usuario = YES.
                END.
            END.
        END.
    END.
END.

IF l-achou-usuario = YES THEN DO:
    OUTPUT TO "t:\usuario.txt" NO-CONVERT APPEND.
    FOR EACH tt-int-ds-msg-usuario NO-LOCK:

        DISP tt-int-ds-msg-usuario.cod-usuario
             SUBSTR(tt-int-ds-msg-usuario.mensagem,1,50)
             tt-int-ds-msg-usuario.tamanho WITH SCROLLABLE.
             

    END.
    OUTPUT CLOSE.

    FOR EACH tt-int-ds-msg-usuario
       BREAK BY tt-int-ds-msg-usuario.tamanho DESC:

        ASSIGN po-cod-usuario =  tt-int-ds-msg-usuario.cod-usuario.
        LEAVE.
    END.

END.
ELSE DO:
    ASSIGN po-cod-usuario = "".
END.

RETURN "OK".

/* 

     /* INICIO - LΩgica para mostrar o usuˇrio Responsav≤l, e realizaªío do filtro */
     IF TRIM(c-cod-usuario) = "*" OR TRIM(c-cod-usuario) = "" THEN DO:
         FIND FIRST  int-ds-msg-usuario NO-LOCK
              WHERE  int-ds-msg-usuario.origem          = int-ds-log.origem
                AND  int-ds-msg-usuario.mensagem       <> "*"
                AND (int-ds-log.desc-ocorrencia MATCHES   "*" + TRIM(int-ds-msg-usuario.mensagem) + "*"
                 OR  int-ds-log.desc-ocorrencia BEGINS          TRIM(int-ds-msg-usuario.mensagem))      NO-ERROR.
         IF AVAIL int-ds-msg-usuario THEN DO:
             ASSIGN c-cod-usuar-aux = int-ds-msg-usuario.cod-usuario
                    l-achou-usuario = YES.
         END.
         ELSE DO:
             FIND FIRST  int-ds-msg-usuario NO-LOCK
                  WHERE  int-ds-msg-usuario.origem          = int-ds-log.origem
                    AND  int-ds-msg-usuario.mensagem        = "*" NO-ERROR.
             IF AVAIL int-ds-msg-usuario THEN DO:
                 ASSIGN c-cod-usuar-aux = int-ds-msg-usuario.cod-usuario
                        l-achou-usuario = YES.             END.
             ELSE DO:
                 ASSIGN c-cod-usuar-aux = ""
                        l-achou-usuario = NO.
             END.
         END.
     END.
     ELSE DO: /* ELSE da Verificaá∆o do Usu†rio em Branco ou Usu†rio "*" */
            
         /* INICIO - Primeiro - Busca se existe mensagem ligada ao usu†rio diretamente  */
        FIND FIRST  int-ds-msg-usuario NO-LOCK
             WHERE  int-ds-msg-usuario.origem          = int-ds-log.origem 
               AND  int-ds-msg-usuario.cod-usuario     =  c-cod-usuario
               AND (int-ds-log.desc-ocorrencia MATCHES "*" + TRIM(int-ds-msg-usuario.mensagem) + "*" 
                OR  int-ds-log.desc-ocorrencia BEGINS        TRIM(int-ds-msg-usuario.mensagem))      NO-ERROR.
        IF AVAIL int-ds-msg-usuario THEN DO:
            ASSIGN c-cod-usuar-aux = int-ds-msg-usuario.cod-usuario.
            ASSIGN l-achou-usuario = YES.
        END.
        /* FIM - Primeiro - Busca se existe mensagem ligada ao usu†rio diretamente  */
        ELSE DO:
            FIND FIRST  int-ds-msg-usuario NO-LOCK
             WHERE  int-ds-msg-usuario.origem          = int-ds-log.origem
               AND (int-ds-log.desc-ocorrencia MATCHES "*" + TRIM(int-ds-msg-usuario.mensagem) + "*"
                OR  int-ds-log.desc-ocorrencia BEGINS        TRIM(int-ds-msg-usuario.mensagem))      NO-ERROR.
            IF AVAIL int-ds-msg-usuario THEN DO:
    
                /* INICIO - Caso o usu†rio encontrado n∆o seja igual usu†rio selecionado n∆o mostra a mensagem */
                    IF int-ds-msg-usuario.cod-usuario <> "*" AND
                       int-ds-msg-usuario.cod-usuario <> c-cod-usuario THEN NEXT.
                /* FIM    - Caso o usu†rio encontrado n∆o seja igual usu†rio selecionado n∆o mostra a mensagem */
    
                ASSIGN c-cod-usuar-aux = int-ds-msg-usuario.cod-usuario.
                ASSIGN l-achou-usuario = YES.
            END.
            ELSE DO:
                FIND FIRST  int-ds-msg-usuario NO-LOCK
                 WHERE  int-ds-msg-usuario.origem          = int-ds-log.origem
                   AND  int-ds-msg-usuario.cod-usuario     = c-cod-usuario
                   AND  TRIM(int-ds-msg-usuario.mensagem)  = "*"   NO-ERROR.
                IF AVAIL int-ds-msg-usuario THEN DO:
                    ASSIGN c-cod-usuar-aux = int-ds-msg-usuario.cod-usuario.
                    ASSIGN l-achou-usuario = YES.
                END.
                ELSE DO:
                    FIND FIRST int-ds-msg-usuario NO-LOCK
                         WHERE int-ds-msg-usuario.origem            = int-ds-log.origem
                           AND TRIM(int-ds-msg-usuario.mensagem)    = "*"
                           AND TRIM(int-ds-msg-usuario.cod-usuario) = "*" NO-ERROR.
                    IF AVAIL int-ds-msg-usuario THEN DO:
                        ASSIGN c-cod-usuar-aux = "*".
                        ASSIGN l-achou-usuario = YES.
                    END.
                    ELSE DO:
                        ASSIGN c-cod-usuar-aux = "*".
                        ASSIGN l-achou-usuario = NO.
                        NEXT.
                    END.
                END.
            END.
    
        END.
     END.
    /* FIM - LΩgica para mostrar o usuˇrio Responsav≤l, e realizaªío do filtro */
 */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryLog wWindow 
PROCEDURE pi-openQueryLog :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def var h-acomp as handle no-undo.
def var i-aux as integer no-undo.

DEF VAR l-achou-usuario  AS LOGICAL INITIAL NO         NO-UNDO.
DEF VAR c-cod-usuar-aux  LIKE usuar_mestre.cod_usuario NO-UNDO.

def buffer b-int-ds-log for int-ds-log.

empty temp-table tt-int-ds-log.

/*session:SET-WAIT-STATE ("GENERAL").*/
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Lendo Integraá‰es").

for each int-ds-log no-lock use-index data-origem-sit where 
    int-ds-log.dt-ocorrencia >= d-dt-ocorrencia-ini and
    int-ds-log.dt-ocorrencia <= d-dt-ocorrencia-fim and
    int-ds-log.origem        >= c-origem-ini        and
    int-ds-log.origem        <= c-origem-fim        and
   (i-situacao = 0 or int-ds-log.situacao = i-situacao)
    on stop undo, leave:

    i-aux = i-aux + 1.
    if c-chave <> "" or i-aux mod 100 = 0 then
        run pi-acompanhar in h-acomp (input string(int-ds-log.chave)).

    if  int-ds-log.situacao = 9  then next.

    if i-situacao <> 0 and i-situacao <> int-ds-log.situacao then next.

    IF int-ds-log.origem = "CUPOM" THEN DO:
       if int-ds-log.dt-movto <> ? then do:
          IF int-ds-log.dt-movto < d-dt-movto-ini OR
             int-ds-log.dt-movto > d-dt-movto-fim THEN
             NEXT.
       end.      
    END.

    if c-chave <> "" and not int-ds-log.chave matches "*" + c-chave + "*" then next.

    /*if i-situacao <> 0 and int-ds-log.situacao <> i-situacao then next.*/
    
    for first tt-int-ds-log use-index ocorrencia where
        tt-int-ds-log.desc-ocorrencia = int-ds-log.desc-ocorrencia: end.

     ASSIGN l-achou-usuario = NO
            c-cod-usuar-aux = "".


     RUN pi-buscaUsuarioResposavel(INPUT  c-cod-usuario,
                                   INPUT  int-ds-log.origem,
                                   INPUT  int-ds-log.desc-ocorrencia,
                                   OUTPUT c-cod-usuar-aux ).

     IF c-cod-usuario <> "" AND c-cod-usuario <> "*" AND c-cod-usuar-aux <> "*" THEN DO:
         IF c-cod-usuario <> c-cod-usuar-aux THEN NEXT.
     END.

     IF NOT AVAIL tt-int-ds-log THEN DO:
        CREATE tt-int-ds-log.
        BUFFER-COPY int-ds-log TO tt-int-ds-log.
        ASSIGN tt-int-ds-log.cod-usuario-msg  = c-cod-usuar-aux .
     END.
end.

if i-situacao = 1 then 
for each tt-int-ds-log:
    if can-find (first b-int-ds-log where
                 b-int-ds-log.origem   = tt-int-ds-log.origem and 
                 b-int-ds-log.chave    = tt-int-ds-log.chave  and          
                 b-int-ds-log.situacao = 2) then do:

        i-aux = i-aux + 1.
        if c-chave <> "" or i-aux mod 100 = 0 then
            run pi-acompanhar in h-acomp (input string(tt-int-ds-log.chave)).
        delete tt-int-ds-log.

    end.
end.
/*session:SET-WAIT-STATE ("").*/

run pi-seta-titulo in h-acomp ("Abrindo consulta").
if can-find (first tt-int-ds-log) then do:
    OPEN QUERY brLog FOR EACH tt-int-ds-log NO-LOCK /*INDEXED-REPOSITION*/
        BY tt-int-ds-log.origem
           BY tt-int-ds-log.dt-ocorrencia
             BY tt-int-ds-log.hr-ocorrencia
               BY tt-int-ds-log.situacao
        max-rows 100000 .
    run setEnabled in hFolder (input 1, input true).
    enable all with frame fPage1.
    brLog:SELECT-ROW(1) in frame fPage1.
    apply "VALUE-CHANGED":U to brLog in frame fPage1.
end.
else do:
    run setEnabled in hFolder (input 1, input false).
    close query brLog.
    disable all with frame fPage1.
end.
run pi-finalizar in h-acomp.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-QuantidadeErrosOrigem wWindow 
PROCEDURE pi-QuantidadeErrosOrigem :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE iQtdPendente AS INT64       NO-UNDO.

EMPTY TEMP-TABLE tt-origem.

ASSIGN iQtdPendente = 0.

FOR EACH tt-int-ds-log
   WHERE tt-int-ds-log.situacao = 1 NO-LOCK
 BREAK BY tt-int-ds-log.origem.

    ASSIGN iQtdPendente = iQtdPendente + 1.

    IF LAST-OF(tt-int-ds-log.origem) THEN DO:

/*         MESSAGE "Origem       - " tt-int-ds-log.origem SKIP */
/*                 "iQtdPendente - " iQtdPendente              */
/*             VIEW-AS ALERT-BOX INFO BUTTONS OK.              */
        CREATE tt-origem.
        ASSIGN tt-origem.origem  = CAPS(tt-int-ds-log.origem)
               tt-origem.qtd-pen = iQtdPendente.

        ASSIGN iQtdPendente = 0.

    END.
END.

RUN intprg/int030c.w(INPUT TABLE tt-origem).

/*     DEFINE TEMP-TABLE tt-origem                                     */
/*     FIELD origem   AS CHAR FORMAT "x(12)" COLUMN-LABEL "Origem"     */
/*     FIELD qtd-int  AS INT64               COLUMN-LABEL "Integradas" */
/*     FIELD qtd-pen  AS INT64               COLUMN-LABEL "Pendentes". */

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

