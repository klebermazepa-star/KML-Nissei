&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wMaintenanceNoNavigation


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int-ds-docto-xml NO-UNDO LIKE int-ds-docto-xml
       field r-rowid as row.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wMaintenanceNoNavigation 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i int002a-01 2.06.00.001}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program           int002a-01
&GLOBAL-DEFINE Version           2.06.00.001

&GLOBAL-DEFINE Folder            YES
&GLOBAL-DEFINE InitialPage       1

&GLOBAL-DEFINE FolderLabels      Geral,Observa‡Æo,Impostos

&GLOBAL-DEFINE ttTable           tt-int-ds-docto-xml
&GLOBAL-DEFINE hDBOTable         h-tt-int-ds-docto-xml
&GLOBAL-DEFINE DBOTable          dbo-tt-int-ds-docto-xml
                                                      
&GLOBAL-DEFINE page0KeyFields    tt-int-ds-docto-xml.serie i-nro-docto tt-int-ds-docto-xml.cod-emitente cb-tipo-nota 
&GLOBAL-DEFINE page0Fields
&GLOBAL-DEFINE page1Fields       tt-int-ds-docto-xml.nat-operacao tt-int-ds-docto-xml.cod-estab tt-int-ds-docto-xml.estab-de-or tt-int-ds-docto-xml.dEmi tt-int-ds-docto-xml.dt-trans  tt-int-ds-docto-xml.volume tt-int-ds-docto-xml.num-pedido
                                                             
&GLOBAL-DEFINE page2Fields       tt-int-ds-docto-xml.observacao

&GLOBAL-DEFINE page3Fields        tt-int-ds-docto-xml.valor-mercad tt-int-ds-docto-xml.tot-desconto tt-int-ds-docto-xml.vbc tt-int-ds-docto-xml.vbc-cst tt-int-ds-docto-xml.valor-pis tt-int-ds-docto-xml.valor-ipi tt-int-ds-docto-xml.valor-icms-des tt-int-ds-docto-xml.valor-icms tt-int-ds-docto-xml.valor-cofins tt-int-ds-docto-xml.valor-st tt-int-ds-docto-xml.valor-outras  tt-int-ds-docto-xml.despesa-nota tt-int-ds-docto-xml.vnf tt-int-ds-docto-xml.valor-frete tt-int-ds-docto-xml.valor-seguro 

DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE        NO-UNDO.



DEFINE INPUT PARAMETER prTable         AS ROWID     NO-UNDO.
DEFINE INPUT PARAMETER pcAction        AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER phCaller        AS HANDLE    NO-UNDO.


define variable wh-pesquisa             as handle               no-undo.

DEFINE VARIABLE {&hDBOTable}  AS HANDLE NO-UNDO.

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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE MaintenanceNoNavigation
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-int-ds-docto-xml.cod-emitente ~
tt-int-ds-docto-xml.serie 
&Scoped-define ENABLED-TABLES tt-int-ds-docto-xml
&Scoped-define FIRST-ENABLED-TABLE tt-int-ds-docto-xml
&Scoped-Define ENABLED-OBJECTS rtKeys rtToolBar c-emitente i-nro-docto ~
cb-tipo-nota btOK btSave btCancel btHelp 
&Scoped-Define DISPLAYED-FIELDS tt-int-ds-docto-xml.cod-emitente ~
tt-int-ds-docto-xml.serie 
&Scoped-define DISPLAYED-TABLES tt-int-ds-docto-xml
&Scoped-define FIRST-DISPLAYED-TABLE tt-int-ds-docto-xml
&Scoped-Define DISPLAYED-OBJECTS c-emitente i-nro-docto cb-tipo-nota 

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

DEFINE VARIABLE cb-tipo-nota AS CHARACTER FORMAT "X(256)":U 
     LABEL "Tipo Nota" 
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEMS "Nota de Compra","Devolu‡Æo","Transferˆncia","Remessa Entr. Futura" 
     DROP-DOWN-LIST
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE c-emitente AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 49 BY .88 NO-UNDO.

DEFINE VARIABLE i-nro-docto AS DECIMAL FORMAT "99999999":U INITIAL 0 
     LABEL "Documento" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKeys
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 4.92.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE VARIABLE c-desc-nat AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 37 BY .88 NO-UNDO.

DEFINE VARIABLE c-estab AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE VARIABLE c-estab-orig AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     tt-int-ds-docto-xml.cod-emitente AT ROW 1.5 COL 18 COLON-ALIGNED WIDGET-ID 56
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     c-emitente AT ROW 1.5 COL 28.14 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     tt-int-ds-docto-xml.serie AT ROW 2.46 COL 18 COLON-ALIGNED WIDGET-ID 60
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     i-nro-docto AT ROW 3.5 COL 18 COLON-ALIGNED WIDGET-ID 64
     cb-tipo-nota AT ROW 4.58 COL 18 COLON-ALIGNED WIDGET-ID 62
     btOK AT ROW 19.04 COL 2
     btSave AT ROW 19.04 COL 13
     btCancel AT ROW 19.04 COL 24
     btHelp AT ROW 19.04 COL 80
     rtKeys AT ROW 1.08 COL 2
     rtToolBar AT ROW 18.79 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 19.54
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fpage1
     tt-int-ds-docto-xml.nat-operacao AT ROW 1.5 COL 16 COLON-ALIGNED WIDGET-ID 60
          VIEW-AS FILL-IN 
          SIZE 8.86 BY .88
     c-desc-nat AT ROW 1.5 COL 25 COLON-ALIGNED NO-LABEL WIDGET-ID 58
     tt-int-ds-docto-xml.cod-estab AT ROW 2.63 COL 16 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     c-estab AT ROW 2.63 COL 21.43 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     tt-int-ds-docto-xml.estab-de-or AT ROW 3.63 COL 16 COLON-ALIGNED WIDGET-ID 42
          LABEL "Est Origem":R22
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     c-estab-orig AT ROW 3.63 COL 21.57 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     tt-int-ds-docto-xml.dEmi AT ROW 4.63 COL 16 COLON-ALIGNED WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 11 BY .88
     tt-int-ds-docto-xml.dt-trans AT ROW 5.75 COL 16 COLON-ALIGNED WIDGET-ID 40
          VIEW-AS FILL-IN 
          SIZE 11 BY .88
     tt-int-ds-docto-xml.num-pedido AT ROW 6.79 COL 16.14 COLON-ALIGNED WIDGET-ID 62
          VIEW-AS FILL-IN 
          SIZE 13.29 BY .88
     tt-int-ds-docto-xml.volume AT ROW 7.79 COL 16 COLON-ALIGNED WIDGET-ID 54
          LABEL "Peso"
          VIEW-AS FILL-IN 
          SIZE 13.43 BY .88
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.29 ROW 7.75
         SIZE 87.14 BY 10.25
         FONT 1 WIDGET-ID 300.

DEFINE FRAME fpage2
     tt-int-ds-docto-xml.observacao AT ROW 2.42 COL 3 NO-LABEL WIDGET-ID 4
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 83 BY 7.5
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.43 ROW 7.71
         SIZE 87 BY 9
         FONT 1 WIDGET-ID 200.

DEFINE FRAME fpage3
     tt-int-ds-docto-xml.vNF AT ROW 8.5 COL 57 COLON-ALIGNED WIDGET-ID 30
          LABEL "Valor Total"
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.tot-desconto AT ROW 2.75 COL 15 COLON-ALIGNED WIDGET-ID 28
          LABEL "Total Desconto":R15
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.despesa-nota AT ROW 3.75 COL 15 COLON-ALIGNED WIDGET-ID 26
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.valor-frete AT ROW 4.75 COL 15 COLON-ALIGNED WIDGET-ID 46
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.valor-seguro AT ROW 5.75 COL 15 COLON-ALIGNED WIDGET-ID 52
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.valor-outras AT ROW 6.75 COL 15 COLON-ALIGNED WIDGET-ID 16
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.vbc AT ROW 1.5 COL 57 COLON-ALIGNED WIDGET-ID 22
          LABEL "Base C lc. ICMS":R20
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.valor-icms AT ROW 2.5 COL 57 COLON-ALIGNED WIDGET-ID 8
          LABEL "Valor ICMS":R12
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.vbc-cst AT ROW 3.5 COL 57 COLON-ALIGNED WIDGET-ID 24
          LABEL "Base Calc ICMS ST":R18
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.valor-st AT ROW 4.5 COL 57 COLON-ALIGNED WIDGET-ID 20
          LABEL "Valor ICMS ST":R18
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.valor-icms-des AT ROW 7.75 COL 15 COLON-ALIGNED WIDGET-ID 10
          LABEL "Vlr ICMS Desonerado":R19
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.valor-ipi AT ROW 5.5 COL 57 COLON-ALIGNED WIDGET-ID 14
          LABEL "Valor IPI":R10
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.valor-pis AT ROW 6.5 COL 57 COLON-ALIGNED WIDGET-ID 18
          LABEL "Valor Pis":R10
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.valor-cofins AT ROW 7.5 COL 57 COLON-ALIGNED WIDGET-ID 6
          LABEL "Valor Cofins":R12
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.valor-mercad AT ROW 1.75 COL 15 COLON-ALIGNED WIDGET-ID 54
          LABEL "Valor Total Mercad.":R20
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.43 ROW 7.75
         SIZE 87 BY 9
         FONT 1 WIDGET-ID 400.


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
          field r-rowid as row
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
         HEIGHT             = 19.54
         WIDTH              = 90
         MAX-HEIGHT         = 30.17
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 30.17
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
ASSIGN FRAME fpage1:FRAME = FRAME fpage0:HANDLE
       FRAME fpage2:FRAME = FRAME fpage0:HANDLE
       FRAME fpage3:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fpage1
   Custom                                                               */
/* SETTINGS FOR FILL-IN c-estab IN FRAME fpage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-estab-orig IN FRAME fpage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.estab-de-or IN FRAME fpage1
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.num-pedido IN FRAME fpage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.volume IN FRAME fpage1
   EXP-LABEL                                                            */
/* SETTINGS FOR FRAME fpage2
                                                                        */
/* SETTINGS FOR FRAME fpage3
   Custom                                                               */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.tot-desconto IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.valor-cofins IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.valor-icms IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.valor-icms-des IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.valor-ipi IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.valor-mercad IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.valor-pis IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.valor-st IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.vbc IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.vbc-cst IN FRAME fpage3
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.vNF IN FRAME fpage3
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
    CASE INPUT FRAME fpage0 cb-tipo-nota:
        WHEN "Nota de Compra" THEN ASSIGN tt-int-ds-docto-xml.tipo-nota = 1.
        WHEN "Devolu‡Æo"      THEN ASSIGN tt-int-ds-docto-xml.tipo-nota = 2.
        WHEN "Transferˆncia"  THEN ASSIGN tt-int-ds-docto-xml.tipo-nota = 3.

    END CASE.

    RUN saveRecord IN THIS-PROCEDURE.
    IF RETURN-VALUE = "OK":U THEN DO:

    FIND FIRST int-ds-it-docto-xml NO-LOCK WHERE
               int-ds-it-docto-xml.serie         = tt-int-ds-docto-xml.serie         AND
               int(int-ds-it-docto-xml.nNF)      = int(tt-int-ds-docto-xml.nNF)      AND
               int-ds-it-docto-xml.cod-emitente  = tt-int-ds-docto-xml.cod-emitente  AND
               int-ds-it-docto-xml.tipo-nota     = tt-int-ds-docto-xml.tipo-nota NO-ERROR.  
    IF AVAIL int-ds-it-docto-xml 
    THEN DO:
              
        for each tt-raw-digita:
            delete tt-raw-digita.
         end.

         EMPTY TEMP-TABLE tt-digita.
         EMPTY TEMP-TABLE tt-param.
    
        CREATE tt-param.
        ASSIGN tt-param.destino         = 2                              
               tt-param.arquivo         = SESSION:TEMP-DIRECTORY + "\" + "int002brp.txt"       
               tt-param.usuario         = c-seg-usuario       
               tt-param.data-exec       = TODAY  
               tt-param.hora-exec       = TIME      
               tt-param.dt-trans-ini    = tt-int-ds-docto-xml.DEmi 
               tt-param.dt-trans-fin    = tt-int-ds-docto-xml.DEmi
               tt-param.i-nro-docto-ini = int-ds-it-docto-xml.nNF 
               tt-param.i-nro-docto-fin = int-ds-it-docto-xml.nNF
               tt-param.i-cod-emit-ini  = int-ds-it-docto-xml.cod-emitente
               tt-param.i-cod-emit-fin  = int-ds-it-docto-xml.cod-emitente. 
    
        create tt-digita.
        assign tt-digita.campo = ""
               tt-digita.valor = string(ROWID(int-ds-it-docto-xml)).
        raw-transfer tt-param  to raw-param.
    
        for each tt-digita:
            create tt-raw-digita.
            raw-transfer tt-digita to tt-raw-digita.raw-digita.
        end.

        run intprg/int002brp.p (input raw-param, 
                                input table tt-raw-digita).
    END. 

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
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-tipo-nota
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-tipo-nota wMaintenanceNoNavigation
ON VALUE-CHANGED OF cb-tipo-nota IN FRAME fpage0 /* Tipo Nota */
DO:
    IF SELF:SCREEN-VALUE = "Transferˆncia" THEN DO:
        ENABLE tt-int-ds-docto-xml.estab-de-or WITH FRAME fpage1.

    END.
    ELSE DO:
        DISABLE tt-int-ds-docto-xml.estab-de-or WITH FRAME fpage1.
        ASSIGN tt-int-ds-docto-xml.estab-de-or:SCREEN-VALUE IN FRAME fpage1 = "".

        APPLY "leave" TO tt-int-ds-docto-xml.estab-de-or IN FRAME fpage1.

    END.
         
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-int-ds-docto-xml.cod-emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.cod-emitente wMaintenanceNoNavigation
ON F5 OF tt-int-ds-docto-xml.cod-emitente IN FRAME fpage0 /* Emitente */
DO:
  
   {include/zoomvar.i &prog-zoom=adzoom/z01ad098.w
                      &campo=tt-int-ds-docto-xml.cod-emitente
                      &campozoom=cod-emitente
                      &campo2=c-emitente
                      &campozoom2=nome-emit}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.cod-emitente wMaintenanceNoNavigation
ON LEAVE OF tt-int-ds-docto-xml.cod-emitente IN FRAME fpage0 /* Emitente */
DO:
   FIND FIRST emitente WHERE 
             emitente.cod-emitente = INPUT FRAME fpage0 tt-int-ds-docto-xml.cod-emitente NO-LOCK NO-ERROR.
  IF AVAIL emitente THEN DO:
      ASSIGN c-emitente:SCREEN-VALUE IN FRAME fpage0 = emitente.nome-emit.
  END.
  ELSE DO:
      ASSIGN c-emitente:SCREEN-VALUE IN FRAME fpage0 = "".
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.cod-emitente wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int-ds-docto-xml.cod-emitente IN FRAME fpage0 /* Emitente */
DO:
  
    APPLY "f5" TO SELF.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage1
&Scoped-define SELF-NAME tt-int-ds-docto-xml.cod-estab
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.cod-estab wMaintenanceNoNavigation
ON F5 OF tt-int-ds-docto-xml.cod-estab IN FRAME fpage1 /* Estabelecimento */
DO:
  
    {include/zoomvar.i &prog-zoom="adzoom/z01ad107.w"
                     &campo=tt-int-ds-docto-xml.cod-estab
                     &campozoom=cod-estabel
                     &campo2=c-estab
                     &campozoom2=nome}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.cod-estab wMaintenanceNoNavigation
ON LEAVE OF tt-int-ds-docto-xml.cod-estab IN FRAME fpage1 /* Estabelecimento */
DO:

  FIND FIRST estabelec WHERE 
              estabelec.cod-estabel = INPUT FRAME fpage1 tt-int-ds-docto-xml.cod-estab NO-LOCK NO-ERROR.
  IF AVAIL estabelec THEN DO:
      ASSIGN c-estab:SCREEN-VALUE IN FRAME fpage1 = estabelec.nome.
  END.
  ELSE DO:
      ASSIGN c-estab:SCREEN-VALUE IN FRAME fpage1 = "".
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.cod-estab wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int-ds-docto-xml.cod-estab IN FRAME fpage1 /* Estabelecimento */
DO:

  APPLY "f5" TO SELF.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-int-ds-docto-xml.estab-de-or
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.estab-de-or wMaintenanceNoNavigation
ON F5 OF tt-int-ds-docto-xml.estab-de-or IN FRAME fpage1 /* Est Origem */
DO:
      {include/zoomvar.i &prog-zoom="adzoom/z01ad107.w"
                     &campo=tt-int-ds-docto-xml.estab-de-or
                     &campozoom=cod-estabel
                     &campo2=c-estab-orig
                     &campozoom2=nome}


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.estab-de-or wMaintenanceNoNavigation
ON LEAVE OF tt-int-ds-docto-xml.estab-de-or IN FRAME fpage1 /* Est Origem */
DO:
  FIND FIRST estabelec WHERE 
              estabelec.cod-estabel = INPUT FRAME fpage1 tt-int-ds-docto-xml.estab-de-or NO-LOCK NO-ERROR.
  IF AVAIL estabelec THEN DO:
      ASSIGN c-estab-orig:SCREEN-VALUE IN FRAME fpage1 = estabelec.nome.
  END.
  ELSE DO:
      ASSIGN c-estab-orig:SCREEN-VALUE IN FRAME fpage1 = "".
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.estab-de-or wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int-ds-docto-xml.estab-de-or IN FRAME fpage1 /* Est Origem */
DO:
  APPLY "f5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-int-ds-docto-xml.nat-operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.nat-operacao wMaintenanceNoNavigation
ON F5 OF tt-int-ds-docto-xml.nat-operacao IN FRAME fpage1 /* Nat Opera‡Æo */
DO:
  
     {method/zoomfields.i &ProgramZoom="inzoom/z04in245.w"
                         &FieldZoom1="nat-operacao"
                         &FieldScreen1="tt-int-ds-docto-xml.nat-operacao"
                         &frame1="fpage1"
                         &FieldZoom2="denominacao"
                         &FieldScreen2="c-desc-nat"
                         &frame2="fpage1"} 
                         
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.nat-operacao wMaintenanceNoNavigation
ON LEAVE OF tt-int-ds-docto-xml.nat-operacao IN FRAME fpage1 /* Nat Opera‡Æo */
DO:
  FIND FIRST natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = INPUT FRAME fpage1 tt-int-ds-docto-xml.nat-operacao NO-ERROR.
   IF AVAIL natur-oper THEN
       ASSIGN c-desc-nat:SCREEN-VALUE IN FRAME fpage1                  = natur-oper.denominacao.
   ELSE 
       ASSIGN c-desc-nat:SCREEN-VALUE IN FRAME fpage1 = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.nat-operacao wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int-ds-docto-xml.nat-operacao IN FRAME fpage1 /* Nat Opera‡Æo */
DO:
  APPLY "f5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMaintenanceNoNavigation 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{maintenancenonavigation/mainblock.i}

tt-int-ds-docto-xml.cod-emitente:load-mouse-pointer("image/lupa.cur":U) in frame fPage0.
tt-int-ds-docto-xml.nat-operacao:load-mouse-pointer("image/lupa.cur":U) in frame fPage1.
tt-int-ds-docto-xml.cod-estab:load-mouse-pointer("image/lupa.cur":U) in frame fPage1.
tt-int-ds-docto-xml.estab-de-or:load-mouse-pointer("image/lupa.cur":U) in frame fPage1.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterdisplayfields wMaintenanceNoNavigation 
PROCEDURE afterdisplayfields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    
    RETURN "ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wMaintenanceNoNavigation 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DISABLE tt-int-ds-docto-xml.num-pedido WITH FRAME fpage1.                                                             

    IF pcAction <> "update" THEN DO:

        DISABLE tt-int-ds-docto-xml.estab-de-or WITH FRAME fpage1. 

        ENABLE i-nro-docto cb-tipo-nota WITH FRAME fpage0.
                  
        ASSIGN cb-tipo-nota:SCREEN-VALUE IN FRAME fpage0 = "Nota de Compra"
               tt-int-ds-docto-xml.dEmi:SCREEN-VALUE IN FRAME fpage1     = STRING(TODAY)
               tt-int-ds-docto-xml.dt-trans:SCREEN-VALUE IN FRAME fpage1 = STRING(TODAY).
    END.
    ELSE DO:
        CASE tt-int-ds-docto-xml.tipo-nota :
          WHEN 1 THEN ASSIGN cb-tipo-nota:SCREEN-VALUE IN FRAME fpage0 = "Nota de Compra". 
          WHEN 2 THEN ASSIGN cb-tipo-nota:SCREEN-VALUE IN FRAME fpage0 = "Devolu‡Æo".     
          WHEN 3 THEN ASSIGN cb-tipo-nota:SCREEN-VALUE IN FRAME fpage0 = "Transferˆncia".
          WHEN 4 THEN ASSIGN cb-tipo-nota:SCREEN-VALUE IN FRAME fpage0 = "Remessa Entr. Futura".

         END CASE.

         APPLY "value-changed" TO cb-tipo-nota IN FRAME fpage0.

         ASSIGN i-nro-docto:SCREEN-VALUE IN FRAME fpage0 = tt-int-ds-docto-xml.nNF. 

    END.
    
    APPLY "leave" TO tt-int-ds-docto-xml.cod-emitente  IN FRAME fpage0.
    APPLY "leave" TO tt-int-ds-docto-xml.cod-estab     IN FRAME fpage1.

    RETURN "Ok".

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
    
    
    ASSIGN tt-int-ds-docto-xml.ep-codigo     = int(i-ep-codigo-usuario)
           tt-int-ds-docto-xml.nNF           = i-nro-docto:SCREEN-VALUE IN FRAME fpage0
           /* tt-int-ds-docto-xml.data-inclusao = TODAY */
           tt-int-ds-docto-xml.cod-usuario   = c-seg-usuario.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

