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
{include/i-prgvrs.i FT0603 2.00.00.030 } /*** 010030 ***/

DEFINE BUFFER portador FOR ems2log.portador.


&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i ft0603 MFT}
&ENDIF

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
/* Obs: Retirar o valor do preprocessador para as p ginas que nÆo existirem  */

&GLOBAL-DEFINE PGSEL f-pg-sel
&GLOBAL-DEFINE PGCLA 
&GLOBAL-DEFINE PGPAR f-pg-par
&GLOBAL-DEFINE PGDIG 
&GLOBAL-DEFINE PGIMP f-pg-imp

/* Parameters Definitions ---                                           */

/* Temporary Table Definitions ---                                      */

define temp-table tt-param
    field destino             as integer
    field arquivo             as char
    field usuario             as char
    field data-exec           as date
    field hora-exec           as integer
    field classifica          as integer
    field da-emissao-ini      as date
    field da-emissao-fim      as date
    field c-estabel-ini       as char
    field c-serie-ini         as char
    field c-serie-fim         as char
    field c-nota-fis-ini      as char
    field c-nota-fis-fim      as char
    field de-embarque-ini     like nota-fiscal.cdd-embarq
    field de-embarque-fim     like nota-fiscal.cdd-embarq
    field i-cod-portador      as integer
    field rs-gera-titulo      as integer
    field desc-titulo         as char format "x(35)"
    field i-pais              as int
    field c-estabel-fim       as char
    field c-arquivo-exp       as char
    FIELD l-processa-convenio AS LOG
    FIELD l-processa-servico  AS LOG
    FIELD l-processa-cheque   AS LOG.


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

{utp/ut-glob.i}

{cdp/cdapi3001.i MFT YES} /* inicializa‡Æo da seguran‡a por estabelecimento */

ON FIND OF estabelec do:
    FIND param_seg_estab 
        WHERE param_seg_estab.cdn_param = 1004  /* Modulo de Faturamento */
        NO-LOCK NO-ERROR.

    IF AVAIL param_seg_estab
    AND param_seg_estab.des_valor = "SIM":U then do:
        IF  NOT CAN-FIND(tt_estab_ems2 WHERE
                tt_estab_ems2.tta_cod_estab = estabelec.cod-estabel) THEN return error.                 
    END.
END.

{ftp/ftapi207.i} /* Multi-planta */
{cdp/cdcfgdis.i} /* pre-processador */
{cdp/cd7300.i1}

def var l-ok               as logical no-undo.
def var c-arq-digita       as char    no-undo.
def var c-terminal         as char    no-undo.
def var l-atual            as logical no-undo.
def var l-usa-mp           as logical no-undo.
DEF VAR i-empresa          LIKE param-global.empresa-pri no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-relat
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-pg-imp

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-7 RECT-9 rs-destino bt-arquivo ~
bt-config-impr c-arquivo rs-execucao 
&Scoped-Define DISPLAYED-OBJECTS rs-destino c-arquivo rs-execucao 

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
     SIZE 4 BY 1.

DEFINE BUTTON bt-config-impr 
     IMAGE-UP FILE "image\im-cfprt":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE VARIABLE c-arquivo AS CHARACTER 
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
     SIZE 46.29 BY 2.92.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.29 BY 1.71.

DEFINE VARIABLE c-arquivo-exp AS CHARACTER FORMAT "X(256)":U INITIAL "spool~\lin-i-cr.d" 
     LABEL "Exportar para" 
     VIEW-AS FILL-IN 
     SIZE 29.29 BY .92 NO-UNDO.

DEFINE VARIABLE c-desc-portador AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 35.57 BY .88 NO-UNDO.

DEFINE VARIABLE i-portador AS INTEGER FORMAT ">>,>>9" INITIAL 0 
     LABEL "Portador":R10 
     VIEW-AS FILL-IN 
     SIZE 7.14 BY .88.

DEFINE VARIABLE text-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Forma de Gera‡Æo dos T¡tulos" 
      VIEW-AS TEXT 
     SIZE 24 BY .67 NO-UNDO.

DEFINE VARIABLE text-exporta AS CHARACTER FORMAT "X(256)":U INITIAL "Exporta‡Æo" 
      VIEW-AS TEXT 
     SIZE 10.29 BY .63 NO-UNDO.

DEFINE VARIABLE rs-gera-titulo AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Gera t¡tulo para o cliente", 0,
"Gera t¡tulo para o endere‡o de cobran‡a do cliente", 1
     SIZE 39.86 BY 1.83 NO-UNDO.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 43.29 BY 3.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 75.14 BY 1.88.

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31.72 BY 3.42.

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 43.57 BY 2.33.

DEFINE VARIABLE tg-processa-cheque AS LOGICAL INITIAL no 
     LABEL "Cupons Cheque" 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 NO-UNDO.

DEFINE VARIABLE tg-processa-convenio AS LOGICAL INITIAL no 
     LABEL "Cupons Convˆnio" 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 NO-UNDO.

DEFINE VARIABLE tg-processa-servico AS LOGICAL INITIAL no 
     LABEL "Notas Fiscais de Servi‡o" 
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY .83 NO-UNDO.

DEFINE VARIABLE c-estabel-fim LIKE estabelec.cod-estabel
     VIEW-AS FILL-IN 
     SIZE 7.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-estabel-ini LIKE estabelec.cod-estabel
     LABEL "Estabelecimento":R7 
     VIEW-AS FILL-IN 
     SIZE 7.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-nr-nota-fim AS CHARACTER FORMAT "X(16)" INITIAL "9999999999" 
     VIEW-AS FILL-IN 
     SIZE 17.43 BY .88.

DEFINE VARIABLE c-nr-nota-ini AS CHARACTER FORMAT "x(16)" INITIAL "0" 
     LABEL "Nr Nota Fiscal":R17 
     VIEW-AS FILL-IN 
     SIZE 17.43 BY .88.

DEFINE VARIABLE c-serie-fim AS CHARACTER FORMAT "x(5)" INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 9.43 BY .88.

DEFINE VARIABLE c-serie-ini AS CHARACTER FORMAT "x(5)" 
     LABEL "S‚rie":R7 
     VIEW-AS FILL-IN 
     SIZE 9.43 BY .88.

DEFINE VARIABLE da-emissao-fim AS DATE FORMAT "99/99/9999" 
     VIEW-AS FILL-IN 
     SIZE 12.86 BY .88.

DEFINE VARIABLE da-emissao-ini AS DATE FORMAT "99/99/9999" 
     LABEL "Data da EmissÆo":R18 
     VIEW-AS FILL-IN 
     SIZE 12.86 BY .88.

DEFINE VARIABLE de-embarque-fim AS DECIMAL FORMAT ">>>>>>>>>>>>>>>9" INITIAL 9999999999999999 
     VIEW-AS FILL-IN 
     SIZE 17.43 BY .88.

DEFINE VARIABLE de-embarque-ini AS DECIMAL FORMAT ">>>>>>>>>>>>>>>9" INITIAL 0 
     LABEL "Embarque":R10 
     VIEW-AS FILL-IN 
     SIZE 17.43 BY .88.

DEFINE IMAGE IMAGE-10
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-11
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-23
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-24
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-3
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-4
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-8
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-9
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE BUTTON bt-ajuda 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-cancelar AUTO-END-KEY 
     LABEL "Fechar" 
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


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-pg-imp
     rs-destino AT ROW 2.38 COL 3.29 HELP
          "Destino de ImpressÆo do Relat¢rio" NO-LABEL
     bt-arquivo AT ROW 3.58 COL 43.29 HELP
          "Escolha do nome do arquivo"
     bt-config-impr AT ROW 3.58 COL 43.29 HELP
          "Configura‡Æo da impressora"
     c-arquivo AT ROW 3.63 COL 3.29 HELP
          "Nome do arquivo de destino do relat¢rio" NO-LABEL
     rs-execucao AT ROW 5.75 COL 3 HELP
          "Modo de Execu‡Æo" NO-LABEL
     text-destino AT ROW 1.63 COL 3.86 NO-LABEL
     text-modo AT ROW 5 COL 1.29 COLON-ALIGNED NO-LABEL
     RECT-7 AT ROW 1.92 COL 2.14
     RECT-9 AT ROW 5.29 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 3
         SIZE 73.72 BY 10.

DEFINE FRAME f-relat
     bt-executar AT ROW 14.54 COL 3 HELP
          "Dispara a execu‡Æo do relat¢rio"
     bt-cancelar AT ROW 14.54 COL 14 HELP
          "Cancelar"
     bt-ajuda AT ROW 14.54 COL 70 HELP
          "Ajuda"
     rt-folder AT ROW 2.5 COL 2
     rt-folder-right AT ROW 2.67 COL 79.29
     RECT-1 AT ROW 14.29 COL 2
     RECT-6 AT ROW 13.75 COL 2.14
     rt-folder-top AT ROW 2.54 COL 2.14
     rt-folder-left AT ROW 2.54 COL 2.14
     im-pg-imp AT ROW 1.5 COL 33.29
     im-pg-par AT ROW 1.5 COL 17.72
     im-pg-sel AT ROW 1.5 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 81.43 BY 15.46
         DEFAULT-BUTTON bt-executar.

DEFINE FRAME f-pg-sel
     da-emissao-ini AT ROW 2.54 COL 20.72 COLON-ALIGNED
     da-emissao-fim AT ROW 2.54 COL 47.57 COLON-ALIGNED NO-LABEL
     de-embarque-ini AT ROW 3.54 COL 20.72 COLON-ALIGNED
     de-embarque-fim AT ROW 3.54 COL 47.57 COLON-ALIGNED NO-LABEL
     c-nr-nota-ini AT ROW 4.54 COL 20.72 COLON-ALIGNED
     c-nr-nota-fim AT ROW 4.54 COL 47.57 COLON-ALIGNED NO-LABEL
     c-serie-ini AT ROW 5.54 COL 20.72 COLON-ALIGNED
     c-serie-fim AT ROW 5.54 COL 47.57 COLON-ALIGNED NO-LABEL
     c-estabel-ini AT ROW 6.54 COL 20.72 COLON-ALIGNED HELP
          ""
          LABEL "Estabelecimento":R7
     c-estabel-fim AT ROW 6.54 COL 47.57 COLON-ALIGNED HELP
          "" NO-LABEL
     IMAGE-10 AT ROW 5.54 COL 45
     IMAGE-11 AT ROW 3.54 COL 45
     IMAGE-23 AT ROW 6.54 COL 41
     IMAGE-24 AT ROW 6.54 COL 45
     IMAGE-3 AT ROW 2.54 COL 41
     IMAGE-4 AT ROW 4.54 COL 41
     IMAGE-5 AT ROW 5.54 COL 41
     IMAGE-6 AT ROW 3.54 COL 41
     IMAGE-8 AT ROW 2.54 COL 45
     IMAGE-9 AT ROW 4.54 COL 45
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 2.85
         SIZE 76.86 BY 10.62.

DEFINE FRAME f-pg-par
     i-portador AT ROW 1.71 COL 21 COLON-ALIGNED
     c-desc-portador AT ROW 1.71 COL 28.29 COLON-ALIGNED NO-LABEL
     tg-processa-convenio AT ROW 4.25 COL 48 WIDGET-ID 6
     rs-gera-titulo AT ROW 4.33 COL 4.43 NO-LABEL
     tg-processa-servico AT ROW 5.08 COL 48 WIDGET-ID 8
     tg-processa-cheque AT ROW 5.92 COL 48 WIDGET-ID 12
     c-arquivo-exp AT ROW 8.17 COL 12 COLON-ALIGNED
     text-1 AT ROW 3.33 COL 3.86 NO-LABEL
     text-exporta AT ROW 7.17 COL 2 COLON-ALIGNED NO-LABEL
     "Processamento" VIEW-AS TEXT
          SIZE 12 BY .54 AT ROW 3.33 COL 47 WIDGET-ID 10
     RECT-12 AT ROW 3.58 COL 2.29
     RECT-13 AT ROW 1.17 COL 2.29
     RECT-15 AT ROW 7.42 COL 2.14
     RECT-14 AT ROW 3.58 COL 46 WIDGET-ID 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 2.92
         SIZE 77.29 BY 10.33
         FONT 1.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-relat
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "<insert window title>"
         HEIGHT             = 15.46
         WIDTH              = 81.43
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
/* SETTINGS FOR FILL-IN c-desc-portador IN FRAME f-pg-par
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN text-1 IN FRAME f-pg-par
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
/* SETTINGS FOR FILL-IN text-exporta IN FRAME f-pg-par
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       text-exporta:PRIVATE-DATA IN FRAME f-pg-par     = 
                "Exporta‡Æo".

/* SETTINGS FOR FRAME f-pg-sel
                                                                        */
/* SETTINGS FOR FILL-IN c-estabel-fim IN FRAME f-pg-sel
   LIKE = mgadm.estabelec.cod-estabel EXP-LABEL EXP-SIZE                */
/* SETTINGS FOR FILL-IN c-estabel-ini IN FRAME f-pg-sel
   LIKE = mgadm.estabelec.cod-estabel EXP-LABEL EXP-SIZE                */
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
     _Query            is NOT OPENED
*/  /* FRAME f-pg-sel */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* <insert window title> */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
   RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* <insert window title> */
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
ON CHOOSE OF bt-cancelar IN FRAME f-relat /* Fechar */
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


&Scoped-define FRAME-NAME f-pg-sel
&Scoped-define SELF-NAME c-estabel-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-estabel-ini C-Win
ON LEAVE OF c-estabel-ini IN FRAME f-pg-sel /* Estabelecimento */
DO:
    &if defined (bf_dis_consiste_conta) &then
        find estabelec where
             estabelec.cod-estabel = input frame f-pg-sel c-estabel-ini no-lock no-error.  
        IF AVAIL estabelec THEN
            run cdp/cd9970.p (input rowid(estabelec),
                              output i-empresa).
    &endif
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-par
&Scoped-define SELF-NAME i-portador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-portador C-Win
ON F5 OF i-portador IN FRAME f-pg-par /* Portador */
DO:
  {include/zoomvar.i &prog-zoom=adzoom/z01ad209.w   
                     &campo=i-portador
                     &campozoom=cod-portador
                     &parametros="run pi-seta-empresa in wh-pesquisa (input i-empresa)."}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-portador C-Win
ON LEAVE OF i-portador IN FRAME f-pg-par /* Portador */
DO:
      assign l-implanta = yes.
      {include/leave.i &tabela=portador
                       &atributo-ref=nome
                       &variavel-ref=c-desc-portador
                       &where="portador.ep-codigo    = i-empresa and
                               portador.cod-portador = input frame f-pg-par i-portador and
                               portador.modalidade   = 1"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-portador C-Win
ON MOUSE-SELECT-DBLCLICK OF i-portador IN FRAME f-pg-par /* Portador */
DO:
  apply "f5" to self.
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

{utp/ut9000.i "FT0603" "2.00.00.027"}


{include/i-rpini.i}


find first param-global no-lock no-error.

assign i-empresa = param-global.empresa-prin.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

{include/i-rplbl.i}

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    RUN enable_UI.

    /* desabilitar/habilitar os campos da op‡Æo exporta */
    find first para-fat no-lock no-error.
    if  para-fat.int-exp-cr = 1 then /* caso seja integra */
        assign rect-15:sensitive in frame f-pg-par       = no
               text-exporta:sensitive in frame f-pg-par  = no
               c-arquivo-exp:sensitive in frame f-pg-par = no.


    if  i-portador:load-mouse-pointer  ("image/lupa.cur") in frame f-pg-par then.

    assign da-emissao-ini:screen-value in frame f-pg-sel = string(today)
           da-emissao-fim:screen-value in frame f-pg-sel = string(today).

    assign rs-gera-titulo:radio-buttons in frame f-pg-par = {varinc/var00112.i 7}.

    find first para-fat no-lock no-error.
    if  avail para-fat then
       if substr(para-fat.char-1,16,5) = "2"
       then  assign rs-gera-titulo:screen-value in frame f-pg-par = "2".
       else  assign rs-gera-titulo:screen-value in frame f-pg-par = "1".

    {include/i-rpmbl.i}

    &IF "{&mguni_version}" >= "2.071" &THEN
        ASSIGN c-estabel-fim:SCREEN-VALUE IN FRAME f-pg-sel = "ZZZZZ".
    &ELSE
        ASSIGN c-estabel-fim:SCREEN-VALUE IN FRAME f-pg-sel = "ZZZ".
    &ENDIF

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
  DISPLAY da-emissao-ini da-emissao-fim de-embarque-ini de-embarque-fim 
          c-nr-nota-ini c-nr-nota-fim c-serie-ini c-serie-fim c-estabel-ini 
          c-estabel-fim 
      WITH FRAME f-pg-sel IN WINDOW C-Win.
  ENABLE IMAGE-10 IMAGE-11 IMAGE-23 IMAGE-24 IMAGE-3 IMAGE-4 IMAGE-5 IMAGE-6 
         IMAGE-8 IMAGE-9 da-emissao-ini da-emissao-fim de-embarque-ini 
         de-embarque-fim c-nr-nota-ini c-nr-nota-fim c-serie-ini c-serie-fim 
         c-estabel-ini c-estabel-fim 
      WITH FRAME f-pg-sel IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-sel}
  DISPLAY i-portador c-desc-portador tg-processa-convenio rs-gera-titulo 
          tg-processa-servico tg-processa-cheque c-arquivo-exp 
      WITH FRAME f-pg-par IN WINDOW C-Win.
  ENABLE RECT-12 RECT-13 RECT-15 RECT-14 i-portador tg-processa-convenio 
         rs-gera-titulo tg-processa-servico tg-processa-cheque c-arquivo-exp 
      WITH FRAME f-pg-par IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-par}
  DISPLAY rs-destino c-arquivo rs-execucao 
      WITH FRAME f-pg-imp IN WINDOW C-Win.
  ENABLE RECT-7 RECT-9 rs-destino bt-arquivo bt-config-impr c-arquivo 
         rs-execucao 
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

DEF VAR l-ems5 AS LOG NO-UNDO.

do  on error undo, return error
    on stop  undo, return error:     

    {include/i-rpexa.i}

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

    if  input frame f-pg-sel c-estabel-fim < 
        input frame f-pg-sel c-estabel-ini then do:
        run utp/ut-msgs.p (input "show",
                           input 252,
                           input "").
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to c-estabel-ini in frame f-pg-sel.
        return error.
    end.


    if  input frame f-pg-sel c-nr-nota-fim < 
        input frame f-pg-sel c-nr-nota-ini then do:
        run utp/ut-msgs.p (input "show",
                           input 252,
                           input "").
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to c-nr-nota-ini in frame f-pg-sel.
        return error.
    end.

    if  input frame f-pg-sel c-serie-fim < 
        input frame f-pg-sel c-serie-ini then do:
        run utp/ut-msgs.p (input "show",
                           input 252,
                           input "").
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to c-serie-ini in frame f-pg-sel.
        return error.
    end.

    if  input frame f-pg-sel de-embarque-fim <
        input frame f-pg-sel de-embarque-ini then do:
        run utp/ut-msgs.p (input "show",
                           input 252,
                           input "").
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to de-embarque-ini in frame f-pg-sel.
        return error.
    end.

    if  input frame f-pg-sel da-emissao-fim < 
        input frame f-pg-sel da-emissao-ini then do:
        run utp/ut-msgs.p (input "show",
                           input 252,
                           input "").
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to da-emissao-ini in frame f-pg-sel.
        return error.
    end.

    if  input frame f-pg-par i-portador <> 0 then do: 
       find first portador where
                  portador.ep-codigo = i-empresa and
                  portador.modalidade = 1                       and
                  portador.cod-portador = input frame f-pg-par i-portador no-lock no-error.
       if  not avail portador then do:
          {utp/ut-table.i mgadm portador 1}
           run utp/ut-msgs.p (input "show",
                              input 47,
                              input return-value).
           apply 'mouse-select-click' to im-pg-par in frame f-relat.
           apply 'entry' to i-portador in frame f-pg-par.
           return error.
       end.
    end.              

    assign l-usa-mp = no.   
    if  param-global.modulo-mp then do:
            assign c-transacao = "ADM046".
            {cdp/cd7300.i3 "001" c-transacao}
            if  tt-replica-msg.log-replica-msg  = yes then 
                assign l-usa-mp = yes.
    end.

    /* se CR do 5 estiver implantado, nao e necessario o CR do 2 */
    ASSIGN l-ems5 = can-find(funcao where funcao.cd-funcao = "adm-acr-ems-5.00" 
                                      and funcao.ativo     = yes
                                      and funcao.log-1     = yes).

    if  param-global.modulo-cr = no 
    and l-usa-mp = no 
    AND l-ems5   = NO
    and para-fat.int-exp-cr = 1 then do: 
        run utp/ut-msgs.p (input "show",
                        input 1478,
                        input "").
        apply 'mouse-select-click' to im-pg-par in frame f-relat.
        apply 'entry' to i-portador in frame f-pg-par.
        return error.
    end.

    find first para-fat no-lock no-error.
    assign l-atual = if  para-fat.ind-atu-cr
                     and program-name(2) matches "*ft0506*"
                     then yes
                     else no.

/*     IF INPUT FRAME f-pg-par tg-processa-convenio = NO AND                                                                                           */
/*        INPUT FRAME f-pg-par tg-processa-servico  = NO AND                                                                                           */
/*        INPUT FRAME f-pg-par tg-processa-cheque   = NO THEN DO:                                                                                      */
/*                                                                                                                                                     */
/*         run utp/ut-msgs.p (input "show",                                                                                                            */
/*                         input 17006,                                                                                                                */
/*                         input "Processamento deve ser Informado!~~ Deve ser informado ao menos uma das formas de processamento. Favor verificar."). */
/*         apply 'mouse-select-click' to im-pg-par in frame f-relat.                                                                                   */
/*         apply 'entry' to tg-processa-convenio in frame f-pg-par.                                                                                    */
/*         return error.                                                                                                                               */
/*     END.                                                                                                                                            */


    /* Coloque aqui as valida‡äes das outras p ginas, lembrando que elas
       devem apresentar uma mensagem de erro cadastrada, posicionar na p gina 
       com problemas e colocar o focus no campo com problemas             */    

    create tt-param.
    assign tt-param.usuario              = c-seg-usuario
           tt-param.destino              = input frame f-pg-imp rs-destino
           tt-param.data-exec            = today
           tt-param.hora-exec            = time
           tt-param.c-estabel-ini        = input frame f-pg-sel c-estabel-ini
           tt-param.c-estabel-fim        = input frame f-pg-sel c-estabel-fim
           tt-param.da-emissao-ini       = input frame f-pg-sel da-emissao-ini
           tt-param.da-emissao-fim       = input frame f-pg-sel da-emissao-fim
           tt-param.c-nota-fis-ini       = input frame f-pg-sel c-nr-nota-ini
           tt-param.c-nota-fis-fim       = input frame f-pg-sel c-nr-nota-fim
           tt-param.c-serie-ini          = input frame f-pg-sel c-serie-ini
           tt-param.c-serie-fim          = input frame f-pg-sel c-serie-fim
           tt-param.i-cod-portador       = input frame f-pg-par i-portador
           tt-param.de-embarque-ini      = input frame f-pg-sel de-embarque-ini
           tt-param.de-embarque-fim      = input frame f-pg-sel de-embarque-fim
           tt-param.rs-gera-titulo       = input frame f-pg-par rs-gera-titulo
           tt-param.l-processa-convenio  = input frame f-pg-par tg-processa-convenio
           tt-param.l-processa-servico   = input frame f-pg-par tg-processa-servico
           tt-param.l-processa-cheque    = input frame f-pg-par tg-processa-cheque
           tt-param.desc-titulo          = entry((tt-param.rs-gera-titulo - 1) * 2 + 1, 
                                          rs-gera-titulo:radio-buttons in frame f-pg-par)
           tt-param.i-pais               = i-pais-impto-usuario
           tt-param.c-arquivo-exp        = input frame f-pg-par c-arquivo-exp.

    if  tt-param.destino = 1 then
        assign tt-param.arquivo = "".
    else
    if  tt-param.destino = 2 then 
        assign tt-param.arquivo = input frame f-pg-imp c-arquivo.
    else
        assign tt-param.arquivo = session:temp-directory + c-programa-mg97 + ".tmp".

    /* Coloque aqui a l¢gica de grava‡Æo dos parƒmtros e sele‡Æo na temp-table
       tt-param */ 

    /* Limpar o arquivo de saida no diretorio padrao */
    if  tt-param.destino <> 1                                 /* Destino Arquivo */
    and rs-execucao:screen-value in frame f-pg-imp = "1" then /* Execucao On line */
    do:    
        output to value(tt-param.arquivo). 
        output close.
    end.    

    {include/i-rpexb.i}

    if  session:set-wait-state("general") then.

    {include/i-rprun.i ftp/ft0603rp.p}

    {include/i-rpexc.i}

    if  session:set-wait-state("") then.

    {include/i-rptrm.i}

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-troca-pagina C-Win 
PROCEDURE pi-troca-pagina :
/*------------------------------------------------------------------------------
  Purpose: Gerencia a Troca de P gina (folder)   
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

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this w-relat, and there are no
     tables specified in any contained Browse, Query, or Frame. */

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

