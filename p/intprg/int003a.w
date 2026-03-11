&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wMaintenanceNoNavigation


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int_ds_param_fundo_fixo NO-UNDO LIKE int_ds_param_fundo_fixo
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

{include/i-prgvrs.i int003a 2.12.00.001}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program           int003a
&GLOBAL-DEFINE Version           2.12.00.001

&GLOBAL-DEFINE Folder            NO
&GLOBAL-DEFINE InitialPage       1

&GLOBAL-DEFINE FolderLabels      Parƒmetros

&GLOBAL-DEFINE ttTable           tt-int_ds_param_fundo_fixo
&GLOBAL-DEFINE hDBOTable         h-tt-int_ds_param_fundo_fixo
&GLOBAL-DEFINE DBOTable          dbo-tt-int_ds_param_fundo_fixo
                                                      
&GLOBAL-DEFINE page0KeyFields    tt-int_ds_param_fundo_fixo.cod_empresa 
&GLOBAL-DEFINE page0Fields
&GLOBAL-DEFINE page1Fields       tt-int_ds_param_fundo_fixo.cta_ctbl tt-int_ds_param_fundo_fixo.cod_tip_trans_cx
                                                             
&GLOBAL-DEFINE page2Fields       
&GLOBAL-DEFINE page3Fields       

DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE        NO-UNDO.

def new global shared var v_rec_tip_trans_cx
    as recid
    format ">>>>>>9":U
    no-undo.

def new global shared var v_rec_cta_ctbl_integr
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.

DEFINE INPUT PARAMETER prTable         AS ROWID     NO-UNDO.
DEFINE INPUT PARAMETER pcAction        AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER phCaller        AS HANDLE    NO-UNDO.


define variable wh-pesquisa             as handle               no-undo.

DEFINE VARIABLE {&hDBOTable}  AS HANDLE NO-UNDO.
DEFINE VARIABLE h-boin176     AS HANDLE NO-UNDO.

DEF VAR c-conta-codigo    AS CHAR NO-UNDO.
DEF VAR c-conta-desc      AS CHAR NO-UNDO.
DEF VAR c-ccusto-desc     AS CHAR NO-UNDO.
DEF VAR l-utiliza-ccusto  AS LOG  NO-UNDO.
DEF VAR c-zoom-cod-conta  AS CHAR NO-UNDO.
DEF VAR c-zoom-desc-conta AS CHAR NO-UNDO.
DEF VAR c-conta           AS CHAR NO-UNDO.
def var c-formato-conta  as char        no-undo.
DEF VAR c-formato-ccusto AS CHAR        NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE MaintenanceNoNavigation
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-int_ds_param_fundo_fixo.cod_empresa 
&Scoped-define ENABLED-TABLES tt-int_ds_param_fundo_fixo
&Scoped-define FIRST-ENABLED-TABLE tt-int_ds_param_fundo_fixo
&Scoped-Define ENABLED-OBJECTS rtKeys rtToolBar c-desc-empresa btOK btSave ~
btCancel btHelp 
&Scoped-Define DISPLAYED-FIELDS tt-int_ds_param_fundo_fixo.cod_empresa 
&Scoped-define DISPLAYED-TABLES tt-int_ds_param_fundo_fixo
&Scoped-define FIRST-DISPLAYED-TABLE tt-int_ds_param_fundo_fixo
&Scoped-Define DISPLAYED-OBJECTS c-desc-empresa 

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

DEFINE VARIABLE c-desc-empresa AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 57 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKeys
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 1.67.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE BUTTON bt-zoom 
     IMAGE-UP FILE "image/toolbar/im-zoo.bmp":U
     LABEL "bt-zoom" 
     SIZE 5 BY 1.

DEFINE BUTTON bt-zoom-cx 
     IMAGE-UP FILE "image/toolbar/im-zoo.bmp":U
     LABEL "bt-zoom-cx" 
     SIZE 5 BY 1.

DEFINE VARIABLE c-desc-conta AS CHARACTER FORMAT "x(32)":U 
     VIEW-AS FILL-IN 
     SIZE 40.86 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     tt-int_ds_param_fundo_fixo.cod_empresa AT ROW 1.5 COL 20.14 COLON-ALIGNED WIDGET-ID 58
          VIEW-AS FILL-IN 
          SIZE 8.86 BY .88
     c-desc-empresa AT ROW 1.5 COL 29.29 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     btOK AT ROW 7.71 COL 2
     btSave AT ROW 7.71 COL 13
     btCancel AT ROW 7.71 COL 24
     btHelp AT ROW 7.71 COL 80
     rtKeys AT ROW 1.08 COL 2
     rtToolBar AT ROW 7.46 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 8.17
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fpage1
     bt-zoom AT ROW 1.17 COL 40.57 WIDGET-ID 16
     tt-int_ds_param_fundo_fixo.cta_ctbl AT ROW 1.25 COL 19 COLON-ALIGNED WIDGET-ID 12
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
     c-desc-conta AT ROW 1.25 COL 44 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     tt-int_ds_param_fundo_fixo.cod_tip_trans_cx AT ROW 2.25 COL 19 COLON-ALIGNED WIDGET-ID 18
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     bt-zoom-cx AT ROW 2.21 COL 31.57 WIDGET-ID 20
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.14 ROW 3
         SIZE 87.86 BY 4.25
         FONT 1 WIDGET-ID 300.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MaintenanceNoNavigation
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int_ds_param_fundo_fixo T "?" NO-UNDO emsesp int_ds_param_fundo_fixo
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
         HEIGHT             = 8.17
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
ASSIGN FRAME fpage1:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fpage1
   Custom                                                               */
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


&Scoped-define FRAME-NAME fpage1
&Scoped-define SELF-NAME bt-zoom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-zoom wMaintenanceNoNavigation
ON CHOOSE OF bt-zoom IN FRAME fpage1 /* bt-zoom */
DO:
    assign v_rec_cta_ctbl_integr = ?.

    /* Zoom de Conta Contabil Integracao */
    run prgint/utb/utb033na.p ("CMG", "PADRAO", "D‚bito PadrÆo").

    if v_rec_cta_ctbl_integr = ? then return "NOK" /*l_nok*/ .

    find cta_ctbl_integr where recid(cta_ctbl_integr) = v_rec_cta_ctbl_integr no-lock no-error.
    if not avail cta_ctbl_integr then return "NOK" /*l_nok*/ .

    assign tt-int_ds_param_fundo_fixo.cta_ctbl:SCREEN-VALUE IN FRAME fpage1  = cta_ctbl_integr.cod_cta_ctbl.
           
    find cta_ctbl where
         cta_ctbl.cod_plano_cta_ctbl = cta_ctbl_integr.cod_plano_cta_ctbl and
         cta_ctbl.cod_cta_ctbl       = cta_ctbl_integr.cod_cta_ctbl no-lock no-error.
    if avail cta_ctbl then
       assign c-desc-conta:screen-value in frame fpage1 = cta_ctbl.des_tit_ctbl.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-zoom-cx
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-zoom-cx wMaintenanceNoNavigation
ON CHOOSE OF bt-zoom-cx IN FRAME fpage1 /* bt-zoom-cx */
DO:
    
    run prgfin/cmg/cmg003ka.p /*prg_sea_tip_trans_cx*/.

    if  v_rec_tip_trans_cx <> ?
    then do:
        find tip_trans_cx where recid(tip_trans_cx) = v_rec_tip_trans_cx no-lock no-error.
        IF AVAIL tip_trans_cx THEN
          assign tt-int_ds_param_fundo_fixo.cod_tip_trans_cx:screen-value in frame fpage1 = string(tip_trans_cx.cod_tip_trans_cx).

    end /* if */.

    apply "entry" to tt-int_ds_param_fundo_fixo.cod_tip_trans_cx in frame fpage1.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
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
    IF RETURN-VALUE = "OK":U THEN
        APPLY "CLOSE":U TO THIS-PROCEDURE.
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


&Scoped-define SELF-NAME tt-int_ds_param_fundo_fixo.cod_empresa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_param_fundo_fixo.cod_empresa wMaintenanceNoNavigation
ON LEAVE OF tt-int_ds_param_fundo_fixo.cod_empresa IN FRAME fpage0 /* Empresa */
DO:

  FIND FIRST ems2mult.empresa NO-LOCK WHERE
             string(empresa.ep-codigo) =  tt-int_ds_param_fundo_fixo.cod_empresa:SCREEN-VALUE IN FRAME {&FRAME-NAME} NO-ERROR.
  IF AVAIL empresa  THEN
     ASSIGN c-desc-empresa:SCREEN-VALUE IN FRAME {&FRAME-NAME} = empresa.razao-social.
  ELSE 
     ASSIGN c-desc-empresa:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage1
&Scoped-define SELF-NAME tt-int_ds_param_fundo_fixo.cod_tip_trans_cx
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_param_fundo_fixo.cod_tip_trans_cx wMaintenanceNoNavigation
ON F5 OF tt-int_ds_param_fundo_fixo.cod_tip_trans_cx IN FRAME fpage1 /* Tipo Transa‡Æo Caixa */
DO:
  APPLY "choose" TO bt-zoom-cx.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_param_fundo_fixo.cod_tip_trans_cx wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int_ds_param_fundo_fixo.cod_tip_trans_cx IN FRAME fpage1 /* Tipo Transa‡Æo Caixa */
DO:
  APPLY "f5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-int_ds_param_fundo_fixo.cta_ctbl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_param_fundo_fixo.cta_ctbl wMaintenanceNoNavigation
ON F5 OF tt-int_ds_param_fundo_fixo.cta_ctbl IN FRAME fpage1 /* Conta Cont bil */
DO:
  APPLY "choose" TO bt-zoom.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_param_fundo_fixo.cta_ctbl wMaintenanceNoNavigation
ON LEAVE OF tt-int_ds_param_fundo_fixo.cta_ctbl IN FRAME fpage1 /* Conta Cont bil */
DO: 

    find cta_ctbl NO-LOCK where 
         cta_ctbl.cod_plano_cta_ctbl = "PADRAO" and 
         cta_ctbl.cod_cta_ctbl       = input frame fpage1 tt-int_ds_param_fundo_fixo.cta_ctbl no-error.
    IF avail cta_ctbl then 
       ASSIGN c-desc-conta:SCREEN-VALUE IN FRAME fpage1 = cta_ctbl.des_tit_ctbl.
    ELSE 
       ASSIGN c-desc-conta:SCREEN-VALUE IN FRAME fpage1 = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_param_fundo_fixo.cta_ctbl wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int_ds_param_fundo_fixo.cta_ctbl IN FRAME fpage1 /* Conta Cont bil */
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

tt-int_ds_param_fundo_fixo.cta_ctbl:LOAD-MOUSE-POINTER("image/lupa.cur":U) in frame fpage1.

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
    
    ASSIGN tt-int_ds_param_fundo_fixo.cod_empresa:SCREEN-VALUE IN FRAME {&FRAME-NAME} = string(i-ep-codigo-usuario)
           tt-int_ds_param_fundo_fixo.cod_empresa:SENSITIVE    IN FRAME {&FRAME-NAME} = NO
           bt-zoom:SENSITIVE                                   IN FRAME fpage1        = YES
           bt-zoom-cx:SENSITIVE                                IN FRAME fpage1        = YES
           tt-int_ds_param_fundo_fixo.cod_tip_trans_cx:SENSITIVE    IN FRAME fpage1   = YES.
           

    APPLY "leave" TO tt-int_ds_param_fundo_fixo.cod_empresa. 
    APPLY "leave" TO tt-int_ds_param_fundo_fixo.cta_ctbl.
    
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
    
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

