&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

def buffer bf-nota-fiscal  for nota-fiscal.
def buffer bf-it-nota-fisc for it-nota-fisc.
def buffer bf-fat-ser-lote for fat-ser-lote.

DEF TEMP-TABLE tt-nota-fiscal  NO-UNDO LIKE nota-fiscal.
DEF TEMP-TABLE tt-it-nota-fisc NO-UNDO LIKE it-nota-fisc.
DEF TEMP-TABLE tt-fat-ser-lote NO-UNDO LIKE fat-ser-lote.
DEF TEMP-TABLE tt-rat-lote     NO-UNDO LIKE rat-lote.

def temp-table tt-versao-integr-2
   field registro              as int format "9"          initial 0
   field cod-versao-integracao as int format "999"        initial 4.

define temp-table tt-docum-est
  field registro           as integer
  field serie-docto        as character
  field nro-docto          as character
  field cod-emitente       as integer
  field nat-operacao       as character
  field cod-observa        as integer
  field cod-estabel        as character
  field estab-fisc         as character
  field conta-transit      as character
  field dt-emissao         as date
  field dt-trans           as date
  field usuario            as character
  field uf                 as character
  field via-transp         as integer
  field mod-frete          as integer
  field nff                as logical 
  field tot-peso           as decimal
  field tot-desconto       as decimal 
  field valor-frete        as decimal
  field valor-seguro       as decimal
  field valor-embal        as decimal
  field valor-outras       as decimal
  field valor-mercad       as decimal
  field dt-venc-ipi        as date
  field dt-venc-icm        as date
  field tot-valor          as decimal
  field efetua-calculo     as integer
  field observacao         as character
  field cotacao-dia        as decimal
  field embarque           as character
  field sequencia          as integer
  field esp-docto          as integer
  field rec-fisico         as logical
  field origem             as character
  field pais-origem        as character
  field ct-transit         as character
  field sc-transit         as character
  field gera-unid-neg      as INTEGER
  field nome-transp        as char
  field cod-placa-1        as char
  field cod-placa-2        as char
  field cod-placa-3        as char
  field cod-uf-placa-1     as char
  field cod-uf-placa-2     as char
  field cod-uf-placa-3     as char
  field char-1             as CHAR
  index documento is primary
          serie-docto
          nro-docto
          cod-emitente
          nat-operacao
  index seq is unique
           sequencia.
  

define temp-table tt-item-doc-est
  field registro           as integer
  field it-codigo          as character
  field cod-refer          as character
  field numero-ordem       as integer
  field parcela            as integer
  field encerra-pa         as logical
  field nr-ord-prod        as integer
  field cod-roteiro        as character
  field op-codigo          as integer
  field item-pai           as character
  field conta-contabil     as character
  field baixa-ce           as logical
  field etiquetas          as integer
  field qt-do-forn         as decimal
  field quantidade         as decimal
  field preco-total        as decimal
  field desconto           as decimal
  field vl-frete-cons      as decimal
  field despesas           as decimal
  field peso-liquido       as decimal
  field cod-depos          as character
  field cod-localiz        as character
  field lote               as character
  field dt-vali-lote       as date
  field class-fiscal       as character
  field aliquota-ipi       as decimal
  field cd-trib-ipi        as integer
  field base-ipi           as decimal
  field valor-ipi          as decimal
  field aliquota-iss       as decimal
  field cd-trib-iss        as integer
  field base-iss           as decimal
  field valor-iss          as decimal
  field aliquota-icm       as decimal
  field cd-trib-icm        as integer
  field base-icm           as decimal
  field valor-icm          as decimal
  field base-subs          as decimal
  field valor-subs         as decimal
  field icm-complem        as decimal
  field ind-icm-ret        as logical
  field narrativa          as character
  field serie-comp         as character
  field nro-comp           as character
  field nat-comp           as character
  field seq-comp           as integer
  field data-comp          as date
  field icm-outras         as decimal
  field ipi-outras         as decimal
  field iss-outras         as decimal
  field icm-ntrib          as decimal
  field ipi-ntrib          as decimal
  field iss-ntrib          as decimal
  field val-perc-red-ipi   as decimal
  field val-perc-red-icm   as decimal
  field nr-proc-imp        as character
  field serie-docto        as character
  field nro-docto          as character
  field cod-emitente       as integer
  field nat-operacao       as character
  field sequencia          as integer
  field nr-ato-concessorio as character
  field per-ppm            as decimal
  field cod-unid-negoc     as CHAR
  index documento is primary unique
         serie-docto
         nro-docto
         cod-emitente
         nat-operacao
         sequencia.

define temp-table tt-dupli-apagar
   field registro        as integer
   field parcela         as character
   field nr-duplic       as character
   field cod-esp         as character
   field tp-despesa      as integer
   field dt-vencim       as date
   field vl-a-pagar      as decimal
   field vl-desconto     as decimal
   field dt-venc-desc    as date
   field cod-ret-irf     as integer
   field mo-codigo       as integer
   field vl-a-pagar-mo   as decimal
   field serie-docto     as character
   field nro-docto       as character
   field cod-emitente    as integer
   field nat-operacao    as character.

def temp-table tt-dupli-imp
   field registro      as int   
   field cod-imp       as int   
   field cod-esp       as char  
   field dt-venc-imp   as date  
   field rend-trib     as dec   
   field aliquota      as dec   
   field vl-imposto    as dec   
   field tp-codigo     as int   
   field cod-retencao  as int   
   field serie-docto   as char  
   field nro-docto     as char  
   field cod-emitente  as int   
   field nat-operacao  as char  
   field parcela       as char.  

def temp-table tt-unid-neg-nota
   field registro        as int  
   field cod-emitente    as int  
   field serie-docto     as char 
   field nro-docto       as char 
   field nat-operacao    as char 
   field sequencia       as int  
   field cod_unid_negoc  as char
   field perc-unid-neg   as dec. 

def temp-table tt-erro
   field i-sequen  as int  format "9999"                   initial 1 
   field cd-erro   as int  format "99999"  
   field mensagem  as char format "x(70)".

/* Parameters Definitions ---                                           */

def new global shared var c-seg-usuario as character format "x(12)" no-undo.

/* Local Variable Definitions ---                                       */

DEF VAR i-seq-erro   AS INTEGER NO-UNDO.
DEF VAR c-arq-erro   AS CHAR    NO-UNDO.
DEF VAR c-key-value  AS CHAR    NO-UNDO.
DEF VAR i-sequencial AS INTEGER NO-UNDO.

C-arq-erro = SESSION:TEMP-DIRECTORY + "esre006.txt".

DEF STREAM s-erro.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-4 RECT-5 fi-cod-estabel fi-serie ~
fi-nr-nota-fis fi-pasta fi-estab-ent fi-emit-ent fi-natur-ent fi-cod-depos ~
tg-devolucao bt-ok bt-cancelar  
&Scoped-Define DISPLAYED-OBJECTS fi-cod-estabel fi-serie ~
fi-nr-nota-fis fi-pasta fi-estab-ent fi-emit-ent fi-natur-ent fi-cod-depos tg-devolucao

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-arquivo-imagem 
     IMAGE-UP FILE "image/im-sea.bmp":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-cancelar AUTO-END-KEY 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-ok 
     LABEL "Gerar" 
     SIZE 10 BY 1.

DEFINE VARIABLE fi-pasta AS CHARACTER FORMAT "x(70)" 
     LABEL "Diret¢rio" 
     VIEW-AS FILL-IN 
     SIZE 42 BY .88 NO-UNDO.

DEFINE VARIABLE fi-cod-estabel LIKE nota-fiscal.cod-estabel
     LABEL "Estab. Sa¡da" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE fi-serie LIKE nota-fiscal.serie INITIAL ""
     LABEL "S‚rie" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nr-nota-fis LIKE nota-fiscal.nr-nota-fis
     LABEL "Nota Fiscal" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE fi-estab-ent LIKE nota-fiscal.cod-estabel
     LABEL "Estab. Entrada" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE fi-emit-ent LIKE docum-est.cod-emitente
     LABEL "Fornecedor" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE fi-natur-ent LIKE docum-est.nat-operacao
     LABEL "Natureza Entrada" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE tg-devolucao AS LOGICAL INITIAL no 
     LABEL "Devolu‡Æo" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY .83
     FONT 1 NO-UNDO.

DEFINE VARIABLE fi-cod-depos LIKE deposito.cod-depos
     LABEL "Dep¢sito Entrada" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 84.43 BY 1.38
     BGCOLOR 7 .

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 84.57 BY 4.3.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 84.57 BY 4.3.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     fi-cod-estabel    AT ROW 1.17 COL 24.29 COLON-ALIGNED WIDGET-ID 26
     fi-serie          AT ROW 2.17 COL 24.29 COLON-ALIGNED WIDGET-ID 26
     fi-nr-nota-fis    AT ROW 3.17 COL 24.29 COLON-ALIGNED WIDGET-ID 26
     fi-pasta          AT ROW 4.17 COL 24.29 COLON-ALIGNED WIDGET-ID 26
     fi-estab-ent      AT ROW 5.67 COL 24.29 COLON-ALIGNED WIDGET-ID 26
     fi-emit-ent       AT ROW 6.67 COL 24.29 COLON-ALIGNED WIDGET-ID 26
     fi-natur-ent      AT ROW 7.67 COL 24.29 COLON-ALIGNED WIDGET-ID 26
     fi-cod-depos      AT ROW 8.67 COL 24.29 COLON-ALIGNED WIDGET-ID 26
     tg-devolucao      AT ROW 8.67 COL 40    COLON-ALIGNED WIDGET-ID 26
     bt-ok             AT ROW 10.26 COL 2.14 WIDGET-ID 48
     bt-cancelar       AT ROW 10.26 COL 13.14 WIDGET-ID 46
     RECT-1            AT ROW 9.97 COL 1 WIDGET-ID 52
     RECT-4            AT ROW 1    COL 1 WIDGET-ID 2
     RECT-5            AT ROW 5.5  COL 1 WIDGET-ID 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 84.57 BY 10.54 WIDGET-ID 100.


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
         TITLE              = "Importar NF Entrada"
         HEIGHT             = 10.54
         WIDTH              = 84.57
         MAX-HEIGHT         = 10.63
         MAX-WIDTH          = 84.57
         VIRTUAL-HEIGHT     = 10.63
         VIRTUAL-WIDTH      = 84.57
         RESIZE             = yes
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
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* <insert window title> */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
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


&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar C-Win
ON CHOOSE OF bt-cancelar IN FRAME DEFAULT-FRAME /* Cancelar */
DO:
  apply "close":U to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok C-Win
ON CHOOSE OF bt-ok IN FRAME DEFAULT-FRAME /* Enviar */
DO:

   DEF VAR i-seq-fat  AS INTEGER NO-UNDO.
   DEF VAR c-arq-nota AS CHAR    NO-UNDO.
   DEF VAR c-arq-item AS CHAR    NO-UNDO.
   DEF VAR c-arq-lote AS CHAR    NO-UNDO.

   EMPTY TEMP-TABLE tt-nota-fiscal.
   EMPTY TEMP-TABLE tt-it-nota-fisc.
   EMPTY TEMP-TABLE tt-fat-ser-lote.

   ASSIGN fi-cod-estabel.
   ASSIGN fi-serie.
   ASSIGN fi-nr-nota-fis.
   ASSIGN fi-pasta.
   ASSIGN fi-estab-ent.
   ASSIGN fi-emit-ent.
   ASSIGN fi-natur-ent.
   ASSIGN fi-cod-depos.
   ASSIGN tg-devolucao.

   c-arq-nota = fi-pasta + fi-cod-estabel + "-" + fi-serie + "-" + fi-nr-nota-fis + "-nota.d".
   c-arq-item = fi-pasta + fi-cod-estabel + "-" + fi-serie + "-" + fi-nr-nota-fis + "-item.d".
   c-arq-lote = fi-pasta + fi-cod-estabel + "-" + fi-serie + "-" + fi-nr-nota-fis + "-lote.d".

   IF NOT (search(c-arq-nota) <> ?) OR
      NOT (search(c-arq-item) <> ?) OR
      NOT (search(c-arq-lote) <> ?) THEN DO:

      MESSAGE "Arquivos a ser importados nÆo foram encontrados." VIEW-AS ALERT-BOX.

      apply 'entry':U to fi-pasta in frame {&frame-name}.

   END.

   input from value(search(c-arq-nota)).

   repeat:

      CREATE tt-nota-fiscal.
      IMPORT tt-nota-fiscal.

   end.   

   input close.

   input from value(search(c-arq-item)).

   repeat:

      CREATE tt-it-nota-fisc.
      IMPORT tt-it-nota-fisc.

   end.   

   input close.

   input from value(search(c-arq-lote)).

   repeat:

      CREATE tt-fat-ser-lote.
      IMPORT tt-fat-ser-lote.

   end.   

   input close.

   IF CAN-FIND(FIRST tt-nota-fiscal) THEN DO:

      EMPTY TEMP-TABLE tt-erro.

      RUN gera-nota-fiscal.

      IF NOT CAN-FIND(FIRST tt-erro) THEN

         MESSAGE "Nota Fiscal importada com sucesso!" VIEW-AS ALERT-BOX.

      ELSE DO:

         OUTPUT STREAM s-erro TO VALUE(c-arq-erro).

         PUT STREAM s-erro "ERROS NA GERACAO DA NOTA FISCAL" SKIP
                           "-------------------------------" SKIP.

         FOR EACH tt-erro NO-LOCK:

            PUT STREAM s-erro tt-erro.cd-erro  " - "
                              tt-erro.mensagem SKIP.

         END.

         OUTPUT STREAM s-erro CLOSE.

         get-key-value section "Datasul_EMS2" key "Show-Report-Program" value c-key-value.

         if c-key-value = "":U or c-key-value = ?  then do:
            assign c-key-value = "Notepad.exe".
            put-key-value section "Datasul_EMS2" key "Show-Report-Program" value c-key-value no-error.
         end.

         run winexec (input c-key-value + chr(32) + c-arq-erro, input 1).

      END.
   END.

   apply 'entry':U to fi-cod-estabel in frame {&frame-name}.

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

  fi-pasta:screen-value in frame {&frame-name} = session:temp-directory.

  apply 'entry':U to fi-cod-estabel in frame {&frame-name}.

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
  DISPLAY fi-cod-estabel fi-serie fi-nr-nota-fis fi-pasta
          fi-estab-ent fi-emit-ent fi-natur-ent fi-cod-depos tg-devolucao
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE RECT-1 RECT-4  RECT-5 
         fi-cod-estabel fi-serie fi-nr-nota-fis fi-pasta 
         fi-estab-ent fi-emit-ent fi-natur-ent fi-cod-depos tg-devolucao
         bt-ok bt-cancelar 
         WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-nota-fiscal C-Win
PROCEDURE gera-nota-fiscal:

   def var c-ct-codigo as char no-undo.
   def var c-sc-codigo as char no-undo.

   find first param-estoq no-lock no-error.

   find first estabelec  where estabelec.cod-estabel   = fi-estab-ent no-lock no-error.  
   find first natur-oper where natur-oper.nat-operacao = fi-natur-ent no-lock no-error.  
   find first emitente   where emitente.cod-emitente   = fi-emit-ent  no-lock no-error.

   if tg-devolucao then do:
   
      for each cta_grp_clien where cta_grp_clien.cod_grp_clien = string(emitente.cod-gr-cli) no-lock:

         if cta_grp_clien.ind_finalid_ctbl <> "Devolu‡Æo" then next.

         c-ct-codigo = substring(cta_grp_clien.cod_cta_ctbl, 1, 8).
         c-sc-codigo = substring(cta_grp_clien.cod_cta_ctbl, 9).

      end.
   end.

   EMPTY TEMP-TABLE tt-versao-integr-2.

   CREATE tt-versao-integr-2.

   ASSIGN tt-versao-integr-2.registro               =  3
          tt-versao-integr-2.cod-versao-integracao  =  4.

   FOR EACH tt-nota-fiscal NO-LOCK:

      IF tt-nota-fiscal.nr-nota-fis = "" THEN NEXT.
         
      EMPTY TEMP-TABLE tt-docum-est.

      CREATE tt-docum-est.

      ASSIGN tt-docum-est.registro          = 2
             tt-docum-est.serie-docto       = tt-nota-fiscal.serie
             tt-docum-est.nro-docto         = tt-nota-fiscal.nr-nota-fis
             tt-docum-est.cod-emitente      = fi-emit-ent
             tt-docum-est.nat-operacao      = fi-natur-ent
             tt-docum-est.cod-observa       = (IF tg-devolucao THEN 3 ELSE 1)
             tt-docum-est.cod-estabel       = fi-estab-ent
             tt-docum-est.estab-fisc        = fi-estab-ent
             tt-docum-est.dt-emissao        = tt-nota-fiscal.dt-emis-nota
             tt-docum-est.dt-trans          = today
             tt-docum-est.usuario           = c-seg-usuario
             tt-docum-est.uf                = (IF AVAILABLE emitente THEN emitente.estado ELSE tt-nota-fiscal.estado)
             tt-docum-est.via-transp        = 1
             tt-docum-est.mod-frete         = 1
             tt-docum-est.tot-desconto      = 0
             tt-docum-est.valor-frete       = 0
             tt-docum-est.valor-seguro      = 0
             tt-docum-est.valor-embal       = 0
             tt-docum-est.valor-outras      = 0
             tt-docum-est.dt-venc-ipi       = today
             tt-docum-est.dt-venc-icm       = today
             tt-docum-est.efetua-calculo    = 0 /* efetua os cÿlculos */
             tt-docum-est.sequencia         = 1
             tt-docum-est.esp-docto         = (IF tg-devolucao THEN 20 ELSE 21)
             tt-docum-est.rec-fisico        = no
             tt-docum-est.origem            = "" /* verificar*/
             tt-docum-est.pais-origem       = "Brasil"
             tt-docum-est.cotacao-dia       = 0
             tt-docum-est.embarque          = ""
             tt-docum-est.gera-unid-neg     = 0
             tt-docum-est.tot-valor         = tt-nota-fiscal.vl-tot-nota
             tt-docum-est.valor-mercad      = tt-nota-fiscal.vl-mercad
             tt-docum-est.nff               = no
             tt-docum-est.cotacao-dia       = 1.

      if tg-devolucao then do:

         if c-ct-codigo <> "" and
            c-sc-codigo <> "" then
            assign tt-docum-est.conta-transit = c-ct-codigo + c-sc-codigo
                   tt-docum-est.ct-transit    = c-ct-codigo
                   tt-docum-est.sc-transit    = c-sc-codigo.
         else
            assign tt-docum-est.conta-transit = "3112010200000"
                   tt-docum-est.ct-transit    = "31120102"
                   tt-docum-est.sc-transit    = "00000".
             
      end.
      else do:
      
         assign tt-docum-est.conta-transit = (param-estoq.ct-tr-fornec + param-estoq.sc-tr-fornec)
                tt-docum-est.ct-transit    = param-estoq.ct-tr-fornec
                tt-docum-est.sc-transit    = param-estoq.sc-tr-fornec.
             
      end.

      EMPTY TEMP-TABLE tt-item-doc-est.

      FOR EACH tt-it-nota-fisc NO-LOCK:

         IF tt-it-nota-fisc.it-codigo = "" THEN NEXT.
            
         find first item where item.it-codigo = tt-it-nota-fisc.it-codigo no-lock no-error.

         create tt-item-doc-est.

         tt-item-doc-est.registro           = 3.
         tt-item-doc-est.it-codigo          = tt-it-nota-fisc.it-codigo.
         tt-item-doc-est.cod-refer          = "".
         tt-item-doc-est.baixa-ce           = yes .
         tt-item-doc-est.qt-do-forn         = tt-it-nota-fisc.qt-faturada[1].
         tt-item-doc-est.quantidade         = tt-it-nota-fisc.qt-faturada[1].
         tt-item-doc-est.preco-total        = tt-it-nota-fisc.vl-merc-liq /*tt-it-nota-fisc.vl-tot-item*/.
         tt-item-doc-est.cod-depos          = fi-cod-depos.
         tt-item-doc-est.class-fiscal       = tt-it-nota-fisc.class-fiscal.
         tt-item-doc-est.cod-localiz        = "".
         tt-item-doc-est.aliquota-iss       = tt-it-nota-fisc.aliquota-iss.
         tt-item-doc-est.cd-trib-iss        = tt-it-nota-fisc.cd-trib-iss.
         tt-item-doc-est.aliquota-icm       = tt-it-nota-fisc.aliquota-icm.
         tt-item-doc-est.cd-trib-icm        = tt-it-nota-fisc.cd-trib-icm.
         tt-item-doc-est.base-icm           = tt-it-nota-fisc.vl-bicms-it.
         tt-item-doc-est.valor-icm          = tt-it-nota-fisc.vl-icms-it.
         tt-item-doc-est.ind-icm-ret        = NO.
         tt-item-doc-est.narrativa          = "".
         tt-item-doc-est.serie-comp         = tt-it-nota-fisc.serie-docum.
         tt-item-doc-est.nro-comp           = tt-it-nota-fisc.nr-docum.
         tt-item-doc-est.serie-docto        = tt-docum-est.serie-docto.
         tt-item-doc-est.nro-docto          = tt-docum-est.nro-docto.
         tt-item-doc-est.cod-emitente       = tt-docum-est.cod-emitente.
         tt-item-doc-est.nat-operacao       = tt-docum-est.nat-operacao.
         tt-item-doc-est.sequencia          = tt-it-nota-fisc.nr-seq-fat.
         tt-item-doc-est.nr-proc-imp        = "".
         tt-item-doc-est.nr-ato-concessorio = "".
         tt-item-doc-est.cd-trib-ipi        = tt-it-nota-fisc.cd-trib-ipi.
         tt-item-doc-est.base-ipi           = tt-it-nota-fisc.vl-bipi-it.
         tt-item-doc-est.aliquota-ipi       = tt-it-nota-fisc.aliquota-ipi.
         tt-item-doc-est.valor-ipi          = tt-it-nota-fisc.vl-ipi-it.
         tt-item-doc-est.icm-outras         = tt-it-nota-fisc.vl-icmsou-it.
         
         tt-item-doc-est.lote         = "TMP".
         tt-item-doc-est.dt-vali-lote = 12/31/9999.
         
         if tt-item-doc-est.nro-comp <> "" then do:
         
            find first bf-nota-fiscal where bf-nota-fiscal.cod-estabel = fi-estab-ent               and
                                            bf-nota-fiscal.serie       = tt-item-doc-est.serie-comp and
                                            bf-nota-fiscal.nr-nota-fis = tt-item-doc-est.nro-comp   no-lock no-error.
                                         
            if available bf-nota-fiscal then do:
         
               tt-item-doc-est.nat-comp  = bf-nota-fiscal.nat-operacao.
               tt-item-doc-est.data-comp = bf-nota-fiscal.dt-emis-nota.
               
               for each bf-it-nota-fisc of bf-nota-fiscal  no-lock,
                   each bf-fat-ser-lote of bf-it-nota-fisc no-lock:
                   
                  find first tt-fat-ser-lote where tt-fat-ser-lote.cod-estabel = tt-nota-fiscal.cod-estabel and 
                                                   tt-fat-ser-lote.serie       = tt-nota-fiscal.serie       and 
                                                   tt-fat-ser-lote.nr-nota-fis = tt-nota-fiscal.nr-nota-fis and
                                                   tt-fat-ser-lote.nr-seq-fat  = tt-it-nota-fisc.nr-seq-fat and
                                                   tt-fat-ser-lote.nr-serlote  = bf-fat-ser-lote.nr-serlote no-lock no-error.

                  if available tt-fat-ser-lote then do:
                   
                     tt-item-doc-est.seq-comp = bf-fat-ser-lote.nr-seq-fat.
                     
                     leave.
                  
                  end.
               end.
            end.
         end.
      END.

      run rep/reapi190.p (input  table tt-versao-integr-2,
                          input  table tt-docum-est,
                          input  table tt-item-doc-est,
                          input  table tt-dupli-apagar,
                          input  table tt-dupli-imp,
                          input  table tt-unid-neg-nota,
                          output table tt-erro).

      IF NOT CAN-FIND(FIRST tt-erro) THEN DO:

         for each tt-item-doc-est:

             FOR EACH docum-est where docum-est.serie-docto  = tt-item-doc-est.serie-docto  and
                                      docum-est.nro-docto    = tt-item-doc-est.nro-docto    and
                                      docum-est.cod-emitente = tt-item-doc-est.cod-emitente and
                                      docum-est.nat-operacao = tt-item-doc-est.nat-operacao :

                docum-est.nff         = no.
                docum-est.dt-venc-iss = today.
                docum-est.origem      = "".
                docum-est.cotacao-dia = 1.
                
                for each item-doc-est of docum-est:
                
                   item-doc-est.cd-trib-iss    = 1.
                   item-doc-est.usuario        = "".
                   item-doc-est.qt-etiquetas   = 0.
                   item-doc-est.nro-docto-terc = "".
                   item-doc-est.cod-unid-negoc = "".
                   item-doc-est.char-2         = trim(item-doc-est.char-2).
                
                end.
                
             END.

             EMPTY TEMP-TABLE tt-rat-lote.

             FOR EACH rat-lote where rat-lote.serie-docto  = tt-item-doc-est.serie-docto  and
                                     rat-lote.nro-docto    = tt-item-doc-est.nro-docto    and
                                     rat-lote.cod-emitente = tt-item-doc-est.cod-emitente and
                                     rat-lote.nat-operacao = tt-item-doc-est.nat-operacao and
                                     rat-lote.sequencia    = tt-item-doc-est.sequencia    :

                CREATE tt-rat-lote.

                BUFFER-COPY rat-lote TO tt-rat-lote.

                DELETE rat-lote.

             END.

             FOR EACH tt-fat-ser-lote WHERE tt-fat-ser-lote.cod-estabel = tt-nota-fiscal.cod-estabel AND 
                                            tt-fat-ser-lote.serie       = tt-nota-fiscal.serie       AND 
                                            tt-fat-ser-lote.nr-nota-fis = tt-nota-fiscal.nr-nota-fis and
                                            tt-fat-ser-lote.nr-seq-fat  = tt-item-doc-est.sequencia  NO-LOCK:

                IF tt-fat-ser-lote.it-codigo = "" THEN NEXT.
                   
                CREATE rat-lote.

                FIND FIRST tt-rat-lote NO-LOCK NO-ERROR.

                IF AVAILABLE tt-rat-lote THEN DO:
                   
                   BUFFER-COPY tt-rat-lote TO rat-lote.

                END.
                ELSE DO:

                   rat-lote.serie-docto  = tt-item-doc-est.serie-docto.
                   rat-lote.nro-docto    = tt-item-doc-est.nro-docto.
                   rat-lote.cod-emitente = tt-item-doc-est.cod-emitente.
                   rat-lote.nat-operacao = tt-item-doc-est.nat-operacao.
                   rat-lote.sequencia    = tt-item-doc-est.sequencia.
                   rat-lote.it-codigo    = tt-item-doc-est.it-codigo.
                   
                END.

                rat-lote.cod-depos    = fi-cod-depos.
                rat-lote.quantidade   = tt-fat-ser-lote.qt-baixada[1].
                rat-lote.qtd-origin   = tt-fat-ser-lote.qt-baixada[1].
                rat-lote.lote         = tt-fat-ser-lote.nr-serlote.
                
                if tt-fat-ser-lote.dt-vali-lote = ? then
                   rat-lote.dt-vali-lote = 12/31/9999.
                else
                   rat-lote.dt-vali-lote = tt-fat-ser-lote.dt-vali-lote.

             END.
         end.
      END.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE WinExec C-Win 
procedure WinExec external "kernel32.dll":

    def input param prg_name  as char.
    def input param prg_style as short.

end procedure.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
