&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
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
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
{system/Error.i}
{system/InstanceManagerDef.i}

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable tituloExtensao as handle    no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-7 RECT-39 bt_sai btAtualizar dataCorte 
&Scoped-Define DISPLAYED-OBJECTS dataCorte 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU m_Arquivo 
       MENU-ITEM m_Atualizar    LABEL "A&tualizar"    
       MENU-ITEM m_Sair         LABEL "&Sair"         .

DEFINE MENU MENU-BAR-C-Win MENUBAR
       SUB-MENU  m_Arquivo      LABEL "&Arquivo"      .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btAtualizar 
     IMAGE-UP FILE "image/im-chck1.bmp":U
     LABEL "Atualizar" 
     SIZE 3.86 BY 1.21 TOOLTIP "Atualizar".

DEFINE BUTTON bt_sai 
     IMAGE-UP FILE "image\im-exi":U
     LABEL "" 
     SIZE 3.86 BY 1.21 TOOLTIP "Sair".

DEFINE VARIABLE dataCorte AS DATE FORMAT "99/99/9999":U 
     LABEL "Data de Corte" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 TOOLTIP "Informe a data a partir da qual ser∆o gerados dados"
     BGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-39
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 78.57 BY 4.5.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 79.72 BY 1.5
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     bt_sai AT ROW 1.21 COL 75.86
     btAtualizar AT ROW 1.25 COL 2.14
     dataCorte AT ROW 5.88 COL 34 COLON-ALIGNED
     "Para executar a atualizaá∆o, informe a data de corte abaixo e pressione o bot∆o" VIEW-AS TEXT
          SIZE 66 BY .54 AT ROW 4.21 COL 7
          FONT 6
     "Este programa limpa o °ndice e o preenche com dados a partir da data de corte." VIEW-AS TEXT
          SIZE 66 BY .67 AT ROW 3.42 COL 7.43
          FONT 6
     "verde acima." VIEW-AS TEXT
          SIZE 11 BY .54 AT ROW 4.96 COL 32.57
          FONT 6
     RECT-7 AT ROW 1.08 COL 1
     RECT-39 AT ROW 2.75 COL 1.57
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80 BY 6.58
         BGCOLOR 17 FONT 1.


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
         TITLE              = "Atualizaá∆o do ÷ndice de Vinculaá∆o"
         HEIGHT             = 6.58
         WIDTH              = 80
         MAX-HEIGHT         = 16
         MAX-WIDTH          = 80
         VIRTUAL-HEIGHT     = 16
         VIRTUAL-WIDTH      = 80
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

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU MENU-BAR-C-Win:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Atualizaá∆o do ÷ndice de Vinculaá∆o */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Atualizaá∆o do ÷ndice de Vinculaá∆o */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAtualizar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAtualizar C-Win
ON CHOOSE OF btAtualizar IN FRAME DEFAULT-FRAME /* Atualizar */
DO:
  message 'Confirma data de corte' dataCorte:screen-value '?'
      view-as alert-box question buttons yes-no 
      update atualiza as logical.
  if not atualiza then
      return no-apply.

  session:set-wait-state('general').

  run actualize.

  session:set-wait-state('').

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt_sai
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt_sai C-Win
ON CHOOSE OF bt_sai IN FRAME DEFAULT-FRAME
DO:
  apply "close" to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Atualizar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Atualizar C-Win
ON CHOOSE OF MENU-ITEM m_Atualizar /* Atualizar */
DO:
    apply "choose":U to btAtualizar in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Sair
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Sair C-Win
ON CHOOSE OF MENU-ITEM m_Sair /* Sair */
DO:
  apply "choose":U to bt_sai in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  run startup.

  assign 
      dataCorte:screen-value in frame {&frame-name} = '01/01/' + string(year(today),'9999').

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE actualize C-Win 
PROCEDURE actualize :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&try}:
        run verifyTituloExtensaoInstance.

        run clearTable in tituloExtensao.

        run createExtensoes.
        
        message 'Dados atualizados com sucesso'
            view-as alert-box info buttons ok.

        return.
    end.

    run showErrors.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createExtensoes C-Win 
PROCEDURE createExtensoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable found as logical   no-undo.

    do with frame {&frame-name}
        {&throws}:

        for each tit_ap use-index titap_dat_prev_pagto
            where tit_ap.cod_estab = tit_ap.cod_estab
              and tit_ap.dat_prev_pagto >= dataCorte:input-value
              and tit_ap.val_sdo_tit_ap > 0
            no-lock
            {&throws}:

            run canFind in tituloExtensao(tit_ap.cod_estab, tit_ap.cdn_fornecedor, 
                    tit_ap.cod_espec_docto, tit_ap.cod_ser_docto, tit_ap.cod_tit_ap, 
                    tit_ap.cod_parcela, output found).

            if not found then do:
                run new in tituloExtensao.
                run setEstabelecimento in tituloExtensao(tit_ap.cod_estab).
                run setFornecedor in tituloExtensao(tit_ap.cdn_fornecedor).
                run setEspecie in tituloExtensao(tit_ap.cod_espec_docto).
                run setSerie in tituloExtensao(tit_ap.cod_ser_docto).
                run setTitulo in tituloExtensao(tit_ap.cod_tit_ap).
                run setParcela in tituloExtensao(tit_ap.cod_parcela).
            end.
            else 
                run find in tituloExtensao(tit_ap.cod_estab, tit_ap.cdn_fornecedor, 
                    tit_ap.cod_espec_docto, tit_ap.cod_ser_docto, tit_ap.cod_tit_ap, 
                    tit_ap.cod_parcela).

            run populateValues.

            if not found then
                run insert in tituloExtensao.
            else
                run update in tituloExtensao.
        end.
    end.

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
  DISPLAY dataCorte 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE RECT-7 RECT-39 bt_sai btAtualizar dataCorte 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateValues C-Win 
PROCEDURE populateValues :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        run setDataVencimento in tituloExtensao(tit_ap.dat_vencto_tit_ap).
        run setDataLiquidacao in tituloExtensao(tit_ap.dat_liquidac_tit_ap).
        run setValorSaldo in tituloExtensao(tit_ap.val_sdo_tit_ap).
        run setCodigoDeBarras in tituloExtensao(tit_ap.cb4_tit_ap_bco_cobdor).
        run setTipoEspecie in tituloExtensao(tit_ap.ind_tip_espec_docto).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup C-Win 
PROCEDURE startup :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    {system/InstanceManager.i}
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyTituloExtensaoInstance C-Win 
PROCEDURE verifyTituloExtensaoInstance :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if not valid-handle(tituloExtensao) then
            run createInstance in ghInstanceManager (this-procedure,
                'nissei/ems5/pagar/titulo/Extensao.p':u, output tituloExtensao).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

