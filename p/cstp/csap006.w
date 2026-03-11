&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsbas           PROGRESS
*/
&Scoped-define WINDOW-NAME hC-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS hC-Win 
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

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEF VAR c-ant AS CHAR NO-UNDO.

{cstp/i-var-imp.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tit_ap

/* Definitions for FRAME DEFAULT-FRAME                                  */
&Scoped-define QUERY-STRING-DEFAULT-FRAME FOR EACH tit_ap SHARE-LOCK
&Scoped-define OPEN-QUERY-DEFAULT-FRAME OPEN QUERY DEFAULT-FRAME FOR EACH tit_ap SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-DEFAULT-FRAME tit_ap
&Scoped-define FIRST-TABLE-IN-QUERY-DEFAULT-FRAME tit_ap


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-10 RECT-11 RECT-3 RECT-5 ~
i-fornec-ini i-fornec-fim rs-execucao v_imp_param c-tit-ini c-tit-fim ~
c-parcela-ini c-parcela-fim da-vencto-ini da-vencto-fim bt-ok v-cod-bar ~
fi-lin-dig rs-destino bt-imprimir bt-fechar 
&Scoped-Define DISPLAYED-OBJECTS i-fornec-ini i-fornec-fim rs-execucao ~
v_imp_param c-tit-ini c-tit-fim i-linhas c-parcela-ini c-parcela-fim ~
i-dim-colunas da-vencto-ini da-vencto-fim v-cod-bar fi-lin-dig rs-destino 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR hC-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-arquivo 
     IMAGE-UP FILE "image/im-sea1.bmp":U
     LABEL "Button 1" 
     SIZE 3.86 BY 1.08.

DEFINE BUTTON bt-cfimp 
     IMAGE-UP FILE "image\im-cfprt":U
     LABEL "" 
     SIZE 3.86 BY 1.08 TOOLTIP "Layout Impress∆o".

DEFINE BUTTON bt-fechar 
     LABEL "&Fechar" 
     SIZE 11.14 BY 1.

DEFINE BUTTON bt-imprimir 
     LABEL "&Imprimir" 
     SIZE 11.14 BY 1.

DEFINE BUTTON bt-ok 
     IMAGE-UP FILE "image/im-chck1.bmp":U
     LABEL "Ok" 
     SIZE 4 BY 1.

DEFINE VARIABLE c-parcela-fim AS CHARACTER FORMAT "x(02)" INITIAL "ZZ" 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE c-parcela-ini AS CHARACTER FORMAT "x(02)" 
     LABEL "Parcela" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE c-tit-fim AS CHARACTER FORMAT "x(10)" INITIAL "ZZZZZZZZZZ" 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 8.29 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE c-tit-ini AS CHARACTER FORMAT "x(10)" 
     LABEL "T°tulo" 
     VIEW-AS FILL-IN 
     SIZE 8.29 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE da-vencto-fim AS DATE FORMAT "99/99/9999" 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE da-vencto-ini AS DATE FORMAT "99/99/9999" 
     LABEL "Data Vencimento" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-lin-dig AS CHARACTER FORMAT "XXXXX.XXXXX XXXXX.XXXXXX XXXXX.XXXXXX X XXXXXXXXXXXXXX" 
     LABEL "Linha digit†vel" 
     VIEW-AS FILL-IN 
     SIZE 44 BY .88
     BGCOLOR 15 .

DEFINE VARIABLE i-dim-colunas AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 132 
     LABEL "Colunas" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE i-fornec-fim AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 999999999 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE i-fornec-ini AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Fornecedor" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE i-linhas AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 63 
     LABEL "Linhas" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE v-cod-bar AS CHARACTER FORMAT "x(44)" 
     LABEL "C¢digo de Barras" 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88
     BGCOLOR 15 .

DEFINE VARIABLE v_des_arquivo AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 53 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE rs-destino AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Terminal", 3,
"Arquivo", 2,
"Impressora", 1
     SIZE 57 BY 1 NO-UNDO.

DEFINE VARIABLE rs-execucao AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "On-line", "1"
     SIZE 12 BY .75 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 40 BY 4.75.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 59 BY 1.5
     BGCOLOR 18 .

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 59 BY 2.75.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 18 BY 4.75.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 59 BY 2.75.

DEFINE VARIABLE v_imp_param AS LOGICAL INITIAL no 
     LABEL "Imprimir ParÉmetros" 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY DEFAULT-FRAME FOR 
      tit_ap SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     i-fornec-ini AT ROW 1.75 COL 13 COLON-ALIGNED
     i-fornec-fim AT ROW 1.75 COL 28 COLON-ALIGNED
     rs-execucao AT ROW 1.75 COL 44 NO-LABEL
     v_imp_param AT ROW 2.5 COL 44
     c-tit-ini AT ROW 2.75 COL 13 COLON-ALIGNED
     c-tit-fim AT ROW 2.75 COL 28 COLON-ALIGNED
     i-linhas AT ROW 3.5 COL 53 COLON-ALIGNED
     c-parcela-ini AT ROW 3.75 COL 13 COLON-ALIGNED
     c-parcela-fim AT ROW 3.75 COL 28 COLON-ALIGNED
     i-dim-colunas AT ROW 4.5 COL 53 COLON-ALIGNED
     da-vencto-ini AT ROW 4.75 COL 13 COLON-ALIGNED
     da-vencto-fim AT ROW 4.75 COL 28 COLON-ALIGNED
     bt-ok AT ROW 6.88 COL 55.43
     v-cod-bar AT ROW 7 COL 2.57
     fi-lin-dig AT ROW 8 COL 4.43
     rs-destino AT ROW 10.08 COL 3 NO-LABEL
     bt-cfimp AT ROW 11.13 COL 56.29 HELP
          "Layout Impress∆o"
     bt-arquivo AT ROW 11.13 COL 56.29
     v_des_arquivo AT ROW 11.25 COL 3 NO-LABEL
     bt-imprimir AT ROW 13 COL 2.86
     bt-fechar AT ROW 13.04 COL 49
     "C¢d Barras" VIEW-AS TEXT
          SIZE 8 BY .54 AT ROW 6.25 COL 4
     "Execuá∆o" VIEW-AS TEXT
          SIZE 8 BY .54 AT ROW 1 COL 44
     "Seleá∆o" VIEW-AS TEXT
          SIZE 6 BY .67 AT ROW 1 COL 4
     "Destino" VIEW-AS TEXT
          SIZE 6 BY .54 AT ROW 9.5 COL 4
     RECT-1 AT ROW 1.25 COL 2
     RECT-10 AT ROW 12.75 COL 2
     RECT-11 AT ROW 6.5 COL 2
     RECT-3 AT ROW 1.25 COL 43
     RECT-5 AT ROW 9.75 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 61 BY 13.33
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
  CREATE WINDOW hC-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Recibo de Pagamento Escritural"
         HEIGHT             = 13.33
         WIDTH              = 61
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
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW hC-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
/* SETTINGS FOR BUTTON bt-arquivo IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
ASSIGN 
       bt-arquivo:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

/* SETTINGS FOR BUTTON bt-cfimp IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
ASSIGN 
       bt-cfimp:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

/* SETTINGS FOR FILL-IN fi-lin-dig IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN i-dim-colunas IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-linhas IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-cod-bar IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v_des_arquivo IN FRAME DEFAULT-FRAME
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN 
       v_des_arquivo:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(hC-Win)
THEN hC-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME DEFAULT-FRAME
/* Query rebuild information for FRAME DEFAULT-FRAME
     _TblList          = "emsbas.tit_ap"
     _Query            is OPENED
*/  /* FRAME DEFAULT-FRAME */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME hC-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL hC-Win hC-Win
ON END-ERROR OF hC-Win /* Recibo de Pagamento Escritural */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL hC-Win hC-Win
ON WINDOW-CLOSE OF hC-Win /* Recibo de Pagamento Escritural */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-arquivo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-arquivo hC-Win
ON CHOOSE OF bt-arquivo IN FRAME DEFAULT-FRAME /* Button 1 */
DO:
  def var c-arq-conv  as char no-undo.
    def var l-ok        as logical init no.

    assign c-arq-conv = replace(input frame {&frame-name} v_des_arquivo, "/", "\").
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
        display v_des_arquivo with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cfimp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cfimp hC-Win
ON CHOOSE OF bt-cfimp IN FRAME DEFAULT-FRAME
DO:
  assign c-ant = v_des_arquivo:screen-value in frame {&frame-name}.

  run prgtec/btb/btb036nb.p (output c-impressora, output c-layout).

  if v_des_arquivo <> ":" then
    assign v_des_arquivo = c-impressora + ":" + c-layout.
  else
    assign v_des_arquivo = c-ant.

  disp v_des_arquivo with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-fechar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-fechar hC-Win
ON CHOOSE OF bt-fechar IN FRAME DEFAULT-FRAME /* Fechar */
DO:
  APPLY "close" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-imprimir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-imprimir hC-Win
ON CHOOSE OF bt-imprimir IN FRAME DEFAULT-FRAME /* Imprimir */
DO:
/*     FIND FIRST sc-param NO-LOCK NO-ERROR. */
    def var v_cod_key_value as CHAR format "x(8)" no-undo.
    run pi_salva_param.

    /* execuá∆o em RPW */

    if session:set-wait-state("general") then. /* mostra na tela a amputela */
    RUN cstp\csap006rp.p.
    if session:set-wait-state("") then.
    IF rs-destino = 3 THEN DO:
        get-key-value section 'EMS' key 'Show-Report-Program' value v_cod_key_value.
        if  v_cod_key_value = ""
        or  v_cod_key_value = ?
        then do:
            assign v_cod_key_value = 'notepad.exe'.
            put-key-value section 'EMS' key 'Show-Report-Program' value v_cod_key_value no-error.
        end.
/*         FOR FIRST sc-param FIELDS (caminho). */
/*         END.                                 */
        
        os-command silent value(v_cod_key_value + chr(32) + session:temp-directory + 'csap006rp' + ".lst").

    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok hC-Win
ON CHOOSE OF bt-ok IN FRAME DEFAULT-FRAME /* Ok */
DO:
    DEFINE VARIABLE c-linha-digi  AS CHARACTER  NO-UNDO.
    define variable v-datavenctit as date       no-undo.

    ASSIGN c-linha-digi = replace(replace(input frame {&frame-name} fi-lin-dig:screen-value, " ", ""), ".", "").
    if c-linha-digi="" then
        apply "leave":U to v-cod-bar.

    IF c-linha-digi = "" THEN DO:
        MESSAGE "Linha digit†vel n∆o informada." SKIP(1)
                "ê necess†rio informar ao menos a linha" SKIP
                "digit†vel para pesquisar um t°tulo."
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    if input frame {&frame-name} v-cod-bar  <> "" or
       input frame {&frame-name} fi-lin-dig <> "" then do:
            
        assign v-datavenctit = 10/07/97 + int(substring(input frame {&frame-name} fi-lin-dig, 34, 4)).

        assign da-vencto-ini:screen-value in frame {&frame-name} = string(v-datavenctit)
               da-vencto-fim:screen-value in frame {&frame-name} = string(v-datavenctit).
    end.
    apply "entry":U to bt-imprimir.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-parcela-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-parcela-ini hC-Win
ON LEAVE OF c-parcela-ini IN FRAME DEFAULT-FRAME /* Parcela */
DO:
    DO WITH FRAME {&FRAME-NAME}:
        IF c-parcela-ini:SCREEN-VALUE <> ""
        AND c-parcela-ini:SCREEN-VALUE <> ? THEN
            ASSIGN c-parcela-fim:SCREEN-VALUE = c-parcela-ini:SCREEN-VALUE.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-tit-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-tit-ini hC-Win
ON LEAVE OF c-tit-ini IN FRAME DEFAULT-FRAME /* T°tulo */
DO:
    DO WITH FRAME {&FRAME-NAME}:
        IF c-tit-ini:SCREEN-VALUE <> ""
            AND c-tit-ini:SCREEN-VALUE <> ? THEN
        ASSIGN c-tit-fim:SCREEN-VALUE = c-tit-ini:SCREEN-VALUE.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME da-vencto-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL da-vencto-ini hC-Win
ON LEAVE OF da-vencto-ini IN FRAME DEFAULT-FRAME /* Data Vencimento */
DO:
    DO WITH FRAME {&FRAME-NAME}:
        IF da-vencto-ini:SCREEN-VALUE <> STRING(TODAY, "99/99/9999") THEN
            ASSIGN da-vencto-fim:SCREEN-VALUE = da-vencto-ini:SCREEN-VALUE.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-lin-dig
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-lin-dig hC-Win
ON RETURN OF fi-lin-dig IN FRAME DEFAULT-FRAME /* Linha digit†vel */
DO:
  apply "choose":U to bt-ok in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-fornec-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-fornec-ini hC-Win
ON LEAVE OF i-fornec-ini IN FRAME DEFAULT-FRAME /* Fornecedor */
DO:
    DO WITH FRAME {&FRAME-NAME}:
        IF i-fornec-ini:SCREEN-VALUE <> "0" THEN
        ASSIGN i-fornec-fim:SCREEN-VALUE = i-fornec-ini:SCREEN-VALUE.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-destino
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-destino hC-Win
ON VALUE-CHANGED OF rs-destino IN FRAME DEFAULT-FRAME
DO:
/*     FIND FIRST sc-param NO-LOCK NO-ERROR. */
    if input frame {&FRAME-NAME} rs-destino = 1 then do:
       assign bt-arquivo:visible  in frame {&FRAME-NAME} = no
              bt-cfimp:visible    in frame {&FRAME-NAME} = yes
              bt-cfimp:SENSITIVE    in frame {&FRAME-NAME} = YES
              v_des_arquivo:visible   in frame {&FRAME-NAME} = yes
              v_des_arquivo:sensitive in frame {&FRAME-NAME} = no.
       if c-impressora = "" then do:
           find first emsfnd.imprsor_usuar no-lock
               where imprsor_usuar.cod_usuario = v_cod_usuar_corren
               use-index imprsrsr_id no-error.
           if avail imprsor_usuar then do:
               find first emsfnd.layout_impres no-lock
                   where layout_impres.nom_impressora  = emsfnd.imprsor_usuar.nom_impressora no-error.
               if avail layout_impres then
                   assign v_des_arquivo:screen-value in frame {&FRAME-NAME} = emsfnd.imprsor_usuar.nom_impressora + ":" + emsfnd.layout_impres.cod_layout_impres
                          c-impressora                          = emsfnd.imprsor_usuar.nom_impressora
                          c-layout                              = emsfnd.layout_impres.cod_layout_impres.
           end.
       end.
       else
           assign v_des_arquivo:screen-value in frame {&FRAME-NAME} = c-impressora + ":" + c-layout.

   end.

   if input frame {&FRAME-NAME} rs-destino = 2 then do:
       assign bt-arquivo:visible  in frame {&FRAME-NAME} = no
              bt-arquivo:SENSITIVE  in frame {&FRAME-NAME} = no
              bt-cfimp:visible    in frame {&FRAME-NAME} = no
              v_des_arquivo:visible   in frame {&FRAME-NAME} = yes             
              v_des_arquivo:sensitive in frame {&FRAME-NAME} = no.
       assign v_des_arquivo:screen-value in frame {&FRAME-NAME} = 
            session:temp-directory + 'csap006rp' + ".lst"
              c-impressora                          = ""
              c-layout                              = "".
   end.
   
   if input frame {&FRAME-NAME} rs-destino = 3 then DO:
       assign bt-arquivo:visible  in frame {&FRAME-NAME} = no
              bt-cfimp:visible    in frame {&FRAME-NAME} = no
              v_des_arquivo:visible   in frame {&FRAME-NAME} = no.
   END.  

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-cod-bar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-cod-bar hC-Win
ON LEAVE OF v-cod-bar IN FRAME DEFAULT-FRAME /* C¢digo de Barras */
DO:
    def var c-campo1 as char no-undo.
    def var c-campo2 as char no-undo.
    def var c-campo3 as char no-undo.
    def var c-campo4 as char no-undo.
    def var c-campo5 as char no-undo.

    if length(v-cod-bar:screen-value in frame {&frame-name}) > 35 then do:
        run pi-calc-linha-digitavel (input v-cod-bar:screen-value in frame {&frame-name},
                                     output c-campo1,
                                     output c-campo2,
                                     output c-campo3,
                                     output c-campo4,
                                     output c-campo5).

        assign fi-lin-dig:screen-value in frame {&frame-name} = c-campo1 + c-campo2 + c-campo3 + c-campo4 + c-campo5.
/*         assign fi-lin-dig1:screen-value in frame {&frame-name} = c-campo1  */
/*                fi-lin-dig2:screen-value in frame {&frame-name} = c-campo2  */
/*                fi-lin-dig3:screen-value in frame {&frame-name} = c-campo3  */
/*                fi-lin-dig4:screen-value in frame {&frame-name} = c-campo4  */
/*                fi-lin-dig5:screen-value in frame {&frame-name} = c-campo5. */
    end.
    else
        assign fi-lin-dig:screen-value in frame {&frame-name} = "".
/*         assign fi-lin-dig1:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig2:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig3:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig4:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig5:screen-value in frame {&frame-name} = "". */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-cod-bar hC-Win
ON RETURN OF v-cod-bar IN FRAME DEFAULT-FRAME /* C¢digo de Barras */
DO:
    apply "leave":u to self.
    apply "choose":u to bt-ok in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK hC-Win 


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
  ASSIGN da-vencto-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "01/01/2000"
         da-vencto-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "31/12/9999".
/*   FIND FIRST sc-param NO-LOCK NO-ERROR. */
/*   IF AVAIL sc-param THEN                */
      assign 
          v_des_arquivo:screen-value in frame {&FRAME-NAME} = session:temp-directory + 'csap006rp' + ".lst".
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI hC-Win  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(hC-Win)
  THEN DELETE WIDGET hC-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI hC-Win  _DEFAULT-ENABLE
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

  {&OPEN-QUERY-DEFAULT-FRAME}
  GET FIRST DEFAULT-FRAME.
  DISPLAY i-fornec-ini i-fornec-fim rs-execucao v_imp_param c-tit-ini c-tit-fim 
          i-linhas c-parcela-ini c-parcela-fim i-dim-colunas da-vencto-ini 
          da-vencto-fim v-cod-bar fi-lin-dig rs-destino 
      WITH FRAME DEFAULT-FRAME IN WINDOW hC-Win.
  ENABLE RECT-1 RECT-10 RECT-11 RECT-3 RECT-5 i-fornec-ini i-fornec-fim 
         rs-execucao v_imp_param c-tit-ini c-tit-fim c-parcela-ini 
         c-parcela-fim da-vencto-ini da-vencto-fim bt-ok v-cod-bar fi-lin-dig 
         rs-destino bt-imprimir bt-fechar 
      WITH FRAME DEFAULT-FRAME IN WINDOW hC-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW hC-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-calc-linha-digitavel hC-Win 
PROCEDURE pi-calc-linha-digitavel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter c-codigo-barras as char no-undo.
    define output parameter c-campo-1       as char no-undo.
    define output parameter c-campo-2       as char no-undo.
    define output parameter c-campo-3       as char no-undo.
    define output parameter c-campo-4       as char no-undo.
    define output parameter c-campo-5       as char no-undo.

    define variable c-digito    as char     no-undo.
    define variable i-pos       as integer  no-undo.
    define variable i-tot       as integer  no-undo.
    define variable i-mult      as integer  no-undo.
    define variable i-cont      as integer  no-undo.
    define variable i-aux       as integer  no-undo.

    assign c-campo-1 = substr(c-codigo-barras, 01, 04) + substr(c-codigo-barras, 20, 5)
           c-campo-2 = substr(c-codigo-barras, 25, 10)
           c-campo-3 = substr(c-codigo-barras, 35, 10)
           c-campo-4 = substr(c-codigo-barras, 05, 01)
           c-campo-5 = substr(c-codigo-barras, 06, 14).

    /* digito do campo 1 */
    assign i-pos  = 10
           i-tot  = 0.

    do i-cont = 1 to 9:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 1.
       else
           assign i-mult = 2.

       assign i-aux = int(substr(c-campo-1,i-pos,1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux,"99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.
    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito = "0".
    else
        assign c-digito = string(i-aux,"9").

    assign c-campo-1 = c-campo-1 + c-digito.

    /* digito do campo 2 */
    assign i-pos  = 11
           i-tot  = 0.

    do i-cont = 1 to 10:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 2.
       else
           assign i-mult = 1.

       assign i-aux = int(substr(c-campo-2,i-pos,1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux, "99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.
    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito =  "0".
    else 
        assign c-digito = string(i-aux, "9").

    assign c-campo-2 = c-campo-2 + c-digito.

    /* digito do campo 3 */
    assign i-pos  = 11
           i-tot  = 0.

    do i-cont = 1 to 10:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 2.
       else
           assign i-mult = 1.

       assign i-aux = int(substr(c-campo-3, i-pos, 1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux, "99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.

    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito = "0".
    else
        assign c-digito = string(i-aux,"9").

    assign c-campo-3 = c-campo-3 + c-digito.

/*     /* montagem da linha digitavel */                                    */
/*     assign c-linha-digitavel = string(c-campo-1,"XXXXX.XXXXX")  + "  " + */
/*                                string(c-campo-2,"XXXXX.XXXXXX") + "  " + */
/*                                string(c-campo-3,"XXXXX.XXXXXX") + "  " + */
/*                                c-campo-4                        + "  " + */
/*                                c-campo-5.                                */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_salva_param hC-Win 
PROCEDURE pi_salva_param :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable c-linha-digi as char no-undo.
    
    assign c-linha-digi = replace(replace(input frame {&frame-name} fi-lin-dig:screen-value, " ", ""), ".", "").
    
    assign 
        input frame {&FRAME-NAME} rs-destino
        input frame {&FRAME-NAME} v_des_arquivo.
    
    assign 
        v_cod_programa         = "csap006"
        v_cod_dwb_file         = input frame {&FRAME-NAME} v_des_arquivo
        v_imp_param            = LOGICAL(v_imp_param:SCREEN-VALUE IN FRAME {&FRAME-NAME})
        v_log_dwb_param        = input frame {&FRAME-NAME} v_imp_param
        v_cod_parameters       = string(i-fornec-ini:SCREEN-VALUE IN FRAME {&frame-name}) + chr(10) +                          
                                 string(i-fornec-fim:SCREEN-VALUE IN FRAME {&frame-name}) + CHR(10) +
                                 c-tit-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} + CHR(10) +    
                                 c-tit-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} + CHR(10) +    
                                 c-parcela-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} + CHR(10) +    
                                 c-parcela-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} + CHR(10) +    
                                 string(da-vencto-ini:SCREEN-VALUE IN FRAME {&frame-name}) + chr(10) +                         
                                 string(da-vencto-fim:SCREEN-VALUE IN FRAME {&frame-name}) + CHR(10) +
                                 c-linha-digi.
        v_cod_dwb_output       = if rs-destino = 1 then "Impressora" else
                                 if rs-destino = 2 then "Arquivo" else
                                 if rs-destino = 3 then "Terminal" else "Arquivo".

    run prgtec/btb/btb906za.p.
    
    if rs-destino = 2 and rs-execucao = "2" then do: /* arquivo ou batch */
        do while index(v_des_arquivo,"~/") <> 0: 
            assign v_des_arquivo = substring(v_des_arquivo,(index(v_des_arquivo,"~/" ) + 1)).
        end. 
    end.
    
    /* Recuperar parÉmetros da £ltima execuá∆o */
    
    do transaction:    
        find emsfnd.dwb_set_list_param exclusive-lock
            where emsfnd.dwb_set_list_param.cod_dwb_program = v_cod_programa
            and   emsfnd.dwb_set_list_param.cod_dwb_user    = v_cod_usuar_corren no-error.
            
        if  not avail emsfnd.dwb_set_list_param then
            create emsfnd.dwb_set_list_param.

        assign emsfnd.dwb_set_list_param.cod_dwb_program          = v_cod_programa
               emsfnd.dwb_set_list_param.cod_dwb_user             = v_cod_usuar_corren
               emsfnd.dwb_set_list_param.cod_dwb_file             = session:temp-directory + 'csap006rp' + ".lst"
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

