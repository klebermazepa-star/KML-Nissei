&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
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

DEFINE TEMP-TABLE tt-movto-furo-aux LIKE cst_furo_caixa
    FIELD nome-colaborador AS CHAR FORMAT "x(200)" COLUMN-LABEL "Nome Colaborador".

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAM inclusao AS LOGICAL NO-UNDO.
DEFINE INPUT-OUTPUT PARAM TABLE FOR tt-movto-furo-aux .

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE c-lista-cb AS CHARACTER   NO-UNDO.
DEFINE VARIABLE lErro      AS LOGICAL     NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-livre
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-cad

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rt-button RECT-1 rt-buttom RECT-12 ~
bt-zoom-func fi-data fi-valor cb-tipo fi-bo ed-observacao bt-ok bt-cancelar 
&Scoped-Define DISPLAYED-OBJECTS fi-bordero fi-matricula fi-nome-func ~
fi-data fi-valor cb-tipo fi-bo ed-observacao 

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
     LABEL "&Cancelar" 
     SIZE 15 BY 1.

DEFINE BUTTON bt-ok 
     LABEL "&OK" 
     SIZE 15 BY 1.

DEFINE BUTTON bt-zoom-func 
     IMAGE-UP FILE "//192.168.200.52/datasul/ems2/image/ii-zoo.bmp":U
     IMAGE-INSENSITIVE FILE "//192.168.200.52/datasul/ems2/image/ii-zoo.bmp":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE VARIABLE cb-tipo AS CHARACTER FORMAT "X(256)":U 
     LABEL "Tipo" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1" 
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

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

DEFINE RECTANGLE rt-buttom
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 89.72 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 89.72 BY 1.46
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-cad
     fi-bordero AT ROW 2.75 COL 14.14 COLON-ALIGNED WIDGET-ID 2
     bt-zoom-func AT ROW 3.67 COL 30.14 WIDGET-ID 50
     fi-matricula AT ROW 3.75 COL 14.14 COLON-ALIGNED WIDGET-ID 6
     fi-nome-func AT ROW 3.75 COL 32.29 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     fi-data AT ROW 4.75 COL 14.14 COLON-ALIGNED WIDGET-ID 8
     fi-valor AT ROW 5.75 COL 14.14 COLON-ALIGNED WIDGET-ID 12
     cb-tipo AT ROW 6.75 COL 14.14 COLON-ALIGNED WIDGET-ID 48
     fi-bo AT ROW 7.88 COL 14.14 COLON-ALIGNED WIDGET-ID 26
     ed-observacao AT ROW 9.63 COL 3.29 NO-LABEL WIDGET-ID 46
     bt-ok AT ROW 14.88 COL 2.14 WIDGET-ID 30
     bt-cancelar AT ROW 14.88 COL 17.43 WIDGET-ID 32
     "Hist¢rico" VIEW-AS TEXT
          SIZE 6 BY .67 AT ROW 8.96 COL 3 WIDGET-ID 44
     rt-button AT ROW 1 COL 1.43
     RECT-1 AT ROW 2.54 COL 1.57 WIDGET-ID 4
     rt-buttom AT ROW 14.67 COL 1.43 WIDGET-ID 28
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
         HEIGHT             = 15.25
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
/* SETTINGS FOR FILL-IN fi-bordero IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-matricula IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-nome-func IN FRAME f-cad
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-livre)
THEN w-livre:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
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


&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar w-livre
ON CHOOSE OF bt-cancelar IN FRAME f-cad /* Cancelar */
DO:
  APPLY "CLOSE" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok w-livre
ON CHOOSE OF bt-ok IN FRAME f-cad /* OK */
DO:
  ASSIGN lErro = NO.
  RUN pi-salvar-informacoes.

  IF lErro = NO THEN
      APPLY "CLOSE" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-zoom-func
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-zoom-func w-livre
ON CHOOSE OF bt-zoom-func IN FRAME f-cad
DO:
        {include/zoomvar.i &prog-zoom=intprg/nicr009-z01.w
                           &campo=fi-matricula
                           &campozoom=numcad
                           &campo2=fi-nome-func
                           &campozoom2=nomfun}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-tipo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-tipo w-livre
ON VALUE-CHANGED OF cb-tipo IN FRAME f-cad /* Tipo */
DO:
  IF INPUT FRAME {&FRAME-NAME} cb-tipo = "SINISTRO" THEN DO:
      ASSIGN fi-bo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "".
      ENABLE fi-bo WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      ASSIGN fi-bo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "".
      DISABLE fi-bo WITH FRAME {&FRAME-NAME}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-matricula
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-matricula w-livre
ON MOUSE-SELECT-DBLCLICK OF fi-matricula IN FRAME f-cad /* Matr°cula */
DO:
  APPLY "CHOOSE" TO bt-zoom-func IN FRAME {&FRAME-NAME}.
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
  DISPLAY fi-bordero fi-matricula fi-nome-func fi-data fi-valor cb-tipo fi-bo 
          ed-observacao 
      WITH FRAME f-cad IN WINDOW w-livre.
  ENABLE rt-button RECT-1 rt-buttom RECT-12 bt-zoom-func fi-data fi-valor 
         cb-tipo fi-bo ed-observacao bt-ok bt-cancelar 
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

  {utp/ut9000.i "NICR008B" "9.99.99.999"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  run pi-after-initialize.

  RUN pi-local-initialize.
  
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


IF inclusao = YES THEN DO:
    FIND FIRST movto_tit_acr NO-LOCK
         WHERE ROWID(movto_tit_acr) = gr-movto-furo NO-ERROR.
    IF AVAIL movto_tit_acr THEN DO:
        FIND FIRST cst_furo_caixa NO-LOCK
             WHERE cst_furo_caixa.num_id_tit_acr       = movto_tit_acr.num_id_tit_acr      
               AND cst_furo_caixa.cod_estab            = movto_tit_acr.cod_estab
               AND cst_furo_caixa.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr NO-ERROR.
        IF AVAIL cst_furo_caixa THEN DO:
    
            ASSIGN fi-bordero:SCREEN-VALUE IN FRAME {&FRAME-NAME}    = cst_furo_caixa.num_bordero
                   fi-matricula:SCREEN-VALUE IN FRAME {&FRAME-NAME}  = cst_furo_caixa.mat_colabor
                   fi-data:SCREEN-VALUE IN FRAME {&FRAME-NAME}       = STRING(cst_furo_caixa.dat_bordero,"99/99/9999").
            ASSIGN fi-valor:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = STRING(cst_furo_caixa.vl_furo,">>>,>>>,>>9.99")
                   ed-observacao:SCREEN-VALUE IN FRAME {&FRAME-NAME} = cst_furo_caixa.des_observ
                   fi-bo:SCREEN-VALUE IN FRAME {&FRAME-NAME}         = STRING(cst_furo_caixa.num_bo)
                .
    
/*             FIND FIRST VR034FUN NO-LOCK                                                                  */
/*                  WHERE VR034FUN.NUMCAD = INT(cst_furo_caixa.mat_colabor) NO-ERROR.                       */
/*             IF AVAIL VR034FUN THEN DO:                                                                   */
/*                 ASSIGN fi-nome-func:SCREEN-VALUE IN FRAME {&FRAME-NAME} = CAPS(VR034FUN.NOMFUN).         */
/*             END.                                                                                         */
/*             ELSE  DO:                                                                                    */
/*                  ASSIGN fi-nome-func:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "FUNCIONµRIO N«O ENCONTRADO". */
/*             END.                                                                                         */
    
            IF cst_furo_caixa.tip_furo = "PERDA" THEN
                ASSIGN c-lista-cb = "VALE,VALE".
            ELSE c-lista-cb = "SINISTRO,SINISTRO,VALE,VALE,PERDA,PERDA,REPOSIÄ«O,REPOSIÄ«O".
    
            ASSIGN cb-tipo:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = c-lista-cb.
    
        END.
    END.
END.
ELSE DO:

    ASSIGN cb-tipo:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = c-lista-cb.
END.

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
IF INPUT FRAME {&FRAME-NAME} cb-tipo = "" THEN DO:
    run utp/ut-msgs.p (input "show":U, 
                       input 17006, 
                       input "Tipo de Movimento deve ser informado!~~Favor verificar pois o tipo de movimento n∆o foi informado!").
    ASSIGN lErro = YES.
END.

IF INPUT FRAME {&FRAME-NAME} cb-tipo = "SINISTRO" AND 
   INPUT FRAME {&FRAME-NAME} fi-bo   = 0 THEN DO:
    run utp/ut-msgs.p (input "show":U, 
                       input 17006, 
                       input "N£mero do BO(Boletim de Ocorrencia) deve ser informado!~~Favor verificar pois o n£mero do BO, deve se informado para movimento de SINISTRO!").
    ASSIGN lErro = YES.
END.

IF lErro = NO THEN DO:
    FIND FIRST movto_tit_acr NO-LOCK
         WHERE ROWID(movto_tit_acr) = gr-movto-furo NO-ERROR.
    IF AVAIL movto_tit_acr THEN DO:
        FIND FIRST cst_furo_caixa EXCLUSIVE-LOCK
             WHERE cst_furo_caixa.num_id_tit_acr       = movto_tit_acr.num_id_tit_acr      
               AND cst_furo_caixa.cod_estab            = movto_tit_acr.cod_estab
               AND cst_furo_caixa.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr NO-ERROR.
        IF AVAIL cst_furo_caixa THEN DO:
            EMPTY TEMP-TABLE tt-movto-furo-aux.
        
            CREATE tt-movto-furo-aux.
            ASSIGN tt-movto-furo-aux.num_bordero    = cst_furo_caixa.num_bordero
                   tt-movto-furo-aux.cod_estab      = cst_furo_caixa.cod_estab 
                   tt-movto-furo-aux.dat_bordero    = INPUT FRAME {&FRAME-NAME} fi-data
                   tt-movto-furo-aux.des_observ     = INPUT FRAME {&FRAME-NAME} ed-observacao
                   tt-movto-furo-aux.mat_colabor    = INPUT FRAME {&FRAME-NAME} fi-matricula
                   tt-movto-furo-aux.num_bo         = INPUT FRAME {&FRAME-NAME} fi-bo
                   tt-movto-furo-aux.situacao       = 1
                   tt-movto-furo-aux.tip_furo       = INPUT FRAME {&FRAME-NAME} cb-tipo
                   tt-movto-furo-aux.vl_furo        = INPUT FRAME {&FRAME-NAME} fi-valor
                   tt-movto-furo-aux.nome-colaborador = INPUT FRAME {&FRAME-NAME} fi-nome-func
                .
           
        END.
        RELEASE cst_furo_caixa.
    END.
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

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this w-livre, and there are no
     tables specified in any contained Browse, Query, or Frame. */

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

