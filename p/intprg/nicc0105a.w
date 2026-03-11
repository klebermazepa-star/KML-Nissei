&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          mgind            PROGRESS
*/
&Scoped-define WINDOW-NAME wMasterDetail


/* Temp-Table and Buffer definitions                                    */

DEFINE TEMP-TABLE tt-item-fornec NO-UNDO LIKE item-fornec
       field r-rowid as rowid.
DEFINE TEMP-TABLE tt-item-fornec-umd NO-UNDO LIKE item-fornec-umd
       field r-rowid as rowid.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wMasterDetail 
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i NICC0105A 2.00.00.000}  /*** 010001 ***/

/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program          NICC0105A
&GLOBAL-DEFINE Version          2.00.00.000

&GLOBAL-DEFINE Folder           yes
&GLOBAL-DEFINE InitialPage      1

&GLOBAL-DEFINE FolderLabels     Alternativos

&GLOBAL-DEFINE First            no
&GLOBAL-DEFINE Prev             no
&GLOBAL-DEFINE Next             no
&GLOBAL-DEFINE Last             no
&GLOBAL-DEFINE GoTo             no
&GLOBAL-DEFINE Search           no

&GLOBAL-DEFINE AddSon1          YES
&GLOBAL-DEFINE UpdateSon1       YES
&GLOBAL-DEFINE DeleteSon1       YES

&GLOBAL-DEFINE ttParent         tt-item-fornec
&GLOBAL-DEFINE hDBOParent       h-boin178
&GLOBAL-DEFINE DBOParentTable   item-fornec

&GLOBAL-DEFINE ttSon1           tt-item-fornec-umd
&GLOBAL-DEFINE hDBOSon1         h-boin841         
&GLOBAL-DEFINE DBOSon1Table     item-fornec-umd   

&GLOBAL-DEFINE page0Fields      tt-item-fornec.it-codigo ~
                                tt-item-fornec.cod-emitente
&GLOBAL-DEFINE page1Browse      brSon1
&GLOBAL-DEFINE page2Browse      

/* Parameters Definitions ---                                           */
define INPUT PARAM c-item     like item-fornec.it-codigo    no-undo.
define INPUT PARAM i-emitente like item-fornec.cod-emitente no-undo.
/* Local Variable Definitions ---                                       */

/* Local Variable Definitions (DBOs Handles) ---                        */
DEFINE VARIABLE {&hDBOParent} AS HANDLE NO-UNDO.
DEFINE VARIABLE {&hDBOSon1}   AS HANDLE NO-UNDO.
def var ccod-emitente as char no-undo.
def var h-boad098na as handle no-undo.
def var h-boin172   AS HANDLE NO-UNDO.
def var h-boin417   AS HANDLE NO-UNDO.

def var cclasse-repro as char no-undo.
def var c-desc-pagto  as char no-undo format "x(20)" label "Descri‡Æo Cond Pagamento".

def var c-format      as char   no-undo.
def var c-descricao-un  as char no-undo format "x(20)" label "Descri‡Æo UN".

DEFINE VARIABLE wh-pesquisa AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE MasterDetail
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0
&Scoped-define BROWSE-NAME brSon1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-item-fornec-umd

/* Definitions for BROWSE brSon1                                        */
&Scoped-define FIELDS-IN-QUERY-brSon1 tt-item-fornec-umd.unid-med-for ~
fnDescUn()@ c-descricao-un tt-item-fornec.cod-livre-1 tt-item-fornec-umd.log-ativo tt-item-fornec-umd.fator-conver ~
tt-item-fornec-umd.num-casa-dec tt-item-fornec-umd.lote-minimo tt-item-fornec-umd.lote-mul-for
&Scoped-define ENABLED-FIELDS-IN-QUERY-brSon1 
&Scoped-define QUERY-STRING-brSon1 FOR EACH tt-item-fornec-umd NO-LOCK
&Scoped-define OPEN-QUERY-brSon1 OPEN QUERY brSon1 FOR EACH tt-item-fornec-umd NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brSon1 tt-item-fornec-umd
&Scoped-define FIRST-TABLE-IN-QUERY-brSon1 tt-item-fornec-umd


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brSon1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-item-fornec.it-codigo c-desc-item tt-item-fornec.cod-emitente c-nom-emit
&Scoped-define ENABLED-TABLES tt-item-fornec
&Scoped-define FIRST-ENABLED-TABLE tt-item-fornec
&Scoped-Define ENABLED-OBJECTS /*rtParent rtToolBar btFirst btPrev btNext ~
btLast btGoTo btSearch*/ btQueryJoins btReportsJoins btExit btHelp 
&Scoped-Define DISPLAYED-FIELDS tt-item-fornec.it-codigo c-desc-item tt-item-fornec.cod-emitente c-nom-emit
&Scoped-define DISPLAYED-TABLES tt-item-fornec
&Scoped-define FIRST-DISPLAYED-TABLE tt-item-fornec


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnDescUn wMasterDetail 
FUNCTION fnDescUn RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnDescItem wMasterDetail 
FUNCTION fnDescItem RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnNomeEmitente wMasterDetail 
FUNCTION fnNomeEmitente RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wMasterDetail AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miQueryJoins   LABEL "&Consultas"    
       MENU-ITEM miReportsJoins LABEL "&Relat¢rios"   
       RULE
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       RULE
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of the field level widgets                               */

DEFINE VARIABLE c-desc-item AS CHARACTER FORMAT "X(60)":U 
     VIEW-AS FILL-IN 
     SIZE 27 BY .88 NO-UNDO.

DEFINE VARIABLE c-nom-emit AS CHARACTER FORMAT "X(60)":U
     VIEW-AS FILL-IN
     SIZE 27 BY .88 NO-UNDO.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btQueryJoins 
     IMAGE-UP FILE "image\im-joi":U
     IMAGE-INSENSITIVE FILE "image\ii-joi":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE RECTANGLE rtParent
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 2.25.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON btAddSon1 
     LABEL "&Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeleteSon1 
     LABEL "&Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdateSon1 
     LABEL "&Alterar" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brSon1 FOR 
      tt-item-fornec-umd SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brSon1 wMasterDetail _STRUCTURED
  QUERY brSon1 DISPLAY
      tt-item-fornec-umd.cod-livre-1 FORMAT "X(20)" COLUMN-LABEL "C¢digo"  
      tt-item-fornec-umd.unid-med-for column-label "Unidade"
      fnDescUn()@ c-descricao-un      column-label "Descri‡Æo"
      tt-item-fornec-umd.fator-conver column-label "Fator ConversÆo"
      tt-item-fornec-umd.num-casa-dec column-label "Dec"
      tt-item-fornec-umd.log-ativo
      tt-item-fornec-umd.lote-minimo  format ">>>>>,>>9.9999":U
      tt-item-fornec-umd.lote-mul-for column-label "Lote M£ltiplo" format ">>>>>,>>9.9999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 82 BY 5.77
         FONT 2.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     btQueryJoins AT ROW 1.13 COL 74.86 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.86 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 82.86 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.86 HELP
          "Ajuda"
     tt-item-fornec.it-codigo AT ROW 2.83 COL 10 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 27 BY .88
     c-desc-item AT ROW 2.83 COL 37 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 51.14 BY .88
     tt-item-fornec.cod-emitente AT ROW 3.83 COL 10 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 8 BY .88
     c-nom-emit AT ROW 3.83 COL 18 colon-aligned no-label
          VIEW-AS FILL-IN 
          SIZE 27 BY .88
     rtParent AT ROW 2.67 COL 1
     rtToolBar AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 13.08
         FONT 1.

DEFINE FRAME fPage1
     brSon1 AT ROW 1.5 COL 2
     btAddSon1 AT ROW 5.92 COL 2
     btUpdateSon1 AT ROW 5.92 COL 12
     btDeleteSon1 AT ROW 5.92 COL 22
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 6.38
         SIZE 84.43 BY 6.67
         FONT 1.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MasterDetail
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt-item T "?" NO-UNDO mgind item
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
      TABLE: tt-item-fornec T "?" NO-UNDO mgind item-fornec
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wMasterDetail ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 13.13
         WIDTH              = 90
         MAX-HEIGHT         = 17
         MAX-WIDTH          = 90
         VIRTUAL-HEIGHT     = 17
         VIRTUAL-WIDTH      = 90
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

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU mbMain:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wMasterDetail 
/* ************************* Included-Libraries *********************** */

{masterdetail/masterdetail.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wMasterDetail
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fPage0:HANDLE.

/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brSon1 1 fPage1 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wMasterDetail)
THEN wMasterDetail:HIDDEN = yes.

ASSIGN 
       btAddSon1:HIDDEN IN FRAME fPage1           = TRUE.

/* SETTINGS FOR BUTTON btDeleteSon1 IN FRAME fPage1
   NO-ENABLE                                                            */
ASSIGN 
       btDeleteSon1:HIDDEN IN FRAME fPage1           = TRUE.

/* SETTINGS FOR BUTTON btUpdateSon1 IN FRAME fPage1
   NO-ENABLE                                                            */
ASSIGN 
       btUpdateSon1:HIDDEN IN FRAME fPage1           = TRUE.


/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brSon1
/* Query rebuild information for BROWSE brSon1
     _TblList          = "Temp-Tables.tt-item-fornec"
     _FldNameList[1]   = Temp-Tables.tt-item-fornec.cod-emitente
     _FldNameList[2]   > "_<CALC>"
"fnEmitente(input tt-item-fornec.cod-emitente) @ ccod-emitente" "Nome-Abrev" "x(20)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   = Temp-Tables.tt-item-fornec.item-do-forn
     _FldNameList[4]   = Temp-Tables.tt-item-fornec.unid-med-for
     _FldNameList[5]   = Temp-Tables.tt-item-fornec.fator-conver
     _FldNameList[6]   = Temp-Tables.tt-item-fornec.num-casa-dec
     _FldNameList[7]   = Temp-Tables.tt-item-fornec.cod-cond-pag
     _FldNameList[8]   = Temp-Tables.tt-item-fornec.perc-compra
     _FldNameList[9]   = Temp-Tables.tt-item-fornec.cod-mensagem
     _FldNameList[10]   = Temp-Tables.tt-item-fornec.lote-minimo
     _FldNameList[11]   = Temp-Tables.tt-item-fornec.lote-mul-for
     _FldNameList[12]   = Temp-Tables.tt-item-fornec.tempo-ressup
     _FldNameList[13]   = Temp-Tables.tt-item-fornec.contr-forn
     _FldNameList[14]   > "_<CALC>"
"fnClasse(input tt-item-fornec.classe-repro) @ cclasse-repro" "Classe Reprograma‡Æo" "x(30)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[15]   > "_<CALC>"
"fnDescPagto() @ c-desc-pagto" ? ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE brSon1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage0
/* Query rebuild information for FRAME fPage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage0 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage1
/* Query rebuild information for FRAME fPage1
     _Query            is NOT OPENED
*/  /* FRAME fPage1 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wMasterDetail
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMasterDetail wMasterDetail
ON END-ERROR OF wMasterDetail
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMasterDetail wMasterDetail
ON WINDOW-CLOSE OF wMasterDetail
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wMasterDetail
ON CHOOSE OF btExit IN FRAME fPage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wMasterDetail
ON CHOOSE OF btHelp IN FRAME fPage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wMasterDetail
ON CHOOSE OF btQueryJoins IN FRAME fPage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wMasterDetail
ON CHOOSE OF btReportsJoins IN FRAME fPage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMasterDetail 


/*--- L¢gica para inicializa‡Æo do programam ---*/
{masterdetail/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDestroyInterface wMasterDetail 
PROCEDURE afterDestroyInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF VALID-HANDLE(h-boin178) then do:
        DELETE PROCEDURE h-boin178.
        assign h-boin178 = ?.
    end.
    IF VALID-HANDLE(h-boin841) then do:
        DELETE PROCEDURE h-boin841.
        assign h-boin841 = ?.
    end.
    IF VALID-HANDLE(h-boad098na) then do:
        DELETE PROCEDURE h-boad098na.
        assign h-boad098na = ?.
    end.
    IF VALID-HANDLE(h-boin172) THEN DO:
        DELETE PROCEDURE h-boin172.
        assign h-boin172 = ?.
    END.
    IF VALID-HANDLE(h-boin417) THEN DO:
        DELETE PROCEDURE h-boin417.
        assign h-boin417 = ?.
    END.

    return "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDisplayFields wMasterDetail 
PROCEDURE afterDisplayFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    if avail tt-item-fornec then
        assign c-desc-item:screen-value in frame fPage0 = fnDescItem()
               c-nom-emit:screen-value in frame fPage0 = fnNomeEmitente().

    return "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializeDBOs wMasterDetail 
PROCEDURE initializeDBOs :
/*------------------------------------------------------------------------------
  Purpose:     Inicializa DBOs
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

    /*--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOParent}) THEN DO:
        {btb/btb008za.i1 inbo/boin178.p}
        {btb/btb008za.i2 inbo/boin178.p '' {&hDBOParent}} 
    END.
    run setConstraintFaixaByItCodigo IN {&hDBOParent} (input i-emitente,
                                                       input c-item,
                                                       input c-item).
    RUN openQueryStatic IN {&hDBOParent} (INPUT "FaixaByItCodigo":U).
    run getRecord IN {&hDBOParent} (output table tt-item-fornec).
   
    /*--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOSon1}) THEN DO:
        {btb/btb008za.i1 inbo/boin841.p}
        {btb/btb008za.i2 inbo/boin841.p '' {&hDBOSon1}} 
    END.
    /*run openQueriesSon in this-procedure.*/

    /*--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE(h-boad098na) THEN DO:
        {btb/btb008za.i1 adbo/boad098na.p}
        {btb/btb008za.i2 adbo/boad098na.p '' h-boad098na} 
    END.
    RUN openQueryStatic IN h-boad098na (INPUT "Main":U).

    IF NOT VALID-HANDLE(h-boin172) THEN DO:
        {btb/btb008za.i1 inbo/boin172.p}
        {btb/btb008za.i2 inbo/boin172.p '' h-boin172}
    END.
    RUN openQueryStatic IN h-boin172 (INPUT "Main":U).

    IF NOT VALID-HANDLE(h-boin417) THEN DO:
        {btb/btb008za.i1 inbo/boin417.p}
        {btb/btb008za.i2 inbo/boin417.p '' h-boin417}
    END.
    run openQueryStatic in h-boin417("main":U).

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openQueriesSon wMasterDetail 
PROCEDURE openQueriesSon :
/*------------------------------------------------------------------------------
  Purpose:     Atualiza browsers filhos
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

    if valid-handle ({&hDBOSon1}) then do:
        RUN linkToItemFornec IN {&hDBOSon1} (INPUT {&hDBOParent}).        
        /*--- Abre query do DBO filho ---*/
        RUN openQueryStatic IN {&hDBOSon1} (INPUT "ByItemFornec":U).           
       /* run getFirst in {&hDBOSon1}.*/
        RUN getBatchRecords IN {&hDBOSon1} (INPUT ?,
                                            INPUT NO,
                                            INPUT 40,
                                            OUTPUT iRowsReturned,
                                            OUTPUT TABLE {&ttSon1}).
        {&open-query-brson1}
    end.
    
    run enableButtons.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enableButtons wMasterDetail 
PROCEDURE enableButtons :
/*------------------------------------------------------------------------------
  Purpose:     Habilita botäes
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

    if  num-results("brSon1":U) = 0 then
        assign btDeleteSon1:sensitive in frame fPage1 = no
               btUpdateSon1:sensitive in frame fPage1 = no.
    else
        assign btDeleteSon1:sensitive in frame fPage1 = yes
               btUpdateSon1:sensitive in frame fPage1 = yes. 
    assign btAddSon1:sensitive in frame fPage1 = yes.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnDescUn wMasterDetail 
FUNCTION fnDescUn RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  def var c-descricao as char   no-undo.
    if valid-handle(h-boin417) then do:
        RUN goToKey in h-boin417 (input tt-item-fornec-umd.unid-med-for).
        if return-value = "Ok" then
           run getCharField in h-boin417 (input "descricao":U, output c-descricao).
    end.

    RETURN c-descricao.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnDescItem wMasterDetail 
FUNCTION fnDescItem RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  def var c-descricao as char   no-undo.
    RUN GotoKey in h-boin172 (input tt-item-fornec.it-codigo).
    if return-value = "Ok" then
       run getCharField in h-boin172 (input "desc-item":U, output c-descricao).

    RETURN c-descricao.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnNomeEmitente wMasterDetail 
FUNCTION fnNomeEmitente RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  def var cnome-abrev as char no-undo.
  RUN GotoKey in h-boad098na (input tt-item-fornec.cod-emitente).
  if return-value = "Ok" then
      RUN GetCharField in h-boad098na (input "nome-abrev", output cnome-abrev).

  RETURN cnome-abrev.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
