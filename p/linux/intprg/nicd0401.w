&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-window
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-window 
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i NICD0401 2.06.00.000}  /*** 010024 ***/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

DEFINE new global shared var gr-emitente  as rowid NO-UNDO.

DEF VAR c-situacao    AS CHAR FORMAT "x(1)"  NO-UNDO.
DEF VAR i-prazo-pagto AS INT  FORMAT ">,>>9" NO-UNDO.
DEF VAR i-cont        AS INT  NO-UNDO.
DEF VAR i-tp-movto    AS INT  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE JanelaDetalhe
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 RECT-3 tg-protocolo ~
tg-emitedanfe tg-biometria tg-microempresa tg-industria tg-notadevolucao ~
tg-excecao rs-tipo-trib da-dt-bloqueio c-eancnpj i-prazo bt-ok bt-cancelar ~
bt-ajuda 
&Scoped-Define DISPLAYED-OBJECTS tg-protocolo tg-emitedanfe tg-biometria ~
tg-microempresa tg-industria tg-notadevolucao tg-excecao rs-tipo-trib ~
da-dt-bloqueio c-eancnpj i-prazo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-window AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-ajuda 
     LABEL "&Ajuda" 
     SIZE 10 BY 1 TOOLTIP "Ajuda".

DEFINE BUTTON bt-cancelar AUTO-END-KEY 
     LABEL "&Cancelar" 
     SIZE 10 BY 1 TOOLTIP "Cancelar".

DEFINE BUTTON bt-ok AUTO-GO 
     LABEL "&OK" 
     SIZE 10 BY 1 TOOLTIP "Ok".

DEFINE VARIABLE c-eancnpj AS CHARACTER FORMAT "X(13)":U 
     LABEL "EAN CNPJ" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88 NO-UNDO.

DEFINE VARIABLE da-dt-bloqueio AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Bloqueio" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE i-prazo AS INTEGER FORMAT ">>>9":U INITIAL 0 
     LABEL "Prazo Entrega" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE rs-tipo-trib AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Substitu¡da", 1,
"Substituta", 2
     SIZE 26.29 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 77.86 BY 1.38
     BGCOLOR 7 .

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 77.86 BY 12.83.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 73.72 BY 11.67.

DEFINE VARIABLE tg-biometria AS LOGICAL INITIAL no 
     LABEL "Biometria Motorista" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.72 BY .88 NO-UNDO.

DEFINE VARIABLE tg-emitedanfe AS LOGICAL INITIAL yes 
     LABEL "Emite DANFE" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.72 BY .88 NO-UNDO.

DEFINE VARIABLE tg-excecao AS LOGICAL INITIAL no 
     LABEL "Exce‡Æo Ind£stria" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.72 BY .88 NO-UNDO.

DEFINE VARIABLE tg-industria AS LOGICAL INITIAL no 
     LABEL "Ind£stria" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.72 BY .88 NO-UNDO.

DEFINE VARIABLE tg-microempresa AS LOGICAL INITIAL no 
     LABEL "Microempresa" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.72 BY .88 NO-UNDO.

DEFINE VARIABLE tg-notadevolucao AS LOGICAL INITIAL no 
     LABEL "Emite Nota Devolu‡Æo" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.72 BY .88 NO-UNDO.

DEFINE VARIABLE tg-protocolo AS LOGICAL INITIAL no 
     LABEL "Protocolo Devolu‡Æo" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.72 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     tg-protocolo AT ROW 2.29 COL 28.43 WIDGET-ID 6
     tg-emitedanfe AT ROW 3.29 COL 28.43 WIDGET-ID 8
     tg-biometria AT ROW 4.29 COL 28.43 WIDGET-ID 12
     tg-microempresa AT ROW 5.29 COL 28.43 WIDGET-ID 14
     tg-industria AT ROW 6.29 COL 28.43 WIDGET-ID 28
     tg-notadevolucao AT ROW 7.29 COL 28.43 WIDGET-ID 32
     tg-excecao AT ROW 8.29 COL 28.43 WIDGET-ID 30
     rs-tipo-trib AT ROW 9.29 COL 28.57 NO-LABEL WIDGET-ID 20
     da-dt-bloqueio AT ROW 10.29 COL 26.43 COLON-ALIGNED WIDGET-ID 10
     c-eancnpj AT ROW 11.29 COL 26.43 COLON-ALIGNED WIDGET-ID 18
     i-prazo AT ROW 12.29 COL 26.43 COLON-ALIGNED WIDGET-ID 16
     bt-ok AT ROW 14.33 COL 2.72 HELP
          "Ok"
     bt-cancelar AT ROW 14.33 COL 13.72 HELP
          "Cancelar"
     bt-ajuda AT ROW 14.33 COL 68.72 HELP
          "Ajuda"
     "  Informa‡äes Sysfarma" VIEW-AS TEXT
          SIZE 16.86 BY .88 AT ROW 1.38 COL 5.43 WIDGET-ID 36
     "Tipo Tributa‡Æo:" VIEW-AS TEXT
          SIZE 11.57 BY .88 AT ROW 9.29 COL 16.86 WIDGET-ID 24
     RECT-1 AT ROW 14.13 COL 1.72
     RECT-2 AT ROW 1.13 COL 1.72
     RECT-3 AT ROW 1.83 COL 3.86 WIDGET-ID 34
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80 BY 16.83
         FONT 4.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: JanelaDetalhe
   Allow: Basic,Browse,DB-Fields,Smart,Window,Query
   Container Links: 
   Add Fields to: Neither
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-window ASSIGN
         HIDDEN             = YES
         TITLE              = "Informa‡äes Complementares Sysfarma"
         HEIGHT             = 14.67
         WIDTH              = 79.14
         MAX-HEIGHT         = 27.96
         MAX-WIDTH          = 146.29
         VIRTUAL-HEIGHT     = 27.96
         VIRTUAL-WIDTH      = 146.29
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-window 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/w-window.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-window
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-window)
THEN w-window:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-window
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-window w-window
ON END-ERROR OF w-window /* Informa‡äes Complementares Sysfarma */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-window w-window
ON WINDOW-CLOSE OF w-window /* Informa‡äes Complementares Sysfarma */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ajuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ajuda w-window
ON CHOOSE OF bt-ajuda IN FRAME F-Main /* Ajuda */
OR HELP OF FRAME {&FRAME-NAME}
DO:
  {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar w-window
ON CHOOSE OF bt-cancelar IN FRAME F-Main /* Cancelar */
DO:
    apply "close" to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok w-window
ON CHOOSE OF bt-ok IN FRAME F-Main /* OK */
DO:    
    FIND FIRST emitente WHERE
               ROWID(emitente) = gr-emitente NO-LOCK NO-ERROR.
    IF AVAIL emitente THEN DO:
       FIND FIRST int_ds_ext_emitente WHERE
                  int_ds_ext_emitente.cod_emitente = emitente.cod-emitente NO-ERROR.
       IF NOT AVAIL int_ds_ext_emitente THEN DO:
          CREATE int_ds_ext_emitente.
          ASSIGN int_ds_ext_emitente.cod_emitente = emitente.cod-emitente.
       END.

       ASSIGN int_ds_ext_emitente.protocolodevolucao = INPUT FRAME {&FRAME-NAME} tg-protocolo
              int_ds_ext_emitente.emitedanfe         = INPUT FRAME {&FRAME-NAME} tg-emitedanfe
              int_ds_ext_emitente.biometriamotorista = INPUT FRAME {&FRAME-NAME} tg-biometria
              int_ds_ext_emitente.microempresa       = INPUT FRAME {&FRAME-NAME} tg-microempresa
              int_ds_ext_emitente.industria          = INPUT FRAME {&FRAME-NAME} tg-industria
              int_ds_ext_emitente.emitenotadevolucao = INPUT FRAME {&FRAME-NAME} tg-notadevolucao
              int_ds_ext_emitente.excecaoindustria   = INPUT FRAME {&FRAME-NAME} tg-excecao
              int_ds_ext_emitente.tipo_trib          = INPUT FRAME {&FRAME-NAME} rs-tipo-trib
              int_ds_ext_emitente.databloqueio       = INPUT FRAME {&FRAME-NAME} da-dt-bloqueio
              int_ds_ext_emitente.eancnpj            = INPUT FRAME {&FRAME-NAME} c-eancnpj
              int_ds_ext_emitente.prazo_entrega      = INPUT FRAME {&FRAME-NAME} i-prazo.

       ASSIGN c-situacao = "A".
       FIND FIRST dist-emitente WHERE
                  dist-emitente.cod-emitente = emitente.cod-emitente NO-LOCK NO-ERROR.
       IF AVAIL dist-emitente THEN DO:
          IF dist-emitente.idi-sit-fornec = 4 THEN
             ASSIGN c-situacao = "I".
       END.

       ASSIGN i-prazo-pagto = 0.

       FIND FIRST cond-pagto WHERE 
                  cond-pagto.cod-cond-pag = emitente.cod-cond-pag NO-LOCK NO-ERROR.
       IF AVAIL cond-pagto THEN DO:
          DO i-cont = 1 TO 12:
             IF cond-pagto.prazos[i-cont] <> 0 THEN
                ASSIGN i-prazo-pagto = cond-pagto.prazos[i-cont].
          END.
       END.

       ASSIGN i-tp-movto = 1.
       FIND FIRST int_ds_fornecedor WHERE
                  int_ds_fornecedor.codigo     = emitente.cod-emitente AND 
                  int_ds_fornecedor.tipo_movto = 1 NO-LOCK NO-ERROR.
       IF AVAIL int_ds_fornecedor THEN
          ASSIGN i-tp-movto = 2.

       CREATE int_ds_fornecedor.
       ASSIGN int_ds_fornecedor.tipo_movto             = i-tp-movto
              int_ds_fornecedor.dt_geracao             = TODAY
              int_ds_fornecedor.hr_geracao             = STRING(TIME,"hh:mm:ss") 
              int_ds_fornecedor.cod_usuario            = c-seg-usuario
              int_ds_fornecedor.situacao               = 1 /* Pendente */
              int_ds_fornecedor.codigo                 = emitente.cod-emitente
              int_ds_fornecedor.nome                   = substr(emitente.nome-emit,1,50)
              int_ds_fornecedor.endereco               = substr(emitente.endereco,1,50)
              int_ds_fornecedor.cidade                 = substr(emitente.cidade,1,30)
              int_ds_fornecedor.estado                 = substr(emitente.estado,1,2)
              int_ds_fornecedor.inscricao              = substr(emitente.ins-estadual,1,18)
              int_ds_fornecedor.telefone               = substr(emitente.telefone[1],1,15)
              int_ds_fornecedor.fax                    = substr(emitente.telefax,1,15)
              int_ds_fornecedor.email                  = substr(emitente.e-mail,1,40)
              int_ds_fornecedor.url                    = substr(emitente.home-page,1,40) 
              int_ds_fornecedor.contato                = substr(emitente.contato[1],1,30)
              int_ds_fornecedor.tipo                   = SUBSTR(emitente.atividade,1,1) /* M - Medicamentos / P - Perfumaria / C - Conveniˆncia / D - Diversos */
              int_ds_fornecedor.cep                    = substr(emitente.cep,1,9)
              int_ds_fornecedor.cnpj                   = substr(emitente.cgc,1,18)
              int_ds_fornecedor.prazo_pagto            = i-prazo-pagto
              int_ds_fornecedor.situacao_ativo         = c-situacao
              int_ds_fornecedor.nome_abrev             = emitente.nome-abrev
              int_ds_fornecedor.tipo_pessoa            = IF emitente.natureza = 1 THEN "F¡sica" ELSE "Jur¡dica"
              int_ds_fornecedor.equivaleds             = "?"
              int_ds_fornecedor.bairro                 = substr(emitente.bairro,1,30)
              int_ds_fornecedor.complemento            = substr(emitente.inf-complementar,1,20)
              int_ds_fornecedor.email_nfe              = substr(emitente.e-mail,1,40)           
              int_ds_fornecedor.importar               = "1"
              int_ds_fornecedor.fluxocaixads           = ""
              int_ds_fornecedor.forma_pgto             = ""    
              int_ds_fornecedor.grupo_desp             = SUBSTR(STRING(emitente.tp-desp-padrao),1,2)  
              int_ds_fornecedor.gera_prov              = "S" 
              int_ds_fornecedor.gera_lanc              = "S" 
              int_ds_fornecedor.aplicaredutorsn        = "N" 
              int_ds_fornecedor.perc_verba             = 0 
              int_ds_fornecedor.liberacaolab           = "N" 
              int_ds_fornecedor.calculostvalordesconto = "N"
              int_ds_fornecedor.protocolodevolucao     = IF int_ds_ext_emitente.protocolodevolucao = YES THEN "S" ELSE "N"
              int_ds_fornecedor.emitedanfe             = IF int_ds_ext_emitente.emitedanfe         = YES THEN "S" ELSE "N"
              int_ds_fornecedor.databloqueio           = int_ds_ext_emitente.databloqueio
              int_ds_fornecedor.biometriamotorista     = IF int_ds_ext_emitente.biometriamotorista = YES THEN "S" ELSE "N"
              int_ds_fornecedor.microempresa           = IF int_ds_ext_emitente.microempresa       = YES THEN "S" ELSE "N"
              int_ds_fornecedor.prazo_entrega          = int_ds_ext_emitente.prazo_entrega
              int_ds_fornecedor.eancnpj                = substr(int_ds_ext_emitente.eancnpj,1,13)
              int_ds_fornecedor.tipo_trib              = IF int_ds_ext_emitente.tipo_trib          = 1 THEN "D" ELSE "T"
              int_ds_fornecedor.industria              = IF int_ds_ext_emitente.industria          = YES THEN "S" ELSE "N"
              int_ds_fornecedor.emitenotadevolucao     = IF int_ds_ext_emitente.emitenotadevolucao = YES THEN "S" ELSE "N"
              int_ds_fornecedor.excecaoindustria       = IF int_ds_ext_emitente.excecaoindustria   = YES THEN "S" ELSE "N"
              int_ds_fornecedor.cod_gr_forn            = emitente.cod-gr-forn
              int_ds_fornecedor.id_sequencial          = NEXT-VALUE(seq-int-ds-fornecedor).
    END.
    
    apply "close" to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-window 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-window  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-window  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-window  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-window)
  THEN DELETE WIDGET w-window.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-window  _DEFAULT-ENABLE
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
  DISPLAY tg-protocolo tg-emitedanfe tg-biometria tg-microempresa tg-industria 
          tg-notadevolucao tg-excecao rs-tipo-trib da-dt-bloqueio c-eancnpj 
          i-prazo 
      WITH FRAME F-Main IN WINDOW w-window.
  ENABLE RECT-1 RECT-2 RECT-3 tg-protocolo tg-emitedanfe tg-biometria 
         tg-microempresa tg-industria tg-notadevolucao tg-excecao rs-tipo-trib 
         da-dt-bloqueio c-eancnpj i-prazo bt-ok bt-cancelar bt-ajuda 
      WITH FRAME F-Main IN WINDOW w-window.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
  VIEW w-window.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy w-window 
PROCEDURE local-destroy :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'destroy':U ) .
 
  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-window 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize w-window 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
  {include/win-size.i}

  {utp/ut9000.i "NICD0401" "2.06.00.000"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE (INPUT 'initialize':U ) .

  ASSIGN tg-protocolo                = NO 
         tg-emitedanfe               = YES 
         tg-biometria                = NO 
         tg-microempresa             = NO 
         tg-industria                = NO 
         tg-notadevolucao            = NO 
         tg-excecao                  = NO 
         rs-tipo-trib                = 1
         da-dt-bloqueio              = ? 
         c-eancnpj                   = "" 
         i-prazo                     = 0.

  FIND FIRST emitente WHERE
             ROWID(emitente) = gr-emitente NO-LOCK NO-ERROR.
  IF AVAIL emitente THEN DO:
     FIND FIRST int_ds_ext_emitente WHERE
                int_ds_ext_emitente.cod_emitente = emitente.cod-emitente NO-LOCK NO-ERROR.
     IF AVAIL int_ds_ext_emitente THEN DO:
        ASSIGN tg-protocolo     = int_ds_ext_emitente.protocolodevolucao 
               tg-emitedanfe    = int_ds_ext_emitente.emitedanfe         
               tg-biometria     = int_ds_ext_emitente.biometriamotorista 
               tg-microempresa  = int_ds_ext_emitente.microempresa       
               tg-industria     = int_ds_ext_emitente.industria          
               tg-notadevolucao = int_ds_ext_emitente.emitenotadevolucao 
               tg-excecao       = int_ds_ext_emitente.excecaoindustria   
               rs-tipo-trib     = int_ds_ext_emitente.tipo_trib          
               da-dt-bloqueio   = int_ds_ext_emitente.databloqueio       
               c-eancnpj        = int_ds_ext_emitente.eancnpj            
               i-prazo          = int_ds_ext_emitente.prazo_entrega.
     END.
  END.

  DISP tg-protocolo    
       tg-emitedanfe   
       tg-biometria    
       tg-microempresa 
       tg-industria    
       tg-notadevolucao
       tg-excecao      
       rs-tipo-trib    
       da-dt-bloqueio               
       c-eancnpj            
       i-prazo
       WITH FRAME {&FRAME-NAME}.
      
  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-window  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this JanelaDetalhe, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-window 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

