&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           ORACLE
*/
&Scoped-define WINDOW-NAME w-cadpaifilho-ambos


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int_ds_docto_xml NO-UNDO LIKE int_ds_docto_xml
       field r-int_ds_docto_xml as rowid
       field c-nome-emit        as char
       field c-uf-emit          as char
       FIELD l-divergente       AS LOG.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-cadpaifilho-ambos 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i nire003 1.12.01.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
CURRENT-LANGUAGE = CURRENT-LANGUAGE.


DEFINE NEW GLOBAL SHARED VARIABLE v-row-docto-xml-nire003 AS ROWID       NO-UNDO.

/* Local Variable Definitions ---                                       */

def var p-table as rowid.

DEF TEMP-TABLE tt-int_ds_it_docto_xml LIKE int_ds_it_docto_xml
    FIELD cod-estab           AS CHAR
    FIELD c-nome-emit         AS CHAR
    FIELD c-uf-emit           AS CHAR
    FIELD chnfe               AS CHAR
    FIELD demi                AS DATE
    FIELD de-aliq-pis         AS DEC
    FIELD de-aliq-cofins      AS DEC
    FIELD de-aliq-ipi         AS DEC
    FIELD de-aliq-icms        AS DEC
    FIELD de-base-icm-calc    AS DEC
    FIELD de-base-st-calc     AS DEC
    FIELD de-valor-st-calc    AS DEC
    FIELD de-perc-st-calc     AS DEC
    FIELD c-tabela-pauta      AS CHAR
    FIELD de-tabela-pauta     AS DEC
    FIELD de-per-sub-tri      AS DEC
    FIELD de-per-red-bc-calc  AS DEC
    FIELD de-perc-va-st       AS DEC
    FIELD l-divergente        AS LOG
    FIELD de-valor-pis-cad    AS DEC
    FIELD de-valor-cofins-cad AS DEC
    FIELD de-valor-ipi-cad    AS DEC
    FIELD i-class-fiscal      AS INT
    FIELD de-base-pis-calc    AS DEC
    FIELD de-total-nf         AS DEC
    FIELD de-total-cad        AS DEC
    FIELD de-valor-icms-cad   AS DEC.

DEF TEMP-TABLE tt-itens-tmp LIKE tt-int_ds_it_docto_xml.

DEFINE VARIABLE h-cdapi995                  AS HANDLE      NO-UNDO.
DEFINE VARIABLE de-aliq-pis                 AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-aliq-cofins              AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-aliquota-icms-excessao   AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-valor-pauta              AS DECIMAL     NO-UNDO.
DEFINE VARIABLE c-uf-orig                   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-uf-dest                   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-cont                      AS INTEGER     NO-UNDO.
DEFINE VARIABLE de-valor-dif-aceita         AS DECIMAL     NO-UNDO.

DEF BUFFER b-unid-feder-dest FOR unid-feder.
DEF BUFFER b-unid-feder-orig FOR unid-feder.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-paiamb
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-cad
&Scoped-define BROWSE-NAME br-notas

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int_ds_docto_xml

/* Definitions for BROWSE br-notas                                      */
&Scoped-define FIELDS-IN-QUERY-br-notas tt-int_ds_docto_xml.dEmi ~
tt-int_ds_docto_xml.dt_trans tt-int_ds_docto_xml.nNF ~
tt-int_ds_docto_xml.serie tt-int_ds_docto_xml.cod_emitente ~
tt-int_ds_docto_xml.c-nome-emit @ tt-int_ds_docto_xml.c-nome-emit ~
tt-int_ds_docto_xml.c-uf-emit @ tt-int_ds_docto_xml.c-uf-emit ~
tt-int_ds_docto_xml.chnfe ~
tt-int_ds_docto_xml.l-divergente @ tt-int_ds_docto_xml.l-divergente 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-notas 
&Scoped-define QUERY-STRING-br-notas FOR EACH tt-int_ds_docto_xml NO-LOCK
&Scoped-define OPEN-QUERY-br-notas OPEN QUERY br-notas FOR EACH tt-int_ds_docto_xml NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-notas tt-int_ds_docto_xml
&Scoped-define FIRST-TABLE-IN-QUERY-br-notas tt-int_ds_docto_xml


/* Definitions for FRAME f-cad                                          */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-cad ~
    ~{&OPEN-QUERY-br-notas}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS dt-trans-ini dt-trans-fim i-cod-emitente ~
c-serie-docto c-nro-docto tg-divergente c-chave bt-fil bt-excel btExit ~
RECT-25 IMAGE-21 IMAGE-22 br-notas 
&Scoped-Define DISPLAYED-OBJECTS dt-trans-ini dt-trans-fim i-cod-emitente ~
c-serie-docto c-nro-docto tg-divergente c-chave 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-cadpaifilho-ambos AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU mi-arquivo 
       MENU-ITEM mi-sair        LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE MENU m-cadastro MENUBAR
       SUB-MENU  mi-arquivo     LABEL "&Arquivo"      .


/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_folder AS HANDLE NO-UNDO.
DEFINE VARIABLE h_nire003-browser-itens AS HANDLE NO-UNDO.
DEFINE VARIABLE h_nire003-browser-itens-orig AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-excel 
     IMAGE-UP FILE "image/excel.bmp":U
     LABEL "Excel" 
     SIZE 4 BY 1 TOOLTIP "Enviar requisiá‰es encontradas para planilha Excel".

DEFINE BUTTON bt-fil 
     IMAGE-UP FILE "image/im-enter.bmp":U
     LABEL "Filtrar" 
     SIZE 4 BY 1 TOOLTIP "Localizar Notas"
     FONT 4.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1 TOOLTIP "Sair"
     FONT 4.

DEFINE VARIABLE c-chave AS CHARACTER FORMAT "X(50)":U 
     LABEL "Chave" 
     VIEW-AS FILL-IN 
     SIZE 55 BY .79 NO-UNDO.

DEFINE VARIABLE c-nro-docto AS CHARACTER FORMAT "X(7)":U 
     LABEL "Nota" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79 NO-UNDO.

DEFINE VARIABLE c-serie-docto AS CHARACTER FORMAT "X(3)":U 
     LABEL "SÇrie" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE dt-trans-fim AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79 NO-UNDO.

DEFINE VARIABLE dt-trans-ini AS DATE FORMAT "99/99/9999":U 
     LABEL "Transaá∆o" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79 NO-UNDO.

DEFINE VARIABLE i-cod-emitente AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Fornecedor" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79 NO-UNDO.

DEFINE IMAGE IMAGE-21
     FILENAME "image\im-fir":U
     SIZE 3.14 BY .88.

DEFINE IMAGE IMAGE-22
     FILENAME "image\im-las":U
     SIZE 3.14 BY .88.

DEFINE RECTANGLE RECT-25
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 143.72 BY 14.

DEFINE VARIABLE tg-divergente AS LOGICAL INITIAL yes 
     LABEL "Apenas Divergentes" 
     VIEW-AS TOGGLE-BOX
     SIZE 17.57 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-notas FOR 
      tt-int_ds_docto_xml SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-notas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-notas w-cadpaifilho-ambos _STRUCTURED
  QUERY br-notas NO-LOCK DISPLAY
      tt-int_ds_docto_xml.dEmi COLUMN-LABEL "Emiss∆o" FORMAT "99/99/9999":U
      tt-int_ds_docto_xml.dt_trans FORMAT "99/99/9999":U
      tt-int_ds_docto_xml.nNF COLUMN-LABEL "NF" FORMAT "x(16)":U
            WIDTH 8
      tt-int_ds_docto_xml.serie FORMAT "x(5)":U WIDTH 6
      tt-int_ds_docto_xml.cod_emitente COLUMN-LABEL "Fornec" FORMAT ">>>>>>>>9":U
      tt-int_ds_docto_xml.c-nome-emit @ tt-int_ds_docto_xml.c-nome-emit COLUMN-LABEL "Nome" FORMAT "x(60)":U
      tt-int_ds_docto_xml.c-uf-emit @ tt-int_ds_docto_xml.c-uf-emit COLUMN-LABEL "UF" FORMAT "x(03)":U
      tt-int_ds_docto_xml.chnfe FORMAT "x(60)":U WIDTH 45
      tt-int_ds_docto_xml.l-divergente @ tt-int_ds_docto_xml.l-divergente COLUMN-LABEL "Divergente" FORMAT "Sim/N∆o":U
            WIDTH 8
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 142 BY 11.5 ROW-HEIGHT-CHARS .6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-cad
     dt-trans-ini AT ROW 13 COL 15 COLON-ALIGNED WIDGET-ID 208
     dt-trans-fim AT ROW 13 COL 35 COLON-ALIGNED NO-LABEL WIDGET-ID 206
     i-cod-emitente AT ROW 12.92 COL 59 COLON-ALIGNED WIDGET-ID 202
     c-serie-docto AT ROW 12.92 COL 77 COLON-ALIGNED WIDGET-ID 200
     c-nro-docto AT ROW 12.92 COL 88.14 COLON-ALIGNED WIDGET-ID 196
     tg-divergente AT ROW 12.92 COL 102 WIDGET-ID 214
     c-chave AT ROW 13.92 COL 59 COLON-ALIGNED WIDGET-ID 204
     bt-fil AT ROW 13.75 COL 116 WIDGET-ID 14
     bt-excel AT ROW 13.79 COL 135.43 WIDGET-ID 66
     btExit AT ROW 13.79 COL 139.86 HELP
          "Sair" WIDGET-ID 182
     br-notas AT ROW 1.25 COL 2 WIDGET-ID 200
     RECT-25 AT ROW 1 COL 1 WIDGET-ID 2
     IMAGE-21 AT ROW 13 COL 28 WIDGET-ID 210
     IMAGE-22 AT ROW 13 COL 33 WIDGET-ID 212
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 144.29 BY 26.83 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-paiamb
   Allow: Basic,Browse,DB-Fields,Smart,Window,Query
   Container Links: 
   Add Fields to: Neither
   Design Page: 2
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int_ds_docto_xml T "?" NO-UNDO custom int_ds_docto_xml
      ADDITIONAL-FIELDS:
          field r-int_ds_docto_xml as rowid
          field c-nome-emit        as char
          field c-uf-emit          as char
          FIELD l-divergente       AS LOG
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-cadpaifilho-ambos ASSIGN
         HIDDEN             = YES
         TITLE              = "Validaá∆o Fiscal Recebimento"
         HEIGHT             = 26.83
         WIDTH              = 144.29
         MAX-HEIGHT         = 33
         MAX-WIDTH          = 228.57
         VIRTUAL-HEIGHT     = 33
         VIRTUAL-WIDTH      = 228.57
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU m-cadastro:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-cadpaifilho-ambos 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-cadpaifilho-ambos
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-cad
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB br-notas IMAGE-22 f-cad */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-cadpaifilho-ambos)
THEN w-cadpaifilho-ambos:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-notas
/* Query rebuild information for BROWSE br-notas
     _TblList          = "Temp-Tables.tt-int_ds_docto_xml"
     _Options          = "NO-LOCK"
     _FldNameList[1]   > Temp-Tables.tt-int_ds_docto_xml.dEmi
"tt-int_ds_docto_xml.dEmi" "Emiss∆o" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.tt-int_ds_docto_xml.dt_trans
     _FldNameList[3]   > Temp-Tables.tt-int_ds_docto_xml.nNF
"tt-int_ds_docto_xml.nNF" "NF" ? "character" ? ? ? ? ? ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-int_ds_docto_xml.serie
"tt-int_ds_docto_xml.serie" ? ? "character" ? ? ? ? ? ? no ? no no "6" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.tt-int_ds_docto_xml.cod_emitente
"tt-int_ds_docto_xml.cod_emitente" "Fornec" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"tt-int_ds_docto_xml.c-nome-emit @ tt-int_ds_docto_xml.c-nome-emit" "Nome" "x(60)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > "_<CALC>"
"tt-int_ds_docto_xml.c-uf-emit @ tt-int_ds_docto_xml.c-uf-emit" "UF" "x(03)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > Temp-Tables.tt-int_ds_docto_xml.chnfe
"tt-int_ds_docto_xml.chnfe" ? ? "character" ? ? ? ? ? ? no ? no no "45" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > "_<CALC>"
"tt-int_ds_docto_xml.l-divergente @ tt-int_ds_docto_xml.l-divergente" "Divergente" "Sim/N∆o" ? ? ? ? ? ? ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-notas */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-cadpaifilho-ambos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-cadpaifilho-ambos w-cadpaifilho-ambos
ON END-ERROR OF w-cadpaifilho-ambos /* Validaá∆o Fiscal Recebimento */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-cadpaifilho-ambos w-cadpaifilho-ambos
ON WINDOW-CLOSE OF w-cadpaifilho-ambos /* Validaá∆o Fiscal Recebimento */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-notas
&Scoped-define SELF-NAME br-notas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-notas w-cadpaifilho-ambos
ON ROW-DISPLAY OF br-notas IN FRAME f-cad
DO:
    IF  tt-int_ds_docto_xml.l-divergente
    THEN DO:
        ASSIGN tt-int_ds_docto_xml.dEmi        :BGCOLOR IN BROWSE br-notas = 14
               tt-int_ds_docto_xml.dt_trans    :BGCOLOR IN BROWSE br-notas = 14
               tt-int_ds_docto_xml.nNF         :BGCOLOR IN BROWSE br-notas = 14
               tt-int_ds_docto_xml.serie       :BGCOLOR IN BROWSE br-notas = 14
               tt-int_ds_docto_xml.cod_emitente:BGCOLOR IN BROWSE br-notas = 14
               tt-int_ds_docto_xml.c-nome-emit :BGCOLOR IN BROWSE br-notas = 14
               tt-int_ds_docto_xml.c-uf-emit   :BGCOLOR IN BROWSE br-notas = 14
               tt-int_ds_docto_xml.chnfe       :BGCOLOR IN BROWSE br-notas = 14
               tt-int_ds_docto_xml.l-divergente:BGCOLOR IN BROWSE br-notas = 14.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-notas w-cadpaifilho-ambos
ON VALUE-CHANGED OF br-notas IN FRAME f-cad
DO:
    EMPTY TEMP-TABLE tt-itens-tmp.

    FOR EACH  tt-int_ds_it_docto_xml NO-LOCK 
        WHERE tt-int_ds_it_docto_xml.cnpj      = tt-int_ds_docto_xml.cnpj
          AND tt-int_ds_it_docto_xml.serie     = tt-int_ds_docto_xml.serie
          AND tt-int_ds_it_docto_xml.nNF       = tt-int_ds_docto_xml.nNF
          AND tt-int_ds_it_docto_xml.tipo_nota = tt-int_ds_docto_xml.tipo_nota:

        CREATE tt-itens-tmp.
        BUFFER-COPY tt-int_ds_it_docto_xml TO tt-itens-tmp.
    END.


    RUN pi-itens-nf IN h_nire003-browser-itens (INPUT TABLE tt-itens-tmp).  

    RUN pi-itens-nf IN h_nire003-browser-itens-orig (INPUT TABLE tt-itens-tmp).  

/*     RUN pi-itens-nf IN h_nire003-browser-itens-orig (INPUT tt-int_ds_docto_xml.serie,        */
/*                                                      INPUT tt-int_ds_docto_xml.nnf,          */
/*                                                      INPUT tt-int_ds_docto_xml.cod_emitente, */
/*                                                      INPUT tt-int_ds_docto_xml.tipo_nota).   */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-excel w-cadpaifilho-ambos
ON CHOOSE OF bt-excel IN FRAME f-cad /* Excel */
DO:
    IF  SESSION:SET-WAIT-STATE("general") THEN.
    RUN pi-gera-excel.  
    IF  SESSION:SET-WAIT-STATE("") THEN.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-fil
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-fil w-cadpaifilho-ambos
ON CHOOSE OF bt-fil IN FRAME f-cad /* Filtrar */
DO:
   IF  SESSION:SET-WAIT-STATE("general") THEN.

    ASSIGN de-valor-dif-aceita = 0.
    FOR FIRST cst_param_estoq NO-LOCK:
        ASSIGN de-valor-dif-aceita = cst_param_estoq.de_valor_dif_aceita_impto.
    END.

   EMPTY TEMP-TABLE tt-int_ds_docto_xml.
   EMPTY TEMP-TABLE tt-int_ds_it_docto_xml.

   ASSIGN dt-trans-ini   = INPUT FRAME {&FRAME-NAME} dt-trans-ini
          dt-trans-fim   = INPUT FRAME {&FRAME-NAME} dt-trans-fim
          c-nro-docto    = INPUT FRAME {&FRAME-NAME} c-nro-docto
          c-serie-docto  = INPUT FRAME {&FRAME-NAME} c-serie-docto
          i-cod-emitente = INPUT FRAME {&FRAME-NAME} i-cod-emitente
          tg-divergente  = INPUT FRAME {&FRAME-NAME} tg-divergente
          c-chave        = INPUT FRAME {&FRAME-NAME} c-chave.

    IF  c-chave <> ""
    THEN DO:
        IF  v-row-docto-xml-nire003 = ?
        THEN DO:
            ASSIGN c-nro-docto    = ""
                   c-serie-docto  = ""
                   i-cod-emitente = 0.

            DISP c-nro-docto c-serie-docto i-cod-emitente WITH FRAME {&FRAME-NAME}.
        END.

        FOR EACH  int_ds_docto_xml NO-LOCK 
            WHERE int_ds_docto_xml.situacao  <> 9
              AND int_ds_docto_xml.tipo_nota <> 3
              AND int_ds_docto_xml.CNPJ_dest  = "79430682025540"
              AND int_ds_docto_xml.chnfe      = c-chave,
            LAST  int_ds_docto_wms USE-INDEX sequencial NO-LOCK
            WHERE int_ds_docto_wms.doc_numero_n        = INT(int_ds_docto_xml.nNF)
              AND int_ds_docto_wms.doc_serie_s         = int_ds_docto_xml.serie
              AND int_ds_docto_wms.cnpj_cpf            = int_ds_docto_xml.CNPJ
              AND int_ds_docto_wms.datamovimentacao_d >= dt-trans-ini
              AND int_ds_docto_wms.datamovimentacao_d <= dt-trans-fim:

              RUN pi-cria-tt-int_ds_docto_xml.
        END.
        FOR EACH  int_ds_docto_xml NO-LOCK 
            WHERE int_ds_docto_xml.situacao  <> 9
              AND int_ds_docto_xml.tipo_nota <> 3
              AND int_ds_docto_xml.CNPJ_dest  = "79430682025540"
              AND int_ds_docto_xml.chnfe      = c-chave
              AND int_ds_docto_xml.dt_trans  >= dt-trans-ini
              AND int_ds_docto_xml.dt_trans  <= dt-trans-fim:

              RUN pi-cria-tt-int_ds_docto_xml.
        END.
    END.
    ELSE DO:
        IF  c-nro-docto   <> "" AND
            c-serie-docto <> "" 
        THEN DO:
            FOR EACH   int_ds_docto_xml NO-LOCK 
                WHERE  int_ds_docto_xml.serie         = c-serie-docto
                  AND  int_ds_docto_xml.nnf           = c-nro-docto
                  AND  int_ds_docto_xml.tipo_nota    <> 3
                  AND  int_ds_docto_xml.CNPJ_dest     = "79430682025540"
                  AND  int_ds_docto_xml.situacao     <> 9 
                  AND (int_ds_docto_xml.cod_emitente  = i-cod-emitente
                   OR  i-cod-emitente                 = 0),
                LAST  int_ds_docto_wms USE-INDEX sequencial NO-LOCK
                WHERE int_ds_docto_wms.doc_numero_n        = INT(int_ds_docto_xml.nNF)
                  AND int_ds_docto_wms.doc_serie_s         = int_ds_docto_xml.serie
                  AND int_ds_docto_wms.cnpj_cpf            = int_ds_docto_xml.CNPJ
                  AND int_ds_docto_wms.datamovimentacao_d >= dt-trans-ini
                  AND int_ds_docto_wms.datamovimentacao_d <= dt-trans-fim:
    
                  RUN pi-cria-tt-int_ds_docto_xml.
            END.
            FOR EACH   int_ds_docto_xml NO-LOCK 
                WHERE  int_ds_docto_xml.serie         = c-serie-docto
                  AND  int_ds_docto_xml.nnf           = c-nro-docto
                  AND  int_ds_docto_xml.tipo_nota    <> 3
                  AND  int_ds_docto_xml.CNPJ_dest     = "79430682025540"
                  AND  int_ds_docto_xml.situacao     <> 9 
                  AND  int_ds_docto_xml.dt_trans     >= dt-trans-ini
                  AND  int_ds_docto_xml.dt_trans     <= dt-trans-fim
                  AND (int_ds_docto_xml.cod_emitente  = i-cod-emitente
                   OR  i-cod-emitente                 = 0):
    
                  RUN pi-cria-tt-int_ds_docto_xml.
            END.
        END.
        ELSE DO:
            FOR EACH   int_ds_docto_xml NO-LOCK 
                WHERE  int_ds_docto_xml.situacao     <> 9
                  AND  int_ds_docto_xml.tipo_nota    <> 3
                  AND  int_ds_docto_xml.CNPJ_dest     = "79430682025540"
                  AND (int_ds_docto_xml.cod_emitente  = i-cod-emitente
                   OR  i-cod-emitente                 = 0),
                 LAST  int_ds_docto_wms USE-INDEX sequencial NO-LOCK
                 WHERE int_ds_docto_wms.doc_numero_n        = INT(int_ds_docto_xml.nNF)
                   AND int_ds_docto_wms.doc_serie_s         = int_ds_docto_xml.serie
                   AND int_ds_docto_wms.cnpj_cpf            = int_ds_docto_xml.CNPJ
                   AND int_ds_docto_wms.datamovimentacao_d >= dt-trans-ini
                   AND int_ds_docto_wms.datamovimentacao_d <= dt-trans-fim:
    
                  RUN pi-cria-tt-int_ds_docto_xml.
            END.
            FOR EACH   int_ds_docto_xml NO-LOCK 
                WHERE  int_ds_docto_xml.situacao     <> 9
                  AND  int_ds_docto_xml.tipo_nota    <> 3
                  AND  int_ds_docto_xml.CNPJ_dest     = "79430682025540"
                  AND  int_ds_docto_xml.dt_trans     >= dt-trans-ini
                  AND  int_ds_docto_xml.dt_trans     <= dt-trans-fim
                  AND (int_ds_docto_xml.cod_emitente  = i-cod-emitente
                   OR  i-cod-emitente                 = 0):
    
                  RUN pi-cria-tt-int_ds_docto_xml.
            END.
        END.
    END.

    {&OPEN-QUERY-br-notas}

    APPLY "VALUE-CHANGED" TO br-notas IN FRAME {&FRAME-NAME}.

    IF  SESSION:SET-WAIT-STATE("") THEN.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit w-cadpaifilho-ambos
ON CHOOSE OF btExit IN FRAME f-cad /* Exit */
APPLY "CLOSE" TO THIS-PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sair
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sair w-cadpaifilho-ambos
ON CHOOSE OF MENU-ITEM mi-sair /* Sair */
DO:
    APPLY "CLOSE" TO THIS-PROCEDURE.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-cadpaifilho-ambos 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */

{src/adm/template/windowmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-cadpaifilho-ambos  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  CASE adm-current-page: 

    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'adm/objects/folder.w':U ,
             INPUT  FRAME f-cad:HANDLE ,
             INPUT  'FOLDER-LABELS = ':U + 'Itens Atual|Orig-Atu-Cad' + ',
                     FOLDER-TAB-TYPE = 1':U ,
             OUTPUT h_folder ).
       RUN set-position IN h_folder ( 15.29 , 1.00 ) NO-ERROR.
       RUN set-size IN h_folder ( 12.54 , 143.57 ) NO-ERROR.

       /* Links to SmartFolder h_folder. */
       RUN add-link IN adm-broker-hdl ( h_folder , 'Page':U , THIS-PROCEDURE ).

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_folder ,
             br-notas:HANDLE IN FRAME f-cad , 'AFTER':U ).
    END. /* Page 0 */
    WHEN 1 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'intprg/nire003-browser-itens.w':U ,
             INPUT  FRAME f-cad:HANDLE ,
             INPUT  'Initial-Lock = NO-LOCK,
                     Hide-on-Init = no,
                     Disable-on-Init = no,
                     Layout = ,
                     Create-On-Add = ?':U ,
             OUTPUT h_nire003-browser-itens ).
       RUN set-position IN h_nire003-browser-itens ( 16.75 , 1.72 ) NO-ERROR.
       /* Size in UIB:  ( 10.75 , 142.57 ) */

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_nire003-browser-itens ,
             h_folder , 'AFTER':U ).
    END. /* Page 1 */
    WHEN 2 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'intprg/nire003-browser-itens-orig.w':U ,
             INPUT  FRAME f-cad:HANDLE ,
             INPUT  'Initial-Lock = NO-LOCK,
                     Hide-on-Init = no,
                     Disable-on-Init = no,
                     Layout = ,
                     Create-On-Add = ?':U ,
             OUTPUT h_nire003-browser-itens-orig ).
       RUN set-position IN h_nire003-browser-itens-orig ( 16.75 , 1.72 ) NO-ERROR.
       /* Size in UIB:  ( 10.75 , 142.57 ) */

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_nire003-browser-itens-orig ,
             h_folder , 'AFTER':U ).
    END. /* Page 2 */

  END CASE.
  /* Select a Startup page. */
  IF adm-current-page eq 0 
  THEN RUN select-page IN THIS-PROCEDURE ( 1 ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-cadpaifilho-ambos  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-cadpaifilho-ambos  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-cadpaifilho-ambos)
  THEN DELETE WIDGET w-cadpaifilho-ambos.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-cadpaifilho-ambos  _DEFAULT-ENABLE
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
  DISPLAY dt-trans-ini dt-trans-fim i-cod-emitente c-serie-docto c-nro-docto 
          tg-divergente c-chave 
      WITH FRAME f-cad IN WINDOW w-cadpaifilho-ambos.
  ENABLE dt-trans-ini dt-trans-fim i-cod-emitente c-serie-docto c-nro-docto 
         tg-divergente c-chave bt-fil bt-excel btExit RECT-25 IMAGE-21 IMAGE-22 
         br-notas 
      WITH FRAME f-cad IN WINDOW w-cadpaifilho-ambos.
  {&OPEN-BROWSERS-IN-QUERY-f-cad}
  VIEW w-cadpaifilho-ambos.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy w-cadpaifilho-ambos 
PROCEDURE local-destroy :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'destroy':U ) .
  {include/i-logfin.i}
  
  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-cadpaifilho-ambos 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize w-cadpaifilho-ambos 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
  {include/win-size.i}

  

  {utp/ut9000.i "nire003" "1.12.01.AVB"}

  IF  v-row-docto-xml-nire003 <> ?
  THEN DO:
      FOR FIRST int_ds_docto_xml NO-LOCK
          WHERE ROWID(int_ds_docto_xml) = v-row-docto-xml-nire003:

          FOR LAST  int_ds_docto_wms USE-INDEX sequencial NO-LOCK 
              WHERE int_ds_docto_wms.doc_numero_n        = INT(int_ds_docto_xml.nNF) 
                AND int_ds_docto_wms.doc_serie_s         = int_ds_docto_xml.serie 
                AND int_ds_docto_wms.cnpj_cpf            = int_ds_docto_xml.CNPJ:
          END.

         ASSIGN dt-trans-ini   = IF AVAIL int_ds_docto_wms 
                                 THEN int_ds_docto_wms.datamovimentacao_d ELSE int_ds_docto_xml.dt_trans
                dt-trans-fim   = IF AVAIL int_ds_docto_wms 
                                 THEN int_ds_docto_wms.datamovimentacao_d ELSE int_ds_docto_xml.dt_trans
                c-nro-docto    = int_ds_docto_xml.nnf
                c-serie-docto  = int_ds_docto_xml.serie
                i-cod-emitente = int_ds_docto_xml.cod_emitente
                tg-divergente  = NO
                c-chave        = int_ds_docto_xml.chnfe.
      END.
  END.
  ELSE
      ASSIGN dt-trans-ini = 01/01/2016
             dt-trans-fim = TODAY.    

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  RUN select-page IN THIS-PROCEDURE ( 2 ).
  RUN select-page IN THIS-PROCEDURE ( 1 ).

  IF  v-row-docto-xml-nire003 <> ?
  THEN
      APPLY "CHOOSE" TO bt-fil IN FRAME {&FRAME-NAME}.

  /* Code placed here will execute AFTER standard behavior.    */

/*   RUN enable-elimina in h_p-cadpai (no). */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-calcula-aliquota-icms w-cadpaifilho-ambos 
PROCEDURE pi-calcula-aliquota-icms :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    /* Definiá∆o dos parÉmetros de Entrada/Sa°da */
    def input  param p-l-contrib-icms    like emitente.contrib-icms     no-undo.
    def input  param p-i-natureza-emit   like emitente.natureza         no-undo.
    def input  param p-c-estado-origem   like estabelec.estado          no-undo.
    def input  param p-c-pais-origem     like estabelec.pais            no-undo.
    def input  param p-c-estado-dest     like nota-fiscal.estado        no-undo.
    def input  param p-c-it-codigo       like item.it-codigo            no-undo.
    def input  param p-c-nat-operacao    like it-nota-fisc.nat-operacao no-undo.
    def output param p-de-aliquota       like natur-oper.aliquota-icm   no-undo.

    if  ((p-l-contrib-icms  = YES                      AND /* Emitente contribuinte        */
          p-c-estado-dest   = b-unid-feder-orig.estado) OR /* Nota interna                 */
          p-l-contrib-icms  = NO)                          /* Emitente nao contribuinte    */
    THEN
        /* Verifica aliquota diferenciada de ICMS a nivel Item/Unidade Federacao       */
        for first icms-it-uf
            fields (icms-it-uf.aliquota-icm)
            where icms-it-uf.it-codigo    = p-c-it-codigo
              and icms-it-uf.estado       = b-unid-feder-orig.estado
              and icms-it-uf.aliquota-icm > 0 no-lock:

            /* Caso exista, utiliza a aliquota encontrada */

            assign p-de-aliquota = icms-it-uf.aliquota-icm.

        end.

    if  p-de-aliquota = 0 /* Nao existe aliquota diferenciada de ICMS        */
    then do:
        if  p-i-natureza-emit <> 3 AND /* Natureza do emitente diferente de Estrangeiro   */
            p-l-contrib-icms           /* Emitente contribuinte de ICMS                   */
        THEN
            if  p-c-estado-dest = b-unid-feder-orig.estado /* Aliquota interna    */
            THEN DO:
                assign p-de-aliquota = b-unid-feder-orig.per-icms-int.
            END.
            else  DO:             /* Aliquota interestadual                          */
             /*   assign p-de-aliquota = 
                           if  de-aliquota-icms-excessao > 0    /* Se houver al°quota exceá∆o */
                           then de-aliquota-icms-excessao       /* utiliza al°quota exceá∆o   */
                           else b-unid-feder-orig.per-icms-ext. /* Al°quota Externa           */
                                         */

                assign p-de-aliquota = b-unid-feder-orig.per-icms-ext.
               /* MESSAGE "3 - " p-de-aliquota SKIP 
                        "p-c-it-codigo - " p-c-it-codigo SKIP
                        "p-c-estado-origem - " p-c-estado-origem SKIP
                        "p-c-estado-dest - " p-c-estado-dest SKIP
                        "de-aliquota-icms-excessao  - " de-aliquota-icms-excessao  SKIP
                        "b-unid-feder-orig.per-icms-ext - " b-unid-feder-orig.per-icms-ext
                    VIEW-AS ALERT-BOX INFO BUTTONS OK. */
            END.
        else do: /* Emitente n∆o Ç contribuinte ou ele e estrangeiro                      */
            assign p-de-aliquota =
                       if  p-l-contrib-icms      = NO AND /* Emitente n∆o contribuinte     */
                           para-fat.aliq-icms-nc = 1      /* Al°quota da UF                */
                       then b-unid-feder-orig.per-icms-int
                       else 0.
        END.
    
        /* Caso for zero, utilizara a aliquota da natureza de operacao  */
        if  p-de-aliquota = 0 AND
            AVAIL natur-oper
        THEN DO:
            assign p-de-aliquota = natur-oper.aliquota-icm.
        END.
    end.

    IF  AVAIL ITEM
    THEN DO:
        /* Tratar importados */

        IF p-c-estado-origem       <> p-c-estado-dest THEN
            IF  ITEM.FM-CODIGO =  "101" OR
                ITEM.FM-CODIGO =  "201" OR
               (ITEM.FM-CODIGO >= "300" AND
                ITEM.FM-CODIGO <= "309")
            THEN DO:
                ASSIGN p-de-aliquota = 4.
           /*     MESSAGE "6 - " p-de-aliquota
                    VIEW-AS ALERT-BOX INFO BUTTONS OK. */
            END. 
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cria-tt-int_ds_docto_xml w-cadpaifilho-ambos 
PROCEDURE pi-cria-tt-int_ds_docto_xml :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF NOT VALID-HANDLE (h-cdapi995)  
    THEN
        RUN cdp\cdapi995.p PERSISTENT SET h-cdapi995.

    FOR FIRST para-fat NO-LOCK:
    END.

    if can-find (first tt-int_ds_docto_xml no-lock
        where tt-int_ds_docto_xml.cnpj      = int_ds_docto_xml.cnpj
          and tt-int_ds_docto_xml.serie     = int_ds_docto_xml.serie
          and tt-int_ds_docto_xml.nNF       = int_ds_docto_xml.nNF
          and tt-int_ds_docto_xml.tipo_nota = int_ds_docto_xml.tipo_nota) then return.

    CREATE tt-int_ds_docto_xml.
    BUFFER-COPY int_ds_docto_xml TO tt-int_ds_docto_xml.

    ASSIGN tt-int_ds_docto_xml.r-int_ds_docto_xml = ROWID(int_ds_docto_xml)
           tt-int_ds_docto_xml.dt_trans           = IF AVAIL int_ds_docto_wms 
                                                    THEN int_ds_docto_wms.datamovimentacao_d 
                                                    ELSE int_ds_docto_xml.dt_trans.

    FOR FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = int_ds_docto_xml.cod_emitente:
    END.
    
    FOR FIRST estabelec no-lock
        WHERE estabelec.cod-estabel = int_ds_docto_xml.cod_estab:
    END.

    ASSIGN c-uf-orig = IF AVAIL emitente THEN emitente.estado ELSE ""
           c-uf-dest = estabelec.estado.
    
    IF  c-uf-orig <> "SP" AND
        c-uf-orig <> "PR" AND
        c-uf-orig <> "SC"
    THEN
        ASSIGN c-uf-orig = "SP"
               c-uf-dest = "PR".
    
    IF AVAIL emitente 
    THEN DO:
        FOR FIRST b-unid-feder-orig NO-LOCK
            WHERE b-unid-feder-orig.pais   = emitente.pais
              AND b-unid-feder-orig.estado = c-uf-orig:
        END.
    END.
    ELSE DO:
        FOR FIRST b-unid-feder-orig NO-LOCK
            WHERE b-unid-feder-orig.pais   = "Brasil"
              AND b-unid-feder-orig.estado = c-uf-orig:
        END.
    END.

    
    FOR FIRST b-unid-feder-dest NO-LOCK
        WHERE b-unid-feder-dest.pais   = estabelec.pais      
          AND b-unid-feder-dest.estado = c-uf-dest:
    END.
    
    ASSIGN tt-int_ds_docto_xml.c-nome-emit = IF AVAIL emitente THEN emitente.nome-emit ELSE "FORNECEDOR N«O CADASTRADO"
           tt-int_ds_docto_xml.c-uf-emit   = IF AVAIL emitente THEN emitente.estado    ELSE "".

   FIND FIRST int_ds_ext_emitente NO-LOCK 
       WHERE  int_ds_ext_emitente.cod_emitente = int_ds_docto_xml.cod_emitente NO-ERROR.

    FOR EACH  int_ds_it_docto_xml NO-LOCK 
        WHERE int_ds_it_docto_xml.cnpj      = int_ds_docto_xml.cnpj
          AND int_ds_it_docto_xml.serie     = int_ds_docto_xml.serie
          AND int_ds_it_docto_xml.nNF       = int_ds_docto_xml.nNF
          AND int_ds_it_docto_xml.tipo_nota = int_ds_docto_xml.tipo_nota:

        if can-find (first tt-int_ds_it_docto_xml no-lock 
                     WHERE tt-int_ds_it_docto_xml.cnpj      = int_ds_docto_xml.cnpj
                       AND tt-int_ds_it_docto_xml.serie     = int_ds_docto_xml.serie
                       AND tt-int_ds_it_docto_xml.nNF       = int_ds_docto_xml.nNF
                       AND tt-int_ds_it_docto_xml.tipo_nota = int_ds_docto_xml.tipo_nota
                       and tt-int_ds_it_docto_xml.sequencia = int_ds_it_docto_xml.sequencia) then next.

        CREATE tt-int_ds_it_docto_xml.
        BUFFER-COPY int_ds_it_docto_xml TO tt-int_ds_it_docto_xml.

        ASSIGN tt-int_ds_it_docto_xml.cod-estab        = int_ds_docto_xml.cod_estab
               tt-int_ds_it_docto_xml.demi             = int_ds_docto_xml.demi
               tt-int_ds_it_docto_xml.chnfe            = int_ds_docto_xml.chnfe
               tt-int_ds_it_docto_xml.c-nome-emit      = tt-int_ds_docto_xml.c-nome-emit
               tt-int_ds_it_docto_xml.c-uf-emit        = tt-int_ds_docto_xml.c-uf-emit
               tt-int_ds_it_docto_xml.de-base-pis-calc = ROUND(int_ds_it_docto_xml.vprod - int_ds_it_docto_xml.vdesc,2).

        FOR FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = int_ds_it_docto_xml.it_codigo:

            ASSIGN tt-int_ds_it_docto_xml.de-aliq-ipi    = ITEM.aliquota-ipi
                   tt-int_ds_it_docto_xml.i-class-fiscal = INT(ITEM.class-fiscal).

            RUN recupera-aliquotas IN h-cdapi995 (INPUT  "classif-fisc",
                                                  INPUT  ITEM.class-fiscal,
                                                  OUTPUT tt-int_ds_it_docto_xml.de-aliq-pis,
                                                  OUTPUT tt-int_ds_it_docto_xml.de-aliq-cofins).

            IF  tt-int_ds_it_docto_xml.de-aliq-pis    = 0 OR
                tt-int_ds_it_docto_xml.de-aliq-cofins = 0
            THEN DO:
                FOR FIRST classif-fisc NO-LOCK
                    WHERE classif-fisc.class-fiscal = ITEM.class-fiscal:
            
                    IF  tt-int_ds_it_docto_xml.de-aliq-pis = 0
                    THEN
                        ASSIGN tt-int_ds_it_docto_xml.de-aliq-pis = classif-fisc.dec-1.
            
                    IF  tt-int_ds_it_docto_xml.de-aliq-cofins = 0
                    THEN
                        ASSIGN tt-int_ds_it_docto_xml.de-aliq-cofins = classif-fisc.dec-2.
                END.
            END.
        END.

        FOR FIRST natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao = int_ds_it_docto_xml.nat_operacao:
        END.

        if  avail b-unid-feder-orig and 
            avail b-unid-feder-dest 
        then do  i-cont = 1 to 12:
            if  b-unid-feder-orig.est-exc[i-cont] = b-unid-feder-dest.estado 
            then
                assign de-aliquota-icms-excessao = b-unid-feder-orig.perc-exc[i-cont].
        end.

        IF AVAIL emitente 
        THEN DO:
            RUN pi-calcula-aliquota-icms (input  emitente.contrib-icms,
                                          input  emitente.natureza,
                                          input  c-uf-orig,
                                          input  estabelec.pais,
                                          input  c-uf-dest,
                                          input  int_ds_it_docto_xml.it_codigo,
                                          input  int_ds_it_docto_xml.nat_operacao,
                                          output tt-int_ds_it_docto_xml.de-aliq-icms).
    
            IF  c-uf-orig = "PR" AND
                c-uf-dest = "PR"
            THEN DO:
                IF  tt-int_ds_it_docto_xml.de-aliq-icms = 18 
                THEN
                    ASSIGN tt-int_ds_it_docto_xml.de-per-red-bc-calc = 33.33.
    
                IF  tt-int_ds_it_docto_xml.de-aliq-icms = 25 
                THEN
                    ASSIGN tt-int_ds_it_docto_xml.de-per-red-bc-calc = 52.
            END.
        END.

        ASSIGN tt-int_ds_it_docto_xml.de-base-icm-calc  = ROUND(int_ds_it_docto_xml.vprod - int_ds_it_docto_xml.vdesc,2) - (ROUND(int_ds_it_docto_xml.vprod - int_ds_it_docto_xml.vdesc,2) * (tt-int_ds_it_docto_xml.de-per-red-bc-calc / 100))
               tt-int_ds_it_docto_xml.de-valor-icms-cad = tt-int_ds_it_docto_xml.de-base-icm-calc * (tt-int_ds_it_docto_xml.de-aliq-icms / 100).

        IF  AVAIL natur-oper AND
                  natur-oper.cd-trib-icm = 2 /* Isento  */
        THEN
            ASSIGN tt-int_ds_it_docto_xml.de-aliq-icms     = 0
                   tt-int_ds_it_docto_xml.de-base-icm-calc = 0.

        FOR FIRST item-uf NO-LOCK
            WHERE item-uf.it-codigo       = int_ds_it_docto_xml.it_codigo
              AND item-uf.cod-estado-orig = c-uf-orig 
              AND item-uf.estado          = c-uf-dest:

            IF  c-tabela-pauta = ""
            THEN
                ASSIGN tt-int_ds_it_docto_xml.de-perc-va-st = item-uf.perc-red-sub.
            ELSE
                ASSIGN tt-int_ds_it_docto_xml.de-perc-va-st = item-uf.val-perc-reduc-tab-pauta.
        END.


        IF  AVAIL emitente   AND 
            AVAIL ITEM       AND
            AVAIL natur-oper AND 
                  natur-oper.subs-trib = YES 
        THEN DO:
            RUN intprg\int510-icms-st.p (INPUT int_ds_it_docto_xml.cod_emitente,
                                         INPUT int_ds_it_docto_xml.it_codigo,   
                                         INPUT int_ds_it_docto_xml.nat_operacao,
                                         INPUT int_ds_docto_xml.cod_estab,        
                                         INPUT int_ds_it_docto_xml.qCom,        
                                         INPUT int_ds_it_docto_xml.vprod,    
                                         INPUT int_ds_it_docto_xml.vdesc,       
                                         INPUT int_ds_it_docto_xml.vipi,
                                         OUTPUT tt-int_ds_it_docto_xml.de-base-st-calc, 
                                         OUTPUT tt-int_ds_it_docto_xml.de-valor-st-calc, 
                                         OUTPUT tt-int_ds_it_docto_xml.de-perc-st-calc,
                                         OUTPUT tt-int_ds_it_docto_xml.c-tabela-pauta,
                                         OUTPUT tt-int_ds_it_docto_xml.de-tabela-pauta,
                                         OUTPUT tt-int_ds_it_docto_xml.de-per-sub-tri).

            ASSIGN tt-int_ds_it_docto_xml.de-valor-st-calc = tt-int_ds_it_docto_xml.de-valor-st-calc - tt-int_ds_it_docto_xml.de-valor-icms-cad.

            IF  tt-int_ds_it_docto_xml.c-tabela-pauta = ""
            THEN
                ASSIGN tt-int_ds_it_docto_xml.de-tabela-pauta = int_ds_it_docto_xml.vpmc.
        END.

        IF  AVAIL int_ds_ext_emitente                    AND
                  int_ds_ext_emitente.microempresa = YES
        THEN DO:
            ASSIGN tt-int_ds_it_docto_xml.de-per-red-bc-calc = 0
                   tt-int_ds_it_docto_xml.de-base-icm-calc   = 0
                   tt-int_ds_it_docto_xml.de-aliq-icms       = 0
                   tt-int_ds_it_docto_xml.de-valor-icms-cad  = 0.
        END.

        IF  tt-int_ds_it_docto_xml.ncm <> tt-int_ds_it_docto_xml.i-class-fiscal
        THEN
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  tt-int_ds_it_docto_xml.uCom_forn              = "" OR 
            tt-int_ds_it_docto_xml.uCom_forn              = ?  OR 
           trim(string(tt-int_ds_it_docto_xml.uCom_forn)) = "?" 
        THEN 
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  tt-int_ds_it_docto_xml.uCom              = "" OR 
            tt-int_ds_it_docto_xml.uCom              = ?  OR 
           trim(string(tt-int_ds_it_docto_xml.uCom)) = "?" 
        THEN 
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  (tt-int_ds_it_docto_xml.vpmc - tt-int_ds_it_docto_xml.de-tabela-pauta >  de-valor-dif-aceita  OR
             tt-int_ds_it_docto_xml.vpmc - tt-int_ds_it_docto_xml.de-tabela-pauta < (de-valor-dif-aceita * -1))
        THEN
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF   tt-int_ds_it_docto_xml.de-aliq-icms                                      <> 0                    AND
            (tt-int_ds_it_docto_xml.vbc_icms - tt-int_ds_it_docto_xml.de-base-icm-calc >  de-valor-dif-aceita  OR
             tt-int_ds_it_docto_xml.vbc_icms - tt-int_ds_it_docto_xml.de-base-icm-calc < (de-valor-dif-aceita * -1))
        THEN
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  tt-int_ds_it_docto_xml.picms <> tt-int_ds_it_docto_xml.de-aliq-icms
        THEN
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  tt-int_ds_it_docto_xml.predBc <> tt-int_ds_it_docto_xml.de-per-red-bc-calc  
        THEN
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  tt-int_ds_it_docto_xml.vbcst - tt-int_ds_it_docto_xml.de-base-st-calc >  de-valor-dif-aceita OR     
            tt-int_ds_it_docto_xml.vbcst - tt-int_ds_it_docto_xml.de-base-st-calc < (de-valor-dif-aceita * -1)
        THEN
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  tt-int_ds_it_docto_xml.picmsst <> tt-int_ds_it_docto_xml.de-perc-st-calc
        THEN
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  tt-int_ds_it_docto_xml.vicmsst - tt-int_ds_it_docto_xml.de-valor-st-calc >  de-valor-dif-aceita OR   
            tt-int_ds_it_docto_xml.vicmsst - tt-int_ds_it_docto_xml.de-valor-st-calc < (de-valor-dif-aceita * -1)
        THEN
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  tt-int_ds_it_docto_xml.pmvast <> tt-int_ds_it_docto_xml.de-per-sub-tri     
        THEN
            ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                   tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  tt-int_ds_it_docto_xml.ppis <> 0
        THEN DO:
            IF  tt-int_ds_it_docto_xml.ppis <> tt-int_ds_it_docto_xml.de-aliq-pis
            THEN
                ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                       tt-int_ds_it_docto_xml.l-divergente = YES.

            IF  tt-int_ds_it_docto_xml.vbc_pis - tt-int_ds_it_docto_xml.de-base-pis-calc >  de-valor-dif-aceita OR
                tt-int_ds_it_docto_xml.vbc_pis - tt-int_ds_it_docto_xml.de-base-pis-calc < (de-valor-dif-aceita * -1)
            THEN
                ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                       tt-int_ds_it_docto_xml.l-divergente = YES.

            ASSIGN tt-int_ds_it_docto_xml.de-valor-pis-cad = ROUND(tt-int_ds_it_docto_xml.de-base-pis-calc * (tt-int_ds_it_docto_xml.de-aliq-pis / 100),2).

            IF  tt-int_ds_it_docto_xml.vpis - tt-int_ds_it_docto_xml.de-valor-pis-cad >  de-valor-dif-aceita OR
                tt-int_ds_it_docto_xml.vpis - tt-int_ds_it_docto_xml.de-valor-pis-cad < (de-valor-dif-aceita * -1)
            THEN
                ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                       tt-int_ds_it_docto_xml.l-divergente = YES.
        END.
        ELSE
            ASSIGN tt-int_ds_it_docto_xml.de-aliq-pis = 0.

        IF  tt-int_ds_it_docto_xml.pcofins <> 0
        THEN DO:
            IF  tt-int_ds_it_docto_xml.pcofins <> tt-int_ds_it_docto_xml.de-aliq-cofins
            THEN
                ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                       tt-int_ds_it_docto_xml.l-divergente = YES.

            IF  tt-int_ds_it_docto_xml.vbc_cofins - tt-int_ds_it_docto_xml.de-base-pis-calc >  de-valor-dif-aceita OR
                tt-int_ds_it_docto_xml.vbc_cofins - tt-int_ds_it_docto_xml.de-base-pis-calc < (de-valor-dif-aceita * -1)
            THEN
                ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                       tt-int_ds_it_docto_xml.l-divergente = YES.

            ASSIGN tt-int_ds_it_docto_xml.de-valor-cofins-cad = ROUND(tt-int_ds_it_docto_xml.de-base-pis-calc * (tt-int_ds_it_docto_xml.de-aliq-cofins / 100),2).

            IF  tt-int_ds_it_docto_xml.vcofins - tt-int_ds_it_docto_xml.de-valor-cofins-cad >  de-valor-dif-aceita OR
                tt-int_ds_it_docto_xml.vcofins - tt-int_ds_it_docto_xml.de-valor-cofins-cad < (de-valor-dif-aceita * -1)
            THEN
                ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                       tt-int_ds_it_docto_xml.l-divergente = YES.
        END.
        ELSE
            ASSIGN tt-int_ds_it_docto_xml.de-aliq-cofins = 0.

       IF  AVAIL int_ds_ext_emitente                    AND
                 int_ds_ext_emitente.microempresa = YES AND
                 tt-int_ds_it_docto_xml.pipi      = 0
       THEN 
           ASSIGN tt-int_ds_it_docto_xml.de-aliq-ipi = 0.

       IF  tt-int_ds_it_docto_xml.pipi <> tt-int_ds_it_docto_xml.de-aliq-ipi
       THEN
           ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                  tt-int_ds_it_docto_xml.l-divergente = YES.

       IF  tt-int_ds_it_docto_xml.pipi        <> 0 OR 
           tt-int_ds_it_docto_xml.de-aliq-ipi <> 0
       THEN DO:
           IF  tt-int_ds_it_docto_xml.vbc_ipi - tt-int_ds_it_docto_xml.de-base-pis-calc >  de-valor-dif-aceita OR
               tt-int_ds_it_docto_xml.vbc_ipi - tt-int_ds_it_docto_xml.de-base-pis-calc < (de-valor-dif-aceita * -1)
           THEN
               ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                      tt-int_ds_it_docto_xml.l-divergente = YES.
    
           ASSIGN tt-int_ds_it_docto_xml.de-valor-ipi-cad = ROUND(tt-int_ds_it_docto_xml.de-base-pis-calc * (tt-int_ds_it_docto_xml.de-aliq-ipi / 100),2).
    
           IF  tt-int_ds_it_docto_xml.vipi - tt-int_ds_it_docto_xml.de-valor-ipi-cad >  de-valor-dif-aceita OR
               tt-int_ds_it_docto_xml.vipi - tt-int_ds_it_docto_xml.de-valor-ipi-cad < (de-valor-dif-aceita * -1)
           THEN
               ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                      tt-int_ds_it_docto_xml.l-divergente = YES.
       END.

       ASSIGN tt-int_ds_it_docto_xml.de-total-nf  = ROUND(int_ds_it_docto_xml.vprod - int_ds_it_docto_xml.vicmsdeson - int_ds_it_docto_xml.vdesc  + int_ds_it_docto_xml.voutro + int_ds_it_docto_xml.vicmsst             + int_ds_it_docto_xml.vipi,2)
              tt-int_ds_it_docto_xml.de-total-cad = ROUND(int_ds_it_docto_xml.vprod - int_ds_it_docto_xml.vicmsdeson - int_ds_it_docto_xml.vdesc  + int_ds_it_docto_xml.voutro + tt-int_ds_it_docto_xml.de-valor-st-calc + tt-int_ds_it_docto_xml.de-valor-ipi-cad,2).

       IF  (tt-int_ds_it_docto_xml.de-total-nf - tt-int_ds_it_docto_xml.de-total-cad >  de-valor-dif-aceita  OR
            tt-int_ds_it_docto_xml.de-total-nf - tt-int_ds_it_docto_xml.de-total-cad < (de-valor-dif-aceita * -1))
       THEN
           ASSIGN tt-int_ds_docto_xml.l-divergente    = YES
                  tt-int_ds_it_docto_xml.l-divergente = YES.

        IF  tg-divergente = YES AND
            tt-int_ds_it_docto_xml.l-divergente = NO
        THEN
            DELETE tt-int_ds_it_docto_xml.
    END.
    
    IF  tg-divergente = YES AND
        tt-int_ds_docto_xml.l-divergente = NO
    THEN
        DELETE tt-int_ds_docto_xml.

    IF  VALID-HANDLE(h-cdapi995) 
    THEN DO:
        RUN pi-finalizar IN h-cdapi995.
        ASSIGN h-cdapi995 = ?.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-excel w-cadpaifilho-ambos 
PROCEDURE pi-gera-excel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR chExcel         AS   COM-HANDLE NO-UNDO. 
    DEF VAR chArquivo       AS   COM-HANDLE NO-UNDO. 
    DEF VAR chPlanilha      AS   COM-HANDLE NO-UNDO.
    DEF VAR v-arq-dest      AS         CHAR NO-UNDO.
        
    ASSIGN v-arq-dest = SESSION:TEMP-DIRECTORY + "nire003.csv".
    OS-DELETE VALUE(v-arq-dest) NO-ERROR.

    OUTPUT TO VALUE(v-arq-dest) CONVERT TARGET "iso8859-1".

    PUT UNFORMATTED "Emiss∆o;Transaá∆o;NF;SÇrie;Fornec;Nome Fornecedor;UF;Seq;ITEM;ITEM Fornec;Descriá∆o;Nat Oper;Divergente;NCM NF;NCM Cad;Qtd;Qtd Fornec;Un;Un Fornec;Vlr Unit;Vlr Desconto;Vlr Despesas;Vlr Total Prod;Base ICMS NF;Base ICMS Cad;% Red BC NF;% Red BC Cad;%ICMS NF;% ICMS Cad;Valor ICMS NF;Valor ICMS CAD;Vlr ICMS Deson NF;Base ST NF;Base ST Cad;% MVA NF;% MVA Cad;Vl PMC NF;Vl PMC Cad;% ST NF;% ST Cad;% Red Cad;Valor ST NF;Valor ST Cad;Base PIS NF;Base PIS Cad;% PIS NF;% PIS Cad;Valor PIS NF;Valor PIS Cad;Base Cofins NF;Base Cofins Cad;% Cofins NF;% Cofins Cad;Valor Cofins NF;Valor Cofins Cad;Base IPI NF;Base IPI Cad;% IPI NF;% IPI Cad;Valor IPI NF;Valor IPI Cad;Total NF;Total Cad;Chave NFE" SKIP.

    FOR EACH  tt-int_ds_docto_xml,
        EACH  tt-int_ds_it_docto_xml 
        WHERE tt-int_ds_it_docto_xml.cnpj      = tt-int_ds_docto_xml.cnpj
          AND tt-int_ds_it_docto_xml.serie     = tt-int_ds_docto_xml.serie
          AND tt-int_ds_it_docto_xml.nNF       = tt-int_ds_docto_xml.nNF
          AND tt-int_ds_it_docto_xml.tipo_nota = tt-int_ds_docto_xml.tipo_nota:

        ASSIGN tt-int_ds_it_docto_xml.chnfe = "'" + tt-int_ds_it_docto_xml.chnfe.


        IF tt-int_ds_it_docto_xml.vpmc > 0  THEN
            ASSIGN tt-int_ds_it_docto_xml.de-per-sub-tri = 0.

        PUT UNFORMATTED tt-int_ds_docto_xml.dEmi                   ";"
                        tt-int_ds_docto_xml.dt_trans               ";"
                        tt-int_ds_docto_xml.nNF                    ";"
                        tt-int_ds_docto_xml.serie                  ";"
                        tt-int_ds_docto_xml.cod_emitente           ";"
                        tt-int_ds_docto_xml.c-nome-emit            ";"
                        tt-int_ds_docto_xml.c-uf-emit              ";"            
                        tt-int_ds_it_docto_xml.sequencia           ";"
                        tt-int_ds_it_docto_xml.it_codigo           ";"
                        tt-int_ds_it_docto_xml.item_do_forn        ";"
                        tt-int_ds_it_docto_xml.xProd               ";"
                        tt-int_ds_it_docto_xml.nat_operacao        ";"
                        tt-int_ds_it_docto_xml.l-divergente        FORMAT "Sim/N∆o" ";"
                        tt-int_ds_it_docto_xml.ncm                 ";"
                        tt-int_ds_it_docto_xml.i-class-fiscal      ";"
                        tt-int_ds_it_docto_xml.qCom                ";"
                        tt-int_ds_it_docto_xml.qCom_forn           ";"
                        tt-int_ds_it_docto_xml.uCom                ";"
                        tt-int_ds_it_docto_xml.uCom_forn           ";"
                        tt-int_ds_it_docto_xml.vUnCom              ";"
                        tt-int_ds_it_docto_xml.vDesc               ";"
                        tt-int_ds_it_docto_xml.voutro              ";"
                        tt-int_ds_it_docto_xml.vprod               ";"
                        tt-int_ds_it_docto_xml.vbc_icms            ";"
                        tt-int_ds_it_docto_xml.de-base-icm-calc    ";"
                        tt-int_ds_it_docto_xml.predBc              ";"
                        tt-int_ds_it_docto_xml.de-per-red-bc-calc  ";"
                        tt-int_ds_it_docto_xml.picms               ";"
                        tt-int_ds_it_docto_xml.de-aliq-icms        ";"
                        tt-int_ds_it_docto_xml.vicms               ";"
                        string(tt-int_ds_it_docto_xml.de-valor-icms-cad,">>>>>>>>9.99")   ";"  /* incluido kleber */
                        tt-int_ds_it_docto_xml.vicmsdeson          ";"
                        tt-int_ds_it_docto_xml.vbcst               ";"
                        tt-int_ds_it_docto_xml.de-base-st-calc     ";"
                        tt-int_ds_it_docto_xml.pmvast              ";"
                        tt-int_ds_it_docto_xml.de-per-sub-tri      ";"
                        tt-int_ds_it_docto_xml.vpmc                ";"  /* incluido kleber */
                        tt-int_ds_it_docto_xml.de-tabela-pauta     ";"  /* incluido kleber */
                        tt-int_ds_it_docto_xml.picmsst             ";"
                        tt-int_ds_it_docto_xml.de-perc-st-calc     ";"
                        tt-int_ds_it_docto_xml.de-perc-va-st       ";"
                        tt-int_ds_it_docto_xml.vicmsst             ";"
                        tt-int_ds_it_docto_xml.de-valor-st-calc    ";"
                        tt-int_ds_it_docto_xml.vbc_pis             ";"
                        tt-int_ds_it_docto_xml.de-base-pis-calc    ";"
                        tt-int_ds_it_docto_xml.ppis                ";"
                        tt-int_ds_it_docto_xml.de-aliq-pis         ";"
                        tt-int_ds_it_docto_xml.vpis                ";"
                        tt-int_ds_it_docto_xml.de-valor-pis-cad    ";"
                        tt-int_ds_it_docto_xml.vbc_cofins          ";"
                        tt-int_ds_it_docto_xml.de-base-pis-calc    ";"
                        tt-int_ds_it_docto_xml.pcofins             ";"
                        tt-int_ds_it_docto_xml.de-aliq-cofins      ";"
                        tt-int_ds_it_docto_xml.vcofins             ";"
                        tt-int_ds_it_docto_xml.de-valor-cofins-cad ";"
                        tt-int_ds_it_docto_xml.vbc_ipi             ";"
                        tt-int_ds_it_docto_xml.de-base-pis-calc    ";"
                        tt-int_ds_it_docto_xml.pipi                ";"
                        tt-int_ds_it_docto_xml.de-aliq-ipi         ";"
                        tt-int_ds_it_docto_xml.vipi                ";"
                        tt-int_ds_it_docto_xml.de-valor-ipi-cad    ";"
                        tt-int_ds_it_docto_xml.de-total-nf         ";"
                        tt-int_ds_it_docto_xml.de-total-cad        ";"
                        tt-int_ds_it_docto_xml.chnfe              SKIP.
    END.

    OUTPUT CLOSE.
    

    CREATE 'Excel.Application' chExcel.
    chExcel:VISIBLE        = NO.
    chExcel:ScreenUpdating = NO. 
    chexcel:WindowState    = 3.
    chArquivo  = chExcel:WorkBooks:OPEN (REPLACE(v-arq-dest,"/","\")).
    chArquivo:Activate().
    chPlanilha = chExcel:Sheets:Item(1). 
    chexcel:Columns("A:BA"):EntireColumn:AutoFit.
    chPlanilha = chExcel:Range('A2'):SELECT.
    chExcel:VISIBLE        = YES.
    chExcel:ScreenUpdating = YES. 

    RELEASE OBJECT chArquivo  NO-ERROR.
    RELEASE OBJECT chPlanilha NO-ERROR.
    RELEASE OBJECT chExcel    NO-ERROR.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-cadpaifilho-ambos  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-int_ds_docto_xml"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-cadpaifilho-ambos 
PROCEDURE state-changed :
/*:T -----------------------------------------------------------
  Purpose:     Manuseia trocas de estado dos SmartObjects
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

