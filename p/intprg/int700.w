&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
          ems2log          PROGRESS
*/
&Scoped-define WINDOW-NAME wWindow


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ttesp-itens-integracao NO-UNDO LIKE esp-itens-integracao
       field r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*:T*******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int700 1.00.00.001KML}

/* Chamada a include do gerenciador de licen‡as. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i int700 1.00.00.001KML}
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        int700
&GLOBAL-DEFINE Version        1.00.00.001KML

&GLOBAL-DEFINE WindowType     Master/Detail

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   <Folder1 ,Folder 2 ,... , Folder8>

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK  btHelp2 
&GLOBAL-DEFINE page1Widgets   fi-it-codigo-ini fi-it-codigo-fim ~
                              fi-ncm-ini fi-ncm-fim fi-dt-integracao-ini fi-dt-integracao-fim ~
                              ra-tributario ra-situacao bt-atualiza bt-ativar bt-integracao BROWSE-4
&GLOBAL-DEFINE page2Widgets 

DEFINE VARIABLE codigo AS CHARACTER   NO-UNDO.

{cdp/cdapi1001.i}
DEF VAR h-cdapi1001             AS WIDGET-HANDLE NO-UNDO.

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
&Scoped-define BROWSE-NAME BROWSE-4

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttesp-itens-integracao ITEM grup-estoque ~
familia

/* Definitions for BROWSE BROWSE-4                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-4 ttesp-itens-integracao.dt-integracao ttesp-itens-integracao.hr-integracao ttesp-itens-integracao.situacao ttesp-itens-integracao.it-codigo ITEM.desc-item FnCEST(codigo) ITEM.class-fiscal ITEM.fm-codigo familia.descricao ITEM.data-implant ITEM.un ITEM.ge-codigo grup-estoque.descricao ITEM.preco-base   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-4   
&Scoped-define SELF-NAME BROWSE-4
&Scoped-define QUERY-STRING-BROWSE-4 FOR EACH ttesp-itens-integracao, ~
           FIRST ITEM             WHERE ITEM.it-codigo             = ttesp-itens-integracao.it-codigo NO-LOCK, ~
           FIRST grup-estoque     WHERE grup-estoque.ge-codigo     = ITEM.ge-codigo   NO-LOCK, ~
           FIRST familia          WHERE familia.fm-codigo          = ITEM.fm-codigo NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-4 OPEN QUERY {&SELF-NAME} FOR EACH ttesp-itens-integracao, ~
           FIRST ITEM             WHERE ITEM.it-codigo             = ttesp-itens-integracao.it-codigo NO-LOCK, ~
           FIRST grup-estoque     WHERE grup-estoque.ge-codigo     = ITEM.ge-codigo   NO-LOCK, ~
           FIRST familia          WHERE familia.fm-codigo          = ITEM.fm-codigo NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-4 ttesp-itens-integracao ITEM ~
grup-estoque familia
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-4 ttesp-itens-integracao
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-4 ITEM
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-4 grup-estoque
&Scoped-define FOURTH-TABLE-IN-QUERY-BROWSE-4 familia


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-BROWSE-4}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 rtToolBar btQueryJoins ~
btReportsJoins btExit btHelp btOK btHelp2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD FnCEST wWindow 
FUNCTION FnCEST RETURNS CHARACTER ( INPUT it-codigo AS CHAR)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD FnCEST2 wWindow 
FUNCTION FnCEST2 RETURNS CHARACTER ( INPUT it-codigo AS CHAR)  FORWARD.

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


/* Definitions of the field level widgets                               */
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
     LABEL "Fechar" 
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

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 142 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 142 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON bt-ativar 
     LABEL "Ativar Item" 
     SIZE 17 BY 1.13.

DEFINE BUTTON bt-atualiza 
     IMAGE-UP FILE "adeicon/check.bmp":U
     IMAGE-DOWN FILE "adeicon/check.bmp":U
     IMAGE-INSENSITIVE FILE "adeicon/check.bmp":U
     LABEL "" 
     SIZE 6 BY 1.13.

DEFINE BUTTON bt-integracao 
     LABEL "Integra‡Æo TAXWEB" 
     SIZE 17 BY 1.13.

DEFINE VARIABLE fi-dt-integracao-fim AS DATE FORMAT "99/99/9999":U INITIAL 12/31/2999 
     VIEW-AS FILL-IN 
     SIZE 9.72 BY .79 NO-UNDO.

DEFINE VARIABLE fi-dt-integracao-ini AS DATE FORMAT "99/99/9999":U INITIAL 01/01/001 
     LABEL "Dt Integra‡Æo" 
     VIEW-AS FILL-IN 
     SIZE 9.72 BY .79 NO-UNDO.

DEFINE VARIABLE fi-it-codigo-fim AS CHARACTER FORMAT "X(256)":U INITIAL "ZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 12.57 BY .79 NO-UNDO.

DEFINE VARIABLE fi-it-codigo-ini AS CHARACTER FORMAT "X(20)":U 
     LABEL "Cod Item" 
     VIEW-AS FILL-IN 
     SIZE 12.57 BY .79 NO-UNDO.

DEFINE VARIABLE fi-ncm-fim AS INTEGER FORMAT "9999,99,99":U INITIAL 99999999 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .79 NO-UNDO.

DEFINE VARIABLE fi-ncm-ini AS INTEGER FORMAT "9999,99,99":U INITIAL 0 
     LABEL "NCM" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .79 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-3
     FILENAME "image\im-fir":U
     SIZE 8 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 8 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-7
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE VARIABLE ra-situacao AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Apenas recebido Venda+", 1,
"Validado fiscal", 2,
"Ambos", 3
     SIZE 20.72 BY 2.25 NO-UNDO.

DEFINE VARIABLE ra-tributario AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Integrado TaxWeb", 1,
"NÆo integrado", 2,
"Ambos", 3
     SIZE 20 BY 2.25 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 23 BY 3.25.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 25 BY 3.21.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 134 BY 18.5.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 3.5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-4 FOR 
      ttesp-itens-integracao, 
      ITEM, 
      grup-estoque, 
      familia SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-4 wWindow _FREEFORM
  QUERY BROWSE-4 DISPLAY
      ttesp-itens-integracao.dt-integracao
    ttesp-itens-integracao.hr-integracao
    ttesp-itens-integracao.situacao
    ttesp-itens-integracao.it-codigo
    ITEM.desc-item
    FnCEST(codigo) COLUMN-LABEL "CEST"
    ITEM.class-fiscal
    ITEM.fm-codigo
    familia.descricao
    ITEM.data-implant
    ITEM.un
    ITEM.ge-codigo
    grup-estoque.descricao
    ITEM.preco-base
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 131 BY 16
         FONT 1 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.17 COL 125.14 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.17 COL 129.14 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.17 COL 133.14 HELP
          "Sair"
     btHelp AT ROW 1.17 COL 137.14 HELP
          "Ajuda"
     btOK AT ROW 26.96 COL 2.57
     btCancel AT ROW 26.96 COL 13.57
     btHelp2 AT ROW 27 COL 130
     rtToolBar-2 AT ROW 1 COL 1
     rtToolBar AT ROW 26.75 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 144.14 BY 27.17
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     fi-it-codigo-ini AT ROW 1.5 COL 12.43 COLON-ALIGNED WIDGET-ID 4
     fi-it-codigo-fim AT ROW 1.5 COL 33.57 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     ra-tributario AT ROW 1.96 COL 54.14 NO-LABEL WIDGET-ID 30
     ra-situacao AT ROW 2.08 COL 82.29 NO-LABEL WIDGET-ID 38
     fi-ncm-ini AT ROW 2.46 COL 16 COLON-ALIGNED WIDGET-ID 8
     fi-ncm-fim AT ROW 2.46 COL 33.57 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     fi-dt-integracao-ini AT ROW 3.42 COL 15 COLON-ALIGNED WIDGET-ID 10
     fi-dt-integracao-fim AT ROW 3.42 COL 33.57 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     bt-atualiza AT ROW 3.5 COL 108 WIDGET-ID 46
     bt-integracao AT ROW 3.75 COL 118 WIDGET-ID 48
     BROWSE-4 AT ROW 6.25 COL 4 WIDGET-ID 200
     bt-ativar AT ROW 22.42 COL 4.29 WIDGET-ID 50
     "Situa‡Æo" VIEW-AS TEXT
          SIZE 8 BY .54 AT ROW 1.25 COL 80.57 WIDGET-ID 44
     "Integra‡Æo TaxWeb" VIEW-AS TEXT
          SIZE 15.29 BY .54 AT ROW 1.21 COL 53.72 WIDGET-ID 36
     IMAGE-1 AT ROW 1.54 COL 27.86 WIDGET-ID 16
     IMAGE-2 AT ROW 1.54 COL 31.86 WIDGET-ID 18
     IMAGE-3 AT ROW 2.46 COL 27.86 WIDGET-ID 20
     IMAGE-5 AT ROW 3.38 COL 27.86 WIDGET-ID 24
     IMAGE-6 AT ROW 3.42 COL 31.86 WIDGET-ID 26
     IMAGE-7 AT ROW 2.5 COL 31.86 WIDGET-ID 28
     RECT-1 AT ROW 1.5 COL 52 WIDGET-ID 34
     RECT-2 AT ROW 1.54 COL 79 WIDGET-ID 42
     RECT-3 AT ROW 5.25 COL 3 WIDGET-ID 52
     RECT-4 AT ROW 1.25 COL 4 WIDGET-ID 54
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 2.75
         SIZE 141 BY 23.25
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: ttesp-itens-integracao T "?" NO-UNDO custom esp-itens-integracao
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
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
         HEIGHT             = 27.17
         WIDTH              = 144.14
         MAX-HEIGHT         = 27.71
         MAX-WIDTH          = 160.86
         VIRTUAL-HEIGHT     = 27.71
         VIRTUAL-WIDTH      = 160.86
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
/* SETTINGS FOR BUTTON btCancel IN FRAME fpage0
   NO-ENABLE                                                            */
ASSIGN 
       btCancel:HIDDEN IN FRAME fpage0           = TRUE.

/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB BROWSE-4 bt-integracao fPage1 */
ASSIGN 
       BROWSE-4:ROW-RESIZABLE IN FRAME fPage1          = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-4
/* Query rebuild information for BROWSE BROWSE-4
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttesp-itens-integracao,
    FIRST ITEM             WHERE ITEM.it-codigo             = ttesp-itens-integracao.it-codigo NO-LOCK,
    FIRST grup-estoque     WHERE grup-estoque.ge-codigo     = ITEM.ge-codigo   NO-LOCK,
    FIRST familia          WHERE familia.fm-codigo          = ITEM.fm-codigo NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-4 */
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


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME bt-ativar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ativar wWindow
ON CHOOSE OF bt-ativar IN FRAME fPage1 /* Ativar Item */
DO:
  FIND CURRENT ttesp-itens-integracao NO-ERROR.

  FIND FIRST esp-itens-integracao 
      WHERE esp-itens-integracao.it-codigo = ttesp-itens-integracao.it-codigo EXCLUSIVE-LOCK NO-ERROR.
  
  IF AVAIL esp-itens-integracao THEN DO:
  
    ASSIGN esp-itens-integracao.situacao = 2
           ttesp-itens-integracao.situacao = 2.
   
  END.

  RELEASE esp-itens-integracao.

  APPLY "CHOOSE" TO bt-atualiza IN FRAME fpage1.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-atualiza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-atualiza wWindow
ON CHOOSE OF bt-atualiza IN FRAME fPage1
DO:

    EMPTY TEMP-TABLE ttesp-itens-integracao.

    FOR EACH esp-itens-integracao NO-LOCK
        WHERE esp-itens-integracao.dt-integracao    >= date(fi-dt-integracao-ini:SCREEN-VALUE IN FRAME fpage1)
          AND esp-itens-integracao.dt-integracao    <= date(fi-dt-integracao-fim:SCREEN-VALUE IN FRAME fpage1)
          AND esp-itens-integracao.it-codigo        >= fi-it-codigo-ini:SCREEN-VALUE IN FRAME fpage1
          AND esp-itens-integracao.it-codigo        <= fi-it-codigo-fim:SCREEN-VALUE IN FRAME fpage1
          AND (INPUT FRAME fpage1 ra-situacao         = 3 OR esp-itens-integracao.situacao          = INPUT FRAME fpage1 ra-situacao):

        FIND FIRST ITEM NO-LOCK 
            WHERE ITEM.it-codigo    = esp-itens-integracao.it-codigo 
              AND ITEM.class-fiscal >= string(int(INPUT FRAME fpage1 fi-ncm-ini))
              AND ITEM.class-fiscal <= string(int(INPUT FRAME fpage1 fi-ncm-fim)) NO-ERROR.

        IF AVAIL ITEM  THEN DO:
        
            
            CREATE ttesp-itens-integracao.
            BUFFER-COPY esp-itens-integracao TO ttesp-itens-integracao.
        END.
    END.
    
    
    {&OPEN-QUERY-BROWSE-4}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
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
ON CHOOSE OF btOK IN FRAME fpage0 /* Fechar */
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


&Scoped-define SELF-NAME miAbout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL miAbout wWindow
ON CHOOSE OF MENU-ITEM miAbout /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-4
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{window/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION FnCEST wWindow 
FUNCTION FnCEST RETURNS CHARACTER ( INPUT it-codigo AS CHAR) :

    IF NOT VALID-HANDLE(h-cdapi1001) THEN
       RUN cdp/cdapi1001.p     PERSISTENT SET h-cdapi1001.
        
    EMPTY TEMP-TABLE tt-sit-tribut.
    RUN pi-seta-tributos IN h-cdapi1001 (input "11").
    RUN pi-retorna-sit-tribut IN h-cdapi1001 (INPUT  1,
                                            INPUT  "*",
                                            INPUT  "*",
                                            INPUT  ITEM.class-fiscal,
                                            INPUT  ITEM.it-codigo,
                                            INPUT  "*",
                                            INPUT  0,
                                            INPUT  TODAY,
                                            OUTPUT TABLE tt-sit-tribut).
                                            
    FIND FIRST tt-sit-tribut NO-ERROR.
    IF AVAIL tt-sit-tribut THEN
    DO:
      RETURN string(tt-sit-tribut.cdn-sit-tribut).  
    END.
       
   


  
 

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION FnCEST2 wWindow 
FUNCTION FnCEST2 RETURNS CHARACTER ( INPUT it-codigo AS CHAR) :

    IF NOT VALID-HANDLE(h-cdapi1001) THEN
       RUN cdp/cdapi1001.p     PERSISTENT SET h-cdapi1001.
        
    EMPTY TEMP-TABLE tt-sit-tribut.
    RUN pi-seta-tributos IN h-cdapi1001 (input "11").
    RUN pi-retorna-sit-tribut IN h-cdapi1001 (INPUT  1,
                                            INPUT  "*",
                                            INPUT  "*",
                                            INPUT  ITEM.class-fiscal,
                                            INPUT  ITEM.it-codigo,
                                            INPUT  "*",
                                            INPUT  0,
                                            INPUT  TODAY,
                                            OUTPUT TABLE tt-sit-tribut).
                                            
    FIND FIRST tt-sit-tribut NO-ERROR.
    IF AVAIL tt-sit-tribut THEN
    DO:
      RETURN STRING(tt-sit-tribut.cdn-sit-tribut).  
    END.
       



  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

