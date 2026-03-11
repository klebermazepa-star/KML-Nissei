&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: JRA
Template Name: WWIN_BASIC
Template Library: CSTDDK
Template Version: 1.01
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              CSAP008
&SCOPED-DEFINE Version              1.00.00.006

&SCOPED-DEFINE page0EnableWidgets   f-mes-transacao f-ano-transacao cb-prefeituras ~
                                    bt-buscar bt-gerar bt-retornar ~
                                    brTable0 ~
                                    bt-brTable0-todos bt-brTable0-nenhum ~
                                    t-gerados-n t-gerados-s t-teste ~
                                    f-nat-operacao-filtro-1 f-nat-operacao-filtro-2
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */
{cstp/csap008i01.i}

DEF TEMP-TABLE tt-docto-ger NO-UNDO LIKE tt-docto .

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF BUFFER fornecedor FOR ems5.fornecedor .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brTable0

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-docto

/* Definitions for BROWSE brTable0                                      */
&Scoped-define FIELDS-IN-QUERY-brTable0 tt-docto.cod-estabel tt-docto.cod-emitente tt-docto.cod-esp tt-docto.serie-docto tt-docto.nro-docto tt-docto.parcela tt-docto.nat-operacao tt-docto.dt-emissao tt-docto.dt-trans tt-docto.dt-vencim tt-docto.vl-docto tt-docto.vl-a-pagar tt-docto.cod-imposto tt-docto.cod-retencao tt-docto.rend-trib tt-docto.aliquota tt-docto.vl-imposto tt-docto.simples-nac tt-docto.nome-emit tt-docto.l_ger tt-docto.cod_usuario_ger tt-docto.dt_ger tt-docto.hr_ger   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable0   
&Scoped-define SELF-NAME brTable0
&Scoped-define QUERY-STRING-brTable0 FOR EACH tt-docto NO-LOCK     WHERE (INPUT FRAME fPage0 t-gerados-n = YES AND tt-docto.l_ger = NO  )     OR    (INPUT FRAME fPage0 t-gerados-s = YES AND tt-docto.l_ger = YES )     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable0 OPEN QUERY {&SELF-NAME} FOR EACH tt-docto NO-LOCK     WHERE (INPUT FRAME fPage0 t-gerados-n = YES AND tt-docto.l_ger = NO  )     OR    (INPUT FRAME fPage0 t-gerados-s = YES AND tt-docto.l_ger = YES )     INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brTable0 tt-docto
&Scoped-define FIRST-TABLE-IN-QUERY-brTable0 tt-docto


/* Definitions for FRAME fpage0                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar f-mes-transacao f-ano-transacao ~
cb-prefeituras bt-buscar bt-gerar bt-retornar brTable0 t-gerados-n ~
t-gerados-s t-teste bt-brTable0-todos bt-brTable0-nenhum ~
f-nat-operacao-filtro-1 f-nat-operacao-filtro-2 
&Scoped-Define DISPLAYED-OBJECTS f-mes-transacao f-ano-transacao ~
cb-prefeituras t-gerados-n f-tot-gerados-n f-tot-gerados-n-sel t-gerados-s ~
f-tot-gerados-s f-tot-gerados-s-sel t-teste f-nat-operacao-filtro-1 ~
f-nat-operacao-filtro-2 

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
DEFINE BUTTON bt-brTable0-nenhum 
     LABEL "Nenhum" 
     SIZE 12 BY 1.13 TOOLTIP "Desmarcar todos".

DEFINE BUTTON bt-brTable0-todos 
     LABEL "Todos" 
     SIZE 12 BY 1.13 TOOLTIP "Selecionar todos".

DEFINE BUTTON bt-buscar 
     LABEL "Buscar" 
     SIZE 12 BY 1.

DEFINE BUTTON bt-gerar 
     LABEL "Gerar" 
     SIZE 12 BY 1.

DEFINE BUTTON bt-retornar 
     LABEL "Retornar" 
     SIZE 12 BY 1.

DEFINE VARIABLE cb-prefeituras AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Prefeitura" 
     VIEW-AS COMBO-BOX INNER-LINES 18
     LIST-ITEM-PAIRS "''",0
     DROP-DOWN-LIST
     SIZE 46 BY 1 TOOLTIP "Selecionar Prefeitura" NO-UNDO.

DEFINE VARIABLE f-ano-transacao AS INTEGER FORMAT "9999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 TOOLTIP "Ano" NO-UNDO.

DEFINE VARIABLE f-mes-transacao AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "Màs/Ano Transaá∆o" 
     VIEW-AS FILL-IN 
     SIZE 3 BY .88 TOOLTIP "Màs" NO-UNDO.

DEFINE VARIABLE f-nat-operacao-filtro-1 AS CHARACTER FORMAT "X(6)":U INITIAL "1933a3" 
     LABEL "Filtro Nat Operaá∆o 1" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE f-nat-operacao-filtro-2 AS CHARACTER FORMAT "X(6)":U INITIAL "2933a3" 
     LABEL "Filtro Nat Operaá∆o 2" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-gerados-n AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-gerados-n-sel AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 TOOLTIP "N∆o gerados selecionados" NO-UNDO.

DEFINE VARIABLE f-tot-gerados-s AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 TOOLTIP "Total gerado" NO-UNDO.

DEFINE VARIABLE f-tot-gerados-s-sel AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 TOOLTIP "Gerados Selecionados" NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 130 BY 1.5
     BGCOLOR 7 .

DEFINE VARIABLE t-gerados-n AS LOGICAL INITIAL yes 
     LABEL "N∆o Gerados" 
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE t-gerados-s AS LOGICAL INITIAL no 
     LABEL "Gerados" 
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE t-teste AS LOGICAL INITIAL no 
     LABEL "TESTE" 
     VIEW-AS TOGGLE-BOX
     SIZE 8.86 BY .88 TOOLTIP "Indica se o arquivo a ser gerado ser† apenas de teste." NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable0 FOR 
      tt-docto SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable0 wWindow _FREEFORM
  QUERY brTable0 DISPLAY
      tt-docto.cod-estabel
tt-docto.cod-emitente 
tt-docto.cod-esp
tt-docto.serie-docto     
tt-docto.nro-docto 
tt-docto.parcela  
tt-docto.nat-operacao      
tt-docto.dt-emissao      
tt-docto.dt-trans                  
tt-docto.dt-vencim    
tt-docto.vl-docto
tt-docto.vl-a-pagar COLUMN-LABEL "Vl com PIS/COFINS/IR"     
tt-docto.cod-imposto 
tt-docto.cod-retencao
tt-docto.rend-trib
tt-docto.aliquota        
tt-docto.vl-imposto
tt-docto.simples-nac VIEW-AS TOGGLE-BOX
tt-docto.nome-emit
tt-docto.l_ger VIEW-AS TOGGLE-BOX
tt-docto.cod_usuario_ger 
tt-docto.dt_ger     
tt-docto.hr_ger
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 130 BY 18.75
         FONT 1
         TITLE "Notas Fiscais".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     f-mes-transacao AT ROW 1.25 COL 18 COLON-ALIGNED WIDGET-ID 20
     f-ano-transacao AT ROW 1.25 COL 22 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     cb-prefeituras AT ROW 1.25 COL 38 COLON-ALIGNED WIDGET-ID 12
     bt-buscar AT ROW 1.25 COL 91 WIDGET-ID 6
     bt-gerar AT ROW 1.25 COL 104 WIDGET-ID 24
     bt-retornar AT ROW 1.25 COL 116.72 WIDGET-ID 44
     brTable0 AT ROW 2.75 COL 1 WIDGET-ID 200
     t-gerados-n AT ROW 21.75 COL 2 WIDGET-ID 10
     f-tot-gerados-n AT ROW 21.75 COL 12 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     f-tot-gerados-n-sel AT ROW 21.75 COL 18.57 COLON-ALIGNED HELP
          "N∆o gerados selecionados" NO-LABEL WIDGET-ID 18
     t-gerados-s AT ROW 21.75 COL 36 WIDGET-ID 38
     f-tot-gerados-s AT ROW 21.75 COL 46 COLON-ALIGNED HELP
          "Total gerado" NO-LABEL WIDGET-ID 16
     f-tot-gerados-s-sel AT ROW 21.75 COL 52.57 COLON-ALIGNED HELP
          "Gerados Selecionados" NO-LABEL WIDGET-ID 36
     t-teste AT ROW 21.75 COL 92.86 HELP
          "Indica se o arquivo a ser gerado ser† apenas de teste." WIDGET-ID 22
     bt-brTable0-todos AT ROW 21.75 COL 103 HELP
          "Selecionar todos" WIDGET-ID 34
     bt-brTable0-nenhum AT ROW 21.75 COL 117 HELP
          "Desmarcar todos" WIDGET-ID 8
     f-nat-operacao-filtro-1 AT ROW 22.75 COL 18.57 COLON-ALIGNED WIDGET-ID 40
     f-nat-operacao-filtro-2 AT ROW 22.75 COL 52.57 COLON-ALIGNED WIDGET-ID 42
     rtToolBar AT ROW 1 COL 1 WIDGET-ID 32
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 130 BY 23
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
         TITLE              = "wWindow"
         HEIGHT             = 23
         WIDTH              = 130
         MAX-HEIGHT         = 320
         MAX-WIDTH          = 320
         VIRTUAL-HEIGHT     = 320
         VIRTUAL-WIDTH      = 320
         RESIZE             = no
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



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* BROWSE-TAB brTable0 bt-retornar fpage0 */
ASSIGN 
       brTable0:ALLOW-COLUMN-SEARCHING IN FRAME fpage0 = TRUE
       brTable0:COLUMN-RESIZABLE IN FRAME fpage0       = TRUE
       brTable0:COLUMN-MOVABLE IN FRAME fpage0         = TRUE.

/* SETTINGS FOR FILL-IN f-tot-gerados-n IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-tot-gerados-n-sel IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-tot-gerados-s IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-tot-gerados-s-sel IN FRAME fpage0
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable0
/* Query rebuild information for BROWSE brTable0
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-docto NO-LOCK
    WHERE (INPUT FRAME fPage0 t-gerados-n = YES AND tt-docto.l_ger = NO  )
    OR    (INPUT FRAME fPage0 t-gerados-s = YES AND tt-docto.l_ger = YES )
    INDEXED-REPOSITION
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable0 */
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
ON END-ERROR OF wWindow /* wWindow */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow /* wWindow */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-MAXIMIZED OF wWindow /* wWindow */
DO:
    &IF "{&WinFullScreen}":U = "YES":U &THEN 
    RUN windowMaximized IN THIS-PROCEDURE .
    &ENDIF
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-RESTORED OF wWindow /* wWindow */
DO:
    &IF "{&WinFullScreen}":U = "YES":U &THEN 
    RUN windowRestored IN THIS-PROCEDURE .
    &ENDIF
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable0
&Scoped-define SELF-NAME brTable0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTable0 wWindow
ON VALUE-CHANGED OF brTable0 IN FRAME fpage0 /* Notas Fiscais */
DO:
    DEF VAR v_cont              AS INT NO-UNDO .
    DEF VAR v_cont_gerados_n    AS INT NO-UNDO .
    DEF VAR v_cont_gerados_s    AS INT NO-UNDO .
    
    DO v_cont = 1 TO SELF:NUM-SELECTED-ROWS
        :
        SELF:FETCH-SELECTED-ROW(v_cont) .
        IF tt-docto.l_ger = NO THEN DO:
            ASSIGN v_cont_gerados_n = v_cont_gerados_n + 1 .
        END.    
        ELSE DO:
            ASSIGN v_cont_gerados_s = v_cont_gerados_s + 1 . 
        END.
    END.
    
    ASSIGN f-tot-gerados-n-sel:SCREEN-VALUE IN FRAME fPage0 = STRING(v_cont_gerados_n) .
    ASSIGN f-tot-gerados-s-sel:SCREEN-VALUE IN FRAME fPage0 = STRING(v_cont_gerados_s) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-brTable0-nenhum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-brTable0-nenhum wWindow
ON CHOOSE OF bt-brTable0-nenhum IN FRAME fpage0 /* Nenhum */
DO:
    brTable0:DESELECT-ROWS() NO-ERROR .
    APPLY "ITERATION-CHANGED" TO brTable0 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-brTable0-todos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-brTable0-todos wWindow
ON CHOOSE OF bt-brTable0-todos IN FRAME fpage0 /* Todos */
DO:
    brTable0:SELECT-ALL() NO-ERROR .
    APPLY "ITERATION-CHANGED" TO brTable0 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-buscar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-buscar wWindow
ON CHOOSE OF bt-buscar IN FRAME fpage0 /* Buscar */
DO:
    RUN piBuscar .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-gerar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-gerar wWindow
ON CHOOSE OF bt-gerar IN FRAME fpage0 /* Gerar */
DO:
    IF brTable0:NUM-SELECTED-ROWS IN FRAME fPage0 <= 0 THEN DO:
        RUN utp/ut-msgs.p ("show" , "17242" , 
                           "Nenhuma nota selecionada." + "~~" + 
                           "" )
            .
        RETURN NO-APPLY .
    END.
    RUN piGerar .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-retornar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-retornar wWindow
ON CHOOSE OF bt-retornar IN FRAME fpage0 /* Retornar */
DO:
    IF brTable0:NUM-SELECTED-ROWS IN FRAME fPage0 <= 0 THEN DO:
        RUN utp/ut-msgs.p ("show" , "17242" , 
                           "Nenhuma nota selecionada." + "~~" + 
                           "" )
            .
        RETURN NO-APPLY .
    END.
    RUN piRetornar .
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


&Scoped-define SELF-NAME t-gerados-n
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-gerados-n wWindow
ON VALUE-CHANGED OF t-gerados-n IN FRAME fpage0 /* N∆o Gerados */
DO:
    RUN piLoadBrowser0 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-gerados-s
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-gerados-s wWindow
ON VALUE-CHANGED OF t-gerados-s IN FRAME fpage0 /* Gerados */
DO:
    RUN piLoadBrowser0 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/* ***************************** MAIN BLOCK *************************** */
{cstddk/include/wWinMainBlock.i}

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

DO WITH FRAME fPage0:
    ASSIGN
        f-mes-transacao:SCREEN-VALUE = STRING(MONTH(TODAY))
        f-ano-transacao:SCREEN-VALUE = STRING(YEAR(TODAY)) 
        .

    cb-prefeituras:DELETE(1) .

    FOR FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = 2197 /* Curitiba */
        :
        cb-prefeituras:ADD-LAST(emitente.nome-emit + " - " + STRING(emitente.cod-emitente) , emitente.cod-emitente ) .           
    END.
    FOR FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = 3116 /* Colombo */
        :
        cb-prefeituras:ADD-LAST(emitente.nome-emit + " - " + STRING(emitente.cod-emitente) , emitente.cod-emitente ) .         
    END.

    ASSIGN cb-prefeituras:SCREEN-VALUE = "2197" /* Curitiba */ .
END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piBuscar wWindow 
PROCEDURE piBuscar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF VAR h-acomp AS HANDLE NO-UNDO .
RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
RUN pi-inicializar IN h-acomp (INPUT "Efetuando Busca") .
RUN pi-acompanhar IN h-acomp (INPUT "Aguarde...") .

DEF BUFFER bf-emitente  FOR emitente .

DEF VAR v_cont              AS INT NO-UNDO .
DEF VAR v_dt_ini_emissao    AS DATE NO-UNDO .
DEF VAR v_dt_fim_emissao    AS DATE NO-UNDO .
DEF VAR v_dt_ini_trans      AS DATE NO-UNDO .
DEF VAR v_dt_fim_trans      AS DATE NO-UNDO .

ASSIGN v_dt_ini_emissao = DATE(INPUT FRAME fPage0 f-mes-transacao , 1 , INPUT FRAME fPage0 f-ano-transacao) .
ASSIGN v_dt_fim_emissao = ADD-INTERVAL(v_dt_ini_emissao ,  1 , "MONTH") .
ASSIGN v_dt_fim_emissao = ADD-INTERVAL(v_dt_fim_emissao , -1 , "DAY") . 

ASSIGN v_dt_ini_trans = v_dt_ini_emissao .
ASSIGN v_dt_ini_trans = ADD-INTERVAL(v_dt_ini_trans , -1 , "MONTH") .
ASSIGN v_dt_fim_trans = ADD-INTERVAL(v_dt_ini_trans ,  3 , "MONTH") .
ASSIGN v_dt_fim_trans = ADD-INTERVAL(v_dt_fim_trans , -1 , "DAY") . 

/*
MESSAGE 
    v_dt_ini_emissao " - " v_dt_fim_emissao SKIP
    v_dt_ini_trans " - " v_dt_fim_trans
    VIEW-AS ALERT-BOX .
*/

EMPTY TEMP-TABLE tt-docto .

FOR FIRST bf-emitente NO-LOCK
    WHERE bf-emitente.cod-emitente = INPUT FRAME fPage0 cb-prefeituras 
    , 
    EACH estabelec NO-LOCK
    WHERE estabelec.cidade = bf-emitente.cidade 
    ,
    EACH docum-est NO-LOCK
    WHERE docum-est.cod-estabel = estabelec.cod-estabel
    AND   docum-est.dt-trans >= v_dt_ini_trans
    AND   docum-est.dt-trans <= v_dt_fim_trans
    AND   docum-est.dt-emissao >= v_dt_ini_emissao
    AND   docum-est.dt-emissao <= v_dt_fim_emissao
    AND   docum-est.cod-observa = 4 /* Servicos */ 
    AND   ( (INPUT FRAME fPage0 f-nat-operacao-filtro-1 = "" AND INPUT FRAME fPage0 f-nat-operacao-filtro-2 = "") OR
            INPUT FRAME fPage0 f-nat-operacao-filtro-1 = docum-est.nat-operacao OR
            INPUT FRAME fPage0 f-nat-operacao-filtro-2 = docum-est.nat-operacao
          )
    ,
    FIRST emitente NO-LOCK OF docum-est 
    ,
    EACH dupli-apagar NO-LOCK OF docum-est
    WHERE (dupli-apagar.cod-esp = 'NF' OR dupli-apagar.cod-esp = 'FL')
    :
    ASSIGN v_cont = v_cont + 1 .
    RUN pi-acompanhar IN h-acomp (INPUT "Registros: " + STRING(v_cont) + " - " + "Estab: " + STRING(estabelec.cod-estabel) ) .
    /**/
    CREATE tt-docto .
    ASSIGN
        tt-docto.serie-docto        = docum-est.serie-docto   
        tt-docto.nro-docto          = docum-est.nro-docto     
        tt-docto.cod-emitente       = docum-est.cod-emitente  
        tt-docto.nat-operacao       = docum-est.nat-operacao  
        tt-docto.cod-estabel        = docum-est.cod-estabel   
        tt-docto.dt-emissao         = docum-est.dt-emissao    
        tt-docto.dt-trans           = docum-est.dt-trans   
        tt-docto.nome-emit          = emitente.nome-emit
        tt-docto.cod-esp            = dupli-apagar.cod-esp
        tt-docto.parcela            = dupli-apagar.parcela
        tt-docto.dt-vencim          = dupli-apagar.dt-vencim
        tt-docto.vl-docto           = dupli-apagar.vl-a-pagar
        tt-docto.vl-a-pagar         = dupli-apagar.vl-a-pagar
        .

    FOR FIRST int_ds_ext_emitente NO-LOCK 
        WHERE int_ds_ext_emitente.cod_emitente = emitente.cod-emitente
        :
        ASSIGN tt-docto.simples-nac = int_ds_ext_emitente.microempresa   .
    END.

    FOR EACH dupli-imp NO-LOCK OF docum-est
        WHERE dupli-imp.cod-esp = "IT"
        :
        ASSIGN tt-docto.vl-a-pagar = tt-docto.vl-a-pagar + dupli-imp.vl-imposto .
    END.

    FOR FIRST dupli-imp NO-LOCK OF docum-est
        WHERE dupli-imp.cod-esp = "IS"
        :
        ASSIGN
            tt-docto.cod-imposto        = dupli-imp.int-1
            tt-docto.cod-retencao       = dupli-imp.cod-retencao
            tt-docto.rend-trib          = dupli-imp.rend-trib
            tt-docto.aliquota           = dupli-imp.aliquota
            tt-docto.vl-imposto         = dupli-imp.vl-imposto
            .
    END.

    /* Casos sem retencao de ISS , buscar a atividade do fornecedor */
    IF tt-docto.cod-retencao = 0 THEN DO:
        FOR FIRST fornecedor NO-LOCK
            WHERE fornecedor.cdn_fornecedor = tt-docto.cod-emitente
            ,
            FIRST pessoa_jurid_ativid NO-LOCK
            WHERE pessoa_jurid_ativid.num_pessoa_jurid = fornecedor.num_pessoa
            :
            ASSIGN tt-docto.cod-retencao = INT(pessoa_jurid_ativid.cod_ativid_pessoa_jurid) NO-ERROR .
            IF tt-docto.cod-retencao = ? THEN DO:
                ASSIGN tt-docto.cod-retencao = 0 .
            END.
        END.
    END.
    /**/

    ASSIGN f-tot-gerados-n = f-tot-gerados-n + 1 .
    FOR FIRST cst_dupli_apagar NO-LOCK OF dupli-apagar
        :
        ASSIGN
            tt-docto.l_ger              = cst_dupli_apagar.l_ger
            tt-docto.cod_usuario_ger    = cst_dupli_apagar.cod_usuario_ger
            tt-docto.dt_ger             = cst_dupli_apagar.dt_ger
            tt-docto.hr_ger             = cst_dupli_apagar.hr_ger
            .
        IF tt-docto.l_ger = YES THEN DO:
            ASSIGN f-tot-gerados-n = f-tot-gerados-n - 1 .
            ASSIGN f-tot-gerados-s = f-tot-gerados-s + 1 .
        END.
    END.
END.

RUN piLoadBrowser0 .

DISPLAY f-tot-gerados-n f-tot-gerados-s WITH FRAME fPage0 .

/**/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piGerar wWindow 
PROCEDURE piGerar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF VAR v_dir   AS CHAR NO-UNDO .
DEF VAR v_cont  AS INT NO-UNDO .

SYSTEM-DIALOG GET-DIR v_dir
    INITIAL-DIR SESSION:TEMP-DIR + "integraPref"
    RETURN-TO-START-DIR
    TITLE "Escolha o Diret¢rio Onde os Arquivos Ser∆o Gerados"
    .
IF v_dir = ? OR v_dir = "" THEN RETURN "NOK".        

EMPTY TEMP-TABLE tt-param .
EMPTY TEMP-TABLE tt-docto-ger .

CREATE tt-param . ASSIGN
    tt-param.empresa            = i-ep-codigo-usuario          
    tt-param.destino            = 2 /* Arquivo */
    tt-param.arquivo            = "csap008.txt"
    tt-param.usuario            = c-seg-usuario
    tt-param.data-exec          = TODAY
    tt-param.hora-exec          = TIME
    tt-param.classifica         = 1
    tt-param.desc-classifica    = ""   
    tt-param.mes-transacao      = INPUT FRAME fPage0 f-mes-transacao
    tt-param.ano-transacao      = INPUT FRAME fPage0 f-ano-transacao
    tt-param.cod-prefeitura     = INPUT FRAME fPage0 cb-prefeituras
    tt-param.dir-arquivos       = v_dir
    tt-param.l-teste            = INPUT FRAME fPage0 t-teste
    .

DO v_cont = 1 TO brTable0:NUM-SELECTED-ROWS IN FRAME fPage0
    :
    brTable0:FETCH-SELECTED-ROW(v_cont) IN FRAME fPage0 .
    CREATE tt-docto-ger . 
    BUFFER-COPY tt-docto TO tt-docto-ger .
END.

RUN VALUE("cstp/csap008a" + STRING(INPUT FRAME fPage0 cb-prefeituras) + ".p") 
    (INPUT TABLE tt-param ,
     INPUT TABLE tt-docto-ger )
    .

/* Efetivar */
IF INPUT FRAME fPage0 t-teste = NO THEN DO:
    FOR EACH tt-docto-ger NO-LOCK
        :
        FIND FIRST cst_dupli_apagar OF tt-docto-ger NO-ERROR .
        IF NOT AVAIL cst_dupli_apagar THEN DO:
            CREATE cst_dupli_apagar . ASSIGN
                cst_dupli_apagar.serie-docto    = tt-docto-ger.serie-docto
                cst_dupli_apagar.nro-docto      = tt-docto-ger.nro-docto
                cst_dupli_apagar.cod-emitente   = tt-docto-ger.cod-emitente
                cst_dupli_apagar.nat-operacao   = tt-docto-ger.nat-operacao
                cst_dupli_apagar.parcela        = tt-docto-ger.parcela
                .
        END.
        ASSIGN
            cst_dupli_apagar.l_ger              = TRUE
            cst_dupli_apagar.cod_usuario_ger    = c-seg-usuario
            cst_dupli_apagar.dt_ger             = TODAY
            cst_dupli_apagar.hr_ger             = TIME
            .
    END.
END.
/**/

RUN utp/ut-msgs.p ("show" , "15825" , 
                   "Arquivo(s) gerado(s).~~" + 
                   "Diret¢rio: " + v_dir) 
    .

RUN piBuscar .

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piLoadBrowser0 wWindow 
PROCEDURE piLoadBrowser0 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

{&open-query-brTable0}

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piRetornar wWindow 
PROCEDURE piRetornar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF VAR v_cont  AS INT NO-UNDO .

EMPTY TEMP-TABLE tt-docto-ger .
DO v_cont = 1 TO brTable0:NUM-SELECTED-ROWS IN FRAME fPage0
    :
    brTable0:FETCH-SELECTED-ROW(v_cont) IN FRAME fPage0 .
    CREATE tt-docto-ger . 
    BUFFER-COPY tt-docto TO tt-docto-ger .
END.

/* Retornar */
FOR EACH tt-docto-ger NO-LOCK
    :
    FOR EACH cst_dupli_apagar OF tt-docto-ger
        :
        ASSIGN
            cst_dupli_apagar.l_ger              = FALSE
            cst_dupli_apagar.cod_usuario_ger    = ""
            cst_dupli_apagar.dt_ger             = ?
            cst_dupli_apagar.hr_ger             = 0
            .
    END.
END.
/**/

RUN utp/ut-msgs.p ("show" , "15825" , 
                   "Notas(s) retornada(s).~~" + 
                   "") 
    .

RUN piBuscar .

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

