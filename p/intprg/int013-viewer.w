&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int013-viewer 2.12.01.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/viewerd.w

/* global variable definitions */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var v-row-parent as rowid no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-main

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int_ds_cfop_natur_oper
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_cfop_natur_oper


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_cfop_natur_oper.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_cfop_natur_oper.nat_operacao 
&Scoped-define ENABLED-TABLES int_ds_cfop_natur_oper
&Scoped-define FIRST-ENABLED-TABLE int_ds_cfop_natur_oper
&Scoped-Define ENABLED-OBJECTS rt-key rt-mold 
&Scoped-Define DISPLAYED-FIELDS int_ds_cfop_natur_oper.nen_cfop_n ~
int_ds_cfop_natur_oper.nep_cstb_icm_n int_ds_cfop_natur_oper.cod_estabel ~
int_ds_cfop_natur_oper.cod_emitente int_ds_cfop_natur_oper.ncm ~
int_ds_cfop_natur_oper.dt_inicio_validade ~
int_ds_cfop_natur_oper.nat_operacao int_ds_cfop_natur_oper.nep_cstb_ipi_n 
&Scoped-define DISPLAYED-TABLES int_ds_cfop_natur_oper
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_cfop_natur_oper
&Scoped-Define DISPLAYED-OBJECTS c-fm-codigo c-cfop c-nome c-nome-emit ~
c-denominacao c-Familia 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS int_ds_cfop_natur_oper.nen_cfop_n ~
int_ds_cfop_natur_oper.nep_cstb_icm_n int_ds_cfop_natur_oper.cod_estabel ~
int_ds_cfop_natur_oper.cod_emitente int_ds_cfop_natur_oper.ncm ~
int_ds_cfop_natur_oper.dt_inicio_validade 
&Scoped-define ADM-ASSIGN-FIELDS int_ds_cfop_natur_oper.nep_cstb_ipi_n 
&Scoped-define ADM-MODIFY-FIELDS int_ds_cfop_natur_oper.nat_operacao ~
int_ds_cfop_natur_oper.nep_cstb_ipi_n 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS> 
<EXECUTING-CODE>
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


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE cb-trib-icms AS CHARACTER FORMAT "X(30)":U 
     LABEL "Tributaá∆o ICMS" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "0" 
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE cb-trib-ipi AS CHARACTER FORMAT "X(256)":U 
     LABEL "Tributaá∆o IPI" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "0" 
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE cd-trib-cofins AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
     LABEL "Tributaá∆o COFINS" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "0" 
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE cd-trib-pis AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
     LABEL "Tributaá∆o PIS" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "0" 
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE c-cfop AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 56 BY .88 NO-UNDO.

DEFINE VARIABLE c-cod-cfop AS CHARACTER FORMAT "x(10)" 
     LABEL "CFOP":R5 
     VIEW-AS FILL-IN 
     SIZE 5.57 BY .88.

DEFINE VARIABLE c-denominacao AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 56 BY .88 NO-UNDO.

DEFINE VARIABLE c-Familia AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 45 BY .88 NO-UNDO.

DEFINE VARIABLE c-fm-codigo AS CHARACTER FORMAT "X(8)":U 
     LABEL "Fam°lia" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE c-nome AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 56 BY .88 NO-UNDO.

DEFINE VARIABLE c-nome-emit AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 56 BY .88 NO-UNDO.

DEFINE RECTANGLE rt-key
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 7.5.

DEFINE RECTANGLE rt-mold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 5.58.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int_ds_cfop_natur_oper.nen_cfop_n AT ROW 1.17 COL 15.57 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 7 BY .88
     int_ds_cfop_natur_oper.nep_cstb_icm_n AT ROW 2.17 COL 15.57 COLON-ALIGNED HELP
          "C¢digo da situaá∆o tribut†ria p/ ICMS" WIDGET-ID 12
          VIEW-AS FILL-IN 
          SIZE 3.29 BY .88
     int_ds_cfop_natur_oper.cod_estabel AT ROW 3.17 COL 15.57 COLON-ALIGNED HELP
          "C¢digo do estabelecimento (Utilize ? para TODOS)" WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 12.29 BY .88
     int_ds_cfop_natur_oper.cod_emitente AT ROW 4.17 COL 15.57 COLON-ALIGNED HELP
          "C¢digo do fornecedor (Utilize ? para TODOS)" WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 12.29 BY .88
     int_ds_cfop_natur_oper.ncm AT ROW 5.17 COL 15.57 COLON-ALIGNED WIDGET-ID 54
          VIEW-AS FILL-IN 
          SIZE 14 BY .88
     c-fm-codigo AT ROW 6.21 COL 15.57 COLON-ALIGNED WIDGET-ID 48
     int_ds_cfop_natur_oper.dt_inicio_validade AT ROW 7.25 COL 15.57 COLON-ALIGNED WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 11.29 BY .88
     int_ds_cfop_natur_oper.nat_operacao AT ROW 9.17 COL 15.57 COLON-ALIGNED WIDGET-ID 8
          VIEW-AS FILL-IN 
          SIZE 10.57 BY .88
     c-cod-cfop AT ROW 10.17 COL 15.57 COLON-ALIGNED HELP
          "C¢digo Fiscal de Operaá‰es e Prestaá‰es a partir de 01/01/2003." WIDGET-ID 32
     cb-trib-icms AT ROW 11.25 COL 15.57 COLON-ALIGNED WIDGET-ID 38
     cd-trib-pis AT ROW 12.58 COL 15.57 COLON-ALIGNED WIDGET-ID 42
     c-cfop AT ROW 1.17 COL 22.72 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     c-nome AT ROW 3.17 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     c-nome-emit AT ROW 4.17 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     c-denominacao AT ROW 9.17 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     c-Familia AT ROW 6.21 COL 29.57 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     cb-trib-ipi AT ROW 11.25 COL 57 COLON-ALIGNED WIDGET-ID 36
     cd-trib-cofins AT ROW 12.58 COL 57 COLON-ALIGNED WIDGET-ID 40
     int_ds_cfop_natur_oper.nep_cstb_ipi_n AT ROW 6.21 COL 74.57 COLON-ALIGNED NO-LABEL WIDGET-ID 52 FORMAT ">>>>>>>9"
          VIEW-AS FILL-IN 
          SIZE 9.14 BY .88
     rt-key AT ROW 1 COL 1
     rt-mold AT ROW 8.58 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: custom.int_ds_cfop_natur_oper
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY COMPILE
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 15.42
         WIDTH              = 88.57.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}
{include/c-viewer.i}
{utp/ut-glob.i}
{include/i_dbtype.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-main
   NOT-VISIBLE FRAME-NAME Size-to-Fit L-To-R,COLUMNS                    */
ASSIGN 
       FRAME f-main:SCROLLABLE       = FALSE
       FRAME f-main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN c-cfop IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-cod-cfop IN FRAME f-main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN c-denominacao IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-Familia IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-fm-codigo IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-nome IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-nome-emit IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX cb-trib-icms IN FRAME f-main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR COMBO-BOX cb-trib-ipi IN FRAME f-main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR COMBO-BOX cd-trib-cofins IN FRAME f-main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR COMBO-BOX cd-trib-pis IN FRAME f-main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN int_ds_cfop_natur_oper.cod_emitente IN FRAME f-main
   NO-ENABLE 1 EXP-HELP                                                 */
/* SETTINGS FOR FILL-IN int_ds_cfop_natur_oper.cod_estabel IN FRAME f-main
   NO-ENABLE 1 EXP-HELP                                                 */
/* SETTINGS FOR FILL-IN int_ds_cfop_natur_oper.dt_inicio_validade IN FRAME f-main
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN int_ds_cfop_natur_oper.nat_operacao IN FRAME f-main
   3                                                                    */
/* SETTINGS FOR FILL-IN int_ds_cfop_natur_oper.ncm IN FRAME f-main
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN int_ds_cfop_natur_oper.nen_cfop_n IN FRAME f-main
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN int_ds_cfop_natur_oper.nep_cstb_icm_n IN FRAME f-main
   NO-ENABLE 1 EXP-HELP                                                 */
/* SETTINGS FOR FILL-IN int_ds_cfop_natur_oper.nep_cstb_ipi_n IN FRAME f-main
   NO-ENABLE 2 3 EXP-FORMAT                                             */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-main
/* Query rebuild information for FRAME f-main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME f-main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME c-fm-codigo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-fm-codigo V-table-Win
ON F5 OF c-fm-codigo IN FRAME f-main /* Fam°lia */
or "MOUSE-SELECT-DBLCLICK":U of c-fm-codigo
DO:
    {include/zoomvar.i &prog-zoom="inzoom/z01in122.w"
                       &campo=c-fm-codigo
                       &campozoom=fm-codigo}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-fm-codigo V-table-Win
ON LEAVE OF c-fm-codigo IN FRAME f-main /* Fam°lia */
DO:
    c-nome:screen-value in frame {&frame-name} = "".
    {include/leave.i &tabela=familia 
                   &atributo-ref=descricao
                   &variavel-ref=c-familia
                   &where="familia.fm-codigo = c-fm-codigo:screen-value in frame {&frame-name}"}
    assign int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value IN FRAME {&FRAME-NAME} = c-fm-codigo:screen-value in FRAME {&FRAME-NAME}.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_cfop_natur_oper.cod_emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_cfop_natur_oper.cod_emitente V-table-Win
ON F5 OF int_ds_cfop_natur_oper.cod_emitente IN FRAME f-main /* Fornecedor */
or "MOUSE-SELECT-DBLCLICK":U of int_ds_cfop_natur_oper.cod_emitente
DO:
    {include/zoomvar.i &prog-zoom="adzoom/z01ad098.w"
                       &campo=int_ds_cfop_natur_oper.cod_emitente
                       &campozoom=cod-emitente}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_cfop_natur_oper.cod_emitente V-table-Win
ON LEAVE OF int_ds_cfop_natur_oper.cod_emitente IN FRAME f-main /* Fornecedor */
DO:
    c-nome-emit:screen-value in frame {&frame-name} = "".
    {include/leave.i &tabela=emitente 
                 &atributo-ref=nome-emit
                 &variavel-ref=c-nome-emit
                 &where="emitente.cod-emitente = input frame {&frame-name} int_ds_cfop_natur_oper.cod_emitente"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_cfop_natur_oper.cod_estabel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_cfop_natur_oper.cod_estabel V-table-Win
ON F5 OF int_ds_cfop_natur_oper.cod_estabel IN FRAME f-main /* Estabelecimento */
or "MOUSE-SELECT-DBLCLICK":U of int_ds_cfop_natur_oper.cod_estabel
DO:
    {include/zoomvar.i &prog-zoom="adzoom/z01ad107.w"
                       &campo=int_ds_cfop_natur_oper.cod_estabel
                       &campozoom=cod-estabel}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_cfop_natur_oper.cod_estabel V-table-Win
ON LEAVE OF int_ds_cfop_natur_oper.cod_estabel IN FRAME f-main /* Estabelecimento */
DO:
    c-nome:screen-value in frame {&frame-name} = "".
    {include/leave.i &tabela=estabelec 
                   &atributo-ref=nome
                   &variavel-ref=c-nome
                   &where="estabelec.cod-estabel = input frame {&frame-name} int_ds_cfop_natur_oper.cod_estabel"}
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_cfop_natur_oper.nat_operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_cfop_natur_oper.nat_operacao V-table-Win
ON F5 OF int_ds_cfop_natur_oper.nat_operacao IN FRAME f-main /* Nat Operaá∆o */
or "MOUSE-SELECT-DBLCLICK":U of int_ds_cfop_natur_oper.nat_operacao
DO:
    {include/zoomvar.i &prog-zoom="inzoom/z01in245.w"
                       &campo=int_ds_cfop_natur_oper.nat_operacao
                       &campozoom=nat-operacao}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_cfop_natur_oper.nat_operacao V-table-Win
ON LEAVE OF int_ds_cfop_natur_oper.nat_operacao IN FRAME f-main /* Nat Operaá∆o */
DO:
    def var i-aux1 as integer no-undo.
    def var i-aux2 as integer no-undo.

    assign c-nome-emit = ""
           c-nome = ""
           c-denominacao = ""
    cb-trib-ipi:screen-value     in frame f-main = "".
    cb-trib-icms:screen-value    in frame f-main = "".
    cd-trib-pis:screen-value        in frame f-main = "".
    cd-trib-cofins:screen-value     in frame f-main = "".
    c-cod-cfop:screen-value     in frame f-main = "".
    c-denominacao:screen-value     in frame f-main = "".
    for first natur-oper 
        fields (char-1 cod-cfop cd-trib-ipi cd-trib-icm denominacao)
        no-lock where
        natur-oper.nat-operacao = int_ds_cfop_natur_oper.nat_operacao:screen-value in frame f-main:

        assign i-aux1                                          = int(substr(natur-oper.char-1,86,1))
               i-aux2                                          = int(substr(natur-oper.char-1,87,1))
               i-aux1                                          = if i-aux1 = 0 then 1 else i-aux1
               i-aux2                                          = if i-aux2 = 0 then 1 else i-aux2

        cb-trib-ipi:screen-value     in frame f-main = {ininc/i10in172.i 04 natur-oper.cd-trib-ipi}.
        cb-trib-icms:screen-value    in frame f-main = {ininc/i01in245.i 04 natur-oper.cd-trib-icm}.
        cd-trib-pis:screen-value        in frame f-main = {ininc/i11in172.i 04 i-aux1}.
        cd-trib-cofins:screen-value     in frame f-main = {ininc/i11in172.i 04 i-aux2}.
        c-cod-cfop:screen-value     in frame f-main = natur-oper.cod-cfop.
        c-denominacao:screen-value     in frame f-main = natur-oper.denominacao.
    end.

  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_cfop_natur_oper.nen_cfop_n
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_cfop_natur_oper.nen_cfop_n V-table-Win
ON F5 OF int_ds_cfop_natur_oper.nen_cfop_n IN FRAME f-main /* CFOP */
or "MOUSE-SELECT-DBLCLICK":U of int_ds_cfop_natur_oper.nen_cfop_n
DO:
    def var hProgramZoom as handle.
    {method/ZoomFields.i &ProgramZoom="cdp/cd0620-Z01.w"                 /* programa zoom da tabela do banco de dados */
                         &FieldZoom1="cod-cfop"                       /* campo chave da tabela a buscar - recebera leave */
                         &FieldScreen1="int_ds_cfop_natur_oper.nen_cfop_n"  /* aonde sera aplicado o leave da chave */
                         &Frame1="{&FRAME-NAME}"                            /* frame aonde estao os campos chave e descricao */
                         &FieldZoom2="des-cfop"               /* campo a ser retornado pelo zoom */    
                         &FieldScreen2="c-cfop"       /* campo em tela que recebera o retorno */
                         &Frame2="{&FRAME-NAME}"                            /* frame aonde estao os campos chave e descricao */
                         &EnableImplant="NO"}                           /* nao permitir implantacao */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_cfop_natur_oper.nen_cfop_n V-table-Win
ON LEAVE OF int_ds_cfop_natur_oper.nen_cfop_n IN FRAME f-main /* CFOP */
DO:
    c-cfop:screen-value in frame {&frame-name} = "".
    {include/leave.i &tabela=cfop-natur
                   &atributo-ref=des-cfop
                   &variavel-ref=c-cfop
                   &where="cfop-natur.cod-cfop = input frame {&frame-name} int_ds_cfop_natur_oper.nen_cfop_n"}.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */


  cb-trib-ipi:list-items        in frame f-main = {ininc/i10in172.i 03}.
  cb-trib-icms:list-items       in frame f-main = {ininc/i01in245.i 03}.
  cd-trib-pis:list-items        in frame f-main = {ininc/i11in172.i 03}.
  cd-trib-cofins:list-items     in frame f-main = {ininc/i11in172.i 03}.


  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
  &ENDIF         
  
  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
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
  {src/adm/template/row-list.i "int_ds_cfop_natur_oper"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_cfop_natur_oper"}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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
  HIDE FRAME f-main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record V-table-Win 
PROCEDURE local-assign-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

    /* Code placed here will execute PRIOR to standard behavior. */
    if  not frame {&frame-name}:validate() then
        return 'ADM-ERROR':U.
        
    /*:T Ponha na pi-validate todas as validaá‰es */
    /*:T N∆o gravar nada no registro antes do dispatch do assign-record e 
       nem na PI-validate. */
    RUN pi-validate.    
    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.

    assign int_ds_cfop_natur_oper.nep_cstb_ipi_n:SCREEN-VALUE = c-fm-codigo:screen-value in FRAME {&FRAME-NAME}.

    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .
    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.
    
    /*:T Todos os assignÔs n∆o feitos pelo assign-record devem ser feitos aqui */  
    /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-disable-fields V-table-Win 
PROCEDURE local-disable-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
    
    /* Code placed here will execute PRIOR to standard behavior. */
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'disable-fields':U ) .
    ASSIGN c-fm-codigo:sensitive in FRAME f-main = no.
    
    /* Code placed here will execute AFTER standard behavior.    */
    &if  defined(ADM-MODIFY-FIELDS) &then
    disable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
    &endif
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-enable-fields V-table-Win 
PROCEDURE local-enable-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
    
    /* Code placed here will execute PRIOR to standard behavior. */
    int_ds_cfop_natur_oper.cod_emitente:LOAD-MOUSE-POINTER("image/lupa.cur":U) in FRAME f-main.
    int_ds_cfop_natur_oper.cod_estabel :LOAD-MOUSE-POINTER("image/lupa.cur":U) in FRAME f-main.
    int_ds_cfop_natur_oper.nat_operacao:LOAD-MOUSE-POINTER("image/lupa.cur":U) in FRAME f-main.
    int_ds_cfop_natur_oper.nen_cfop_n:LOAD-MOUSE-POINTER("image/lupa.cur":U) in FRAME f-main.
    c-fm-codigo:LOAD-MOUSE-POINTER("image/lupa.cur":U) in FRAME f-main.

    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'enable-fields':U ) .

    if adm-new-record = yes then do:
        ASSIGN c-fm-codigo:sensitive in FRAME f-main = yes.
    end.
    else do:
        ASSIGN c-fm-codigo:sensitive in FRAME f-main = no.
    end.
    /* Code placed here will execute AFTER standard behavior.    */
    &if  defined(ADM-MODIFY-FIELDS) &then
    if adm-new-record = yes then do:
        enable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
    end.
    &endif
    int_ds_cfop_natur_oper.nep_cstb_ipi_n:sensitive in FRAME f-main = no.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-row-available V-table-Win 
PROCEDURE local-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'row-available':U ) .

  apply "LEAVE":U to int_ds_cfop_natur_oper.cod_emitente in frame f-main.
  apply "LEAVE":U to int_ds_cfop_natur_oper.cod_estabel in frame f-main.
  apply "LEAVE":U to int_ds_cfop_natur_oper.nat_operacao in frame f-main.
  apply "LEAVE":U to int_ds_cfop_natur_oper.nen_cfop_n in frame f-main.
      
  /* Code placed here will execute AFTER standard behavior.    */
  if avail int_ds_cfop_natur_oper then
      assign c-fm-codigo:screen-value in frame {&frame-name} = string(int_ds_cfop_natur_oper.nep_cstb_ipi_n).
  apply "LEAVE":U to c-fm-codigo in frame f-main.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualiza-parent V-table-Win 
PROCEDURE pi-atualiza-parent :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter v-row-parent-externo as rowid no-undo.
    
    assign v-row-parent = v-row-parent-externo.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Pi-validate V-table-Win 
PROCEDURE Pi-validate :
/*:T------------------------------------------------------------------------------
  Purpose:Validar a viewer     
  Parameters:  <none>
  Notes: N∆o fazer assign aqui. Nesta procedure
  devem ser colocadas apenas validaá‰es, pois neste ponto do programa o registro 
  ainda n∆o foi criado.       
------------------------------------------------------------------------------*/
    {include/i-vldfrm.i} /*:T Validaá∆o de dicion†rio */
    
    if int_ds_cfop_natur_oper.cod_emitente:input-value in frame f-main <> ? and
       not can-find (first emitente no-lock where 
                     emitente.cod-emitente = int(int_ds_cfop_natur_oper.cod_emitente:input-value in frame f-main)) 
    then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Emitente inv†lido!" + "~~" + "Emitente deve estar cadastrado ou ser ?.")).
        return "ADM-ERROR".
    end.

    if int_ds_cfop_natur_oper.dt_inicio_validade:input-value in frame f-main = ? then do:

        run utp/ut-msgs.p(input "show",
                          input 173,
                          input "").
        return "ADM-ERROR".

    end.

    if c-fm-codigo:input-value in frame f-main <> ? and
       not can-find (first familia no-lock where 
                     familia.fm-codigo = c-fm-codigo:screen-value in frame f-main) 
    then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Fam°lia inv†lida!" + "~~" + "Fam°lia deve estar cadastrada ou ser ?.")).
        return "ADM-ERROR".
    end.

    for first natur-oper no-lock where
        natur-oper.nat-operacao = int_ds_cfop_natur_oper.nat_operacao:screen-value in frame f-main:

        /*
        if natur-oper.cod-cfop <> int_ds_cfop_natur_oper.nen_cfop_n:screen-value in frame f-main then do:

            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Natureza de Operaá∆o Inv†lida!" + "~~" + "CFOP: " +  int_ds_cfop_natur_oper.nen_cfop_n:screen-value + " incompat°vel com cfop cadastrada na natureza de operaá∆o: " + int_ds_cfop_natur_oper.nat_operacao:screen-value)).
            return "ADM-ERROR".
        end.
        */
/*
        if  /* Tributada integralmente */
            (int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value = "00" and
             natur-oper.cd-trib-icm <> 1) or
            /* Tributada e com cobranáa do ICMS por substituiá∆o tribut†ria */
            (int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value = "10" and
             natur-oper.cd-trib-icm <> 1) or
            /* Com reduá∆o de base de c†lculo */
            (int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value = "20" and
             natur-oper.cd-trib-icm <> 4) or
            /* Com reduá∆o de base de c†lculo e cobranáa do ICMS por substituiá∆o tribut†ria */
            (int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value = "70" and
             natur-oper.cd-trib-icm <> 4) or
            /* Isenta */
            (int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value = "40" and
             natur-oper.cd-trib-icm <> 2) or
            /* N∆o tributada */
            (int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value = "41" and
             natur-oper.cd-trib-icm <> 2) or
            /* Isenta ou n∆o tributada e com cobranáa do ICMS por substituiá∆o tribut†ria */
            (int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value = "30" and
             natur-oper.cd-trib-icm <> 2) or
            /*Outras */
            (int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value = "90" and
             natur-oper.cd-trib-icm <> 3) or
            /* Diferimento */
            (int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value = "51" and
             natur-oper.cd-trib-icm <> 5) or
             /* Suspens∆o */
            (natur-oper.ind-it-sub-dif and
             int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value <> "50") or
            /* ICMS cobrado anteriormente por substituiá∆o tribut†ria */
            (natur-oper.ind-it-icms and
             int_ds_cfop_natur_oper.nep_cstb_icm_n:screen-value <> "60")
        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Natureza de Operaá∆o Inv†lida!" + "~~" + "C¢digo de tributaá∆o do ICMS incompat°vel com o CST Informado.")).
            return "ADM-ERROR".
        end.
        /*
        if  /* Entrada com Recuperaá∆o de CrÇdito */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "00" and
             natur-oper.cd-trib-ipi <> 1) or
            /* Entrada Tribut†vel com Al°quota Zero */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "01" and
             natur-oper.cd-trib-ipi <> 4 and natur-oper.cd-trib-ipi <> 3) or
            /* Entrada Isenta */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "02" and
             natur-oper.cd-trib-ipi <> 2) or
            /* Entrada N∆o-Tributada */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "03" and
             natur-oper.cd-trib-ipi <> 2 and natur-oper.cd-trib-ipi <> 3) or
            /* Entrada Imune */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "04" and
             natur-oper.cd-trib-ipi <> 2 and natur-oper.cd-trib-ipi <> 3) or
            /* Entrada com Suspens∆o */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "05" and
             natur-oper.cd-trib-ipi <> 3) or
            /* Outras Entradas */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "49" and
             natur-oper.cd-trib-ipi <> 3) or
            /* Sa°da Tributada */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "50" and
             natur-oper.cd-trib-ipi <> 1) or
            /* Sa°da Tribut†vel com Al°quota Zero */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "51" and
             natur-oper.cd-trib-ipi <> 4 and natur-oper.cd-trib-ipi <> 3) or
            /* Sa°da Isenta */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "52" and
             natur-oper.cd-trib-ipi <> 2) or
            /* Sa°da N∆o-Tributada */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "53" and
             natur-oper.cd-trib-ipi <> 2 and natur-oper.cd-trib-ipi <> 3) or
            /* Sa°da Imune */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "54" and
             natur-oper.cd-trib-ipi <> 2 and natur-oper.cd-trib-ipi <> 3) or
            /* Sa°da com Suspens∆o */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "55" and
             natur-oper.cd-trib-ipi <> 3) or
            /* Outras Sa°das */
            (int_ds_cfop_natur_oper.nep_cstb_ipi_n:screen-value = "99" and
             natur-oper.cd-trib-ipi <> 3)

        then do:
            run utp/ut-msgs.p(input "show",
                              input 17006,
                              input ("Natureza de Operaá∆o Inv†lida!" + "~~" + "C¢digo de tributaá∆o do IPI incompat°vel com o CST Informado.")).
            return "ADM-ERROR".
        end.
        */
        */
    end.
    if not avail natur-oper then do:
        run utp/ut-msgs.p(input "show",
                          input 2,
                          input ("Natureza de Operaá∆o" + "~~" + int_ds_cfop_natur_oper.nat_operacao:screen-value)).
        return "ADM-ERROR".
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "int_ds_cfop_natur_oper"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win 
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
      {src/adm/template/vstates.i}
  END CASE.
  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

