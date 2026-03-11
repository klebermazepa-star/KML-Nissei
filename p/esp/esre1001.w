&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
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
{include/i-prgvrs.i ESRE1001 2.00.01.GCJ}

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        ESRE1001
&GLOBAL-DEFINE Version        2.00.01.GCJ

&GLOBAL-DEFINE WindowType     Master
&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   

&GLOBAL-DEFINE page0Widgets   btFiltro btQueryJoins btReportsJoins btExit btHelp ~
                              
&GLOBAL-DEFINE page1Widgets   
&GLOBAL-DEFINE page2Widgets   

&GLOBAL-DEFINE EXCLUDE-translate     YES
&GLOBAL-DEFINE EXCLUDE-translateMenu YES


/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE i-seq-aux       AS INTEGER     NO-UNDO.
DEFINE VARIABLE i-seq-dup-aux   AS INTEGER     NO-UNDO.
DEFINE VARIABLE c-nro-docto-aux AS CHARACTER   NO-UNDO.
DEFINE VARIABLE preco-total-aux AS DECIMAL     NO-UNDO.

DEF TEMP-TABLE tt-param NO-UNDO
    FIELD situacao AS INT INITIAL 1
    FIELD dt-valid-ini AS DATE   INIT 01/01/0001
    FIELD dt-valid-fim AS DATE   INIT 12/31/2099
    FIELD cod-estabel-ini AS CHAR
    FIELD cod-estabel-fim AS CHAR INIT "ZZZ"
    FIELD nr-contrato-ini AS INT
    FIELD nr-contrato-fim AS INT INIT 9999999
    .


DEF TEMP-TABLE tt-es-contrato-docum-aux NO-UNDO
    LIKE es-contrato-docum
    FIELD r-rowid AS ROWID.

DEF TEMP-TABLE tt-es-contrato-docum NO-UNDO
    LIKE es-contrato-docum
    FIELD dt-vencimento AS DATE
    FIELD r-rowid AS ROWID
    FIELD id-selecionado AS LOG
    .

DEF BUFFER bf-tt-es-contrato-docum FOR tt-es-contrato-docum.
DEF TEMP-TABLE tt-es-contrato-docum-selecionado NO-UNDO
    LIKE es-contrato-docum
    FIELD r-rowid AS ROWID
    FIELD id-selecionado AS LOG
    .


DEF BUFFER bf-es-contrato-docum FOR es-contrato-docum.


DEF TEMP-TABLE tt-es-contrato-docum-dup-aux NO-UNDO
    LIKE es-contrato-docum-dup
    FIELD r-rowid AS ROWID.

DEF TEMP-TABLE tt-es-contrato-docum-dup NO-UNDO
    LIKE es-contrato-docum-dup
    FIELD r-rowid AS ROWID.

DEF BUFFER bf-es-contrato-docum-dup FOR es-contrato-docum-dup.

DEF TEMP-TABLE tt-es-contrato-docum-imp-aux NO-UNDO
    LIKE es-contrato-docum-imp
    FIELD r-rowid AS ROWID.

DEF TEMP-TABLE tt-es-contrato-docum-imp NO-UNDO
    LIKE es-contrato-docum-imp
    FIELD r-rowid AS ROWID.

DEF BUFFER bf-es-contrato-docum-imp FOR es-contrato-docum-imp.

    def temp-table tt-erro no-undo
        field i-sequen as int             
        field cd-erro  as int
        field mensagem as char format "x(255)".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brTable1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-es-contrato-docum ~
tt-es-contrato-docum-dup tt-es-contrato-docum-imp

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 tt-es-contrato-docum.id-selecionado tt-es-contrato-docum.sequencia tt-es-contrato-docum.num-pedido tt-es-contrato-docum.nr-contrato tt-es-contrato-docum.cod-emitente tt-es-contrato-docum.serie-docto tt-es-contrato-docum.nro-docto tt-es-contrato-docum.it-codigo tt-es-contrato-docum.preco-total tt-es-contrato-docum.nat-operacao tt-es-contrato-docum.cod-estabel tt-es-contrato-docum.dt-vencimento tt-es-contrato-docum.dt-integracao   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH tt-es-contrato-docum
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME} FOR EACH tt-es-contrato-docum.
&Scoped-define TABLES-IN-QUERY-brTable1 tt-es-contrato-docum
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 tt-es-contrato-docum


/* Definitions for BROWSE brTable2                                      */
&Scoped-define FIELDS-IN-QUERY-brTable2 tt-es-contrato-docum-dup.seq-dup tt-es-contrato-docum-dup.parcela tt-es-contrato-docum-dup.nr-duplic tt-es-contrato-docum-dup.cod-esp tt-es-contrato-docum-dup.tp-despesa tt-es-contrato-docum-dup.dt-emissao tt-es-contrato-docum-dup.dt-trans tt-es-contrato-docum-dup.dt-vencim tt-es-contrato-docum-dup.vl-a-pagar tt-es-contrato-docum-dup.desconto tt-es-contrato-docum-dup.vl-desconto tt-es-contrato-docum-dup.dt-venc-desc   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable2   
&Scoped-define SELF-NAME brTable2
&Scoped-define QUERY-STRING-brTable2 FOR EACH tt-es-contrato-docum-dup
&Scoped-define OPEN-QUERY-brTable2 OPEN QUERY {&SELF-NAME} FOR EACH tt-es-contrato-docum-dup.
&Scoped-define TABLES-IN-QUERY-brTable2 tt-es-contrato-docum-dup
&Scoped-define FIRST-TABLE-IN-QUERY-brTable2 tt-es-contrato-docum-dup


/* Definitions for BROWSE brTable3                                      */
&Scoped-define FIELDS-IN-QUERY-brTable3 tt-es-contrato-docum-imp.sequencia tt-es-contrato-docum-imp.seq-dup tt-es-contrato-docum-imp.seq-imp tt-es-contrato-docum-imp.cod-imposto tt-es-contrato-docum-imp.cod-esp tt-es-contrato-docum-imp.serie tt-es-contrato-docum-imp.nro-docto-imp tt-es-contrato-docum-imp.parcela-imp tt-es-contrato-docum-imp.cod-retencao tt-es-contrato-docum-imp.dt-venc-imp tt-es-contrato-docum-imp.rend-trib round(tt-es-contrato-docum-imp.aliquota ,2) tt-es-contrato-docum-imp.vl-imposto tt-es-contrato-docum-imp.tp-codigo   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable3   
&Scoped-define SELF-NAME brTable3
&Scoped-define QUERY-STRING-brTable3 FOR EACH tt-es-contrato-docum-imp
&Scoped-define OPEN-QUERY-brTable3 OPEN QUERY {&SELF-NAME} FOR EACH tt-es-contrato-docum-imp.
&Scoped-define TABLES-IN-QUERY-brTable3 tt-es-contrato-docum-imp
&Scoped-define FIRST-TABLE-IN-QUERY-brTable3 tt-es-contrato-docum-imp


/* Definitions for FRAME fpage0                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fpage0 ~
    ~{&OPEN-QUERY-brTable1}~
    ~{&OPEN-QUERY-brTable2}~
    ~{&OPEN-QUERY-brTable3}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 RECT-1 btQueryJoins ~
btReportsJoins btExit btHelp btGerar btFiltro btPeriodo c-periodo brTable1 ~
btAdd btUpdate btDelete btSelTodos btDeselTodos brTable3 brTable2 btAdd3 ~
btUpdate3 btDelete3 btAdd2 btUpdate2 btDelete2 btGeraImpto 
&Scoped-Define DISPLAYED-OBJECTS c-periodo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btAdd 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btAdd2 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btAdd3 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btDelete 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btDelete2 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btDelete3 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeselTodos 
     LABEL "Deselecionar todos" 
     SIZE 15 BY 1.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btFiltro 
     IMAGE-UP FILE "image\im-fil.gif":U
     LABEL "" 
     SIZE 4 BY 1.13 TOOLTIP "Parƒmetros".

DEFINE BUTTON btGeraImpto 
     LABEL "Gera Impto" 
     SIZE 10 BY 1.

DEFINE BUTTON btGerar 
     IMAGE-UP FILE "image/im-run.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-run.bmp":U
     LABEL "Gerar" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btPeriodo 
     IMAGE-UP FILE "image\im-sav":U
     IMAGE-INSENSITIVE FILE "image\ii-sav":U
     LABEL "Save" 
     SIZE 4 BY 1.25
     FONT 4.

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

DEFINE BUTTON btSelTodos 
     LABEL "Selecionar todos" 
     SIZE 15 BY 1.

DEFINE BUTTON btUpdate 
     LABEL "Alterar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdate2 
     LABEL "Alterar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdate3 
     LABEL "Alterar" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-periodo AS CHARACTER FORMAT "xx/xxxx" 
     LABEL "Per¡odo" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88
     BGCOLOR 15 .

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 2.

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 164 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      tt-es-contrato-docum SCROLLING.

DEFINE QUERY brTable2 FOR 
      tt-es-contrato-docum-dup SCROLLING.

DEFINE QUERY brTable3 FOR 
      tt-es-contrato-docum-imp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      tt-es-contrato-docum.id-selecionado FORMAT "SIM/NAO"  COLUMN-LABEL "Selecionado"          
 tt-es-contrato-docum.sequencia           
 tt-es-contrato-docum.num-pedido          
 tt-es-contrato-docum.nr-contrato         
 tt-es-contrato-docum.cod-emitente        
 tt-es-contrato-docum.serie-docto         
 tt-es-contrato-docum.nro-docto  

 tt-es-contrato-docum.it-codigo           
 tt-es-contrato-docum.preco-total           
 tt-es-contrato-docum.nat-operacao        
 tt-es-contrato-docum.cod-estabel
 tt-es-contrato-docum.dt-vencimento COLUMN-LABEL "Dt Vencim"   
 tt-es-contrato-docum.dt-integracao
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-SCROLLBAR-VERTICAL SIZE 159.72 BY 10.21
         FONT 2 FIT-LAST-COLUMN.

DEFINE BROWSE brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable2 wWindow _FREEFORM
  QUERY brTable2 DISPLAY
      tt-es-contrato-docum-dup.seq-dup

tt-es-contrato-docum-dup.parcela       


tt-es-contrato-docum-dup.nr-duplic     
tt-es-contrato-docum-dup.cod-esp       
tt-es-contrato-docum-dup.tp-despesa    
tt-es-contrato-docum-dup.dt-emissao    
tt-es-contrato-docum-dup.dt-trans      
tt-es-contrato-docum-dup.dt-vencim     
tt-es-contrato-docum-dup.vl-a-pagar    
tt-es-contrato-docum-dup.desconto      
tt-es-contrato-docum-dup.vl-desconto   
tt-es-contrato-docum-dup.dt-venc-desc
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-SCROLLBAR-VERTICAL SIZE 70 BY 10.21
         FONT 2 FIT-LAST-COLUMN.

DEFINE BROWSE brTable3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable3 wWindow _FREEFORM
  QUERY brTable3 DISPLAY
      tt-es-contrato-docum-imp.sequencia     
tt-es-contrato-docum-imp.seq-dup       
tt-es-contrato-docum-imp.seq-imp
                                           
tt-es-contrato-docum-imp.cod-imposto   
tt-es-contrato-docum-imp.cod-esp       
tt-es-contrato-docum-imp.serie         
tt-es-contrato-docum-imp.nro-docto-imp 
tt-es-contrato-docum-imp.parcela-imp   
tt-es-contrato-docum-imp.cod-retencao  
tt-es-contrato-docum-imp.dt-venc-imp   
tt-es-contrato-docum-imp.rend-trib     
round(tt-es-contrato-docum-imp.aliquota      ,2) 
tt-es-contrato-docum-imp.vl-imposto    
tt-es-contrato-docum-imp.tp-codigo
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-SCROLLBAR-VERTICAL SIZE 70 BY 10.21
         FONT 2 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 147.43 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 151.43 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 155.43 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 159.43 HELP
          "Ajuda"
     btGerar AT ROW 1.17 COL 3.29 HELP
          "Confirma altera‡äes" WIDGET-ID 28
     btFiltro AT ROW 1.17 COL 7.43 WIDGET-ID 38
     btPeriodo AT ROW 3.25 COL 23.14 HELP
          "Confirma altera‡äes" WIDGET-ID 10
     c-periodo AT ROW 3.5 COL 8 COLON-ALIGNED WIDGET-ID 14
     brTable1 AT ROW 5.04 COL 3 WIDGET-ID 200
     btAdd AT ROW 15.38 COL 3 WIDGET-ID 8
     btUpdate AT ROW 15.38 COL 13 WIDGET-ID 36
     btDelete AT ROW 15.38 COL 23 WIDGET-ID 18
     btSelTodos AT ROW 15.38 COL 33 WIDGET-ID 40
     btDeselTodos AT ROW 15.38 COL 48 WIDGET-ID 42
     brTable3 AT ROW 17.25 COL 91 WIDGET-ID 400
     brTable2 AT ROW 17.5 COL 3 WIDGET-ID 300
     btAdd3 AT ROW 27.58 COL 91 WIDGET-ID 24
     btUpdate3 AT ROW 27.58 COL 101 WIDGET-ID 32
     btDelete3 AT ROW 27.58 COL 111 WIDGET-ID 26
     btAdd2 AT ROW 27.83 COL 3 WIDGET-ID 20
     btUpdate2 AT ROW 27.83 COL 13 WIDGET-ID 34
     btDelete2 AT ROW 27.83 COL 23 WIDGET-ID 22
     btGeraImpto AT ROW 27.83 COL 33 WIDGET-ID 30
     rtToolBar-2 AT ROW 1 COL 1
     RECT-1 AT ROW 2.88 COL 3 WIDGET-ID 16
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 164.29 BY 28.17
         FONT 1 WIDGET-ID 100.


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
         HEIGHT             = 28.17
         WIDTH              = 164.29
         MAX-HEIGHT         = 29.33
         MAX-WIDTH          = 164.29
         VIRTUAL-HEIGHT     = 29.33
         VIRTUAL-WIDTH      = 164.29
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
/* BROWSE-TAB brTable1 c-periodo fpage0 */
/* BROWSE-TAB brTable3 btDeselTodos fpage0 */
/* BROWSE-TAB brTable2 brTable3 fpage0 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable1
/* Query rebuild information for BROWSE brTable1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-es-contrato-docum.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable2
/* Query rebuild information for BROWSE brTable2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-es-contrato-docum-dup.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brTable2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable3
/* Query rebuild information for BROWSE brTable3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-es-contrato-docum-imp.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brTable3 */
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
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable1
&Scoped-define SELF-NAME brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTable1 wWindow
ON MOUSE-SELECT-DBLCLICK OF brTable1 IN FRAME fpage0
DO:
    IF AVAIL tt-es-contrato-docum THEN DO:
        IF tt-es-contrato-docum.id-selecionado THEN
           ASSIGN tt-es-contrato-docum.id-selecionado = NO
                  tt-es-contrato-docum.id-selecionado:BGCOLOR IN BROWSE brTable1 = 12
                  tt-es-contrato-docum.id-selecionado:FGCOLOR IN BROWSE brTable1 = 15
                  .
        ELSE
           ASSIGN tt-es-contrato-docum.id-selecionado = YES
                  tt-es-contrato-docum.id-selecionado:BGCOLOR IN BROWSE brTable1 = 10
                  tt-es-contrato-docum.id-selecionado:FGCOLOR IN BROWSE brTable1 = 0
                  .
       DISP tt-es-contrato-docum.id-selecionado WITH BROWSE brTable1.

    END.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTable1 wWindow
ON ROW-DISPLAY OF brTable1 IN FRAME fpage0
DO:
    IF tt-es-contrato-docum.id-selecionado THEN
      ASSIGN 
             tt-es-contrato-docum.id-selecionado:BGCOLOR IN BROWSE brTable1 = 10
             
             tt-es-contrato-docum.id-selecionado:FGCOLOR IN BROWSE brTable1 = 0
             .



    ELSE
      ASSIGN 
             tt-es-contrato-docum.id-selecionado:BGCOLOR IN BROWSE brTable1 = 12
             tt-es-contrato-docum.id-selecionado:FGCOLOR IN BROWSE brTable1 = 15.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTable1 wWindow
ON VALUE-CHANGED OF brTable1 IN FRAME fpage0
DO:
    
    
   DEFINE VARIABLE i-rows AS INTEGER     NO-UNDO.

   
    IF BROWSE brTable1:NUM-SELECTED-ROWS >= 1  THEN DO:

        DO i-rows = 1 TO BROWSE brTable1:NUM-SELECTED-ROWS:

            BROWSE brTable1:FETCH-SELECTED-ROW(i-rows) no-error.   
            GET CURRENT brTable1.
            ASSIGN i-seq-aux        = tt-es-contrato-docum.sequencia
                   c-nro-docto-aux  = tt-es-contrato-docum.nro-docto
                   preco-total-aux  = tt-es-contrato-docum.preco-total.

           END.                 

     END. /* NUM-SELECTED-ROWS */
  
     RUN openQueryBrTable2.


   

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable2
&Scoped-define SELF-NAME brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTable2 wWindow
ON VALUE-CHANGED OF brTable2 IN FRAME fpage0
DO:
    DEFINE VARIABLE i-rows AS INTEGER     NO-UNDO.

    ASSIGN i-seq-dup-aux = 0.

     IF BROWSE brTable2:NUM-SELECTED-ROWS >= 1  THEN DO:

         DO i-rows = 1 TO BROWSE brTable2:NUM-SELECTED-ROWS:

             BROWSE brTable2:FETCH-SELECTED-ROW(i-rows) no-error.   
             GET CURRENT brTable2.
             ASSIGN i-seq-dup-aux = tt-es-contrato-docum-dup.seq-dup.

         END.                 

      END. /* NUM-SELECTED-ROWS */

      RUN openQueryBrTable3.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd wWindow
ON CHOOSE OF btAdd IN FRAME fpage0 /* Incluir */
DO:

    RUN pi-btadd.
    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAdd2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd2 wWindow
ON CHOOSE OF btAdd2 IN FRAME fpage0 /* Incluir */
DO:

    IF CAN-FIND(FIRST tt-es-contrato-docum) THEN
      RUN pi-btadd2.
    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAdd3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd3 wWindow
ON CHOOSE OF btAdd3 IN FRAME fpage0 /* Incluir */
DO:

    IF CAN-FIND(FIRST tt-es-contrato-docum-dup) THEN
      RUN pi-btadd3.
    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDelete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelete wWindow
ON CHOOSE OF btDelete IN FRAME fpage0 /* Eliminar */
DO:
    
    IF BROWSE brTable1:NUM-SELECTED-ROWS > 0  THEN DO:

        RUN utp\ut-msgs.p (INPUT "SHOW",
                           INPUT 27100,
                           INPUT "Deseja Eliminar Registro? ").
        
        IF RETURN-VALUE = "YES" THEN DO:
        
            BROWSE brTable1:FETCH-SELECTED-ROW(1) no-error.   
            GET CURRENT brTable1.
    
            FIND FIRST bf-es-contrato-docum EXCLUSIVE-LOCK
                 WHERE ROWID(bf-es-contrato-docum) = tt-es-contrato-docum.r-rowid.

            IF AVAIL bf-es-contrato-docum THEN DO:

                FOR EACH bf-es-contrato-docum-dup EXCLUSIVE-LOCK
                   WHERE bf-es-contrato-docum-dup.sequencia = bf-es-contrato-docum.sequencia:

                    DELETE  bf-es-contrato-docum-dup.
                END.


                FOR EACH bf-es-contrato-docum-imp EXCLUSIVE-LOCK
                   WHERE bf-es-contrato-docum-imp.sequencia = bf-es-contrato-docum.sequencia:

                    DELETE  bf-es-contrato-docum-imp.
                END.

                DELETE bf-es-contrato-docum.



            END.

            RUN openQuerybrTable1.           
    
        END.

    END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDelete2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelete2 wWindow
ON CHOOSE OF btDelete2 IN FRAME fpage0 /* Eliminar */
DO:
    
    IF BROWSE brTable2:NUM-SELECTED-ROWS > 0  THEN DO:

        RUN utp\ut-msgs.p (INPUT "SHOW",
                           INPUT 27100,
                           INPUT "Deseja Eliminar Registro? ").
        
        IF RETURN-VALUE = "YES" THEN DO:
        
            BROWSE brTable2:FETCH-SELECTED-ROW(1) no-error.   
            GET CURRENT brTable2.
    
            FIND FIRST bf-es-contrato-docum-dup EXCLUSIVE-LOCK
                 WHERE ROWID(bf-es-contrato-docum-dup) = tt-es-contrato-docum-dup.r-rowid.
    
            DELETE bf-es-contrato-docum-dup.

            RUN openQuerybrTable2.           
    
        END.

    END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDelete3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelete3 wWindow
ON CHOOSE OF btDelete3 IN FRAME fpage0 /* Eliminar */
DO:
    
    IF BROWSE brTable3:NUM-SELECTED-ROWS > 0  THEN DO:

        RUN utp\ut-msgs.p (INPUT "SHOW",
                           INPUT 27100,
                           INPUT "Deseja Eliminar Registro? ").
        
        IF RETURN-VALUE = "YES" THEN DO:
        
            BROWSE brTable3:FETCH-SELECTED-ROW(1) no-error.   
            GET CURRENT brTable3.

            MESSAGE tt-es-contrato-docum-imp.sequencia
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
    
            FIND FIRST bf-es-contrato-docum-imp EXCLUSIVE-LOCK
                 WHERE ROWID(bf-es-contrato-docum-imp) = tt-es-contrato-docum-imp.r-rowid.
    
            DELETE bf-es-contrato-docum-imp.

            RUN openQuerybrTable3.           
    
        END.

    END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDeselTodos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeselTodos wWindow
ON CHOOSE OF btDeselTodos IN FRAME fpage0 /* Deselecionar todos */
DO:
    FOR EACH tt-es-contrato-docum:
        ASSIGN tt-es-contrato-docum.id-selecionado = NO.
    END.
    brTable1:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFiltro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFiltro wWindow
ON CHOOSE OF btFiltro IN FRAME fpage0
DO:
    DEFINE VARIABLE l-ok AS LOGICAL     NO-UNDO.


    RUN esp\esre1001f.w (OUTPUT l-ok,
                         INPUT-OUTPUT TABLE tt-param).


    IF l-ok THEN
        RUN openQueryBrTable1.


    RETURN "OK".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGeraImpto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGeraImpto wWindow
ON CHOOSE OF btGeraImpto IN FRAME fpage0 /* Gera Impto */
DO:
    


    RUN pi-btGeraImpto.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGerar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGerar wWindow
ON CHOOSE OF btGerar IN FRAME fpage0 /* Gerar */
DO:

    RUN piBtGerar.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Help */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btPeriodo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btPeriodo wWindow
ON CHOOSE OF btPeriodo IN FRAME fpage0 /* Save */
DO:

    RUN openQueryBrTable1.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wWindow
ON CHOOSE OF btQueryJoins IN FRAME fpage0 /* Query Joins */
DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fpage0 /* Reports Joins */
DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSelTodos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSelTodos wWindow
ON CHOOSE OF btSelTodos IN FRAME fpage0 /* Selecionar todos */
DO:
    FOR EACH tt-es-contrato-docum:
        ASSIGN tt-es-contrato-docum.id-selecionado = YES.
    END.
    brTable1:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdate wWindow
ON CHOOSE OF btUpdate IN FRAME fpage0 /* Alterar */
DO:

    RUN pi-btUpdate.
    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpdate2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdate2 wWindow
ON CHOOSE OF btUpdate2 IN FRAME fpage0 /* Alterar */
DO:

  
      RUN pi-btUpdate2.
    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpdate3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdate3 wWindow
ON CHOOSE OF btUpdate3 IN FRAME fpage0 /* Alterar */
DO:
    
  RUN pi-btUpdate3.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable1
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

 CREATE tt-param.

 /*
 ASSIGN tt-param.dt-valid-ini = TODAY
        tt-param.dt-valid-fim = TODAY.*/

 DO WITH FRAME fPage0:

     ASSIGN c-periodo:SENSITIVE     = YES
            btPeriodo:SENSITIVE     = YES
                                    
            btGerar:SENSITIVE       = YES
                                    
            brTable1:SENSITIVE      = YES
            btAdd:SENSITIVE         = YES
            btDelete:SENSITIVE      = YES
            btUpdate:SENSITIVE      = YES
            btSelTodos:SENSITIVE    = YES
            btDeselTodos:SENSITIVE  = YES
                                  
            brTable2:SENSITIVE      = YES
            btAdd2:SENSITIVE        = YES
            btDelete2:SENSITIVE     = YES
            btUpdate2:SENSITIVE     = YES
                                    
             brTable3:SENSITIVE     = YES
             btAdd3:SENSITIVE       = YES
             btDelete3:SENSITIVE    = YES
             btUpdate3:SENSITIVE    = YES
                                    
                                    
            btGeraImpto:SENSITIVE   = YES
            .


     ASSIGN c-periodo:SCREEN-VALUE = STRING(MONTH(TODAY), '99') + STRING(YEAR(TODAY), '9999').

 END.

 RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openQueryBrTable1 wWindow 
PROCEDURE openQueryBrTable1 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
 DEFINE VARIABLE iMes      AS INTEGER     NO-UNDO.
 DEFINE VARIABLE iAno      AS INTEGER     NO-UNDO.
 DEFINE VARIABLE dtPeriodo AS DATE        NO-UNDO.

 ASSIGN INPUT FRAME fPage0 c-periodo.

 ASSIGN iMes        = INTEGER(SUBSTRING(c-periodo, 1, 02))
        iAno        = INTEGER(SUBSTRING(c-periodo, 3, 04))
        dtPeriodo   = DATE(iMes, 1, iAno)
        NO-ERROR.           



 FIND FIRST tt-param NO-ERROR.
 EMPTY TEMP-TABLE tt-es-contrato-docum.

 blk_oper:
 FOR EACH es-contrato-docum NO-LOCK
    WHERE es-contrato-docum.dt-periodo = dtPeriodo
      AND es-contrato-docum.nr-contrato >= tt-param.nr-contrato-ini
      AND es-contrato-docum.nr-contrato <= tt-param.nr-contrato-fim
      AND es-contrato-docum.cod-estabel >= tt-param.cod-estabel-ini
      AND es-contrato-docum.cod-estabel <= tt-param.cod-estabel-fim
      AND es-contrato-docum.it-codigo BEGINS "CONT" :

 
     IF  tt-param.dt-valid-ini <> ?
     AND tt-param.dt-valid-fim <> ?
     AND NOT CAN-FIND(FIRST es-contrato-docum-dup
                  WHERE es-contrato-docum-dup.sequencia  = es-contrato-docum.sequencia)
     AND NOT CAN-FIND(FIRST es-contrato-docum-dup
                      WHERE es-contrato-docum-dup.sequencia  = es-contrato-docum.sequencia
                      AND   es-contrato-docum-dup.dt-vencim >= tt-param.dt-valid-ini
                      AND   es-contrato-docum-dup.dt-vencim <= tt-param.dt-valid-fim) THEN NEXT blk_oper.

     /* situacao conciliacao */
     IF tt-param.situacao > 1 THEN DO:
     
         IF  tt-param.situacao = 2 
         AND es-contrato-docum.dt-integracao = ? THEN NEXT blk_oper.
     
         IF  tt-param.situacao = 3 
         AND es-contrato-docum.dt-integracao <> ? THEN NEXT blk_oper.
     END.

     FIND FIRST es-contrato-docum-dup
            WHERE es-contrato-docum-dup.sequencia  = es-contrato-docum.sequencia NO-ERROR.

     IF es-contrato-docum-dup.dt-vencim >= tt-param.dt-valid-ini AND
        es-contrato-docum-dup.dt-vencim <= tt-param.dt-valid-fim  THEN DO:
     
         CREATE tt-es-contrato-docum.
         BUFFER-COPY es-contrato-docum TO tt-es-contrato-docum.
         ASSIGN tt-es-contrato-docum.r-rowid = ROWID(es-contrato-docum)
                tt-es-contrato-docum.dt-vencimento = IF AVAIL es-contrato-docum-dup THEN es-contrato-docum-dup.dt-vencim ELSE ? .

     END.
 END.

 {&OPEN-QUERY-brTable1}

  APPLY "VALUE-CHANGED" TO Brtable1 IN FRAME fPage0.

 RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openQuerybrTable2 wWindow 
PROCEDURE openQuerybrTable2 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


 FIND FIRST tt-param NO-ERROR.
 EMPTY TEMP-TABLE tt-es-contrato-docum-dup.

 FOR EACH es-contrato-docum-dup NO-LOCK
     WHERE es-contrato-docum-dup.sequencia  = i-seq-aux:

     CREATE tt-es-contrato-docum-dup.
     BUFFER-COPY es-contrato-docum-dup TO tt-es-contrato-docum-dup.
     ASSIGN tt-es-contrato-docum-dup.r-rowid = ROWID(es-contrato-docum-dup).

 END.

 {&OPEN-QUERY-brTable2}


  APPLY "VALUE-CHANGED" TO Brtable2 IN FRAME fPage0.

 RETURN "OK".




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openQueryBrTable3 wWindow 
PROCEDURE openQueryBrTable3 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

EMPTY TEMP-TABLE tt-es-contrato-docum-imp.

 FOR EACH es-contrato-docum-imp NO-LOCK
    WHERE es-contrato-docum-imp.sequencia = i-seq-aux
    AND   es-contrato-docum-imp.seq-dup = i-seq-dup-aux:

     CREATE tt-es-contrato-docum-imp.
     BUFFER-COPY es-contrato-docum-imp TO tt-es-contrato-docum-imp.
     ASSIGN tt-es-contrato-docum-imp.r-rowid = ROWID(es-contrato-docum-imp).

 END.

 {&OPEN-QUERY-brTable3}


  APPLY "VALUE-CHANGED" TO Brtable3 IN FRAME fPage0.

 RETURN "OK".


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-btadd wWindow 
PROCEDURE pi-btadd :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

   EMPTY TEMP-TABLE tt-es-contrato-docum-aux.

   RUN esp\esre1001a.w (INPUT ?,
                        INPUT INPUT FRAME fpage0 c-periodo,
                        INPUT "ADD",
                        OUTPUT TABLE tt-es-contrato-docum-aux).

   IF RETURN-VALUE = "OK" THEN
      RUN openQueryBrTable1.



   RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-btadd2 wWindow 
PROCEDURE pi-btadd2 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

   EMPTY TEMP-TABLE tt-es-contrato-docum-dup-aux.


   RUN esp\esre1001b.w (INPUT ?,
                        INPUT i-seq-aux,
                        INPUT c-nro-docto-aux,
                        INPUT preco-total-aux,
                        INPUT "ADD",
                        OUTPUT TABLE tt-es-contrato-docum-dup-aux).

   IF RETURN-VALUE = "OK" THEN
      RUN openQueryBrTable2.


  RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-btadd3 wWindow 
PROCEDURE pi-btadd3 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

   EMPTY TEMP-TABLE tt-es-contrato-docum-imp-aux.

   RUN esp\esre1001c.w (INPUT "ADD",
                        INPUT ?,
                        INPUT i-seq-aux,
                        INPUT i-seq-dup-aux,
                        OUTPUT TABLE tt-es-contrato-docum-imp-aux).

   IF RETURN-VALUE = "OK" THEN
      RUN openQueryBrTable3.


  RETURN "OK".


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-btGeraImpto wWindow 
PROCEDURE pi-btGeraImpto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  
   IF CAN-FIND(FIRST tt-es-contrato-docum-dup) THEN DO:

       IF CAN-FIND(FIRST es-contrato-docum-imp
                   WHERE es-contrato-docum-imp.sequencia = i-seq-aux) THEN DO:


           RUN utp\ut-msgs.p (INPUT "SHOW",
                   INPUT 25997,
                   INPUT "Impostos ja gerados!").

            RETURN NO-APPLY.

       END.
       ELSE DO:

            RUN esp\esre9343.p (INPUT TABLE tt-es-contrato-docum-dup,
                                OUTPUT TABLE tt-erro).

            IF CAN-FIND(FIRST tt-erro) THEN DO:

                RUN cdp\cd0666.w (INPUT TABLE tt-erro).

            END.
            ELSE DO:

                  RUN utp\ut-msgs.p (INPUT "SHOW",
                                     INPUT 15825,
                                     INPUT "Impostos Gerados!").


                  RUN openQueryBrTable3.


            END.

       END.





   END.

   RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-btUpdate wWindow 
PROCEDURE pi-btUpdate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF BROWSE brTable1:NUM-SELECTED-ROWS > 0  THEN DO:

        
            BROWSE brTable1:FETCH-SELECTED-ROW(1) no-error.   
            GET CURRENT brTable1.

            RUN esp\esre1001a.w (INPUT tt-es-contrato-docum.r-rowid,
                                 INPUT "",
                                 INPUT "UPDATE",
                                 OUTPUT TABLE tt-es-contrato-docum-aux).




            IF RETURN-VALUE = "OK" THEN
               RUN openQueryBrTable1.

    END.





END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-btUpdate2 wWindow 
PROCEDURE pi-btUpdate2 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF BROWSE brTable2:NUM-SELECTED-ROWS > 0  THEN DO:

        
            BROWSE brTable2:FETCH-SELECTED-ROW(1) no-error.   
            GET CURRENT brTable2.

            RUN esp\esre1001b.w (INPUT tt-es-contrato-docum-dup.r-rowid,
                                 INPUT i-seq-aux,
                                 INPUT c-nro-docto-aux,
                                 INPUT preco-total-aux,
                                 INPUT "UPDATE",
                                 OUTPUT TABLE tt-es-contrato-docum-dup-aux).



            IF RETURN-VALUE = "OK" THEN
               RUN openQueryBrTable2.

    END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-btUpdate3 wWindow 
PROCEDURE pi-btUpdate3 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    IF BROWSE brTable3:NUM-SELECTED-ROWS > 0  THEN DO:

        
            BROWSE brTable3:FETCH-SELECTED-ROW(1) no-error.   
            GET CURRENT brTable3.

            RUN esp\esre1001c.w (INPUT "UPDATE",
                                 INPUT tt-es-contrato-docum-imp.r-rowid,
                                 INPUT i-seq-aux,
                                 INPUT i-seq-dup-aux,
                                 OUTPUT TABLE tt-es-contrato-docum-imp-aux).

            IF RETURN-VALUE = "OK" THEN
               RUN openQueryBrTable3.

    END.


  RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piBtGerar wWindow 
PROCEDURE piBtGerar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF NOT CAN-FIND(FIRST tt-es-contrato-docum
                    WHERE tt-es-contrato-docum.id-selecionado) THEN DO:

        RUN utp\ut-msgs.p (INPUT "SHOW",
                           INPUT 25997,
                           INPUT "Nenhum registro Selecionado!").

        RETURN NO-APPLY.
    END.
    ELSE DO:

        IF CAN-FIND(FIRST tt-es-contrato-docum
                    WHERE tt-es-contrato-docum.id-selecionado
                    AND   tt-es-contrato-docum.dt-integracao <> ?) THEN DO:

            RUN utp\ut-msgs.p (INPUT "SHOW",
                               INPUT 25997,
                               INPUT "Registro ja integrado foi Selecionado!").

            RETURN NO-APPLY.

        END.


        EMPTY TEMP-TABLE tt-es-contrato-docum-selecionado.
        FOR EACH bf-tt-es-contrato-docum
            WHERE bf-tt-es-contrato-docum.id-selecionado:

            CREATE tt-es-contrato-docum-selecionado.
            BUFFER-COPY bf-tt-es-contrato-docum TO tt-es-contrato-docum-selecionado.

        END.

        RUN utp\ut-msgs.p (INPUT "SHOW",
                           INPUT 27100,
                           INPUT "Deseja Gerar Documento de Entrada ? ").

        IF RETURN-VALUE = "YES" THEN DO:
           RUN esp\esreapi190.p (INPUT TABLE tt-es-contrato-docum-selecionado).
        END.

    END.

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

