&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           PROGRESS
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
{include/i-prgvrs.i int512-browser-itens 1.12.00.AVB}

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

/*:T v†ri†veis de uso globla */
def  var v-row-parent    as rowid no-undo.

/*:T vari†veis de uso local */
def var v-row-table  as rowid no-undo.

/*:T fim das variaveis utilizadas no estilo */

def var i-sit-re as integer no-undo.

def var de-vl-unit-nf as decimal no-undo.
def var de-vl-unit-for-ped as decimal no-undo.
def var de-vl-unit-ped as decimal no-undo.
def var de-qtde-ped as decimal no-undo.
def var de-qtde-rec as decimal no-undo.

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
&Scoped-define EXTERNAL-TABLES int-ds-docto-xml
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-docto-xml


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-docto-xml.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES int-ds-it-docto-xml

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table int-ds-it-docto-xml.sequencia int-ds-it-docto-xml.it-codigo int-ds-it-docto-xml.item-do-forn int-ds-it-docto-xml.xProd int-ds-it-docto-xml.numero-ordem int-ds-it-docto-xml.qCom-forn int-ds-it-docto-xml.uCom-forn int-ds-it-docto-xml.vUnCom /* fnVlrUnitForPed(int-ds-it-docto-xml.numero-ordem, int-ds-it-docto-xml.it-codigo) @ de-vl-unit-for-ped */ int-ds-it-docto-xml.qCom fnQtdePed(int-ds-it-docto-xml.numero-ordem, int-ds-it-docto-xml.it-codigo) @ de-qtde-ped fnQtdeRec(int-ds-it-docto-xml.numero-ordem, int-ds-it-docto-xml.it-codigo) @ de-qtde-rec fnVlrUnitNF() @ de-vl-unit-nf fnVlrUnitPed(int-ds-it-docto-xml.numero-ordem, int-ds-it-docto-xml.it-codigo) @ de-vl-unit-ped int-ds-it-docto-xml.vProd int-ds-it-docto-xml.vDesc int-ds-it-docto-xml.vicms int-ds-it-docto-xml.vicmsdeson int-ds-it-docto-xml.vicmsst int-ds-it-docto-xml.vpis int-ds-it-docto-xml.pcofins int-ds-it-docto-xml.vcofins int-ds-it-docto-xml.vOutro   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table   
&Scoped-define SELF-NAME br-table
&Scoped-define QUERY-STRING-br-table FOR EACH int-ds-it-docto-xml WHERE int-ds-it-docto-xml.cnpj = int-ds-docto-xml.cnpj   AND int-ds-it-docto-xml.serie = int-ds-docto-xml.serie   AND int-ds-it-docto-xml.nNF = int-ds-docto-xml.nNF   AND int-ds-it-docto-xml.tipo-nota = int-ds-docto-xml.tipo-nota NO-LOCK     ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-br-table OPEN QUERY {&SELF-NAME} FOR EACH int-ds-it-docto-xml WHERE int-ds-it-docto-xml.cnpj = int-ds-docto-xml.cnpj   AND int-ds-it-docto-xml.serie = int-ds-docto-xml.serie   AND int-ds-it-docto-xml.nNF = int-ds-docto-xml.nNF   AND int-ds-it-docto-xml.tipo-nota = int-ds-docto-xml.tipo-nota NO-LOCK     ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-br-table int-ds-it-docto-xml
&Scoped-define FIRST-TABLE-IN-QUERY-br-table int-ds-it-docto-xml


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br-table 

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnQtdePed B-table-Win 
FUNCTION fnQtdePed RETURNS decimal
  ( p-numero-ordem as integer,
    p-it-codigo as char) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnQtdeRec B-table-Win 
FUNCTION fnQtdeRec RETURNS decimal
  ( p-numero-ordem as integer,
    p-it-codigo as char) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnVlrUnitForPed B-table-Win 
FUNCTION fnVlrUnitForPed RETURNS decimal
  ( p-numero-ordem as integer,
    p-it-codigo as char) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnVlrUnitNF B-table-Win 
FUNCTION fnVlrUnitNF RETURNS decimal
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnVlrUnitPed B-table-Win 
FUNCTION fnVlrUnitPed RETURNS decimal
  ( p-numero-ordem as integer,
    p-it-codigo as char) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      int-ds-it-docto-xml SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      int-ds-it-docto-xml.sequencia FORMAT ">>>,>>9":U WIDTH 3.29
      int-ds-it-docto-xml.it-codigo FORMAT "x(16)":U WIDTH 7
      int-ds-it-docto-xml.item-do-forn FORMAT "x(60)":U WIDTH 10
      int-ds-it-docto-xml.xProd FORMAT "x(60)":U WIDTH 32
      int-ds-it-docto-xml.numero-ordem FORMAT "zzzzzzz999":U
      int-ds-it-docto-xml.qCom-forn COLUMN-LABEL "Qtd NF!Forn" FORMAT ">>,>>>,>>9.99":U WIDTH 6.29
      int-ds-it-docto-xml.uCom-forn FORMAT "x(03)":U WIDTH 2.57
      int-ds-it-docto-xml.vUnCom column-label "Vlr Un NF!Forn" FORMAT ">>,>>>,>>9.99999":U WIDTH 7.43
      /* fnVlrUnitForPed(int-ds-it-docto-xml.numero-ordem, int-ds-it-docto-xml.it-codigo) @ de-vl-unit-for-ped column-label "Vlr!Ped Forn" FORMAT ">>,>>>,>>9.99999":U WIDTH 7.43 */
      int-ds-it-docto-xml.qCom COLUMN-LABEL "Qtd NF" FORMAT ">>>>,>>>,>>9.99":U WIDTH 7
      fnQtdePed(int-ds-it-docto-xml.numero-ordem, int-ds-it-docto-xml.it-codigo) @ de-qtde-ped COLUMN-LABEL "Qtd Ped" FORMAT ">>,>>>,>>9.99":U WIDTH 6.29
      fnQtdeRec(int-ds-it-docto-xml.numero-ordem, int-ds-it-docto-xml.it-codigo) @ de-qtde-rec COLUMN-LABEL "Qtd Rec!Acumulada" FORMAT ">>,>>>,>>9.99":U WIDTH 7
      fnVlrUnitNF() @ de-vl-unit-nf column-label "Vlr Un NF" FORMAT ">>,>>>,>>9.99999":U WIDTH 7.43
      fnVlrUnitPed(int-ds-it-docto-xml.numero-ordem, int-ds-it-docto-xml.it-codigo) @ de-vl-unit-ped column-label "Vlr Ped" FORMAT ">>,>>>,>>9.99999":U WIDTH 7.43
      int-ds-it-docto-xml.vProd FORMAT ">>>>,>>>,>>9.99999":U WIDTH 11.5
      int-ds-it-docto-xml.vDesc FORMAT ">>>>,>>>,>>9.99999":U WIDTH 8.86
      int-ds-it-docto-xml.vicms COLUMN-LABEL "Vlr ICMS" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 7.43
      int-ds-it-docto-xml.vicmsdeson COLUMN-LABEL "Vlr!ICMS Deson" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 10.72
      int-ds-it-docto-xml.vicmsst COLUMN-LABEL "Vlr ST" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 7.43
      int-ds-it-docto-xml.vpis COLUMN-LABEL "Vlr PIS" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 8.57
      int-ds-it-docto-xml.pcofins COLUMN-LABEL "% Cofins" FORMAT ">>9.99":U
            WIDTH 6.43
      int-ds-it-docto-xml.vcofins COLUMN-LABEL "Vlr Cofins" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 9
      int-ds-it-docto-xml.vOutro FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 11
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 142.57 BY 11
         FONT 1 ROW-HEIGHT-CHARS .5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     br-table AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: BrowserCadastro2
   External Tables: emsesp.int-ds-docto-xml
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
         HEIGHT             = 11.08
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
       br-table:NUM-LOCKED-COLUMNS IN FRAME F-Main     = 4
       br-table:COLUMN-RESIZABLE IN FRAME F-Main       = TRUE
       br-table:COLUMN-MOVABLE IN FRAME F-Main         = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH int-ds-it-docto-xml WHERE int-ds-it-docto-xml.cnpj = int-ds-docto-xml.cnpj
  AND int-ds-it-docto-xml.serie = int-ds-docto-xml.serie
  AND int-ds-it-docto-xml.nNF = int-ds-docto-xml.nNF
  AND int-ds-it-docto-xml.tipo-nota = int-ds-docto-xml.tipo-nota NO-LOCK
    ~{&SORTBY-PHRASE}.
     _END_FREEFORM
     _Options          = "NO-LOCK KEY-PHRASE SORTBY-PHRASE"
     _JoinCode[1]      = "emsesp.int-ds-it-docto-xml.cnpj = emsesp.int-ds-docto-xml.cnpj
  AND emsesp.int-ds-it-docto-xml.serie = emsesp.int-ds-docto-xml.serie
  AND emsesp.int-ds-it-docto-xml.nNF = emsesp.int-ds-docto-xml.nNF
  AND emsesp.int-ds-it-docto-xml.tipo-nota = emsesp.int-ds-docto-xml.tipo-nota"
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
ON ROW-DISPLAY OF br-table IN FRAME F-Main
DO:

    RUN pi-valores-ordem-compra (int-ds-it-docto-xml.numero-ordem,
                                 int-ds-it-docto-xml.it-codigo).
  
    if int-ds-it-docto-xml.numero-ordem = 0 then
        int-ds-it-docto-xml.numero-ordem:bgcolor in browse br-table = 14.
    else do:
        int-ds-it-docto-xml.numero-ordem:bgcolor in browse br-table = ?.
        
        /*
        if int-ds-it-docto-xml.vUnCom > (de-vl-unit-for-ped * 1.02) 
        then do:
            assign  int-ds-it-docto-xml.vUnCom :bgcolor in browse br-table = 14
                    de-vl-unit-for-ped:bgcolor in browse br-table = 14.
        end.
        else do:
            assign  int-ds-it-docto-xml.vUnCom :bgcolor in browse br-table = ?
                    de-vl-unit-for-ped:bgcolor in browse br-table = ?.
        end.
        */

        if int-ds-it-docto-xml.qCom > de-qtde-ped 
        then do:
            assign  int-ds-it-docto-xml.qCom :bgcolor in browse br-table = 14
                    de-qtde-ped:bgcolor in browse br-table = 14.
        end.
        else do:
            assign  int-ds-it-docto-xml.qCom :bgcolor in browse br-table = ?
                    de-qtde-ped:bgcolor in browse br-table = ?.
        end.

        if de-vl-unit-nf > de-vl-unit-ped * 1.02
        then do:
            assign  de-vl-unit-nf   :bgcolor in browse br-table = 14
                    de-vl-unit-ped  :bgcolor in browse br-table = 14.
        end.
        else do:
            assign  de-vl-unit-nf   :bgcolor in browse br-table = ?
                    de-vl-unit-ped  :bgcolor in browse br-table = ?.
        end.
        if ordem-compra.qt-solic < de-qtde-rec then
            assign  int-ds-it-docto-xml.qCom :bgcolor in browse br-table = 14
                    de-qtde-rec:bgcolor in browse br-table = 14.
        else        
            assign  de-qtde-rec:bgcolor in browse br-table = ?.

    end.
    
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
  {src/adm/template/row-list.i "int-ds-docto-xml"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int-ds-docto-xml"}

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-row-available B-table-Win 
PROCEDURE local-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'row-available':U ) .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-busca-docto-wms B-table-Win 
PROCEDURE pi-busca-docto-wms :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

      i-sit-re = 0.
      for first int-ds-docto-wms fields (situacao datamovimentacao_d) no-lock where 
          int-ds-docto-wms.doc_numero_n = int(int-ds-docto-xml.nNF) and
          int-ds-docto-wms.doc_serie_s  = int-ds-docto-xml.serie and
          int-ds-docto-wms.cnpj_cpf     = int-ds-docto-xml.CNPJ: 
          assign i-sit-re = int-ds-docto-wms.situacao.
      end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-valida-situacao B-table-Win 
PROCEDURE pi-valida-situacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    RUN pi-busca-docto-wms. 
    /*
    if (i-sit-re >= 25 /* conferida wms */ and
        i-sit-re <> 60 /* cancelada wms */)
    then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Modificaá‰es bloqueadas!" + "~~" + "A nota fiscal j† foi conferida no WMS. Alteraá‰es n∆o ser∆o permitidas.")).
        return "ADM-ERROR":U.
    end.
    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-valida-usuario B-table-Win 
PROCEDURE pi-valida-usuario :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    if can-find (first usuar_grp_usuar no-lock where 
                 usuar_grp_usuar.cod_grp_usuar = "ZZZ") then return "OK":U.


    /* compras n∆o pode alterar documento */
    if can-find (first usuar_grp_usuar no-lock where 
                 usuar_grp_usuar.cod_usuario = c-seg-usuario and
                 usuar_grp_usuar.cod_grp_usuar = "X23")
    then do:
        return "ADM-ERROR":U.
    end.  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-valores-ordem-compra B-table-Win 
PROCEDURE pi-valores-ordem-compra :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define input parameter p-numero-ordem as integer no-undo.
define input parameter p-it-codigo as char no-undo.

    de-vl-unit-nf = (int-ds-it-docto-xml.vProd / int-ds-it-docto-xml.qCom) .
    de-qtde-ped = 0.
    de-qtde-rec = 0.
    de-vl-unit-for-ped = 0.
    de-vl-unit-ped = 0.
    for first ordem-compra 
        no-lock where 
        ordem-compra.numero-ordem = p-numero-ordem and
        ordem-compra.it-codigo = p-it-codigo:
        de-qtde-ped = ordem-compra.qt-solic.
        de-vl-unit-for-ped = ordem-compra.pre-unit-for.
        de-vl-unit-ped = ordem-compra.preco-unit.
        de-qtde-rec = ordem-compra.qt-acum-rec 
                    + int-ds-it-docto-xml.qCom
                    - ordem-compra.qt-acum-dev. 
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
  {src/adm/template/snd-list.i "int-ds-docto-xml"}
  {src/adm/template/snd-list.i "int-ds-it-docto-xml"}

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnQtdePed B-table-Win 
FUNCTION fnQtdePed RETURNS decimal
  ( p-numero-ordem as integer,
    p-it-codigo as char):

    de-qtde-ped = 0.
    for first ordem-compra 
        no-lock where 
        ordem-compra.numero-ordem = p-numero-ordem and
        ordem-compra.it-codigo = p-it-codigo:
        de-qtde-ped = ordem-compra.qt-solic.
        return ordem-compra.qt-solic.
    end.

  RETURN 0.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnQtdeRec B-table-Win 
FUNCTION fnQtdeRec RETURNS decimal
  ( p-numero-ordem as integer,
    p-it-codigo as char):

    for first ordem-compra 
        no-lock where 
        ordem-compra.numero-ordem = p-numero-ordem and
        ordem-compra.it-codigo = p-it-codigo:
        return ordem-compra.qt-acum-rec + int-ds-it-docto-xml.qCom - ordem-compra.qt-acum-dev.
    end.

  RETURN 0.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnVlrUnitForPed B-table-Win 
FUNCTION fnVlrUnitForPed RETURNS decimal
  ( p-numero-ordem as integer,
    p-it-codigo as char):

    assign de-vl-unit-for-ped = 0.
    for first ordem-compra 
        no-lock where 
        ordem-compra.numero-ordem = p-numero-ordem and
        ordem-compra.it-codigo = p-it-codigo:

        assign de-vl-unit-for-ped = ordem-compra.pre-unit-for.
        return ordem-compra.pre-unit-for.
        
    end.

  RETURN 0.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnVlrUnitNF B-table-Win 
FUNCTION fnVlrUnitNF RETURNS decimal
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    de-vl-unit-nf = (int-ds-it-docto-xml.vProd / int-ds-it-docto-xml.qCom) .
    RETURN (int-ds-it-docto-xml.vProd / int-ds-it-docto-xml.qCom) .


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnVlrUnitPed B-table-Win 
FUNCTION fnVlrUnitPed RETURNS decimal
  ( p-numero-ordem as integer,
    p-it-codigo as char):

    de-vl-unit-ped = 0.
    for first ordem-compra 
        no-lock where 
        ordem-compra.numero-ordem = p-numero-ordem and
        ordem-compra.it-codigo = p-it-codigo:
        de-vl-unit-ped = ordem-compra.preco-unit.
        return ordem-compra.preco-unit.
        
    end.

  RETURN 0.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

