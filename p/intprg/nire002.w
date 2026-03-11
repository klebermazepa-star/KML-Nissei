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
{include/i-prgvrs.i NIRE002 2.00.06.000}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        NIRE002
&GLOBAL-DEFINE Version        2.00.06.000

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Folder1

&GLOBAL-DEFINE page0Widgets  c-estab-ini c-estab-fim dt-trans-ini dt-trans-fim c-nro-docto c-serie-docto br-notas bt-fil btExit 

&GLOBAL-DEFINE page1Widgets   
&GLOBAL-DEFINE page2Widgets   

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEF NEW GLOBAL SHARED VAR adm-broker-hdl AS HANDLE NO-UNDO.
/*                                                             */
DEFINE VARIABLE wh-pesquisa   AS HANDLE      NO-UNDO.


DEF TEMP-TABLE tt-notas NO-UNDO
    FIELD cod-estabel   LIKE docum-est.cod-estabel
    FIELD serie-docto   LIKE docum-est.serie-docto
    FIELD nro-docto     LIKE docum-est.nro-docto
    FIELD cod-emitente  LIKE docum-est.cod-emitente
    FIELD nat-operacao  LIKE docum-est.nat-operacao
    FIELD dt-trans      LIKE docum-est.dt-trans
    FIELD it-codigo     LIKE item-doc-est.it-codigo
    FIELD quantidade    LIKE item-doc-est.quantidade
    FIELD preco-unit    LIKE item-doc-est.preco-unit
    FIELD un            LIKE item-doc-est.un
    FIELD nome-emit     LIKE emitente.nome-emit
    FIELD desc-item     LIKE ITEM.desc-item
    FIELD vl-total      LIKE docum-est.valor-mercad
    FIELD vl-div        LIKE docum-est.valor-mercad
    FIELD vl-st         LIKE docum-est.valor-mercad
    INDEX id-nota
            serie-docto 
            nro-docto   
            cod-emitente
            nat-operacao.

/* Temp Table Definitions ---                                          */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME br-notas

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-notas

/* Definitions for BROWSE br-notas                                      */
&Scoped-define FIELDS-IN-QUERY-br-notas tt-notas.cod-estabel tt-notas.serie-docto tt-notas.nro-docto tt-notas.cod-emitente tt-notas.nat-operacao tt-notas.dt-trans tt-notas.it-codigo tt-notas.quantidade tt-notas.preco-unit[1] tt-notas.vl-total tt-notas.vl-div tt-notas.vl-st tt-notas.desc-item tt-notas.nome-emit   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-notas   
&Scoped-define SELF-NAME br-notas
&Scoped-define QUERY-STRING-br-notas FOR EACH tt-notas
&Scoped-define OPEN-QUERY-br-notas OPEN QUERY {&SELF-NAME} FOR EACH tt-notas.
&Scoped-define TABLES-IN-QUERY-br-notas tt-notas
&Scoped-define FIRST-TABLE-IN-QUERY-br-notas tt-notas


/* Definitions for FRAME fpage0                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fpage0 ~
    ~{&OPEN-QUERY-br-notas}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS c-estab-ini c-estab-fim dt-trans-ini ~
dt-trans-fim c-nro-docto c-serie-docto bt-fil br-notas RECT-1 IMAGE-5 ~
btExit IMAGE-6 IMAGE-19 IMAGE-20 
&Scoped-Define DISPLAYED-OBJECTS c-estab-ini c-estab-fim dt-trans-ini ~
dt-trans-fim c-nro-docto c-serie-docto 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-fil 
     IMAGE-UP FILE "image/im-enter.bmp":U
     LABEL "Filtrar" 
     SIZE 4 BY 1 TOOLTIP "Localizar Notas"
     FONT 4.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1 TOOLTIP "Sair"
     FONT 4.

DEFINE VARIABLE c-estab-fim AS CHARACTER FORMAT "X(5)":U INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .79 NO-UNDO.

DEFINE VARIABLE c-estab-ini AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .79 NO-UNDO.

DEFINE VARIABLE c-nro-docto AS CHARACTER FORMAT "X(7)":U 
     LABEL "Nota" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79 NO-UNDO.

DEFINE VARIABLE c-serie-docto AS CHARACTER FORMAT "X(3)":U 
     LABEL "S‚rie" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE dt-trans-fim AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79 NO-UNDO.

DEFINE VARIABLE dt-trans-ini AS DATE FORMAT "99/99/9999":U 
     LABEL "Transa‡Æo" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79 NO-UNDO.

DEFINE IMAGE IMAGE-19
     FILENAME "image\im-fir":U
     SIZE 3.14 BY .88.

DEFINE IMAGE IMAGE-20
     FILENAME "image\im-las":U
     SIZE 3.14 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3.14 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3.14 BY .88.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 112 BY 3.08.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-notas FOR 
      tt-notas SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-notas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-notas wWindow _FREEFORM
  QUERY br-notas NO-LOCK DISPLAY
      tt-notas.cod-estabel                                 FORMAT "X(05)"
tt-notas.serie-docto                                 FORMAT "X(03)"
tt-notas.nro-docto     COLUMN-LABEL "Nota"           WIDTH 7
tt-notas.cod-emitente  COLUMN-LABEL "Fornecedor"
tt-notas.nat-operacao
tt-notas.dt-trans  
tt-notas.it-codigo                                    WIDTH 6
tt-notas.quantidade    COLUMN-LABEL "Quantidade"      WIDTH 10
tt-notas.preco-unit[1] COLUMN-LABEL "Unit rio"        WIDTH 10 
tt-notas.vl-total      COLUMN-LABEL "Valor Total"     WIDTH 10
tt-notas.vl-div        COLUMN-LABEL "Valor Bonif"     WIDTH 10
tt-notas.vl-st         COLUMN-LABEL "Valor ST"        WIDTH 10
tt-notas.desc-item     COLUMN-LABEL "Descri‡Æo Item"  FORMAT "X(40)"
tt-notas.nome-emit     COLUMN-LABEL "Nome Fornecedor" FORMAT "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 112 BY 17
         FONT 1
         TITLE "" ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     c-estab-ini AT ROW 1.5 COL 36 COLON-ALIGNED WIDGET-ID 184
     c-estab-fim AT ROW 1.5 COL 56 COLON-ALIGNED NO-LABEL WIDGET-ID 186
     dt-trans-ini AT ROW 2.5 COL 36 COLON-ALIGNED WIDGET-ID 188
     dt-trans-fim AT ROW 2.5 COL 56 COLON-ALIGNED NO-LABEL WIDGET-ID 190
     c-nro-docto AT ROW 3.5 COL 36 COLON-ALIGNED WIDGET-ID 196
     c-serie-docto AT ROW 3.5 COL 56 COLON-ALIGNED WIDGET-ID 200
     bt-fil AT ROW 3.42 COL 62.29 WIDGET-ID 14
     br-notas AT ROW 4.75 COL 1 WIDGET-ID 200
     btExit AT ROW 3.42 COL 108 HELP
          "Sair" WIDGET-ID 182
     RECT-1 AT ROW 1.42 COL 1 WIDGET-ID 62
     IMAGE-5 AT ROW 1.5 COL 49 WIDGET-ID 84
     IMAGE-6 AT ROW 1.5 COL 54 WIDGET-ID 86
     IMAGE-19 AT ROW 2.5 COL 49 WIDGET-ID 192
     IMAGE-20 AT ROW 2.5 COL 54 WIDGET-ID 194
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 112.57 BY 20.96
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
         HEIGHT             = 21
         WIDTH              = 112.57
         MAX-HEIGHT         = 34.04
         MAX-WIDTH          = 228.57
         VIRTUAL-HEIGHT     = 34.04
         VIRTUAL-WIDTH      = 228.57
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
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
/* BROWSE-TAB br-notas bt-fil fpage0 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-notas
/* Query rebuild information for BROWSE br-notas
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-notas.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-notas */
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


&Scoped-define SELF-NAME bt-fil
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-fil wWindow
ON CHOOSE OF bt-fil IN FRAME fpage0 /* Filtrar */
DO:
   IF  SESSION:SET-WAIT-STATE("general") THEN.

   EMPTY TEMP-TABLE tt-notas.

   ASSIGN c-estab-ini   = INPUT FRAME {&FRAME-NAME} c-estab-ini
          c-estab-fim   = INPUT FRAME {&FRAME-NAME} c-estab-fim
          dt-trans-ini  = INPUT FRAME {&FRAME-NAME} dt-trans-ini
          dt-trans-fim  = INPUT FRAME {&FRAME-NAME} dt-trans-fim
          c-nro-docto   = INPUT FRAME {&FRAME-NAME} c-nro-docto
          c-serie-docto = INPUT FRAME {&FRAME-NAME} c-serie-docto.

   IF  c-nro-docto   <> "" AND
       c-serie-docto <> "" 
   THEN DO:
       FOR EACH  docum-est NO-LOCK
           WHERE docum-est.serie-docto  = c-serie-docto
             AND docum-est.nro-docto    = c-nro-docto
             AND docum-est.dt-trans    >= dt-trans-ini
             AND docum-est.dt-trans    <= dt-trans-fim
             AND docum-est.cod-estabel >= c-estab-ini
             AND docum-est.cod-estabel <= c-estab-fim,
           FIRST int-ds-natur-oper NO-LOCK
           WHERE int-ds-natur-oper.nat-operacao = docum-est.nat-operacao:
            
           IF  int-ds-natur-oper.log-bonificacao = YES
           THEN
               RUN pi-cria-tt-notas.
       END.
   END.
   ELSE DO:
       FOR EACH  docum-est NO-LOCK
           WHERE docum-est.dt-trans    >= dt-trans-ini
             AND docum-est.dt-trans    <= dt-trans-fim
             AND docum-est.cod-estabel >= c-estab-ini
             AND docum-est.cod-estabel <= c-estab-fim,
           FIRST int-ds-natur-oper NO-LOCK
           WHERE int-ds-natur-oper.nat-operacao = docum-est.nat-operacao:
            
           IF  int-ds-natur-oper.log-bonificacao = YES
           THEN
               RUN pi-cria-tt-notas.
       END.
   END.

   {&OPEN-QUERY-br-notas}

   IF  SESSION:SET-WAIT-STATE("") THEN.

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


&Scoped-define SELF-NAME c-nro-docto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-nro-docto wWindow
ON F5 OF c-nro-docto IN FRAME fpage0 /* Nota */
DO:
  {include/zoomvar.i &prog-zoom="inzoom/z01in090.w"
                     &campo=c-nro-docto
                     &campozoom=nro-docto
                     &campo2=c-serie-docto
                     &campozoom2=serie-docto}                       
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-nro-docto wWindow
ON MOUSE-SELECT-DBLCLICK OF c-nro-docto IN FRAME fpage0 /* Nota */
DO:
    APPLY "F5" TO SELF.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-notas
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/

{window/mainblock.i}

ASSIGN dt-trans-ini = TODAY - 31
       dt-trans-fim = TODAY.

DISP dt-trans-ini dt-trans-fim WITH FRAME {&FRAME-NAME}.

c-nro-docto:load-mouse-pointer("image/lupa.cur":U) in frame {&FRAME-NAME}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cria-tt-notas wWindow 
PROCEDURE pi-cria-tt-notas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   FIND emitente NO-LOCK
       WHERE emitente.cod-emitente = docum-est.cod-emitente NO-ERROR.

   FOR EACH item-doc-est OF docum-est NO-LOCK,
       FIRST ITEM OF item-doc-est NO-LOCK:

       CREATE tt-notas.
       ASSIGN tt-notas.cod-estabel  = docum-est.cod-estabel 
              tt-notas.serie-docto  = docum-est.serie-docto 
              tt-notas.nro-docto    = docum-est.nro-docto   
              tt-notas.cod-emitente = docum-est.cod-emitente
              tt-notas.nat-operacao = docum-est.nat-operacao
              tt-notas.dt-trans     = docum-est.dt-trans  
              tt-notas.it-codigo    = item-doc-est.it-codigo   
              tt-notas.quantidade   = item-doc-est.quantidade  
              tt-notas.preco-unit   = item-doc-est.preco-unit  
              tt-notas.un           = item-doc-est.un          
              tt-notas.nome-emit    = emitente.nome-emit   
              tt-notas.desc-item    = ITEM.desc-item
              tt-notas.vl-total     = (item-doc-est.preco-unit[1] * item-doc-est.quantidade) + item-doc-est.despesas[1] + item-doc-est.valor-ipi[1] + item-doc-est.vl-subs[1] - item-doc-est.desconto[1]
              tt-notas.vl-st        = item-doc-est.vl-subs[1].  

        FOR FIRST movto-estoq NO-LOCK
            WHERE movto-estoq.serie        = docum-est.serie-docto 
              AND movto-estoq.nro-docto    = docum-est.nro-docto   
              AND movto-estoq.cod-emitente = docum-est.cod-emitente
              AND movto-estoq.nat-operacao = docum-est.nat-operacao
              AND movto-estoq.it-codigo    = item-doc-est.it-codigo
              AND movto-estoq.esp-docto    = 6
              AND movto-estoq.tipo-trans   = 2:

            ASSIGN tt-notas.vl-div   = movto-estoq.valor-nota.
        END.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

