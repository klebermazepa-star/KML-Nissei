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

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */




DEF STREAM s1.

def var l-ok         as logical no-undo.
DEF VAR c-novo-dir   AS CHAR NO-UNDO.
DEF VAR c-dir-sessao AS CHAR NO-UNDO.
def var i-lin        as integer init 1 NO-UNDO.
def var i-colun      as integer init 1 NO-UNDO.
DEF VAR i            AS INTEGER NO-UNDO.
DEF VAR i-tot        AS INTEGER NO-UNDO.
DEF VAR i-mostra     AS INTEGER NO-UNDO.

/********************************Definicao Temp-Table **************************************/
define temp-table tt-dados
    field arquivo-num                   as integer format ">9"     initial 1
    field planilha-num                  as integer format ">9"
    field celula-coluna                 as integer format ">>9"
    field celula-linha                  as integer format ">>>>9"
    field celula-cor-interior           as integer format ">9"     initial 58 /* None */
    field celula-formato                as char    format "x(255)"
    field celula-formula                as char    format "x(255)"
    field celula-alinhamento-horizontal as integer format "9"      initial 4 /* Left */
    field celula-alinhamento-vertical   as integer format "9"      initial 1 /* Bottom */
    field celula-valor                  as char    format "x(255)"
    field celula-fonte-nome             as char    format "x(255)" initial "Times New Roman"
    field celula-fonte-tamanho          as integer format ">9"     initial 10
    field celula-fonte-negrito          as logical                 initial no
    field celula-fonte-italico          as logical                 initial no
    field celula-fonte-sublinhado       as integer format "9"      initial 3 /* None */
    field celula-fonte-cor              as integer format ">9"     initial 57 /* Automatic */
    field celula-tipo-borda-sup         as integer format "9"      initial 7 /* None */
    field celula-tipo-borda-inf         as integer format "9"      initial 7 /* None */
    field celula-tipo-borda-esq         as integer format "9"      initial 7 /* None */
    field celula-tipo-borda-dir         as integer format "9"      initial 7 /* None */
    index tt-dados-pri is unique primary
        arquivo-num
        planilha-num
        celula-coluna
        celula-linha.

define temp-table tt-configuracao
    field versao-integracao   as integer format ">>9"
    field arquivo-num         as integer format ">9"     initial 1
    field arquivo             as char    format "x(255)" initial "c:~\tmp~\utapi013.xls"
    field total-planilhas     as integer format ">9"     initial 05
    field exibir-construcao   as logical                 initial no
    field abrir-excel-termino as logical                 initial no    
    index tt-configuracao-pri is unique primary 
        versao-integracao
        arquivo-num.
/********************************Definicao Temp-Table **************************************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frame0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-11 RECT-10 fi-texto bt-fornec ~
c-arquivo-fornec BUTTON-2 bt-Importar 
&Scoped-Define DISPLAYED-OBJECTS fi-texto c-arquivo-fornec fi-acomp 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-fornec 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-Importar 
     LABEL "Importar" 
     SIZE 15 BY 1.13.

DEFINE BUTTON BUTTON-2 
     LABEL "Sair" 
     SIZE 15 BY 1.13.

DEFINE VARIABLE fi-texto AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 77 BY 1.92
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE c-arquivo-fornec AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 69.14 BY .79 NO-UNDO.

DEFINE VARIABLE fi-acomp AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 77 BY 1
     BGCOLOR 7 FGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 77 BY 1.33.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 77 BY 1.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frame0
     fi-texto AT ROW 1.42 COL 2.14 NO-LABEL WIDGET-ID 12
     bt-fornec AT ROW 3.96 COL 73 HELP
          "Escolha do nome do arquivo" WIDGET-ID 52
     c-arquivo-fornec AT ROW 4.04 COL 1.86 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     BUTTON-2 AT ROW 5.79 COL 63 WIDGET-ID 6
     bt-Importar AT ROW 5.83 COL 3 WIDGET-ID 2
     fi-acomp AT ROW 7.33 COL 2.14 NO-LABEL WIDGET-ID 32
     RECT-11 AT ROW 5.67 COL 2 WIDGET-ID 28
     RECT-10 AT ROW 3.79 COL 2 WIDGET-ID 72
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 79.14 BY 17.96 WIDGET-ID 100.


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
         TITLE              = "Importac∆o M100/M500":U
         HEIGHT             = 7.88
         WIDTH              = 79.57
         MAX-HEIGHT         = 31.21
         MAX-WIDTH          = 182.86
         VIRTUAL-HEIGHT     = 31.21
         VIRTUAL-WIDTH      = 182.86
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
/* SETTINGS FOR FRAME frame0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN fi-acomp IN FRAME frame0
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
       fi-texto:AUTO-INDENT IN FRAME frame0      = TRUE
       fi-texto:READ-ONLY IN FRAME frame0        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Importaá∆o M100/M500 */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Importaá∆o M100/M500 */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-fornec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-fornec C-Win
ON CHOOSE OF bt-fornec IN FRAME frame0
DO:
    def var cArqConv  as char no-undo.

    assign cArqConv = replace(input frame frame0 c-arquivo-fornec, "/":U, "~\":U).
    SYSTEM-DIALOG GET-FILE cArqConv
       FILTERS "*.xls":U "*.xls":U
       ASK-OVERWRITE 
       DEFAULT-EXTENSION "xls":U
       INITIAL-DIR session:temp-directory
       TITLE "Arquivo de Fornecedores":U
       USE-FILENAME
       UPDATE l-ok.
    if  l-ok = yes then do:
        assign c-arquivo-fornec = replace(cArqConv, "~\":U, "/":U).
        display c-arquivo-fornec with frame frame0.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-Importar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-Importar C-Win
ON CHOOSE OF bt-Importar IN FRAME frame0 /* Importar */
DO:
      
    IF  NOT SEARCH(c-arquivo-fornec:SCREEN-VALUE) <> ? THEN DO:
        MESSAGE "Arquivo de dados FORNECEDORES n∆o encontrado" VIEW-AS ALERT-BOX INFO BUTTONS OK.
        return NO-APPLY.
    END.  

    RUN pi-importa.

    IF  SESSION:SET-WAIT-STATE("") THEN.

    fi-acomp:screen-value = "CONCLU÷DO.".


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-2 C-Win
ON CHOOSE OF BUTTON-2 IN FRAME frame0 /* Sair */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
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

   ASSIGN fi-texto:SCREEN-VALUE = "  Importar M100/M500 - Imformar a planilha com os valores iniciais...".

   ASSIGN c-dir-sessao = replace(SESSION:TEMP-DIRECTORY, "/", "\").
   IF  SUBSTR(trim(c-dir-sessao), LENGTH(c-dir-sessao), 1) <> "\" THEN
       c-dir-sessao = c-dir-sessao + "\".

   
  ASSIGN c-arquivo-fornec:SENSITIVE = YES
                bt-fornec:SENSITIVE = YES.


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
  DISPLAY fi-texto c-arquivo-fornec fi-acomp 
      WITH FRAME frame0 IN WINDOW C-Win.
  ENABLE RECT-11 RECT-10 fi-texto bt-fornec c-arquivo-fornec BUTTON-2 
         bt-Importar 
      WITH FRAME frame0 IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frame0}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-busca-tot-linhas C-Win 
PROCEDURE pi-busca-tot-linhas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEF INPUT PARAMETER ch-Excel as component-handle no-undo.
    DEF INPUT PARAMETER i-coluna AS INTEGER NO-UNDO.

    /*GUARDA O TOTAL DE REGISTROS ˙ PROCESSA, LENDO O ARQUIVO EXCEL*/
    assign i-lin   = 2 i-tot   = 0.
    REPEAT:
        IF  TRIM(ch-Excel:Cells(i-lin, i-coluna):Text) = "" THEN leave.
        assign i-lin = i-lin + 1. 
               i-tot = i-tot + 1.
    END.
    /***************************************************************/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-DUMP C-Win 
PROCEDURE pi-gera-DUMP :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEF INPUT PARAMETER c-tabela AS CHAR NO-UNDO.             

    /* deleta dump anterior, caso exista e faz novo dump para backup */

    IF  c-tabela = "FORNECEDOR" THEN DO:
        fi-acomp:SCREEN-VALUE IN FRAME frame0 = "Gerando DUMP da tabela EMITENTE . . . ".
        os-delete value(c-novo-dir + "\dump-fornec.d":U) NO-ERROR.
    
        OUTPUT TO VALUE(c-novo-dir + "\dump-fornec.d":U) CONVERT TARGET "iso8859-1".
        FOR EACH emitente NO-LOCK:
            EXPORT emitente.
        END.
        OUTPUT CLOSE.
    END.
    
    IF  c-tabela = "ITEM" THEN DO:
        fi-acomp:SCREEN-VALUE IN FRAME frame0 = "Gerando DUMP da tabela ITEM . . . ".
        os-delete value(c-novo-dir + "\dump-item.d":U) NO-ERROR.
    
        OUTPUT TO VALUE(c-novo-dir + "\dump-item.d":U) CONVERT TARGET "iso8859-1".
        FOR EACH ITEM NO-LOCK:
            EXPORT ITEM.
        END.
        OUTPUT CLOSE.
    END.

    IF  c-tabela = "NATUREZA" THEN DO:
        fi-acomp:SCREEN-VALUE IN FRAME frame0 = "Gerando DUMP da tabela NATUR-OPER . . . ".
        os-delete value(c-novo-dir + "\dump-natur-oper.d":U) NO-ERROR.
    
        OUTPUT TO VALUE(c-novo-dir + "\dump-natur-oper.d":U) CONVERT TARGET "iso8859-1".
        FOR EACH natur-oper NO-LOCK:
            EXPORT natur-oper.
        END.
        OUTPUT CLOSE.
    END.

    IF  c-tabela = "RI-BEM" THEN DO:
        fi-acomp:SCREEN-VALUE IN FRAME frame0 = "Gerando DUMP da tabela RI-BEM . . . ".
        os-delete value(c-novo-dir + "\dump-ri-bem.d":U) NO-ERROR.
    
        OUTPUT TO VALUE(c-novo-dir + "\dump-ri-bem.d":U) CONVERT TARGET "iso8859-1".
        FOR EACH ri-bem NO-LOCK:
            EXPORT ri-bem.
        END.
        OUTPUT CLOSE.
    END.

    IF  c-tabela = "BEM" THEN DO:
        fi-acomp:SCREEN-VALUE IN FRAME frame0 = "Gerando DUMP da tabela BEM (FINANCEIRO - EMS2) . . . ".
        os-delete value(c-novo-dir + "\dump-bem.d":U) NO-ERROR.
    
        OUTPUT TO VALUE(c-novo-dir + "\dump-bem.d":U) CONVERT TARGET "iso8859-1".
        FOR EACH bem NO-LOCK:
            EXPORT bem.
        END.
        OUTPUT CLOSE.
    END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-importa C-Win 
PROCEDURE pi-importa :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    def var ch-Excel    as component-handle no-undo.
    def var ch-Arquivo  as component-handle no-undo.
    def var ch-Planilha as component-handle no-undo.

    def var c-arquivo   as char         NO-UNDO.
    def var i-col    as int          NO-UNDO.
    
    /************************** ABERTURA ARQUIVO EXCEL *****************************************/
    assign i-lin   = 2.

    CREATE "Excel.Application" ch-Excel.

    assign c-arquivo  = replace(c-arquivo-fornec:SCREEN-VALUE IN FRAME frame0, "/", "\").

    if  valid-handle(ch-Arquivo) then ch-Arquivo:Close().

    if  search(c-arquivo) <> ? then  
        ch-Arquivo = ch-Excel:Workbooks:Open(c-arquivo,,yes).
    else do:
        MESSAGE "Arquivo de dados dos FORNECEDORES n∆o encontrado" VIEW-AS ALERT-BOX INFO BUTTONS OK.
        return "NOK".
    end.  

    ch-Planilha = ch-Arquivo:WorkSheets:Item(1):Activate.
    /****************************** FIM ABERTURA ***********************************************/
     
    IF  SESSION:SET-WAIT-STATE("general") THEN.

    DEF VAR c-cod-tip-cr-recta-trib-mi   AS CHAR NO-UNDO.
    DEF VAR c-cod-tip-cr-recta-nao-trib-mi AS CHAR NO-UNDO.
    DEF VAR c-cod-tip-cr-recta-export      AS CHAR NO-UNDO.
    DEF VAR c-cod-natur-base-calc-cr       AS CHAR NO-UNDO.
    DEF VAR c-cod-cfop                     AS CHAR NO-UNDO.
    DEF VAR c-cod-sit-tributar             AS CHAR NO-UNDO.
    DEF VAR de-val-aliq-impto              AS DECIMAL NO-UNDO.
    
    /*calcula total de linhas do excel*/
    RUN pi-busca-tot-linhas (INPUT ch-Excel, 2)/*coluna que contem a chave da tabela*/ .
   
    assign i-lin   = 2.

    REPEAT : 
        
        /* número de colunas do arquivo excel em questío */
        do  i-col = 1 TO 7: 
           
            if  i-col = 5 and TRIM(ch-Excel:Cells(i-lin,i-col):Text) = "" THEN leave.
      
            
            IF  i-col = 1 THEN
                ASSIGN c-cod-tip-cr-recta-trib-mi     = ch-Excel:Cells(i-lin,i-col):TEXT.
            
            IF  i-col = 2 THEN
                ASSIGN c-cod-tip-cr-recta-nao-trib-mi = ch-Excel:Cells(i-lin,i-col):TEXT.

            IF  i-col = 3 THEN
                ASSIGN c-cod-tip-cr-recta-export      = ch-Excel:Cells(i-lin,i-col):TEXT.

            IF  i-col = 4 THEN
                ASSIGN c-cod-natur-base-calc-cr       = ch-Excel:Cells(i-lin,i-col):TEXT.
            
            IF  i-col = 5 THEN
                ASSIGN c-cod-cfop                     = ch-Excel:Cells(i-lin,i-col):TEXT.

            IF  i-col = 6 THEN
                ASSIGN c-cod-sit-tributar             = ch-Excel:Cells(i-lin,i-col):TEXT.

            IF  i-col = 7 THEN
                ASSIGN de-val-aliq-impto              = dec(ch-Excel:Cells(i-lin,i-col):TEXT).

        end.       

        assign i-lin = i-lin + 1.    
 
        if  i-col = 5 and TRIM(ch-Excel:Cells(i-lin,i-col):Text) = "" then
            leave.
        
        CREATE  dwf-relac-tip-cr.
        ASSIGN  dwf-relac-tip-cr.cod-tip-cr-recta-trib-mi     = c-cod-tip-cr-recta-trib-mi
                dwf-relac-tip-cr.cod-tip-cr-recta-nao-trib-mi = c-cod-tip-cr-recta-nao-trib-mi
                dwf-relac-tip-cr.cod-tip-cr-recta-export      = c-cod-tip-cr-recta-export
                dwf-relac-tip-cr.cod-natur-base-calc-cr       = c-cod-natur-base-calc-cr
                dwf-relac-tip-cr.cod-cfop                     = c-cod-cfop
                dwf-relac-tip-cr.cod-sit-tributar             = c-cod-sit-tributar
                dwf-relac-tip-cr.val-aliq-impto               = de-val-aliq-impto.

        /* Display de registros processados*/
        ASSIGN i-mostra = i-mostra + 1.

        IF  i-mostra = 50 THEN DO:
            fi-acomp:SCREEN-VALUE IN FRAME frame0 = "IMPORTANDO M100/M500: " + STRING(i-lin - 2) + " de " + STRING(i-tot - 1).
            i-mostra = 0.
        END.
    END.
    /*************************************************** fim do repeat *************************************************/

    OUTPUT STREAM s1 CLOSE.

    ch-Arquivo:Close().
    ch-Excel:Quit().

    if  valid-handle(ch-planilha) THEN release object ch-Planilha.
    if  valid-handle(ch-arquivo)  THEN release object ch-Arquivo.
    if  valid-handle(ch-Excel)    THEN release object ch-Excel.


    RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

