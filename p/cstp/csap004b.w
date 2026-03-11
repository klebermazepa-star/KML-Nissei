&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

  File: 

  Description: 

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
{cstp/csap004.i}

/* Local Variable Definitions ---                                       */

DEFINE INPUT PARAM TABLE FOR ttTitulo.
DEFINE INPUT PARAMETER p-estab-ini   AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER p-estab-fim   AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER p-espec-ini   AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER p-espec-fim   AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER p-titulo-ini  AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER p-titulo-fim  AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER p-parcela-ini AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER p-parcela-fim AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER p-vencto-ini  AS DATE       NO-UNDO.
DEFINE INPUT PARAMETER p-vencto-fim  AS DATE       NO-UNDO.
DEFINE INPUT PARAMETER p-emissao-ini AS DATE       NO-UNDO.
DEFINE INPUT PARAMETER p-emissao-fim AS DATE       NO-UNDO.
DEFINE INPUT PARAMETER p-portad-ini  AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER p-portad-fim  AS CHARACTER  NO-UNDO.
DEFINE INPUT PARAMETER p-fornec-ini  AS INTEGER  NO-UNDO.
DEFINE INPUT PARAMETER p-fornec-fim  AS INTEGER  NO-UNDO.
DEFINE INPUT PARAM TABLE FOR ttPortador.


DEFINE VARIABLE c-ant AS CHARACTER  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-440

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rs-destino rs-execucao bt-cfimp bt-salva ~
bt-imprime bt-cancela RECT-2 RECT-8 
&Scoped-Define DISPLAYED-OBJECTS v-linha rs-destino rs-execucao v_imp_param ~
v-coluna v_des_arquivo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-arquivo 
     IMAGE-UP FILE "image\im-sea1":U
     LABEL "" 
     SIZE 3.86 BY 1.08 TOOLTIP "Localiza Arquivo".

DEFINE BUTTON bt-cancela 
     LABEL "Cancelar" 
     SIZE 11.14 BY 1 TOOLTIP "Cancelar"
     FONT 1.

DEFINE BUTTON bt-cfimp 
     IMAGE-UP FILE "image\im-cfprt":U
     LABEL "" 
     SIZE 3.86 BY 1.08 TOOLTIP "Layout ImpressÆo".

DEFINE BUTTON bt-imprime 
     LABEL "Imprimir" 
     SIZE 11.14 BY 1 TOOLTIP "Imprimir"
     FONT 1.

DEFINE BUTTON bt-salva 
     LABEL "Fechar" 
     SIZE 11.14 BY 1 TOOLTIP "Fechar/Salvar"
     FONT 1.

DEFINE VARIABLE v-coluna AS INTEGER FORMAT "ZZ9":U INITIAL 132 
     LABEL "Col" 
     VIEW-AS FILL-IN 
     SIZE 4.43 BY .88 TOOLTIP "Colunas"
     BGCOLOR 15 FONT 2 NO-UNDO.

DEFINE VARIABLE v-linha AS INTEGER FORMAT "Z9":U INITIAL 63 
     LABEL "Lin" 
     VIEW-AS FILL-IN 
     SIZE 4.43 BY .88 TOOLTIP "Linhas"
     BGCOLOR 15 FONT 2 NO-UNDO.

DEFINE VARIABLE v_des_arquivo AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 40.57 BY .88 TOOLTIP "Destino"
     BGCOLOR 15 FONT 2 NO-UNDO.

DEFINE VARIABLE rs-destino AS INTEGER INITIAL 3 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Terminal", 3,
"Arquivo", 2,
"Impressora", 1
     SIZE 40.43 BY .67 TOOLTIP "Destino da ImpressÆo"
     FONT 1 NO-UNDO.

DEFINE VARIABLE rs-execucao AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "On Line", "1"
     SIZE 10.29 BY .75 TOOLTIP "Execu‡Æo On Line ou Batch"
     FONT 1 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 48.14 BY 1.5
     BGCOLOR 18 .

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 48.14 BY 2.58.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 48 BY 2.58.

DEFINE VARIABLE v_imp_param AS LOGICAL INITIAL no 
     LABEL "Imprimir Parƒmetros" 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 TOOLTIP "Imprimir Parƒmetros"
     FONT 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-440
     v-linha AT ROW 1.5 COL 42.14 COLON-ALIGNED
     rs-destino AT ROW 4.54 COL 3.29 HELP
          "Destino da ImpressÆo" NO-LABEL
     rs-execucao AT ROW 2.25 COL 3 HELP
          "Execu‡Æo On Line ou Batch" NO-LABEL
     v_imp_param AT ROW 2.25 COL 19.14 HELP
          "Imprimir Parƒmetros"
     bt-cfimp AT ROW 5.21 COL 44 HELP
          "Layout ImpressÆo"
     bt-arquivo AT ROW 5.29 COL 44 HELP
          "Localiza Arquivo"
     v-coluna AT ROW 2.5 COL 42.14 COLON-ALIGNED
     v_des_arquivo AT ROW 5.46 COL 3 HELP
          "Destino" NO-LABEL
     bt-salva AT ROW 7.21 COL 3.14
     bt-imprime AT ROW 7.21 COL 14.72
     bt-cancela AT ROW 7.21 COL 26.29
     " Parƒmetro" VIEW-AS TEXT
          SIZE 8 BY .63 AT ROW 1 COL 5.14
          FONT 1
     "ImpressÆo" VIEW-AS TEXT
          SIZE 8 BY .63 AT ROW 3.92 COL 4.14
          FONT 1
     RECT-7 AT ROW 4.21 COL 2
     RECT-2 AT ROW 6.96 COL 2
     RECT-8 AT ROW 1.29 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY NO-HELP 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 49.57 BY 7.54
         BGCOLOR 17 FONT 1.


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
         TITLE              = "Execu‡Æo destina‡Æo pagamentos"
         COLUMN             = 110.29
         ROW                = 6.92
         HEIGHT             = 7.54
         WIDTH              = 49.57
         MAX-HEIGHT         = 16
         MAX-WIDTH          = 96.72
         VIRTUAL-HEIGHT     = 16
         VIRTUAL-WIDTH      = 96.72
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-440
   FRAME-NAME Custom                                                    */
/* SETTINGS FOR BUTTON bt-arquivo IN FRAME f-440
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-7 IN FRAME f-440
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-coluna IN FRAME f-440
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-linha IN FRAME f-440
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v_des_arquivo IN FRAME f-440
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR TOGGLE-BOX v_imp_param IN FRAME f-440
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Execu‡Æo destina‡Æo pagamentos */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Execu‡Æo destina‡Æo pagamentos */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-arquivo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-arquivo C-Win
ON CHOOSE OF bt-arquivo IN FRAME f-440
DO:
    def var c-arq-conv  as char no-undo.
    def var l-ok        as logical init no.

    assign c-arq-conv = replace(input frame f-440 v_des_arquivo, "/", "\").
    SYSTEM-DIALOG GET-FILE c-arq-conv
       FILTERS "*.lst" "*.lst",
               "*.*" "*.*"
       ASK-OVERWRITE 
       DEFAULT-EXTENSION "lst"
       INITIAL-DIR "spool" 
       SAVE-AS
       USE-FILENAME
       UPDATE l-ok.
    if  l-ok = yes then do:
        assign v_des_arquivo = replace(c-arq-conv, "\", "/"). 
        display v_des_arquivo with frame f-440.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cancela
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancela C-Win
ON CHOOSE OF bt-cancela IN FRAME f-440 /* Cancelar */
DO:
  apply "close" to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cfimp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cfimp C-Win
ON CHOOSE OF bt-cfimp IN FRAME f-440
DO:
    assign c-ant = v_des_arquivo:screen-value in frame f-440.
  
    run prgtec/btb/btb036nb.p (output c-impressora, output c-layout).
    
    if v_des_arquivo <> ":" then
      assign v_des_arquivo = c-impressora + ":" + c-layout.
    else
      assign v_des_arquivo = c-ant.
      
    disp v_des_arquivo with frame f-440.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-imprime
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-imprime C-Win
ON CHOOSE OF bt-imprime IN FRAME f-440 /* Imprimir */
DO:
    run pi_salva_param.
    
    if session:set-wait-state("general") then. /* mostra na tela a amputela */

    run cstp\csap004rp.p (INPUT TABLE ttTitulo, INPUT TABLE ttPortador).

    if session:set-wait-state("") then.

    if rs-destino:screen-value in frame {&frame-name} = "3" then
        run utils/winExec.p('notepad.exe ' + session:temp-directory + 'csap004rp' + ".lst", 1).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-salva
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-salva C-Win
ON CHOOSE OF bt-salva IN FRAME f-440 /* Fechar */
DO:
  run pi_vld_param.
  
  run pi_salva_param.
  
  apply "close" to this-procedure. 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-destino
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-destino C-Win
ON VALUE-CHANGED OF rs-destino IN FRAME f-440
DO:
 
    
  if input frame f-440 rs-destino = 1 then do:
      assign bt-arquivo:visible  in frame f-440 = no
             bt-cfimp:visible    in frame f-440 = yes
             v_des_arquivo:visible   in frame f-440 = yes
             v_des_arquivo:sensitive in frame f-440 = no.
      if c-impressora = "" then do:
          find first imprsor_usuar no-lock
              where imprsor_usuar.cod_usuario = v_cod_usuar_corren
              use-index imprsrsr_id no-error.
          if avail imprsor_usuar then do:
              find first layout_impres no-lock
                  where layout_impres.nom_impressora  = imprsor_usuar.nom_impressora no-error.
              if avail layout_impres then
                  assign v_des_arquivo:screen-value in frame f-440 = imprsor_usuar.nom_impressora + ":" + layout_impres.cod_layout_impres
                         c-impressora                          = imprsor_usuar.nom_impressora
                         c-layout                              = layout_impres.cod_layout_impres.
          end.
      end.
      else
          assign v_des_arquivo:screen-value in frame f-440 = c-impressora + ":" + c-layout.
          
  end.
             
  if input frame f-440 rs-destino = 2 then do:
      assign bt-arquivo:visible  in frame f-440 = no
             bt-cfimp:visible    in frame f-440 = no
             v_des_arquivo:visible   in frame f-440 = yes             
             v_des_arquivo:sensitive in frame f-440 = no.
      assign v_des_arquivo:screen-value in frame f-440 = session:temp-directory + 'csap004rp' + ".lst"
             c-impressora                          = ""
             c-layout                              = "".
          
          
  end.

  if input frame f-440 rs-destino = 3 then
      assign bt-arquivo:visible  in frame f-440 = no
             bt-cfimp:visible    in frame f-440 = no
             v_des_arquivo:visible   in frame f-440 = no
             v_des_arquivo:screen-value in frame f-440 = session:temp-directory + 'csap004rp' + ".lst". 
       
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-execucao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-execucao C-Win
ON VALUE-CHANGED OF rs-execucao IN FRAME f-440
DO:
  if input frame f-440 rs-execucao = "2" then do:
     if rs-destino:disable("Terminal") in frame f-440 then.
  end.
  else do:
      if rs-destino:enable("Terminal") in frame f-440 then.
  end.
  
  apply "value-changed" to rs-destino in frame f-440.
     
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
  
   assign bt-arquivo:visible  in frame f-440 = no
             bt-cfimp:visible    in frame f-440 = no
             v_des_arquivo:sensitive   in frame f-440 = no
             v_des_arquivo:screen-value in frame f-440 = session:temp-directory + 'csap004rp' + ".lst". 
  
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY v-linha rs-destino rs-execucao v_imp_param v-coluna v_des_arquivo 
      WITH FRAME f-440 IN WINDOW C-Win.
  ENABLE rs-destino rs-execucao bt-cfimp bt-salva bt-imprime bt-cancela RECT-2 
         RECT-8 
      WITH FRAME f-440 IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-440}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_message C-Win 
PROCEDURE pi_message :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def input param c_action    as char    no-undo.
def input param i_msg       as integer no-undo.
def input param c_param     as char    no-undo.

def var c_prg_msg           as char    no-undo.

assign c_prg_msg = "messages/"
                 + string(trunc(i_msg / 1000,0),"99")
                 + "/msg"
                 + string(i_msg, "99999").

if search(c_prg_msg + ".r") = ? and search(c_prg_msg + ".p") = ? then do:
    message "Mensagem nr. " i_msg "!!!" skip
            "Programa Mensagem" c_prg_msg "nÆo encontrado."
            view-as alert-box error.
    return error.
end.

run value(c_prg_msg + ".p") (input c_action, input c_param).
return return-value.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_salva_param C-Win 
PROCEDURE pi_salva_param :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    assign input frame f-440 rs-destino
           input frame f-440 v_des_arquivo.
    
    assign v_cod_programa         = "csap004"
           v_cod_dwb_file         = input frame f-440 v_des_arquivo                            
           v_log_dwb_param        = input frame f-440 v_imp_param
           v_cod_parameters       =  p-estab-ini  + chr(10) +
                                     p-estab-fim  + chr(10) +                          
                                     p-espec-ini  + chr(10) +                          
                                     p-espec-fim  + chr(10) +                          
                                     p-titulo-ini + chr(10) +                          
                                     p-titulo-fim + chr(10) +                          
                                     p-parcela-ini + chr(10) +                         
                                     p-parcela-fim + chr(10) +                      
                                     string(p-vencto-ini)  + chr(10) +                         
                                     string(p-vencto-fim)  + chr(10) +                          
                                     string(p-emissao-ini) + chr(10) +                          
                                     string(p-emissao-fim) + chr(10) +                          
                                     string(p-portad-ini)  + chr(10) +                         
                                     string(p-portad-fim)  + chr(10) +                         
                                     string(p-fornec-ini) + chr(10) +                          
                                     string(p-fornec-fim).                           
        v_cod_dwb_output          = if rs-destino = 1 then "Impressora" else
                                    if rs-destino = 2 then "Arquivo" else
                                    if rs-destino = 3 then "Terminal" else "arquivo".

    run prgtec/btb/btb906za.p.
    
    if rs-destino = 2 and rs-execucao = "2" then do: /* arquivo ou batch */
        do while index(v_des_arquivo,"~/") <> 0: 
            assign v_des_arquivo = substring(v_des_arquivo,(index(v_des_arquivo,"~/" ) + 1)).
        end. 
    end.
    
    /* Recuperar parâmetros da última execução */
    
    do transaction:    
        find dwb_set_list_param exclusive-lock
            where dwb_set_list_param.cod_dwb_program = v_cod_programa
            and   dwb_set_list_param.cod_dwb_user    = v_cod_usuar_corren no-error.
            
        if  not avail emsfnd.dwb_set_list_param then
            create emsfnd.dwb_set_list_param.
        assign emsfnd.dwb_set_list_param.cod_dwb_program          = v_cod_programa
               emsfnd.dwb_set_list_param.cod_dwb_user             = v_cod_usuar_corren
               emsfnd.dwb_set_list_param.cod_dwb_file             = session:temp-directory + 'csap004rp' + ".lst"
               emsfnd.dwb_set_list_param.nom_dwb_printer          = c-impressora
               emsfnd.dwb_set_list_param.cod_dwb_print_layout     = c-layout
               emsfnd.dwb_set_list_param.qtd_dwb_line             = 66
               emsfnd.dwb_set_list_param.log_dwb_print_parameters = v_imp_param
               emsfnd.dwb_set_list_param.cod_dwb_parameters       = v_cod_parameters
               emsfnd.dwb_set_list_param.cod_dwb_output           = if rs-destino = 1 then "Impressora" ELSE 
                                                                    if rs-destino = 2 then "Arquivo" ELSE 
                                                                    if rs-destino = 3 then "Terminal" else "arquivo".
    end. /* transaction */    
    /*** para desalocar o registro ***/
    
    find emsfnd.dwb_set_list_param no-lock
        where emsfnd.dwb_set_list_param.cod_dwb_program = v_cod_programa
        and   emsfnd.dwb_set_list_param.cod_dwb_user    = v_cod_usuar_corren no-error.

    if rs-execucao = "2" then do:
        run prgtec/btb/btb911za.p (input  v_cod_programa,
                                   input  "1.00.000",
                                   input  0,
                                   input  recid(emsfnd.dwb_set_list_param),
                                   output v_num_ped_exec_rpw).
       
        if v_num_ped_exec_rpw <> 0 then do:
            run pi_messages  (input "show",
                             input 3556,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                 v_num_ped_exec_rpw)).
      
            find current dwb_set_list_param no-lock no-error.           
        end.
    end.   
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_vld_param C-Win 
PROCEDURE pi_vld_param :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
if input frame f-440 rs-destino = 2 then do:

    for each emsfnd.ped_exec no-lock
        where emsfnd.ped_exec.cod_prog_dtsul = "rpt_comp_orcamen_desp_denso"
          and emsfnd.ped_exec.ind_sit_ped    = "NÆo executado" :
          
       find emsfnd.ped_exec_param  of ped_exec no-lock no-error.
       if avail ped_exec_param then do:
          if ped_exec_param.cod_dwb_file = input frame f-440 v_des_arquivo then do:
            run utp/message.p (input "Nome do Arquivo encontrado em outro pedido,Deseja continuar?",
                               input  "Foi encontrado um pedido com o mesmo nome a ser criado."      + chr(10) +
                                      "Arquivo....: " + ped_exec_param.cod_dwb_file + chr(10) +
                                      "Usuario....: " + ped_exec.cod_usuar   + chr(10) +
                                      "Num Pedido.: " + string(ped_exec_param.num_ped_exec)).
            apply "entry" to v_des_arquivo in frame f-440.
            leave.
          end.  
       end.
    end.

     
 END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

