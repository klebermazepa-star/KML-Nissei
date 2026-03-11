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
{system/Error.i}

/* Parameters Definitions ---                                           */
DEFINE BUFFER fornecedor FOR emsuni.fornecedor.
DEFINE BUFFER portador FOR emsfin.portador.

/* Local Variable Definitions ---                                       */

define new global shared variable v_cod_empres_usuar like emsuni.empresa.cod_empresa no-undo.
define new global shared variable v_cod_estab_usuar  as char  format 'x(03)' no-undo.
define new global shared variable v_cod_usuar_corren as char  no-undo.

define variable v_num_ped_exec     as integer no-undo.
define variable v_num_ped_exec_rpw as integer no-undo.
define variable c-impressora       as char    no-undo.
define variable c-layout           as char    no-undo.
define variable c-ant              as char    no-undo.

define new global shared variable v_rec_fornecedor as recid no-undo.
define new global shared variable v_rec_bord_ap    as recid no-undo.
define new global shared variable v_rec_portador   as recid no-undo.


def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.
def var raw-param          as raw no-undo.

DEFINE TEMP-TABLE tt-param
field v_imp_parametro     as logical    
field empresaIni         as character   
field empresaFim         as character   
field estabelecimentoIni as character   
field estabelecimentoFim as character   
field dataVencimentoIni  as date           
field dataVencimentoFim  as date           
field fornecedorIni      as integer     
field fornecedorFim      as integer     
field matrizIni          as integer     
field matrizFim          as integer     
field borderoIni         as integer     
field borderoFim         as integer     
field portadorIni        as character   
field portadorFim        as character   
field especieIni         as character   
field especieFim         as character   
field titulosVinculados  as integer     
field titulosBordero     as integer     
field notasRelacionadas  as logical    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-440

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 RECT-7 RECT-8 RECT-33 RECT-34 ~
empresaIni empresaFim estabelecimentoIni estabelecimentoFim ~
dataVencimentoIni dataVencimentoFim fornecedorIni btFornecedorIni ~
fornecedorFim btFornecedorFim matrizIni btMatrizIni matrizFim btMatrizFim ~
borderoIni btBorderoIni borderoFim btBorderoFim portadorIni btPortadorIni ~
portadorFim btPortadorFim especieIni especieFim titulosVinculados ~
titulosBordero notasRelacionadas rs-destino rs-execucao bt-arquivo bt-cfimp ~
v_des_arquivo v_imp_param bt-imprime bt-salva 
&Scoped-Define DISPLAYED-OBJECTS empresaIni empresaFim estabelecimentoIni ~
estabelecimentoFim dataVencimentoIni dataVencimentoFim fornecedorIni ~
fornecedorFim matrizIni matrizFim borderoIni borderoFim portadorIni ~
portadorFim especieIni especieFim titulosVinculados titulosBordero ~
notasRelacionadas rs-destino rs-execucao v-linha v_des_arquivo v_imp_param ~
v-coluna 

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

DEFINE BUTTON bt-cfimp 
     IMAGE-UP FILE "image\im-cfprt":U
     LABEL "" 
     SIZE 3.86 BY 1.08 TOOLTIP "Layout ImpressÆo".

DEFINE BUTTON bt-imprime 
     LABEL "Imprime" 
     SIZE 11.14 BY 1 TOOLTIP "Imprimir"
     FONT 1.

DEFINE BUTTON bt-salva 
     LABEL "Fechar" 
     SIZE 11.14 BY 1 TOOLTIP "Fechar/Salvar"
     FONT 1.

DEFINE BUTTON btBorderoFim 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "" 
     SIZE 4 BY .88.

DEFINE BUTTON btBorderoIni 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "" 
     SIZE 4 BY .88.

DEFINE BUTTON btFornecedorFim 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "" 
     SIZE 4 BY .88.

DEFINE BUTTON btFornecedorIni 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "" 
     SIZE 4 BY .88.

DEFINE BUTTON btMatrizFim 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "" 
     SIZE 4 BY .88.

DEFINE BUTTON btMatrizIni 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "" 
     SIZE 4 BY .88.

DEFINE BUTTON btPortadorFim 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "" 
     SIZE 4 BY .88.

DEFINE BUTTON btPortadorIni 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "" 
     SIZE 4 BY .88.

DEFINE VARIABLE borderoFim AS INTEGER FORMAT ">>>>>>9" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 8.29 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE borderoIni AS INTEGER FORMAT ">>>>>>9" INITIAL 0 
     LABEL "Border“" 
     VIEW-AS FILL-IN 
     SIZE 7.72 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE dataVencimentoFim AS DATE FORMAT "99/99/9999" INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 12.57 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE dataVencimentoIni AS DATE FORMAT "99/99/9999" INITIAL 01/01/001 
     LABEL "Data Vencto/Border“" 
     VIEW-AS FILL-IN 
     SIZE 12.57 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE empresaFim AS CHARACTER FORMAT "X(3)" INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5.29 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE empresaIni AS CHARACTER FORMAT "X(3)" 
     LABEL "Empresa" 
     VIEW-AS FILL-IN 
     SIZE 5.72 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE especieFim AS CHARACTER FORMAT "x(3)" INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5.29 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE especieIni AS CHARACTER FORMAT "x(3)" 
     LABEL "Esp‚cie Documento" 
     VIEW-AS FILL-IN 
     SIZE 5.72 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE estabelecimentoFim AS CHARACTER FORMAT "X(3)" INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5.29 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE estabelecimentoIni AS CHARACTER FORMAT "X(3)" 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 5.72 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fornecedorFim AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 999999999 
     VIEW-AS FILL-IN 
     SIZE 13.72 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fornecedorIni AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Fornecedor" 
     VIEW-AS FILL-IN 
     SIZE 13.72 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE matrizFim AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 999999999 
     VIEW-AS FILL-IN 
     SIZE 13.72 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE matrizIni AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Matriz" 
     VIEW-AS FILL-IN 
     SIZE 13.72 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE portadorFim AS CHARACTER FORMAT "X(5)" INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE portadorIni AS CHARACTER FORMAT "X(5)" 
     LABEL "Portador" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-coluna AS INTEGER FORMAT "ZZ9":U INITIAL 132 
     LABEL "Colunas" 
     VIEW-AS FILL-IN 
     SIZE 4.43 BY .79 TOOLTIP "Colunas"
     BGCOLOR 15 FONT 2 NO-UNDO.

DEFINE VARIABLE v-linha AS INTEGER FORMAT "Z9":U INITIAL 63 
     LABEL "Linhas" 
     VIEW-AS FILL-IN 
     SIZE 4.43 BY .79 TOOLTIP "Linhas"
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
     SIZE 35.72 BY .67 TOOLTIP "Destino da ImpressÆo"
     FONT 1 NO-UNDO.

DEFINE VARIABLE rs-execucao AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "On-Line", 1,
"Batch", 2
     SIZE 17 BY .75 TOOLTIP "Execu‡Æo On Line ou Batch"
     FONT 1 NO-UNDO.

DEFINE VARIABLE titulosBordero AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "T¡tulos que estÆo em border“", 1,
"T¡tulos que nÆo estÆo em border“", 2
     SIZE 27 BY 1.21 NO-UNDO.

DEFINE VARIABLE titulosVinculados AS INTEGER INITIAL 3 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "T¡tulos vinculados", 1,
"T¡tulos nÆo vinculados", 2,
"Todos", 3
     SIZE 21 BY 2 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 85 BY 8.63
     BGCOLOR 19 .

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 85 BY 1.54
     BGCOLOR 18 .

DEFINE RECTANGLE RECT-33
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 15 BY 3.

DEFINE RECTANGLE RECT-34
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 85 BY 2.75.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 48 BY 3.08.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 20 BY 3.04.

DEFINE VARIABLE notasRelacionadas AS LOGICAL INITIAL no 
     LABEL "Notas Relacionadas" 
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY .83 NO-UNDO.

DEFINE VARIABLE v_imp_param AS LOGICAL INITIAL no 
     LABEL "Imprime Parƒmetros" 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 TOOLTIP "Imprimir Parƒmetros"
     FONT 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-440
     empresaIni AT ROW 1.75 COL 39.72 RIGHT-ALIGNED WIDGET-ID 18
     empresaFim AT ROW 1.75 COL 52.72 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     estabelecimentoIni AT ROW 2.75 COL 39.72 RIGHT-ALIGNED HELP
          "Numero do documento da Denso" WIDGET-ID 14
     estabelecimentoFim AT ROW 2.75 COL 52.72 COLON-ALIGNED HELP
          "Numero do documento da Denso" NO-LABEL WIDGET-ID 12
     dataVencimentoIni AT ROW 3.75 COL 39.71 RIGHT-ALIGNED
     dataVencimentoFim AT ROW 3.75 COL 52.72 COLON-ALIGNED NO-LABEL
     fornecedorIni AT ROW 4.75 COL 39.72 RIGHT-ALIGNED HELP
          "C¢digo Fornecedor"
     btFornecedorIni AT ROW 4.75 COL 41 WIDGET-ID 64
     fornecedorFim AT ROW 4.75 COL 52.72 COLON-ALIGNED HELP
          "C¢digo Fornecedor" NO-LABEL
     btFornecedorFim AT ROW 4.75 COL 68.72 WIDGET-ID 66
     matrizIni AT ROW 5.75 COL 39.72 RIGHT-ALIGNED HELP
          "C¢digo Fornecedor" WIDGET-ID 56
     btMatrizIni AT ROW 5.75 COL 41 WIDGET-ID 68
     matrizFim AT ROW 5.75 COL 52.72 COLON-ALIGNED HELP
          "C¢digo Fornecedor" NO-LABEL WIDGET-ID 54
     btMatrizFim AT ROW 5.75 COL 68.72 WIDGET-ID 70
     borderoIni AT ROW 6.75 COL 39.72 RIGHT-ALIGNED HELP
          "C¢digo Esp‚cie Documento" WIDGET-ID 62
     btBorderoIni AT ROW 6.75 COL 41 WIDGET-ID 72
     borderoFim AT ROW 6.75 COL 52.72 COLON-ALIGNED HELP
          "C¢digo Esp‚cie Documento" NO-LABEL WIDGET-ID 60
     btBorderoFim AT ROW 6.75 COL 63.29 WIDGET-ID 76
     portadorIni AT ROW 7.75 COL 39.72 RIGHT-ALIGNED
     btPortadorIni AT ROW 7.75 COL 41 WIDGET-ID 74
     portadorFim AT ROW 7.75 COL 52.72 COLON-ALIGNED NO-LABEL
     btPortadorFim AT ROW 7.75 COL 62 WIDGET-ID 78
     especieIni AT ROW 8.75 COL 39.72 RIGHT-ALIGNED HELP
          "C¢digo Esp‚cie Documento" WIDGET-ID 30
     especieFim AT ROW 8.75 COL 52.72 COLON-ALIGNED HELP
          "C¢digo Esp‚cie Documento" NO-LABEL WIDGET-ID 28
     titulosVinculados AT ROW 10.88 COL 39.72 NO-LABEL WIDGET-ID 90
     titulosBordero AT ROW 11.33 COL 8 NO-LABEL WIDGET-ID 84
     notasRelacionadas AT ROW 11.5 COL 64.72 WIDGET-ID 94
     rs-destino AT ROW 14.58 COL 3.29 HELP
          "Destino da ImpressÆo" NO-LABEL
     rs-execucao AT ROW 14.58 COL 52.14 HELP
          "Execu‡Æo On Line ou Batch" NO-LABEL
     v-linha AT ROW 14.58 COL 78.14 COLON-ALIGNED
     bt-arquivo AT ROW 15.38 COL 43.86 HELP
          "Localiza Arquivo"
     bt-cfimp AT ROW 15.38 COL 43.86 HELP
          "Layout ImpressÆo"
     v_des_arquivo AT ROW 15.5 COL 3 HELP
          "Destino" NO-LABEL
     v_imp_param AT ROW 15.58 COL 52.14 HELP
          "Imprimir Parƒmetros"
     v-coluna AT ROW 15.58 COL 78.14 COLON-ALIGNED
     bt-imprime AT ROW 17.38 COL 3
     bt-salva AT ROW 17.38 COL 74.57
     " Execu‡Æo" VIEW-AS TEXT
          SIZE 8 BY .63 AT ROW 13.5 COL 52.14
          FONT 1
     " Parƒmetros" VIEW-AS TEXT
          SIZE 9 BY .54 AT ROW 10.25 COL 3 WIDGET-ID 82
          FONT 1
     "at‚:" VIEW-AS TEXT
          SIZE 3 BY .54 AT ROW 6 COL 51.57 WIDGET-ID 58
     " Dimensäes" VIEW-AS TEXT
          SIZE 8 BY .63 AT ROW 13.5 COL 73.14 WIDGET-ID 6
          FONT 1
     "at‚:" VIEW-AS TEXT
          SIZE 3 BY .54 AT ROW 9 COL 51.57 WIDGET-ID 48
     "at‚:" VIEW-AS TEXT
          SIZE 3 BY .54 AT ROW 7 COL 51.57 WIDGET-ID 50
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY NO-HELP 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 93 BY 19.5
         BGCOLOR 17 FONT 1.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-440
     "at‚:" VIEW-AS TEXT
          SIZE 3 BY .54 AT ROW 3.96 COL 51.57 WIDGET-ID 42
     "at‚:" VIEW-AS TEXT
          SIZE 3 BY .54 AT ROW 1.92 COL 51.57 WIDGET-ID 38
     "at‚:" VIEW-AS TEXT
          SIZE 3 BY .54 AT ROW 2.96 COL 51.57 WIDGET-ID 40
     " Sele‡Æo" VIEW-AS TEXT
          SIZE 7 BY .54 AT ROW 1.08 COL 3.57
          FONT 1
     "at‚:" VIEW-AS TEXT
          SIZE 3 BY .54 AT ROW 8 COL 51.57 WIDGET-ID 52
     " Destino" VIEW-AS TEXT
          SIZE 6 BY .63 AT ROW 13.5 COL 4 WIDGET-ID 2
          FONT 1
     "at‚:" VIEW-AS TEXT
          SIZE 3 BY .54 AT ROW 5 COL 51.57 WIDGET-ID 44
     RECT-1 AT ROW 1.38 COL 2
     RECT-2 AT ROW 17.08 COL 2
     RECT-7 AT ROW 13.83 COL 2
     RECT-8 AT ROW 13.83 COL 51
     RECT-33 AT ROW 13.83 COL 72 WIDGET-ID 4
     RECT-34 AT ROW 10.5 COL 2 WIDGET-ID 80
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY NO-HELP 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 93 BY 19.5
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
         TITLE              = "T¡tulos em Aberto"
         COLUMN             = 17.43
         ROW                = 9.04
         HEIGHT             = 17.63
         WIDTH              = 86.72
         MAX-HEIGHT         = 29
         MAX-WIDTH          = 146.29
         VIRTUAL-HEIGHT     = 29
         VIRTUAL-WIDTH      = 146.29
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         FONT               = 1
         MESSAGE-AREA       = yes
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-440
   FRAME-NAME L-To-R                                                    */
/* SETTINGS FOR FILL-IN borderoIni IN FRAME f-440
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN dataVencimentoIni IN FRAME f-440
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN empresaIni IN FRAME f-440
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN especieIni IN FRAME f-440
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN estabelecimentoIni IN FRAME f-440
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN fornecedorIni IN FRAME f-440
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN matrizIni IN FRAME f-440
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN portadorIni IN FRAME f-440
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN v-coluna IN FRAME f-440
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-linha IN FRAME f-440
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v_des_arquivo IN FRAME f-440
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* T¡tulos em Aberto */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* T¡tulos em Aberto */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME borderoFim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL borderoFim C-Win
ON F5 OF borderoFim IN FRAME f-440
DO:
    run prgfin/apb/apb710ka.p.

    find first bord_ap 
        where recid(bord_ap) = v_rec_bord_ap 
        no-lock no-error.

    if avail bord_ap then do
        with frame {&frame-name}:
        assign 
            borderoFim:screen-value = string(bord_ap.num_bord_ap)
            portadorFim:screen-value = string(bord_ap.cod_portador).

        apply "entry" to borderoFim.
    end. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL borderoFim C-Win
ON MOUSE-SELECT-DBLCLICK OF borderoFim IN FRAME f-440
DO:
    apply 'f5':u to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME borderoIni
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL borderoIni C-Win
ON F5 OF borderoIni IN FRAME f-440 /* Border“ */
DO:
    run prgfin/apb/apb710ka.p.

    find first bord_ap 
        where recid(bord_ap) = v_rec_bord_ap 
        no-lock no-error.

    if avail bord_ap then do
        with frame {&frame-name}:
        assign 
            borderoIni:screen-value = string(bord_ap.num_bord_ap)
            portadorIni:screen-value = string(bord_ap.cod_portador).

        apply "entry" to borderoIni.
    end. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL borderoIni C-Win
ON MOUSE-SELECT-DBLCLICK OF borderoIni IN FRAME f-440 /* Border“ */
DO:
    apply 'f5':u to self.
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


&Scoped-define SELF-NAME bt-cfimp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cfimp C-Win
ON CHOOSE OF bt-cfimp IN FRAME f-440
DO:
    DEFINE VARIABLE p_nom_filename AS CHARACTER  NO-UNDO.

    assign c-ant = v_des_arquivo:screen-value in frame f-440.

/*     run prgtec/btb/btb036nb.p (output c-impressora, output c-layout). */
    run prgtec/btb/btb036zb.p (INPUT-OUTPUT c-impressora,
                               INPUT-OUTPUT c-layout,
                               INPUT-OUTPUT p_nom_filename).

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
ON CHOOSE OF bt-imprime IN FRAME f-440 /* Imprime */
DO:
    run print.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-salva
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-salva C-Win
ON CHOOSE OF bt-salva IN FRAME f-440 /* Fechar */
DO:
/*   run pi_vld_param. */

  /*run pi_salva_param.*/

  apply "close" to this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btBorderoFim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btBorderoFim C-Win
ON CHOOSE OF btBorderoFim IN FRAME f-440
DO:
    apply 'f5':u to borderoFim.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btBorderoIni
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btBorderoIni C-Win
ON CHOOSE OF btBorderoIni IN FRAME f-440
DO:
    apply 'f5':u to borderoIni.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFornecedorFim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFornecedorFim C-Win
ON CHOOSE OF btFornecedorFim IN FRAME f-440
DO:
    apply 'f5':u to fornecedorFim.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFornecedorIni
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFornecedorIni C-Win
ON CHOOSE OF btFornecedorIni IN FRAME f-440
DO:
    apply 'f5':u to fornecedorIni.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btMatrizFim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btMatrizFim C-Win
ON CHOOSE OF btMatrizFim IN FRAME f-440
DO:
    apply 'f5':u to matrizFim.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btMatrizIni
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btMatrizIni C-Win
ON CHOOSE OF btMatrizIni IN FRAME f-440
DO:
    apply 'f5':u to matrizIni.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btPortadorFim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btPortadorFim C-Win
ON CHOOSE OF btPortadorFim IN FRAME f-440
DO:
    apply 'f5':u to portadorIni.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btPortadorIni
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btPortadorIni C-Win
ON CHOOSE OF btPortadorIni IN FRAME f-440
DO:
    apply 'f5':u to portadorIni.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fornecedorFim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fornecedorFim C-Win
ON F5 OF fornecedorFim IN FRAME f-440
DO:
    run prgint/ufn/ufn003nb.p (v_cod_empres_usuar).

    find first fornecedor 
        where recid(fornecedor) = v_rec_fornecedor 
        no-lock no-error.

    if avail fornecedor then do
        with frame {&frame-name}:
        assign 
            fornecedorFim:screen-value = string(fornecedor.cdn_fornecedor).

        apply "entry" to fornecedorFim.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fornecedorFim C-Win
ON MOUSE-SELECT-DBLCLICK OF fornecedorFim IN FRAME f-440
DO:
    apply 'f5':u to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fornecedorIni
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fornecedorIni C-Win
ON F5 OF fornecedorIni IN FRAME f-440 /* Fornecedor */
DO:
    run prgint/ufn/ufn003nb.p (v_cod_empres_usuar).

    find first fornecedor 
        where recid(fornecedor) = v_rec_fornecedor 
        no-lock no-error.

    if avail fornecedor then do
        with frame {&frame-name}:
        assign 
            fornecedorIni:screen-value = string(fornecedor.cdn_fornecedor).

        apply "entry" to fornecedorIni.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fornecedorIni C-Win
ON MOUSE-SELECT-DBLCLICK OF fornecedorIni IN FRAME f-440 /* Fornecedor */
DO:
    apply 'f5':u to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME matrizFim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL matrizFim C-Win
ON F5 OF matrizFim IN FRAME f-440
DO:
    run prgint/ufn/ufn003nb.p (v_cod_empres_usuar).

    find first fornecedor 
        where recid(fornecedor) = v_rec_fornecedor 
        no-lock no-error.

    if avail fornecedor then do
        with frame {&frame-name}:
        assign 
            matrizFim:screen-value = string(fornecedor.cdn_fornecedor).

        apply "entry" to matrizFim.
    end. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL matrizFim C-Win
ON MOUSE-SELECT-DBLCLICK OF matrizFim IN FRAME f-440
DO:
    apply 'f5':u to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME matrizIni
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL matrizIni C-Win
ON F5 OF matrizIni IN FRAME f-440 /* Matriz */
DO:
    run prgint/ufn/ufn003nb.p (v_cod_empres_usuar).

    find first fornecedor 
        where recid(fornecedor) = v_rec_fornecedor 
        no-lock no-error.

    if avail fornecedor then do
        with frame {&frame-name}:
        assign 
            matrizIni:screen-value = string(fornecedor.cdn_fornecedor).

        apply "entry" to matrizIni.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL matrizIni C-Win
ON MOUSE-SELECT-DBLCLICK OF matrizIni IN FRAME f-440 /* Matriz */
DO:
    apply 'f5':u to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME portadorFim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL portadorFim C-Win
ON F5 OF portadorFim IN FRAME f-440
DO:
    run prgint/ufn/ufn008na.p (v_cod_estab_usuar).

    find first portador 
        where recid(portador) = v_rec_portador 
        no-lock no-error.

    if avail portador then do
        with frame {&frame-name}:
        assign 
            portadorFim:screen-value = string(portador.cod_portador).

        apply "entry" to portadorFim.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL portadorFim C-Win
ON MOUSE-SELECT-DBLCLICK OF portadorFim IN FRAME f-440
DO:
    apply 'f5':u to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME portadorIni
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL portadorIni C-Win
ON F5 OF portadorIni IN FRAME f-440 /* Portador */
DO:  
    run prgint/ufn/ufn008na.p (v_cod_estab_usuar).

    find first portador 
        where recid(portador) = v_rec_portador 
        no-lock no-error.

    if avail portador then do
        with frame {&frame-name}:
        assign 
            portadorIni:screen-value = string(portador.cod_portador).

        apply "entry" to portadorIni.
    end. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL portadorIni C-Win
ON MOUSE-SELECT-DBLCLICK OF portadorIni IN FRAME f-440 /* Portador */
DO:
    apply 'f5':u to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-destino
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-destino C-Win
ON VALUE-CHANGED OF rs-destino IN FRAME f-440
DO:
  IF RS-EXECUCAO:ENABLE("Batch") THEN.

  if input frame f-440 rs-destino = 1 then do:
      assign bt-arquivo:visible  in frame f-440 = no
             bt-cfimp:visible    in frame f-440 = yes
             v_des_arquivo:visible   in frame f-440 = yes
             v_des_arquivo:sensitive in frame f-440 = no.
      if c-impressora = "" then do:
          find first emsfnd.imprsor_usuar no-lock
              where imprsor_usuar.cod_usuario = v_cod_usuar_corren
              use-index imprsrsr_id no-error.
          if avail imprsor_usuar then do:
              find first emsfnd.layout_impres no-lock
                  where layout_impres.nom_impressora  = emsfnd.imprsor_usuar.nom_impressora no-error.
              if avail layout_impres then
                  assign v_des_arquivo:screen-value in frame f-440 = emsfnd.imprsor_usuar.nom_impressora + ":" + emsfnd.layout_impres.cod_layout_impres
                         c-impressora                          = emsfnd.imprsor_usuar.nom_impressora
                         c-layout                              = emsfnd.layout_impres.cod_layout_impres.
          end.
      end.
      else
          assign v_des_arquivo:screen-value in frame f-440 = c-impressora + ":" + c-layout.

  end.

  if input frame f-440 rs-destino = 2 then do:
      assign bt-arquivo:visible  in frame f-440 = yes
             bt-cfimp:visible    in frame f-440 = no
             v_des_arquivo:visible   in frame f-440 = yes
             v_des_arquivo:sensitive in frame f-440 = yes.
      if input frame f-440 rs-execucao = 1 then
          assign v_des_arquivo:screen-value in frame f-440 = session:temp-directory + "apb0055de.lst"
                 c-impressora                          = ""
                 c-layout                              = "".
      else
          assign v_des_arquivo:screen-value in frame f-440 = "apb0055de.lst"
                 c-impressora                          = ""
                 c-layout                              = "".


  end.

  if input frame f-440 rs-destino = 3 then DO:
      assign bt-arquivo:visible  in frame f-440 = no
             bt-cfimp:visible    in frame f-440 = no
             v_des_arquivo:visible   in frame f-440 = no.

         if rs-execucao:DISABLE("Batch") THEN.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-execucao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-execucao C-Win
ON VALUE-CHANGED OF rs-execucao IN FRAME f-440
DO:
  if input frame f-440 rs-execucao = 2 then do:
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

  assign
      C-Win:message-area-font = 1.

  run enable_UI.

  run getParameters.

end.

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
  DISPLAY empresaIni empresaFim estabelecimentoIni estabelecimentoFim 
          dataVencimentoIni dataVencimentoFim fornecedorIni fornecedorFim 
          matrizIni matrizFim borderoIni borderoFim portadorIni portadorFim 
          especieIni especieFim titulosVinculados titulosBordero 
          notasRelacionadas rs-destino rs-execucao v-linha v_des_arquivo 
          v_imp_param v-coluna 
      WITH FRAME f-440 IN WINDOW C-Win.
  ENABLE RECT-1 RECT-2 RECT-7 RECT-8 RECT-33 RECT-34 empresaIni empresaFim 
         estabelecimentoIni estabelecimentoFim dataVencimentoIni 
         dataVencimentoFim fornecedorIni btFornecedorIni fornecedorFim 
         btFornecedorFim matrizIni btMatrizIni matrizFim btMatrizFim borderoIni 
         btBorderoIni borderoFim btBorderoFim portadorIni btPortadorIni 
         portadorFim btPortadorFim especieIni especieFim titulosVinculados 
         titulosBordero notasRelacionadas rs-destino rs-execucao bt-arquivo 
         bt-cfimp v_des_arquivo v_imp_param bt-imprime bt-salva 
      WITH FRAME f-440 IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-440}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getParameters C-Win 
PROCEDURE getParameters :
/*-----------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    define variable v_contador as integer   no-undo.

    find first emsfnd.dwb_set_list_param
         where emsfnd.dwb_set_list_param.cod_dwb_program = "rpt_titulo_abertos_apb_nissei"
           and emsfnd.dwb_set_list_param.cod_dwb_user    = v_cod_usuar_corren
        exclusive-lock no-error.

    do with frame {&frame-name}:
        if avail emsfnd.dwb_set_list_param then
            assign 
                v_imp_param:screen-value        = string(emsfnd.dwb_set_list_param.log_dwb_print_parameters )      
                empresaIni:screen-value         = entry(1,  emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))  
                empresaFim:screen-value         = entry(2,  emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))  
                estabelecimentoIni:screen-value = entry(3,  emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)) 
                estabelecimentoFim:screen-value = entry(4,  emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)) 
                dataVencimentoIni:screen-value  = entry(5,  emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)) 
                dataVencimentoFim:screen-value  = entry(6,  emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)) 
                fornecedorIni:screen-value      = entry(7,  emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)) 
                fornecedorFim:screen-value      = entry(8,  emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)) 
                matrizIni:screen-value          = entry(9,  emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)) 
                matrizFim:screen-value          = entry(10, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)) 
                borderoIni:screen-value         = entry(11, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                borderoFim:screen-value         = entry(12, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                portadorIni:screen-value        = entry(13, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                portadorFim:screen-value        = entry(14, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                especieIni:screen-value         = entry(15, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                especieFim:screen-value         = entry(16, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                titulosVinculados:screen-value  = entry(17, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)) 
                titulosBordero:screen-value     = entry(18, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                notasRelacionadas:screen-value  = entry(19, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                no-error.
        else
            assign        
                empresaFim:screen-value         = 'ZZZ'
                estabelecimentoFim:screen-value = 'ZZZ'
                dataVencimentoIni:screen-value  = string(today)
                dataVencimentoFim:screen-value  = string(today)
                fornecedorFim:screen-value      = '999999999'
                matrizFim:screen-value          = '999999999'
                borderoFim:screen-value         = '9999999'
                portadorFim:screen-value        = 'ZZZZZ'
                especieFim:screen-value         = 'ZZZ'
                titulosBordero:screen-value     = '1'
                titulosVinculados:screen-value  = '3'
                notasRelacionadas:screen-value  = "no".
    end.


    apply "value-changed" to rs-destino in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print C-Win 
PROCEDURE print :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    do {&try}:

        run validate.
    
        run saveParameters.

        raw-transfer tt-param to raw-param.
        
        if rs-execucao:screen-value in frame f-440 = '2' then do:

            run btb/btb911zb.p (input "rpt_titulo_abertos_apb_nissei-RP",
                                input "cstp/csap001rp.p",
                                input "2.00.00.000",
                                input 97,
                                input v_des_arquivo:screen-value IN FRAME f-440,
                                input 2,
                                input raw-param,
                                input table tt-raw-digita,
                                output v_num_ped_exec_rpw).

            if v_num_ped_exec_rpw <> 0 then do:
                run showMessage('show', 3556,
                        substitute ('&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9',
                        v_num_ped_exec_rpw)).
        
                find current dwb_set_list_param no-lock no-error.
            end.
        end.
        ELSE DO:

          run cstp/csap001rp.p(INPUT raw-param, INPUT TABLE tt-raw-digita).

        END.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveParameters C-Win 
PROCEDURE saveParameters :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    if rs-destino = 2 and rs-execucao = 2 then do:
        do while index(v_des_arquivo,'~/') <> 0:
            assign v_des_arquivo = substring(v_des_arquivo,(index(v_des_arquivo,'~/' ) + 1)).
        end.
    end.

    do with frame {&frame-name}
        transaction:

        find first emsfnd.dwb_set_list_param
            where emsfnd.dwb_set_list_param.cod_dwb_program = 'rpt_titulo_abertos_apb_nissei'
              and emsfnd.dwb_set_list_param.cod_dwb_user    = v_cod_usuar_corren
            exclusive-lock no-error.

        if  not avail emsfnd.dwb_set_list_param THEN DO: 

            create emsfnd.dwb_set_list_param.
        END.
            

        IF AVAIL emsfnd.dwb_set_list_param THEN DO:
        
            assign emsfnd.dwb_set_list_param.cod_dwb_program          = 'rpt_titulo_abertos_apb_nissei'
                   emsfnd.dwb_set_list_param.cod_dwb_user             = v_cod_usuar_corren
                   emsfnd.dwb_set_list_param.cod_dwb_file             = v_des_arquivo:input-value
                   emsfnd.dwb_set_list_param.nom_dwb_printer          = c-impressora
                   emsfnd.dwb_set_list_param.cod_dwb_print_layout     = c-layout
                   emsfnd.dwb_set_list_param.qtd_dwb_line             = 66
                   emsfnd.dwb_set_list_param.log_dwb_print_parameters = v_imp_param:input-value
                   emsfnd.dwb_set_list_param.cod_dwb_parameters       = empresaIni:screen-value         + chr(10) +
                                                                        empresaFim:screen-value         + chr(10) +
                                                                        estabelecimentoIni:screen-value + chr(10) +
                                                                        estabelecimentoFim:screen-value + chr(10) +
                                                                        dataVencimentoIni:screen-value  + chr(10) +
                                                                        dataVencimentoFim:screen-value  + chr(10) +
                                                                        fornecedorIni:screen-value      + chr(10) +
                                                                        fornecedorFim:screen-value      + chr(10) +
                                                                        matrizIni:screen-value          + chr(10) +
                                                                        matrizFim:screen-value          + chr(10) +
                                                                        borderoIni:screen-value         + chr(10) +
                                                                        borderoFim:screen-value         + chr(10) +
                                                                        portadorIni:screen-value        + chr(10) +
                                                                        portadorFim:screen-value        + chr(10) +
                                                                        especieIni:screen-value         + chr(10) +
                                                                        especieFim:screen-value         + chr(10) +
                                                                        titulosVinculados:screen-value  + chr(10) +
                                                                        titulosBordero:screen-value     + chr(10) +
                                                                        notasRelacionadas:screen-value  + chr(10)
                   emsfnd.dwb_set_list_param.cod_dwb_output           = if rs-destino:input-value = 1 then 
                                                                            'Impressora'
                                                                        else 
                                                                            if rs-destino:input-value = 2 then 
                                                                                'Arquivo'
                                                                            else 
                                                                                if rs-destino:input-value = 3 then 
                                                                                    'Terminal'
                                                                                else 
                                                                                    'arquivo'.
    
        END.
        CREATE tt-param.
        ASSIGN tt-param.v_imp_parametro     = logical(v_imp_param:INPUT-VALUE)
               tt-param.empresaIni          = empresaIni:screen-value        
               tt-param.empresaFim          = empresaFim:screen-value        
               tt-param.estabelecimentoIni  = estabelecimentoIni:screen-value
               tt-param.estabelecimentoFim  = estabelecimentoFim:screen-value
               tt-param.dataVencimentoIni   = date(dataVencimentoIni:screen-value )
               tt-param.dataVencimentoFim   = date(dataVencimentoFim:screen-value )
               tt-param.fornecedorIni       = integer(fornecedorIni:screen-value)     
               tt-param.fornecedorFim       = integer(fornecedorFim:screen-value )    
               tt-param.matrizIni           = integer(matrizIni:screen-value  )       
               tt-param.matrizFim           = integer(matrizFim:screen-value  )       
               tt-param.borderoIni          = integer(borderoIni:screen-value )       
               tt-param.borderoFim          = integer(borderoFim:screen-value )       
               tt-param.portadorIni         = portadorIni:screen-value       
               tt-param.portadorFim         = portadorFim:screen-value       
               tt-param.especieIni          = especieIni:screen-value        
               tt-param.especieFim          = especieFim:screen-value        
               tt-param.titulosVinculados   = integer(titulosVinculados:screen-value )
               tt-param.titulosBordero      = integer(titulosBordero:SCREEN-VALUE )    
               tt-param.notasRelacionadas   = logical(notasRelacionadas:screen-value) .

    end.

    find first emsfnd.dwb_set_list_param
        where emsfnd.dwb_set_list_param.cod_dwb_program = 'rpt_titulo_abertos_apb_nissei'
          and emsfnd.dwb_set_list_param.cod_dwb_user    = v_cod_usuar_corren
        no-lock no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE showMessage C-Win 
PROCEDURE showMessage :
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate C-Win 
PROCEDURE validate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    do with frame {&frame-name}:

        if rs-destino:input-value = 2 then do:

            for each emsfnd.ped_exec 
                where emsfnd.ped_exec.cod_prog_dtsul = 'rpt_titulo_relac_apb_denso'
                  and emsfnd.ped_exec.ind_sit_ped    = 'NÆo executado' 
                no-lock:
        
               find emsfnd.ped_exec_param of ped_exec no-lock no-error.
               if avail ped_exec_param then do:

                  if ped_exec_param.cod_dwb_file = v_des_arquivo:input-value then do:

                    run utp/message.p('Nome do Arquivo encontrado em outro pedido,Deseja continuar?',
                            'Foi encontrado um pedido com o mesmo nome a ser criado.' 
                            + chr(10) 
                            + 'Arquivo....: ' 
                            + ped_exec_param.cod_dwb_file             
                            + chr(10) 
                            + 'Usuario....: ' 
                            + ped_exec.cod_usuar                      
                            + chr(10) 
                            + 'Num Pedido.: ' 
                            + string(ped_exec_param.num_ped_exec)).

                    apply 'entry' to v_des_arquivo.
                    leave.
                  end.
               end.
            end.
        end.

        if empresaFim:screen-value < empresaIni:screen-value then do:
            message 'Empresa inicial ‚ maior que o final!' 
                view-as alert-box error.
            apply 'entry' to empresaIni.
            return error.
        end.
        if estabelecimentoFim:screen-value < estabelecimentoIni:screen-value then do:
            message 'Estabelecimento inicial ‚ maior que o final!' 
                view-as alert-box error.
            apply 'entry' to estabelecimentoIni.
            return error.
        end.
        
        if date(dataVencimentoFim:screen-value) < date(dataVencimentoIni:screen-value) then do:
            message 'Data de vencimento inicial ‚ maior que o final!' 
                view-as alert-box error.
            apply 'entry' to dataVencimentoIni.
            return error.
        end.
        if integer(fornecedorFim:screen-value) < integer(fornecedorIni:screen-value) then do:
            message 'Fornecedor inicial ‚ maior que o final!' 
                view-as alert-box error.
            apply 'entry' to fornecedorIni.
            return error.
        end.
        if matrizFim:screen-value < matrizini:screen-value then do:
            message 'Matriz inicial ‚ maior que o final!' 
                view-as alert-box error.
            apply 'entry' to matrizini.
            return error.
        end.
        if integer(borderoFim:screen-value) < integer(borderoIni:screen-value) then do:
            message 'Border“ inicial ‚ maior que o final!' 
                view-as alert-box error.
            apply 'entry' to borderoIni.
            return error.
        end.
        if portadorFim:screen-value < portadorIni:screen-value then do:
            message 'Portador inicial ‚ maior que o final!' 
                view-as alert-box error.
            apply 'entry' to portadorIni.
            return error.
        end.
        if especieFim:screen-value < especieIni:screen-value then do:
            message 'Esp‚cie inicial ‚ maior que o final!' 
                view-as alert-box error.
            apply 'entry' to especieIni.
            return error.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

