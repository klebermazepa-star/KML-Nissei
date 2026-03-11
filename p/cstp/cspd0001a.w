&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: JRA
Template Name: WWIN_DIALOG
Template Library: CSTDDK
Template Version: 1.00
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              CSPD0001a
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE WinModal             YES

&SCOPED-DEFINE page0EnableWidgets   btOK btCancel btHelp ~
                                    fi-no-ab-reppri-ini   fi-no-ab-reppri-fim ~
                                    fi-cod-estabel-ini    fi-cod-estabel-fim  ~
                                    fi-nr-pedido-ini      fi-nr-pedido-fim    ~
                                    fi-nome-abrev-ini     fi-nome-abrev-fim   ~
                                    fi-nr-nota-fis-ini    fi-nr-nota-fis-fim  ~
                                    fi-dt-implant-ini     fi-dt-implant-fim   ~
                                    fi-dt-emis-nota-ini   fi-dt-emis-nota-fim     
           
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}
/* Template Includes                                                       */
{cstddk/include/wWinDefinitions.i}
{cstp/cspd0001param.i}
/* ***************************  Definitions  ***************************    */
/* Parameters Definitions ---                                               */
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt-param.
/* Local Variable Definitions ---                                           */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 ~
IMAGE-5 IMAGE-6 IMAGE-7 IMAGE-8 IMAGE-9 IMAGE-10 IMAGE-11 IMAGE-12 IMAGE-13 ~
IMAGE-14 fi-no-ab-reppri-ini fi-no-ab-reppri-fim fi-cod-estabel-ini ~
fi-cod-estabel-fim fi-nr-pedido-ini fi-nr-pedido-fim fi-nome-abrev-ini ~
fi-nome-abrev-fim fi-nr-nota-fis-ini fi-nr-nota-fis-fim fi-dt-implant-ini ~
fi-dt-implant-fim fi-dt-emis-nota-ini fi-dt-emis-nota-fim btOK btCancel 
&Scoped-Define DISPLAYED-OBJECTS fi-no-ab-reppri-ini fi-no-ab-reppri-fim ~
fi-cod-estabel-ini fi-cod-estabel-fim fi-nr-pedido-ini fi-nr-pedido-fim ~
fi-nome-abrev-ini fi-nome-abrev-fim fi-nr-nota-fis-ini fi-nr-nota-fis-fim ~
fi-dt-implant-ini fi-dt-implant-fim fi-dt-emis-nota-ini fi-dt-emis-nota-fim 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "&Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp 
     LABEL "&Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "&OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE fi-cod-estabel-fim AS CHARACTER FORMAT "x(5)" INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE fi-cod-estabel-ini AS CHARACTER FORMAT "x(5)" 
     LABEL "Estabelecimento":R17 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE fi-dt-emis-nota-fim AS DATE FORMAT "99/99/9999" INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 9.43 BY .88 NO-UNDO.

DEFINE VARIABLE fi-dt-emis-nota-ini AS DATE FORMAT "99/99/9999" INITIAL 01/01/001 
     LABEL "Dt. EmissÆo NF":R18 
     VIEW-AS FILL-IN 
     SIZE 9.43 BY .88 NO-UNDO.

DEFINE VARIABLE fi-dt-implant-fim AS DATE FORMAT "99/99/9999" INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 9.43 BY .88 NO-UNDO.

DEFINE VARIABLE fi-dt-implant-ini AS DATE FORMAT "99/99/9999" INITIAL 01/01/001 
     LABEL "Dt. Pedido":R18 
     VIEW-AS FILL-IN 
     SIZE 9.43 BY .88 NO-UNDO.

DEFINE VARIABLE fi-no-ab-reppri-fim AS CHARACTER FORMAT "X(12)" INITIAL "ZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE fi-no-ab-reppri-ini AS CHARACTER FORMAT "X(12)" 
     LABEL "Representante":R14 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nome-abrev-fim AS CHARACTER FORMAT "X(12)" INITIAL "ZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nome-abrev-ini AS CHARACTER FORMAT "X(12)" 
     LABEL "Cliente":R14 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nr-nota-fis-fim AS CHARACTER FORMAT "X(16)" INITIAL "ZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nr-nota-fis-ini AS CHARACTER FORMAT "X(16)" 
     LABEL "Nota Fiscal":R14 
     VIEW-AS FILL-IN 
     SIZE 17 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nr-pedido-fim AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 999999999 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nr-pedido-ini AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Nr. Pedido":R17 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-10
     FILENAME "image\im-las":U
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

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-3
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-4
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-7
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-8
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-9
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 78 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     fi-no-ab-reppri-ini AT ROW 1.25 COL 21 COLON-ALIGNED WIDGET-ID 16
     fi-no-ab-reppri-fim AT ROW 1.25 COL 46.57 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     fi-cod-estabel-ini AT ROW 2.25 COL 21 COLON-ALIGNED WIDGET-ID 20
     fi-cod-estabel-fim AT ROW 2.25 COL 46.57 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     fi-nr-pedido-ini AT ROW 3.25 COL 21 COLON-ALIGNED WIDGET-ID 32
     fi-nr-pedido-fim AT ROW 3.25 COL 46.57 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     fi-nome-abrev-ini AT ROW 4.25 COL 21 COLON-ALIGNED WIDGET-ID 38
     fi-nome-abrev-fim AT ROW 4.25 COL 46.57 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     fi-nr-nota-fis-ini AT ROW 5.25 COL 21 COLON-ALIGNED WIDGET-ID 46
     fi-nr-nota-fis-fim AT ROW 5.25 COL 46.57 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     fi-dt-implant-ini AT ROW 6.25 COL 21 COLON-ALIGNED WIDGET-ID 56
     fi-dt-implant-fim AT ROW 6.25 COL 46.57 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     fi-dt-emis-nota-ini AT ROW 7.25 COL 21 COLON-ALIGNED WIDGET-ID 64
     fi-dt-emis-nota-fim AT ROW 7.25 COL 46.57 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     btOK AT ROW 8.96 COL 2 WIDGET-ID 10
     btCancel AT ROW 8.96 COL 13 WIDGET-ID 6
     btHelp AT ROW 8.96 COL 68.29 WIDGET-ID 8
     rtToolBar AT ROW 8.71 COL 1 WIDGET-ID 12
     IMAGE-1 AT ROW 1.25 COL 40.72 WIDGET-ID 22
     IMAGE-2 AT ROW 1.25 COL 44.72 WIDGET-ID 24
     IMAGE-3 AT ROW 2.25 COL 40.57 WIDGET-ID 26
     IMAGE-4 AT ROW 2.25 COL 44.72 WIDGET-ID 28
     IMAGE-5 AT ROW 3.25 COL 40.57 WIDGET-ID 34
     IMAGE-6 AT ROW 3.25 COL 44.72 WIDGET-ID 36
     IMAGE-7 AT ROW 4.25 COL 40.72 WIDGET-ID 42
     IMAGE-8 AT ROW 4.25 COL 44.72 WIDGET-ID 44
     IMAGE-9 AT ROW 5.25 COL 40.72 WIDGET-ID 50
     IMAGE-10 AT ROW 5.25 COL 44.72 WIDGET-ID 52
     IMAGE-11 AT ROW 6.25 COL 40.72 WIDGET-ID 60
     IMAGE-12 AT ROW 6.25 COL 44.72 WIDGET-ID 58
     IMAGE-13 AT ROW 7.25 COL 40.72 WIDGET-ID 66
     IMAGE-14 AT ROW 7.25 COL 44.72 WIDGET-ID 68
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80 BY 9.54
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = "wWindow"
         HEIGHT             = 10
         WIDTH              = 80
         MAX-HEIGHT         = 320
         MAX-WIDTH          = 320
         VIRTUAL-HEIGHT     = 320
         VIRTUAL-WIDTH      = 320
         RESIZE             = no
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



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR BUTTON btHelp IN FRAME fpage0
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

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

&Scoped-define SELF-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON END-ERROR OF wWindow /* wWindow */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow /* wWindow */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-MAXIMIZED OF wWindow /* wWindow */
DO:
    &IF "{&WinFullScreen}":U = "YES":U &THEN 
    RUN windowMaximized IN THIS-PROCEDURE .
    &ENDIF
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-RESTORED OF wWindow /* wWindow */
DO:
    &IF "{&WinFullScreen}":U = "YES":U &THEN 
    RUN windowRestored IN THIS-PROCEDURE .
    &ENDIF
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Ajuda */
DO:
    /*{include/ajuda.i}*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    RUN piSave .
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/* ***************************** MAIN BLOCK *************************** */
{cstddk/include/wWinMainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wWindow 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


DO WITH FRAME fPage0
    :
    
    FIND FIRST tt-param NO-ERROR.
    IF AVAIL tt-param THEN
        ASSIGN
            fi-no-ab-reppri-ini     :SCREEN-VALUE = tt-param.no-ab-reppri-ini  
            fi-no-ab-reppri-fim     :SCREEN-VALUE = tt-param.no-ab-reppri-fim  
            fi-cod-estabel-ini      :SCREEN-VALUE = tt-param.cod-estabel-ini   
            fi-cod-estabel-fim      :SCREEN-VALUE = tt-param.cod-estabel-fim
            fi-nr-pedido-ini        :SCREEN-VALUE = STRING(tt-param.nr-pedido-ini)
            fi-nr-pedido-fim        :SCREEN-VALUE = STRING(tt-param.nr-pedido-fim)
            fi-nome-abrev-ini       :SCREEN-VALUE = tt-param.nome-abrev-ini
            fi-nome-abrev-fim       :SCREEN-VALUE = tt-param.nome-abrev-fim
            fi-nr-nota-fis-ini      :SCREEN-VALUE = tt-param.nr-nota-fis-ini
            fi-nr-nota-fis-fim      :SCREEN-VALUE = tt-param.nr-nota-fis-fim
            fi-dt-implant-ini       :SCREEN-VALUE = STRING(tt-param.dt-implant-ini)
            fi-dt-implant-fim       :SCREEN-VALUE = STRING(tt-param.dt-implant-fim)
            fi-dt-emis-nota-ini     :SCREEN-VALUE = STRING(tt-param.dt-emis-nota-ini)
            fi-dt-emis-nota-fim     :SCREEN-VALUE = STRING(tt-param.dt-emis-nota-fim)
            .
    ELSE
        CREATE tt-param.
END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piSave wWindow 
PROCEDURE piSave :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME fPage0
    :
    ASSIGN
        tt-param.no-ab-reppri-ini   = fi-no-ab-reppri-ini     :SCREEN-VALUE
        tt-param.no-ab-reppri-fim   = fi-no-ab-reppri-fim     :SCREEN-VALUE
        tt-param.cod-estabel-ini    = fi-cod-estabel-ini      :SCREEN-VALUE
        tt-param.cod-estabel-fim    = fi-cod-estabel-fim      :SCREEN-VALUE
        tt-param.nr-pedido-ini      = INT(fi-nr-pedido-ini    :SCREEN-VALUE)
        tt-param.nr-pedido-fim      = INT(fi-nr-pedido-fim    :SCREEN-VALUE)
        tt-param.nome-abrev-ini     = fi-nome-abrev-ini       :SCREEN-VALUE
        tt-param.nome-abrev-fim     = fi-nome-abrev-fim       :SCREEN-VALUE
        tt-param.nr-nota-fis-ini    = fi-nr-nota-fis-ini      :SCREEN-VALUE
        tt-param.nr-nota-fis-fim    = fi-nr-nota-fis-fim      :SCREEN-VALUE 
        tt-param.dt-implant-ini     = DATE(fi-dt-implant-ini  :SCREEN-VALUE)
        tt-param.dt-implant-fim     = DATE(fi-dt-implant-fim  :SCREEN-VALUE) 
        tt-param.dt-emis-nota-ini   = DATE(fi-dt-emis-nota-ini:SCREEN-VALUE)
        tt-param.dt-emis-nota-fim   = DATE(fi-dt-emis-nota-fim:SCREEN-VALUE)        
        .
END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

