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
{include/i-prgvrs.i CC0305 2.00.00.050 } /*** 010050 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i cc0305 MCC}
&ENDIF




/*------------------------------------------------------------------------

  File: 
  Description: 
  Input Parameters:      <none>
  Output Parameters:     <none>
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
/* Obs: Retirar o valor do preprocessador para as pÿginas que nÆo existirem  */

&GLOBAL-DEFINE PGSEL f-pg-sel
&GLOBAL-DEFINE PGCLA
&GLOBAL-DEFINE PGPAR f-pg-par
&GLOBAL-DEFINE PGDIG
&GLOBAL-DEFINE PGIMP f-pg-imp

/* Include Com as Variÿveis Globais */
{utp/ut-glob.i}
{cdp/cdcfgdis.i}
{cdp/cdcfgmat.i}
  
/* Parameters Definitions ---                                           */

/* Temporary Table Definitions ---                                      */

define temp-table tt-param
    field destino           as integer
    field arquivo           as char
    field diretorio         as char
    field usuario           as char
    field data-exec         as date
    field hora-exec         as integer
    field i-pedi-i          as integer
    field i-pedi-f          as integer
    field l-narrativa-item  as logical
    field l-narrativa-ordem as logical
    field l-bus-to-bus      as logical
    field l-descricao       as logical
    field l-impressao       as logical
    field i-param-c         as integer
    field i-ordem-ini       like ordem-compra.numero-ordem
    field i-ordem-fim       like ordem-compra.numero-ordem
    field l-envia           as logical
    field c-destino         as char
    field l-eprocurement    as logical
    &IF "{&bf_mat_versao_ems}" >= "2.062" &THEN 
        FIELD l-integra-portal AS LOGICAL
    &ENDIF
    FIELD l-ped-compra     AS LOG
    FIELD l-gera-arq-local AS LOG
    FIELD c-arq-ped-compra   AS CHAR
    .

define temp-table tt-digita
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id is primary unique ordem.

define buffer b-tt-digita for tt-digita.

/* Transfer Definitions */

def var raw-param        as raw no-undo.

def temp-table tt-raw-digita
   field raw-digita      as raw.
                    
/* Local Variable Definitions ---                                       */


def var l-ok               as logical no-undo.
def var c-arq-digita       as char    no-undo.
def var c-terminal         as char    no-undo.

def var c-pasta            as char    no-undo.
def var l-cancelado        as logical no-undo.

DEF VAR l-totvs-colab AS LOG NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-pg-imp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ordem-compra

/* Definitions for FRAME f-pg-sel                                       */
&Scoped-define QUERY-STRING-f-pg-sel FOR EACH mgind.ordem-compra SHARE-LOCK
&Scoped-define OPEN-QUERY-f-pg-sel OPEN QUERY f-pg-sel FOR EACH mgind.ordem-compra SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-f-pg-sel ordem-compra
&Scoped-define FIRST-TABLE-IN-QUERY-f-pg-sel ordem-compra


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-9 RECT-7 rs-destino c-arquivo2 ~
c-arquivo bt-config-impr bt-arquivo rs-execucao 
&Scoped-Define DISPLAYED-OBJECTS rs-destino c-arquivo2 c-arquivo ~
rs-execucao 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-arq1 
     IMAGE-UP FILE "image\im-fold":U
     IMAGE-INSENSITIVE FILE "image\ii-fold":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-arquivo 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-config-impr 
     IMAGE-UP FILE "image\im-cfprt":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE VARIABLE c-arquivo AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 256
     SIZE 40 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE c-arquivo2 AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 256
     SIZE 40 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE text-destino AS CHARACTER FORMAT "X(256)":U INITIAL " Destino" 
      VIEW-AS TEXT 
     SIZE 8.57 BY .63 NO-UNDO.

DEFINE VARIABLE text-modo AS CHARACTER FORMAT "X(256)":U INITIAL "Execu‡Æo" 
      VIEW-AS TEXT 
     SIZE 10.86 BY .63 NO-UNDO.

DEFINE VARIABLE rs-destino AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Impressora", 1,
"Arquivo", 2,
"Terminal", 3
     SIZE 44 BY 1.08 NO-UNDO.

DEFINE VARIABLE rs-execucao AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "On-Line", 1,
"Batch", 2
     SIZE 27.72 BY .92 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 49 BY 4.08.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 49.14 BY 1.71.

DEFINE BUTTON bt-imp-ped-compra 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE VARIABLE c-arq-ped-compra AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 256
     SIZE 40 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-texto-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Ordens/Contratos" 
      VIEW-AS TEXT 
     SIZE 18 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Totvs Colabora‡Æo" 
      VIEW-AS TEXT 
     SIZE 21 BY .67 NO-UNDO.

DEFINE VARIABLE rs-param-c AS INTEGER INITIAL 3 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Impressas", 1,
"NÆo Impressas", 2,
"Ambas", 3
     SIZE 24 BY 3 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 29 BY 3.75.

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 47 BY 3.75.

DEFINE VARIABLE tg-envia AS LOGICAL INITIAL no 
     LABEL "Envia E-mail" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .88 NO-UNDO.

DEFINE VARIABLE tg-gera-arq-local AS LOGICAL INITIAL no 
     LABEL "Gera arquivo XML local" 
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .83 NO-UNDO.

DEFINE VARIABLE tg-ped-compra AS LOGICAL INITIAL no 
     LABEL "Envia via Totvs Colabora‡Æo" 
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE i-ordem-fim AS INTEGER FORMAT "zzzzz9,99" INITIAL 99999999 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE i-ordem-ini AS INTEGER FORMAT "zzzzz9,99" INITIAL 0 
     LABEL "Ordem":R7 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE i-pedi-f AS INTEGER FORMAT ">>>>>,>>9" INITIAL 99999999 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE i-pedi-i AS INTEGER FORMAT ">>>>>,>>9" INITIAL 0 
     LABEL "Pedido":R8 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-7
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-8
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-9
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

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
DEFINE QUERY f-pg-sel FOR 
      ordem-compra SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-relat
     bt-executar AT ROW 14.54 COL 3 HELP
          "Dispara a Execu‡Æo do Relat¢rio"
     bt-cancelar AT ROW 14.54 COL 14 HELP
          "Cancelar"
     bt-ajuda AT ROW 14.54 COL 70 HELP
          "Ajuda"
     im-pg-imp AT ROW 1.5 COL 33.57
     im-pg-par AT ROW 1.5 COL 17.86
     im-pg-sel AT ROW 1.5 COL 2.14
     RECT-1 AT ROW 14.29 COL 2
     rt-folder-top AT ROW 2.54 COL 2.14
     rt-folder AT ROW 2.5 COL 2
     rt-folder-left AT ROW 2.54 COL 2.14
     RECT-6 AT ROW 13.75 COL 2.14
     rt-folder-right AT ROW 2.67 COL 80.43
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 81 BY 15
         DEFAULT-BUTTON bt-executar.

DEFINE FRAME f-pg-sel
     i-pedi-i AT ROW 2 COL 15 COLON-ALIGNED
     i-pedi-f AT ROW 2 COL 38 COLON-ALIGNED NO-LABEL
     i-ordem-ini AT ROW 3.5 COL 15 COLON-ALIGNED
     i-ordem-fim AT ROW 3.5 COL 38 COLON-ALIGNED NO-LABEL
     IMAGE-5 AT ROW 2 COL 29
     IMAGE-7 AT ROW 2 COL 37
     IMAGE-8 AT ROW 3.5 COL 29
     IMAGE-9 AT ROW 3.5 COL 37
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 3
         SIZE 76.5 BY 10.5.

DEFINE FRAME f-pg-par
     tg-envia AT ROW 1.5 COL 4
     rs-param-c AT ROW 2 COL 48 NO-LABEL
     tg-ped-compra AT ROW 8.42 COL 4 WIDGET-ID 12
     tg-gera-arq-local AT ROW 9.25 COL 4 WIDGET-ID 14
     bt-imp-ped-compra AT ROW 10.25 COL 44 HELP
          "Escolha do nome do arquivo" WIDGET-ID 16
     c-arq-ped-compra AT ROW 10.29 COL 4 HELP
          "Nome do arquivo de destino do relat¢rio" NO-LABEL WIDGET-ID 6
     fi-texto-1 AT ROW 1.25 COL 46 COLON-ALIGNED NO-LABEL
     FILL-IN-2 AT ROW 7.42 COL 4 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     RECT-10 AT ROW 1.5 COL 47
     RECT-14 AT ROW 7.75 COL 3 WIDGET-ID 8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 3
         SIZE 76.5 BY 10.5.

DEFINE FRAME f-pg-imp
     rs-destino AT ROW 2.5 COL 4 HELP
          "Destino de Impressao do Relatorio" NO-LABEL
     c-arquivo2 AT ROW 3.75 COL 4 HELP
          "Nome do Arquivo de Destino do Relat¢rio" NO-LABEL
     c-arquivo AT ROW 3.75 COL 4 HELP
          "Nome do Arquivo de Destino do Relat¢rio" NO-LABEL
     bt-config-impr AT ROW 3.75 COL 44 HELP
          "Configura‡Æo da Impressora"
     bt-arquivo AT ROW 3.75 COL 44 HELP
          "Escolha do Nome do Arquivo"
     bt-arq1 AT ROW 3.75 COL 44 HELP
          "Configura‡Æo da impressora"
     rs-execucao AT ROW 7 COL 2.86 HELP
          "Modo de Execu‡Æo" NO-LABEL
     text-destino AT ROW 1.75 COL 3 NO-LABEL
     text-modo AT ROW 6.25 COL 1.14 COLON-ALIGNED NO-LABEL
     RECT-9 AT ROW 6.54 COL 2
     RECT-7 AT ROW 2 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 3
         SIZE 76.5 BY 10.5.


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
         TITLE              = "EmissÆo de Pedidos"
         HEIGHT             = 15.38
         WIDTH              = 81.57
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
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-pg-imp
   FRAME-NAME                                                           */
/* SETTINGS FOR BUTTON bt-arq1 IN FRAME f-pg-imp
   NO-ENABLE                                                            */
ASSIGN 
       bt-arq1:HIDDEN IN FRAME f-pg-imp           = TRUE.

/* SETTINGS FOR FILL-IN text-destino IN FRAME f-pg-imp
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN 
       text-destino:PRIVATE-DATA IN FRAME f-pg-imp     = 
                "Destino".

/* SETTINGS FOR FILL-IN text-modo IN FRAME f-pg-imp
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       text-modo:PRIVATE-DATA IN FRAME f-pg-imp     = 
                "Execu‡Æo".

/* SETTINGS FOR FRAME f-pg-par
                                                                        */
/* SETTINGS FOR BUTTON bt-imp-ped-compra IN FRAME f-pg-par
   NO-ENABLE                                                            */
/* SETTINGS FOR EDITOR c-arq-ped-compra IN FRAME f-pg-par
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-texto-1 IN FRAME f-pg-par
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       fi-texto-1:PRIVATE-DATA IN FRAME f-pg-par     = 
                "Ordens/Contratos".

/* SETTINGS FOR RADIO-SET rs-param-c IN FRAME f-pg-par
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX tg-gera-arq-local IN FRAME f-pg-par
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME f-pg-sel
                                                                        */
/* SETTINGS FOR FILL-IN i-ordem-fim IN FRAME f-pg-sel
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-ordem-ini IN FRAME f-pg-sel
   NO-ENABLE                                                            */
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

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-pg-sel
/* Query rebuild information for FRAME f-pg-sel
     _TblList          = "mgind.ordem-compra"
     _Query            is NOT OPENED
*/  /* FRAME f-pg-sel */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* EmissÆo de Pedidos */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
   RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* EmissÆo de Pedidos */
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
&Scoped-define SELF-NAME bt-arq1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-arq1 C-Win
ON CHOOSE OF bt-arq1 IN FRAME f-pg-imp
DO:
   run utp/ut-dir.p (input return-value, output c-pasta, output l-cancelado).
   
   if l-cancelado = no then do:
        assign c-arquivo2:screen-value in frame f-pg-imp = c-pasta.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
&Scoped-define SELF-NAME bt-imp-ped-compra
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-imp-ped-compra C-Win
ON CHOOSE OF bt-imp-ped-compra IN FRAME f-pg-par
DO:
    DEFINE VARIABLE c-dir AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE l-cancelado AS LOGICAL  NO-UNDO.
  
    run utp/ut-dir.p(input "Selecione o diret¢rio.",
                   output c-dir,
                   output l-cancelado).
    if  not l-cancelado then 
      
      if length(c-dir) > 3 
      and substr(c-dir,length(c-dir),1) <> "~\" 
      then assign c-arq-ped-compra:SCREEN-VALUE IN FRAME f-pg-par = (c-dir + "~\")
                  c-arq-ped-compra = (c-dir + "~\"). 
      else assign c-arq-ped-compra:SCREEN-VALUE IN FRAME f-pg-par = c-dir
                  c-arq-ped-compra = c-dir. 

    
    /*RUN pi-salva-arq.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-sel
&Scoped-define SELF-NAME i-ordem-fim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-ordem-fim C-Win
ON LEAVE OF i-ordem-fim IN FRAME f-pg-sel
DO:
assign i-ordem-fim = input frame f-pg-sel i-ordem-fim.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-ordem-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-ordem-ini C-Win
ON LEAVE OF i-ordem-ini IN FRAME f-pg-sel /* Ordem */
DO:

assign i-ordem-ini = input frame f-pg-sel i-ordem-ini.
  
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
                   c-arquivo2:sensitive    = no
                   c-arquivo2:visible      = no
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


&Scoped-define FRAME-NAME f-pg-par
&Scoped-define SELF-NAME tg-envia
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-envia C-Win
ON VALUE-CHANGED OF tg-envia IN FRAME f-pg-par /* Envia E-mail */
DO:

if input frame f-pg-par tg-envia 
then do with frame f-pg-imp:
    find first param-compra no-lock no-error.
    assign rs-destino:screen-value  = "3"
           c-arquivo:hidden         = yes
           c-arquivo2:sensitive     = yes
           c-arquivo2:hidden        = no
           c-arquivo2:screen-value in frame f-pg-imp = trim(substr(param-compra.char-1,51,50)) when avail param-compra
           bt-arquivo:hidden       = yes
           bt-arq1:hidden          = no
           bt-arq1:sensitive       = yes
           bt-config-impr:hidden   = yes
           rs-destino:sensitive    = no
           rs-execucao:sensitive   = no.
            /*l-bus-to-bus.*/
end.
else do with frame f-pg-imp:
    /*enable rs-destino. 
           l-bus-to-bus.*/
    assign c-arquivo2:sensitive    = no
           c-arquivo2:visible      = no
           c-arquivo2:screen-value in frame f-pg-imp = " "
           bt-arq1:visible         = no
           bt-arq1:sensitive       = no
           rs-destino:sensitive    = yes
           rs-execucao:sensitive   = yes.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-gera-arq-local
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-gera-arq-local C-Win
ON VALUE-CHANGED OF tg-gera-arq-local IN FRAME f-pg-par /* Gera arquivo XML local */
DO:
    IF tg-gera-arq-local:CHECKED IN FRAME f-pg-par THEN DO:
        ASSIGN c-arq-ped-compra:SENSITIVE    IN FRAME f-pg-par = YES
               bt-imp-ped-compra:SENSITIVE   IN FRAME f-pg-par = YES
               c-arq-ped-compra:SCREEN-VALUE IN FRAME f-pg-par = REPLACE(INPUT FRAME f-pg-par c-arq-ped-compra, "\", "/").       
    END.
    ELSE
        ASSIGN c-arq-ped-compra:SENSITIVE  IN FRAME f-pg-par = NO
               bt-imp-ped-compra:SENSITIVE IN FRAME f-pg-par = NO.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-ped-compra
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-ped-compra C-Win
ON VALUE-CHANGED OF tg-ped-compra IN FRAME f-pg-par /* Envia via Totvs Colabora‡Æo */
DO:
    IF tg-ped-compra:CHECKED IN FRAME f-pg-par THEN
        ASSIGN tg-gera-arq-local:SENSITIVE IN FRAME f-pg-par = YES.
    ELSE
        ASSIGN tg-gera-arq-local:SENSITIVE IN FRAME f-pg-par = NO
               tg-gera-arq-local:CHECKED   IN FRAME f-pg-par = NO.

    APPLY 'VALUE-CHANGED':U TO tg-gera-arq-local IN FRAME f-pg-par.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

{utp/ut9000.i "CC0305" "2.00.00.040"}

/* inicializa»„es do template de relat¢rio */
{include/i-rpini.i}

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

{include/i-rplbl.i}

ON "~\" OF C-ARQUIVO2 IN FRAME F-PG-IMP do:
    apply "/" to C-ARQUIVO2 in frame F-PG-IMP.
    return no-apply.       
end.


/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    RUN enable_UI.

    find first param-global no-lock no-error.
    find first param-compra no-lock no-error.

    if not param-compra.log-2 then
       tg-envia:sensitive in frame f-pg-par = no.

    {include/i-rpmbl.i}
    
        RUN pi-atualiza-campo.

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
  ENABLE im-pg-imp im-pg-par im-pg-sel bt-executar bt-cancelar bt-ajuda 
      WITH FRAME f-relat IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-relat}
  DISPLAY rs-destino c-arquivo2 c-arquivo rs-execucao 
      WITH FRAME f-pg-imp IN WINDOW C-Win.
  ENABLE RECT-9 RECT-7 rs-destino c-arquivo2 c-arquivo bt-config-impr 
         bt-arquivo rs-execucao 
      WITH FRAME f-pg-imp IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-imp}
  DISPLAY tg-envia rs-param-c tg-ped-compra tg-gera-arq-local c-arq-ped-compra 
          FILL-IN-2 
      WITH FRAME f-pg-par IN WINDOW C-Win.
  ENABLE RECT-10 RECT-14 tg-envia tg-ped-compra FILL-IN-2 
      WITH FRAME f-pg-par IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-par}
  DISPLAY i-pedi-i i-pedi-f i-ordem-ini i-ordem-fim 
      WITH FRAME f-pg-sel IN WINDOW C-Win.
  ENABLE IMAGE-5 IMAGE-7 IMAGE-8 IMAGE-9 i-pedi-i i-pedi-f 
      WITH FRAME f-pg-sel IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-sel}
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize C-Win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

 
  assign bt-arq1:visible      in frame f-pg-imp = no
         bt-arq1:sensitive    in frame f-pg-imp = no
         c-arquivo2:sensitive in frame f-pg-imp = no
         c-arquivo2:visible   in frame f-pg-imp = no.
         
  apply "value-changed" to rs-destino in frame {&FRAME-NAME}.
  
    
  if  param-compra.log-2 then 
     enable tg-envia with frame f-pg-par.
  else
     disable tg-envia with frame f-pg-par.

  apply "mouse-select-click" to im-pg-sel in frame f-relat.
      
  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualiza-campo C-Win 
PROCEDURE pi-atualiza-campo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
     /****************** Valida‡Æo de slot do TOTVS Colabora‡Æo ******************/
    DEFINE VARIABLE l-colab AS LOGICAL NO-UNDO.
    
    /* RUN cdp/cd0029.p (output l-colab). */
    
    IF l-colab THEN DO:
        FIND FIRST param-global NO-LOCK NO-ERROR.
        IF &IF '{&bf_dis_versao_ems}' >= '2.09' &THEN
              param-global.log-integr-totvs-colab
           &ELSE
              SUBSTRING(param-global.char-2,35,1) = "S":U
           &ENDIF
        THEN DO:
            ASSIGN l-totvs-colab = YES.
        END.
        ELSE
            ASSIGN l-totvs-colab = NO.
    END.
    ELSE
        ASSIGN l-totvs-colab = NO.
    
    IF NOT l-totvs-colab THEN
        ASSIGN tg-ped-compra:SENSITIVE IN FRAME f-pg-par = NO.
    ELSE
        ASSIGN tg-ped-compra:SENSITIVE IN FRAME f-pg-par = YES
               c-arq-ped-compra:SCREEN-VALUE IN FRAME f-pg-par = SESSION:TEMP-DIRECTORY.           
        
     /*Fim Valida‡Æo de slot do TOTVS Colabora‡Æo */ 
    RETURN "OK":U.

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

    if  input frame f-pg-imp rs-destino = 2 
    then do:
        run utp/ut-vlarq.p (input input frame f-pg-imp c-arquivo).
        if  return-value = "nok" then do:
            run utp/ut-msgs.p (input "show", input 73, input "").
            apply 'mouse-select-click' to im-pg-imp in frame f-relat.
            apply 'entry' to c-arquivo in frame f-pg-imp.
            return error.
        end.
    end.
    
    if input frame f-pg-par tg-envia then do:
        assign file-info:file-name = trim(input frame f-pg-imp c-arquivo2).
        if file-info:file-type = ? then do:
            run utp/ut-msgs.p (input "show", input 3943, input input frame f-pg-imp c-arquivo2).
            apply 'mouse-select-click' to im-pg-imp in frame f-relat.
            apply "entry" to c-arquivo2 in frame f-pg-imp.
            return "adm-error".
        end.
    end.
    
    /* Coloque aqui as valida‡äes das outras pÿginas, lembrando que elas
       devem apresentar uma mensagem de erro cadastrada, posicionar na pÿgina 
       com problemas e colocar o focus no campo com problemas             */    

    find first param-global no-lock no-error.
    if  not avail param-global then do:
        run utp/ut-msgs.p (input "show", input 16, input "").
        return error.
    end.
    
    find first param-compra no-lock no-error.
    if  not avail param-compra then do:
        run utp/ut-msgs.p (input "show", input 2587, input "").
        return error.
    end.

    /* find first param_email no-lock no-error.

    if  input frame f-pg-par tg-envia then do:
        IF AVAIL param_email THEN DO:
            if param_email.cod_servid_e_mail  = "" and param_email.num_porta = 0 then do:
                run utp/ut-msgs.p (input "show", input 53445, input "").
                apply 'mouse-select-click' to im-pg-par in frame f-relat.
                apply 'entry'              to tg-envia  in frame f-pg-par.
                return error.
            end.
        END.
    end. */

    IF l-totvs-colab AND tg-gera-arq-local:CHECKED IN FRAME f-pg-par THEN DO:
        RUN pi-valida-diretorio.
        IF RETURN-VALUE = "NOK":U THEN DO:
            RUN utp/ut-msgs.p (INPUT "show", INPUT 73, INPUT "").
            APPLY 'entry' TO c-arq-ped-compra IN FRAME f-pg-par.                   
            RETURN ERROR.
        END.
    END.

    create tt-param.
    assign tt-param.usuario           = c-seg-usuario
           tt-param.destino           = input frame f-pg-imp rs-destino
           tt-param.data-exec         = today
           tt-param.hora-exec         = time
           tt-param.i-pedi-i          = input frame f-pg-sel i-pedi-i
           tt-param.i-pedi-f          = input frame f-pg-sel i-pedi-f
           tt-param.l-narrativa-item  = YES
           tt-param.l-narrativa-ordem = YES
           tt-param.l-bus-to-bus      = NO
           tt-param.l-descricao       = NO
           tt-param.l-impressao       = NO
           tt-param.i-param-c         = input frame f-pg-par rs-param-c
           tt-param.i-ordem-ini       = input frame f-pg-sel i-ordem-ini
           tt-param.i-ordem-fim       = input frame f-pg-sel i-ordem-fim
           tt-param.l-envia           = input frame f-pg-par tg-envia
           tt-param.l-eprocurement    = NO
           &IF "{&bf_mat_versao_ems}" >= "2.062" &THEN 
           tt-param.l-integra-portal  = NO 
           &ENDIF
           
           tt-param.l-ped-compra     = input frame f-pg-par tg-ped-compra
           tt-param.l-gera-arq-local = input frame f-pg-par tg-gera-arq-local
           tt-param.c-arq-ped-compra   = input frame f-pg-par c-arq-ped-compra
           .
    
    if  tt-param.l-envia then 
        assign tt-param.diretorio = input frame f-pg-imp c-arquivo2.

    if  tt-param.destino = 1 then
        assign tt-param.arquivo = "".
    else
    if  tt-param.destino = 2 then 
        assign tt-param.arquivo = input frame f-pg-imp c-arquivo.
    else
        assign tt-param.arquivo = session:temp-directory + c-programa-mg97 + ".tmp".
    
    /* Coloque aqui a l¢gica de grava‡Æo dos parƒmtros e sele‡Æo na temp-table
       tt-param */ 

    {include/i-rpexb.i}

    if  session:set-wait-state("general") then.
    
    {include/i-rprun.i ccp/cc0305rp.p}
    
    /* {include/i-rpexc.i} */

    if  session:set-wait-state("") then.
    
    /*
    if not tt-param.l-envia then do:
        {include/i-rptrm.i}
    end.
    
    */
         
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-salva-arq C-Win 
PROCEDURE pi-salva-arq :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    def var c-arq-ped  as char no-undo.

    /* tech1139 - FO 1223.694  - 02/11/2005 */
    assign c-arq-ped = replace(input frame f-pg-par c-arq-ped-compra, "/", CHR(92)).
    /* tech1139 - FO 1223.694  - 02/11/2005 */

        
    /*tech14178 modificado para apresentar dialog com extensÊo PDF quando o mesmo estiver sendo usado */
    &IF "{&PDF}" = "YES" &THEN /*tech868*/
        
        IF NOT usePDF() THEN
    
    &ENDIF
        
            SYSTEM-DIALOG GET-FILE c-arq-ped
               FILTERS "*.xml" "*.xml",
                       "*.*" "*.*"
               ASK-OVERWRITE 
               DEFAULT-EXTENSION "xml"
               INITIAL-DIR "spool" 
               SAVE-AS
               USE-FILENAME
               UPDATE l-ok.
    
    &IF "{&PDF}" = "YES" &THEN /*tech868*/
       ELSE
           SYSTEM-DIALOG GET-FILE c-arq-ped
              FILTERS "*.pdf" "*.pdf",
                      "*.*" "*.*"
              ASK-OVERWRITE 
              DEFAULT-EXTENSION "pdf"
              INITIAL-DIR "spool" 
              SAVE-AS
              USE-FILENAME
              UPDATE l-ok.
    
    &endif
    
    if  l-ok = yes then do:
        /* tech1139 - FO 1223.694  - 02/11/2005 */
        assign c-arq-ped-compra = replace(c-arq-ped, CHR(92), "/"). 
        /* tech1139 - FO 1223.694  - 02/11/2005 */
        display c-arq-ped-compra with frame f-pg-par.
    end.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-troca-pagina C-Win 
PROCEDURE pi-troca-pagina :
/*------------------------------------------------------------------------------
  Purpose: Gerencia a Troca de Pÿgina (folder)   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

{include/i-rptrp.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-valida-diretorio C-Win 
PROCEDURE pi-valida-diretorio :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR c-dir  AS CHAR NO-UNDO.
    DEF VAR c-dir1 AS CHAR NO-UNDO.
    DEF VAR i-poss AS INT  NO-UNDO.
    DEF VAR i-num  AS INT  NO-UNDO.
    DEF VAR i-cont AS INT  NO-UNDO.

    ASSIGN c-dir = INPUT FRAME f-pg-par c-arq-ped-compra.
    
    ASSIGN i-num = LENGTH(c-dir).

    REPEAT i-cont = 1 TO i-num:   
        IF SUBSTRING(c-dir,i-cont,1) = "/":U OR
           SUBSTRING(c-dir,i-cont,1) = "\":U THEN
            ASSIGN i-poss = i-cont.
    END.

    ASSIGN c-dir1 = SUBSTRING(c-dir,1,i-poss)
           FILE-INFO:FILE-NAME = c-dir1.

    IF FILE-INFO:FULL-PATHNAME = ? THEN
        RETURN "NOK":U.
    ELSE
        RETURN "OK":U.

    RETURN "OK":U.

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
  {src/adm/template/snd-list.i "ordem-compra"}

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

