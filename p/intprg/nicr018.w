&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME w-livre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-livre 
/*:T *******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
DEFINE BUFFER portador FOR emscad.portador.
{include/i-prgvrs.i XX9999 9.99.99.999}

/* Chamada a include do gerenciador de licenáas. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i <programa> <m¢dulo>}
&ENDIF

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE h-acomp AS HANDLE      NO-UNDO.

DEFINE TEMP-TABLE tt-processados NO-UNDO
    FIELD cod-estabel   LIKE cst-nota-fiscal.cod-estabel
    FIELD serie         LIKE cst-nota-fiscal.serie
    FIELD nr-nota-fis   LIKE cst-nota-fiscal.nr-nota-fis
    FIELD parcela       LIKE cst-fat-duplic.parcela
    FIELD nsu-numero    LIKE cst-fat-duplic.nsu-numero
    FIELD cod-portador  LIKE cst-fat-duplic.cod-portador 
    FIELD valor         LIKE fat-duplic.vl-parcela
    FIELD valor-taxa    LIKE cst-fat-duplic.taxa-admin
    FIELD tipo          AS CHAR
    FIELD mostra        AS LOG INITIAL YES
    FIELD iLinha        AS INT
    FIELD conciliado    LIKE cst-fat-duplic.conciliado-sitef
    FIELD rArquivoSitef AS ROWID.
    .

DEFINE TEMP-TABLE tt-divergencia NO-UNDO
    FIELD cod-estabel     LIKE cst-nota-fiscal.cod-estabel
    FIELD serie           LIKE cst-nota-fiscal.serie
    FIELD nr-nota-fis     LIKE cst-nota-fiscal.nr-nota-fis
    FIELD parcela         LIKE cst-fat-duplic.parcela
    FIELD cod-erro        AS INT COLUMN-LABEL "Erro"
    FIELD obs-divergencia AS CHAR FORMAT "X(600)"
    FIELD clinha          AS CHAR
    FIELD ilinha          AS INT
    FIELD marca           AS LOGICAL FORMAT "*/" INITIAL NO.

DEFINE TEMP-TABLE tt-arquivo-sitef NO-UNDO
    FIELD cCodEstab LIKE cst-fat-duplic.cod-estabel
    FIELD iNumNSU   LIKE cst-fat-duplic.nsu-numero 
    FIELD dPorcTaxa LIKE cst-fat-duplic.taxa-admin 
    FIELD cParcela  LIKE cst-fat-duplic.parcela    
    FIELD dValorLiq LIKE fat-duplic.vl-parcela     
    FIELD dValorBru LIKE fat-duplic.vl-parcela 
    FIELD cNroCupom LIKE cst-fat-duplic.nr-fatura  
    FIELD cTipo     AS CHAR  
    FIELD cLinha    AS CHAR
    FIELD iLinha    AS INT.
    .

DEFINE TEMP-TABLE tt-nao-encontrados NO-UNDO
    FIELD cCodEstab LIKE cst-fat-duplic.cod-estabel
    FIELD iNumNSU   LIKE cst-fat-duplic.nsu-numero
    FIELD dPorcTaxa LIKE cst-fat-duplic.taxa-admin 
    FIELD cParcela  LIKE cst-fat-duplic.parcela    
    FIELD dValorLiq LIKE fat-duplic.vl-parcela     
    FIELD dValorBru LIKE fat-duplic.vl-parcela     
    FIELD cNroCupom LIKE cst-fat-duplic.nr-fatura 
    FIELD cTipo     AS CHAR 
    FIELD cLinha    AS CHAR
    FIELD iLinha    AS INT.
    .

def new global shared var v_rec_portador
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-livre
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-cad
&Scoped-define BROWSE-NAME br-conciliados

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-processados tt-divergencia ~
tt-nao-encontrados

/* Definitions for BROWSE br-conciliados                                */
&Scoped-define FIELDS-IN-QUERY-br-conciliados tt-processados.cod-estabel tt-processados.serie tt-processados.nr-nota-fis tt-processados.parcela tt-processados.nsu-numero tt-processados.cod-portador tt-processados.valor tt-processados.valor-taxa tt-processados.conciliado tt-processados.iLinha   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-conciliados   
&Scoped-define SELF-NAME br-conciliados
&Scoped-define QUERY-STRING-br-conciliados FOR EACH tt-processados WHERE tt-processados.mostra = YES
&Scoped-define OPEN-QUERY-br-conciliados OPEN QUERY {&SELF-NAME} FOR EACH tt-processados WHERE tt-processados.mostra = YES.
&Scoped-define TABLES-IN-QUERY-br-conciliados tt-processados
&Scoped-define FIRST-TABLE-IN-QUERY-br-conciliados tt-processados


/* Definitions for BROWSE br-divergencia                                */
&Scoped-define FIELDS-IN-QUERY-br-divergencia tt-divergencia.marca tt-divergencia.cod-estabel tt-divergencia.serie tt-divergencia.nr-nota-fis tt-divergencia.parcela tt-divergencia.cod-erro tt-divergencia.obs-divergencia tt-divergencia.iLinha   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-divergencia   
&Scoped-define SELF-NAME br-divergencia
&Scoped-define QUERY-STRING-br-divergencia FOR EACH tt-divergencia
&Scoped-define OPEN-QUERY-br-divergencia OPEN QUERY {&SELF-NAME} FOR EACH tt-divergencia.
&Scoped-define TABLES-IN-QUERY-br-divergencia tt-divergencia
&Scoped-define FIRST-TABLE-IN-QUERY-br-divergencia tt-divergencia


/* Definitions for BROWSE br-nao-encontrado                             */
&Scoped-define FIELDS-IN-QUERY-br-nao-encontrado tt-nao-encontrados.cCodEstab tt-nao-encontrados.iNumNSU tt-nao-encontrados.cNroCupom tt-nao-encontrados.cLinha tt-nao-encontrados.iLinha   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-nao-encontrado   
&Scoped-define SELF-NAME br-nao-encontrado
&Scoped-define QUERY-STRING-br-nao-encontrado FOR EACH tt-nao-encontrados
&Scoped-define OPEN-QUERY-br-nao-encontrado OPEN QUERY {&SELF-NAME} FOR EACH tt-nao-encontrados.
&Scoped-define TABLES-IN-QUERY-br-nao-encontrado tt-nao-encontrados
&Scoped-define FIRST-TABLE-IN-QUERY-br-nao-encontrado tt-nao-encontrados


/* Definitions for FRAME FRAME-A                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-A ~
    ~{&OPEN-QUERY-br-conciliados}

/* Definitions for FRAME FRAME-D                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-D ~
    ~{&OPEN-QUERY-br-divergencia}

/* Definitions for FRAME FRAME-E                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-E ~
    ~{&OPEN-QUERY-br-nao-encontrado}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rt-button RECT-1 rt-button-2 im-pg-cla ~
im-pg-par im-pg-sel fi-portador-credito fi-portador-debito BUTTON-1 ~
bt-processar 
&Scoped-Define DISPLAYED-OBJECTS fi-portador-credito fi-nom-credito ~
fi-portador-debito fi-nom-debito fi-arquivo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-livre AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU mi-programa 
       MENU-ITEM mi-consultas   LABEL "Co&nsultas"     ACCELERATOR "CTRL-L"
       MENU-ITEM mi-imprimir    LABEL "&Relat¢rios"    ACCELERATOR "CTRL-P"
       RULE
       MENU-ITEM mi-sair        LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU m_Ajuda 
       MENU-ITEM mi-conteudo    LABEL "&Conteudo"     
       MENU-ITEM mi-sobre       LABEL "&Sobre..."     .

DEFINE MENU m-livre MENUBAR
       SUB-MENU  mi-programa    LABEL "&Nome-do-Programa"
       SUB-MENU  m_Ajuda        LABEL "&Ajuda"        .


/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_p-exihel AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-processar 
     IMAGE-UP FILE "image/toolbar/im-tick.bmp":U
     LABEL "Processar" 
     SIZE 9.43 BY 1.92.

DEFINE BUTTON BUTTON-1 
     IMAGE-UP FILE "image/toolbar/im-open.bmp":U
     LABEL "Button 1" 
     SIZE 5.14 BY 1.46.

DEFINE VARIABLE fi-arquivo AS CHARACTER FORMAT "X(256)":U 
     LABEL "Arquivo" 
     VIEW-AS FILL-IN 
     SIZE 84 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nom-credito AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 27.72 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nom-debito AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 27.72 BY .88 NO-UNDO.

DEFINE VARIABLE fi-portador-credito AS CHARACTER FORMAT "X(256)":U 
     LABEL "Portador CrÇdito" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE fi-portador-debito AS CHARACTER FORMAT "X(256)":U 
     LABEL "Portador DÇdito" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE IMAGE im-pg-cla
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE IMAGE im-pg-par
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE IMAGE im-pg-sel
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 107.72 BY 2.58.

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 119 BY 1.46
     BGCOLOR 7 .

DEFINE RECTANGLE rt-button-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 119 BY 1.46
     BGCOLOR 7 .

DEFINE BUTTON bt-confirmar 
     LABEL "Conciliar" 
     SIZE 15 BY 1.13 TOOLTIP "Conciliar Faturas Selecionadas".

DEFINE VARIABLE fi-tot-conciliados AS INTEGER FORMAT "->>,>>>,>>9":U INITIAL 0 
     LABEL "Total Conciliados" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88
     FONT 2 NO-UNDO.

DEFINE VARIABLE fi-tot-nao-conciliados AS INTEGER FORMAT "->>,>>>,>>9":U INITIAL 0 
     LABEL "Total n∆o Conciliados" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88
     FONT 2 NO-UNDO.

DEFINE VARIABLE vl-tot-conciliados AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0 
     LABEL "Valor Conciliados" 
     VIEW-AS FILL-IN 
     SIZE 17.57 BY .88
     FONT 2 NO-UNDO.

DEFINE VARIABLE vl-tot-nao-conciliados AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0 
     LABEL "Valor n∆o Conciliados" 
     VIEW-AS FILL-IN 
     SIZE 17.57 BY .88
     FONT 2 NO-UNDO.

DEFINE BUTTON bt-proc-erro 
     LABEL "Processar Erro" 
     SIZE 16.57 BY 1.08.

DEFINE BUTTON bt-sel-erro 
     LABEL "Selecionar Erro" 
     SIZE 16.57 BY 1.08.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-conciliados FOR 
      tt-processados SCROLLING.

DEFINE QUERY br-divergencia FOR 
      tt-divergencia SCROLLING.

DEFINE QUERY br-nao-encontrado FOR 
      tt-nao-encontrados SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-conciliados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-conciliados w-livre _FREEFORM
  QUERY br-conciliados DISPLAY
      tt-processados.cod-estabel
 tt-processados.serie      
 tt-processados.nr-nota-fis
 tt-processados.parcela     
 tt-processados.nsu-numero  
 tt-processados.cod-portador
 tt-processados.valor       
 tt-processados.valor-taxa
 tt-processados.conciliado COLUMN-LABEL "Conc. Sitef" FORMAT "Sim/N∆o"
 tt-processados.iLinha COLUMN-LABEL "Nr. Linha"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 116.57 BY 16.63
         FONT 2 ROW-HEIGHT-CHARS .55.

DEFINE BROWSE br-divergencia
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-divergencia w-livre _FREEFORM
  QUERY br-divergencia DISPLAY
      tt-divergencia.marca COLUMN-LABEL " * " WIDTH 1
 tt-divergencia.cod-estabel    
 tt-divergencia.serie          
 tt-divergencia.nr-nota-fis    
 tt-divergencia.parcela        
 tt-divergencia.cod-erro  WIDTH 4
 tt-divergencia.obs-divergencia COLUMN-LABEL "Divergàngia"
 tt-divergencia.iLinha COLUMN-LABEL "Nr. Linha"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 116.57 BY 17.46
         FONT 2 ROW-HEIGHT-CHARS .46.

DEFINE BROWSE br-nao-encontrado
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-nao-encontrado w-livre _FREEFORM
  QUERY br-nao-encontrado DISPLAY
      tt-nao-encontrados.cCodEstab
    tt-nao-encontrados.iNumNSU   WIDTH 15
    tt-nao-encontrados.cNroCupom COLUMN-LABEL "Cupom"
    tt-nao-encontrados.cLinha    COLUMN-LABEL "Linha Arquivo"  FORMAT "X(2000)" WIDTH 650
    tt-nao-encontrados.iLinha    COLUMN-LABEL "Nr. Linha"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 116.57 BY 18.38
         FONT 2 ROW-HEIGHT-CHARS .5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-cad
     fi-portador-credito AT ROW 2.92 COL 16 COLON-ALIGNED WIDGET-ID 28
     fi-nom-credito AT ROW 2.92 COL 22.14 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     fi-portador-debito AT ROW 2.92 COL 66.14 COLON-ALIGNED WIDGET-ID 30
     fi-nom-debito AT ROW 2.92 COL 72.29 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     BUTTON-1 AT ROW 3.33 COL 102.57 WIDGET-ID 4
     bt-processar AT ROW 3.33 COL 110 WIDGET-ID 14
     fi-arquivo AT ROW 3.92 COL 16 COLON-ALIGNED WIDGET-ID 10
     "Conciliados" VIEW-AS TEXT
          SIZE 13 BY .67 AT ROW 5.63 COL 3.72 WIDGET-ID 22
     "N∆o encontrados" VIEW-AS TEXT
          SIZE 13 BY .67 AT ROW 5.63 COL 34.57 WIDGET-ID 26
     "Divergàncias" VIEW-AS TEXT
          SIZE 13 BY .67 AT ROW 5.63 COL 18.86 WIDGET-ID 24
     rt-button AT ROW 1 COL 1
     RECT-1 AT ROW 2.67 COL 1.29 WIDGET-ID 6
     rt-button-2 AT ROW 25.67 COL 1.14 WIDGET-ID 12
     im-pg-cla AT ROW 5.33 COL 17.72 WIDGET-ID 16
     im-pg-par AT ROW 5.33 COL 33.43 WIDGET-ID 18
     im-pg-sel AT ROW 5.33 COL 2 WIDGET-ID 20
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 124.86 BY 26.88 WIDGET-ID 100.

DEFINE FRAME FRAME-A
     br-conciliados AT ROW 1.13 COL 1.43 WIDGET-ID 500
     fi-tot-nao-conciliados AT ROW 17.83 COL 46.29 COLON-ALIGNED WIDGET-ID 10
     vl-tot-nao-conciliados AT ROW 17.83 COL 80.43 COLON-ALIGNED WIDGET-ID 2
     bt-confirmar AT ROW 18.5 COL 102.29 WIDGET-ID 6
     fi-tot-conciliados AT ROW 18.79 COL 46.29 COLON-ALIGNED WIDGET-ID 12
     vl-tot-conciliados AT ROW 18.79 COL 80.43 COLON-ALIGNED WIDGET-ID 8
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 6.54
         SIZE 118 BY 19 WIDGET-ID 200.

DEFINE FRAME FRAME-D
     br-divergencia AT ROW 1.21 COL 1.57 WIDGET-ID 700
     bt-sel-erro AT ROW 18.75 COL 1.43 WIDGET-ID 2
     bt-proc-erro AT ROW 18.75 COL 18 WIDGET-ID 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 6.54
         SIZE 118 BY 19 WIDGET-ID 300.

DEFINE FRAME FRAME-E
     br-nao-encontrado AT ROW 1.13 COL 1.43 WIDGET-ID 600
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 6.54
         SIZE 118 BY 19 WIDGET-ID 400.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-livre
   Allow: Basic,Browse,DB-Fields,Smart,Window,Query
   Container Links: 
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-livre ASSIGN
         HIDDEN             = YES
         TITLE              = "Conciliaá∆o de Vendas - SITEF"
         COLUMN             = 71.43
         ROW                = 3.5
         HEIGHT             = 26.25
         WIDTH              = 119.57
         MAX-HEIGHT         = 33
         MAX-WIDTH          = 228.57
         VIRTUAL-HEIGHT     = 33
         VIRTUAL-WIDTH      = 228.57
         MAX-BUTTON         = no
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU m-livre:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-livre 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/w-livre.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-livre
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME FRAME-A:FRAME = FRAME f-cad:HANDLE
       FRAME FRAME-D:FRAME = FRAME f-cad:HANDLE
       FRAME FRAME-E:FRAME = FRAME f-cad:HANDLE.

/* SETTINGS FOR FRAME f-cad
   FRAME-NAME L-To-R                                                    */
/* SETTINGS FOR FILL-IN fi-arquivo IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-nom-credito IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-nom-debito IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME FRAME-A
                                                                        */
/* BROWSE-TAB br-conciliados 1 FRAME-A */
/* SETTINGS FOR FILL-IN fi-tot-conciliados IN FRAME FRAME-A
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-tot-nao-conciliados IN FRAME FRAME-A
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vl-tot-conciliados IN FRAME FRAME-A
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vl-tot-nao-conciliados IN FRAME FRAME-A
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME FRAME-D
                                                                        */
/* BROWSE-TAB br-divergencia 1 FRAME-D */
/* SETTINGS FOR FRAME FRAME-E
                                                                        */
/* BROWSE-TAB br-nao-encontrado 1 FRAME-E */
ASSIGN 
       br-nao-encontrado:MAX-DATA-GUESS IN FRAME FRAME-E         = 650.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-livre)
THEN w-livre:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-conciliados
/* Query rebuild information for BROWSE br-conciliados
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-processados WHERE tt-processados.mostra = YES..
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-conciliados */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-divergencia
/* Query rebuild information for BROWSE br-divergencia
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-divergencia.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-divergencia */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-nao-encontrado
/* Query rebuild information for BROWSE br-nao-encontrado
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-nao-encontrados.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-nao-encontrado */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-livre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-livre w-livre
ON END-ERROR OF w-livre /* Conciliaá∆o de Vendas - SITEF */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-livre w-livre
ON WINDOW-CLOSE OF w-livre /* Conciliaá∆o de Vendas - SITEF */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-A
&Scoped-define SELF-NAME bt-confirmar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-confirmar w-livre
ON CHOOSE OF bt-confirmar IN FRAME FRAME-A /* Conciliar */
DO:
   RUN utp/ut-acomp.p persistent set h-acomp.
   {utp/ut-liter.i Confirmando_Conciliacao * L}
   RUN pi-inicializar in h-acomp (input return-value).

   FOR EACH tt-processados 
      WHERE tt-processados.mostra = YES
        AND tt-processados.conciliado = NO :

     RUN pi-acompanhar IN h-acomp(INPUT STRING(tt-processados.cod-estabel) + "/" +
                                        STRING(tt-processados.serie)       + "/" +
                                        STRING(tt-processados.nr-nota-fis) + "/" +
                                        STRING(tt-processados.parcela)). 

       FIND FIRST cst-fat-duplic EXCLUSIVE-LOCK
            WHERE cst-fat-duplic.cod-estabel = tt-processados.cod-estabel
              AND cst-fat-duplic.serie       = tt-processados.serie      
              AND cst-fat-duplic.nr-fatura   = tt-processados.nr-nota-fis
              AND cst-fat-duplic.parcela     = tt-processados.parcela     NO-ERROR. 
       IF AVAIL cst-fat-duplic THEN DO:
           ASSIGN cst-fat-duplic.conciliado-sitef = YES.
       END.
   END.

   RUN pi-finalizar IN h-acomp.

   EMPTY TEMP-TABLE tt-processados.
   EMPTY TEMP-TABLE tt-arquivo-sitef.
   EMPTY TEMP-TABLE tt-nao-encontrados.
   EMPTY TEMP-TABLE tt-divergencia.

   APPLY "MOUSE-SELECT-CLICK" TO im-pg-sel IN FRAME f-cad.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-D
&Scoped-define SELF-NAME bt-proc-erro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-proc-erro w-livre
ON CHOOSE OF bt-proc-erro IN FRAME FRAME-D /* Processar Erro */
DO:
   RUN utp/ut-acomp.p persistent set h-acomp.
   {utp/ut-liter.i Processando_Correcao_Erro * L}
   run pi-inicializar in h-acomp (input return-value).

  FOR EACH tt-divergencia
     WHERE tt-divergencia.marca = YES EXCLUSIVE-LOCK:

     RUN pi-acompanhar IN h-acomp(INPUT STRING(tt-divergencia.cod-estabel) + "/" +
                                        STRING(tt-divergencia.serie)       + "/" +
                                        STRING(tt-divergencia.nr-nota-fis) + "/" +
                                        STRING(tt-divergencia.parcela)). 

     IF tt-divergencia.cod-erro = 1 THEN DO:

         FIND FIRST tt-processados NO-LOCK
              WHERE tt-processados.cod-estabel = tt-divergencia.cod-estabel
                AND tt-processados.serie       = tt-divergencia.serie      
                AND tt-processados.nr-nota-fis = tt-divergencia.nr-nota-fis
                AND tt-processados.parcela     = tt-divergencia.parcela       NO-ERROR.
         IF AVAIL tt-processados THEN DO:
             FIND FIRST cst-fat-duplic EXCLUSIVE-LOCK
                  WHERE cst-fat-duplic.cod-estabel = tt-divergencia.cod-estabel
                    AND cst-fat-duplic.serie       = tt-divergencia.serie
                    AND cst-fat-duplic.nr-fatura   = tt-divergencia.nr-nota-fis
                    AND cst-fat-duplic.parcela     = tt-divergencia.parcela     NO-ERROR. 
             IF AVAIL cst-fat-duplic THEN DO:

                 FIND FIRST tt-arquivo-sitef
                      WHERE ROWID(tt-arquivo-sitef) = tt-processados.rArquivoSitef NO-LOCK NO-ERROR.
                 IF AVAIL tt-arquivo-sitef THEN DO:

/*                      MESSAGE 1 SKIP                                                        */
/*                              "tt-processados.valor-taxa - " tt-processados.valor-taxa SKIP */
/*                              "cst-fat-duplic.taxa-admin - " cst-fat-duplic.taxa-admin SKIP */
/*                              "tt-arquivo-sitef.dPorcTaxa - " tt-arquivo-sitef.dPorcTaxa    */
/*                          VIEW-AS ALERT-BOX INFO BUTTONS OK.                                */
    
                     ASSIGN cst-fat-duplic.taxa-admin = tt-arquivo-sitef.dPorcTaxa.
    
/*                      MESSAGE 2 SKIP                                                        */
/*                              "tt-processados.valor-taxa - " tt-processados.valor-taxa SKIP */
/*                              "cst-fat-duplic.taxa-admin - " cst-fat-duplic.taxa-admin SKIP */
/*                              "tt-arquivo-sitef.dPorcTaxa - " tt-arquivo-sitef.dPorcTaxa    */
/*                          VIEW-AS ALERT-BOX INFO BUTTONS OK.                                */
                 END.

             END.
             RELEASE cst-fat-duplic.
         END.                                                                 
         DELETE tt-divergencia.
     END.
  END.

  br-divergencia:REFRESH().
  run pi-finalizar in h-acomp.
END.

/* 
 DEFINE TEMP-TABLE tt-processados NO-UNDO
    FIELD cod-estabel   LIKE cst-nota-fiscal.cod-estabel
    FIELD serie         LIKE cst-nota-fiscal.serie
    FIELD nr-nota-fis   LIKE cst-nota-fiscal.nr-nota-fis
    FIELD parcela       LIKE cst-fat-duplic.parcela
    FIELD nsu-numero    LIKE cst-fat-duplic.nsu-numero
    FIELD cod-portador  LIKE cst-fat-duplic.cod-portador 
    FIELD valor         LIKE fat-duplic.vl-parcela
    FIELD valor-taxa    LIKE cst-fat-duplic.taxa-admin
    FIELD tipo          AS CHAR
    FIELD mostra        AS LOG INITIAL YES
    FIELD iLinha        AS INT
    FIELD rArquivoSitef AS ROWID.
 
 
 */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-cad
&Scoped-define SELF-NAME bt-processar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-processar w-livre
ON CHOOSE OF bt-processar IN FRAME f-cad /* Processar */
DO:
    EMPTY TEMP-TABLE tt-processados.
    EMPTY TEMP-TABLE tt-arquivo-sitef.
    EMPTY TEMP-TABLE tt-nao-encontrados.
    EMPTY TEMP-TABLE tt-divergencia.   .

    RUN pi-valida-informacoes.
    RUN pi-le-arquivo-sitef.
    RUN pi-processa-arquivo. 

    APPLY "MOUSE-SELECT-CLICK" TO im-pg-sel IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME FRAME-D
&Scoped-define SELF-NAME bt-sel-erro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-erro w-livre
ON CHOOSE OF bt-sel-erro IN FRAME FRAME-D /* Selecionar Erro */
DO:
  DEFINE VARIABLE iCodErro AS INTEGER     NO-UNDO.

        FOR EACH tt-divergencia:
            ASSIGN tt-divergencia.marca = NO.
      END.

  RUN intprg/nicr018a.w(OUTPUT iCodErro).

  IF iCodErro <> ? AND iCodErro <> 0  THEN DO:
      FOR EACH tt-divergencia
         WHERE tt-divergencia.cod-erro = iCodErro.
          ASSIGN tt-divergencia.marca = YES.
      END.
  END.

  br-divergencia:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-cad
&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 w-livre
ON CHOOSE OF BUTTON-1 IN FRAME f-cad /* Button 1 */
DO:
  DEFINE VARIABLE vConfirma      AS LOGICAL    NO-UNDO.
  DEFINE VARIABLE vArquivo AS CHARACTER  NO-UNDO.

    SYSTEM-DIALOG GET-FILE vArquivo
        TITLE      "Selecionar arquivo"
        FILTERS "Arquivos texto separado por ';' (*.csv)" "*.csv"
        DEFAULT-EXTENSION "*.txt"
        MUST-EXIST
        USE-FILENAME
        UPDATE vConfirma.

    IF NOT vConfirma THEN DO:
        RETURN NO-APPLY.
    END.
    ELSE DO:
        ASSIGN fi-arquivo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = vArquivo.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-portador-credito
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-portador-credito w-livre
ON F5 OF fi-portador-credito IN FRAME f-cad /* Portador CrÇdito */
DO:
    run prgint/ufn/ufn008na.p (Input "001") /*prg_see_portad_estab_estab*/.
    IF  v_rec_portador <> ? then do:
       find portador where recid(portador) = v_rec_portador no-lock no-error.
       if  avail portador then do:
          assign fi-portador-credito:screen-value in frame {&FRAME-NAME} = STRING(portador.cod_portador).
       end /* if */.
       ELSE DO:
           assign fi-portador-credito:screen-value in frame {&FRAME-NAME} = "0".
       END.
    END.

    APPLY "LEAVE" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-portador-credito w-livre
ON LEAVE OF fi-portador-credito IN FRAME f-cad /* Portador CrÇdito */
DO:
    FIND FIRST portador 
         WHERE portador.cod_portador = INPUT FRAME {&FRAME-NAME} fi-portador-credito no-lock no-error.
    if  avail portador then do:
        ASSIGN fi-nom-credito:screen-value in frame {&FRAME-NAME} = STRING(portador.nom_pessoa).
    end /* if */.
    ELSE DO:
        ASSIGN fi-nom-credito:screen-value in frame {&FRAME-NAME} = ""
               fi-portador-credito:screen-value in frame {&FRAME-NAME} = "".
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-portador-credito w-livre
ON MOUSE-SELECT-DBLCLICK OF fi-portador-credito IN FRAME f-cad /* Portador CrÇdito */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-portador-debito
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-portador-debito w-livre
ON F5 OF fi-portador-debito IN FRAME f-cad /* Portador DÇdito */
DO:
    run prgint/ufn/ufn008na.p (Input "001") /*prg_see_portad_estab_estab*/.
    IF  v_rec_portador <> ? then do:
       find portador where recid(portador) = v_rec_portador no-lock no-error.
       if  avail portador then do:
          assign fi-portador-debito:screen-value in frame {&FRAME-NAME} = STRING(portador.cod_portador).
       end /* if */.
       ELSE DO:
           assign fi-portador-debito:screen-value in frame {&FRAME-NAME} = "0".
       END.
    END.

    APPLY "LEAVE" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-portador-debito w-livre
ON LEAVE OF fi-portador-debito IN FRAME f-cad /* Portador DÇdito */
DO:
    FIND FIRST portador 
         WHERE portador.cod_portador = INPUT FRAME {&FRAME-NAME} fi-portador-debito no-lock no-error.
    if  avail portador then do:
        ASSIGN fi-nom-debito:screen-value in frame {&FRAME-NAME} = STRING(portador.nom_pessoa).
    end /* if */.
    ELSE DO:
        ASSIGN fi-nom-debito:screen-value in frame {&FRAME-NAME} = ""
               fi-portador-debito:screen-value in frame {&FRAME-NAME} = "".
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-portador-debito w-livre
ON MOUSE-SELECT-DBLCLICK OF fi-portador-debito IN FRAME f-cad /* Portador DÇdito */
DO:
  APPLY "f5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-cla
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-cla w-livre
ON MOUSE-SELECT-CLICK OF im-pg-cla IN FRAME f-cad
DO:
    HIDE FRAME frame-a.
    VIEW FRAME frame-d.
    HIDE FRAME frame-e.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-par w-livre
ON MOUSE-SELECT-CLICK OF im-pg-par IN FRAME f-cad
DO:
    HIDE FRAME frame-a.
    HIDE FRAME frame-d.
    VIEW FRAME frame-e.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-sel w-livre
ON MOUSE-SELECT-CLICK OF im-pg-sel IN FRAME f-cad
DO:
    VIEW FRAME frame-a.
    HIDE FRAME frame-d.
    HIDE FRAME frame-e.

    RUN calculaTotaisConciliados.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-consultas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-consultas w-livre
ON CHOOSE OF MENU-ITEM mi-consultas /* Consultas */
DO:
  RUN pi-consulta IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-conteudo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-conteudo w-livre
ON CHOOSE OF MENU-ITEM mi-conteudo /* Conteudo */
OR HELP OF FRAME {&FRAME-NAME}
DO:
  RUN pi-ajuda IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-imprimir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-imprimir w-livre
ON CHOOSE OF MENU-ITEM mi-imprimir /* Relat¢rios */
DO:
  RUN pi-imprimir IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-programa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-programa w-livre
ON MENU-DROP OF MENU mi-programa /* Nome-do-Programa */
DO:
  run pi-disable-menu.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sair
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sair w-livre
ON CHOOSE OF MENU-ITEM mi-sair /* Sair */
DO:
  RUN pi-sair IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sobre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sobre w-livre
ON CHOOSE OF MENU-ITEM mi-sobre /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-conciliados
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-livre 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

fi-portador-credito:LOAD-MOUSE-POINTER("image/lupa.cur").
fi-portador-debito:LOAD-MOUSE-POINTER("image/lupa.cur").

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-livre  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  CASE adm-current-page: 

    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'panel/p-exihel.w':U ,
             INPUT  FRAME f-cad:HANDLE ,
             INPUT  'Edge-Pixels = 2,
                     SmartPanelType = NAV-ICON,
                     Right-to-Left = First-On-Left':U ,
             OUTPUT h_p-exihel ).
       RUN set-position IN h_p-exihel ( 1.25 , 103.43 ) NO-ERROR.
       /* Size in UIB:  ( 1.25 , 16.00 ) */

       /* Links to SmartPanel h_p-exihel. */
       RUN add-link IN adm-broker-hdl ( h_p-exihel , 'State':U , THIS-PROCEDURE ).

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_p-exihel ,
             fi-portador-credito:HANDLE IN FRAME f-cad , 'BEFORE':U ).
    END. /* Page 0 */

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-livre  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calculaTotaisConciliados w-livre 
PROCEDURE calculaTotaisConciliados :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE dvt1 AS DECIMAL     NO-UNDO.
DEFINE VARIABLE dvt2 AS DECIMAL     NO-UNDO.
DEFINE VARIABLE iqt1 AS INTEGER     NO-UNDO.
DEFINE VARIABLE iqt2 AS INTEGER     NO-UNDO.

ASSIGN dvt1 = 0
       iqt1 = 0
       dvt2 = 0
       iqt2 = 0.
    
FOR EACH tt-processados WHERE tt-processados.mostra = YES:

    IF tt-processados.conciliado = YES THEN DO:
        ASSIGN dvt1 = dvt1 + tt-processados.valor
               iqt1 = iqt1 + 1.
    END.
    ELSE DO:
        ASSIGN dvt2 = dvt2 + tt-processados.valor
               iqt2 = iqt2 + 1.
    END.
END.

ASSIGN fi-tot-nao-conciliados:SCREEN-VALUE IN FRAME FRAME-A  = STRING(iqt2)
       vl-tot-nao-conciliados:SCREEN-VALUE IN FRAME FRAME-A  = STRING(dvt2,"->>,>>>,>>>,>>9.9999")
       fi-tot-conciliados:SCREEN-VALUE IN FRAME FRAME-A      = STRING(iqt1)
       vl-tot-conciliados:SCREEN-VALUE IN FRAME FRAME-A      = STRING(dvt1,"->>,>>>,>>>,>>9.9999")
    .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-livre  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-livre)
  THEN DELETE WIDGET w-livre.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-livre  _DEFAULT-ENABLE
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
  DISPLAY fi-portador-credito fi-nom-credito fi-portador-debito fi-nom-debito 
          fi-arquivo 
      WITH FRAME f-cad IN WINDOW w-livre.
  ENABLE rt-button RECT-1 rt-button-2 im-pg-cla im-pg-par im-pg-sel 
         fi-portador-credito fi-portador-debito BUTTON-1 bt-processar 
      WITH FRAME f-cad IN WINDOW w-livre.
  {&OPEN-BROWSERS-IN-QUERY-f-cad}
  DISPLAY fi-tot-nao-conciliados vl-tot-nao-conciliados fi-tot-conciliados 
          vl-tot-conciliados 
      WITH FRAME FRAME-A IN WINDOW w-livre.
  ENABLE br-conciliados bt-confirmar 
      WITH FRAME FRAME-A IN WINDOW w-livre.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  ENABLE br-divergencia bt-sel-erro bt-proc-erro 
      WITH FRAME FRAME-D IN WINDOW w-livre.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-D}
  ENABLE br-nao-encontrado 
      WITH FRAME FRAME-E IN WINDOW w-livre.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-E}
  VIEW w-livre.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy w-livre 
PROCEDURE local-destroy :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'destroy':U ) .
  {include/i-logfin.i}

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-livre 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize w-livre 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
  run pi-before-initialize.

  {include/win-size.i}

  {utp/ut9000.i "XX9999" "9.99.99.999"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  VIEW FRAME frame-a.
  HIDE FRAME frame-d.
  HIDE FRAME frame-e.

  run pi-after-initialize.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-le-arquivo-sitef w-livre 
PROCEDURE pi-le-arquivo-sitef :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE c-Arquivo AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-linha   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i         AS INTEGER     NO-UNDO.

/* INICIO - Vari†veis para a leitura e montagem da temp-table */
DEFINE VARIABLE cCodEstab LIKE cst-fat-duplic.cod-estabel NO-UNDO.
DEFINE VARIABLE iNumNSU   LIKE cst-fat-duplic.nsu-numero  NO-UNDO.
DEFINE VARIABLE dPorcTaxa LIKE cst-fat-duplic.taxa-admin  NO-UNDO.
DEFINE VARIABLE cParcela  LIKE cst-fat-duplic.parcela     NO-UNDO.
DEFINE VARIABLE dValorLiq LIKE fat-duplic.vl-parcela      NO-UNDO.
DEFINE VARIABLE dValorBru LIKE fat-duplic.vl-parcela      NO-UNDO.
DEFINE VARIABLE cTipo     AS CHAR                         NO-UNDO.
DEFINE VARIABLE cNroCupom LIKE cst-fat-duplic.nr-fatura   NO-UNDO.
/* FIM    - Vari†veis para a leitura e montagem da temp-table */

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Leitura_Arquivo_Sitef * L}
run pi-inicializar in h-acomp (input return-value).

IF INPUT FRAME {&FRAME-NAME} fi-arquivo <> "" THEN DO:

    ASSIGN c-Arquivo = fi-arquivo:SCREEN-VALUE IN FRAME {&FRAME-NAME}.

    ASSIGN i = 0.

    INPUT FROM VALUE(c-Arquivo) NO-CONVERT.
    REPEAT:
        IMPORT UNFORMATTED c-linha.

        ASSIGN i = i + 1.

        IF STRING(ENTRY(1,c-linha,";")) <> "" AND REPLACE(STRING(ENTRY(1,c-linha,";")),'"',"") = "1" THEN DO:
  

            ASSIGN cCodEstab = REPLACE(STRING(ENTRY(22,c-linha,";")),'"',"")
                   cCodEstab = SUBSTRING(cCodEstab,6,3)
                   iNumNSU   = REPLACE(STRING(ENTRY(07,c-linha,";")),'"',"")
                   dPorcTaxa = DEC(REPLACE(STRING(ENTRY(20,c-linha,";")),'"',"")) / 100 
                   cParcela  = REPLACE(STRING(ENTRY(10,c-linha,";")),'"',"")            
                   dValorLiq = DEC(REPLACE(STRING(ENTRY(09,c-linha,";")),'"',"")) / 100 
                   dValorBru = DEC(REPLACE(STRING(ENTRY(11,c-linha,";")),'"',"")) / 100 
                   cTipo     = REPLACE(STRING(ENTRY(14,c-linha,";")),'"',"") 
                   cNroCupom = REPLACE(STRING(ENTRY(24,c-linha,";")),'"',"") 
                   cNroCupom = STRING(INT(cNroCupom),"9999999")
                   .

            IF VALID-HANDLE(h-acomp) AND (i MOD 500) = 0 THEN
                RUN pi-acompanhar IN h-acomp(INPUT "Linha - " + STRING(i)).

            CREATE tt-arquivo-sitef.
            ASSIGN tt-arquivo-sitef.cCodEstab  = cCodEstab
                   tt-arquivo-sitef.iNumNSU    = iNumNSU  
                   tt-arquivo-sitef.dPorcTaxa  = dPorcTaxa
                   tt-arquivo-sitef.cParcela   = cParcela 
                   tt-arquivo-sitef.dValorLiq  = dValorLiq
                   tt-arquivo-sitef.dValorBru  = dValorBru
                   tt-arquivo-sitef.cNroCupom  = cNroCupom
                   tt-arquivo-sitef.cTipo      = cTipo 
                   tt-arquivo-sitef.cLinha     = c-linha
                   tt-arquivo-sitef.iLinha     = i
                .

        END.
    END.
    INPUT CLOSE.
END.

IF VALID-HANDLE(h-acomp) THEN 
   run pi-finalizar in h-acomp.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-processa-arquivo w-livre 
PROCEDURE pi-processa-arquivo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE BUFFER bf-cst-fat-duplic FOR cst-fat-duplic.

DEFINE VARIABLE iTot AS INTEGER     NO-UNDO.
def var h-prog as handle no-undo.

DEFINE VARIABLE horaini AS CHARACTER   NO-UNDO.
DEFINE VARIABLE horafim AS CHARACTER   NO-UNDO.

ASSIGN iTot = 0.
FOR EACH  tt-arquivo-sitef:
    ASSIGN iTot = iTot + 1.
END.

run utp/ut-perc.p persistent set h-prog.
run pi-inicializar        in h-prog(input "Localizando Cupom Venda", iTot).
/* run pi-desabilita-cancela in h-prog. */

ASSIGN horaini = STRING(TIME, "HH:MM:SS").

FOR EACH  tt-arquivo-sitef:
    run pi-acompanhar in h-prog.

    FIND FIRST bf-cst-fat-duplic NO-LOCK USE-INDEX sitef
         WHERE bf-cst-fat-duplic.cod-estabel = tt-arquivo-sitef.cCodEstab
           AND bf-cst-fat-duplic.nr-fatura   = tt-arquivo-sitef.cNroCupom
           AND bf-cst-fat-duplic.nsu-numero  = tt-arquivo-sitef.iNumNSU   NO-ERROR.
    IF AVAIL bf-cst-fat-duplic THEN DO:

        FOR EACH cst-fat-duplic NO-LOCK USE-INDEX sitef
           WHERE cst-fat-duplic.cod-estabel = tt-arquivo-sitef.cCodEstab
             AND cst-fat-duplic.nr-fatura   = tt-arquivo-sitef.cNroCupom
             AND cst-fat-duplic.nsu-numero  = tt-arquivo-sitef.iNumNSU   :

                FIND FIRST fat-duplic OF cst-fat-duplic NO-LOCK NO-ERROR.
                IF AVAIL fat-duplic THEN DO:

                    FIND FIRST tt-processados
                         WHERE tt-processados.cod-estabel  = cst-fat-duplic.cod-estabel
                           AND tt-processados.serie        = cst-fat-duplic.serie
                           AND tt-processados.nr-nota-fis  = cst-fat-duplic.nr-fatura
                           AND tt-processados.parcela      = fat-duplic.parcela         NO-ERROR.
                    IF NOT AVAIL tt-processados THEN DO:

                        CREATE tt-processados.
                        ASSIGN tt-processados.cod-estabel   = cst-fat-duplic.cod-estabel
                               tt-processados.serie         = cst-fat-duplic.serie
                               tt-processados.nr-nota-fis   = cst-fat-duplic.nr-fatura
                               tt-processados.nsu-numero    = cst-fat-duplic.nsu-numero
                               tt-processados.parcela       = fat-duplic.parcela
                               tt-processados.cod-portador  = cst-fat-duplic.cod-portador
                               tt-processados.valor         = fat-duplic.vl-parcela
                               tt-processados.valor-taxa    = cst-fat-duplic.taxa-admin
                               tt-processados.tipo          = tt-arquivo-sitef.cTipo
                               tt-processados.iLinha        = tt-arquivo-sitef.iLinha
                               tt-processados.conciliado    = cst-fat-duplic.conciliado-sitef
                               tt-processados.rArquivoSitef = ROWID(tt-arquivo-sitef).
                            .
                         LEAVE.
                    END.
                    ELSE NEXT.
                END.
        END.
    END.
    ELSE DO:
        CREATE tt-nao-encontrados.
        BUFFER-COPY tt-arquivo-sitef TO tt-nao-encontrados.
    END.
END.
run pi-finalizar in h-prog.

ASSIGN horafim = STRING(TIME, "HH:MM:SS").

/* MESSAGE "horaini - " horaini SKIP      */
/*         "horafim - " horafim           */
/*     VIEW-AS ALERT-BOX INFO BUTTONS OK. */

/* Verificando Divergàncias nos registros processados. */
run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Leitura_Arquivo_Sitef * L}
run pi-inicializar in h-acomp (input return-value).

run pi-seta-titulo in h-acomp (input "Verificando_Divergància":U).

FOR EACH tt-processados:

    IF (tt-processados.iLinha MOD 500) = 0 THEN
        RUN pi-acompanhar IN h-acomp(INPUT "Linha - " + STRING(tt-processados.iLinha)).

    /* INICIO - Verificaá∆o do Portador confere com o informado */
    IF tt-processados.tipo          = "C" AND 
       tt-processados.cod-portador <> INT(fi-portador-credito:SCREEN-VALUE IN FRAME {&FRAME-NAME}) THEN DO:

        CREATE tt-divergencia.
        ASSIGN tt-divergencia.cod-estabel     = tt-processados.cod-estabel 
               tt-divergencia.serie           = tt-processados.serie       
               tt-divergencia.nr-nota-fis     = tt-processados.nr-nota-fis 
               tt-divergencia.parcela         = tt-processados.parcela     
               tt-divergencia.cod-erro        = 4
               tt-divergencia.obs-divergencia = "Portador Credito(" + STRING(tt-processados.cod-portador) + ") n∆o confere com o informado na tela("+ STRING(fi-portador-credito:SCREEN-VALUE IN FRAME {&FRAME-NAME}) + ")."
               tt-divergencia.iLinha          = tt-processados.iLinha.
        ASSIGN tt-processados.mostra = NO.
        NEXT.
    END.

    IF tt-processados.tipo = "D" AND 
       tt-processados.cod-portador <> INT(fi-portador-debito:SCREEN-VALUE IN FRAME {&FRAME-NAME}) THEN DO:

        CREATE tt-divergencia.
        ASSIGN tt-divergencia.cod-estabel     = tt-processados.cod-estabel 
               tt-divergencia.serie           = tt-processados.serie       
               tt-divergencia.nr-nota-fis     = tt-processados.nr-nota-fis 
               tt-divergencia.parcela         = tt-processados.parcela  
               tt-divergencia.cod-erro        = 3
               tt-divergencia.obs-divergencia = "Portador Debito(" + STRING(tt-processados.cod-portador) + ") n∆o confere com o informado na tela("+ STRING(fi-portador-debito:SCREEN-VALUE IN FRAME {&FRAME-NAME}) + ")."
               tt-divergencia.iLinha          = tt-processados.iLinha.
        ASSIGN tt-processados.mostra = NO.
        NEXT.
    END.
    /* FIM    - Verificaá∆o do Portador confere com o informado */

    FIND FIRST tt-arquivo-sitef
         WHERE ROWID(tt-arquivo-sitef) = tt-processados.rArquivoSitef NO-LOCK NO-ERROR.
    IF AVAIL tt-arquivo-sitef THEN DO:

        /* INICIO - Verificaá∆o dos valores de TAXA */
        IF tt-processados.valor-taxa <> tt-arquivo-sitef.dPorcTaxa THEN DO:
            CREATE tt-divergencia.
            ASSIGN tt-divergencia.cod-estabel     = tt-processados.cod-estabel 
                   tt-divergencia.serie           = tt-processados.serie       
                   tt-divergencia.nr-nota-fis     = tt-processados.nr-nota-fis 
                   tt-divergencia.parcela         = tt-processados.parcela     
                   tt-divergencia.cod-erro        = 1
                   tt-divergencia.obs-divergencia = "Valor da Taxa (R$ " + TRIM(STRING(tt-arquivo-sitef.dPorcTaxa,">,>>9.99")) + ") contida no arquivo n∆o confere com a taxa da Nota Fiscal (R$ "+ TRIM(STRING(tt-processados.valor-taxa,">,>>9.99")) + ")."
                   tt-divergencia.iLinha          = tt-processados.iLinha.
            ASSIGN tt-processados.mostra = NO.
            NEXT.
        END.
        /* FIM - Verificaá∆o dos valores de TAXA */

        /* INICIO - Verificaá∆o dos valores de Parcela */
        IF tt-processados.valor <> tt-arquivo-sitef.dValorLiq THEN DO:
            CREATE tt-divergencia.
            ASSIGN tt-divergencia.cod-estabel     = tt-processados.cod-estabel 
                   tt-divergencia.serie           = tt-processados.serie       
                   tt-divergencia.nr-nota-fis     = tt-processados.nr-nota-fis 
                   tt-divergencia.parcela         = tt-processados.parcela     
                   tt-divergencia.cod-erro        = 2
                   tt-divergencia.obs-divergencia = "Valor da Parcela (R$ " + TRIM(STRING(tt-arquivo-sitef.dValorLiq,">>>,>>9.99")) + ") contida no arquivo n∆o confere com a parcela da Nota Fiscal (R$ "+ TRIM(STRING(tt-processados.valor,">,>>9.99")) + ")."
                   tt-divergencia.iLinha          = tt-processados.iLinha.
            ASSIGN tt-processados.mostra = NO.
            NEXT.
        END.
        /* FIM    - Verificaá∆o dos valores de Parcela */

    END.




END.


IF VALID-HANDLE(h-acomp) THEN 
   run pi-finalizar in h-acomp.

{&OPEN-QUERY-BR-NAO-ENCONTRADO}
{&OPEN-QUERY-BR-CONCILIADOS}
{&OPEN-QUERY-BR-DIVERGENCIA}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-valida-informacoes w-livre 
PROCEDURE pi-valida-informacoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
IF INPUT FRAME {&FRAME-NAME} fi-portador-credito = "" AND
   INPUT FRAME {&FRAME-NAME} fi-portador-debito  = "" THEN DO:
    RUN utp/ut-msgs.p (INPUT "show":U,
                       INPUT 17006,
                       INPUT "Erro Portador n∆o informado !.~~Vocà deve informar ao menos um Portador, de DÇbito ou de CrÇdito.").
    RETURN "NOK". 
END.

IF INPUT FRAME {&FRAME-NAME} fi-arquivo = "" THEN DO:
    RUN utp/ut-msgs.p (INPUT "show":U,
                       INPUT 17006,
                       INPUT "Erro Arquivo de Importaá∆o n∆o selecionado !.~~Vocà deve selecionar o arquivo que deseja realizar a leitura do arquivo.").
    RETURN "NOK". 
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-livre  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-processados"}
  {src/adm/template/snd-list.i "tt-nao-encontrados"}
  {src/adm/template/snd-list.i "tt-divergencia"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-livre 
PROCEDURE state-changed :
/*:T -----------------------------------------------------------
  Purpose:     Manuseia trocas de estado dos SmartObjects
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.

  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

