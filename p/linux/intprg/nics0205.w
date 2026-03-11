&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i NICS0205 2.00.00.000}  /*** 010019 ***/

/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessadores do Template de Relat¢rio                            */
/* Obs: Retirar o valor do preprocessador para as p†ginas que n∆o existirem  */

&GLOBAL-DEFINE PGSEL f-pg-sel
&GLOBAL-DEFINE PGCLA 
&GLOBAL-DEFINE PGPAR f-pg-par
&GLOBAL-DEFINE PGDIG 
&GLOBAL-DEFINE PGIMP f-pg-imp

/* Include Com as Vari†veis Globais */
{utp/ut-glob.i}

{cdp/cdcfgman.i}

/* Parameters Definitions ---                                           */

/* Temporary Table Definitions ---                                      */

define temp-table tt-param
    field destino          as integer
    field arquivo          as char
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer
    field i-ge-codigo-ini      like item.ge-codigo
    field i-ge-codigo-fim      like item.ge-codigo  
    field c-fm-codigo-ini      like item.fm-codigo     
    field c-fm-codigo-fim      like item.fm-codigo    
    field c-it-codigo-ini      like item.it-codigo   
    field c-it-codigo-fim      like item.it-codigo     
    field c-descricao-1-ini    like item.desc-item   
    field c-descricao-1-fim    like item.desc-item
    field c-inform-compl-ini   like item.inform-compl  
    field c-inform-compl-fim   like item.inform-compl    
    field da-implant-ini       like item.data-implant       
    field da-implant-fim       like item.data-implant 
    field rs-item              as integer format ">9"
    field cod-estabel          like estabelec.cod-estabel
    field rs-preco             as integer
    field descricao            like estabelec.nome.   

define temp-table tt-digita
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id is primary unique
        ordem.

define buffer b-tt-digita for tt-digita.

/* Transfer Definitions */

def var raw-param        as raw no-undo.

def temp-table tt-raw-digita
   field raw-digita      as raw.

/* Local Variable Definitions ---                                       */

def var l-ok               as logical no-undo.
def var c-arq-digita       as char    no-undo.
def var c-terminal         as char    no-undo.

def var c-preco as char format "x(15)" no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-pg-imp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES estabelec item familia

/* Definitions for FRAME f-pg-par                                       */
&Scoped-define QUERY-STRING-f-pg-par FOR EACH estabelec SHARE-LOCK
&Scoped-define OPEN-QUERY-f-pg-par OPEN QUERY f-pg-par FOR EACH estabelec SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-f-pg-par estabelec
&Scoped-define FIRST-TABLE-IN-QUERY-f-pg-par estabelec


/* Definitions for FRAME f-pg-sel                                       */
&Scoped-define QUERY-STRING-f-pg-sel FOR EACH mgcad.item SHARE-LOCK, ~
      EACH mgcad.familia WHERE TRUE /* Join to mgcad.item incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-f-pg-sel OPEN QUERY f-pg-sel FOR EACH mgcad.item SHARE-LOCK, ~
      EACH mgcad.familia WHERE TRUE /* Join to mgcad.item incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-f-pg-sel item familia
&Scoped-define FIRST-TABLE-IN-QUERY-f-pg-sel item
&Scoped-define SECOND-TABLE-IN-QUERY-f-pg-sel familia


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-2 rs-excel bt-arquivo c-arquivo ~
bt-config-impr 
&Scoped-Define DISPLAYED-OBJECTS rs-excel c-arquivo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-arquivo 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE .86 BY .21.

DEFINE BUTTON bt-config-impr 
     IMAGE-UP FILE "image\im-cfprt":U
     LABEL "" 
     SIZE 1 BY .25.

DEFINE VARIABLE c-arquivo AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 256
     SIZE 1 BY .25
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE rs-destino AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Impressora", 1,
"Arquivo", 2,
"Terminal", 3
     SIZE 1 BY .25 NO-UNDO.

DEFINE VARIABLE rs-excel AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Excel", 1
     SIZE 12 BY .83 NO-UNDO.

DEFINE VARIABLE rs-execucao AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "On-Line", 1,
"Batch", 2
     SIZE 1 BY .25 NO-UNDO.

DEFINE RECTANGLE rect-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 49.14 BY 1.71.

DEFINE VARIABLE c-cod-estabel LIKE estabelec.cod-estabel
     LABEL "Estab":R7 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE c-nome AS CHARACTER FORMAT "X(40)" 
     VIEW-AS FILL-IN 
     SIZE 48.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-text AS CHARACTER FORMAT "X(256)":U INITIAL "Item" 
      VIEW-AS TEXT 
     SIZE 5 BY .63 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Preáo Item" 
      VIEW-AS TEXT 
     SIZE 11.43 BY .67 NO-UNDO.

DEFINE VARIABLE rs-item AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Todos", 1,
"Somente os Ativos", 2,
"Somente os Obsoletos", 3
     SIZE 27 BY 3 NO-UNDO.

DEFINE VARIABLE rs-preco AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Mensal", 1,
"On-line", 2,
"Padr∆o", 3
     SIZE 25 BY 3.5 NO-UNDO.

DEFINE RECTANGLE RECT-38
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 35 BY 4.83.

DEFINE RECTANGLE RECT-39
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 71 BY 2.75.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 35 BY 4.83.

DEFINE VARIABLE c-descricao-1-fim AS CHARACTER FORMAT "x(18)" INITIAL "ZZZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 19.43 BY .88.

DEFINE VARIABLE c-descricao-1-ini AS CHARACTER FORMAT "x(18)" 
     LABEL "Descriá∆o":R11 
     VIEW-AS FILL-IN 
     SIZE 19.43 BY .88.

DEFINE VARIABLE c-fm-codigo-fim AS CHARACTER FORMAT "x(8)" INITIAL "ZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 12.43 BY .88.

DEFINE VARIABLE c-fm-codigo-ini AS CHARACTER FORMAT "x(8)" 
     LABEL "Fam°lia":R9 
     VIEW-AS FILL-IN 
     SIZE 12.43 BY .88.

DEFINE VARIABLE c-inform-compl-fim AS CHARACTER FORMAT "x(16)" INITIAL "ZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 17.43 BY .88.

DEFINE VARIABLE c-inform-compl-ini AS CHARACTER FORMAT "x(16)" 
     LABEL "Inf Complementar":R20 
     VIEW-AS FILL-IN 
     SIZE 17.43 BY .88.

DEFINE VARIABLE c-it-codigo-fim AS CHARACTER FORMAT "x(16)" INITIAL "ZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 17.43 BY .88.

DEFINE VARIABLE c-it-codigo-ini AS CHARACTER FORMAT "x(16)" 
     LABEL "Item":R5 
     VIEW-AS FILL-IN 
     SIZE 17.43 BY .88.

DEFINE VARIABLE da-implant-fim AS DATE FORMAT "99/99/9999" 
     VIEW-AS FILL-IN 
     SIZE 12.86 BY .88.

DEFINE VARIABLE da-implant-ini AS DATE FORMAT "99/99/9999" 
     LABEL "Implantaá∆o":R14 
     VIEW-AS FILL-IN 
     SIZE 12.86 BY .88.

DEFINE VARIABLE i-ge-codigo-fim AS INTEGER FORMAT "->,>>>,>>9" INITIAL 99 
     VIEW-AS FILL-IN 
     SIZE 3.72 BY .88.

DEFINE VARIABLE i-ge-codigo-ini AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0 
     LABEL "Grupo Estoque":R16 
     VIEW-AS FILL-IN 
     SIZE 3.72 BY .88.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3.14 BY .88.

DEFINE IMAGE IMAGE-10
     FILENAME "image\im-fir":U
     SIZE 3.14 BY .88.

DEFINE IMAGE IMAGE-11
     FILENAME "image\im-fir":U
     SIZE 3.14 BY .88.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-13
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-14
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-15
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-16
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-7
     FILENAME "image\im-fir":U
     SIZE 3.14 BY .88.

DEFINE IMAGE IMAGE-8
     FILENAME "image\im-fir":U
     SIZE 3.14 BY .88.

DEFINE IMAGE IMAGE-9
     FILENAME "image\im-fir":U
     SIZE 3.14 BY .88.

DEFINE BUTTON bt-ajuda 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-cancelar AUTO-END-KEY 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-executar 
     LABEL "Executar" 
     SIZE 10 BY 1.

DEFINE IMAGE im-pg-imp
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE IMAGE im-pg-par
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE IMAGE im-pg-sel
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 79 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 0    
     SIZE 78.72 BY .13
     BGCOLOR 7 .

DEFINE RECTANGLE rt-folder
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL   
     SIZE 79 BY 11.38
     FGCOLOR 0 .

DEFINE RECTANGLE rt-folder-left
     EDGE-PIXELS 0    
     SIZE .43 BY 11.21
     BGCOLOR 15 .

DEFINE RECTANGLE rt-folder-right
     EDGE-PIXELS 0    
     SIZE .43 BY 11.17
     BGCOLOR 7 .

DEFINE RECTANGLE rt-folder-top
     EDGE-PIXELS 0    
     SIZE 78.72 BY .13
     BGCOLOR 15 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY f-pg-par FOR 
      estabelec SCROLLING.

DEFINE QUERY f-pg-sel FOR 
      item, 
      familia SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-relat
     bt-executar AT ROW 14.54 COL 3 HELP
          "Dispara a execuá∆o do relat¢rio"
     bt-cancelar AT ROW 14.54 COL 14 HELP
          "Cancelar"
     bt-ajuda AT ROW 14.54 COL 70 HELP
          "Ajuda"
     RECT-1 AT ROW 14.29 COL 2
     RECT-6 AT ROW 13.75 COL 2.14
     im-pg-sel AT ROW 1.5 COL 2.14
     rt-folder-right AT ROW 2.67 COL 80.43
     im-pg-par AT ROW 1.5 COL 17.86
     im-pg-imp AT ROW 1.5 COL 33.57
     rt-folder AT ROW 2.5 COL 2
     rt-folder-left AT ROW 2.54 COL 2.14
     rt-folder-top AT ROW 2.54 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 81 BY 15
         DEFAULT-BUTTON bt-executar.

DEFINE FRAME f-pg-sel
     i-ge-codigo-ini AT ROW 2.92 COL 21.86 COLON-ALIGNED HELP
          "Informe o grupo inicial"
     i-ge-codigo-fim AT ROW 2.92 COL 49.57 COLON-ALIGNED HELP
          "Informe o grupo final" NO-LABEL
     c-fm-codigo-ini AT ROW 3.92 COL 21.86 COLON-ALIGNED HELP
          "Informe a fam°lia inicial"
     c-fm-codigo-fim AT ROW 3.92 COL 49.57 COLON-ALIGNED HELP
          "Informe a fam°lia final" NO-LABEL
     c-it-codigo-ini AT ROW 4.92 COL 21.86 COLON-ALIGNED HELP
          "Informe o c¢digo do Item inicial"
     c-it-codigo-fim AT ROW 4.92 COL 49.57 COLON-ALIGNED HELP
          "Informe o c¢digo do Item final" NO-LABEL
     c-descricao-1-ini AT ROW 5.92 COL 21.86 COLON-ALIGNED
     c-descricao-1-fim AT ROW 5.92 COL 49.57 COLON-ALIGNED HELP
          "Informe a descriá∆o final" NO-LABEL
     c-inform-compl-ini AT ROW 6.92 COL 21.86 COLON-ALIGNED HELP
          "Entre com a Informaá∆o Complementar Inicial"
     c-inform-compl-fim AT ROW 6.92 COL 49.57 COLON-ALIGNED HELP
          "Entre com a Informaá∆o Complementar final" NO-LABEL
     da-implant-ini AT ROW 7.92 COL 21.86 COLON-ALIGNED HELP
          "Informe a data de implantaá∆o inicial"
     da-implant-fim AT ROW 7.92 COL 49.57 COLON-ALIGNED HELP
          "Informe a data de implantaá∆o final" NO-LABEL
     IMAGE-13 AT ROW 4.92 COL 48.43
     IMAGE-8 AT ROW 4.92 COL 44.14
     IMAGE-12 AT ROW 3.92 COL 48.43
     IMAGE-7 AT ROW 3.92 COL 44.14
     IMAGE-2 AT ROW 2.92 COL 48.43
     IMAGE-1 AT ROW 2.92 COL 44.14
     IMAGE-10 AT ROW 6.92 COL 44.14
     IMAGE-15 AT ROW 6.92 COL 48.43
     IMAGE-11 AT ROW 7.92 COL 44.14
     IMAGE-16 AT ROW 7.92 COL 48.43
     IMAGE-9 AT ROW 5.92 COL 44.14
     IMAGE-14 AT ROW 5.92 COL 48.43
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 2.85
         SIZE 76.86 BY 10.62.

DEFINE FRAME f-pg-par
     rs-preco AT ROW 2.88 COL 41 NO-LABEL
     rs-item AT ROW 3.13 COL 8 HELP
          "Informe a classificaá∆o do Item" NO-LABEL
     c-cod-estabel AT ROW 9.17 COL 12 COLON-ALIGNED HELP
          ""
          LABEL "Estab":R7
     c-nome AT ROW 9.17 COL 20.29 COLON-ALIGNED HELP
          "Nome Estabelecimento" NO-LABEL
     c-text AT ROW 1.88 COL 3 COLON-ALIGNED NO-LABEL
     FILL-IN-1 AT ROW 1.88 COL 38 COLON-ALIGNED NO-LABEL
     RECT-39 AT ROW 8.21 COL 3
     RECT-38 AT ROW 2.17 COL 39
     RECT-9 AT ROW 2.17 COL 3
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 2.62
         SIZE 75 BY 11.04.

DEFINE FRAME f-pg-imp
     rs-excel AT ROW 3.21 COL 12 NO-LABEL WIDGET-ID 4
     bt-arquivo AT ROW 3.38 COL 49.86 HELP
          "Escolha do nome do arquivo"
     c-arquivo AT ROW 9 COL 17 HELP
          "Nome do arquivo de destino do relat¢rio" NO-LABEL
     rs-execucao AT ROW 9 COL 22 HELP
          "Modo de Execuá∆o" NO-LABEL
     rs-destino AT ROW 9 COL 27 HELP
          "Destino de Impress∆o do Relat¢rio" NO-LABEL
     bt-config-impr AT ROW 9 COL 33 HELP
          "Configuraá∆o da impressora"
     " Destino" VIEW-AS TEXT
          SIZE 6.72 BY .88 AT ROW 2.21 COL 7 WIDGET-ID 2
     rect-2 AT ROW 2.67 COL 6 WIDGET-ID 6
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 3
         SIZE 75.14 BY 10.54.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Relat¢rio Preáos Unit†rios"
         HEIGHT             = 15
         WIDTH              = 81.14
         MAX-HEIGHT         = 22.33
         MAX-WIDTH          = 114.29
         VIRTUAL-HEIGHT     = 22.33
         VIRTUAL-WIDTH      = 114.29
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB C-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/w-relat.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-pg-imp
   FRAME-NAME                                                           */
ASSIGN 
       bt-config-impr:HIDDEN IN FRAME f-pg-imp           = TRUE.

/* SETTINGS FOR RADIO-SET rs-destino IN FRAME f-pg-imp
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       rs-destino:HIDDEN IN FRAME f-pg-imp           = TRUE.

/* SETTINGS FOR RADIO-SET rs-execucao IN FRAME f-pg-imp
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       rs-execucao:HIDDEN IN FRAME f-pg-imp           = TRUE.

/* SETTINGS FOR FRAME f-pg-par
                                                                        */
/* SETTINGS FOR FILL-IN c-cod-estabel IN FRAME f-pg-par
   LIKE = mgcad.estabelec.cod-estabel EXP-LABEL EXP-SIZE                */
/* SETTINGS FOR FILL-IN c-nome IN FRAME f-pg-par
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-text IN FRAME f-pg-par
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       c-text:PRIVATE-DATA IN FRAME f-pg-par     = 
                "Item".

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME f-pg-par
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       FILL-IN-1:PRIVATE-DATA IN FRAME f-pg-par     = 
                "Preáo Item".

/* SETTINGS FOR FRAME f-pg-sel
                                                                        */
/* SETTINGS FOR FRAME f-relat
                                                                        */
/* SETTINGS FOR RECTANGLE RECT-1 IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-6 IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder-left IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder-right IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder-top IN FRAME f-relat
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-pg-imp
/* Query rebuild information for FRAME f-pg-imp
     _Query            is NOT OPENED
*/  /* FRAME f-pg-imp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-pg-par
/* Query rebuild information for FRAME f-pg-par
     _TblList          = "mgcad.estabelec"
     _Query            is OPENED
*/  /* FRAME f-pg-par */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-pg-sel
/* Query rebuild information for FRAME f-pg-sel
     _TblList          = "mgcad.item,mgcad.familia WHERE mgcad.item ..."
     _Query            is NOT OPENED
*/  /* FRAME f-pg-sel */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Relat¢rio Preáos Unit†rios */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
   RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Relat¢rio Preáos Unit†rios */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-ajuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ajuda C-Win
ON CHOOSE OF bt-ajuda IN FRAME f-relat /* Ajuda */
DO:
   {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME bt-arquivo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-arquivo C-Win
ON CHOOSE OF bt-arquivo IN FRAME f-pg-imp
DO:
    {include/i-rparq.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar C-Win
ON CHOOSE OF bt-cancelar IN FRAME f-relat /* Cancelar */
DO:
   apply "close" to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME bt-config-impr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-config-impr C-Win
ON CHOOSE OF bt-config-impr IN FRAME f-pg-imp
DO:
   {include/i-rpimp.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-executar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-executar C-Win
ON CHOOSE OF bt-executar IN FRAME f-relat /* Executar */
DO:
   do  on error undo, return no-apply:
       run pi-executar.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-par
&Scoped-define SELF-NAME c-cod-estabel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estabel C-Win
ON F5 OF c-cod-estabel IN FRAME f-pg-par /* Estab */
DO:

   {include/zoomvar.i &prog-zoom=adzoom/z01ad107.w
                      &campo=c-cod-estabel
                      &campozoom=cod-estabel
                      &campo2=c-nome
                      &campozoom2=nome
                      &frame=f-pg-par}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estabel C-Win
ON LEAVE OF c-cod-estabel IN FRAME f-pg-par /* Estab */
DO:
  {include/leave.i &tabela=estabelec 
                 &atributo-ref=nome
                 &variavel-ref=c-nome
                 &where="estabelec.cod-estabel = input frame {&frame-name} c-cod-estabel"}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estabel C-Win
ON MOUSE-SELECT-DBLCLICK OF c-cod-estabel IN FRAME f-pg-par /* Estab */
DO:
  apply 'F5' to self.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME im-pg-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-imp C-Win
ON MOUSE-SELECT-CLICK OF im-pg-imp IN FRAME f-relat
DO:
    run pi-troca-pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-par C-Win
ON MOUSE-SELECT-CLICK OF im-pg-par IN FRAME f-relat
DO:
    run pi-troca-pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-sel C-Win
ON MOUSE-SELECT-CLICK OF im-pg-sel IN FRAME f-relat
DO:
    run pi-troca-pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME rs-destino
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-destino C-Win
ON VALUE-CHANGED OF rs-destino IN FRAME f-pg-imp
DO:
do  with frame f-pg-imp:
    case self:screen-value:
        when "1" then do:
            assign c-arquivo:sensitive    = no
                   bt-arquivo:visible     = no
                   bt-config-impr:visible = yes.
        end.
        when "2" then do:
            assign c-arquivo:sensitive     = yes
                   bt-arquivo:visible      = yes
                   bt-config-impr:visible  = no.
        end.
        when "3" then do:
            assign c-arquivo:sensitive     = no
                   bt-arquivo:visible      = no
                   bt-config-impr:visible  = no.
        end.
    end case.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-execucao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-execucao C-Win
ON VALUE-CHANGED OF rs-execucao IN FRAME f-pg-imp
DO:
   {include/i-rprse.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

{utp/ut9000.i "NICS0205" "2.00.00.000"}

/* inicializaá‰es do template de relat¢rio */
{include/i-rpini.i}

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

{include/i-rplbl.i}

if c-cod-estabel:load-mouse-pointer ("Image~\lupa.cur") in frame f-pg-par then.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

find first item-estab no-lock no-error.
if  available(item-estab) then do:
    find first estabelec
         where estabelec.cod-estabel = item-estab.cod-estabel no-lock no-error.
    if  available(estabelec) then
        assign c-cod-estabel = estabelec.cod-estabel
               c-nome        = estabelec.nome.
end.

&IF DEFINED (bf_man_custeio_item) &THEN
    assign rs-preco:radio-buttons in frame f-pg-par = "Batch,1,On-line,2".

    find first param-cp no-lock no-error.
    if avail param-cp then do:
        find first estab-mat where
                   estab-mat.cod-estabel = param-cp.cod-estabel no-lock no-error.
        if avail estab-mat then
            assign rs-preco:screen-value in frame f-pg-par = string(estab-mat.custo-contab).
    end.
&ENDIF

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    assign da-implant-ini = &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF 
           da-implant-fim = 12/31/9999.

    RUN enable_UI.

    {include/i-rpmbl.i}

    ASSIGN bt-config-impr:VISIBLE IN FRAME f-pg-imp      = NO
           c-arquivo:VISIBLE IN FRAME f-pg-imp           = NO.

    IF  NOT THIS-PROCEDURE:PERSISTENT THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects C-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available C-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  ENABLE im-pg-sel im-pg-par im-pg-imp bt-executar bt-cancelar bt-ajuda 
      WITH FRAME f-relat IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-relat}

  {&OPEN-QUERY-f-pg-par}
  GET FIRST f-pg-par.
  DISPLAY rs-preco rs-item c-cod-estabel c-nome 
      WITH FRAME f-pg-par IN WINDOW C-Win.
  ENABLE RECT-39 RECT-38 RECT-9 rs-preco rs-item c-cod-estabel 
      WITH FRAME f-pg-par IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-par}
  DISPLAY i-ge-codigo-ini i-ge-codigo-fim c-fm-codigo-ini c-fm-codigo-fim 
          c-it-codigo-ini c-it-codigo-fim c-descricao-1-ini c-descricao-1-fim 
          c-inform-compl-ini c-inform-compl-fim da-implant-ini da-implant-fim 
      WITH FRAME f-pg-sel IN WINDOW C-Win.
  ENABLE IMAGE-13 IMAGE-8 IMAGE-12 IMAGE-7 IMAGE-2 IMAGE-1 IMAGE-10 IMAGE-15 
         IMAGE-11 IMAGE-16 IMAGE-9 IMAGE-14 i-ge-codigo-ini i-ge-codigo-fim 
         c-fm-codigo-ini c-fm-codigo-fim c-it-codigo-ini c-it-codigo-fim 
         c-descricao-1-ini c-descricao-1-fim c-inform-compl-ini 
         c-inform-compl-fim da-implant-ini da-implant-fim 
      WITH FRAME f-pg-sel IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-sel}
  DISPLAY rs-excel c-arquivo 
      WITH FRAME f-pg-imp IN WINDOW C-Win.
  ENABLE rect-2 rs-excel bt-arquivo c-arquivo bt-config-impr 
      WITH FRAME f-pg-imp IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-imp}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit C-Win 
PROCEDURE local-exit :
/* -----------------------------------------------------------
  Purpose:  Starts an "exit" by APPLYing CLOSE event, which starts "destroy".
  Parameters:  <none>
  Notes:    If activated, should APPLY CLOSE, *not* dispatch adm-exit.   
-------------------------------------------------------------*/
   APPLY "CLOSE":U TO THIS-PROCEDURE.

   RETURN.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-executar C-Win 
PROCEDURE pi-executar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

do  on error undo, return error
    on stop  undo, return error:     

    {include/i-rpexa.i}

    assign i-ge-codigo-ini     = input frame f-pg-sel i-ge-codigo-ini
           i-ge-codigo-fim     = input frame f-pg-sel i-ge-codigo-fim
           c-fm-codigo-ini     = input frame f-pg-sel c-fm-codigo-ini     
           c-fm-codigo-fim     = input frame f-pg-sel c-fm-codigo-fim     
           c-it-codigo-ini     = input frame f-pg-sel c-it-codigo-ini     
           c-it-codigo-fim     = input frame f-pg-sel c-it-codigo-fim     
           c-descricao-1-ini   = input frame f-pg-sel c-descricao-1-ini   
           c-descricao-1-fim   = input frame f-pg-sel c-descricao-1-fim   
           c-inform-compl-ini  = input frame f-pg-sel c-inform-compl-ini  
           c-inform-compl-fim  = input frame f-pg-sel c-inform-compl-fim  
           da-implant-ini      = input frame f-pg-sel da-implant-ini      
           da-implant-fim      = input frame f-pg-sel da-implant-fim.

    if  input frame f-pg-imp rs-destino = 2 then do:
        run utp/ut-vlarq.p (input input frame f-pg-imp c-arquivo).
        if  return-value = "nok" then do:
            run utp/ut-msgs.p (input "show",
                               input 73,
                               input "").
            apply 'mouse-select-click' to im-pg-imp in frame f-relat.
            apply 'entry' to c-arquivo in frame f-pg-imp.                   
            return error.
        end.
    end.

    if  input frame f-pg-sel i-ge-codigo-ini > input i-ge-codigo-fim then do:
        run utp/ut-msgs.p (input "show",
                           input 23,
                           input string(i-ge-codigo-ini) + "~~" + string(i-ge-codigo-fim)).
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to i-ge-codigo-ini in frame f-pg-sel.                
        return error.
    end. 

    if  input frame f-pg-sel c-fm-codigo-ini > c-fm-codigo-fim then do:
        run utp/ut-msgs.p (input "show",
                           input 27,
                           input string(c-fm-codigo-ini) + "~~" + string(c-fm-codigo-fim)).
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to c-fm-codigo-ini in frame f-pg-sel.                
        return error.
    end. 

    if  input frame f-pg-sel c-it-codigo-ini > c-it-codigo-fim then do:
        run utp/ut-msgs.p (input "show",
                           input 52,
                           input string(c-it-codigo-ini) + "~~" + string(c-it-codigo-fim)).
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to c-it-codigo-ini in frame f-pg-sel.                
        return error.
    end. 

    if  input frame f-pg-sel c-descricao-1-ini > c-descricao-1-fim then do:
        run utp/ut-msgs.p (input "show",
                           input 96,
                           input string(c-descricao-1-ini) + "~~" + string(c-descricao-1-fim)).
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to c-descricao-1-ini in frame f-pg-sel.
        return error.
    end. 

    if  input frame f-pg-sel c-inform-compl-ini > c-inform-compl-fim then do:
        run utp/ut-msgs.p (input "show",
                           input 118,
                           input string(c-inform-compl-ini) + "~~" + string(c-inform-compl-fim)).
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to c-inform-compl-ini in frame f-pg-sel.
        return error.
    end. 

    if  input frame f-pg-sel da-implant-ini > da-implant-fim then do:
        run utp/ut-msgs.p (input "show",
                           input 118,
                           input string(da-implant-ini) + "~~" + string(da-implant-fim)).
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to da-implant-ini in frame f-pg-sel.                
        return error.
    end. 

    assign rs-preco = input frame f-pg-par rs-preco.

    if  rs-preco = 1 then 
        assign c-preco = {varinc/var00034.i 04 1}.
    else
    if  rs-preco = 2 then 
        assign c-preco = {varinc/var00034.i 04 2}.
    else 
    if  rs-preco = 3 then 
        assign c-preco = {varinc/var00034.i 04 3}.
    else c-preco = "".    

    if  rs-preco < 4 then do:
        find estabelec where 
             estabelec.cod-estabel = input frame f-pg-par c-cod-estabel no-lock no-error.
        if  not avail estabelec  then do:
            {utp/ut-table.i mgcad estabelec 1}
            run utp/ut-msgs.p (input "show",
                               input 56,
                               input return-value).
            apply 'mouse-select-click' to im-pg-par in frame f-relat.
            apply 'entry' to c-cod-estabel in frame f-pg-par.
            return error.
        end.

        &IF DEFINED (bf_man_custeio_item) &THEN
        find estab-mat where 
             estab-mat.cod-estabel = input frame f-pg-par c-cod-estabel no-lock no-error.
        if  not avail estab-mat  then do:
            {utp/ut-table.i mgind estab-mat 1}
            run utp/ut-msgs.p (input "show",
                               input 56,
                               input return-value).
            apply 'mouse-select-click' to im-pg-par in frame f-relat.
            apply 'entry' to c-cod-estabel in frame f-pg-par.
            return error.
        end.
        &ENDIF

        if  rs-preco = 1 
        and estabelec.usa-mensal = no then do: 
            run utp/ut-msgs.p (input "show",
                                       input 6433,
                                       input c-preco + "~~" + c-cod-estabel:screen-value).
            apply 'mouse-select-click' to im-pg-par in frame f-relat. 
            apply 'choose'             to rs-preco in frame f-pg-par.             
            return error.
        end.

        if  rs-preco = 2 
        and ( estabelec.usa-on-line = no 
        &IF DEFINED (bf_man_custeio_item) &THEN
        or  estab-mat.usa-on-line   = no
        &ENDIF
        ) then do:
            run utp/ut-msgs.p (input "show",
                               input 6433 ,
                               input c-preco + "~~" + c-cod-estabel:screen-value).
            apply 'mouse-select-click' to im-pg-par in frame f-relat. 
            apply 'choose'             to rs-preco in frame f-pg-par.             
            return error.
        end.

        if  rs-preco = 3 and estabelec.usa-padrao = no then do:
            run utp/ut-msgs.p (input "show",
                               input 6433 ,
                               input c-preco + "~~" + c-cod-estabel:screen-value).
            apply 'mouse-select-click' to im-pg-par in frame f-relat. 
            apply 'choose'             to rs-preco  in frame f-pg-par.             
            return error.
        end.
    end.

    create tt-param.
    assign tt-param.usuario    = c-seg-usuario
           tt-param.destino    = input frame f-pg-imp rs-destino
           tt-param.data-exec  = today
           tt-param.hora-exec  = TIME.
    if  tt-param.destino = 1 then
        assign tt-param.arquivo = "".
    else
    if  tt-param.destino = 2 then 
        assign tt-param.arquivo = input frame f-pg-imp c-arquivo.
    else
        assign tt-param.arquivo = session:temp-directory + c-programa-mg97 + ".tmp".

    /* Coloque aqui a l¢gica de gravaá∆o dos parÉmtros e seleá∆o na temp-table
       tt-param */ 
    assign tt-param.i-ge-codigo-ini     = input frame f-pg-sel i-ge-codigo-ini
           tt-param.i-ge-codigo-fim     = input frame f-pg-sel i-ge-codigo-fim
           tt-param.c-fm-codigo-ini     = input frame f-pg-sel c-fm-codigo-ini
           tt-param.c-fm-codigo-fim     = input frame f-pg-sel c-fm-codigo-fim
           tt-param.c-it-codigo-ini     = input frame f-pg-sel c-it-codigo-ini
           tt-param.c-it-codigo-fim     = input frame f-pg-sel c-it-codigo-fim
           tt-param.c-descricao-1-ini   = input frame f-pg-sel c-descricao-1-ini
           tt-param.c-descricao-1-fim   = input frame f-pg-sel c-descricao-1-fim
           tt-param.c-inform-compl-ini  = input frame f-pg-sel c-inform-compl-ini 
           tt-param.c-inform-compl-fim  = input frame f-pg-sel c-inform-compl-fim 
           tt-param.da-implant-ini      = input frame f-pg-sel da-implant-ini
           tt-param.da-implant-fim      = input frame f-pg-sel da-implant-fim
           tt-param.rs-item             = input frame f-pg-par rs-item 
           tt-param.rs-preco            = input frame f-pg-par rs-preco
           tt-param.cod-estabel         = input frame f-pg-par c-cod-estabel
           tt-param.descricao           = input frame f-pg-par c-nome.

    /*{include/i-rpexb.i}*/

    if  session:set-wait-state("general") then.

    {include/i-rprun.i intprg/nics0205rp.p}

    {include/i-rpexc.i}

    if  session:set-wait-state("") then.

    /*{include/i-rptrm.i}*/

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-troca-pagina C-Win 
PROCEDURE pi-troca-pagina :
/*------------------------------------------------------------------------------
  Purpose: Gerencia a Troca de P†gina (folder)   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

{include/i-rptrp.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records C-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "estabelec"}
  {src/adm/template/snd-list.i "item"}
  {src/adm/template/snd-list.i "familia"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed C-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.

  run pi-trata-state (p-issuer-hdl, p-state).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

