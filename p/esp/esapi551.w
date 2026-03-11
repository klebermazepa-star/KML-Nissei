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
{include/i-prgvrs.i ESAPI551 TOTVS}

/* Chamada a include do gerenciador de licen‡as. Necessario alterar os parametros */
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

DEF VAR c-situacao AS c LABEL "Tipo" NO-UNDO.

DEF TEMP-TABLE tt-bv-fat-duplic NO-UNDO
          LIKE es-bv-fat-duplic
         FIELD i    AS i
         FIELD Tipo AS c.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-livre
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-cad
&Scoped-define BROWSE-NAME br-int

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-bv-fat-duplic

/* Definitions for BROWSE br-int                                        */
&Scoped-define FIELDS-IN-QUERY-br-int tt-bv-fat-duplic.i NO-LABEL tt-bv-fat-duplic.tipo tt-bv-fat-duplic.cod-estabel tt-bv-fat-duplic.serie tt-bv-fat-duplic.nr-fatura tt-bv-fat-duplic.parcela tt-bv-fat-duplic.cod-portador tt-bv-fat-duplic.dt-emissao tt-bv-fat-duplic.dt-venciment tt-bv-fat-duplic.ret-dt-venciment tt-bv-fat-duplic.vl-parcela tt-bv-fat-duplic.ret-vl-parcela tt-bv-fat-duplic.vl-taxa tt-bv-fat-duplic.ret-vl-taxa   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-int   
&Scoped-define SELF-NAME br-int
&Scoped-define QUERY-STRING-br-int FOR EACH tt-bv-fat-duplic           BY tt-bv-fat-duplic.i        INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-int OPEN QUERY {&SELF-NAME}     FOR EACH tt-bv-fat-duplic           BY tt-bv-fat-duplic.i        INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-int tt-bv-fat-duplic
&Scoped-define FIRST-TABLE-IN-QUERY-br-int tt-bv-fat-duplic


/* Definitions for FRAME f-cad                                          */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rt-button RECT-1 c-cod-estabel-ini ~
c-cod-estabel-fim i-ind-conciliacao dt-emissao-ini dt-emissao-fim ~
nr-nota-fis-ini nr-nota-fis-fim bt-pesquisar i-cod-portador-ini ~
i-cod-portador-fim br-int i-nr-registros 
&Scoped-Define DISPLAYED-OBJECTS c-cod-estabel-ini c-cod-estabel-fim ~
i-ind-conciliacao dt-emissao-ini dt-emissao-fim nr-nota-fis-ini ~
nr-nota-fis-fim i-cod-portador-ini i-cod-portador-fim i-nr-registros 

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
DEFINE BUTTON bt-excel 
     LABEL "Gerar Relat¢rio em Excel" 
     SIZE 29.43 BY 1.13.

DEFINE BUTTON bt-pesquisar 
     LABEL "Pesquisar" 
     SIZE 15 BY 1.13.

DEFINE VARIABLE c-cod-estabel-fim AS CHARACTER FORMAT "X(256)":U INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE c-cod-estabel-ini AS CHARACTER FORMAT "X(256)":U 
     LABEL "Filial" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE dt-emissao-fim AS DATE FORMAT "99/99/9999":U INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE dt-emissao-ini AS DATE FORMAT "99/99/9999":U INITIAL 01/01/001 
     LABEL "Data" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE i-cod-portador-fim AS INTEGER FORMAT "->>>,>>>,>>9":U INITIAL 999999999 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE i-cod-portador-ini AS INTEGER FORMAT "->>>,>>>,>>9":U INITIAL 0 
     LABEL "Portador" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE i-nr-registros AS CHARACTER FORMAT "X(256)":U 
     LABEL "Registros" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .79 NO-UNDO.

DEFINE VARIABLE nr-nota-fis-fim AS CHARACTER FORMAT "X(256)":U INITIAL "999999999" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE nr-nota-fis-ini AS CHARACTER FORMAT "X(256)":U 
     LABEL "Cupom" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE i-ind-conciliacao AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "NÆo Enviados", 0,
"Pendentes", 1,
"Conciliados", 2,
"Pagos", 3,
"Liquidados", 4,
"Todos menos os 'nÆo enviados'", 9
     SIZE 100.86 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 103 BY 2.

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 143 BY 1.46
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-int FOR 
      tt-bv-fat-duplic SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-int
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-int w-livre _FREEFORM
  QUERY br-int NO-LOCK DISPLAY
      tt-bv-fat-duplic.i                                           NO-LABEL
      tt-bv-fat-duplic.tipo             FORMAT "x(16)"             COLUMN-LABEL "Situa‡Æo"
      tt-bv-fat-duplic.cod-estabel      FORMAT "x(5)":U
      tt-bv-fat-duplic.serie            FORMAT "x(5)":U
      tt-bv-fat-duplic.nr-fatura        FORMAT "x(16)":U           COLUMN-LABEL "Cupom"
      tt-bv-fat-duplic.parcela          FORMAT "x(02)":U           
      tt-bv-fat-duplic.cod-portador     
      tt-bv-fat-duplic.dt-emissao       FORMAT "99/99/9999":U      
      tt-bv-fat-duplic.dt-venciment     FORMAT "99/99/9999":U      COLUMN-LABEL "Venc Datasul"   
      tt-bv-fat-duplic.ret-dt-venciment FORMAT "99/99/9999":U      COLUMN-LABEL "Venc Boa Vista" 
      tt-bv-fat-duplic.vl-parcela       FORMAT ">>>,>>>,>>9.99":U  COLUMN-LABEL "Vl Datasul (bruto)"
      tt-bv-fat-duplic.ret-vl-parcela   FORMAT ">>>,>>>,>>9.99":U  COLUMN-LABEL "Vl Boa Vista (bruto)"
      tt-bv-fat-duplic.vl-taxa          FORMAT ">,>>9.99":U        COLUMN-LABEL "Taxa Datasul"
      tt-bv-fat-duplic.ret-vl-taxa      FORMAT ">,>>9.99":U        COLUMN-LABEL "Taxa Boa Vista"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 143 BY 11.5
         FONT 1
         TITLE "Integracao Boa Vista" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-cad
     c-cod-estabel-ini AT ROW 2.71 COL 6.14 COLON-ALIGNED WIDGET-ID 32
     c-cod-estabel-fim AT ROW 2.71 COL 21.14 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     i-ind-conciliacao AT ROW 3.5 COL 42.14 NO-LABEL WIDGET-ID 14
     dt-emissao-ini AT ROW 3.75 COL 6.14 COLON-ALIGNED WIDGET-ID 2
     dt-emissao-fim AT ROW 3.75 COL 21.14 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     nr-nota-fis-ini AT ROW 4.79 COL 6.14 COLON-ALIGNED WIDGET-ID 4
     nr-nota-fis-fim AT ROW 4.79 COL 21.14 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     bt-pesquisar AT ROW 5.83 COL 41.14 WIDGET-ID 22
     bt-excel AT ROW 5.83 COL 57 WIDGET-ID 24
     i-cod-portador-ini AT ROW 5.88 COL 6.14 COLON-ALIGNED WIDGET-ID 6
     i-cod-portador-fim AT ROW 5.88 COL 21.14 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     br-int AT ROW 7.25 COL 1 WIDGET-ID 200
     i-nr-registros AT ROW 18.83 COL 132.86 COLON-ALIGNED WIDGET-ID 34
     "Situa‡Æo de Envio" VIEW-AS TEXT
          SIZE 14 BY .54 AT ROW 2.79 COL 41.43 WIDGET-ID 20
     rt-button AT ROW 1 COL 1
     RECT-1 AT ROW 3 COL 41 WIDGET-ID 36
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 143.86 BY 18.71
         FONT 1.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-livre Template
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
         TITLE              = "Template Livre <Insira complemento>"
         HEIGHT             = 18.71
         WIDTH              = 143.86
         MAX-HEIGHT         = 19
         MAX-WIDTH          = 143.86
         VIRTUAL-HEIGHT     = 19
         VIRTUAL-WIDTH      = 143.86
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
/* BROWSE-TAB br-int i-cod-portador-fim f-cad */
ASSIGN 
       br-int:HIDDEN  IN FRAME f-cad                = TRUE.

/* SETTINGS FOR BUTTON bt-excel IN FRAME f-cad
   NO-ENABLE                                                            */
ASSIGN 
       i-nr-registros:READ-ONLY IN FRAME f-cad        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-livre)
THEN w-livre:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-int
/* Query rebuild information for BROWSE br-int
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH tt-bv-fat-duplic
          BY tt-bv-fat-duplic.i
       INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-int */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-livre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-livre w-livre
ON END-ERROR OF w-livre /* Template Livre <Insira complemento> */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-livre w-livre
ON WINDOW-CLOSE OF w-livre /* Template Livre <Insira complemento> */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-int
&Scoped-define SELF-NAME br-int
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-int w-livre
ON VALUE-CHANGED OF br-int IN FRAME f-cad /* Integracao Boa Vista */
DO:
   {&OPEN-QUERY-br-retorno}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-excel w-livre
ON CHOOSE OF bt-excel IN FRAME f-cad /* Gerar Relat¢rio em Excel */
DO:
   RUN pi-excel.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-pesquisar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-pesquisar w-livre
ON CHOOSE OF bt-pesquisar IN FRAME f-cad /* Pesquisar */
DO:
   RUN pi-carga-tt.
   {&OPEN-QUERY-{&BROWSE-NAME}}
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
       RUN set-position IN h_p-exihel ( 1.13 , 127.29 ) NO-ERROR.
       /* Size in UIB:  ( 1.25 , 16.00 ) */

       /* Links to SmartPanel h_p-exihel. */
       RUN add-link IN adm-broker-hdl ( h_p-exihel , 'State':U , THIS-PROCEDURE ).

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_p-exihel ,
             c-cod-estabel-ini:HANDLE IN FRAME f-cad , 'BEFORE':U ).
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
  DISPLAY c-cod-estabel-ini c-cod-estabel-fim i-ind-conciliacao dt-emissao-ini 
          dt-emissao-fim nr-nota-fis-ini nr-nota-fis-fim i-cod-portador-ini 
          i-cod-portador-fim i-nr-registros 
      WITH FRAME f-cad IN WINDOW w-livre.
  ENABLE rt-button RECT-1 c-cod-estabel-ini c-cod-estabel-fim i-ind-conciliacao 
         dt-emissao-ini dt-emissao-fim nr-nota-fis-ini nr-nota-fis-fim 
         bt-pesquisar i-cod-portador-ini i-cod-portador-fim br-int 
         i-nr-registros 
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
  RUN pi-before-initialize.

  {include/win-size.i}

  {utp/ut9000.i "ESAPI551" "TOTVS"}

  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  ASSIGN
    dt-emissao-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(TODAY)
    dt-emissao-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(TODAY)
      
//    dt-emissao-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(10/9)
//    dt-emissao-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(10/9)
    .

  RUN pi-after-initialize.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carga-tt w-livre 
PROCEDURE pi-carga-tt :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF VAR t     AS i               NO-UNDO.
   DEF VAR i     AS i               NO-UNDO.
   DEF VAR j     AS i               NO-UNDO.
   DEF VAR h     AS HANDLE          NO-UNDO.
   DEF VAR i-ind AS i      EXTENT 2 NO-UNDO.
   t = TIME.
   
   RUN utp/ut-acomp.p PERSISTEN SET h.
   RUN pi-inicializar IN h ("").

   EMPTY TEMP-TABLE tt-bv-fat-duplic.

   ASSIGN
      i-nr-registros:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "0".

   IF i-ind-conciliacao:INPUT-VALUE IN FRAME {&FRAME-NAME} = 0
   THEN DO:
      FOR EACH nota-fiscal NO-LOCK
         WHERE nota-fiscal.dt-emis-nota   >= dt-emissao-ini    :INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND nota-fiscal.dt-emis-nota   <= dt-emissao-fim    :INPUT-VALUE IN FRAME {&FRAME-NAME} 
           AND nota-fiscal.cod-portador   >= i-cod-portador-ini:INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND nota-fiscal.cod-portador   <= i-cod-portador-fim:INPUT-VALUE IN FRAME {&FRAME-NAME}
//         WHERE nota-fiscal.cod-estabel = "040"      
//           AND nota-fiscal.serie = "530"            
//           AND nota-fiscal.nr-nota-fis = "0021136"
          ,
         FIRST es-bv-param NO-LOCK
         WHERE es-bv-param.cod-portador   =  nota-fiscal.cod-portador
           AND es-bv-param.modalidade     =  nota-fiscal.modalidade
           AND es-bv-param.ativo          =  YES,
          EACH fat-duplic NO-LOCK         
         WHERE fat-duplic.cod-estabel     =  nota-fiscal.cod-estabel
           AND fat-duplic.cod-estabel     >= c-cod-estabel-ini :INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND fat-duplic.cod-estabel     <= c-cod-estabel-fim :INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND fat-duplic.serie           =  nota-fiscal.serie
           AND fat-duplic.nr-fatura       =  nota-fiscal.nr-fatura
           AND fat-duplic.nr-fatura       >= nr-nota-fis-ini   :INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND fat-duplic.nr-fatura       <= nr-nota-fis-fim   :INPUT-VALUE IN FRAME {&FRAME-NAME},
         FIRST cst_fat_duplic NO-LOCK 
         WHERE cst_fat_duplic.cod_estabel =  fat-duplic.cod-estabel 
           AND cst_fat_duplic.serie       =  fat-duplic.serie 
           AND cst_fat_duplic.nr_fatura   =  fat-duplic.nr-fatura
           AND cst_fat_duplic.parcela     =  fat-duplic.parcela
         ON STOP  UNDO, LEAVE
         ON ERROR UNDO, LEAVE:
         IF cst_fat_duplic.nsu_numero = ? 
         THEN NEXT.
         
         ASSIGN
            i = i + 1.

         IF i = 1
         OR i / 100 = INT(i / 100)
         THEN RUN pi-acompanhar IN h (STRING(i) 
                                      + " "
                                      + STRING(TIME - t,"hh:mm:ss")
                                      ).

         FIND FIRST es-bv-fat-duplic NO-LOCK
              WHERE es-bv-fat-duplic.cod-estabel = fat-duplic.cod-estabel
                AND es-bv-fat-duplic.serie       = fat-duplic.serie
                AND es-bv-fat-duplic.nr-fatura   = fat-duplic.nr-fatura
                AND es-bv-fat-duplic.parcela     = fat-duplic.parcela
              NO-ERROR.
         IF NOT AVAIL es-bv-fat-duplic
         THEN DO:
            ASSIGN
               j = j + 1.

            CREATE tt-bv-fat-duplic.
            BUFFER-COPY fat-duplic
                     TO tt-bv-fat-duplic.
            ASSIGN
               tt-bv-fat-duplic.cod-portador = nota-fiscal.cod-portador
               tt-bv-fat-duplic.modalidade   = nota-fiscal.modalidade
               tt-bv-fat-duplic.vl-taxa      = cst_fat_duplic.taxa_admin
               tt-bv-fat-duplic.tipo         = "NÆo Enviado"
               tt-bv-fat-duplic.i            = j
               .
         END.
      END.
   END.
   ELSE DO:
      IF i-ind-conciliacao :INPUT-VALUE IN FRAME {&FRAME-NAME} < 9
      THEN ASSIGN
         i-ind = i-ind-conciliacao :INPUT-VALUE IN FRAME {&FRAME-NAME}.
      ELSE ASSIGN
         i-ind[1] = 0
         i-ind[2] = 9.
      FOR EACH es-bv-fat-duplic NO-LOCK
         WHERE es-bv-fat-duplic.cod-estabel  >= c-cod-estabel-ini :INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND es-bv-fat-duplic.cod-estabel  <= c-cod-estabel-fim :INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND es-bv-fat-duplic.dt-emissao   >= dt-emissao-ini    :INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND es-bv-fat-duplic.dt-emissao   <= dt-emissao-fim    :INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND es-bv-fat-duplic.nr-fatura    >= nr-nota-fis-ini   :INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND es-bv-fat-duplic.nr-fatura    <= nr-nota-fis-fim   :INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND es-bv-fat-duplic.cod-portador >= i-cod-portador-ini:INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND es-bv-fat-duplic.cod-portador <= i-cod-portador-fim:INPUT-VALUE IN FRAME {&FRAME-NAME}
           AND es-bv-fat-duplic.ind-envio    >= i-ind[1]
           AND es-bv-fat-duplic.ind-envio    <= i-ind[2]
         ON STOP  UNDO, LEAVE
         ON ERROR UNDO, LEAVE:

         ASSIGN
            i = i + 1
            j = j + 1.
      
         IF i = 1
         OR i / 100 = INT(i / 100)
         THEN RUN pi-acompanhar IN h (STRING(i) 
                                      + " "
                                      + STRING(TIME - t,"hh:mm:ss")
                                      ).
      
         CREATE tt-bv-fat-duplic.
         BUFFER-COPY es-bv-fat-duplic
                  TO tt-bv-fat-duplic.
         ASSIGN
            tt-bv-fat-duplic.tipo    = ENTRY(es-bv-fat-duplic.ind-envio,
                                             "Pendente,Conciliado,Pago,Liquidado")
            tt-bv-fat-duplic.i       = j.
      END.
   END.
   RUN pi-finalizar IN h.    

   ASSIGN
      i-nr-registros:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(j).

   IF TEMP-TABLE tt-bv-fat-duplic:HAS-RECORDS
   THEN ASSIGN
      bt-excel:SENSITIVE IN FRAME {&FRAME-NAME} = TRUE.
   ELSE ASSIGN
      bt-excel:SENSITIVE IN FRAME {&FRAME-NAME} = FALSE.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-excel w-livre 
PROCEDURE pi-excel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR excelAppl  AS COM-HANDLE NO-UNDO.
    DEF VAR chquery    AS COM-HANDLE NO-UNDO.
    DEF VAR h          AS HANDLE     NO-UNDO.

    RUN utp/ut-acomp.p PERSISTEN SET h.
    RUN pi-inicializar IN h ("").

    DEF VAR c-arquivo  AS c          NO-UNDO.

    ASSIGN
       c-arquivo = SESSION:TEMP-DIRECTORY 
                 + "ESAPI501-"
                 + STRING(TIME)
                 + ".csv"
                 .
    OUTPUT TO VALUE(c-arquivo) PAGE-SIZE 0 CONVERT TARGET "iso8859-1".

    PUT 
       "Situa‡Æo"             CHR(9)
       "Filial"               CHR(9)
       "Parcela"              CHR(9)
       "Cupom"                CHR(9)
       "Parcela"              CHR(9)
       "Portador"             CHR(9)
       "EmissÆo"              CHR(9)
       "Venc Datasul"         CHR(9)
       "Venc Boa Vista"       CHR(9)
       "Vl Datasul (bruto)"   CHR(9)
       "Vl Boa Vista (bruto)" CHR(9)
       "Taxa Datasul"         CHR(9)
       "Taxa Boa Vista"       CHR(9)
       SKIP.

    FOR EACH tt-bv-fat-duplic ON STOP UNDO, LEAVE:
       ASSIGN
          i = i + 1.

       IF i / 100 = INT(i / 100)
       THEN RUN pi-acompanhar IN h (STRING(i)).

       PUT
          tt-bv-fat-duplic.tipo             FORMAT "x(12)"            CHR(9)
          tt-bv-fat-duplic.cod-estabel      FORMAT "x(5)":U           CHR(9)
          tt-bv-fat-duplic.serie            FORMAT "x(5)":U           CHR(9)
          tt-bv-fat-duplic.nr-fatura        FORMAT "x(16)":U          CHR(9) 
          tt-bv-fat-duplic.parcela          FORMAT "x(02)":U          CHR(9) 
          tt-bv-fat-duplic.cod-portador     FORMAT ">>>>>>>>9":U      CHR(9) 
          tt-bv-fat-duplic.dt-emissao       FORMAT "99/99/9999":U     CHR(9) 
          tt-bv-fat-duplic.dt-venciment     FORMAT "99/99/9999":U     CHR(9) 
          tt-bv-fat-duplic.ret-dt-venciment FORMAT "99/99/9999":U     CHR(9) 
          tt-bv-fat-duplic.vl-parcela       FORMAT ">>>,>>>,>>9.99":U CHR(9) 
          tt-bv-fat-duplic.ret-vl-parcela   FORMAT ">>>,>>>,>>9.99":U CHR(9) 
          tt-bv-fat-duplic.vl-taxa          FORMAT ">,>>9.99":U       CHR(9) 
          tt-bv-fat-duplic.ret-vl-taxa      FORMAT ">,>>9.99":U       CHR(9) 
          SKIP.
    END.
    OUTPUT CLOSE.
    
    CREATE "Excel.Application" excelAppl.
    excelAppl:SheetsInNewWorkbook = 1.
    excelAppl:Workbooks:ADD.
    excelAppl:Sheets(1):SELECT.
    excelAppl:range("a1"):SELECT.
    chquery = excelAppl:activesheet:QueryTables:ADD("TEXT;" + SEARCH(c-arquivo),excelAppl:range("a1")).
    chquery:REFRESH().
    excelAppl:Cells:EntireColumn:Autofit.
    excelAppl:VISIBLE = YES.
    RELEASE OBJECT chquery.
    RELEASE OBJECT excelAppl.
    RUN pi-finalizar IN h.    

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
  {src/adm/template/snd-list.i "tt-bv-fat-duplic"}

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

