&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i NICE0221 2.00.06.000}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        NICE0221
&GLOBAL-DEFINE Version        2.00.06.000

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Folder1

&GLOBAL-DEFINE page0Widgets  c-arquivo-origem c-arquivo-destino bt-imp btExit bt-arq

&GLOBAL-DEFINE page1Widgets   
&GLOBAL-DEFINE page2Widgets   

/* Parameters Definitions ---                                           */

/* Local Definitions ---                                       */

{utp/ut-glob.i}

DEF TEMP-TABLE tt-custos
    FIELD it-codigo   AS CHAR
    FIELD de-valor    AS DEC
    FIELD cod-estabel AS CHAR
    INDEX id-item-estab
            it-codigo
            cod-estabel.

define temp-table tt-param
    field destino     as integer
    field arq-destino as char
    field arq-entrada as char
    field arq-erros   as char
    field todos       as integer
    field usuario     as char
    field data-exec   as date
    field hora-exec   as integer
    field c-item-ini  as char
    field c-item-fim  as char
    field c-todos     as char
    field c-destino   as char.

DEF TEMP-TABLE tt-raw-digita
   FIELD raw-digita AS RAW.

DEFINE VARIABLE c-arquivo-tmp     AS CHARACTER                 NO-UNDO.
DEFINE VARIABLE c-linha           AS CHARACTER                 NO-UNDO.
DEFINE VARIABLE c-deposito        AS CHARACTER                 NO-UNDO.
DEFINE VARIABLE h-acomp           AS HANDLE                    NO-UNDO.
DEFINE VARIABLE raw-param         AS RAW                       NO-UNDO.

DEF STREAM str-erro.
DEF STREAM str-item.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS c-arquivo-origem bt-imp btExit ~
c-arquivo-destino RECT-1 
&Scoped-Define DISPLAYED-OBJECTS c-arquivo-origem c-arquivo-destino 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-arq 
     IMAGE-UP FILE "image\im-fold":U
     IMAGE-INSENSITIVE FILE "image\ii-fold":U
     LABEL "" 
     SIZE 4 BY .92 TOOLTIP "Selecionar Arquivo com Preáos MÇdios".

DEFINE BUTTON bt-imp 
     IMAGE-UP FILE "image/im-enter.bmp":U
     LABEL "Importar" 
     SIZE 4 BY 1 TOOLTIP "Importar Arquivo Selecionado"
     FONT 4.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1 TOOLTIP "Sair"
     FONT 4.

DEFINE VARIABLE c-arquivo-destino AS CHARACTER FORMAT "X(60)":U 
     LABEL "Arquivo Destino" 
     VIEW-AS FILL-IN 
     SIZE 60 BY .88 NO-UNDO.

DEFINE VARIABLE c-arquivo-origem AS CHARACTER FORMAT "X(60)":U 
     LABEL "Arquivo Origem" 
     VIEW-AS FILL-IN 
     SIZE 60 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 84 BY 2.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     c-arquivo-origem AT ROW 1.5 COL 13 COLON-ALIGNED WIDGET-ID 184
     bt-imp AT ROW 1.5 COL 81 WIDGET-ID 14
     btExit AT ROW 2.5 COL 81 HELP
          "Sair" WIDGET-ID 182
     c-arquivo-destino AT ROW 2.5 COL 13 COLON-ALIGNED WIDGET-ID 196
     bt-arq AT ROW 1.46 COL 75 HELP
          "Configuraá∆o da impressora" WIDGET-ID 198
     RECT-1 AT ROW 1.25 COL 2 WIDGET-ID 62
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 85.57 BY 19.5
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 2.75
         WIDTH              = 85.29
         MAX-HEIGHT         = 33
         MAX-WIDTH          = 228.57
         VIRTUAL-HEIGHT     = 33
         VIRTUAL-WIDTH      = 228.57
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

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU mbMain:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wWindow 
/* ************************* Included-Libraries *********************** */

{window/window.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME fpage0
   FRAME-NAME Custom                                                    */
/* SETTINGS FOR BUTTON bt-arq IN FRAME fpage0
   NO-ENABLE                                                            */
ASSIGN 
       bt-arq:HIDDEN IN FRAME fpage0           = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON END-ERROR OF wWindow
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-arq
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-arq wWindow
ON CHOOSE OF bt-arq IN FRAME fpage0
DO:
    DEFINE VARIABLE l-ok      AS LOGICAL     NO-UNDO.

    SYSTEM-DIALOG GET-FILE c-arquivo-tmp
       FILTERS "*.csv" "*.csv","*.csv" "*.csv"
       DEFAULT-EXTENSION "csv"
       INITIAL-DIR "spool" 
       SAVE-AS
       USE-FILENAME
       UPDATE l-ok.

    IF  l-ok
    THEN DO:
        ASSIGN c-arquivo-origem = c-arquivo-tmp.
        DISPLAY c-arquivo-origem WITH FRAME {&FRAME-NAME}.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-imp wWindow
ON CHOOSE OF bt-imp IN FRAME fpage0 /* Importar */
DO:
    ASSIGN c-arquivo-origem  = INPUT FRAME {&FRAME-NAME} c-arquivo-origem
           c-arquivo-destino = INPUT FRAME {&FRAME-NAME} c-arquivo-destino.

    IF  SEARCH(c-arquivo-origem) = ?
    THEN DO:
        RUN utp/ut-msgs.p (INPUT "show",
                           INPUT 17006,
                           INPUT "Arquivo origem n∆o encontrado.").
        APPLY "ENTRY" TO c-arquivo-origem IN FRAME {&FRAME-NAME}.
        RETURN.
    END.

    IF  INDEX(c-arquivo-destino,".txt") = 0
    THEN DO:
        RUN utp/ut-msgs.p (INPUT "show",
                           INPUT 17006,
                           INPUT "Arquivo destino deve ter extens∆o .txt").
        APPLY "ENTRY" TO c-arquivo-destino IN FRAME {&FRAME-NAME}.
        RETURN.
    END.

    RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
    RUN pi-inicializar IN h-acomp (INPUT "Processando").

    EMPTY TEMP-TABLE tt-custos.

    INPUT FROM VALUE(c-arquivo-origem).
    REPEAT:
        IMPORT UNFORMATTED c-linha.

        RUN pi-acompanhar IN h-acomp (INPUT "Importando Planilha, Item: " + ENTRY(1,c-linha,";")).

        IF  ENTRY(1,c-linha,";") = "item"
        THEN
            NEXT.

        CREATE tt-custos.
        ASSIGN tt-custos.it-codigo   = TRIM(ENTRY(1,c-linha,";"))
               tt-custos.de-valor    = DEC (ENTRY(2,c-linha,";"))
               tt-custos.cod-estabel = TRIM(ENTRY(3,c-linha,";")).
    END.
    INPUT CLOSE.


    ASSIGN c-arquivo-destino = REPLACE(c-arquivo-destino,".txt","")
           c-arquivo-tmp     = c-arquivo-destino + "-sem-estab.txt".

    OUTPUT STREAM str-erro TO VALUE(c-arquivo-tmp). 
    PUT STREAM str-erro UNFORMATTED "Item;Estab" SKIP.

    ASSIGN c-arquivo-tmp = c-arquivo-destino + "-" + STRING(TIME) + ".txt".
    OUTPUT STREAM str-item TO VALUE(c-arquivo-tmp).

    bloco-item:
    FOR EACH tt-custos:

        FIND item-estab NO-LOCK
            WHERE item-estab.it-codigo   = tt-custos.it-codigo 
              AND item-estab.cod-estabel = tt-custos.cod-estabel NO-ERROR.

        IF  NOT AVAIL item-estab
        THEN DO:
            PUT STREAM str-erro UNFORMATTED tt-custos.it-codigo   ";"
                                            tt-custos.cod-estabel SKIP.
            NEXT bloco-item.
        END.

        RUN pi-acompanhar IN h-acomp (INPUT "Exp Item / Estab: " + tt-custos.it-codigo + " / " + tt-custos.cod-estabel).

        IF tt-custos.cod-estabel = "973" THEN 
        DO:
            
            ASSIGN c-deposito = "973".
            
        END.
        
        ELSE IF  tt-custos.cod-estabel = "977" THEN
        DO:
            ASSIGN c-deposito = "977".
            
        END.

        ELSE IF tt-custos.cod-estabel <> "973" OR tt-custos.cod-estabel = "977" THEN
        DO:
        
            ASSIGN c-deposito = "LOJ".
        
        END.
            

        PUT STREAM str-item tt-custos.it-codigo        FORMAT "x(19)"           // 001
                            c-deposito                 FORMAT "x(03)"           // 020
                            "S"                                                 // 021                                
                            tt-custos.de-valor * 10000 FORMAT "99999999999999"  // 022
                            FILL("0",14)               FORMAT "x(14)"           // 038
                            FILL("0",14)               FORMAT "x(14)"           // 052
                            "N"
                            FILL("0",14)               FORMAT "x(14)"           // 067
                            FILL("0",14)               FORMAT "x(14)"           // 081
                            FILL("0",14)               FORMAT "x(14)"           // 095
                            "N"
                            FILL("0",14)               FORMAT "x(14)"           // 109
                            FILL("0",14)               FORMAT "x(14)"           // 124
                            FILL("0",14)               FORMAT "x(14)"           //
                            "1"
                            tt-custos.cod-estabel      FORMAT "x(05)" SKIP.
    END.

    OUTPUT STREAM str-item CLOSE.

    EMPTY TEMP-TABLE tt-param.    
    CREATE tt-param.
    ASSIGN tt-param.usuario     = c-seg-usuario
           tt-param.destino     = 2
           tt-param.todos       = 1
           tt-param.arq-entrada = c-arquivo-tmp
           tt-param.arq-erros   = REPLACE(c-arquivo-tmp,".txt","-log1.txt")
           tt-param.arq-destino = REPLACE(c-arquivo-tmp,".txt","-log2.txt")
           tt-param.data-exec   = today
           tt-param.hora-exec   = time
           tt-param.c-item-ini  = ""
           tt-param.c-item-fim  = "ZZZZZZZZZZZZZZZZ"
           tt-param.c-todos     = "Todos"
           tt-param.c-destino   = "Arquivo".

    RAW-TRANSFER tt-param TO raw-param.

    RUN cep/ce0221rp.p (INPUT raw-param,
                        INPUT TABLE tt-raw-digita).


    OUTPUT STREAM str-erro CLOSE.

    RUN pi-finalizar IN h-acomp.

    RUN utp/ut-msgs.p (INPUT "show",
                       INPUT 15825,
                       INPUT "Importaá∆o do arquivo finalizada.~~" + "Verifique na pasta do arquivo de destino os logs de importaá∆o gerados.").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializaá∆o do programam ---*/

{window/mainblock.i}

ASSIGN c-arquivo-origem  = SESSION:TEMP-DIRECTORY + "ajuste_custos.csv"
       c-arquivo-destino = SESSION:TEMP-DIRECTORY + "ajuste_custos.txt".

DISP c-arquivo-origem c-arquivo-destino WITH FRAME {&FRAME-NAME}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


