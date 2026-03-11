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
{include/i-prgvrs.i NICR008B 9.99.99.999}

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
def new global shared var gr-movto-furo as rowid no-undo.
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE TEMP-TABLE tt-movto-furo LIKE cst_furo_caixa
    FIELD nome-colaborador AS CHAR FORMAT "x(200)" COLUMN-LABEL "Nome Colaborador".

DEFINE TEMP-TABLE tt-movto-furo-aux LIKE cst_furo_caixa
    FIELD nome-colaborador AS CHAR FORMAT "x(200)" COLUMN-LABEL "Nome Colaborador".

DEFINE VARIABLE vl_saldo LIKE tt-movto-furo.vl_furo  NO-UNDO.
DEFINE VARIABLE lErro    AS LOGICAL     NO-UNDO.

DEFINE VARIABLE r-cst_furo_caixa AS ROWID       NO-UNDO.
DEFINE VARIABLE r-movto-tit-acr  AS ROWID       NO-UNDO.

DEFINE VARIABLE c-cod-refer      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_log_refer_uni  AS LOGICAL            .
DEFINE VARIABLE v_log_integr_cmg AS LOGICAL            .
DEFINE VARIABLE v_hdl_program    AS HANDLE      NO-UNDO.

DEFINE BUFFER b_movto_tit_acr  FOR movto_tit_acr.
DEFINE BUFFER bf_movto_tit_acr FOR movto_tit_acr.

{intprg/nicr008.i}

DEFINE TEMP-TABLE tt-erro NO-UNDO
    FIELD i-sequen    AS INTEGER
    FIELD cd-erro     AS INTEGER
    FIELD mensagem    AS CHAR
    FIELD ajuda       AS CHAR. 

PROCEDURE WinExec EXTERNAL "kernel32" :
    DEF INPUT PARAM lpszCmdLine AS CHAR.
    DEF INPUT PARAM fuCmdShow AS LONG.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-livre
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-cad
&Scoped-define BROWSE-NAME br-movto-subs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-movto-furo

/* Definitions for BROWSE br-movto-subs                                 */
&Scoped-define FIELDS-IN-QUERY-br-movto-subs tt-movto-furo.mat_colabor tt-movto-furo.nome-colaborador tt-movto-furo.dat_bordero tt-movto-furo.tip_furo tt-movto-furo.vl_furo   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-movto-subs   
&Scoped-define SELF-NAME br-movto-subs
&Scoped-define QUERY-STRING-br-movto-subs FOR EACH tt-movto-furo
&Scoped-define OPEN-QUERY-br-movto-subs OPEN QUERY {&SELF-NAME} FOR EACH tt-movto-furo.
&Scoped-define TABLES-IN-QUERY-br-movto-subs tt-movto-furo
&Scoped-define FIRST-TABLE-IN-QUERY-br-movto-subs tt-movto-furo


/* Definitions for FRAME f-cad                                          */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-cad ~
    ~{&OPEN-QUERY-br-movto-subs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rt-button RECT-1 RECT-2 rt-buttom RECT-12 ~
fi-bo ed-observacao br-movto-subs bt-incluir bt-eliminar ~
bt-gera-movto-menor bt-cancelar 
&Scoped-Define DISPLAYED-OBJECTS fi-bordero fi-matricula fi-nome-func ~
fi-data fi-valor fi-saldo fi-tipo fi-bo ed-observacao 

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
DEFINE BUTTON bt-cancelar 
     LABEL "&Sair" 
     SIZE 15 BY 1.

DEFINE BUTTON bt-eliminar 
     LABEL "&Eliminar" 
     SIZE 15 BY 1.

DEFINE BUTTON bt-gera-movto-menor 
     LABEL "&Gera Movto -" 
     SIZE 15 BY 1.

DEFINE BUTTON bt-incluir 
     LABEL "&Incluir" 
     SIZE 15 BY 1.

DEFINE VARIABLE ed-observacao AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 86 BY 4.38 NO-UNDO.

DEFINE VARIABLE fi-bo AS INTEGER FORMAT ">>>>>>>9":U INITIAL 0 
     LABEL "BO" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 TOOLTIP "Boletim de Ocorrància" NO-UNDO.

DEFINE VARIABLE fi-bordero AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Borderì" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE fi-data AS DATE FORMAT "99/99/9999":U 
     LABEL "Data" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-matricula AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Matr°cula" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nome-func AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 40.72 BY .88 NO-UNDO.

DEFINE VARIABLE fi-saldo AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Saldo" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-tipo AS CHARACTER FORMAT "X(256)":U 
     LABEL "Tipo" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-valor AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Valor" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 89.72 BY 11.96.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 5.04.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 89.72 BY 8.83.

DEFINE RECTANGLE rt-buttom
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 89.72 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 89.72 BY 1.46
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-movto-subs FOR 
      tt-movto-furo SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-movto-subs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-movto-subs w-livre _FREEFORM
  QUERY br-movto-subs DISPLAY
      tt-movto-furo.mat_colabor
 tt-movto-furo.nome-colaborador WIDTH 40
 tt-movto-furo.dat_bordero COLUMN-LABEL "Dat. Movto"
 tt-movto-furo.tip_furo WIDTH 10
 tt-movto-furo.vl_furo
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 88.29 BY 7.08 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-cad
     fi-bordero AT ROW 2.75 COL 14.14 COLON-ALIGNED WIDGET-ID 2
     fi-matricula AT ROW 3.75 COL 14.14 COLON-ALIGNED WIDGET-ID 6
     fi-nome-func AT ROW 3.75 COL 28.29 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     fi-data AT ROW 4.75 COL 14.14 COLON-ALIGNED WIDGET-ID 8
     fi-valor AT ROW 5.75 COL 14.14 COLON-ALIGNED WIDGET-ID 12
     fi-saldo AT ROW 5.75 COL 36.72 COLON-ALIGNED WIDGET-ID 14
     fi-tipo AT ROW 6.75 COL 14.14 COLON-ALIGNED WIDGET-ID 16
     fi-bo AT ROW 7.75 COL 14.14 COLON-ALIGNED WIDGET-ID 26
     ed-observacao AT ROW 9.63 COL 3.29 NO-LABEL WIDGET-ID 46
     br-movto-subs AT ROW 15.17 COL 2.14 WIDGET-ID 200
     bt-incluir AT ROW 22.33 COL 2.29 WIDGET-ID 36
     bt-eliminar AT ROW 22.33 COL 17.43 WIDGET-ID 40
     bt-gera-movto-menor AT ROW 23.83 COL 2 WIDGET-ID 48
     bt-cancelar AT ROW 23.83 COL 75.29 WIDGET-ID 32
     "Hist¢rico" VIEW-AS TEXT
          SIZE 6 BY .67 AT ROW 8.96 COL 3 WIDGET-ID 44
     "Substituir Movimentos" VIEW-AS TEXT
          SIZE 14.29 BY .67 AT ROW 14.46 COL 2.72 WIDGET-ID 34
     rt-button AT ROW 1 COL 1.43
     RECT-1 AT ROW 2.54 COL 1.57 WIDGET-ID 4
     RECT-2 AT ROW 14.67 COL 1.57 WIDGET-ID 22
     rt-buttom AT ROW 23.63 COL 1.43 WIDGET-ID 28
     RECT-12 AT ROW 9.25 COL 2.29 WIDGET-ID 42
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90.43 BY 24.29 WIDGET-ID 100.


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
         TITLE              = "Conferància Furo Caixa"
         HEIGHT             = 24.17
         WIDTH              = 90.57
         MAX-HEIGHT         = 33
         MAX-WIDTH          = 228.57
         VIRTUAL-HEIGHT     = 33
         VIRTUAL-WIDTH      = 228.57
         RESIZE             = yes
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
/* SETTINGS FOR FRAME f-cad
   FRAME-NAME L-To-R                                                    */
/* BROWSE-TAB br-movto-subs ed-observacao f-cad */
/* SETTINGS FOR FILL-IN fi-bordero IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-data IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-matricula IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-nome-func IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-saldo IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-tipo IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-valor IN FRAME f-cad
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-livre)
THEN w-livre:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-movto-subs
/* Query rebuild information for BROWSE br-movto-subs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-movto-furo.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-movto-subs */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-livre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-livre w-livre
ON END-ERROR OF w-livre /* Conferància Furo Caixa */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-livre w-livre
ON WINDOW-CLOSE OF w-livre /* Conferància Furo Caixa */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-movto-subs
&Scoped-define SELF-NAME br-movto-subs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-movto-subs w-livre
ON ROW-DISPLAY OF br-movto-subs IN FRAME f-cad
DO:
  ASSIGN vl_saldo = vl_saldo + tt-movto-furo.vl_furo.

  ASSIGN fi-saldo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING((INPUT FRAME {&FRAME-NAME} fi-valor - vl_saldo),"->>>,>>>,>>9.99").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar w-livre
ON CHOOSE OF bt-cancelar IN FRAME f-cad /* Sair */
DO:
  APPLY "CLOSE" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-eliminar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-eliminar w-livre
ON CHOOSE OF bt-eliminar IN FRAME f-cad /* Eliminar */
DO:
  IF AVAIL tt-movto-furo THEN DO:
      DELETE tt-movto-furo.

       ASSIGN fi-saldo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = INPUT FRAME {&FRAME-NAME} fi-valor.
       ASSIGN vl_saldo = 0.

      {&OPEN-QUERY-BR-MOVTO-SUBS}
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-gera-movto-menor
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-gera-movto-menor w-livre
ON CHOOSE OF bt-gera-movto-menor IN FRAME f-cad /* Gera Movto - */
DO:
  EMPTY TEMP-TABLE tt-erro.

  ASSIGN lErro = NO.
  RUN pi-salvar-informacoes.

  IF lErro = NO THEN
      APPLY "CLOSE" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-incluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-incluir w-livre
ON CHOOSE OF bt-incluir IN FRAME f-cad /* Incluir */
DO:
  DEFINE VARIABLE idSequencia AS INTEGER     NO-UNDO.

  RUN intprg/nicr008b.w(INPUT YES,
                        INPUT-OUTPUT TABLE tt-movto-furo-aux).

  ASSIGN vl_saldo = 0.


  FOR EACH tt-movto-furo-aux:

      FOR LAST tt-movto-furo NO-LOCK
             BY tt-movto-furo.codigo
             BY tt-movto-furo.ind_sequencia .
          ASSIGN idSequencia = tt-movto-furo.ind_sequencia + 1.
      END.

      IF idSequencia = 0 THEN
          ASSIGN idSequencia = 1.

      
      FIND FIRST tt-movto-furo EXCLUSIVE-LOCK
           WHERE tt-movto-furo.cod_estab    = tt-movto-furo-aux.cod_estab  
             AND tt-movto-furo.dat_bordero  = tt-movto-furo-aux.dat_bordero
             AND tt-movto-furo.num_bordero  = tt-movto-furo-aux.num_bordero
             AND tt-movto-furo.mat_colabor  = tt-movto-furo-aux.mat_colabor
             AND tt-movto-furo.tip_furo     = tt-movto-furo-aux.tip_furo    NO-ERROR.
      IF NOT AVAIL tt-movto-furo THEN DO:
          CREATE tt-movto-furo.
          ASSIGN tt-movto-furo.ind_sequencia = idSequencia.
          BUFFER-COPY tt-movto-furo-aux EXCEPT tt-movto-furo-aux.ind_sequencia TO tt-movto-furo.
      END.
      ELSE DO:
          run utp/ut-msgs.p (input "show":U, 
                             input 17006, 
                             input "J† existe um movimento igual para substiuiá∆o!~~Favor verificar a movimentaá∆o a ser criada!").
      END.
  END.

  {&OPEN-QUERY-BR-MOVTO-SUBS}
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


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-livre 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

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
       RUN set-position IN h_p-exihel ( 1.17 , 74.14 ) NO-ERROR.
       /* Size in UIB:  ( 1.25 , 16.00 ) */

       /* Links to SmartPanel h_p-exihel. */
       RUN add-link IN adm-broker-hdl ( h_p-exihel , 'State':U , THIS-PROCEDURE ).

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_p-exihel ,
             fi-bordero:HANDLE IN FRAME f-cad , 'BEFORE':U ).
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
  DISPLAY fi-bordero fi-matricula fi-nome-func fi-data fi-valor fi-saldo fi-tipo 
          fi-bo ed-observacao 
      WITH FRAME f-cad IN WINDOW w-livre.
  ENABLE rt-button RECT-1 RECT-2 rt-buttom RECT-12 fi-bo ed-observacao 
         br-movto-subs bt-incluir bt-eliminar bt-gera-movto-menor bt-cancelar 
      WITH FRAME f-cad IN WINDOW w-livre.
  {&OPEN-BROWSERS-IN-QUERY-f-cad}
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

  {utp/ut9000.i "NICR008A" "9.99.99.999"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  run pi-after-initialize.

  RUN pi-local-initialize.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cria-tt-erro w-livre 
PROCEDURE pi-cria-tt-erro :
DEFINE INPUT PARAMETER p-i-sequen    AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER p-cd-erro     AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER p-mensagem    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-ajuda       AS CHARACTER NO-UNDO.
    
    CREATE tt-erro.
    ASSIGN tt-erro.i-sequen    = p-i-sequen
           tt-erro.cd-erro     = p-cd-erro 
           tt-erro.mensagem    = p-mensagem
           tt-erro.ajuda       = p-ajuda.

    RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-movto w-livre 
PROCEDURE pi-gera-movto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE numIdMovtoFuro LIKE movto_tit_acr.num_id_movto_tit_acr.

DEFINE VARIABLE idSeqFuro      AS INTEGER     NO-UNDO.

IF lErro = NO THEN DO:
    movto_block:
    DO TRANSACTION ON ERROR UNDO:
    
        IF CAN-FIND(FIRST tt-movto-furo) THEN DO:
    
            FOR EACH tt-movto-furo:
                
                FIND FIRST movto_tit_acr NO-LOCK
                     WHERE ROWID(movto_tit_acr) = gr-movto-furo NO-ERROR.


    
                FIND FIRST tit_acr OF movto_tit_acr NO-LOCK 
/*                      WHERE tit_acr.cod_estab       = tt-movto-furo.cod_estab                                               */
/*                        AND tit_acr.cod_espec_docto = "DI"                                                                  */
/*                        AND tit_acr.cod_tit_acr     = "DINH" + REPLACE(STRING(tt-movto-furo.dat_bordero,"99/99/99"),"/","") */
    /*                    AND tit_acr.log_sdo_tit_acr = YES */
                    NO-ERROR.
                IF AVAIL tit_acr THEN DO:
                    IF tt-movto-furo.tip_furo <> "REPOSIÄ«O" THEN DO:
                        RUN pi-movto-menor-especifico(INPUT tt-movto-furo.cod_estab,   /* Estabelecimento    */
                                                      INPUT tit_acr.num_id_tit_acr,    /* ID Titulo ACR      */
                                                      INPUT tt-movto-furo.tip_furo,    /* Tipo Movto         */
                                                      INPUT tt-movto-furo.vl_furo,     /* Valor Movto        */
                                                      INPUT tt-movto-furo.des_observ,  /* Historico da Movimentaá∆o */   
                                                      INPUT tt-movto-furo.dat_bordero, /* Data Furo                 */ 
                                                      OUTPUT numIdMovtoFuro). 
                    END.
                    ELSE DO:
                        RUN pi-movto-liquid-especifico(INPUT tt-movto-furo.cod_estab,   /* Estabelecimento           */  
                                                       INPUT tit_acr.num_id_tit_acr,    /* ID Titulo ACR             */  
                                                       INPUT tt-movto-furo.tip_furo,    /* Tipo Movto                */  
                                                       INPUT tt-movto-furo.vl_furo,     /* Valor Movto               */  
                                                       INPUT tt-movto-furo.des_observ,  /* Historico da Movimentaá∆o */  
                                                       INPUT tt-movto-furo.dat_bordero, /* Data Furo                 */ 
                                                       OUTPUT numIdMovtoFuro).
                    END.
        
                    IF lErro = NO THEN DO:
                        /* Cria o Movto do Furo na Tabela Especifica */
                        ASSIGN idSeqFuro = 0.
                        FOR LAST cst_furo_caixa
                           WHERE cst_furo_caixa.codigo = tt-movto-furo.codigo NO-LOCK
                              BY cst_furo_caixa.codigo
                              BY cst_furo_caixa.ind_sequencia :
                            ASSIGN idSeqFuro = cst_furo_caixa.ind_sequencia + 1.
                        END.
    
                        IF idSeqFuro = 0 THEN ASSIGN idSeqFuro = 1.
    
                        CREATE cst_furo_caixa.
                        ASSIGN cst_furo_caixa.codigo        = tt-movto-furo.codigo
                               cst_furo_caixa.ind_sequencia = idSeqFuro.
    
                        BUFFER-COPY tt-movto-furo EXCEPT tt-movto-furo.codigo tt-movto-furo.ind_sequencia TO cst_furo_caixa.
                        ASSIGN cst_furo_caixa.situacao             = 1
                               cst_furo_caixa.num_id_tit_acr       = tit_acr.num_id_tit_acr
                               cst_furo_caixa.num_id_movto_tit_acr = numIdMovtoFuro.
                    END.
                END.
                ELSE DO:
                    RUN pi-cria-tt-erro(INPUT 1,
                                        INPUT 17006,
                                        INPUT "Estab/Especie/Titulo: " + string(tt-movto-furo.cod_estab) + "/DI/" + STRING("DINH" + REPLACE(STRING(tt-movto-furo.dat_bordero,"99/99/99"),"/","") ) + " , n∆o encontrado .",
                                        INPUT "Estab/Especie/Titulo: " + string(tt-movto-furo.cod_estab) + "/DI/" + STRING("DINH" + REPLACE(STRING(tt-movto-furo.dat_bordero,"99/99/99"),"/","") ) + " , n∆o encontrado .").                
    
                    UNDO movto_block, LEAVE movto_block.
                END.
            END.
        
            IF lErro = YES THEN DO:
                UNDO movto_block, LEAVE movto_block.
            END.
        END.
    END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-local-initialize w-livre 
PROCEDURE pi-local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

FIND FIRST movto_tit_acr NO-LOCK
     WHERE ROWID(movto_tit_acr) = gr-movto-furo NO-ERROR.
IF AVAIL movto_tit_acr THEN DO:
    FIND FIRST cst_furo_caixa NO-LOCK
         WHERE cst_furo_caixa.num_id_tit_acr       = movto_tit_acr.num_id_tit_acr      
           AND cst_furo_caixa.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr NO-ERROR.
    IF AVAIL cst_furo_caixa THEN DO:

        ASSIGN r-cst_furo_caixa = ROWID(cst_furo_caixa)
               r-movto-tit-acr  = ROWID(movto_tit_acr).

        ASSIGN fi-bordero:SCREEN-VALUE IN FRAME {&FRAME-NAME}    = cst_furo_caixa.num_bordero
               fi-matricula:SCREEN-VALUE IN FRAME {&FRAME-NAME}  = cst_furo_caixa.mat_colabor
               fi-data:SCREEN-VALUE IN FRAME {&FRAME-NAME}       = STRING(cst_furo_caixa.dat_bordero,"99/99/9999").
        ASSIGN fi-valor:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = STRING(cst_furo_caixa.vl_furo,">>>,>>>,>>9.99")
               fi-saldo:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = STRING(cst_furo_caixa.vl_furo,">>>,>>>,>>9.99")
               fi-tipo:SCREEN-VALUE IN FRAME {&FRAME-NAME}       = cst_furo_caixa.tip_furo 
               ed-observacao:SCREEN-VALUE IN FRAME {&FRAME-NAME} = cst_furo_caixa.des_observ
               fi-bo:SCREEN-VALUE IN FRAME {&FRAME-NAME}         = STRING(cst_furo_caixa.num_bo)
            .

        IF cst_furo_caixa.tip_furo <> "SINISTRO" THEN DO:
            DISABLE fi-bo WITH FRAME {&FRAME-NAME}.
        END.
        ELSE DO:
            ENABLE fi-bo WITH FRAME {&FRAME-NAME}.
        END.

/*         FIND FIRST VR034FUN NO-LOCK                                                                  */
/*              WHERE VR034FUN.NUMCAD = INT(cst_furo_caixa.mat_colabor) NO-ERROR.                       */
/*         IF AVAIL VR034FUN THEN DO:                                                                   */
/*             ASSIGN fi-nome-func:SCREEN-VALUE IN FRAME {&FRAME-NAME} = CAPS(VR034FUN.NOMFUN).         */
/*         END.                                                                                         */
/*         ELSE  DO:                                                                                    */
/*              ASSIGN fi-nome-func:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "FUNCIONµRIO N«O ENCONTRADO". */
/*         END.                                                                                         */
    END.
    ELSE DO:
        APPLY "CLOSE":U TO THIS-PROCEDURE.
    END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-movto-liquid-especifico w-livre 
PROCEDURE pi-movto-liquid-especifico :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF INPUT  PARAM p-cod-estab         AS CHAR                                 NO-UNDO.
DEF INPUT  PARAM p-tit-acr           AS INT                                  NO-UNDO.
DEF INPUT  PARAM p-tipo              AS CHAR                                 NO-UNDO.
DEF INPUT  PARAM p-valor             AS DECIMAL                              NO-UNDO.
DEF INPUT  PARAM p-historico         AS CHAR  FORMAT "x(2000)"               NO-UNDO.
DEF INPUT  PARAM p-data              AS DATE                                 NO-UNDO.
DEF OUTPUT PARAM idNumMovto          LIKE movto_tit_acr.num_id_movto_tit_acr NO-UNDO.

      empty temp-table tt_integr_acr_liquidac_lote    no-error.
      empty temp-table tt_integr_acr_liq_item_lote    no-error.
      empty temp-table tt_integr_acr_abat_antecip     no-error.
      empty temp-table tt_integr_acr_abat_prev        no-error.
      empty temp-table tt_integr_acr_cheq             no-error.
      empty temp-table tt_integr_acr_liquidac_impto   no-error.
      empty temp-table tt_integr_acr_rel_pend_cheq    no-error.
      empty temp-table tt_integr_acr_liq_aprop_ctbl   no-error.
      empty temp-table tt_integr_acr_liq_desp_rec     no-error.
      empty temp-table tt_integr_acr_aprop_liq_antec  no-error.
      empty temp-table tt_log_erros_import_liquidac   no-error.

      RUN pi_retorna_sugestao_referencia (INPUT  "FC",
                                          INPUT  TODAY,
                                          OUTPUT c-cod-refer,
                                          INPUT  "tit_acr",
                                          INPUT  STRING(tit_acr.cod_estab)).

      create tt_integr_acr_liquidac_lote. 
      assign tt_integr_acr_liquidac_lote.tta_cod_empresa             = tit_acr.cod_empresa
             tt_integr_acr_liquidac_lote.tta_cod_estab_refer         = tit_acr.cod_estab
             tt_integr_acr_liquidac_lote.tta_cod_refer               = c-cod-refer
             tt_integr_acr_liquidac_lote.tta_cod_usuario             = v_cod_usuar_corren
             tt_integr_acr_liquidac_lote.tta_dat_transacao           = p-data
             tt_integr_acr_liquidac_lote.tta_dat_gerac_lote_liquidac = p-data
             tt_integr_acr_liquidac_lote.tta_ind_tip_liquidac_acr    = "lote" /*l_lote*/ 
             tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr   = recid(tt_integr_acr_liquidac_lote)
             tt_integr_acr_liquidac_lote.ttv_log_atualiz_refer       = YES  .

      create tt_integr_acr_liq_item_lote.
      assign tt_integr_acr_liq_item_lote.tta_cod_empresa                     = tit_acr.cod_empresa
             tt_integr_acr_liq_item_lote.tta_cod_estab                       = tit_acr.cod_estab
             tt_integr_acr_liq_item_lote.tta_cod_espec_docto                 = tit_acr.cod_espec_docto
             tt_integr_acr_liq_item_lote.tta_cod_ser_docto                   = tit_acr.cod_ser_docto
             tt_integr_acr_liq_item_lote.tta_num_seq_refer                   = 1
             tt_integr_acr_liq_item_lote.tta_cod_tit_acr                     = tit_acr.cod_tit_acr
             tt_integr_acr_liq_item_lote.tta_cod_parcela                     = tit_acr.cod_parcela
             tt_integr_acr_liq_item_lote.tta_cod_indic_econ                  = tit_acr.cod_indic_econ
             tt_integr_acr_liq_item_lote.tta_dat_cr_liquidac_tit_acr         = p-data
             tt_integr_acr_liq_item_lote.tta_dat_liquidac_tit_acr            = p-data
             tt_integr_acr_liq_item_lote.tta_dat_cr_liquidac_calc            = p-data
             tt_integr_acr_liq_item_lote.tta_val_tit_acr                     = tit_acr.val_sdo_tit_acr - p-valor
             tt_integr_acr_liq_item_lote.tta_val_liquidac_tit_acr            = p-valor
             tt_integr_acr_liq_item_lote.tta_val_desc_tit_acr                = 0
             tt_integr_acr_liq_item_lote.tta_val_abat_tit_acr                = 0
             tt_integr_acr_liq_item_lote.tta_val_despes_bcia                 = 0
             tt_integr_acr_liq_item_lote.tta_val_multa_tit_acr               = 0
             tt_integr_acr_liq_item_lote.tta_val_juros                       = 0
             tt_integr_acr_liq_item_lote.ttv_rec_lote_liquidac_acr           = recid(tt_integr_acr_liquidac_lote)
             tt_integr_acr_liq_item_lote.ttv_rec_item_lote_liquidac_acr      = recid(tt_integr_acr_liq_item_lote)
             tt_integr_acr_liq_item_lote.tta_ind_tip_item_liquidac_acr       = "Pagamento" 
             tt_integr_acr_liq_item_lote.tta_cdn_cliente                     = tit_acr.cdn_cliente
             tt_integr_acr_liq_item_lote.tta_cod_portador                    = tit_acr.cod_portador
             tt_integr_acr_liq_item_lote.tta_cod_cart_bcia                   = "CAR"
             tt_integr_acr_liq_item_lote.tta_log_gera_antecip                = NO 
             tt_integr_acr_liq_item_lote.tta_des_text_histor                 = p-historico
             tt_integr_acr_liq_item_lote.tta_log_gera_avdeb                  = NO 
             tt_integr_acr_liq_item_lote.tta_log_movto_comis_estordo         = NO .

             run prgfin/acr/acr901zc.py (Input 1,
                                        Input table tt_integr_acr_liquidac_lote,
                                        Input table tt_integr_acr_liq_item_lote,
                                        Input table tt_integr_acr_abat_antecip,
                                        Input table tt_integr_acr_abat_prev,
                                        Input table tt_integr_acr_cheq,
                                        Input table tt_integr_acr_liquidac_impto,
                                        Input table tt_integr_acr_rel_pend_cheq,
                                        Input table tt_integr_acr_liq_aprop_ctbl,
                                        Input table tt_integr_acr_liq_desp_rec,
                                        Input table tt_integr_acr_aprop_liq_antec,
                                        Input "",
                                        output table tt_log_erros_import_liquidac) /*prg_api_integr_acr_liquidac_new*/.

             IF can-find(first tt_log_erros_import_liquidac) then do:
                 FIND FIRST tt_integr_acr_liq_item_lote NO-LOCK NO-ERROR.
                 IF AVAIL tt_integr_acr_liq_item_lote THEN DO:
                     RUN pi-cria-tt-erro(INPUT 1,
                                         INPUT 17006,
                                         INPUT "Estab/Especie/Titulo: " + string(tt_integr_acr_liq_item_lote.tta_cod_estab) + "/DI/" + STRING(tt_integr_acr_liq_item_lote.tta_cod_tit_acr) + " , apresentou os erros abaixo.",
                                         INPUT "Estab/Especie/Titulo: " + string(tt_integr_acr_liq_item_lote.tta_cod_estab) + "/DI/" + STRING(tt_integr_acr_liq_item_lote.tta_cod_tit_acr) + " , apresentou os erros abaixo.").                
                 END.

                 FOR EACH tt_log_erros_import_liquidac:
                     RUN pi-cria-tt-erro(INPUT 1,
                                         INPUT tt_log_erros_import_liquidac.ttv_num_erro_log, 
                                         INPUT tt_log_erros_import_liquidac.ttv_des_msg_erro,
                                         INPUT tt_log_erros_import_liquidac.ttv_des_msg_erro).
                 END.
                 ASSIGN lErro = YES.

             END.
             ELSE DO:
                 FIND LAST bf_movto_tit_acr NO-LOCK
                     WHERE bf_movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr 
                       AND bf_movto_tit_acr.ind_trans_acr_abrev = "LIQ"       NO-ERROR.
                 IF AVAIL bf_movto_tit_acr THEN DO:
                     ASSIGN idNumMovto = bf_movto_tit_acr.num_id_movto_tit_acr.
                 END.
             END. /* */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-movto-maior-especifico w-livre 
PROCEDURE pi-movto-maior-especifico :
/***********************************************************************
    * Procedure     : pi-estorno-movto-especifico
    * Descricao     : Estorno de movimentos especifico
    ***********************************************************************/

    DEF INPUT PARAM p-cod-estab         AS CHAR                    NO-UNDO.
    DEF INPUT PARAM p-tit-acr           AS INT                     NO-UNDO.
    DEF INPUT PARAM p-movto             AS INT                     NO-UNDO.
    DEF INPUT PARAM p-data              AS DATE                    NO-UNDO.
    DEF INPUT PARAM p-historico         AS CHAR  FORMAT "x(2000)"  NO-UNDO.

    DEFINE VARIABLE iSeq                AS INTEGER     NO-UNDO.

    FIND FIRST tit_acr NO-LOCK
         WHERE tit_acr.num_id_tit_acr = p-tit-acr NO-ERROR.

    FIND FIRST movto_tit_acr NO-LOCK
         WHERE movto_tit_acr.num_id_movto_tit_acr = p-movto NO-ERROR.

    EMPTY TEMP-TABLE tt_alter_tit_acr_base_5         NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_rateio         NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_ped_vda        NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_comis_1        NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_cheq           NO-ERROR.      
    EMPTY TEMP-TABLE tt_alter_tit_acr_iva            NO-ERROR.          
    EMPTY TEMP-TABLE tt_alter_tit_acr_impto_retid_2  NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_cobr_espec_2   NO-ERROR. 
    EMPTY TEMP-TABLE tt_alter_tit_acr_rat_desp_rec   NO-ERROR. 
    EMPTY TEMP-TABLE tt_log_erros_alter_tit_acr      NO-ERROR.    

    FIND FIRST tt_alter_tit_acr_base_5 EXCLUSIVE-LOCK
         WHERE tt_alter_tit_acr_base_5.tta_cod_estab      = tit_acr.cod_estab
           AND tt_alter_tit_acr_base_5.tta_num_id_tit_acr = tit_acr.num_id_tit_acr NO-ERROR.
    IF NOT AVAIL tt_alter_tit_acr_base_5 THEN DO:
        CREATE tt_alter_tit_acr_base_5.
        ASSIGN tt_alter_tit_acr_base_5.tta_cod_estab      = tit_acr.cod_estab
               tt_alter_tit_acr_base_5.tta_num_id_tit_acr = tit_acr.num_id_tit_acr.
    END.

    RUN pi_retorna_sugestao_referencia (INPUT  "CF",
                                        INPUT  TODAY,
                                        OUTPUT c-cod-refer,
                                        INPUT  "tit_acr",
                                        INPUT  STRING(tit_acr.cod_estab)).

/*     MESSAGE "Maior - " p-data SKIP                                               */
/*             "tit_acr.val_sdo_tit_acr - " tit_acr.val_sdo_tit_acr SKIP            */
/*             "movto_tit_acr.val_movto_tit_acr - " movto_tit_acr.val_movto_tit_acr */
/*         VIEW-AS ALERT-BOX INFO BUTTONS OK.                                       */

    ASSIGN tt_alter_tit_acr_base_5.tta_dat_transacao               = p-data
           tt_alter_tit_acr_base_5.tta_cod_refer                   = CAPS(c-cod-refer)
           tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_imp = ?
           tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr             = tit_acr.val_sdo_tit_acr + movto_tit_acr.val_movto_tit_acr
/*            tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_alt = "SINISTRO" */
           tt_alter_tit_acr_base_5.ttv_ind_motiv_acerto_val        = "Alteraá∆o":U
           tt_alter_tit_acr_base_5.tta_cod_portador                = tit_acr.cod_portador
           tt_alter_tit_acr_base_5.tta_cod_cart_bcia               = tit_acr.cod_cart_bcia
           tt_alter_tit_acr_base_5.tta_val_despes_bcia             = tit_acr.val_despes_bcia
           tt_alter_tit_acr_base_5.tta_cod_agenc_cobr_bcia         = ""
           tt_alter_tit_acr_base_5.tta_cod_tit_acr_bco             = ""
           tt_alter_tit_acr_base_5.tta_dat_emis_docto              = tit_acr.dat_emis_docto
           tt_alter_tit_acr_base_5.tta_dat_vencto_tit_acr          = tit_acr.dat_vencto_tit_acr
           tt_alter_tit_acr_base_5.tta_dat_prev_liquidac           = tit_acr.dat_prev_liquidac
           tt_alter_tit_acr_base_5.tta_dat_fluxo_tit_acr           = tit_acr.dat_fluxo_tit_acr
           tt_alter_tit_acr_base_5.tta_ind_sit_tit_acr             = tit_acr.ind_sit_tit_acr
           tt_alter_tit_acr_base_5.tta_cod_cond_cobr               = tit_acr.cod_cond_cobr
           tt_alter_tit_acr_base_5.tta_log_tip_cr_perda_dedut_tit  = tit_acr.log_tip_cr_perda_dedut_tit
           tt_alter_tit_acr_base_5.tta_log_tit_acr_destndo         = tit_acr.log_tit_acr_destndo
           tt_alter_tit_acr_base_5.ttv_cod_portador_mov            = ""
           tt_alter_tit_acr_base_5.tta_ind_tip_cobr_acr            = tit_acr.ind_tip_cobr_acr
           &if '{&emsfin_version}' >= "5.02" &then
               tt_alter_tit_acr_base_5.tta_des_obs_cobr            = tit_acr.des_obs_cobr
           &endif
           tt_alter_tit_acr_base_5.ttv_log_estorn_impto_retid      = NO
           tt_alter_tit_acr_base_5.tta_cod_histor_padr             = ""
           tt_alter_tit_acr_base_5.ttv_des_text_histor             = p-historico
           tt_alter_tit_acr_base_5.tta_cdn_repres                  = tit_acr.cdn_repres
           tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_1_movto    = tit_acr.cod_instruc_bcia_1_acr  
           tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_2_movto    = tit_acr.cod_instruc_bcia_2_acr
           .

    ASSIGN iSeq =  10.
    FOR EACH aprop_ctbl_acr NO-LOCK
       WHERE aprop_ctbl_acr.cod_estab             = p-cod-estab
         AND aprop_ctbl_acr.num_id_movto_tit_acr  = p-movto
         AND aprop_ctbl_acr.ind_natur_lancto_ctbl = "DB" :

         CREATE tt_alter_tit_acr_rateio.
         ASSIGN tt_alter_tit_acr_rateio.tta_cod_estab                    = tt_alter_tit_acr_base_5.tta_cod_estab     
                tt_alter_tit_acr_rateio.tta_num_id_tit_acr               = tt_alter_tit_acr_base_5.tta_num_id_tit_acr
                tt_alter_tit_acr_rateio.ttv_ind_tip_rat_tit_acr          = "Alteraá∆o":U
                tt_alter_tit_acr_rateio.tta_cod_refer                    = c-cod-refer
                tt_alter_tit_acr_rateio.tta_num_seq_refer                = iSeq
                tt_alter_tit_acr_rateio.tta_cod_plano_cta_ctbl           = aprop_ctbl_acr.cod_plano_cta_ctbl   
                tt_alter_tit_acr_rateio.tta_cod_cta_ctbl                 = aprop_ctbl_acr.cod_cta_ctbl
                tt_alter_tit_acr_rateio.tta_cod_unid_negoc               = aprop_ctbl_acr.cod_unid_negoc 
                tt_alter_tit_acr_rateio.tta_cod_plano_ccusto             = aprop_ctbl_acr.cod_plano_ccusto
                tt_alter_tit_acr_rateio.tta_cod_ccusto                   = aprop_ctbl_acr.cod_ccusto
                tt_alter_tit_acr_rateio.tta_cod_tip_fluxo_financ         = "105"
                tt_alter_tit_acr_rateio.tta_num_seq_aprop_ctbl_pend_acr  = iSeq
                tt_alter_tit_acr_rateio.tta_val_aprop_ctbl               = aprop_ctbl_acr.val_aprop_ctbl
                tt_alter_tit_acr_rateio.tta_log_impto_val_agreg          = NO
                tt_alter_tit_acr_rateio.tta_cod_pais                     = ""
                tt_alter_tit_acr_rateio.tta_cod_unid_federac             = ""
                tt_alter_tit_acr_rateio.tta_cod_imposto                  = ""
                tt_alter_tit_acr_rateio.tta_cod_classif_impto            = ""
                tt_alter_tit_acr_rateio.tta_dat_transacao                = TODAY.

         ASSIGN iSeq = iSeq + 10.

    END.

    run prgfin/acr/acr711zv.py persistent set v_hdl_program /*prg_api_integr_acr_alter_tit_acr_novo_7*/.
    RUN pi_main_code_integr_acr_alter_tit_acr_novo_12 in v_hdl_program (Input 12,
                                                                        Input table  tt_alter_tit_acr_base_5,
                                                                        Input table  tt_alter_tit_acr_rateio,
                                                                        Input table  tt_alter_tit_acr_ped_vda,
                                                                        Input table  tt_alter_tit_acr_comis_1,
                                                                        Input table  tt_alter_tit_acr_cheq,
                                                                        Input table  tt_alter_tit_acr_iva,
                                                                        Input table  tt_alter_tit_acr_impto_retid_2,
                                                                        Input table  tt_alter_tit_acr_cobr_espec_2,
                                                                        Input table  tt_alter_tit_acr_rat_desp_rec,
                                                                        output table tt_log_erros_alter_tit_acr,
                                                                        Input v_log_integr_cmg) /*pi_main_code_integr_acr_alter_tit_acr_novo_12*/.
    delete procedure v_hdl_program.

    /*Tratamento de erros*/
    IF CAN-FIND(FIRST tt_log_erros_alter_tit_acr) THEN DO:
        FIND FIRST tt_alter_tit_acr_base_5 NO-LOCK NO-ERROR.
        IF AVAIL tt_alter_tit_acr_base_5 THEN DO:
            RUN pi-cria-tt-erro(INPUT 1,
                                INPUT 17006,
                                INPUT "Estab/Especie/Titulo: " + string(tt_alter_tit_acr_base_5.tta_cod_estab) + "/DI/" + STRING(tit_acr.cod_tit_acr) + " , apresentou os erros abaixo.",
                                INPUT "Estab/Especie/Titulo: " + string(tt_alter_tit_acr_base_5.tta_cod_estab) + "/DI/" + STRING(tit_acr.cod_tit_acr) + " , apresentou os erros abaixo.").                
        END.

        FOR EACH tt_log_erros_alter_tit_acr:
            RUN pi-cria-tt-erro(INPUT tt_log_erros_alter_tit_acr.tta_num_id_tit_acr,
                                INPUT tt_log_erros_alter_tit_acr.ttv_num_mensagem, 
                                INPUT tt_log_erros_alter_tit_acr.ttv_des_msg_erro,
                                INPUT tt_log_erros_alter_tit_acr.ttv_des_msg_ajuda).
        END.

        ASSIGN lErro = YES.
    END.
    ELSE DO:
        FIND FIRST cst_furo_caixa EXCLUSIVE-LOCK
             WHERE cst_furo_caixa.num_id_tit_acr       = tit_acr.num_id_tit_acr
               AND cst_furo_caixa.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr NO-ERROR.
        IF AVAIL cst_furo_caixa THEN DO:
            ASSIGN cst_furo_caixa.situacao = 2. /* Estornado */
        END.
        RELEASE cst_furo_caixa. 

        ASSIGN lErro = NO.
    END. /* */

/*     ASSIGN lErro = YES. */



END PROCEDURE. /* pi-estorno-movto-especifico */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-movto-menor-especifico w-livre 
PROCEDURE pi-movto-menor-especifico :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF INPUT  PARAM p-cod-estab         AS CHAR                                 NO-UNDO.
    DEF INPUT  PARAM p-tit-acr           AS INT                                  NO-UNDO.
    DEF INPUT  PARAM p-tipo              AS CHAR                                 NO-UNDO.
    DEF INPUT  PARAM p-valor             AS DECIMAL                              NO-UNDO.
    DEF INPUT  PARAM p-historico         AS CHAR  FORMAT "x(2000)"               NO-UNDO.
    DEF INPUT  PARAM p-data              AS DATE                                 NO-UNDO.
    DEF OUTPUT PARAM idNumMovto          LIKE movto_tit_acr.num_id_movto_tit_acr NO-UNDO.

    EMPTY TEMP-TABLE tt_alter_tit_acr_base_5         NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_rateio         NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_ped_vda        NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_comis_1        NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_cheq           NO-ERROR.      
    EMPTY TEMP-TABLE tt_alter_tit_acr_iva            NO-ERROR.          
    EMPTY TEMP-TABLE tt_alter_tit_acr_impto_retid_2  NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_cobr_espec_2   NO-ERROR. 
    EMPTY TEMP-TABLE tt_alter_tit_acr_rat_desp_rec   NO-ERROR. 
    EMPTY TEMP-TABLE tt_log_erros_alter_tit_acr      NO-ERROR.    

    FIND FIRST tt_alter_tit_acr_base_5 EXCLUSIVE-LOCK
         WHERE tt_alter_tit_acr_base_5.tta_cod_estab      = tit_acr.cod_estab
           AND tt_alter_tit_acr_base_5.tta_num_id_tit_acr = tit_acr.num_id_tit_acr NO-ERROR.
    IF NOT AVAIL tt_alter_tit_acr_base_5 THEN DO:
        CREATE tt_alter_tit_acr_base_5.
        ASSIGN tt_alter_tit_acr_base_5.tta_cod_estab      = tit_acr.cod_estab
               tt_alter_tit_acr_base_5.tta_num_id_tit_acr = tit_acr.num_id_tit_acr.
    END.

    ASSIGN c-cod-refer = "".
    RUN pi_retorna_sugestao_referencia (INPUT  "CF",
                                        INPUT  TODAY,
                                        OUTPUT c-cod-refer,
                                        INPUT  "tit_acr",
                                        INPUT  STRING(tit_acr.cod_estab)).

/*     MESSAGE "Menor - " p-data SKIP                                    */
/*             "tit_acr.val_sdo_tit_acr - " tit_acr.val_sdo_tit_acr SKIP */
/*             "p-valor - " p-valor                                      */
/*         VIEW-AS ALERT-BOX INFO BUTTONS OK.                            */

    ASSIGN tt_alter_tit_acr_base_5.tta_dat_transacao               = p-data
           tt_alter_tit_acr_base_5.tta_cod_refer                   = CAPS(c-cod-refer)
           tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_imp = ?
           tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr             = (tit_acr.val_sdo_tit_acr - p-valor)
           tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_alt = p-tipo
           tt_alter_tit_acr_base_5.ttv_ind_motiv_acerto_val        = "Alteraá∆o":U
           tt_alter_tit_acr_base_5.tta_cod_portador                = tit_acr.cod_portador
           tt_alter_tit_acr_base_5.tta_cod_cart_bcia               = tit_acr.cod_cart_bcia
           tt_alter_tit_acr_base_5.tta_val_despes_bcia             = tit_acr.val_despes_bcia
           tt_alter_tit_acr_base_5.tta_cod_agenc_cobr_bcia         = ""
           tt_alter_tit_acr_base_5.tta_cod_tit_acr_bco             = ""
           tt_alter_tit_acr_base_5.tta_dat_emis_docto              = tit_acr.dat_emis_docto
           tt_alter_tit_acr_base_5.tta_dat_vencto_tit_acr          = tit_acr.dat_vencto_tit_acr
           tt_alter_tit_acr_base_5.tta_dat_prev_liquidac           = tit_acr.dat_prev_liquidac
           tt_alter_tit_acr_base_5.tta_dat_fluxo_tit_acr           = tit_acr.dat_fluxo_tit_acr
           tt_alter_tit_acr_base_5.tta_ind_sit_tit_acr             = tit_acr.ind_sit_tit_acr
           tt_alter_tit_acr_base_5.tta_cod_cond_cobr               = tit_acr.cod_cond_cobr
           tt_alter_tit_acr_base_5.tta_log_tip_cr_perda_dedut_tit  = tit_acr.log_tip_cr_perda_dedut_tit
           tt_alter_tit_acr_base_5.tta_log_tit_acr_destndo         = tit_acr.log_tit_acr_destndo
           tt_alter_tit_acr_base_5.ttv_cod_portador_mov            = ""
           tt_alter_tit_acr_base_5.tta_ind_tip_cobr_acr            = tit_acr.ind_tip_cobr_acr
           &if '{&emsfin_version}' >= "5.02" &then
               tt_alter_tit_acr_base_5.tta_des_obs_cobr            = tit_acr.des_obs_cobr
           &endif
           tt_alter_tit_acr_base_5.ttv_log_estorn_impto_retid      = NO
           tt_alter_tit_acr_base_5.tta_cod_histor_padr             = ""
           tt_alter_tit_acr_base_5.ttv_des_text_histor             = p-historico
           tt_alter_tit_acr_base_5.tta_cdn_repres                  = tit_acr.cdn_repres
           tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_1_movto    = tit_acr.cod_instruc_bcia_1_acr  
           tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_2_movto    = tit_acr.cod_instruc_bcia_2_acr
           .

    run prgfin/acr/acr711zv.py persistent set v_hdl_program /*prg_api_integr_acr_alter_tit_acr_novo_7*/.
    RUN pi_main_code_integr_acr_alter_tit_acr_novo_12 in v_hdl_program (Input 12,
                                                                        Input table  tt_alter_tit_acr_base_5,
                                                                        Input table  tt_alter_tit_acr_rateio,
                                                                        Input table  tt_alter_tit_acr_ped_vda,
                                                                        Input table  tt_alter_tit_acr_comis_1,
                                                                        Input table  tt_alter_tit_acr_cheq,
                                                                        Input table  tt_alter_tit_acr_iva,
                                                                        Input table  tt_alter_tit_acr_impto_retid_2,
                                                                        Input table  tt_alter_tit_acr_cobr_espec_2,
                                                                        Input table  tt_alter_tit_acr_rat_desp_rec,
                                                                        output table tt_log_erros_alter_tit_acr,
                                                                        Input v_log_integr_cmg) /*pi_main_code_integr_acr_alter_tit_acr_novo_12*/.
    delete procedure v_hdl_program.

    /*Tratamento de erros*/
    IF CAN-FIND(FIRST tt_log_erros_alter_tit_acr) THEN DO:
        FIND FIRST tt_alter_tit_acr_base_5 NO-LOCK NO-ERROR.
        IF AVAIL tt_alter_tit_acr_base_5 THEN DO:
            RUN pi-cria-tt-erro(INPUT 1,
                                INPUT 17006,
                                INPUT "Estab/Especie/Titulo: " + string(tt_alter_tit_acr_base_5.tta_cod_estab) + "/DI/" + STRING(tit_acr.cod_tit_acr) + " , apresentou os erros abaixo.",
                                INPUT "Estab/Especie/Titulo: " + string(tt_alter_tit_acr_base_5.tta_cod_estab) + "/DI/" + STRING(tit_acr.cod_tit_acr) + " , apresentou os erros abaixo.").                
        END.

        FOR EACH tt_log_erros_alter_tit_acr:
            RUN pi-cria-tt-erro(INPUT tt_log_erros_alter_tit_acr.tta_num_id_tit_acr,
                                INPUT tt_log_erros_alter_tit_acr.ttv_num_mensagem, 
                                INPUT tt_log_erros_alter_tit_acr.ttv_des_msg_erro,
                                INPUT tt_log_erros_alter_tit_acr.ttv_des_msg_ajuda).
        END.

        ASSIGN lErro = YES.

    END.
    ELSE DO:
        FIND LAST bf_movto_tit_acr NO-LOCK
            WHERE bf_movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr 
              AND bf_movto_tit_acr.ind_trans_acr_abrev = "AVMN"       NO-ERROR.
        IF AVAIL bf_movto_tit_acr THEN DO:
            ASSIGN idNumMovto = bf_movto_tit_acr.num_id_movto_tit_acr.
        END.
    END. /* */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-salvar-informacoes w-livre 
PROCEDURE pi-salvar-informacoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
IF lErro = NO THEN DO:
    
    IF CAN-FIND(FIRST tt-movto-furo) THEN
        RUN pi-gera-movto.

    IF NOT CAN-FIND(FIRST tt-erro) THEN DO:
        FIND FIRST movto_tit_acr NO-LOCK
             WHERE ROWID(movto_tit_acr) = gr-movto-furo NO-ERROR.
        IF AVAIL movto_tit_acr THEN DO:
            FIND FIRST cst_furo_caixa EXCLUSIVE-LOCK
                 WHERE cst_furo_caixa.num_id_tit_acr       = movto_tit_acr.num_id_tit_acr      
                   AND cst_furo_caixa.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr NO-ERROR.
            IF AVAIL cst_furo_caixa THEN DO:
                ASSIGN cst_furo_caixa.num_bo     = INT(INPUT FRAME {&FRAME-NAME} fi-bo)
                       cst_furo_caixa.des_observ = INPUT FRAME {&FRAME-NAME} ed-observacao.
                       cst_furo_caixa.situacao   = 2.
            END.
        END.
    END.
END.

IF CAN-FIND(FIRST tt-erro) THEN DO:
    OUTPUT TO VALUE(SESSION:TEMP-DIR + "NICR008.txt") NO-CONVERT.
        FOR EACH tt-erro:
            DISP tt-erro.cd-erro
                 tt-erro.mensagem FORMAT "x(100)" SKIP
                 tt-erro.ajuda    FORMAT "x(150)" NO-LABEL
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro.
        END.
    OUTPUT CLOSE.

    RUN winexec (INPUT "notepad.exe" + CHR(32) + SESSION:TEMP-DIR + "NICR008.txt", INPUT 1).
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_retorna_sugestao_referencia w-livre 
PROCEDURE pi_retorna_sugestao_referencia :
/************************ Parameter Definition Begin ************************/

    def Input param p_ind_tip_atualiz
        as character
        format "X(08)"
        no-undo.
    def Input param p_dat_refer
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def input param p_estabel
        as character
        format "x(3)"
        no-undo.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_dat                        as character       no-undo. /*local*/
    def var v_num_aux                        as integer         no-undo. /*local*/
    def var v_num_aux_2                      as integer         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_des_dat   = string(p_dat_refer,"99999999")
           p_cod_refer = substring(p_ind_tip_atualiz,1,2)
                       + substring(v_des_dat,3,2)
                       + substring(v_des_dat,1,2)
                       
           v_num_aux_2 = integer(this-procedure:handle).

    do  v_num_cont = 1 to 4:
        assign v_num_aux   = (random(0,v_num_aux_2) mod 26) + 97
               p_cod_refer = p_cod_refer + chr(v_num_aux).
    end.
    
    run pi_verifica_refer_unica_acr (Input p_estabel,
                                     Input p_cod_refer,
                                     Input p_cod_table,
                                     Input ?,
                                     output v_log_refer_uni) /*pi_verifica_refer_unica_acr*/.

    IF v_log_refer_uni = NO THEN
            run pi_retorna_sugestao_referencia (Input  "BP",
                                                Input  today,
                                                output p_cod_refer,
                                                Input  p_cod_table,
                                                input  p_estabel).
    
    

END PROCEDURE. /* pi_retorna_sugestao_referencia */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_verifica_refer_unica_acr w-livre 
PROCEDURE pi_verifica_refer_unica_acr :
/************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def Input param p_rec_tabela
        as recid
        format ">>>>>>9"
        no-undo.
    def output param p_log_refer_uni
        as logical
        format "Sim/Nío"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    def buffer b_cobr_especial_acr
        for cobr_especial_acr.
    def buffer b_lote_impl_tit_acr
        for lote_impl_tit_acr.
    def buffer b_lote_liquidac_acr
        for lote_liquidac_acr.
    def buffer b_movto_tit_acr
        for movto_tit_acr.
    def buffer b_renegoc_acr
        for renegoc_acr.


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)"
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_log_refer_uni = yes.

    if  p_cod_table <> "lote_impl_tit_acr" /*l_lote_impl_tit_acr*/  then do:
        find first b_lote_impl_tit_acr no-lock
             where b_lote_impl_tit_acr.cod_estab = p_cod_estab
               and b_lote_impl_tit_acr.cod_refer = p_cod_refer
               and recid( b_lote_impl_tit_acr ) <> p_rec_tabela
             use-index ltmplttc_id no-error.
        if  avail b_lote_impl_tit_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table <> "lote_liquidac_acr" /*l_lote_liquidac_acr*/  then do:
        find first b_lote_liquidac_acr no-lock
             where b_lote_liquidac_acr.cod_estab_refer = p_cod_estab
               and b_lote_liquidac_acr.cod_refer       = p_cod_refer
               and recid( b_lote_liquidac_acr )       <> p_rec_tabela
             use-index ltlqdccr_id no-error.
        if  avail b_lote_liquidac_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table = 'cobr_especial_acr' then do:
        find first b_cobr_especial_acr no-lock
             where b_cobr_especial_acr.cod_estab = p_cod_estab
               and b_cobr_especial_acr.cod_refer = p_cod_refer
               and recid( b_cobr_especial_acr ) <> p_rec_tabela
             use-index cbrspclc_id no-error.
        if  avail b_cobr_especial_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_log_refer_uni = yes then do:
        find first b_renegoc_acr no-lock
            where b_renegoc_acr.cod_estab = p_cod_estab
            and   b_renegoc_acr.cod_refer = p_cod_refer
            and   recid(b_renegoc_acr)   <> p_rec_tabela
            no-error.
        if  avail b_renegoc_acr then
            assign p_log_refer_uni = no.
        else do:
            find first b_movto_tit_acr no-lock
                 where b_movto_tit_acr.cod_estab = p_cod_estab
                   and b_movto_tit_acr.cod_refer = p_cod_refer
                   and recid(b_movto_tit_acr)   <> p_rec_tabela
                 use-index mvtttcr_refer
                 no-error.
            if  avail b_movto_tit_acr then
                assign p_log_refer_uni = no.
        end.
    end.

END PROCEDURE. /* pi_verifica_refer_unica_acr */

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
  {src/adm/template/snd-list.i "tt-movto-furo"}

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

