&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i Ni0302 2.00.00.001}

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i Ni0302 MFP}
&ENDIF

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
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessadores do Template de Relat¢rio                            */
/* Obs: Retirar o valor do preprocessador para as p†ginas que n∆o existirem  */

&GLOBAL-DEFINE PGSEL f-pg-sel
&GLOBAL-DEFINE PGCLA 
&GLOBAL-DEFINE PGPAR f-pg-par
&GLOBAL-DEFINE PGDIG 
&GLOBAL-DEFINE PGIMP f-pg-imp

/* Include para n∆o habilitar PDF 
{cdp/cd9992.i}
           */

/* Parameters Definitions ---                                           */

/* Temporary Table Definitions ---                                      */

define temp-table tt-param no-undo
    field destino           as integer
    field arquivo           as char
    field usuario           as char format "x(12)"
    field data-exec         as date
    field hora-exec         as integer
    field cod-estabel       like apur-imposto.cod-estabel
    field cod-estabel-fim   like apur-imposto.cod-estabel
    field dt-emissao-ini    like apur-imposto.dt-apur-ini
    field dt-emissao-fim    like apur-imposto.dt-apur-fim
    field estado-ini        like estabelec.estado
    field estado-fim        like estabelec.estado
    field termo-ab          like termo.te-codigo
    field termo-en          like termo.te-codigo
    field moeda             like moeda.mo-codigo
    field tp-emissao        as integer
    field l-separadores     as logical
    field l-resumo-aliq     as logical
    field l-incentivado     as logical
    field l-icms-st         as LOGICAL
    FIELD l-considera-cfops AS LOGICAL
    field imp-cab           AS CHARACTER.

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id is primary unique
        ordem.

DEF TEMP-TABLE tt-estab 
FIELD cod-estabel LIKE estabelec.cod-estabel.

define buffer b-tt-digita for tt-digita.
define buffer b-contr-livros for contr-livros.

/* Transfer Definitions */

def var raw-param        as raw no-undo.

def temp-table tt-raw-digita no-undo
   field raw-digita      as raw.
                    
/* Local Variable Definitions ---                                       */

def var l-ok               as logical            no-undo.
def var c-arq-digita       as char               no-undo.
def var c-terminal         as char               no-undo.
def var dt-aux             as date               no-undo.
def var c-est-ant          as char format "x(3)" no-undo.
def var i-livro            as INT                no-undo.

def var l-tem-consolidado  as log     no-undo.

assign l-tem-consolidado = can-find(funcao where funcao.cd-funcao = "spp-of-consolida" and funcao.ativo).
{include/i-epc200.i1}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-relat
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-pg-imp

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rs-destino c-arquivo bt-config-impr ~
bt-arquivo rs-execucao RECT-7 RECT-9 
&Scoped-Define DISPLAYED-OBJECTS rs-destino c-arquivo rs-execucao 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-arquivo 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-config-impr 
     IMAGE-UP FILE "image\im-cfprt":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE VARIABLE c-arquivo AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 256
     SIZE 40 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE text-destino AS CHARACTER FORMAT "X(256)":U INITIAL " Destino" 
      VIEW-AS TEXT 
     SIZE 8.57 BY .63 NO-UNDO.

DEFINE VARIABLE text-modo AS CHARACTER FORMAT "X(256)":U INITIAL "Execuá∆o" 
      VIEW-AS TEXT 
     SIZE 10.86 BY .63 NO-UNDO.

DEFINE VARIABLE rs-destino AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Impressora", 1,
"Arquivo", 2,
"Terminal", 3
     SIZE 44 BY 1.08 NO-UNDO.

DEFINE VARIABLE rs-execucao AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "On-Line", 1,
"Batch", 2
     SIZE 27.72 BY .92 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.29 BY 2.92.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.29 BY 1.71.

DEFINE VARIABLE i-moeda AS INTEGER FORMAT ">9" INITIAL 0 
     LABEL "Moeda":R7 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88.

DEFINE VARIABLE i-terab AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Termo de Abertura" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE i-teren AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Termo de Encerramento" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE text-previa AS CHARACTER FORMAT "X(256)":U INITIAL "Tipo emiss∆o" 
      VIEW-AS TEXT 
     SIZE 13.14 BY .67 NO-UNDO.

DEFINE VARIABLE c-imp-cab AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Folha", 1,
"P†gina", 2
     SIZE 11 BY 1.63 NO-UNDO.

DEFINE VARIABLE rs-previa AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "PrÇvia", 1,
"Emiss∆o", 2
     SIZE 12 BY 1.54 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 36 BY 2.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 75.29 BY 3.38.

DEFINE RECTANGLE RECT-17
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 75.29 BY 5.

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 38 BY 2.

DEFINE VARIABLE l-considera-cfops AS LOGICAL INITIAL no 
     LABEL "Considera CFOPs Serviáos" 
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE l-icms-st AS LOGICAL INITIAL yes 
     LABEL "Considera o ICMS - ST no Valor Cont†bil" 
     VIEW-AS TOGGLE-BOX
     SIZE 44.43 BY .83 NO-UNDO.

DEFINE VARIABLE l-incentivado AS LOGICAL INITIAL no 
     LABEL "Produtos Incentivados" 
     VIEW-AS TOGGLE-BOX
     SIZE 24.57 BY .83 NO-UNDO.

DEFINE VARIABLE l-resumo-aliq AS LOGICAL INITIAL no 
     LABEL "Resumo por Al°quotas ?" 
     VIEW-AS TOGGLE-BOX
     SIZE 26.86 BY .83 NO-UNDO.

DEFINE VARIABLE l-separadores AS LOGICAL INITIAL no 
     LABEL "Imprime Separadores ?" 
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.

DEFINE VARIABLE c-cod-estabel LIKE estabelec.cod-estabel
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE c-cod-estabel-fim AS CHARACTER FORMAT "X(03)":U INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE c-estado-fim AS CHARACTER FORMAT "X(02)":U INITIAL "ZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE c-estado-ini AS CHARACTER FORMAT "x(02)" 
     LABEL "Estado do Estab" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE dt-emissao-fim AS DATE FORMAT "99/99/9999" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88.

DEFINE VARIABLE dt-emissao-ini AS DATE FORMAT "99/99/9999":U 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-3
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-4
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE RECTANGLE RECT-18
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 76.43 BY 10.38.

DEFINE BUTTON bt-ajuda 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-cancelar AUTO-END-KEY 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-executar 
     LABEL "Executar" 
     SIZE 10 BY 1.

DEFINE IMAGE im-pg-imp
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE IMAGE im-pg-par
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE IMAGE im-pg-sel
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 79 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 0    
     SIZE 78.72 BY .13
     BGCOLOR 7 .

DEFINE RECTANGLE rt-folder
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL   
     SIZE 79 BY 11.38
     FGCOLOR 0 .

DEFINE RECTANGLE rt-folder-left
     EDGE-PIXELS 0    
     SIZE .43 BY 11.21
     BGCOLOR 15 .

DEFINE RECTANGLE rt-folder-right
     EDGE-PIXELS 0    
     SIZE .43 BY 11.17
     BGCOLOR 7 .

DEFINE RECTANGLE rt-folder-top
     EDGE-PIXELS 0    
     SIZE 78.72 BY .13
     BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-pg-imp
     rs-destino AT ROW 2.38 COL 3.29 HELP
          "Destino de Impress∆o do Relat¢rio" NO-LABEL
     c-arquivo AT ROW 3.63 COL 3.29 HELP
          "Nome do arquivo de destino do relat¢rio" NO-LABEL
     bt-config-impr AT ROW 3.58 COL 43.29 HELP
          "Configuraá∆o da impressora"
     bt-arquivo AT ROW 3.58 COL 43.29 HELP
          "Escolha do nome do arquivo"
     rs-execucao AT ROW 5.75 COL 3 HELP
          "Modo de Execuá∆o" NO-LABEL
     text-destino AT ROW 1.63 COL 3.86 NO-LABEL
     text-modo AT ROW 5 COL 1.29 COLON-ALIGNED NO-LABEL
     RECT-7 AT ROW 1.92 COL 2.14
     RECT-9 AT ROW 5.29 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 3
         SIZE 73.72 BY 10.

DEFINE FRAME f-relat
     bt-executar AT ROW 14.42 COL 3 HELP
          "Dispara a execuá∆o do relat¢rio"
     bt-cancelar AT ROW 14.42 COL 14 HELP
          "Cancelar"
     bt-ajuda AT ROW 14.42 COL 70 HELP
          "Ajuda"
     rt-folder-left AT ROW 2.54 COL 2.14
     rt-folder-top AT ROW 2.54 COL 2.14
     rt-folder-right AT ROW 2.67 COL 80.43
     rt-folder AT ROW 2.5 COL 2
     RECT-6 AT ROW 13.75 COL 2.14
     RECT-1 AT ROW 14.17 COL 2
     im-pg-imp AT ROW 1.5 COL 33.57
     im-pg-par AT ROW 1.5 COL 17.86
     im-pg-sel AT ROW 1.5 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 81 BY 14.83
         DEFAULT-BUTTON bt-executar.

DEFINE FRAME f-pg-par
     i-terab AT ROW 1.25 COL 32 COLON-ALIGNED
     i-teren AT ROW 2.25 COL 32 COLON-ALIGNED
     i-moeda AT ROW 3.25 COL 32 COLON-ALIGNED
     l-separadores AT ROW 4.71 COL 25
     l-resumo-aliq AT ROW 5.63 COL 25
     l-incentivado AT ROW 6.54 COL 25
     l-icms-st AT ROW 7.5 COL 25
     l-considera-cfops AT ROW 8.46 COL 25
     rs-previa AT ROW 10.25 COL 5.43 NO-LABEL
     c-imp-cab AT ROW 10.25 COL 42.14 NO-LABEL
     text-previa AT ROW 9.58 COL 3 COLON-ALIGNED NO-LABEL
     "Impress∆o Cabeáalho" VIEW-AS TEXT
          SIZE 21.57 BY .67 AT ROW 9.58 COL 42.29
     RECT-10 AT ROW 10 COL 2
     RECT-16 AT ROW 1 COL 2
     RECT-17 AT ROW 4.5 COL 2.14
     RECT-19 AT ROW 10 COL 39
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 2.75
         SIZE 76.86 BY 11.04.

DEFINE FRAME f-pg-sel
     c-cod-estabel AT ROW 2 COL 23 COLON-ALIGNED HELP
          "C¢digo do estabelecimento"
          LABEL "Estabelecimento"
     c-cod-estabel-fim AT ROW 2 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     dt-emissao-ini AT ROW 3 COL 23 COLON-ALIGNED
     dt-emissao-fim AT ROW 3 COL 46 COLON-ALIGNED NO-LABEL
     c-estado-ini AT ROW 4 COL 23 COLON-ALIGNED WIDGET-ID 12
     c-estado-fim AT ROW 4 COL 46 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     IMAGE-1 AT ROW 3 COL 37.29
     IMAGE-2 AT ROW 3 COL 43.29
     RECT-18 AT ROW 1.25 COL 1.43
     IMAGE-3 AT ROW 2.04 COL 37.29 WIDGET-ID 4
     IMAGE-4 AT ROW 2.04 COL 43.29 WIDGET-ID 6
     IMAGE-5 AT ROW 4.04 COL 37.29 WIDGET-ID 8
     IMAGE-6 AT ROW 4.04 COL 43.29 WIDGET-ID 10
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 2.85
         SIZE 76.86 BY 10.62.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-relat
   Allow: Basic,Browse,DB-Fields,Window,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Registro de Apuraá∆o do ICMS"
         HEIGHT             = 14.83
         WIDTH              = 81.14
         MAX-HEIGHT         = 22.33
         MAX-WIDTH          = 114.29
         VIRTUAL-HEIGHT     = 22.33
         VIRTUAL-WIDTH      = 114.29
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB C-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/w-relat.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-pg-imp
   FRAME-NAME Custom                                                    */
/* SETTINGS FOR FILL-IN text-destino IN FRAME f-pg-imp
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN 
       text-destino:PRIVATE-DATA IN FRAME f-pg-imp     = 
                "Destino".

/* SETTINGS FOR FILL-IN text-modo IN FRAME f-pg-imp
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       text-modo:PRIVATE-DATA IN FRAME f-pg-imp     = 
                "Execuá∆o".

/* SETTINGS FOR FRAME f-pg-par
                                                                        */
/* SETTINGS FOR TOGGLE-BOX l-icms-st IN FRAME f-pg-par
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX l-incentivado IN FRAME f-pg-par
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN text-previa IN FRAME f-pg-par
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       text-previa:PRIVATE-DATA IN FRAME f-pg-par     = 
                "Tipo emiss∆o".

/* SETTINGS FOR FRAME f-pg-sel
                                                                        */
/* SETTINGS FOR FILL-IN c-cod-estabel IN FRAME f-pg-sel
   LIKE = mgadm.estabelec.cod-estabel EXP-LABEL EXP-SIZE                */
/* SETTINGS FOR FRAME f-relat
                                                                        */
/* SETTINGS FOR RECTANGLE RECT-1 IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-6 IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder-left IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder-right IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder-top IN FRAME f-relat
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-pg-imp
/* Query rebuild information for FRAME f-pg-imp
     _Query            is NOT OPENED
*/  /* FRAME f-pg-imp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-pg-sel
/* Query rebuild information for FRAME f-pg-sel
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME f-pg-sel */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Registro de Apuraá∆o do ICMS */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
   RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Registro de Apuraá∆o do ICMS */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-ajuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ajuda C-Win
ON CHOOSE OF bt-ajuda IN FRAME f-relat /* Ajuda */
DO:
   {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME bt-arquivo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-arquivo C-Win
ON CHOOSE OF bt-arquivo IN FRAME f-pg-imp
DO:
    {include/i-rparq.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar C-Win
ON CHOOSE OF bt-cancelar IN FRAME f-relat /* Cancelar */
DO:
   apply "close" to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME bt-config-impr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-config-impr C-Win
ON CHOOSE OF bt-config-impr IN FRAME f-pg-imp
DO:
   {include/i-rpimp.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-executar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-executar C-Win
ON CHOOSE OF bt-executar IN FRAME f-relat /* Executar */
DO:
   do  on error undo, return no-apply:
       run pi-executar.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-sel
&Scoped-define SELF-NAME c-cod-estabel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estabel C-Win
ON LEAVE OF c-cod-estabel IN FRAME f-pg-sel /* Estabelecimento */
DO:
    IF l-incentivado:CHECKED IN FRAME f-pg-par THEN DO:
        ASSIGN i-livro = 10.
    END.
    ELSE DO:
        ASSIGN i-livro = 4.
    END.

    if  c-est-ant <> input frame {&frame-name} c-cod-estabel then do:
        assign c-est-ant = input frame {&frame-name} c-cod-estabel.
               l-incentivado:checked in frame f-pg-par = NO.
        
        FIND FIRST estabelec where
                   estabelec.cod-estabel = input frame f-pg-sel c-cod-estabel NO-LOCK NO-ERROR.
        IF NOT AVAIL estabelec AND
          (l-tem-consolidado and 
          NOT CAN-FIND(tab-ocor WHERE 
                       tab-ocor.cod-ocor    = 300 and 
                       tab-ocor.log-1       = YES AND
                &IF "{&mguni_version}" >= "2.071" &THEN
                SUBSTR(tab-ocor.char-1,1,5) = input frame f-pg-sel c-cod-estabel)) 
                &ELSE
                SUBSTR(tab-ocor.char-1,1,3) = input frame f-pg-sel c-cod-estabel)) 
                &ENDIF
                then do: 

            run utp/ut-msgs.p (input "show", input 537, input " ").
            apply 'mouse-select-click' to im-pg-sel in frame f-relat.                   
            apply 'entry' to c-cod-estabel in frame f-pg-sel.                   
            return no-apply.
        end.
        else
            run pi-atualiza-data-tela.
       
        if  avail estabelec 
        and estabelec.estado = "PE" THEN DO:
            assign l-incentivado:sensitive in frame f-pg-par = yes
                   l-icms-st:sensitive in frame f-pg-par     = yes
                   l-icms-st:checked in frame f-pg-par       = YES
                   l-incentivado                             = no
                   l-icms-st                                 = yes.
        END.
        ELSE DO: 
            assign l-incentivado:sensitive in frame f-pg-par = no
                   l-icms-st:sensitive in frame f-pg-par     = no
                   l-incentivado:checked in frame f-pg-par   = no
                   l-incentivado                             = ?
                   l-icms-st                                 = ?.                  
        END.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME dt-emissao-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL dt-emissao-ini C-Win
ON LEAVE OF dt-emissao-ini IN FRAME f-pg-sel
DO:
    find last contr-livros
        where contr-livros.cod-estabel = input frame f-pg-sel c-cod-estabel
        and   contr-livros.livro       = i-livro
        and   contr-livros.dt-ult-emi <= input frame f-pg-sel dt-emissao-ini 
        no-lock no-error.

    /*if month(input frame f-pg-sel dt-emissao-ini) > 11 then
         assign dt-emissao-fim = date(month(input frame f-pg-sel dt-emissao-ini),31,
                                     (year(input frame f-pg-sel dt-emissao-ini))).
      else
         assign dt-emissao-fim = date((month(input frame f-pg-sel dt-emissao-ini) + 1), 01,
                                       year(input frame f-pg-sel dt-emissao-ini))
                dt-emissao-fim = dt-emissao-fim - 1. 

      disp dt-emissao-fim with frame f-pg-sel. 

      assign dt-emissao-fim:screen-value in frame f-pg-sel = string(dt-emissao-fim).*/

      RETURN 'OK':U.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-par
&Scoped-define SELF-NAME i-moeda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-moeda C-Win
ON F5 OF i-moeda IN FRAME f-pg-par /* Moeda */
DO:
  assign l-implanta = yes.
  {include/zoomvar.i &prog-zoom = "unzoom/z01un005.w"
                  &campo = i-moeda
                  &campozoom = mo-codigo}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-moeda C-Win
ON LEAVE OF i-moeda IN FRAME f-pg-par /* Moeda */
DO:

  for first moeda fields()
      where moeda.mo-codigo = input frame f-pg-par i-moeda no-lock.
  end.
  
  if  not avail moeda then do:
      {utp/ut-table.i mguni moeda 1}
      run utp/ut-msgs.p (input "show",
                         input 2,
                         input return-value).
      apply 'mouse-select-click' to im-pg-par in frame f-relat.
      apply "entry" to i-moeda in frame f-pg-par.                   
      return no-apply.
  end.                      
  else
      if  input frame f-pg-par i-moeda = 0 then 
          assign l-separadores:sensitive in frame f-pg-par = yes.
      else   
          assign l-separadores:sensitive in frame f-pg-par = no
                 l-separadores:checked   in frame f-pg-par = no.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-moeda C-Win
ON MOUSE-SELECT-DBLCLICK OF i-moeda IN FRAME f-pg-par /* Moeda */
DO:
  apply "F5" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-terab
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-terab C-Win
ON F5 OF i-terab IN FRAME f-pg-par /* Termo de Abertura */
DO:
    {include/zoomvar.i &prog-zoom = "adzoom/z01ad255.w"
                       &campo     = i-terab
                       &campozoom = te-codigo}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-terab C-Win
ON MOUSE-SELECT-DBLCLICK OF i-terab IN FRAME f-pg-par /* Termo de Abertura */
DO:
  apply 'f5' to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-teren
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-teren C-Win
ON F5 OF i-teren IN FRAME f-pg-par /* Termo de Encerramento */
DO:
    {include/zoomvar.i &prog-zoom = "adzoom/z01ad255.w"
                       &campo     = i-teren
                       &campozoom = te-codigo}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-teren C-Win
ON MOUSE-SELECT-DBLCLICK OF i-teren IN FRAME f-pg-par /* Termo de Encerramento */
DO:
  apply 'f5' to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME im-pg-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-imp C-Win
ON MOUSE-SELECT-CLICK OF im-pg-imp IN FRAME f-relat
DO:
    run pi-troca-pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-par C-Win
ON MOUSE-SELECT-CLICK OF im-pg-par IN FRAME f-relat
DO:
    run pi-troca-pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-sel C-Win
ON MOUSE-SELECT-CLICK OF im-pg-sel IN FRAME f-relat
DO:
    run pi-troca-pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-par
&Scoped-define SELF-NAME l-incentivado
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-incentivado C-Win
ON VALUE-CHANGED OF l-incentivado IN FRAME f-pg-par /* Produtos Incentivados */
DO:
    IF l-incentivado:CHECKED IN FRAME f-pg-par THEN DO:
        ASSIGN i-livro = 10.
    END.
    ELSE DO:
        ASSIGN i-livro = 4.
    END.
   
    find last contr-livros where
              contr-livros.cod-estabel = input frame f-pg-sel c-cod-estabel and
              contr-livros.livro = i-livro no-lock NO-ERROR.

    run pi-atualiza-data-tela.

    if  not avail contr-livros then do:
        run utp/ut-msgs.p (input "show",
                           input IF l-incentivado:CHECKED IN FRAME f-pg-par THEN 
                                     28522
                                 ELSE 
                                     5363,
                           input " ").
                              
        return no-apply.       
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME rs-destino
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-destino C-Win
ON VALUE-CHANGED OF rs-destino IN FRAME f-pg-imp
DO:
do  with frame f-pg-imp:
    case self:screen-value:
        when "1" then do:
            assign c-arquivo:sensitive    = no
                   bt-arquivo:visible     = no
                   bt-config-impr:visible = yes.
        end.
        when "2" then do:
            assign c-arquivo:sensitive     = yes
                   bt-arquivo:visible      = yes
                   bt-config-impr:visible  = no.
        end.
        when "3" then do:
            assign c-arquivo:sensitive     = no
                   bt-arquivo:visible      = no
                   bt-config-impr:visible  = no.
        end.
    end case.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-execucao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-execucao C-Win
ON VALUE-CHANGED OF rs-execucao IN FRAME f-pg-imp
DO:
   {include/i-rprse.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.
       
if i-moeda:load-mouse-pointer ("IMAGE/LUPA.CUR") in frame f-pg-par then.
       

{utp/ut9000.i "Ni0302" "2.00.00.001"}
{utp/ut-field.i mgdis apur-imposto cod-estabel 1}
assign c-cod-estabel:label in frame f-pg-sel = return-value.

{utp/ut-field.i mgdis apur-imposto dt-apur-ini 1}
assign dt-emissao-ini:label in frame f-pg-sel = return-value.

{utp/ut-liter.i Considera_CFOPs_Serviáos * R}
ASSIGN l-considera-cfops:LABEL IN FRAME f-pg-par = TRIM(RETURN-VALUE).

{utp/ut-liter.i Doctos_Serv_Tributados_Pelo_ISSQN_-_Ajuste_SINIEF}
ASSIGN l-considera-cfops:HELP IN FRAME f-pg-par = TRIM(RETURN-VALUE) + " 3/2004":U.

/* inicializaá‰es do template de relat¢rio */
{include/i-rpini.i}

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

{include/i-rplbl.i}

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    RUN enable_UI.
  
    if i-terab:load-mouse-pointer ("IMAGE/LUPA.CUR") in frame f-pg-par then.
    if i-teren:load-mouse-pointer ("IMAGE/LUPA.CUR") in frame f-pg-par then.  
    
    find first param-of no-lock no-error.
    if avail param-of then
       assign c-cod-estabel:screen-value in frame f-pg-sel = param-of.cod-estabel.

    /* dt inicio = ultima data contr-livros + 1 */
    run pi-atualiza-data-tela.

    IF l-tem-consolidado THEN
       ASSIGN c-cod-estabel:LABEL IN FRAME f-pg-sel = 'Grupo/Estab'.

    {include/i-rpmbl.i}
  
    IF  NOT THIS-PROCEDURE:PERSISTENT THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects C-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available C-Win  _ADM-ROW-AVAILABLE
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
  ENABLE im-pg-imp im-pg-par im-pg-sel bt-executar bt-cancelar bt-ajuda 
      WITH FRAME f-relat IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-relat}
  DISPLAY i-terab i-teren i-moeda l-separadores l-resumo-aliq l-incentivado 
          l-icms-st l-considera-cfops rs-previa c-imp-cab 
      WITH FRAME f-pg-par IN WINDOW C-Win.
  ENABLE RECT-10 RECT-16 RECT-17 RECT-19 i-terab i-teren i-moeda l-separadores 
         l-resumo-aliq l-considera-cfops rs-previa c-imp-cab 
      WITH FRAME f-pg-par IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-par}
  DISPLAY c-cod-estabel c-cod-estabel-fim dt-emissao-ini dt-emissao-fim 
          c-estado-ini c-estado-fim 
      WITH FRAME f-pg-sel IN WINDOW C-Win.
  ENABLE IMAGE-1 IMAGE-2 RECT-18 IMAGE-3 IMAGE-4 IMAGE-5 IMAGE-6 c-cod-estabel 
         c-cod-estabel-fim dt-emissao-ini dt-emissao-fim c-estado-ini 
         c-estado-fim 
      WITH FRAME f-pg-sel IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-sel}
  DISPLAY rs-destino c-arquivo rs-execucao 
      WITH FRAME f-pg-imp IN WINDOW C-Win.
  ENABLE rs-destino c-arquivo bt-config-impr bt-arquivo rs-execucao RECT-7 
         RECT-9 
      WITH FRAME f-pg-imp IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-imp}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit C-Win 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize C-Win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
  ASSIGN c-cod-estabel:SCREEN-VALUE IN FRAME f-pg-sel = "".  
  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualiza-data-tela C-Win 
PROCEDURE pi-atualiza-data-tela :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    /*IF l-incentivado:CHECKED IN FRAME f-pg-par THEN DO:
        ASSIGN i-livro = 10.
    END.
    ELSE DO:
        ASSIGN i-livro = 4.
    END.  

    find last  contr-livros
         where contr-livros.cod-estabel = c-cod-estabel:screen-value in frame f-pg-sel
         and   contr-livros.livro       = i-livro no-lock no-error.

    if  avail contr-livros then
        assign dt-emissao-ini:screen-value in frame f-pg-sel = string(contr-livros.dt-ult-emi + 1).

    assign dt-aux = date(dt-emissao-ini:screen-value in frame f-pg-sel).

    /* dt final = ultimo dia do mes. */
    if  month(dt-aux) = 12 then
        assign dt-emissao-fim:screen-value in frame f-pg-sel = string(date(month(dt-aux),31,year(dt-aux))).
    else
        assign dt-emissao-fim:screen-value in frame f-pg-sel = string(date(month(dt-aux) + 1,1,year(dt-aux)))
               dt-emissao-fim:screen-value in frame f-pg-sel = string(date(dt-emissao-fim:screen-value in frame f-pg-sel) - 1 ) .*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-executar C-Win 
PROCEDURE pi-executar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEF VAR l-erro AS LOGICAL NO-UNDO.

do  on error undo, return error
    on stop  undo, return error:     

    {include/i-rpexa.i}

    if  input frame f-pg-imp rs-destino = 2 then do:
        run utp/ut-vlarq.p (input input frame f-pg-imp c-arquivo).
        if  return-value = "nok" then do:
            run utp/ut-msgs.p (input "show",
                               input 73,
                               input "").
            apply 'mouse-select-click' to im-pg-imp in frame f-relat.
            apply 'entry' to c-arquivo in frame f-pg-imp.
            return error.
        end.
    end.
        
    IF INPUT FRAME f-pg-sel dt-emissao-ini = ? THEN DO:
       run utp/ut-msgs.p (input "show",
                          input 17006,
                          input "Data Apuraá∆o Inicial deve ser informada.").
       apply 'entry' to dt-emissao-ini in frame f-pg-sel.
       return error.
    END.

    IF INPUT FRAME f-pg-sel dt-emissao-fim = ? THEN DO:
       run utp/ut-msgs.p (input "show",
                          input 17006,
                          input "Data Apuraá∆o Final deve ser informada.").
       apply 'entry' to dt-emissao-fim in frame f-pg-sel.
       return error.
    END.

    /* Coloque aqui as validaá‰es das outras p†ginas, lembrando que elas
       devem apresentar uma mensagem de erro cadastrada, posicionar na p†gina 
       com problemas e colocar o focus no campo com problemas */   

    IF l-incentivado:CHECKED IN FRAME f-pg-par THEN DO:
        ASSIGN i-livro = 10.
    END.
    ELSE DO:
        ASSIGN i-livro = 4.
    END.

    EMPTY TEMP-TABLE tt-estab.

    FOR EACH estabelec NO-LOCK WHERE
             estabelec.cod-estabel >= input frame f-pg-sel c-cod-estabel     AND 
             estabelec.cod-estabel <= input frame f-pg-sel c-cod-estabel-fim AND 
             estabelec.estado      >= input frame f-pg-sel c-estado-ini      AND 
             estabelec.estado      <= input frame f-pg-sel c-estado-fim:

       CREATE tt-estab.
       ASSIGN tt-estab.cod-estabel = estabelec.cod-estabel. 
                                   
    END.

    ASSIGN l-erro = NO.

    IF NOT CAN-FIND(FIRST tt-estab) 
    THEN DO:
        run utp/ut-msgs.p (input "show",
                           input 17006,
                           input "Nenhum estabelecimento encontrado na seleá∆o").
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to c-cod-estabel in frame f-pg-sel.

        ASSIGN l-erro = YES.

    END.
    ELSE DO :

         Bloco_valida:
         FOR EACH tt-estab :

                    FIND param-of WHERE 
                         param-of.cod-estabel =  tt-estab.cod-estabel no-lock no-error.
        
                    IF NOT AVAIL param-of 
                    THEN DO:

                        run utp/ut-msgs.p (input "show", 
                                           input 17006, 
                                           input "ParÉmetros de Obrigaá‰es Fiscais n∆o encontrados!" + "~~" +  
                                                 "N∆o foram encontrados parÉmetros de Obrigaá‰es Fiscais para o estabelecimento "  + tt-estab.cod-estabel).

                          apply 'mouse-select-click' to im-pg-sel in frame f-relat.
                          apply 'entry' to c-cod-estabel in frame f-pg-sel.

                          ASSIGN l-erro = YES.

                          LEAVE bloco_valida.
                    END. 


                    find last  contr-livros
                         where contr-livros.cod-estabel = tt-estab.cod-estabel
                         and   contr-livros.livro       = i-livro no-lock no-error.
                    if  not avail contr-livros 
                    then do:
                        IF l-incentivado:CHECKED IN FRAME f-pg-par 
                        THEN DO:
                           
                             run utp/ut-msgs.p (input "show",
                                                    input 17006,
                                                    input "Controle de livros n∆o cadastrado!" + "~~" + 
                                                          "N∆o existe controle de livros incentivado para o estabelecimento " + tt-estab.cod-estabel ).

                        END.
                        ELSE DO:

                             run utp/ut-msgs.p (input "show",
                                                input 17006,
                                                input "Controle de livros náao cadastrado!" + "~~" + 
                                                      "N∆o existe controle de livros para o estabelecimento " + tt-estab.cod-estabel ).

                                   

                        END.

                        apply 'mouse-select-click' to im-pg-sel in frame f-relat.                   
                        apply 'entry' to c-cod-estabel in frame f-pg-sel.                   
                        
                        ASSIGN l-erro = YES.

                        LEAVE bloco_valida.
                    end.
                
                    if  avail contr-livros
                    and input frame f-pg-par rs-previa = 2 then do:
                        find first b-contr-livros use-index ch-livro
                            where  b-contr-livros.cod-estabel = tt-estab.cod-estabel
                            and    b-contr-livros.dt-ult-emi  = input frame f-pg-sel dt-emissao-ini - 1
                            and    b-contr-livros.livro       = i-livro
                            no-lock no-error.
                        if not avail b-contr-livros
                        and contr-livros.dt-ult-emi <> input frame f-pg-sel dt-emissao-ini - 1 
                        then do:
                            /* Selecao implica na perda de informacoes nos periodos */
                            run utp/ut-msgs.p (input "show", input 3233, input "").
                              
                            LEAVE bloco_valida.
                        end.
                        if  avail b-contr-livros then do:
                            find first contr-livros use-index ch-livro
                                where  contr-livros.cod-estabel = tt-estab.cod-estabel
                                and    contr-livros.dt-ult-emi >= input frame f-pg-sel dt-emissao-ini
                                and    contr-livros.livro       = i-livro
                                no-lock no-error.
                            if  avail contr-livros then do:
                                /* A reemissao do periodo inicial" dt-emissao-ini
                                   implicara na reemissao dos periodos seguintes */
                                run utp/ut-msgs.p (input "show", input 6856, input string(input frame f-pg-sel dt-emissao-ini)).
                               

                                LEAVE bloco_valida.
                            end.
                        end.
                    end.
                    
                    /*if  l-incentivado:checked in frame f-pg-par THEN
                        for first apur-imposto fields()
                            where apur-imposto.cod-estabel  = tt-estab.cod-estabel  
                            and   apur-imposto.dt-apur-fim <= input frame f-pg-sel dt-emissao-fim 
                            and   apur-imposto.dt-apur-ini >= input frame f-pg-sel dt-emissao-ini
                            and   apur-imposto.tp-imposto   = 3 no-lock. /* ICMS incentivado */
                        end.
                    ELSE 
                        for first apur-imposto fields()
                            where apur-imposto.cod-estabel  = tt-estab.cod-estabel  
                            and   apur-imposto.dt-apur-fim <= input frame f-pg-sel dt-emissao-fim 
                            and   apur-imposto.dt-apur-ini >= input frame f-pg-sel dt-emissao-ini
                            and   (apur-imposto.tp-imposto  = 1 OR apur-imposto.tp-imposto  = 4) no-lock. /* 1 = ICMS normal, 4 = Subst. Trib. */
                        end.
                    if  return-value = "OK":U then
                        /* for first apur-imposto fields()
                            where apur-imposto.cod-estabel  = tt-estab.cod-estabel  
                            and   apur-imposto.dt-apur-fim <= input frame f-pg-sel dt-emissao-fim 
                            and   apur-imposto.dt-apur-ini >= input frame f-pg-sel dt-emissao-ini
                            and   apur-imposto.tp-imposto   = 99 no-lock. /* 99 = ICMS CafÇ */
                        end. */  */

                    if  l-incentivado:checked in frame f-pg-par THEN
                        for first apur-imposto fields()
                            where apur-imposto.cod-estabel        = tt-estab.cod-estabel  
                            and   MONTH(apur-imposto.dt-apur-ini) = MONTH(input frame f-pg-sel dt-emissao-ini) 
                            and   YEAR(apur-imposto.dt-apur-ini)  = YEAR(input frame f-pg-sel dt-emissao-ini) 
                            and   MONTH(apur-imposto.dt-apur-fim) = MONTH(input frame f-pg-sel dt-emissao-fim) 
                            and   YEAR(apur-imposto.dt-apur-fim)  = YEAR(input frame f-pg-sel dt-emissao-fim) 
                            and   apur-imposto.tp-imposto   = 3 no-lock. /* ICMS incentivado */
                        end.
                    ELSE 
                        for first apur-imposto fields()
                            where apur-imposto.cod-estabel        = tt-estab.cod-estabel  
                            and   MONTH(apur-imposto.dt-apur-ini) = MONTH(input frame f-pg-sel dt-emissao-ini) 
                            and   YEAR(apur-imposto.dt-apur-ini)  = YEAR(input frame f-pg-sel dt-emissao-ini) 
                            and   MONTH(apur-imposto.dt-apur-fim) = MONTH(input frame f-pg-sel dt-emissao-fim) 
                            and   YEAR(apur-imposto.dt-apur-fim)  = YEAR(input frame f-pg-sel dt-emissao-fim) 
                            and   (apur-imposto.tp-imposto  = 1 OR apur-imposto.tp-imposto  = 4) no-lock. /* 1 = ICMS normal, 4 = Subst. Trib. */
                        end.
                    if  not avail apur-imposto 
                    then do:
                        run utp/ut-msgs.p (input "show",
                                           input 17006,
                                           input "Apuraá∆o de imposto n∆o cadastrada!" + "~~" + 
                                                 "Cadastre a apuraá∆o de imposto no programa of0313 para o estabelecimento " + tt-estab.cod-estabel ). 
                       
                        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
                        apply 'entry' to c-cod-estabel in frame f-pg-sel.
                        
                        ASSIGN l-erro = YES.

                        LEAVE bloco_valida.

                    end.     

         END. /* bloco */

    END.
    
        
        /* NOT CAN-FIND(tab-ocor WHERE 
                     tab-ocor.cod-ocor    = 300 and 
                     tab-ocor.log-1       = YES AND
              &IF "{&mguni_version}" >= "2.071" &THEN
              SUBSTR(tab-ocor.char-1,1,5) = tt-estab.cod-estabel)) 
              &ELSE
              SUBSTR(tab-ocor.char-1,1,3) = tt-estab.cod-estabel)) 
              &ENDIF
              then do: 

        run utp/ut-msgs.p (input "show",
                           input 537,
                           input " ").
        apply 'mouse-select-click' to im-pg-sel in frame f-relat.
        apply 'entry' to c-cod-estabel in frame f-pg-sel.                   
        return error. :U. */

     IF l-erro = YES THEN return NO-APPLY.  
    

    find first termo 
        where termo.te-codigo = input frame f-pg-par i-terab no-lock no-error.
    if not avail termo then do:
       run utp/ut-msgs.p (input "show",
                           input 2955,
                           input " ").
       apply 'mouse-select-click' to im-pg-par in frame f-relat.
       apply 'entry' to i-terab in frame f-pg-par.                   
       return error.
    end.
 
    if input frame f-pg-par i-terab = input frame f-pg-par i-teren then do:
       run utp/ut-msgs.p (input "show",
                           input 4504,
                           input " ").
       apply 'mouse-select-click' to im-pg-par in frame f-relat.
       apply 'entry' to i-teren in frame f-pg-par.                   
       return error.
    end.
    
    find first termo 
        where termo.te-codigo = input frame f-pg-par i-teren no-lock no-error.
    if not avail termo then do:
       run utp/ut-msgs.p (input "show",
                           input 4500,
                           input " ").
       apply 'mouse-select-click' to im-pg-par in frame f-relat.
       apply 'entry' to i-teren in frame f-pg-par.                   
       return error.
    end.
    
    for first moeda fields()
        where moeda.mo-codigo = input frame f-pg-par i-moeda no-lock.
    end.

    if  not avail moeda then do:
        {utp/ut-table.i mguni moeda 1}
        run utp/ut-msgs.p (input "show",
                           input 2,
                           input return-value).
        apply 'mouse-select-click' to im-pg-par in frame f-relat.
        apply "entry" to i-moeda in frame f-pg-par.                   
        return error.
    end.

    create tt-param.
    assign tt-param.usuario           = c-seg-usuario
           tt-param.destino           = input frame f-pg-imp rs-destino
           tt-param.data-exec         = today
           tt-param.hora-exec         = time
           tt-param.cod-estabel       = input frame f-pg-sel c-cod-estabel
           tt-param.cod-estabel-fim   = input frame f-pg-sel c-cod-estabel-fim  
           tt-param.dt-emissao-ini    = input frame f-pg-sel dt-emissao-ini
           tt-param.dt-emissao-fim    = input frame f-pg-sel dt-emissao-fim
           tt-param.estado-ini        = input frame f-pg-sel c-estado-ini
           tt-param.estado-fim        = input frame f-pg-sel c-estado-fim  
           tt-param.termo-ab          = input frame f-pg-par i-terab
           tt-param.termo-en          = input frame f-pg-par i-teren
           tt-param.moeda             = input frame f-pg-par i-moeda
           tt-param.tp-emissao        = input frame f-pg-par rs-previa
           tt-param.l-separadores     = l-separadores:checked in frame f-pg-par
           tt-param.l-resumo-aliq     = l-resumo-aliq:checked in frame f-pg-par
           tt-param.l-incentivado     = if  l-incentivado <> ? 
                                      then l-incentivado:checked in frame f-pg-par
                                      else l-incentivado
           tt-param.l-icms-st         = input frame f-pg-par l-icms-st
           tt-param.l-considera-cfops = l-considera-cfops:CHECKED IN FRAME f-pg-par
           tt-param.imp-cab           = input frame f-pg-par c-imp-cab.

    if  tt-param.destino = 1 then           
        assign tt-param.arquivo = "".
    else
    if  tt-param.destino = 2 then 
        assign tt-param.arquivo = input frame f-pg-imp c-arquivo.
    else
        assign tt-param.arquivo = session:temp-directory + c-programa-mg97 + ".tmp".

    /* Coloque aqui a l¢gica de gravaá∆o dos parÉmtros e seleá∆o na temp-table
       tt-param */ 

    {include/i-rpexb.i}

    if  session:set-wait-state("general") then.
    
    assign c-est-ant = "".
    
    {include/i-rprun.i intprg/ni0302rp.p}

    {include/i-rpexc.i}

    if  session:set-wait-state("") then.
    
    {include/i-rptrm.i}
    
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-troca-pagina C-Win 
PROCEDURE pi-troca-pagina :
/*------------------------------------------------------------------------------
  Purpose: Gerencia a Troca de P†gina (folder)   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
APPLY "LEAVE" TO c-cod-estabel IN FRAME f-pg-sel.

{include/i-rptrp.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-upc C-Win 
PROCEDURE pi-upc :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/**********************************************************************
** UPC Especifica
** Podem ser passados parametros para ela afim de reutilizar o codigo
** se houver necessidade.
**********************************************************************/ 
def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

    /* DPC */
    if  c-nom-prog-dpc-mg97 <> ""
    and c-nom-prog-dpc-mg97 <> ? then do:

        run value(c-nom-prog-dpc-mg97) (input p-ind-event, 
                                        input p-ind-object,
                                        input THIS-PROCEDURE,
                                        input FRAME f-pg-sel:HANDLE,
                                        input p-cod-table,
                                        input p-row-table).    

    end.

    /* APPC */
    if  c-nom-prog-appc-mg97 <> ""
    and c-nom-prog-appc-mg97 <> ? then do:           

        run value(c-nom-prog-appc-mg97) (input p-ind-event, 
                                         input p-ind-object,
                                         input THIS-PROCEDURE,
                                         input FRAME f-pg-sel:HANDLE,
                                         input p-cod-table,
                                         input p-row-table).    

    end.                                       

    /* UPC */
    if  c-nom-prog-upc-mg97 <> ""
    and c-nom-prog-upc-mg97 <> ? then do:
        run value(c-nom-prog-upc-mg97) (input p-ind-event, 
                                        input p-ind-object,
                                        input THIS-PROCEDURE,
                                        input FRAME f-pg-sel:HANDLE,
                                        input p-cod-table,
                                        input p-row-table).    
    end. 
    ELSE
        RETURN "NOK".

    if  return-value = "OK":U then
        return "OK":U.
    else
        return "NOK":U.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records C-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this w-relat, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed C-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  
  run pi-trata-state (p-issuer-hdl, p-state).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

