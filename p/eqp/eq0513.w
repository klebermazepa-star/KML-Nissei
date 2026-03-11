&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*:T*******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i EQ0513 2.00.00.013 } /*** 010012 ***/

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
{include/i-license-manager.i EQ0513 MEQ}
&ENDIF

CREATE WIDGET-POOL.

/* A tiva Seguranáa por Estabelecimento */
{cdp/cd0019.i "MEQ"}

/* Temp-table Definitions*/
{dibo/bodi102.i tt-loc-entr}
{dibo/bodi102.i tt-loc-entr-aux}
{dibo/bodi784.i tt-estab-rota-entreg}
{dibo/bodi784.i tt-estab-rota-entreg-aux}
{dibo/bodi784.i tt-estab-rota-entreg-remove}

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        EQ0513
&GLOBAL-DEFINE Version        2.00.00.013

&GLOBAL-DEFINE WindowType     Detail

&GLOBAL-DEFINE Folder         0
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit ~
                              btOK btCancel btHelp btHelp2 ~
                              fi-estabel fi-rota fi-busca-cli ~
                              brSource brTarget btCheck ~
                              btAddAllTarget btAddTarget ~
                              btDelTarget btDelAllTarget ~
                              btNovo btModifica btBusca ~
                              btUp btDown

&GLOBAL-DEFINE ttSource       tt-loc-entr
&GLOBAL-DEFINE ttTarget       tt-estab-rota-entreg

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE hDBOTarget     AS HANDLE             NO-UNDO.
                                                     
DEFINE VARIABLE c-cod-estabel  AS CHARACTER          NO-UNDO.
DEFINE VARIABLE c-des-estabel  AS CHARACTER          NO-UNDO.
DEFINE VARIABLE c-cod-rota     AS CHARACTER          NO-UNDO.
DEFINE VARIABLE c-des-rota     AS CHARACTER          NO-UNDO.
DEFINE VARIABLE i-cont         AS INTEGER            NO-UNDO.
DEFINE VARIABLE i-seq          AS INTEGER            NO-UNDO.
DEFINE VARIABLE r-rowid-target AS ROWID              NO-UNDO.
DEFINE VARIABLE cAux           AS CHARACTER          NO-UNDO.
DEFINE VARIABLE cAux2          AS CHARACTER          NO-UNDO.

DEFINE VARIABLE l-ok           AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE l-alterado     AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE l-check        AS LOGICAL INITIAL NO NO-UNDO.

DEFINE BUFFER bf-{&ttTarget} FOR {&ttTarget}.

DEFINE VARIABLE wh-pesquisa                      AS HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brSource

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES {&ttSource} {&ttTarget}

/* Definitions for BROWSE brSource                                      */
&Scoped-define FIELDS-IN-QUERY-brSource {&ttSource}.nome-abrev {&ttSource}.cod-entrega   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brSource   
&Scoped-define SELF-NAME brSource
&Scoped-define QUERY-STRING-brSource FOR EACH {&ttSource} INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brSource OPEN QUERY {&SELF-NAME} FOR EACH {&ttSource} INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brSource {&ttSource}
&Scoped-define FIRST-TABLE-IN-QUERY-brSource {&ttSource}


/* Definitions for BROWSE brTarget                                      */
&Scoped-define FIELDS-IN-QUERY-brTarget {&ttTarget}.nome-abrev {&ttTarget}.cod-entrega {&ttTarget}.nr-sequencia {&ttTarget}.cod-livre-2   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTarget   
&Scoped-define SELF-NAME brTarget
&Scoped-define QUERY-STRING-brTarget FOR EACH {&ttTarget}                               BY {&ttTarget}.nr-sequencia
&Scoped-define OPEN-QUERY-brTarget OPEN QUERY {&SELF-NAME} FOR EACH {&ttTarget}                               BY {&ttTarget}.nr-sequencia.
&Scoped-define TABLES-IN-QUERY-brTarget {&ttTarget}
&Scoped-define FIRST-TABLE-IN-QUERY-brTarget {&ttTarget}


/* Definitions for FRAME fpage0                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fpage0 ~
    ~{&OPEN-QUERY-brSource}~
    ~{&OPEN-QUERY-brTarget}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 fi-rota rtToolBar btOK RECT-1 ~
RECT-2 btCancel btHelp2 btQueryJoins btReportsJoins btExit btHelp btCheck ~
btBusca fi-busca-cli brSource brTarget btNovo btModifica btAddAllTarget ~
btUp btAddTarget btDelTarget btDown btDelAllTarget fi-estabel 
&Scoped-Define DISPLAYED-OBJECTS fi-rota fi-des-rota fi-busca-cli ~
fi-estabel fi-des-estabel 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
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
DEFINE BUTTON btAddAllTarget 
     IMAGE-UP FILE "image\add-all":U
     IMAGE-INSENSITIVE FILE "image\ii-add-all":U
     LABEL "" 
     SIZE 7 BY 1 TOOLTIP "Inclui Todos".

DEFINE BUTTON btAddTarget 
     IMAGE-UP FILE "adeicon\next-au":U
     IMAGE-INSENSITIVE FILE "adeicon\next-ai":U
     LABEL "" 
     SIZE 7 BY 1 TOOLTIP "Inclui".

DEFINE BUTTON btBusca 
     IMAGE-UP FILE "image/im-enter.bmp":U
     LABEL "" 
     SIZE 4 BY 1.25 TOOLTIP "V† Para".

DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btCheck 
     IMAGE-UP FILE "image/im-chck1.bmp":U
     LABEL "" 
     SIZE 4 BY 1.25 TOOLTIP "Confirma".

DEFINE BUTTON btDelAllTarget 
     IMAGE-UP FILE "image\del-all":U
     IMAGE-INSENSITIVE FILE "image\ii-del-all":U
     LABEL "" 
     SIZE 7 BY 1 TOOLTIP "Retira Todos".

DEFINE BUTTON btDelTarget 
     IMAGE-UP FILE "adeicon\prev-au":U
     IMAGE-INSENSITIVE FILE "adeicon\prev-ai":U
     LABEL "" 
     SIZE 7 BY 1 TOOLTIP "Retira".

DEFINE BUTTON btDown 
     IMAGE-UP FILE "image/im-adduni.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-adduni.bmp":U
     LABEL "" 
     SIZE 4 BY 1.79 TOOLTIP "Move para Baixo".

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

DEFINE BUTTON btModifica 
     IMAGE-UP FILE "image/im-mod.bmp":U
     LABEL "" 
     SIZE 4 BY 1.25 TOOLTIP "Altera sequància corrente".

DEFINE BUTTON btNovo 
     IMAGE-UP FILE "image/im-add.bmp":U
     LABEL "" 
     SIZE 4 BY 1.25 TOOLTIP "Inclui nova sequància".

DEFINE BUTTON btOK 
     LABEL "Salvar" 
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

DEFINE BUTTON btUp 
     IMAGE-UP FILE "image/im-remuni.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-remuni.bmp":U
     LABEL "" 
     SIZE 4 BY 1.79 TOOLTIP "Move para Cima".

DEFINE VARIABLE fi-busca-cli AS CHARACTER FORMAT "X(12)":U 
     LABEL "Cliente" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE fi-des-estabel AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 35 BY .88 NO-UNDO.

DEFINE VARIABLE fi-des-rota AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 29 BY .88 NO-UNDO.

DEFINE VARIABLE fi-estabel AS CHARACTER FORMAT "X(5)":U INITIAL "973" 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE fi-rota AS CHARACTER FORMAT "X(12)":U 
     LABEL "Rota" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 89.43 BY 3.25.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 89.43 BY 10.58.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brSource FOR 
      {&ttSource} SCROLLING.

DEFINE QUERY brTarget FOR 
      {&ttTarget} SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brSource
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brSource wWindow _FREEFORM
  QUERY brSource DISPLAY
      {&ttSource}.nome-abrev WIDTH 12
{&ttSource}.cod-entrega
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 26.14 BY 8
         FONT 2.

DEFINE BROWSE brTarget
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTarget wWindow _FREEFORM
  QUERY brTarget DISPLAY
      {&ttTarget}.nome-abrev WIDTH 12
{&ttTarget}.cod-entrega
{&ttTarget}.nr-sequencia
{&ttTarget}.cod-livre-2 WIDTH 6 COLUMN-LABEL "SÇrie"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 36.57 BY 8
         FONT 2.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     fi-rota AT ROW 4.25 COL 18.43 COLON-ALIGNED HELP
          "C¢digo da Rota"
     fi-des-rota AT ROW 4.25 COL 30.43 COLON-ALIGNED NO-LABEL
     btOK AT ROW 16.75 COL 2
     btCancel AT ROW 16.75 COL 13
     btHelp2 AT ROW 16.75 COL 80
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     btCheck AT ROW 4 COL 61.43 HELP
          "Confirma"
     btBusca AT ROW 6.25 COL 26 HELP
          "V† Para"
     fi-busca-cli AT ROW 6.5 COL 12 COLON-ALIGNED HELP
          "Nome Abreviado do Cliente"
     brSource AT ROW 7.75 COL 8
     brTarget AT ROW 7.75 COL 45
     btNovo AT ROW 7.75 COL 81.72 HELP
          "Inclui nova sequància"
     btModifica AT ROW 9 COL 81.72 HELP
          "Altera sequància corrente"
     btAddAllTarget AT ROW 9.63 COL 36 HELP
          "Inclui Todos"
     btUp AT ROW 10.25 COL 81.72 HELP
          "Move para Cima"
     btAddTarget AT ROW 10.79 COL 36 HELP
          "Inclui"
     btDelTarget AT ROW 11.92 COL 36 HELP
          "Retira"
     btDown AT ROW 12.04 COL 81.72 HELP
          "Move para Baixo"
     btDelAllTarget AT ROW 13.04 COL 36 HELP
          "Retira Todos"
     fi-estabel AT ROW 3.25 COL 18.43 COLON-ALIGNED HELP
          "C¢digo do Estabelecimento"
     fi-des-estabel AT ROW 3.25 COL 24.43 COLON-ALIGNED NO-LABEL
     rtToolBar-2 AT ROW 1 COL 1
     rtToolBar AT ROW 16.54 COL 1
     RECT-1 AT ROW 2.58 COL 1.29
     RECT-2 AT ROW 5.92 COL 1.29
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17.13
         FONT 1.


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
         HEIGHT             = 17.13
         WIDTH              = 90
         MAX-HEIGHT         = 33.04
         MAX-WIDTH          = 228.57
         VIRTUAL-HEIGHT     = 33.04
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
/* SETTINGS FOR FRAME fpage0
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB brSource fi-busca-cli fpage0 */
/* BROWSE-TAB brTarget brSource fpage0 */
ASSIGN 
       brSource:COLUMN-RESIZABLE IN FRAME fpage0       = TRUE.

ASSIGN 
       brTarget:COLUMN-MOVABLE IN FRAME fpage0         = TRUE.

/* SETTINGS FOR FILL-IN fi-des-estabel IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-des-rota IN FRAME fpage0
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brSource
/* Query rebuild information for BROWSE brSource
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH {&ttSource} INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brSource */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTarget
/* Query rebuild information for BROWSE brTarget
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH {&ttTarget}
                              BY {&ttTarget}.nr-sequencia.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brTarget */
&ANALYZE-RESUME

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
    RUN pi-validarAlteracao.
    IF RETURN-VALUE = "OK":U THEN DO:
        APPLY "CLOSE":U TO THIS-PROCEDURE.        
    END.

    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brSource
&Scoped-define SELF-NAME brSource
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brSource wWindow
ON MOUSE-SELECT-DBLCLICK OF brSource IN FRAME fpage0
DO:
    APPLY "CHOOSE":U TO btAddTarget.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brSource wWindow
ON VALUE-CHANGED OF brSource IN FRAME fpage0
DO:
    IF brSource:NUM-ITERATIONS > 0 THEN
        ASSIGN btAddAllTarget:SENSITIVE IN FRAME {&FRAME-NAME} = TRUE
               btAddTarget:SENSITIVE    IN FRAME {&FRAME-NAME} = TRUE.
    ELSE
        ASSIGN btAddAllTarget:SENSITIVE IN FRAME {&FRAME-NAME} = FALSE
               btAddTarget:SENSITIVE    IN FRAME {&FRAME-NAME} = FALSE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTarget
&Scoped-define SELF-NAME brTarget
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTarget wWindow
ON MOUSE-SELECT-DBLCLICK OF brTarget IN FRAME fpage0
DO:
    APPLY "CHOOSE":U TO btDelTarget.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTarget wWindow
ON VALUE-CHANGED OF brTarget IN FRAME fpage0
DO:
    IF brTarget:NUM-ITERATIONS > 0 THEN
        ASSIGN btDelAllTarget:SENSITIVE IN FRAME {&FRAME-NAME} = TRUE
               btdelTarget:SENSITIVE    IN FRAME {&FRAME-NAME} = TRUE
               btModifica:SENSITIVE     IN FRAME {&FRAME-NAME} = TRUE.
    ELSE
        ASSIGN btDelAllTarget:SENSITIVE IN FRAME {&FRAME-NAME} = FALSE
               btdelTarget:SENSITIVE    IN FRAME {&FRAME-NAME} = FALSE
               btModifica:SENSITIVE     IN FRAME {&FRAME-NAME} = FALSE.

    IF brTarget:NUM-ITERATIONS > 1 THEN
        ASSIGN btUp:SENSITIVE   IN FRAME {&FRAME-NAME} = TRUE
               btDown:SENSITIVE IN FRAME {&FRAME-NAME} = TRUE.
    ELSE
        ASSIGN btUp:SENSITIVE   IN FRAME {&FRAME-NAME} = FALSE
               btDown:SENSITIVE IN FRAME {&FRAME-NAME} = FALSE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAddAllTarget
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddAllTarget wWindow
ON CHOOSE OF btAddAllTarget IN FRAME fpage0
DO:
    IF CAN-FIND(FIRST {&ttSource}) THEN DO:

        /* Busca £ltima sequància */
        ASSIGN i-seq = 0.
        FOR LAST bf-{&ttTarget} NO-LOCK
              BY bf-{&ttTarget}.cod-estabel 
              BY bf-{&ttTarget}.cod-rota    
              BY bf-{&ttTarget}.nr-sequencia:
            ASSIGN i-seq = bf-{&ttTarget}.nr-sequencia.
        END.

        FOR EACH {&ttSource} NO-LOCK:
            /* Cria registro associado ao browse destino */
            CREATE {&ttTarget}.
            ASSIGN i-seq                    = i-seq + 1
                   {&ttTarget}.r-rowid      = ROWID({&ttTarget})
                   {&ttTarget}.cod-estabel  = INPUT FRAME {&FRAME-NAME} fi-estabel
                   {&ttTarget}.cod-rota     = INPUT FRAME {&FRAME-NAME} fi-rota
                   {&ttTarget}.nome-abrev   = {&ttSource}.nome-abrev
                   {&ttTarget}.cod-entrega  = {&ttSource}.cod-entrega
                   {&ttTarget}.nr-sequencia = i-seq.

            FIND FIRST {&ttTarget}-remove
                 WHERE {&ttTarget}-remove.cod-estabel = {&ttTarget}.cod-estabel
                   AND {&ttTarget}-remove.cod-rota    = {&ttTarget}.cod-rota   
                   AND {&ttTarget}-remove.nome-abrev  = {&ttTarget}.nome-abrev 
                   AND {&ttTarget}-remove.cod-entrega = {&ttTarget}.cod-entrega NO-ERROR.

            /* Elimina registro auxiliar */
            IF AVAIL {&ttTarget}-remove THEN
                DELETE {&ttTarget}-remove.

            /* Cria registro associado ao browse origem */
            DELETE {&ttSource}.       
        END.

        /*--- Abre a query associada aos browser's ---*/
        {&OPEN-QUERY-brSource}
        APPLY "VALUE-CHANGED":U TO BROWSE brSource.  
        {&OPEN-QUERY-brTarget}
        APPLY "VALUE-CHANGED":U TO BROWSE brTarget.  

        ASSIGN l-alterado = YES.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAddTarget
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddTarget wWindow
ON CHOOSE OF btAddTarget IN FRAME fpage0
DO:
    IF AVAIL {&ttSource} THEN DO:

        /* Busca £ltima sequància */
        ASSIGN i-seq = 0.
        FOR LAST bf-{&ttTarget} NO-LOCK
              BY bf-{&ttTarget}.cod-estabel 
              BY bf-{&ttTarget}.cod-rota    
              BY bf-{&ttTarget}.nr-sequencia:
            ASSIGN i-seq = bf-{&ttTarget}.nr-sequencia.
        END.

        /* Cria registro associado ao browse destino */
        CREATE {&ttTarget}.
        ASSIGN i-seq                    = i-seq + 1
               r-rowid-target           = ROWID({&ttTarget})
               {&ttTarget}.r-rowid      = ROWID({&ttTarget})
               {&ttTarget}.cod-estabel  = INPUT FRAME {&FRAME-NAME} fi-estabel
               {&ttTarget}.cod-rota     = INPUT FRAME {&FRAME-NAME} fi-rota
               {&ttTarget}.nome-abrev   = {&ttSource}.nome-abrev
               {&ttTarget}.cod-entrega  = {&ttSource}.cod-entrega
               {&ttTarget}.nr-sequencia = i-seq.

        FIND FIRST {&ttTarget}-remove
             WHERE {&ttTarget}-remove.cod-estabel = {&ttTarget}.cod-estabel
               AND {&ttTarget}-remove.cod-rota    = {&ttTarget}.cod-rota   
               AND {&ttTarget}-remove.nome-abrev  = {&ttTarget}.nome-abrev 
               AND {&ttTarget}-remove.cod-entrega = {&ttTarget}.cod-entrega NO-ERROR.

        /* Elimina registro auxiliar */
        IF AVAIL {&ttTarget}-remove THEN
            DELETE {&ttTarget}-remove.

        /* Elimina registro associado ao browse origem */
        DELETE {&ttSource}.

        /*--- Abre a query associada aos browser's ---*/
        {&OPEN-QUERY-brSource}
        APPLY "VALUE-CHANGED":U TO BROWSE brSource. 
        {&OPEN-QUERY-brTarget}
        APPLY "VALUE-CHANGED":U TO BROWSE brTarget.  

        /* Posiciona o grid no registro alterado. */
        FIND FIRST {&ttTarget}
             WHERE {&ttTarget}.r-rowid = r-rowid-target NO-LOCK NO-ERROR.

        IF AVAIL {&ttTarget} THEN
            REPOSITION brTarget TO ROWID ROWID({&ttTarget}).

        ASSIGN l-alterado = YES.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btBusca
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btBusca wWindow
ON CHOOSE OF btBusca IN FRAME fpage0
DO:
    FIND FIRST {&ttSource}
         WHERE {&ttSource}.nome-abrev = INPUT FRAME {&FRAME-NAME} fi-busca-cli NO-LOCK NO-ERROR.

    IF AVAIL {&ttSource} THEN
        REPOSITION brSource TO ROWID ROWID({&ttSource}).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    RUN pi-validarAlteracao.
    IF RETURN-VALUE = "OK":U THEN
        APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCheck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCheck wWindow
ON CHOOSE OF btCheck IN FRAME fpage0
DO:
    ASSIGN INPUT FRAME fPage0 fi-estabel
           INPUT FRAME fPage0 fi-rota
           INPUT FRAME fPage0 fi-des-estabel
           INPUT FRAME fPage0 fi-des-rota.

    IF c-cod-estabel <> fi-estabel OR
       c-cod-rota    <> fi-rota    THEN DO:

        RUN pi-validarCampos.

        IF RETURN-VALUE = "OK":U THEN DO: 
            RUN pi-enableButtons(YES).
            RUN pi-carregarTarget.
            RUN pi-carregarSource.

            ASSIGN l-check      = YES
                   fi-busca-cli = "":U.
            
            DISPLAY fi-busca-cli
                WITH FRAME {&FRAME-NAME}.

            ASSIGN c-cod-estabel = fi-estabel
                   c-cod-rota    = fi-rota
                   c-des-estabel = fi-des-estabel
                   c-des-rota    = fi-des-rota.
        END.
        ELSE DO:
            IF NOT(l-alterado) THEN DO:
                RUN pi-enableButtons(NO).
    
                EMPTY TEMP-TABLE {&ttSource}.
                EMPTY TEMP-TABLE {&ttTarget}.
    
                ASSIGN l-check = NO.
    
                /*--- Abre a query associada aos browser's ---*/
                {&OPEN-QUERY-brSource}
                APPLY "VALUE-CHANGED":U TO BROWSE brSource. 
                {&OPEN-QUERY-brTarget}
                APPLY "VALUE-CHANGED":U TO BROWSE brTarget.

                ASSIGN c-cod-estabel = ""
                       c-cod-rota    = ""
                       c-des-estabel = ""
                       c-des-rota    = "".
            END.
        END.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDelAllTarget
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelAllTarget wWindow
ON CHOOSE OF btDelAllTarget IN FRAME fpage0
DO:
    IF CAN-FIND(FIRST {&ttTarget}) THEN DO:

        FOR EACH {&ttTarget} NO-LOCK:
            IF NOT CAN-FIND(FIRST {&ttTarget}-remove
                            WHERE {&ttTarget}-remove.cod-estabel = {&ttTarget}.cod-estabel
                              AND {&ttTarget}-remove.cod-rota    = {&ttTarget}.cod-rota   
                              AND {&ttTarget}-remove.nome-abrev  = {&ttTarget}.nome-abrev 
                              AND {&ttTarget}-remove.cod-entrega = {&ttTarget}.cod-entrega) THEN DO:
    
                /* Cria registro auxiliar para eliminaá∆o do banco de dados posteriormente */
                CREATE {&ttTarget}-remove.
                ASSIGN {&ttTarget}-remove.cod-estabel  = {&ttTarget}.cod-estabel 
                       {&ttTarget}-remove.cod-rota     = {&ttTarget}.cod-rota    
                       {&ttTarget}-remove.nome-abrev   = {&ttTarget}.nome-abrev  
                       {&ttTarget}-remove.cod-entrega  = {&ttTarget}.cod-entrega.
            END.

            /* Cria registro associado ao browse origem */
            CREATE {&ttSource}.
            ASSIGN {&ttSource}.cod-rota    = {&ttTarget}.cod-rota
                   {&ttSource}.nome-abrev  = {&ttTarget}.nome-abrev
                   {&ttSource}.cod-entrega = {&ttTarget}.cod-entrega.

            /* Elimina registro associado ao browse destino */
            DELETE {&ttTarget}.
        END.

        /*--- Abre a query associada ao browse destino ---*/
        {&OPEN-QUERY-brTarget}
        APPLY "VALUE-CHANGED":U TO BROWSE brTarget.  
        /*--- Abre a query associada ao browse origem ---*/
        {&OPEN-QUERY-brSource}
        APPLY "VALUE-CHANGED":U TO BROWSE brSource.

        ASSIGN l-alterado = YES.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDelTarget
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelTarget wWindow
ON CHOOSE OF btDelTarget IN FRAME fpage0
DO:
    IF AVAIL {&ttTarget} THEN DO:
        IF NOT CAN-FIND(FIRST {&ttTarget}-remove
                        WHERE {&ttTarget}-remove.cod-estabel = {&ttTarget}.cod-estabel
                          AND {&ttTarget}-remove.cod-rota    = {&ttTarget}.cod-rota   
                          AND {&ttTarget}-remove.nome-abrev  = {&ttTarget}.nome-abrev 
                          AND {&ttTarget}-remove.cod-entrega = {&ttTarget}.cod-entrega) THEN DO:

            /* Cria registro auxiliar para eliminaá∆o do banco de dados posteriormente */
            CREATE {&ttTarget}-remove.
            ASSIGN {&ttTarget}-remove.cod-estabel  = {&ttTarget}.cod-estabel 
                   {&ttTarget}-remove.cod-rota     = {&ttTarget}.cod-rota    
                   {&ttTarget}-remove.nome-abrev   = {&ttTarget}.nome-abrev  
                   {&ttTarget}-remove.cod-entrega  = {&ttTarget}.cod-entrega.
        END.

        /* Cria registro associado ao browse origem */
        CREATE {&ttSource}.
        ASSIGN {&ttSource}.cod-rota    = {&ttTarget}.cod-rota
               {&ttSource}.nome-abrev  = {&ttTarget}.nome-abrev
               {&ttSource}.cod-entrega = {&ttTarget}.cod-entrega.

        /* Elimina Registro Target */
        DELETE {&ttTarget}.

        /* Atualizar Sequància */
        ASSIGN i-seq = 0.
        FOR EACH bf-{&ttTarget}
              BY bf-{&ttTarget}.cod-estabel
              BY bf-{&ttTarget}.cod-rota
              BY bf-{&ttTarget}.nr-sequencia:
            ASSIGN i-seq                       = i-seq + 1
                   bf-{&ttTarget}.nr-sequencia = i-seq.
        END.
        
        /*--- Abre a query associada ao browse destino ---*/
        {&OPEN-QUERY-brTarget}
        APPLY "VALUE-CHANGED":U TO BROWSE brTarget.  
        /*--- Abre a query associada ao browse origem ---*/
        {&OPEN-QUERY-brSource}
        APPLY "VALUE-CHANGED":U TO BROWSE brSource.

        ASSIGN l-alterado = YES.        
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDown
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDown wWindow
ON CHOOSE OF btDown IN FRAME fpage0
DO:
    IF AVAIL {&ttTarget} THEN DO:   
        ASSIGN r-rowid-target = {&ttTarget}.r-rowid
               i-seq          = {&ttTarget}.nr-sequencia.

        FOR EACH bf-{&ttTarget} NO-LOCK
              BY bf-{&ttTarget}.cod-estabel 
              BY bf-{&ttTarget}.cod-rota    
              BY bf-{&ttTarget}.nr-sequencia:

            IF (i-seq + 1) = bf-{&ttTarget}.nr-sequencia THEN DO:
                ASSIGN bf-{&ttTarget}.nr-sequencia = i-seq
                       {&ttTarget}.nr-sequencia    = i-seq + 1.
            END.
        END.

        /*--- Abre a query associada ao browse destino ---*/
        {&OPEN-QUERY-brTarget}

        /* Posiciona o grid no registro movimentado. */
        FIND FIRST {&ttTarget}
             WHERE {&ttTarget}.r-rowid = r-rowid-target NO-LOCK NO-ERROR.

        IF AVAIL {&ttTarget} THEN
            REPOSITION brTarget TO ROWID ROWID({&ttTarget}).

        ASSIGN l-alterado = YES.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    RUN pi-validarAlteracao.
    IF RETURN-VALUE = "OK":U THEN
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


&Scoped-define SELF-NAME btModifica
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btModifica wWindow
ON CHOOSE OF btModifica IN FRAME fpage0
DO:    
    IF AVAIL {&ttTarget} THEN DO:
        ASSIGN {&WINDOW-NAME}:SENSITIVE = NO.

        ASSIGN r-rowid-target = {&ttTarget}.r-rowid.

        RUN eqp/eq0513a.w (INPUT {&ttTarget}.r-rowid,
                           INPUT {&ttTarget}.cod-estabel,
                           INPUT {&ttTarget}.cod-rota,
                           INPUT-OUTPUT TABLE {&ttSource},
                           INPUT-OUTPUT TABLE {&ttTarget},
                           OUTPUT l-ok).
         
        IF l-ok THEN
            ASSIGN l-alterado = YES.

        ASSIGN {&WINDOW-NAME}:SENSITIVE = YES.

        /*--- Abre a query associada aos browser's ---*/
        {&OPEN-QUERY-brSource}
        {&OPEN-QUERY-brTarget}

        /* Posiciona o grid no registro alterado. */
        FIND FIRST {&ttTarget}
             WHERE {&ttTarget}.r-rowid = r-rowid-target NO-LOCK NO-ERROR.

        IF AVAIL {&ttTarget} THEN
            REPOSITION brTarget TO ROWID ROWID({&ttTarget}).
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btNovo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btNovo wWindow
ON CHOOSE OF btNovo IN FRAME fpage0
DO:
    ASSIGN {&WINDOW-NAME}:SENSITIVE = NO.

    RUN eqp/eq0513a.w (INPUT ?,
                       INPUT FRAME {&FRAME-NAME} fi-estabel,
                       INPUT FRAME {&FRAME-NAME} fi-rota,
                       INPUT-OUTPUT TABLE {&ttSource},
                       INPUT-OUTPUT TABLE {&ttTarget},
                       OUTPUT l-ok).
    IF l-ok THEN
        ASSIGN l-alterado = YES.
        
    ASSIGN {&WINDOW-NAME}:SENSITIVE = YES.       

    /*--- Abre a query associada aos browser's ---*/
    {&OPEN-QUERY-brSource}
    APPLY "VALUE-CHANGED":U TO BROWSE brSource.
    {&OPEN-QUERY-brTarget}
    APPLY "VALUE-CHANGED":U TO BROWSE brTarget.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* Salvar */
DO:
    RUN pi-salvarTarget.
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


&Scoped-define SELF-NAME btUp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUp wWindow
ON CHOOSE OF btUp IN FRAME fpage0
DO:
    IF AVAIL {&ttTarget} THEN DO:   
        ASSIGN r-rowid-target = {&ttTarget}.r-rowid
               i-seq          = {&ttTarget}.nr-sequencia.

        FOR EACH bf-{&ttTarget} NO-LOCK
              BY bf-{&ttTarget}.cod-estabel 
              BY bf-{&ttTarget}.cod-rota    
              BY bf-{&ttTarget}.nr-sequencia:

            IF (i-seq - 1) = bf-{&ttTarget}.nr-sequencia THEN DO:
                ASSIGN bf-{&ttTarget}.nr-sequencia = i-seq
                       {&ttTarget}.nr-sequencia    = i-seq - 1.
            END.
        END.

        /*--- Abre a query associada ao browse destino ---*/
        {&OPEN-QUERY-brTarget}

        /* Posiciona o grid no registro movimentado. */
        FIND FIRST {&ttTarget}
             WHERE {&ttTarget}.r-rowid = r-rowid-target NO-LOCK NO-ERROR.

        IF AVAIL {&ttTarget} THEN
            REPOSITION brTarget TO ROWID ROWID({&ttTarget}).

        ASSIGN l-alterado = YES.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-estabel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-estabel wWindow
ON F5 OF fi-estabel IN FRAME fpage0 /* Estabelecimento */
DO:
    {include/zoomvar.i &prog-zoom="adzoom\z01ad107.w"
                       &campo=fi-estabel
                       &campozoom=cod-estabel}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-estabel wWindow
ON LEAVE OF fi-estabel IN FRAME fpage0 /* Estabelecimento */
DO:
    FIND FIRST estabelec
         WHERE estabelec.cod-estabel = fi-estabel:SCREEN-VALUE IN FRAME {&FRAME-NAME} NO-LOCK NO-ERROR.
  
    IF AVAIL estabelec THEN
        ASSIGN fi-des-estabel:SCREEN-VALUE IN FRAME {&FRAME-NAME} = estabelec.nome.
    ELSE
        ASSIGN fi-des-estabel:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "".

    IF l-check THEN
        APPLY "CHOOSE":U TO btCheck IN FRAME fPage0.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-estabel wWindow
ON MOUSE-SELECT-DBLCLICK OF fi-estabel IN FRAME fpage0 /* Estabelecimento */
DO:
    APPLY "F5":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-rota
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-rota wWindow
ON F5 OF fi-rota IN FRAME fpage0 /* Rota */
DO:
    ASSIGN l-implanta = NO.
    {include/zoomvar.i &prog-zoom= "dizoom/z01di181.w"
                       &campo=fi-rota
                       &campozoom= cod-rota}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-rota wWindow
ON LEAVE OF fi-rota IN FRAME fpage0 /* Rota */
DO:
    FIND FIRST rota 
         WHERE rota.cod-rota = fi-rota:SCREEN-VALUE IN FRAME {&FRAME-NAME} NO-LOCK NO-ERROR.
    
    IF AVAIL rota THEN
        ASSIGN fi-des-rota:SCREEN-VALUE IN FRAME {&FRAME-NAME} = rota.descricao.
    ELSE 
        ASSIGN fi-des-rota:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "".

    IF l-check THEN
        APPLY "CHOOSE":U TO btCheck IN FRAME fPage0.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-rota wWindow
ON MOUSE-SELECT-DBLCLICK OF fi-rota IN FRAME fpage0 /* Rota */
DO:
    APPLY "F5":U TO SELF.
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


&Scoped-define BROWSE-NAME brSource
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializaá∆o do programam ---*/
IF fi-estabel:LOAD-MOUSE-POINTER ("image~\lupa.cur") IN FRAME {&FRAME-NAME} THEN.
IF fi-rota:LOAD-MOUSE-POINTER ("image~\lupa.cur")    IN FRAME {&FRAME-NAME} THEN.

{window/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDestroyInterface wWindow 
PROCEDURE afterDestroyInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    IF VALID-HANDLE(hDBOTarget) THEN
        DELETE PROCEDURE hDBOTarget.

    /*--- Elimina Janela de mensagens de erros ---*/
    {method/showmessage.i3}

    /* Desativa Seguranáa por Estabelecimento */
    {cdp/cd0019.i1 "MEQ"}

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wWindow 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    RUN pi-enableButtons(NO).
    RUN initializeDBOs.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializeDBOs wWindow 
PROCEDURE initializeDBOs :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /*:T--- Verifica se o DBO da tabela Formaá∆o j† est† inicializado ---*/
    IF NOT VALID-HANDLE(hDBOTarget) OR
        hDBOTarget:TYPE <> "PROCEDURE":U OR
        hDBOTarget:FILE-NAME <> "dibo/bodi784.p":U THEN DO:
        RUN dibo/bodi784.p PERSISTENT SET hDBOTarget.
    END.

    APPLY "LEAVE" TO fi-estabel IN FRAME {&FRAME-NAME}. 

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carregarSource wWindow 
PROCEDURE pi-carregarSource :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    EMPTY TEMP-TABLE {&ttSource}.

    /*--- Seta cursor do mouse para espera ---*/
    SESSION:SET-WAIT-STATE("GENERAL":U).

    /* Retorna todos os locais de entrega da rota informada */
    RUN getLocEntrByRota IN hDBOTarget (INPUT INPUT FRAME {&FRAME-NAME} fi-estabel,
                                        INPUT INPUT FRAME {&FRAME-NAME} fi-rota,
                                        INPUT  TABLE {&ttTarget},
                                        OUTPUT TABLE {&ttSource}).

    /*--- Seta cursor do mouse para normal ---*/
    SESSION:SET-WAIT-STATE("":U).

    /*--- Abre a query associada ao browse origem ---*/
    {&OPEN-QUERY-brSource}
    APPLY "VALUE-CHANGED":U TO BROWSE brSource.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carregarTarget wWindow 
PROCEDURE pi-carregarTarget :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iRowsReturned AS INTEGER NO-UNDO.

    EMPTY TEMP-TABLE {&ttTarget}.
    
    RUN setConstraintEstabRota IN hDBOTarget (INPUT FRAME {&FRAME-NAME} fi-estabel,
                                              INPUT FRAME {&FRAME-NAME} fi-rota).

    RUN openQueryStatic IN hDBOTarget ("EstabRota":U).
    RUN emptyRowErrors  IN hDBOTarget.

    /*--- Posiciona DBO primeiro registro ---*/
    RUN getFirst IN hDBOTarget.

    /*--- Seta cursor do mouse para espera ---*/
    SESSION:SET-WAIT-STATE("GENERAL":U).

    /*--- Retorna faixa de registro do DBO ---*/
    RUN getBatchRecords IN hDBOTarget (INPUT ?,
                                       INPUT NO,
                                       INPUT ?,
                                       OUTPUT iRowsReturned,
                                       OUTPUT TABLE {&ttTarget}).

    /*--- Seta cursor do mouse para normal ---*/
    SESSION:SET-WAIT-STATE("":U).

    /*--- Abre a query associada ao browse origem ---*/
    {&OPEN-QUERY-brTarget}
    APPLY "VALUE-CHANGED":U TO BROWSE brTarget.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-enableButtons wWindow 
PROCEDURE pi-enableButtons :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-enable AS LOGICAL NO-UNDO.

    IF p-enable THEN
        ENABLE btAddAllTarget btAddTarget btDelTarget btDelAllTarget
               btNovo btModifica btOK btUp btDown
               fi-busca-cli btBusca
            WITH FRAME {&FRAME-NAME}.
    ELSE
        DISABLE btAddAllTarget btAddTarget btDelTarget btDelAllTarget
                btNovo btModifica btOK btUp btDown
                fi-busca-cli btBusca
            WITH FRAME {&FRAME-NAME}.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-recebeEstabRota wWindow 
PROCEDURE pi-recebeEstabRota :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER p-cod-estabel AS CHARACTER FORMAT "x(5)"  NO-UNDO.
    DEFINE INPUT PARAMETER p-cod-rota    AS CHARACTER FORMAT "x(12)" NO-UNDO.

    ASSIGN fi-estabel = p-cod-estabel
           fi-rota    = p-cod-rota.

    DISPLAY fi-estabel
            fi-rota
        WITH FRAME {&FRAME-NAME}.

    APPLY "LEAVE":U TO fi-estabel IN FRAME {&FRAME-NAME}.
    APPLY "LEAVE":U TO fi-rota    IN FRAME {&FRAME-NAME}.

    APPLY "CHOOSE":U TO btCheck   IN FRAME {&FRAME-NAME}.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-salvarTarget wWindow 
PROCEDURE pi-salvarTarget :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE cReturnAux AS CHARACTER NO-UNDO.

/*--- Seta cursor do mouse para espera ---*/
SESSION:SET-WAIT-STATE("GENERAL":U).

RUN openQueryStatic  IN hDBOTarget ("Main":U).

/*--- Limpa temp-table RowErrors no DBO ---*/
RUN emptyRowErrors   IN hDBOTarget.

AddRecords:
DO TRANSACTION ON ERROR UNDO, LEAVE:

    /* Atualizando */
    FOR EACH {&ttTarget}:

        EMPTY TEMP-TABLE {&ttTarget}-aux.

        CREATE {&ttTarget}-aux.
        BUFFER-COPY {&ttTarget} TO {&ttTarget}-aux.

        RUN goToKey IN hDBOTarget (INPUT {&ttTarget}.cod-estabel,
                                   INPUT {&ttTarget}.cod-rota,
                                   INPUT {&ttTarget}.nome-abrev,
                                   INPUT {&ttTarget}.cod-entrega).

        IF RETURN-VALUE = "NOK":U THEN DO:
            /*--- Transfere temp-table {&ttTarget} para o DBO ---*/
            RUN setRecord    IN hDBOTarget (INPUT TABLE {&ttTarget}-aux).
            RUN createRecord IN hDBOTarget.
        END.
        ELSE DO:
            /*--- Transfere temp-table {&ttTarget} para o DBO ---*/
            RUN setRecord    IN hDBOTarget (INPUT TABLE {&ttTarget}-aux).
            RUN updateRecord IN hDBOTarget.
        END.

        /*--- Atualiza vari†vel cReturnAux com o conte£do do RETURN-VALUE ---*/
        ASSIGN cReturnAux = RETURN-VALUE.

        /*--- Verifica ocorrància de erros durante a gravaá∆o ---*/
        IF cReturnAux = "NOK":U THEN DO:
            /*--- Retorna temp-table RowErrors do DBO ---*/
            RUN getRowErrors IN hDBOTarget (OUTPUT TABLE RowErrors).

            /*--- Inicializa tela de mensagens de erros ---*/
            {method/showmessage.i1}        

            /*--- Seta cursor do mouse para normal ---*/
            SESSION:SET-WAIT-STATE("":U).

            /*--- Transfere temp-table RowErrors para a tela de mensagens de erros ---*/
            {method/showmessage.i2}

            UNDO AddRecords, LEAVE AddRecords.
        END.
        ELSE
            /*--- Elimina Janela de mensagens de erros ---*/
            {method/showmessage.i3}
    END.

    /* Eliminando */
    FOR EACH {&ttTarget}-remove:
      
        RUN goToKey IN hDBOTarget (INPUT {&ttTarget}-remove.cod-estabel,
                                   INPUT {&ttTarget}-remove.cod-rota,
                                   INPUT {&ttTarget}-remove.nome-abrev,
                                   INPUT {&ttTarget}-remove.cod-entrega).

        IF RETURN-VALUE = "OK":U THEN DO:
            RUN deleteRecord IN hDBOTarget.
        END.

        /*--- Atualiza vari†vel cReturnAux com o conte£do do RETURN-VALUE ---*/
        ASSIGN cReturnAux = RETURN-VALUE.

        /*--- Verifica ocorrància de erros durante a gravaá∆o ---*/
        IF cReturnAux = "NOK":U THEN DO:
            /*--- Retorna temp-table RowErrors do DBO ---*/
            RUN getRowErrors IN hDBOTarget (OUTPUT TABLE RowErrors).

            /* Query est† no ultimo registro */
            FOR FIRST RowErrors 
                WHERE RowErrors.ErrorType   = "INTERNAL":U
                  AND RowErrors.ErrorNumber = 10 EXCLUSIVE-LOCK:
                DELETE RowErrors.
            END.

            /* Tabela n∆o dispon°vel */
            FOR FIRST RowErrors 
                WHERE RowErrors.ErrorType   = "INTERNAL":U
                  AND RowErrors.ErrorNumber = 3 EXCLUSIVE-LOCK:
                DELETE RowErrors.
            END.

            /* Query est† vazia */
            FOR FIRST RowErrors 
                WHERE RowErrors.ErrorType   = "INTERNAL":U
                  AND RowErrors.ErrorNumber = 8 EXCLUSIVE-LOCK:
                DELETE RowErrors.
            END.

            IF CAN-FIND (FIRST RowErrors) THEN DO:
                /*--- Inicializa tela de mensagens de erros ---*/
                {method/showmessage.i1}        
    
                /*--- Seta cursor do mouse para normal ---*/
                SESSION:SET-WAIT-STATE("":U).
    
                /*--- Transfere temp-table RowErrors para a tela de mensagens de erros ---*/
                {method/showmessage.i2}
    
                UNDO AddRecords, LEAVE AddRecords.
            END.
        END.
        ELSE
            /*--- Elimina Janela de mensagens de erros ---*/
            {method/showmessage.i3}
    END.

    ASSIGN l-alterado = NO.
END.

SESSION:SET-WAIT-STATE("":U).

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-validarAlteracao wWindow 
PROCEDURE pi-validarAlteracao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    IF l-alterado THEN DO:
        {utp/ut-liter.i "Alteraá‰es no sequenciamento da Rota ser∆o perdidas. Deseja continuar?"}
        ASSIGN cAux = RETURN-VALUE.
        {utp/ut-liter.i "Se for confirmado, as manutená‰es realizadas n∆o ser∆o atualizadas, voltando a situaá∆o anterior as alteraá‰es."}
        ASSIGN cAux2 = RETURN-VALUE.

        RUN utp/ut-msgs.p (INPUT "SHOW",
                           INPUT 28084,
                           INPUT cAux + "~~" + cAux2).

        IF RETURN-VALUE = "YES":U THEN
            ASSIGN l-alterado = NO.
        ELSE DO:
            ASSIGN fi-estabel     = c-cod-estabel 
                   fi-rota        = c-cod-rota
                   fi-des-estabel = c-des-estabel
                   fi-des-rota    = c-des-rota.

            DISP fi-estabel
                 fi-rota
                 fi-des-estabel
                 fi-des-rota
                WITH FRAME {&FRAME-NAME}.

            RETURN "NOK":U.
        END.
    END.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-validarCampos wWindow 
PROCEDURE pi-validarCampos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    RUN pi-validarAlteracao.
    IF RETURN-VALUE = "NOK":U THEN
        RETURN "NOK":U.

    IF INPUT FRAME {&FRAME-NAME} fi-estabel = "" THEN DO:
        {utp/ut-liter.i "Estabelecimento"}
        RUN utp/ut-msgs.p (INPUT "SHOW",
                           INPUT 5793,
                           INPUT RETURN-VALUE).

        RETURN "NOK":U.
    END.
    ELSE DO:
        IF NOT CAN-FIND(FIRST estabelec
                        WHERE estabelec.cod-estabel = INPUT FRAME {&FRAME-NAME} fi-estabel) THEN DO:
            RUN utp/ut-msgs.p (INPUT "SHOW",
                               INPUT 537,
                               INPUT "").
            RETURN "NOK":U.
        END.
    END.

    IF INPUT FRAME {&FRAME-NAME} fi-rota = "" THEN DO:
        {utp/ut-liter.i "Rota"}
        RUN utp/ut-msgs.p (INPUT "SHOW",
                           INPUT 3145,
                           INPUT RETURN-VALUE).
        RETURN "NOK":U.
    END.
    ELSE DO:
        IF NOT CAN-FIND(FIRST rota
                        WHERE rota.cod-rota = INPUT FRAME {&FRAME-NAME} fi-rota) THEN DO:
            {utp/ut-liter.i "Rota"}
            RUN utp/ut-msgs.p (INPUT "SHOW",
                               INPUT 5366,
                               INPUT RETURN-VALUE).
            RETURN "NOK":U.
        END.
    END.

    IF NOT CAN-FIND(FIRST loc-entr
                    WHERE loc-entr.cod-rota = INPUT FRAME {&FRAME-NAME} fi-rota) THEN DO:
        {utp/ut-liter.i "Local de Entrega"}
        ASSIGN cAux = RETURN-VALUE.
        {utp/ut-liter.i "a Rota informada"}
        ASSIGN cAux2 = RETURN-VALUE.

        RUN utp/ut-msgs.p (INPUT "SHOW",
                           INPUT 17923,
                           INPUT cAux + "~~" + cAux2).
        RETURN "NOK":U.
    END.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

