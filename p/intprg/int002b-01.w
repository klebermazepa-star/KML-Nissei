&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wMaintenanceNoNavigation


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int-ds-docto-xml NO-UNDO LIKE int-ds-docto-xml
       fields r-rowid as rowid.
DEFINE TEMP-TABLE tt-int-ds-it-docto-xml NO-UNDO LIKE int-ds-it-docto-xml
       fields r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wMaintenanceNoNavigation 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i int002b-01 2.06.00.001}

CREATE WIDGET-POOL.

/* PrenNFrs Definitions ---                                      */
&GLOBAL-DEFINE Program           int002b-01
&GLOBAL-DEFINE Version           2.06.00.001

&GLOBAL-DEFINE Folder            YES
&GLOBAL-DEFINE InitialPage       1

&GLOBAL-DEFINE FolderLabels      ITEM,Narrativa,Impostos

&GLOBAL-DEFINE ttTable           tt-int-ds-it-docto-xml
&GLOBAL-DEFINE hDBOTable         h-tt-int-ds-it-docto-xml
&GLOBAL-DEFINE DBOTable          dbo-tt-int-ds-it-docto-xml

&GLOBAL-DEFINE ttParent          tt-int-ds-docto-xml
&GLOBAL-DEFINE DBOParentTable    dbo-tt-int-ds-docto-xml

&GLOBAL-DEFINE page0KeyFields    tt-int-ds-it-docto-xml.sequencia c-desc-item c-un c-fam c-desc-fam
&GLOBAL-DEFINE page0Fields       tt-int-ds-it-docto-xml.item-do-forn tt-int-ds-it-docto-xml.it-codigo
&GLOBAL-DEFINE page0ParentFields /* tt-int-ds-it-docto-xml.serie tt-int-ds-it-docto-xml.nnf tt-int-ds-it-docto-xml.cod-emitente tt-int-ds-it-docto-xml.tipo-nota */  
&GLOBAL-DEFINE page1Fields       tt-int-ds-it-docto-xml.num-pedido tt-int-ds-it-docto-xml.numero-ordem tt-int-ds-it-docto-xml.qCom-forn tt-int-ds-it-docto-xml.vUnCom ~
                                 tt-int-ds-it-docto-xml.vProd  tt-int-ds-it-docto-xml.Vdesc tt-int-ds-it-docto-xml.nat-operacao tt-int-ds-it-docto-xml.lote ~
                                 tt-int-ds-it-docto-xml.dval   tt-int-ds-it-docto-xml.dfab     

&GLOBAL-DEFINE page2Fields       tt-int-ds-it-docto-xml.narrativa

&GLOBAL-DEFINE page3Fields       tt-int-ds-it-docto-xml.pcofins tt-int-ds-it-docto-xml.vbc-cofins tt-int-ds-it-docto-xml.vcofins tt-int-ds-it-docto-xml.picms tt-int-ds-it-docto-xml.vbc-icms ~
                                 tt-int-ds-it-docto-xml.vicms tt-int-ds-it-docto-xml.vbc-ipi  tt-int-ds-it-docto-xml.vbc-pis tt-int-ds-it-docto-xml.vicmsst tt-int-ds-it-docto-xml.vbcst ~
                                 tt-int-ds-it-docto-xml.ppis tt-int-ds-it-docto-xml.vpis ~
                                 tt-int-ds-it-docto-xml.vtottrib tt-int-ds-it-docto-xml.pipi  tt-int-ds-it-docto-xml.vipi  

DEFINE INPUT PARAMETER prTable         AS ROWID     NO-UNDO.
DEFINE INPUT PARAMETER prParent        AS ROWID     NO-UNDO.
DEFINE INPUT PARAMETER pcAction        AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER phCaller        AS HANDLE    NO-UNDO.
DEFINE INPUT PARAMETER piSonPageNumber AS INTEGER   NO-UNDO.

DEFINE VARIABLE {&hDBOTable}  AS HANDLE NO-UNDO.

DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.
DEFINE VARIABLE wh-pesquisa AS HANDLE NO-UNDO.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD dt-trans-ini     LIKE docum-est.dt-trans
    FIELD dt-trans-fin     LIKE docum-est.dt-trans
    FIELD i-nro-docto-ini  LIKE docum-est.nro-docto
    FIELD i-nro-docto-fin  LIKE docum-est.nro-docto
    FIELD i-cod-emit-ini   LIKE docum-est.cod-emitente
    FIELD i-cod-emit-fin   LIKE docum-est.cod-emitente.

DEFINE TEMP-TABLE tt-digita
    FIELD arquivo AS CHAR
    FIELD raiz    AS CHAR 
    FIELD node    AS CHAR
    FIELD campo   AS CHAR FORMAT "X(100)"
    FIELD valor   AS CHAR FORMAT "X(100)"
    FIELD linha   AS INTEGER.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

DEF VAR raw-param  AS RAW.


/****** Calculo dos impostos ***/

{inbo/boin090.i tt-docum-est}       /* Defini»’o TT-DOCUM-EST       */
{inbo/boin176.i tt-item-doc-est}    /* Defini»’o TT-ITEM-DOC-EST    */

DEFINE TEMP-TABLE tt-impostos NO-UNDO LIKE tt-item-doc-est.

DEF BUFFER b-estabelec FOR estabelec.
DEF BUFFER b-int-ds-it-docto-xml FOR int-ds-it-docto-xml.

DEF VAR c-estab-orig LIKE param-estoq.estabel-pad.
DEF VAR i-seq-item   AS INTEGER NO-UNDO.
DEF VAR c-cod-depos  AS CHAR.
DEF VAR c-nat-oper     LIKE int-ds-it-docto-xml.nat-operacao.
DEF VAR c-nat-oper-ant LIKE int-ds-it-docto-xml.nat-operacao.
DEF VAR d-tot-vbc-icms LIKE int-ds-it-docto-xml.vbc-icms.
DEF VAR d-tot-vpis     LIKE int-ds-it-docto-xml.vpis.   
DEF VAR d-tot-vcofins  LIKE int-ds-it-docto-xml.vcofins.
DEF VAR d-tot-desconto LIKE int-ds-it-docto-xml.vdesc.
DEF VAR d-tot-vicms    LIKE int-ds-it-docto-xml.vicms. 
DEF VAR d-tot-vbcst    LIKE int-ds-it-docto-xml.vbcst.
DEF VAR d-tot-vicmsst  LIKE int-ds-it-docto-xml.vicmsst.
                             
DEF TEMP-TABLE tt-nota no-undo
FIELD situacao     AS INTEGER
FIELD nro-docto    LIKE docum-est.nro-docto   
FIELD serie-nota   LIKE docum-est.serie-docto
FIELD serie-docum  LIKE docum-est.serie-docto        
FIELD cod-emitente LIKE docum-est.cod-emitente
FIELD nat-operacao LIKE docum-est.nat-operacao
FIELD tipo-nota    LIKE int-ds-docto-xml.tipo-nota
FIELD valor-mercad LIKE doc-fisico.valor-mercad.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE MaintenanceNoNavigation
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-int-ds-it-docto-xml.it-codigo ~
tt-int-ds-it-docto-xml.item-do-forn 
&Scoped-define ENABLED-TABLES tt-int-ds-it-docto-xml
&Scoped-define FIRST-ENABLED-TABLE tt-int-ds-it-docto-xml
&Scoped-Define ENABLED-OBJECTS c-desc-fam c-desc-item c-un btOK btSave ~
btCancel btHelp rtKeys rtToolBar 
&Scoped-Define DISPLAYED-FIELDS tt-int-ds-it-docto-xml.sequencia ~
tt-int-ds-it-docto-xml.it-codigo tt-int-ds-it-docto-xml.item-do-forn 
&Scoped-define DISPLAYED-TABLES tt-int-ds-it-docto-xml
&Scoped-define FIRST-DISPLAYED-TABLE tt-int-ds-it-docto-xml
&Scoped-Define DISPLAYED-OBJECTS c-desc-fam c-fam c-desc-item c-un 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wMaintenanceNoNavigation AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE BUTTON btSave 
     LABEL "Salvar" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-desc-fam AS CHARACTER FORMAT "X(60)":U 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 53.72 BY .88 NO-UNDO.

DEFINE VARIABLE c-desc-item AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 40.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-fam AS CHARACTER FORMAT "X(08)":U 
     LABEL "Fam¡lia" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE c-un AS CHARACTER FORMAT "x(02)" 
     VIEW-AS FILL-IN 
     SIZE 3.29 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKeys
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 3.46.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE VARIABLE c-desc-nat AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 44.72 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     c-desc-fam AT ROW 3.5 COL 22.29 COLON-ALIGNED WIDGET-ID 50
     c-fam AT ROW 3.5 COL 14 COLON-ALIGNED WIDGET-ID 48
     tt-int-ds-it-docto-xml.sequencia AT ROW 1.46 COL 14 COLON-ALIGNED WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 6.86 BY .88
     tt-int-ds-it-docto-xml.it-codigo AT ROW 2.5 COL 14 COLON-ALIGNED WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 18 BY .88
     c-desc-item AT ROW 2.5 COL 32.29 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     c-un AT ROW 2.5 COL 73 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     btOK AT ROW 15 COL 2
     btSave AT ROW 15 COL 13
     btCancel AT ROW 15 COL 24
     btHelp AT ROW 15 COL 80
     tt-int-ds-it-docto-xml.item-do-forn AT ROW 1.5 COL 31.86 COLON-ALIGNED WIDGET-ID 46
          LABEL "Item Fornec":R12
          VIEW-AS FILL-IN 
          SIZE 44.14 BY .79
     rtKeys AT ROW 1.29 COL 2
     rtToolBar AT ROW 14.75 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 92.14 BY 16
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     tt-int-ds-it-docto-xml.num-pedido AT ROW 1.5 COL 12 COLON-ALIGNED WIDGET-ID 38
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt-int-ds-it-docto-xml.numero-ordem AT ROW 2.5 COL 12 COLON-ALIGNED WIDGET-ID 40
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     tt-int-ds-it-docto-xml.qCom-forn AT ROW 3.5 COL 12 COLON-ALIGNED WIDGET-ID 22
          LABEL "Quantidade"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-int-ds-it-docto-xml.vUnCom AT ROW 4.5 COL 12 COLON-ALIGNED WIDGET-ID 48
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-int-ds-it-docto-xml.vProd AT ROW 5.5 COL 12 COLON-ALIGNED WIDGET-ID 26
          LABEL "Valor Produto"
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-int-ds-it-docto-xml.vDesc AT ROW 6.58 COL 12 COLON-ALIGNED WIDGET-ID 44
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.nat-operacao AT ROW 7.67 COL 12 COLON-ALIGNED WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 7 BY .88
     c-desc-nat AT ROW 7.67 COL 19.29 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     tt-int-ds-it-docto-xml.cfop AT ROW 8.67 COL 12 COLON-ALIGNED WIDGET-ID 50
          VIEW-AS FILL-IN 
          SIZE 8.86 BY .88
     tt-int-ds-it-docto-xml.Lote AT ROW 1.5 COL 66 COLON-ALIGNED WIDGET-ID 56
          VIEW-AS FILL-IN 
          SIZE 15.43 BY .88
     tt-int-ds-it-docto-xml.dVal AT ROW 2.5 COL 66 COLON-ALIGNED WIDGET-ID 54
          VIEW-AS FILL-IN 
          SIZE 11 BY .88
     tt-int-ds-it-docto-xml.dFab AT ROW 3.5 COL 66 COLON-ALIGNED WIDGET-ID 52
          VIEW-AS FILL-IN 
          SIZE 11 BY .88
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.14 ROW 5.67
         SIZE 87.86 BY 8.79
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fpage2
     tt-int-ds-it-docto-xml.narrativa AT ROW 2 COL 5.72 NO-LABEL WIDGET-ID 48
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 76 BY 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.43 ROW 5.75
         SIZE 86.57 BY 8.54
         FONT 1 WIDGET-ID 200.

DEFINE FRAME fpage3
     tt-int-ds-it-docto-xml.picms AT ROW 3.42 COL 18 COLON-ALIGNED WIDGET-ID 52
          VIEW-AS FILL-IN 
          SIZE 5.43 BY .88
     tt-int-ds-it-docto-xml.vbc-icms AT ROW 4.42 COL 18 COLON-ALIGNED WIDGET-ID 62
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.vicms AT ROW 5.42 COL 18 COLON-ALIGNED WIDGET-ID 72
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.vbcst AT ROW 6.46 COL 18 COLON-ALIGNED WIDGET-ID 66
          LABEL "Base Calc. ICMS ST"
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.vicmsst AT ROW 7.46 COL 18 COLON-ALIGNED WIDGET-ID 74
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.pcofins AT ROW 3.25 COL 46 COLON-ALIGNED WIDGET-ID 50
          VIEW-AS FILL-IN 
          SIZE 5.43 BY .88
     tt-int-ds-it-docto-xml.vbc-cofins AT ROW 4.25 COL 46 COLON-ALIGNED WIDGET-ID 60
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.vcofins AT ROW 5.25 COL 46 COLON-ALIGNED WIDGET-ID 70
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.ppis AT ROW 6.29 COL 46 COLON-ALIGNED WIDGET-ID 58
          VIEW-AS FILL-IN 
          SIZE 5.43 BY .88
     tt-int-ds-it-docto-xml.vbc-pis AT ROW 7.29 COL 46 COLON-ALIGNED WIDGET-ID 64
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.vpis AT ROW 8.33 COL 46 COLON-ALIGNED WIDGET-ID 78
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.pipi AT ROW 3.25 COL 71 COLON-ALIGNED WIDGET-ID 82
          VIEW-AS FILL-IN 
          SIZE 5.43 BY .88
     tt-int-ds-it-docto-xml.vbc-ipi AT ROW 4.25 COL 71 COLON-ALIGNED WIDGET-ID 84
          LABEL "Base Calc IPI"
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.vipi AT ROW 5.25 COL 71 COLON-ALIGNED WIDGET-ID 88
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
     tt-int-ds-it-docto-xml.vtottrib AT ROW 6.29 COL 71 COLON-ALIGNED WIDGET-ID 80
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .88
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.43 ROW 5.75
         SIZE 87.57 BY 8.54
         FONT 1 WIDGET-ID 300.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MaintenanceNoNavigation
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int-ds-docto-xml T "?" NO-UNDO emsesp int-ds-docto-xml
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
      END-FIELDS.
      TABLE: tt-int-ds-it-docto-xml T "?" NO-UNDO emsesp int-ds-it-docto-xml
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wMaintenanceNoNavigation ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 16.17
         WIDTH              = 93.72
         MAX-HEIGHT         = 28.33
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 28.33
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wMaintenanceNoNavigation 
/* ************************* Included-Libraries *********************** */

{maintenancenonavigation/maintenancenonavigation.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wMaintenanceNoNavigation
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE
       FRAME fpage2:FRAME = FRAME fpage0:HANDLE
       FRAME fpage3:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME Custom                                                    */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME fPage1:MOVE-AFTER-TAB-ITEM (btHelp:HANDLE IN FRAME fpage0)
       XXTABVALXX = FRAME fPage1:MOVE-BEFORE-TAB-ITEM (tt-int-ds-it-docto-xml.item-do-forn:HANDLE IN FRAME fpage0)
/* END-ASSIGN-TABS */.

/* SETTINGS FOR FILL-IN c-fam IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-it-docto-xml.item-do-forn IN FRAME fpage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-it-docto-xml.sequencia IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME fPage1
   Custom                                                               */
/* SETTINGS FOR FILL-IN tt-int-ds-it-docto-xml.num-pedido IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-it-docto-xml.numero-ordem IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-it-docto-xml.qCom-forn IN FRAME fPage1
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-it-docto-xml.vProd IN FRAME fPage1
   EXP-LABEL                                                            */
/* SETTINGS FOR FRAME fpage2
                                                                        */
/* SETTINGS FOR FRAME fpage3
   Custom                                                               */
/* SETTINGS FOR FILL-IN tt-int-ds-it-docto-xml.vbc-ipi IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-it-docto-xml.vbcst IN FRAME fpage3
   EXP-LABEL                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wMaintenanceNoNavigation)
THEN wMaintenanceNoNavigation:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage1
/* Query rebuild information for FRAME fPage1
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage2
/* Query rebuild information for FRAME fpage2
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage3
/* Query rebuild information for FRAME fpage3
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage3 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wMaintenanceNoNavigation
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMaintenanceNoNavigation wMaintenanceNoNavigation
ON END-ERROR OF wMaintenanceNoNavigation
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMaintenanceNoNavigation wMaintenanceNoNavigation
ON WINDOW-CLOSE OF wMaintenanceNoNavigation
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wMaintenanceNoNavigation
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wMaintenanceNoNavigation
ON CHOOSE OF btHelp IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wMaintenanceNoNavigation
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    

     
    RUN saveRecord IN THIS-PROCEDURE.

    RUN pi-situacao.

    IF RETURN-VALUE = "OK":U THEN DO:
        RUN pi-reposiciona-filho IN phCaller.
        APPLY "CLOSE":U TO THIS-PROCEDURE.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSave wMaintenanceNoNavigation
ON CHOOSE OF btSave IN FRAME fpage0 /* Salvar */
DO:
    RUN saveRecord IN THIS-PROCEDURE.
    RUN pi-reposiciona-filho IN phCaller.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-int-ds-it-docto-xml.it-codigo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.it-codigo wMaintenanceNoNavigation
ON F5 OF tt-int-ds-it-docto-xml.it-codigo IN FRAME fpage0 /* Item */
DO:
   
    {include/zoomvar.i &prog-zoom="inzoom/z01in172.w"
                      &campo="tt-int-ds-it-docto-xml.it-codigo"
                      &campozoom="it-codigo"
                      &frame="fPage0"
                      &campo2="c-desc-item"
                      &campozoom2="c-descricao"
                      &frame2="fPage0"
                      &campo3="c-un"
                      &campozoom3="un"
                      &frame3="fPage0"
                      &campo4="c-un"  
                      &campozoom4="fm-codigo"
                      &frame4="fPage0"
                      }
   

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.it-codigo wMaintenanceNoNavigation
ON LEAVE OF tt-int-ds-it-docto-xml.it-codigo IN FRAME fpage0 /* Item */
DO:
  
   FIND FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = INPUT FRAME fpage0 tt-int-ds-it-docto-xml.it-codigo NO-ERROR.
   IF AVAIL ITEM then do:
       ASSIGN c-desc-item:SCREEN-VALUE IN FRAME fpage0  = item.desc-item
                     c-un:SCREEN-VALUE IN FRAME fpage0  = item.un
                     c-fam:SCREEN-VALUE IN FRAME fpage0 = ITEM.fm-codigo.

       FIND FIRST familia NO-LOCK WHERE
                  familia.fm-codigo = ITEM.fm-codigo NO-ERROR.
       IF AVAIL familia THEN
           ASSIGN c-desc-fam:SCREEN-VALUE IN FRAME fpage0 = familia.descricao.

       for first item-fornec no-lock where 
           item-fornec.cod-emitente = tt-int-ds-docto-xml.cod-emitente and
           item-fornec.it-codigo    = INPUT FRAME fpage0 tt-int-ds-it-docto-xml.it-codigo and
           item-fornec.ativo        = yes:
           assign tt-int-ds-it-docto-xml.item-do-forn:screen-value in FRAME fPage0 = item-fornec.item-do-forn.           
       end.
   end.
   ELSE 
       ASSIGN c-desc-item:SCREEN-VALUE IN FRAME fpage0  = ""
                      c-un:SCREEN-VALUE IN FRAME fpage0 = ""
                      c-fam:SCREEN-VALUE IN FRAME fpage0 = ""
                      c-desc-fam:SCREEN-VALUE IN FRAME fpage0 = "".

   APPLY "entry" TO tt-int-ds-it-docto-xml.num-pedido IN FRAME fpage1.
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.it-codigo wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int-ds-it-docto-xml.it-codigo IN FRAME fpage0 /* Item */
DO:
  APPLY 'f5' TO self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME tt-int-ds-it-docto-xml.nat-operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.nat-operacao wMaintenanceNoNavigation
ON F5 OF tt-int-ds-it-docto-xml.nat-operacao IN FRAME fPage1 /* Nat Opera‡Æo */
DO:
  
    {method/zoomfields.i &ProgramZoom="inzoom/z04in245.w"
                         &FieldZoom1="nat-operacao"
                         &FieldScreen1="tt-int-ds-it-docto-xml.nat-operacao"
                         &frame1="fpage1"
                         &FieldZoom2="denominacao"
                         &FieldScreen2="c-desc-nat"
                         &frame2="fpage1"
                         &FieldZoom3="cfop"
                         &FieldScreen3="tt-int-ds-it-docto-xml.cfop"
                         &frame3="fpage1"} 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.nat-operacao wMaintenanceNoNavigation
ON LEAVE OF tt-int-ds-it-docto-xml.nat-operacao IN FRAME fPage1 /* Nat Opera‡Æo */
DO:

   RUN pi-leave-natureza.

   IF c-nat-oper <> "" THEN
      ASSIGN c-nat-oper-ant = c-nat-oper 
             c-nat-oper = INPUT FRAME fpage1 tt-int-ds-it-docto-xml.nat-operacao.
             
   IF AVAIL tt-int-ds-docto-xml 
   THEN DO:
      IF tt-int-ds-docto-xml.tipo-docto = 4  /* AND /* Notas Pepsico */ 
         c-nat-oper  <>  c-nat-oper-ant */                                  
      THEN DO:
         
         RUN pi-calcula-impostos (2).

         ASSIGN c-nat-oper = INPUT FRAME fpage1 tt-int-ds-it-docto-xml.nat-operacao.
                
      END.
   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.nat-operacao wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int-ds-it-docto-xml.nat-operacao IN FRAME fPage1 /* Nat Opera‡Æo */
DO:
  APPLY "f5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-int-ds-it-docto-xml.num-pedido
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.num-pedido wMaintenanceNoNavigation
ON F5 OF tt-int-ds-it-docto-xml.num-pedido IN FRAME fPage1 /* Pedido */
DO:
    {include/zoomvar.i &prog-zoom=inzoom/z13in274.w
                       &campo=tt-int-ds-it-docto-xml.numero-ordem                      
                       &campo2=tt-int-ds-it-docto-xml.num-pedido    
                       &campozoom=numero-ordem
                       &campozoom2=num-pedido
                       &parametros="run pi-recebe-parametros in wh-pesquisa 
                                        (input tt-int-ds-docto-xml.cod-emitente, 
                                         input 1,
                                         input tt-int-ds-it-docto-xml.it-codigo)."}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.num-pedido wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int-ds-it-docto-xml.num-pedido IN FRAME fPage1 /* Pedido */
DO:
  
    APPLY "f5" TO SELF.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-int-ds-it-docto-xml.numero-ordem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.numero-ordem wMaintenanceNoNavigation
ON F5 OF tt-int-ds-it-docto-xml.numero-ordem IN FRAME fPage1 /* Ordem Compra */
DO:
  
     {include/zoomvar.i &prog-zoom=inzoom/z13in274.w
                       &campo=tt-int-ds-it-docto-xml.numero-ordem
                       &campozoom=numero-ordem
                       &parametros="run pi-recebe-parametros in wh-pesquisa
                                        (input tt-int-ds-docto-xml.cod-emitente,
                                         input 1,
                                         input tt-int-ds-it-docto-xml.it-codigo)."}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.numero-ordem wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int-ds-it-docto-xml.numero-ordem IN FRAME fPage1 /* Ordem Compra */
DO:
  APPLY "f5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-int-ds-it-docto-xml.vDesc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.vDesc wMaintenanceNoNavigation
ON LEAVE OF tt-int-ds-it-docto-xml.vDesc IN FRAME fPage1 /* Vlr Desconto */
DO:
  IF AVAIL tt-int-ds-docto-xml 
  THEN DO:
     IF tt-int-ds-docto-xml.tipo-docto = 4  /* Notas Pepsico */
     THEN DO:

        RUN pi-calcula-impostos(1).

     END.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-int-ds-it-docto-xml.vUnCom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-it-docto-xml.vUnCom wMaintenanceNoNavigation
ON LEAVE OF tt-int-ds-it-docto-xml.vUnCom IN FRAME fPage1 /* Vlr unit */
DO:
    assign tt-int-ds-it-docto-xml.vProd:screen-value = 
        string(input frame fPage1 tt-int-ds-it-docto-xml.qCom-forn * input frame fPage1 tt-int-ds-it-docto-xml.vUnCom).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMaintenanceNoNavigation 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{maintenancenonavigation/mainblock.i}


tt-int-ds-it-docto-xml.it-codigo:load-mouse-pointer("image/lupa.cur":U) in frame fPage0.
tt-int-ds-it-docto-xml.nat-operacao:load-mouse-pointer("image/lupa.cur":U) in frame fPage1.
tt-int-ds-it-docto-xml.num-pedido:load-mouse-pointer("image/lupa.cur":U) in frame fPage1.
tt-int-ds-it-docto-xml.numero-ordem:load-mouse-pointer("image/lupa.cur":U) in frame fPage1.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wMaintenanceNoNavigation 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF pcAction <> "update" 
    THEN DO:

        FOR LAST int-ds-it-docto-xml NO-LOCK WHERE
                 int-ds-it-docto-xml.serie        = tt-int-ds-docto-xml.serie AND 
                 int-ds-it-docto-xml.cod-emitente = tt-int-ds-docto-xml.cod-emitente AND 
                 int(int-ds-it-docto-xml.nNF)     = INT(tt-int-ds-docto-xml.nNF)     AND 
                 int-ds-it-docto-xml.tipo-nota    = tt-int-ds-docto-xml.tipo-nota :
        END.

        IF AVAIL int-ds-it-docto-xml 
        THEN DO:
              
           ASSIGN tt-int-ds-it-docto-xml.sequencia:SCREEN-VALUE IN FRAME fpage0 = STRING(int-ds-it-docto-xml.sequencia + 10).

        END.
        ELSE 
            ASSIGN tt-int-ds-it-docto-xml.sequencia:SCREEN-VALUE IN FRAME fpage0 = "10".
    END.

    DISABLE tt-int-ds-it-docto-xml.sequencia 
            tt-int-ds-it-docto-xml.item-do-forn
            c-desc-item c-un c-fam WITH FRAME fpage0.

    DISABLE tt-int-ds-it-docto-xml.num-pedido
            tt-int-ds-it-docto-xml.numero-ordem WITH FRAME fPage1.

    ASSIGN c-nat-oper-ant = tt-int-ds-it-docto-xml.nat-operacao.     
                                                     
    APPLY 'leave' TO tt-int-ds-it-docto-xml.it-codigo IN FRAME fpage0.
    APPLY "entry" TO tt-int-ds-it-docto-xml.it-codigo IN FRAME fpage0.
    
    IF tt-int-ds-it-docto-xml.nat-operacao <> "" THEN
       ASSIGN c-nat-oper-ant = tt-int-ds-it-docto-xml.nat-operacao.
    ELSE 
       ASSIGN c-nat-oper-ant = "Nat Oper".
                               
    RUN pi-leave-natureza.

    RETURN "ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-calcula-impostos wMaintenanceNoNavigation 
PROCEDURE pi-calcula-impostos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF INPUT PARAM p-tipo AS INTEGER.

DEF VAR de-aliq-pis    LIKE int-ds-it-docto-xml.ppis.
DEF VAR de-aliq-cofins LIKE int-ds-it-docto-xml.pcofins.
DEF VAR d-vl-bicms     LIKE int-ds-it-docto-xml.vbc-cofins. 

FOR first ITEM no-lock where 
          ITEM.it-codigo  = tt-int-ds-it-docto-xml.it-codigo query-tuning(no-lookahead):

    ASSIGN de-aliq-pis = dec(substr(item.char-2,31,5))
           de-aliq-cofins = dec(substr(item.char-2,36,5)).
    
    
    IF de-aliq-pis > 0 THEN 
        ASSIGN  tt-int-ds-it-docto-xml.vbc-pis:SCREEN-VALUE IN FRAME fpage3    = STRING(dec(tt-int-ds-it-docto-xml.vProd:SCREEN-VALUE IN FRAME fpage1) - dec(tt-int-ds-it-docto-xml.vDesc:SCREEN-VALUE IN FRAME fpage1))
                tt-int-ds-it-docto-xml.ppis:SCREEN-VALUE IN FRAME fpage3       = string(de-aliq-pis)
                tt-int-ds-it-docto-xml.vpis:SCREEN-VALUE IN FRAME fpage3    = string(dec(tt-int-ds-it-docto-xml.vbc-pis:SCREEN-VALUE IN FRAME fpage3) * (de-aliq-pis / 100)).
    ELSE 
        ASSIGN tt-int-ds-it-docto-xml.vbc-pis:SCREEN-VALUE IN FRAME fpage3  = "0"
               tt-int-ds-it-docto-xml.ppis:SCREEN-VALUE IN FRAME fpage3     = "0"
               tt-int-ds-it-docto-xml.vpis:SCREEN-VALUE IN FRAME fpage3     = "0".

    IF de-aliq-cofins > 0 THEN 
       ASSIGN tt-int-ds-it-docto-xml.vbc-cofins:SCREEN-VALUE IN FRAME fpage3 =  STRING(dec(tt-int-ds-it-docto-xml.vProd:SCREEN-VALUE IN FRAME fpage1) - dec(tt-int-ds-it-docto-xml.vDesc:SCREEN-VALUE IN FRAME fpage1))
              tt-int-ds-it-docto-xml.vcofins:SCREEN-VALUE IN FRAME fpage3    =  string(DEC(tt-int-ds-it-docto-xml.vbc-cofins:SCREEN-VALUE IN FRAME fpage3) * (de-aliq-cofins / 100))
              tt-int-ds-it-docto-xml.pcofins:SCREEN-VALUE IN FRAME fpage3    =  string(de-aliq-cofins).
    ELSE
      ASSIGN tt-int-ds-it-docto-xml.vcofins:SCREEN-VALUE IN FRAME fpage3    = "0"
             tt-int-ds-it-docto-xml.vbc-cofins:SCREEN-VALUE IN FRAME fpage3 = "0"
             tt-int-ds-it-docto-xml.vcofins:SCREEN-VALUE IN FRAME fpage3     = "0".
    
    FIND FIRST natur-oper NO-LOCK WHERE 
               natur-oper.nat-operacao = INPUT FRAME fpage1 tt-int-ds-it-docto-xml.nat-operacao AND 
               natur-oper.nat-ativa = YES  NO-ERROR.
    IF AVAIL natur-oper AND 
             p-tipo = 2  
    THEN DO:

       RUN pi-retorna-impostos.

       FIND FIRST tt-impostos NO-ERROR.
                              

       IF AVAIL tt-impostos THEN DO:
           
          ASSIGN tt-int-ds-it-docto-xml.picms:SCREEN-VALUE IN FRAME fpage3    = STRING(tt-impostos.aliquota-icm)
                 tt-int-ds-it-docto-xml.vbc-icms:SCREEN-VALUE IN FRAME fpage3 = STRING(tt-impostos.base-icm[1])
                 tt-int-ds-it-docto-xml.vicms:SCREEN-VALUE IN FRAME fpage3    = STRING(tt-impostos.valor-icm[1])
                 tt-int-ds-it-docto-xml.vbcst:SCREEN-VALUE IN FRAME fpage3    = STRING(tt-impostos.base-subs[1])
                 tt-int-ds-it-docto-xml.vicmsst:SCREEN-VALUE IN FRAME fpage3  = STRING(tt-impostos.vl-subs[1]).
       END.
            
    END.
         
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-leave-natureza wMaintenanceNoNavigation 
PROCEDURE pi-leave-natureza :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

 FIND FIRST natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = INPUT FRAME fpage1 tt-int-ds-it-docto-xml.nat-operacao NO-ERROR.
   IF AVAIL natur-oper THEN DO:
  
       ASSIGN c-desc-nat:SCREEN-VALUE IN FRAME fpage1                  = natur-oper.denominacao
              tt-int-ds-it-docto-xml.cfop:SCREEN-VALUE IN FRAME fpage1 = natur-oper.cod-cfop.

     
   END.
   ELSE 
       ASSIGN c-desc-nat:SCREEN-VALUE IN FRAME fpage1 = ""
              tt-int-ds-it-docto-xml.cfop:SCREEN-VALUE IN FRAME fpage1 = "".


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-retorna-impostos wMaintenanceNoNavigation 
PROCEDURE pi-retorna-impostos :
/*------------------------------------------------------------------------------
  Purpose: Para calcular os impostos , gera uma nota no re1001 via Bo e inclui apenas um item 
           para o c lculo dos impostos.     
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/

    FIND FIRST param-estoq NO-LOCK NO-ERROR.
    
    EMPTY TEMP-TABLE tt-nota.
    EMPTY TEMP-TABLE tt-docum-est.
    EMPTY TEMP-TABLE tt-item-doc-est.
    EMPTY TEMP-TABLE tt-impostos.

    CREATE tt-nota.
    ASSIGN tt-nota.situacao     = 2
           tt-nota.nro-docto    = tt-int-ds-docto-xml.nNF   
           tt-nota.serie-nota   = tt-int-ds-docto-xml.serie 
           tt-nota.serie-docum  = tt-int-ds-docto-xml.serie         
           tt-nota.cod-emitente = tt-int-ds-docto-xml.cod-emitente
           tt-nota.nat-operacao = INPUT FRAME fpage1 tt-int-ds-it-docto-xml.nat-operacao
           tt-nota.valor-mercad = tt-int-ds-docto-xml.valor-mercad.

     FOR EACH tt-nota ,
         FIRST natur-oper NO-LOCK WHERE
               natur-oper.nat-operacao = tt-nota.nat-operacao :

           FIND FIRST emitente NO-LOCK WHERE
                      emitente.cod-emitente = tt-nota.cod-emitente NO-ERROR.
            
           CREATE tt-docum-est.
           assign tt-docum-est.nro-docto    = tt-int-ds-docto-xml.nNF
                  tt-docum-est.cod-emitente = tt-nota.cod-emitente
                  tt-docum-est.serie-docto  = tt-nota.serie-docum
                  tt-docum-est.char-2       = tt-nota.serie-nota  /* Serie documento principal */
                  tt-docum-est.nat-operacao = natur-oper.nat-operacao                              
                  tt-docum-est.cod-observa  = if natur-oper.log-2 then 2 /* Comercio */ else 1  /* Industria*/
                  tt-docum-est.cod-estabel   = tt-int-ds-docto-xml.cod-estab
                  tt-docum-est.estab-fisc    = tt-int-ds-docto-xml.cod-estab
                  tt-docum-est.estab-de-or   = ""  
                  tt-docum-est.usuario       = "super"
                  tt-docum-est.uf            = emitente.estado 
                  tt-docum-est.via-transp    = 1
                  tt-docum-est.dt-emis       = tt-int-ds-docto-xml.dEmi   
                  tt-docum-est.dt-trans      = TODAY                          
                  tt-docum-est.nff           = no                              /**** Nota fiscal de Fatura ***/
                  tt-docum-est.observacao    = "Calculo de impostos" 
                  tt-docum-est.valor-mercad  = 0 
                  tt-docum-est.tot-valor     = tt-nota.valor-mercad
                  tt-docum-est.conta-transit = param-estoq.conta-fornec
                  tt-docum-est.esp-docto     = 21.
                                                                                             
           IF LENGTH(TRIM(string(tt-docum-est.nro-docto))) < 8 THEN
              ASSIGN tt-docum-est.nro-docto = STRING(int(tt-docum-est.nro-docto),"9999999").

           ASSIGN i-seq-item = 0.
          
           FOR FIRST ITEM NO-LOCK WHERE 
                      ITEM.it-codigo = tt-int-ds-it-docto-xml.it-codigo 
                BREAK BY tt-int-ds-it-docto-xml.nat-operacao:

                IF FIRST-OF(tt-int-ds-it-docto-xml.nat-operacao) THEN
                   ASSIGN i-seq-item  = 0.

                 ASSIGN i-seq-item  =  i-seq-item + 10.

                 CREATE tt-item-doc-est.
                 ASSIGN tt-item-doc-est.serie-docto    = tt-docum-est.serie-docto
                        tt-item-doc-est.char-2         = tt-nota.serie-nota       /* Serie documento principal */
                        tt-item-doc-est.nro-docto      = tt-docum-est.nro-docto
                        tt-item-doc-est.cod-emitente   = tt-docum-est.cod-emitente
                        tt-item-doc-est.nat-operacao   = tt-docum-est.nat-operacao
                        tt-item-doc-est.sequencia      = i-seq-item
                        tt-item-doc-est.it-codigo      = ITEM.it-codigo
                        tt-item-doc-est.num-pedido     = 0 
                        tt-item-doc-est.numero-ordem   = 0. 

                 FIND FIRST item-uni-estab NO-LOCK WHERE
                            item-uni-estab.cod-estabel = tt-docum-est.cod-estab AND
                            item-uni-estab.it-codigo   = ITEM.it-codigo NO-ERROR.
                 IF AVAIL item-uni-estab THEN
                    ASSIGN c-cod-depos = item-uni-estab.deposito-pad.
                 ELSE 
                    ASSIGN c-cod-depos = item.deposito-pad.

                 assign tt-item-doc-est.encerra-pa     = no
                        tt-item-doc-est.log-1          = NO /* FIFO */
                        tt-item-doc-est.desconto       = INPUT FRAME fpage1 tt-int-ds-it-docto-xml.vdesc
                        tt-item-doc-est.parcela        = 0
                        tt-item-doc-est.nr-ord-prod    = 0
                        tt-item-doc-est.cod-roteiro    = ""
                        tt-item-doc-est.op-codigo      = 0
                        tt-item-doc-est.item-pai       = ""
                        tt-item-doc-est.baixa-ce       = YES 
                        tt-item-doc-est.quantidade     = INPUT FRAME fpage1 tt-int-ds-it-docto-xml.qcom-forn
                        tt-item-doc-est.cod-depos      = c-cod-depos
                        tt-item-doc-est.class-fiscal   = item.class-fiscal
                        tt-item-doc-est.preco-total[1] = INPUT FRAME fpage1 tt-int-ds-it-docto-xml.Vprod.    

                 IF ITEM.tipo-contr = 4 THEN DO:
                    IF AVAIL item-uni-estab THEN
                       ASSIGN tt-item-doc-est.conta-contabil = item-uni-estab.conta-aplicacao.
                    ELSE 
                       ASSIGN tt-item-doc-est.conta-contabil = ITEM.conta-aplicacao.
                 END.
                 ELSE 
                   ASSIGN tt-item-doc-est.conta-contabil = "".

           END.

       END.    

       DO TRANS:

           RUN intprg/int002i.p(input table tt-nota,
                                input TABLE tt-docum-est,
                                INPUT TABLE tt-item-doc-est,
                                OUTPUT TABLE tt-impostos).

           UNDO , LEAVE.

       END.
            
      
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-situacao wMaintenanceNoNavigation 
PROCEDURE pi-situacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

IF RETURN-VALUE = "OK" 
THEN DO:
     
    FIND FIRST int-ds-docto-xml WHERE                             
               int-ds-docto-xml.serie          = tt-int-ds-docto-xml.serie        AND
               int(int-ds-docto-xml.nNF)       = int(tt-int-ds-docto-xml.nNF)     AND
               int-ds-docto-xml.cod-emitente   = tt-int-ds-docto-xml.cod-emitente AND
               int-ds-docto-xml.tipo-nota      = tt-int-ds-docto-xml.tipo-nota NO-ERROR.
    IF AVAIL int-ds-docto-xml 
    THEN DO: 

        for each tt-raw-digita:
            delete tt-raw-digita.
        end.
           
        EMPTY TEMP-TABLE tt-digita.
        EMPTY TEMP-TABLE tt-param.

        CREATE tt-param.
        ASSIGN tt-param.destino         = 2                              
               tt-param.arquivo         = SESSION:TEMP-DIRECTORY + "\" + "int002brp-tela.txt"       
               tt-param.usuario         = c-seg-usuario       
               tt-param.data-exec       = TODAY  
               tt-param.hora-exec       = TIME      
               tt-param.dt-trans-ini    = int-ds-docto-xml.DEmi 
               tt-param.dt-trans-fin    = int-ds-docto-xml.DEmi
               tt-param.i-nro-docto-ini = int-ds-docto-xml.nNF 
               tt-param.i-nro-docto-fin = int-ds-docto-xml.nNF
               tt-param.i-cod-emit-ini  = int-ds-docto-xml.cod-emitente
               tt-param.i-cod-emit-fin  = int-ds-docto-xml.cod-emitente. 
    
        create tt-digita.
        assign tt-digita.campo = "item"
               tt-digita.valor = string(tt-int-ds-it-docto-xml.r-Rowid).
        raw-transfer tt-param  to raw-param.
    
        for each tt-digita:
            create tt-raw-digita.
            raw-transfer tt-digita to tt-raw-digita.raw-digita.
        end.

        run intprg/int002brp.p (input raw-param, 
                                input table tt-raw-digita).
                                                    
        IF NOT CAN-FIND(FIRST int-ds-it-docto-xml NO-LOCK WHERE 
                              int-ds-it-docto-xml.serie         =  int-ds-docto-xml.serie         AND
                              int(int-ds-it-docto-xml.nNF)      =  int(int-ds-docto-xml.nNF)      AND
                              int-ds-it-docto-xml.cod-emitente  =  int-ds-docto-xml.cod-emitente  AND
                              int-ds-it-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota     AND
                              int-ds-it-docto-xml.situacao      =  1 /* Pendente */)   
        THEN 
            ASSIGN int-ds-docto-xml.situacao = 2. /* Liberado */
        ELSE 
            ASSIGN int-ds-docto-xml.situacao = 1. /* Pendente */ 

              
         /*** Apenas notas da Pepsico ****/
             
         IF int-ds-docto-xml.tipo-docto = 4 
         THEN DO:
        
             ASSIGN d-tot-vbc-icms = 0
                    d-tot-vpis     = 0
                    d-tot-vcofins  = 0 
                    d-tot-desconto = 0
                    d-tot-vicms    = 0
                    d-tot-vbcst    = 0
                    d-tot-vicmsst  = 0.    
                                     
             FOR EACH b-int-ds-it-docto-xml NO-LOCK WHERE 
                      b-int-ds-it-docto-xml.serie         =  int-ds-docto-xml.serie         AND
                      int(b-int-ds-it-docto-xml.nNF)      =  INT(int-ds-docto-xml.nNF)      AND
                      b-int-ds-it-docto-xml.cod-emitente  =  int-ds-docto-xml.cod-emitente  AND
                      b-int-ds-it-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota :
                  
                 ASSIGN d-tot-vbc-icms = d-tot-vbc-icms +  b-int-ds-it-docto-xml.vbc-icms
                        d-tot-vpis     = d-tot-vpis     +  b-int-ds-it-docto-xml.vpis   
                        d-tot-vcofins  = d-tot-vcofins  +  b-int-ds-it-docto-xml.vcofins
                        d-tot-desconto = d-tot-desconto +  b-int-ds-it-docto-xml.vdesc
                        d-tot-vicms    = d-tot-vicms    +  b-int-ds-it-docto-xml.vicms 
                        d-tot-vbcst    = d-tot-vbcst    +  b-int-ds-it-docto-xml.vbcst
                        d-tot-vicmsst  = d-tot-vicmsst  +  b-int-ds-it-docto-xml.vicmsst.
    
             END.

             ASSIGN int-ds-docto-xml.vbc          = d-tot-vbc-icms
                    int-ds-docto-xml.valor-pis    = d-tot-vpis 
                    int-ds-docto-xml.valor-cofins = d-tot-vcofins
                    int-ds-docto-xml.tot-desconto = d-tot-desconto
                    int-ds-docto-xml.valor-icms   = d-tot-vicms            
                    int-ds-docto-xml.vbc-cst      = d-tot-vbcst  
                    int-ds-docto-xml.valor-st     = d-tot-vicmsst
                    int-ds-docto-xml.vNF          = (int-ds-docto-xml.valor-mercad + int-ds-docto-xml.valor-st) - d-tot-desconto. 
                     

         END.
    END.    
    
    /* RUN repositionRecord IN THIS-PROCEDURE (INPUT tt-int-ds-it-docto-xml.r-Rowid). */
    
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveParentFields wMaintenanceNoNavigation 
PROCEDURE saveParentFields :
/*:T------------------------------------------------------------------------------
  Purpose:     Salva valores dos campos da tabela filho ({&ttTable}) com base 
               nos campos da tabela pai ({&ttParent})
  Parameters:  
  Notes:       Este m‚todo somente ‚ executado quando a vari vel pcAction 
               possuir os valores ADD ou COPY
------------------------------------------------------------------------------*/

    ASSIGN tt-int-ds-it-docto-xml.nNF          = tt-int-ds-docto-xml.nNF
           tt-int-ds-it-docto-xml.cod-emitente = tt-int-ds-docto-xml.cod-emitente 
           tt-int-ds-it-docto-xml.serie        = tt-int-ds-docto-xml.serie 
           tt-int-ds-it-docto-xml.tipo-nota    = tt-int-ds-docto-xml.tipo-nota.       
    
    FIND FIRST emitente NO-LOCK WHERE
               emitente.cod-emitente = tt-int-ds-docto-xml.cod-emitente NO-ERROR.
    IF AVAIL emitente THEN DO:

        ASSIGN tt-int-ds-it-docto-xml.CNPJ = emitente.cgc.

    END.
                                       
    RETURN "OK":U.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

