&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS B-table-Win 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int520-browser-itens 1.12.01.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/browserd.w

/* Parameters Definitions ---                                           */
 
/* Local Variable Definitions ---                                       */

/*:T Variaveis usadas internamente pelo estilo, favor nao elimina-las     */

/*:T v ri veis de uso globla */
def  var v-row-parent    as rowid no-undo.

/*:T vari veis de uso local */
def var v-row-table  as rowid no-undo.

/*:T fim das variaveis utilizadas no estilo */

def var c-desc-item as char no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE BrowserCadastro2
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br-table

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int_ds_nota_entrada
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_nota_entrada


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_nota_entrada.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES int_ds_nota_entrada_produt

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table ~
int_ds_nota_entrada_produt.nep_sequencia_n ~
int_ds_nota_entrada_produt.alternativo_fornecedor ~
int_ds_nota_entrada_produt.nep_produto_n ~
fnItem(int_ds_nota_entrada_produt.nep_produto_n) @ c-desc-item ~
int_ds_nota_entrada_produt.nep_ncm_n ~
int_ds_nota_entrada_produt.nen_cfop_n ~
int_ds_nota_entrada_produt.nep_cstb_icm_n ~
int_ds_nota_entrada_produt.nep_quantidade_n ~
int_ds_nota_entrada_produt.nep_valorbruto_n ~
int_ds_nota_entrada_produt.nep_valordesconto_n ~
int_ds_nota_entrada_produt.nep_valorliquido_n ~
int_ds_nota_entrada_produt.nep_valoripi_n ~
int_ds_nota_entrada_produt.nep_baseicms_n ~
int_ds_nota_entrada_produt.nep_valoricms_n ~
int_ds_nota_entrada_produt.nep_basest_n ~
int_ds_nota_entrada_produt.nep_icmsst_n ~
int_ds_nota_entrada_produt.nep_valorpis_n ~
int_ds_nota_entrada_produt.nep_valorcofins_n 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table 
&Scoped-define QUERY-STRING-br-table FOR EACH int_ds_nota_entrada_produt query-tuning(no-lookahead) WHERE int_ds_nota_entrada_produt.nen_cnpj_origem = int_ds_nota_entrada.nen_cnpj_origem ~
  AND int_ds_nota_entrada_produt.nen_serie_s = int_ds_nota_entrada.nen_serie_s ~
  AND int_ds_nota_entrada_produt.nen_notafiscal_n = int_ds_nota_entrada.nen_notafiscal_n NO-LOCK ~
    BY int_ds_nota_entrada_produt.nep_sequencia_n
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH int_ds_nota_entrada_produt  WHERE int_ds_nota_entrada_produt.nen_cnpj_origem = int_ds_nota_entrada.nen_cnpj_origem ~
  AND int_ds_nota_entrada_produt.nen_serie_s = int_ds_nota_entrada.nen_serie_s ~
  AND int_ds_nota_entrada_produt.nen_notafiscal_n = int_ds_nota_entrada.nen_notafiscal_n NO-LOCK ~
    BY int_ds_nota_entrada_produt.nep_sequencia_n query-tuning(no-lookahead).
&Scoped-define TABLES-IN-QUERY-br-table int_ds_nota_entrada_produt
&Scoped-define FIRST-TABLE-IN-QUERY-br-table int_ds_nota_entrada_produt


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br-table bt-modificar 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" B-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS
><EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Advanced Query Options" B-table-Win _INLINE
/* Actions: ? adm/support/advqedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<SORTBY-OPTIONS>
</SORTBY-OPTIONS>
<SORTBY-RUN-CODE>
************************
* Set attributes related to SORTBY-OPTIONS */
RUN set-attribute-list (
    'SortBy-Options = ""':U).
/************************
</SORTBY-RUN-CODE>
<FILTER-ATTRIBUTES>
************************
* Initialize Filter Attributes */
RUN set-attribute-list IN THIS-PROCEDURE ('
  Filter-Value=':U).
/************************
</FILTER-ATTRIBUTES> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnItem B-table-Win 
FUNCTION fnItem RETURNS CHARACTER
  ( p-it-codigo as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-modificar 
     LABEL "&Modificar" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      int_ds_nota_entrada_produt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      int_ds_nota_entrada_produt.nep_sequencia_n COLUMN-LABEL "Seq" FORMAT ">>>,>>>,>>9":U
            WIDTH 3.29
      int_ds_nota_entrada_produt.alternativo_fornecedor COLUMN-LABEL "Item Fornecedor" FORMAT "x(20)":U
            WIDTH 14
      int_ds_nota_entrada_produt.nep_produto_n FORMAT ">>>>>>>>9":U
            WIDTH 7.86
      fnItem(int_ds_nota_entrada_produt.nep_produto_n) @ c-desc-item COLUMN-LABEL "Descri‡Æo" FORMAT "X(65)":U
            WIDTH 16.57
      int_ds_nota_entrada_produt.nep_ncm_n FORMAT ">>>>>>>9":U
      int_ds_nota_entrada_produt.nen_cfop_n FORMAT ">>>9":U
      int_ds_nota_entrada_produt.nep_cstb_icm_n COLUMN-LABEL "CST ICMS" FORMAT "99":U
            WIDTH 7.72
      int_ds_nota_entrada_produt.nep_quantidade_n COLUMN-LABEL "Qtde" FORMAT "->>>,>>>,>>9.99":U
            WIDTH 6.29
      int_ds_nota_entrada_produt.nep_valorbruto_n FORMAT "->,>>>,>>9.99999":U
      int_ds_nota_entrada_produt.nep_valordesconto_n FORMAT "->,>>>,>>9.99999":U
            WIDTH 9.72
      int_ds_nota_entrada_produt.nep_valorliquido_n FORMAT "->,>>>,>>9.99999":U
            WIDTH 11
      int_ds_nota_entrada_produt.nep_valoripi_n FORMAT "->,>>>,>>9.99999":U
            WIDTH 5.14
      int_ds_nota_entrada_produt.nep_baseicms_n FORMAT "->,>>>,>>9.99999":U
            WIDTH 8.86
      int_ds_nota_entrada_produt.nep_valoricms_n FORMAT "->,>>>,>>9.99999":U
            WIDTH 7.43
      int_ds_nota_entrada_produt.nep_basest_n FORMAT "->,>>>,>>9.99999":U
            WIDTH 10
      int_ds_nota_entrada_produt.nep_icmsst_n FORMAT "->,>>>,>>9.99999":U
            WIDTH 6.86
      int_ds_nota_entrada_produt.nep_valorpis_n FORMAT "->,>>>,>>9.99999":U
            WIDTH 8.57
      int_ds_nota_entrada_produt.nep_valorcofins_n COLUMN-LABEL "Vlr Cofins" FORMAT "->,>>>,>>9.99999":U
            WIDTH 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 142.57 BY 9.5
         FONT 1 ROW-HEIGHT-CHARS .5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     br-table AT ROW 1 COL 1
     bt-modificar AT ROW 10.5 COL 1 WIDGET-ID 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: BrowserCadastro2
   External Tables: custom.int_ds_nota_entrada
   Allow: Basic,Browse
   Frames: 1
   Add Fields to: External-Tables
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW B-table-Win ASSIGN
         HEIGHT             = 10.63
         WIDTH              = 142.57.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB B-table-Win 
/* ************************* Included-Libraries *********************** */

{utp/ut-glob.i}
{src/adm/method/browser.i}
{include/c-brows3.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW B-table-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit L-To-R                            */
/* BROWSE-TAB br-table 1 F-Main */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN 
       br-table:COLUMN-RESIZABLE IN FRAME F-Main       = TRUE
       br-table:COLUMN-MOVABLE IN FRAME F-Main         = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "custom.int_ds_nota_entrada_produt WHERE custom.int_ds_nota_entrada <external> ..."
     _Options          = "NO-LOCK KEY-PHRASE"
     _OrdList          = "custom.int_ds_nota_entrada_produt.nep_sequencia_n|yes"
     _JoinCode[1]      = "custom.int_ds_nota_entrada_produt.nen_cnpj_origem = custom.int_ds_nota_entrada.nen_cnpj_origem
  AND custom.int_ds_nota_entrada_produt.nen_serie_s = custom.int_ds_nota_entrada.nen_serie_s
  AND custom.int_ds_nota_entrada_produt.nen_notafiscal_n = custom.int_ds_nota_entrada.nen_notafiscal_n"
     _FldNameList[1]   > custom.int_ds_nota_entrada_produt.nep_sequencia_n
"int_ds_nota_entrada_produt.nep_sequencia_n" "Seq" ? "integer" ? ? ? ? ? ? no ? no no "3.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > custom.int_ds_nota_entrada_produt.alternativo_fornecedor
"int_ds_nota_entrada_produt.alternativo_fornecedor" "Item Fornecedor" ? "character" ? ? ? ? ? ? no ? no no "14" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > custom.int_ds_nota_entrada_produt.nep_produto_n
"int_ds_nota_entrada_produt.nep_produto_n" ? ? "character" ? ? ? ? ? ? no ? no no "7.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"fnItem(int_ds_nota_entrada_produt.nep_produto_n) @ c-desc-item" "Descri‡Æo" "X(65)" ? ? ? ? ? ? ? no ? no no "16.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   = custom.int_ds_nota_entrada_produt.nep_ncm_n
     _FldNameList[6]   = custom.int_ds_nota_entrada_produt.nen_cfop_n
     _FldNameList[7]   > custom.int_ds_nota_entrada_produt.nep_cstb_icm_n
"int_ds_nota_entrada_produt.nep_cstb_icm_n" "CST ICMS" ? "integer" ? ? ? ? ? ? no ? no no "7.72" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > custom.int_ds_nota_entrada_produt.nep_quantidade_n
"int_ds_nota_entrada_produt.nep_quantidade_n" "Qtde" "->>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "6.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > custom.int_ds_nota_entrada_produt.nep_valorbruto_n
"int_ds_nota_entrada_produt.nep_valorbruto_n" ? "->,>>>,>>9.99999" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > custom.int_ds_nota_entrada_produt.nep_valordesconto_n
"int_ds_nota_entrada_produt.nep_valordesconto_n" ? "->,>>>,>>9.99999" "decimal" ? ? ? ? ? ? no ? no no "9.72" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > custom.int_ds_nota_entrada_produt.nep_valorliquido_n
"int_ds_nota_entrada_produt.nep_valorliquido_n" ? "->,>>>,>>9.99999" "decimal" ? ? ? ? ? ? no ? no no "11" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > custom.int_ds_nota_entrada_produt.nep_valoripi_n
"int_ds_nota_entrada_produt.nep_valoripi_n" ? "->,>>>,>>9.99999" "decimal" ? ? ? ? ? ? no ? no no "5.14" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   > custom.int_ds_nota_entrada_produt.nep_baseicms_n
"int_ds_nota_entrada_produt.nep_baseicms_n" ? "->,>>>,>>9.99999" "decimal" ? ? ? ? ? ? no ? no no "8.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[14]   > custom.int_ds_nota_entrada_produt.nep_valoricms_n
"int_ds_nota_entrada_produt.nep_valoricms_n" ? "->,>>>,>>9.99999" "decimal" ? ? ? ? ? ? no ? no no "7.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[15]   > custom.int_ds_nota_entrada_produt.nep_basest_n
"int_ds_nota_entrada_produt.nep_basest_n" ? "->,>>>,>>9.99999" "decimal" ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[16]   > custom.int_ds_nota_entrada_produt.nep_icmsst_n
"int_ds_nota_entrada_produt.nep_icmsst_n" ? "->,>>>,>>9.99999" "decimal" ? ? ? ? ? ? no ? no no "6.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[17]   > custom.int_ds_nota_entrada_produt.nep_valorpis_n
"int_ds_nota_entrada_produt.nep_valorpis_n" ? "->,>>>,>>9.99999" "decimal" ? ? ? ? ? ? no ? no no "8.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[18]   > custom.int_ds_nota_entrada_produt.nep_valorcofins_n
"int_ds_nota_entrada_produt.nep_valorcofins_n" "Vlr Cofins" "->,>>>,>>9.99999" "decimal" ? ? ? ? ? ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON MOUSE-SELECT-DBLCLICK OF br-table IN FRAME F-Main
DO:
    RUN New-State("DblClick, SELF":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-ENTRY OF br-table IN FRAME F-Main
DO:
  /* This code displays initial values for newly added or copied rows. */
  {src/adm/template/brsentry.i}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-LEAVE OF br-table IN FRAME F-Main
DO:
    /* Do not disable this code or no updates will take place except
     by pressing the Save button on an Update SmartPanel. */
   {src/adm/template/brsleave.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON VALUE-CHANGED OF br-table IN FRAME F-Main
DO:
  /* This ADM trigger code must be preserved in order to notify other
     objects when the browser's current row changes. */
  {src/adm/template/brschnge.i}
  /* run new-state('New-Line|':U + string(rowid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}))). */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-modificar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-modificar B-table-Win
ON CHOOSE OF bt-modificar IN FRAME F-Main /* Modificar */
DO:
  RUN pi-Incmod ('modificar':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK B-table-Win 


/* ***************************  Main Block  *************************** */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available B-table-Win  _ADM-ROW-AVAILABLE
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

  /* Create a list of all the tables that we need to get.            */
  {src/adm/template/row-list.i "int_ds_nota_entrada"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_nota_entrada"}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI B-table-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-view B-table-Win 
PROCEDURE local-view :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'view':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  apply 'value-changed':U to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_refresh B-table-Win 
PROCEDURE pi_refresh :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    def var i-ind as integer no-undo.
    if br-table:num-entries in frame {&frame-name} > 0 then
    do i-ind = 1 to browse br-table:NUM-ENTRIES:
        browse br-table:SELECT-ROW(i-ind).
        browse br-table:FETCH-SELECTED-ROW(1).
        if avail int_ds_nota_entrada_produt then do:
            assign 
            int_ds_nota_entrada_produt.nen_cfop_n           :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nen_cfop_n)
            int_ds_nota_entrada_produt.nep_cstb_icm_n       :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_cstb_icm_n)
            int_ds_nota_entrada_produt.nep_valorliquido_n   :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_valorliquido_n  )
            int_ds_nota_entrada_produt.nep_valorbruto_n     :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_valorbruto_n    )
            int_ds_nota_entrada_produt.nep_valordesconto_n  :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_valordesconto_n ) 
            int_ds_nota_entrada_produt.nep_baseicms_n       :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_baseicms_n      ) 
            int_ds_nota_entrada_produt.nep_valoricms_n      :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_valoricms_n     ) 
            int_ds_nota_entrada_produt.nep_valoripi_n       :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_valoripi_n      ) 
            int_ds_nota_entrada_produt.nep_icmsst_n         :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_icmsst_n        ) 
            int_ds_nota_entrada_produt.nep_basest_n         :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_basest_n        ) 
            int_ds_nota_entrada_produt.nep_valorpis_n       :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_valorpis_n      ) 
            int_ds_nota_entrada_produt.nep_valorcofins_n    :screen-value in browse br-table = string(int_ds_nota_entrada_produt.nep_valorcofins_n   ) .
            apply "row-display":u to br-table.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records B-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "int_ds_nota_entrada"}
  {src/adm/template/snd-list.i "int_ds_nota_entrada_produt"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed B-table-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/bstates.i}
  END CASE.
  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnItem B-table-Win 
FUNCTION fnItem RETURNS CHARACTER
  ( p-it-codigo as integer ) :
    for first item fields (desc-item)
        no-lock where item.it-codigo = trim(string(p-it-codigo)):
        return item.desc-item.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

