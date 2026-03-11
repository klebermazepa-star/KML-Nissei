&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-relat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-relat 
{include/i-prgvrs.i esp003 2.04.00.000}

CREATE WIDGET-POOL.

&GLOBAL-DEFINE      PGSEL                       f-pg-sel
&GLOBAL-DEFINE      PGCLA
&GLOBAL-DEFINE      PGPAR                       f-pg-par
&GLOBAL-DEFINE      PGDIG                       
&GLOBAL-DEFINE      PGIMP                       f-pg-imp

define temp-table TT-PARAM NO-UNDO
       FIELD DESTINO            AS INTEGER 
       FIELD ARQUIVO            AS CHAR FORMAT "x(35)"
       FIELD USUARIO            AS CHAR FORMAT "x(12)"
       FIELD DATA-EXEC          AS DATE 
       FIELD HORA-EXEC          AS INTEGER 
       FIELD L-IMP-PARAM        AS LOG 
       FIELD L-EXCEL            AS LOG 
       FIELD it-codigo-ini      as character FORMAT "x(16)"
       FIELD it-codigo-fim      as character FORMAT "x(16)"
       FIELD estado-origem-ini  as character FORMAT "x(4)"
       FIELD estado-origem-fim  as character FORMAT "x(4)"
       FIELD estado-destino-ini as character FORMAT "x(04)"
       FIELD estado-destino-fim as character FORMAT "x(04)"
       FIELD planilha           AS CHAR.

DEFINE TEMP-TABLE   tt-digita                   NO-UNDO
       FIELD        registro                    AS   INTEGER 
       INDEX        ind-digita
                    registro                    ASCENDING.

DEFINE TEMP-TABLE   tt-raw-digita
       FIELD        raw-digita                  AS   RAW.

DEFINE VARIABLE     c-arq-digita                AS   CHARACTER              NO-UNDO.
DEFINE VARIABLE     c-arq-aux                   AS   CHARACTER              NO-UNDO.
DEFINE VARIABLE     c-terminal                  AS   CHARACTER              NO-UNDO.
DEFINE VARIABLE     l-ok                        AS   LOGICAL                NO-UNDO.
DEFINE VARIABLE     raw-param                   AS   RAW                    NO-UNDO.

/** Final **/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-relat
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-objetivo

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS c-objetivo 
&Scoped-Define DISPLAYED-OBJECTS c-objetivo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-relat AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE c-objetivo AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 72.72 BY 5.67 NO-UNDO.

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

DEFINE BUTTON bt-planilha 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE VARIABLE c-planilha AS CHARACTER FORMAT "X(256)":U 
     LABEL "Planilha" 
     VIEW-AS FILL-IN 
     SIZE 53 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-25
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 76 BY 2.38.

DEFINE VARIABLE estado-destino-fim AS CHARACTER FORMAT "x(04)" INITIAL "ZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE estado-destino-ini AS CHARACTER FORMAT "x(04)" 
     LABEL "UF Destino" 
     VIEW-AS FILL-IN 
     SIZE 5.72 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE estado-origem-fim AS CHARACTER FORMAT "x(4)" INITIAL "ZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE estado-origem-ini AS CHARACTER FORMAT "x(4)" 
     LABEL "UF Origem" 
     VIEW-AS FILL-IN 
     SIZE 5.72 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE it-codigo-fim AS CHARACTER FORMAT "x(16)" INITIAL "ZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE it-codigo-ini AS CHARACTER FORMAT "x(16)" 
     LABEL "Item" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88
     FONT 1 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-3
     FILENAME "image\im-fir":U
     SIZE 4 BY .88.

DEFINE IMAGE IMAGE-4
     FILENAME "image\im-las":U
     SIZE 4 BY .88.

DEFINE IMAGE IMAGE-7
     FILENAME "image\im-fir":U
     SIZE 6 BY .88.

DEFINE IMAGE IMAGE-8
     FILENAME "image\im-las":U
     SIZE 6 BY .88.

DEFINE BUTTON bt-ajuda 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-cancelar AUTO-END-KEY 
     LABEL "Fechar" 
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
     bt-arquivo AT ROW 3.58 COL 43.14 HELP
          "Escolha do nome do arquivo"
     bt-config-impr AT ROW 3.58 COL 43.29 HELP
          "Configuraá∆o da impressora"
     c-arquivo AT ROW 3.63 COL 3.29 HELP
          "Nome do arquivo de destino do relat¢rio" NO-LABEL
     rs-execucao AT ROW 5.75 COL 3 HELP
          "Modo de Execuá∆o" NO-LABEL
     text-destino AT ROW 1.63 COL 3.86 NO-LABEL
     text-modo AT ROW 5 COL 1.29 COLON-ALIGNED NO-LABEL
     RECT-7 AT ROW 1.92 COL 2.14
     RECT-9 AT ROW 5.29 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 3.17
         SIZE 76.72 BY 10.

DEFINE FRAME f-pg-par
     bt-planilha AT ROW 1.88 COL 68.29 HELP
          "Escolha do nome do arquivo" WIDGET-ID 6
     c-planilha AT ROW 1.92 COL 13 COLON-ALIGNED WIDGET-ID 8
     RECT-25 AT ROW 1.13 COL 1.86 WIDGET-ID 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.72 ROW 3
         SIZE 77.29 BY 10.79.

DEFINE FRAME f-objetivo
     c-objetivo AT ROW 1.46 COL 2.29 NO-LABEL
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 4
         SIZE 76 BY 7.25
         TITLE "Objetivo" WIDGET-ID 100.

DEFINE FRAME f-relat
     bt-executar AT ROW 14.54 COL 3 HELP
          "Dispara a execuá∆o do relat¢rio"
     bt-cancelar AT ROW 14.54 COL 14 HELP
          "Fechar"
     bt-ajuda AT ROW 14.54 COL 70 HELP
          "Ajuda"
     rt-folder AT ROW 2.5 COL 2
     RECT-1 AT ROW 14.29 COL 2
     rt-folder-top AT ROW 2.54 COL 2.14
     rt-folder-left AT ROW 2.54 COL 2.14
     rt-folder-right AT ROW 2.67 COL 80.43
     RECT-6 AT ROW 13.75 COL 2.14
     im-pg-imp AT ROW 1.5 COL 33.86
     im-pg-par AT ROW 1.5 COL 18
     im-pg-sel AT ROW 1.5 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 81 BY 15
         DEFAULT-BUTTON bt-executar.

DEFINE FRAME f-pg-sel
     it-codigo-ini AT ROW 4.46 COL 11.29 WIDGET-ID 106
     it-codigo-fim AT ROW 4.46 COL 49.14 NO-LABEL WIDGET-ID 104
     estado-origem-ini AT ROW 5.5 COL 5.29 WIDGET-ID 98
     estado-origem-fim AT ROW 5.5 COL 49.14 NO-LABEL WIDGET-ID 96
     estado-destino-ini AT ROW 6.5 COL 4.86 WIDGET-ID 102
     estado-destino-fim AT ROW 6.5 COL 49.14 NO-LABEL WIDGET-ID 100
     IMAGE-1 AT ROW 4.46 COL 39.14 WIDGET-ID 76
     IMAGE-2 AT ROW 4.46 COL 44.14 WIDGET-ID 78
     IMAGE-3 AT ROW 6.5 COL 39.14 WIDGET-ID 80
     IMAGE-4 AT ROW 6.5 COL 44.14 WIDGET-ID 82
     IMAGE-7 AT ROW 5.5 COL 39.14 WIDGET-ID 88
     IMAGE-8 AT ROW 5.5 COL 44.14 WIDGET-ID 90
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.86 ROW 2.83
         SIZE 76.86 BY 10.62 WIDGET-ID 200.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-relat
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-relat ASSIGN
         HIDDEN             = YES
         TITLE              = "Importacao Excel"
         HEIGHT             = 15.25
         WIDTH              = 81.14
         MAX-HEIGHT         = 29.33
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 29.33
         VIRTUAL-WIDTH      = 195.14
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-relat 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/w-relat.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-relat
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME f-objetivo:FRAME = FRAME f-pg-par:HANDLE
       FRAME f-pg-sel:FRAME = FRAME f-relat:HANDLE.

/* SETTINGS FOR FRAME f-objetivo
   FRAME-NAME                                                           */
ASSIGN 
       c-objetivo:AUTO-INDENT IN FRAME f-objetivo      = TRUE
       c-objetivo:AUTO-RESIZE IN FRAME f-objetivo      = TRUE
       c-objetivo:READ-ONLY IN FRAME f-objetivo        = TRUE.

/* SETTINGS FOR FRAME f-pg-imp
                                                                        */
/* SETTINGS FOR RADIO-SET rs-execucao IN FRAME f-pg-imp
   NO-ENABLE                                                            */
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
/* SETTINGS FOR FRAME f-pg-sel
   Custom                                                               */
/* SETTINGS FOR FILL-IN estado-destino-fim IN FRAME f-pg-sel
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN estado-destino-ini IN FRAME f-pg-sel
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN estado-origem-fim IN FRAME f-pg-sel
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN estado-origem-ini IN FRAME f-pg-sel
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN it-codigo-fim IN FRAME f-pg-sel
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN it-codigo-ini IN FRAME f-pg-sel
   ALIGN-L                                                              */
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
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-relat)
THEN w-relat:HIDDEN = no.

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
     _Query            is NOT OPENED
*/  /* FRAME f-pg-sel */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-relat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-relat w-relat
ON END-ERROR OF w-relat /* Importacao Excel */
OR  ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-relat w-relat
ON WINDOW-CLOSE OF w-relat /* Importacao Excel */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-ajuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ajuda w-relat
ON CHOOSE OF bt-ajuda IN FRAME f-relat /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME bt-arquivo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-arquivo w-relat
ON CHOOSE OF bt-arquivo IN FRAME f-pg-imp
DO:
    {include/i-rparq.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar w-relat
ON CHOOSE OF bt-cancelar IN FRAME f-relat /* Fechar */
DO:
    APPLY 'CLOSE' TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME bt-config-impr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-config-impr w-relat
ON CHOOSE OF bt-config-impr IN FRAME f-pg-imp
DO:
    {include/i-rpimp.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-executar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-executar w-relat
ON CHOOSE OF bt-executar IN FRAME f-relat /* Executar */
DO:
    DO  ON ERROR UNDO, RETURN NO-APPLY:
        RUN PI-Executar.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-par
&Scoped-define SELF-NAME bt-planilha
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-planilha w-relat
ON CHOOSE OF bt-planilha IN FRAME f-pg-par
DO:

    ASSIGN c-arq-aux = SEARCH (REPLACE (INPUT FRAME f-Pg-Par c-planilha, '/', '\')).
    
    SYSTEM-DIALOG GET-FILE          c-arq-aux
                  FILTERS           "*.csv" "*.CSV",  
                                    "*.*" "*.*"
                  DEFAULT-EXTENSION "csv"
                  USE-FILENAME
                  ASK-OVERWRITE
                  SAVE-AS
                  UPDATE            l-ok.

    IF  l-ok THEN
        ASSIGN c-planilha :SCREEN-VALUE IN FRAME f-pg-par = REPLACE (c-arq-aux, '\', '/'). 
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME im-pg-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-imp w-relat
ON MOUSE-SELECT-CLICK OF im-pg-imp IN FRAME f-relat
DO:
    RUN PI-Troca-Pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-par w-relat
ON MOUSE-SELECT-CLICK OF im-pg-par IN FRAME f-relat
DO:
    RUN PI-Troca-Pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-sel w-relat
ON MOUSE-SELECT-CLICK OF im-pg-sel IN FRAME f-relat
DO:
    RUN PI-Troca-Pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME rs-destino
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-destino w-relat
ON VALUE-CHANGED OF rs-destino IN FRAME f-pg-imp
DO: 

    DO  WITH FRAME f-pg-imp:

        CASE SELF:SCREEN-VALUE:

            WHEN "1" THEN
                
                ASSIGN c-arquivo      :SENSITIVE = NO
                       bt-arquivo     :VISIBLE   = NO
                       bt-config-impr :VISIBLE   = YES.
            
            WHEN "2" THEN 
                
                ASSIGN c-arquivo      :SENSITIVE = YES
                       bt-arquivo     :VISIBLE   = YES
                       bt-config-impr :VISIBLE   = NO.

            WHEN "3" THEN
                
                ASSIGN c-arquivo      :SENSITIVE = NO
                       bt-arquivo     :VISIBLE   = NO
                       bt-config-impr :VISIBLE   = NO.

        END CASE.

    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-execucao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-execucao w-relat
ON VALUE-CHANGED OF rs-execucao IN FRAME f-pg-imp
DO:
    {include/i-rprse.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-objetivo
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-relat 


/* ***************************  Main Block  *************************** */

ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

{utp/ut9000.i "ESP003" "2.06.00.000"}

{include/i-rpini.i}

ASSIGN c-planilha      = SESSION :TEMP-DIRECTORY + 'esp002.csv'.


    ASSIGN c-Objetivo = "O objetivo deste programa especial e realizar a importacao (atualizacao dos registros) constantes da planilha excel, gerados pelo programa esp002, obedecendo os campos de selecao, iremos atualizar as seguintes tabelas item-uf e unid-feder quando forem modificados.":U + CHR(10) + CHR(10) +
                        "A planilha excel devera seguir o layout definido, separados por ponto e virgula, contendo as seguintes colunas : ":U + CHR(10) +  
                        "A-Item (item.it-codigo - cd0204)":U + CHR(10) +  
                        "B-Descriá∆o Item (item.desc-item - cd0204)":U + CHR(10) +  
                        "C-Grupo Estoque (item.ge-codigo - cd0204)":U + CHR(10) + 
                        "D-EAN (int-ds-ean-item.codigo-ean - nicd0204)":U + CHR(10) +  
                        "E-UF (item-uf.estado - cd0904a)":U + CHR(10) + 
                        "F-TR (se unid-feder.ind-uf-subs = yes (cd0904), ler item-uf.per-sub-tri (cd0904a), se > 0 ent∆o = 5)":U + CHR(10) + 
                        "G-ALIQ (item-uf.d-val-icms-est-sub - cd0904a)% Subs Trib":U + CHR(10) +  
                        "H-RED (item-uf.per-red-sub - cd0904a)":U + CHR(10) +  
                        "I-TR.E (se unid-feder.ind-uf-subs = yes (cd0904), ler item-uf.per-sub-tri (cd0904a), se > 0 ent∆o = 5)":U + CHR(10) +  
                        "J-AL.E (item-uf.d-val-icms-est-sub - cd0904a)":U + CHR(10) + 
                        "K-TR.I (se unid-feder.per-icms-ext >  0 (cd0904), ent∆o = 5)":U + CHR(10) +
                        "L-AL.I (unid-feder.per-icms-ext)":U + CHR(10) +
                        "M-RED.E (se item-uf.estado <> PR, ent∆o item-uf.per-red-sub (cd0904a) )":U + CHR(10) +
                        "N-RED.I (se item-uf.estado = PR, ent∆o item-uf.per-red-sub (cd0904a) )":U + CHR(10) +
                        "O-ST.E  (item-uf.per-sub-tri quando item-uf.estado <> PR)":U + CHR(10) +
                        "P-ST.I (item-uf.per-sub-tri quando item-uf.estado = PR)":U + CHR(10)  +
                        "Q-ICMS (item-uf.d-val-icms-est-sub quando item-uf.estado <> PR)":U + CHR(10) +
                        "R-RBST (10)":U + CHR(10)  +
                        "S-RAST (0)":U + CHR(10) +
                        "T-RBEST (33,33)":U + CHR(10) +
                        "U-IPI (0)":U + CHR(10) +
                        "V-LISTA ()":U + CHR(10) + 
                        "W-NCM (item.class-fiscal - cd0903)":U + CHR(10) +
                        "X-CSTA (item.codigo-orig - cd0903)":U + CHR(10) +
                        "Y-IES (se item.codigo-orig = 0 / 4 se item.codigo-orig <> 0)":U + CHR(10) + CHR(10).

ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

{include/i-rplbl.i}

PAUSE 0 BEFORE-HIDE.

MAIN-BLOCK:

DO  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    RUN enable_UI.
  
    {include/i-rpmbl.i}

  
    IF  NOT THIS-PROCEDURE:PERSISTENT THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-relat  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-relat  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-relat  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-relat)
  THEN DELETE WIDGET w-relat.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-relat  _DEFAULT-ENABLE
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
      WITH FRAME f-relat IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-relat}
  DISPLAY it-codigo-ini it-codigo-fim estado-origem-ini estado-origem-fim 
          estado-destino-ini estado-destino-fim 
      WITH FRAME f-pg-sel IN WINDOW w-relat.
  ENABLE it-codigo-ini it-codigo-fim estado-origem-ini estado-origem-fim 
         estado-destino-ini estado-destino-fim IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 
         IMAGE-7 IMAGE-8 
      WITH FRAME f-pg-sel IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-sel}
  DISPLAY c-planilha 
      WITH FRAME f-pg-par IN WINDOW w-relat.
  ENABLE RECT-25 bt-planilha c-planilha 
      WITH FRAME f-pg-par IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-par}
  DISPLAY rs-destino c-arquivo rs-execucao 
      WITH FRAME f-pg-imp IN WINDOW w-relat.
  ENABLE RECT-7 RECT-9 rs-destino bt-arquivo bt-config-impr c-arquivo 
      WITH FRAME f-pg-imp IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-imp}
  DISPLAY c-objetivo 
      WITH FRAME f-objetivo IN WINDOW w-relat.
  ENABLE c-objetivo 
      WITH FRAME f-objetivo IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-objetivo}
  VIEW w-relat.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-relat 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-executar w-relat 
PROCEDURE pi-executar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DO  ON ERROR UNDO, RETURN ERROR ON STOP UNDO, RETURN ERROR:
        
        {include/i-rpexa.i}

        /** VALIDACOES DA PAGINA DE SELECAO ***********************************/

            /** VALIDACOES DA PAGINA DE SELECAO ***********************************/

/*             IF  INPUT FRAME f-pg-sel cod-estab-ini > INPUT FRAME f-pg-sel cod-estab-fim THEN DO:                               */
/*                 RUN utp/ut-msgs.p (INPUT 'SHOW':U,                                                                             */
/*                                    INPUT 17006,                                                                                */
/*                                    INPUT 'Estabelecimento Final nao pode ser maior que o estabelecimento inicial':U + '~~':U + */
/*                                          'Verifique os parametros de selecao de estabelecimento informados.':U).               */
/*                 APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel      IN FRAME f-relat.                                               */
/*                 APPLY 'ENTRY':U              TO cod-estab-ini IN FRAME f-pg-sel.                                               */
/*                 RETURN ERROR.                                                                                                  */
/*             END.                                                                                                               */

            IF  INPUT FRAME f-pg-sel it-codigo-ini > INPUT FRAME f-pg-sel it-codigo-fim THEN DO:
                RUN utp/ut-msgs.p (INPUT 'SHOW':U,
                                   INPUT 17006,
                                   INPUT 'Codigo do item Final nao pode ser maior que o item inicial':U + '~~':U + 
                                         'Verifique os parametros de selecao de itens informados.':U).
                APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel        IN FRAME f-relat.
                APPLY 'ENTRY':U              TO it-codigo-ini IN FRAME f-pg-sel.
                RETURN ERROR.
            END.

/*             IF  INPUT FRAME f-pg-sel desc-item-ini > INPUT FRAME f-pg-sel desc-item-fim THEN DO:                                   */
/*                 RUN utp/ut-msgs.p (INPUT 'SHOW':U,                                                                                 */
/*                                    INPUT 17006,                                                                                    */
/*                                    INPUT 'Descricao do Item Final nao pode ser maior que a descricao do item inicial':U + '~~':U + */
/*                                          'Verifique os parametros de selecao de descricao de itens informados.':U).                */
/*                 APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel        IN FRAME f-relat.                                                 */
/*                 APPLY 'ENTRY':U              TO it-codigo-ini IN FRAME f-pg-sel.                                                   */
/*                 RETURN ERROR.                                                                                                      */
/*             END.                                                                                                                   */

            IF  INPUT FRAME f-pg-sel estado-origem-ini > INPUT FRAME f-pg-sel estado-origem-fim THEN DO:
                RUN utp/ut-msgs.p (INPUT 'SHOW':U,
                                   INPUT 17006,
                                   INPUT 'Estado Origem Final nao pode ser maior que o estado origem inicial':U + '~~':U + 
                                         'Verifique os parametros de selecao de estados informados.':U).
                APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel       IN FRAME f-relat.
                APPLY 'ENTRY':U              TO estado-origem-ini IN FRAME f-pg-sel.
                RETURN ERROR.
            END.

            IF  INPUT FRAME f-pg-sel estado-destino-ini > INPUT FRAME f-pg-sel estado-destino-fim THEN DO:
                RUN utp/ut-msgs.p (INPUT 'SHOW':U,
                                   INPUT 17006,
                                   INPUT 'Estado Destino Final nao pode ser maior que o estado destino inicial':U + '~~':U + 
                                         'Verifique os parametros de selecao de estados informados.':U).
                APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel          IN FRAME f-relat.
                APPLY 'ENTRY':U              TO estado-destino-ini IN FRAME f-pg-sel.
                RETURN ERROR.
            END.

/*             IF  INPUT FRAME f-pg-sel ge-codigo-ini > INPUT FRAME f-pg-sel ge-codigo-fim THEN DO:                                 */
/*                 RUN utp/ut-msgs.p (INPUT 'SHOW':U,                                                                               */
/*                                    INPUT 17006,                                                                                  */
/*                                    INPUT 'Grupo de estoque Final nao pode ser maior que o grupo de estoque inicial':U + '~~':U + */
/*                                          'Verifique os parametros de selecao de grupos de estoque informados.':U).               */
/*                 APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel     IN FRAME f-relat.                                                  */
/*                 APPLY 'ENTRY':U              TO ge-codigo-ini IN FRAME f-pg-sel.                                                 */
/*                 RETURN ERROR.                                                                                                    */
/*             END.                                                                                                                 */

/*             IF  INPUT FRAME f-pg-sel fm-codigo-ini > INPUT FRAME f-pg-sel fm-codigo-fim THEN DO:                                       */
/*                 RUN utp/ut-msgs.p (INPUT 'SHOW':U,                                                                                     */
/*                                    INPUT 17006,                                                                                        */
/*                                    INPUT 'Familia de material Final nao pode ser maior que o familia de material inicial':U + '~~':U + */
/*                                          'Verifique os parametros de selecao de familia de material informados.':U).                   */
/*                 APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel     IN FRAME f-relat.                                                        */
/*                 APPLY 'ENTRY':U              TO fm-codigo-ini IN FRAME f-pg-sel.                                                       */
/*                 RETURN ERROR.                                                                                                          */
/*             END.                                                                                                                       */

            IF  SEARCH (INPUT FRAME f-pg-par c-planilha) = ? THEN DO:
                RUN utp/ut-msgs.p (INPUT 'Show':U,
                                   INPUT 17006,
                                   INPUT 'Planilha Informada nao encontrada !':U + '~~':U +
                                         'Verifique a existencia do arquivo informado.':U).
                 
                APPLY 'Mouse-Select-Click':U TO im-pg-par  IN FRAME f-relat.
                APPLY 'Entry':U              TO c-planilha IN FRAME f-pg-par.
                RETURN ERROR.
                 
            END.

        /** VALIDACOES DA PAGINA DE IMPRESSAO *********************************/

        IF  INPUT FRAME f-pg-imp rs-destino  = 2 AND
            INPUT FRAME f-pg-imp rs-execucao = 1 THEN DO:
            
            RUN utp/ut-vlarq.p (INPUT INPUT FRAME f-pg-imp c-arquivo).
            
            IF  RETURN-VALUE = 'NOK':U THEN DO:
                RUN utp/ut-msgs.p (INPUT 'show':U, 
                                   INPUT 73, 
                                   INPUT '').
                APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-imp IN FRAME f-relat.
                APPLY 'ENTRY':U              TO c-arquivo IN FRAME f-pg-imp.
                RETURN ERROR.
            END.

        END.

        /** ATUALIZACOES DOS DADOS PARA IMPRESSAO *****************************/

        CREATE tt-param.
        ASSIGN tt-param.usuario   = c-seg-usuario
               tt-param.destino   = INPUT FRAME f-pg-imp rs-destino
               tt-param.data-exec = TODAY  
               tt-param.hora-exec = TIME.
        
        IF  tt-param.destino = 1 THEN DO: 
            ASSIGN tt-param.arquivo = '':U.
        END.
        ELSE DO: 
            IF  tt-param.destino = 2 THEN DO: 
                ASSIGN tt-param.arquivo = INPUT FRAME f-pg-imp c-arquivo.
            END.
            ELSE DO: 
                ASSIGN tt-param.arquivo = SESSION:TEMP-DIRECTORY + CAPS (c-programa-mg97) + '.TMP'.
            END.
        END. 
        
        ASSIGN /* tt-param.cod-estab-ini         = INPUT FRAME f-pg-sel cod-estab-ini     
               tt-param.cod-estab-fim         = INPUT FRAME f-pg-sel cod-estab-fim     */
               tt-param.it-codigo-ini         = INPUT FRAME f-pg-sel it-codigo-ini     
               tt-param.it-codigo-fim         = INPUT FRAME f-pg-sel it-codigo-fim     
               tt-param.estado-origem-ini     = INPUT FRAME f-pg-sel estado-origem-ini 
               tt-param.estado-origem-fim     = INPUT FRAME f-pg-sel estado-origem-fim 
               tt-param.estado-destino-ini    = INPUT FRAME f-pg-sel estado-destino-ini
               tt-param.estado-destino-fim    = INPUT FRAME f-pg-sel estado-destino-fim
/*                tt-param.desc-item-ini         = INPUT FRAME f-pg-sel desc-item-ini */
/*                tt-param.desc-item-fim         = INPUT FRAME f-pg-sel desc-item-fim */
/*                tt-param.ge-codigo-ini         = INPUT FRAME f-pg-sel ge-codigo-ini */
/*                tt-param.ge-codigo-fim         = INPUT FRAME f-pg-sel ge-codigo-fim */
/*                tt-param.fm-codigo-ini         = INPUT FRAME f-pg-sel fm-codigo-ini */
/*                tt-param.fm-codigo-fim         = INPUT FRAME f-pg-sel fm-codigo-fim */
               tt-param.planilha              = INPUT FRAME f-pg-par c-planilha .

        /** EXECUCAO DO RELATORIO *********************************************/

        {include/i-rpexb.i}
        
        SESSION:SET-WAIT-STATE('GENERAL':U).
        
        {include/i-rprun.i intprg/esp003rp.p}
        
        {include/i-rpexc.i}
        
        SESSION:SET-WAIT-STATE('':U).
        
        {include/i-rptrm.i}

    END.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-troca-pagina w-relat 
PROCEDURE pi-troca-pagina :
/*------------------------------------------------------------------------------
  Purpose: Gerencia a Troca de P†gina (folder)   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    {include/i-rptrp.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-relat  _ADM-SEND-RECORDS
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-relat 
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

