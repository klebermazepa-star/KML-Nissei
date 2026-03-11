&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i INT014A 2.12.01.AVB}

/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT014A
&GLOBAL-DEFINE Version        2.00.00.008

&GLOBAL-DEFINE WindowType     Detail

&GLOBAL-DEFINE page0Widgets   c-nome-ab-cli-ini c-nome-ab-cli-fim ~
                              c-cod-estabel-ini c-cod-estabel-fim ~
                              c-serie-ini c-serie-fim ~
                              c-nr-nota-fis-ini c-nr-nota-fis-fim ~
                              d-dt-emis-nota-ini d-dt-emis-nota-fim ~
                              c-nr-embarque-ini c-nr-embarque-fim ~
                              c-mensagem-1 c-mensagem-2 ~
                              rsSituacao rsTipo-Movto rsTipo-Docto ~
                              btHelp btOK btCancel 

/* Parameters Definitions ---                                           */
DEFINE INPUT-OUTPUT PARAM p-nome-ab-cli-ini LIKE nota-fiscal.nome-ab-cli NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-nome-ab-cli-fim LIKE nota-fiscal.nome-ab-cli NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-cod-estabel-ini LIKE nota-fiscal.cod-estabel NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-cod-estabel-fim LIKE nota-fiscal.cod-estabel NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-serie-ini       LIKE nota-fiscal.serie       NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-serie-fim       LIKE nota-fiscal.serie       NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-nr-nota-fis-ini LIKE nota-fiscal.nr-nota-fis NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-nr-nota-fis-fim LIKE nota-fiscal.nr-nota-fis NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-da-dt-emis-ini  LIKE nota-fiscal.dt-emis     NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-da-dt-emis-fim  LIKE nota-fiscal.dt-emis     NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-nr-embarque-ini LIKE nota-fiscal.nr-embarque NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-nr-embarque-fim LIKE nota-fiscal.nr-embarque NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-mensagem-1      as character                 no-undo.
DEFINE INPUT-OUTPUT PARAM p-mensagem-2      as character                 no-undo.
DEFINE INPUT-OUTPUT PARAM p-tipo-movto      as integer                   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-situacao        as integer                   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-tipo-docto      as integer                   NO-UNDO.
DEFINE       OUTPUT PARAM p-l-open-query    AS   LOGICAL                 NO-UNDO.

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE i-cod-ocor AS INTEGER    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS c-mensagem-1 rsTipo-Movto c-nome-ab-cli-ini ~
c-nome-ab-cli-fim c-cod-estabel-ini c-cod-estabel-fim c-serie-ini ~
c-serie-fim c-nr-nota-fis-ini c-nr-nota-fis-fim d-dt-emis-nota-ini ~
d-dt-emis-nota-fim c-nr-embarque-ini c-nr-embarque-fim btOK btCancel btHelp ~
rsSituacao rsTipo-Docto c-mensagem-2 IMAGE-1 IMAGE-10 IMAGE-11 IMAGE-12 ~
IMAGE-2 IMAGE-3 IMAGE-4 IMAGE-5 IMAGE-6 IMAGE-7 IMAGE-8 IMAGE-9 rtToolBar 
&Scoped-Define DISPLAYED-OBJECTS c-mensagem-1 rsTipo-Movto ~
c-nome-ab-cli-ini c-nome-ab-cli-fim c-cod-estabel-ini c-cod-estabel-fim ~
c-serie-ini c-serie-fim c-nr-nota-fis-ini c-nr-nota-fis-fim ~
d-dt-emis-nota-ini d-dt-emis-nota-fim c-nr-embarque-ini c-nr-embarque-fim ~
rsSituacao rsTipo-Docto c-mensagem-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "&Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp 
     LABEL "&Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "&OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-cod-estabel-fim AS CHARACTER FORMAT "X(5)" INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 7.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-cod-estabel-ini AS CHARACTER FORMAT "X(5)" 
     LABEL "Estab":R7 
     VIEW-AS FILL-IN 
     SIZE 7.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-mensagem-1 AS CHARACTER FORMAT "X(256)":U 
     LABEL "Mensagem come‡a  com" 
     VIEW-AS FILL-IN 
     SIZE 36 BY .79 NO-UNDO.

DEFINE VARIABLE c-mensagem-2 AS CHARACTER FORMAT "X(256)":U 
     LABEL "Mensagem Cont‚m" 
     VIEW-AS FILL-IN 
     SIZE 36 BY .79 NO-UNDO.

DEFINE VARIABLE c-nome-ab-cli-fim AS CHARACTER FORMAT "x(12)" INITIAL "ZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE c-nome-ab-cli-ini AS CHARACTER FORMAT "x(12)" 
     LABEL "Cliente/Fornec":R17 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE c-nr-embarque-fim AS INTEGER FORMAT ">>>>>,>>9" INITIAL 99999999 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88.

DEFINE VARIABLE c-nr-embarque-ini AS INTEGER FORMAT ">>>>>,>>9" INITIAL 0 
     LABEL "Embarque":R10 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88.

DEFINE VARIABLE c-nr-nota-fis-fim AS CHARACTER FORMAT "x(16)" INITIAL "ZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88.

DEFINE VARIABLE c-nr-nota-fis-ini AS CHARACTER FORMAT "x(16)" 
     LABEL "Nr Nota Fiscal":R17 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88.

DEFINE VARIABLE c-serie-fim AS CHARACTER FORMAT "x(5)" INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88.

DEFINE VARIABLE c-serie-ini AS CHARACTER FORMAT "x(5)" 
     LABEL "S‚rie":R7 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88.

DEFINE VARIABLE d-dt-emis-nota-fim AS DATE FORMAT "99/99/9999" INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE d-dt-emis-nota-ini AS DATE FORMAT "99/99/9999" INITIAL 01/01/001 
     LABEL "Dt EmissÆo":R12 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-10
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-11
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-3
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-4
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-7
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-8
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-9
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE VARIABLE rsSituacao AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Pendentes", 1,
"Atualizados", 2,
"Todos", 0
     SIZE 30.57 BY .54 NO-UNDO.

DEFINE VARIABLE rsTipo-Docto AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Entradas", 1,
"Saidas", 2,
"Cupons", 3,
"Todos", 0
     SIZE 37 BY .54 NO-UNDO.

DEFINE VARIABLE rsTipo-Movto AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "InclusÆo", 1,
"Altera‡Æo", 2,
"ExclusÆo", 3,
"Todos", 0
     SIZE 41 BY .54 NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 78 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     c-mensagem-1 AT ROW 7.75 COL 21 COLON-ALIGNED WIDGET-ID 22
     rsTipo-Movto AT ROW 9.83 COL 22.29 NO-LABEL WIDGET-ID 2
     c-nome-ab-cli-ini AT ROW 1.54 COL 21 COLON-ALIGNED
     c-nome-ab-cli-fim AT ROW 1.54 COL 46.57 COLON-ALIGNED NO-LABEL
     c-cod-estabel-ini AT ROW 2.54 COL 21 COLON-ALIGNED
     c-cod-estabel-fim AT ROW 2.5 COL 46.57 COLON-ALIGNED NO-LABEL
     c-serie-ini AT ROW 3.54 COL 21 COLON-ALIGNED
     c-serie-fim AT ROW 3.5 COL 46.57 COLON-ALIGNED NO-LABEL
     c-nr-nota-fis-ini AT ROW 4.54 COL 21 COLON-ALIGNED
     c-nr-nota-fis-fim AT ROW 4.54 COL 46.57 COLON-ALIGNED NO-LABEL
     d-dt-emis-nota-ini AT ROW 5.54 COL 21 COLON-ALIGNED HELP
          "Data de emissÆo da nota fiscal"
     d-dt-emis-nota-fim AT ROW 5.54 COL 46.57 COLON-ALIGNED HELP
          "Data de emissÆo da nota fiscal" NO-LABEL
     c-nr-embarque-ini AT ROW 6.54 COL 21 COLON-ALIGNED HELP
          "Embarque"
     c-nr-embarque-fim AT ROW 6.54 COL 46.57 COLON-ALIGNED HELP
          "Embarque" NO-LABEL
     btOK AT ROW 13.04 COL 2
     btCancel AT ROW 13.04 COL 13
     btHelp AT ROW 13.04 COL 68.14
     rsSituacao AT ROW 10.92 COL 22.29 NO-LABEL WIDGET-ID 8
     rsTipo-Docto AT ROW 12 COL 22.29 NO-LABEL WIDGET-ID 16
     c-mensagem-2 AT ROW 8.75 COL 21 COLON-ALIGNED WIDGET-ID 24
     "Tipo Movto:" VIEW-AS TEXT
          SIZE 9.57 BY .54 AT ROW 9.83 COL 12.72 WIDGET-ID 12
     "Situa‡Æo:" VIEW-AS TEXT
          SIZE 7.57 BY .54 AT ROW 10.92 COL 14.72 WIDGET-ID 14
     "Documentos:" VIEW-AS TEXT
          SIZE 10.29 BY .54 AT ROW 12 COL 12 WIDGET-ID 20
     IMAGE-1 AT ROW 4.54 COL 40.57
     IMAGE-10 AT ROW 3.54 COL 44.72
     IMAGE-11 AT ROW 6.54 COL 40.57
     IMAGE-12 AT ROW 6.54 COL 44.72
     IMAGE-2 AT ROW 4.54 COL 44.72
     IMAGE-3 AT ROW 1.54 COL 40.72
     IMAGE-4 AT ROW 1.54 COL 44.72
     IMAGE-5 AT ROW 5.54 COL 40.57
     IMAGE-6 AT ROW 5.54 COL 44.72
     IMAGE-7 AT ROW 2.54 COL 40.57
     IMAGE-8 AT ROW 2.54 COL 44.72
     IMAGE-9 AT ROW 3.54 COL 40.57
     rtToolBar AT ROW 12.75 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 78.57 BY 13.46
         FONT 1
         DEFAULT-BUTTON btOK.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 13.46
         WIDTH              = 79.43
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
   FRAME-NAME Custom                                                    */
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
    ASSIGN p-l-open-query = NO.

    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    assign frame fPage0
            c-nome-ab-cli-ini 
            c-nome-ab-cli-fim 
            c-cod-estabel-ini 
            c-cod-estabel-fim 
            c-serie-ini       
            c-serie-fim       
            c-nr-nota-fis-ini 
            c-nr-nota-fis-fim 
            d-dt-emis-nota-ini
            d-dt-emis-nota-fim
            c-nr-embarque-ini 
            c-nr-embarque-fim
            c-mensagem-1
            c-mensagem-2
            rsTipo-Movto
            rsSituacao
            rsTipo-Docto.

    assign  p-nome-ab-cli-ini  = c-nome-ab-cli-ini 
            p-nome-ab-cli-fim  = c-nome-ab-cli-fim 
            p-cod-estabel-ini  = c-cod-estabel-ini 
            p-cod-estabel-fim  = c-cod-estabel-fim 
            p-serie-ini        = c-serie-ini       
            p-serie-fim        = c-serie-fim       
            p-nr-nota-fis-ini  = c-nr-nota-fis-ini 
            p-nr-nota-fis-fim  = c-nr-nota-fis-fim 
            p-da-dt-emis-ini   = d-dt-emis-nota-ini
            p-da-dt-emis-fim   = d-dt-emis-nota-fim
            p-nr-embarque-ini  = c-nr-embarque-ini 
            p-nr-embarque-fim  = c-nr-embarque-fim 
            p-mensagem-1       = c-mensagem-1
            p-mensagem-2       = c-mensagem-2
            p-tipo-movto       = rsTipo-Movto
            p-situacao         = rsSituacao
            p-tipo-docto       = rsTipo-Docto
            .

    assign p-l-open-query = yes.

    APPLY "CLOSE":U TO THIS-PROCEDURE.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{window/mainblock.i}

&IF "{&mguni_version}" >= "2.071" &THEN
ASSIGN c-cod-estabel-fim:SCREEN-VALUE IN FRAME fPage0 = "ZZZZZ".
&ELSE
ASSIGN c-cod-estabel-fim:SCREEN-VALUE IN FRAME fPage0 = "ZZZ".
&ENDIF

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

    assign  c-nome-ab-cli-ini :screen-value in frame fPage0 = p-nome-ab-cli-ini  
            c-nome-ab-cli-fim :screen-value in frame fPage0 = p-nome-ab-cli-fim  
            c-cod-estabel-ini :screen-value in frame fPage0 = p-cod-estabel-ini  
            c-cod-estabel-fim :screen-value in frame fPage0 = p-cod-estabel-fim  
            c-serie-ini       :screen-value in frame fPage0 = p-serie-ini        
            c-serie-fim       :screen-value in frame fPage0 = p-serie-fim        
            c-nr-nota-fis-ini :screen-value in frame fPage0 = p-nr-nota-fis-ini  
            c-nr-nota-fis-fim :screen-value in frame fPage0 = p-nr-nota-fis-fim  
            d-dt-emis-nota-ini:screen-value in frame fPage0 = string(p-da-dt-emis-ini)   
            d-dt-emis-nota-fim:screen-value in frame fPage0 = string(p-da-dt-emis-fim)   
            c-nr-embarque-ini :screen-value in frame fPage0 = string(p-nr-embarque-ini)  
            c-nr-embarque-fim :screen-value in frame fPage0 = string(p-nr-embarque-fim)
            rsTipo-Movto      :screen-value in frame fPage0 = string(p-tipo-movto)
            rsSituacao        :screen-value in frame fPage0 = string(p-situacao)
            rsTipo-Docto      :screen-value in frame fPage0 = string(p-tipo-docto)
            c-mensagem-1      :screen-value in frame fPage0 = string(p-mensagem-1)
            c-mensagem-2      :screen-value in frame fPage0 = string(p-mensagem-2)
            
        .



RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

