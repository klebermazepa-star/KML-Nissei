&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wWindow


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int_dp_info_abc NO-UNDO LIKE int_dp_info_abc
       FIELD desc-item    AS CHAR
       FIELD c-pnu        AS CHAR
       FIELD c-tipo-preco AS CHAR
       FIELD i-codigo-ean AS DEC
       FIELD fm-codigo    AS CHAR.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
{include/i-prgvrs.i NI0308 2.00.00.000}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        NI0308
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   ABC Farma

&GLOBAL-DEFINE page0Widgets   btOK  
&GLOBAL-DEFINE page1Widgets   brABCFarma

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

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

def var h-acomp as handle no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brABCFarma

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int_dp_info_abc

/* Definitions for BROWSE brABCFarma                                    */
&Scoped-define FIELDS-IN-QUERY-brABCFarma tt-int_dp_info_abc.uf tt-int_dp_info_abc.it_codigo tt-int_dp_info_abc.desc-item tt-int_dp_info_abc.i-codigo-ean tt-int_dp_info_abc.preco-fabric tt-int_dp_info_abc.pmc tt-int_dp_info_abc.c-tipo-preco tt-int_dp_info_abc.c-pnu tt-int_dp_info_abc.categoria tt-int_dp_info_abc.fm-codigo   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brABCFarma   
&Scoped-define SELF-NAME brABCFarma
&Scoped-define QUERY-STRING-brABCFarma FOR EACH tt-int_dp_info_abc NO-LOCK
&Scoped-define OPEN-QUERY-brABCFarma OPEN QUERY {&SELF-NAME} FOR EACH tt-int_dp_info_abc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brABCFarma tt-int_dp_info_abc
&Scoped-define FIRST-TABLE-IN-QUERY-brABCFarma tt-int_dp_info_abc


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brABCFarma}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS c-it-ini c-it-fim c-uf-ini c-uf-fim ~
bt-confirma btOK IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 RECT-1 
&Scoped-Define DISPLAYED-OBJECTS c-it-ini c-it-fim c-uf-ini c-uf-fim 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-confirma 
     IMAGE-UP FILE "image\im-sav":U
     LABEL "Button 1" 
     SIZE 5.14 BY 1.

DEFINE BUTTON btOK 
     IMAGE-UP FILE "image/im-exi.bmp":U
     LABEL "OK" 
     SIZE 5.14 BY 1.21.

DEFINE VARIABLE c-it-fim AS CHARACTER FORMAT "X(16)":U INITIAL "ZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE c-it-ini AS CHARACTER FORMAT "X(16)":U 
     LABEL "Item" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE c-uf-fim AS CHARACTER FORMAT "X(2)":U INITIAL "ZZ" 
     VIEW-AS FILL-IN 
     SIZE 3 BY .88 NO-UNDO.

DEFINE VARIABLE c-uf-ini AS CHARACTER FORMAT "X(2)":U 
     LABEL "UF" 
     VIEW-AS FILL-IN 
     SIZE 3 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-2
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-3
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-4
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 141 BY 2.79.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brABCFarma FOR 
      tt-int_dp_info_abc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brABCFarma
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brABCFarma wWindow _FREEFORM
  QUERY brABCFarma NO-LOCK DISPLAY
      tt-int_dp_info_abc.uf           FORMAT "x(3)"  COLUMN-LABEL "UF"   
      tt-int_dp_info_abc.it_codigo    FORMAT "x(16)" COLUMN-LABEL "Item"
      tt-int_dp_info_abc.desc-item    FORMAT "x(60)" COLUMN-LABEL "Descri‡Æo"
      tt-int_dp_info_abc.i-codigo-ean FORMAT ">>>>>>>>>>>>>>9" COLUMN-LABEL "EAN Principal"
      tt-int_dp_info_abc.preco_fabric COLUMN-LABEL "Pre‡o F brica"   
      tt-int_dp_info_abc.pmc          COLUMN-LABEL "PMC"   
      tt-int_dp_info_abc.c-pnu        FORMAT "x(10)" COLUMN-LABEL "Lista"     
      tt-int_dp_info_abc.categoria    COLUMN-LABEL "In¡cio Validade" FORMAT "x(14)"
      tt-int_dp_info_abc.fm-codigo    COLUMN-LABEL "Fam¡lia" FORMAT "X(50)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 140.72 BY 15.67
         FONT 1 NO-EMPTY-SPACE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     c-it-ini AT ROW 1.58 COL 27.29 COLON-ALIGNED WIDGET-ID 2
     c-it-fim AT ROW 1.58 COL 59.43 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     c-uf-ini AT ROW 2.58 COL 27.29 COLON-ALIGNED WIDGET-ID 16
     c-uf-fim AT ROW 2.58 COL 59.43 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     bt-confirma AT ROW 1.54 COL 80.29 WIDGET-ID 10
     btOK AT ROW 1.5 COL 136.72
     IMAGE-1 AT ROW 1.58 COL 46.72 WIDGET-ID 12
     IMAGE-2 AT ROW 1.58 COL 58.14 WIDGET-ID 14
     IMAGE-3 AT ROW 2.58 COL 46.72 WIDGET-ID 6
     IMAGE-4 AT ROW 2.58 COL 58.14 WIDGET-ID 8
     RECT-1 AT ROW 1.17 COL 2.29 WIDGET-ID 20
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.14 ROW 1
         SIZE 148.86 BY 19.04
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brABCFarma AT ROW 1 COL 1 WIDGET-ID 600
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.29 ROW 4.08
         SIZE 141 BY 15.75
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int_dp_info_abc T "?" NO-UNDO emsesp int_dp_info_abc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = "Consulta Informa‡äes ABC Farma"
         HEIGHT             = 19
         WIDTH              = 143.43
         MAX-HEIGHT         = 24.67
         MAX-WIDTH          = 151.86
         VIRTUAL-HEIGHT     = 24.67
         VIRTUAL-WIDTH      = 151.86
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
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME Custom                                                    */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brABCFarma 1 fPage1 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brABCFarma
/* Query rebuild information for BROWSE brABCFarma
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int_dp_info_abc NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = "USED"
     _Query            is OPENED
*/  /* BROWSE brABCFarma */
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
ON END-ERROR OF wWindow /* Consulta Informa‡äes ABC Farma */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow /* Consulta Informa‡äes ABC Farma */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-confirma
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-confirma wWindow
ON CHOOSE OF bt-confirma IN FRAME fpage0 /* Button 1 */
DO:
  assign input frame fPage0 c-it-ini c-it-fim c-uf-ini c-uf-fim.
  RUN pi-openQueryABCFarma.
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


&Scoped-define BROWSE-NAME brABCFarma
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
  
   ENABLE c-it-ini c-it-fim c-uf-ini c-uf-fim bt-confirma WITH FRAME fPage0.

   ASSIGN c-it-ini = ""
          c-it-fim = "ZZZZZZZZZZZZZZZZ"
          c-uf-ini = ""
          c-uf-fim = "ZZ".

   DISPLAY c-it-ini 
           c-it-fim
           c-uf-ini
           c-uf-fim
           WITH FRAME fPage0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryABCFarma wWindow 
PROCEDURE pi-openQueryABCFarma :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
empty temp-table tt-int_dp_info_abc.

assign input frame fPage0 c-it-ini c-it-fim c-uf-ini c-uf-fim.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp ("ABC Farma").

session:SET-WAIT-STATE ("GENERAL").

for each int_dp_info_abc no-lock WHERE
         int_dp_info_abc.it_codigo >= c-it-ini AND
         int_dp_info_abc.it_codigo <= c-it-fim AND
         int_dp_info_abc.uf        >= c-uf-ini AND
         int_dp_info_abc.uf        <= c-uf-fim QUERY-TUNING(NO-LOOKAHEAD) on stop undo, leave:

    RUN pi-acompanhar IN h-acomp (INPUT "Item: " + int_dp_info_abc.it_codigo).

    CREATE tt-int_dp_info_abc.
    BUFFER-COPY int_dp_info_abc TO tt-int_dp_info_abc.

    ASSIGN tt-int_dp_info_abc.desc-item    = ""
           tt-int_dp_info_abc.i-codigo-ean = 0
           tt-int_dp_info_abc.fm-codigo    = "".

    FOR FIRST int_ds_ean_item WHERE
              int_ds_ean_item.it_codigo = int_dp_info_abc.it_codigo AND 
              int_ds_ean_item.principal = YES NO-LOCK:
    END.
    IF AVAIL int_ds_ean_item THEN
       ASSIGN tt-int_dp_info_abc.i-codigo-ean = int_ds_ean_item.codigo_ean.

    FOR FIRST ITEM WHERE 
              ITEM.it-codigo = int_dp_info_abc.it_codigo NO-LOCK:
    END.
    IF AVAIL ITEM THEN
       ASSIGN tt-int_dp_info_abc.desc-item = ITEM.desc-item
              tt-int_dp_info_abc.fm-codigo = ITEM.fm-codigo.

    FIND FIRST familia WHERE
               familia.fm-codigo = ITEM.fm-codigo NO-LOCK NO-ERROR.
    IF AVAIL familia THEN
       ASSIGN tt-int_dp_info_abc.fm-codigo = tt-int_dp_info_abc.fm-codigo + " - " + familia.descricao.

    IF int_dp_info_abc.pnu = 1 THEN
       ASSIGN tt-int_dp_info_abc.c-pnu = "Positiva".

    IF int_dp_info_abc.pnu = 2 THEN
       ASSIGN tt-int_dp_info_abc.c-pnu = "Negativa".

    IF int_dp_info_abc.pnu = 3 THEN
       ASSIGN tt-int_dp_info_abc.c-pnu = "Neutra".

    IF int_dp_info_abc.tipo_preco = 1 THEN
       ASSIGN tt-int_dp_info_abc.c-tipo-preco = "Sim".
    ELSE 
       ASSIGN tt-int_dp_info_abc.c-tipo-preco = "NÆo".
END.

run pi-finalizar in h-acomp.

session:SET-WAIT-STATE ("").

if can-find (first tt-int_dp_info_abc) then do:
   OPEN QUERY brABCFarma FOR EACH tt-int_dp_info_abc NO-LOCK
       max-rows 100000 .
   enable all with frame fPage1.
   brABCFarma:SELECT-ROW(1) in frame fPage1.
   apply "VALUE-CHANGED":U to brABCFarma in frame fPage1.
end.
else do:
   close query brABCFarma.
   disable all with frame fPage1.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

