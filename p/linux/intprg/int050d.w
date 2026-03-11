&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i INT050D 2.00.00.000}

/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT050D
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Detail

&GLOBAL-DEFINE page0Widgets tempo-fatur-hr dt-prim-nf min-nf item-min ~
tot-ped-integrado tot-ped-faturado tot-item-integrado tot-item-faturado ~
media-item-ped-int media-item-ped-fat dt-ult-nf hr-prim-nf hr-ult-nf ~
tempo-fatur-min btHelp btOK  

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAM p-min-nf             AS DEC  NO-UNDO.
DEFINE INPUT PARAM p-item-min           AS DEC  NO-UNDO.
DEFINE INPUT PARAM p-tot-ped-integrado  AS INT  NO-UNDO.
DEFINE INPUT PARAM p-tot-item-integrado AS INT  NO-UNDO.
DEFINE INPUT PARAM p-media-item-ped-int AS DEC  NO-UNDO.
DEFINE INPUT PARAM p-tot-ped-faturado   AS INT  NO-UNDO.
DEFINE INPUT PARAM p-tot-item-faturado  AS INT  NO-UNDO.
DEFINE INPUT PARAM p-media-item-ped-fat AS DEC  NO-UNDO.
DEFINE INPUT PARAM p-dt-prim-nf         AS DATE NO-UNDO.
DEFINE INPUT PARAM p-hr-prim-nf         AS INT NO-UNDO.
DEFINE INPUT PARAM p-tempo-fatur-hr     AS CHAR NO-UNDO.
DEFINE INPUT PARAM p-dt-ult-nf          AS DATE NO-UNDO.
DEFINE INPUT PARAM p-hr-ult-nf          AS INT NO-UNDO.
DEFINE INPUT PARAM p-tempo-fatur-min    AS INT NO-UNDO.

DEF VAR de-aux AS INT NO-UNDO.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS btOK rtToolBar RECT-consulta-3 RECT-1 RECT-3 ~
RECT-4 
&Scoped-Define DISPLAYED-OBJECTS estima-termino tempo-fatur-hr dt-prim-nf ~
min-nf item-min tot-ped-integrado tot-ped-faturado tot-item-integrado ~
tot-item-faturado media-item-ped-int media-item-ped-fat dt-ult-nf ~
hr-prim-nf hr-ult-nf tempo-fatur-min dt-atual hr-atual 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btHelp 
     LABEL "&Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "&OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE dt-atual AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Atual" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE dt-prim-nf AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Primeira NF" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE dt-ult-nf AS DATE FORMAT "99/99/9999":U 
     LABEL "Data éltima NF" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE estima-termino AS CHARACTER FORMAT "X(8)":U 
     LABEL "Estimativa T‚rmino Faturamento" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE hr-atual AS CHARACTER FORMAT "X(8)":U 
     LABEL "Hora Atual" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE hr-prim-nf AS CHARACTER FORMAT "X(8)":U 
     LABEL "Hora Primeira NF" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE hr-ult-nf AS CHARACTER FORMAT "X(8)":U 
     LABEL "Hora éltima NF" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE item-min AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0 
     LABEL "Itens/Minuto" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE media-item-ped-fat AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "M‚dia Itens/Pedido" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE media-item-ped-int AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "M‚dia Itens/Pedido" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE min-nf AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0 
     LABEL "Minutos/NF" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE tempo-fatur-hr AS CHARACTER FORMAT "X(8)":U 
     LABEL "Tempo Faturamento - Horas" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE tempo-fatur-min AS DECIMAL FORMAT "->>>,>>9.99":U INITIAL 0 
     LABEL "Tempo Faturamento - Minutos" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE tot-item-faturado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Itens Faturados" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE tot-item-integrado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Itens Integrados" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE tot-ped-faturado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Pedidos Faturados" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE tot-ped-integrado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Pedidos Integrados" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 53 BY 3.58.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 81 BY 5.79.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 84.29 BY 11.08.

DEFINE RECTANGLE RECT-consulta-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 24.72 BY 2.58.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 84.29 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     estima-termino AT ROW 10.63 COL 26.43 COLON-ALIGNED WIDGET-ID 80
     tempo-fatur-hr AT ROW 9.63 COL 26.43 COLON-ALIGNED WIDGET-ID 62
     dt-prim-nf AT ROW 7.63 COL 26.43 COLON-ALIGNED WIDGET-ID 54
     btOK AT ROW 12.92 COL 2.43
     btHelp AT ROW 12.92 COL 74.29
     min-nf AT ROW 3 COL 13.43 COLON-ALIGNED WIDGET-ID 48
     item-min AT ROW 4 COL 13.43 COLON-ALIGNED WIDGET-ID 50
     tot-ped-integrado AT ROW 2.5 COL 45.14 COLON-ALIGNED WIDGET-ID 34
     tot-ped-faturado AT ROW 2.5 COL 70.43 COLON-ALIGNED WIDGET-ID 36
     tot-item-integrado AT ROW 3.5 COL 45.14 COLON-ALIGNED WIDGET-ID 38
     tot-item-faturado AT ROW 3.5 COL 70.43 COLON-ALIGNED WIDGET-ID 40
     media-item-ped-int AT ROW 4.5 COL 45.14 COLON-ALIGNED WIDGET-ID 42
     media-item-ped-fat AT ROW 4.5 COL 70.43 COLON-ALIGNED WIDGET-ID 44
     dt-ult-nf AT ROW 8.63 COL 26.43 COLON-ALIGNED WIDGET-ID 56
     hr-prim-nf AT ROW 7.63 COL 64 COLON-ALIGNED WIDGET-ID 58
     hr-ult-nf AT ROW 8.63 COL 64 COLON-ALIGNED WIDGET-ID 60
     tempo-fatur-min AT ROW 9.63 COL 64 COLON-ALIGNED WIDGET-ID 64
     dt-atual AT ROW 6.63 COL 26.43 COLON-ALIGNED WIDGET-ID 76
     hr-atual AT ROW 6.63 COL 64 COLON-ALIGNED WIDGET-ID 78
     "INDICADORES" VIEW-AS TEXT
          SIZE 10.57 BY .54 AT ROW 1.21 COL 38 WIDGET-ID 72
     rtToolBar AT ROW 12.67 COL 1.29
     RECT-consulta-3 AT ROW 2.63 COL 3 WIDGET-ID 52
     RECT-1 AT ROW 2.17 COL 31 WIDGET-ID 46
     RECT-3 AT ROW 6.17 COL 3 WIDGET-ID 68
     RECT-4 AT ROW 1.46 COL 1.29 WIDGET-ID 70
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 84.86 BY 13.25
         FONT 1
         DEFAULT-BUTTON btOK.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 13.25
         WIDTH              = 84.86
         MAX-HEIGHT         = 18.71
         MAX-WIDTH          = 144.57
         VIRTUAL-HEIGHT     = 18.71
         VIRTUAL-WIDTH      = 144.57
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wWindow 
/* ************************* Included-Libraries *********************** */

{window/window.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME fpage0
   FRAME-NAME Custom                                                    */
/* SETTINGS FOR BUTTON btHelp IN FRAME fpage0
   NO-ENABLE                                                            */
ASSIGN 
       btHelp:HIDDEN IN FRAME fpage0           = TRUE.

/* SETTINGS FOR FILL-IN dt-atual IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN dt-prim-nf IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN dt-ult-nf IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN estima-termino IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN hr-atual IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN hr-prim-nf IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN hr-ult-nf IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN item-min IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN media-item-ped-fat IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN media-item-ped-int IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN min-nf IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tempo-fatur-hr IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tempo-fatur-min IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-item-faturado IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-item-integrado IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-ped-faturado IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-ped-integrado IN FRAME fpage0
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
ON END-ERROR OF wWindow
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{window/mainblock.i}

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

   ASSIGN min-nf:SENSITIVE IN FRAME fPage0 = NO            
          item-min:SENSITIVE IN FRAME fPage0 = NO          
          tot-ped-integrado:SENSITIVE IN FRAME fPage0 = NO 
          tot-item-integrado:SENSITIVE IN FRAME fPage0 = NO
          media-item-ped-int:SENSITIVE IN FRAME fPage0 = NO
          tot-ped-faturado:SENSITIVE IN FRAME fPage0 = NO  
          tot-item-faturado:SENSITIVE IN FRAME fPage0 = NO 
          media-item-ped-fat:SENSITIVE IN FRAME fPage0 = NO
          dt-prim-nf:SENSITIVE IN FRAME fPage0 = NO        
          hr-prim-nf:SENSITIVE IN FRAME fPage0 = NO        
          tempo-fatur-hr:SENSITIVE IN FRAME fPage0 = NO    
          dt-ult-nf:SENSITIVE IN FRAME fPage0 = NO         
          hr-ult-nf:SENSITIVE IN FRAME fPage0 = NO         
          tempo-fatur-min:SENSITIVE IN FRAME fPage0 = NO
          dt-atual:SENSITIVE IN FRAME fPage0 = NO
          hr-atual:SENSITIVE IN FRAME fPage0 = NO
          dt-atual = TODAY
          hr-atual = STRING(TIME,"HH:MM").

   ASSIGN de-aux = (p-tot-item-integrado / p-item-min) * 60.
   IF de-aux = ? THEN
      ASSIGN de-aux = 0.
   ASSIGN estima-termino = STRING((TIME + de-aux),"HH:MM").

   DISP p-min-nf              @ min-nf            
        p-item-min            @ item-min          
        p-tot-ped-integrado   @ tot-ped-integrado 
        p-tot-item-integrado  @ tot-item-integrado
        p-media-item-ped-int  @ media-item-ped-int
        p-tot-ped-faturado    @ tot-ped-faturado  
        p-tot-item-faturado   @ tot-item-faturado 
        p-media-item-ped-fat  @ media-item-ped-fat
        p-dt-prim-nf          @ dt-prim-nf        
        string(p-hr-prim-nf,"hh:mm:ss") @ hr-prim-nf        
        STRING(p-tempo-fatur-min,"hh:mm:ss") @ tempo-fatur-hr    
        p-dt-ult-nf           @ dt-ult-nf         
        string(p-hr-ult-nf,"hh:mm:ss") @ hr-ult-nf         
        (p-tempo-fatur-min / 60) @ tempo-fatur-min   
        dt-atual
        hr-atual
        estima-termino
        WITH FRAME fPage0.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

