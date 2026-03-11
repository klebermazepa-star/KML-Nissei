&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-relat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-relat 
{include/i-prgvrs.i INT090 2.00.00.000}  

CREATE WIDGET-POOL.

&GLOBAL-DEFINE      PGSEL                       f-pg-sel
&GLOBAL-DEFINE      PGCLA
&GLOBAL-DEFINE      PGPAR                       
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
       FIELD cod-estab-ini      as character FORMAT "x(3)"
       FIELD cod-estab-fim      as character FORMAT "x(3)"
       FIELD it-codigo-ini      as character FORMAT "x(16)"
       FIELD it-codigo-fim      as character FORMAT "x(16)"
       FIELD tg-pr              AS LOG       
       FIELD tg-sp              AS LOG
       FIELD tg-sc              AS LOG
       FIELD tg-go              AS LOG
       FIELD tg-df              AS LOG
       FIELD tg-pr-dest         AS LOG       
       FIELD tg-sp-dest         AS LOG
       FIELD tg-sc-dest         AS LOG
       FIELD tg-go-dest         AS LOG
       FIELD tg-df-dest         AS LOG
       FIELD ge-codigo-ini      AS INTEGER   FORMAT ">9"
       FIELD ge-codigo-fim      AS INTEGER   FORMAT ">9"
       FIELD fm-codigo-ini      AS CHARACTER FORMAT "x(8)"
       FIELD fm-codigo-fim      AS CHARACTER FORMAT "x(8)"
       FIELD clas-fiscal-ini    AS CHARACTER FORMAT "9999.99.99" /* ncm */
       FIELD clas-fiscal-fim    AS CHARACTER FORMAT "9999.99.99"
       FIELD cst-ini            AS INTEGER   FORMAT ">9"
       FIELD cst-fim            AS INTEGER   FORMAT ">9"
       FIELD com-subst-tribut   AS LOG         
       FIELD sem-subst-tribut   AS LOG
       FIELD forc-integ         AS LOG.

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
&Scoped-define FRAME-NAME f-pg-imp

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-7 RECT-9 rs-destino bt-arquivo ~
bt-config-impr c-arquivo 
&Scoped-Define DISPLAYED-OBJECTS rs-destino c-arquivo rs-execucao 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-relat AS WIDGET-HANDLE NO-UNDO.

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

DEFINE VARIABLE clas-fiscal-fim AS CHARACTER FORMAT "9999.99.99" INITIAL "99999999" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE clas-fiscal-ini AS CHARACTER FORMAT "9999.99.99" INITIAL "00000000" 
     LABEL "NCM" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE cod-estab-fim AS CHARACTER FORMAT "x(3)" INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE cod-estab-ini AS CHARACTER FORMAT "x(3)" 
     LABEL "Estabel" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE cst-fim AS INTEGER FORMAT ">9" INITIAL 99 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE cst-ini AS INTEGER FORMAT ">9" INITIAL 0 
     LABEL "CST" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE fm-codigo-fim AS CHARACTER FORMAT "x(08)" INITIAL "ZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE fm-codigo-ini AS CHARACTER FORMAT "x(08)" 
     LABEL "Fam.Material" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE ge-codigo-fim AS INTEGER FORMAT ">9" INITIAL 99 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE ge-codigo-ini AS INTEGER FORMAT ">9" INITIAL 0 
     LABEL "Grupo Estoque" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88
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

DEFINE IMAGE IMAGE-11
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-13
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-14
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-15
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-16
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-17
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-18
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 32 BY 1.25.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 32 BY 1.25.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 35 BY 2.25.

DEFINE VARIABLE com-subst-tribut AS LOGICAL INITIAL yes 
     LABEL "Substituicao Tributaria" 
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .83 NO-UNDO.

DEFINE VARIABLE forc-integ AS LOGICAL INITIAL no 
     LABEL "Foráar integraá∆o" 
     VIEW-AS TOGGLE-BOX
     SIZE 23.43 BY .83 NO-UNDO.

DEFINE VARIABLE sem-subst-tribut AS LOGICAL INITIAL yes 
     LABEL "Sem SubstituicaoTributaria" 
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY .83 NO-UNDO.

DEFINE VARIABLE tg-DF AS LOGICAL INITIAL yes 
     LABEL "DF" 
     VIEW-AS TOGGLE-BOX
     SIZE 5.72 BY .79 NO-UNDO.

DEFINE VARIABLE tg-DF-Dest AS LOGICAL INITIAL yes 
     LABEL "DF" 
     VIEW-AS TOGGLE-BOX
     SIZE 5.14 BY .79 NO-UNDO.

DEFINE VARIABLE tg-GO AS LOGICAL INITIAL yes 
     LABEL "GO" 
     VIEW-AS TOGGLE-BOX
     SIZE 5.72 BY .79 NO-UNDO.

DEFINE VARIABLE tg-GO-Dest AS LOGICAL INITIAL yes 
     LABEL "GO" 
     VIEW-AS TOGGLE-BOX
     SIZE 5.14 BY .79 NO-UNDO.

DEFINE VARIABLE tg-PR AS LOGICAL INITIAL yes 
     LABEL "PR" 
     VIEW-AS TOGGLE-BOX
     SIZE 7 BY .79 NO-UNDO.

DEFINE VARIABLE tg-PR-dest AS LOGICAL INITIAL yes 
     LABEL "PR" 
     VIEW-AS TOGGLE-BOX
     SIZE 7 BY .79 NO-UNDO.

DEFINE VARIABLE tg-SC AS LOGICAL INITIAL yes 
     LABEL "SC" 
     VIEW-AS TOGGLE-BOX
     SIZE 5.72 BY .79 NO-UNDO.

DEFINE VARIABLE tg-SC-Dest AS LOGICAL INITIAL yes 
     LABEL "SC" 
     VIEW-AS TOGGLE-BOX
     SIZE 5.14 BY .79 NO-UNDO.

DEFINE VARIABLE tg-SP AS LOGICAL INITIAL yes 
     LABEL "SP" 
     VIEW-AS TOGGLE-BOX
     SIZE 7 BY .79 NO-UNDO.

DEFINE VARIABLE tg-SP-Dest AS LOGICAL INITIAL yes 
     LABEL "SP" 
     VIEW-AS TOGGLE-BOX
     SIZE 7 BY .79 NO-UNDO.

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
     im-pg-imp AT ROW 1.5 COL 18
     im-pg-sel AT ROW 1.5 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 81 BY 15
         DEFAULT-BUTTON bt-executar.

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

DEFINE FRAME f-pg-sel
     cod-estab-ini AT ROW 1.5 COL 18 COLON-ALIGNED WIDGET-ID 94
     cod-estab-fim AT ROW 1.5 COL 48.29 NO-LABEL WIDGET-ID 92
     it-codigo-ini AT ROW 2.5 COL 18 COLON-ALIGNED WIDGET-ID 106
     it-codigo-fim AT ROW 2.5 COL 48.29 NO-LABEL WIDGET-ID 104
     ge-codigo-ini AT ROW 3.5 COL 18 COLON-ALIGNED WIDGET-ID 130
     ge-codigo-fim AT ROW 3.5 COL 48.29 NO-LABEL WIDGET-ID 128
     fm-codigo-ini AT ROW 4.5 COL 18 COLON-ALIGNED WIDGET-ID 126
     fm-codigo-fim AT ROW 4.5 COL 48.29 NO-LABEL WIDGET-ID 124
     clas-fiscal-ini AT ROW 5.5 COL 18 COLON-ALIGNED WIDGET-ID 134
     clas-fiscal-fim AT ROW 5.5 COL 48.29 NO-LABEL WIDGET-ID 132
     cst-ini AT ROW 6.5 COL 18 COLON-ALIGNED WIDGET-ID 142
     cst-fim AT ROW 6.5 COL 48.29 NO-LABEL WIDGET-ID 140
     tg-PR AT ROW 8.25 COL 7 WIDGET-ID 152
     tg-SP AT ROW 8.25 COL 13 WIDGET-ID 156
     tg-SC AT ROW 8.25 COL 18.72 WIDGET-ID 160
     tg-PR-dest AT ROW 10.5 COL 6.86 WIDGET-ID 154
     tg-SP-Dest AT ROW 10.5 COL 12.86 WIDGET-ID 158
     tg-SC-Dest AT ROW 10.5 COL 18.72 WIDGET-ID 162
     com-subst-tribut AT ROW 8.25 COL 45.14 WIDGET-ID 148
     sem-subst-tribut AT ROW 9.13 COL 45 WIDGET-ID 150
     forc-integ AT ROW 10.63 COL 45 WIDGET-ID 174
     tg-GO AT ROW 8.25 COL 24.29 WIDGET-ID 176
     tg-DF AT ROW 8.25 COL 30 WIDGET-ID 178
     tg-GO-Dest AT ROW 10.5 COL 24.43 WIDGET-ID 180
     tg-DF-Dest AT ROW 10.5 COL 30 WIDGET-ID 182
     "Origem" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 7.58 COL 6 WIDGET-ID 166
     "Destino" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 9.88 COL 5.72 WIDGET-ID 170
     IMAGE-1 AT ROW 2.5 COL 37.57 WIDGET-ID 76
     IMAGE-2 AT ROW 2.5 COL 45 WIDGET-ID 78
     IMAGE-5 AT ROW 1.5 COL 37.57 WIDGET-ID 84
     IMAGE-6 AT ROW 1.5 COL 45 WIDGET-ID 86
     IMAGE-11 AT ROW 4.5 COL 37.57 WIDGET-ID 116
     IMAGE-12 AT ROW 4.5 COL 45 WIDGET-ID 118
     IMAGE-13 AT ROW 3.5 COL 37.57 WIDGET-ID 120
     IMAGE-14 AT ROW 3.5 COL 45 WIDGET-ID 122
     IMAGE-15 AT ROW 5.5 COL 37.57 WIDGET-ID 136
     IMAGE-16 AT ROW 5.5 COL 45 WIDGET-ID 138
     IMAGE-17 AT ROW 6.5 COL 37.57 WIDGET-ID 144
     IMAGE-18 AT ROW 6.5 COL 45 WIDGET-ID 146
     RECT-10 AT ROW 7.96 COL 5 WIDGET-ID 164
     RECT-11 AT ROW 10.21 COL 5 WIDGET-ID 168
     RECT-12 AT ROW 8 COL 42 WIDGET-ID 172
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.86 ROW 2.83
         SIZE 76.86 BY 10.62
         FONT 4.


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
         TITLE              = "Integraá∆o Parametrizaá∆o Fiscal Itens"
         HEIGHT             = 15.25
         WIDTH              = 81.72
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
/* SETTINGS FOR FRAME f-pg-imp
   FRAME-NAME                                                           */
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

/* SETTINGS FOR FRAME f-pg-sel
   Custom                                                               */
/* SETTINGS FOR FILL-IN clas-fiscal-fim IN FRAME f-pg-sel
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN cod-estab-fim IN FRAME f-pg-sel
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN cst-fim IN FRAME f-pg-sel
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fm-codigo-fim IN FRAME f-pg-sel
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ge-codigo-fim IN FRAME f-pg-sel
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN it-codigo-fim IN FRAME f-pg-sel
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
ON END-ERROR OF w-relat /* Integraá∆o Parametrizaá∆o Fiscal Itens */
OR  ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-relat w-relat
ON WINDOW-CLOSE OF w-relat /* Integraá∆o Parametrizaá∆o Fiscal Itens */
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


&Scoped-define FRAME-NAME f-pg-sel
&Scoped-define SELF-NAME forc-integ
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL forc-integ w-relat
ON VALUE-CHANGED OF forc-integ IN FRAME f-pg-sel /* Foráar integraá∆o */
DO:
    IF INPUT FRAME f-pg-sel it-codigo-ini  <> INPUT FRAME f-pg-sel it-codigo-fim THEN DO:

        ASSIGN INPUT FRAME f-pg-sel forc-integ:SENSITIVE = NO
               INPUT FRAME f-pg-sel forc-integ:CHECKED = NO.
        MESSAGE "foráar a integraá∆o s¢ Ç possivel para filtro de um £nico item "
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
    END.
    ELSE DO:

        ASSIGN INPUT FRAME f-pg-sel forc-integ:SENSITIVE = YES.


    END.
  
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


&Scoped-define SELF-NAME im-pg-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-sel w-relat
ON MOUSE-SELECT-CLICK OF im-pg-sel IN FRAME f-relat
DO:
    RUN PI-Troca-Pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-sel
&Scoped-define SELF-NAME it-codigo-fim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL it-codigo-fim w-relat
ON LEAVE OF it-codigo-fim IN FRAME f-pg-sel
DO:
    
    IF INPUT FRAME f-pg-sel it-codigo-ini  <> INPUT FRAME f-pg-sel it-codigo-fim THEN DO:

      ASSIGN INPUT FRAME f-pg-sel forc-integ:SENSITIVE = NO
             INPUT FRAME f-pg-sel forc-integ:CHECKED = NO.

    END.
    ELSE 
        ASSIGN INPUT FRAME f-pg-sel forc-integ:SENSITIVE = YES.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME it-codigo-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL it-codigo-ini w-relat
ON LEAVE OF it-codigo-ini IN FRAME f-pg-sel /* Item */
DO:
      
    IF INPUT FRAME f-pg-sel it-codigo-ini  <> INPUT FRAME f-pg-sel it-codigo-fim THEN DO:

      ASSIGN INPUT FRAME f-pg-sel forc-integ:SENSITIVE = NO
             INPUT FRAME f-pg-sel forc-integ:CHECKED = NO.

    END.
    ELSE 
        ASSIGN INPUT FRAME f-pg-sel forc-integ:SENSITIVE = YES.


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


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-relat 


/* ***************************  Main Block  *************************** */

ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

{utp/ut9000.i "INT090" "2.00.00.000"}

{include/i-rpini.i}

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
  ENABLE im-pg-imp im-pg-sel bt-executar bt-cancelar bt-ajuda 
      WITH FRAME f-relat IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-relat}
  DISPLAY cod-estab-ini cod-estab-fim it-codigo-ini it-codigo-fim ge-codigo-ini 
          ge-codigo-fim fm-codigo-ini fm-codigo-fim clas-fiscal-ini 
          clas-fiscal-fim cst-ini cst-fim tg-PR tg-SP tg-SC tg-PR-dest 
          tg-SP-Dest tg-SC-Dest com-subst-tribut sem-subst-tribut forc-integ 
          tg-GO tg-DF tg-GO-Dest tg-DF-Dest 
      WITH FRAME f-pg-sel IN WINDOW w-relat.
  ENABLE cod-estab-ini cod-estab-fim it-codigo-ini it-codigo-fim ge-codigo-ini 
         ge-codigo-fim fm-codigo-ini fm-codigo-fim clas-fiscal-ini 
         clas-fiscal-fim cst-ini cst-fim tg-PR tg-SP tg-SC tg-PR-dest 
         tg-SP-Dest tg-SC-Dest com-subst-tribut sem-subst-tribut forc-integ 
         IMAGE-1 IMAGE-2 IMAGE-5 IMAGE-6 IMAGE-11 IMAGE-12 IMAGE-13 IMAGE-14 
         IMAGE-15 IMAGE-16 IMAGE-17 IMAGE-18 RECT-10 RECT-11 RECT-12 tg-GO 
         tg-DF tg-GO-Dest tg-DF-Dest 
      WITH FRAME f-pg-sel IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-sel}
  DISPLAY rs-destino c-arquivo rs-execucao 
      WITH FRAME f-pg-imp IN WINDOW w-relat.
  ENABLE RECT-7 RECT-9 rs-destino bt-arquivo bt-config-impr c-arquivo 
      WITH FRAME f-pg-imp IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-imp}
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

        IF  INPUT FRAME f-pg-sel cod-estab-ini > INPUT FRAME f-pg-sel cod-estab-fim THEN DO:
            RUN utp/ut-msgs.p (INPUT 'SHOW':U,
                               INPUT 17006,
                               INPUT 'Estabelecimento Final nao pode ser maior que o estabelecimento inicial':U + '~~':U + 
                                     'Verifique os parametros de selecao de estabelecimento informados.':U).
            APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel      IN FRAME f-relat.
            APPLY 'ENTRY':U              TO cod-estab-ini IN FRAME f-pg-sel.
            RETURN ERROR.
        END.

        IF  INPUT FRAME f-pg-sel it-codigo-ini > INPUT FRAME f-pg-sel it-codigo-fim THEN DO:
            RUN utp/ut-msgs.p (INPUT 'SHOW':U,
                               INPUT 17006,
                               INPUT 'Codigo do item Final nao pode ser maior que o item inicial':U + '~~':U + 
                                     'Verifique os parametros de selecao de itens informados.':U).
            APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel        IN FRAME f-relat.
            APPLY 'ENTRY':U              TO it-codigo-ini IN FRAME f-pg-sel.
            RETURN ERROR.
        END.

        IF  INPUT FRAME f-pg-sel ge-codigo-ini > INPUT FRAME f-pg-sel ge-codigo-fim THEN DO:
            RUN utp/ut-msgs.p (INPUT 'SHOW':U,
                               INPUT 17006,
                               INPUT 'Grupo de estoque Final nao pode ser maior que o grupo de estoque inicial':U + '~~':U + 
                                     'Verifique os parametros de selecao de grupos de estoque informados.':U).
            APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel     IN FRAME f-relat.
            APPLY 'ENTRY':U              TO ge-codigo-ini IN FRAME f-pg-sel.
            RETURN ERROR.
        END.

        IF  INPUT FRAME f-pg-sel fm-codigo-ini > INPUT FRAME f-pg-sel fm-codigo-fim THEN DO:
            RUN utp/ut-msgs.p (INPUT 'SHOW':U,
                               INPUT 17006,
                               INPUT 'Familia de material Final nao pode ser maior que o familia de material inicial':U + '~~':U +
                                     'Verifique os parametros de selecao de familia de material informados.':U).
            APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel     IN FRAME f-relat.
            APPLY 'ENTRY':U              TO fm-codigo-ini IN FRAME f-pg-sel.
            RETURN ERROR.
        END.

        IF  INPUT FRAME f-pg-sel clas-fiscal-ini > INPUT FRAME f-pg-sel clas-fiscal-fim THEN DO:
            RUN utp/ut-msgs.p (INPUT 'SHOW':U,
                               INPUT 17006,
                               INPUT 'Classificacao fiscal final nao pode ser maior que a classificacao fiscal inicial':U + '~~':U +
                                     'Verifique os parametros de selecao da classificacao fiscal informados.':U).
            APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel        IN FRAME f-relat.
            APPLY 'ENTRY':U              TO clas-fiscal-ini  IN FRAME f-pg-sel.
            RETURN ERROR.
        END.

        IF  INPUT FRAME f-pg-sel cst-ini > INPUT FRAME f-pg-sel cst-fim THEN DO:
            RUN utp/ut-msgs.p (INPUT 'SHOW':U,
                               INPUT 17006,
                               INPUT 'Cst final nao pode ser maior que a Cst inicial':U + '~~':U +
                                     'Verifique os parametros de selecao do cst informados.':U).
            APPLY 'MOUSE-SELECT-CLICK':U TO im-pg-sel        IN FRAME f-relat.
            APPLY 'ENTRY':U              TO cst-ini  IN FRAME f-pg-sel.
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
        
        ASSIGN tt-param.cod-estab-ini         = INPUT FRAME f-pg-sel cod-estab-ini     
               tt-param.cod-estab-fim         = INPUT FRAME f-pg-sel cod-estab-fim     
               tt-param.it-codigo-ini         = INPUT FRAME f-pg-sel it-codigo-ini     
               tt-param.it-codigo-fim         = INPUT FRAME f-pg-sel it-codigo-fim   
               tt-param.tg-pr                 = INPUT FRAME f-pg-sel tg-pr
               tt-param.tg-sp                 = INPUT FRAME f-pg-sel tg-sp
               tt-param.tg-sc                 = INPUT FRAME f-pg-sel tg-sc
               tt-param.tg-go                 = INPUT FRAME f-pg-sel tg-go
               tt-param.tg-df                 = INPUT FRAME f-pg-sel tg-df
               tt-param.tg-pr-dest            = INPUT FRAME f-pg-sel tg-pr-dest
               tt-param.tg-sp-dest            = INPUT FRAME f-pg-sel tg-sp-dest
               tt-param.tg-sc-dest            = INPUT FRAME f-pg-sel tg-sc-dest
               tt-param.tg-go-dest            = INPUT FRAME f-pg-sel tg-go-dest
               tt-param.tg-df-dest            = INPUT FRAME f-pg-sel tg-df-dest
               tt-param.ge-codigo-ini         = INPUT FRAME f-pg-sel ge-codigo-ini 
               tt-param.ge-codigo-fim         = INPUT FRAME f-pg-sel ge-codigo-fim 
               tt-param.fm-codigo-ini         = INPUT FRAME f-pg-sel fm-codigo-ini
               tt-param.fm-codigo-fim         = INPUT FRAME f-pg-sel fm-codigo-fim
               tt-param.clas-fiscal-ini       = INPUT FRAME f-pg-sel clas-fiscal-ini 
               tt-param.clas-fiscal-fim       = INPUT FRAME f-pg-sel clas-fiscal-fim 
               tt-param.cst-ini               = INPUT FRAME f-pg-sel CST-INI
               tt-param.cst-fim               = INPUT FRAME f-pg-sel CST-FIM
               tt-param.com-subst-tribut      = INPUT FRAME f-pg-sel com-subst-tribut
               tt-param.sem-subst-tribut      = INPUT FRAME f-pg-sel sem-subst-tribut
               tt-param.forc-integ            = INPUT FRAME f-pg-sel forc-integ
            .

        /** EXECUCAO DO RELATORIO *********************************************/

        {include/i-rpexb.i}
        
        SESSION:SET-WAIT-STATE('GENERAL':U).
        
        {include/i-rprun.i intprg/int090rp.p}
        
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

