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
{include/i-prgvrs.i INT030A 2.12.01.AVB}

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
&GLOBAL-DEFINE Program        INT030A
&GLOBAL-DEFINE Version        2.00.00.008

&GLOBAL-DEFINE WindowType     Detail

&GLOBAL-DEFINE page0Widgets   c-origem-ini c-origem-fim ~
                              d-dt-ocorrencia-fim d-dt-ocorrencia-ini ~
                              c-hora-ini c-hora-fim ~
                              rsSituacao c-ultimosMov ~
                              btHelp btOK btCancel 

/* Parameters Definitions ---                                           */
DEFINE INPUT-OUTPUT PARAM p-origem-ini LIKE int_ds_prog_rpw.cod_prog NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-origem-fim LIKE int_ds_prog_rpw.cod_prog NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-dt-ocorrencia-ini LIKE int_ds_log.dt_ocorrencia NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-dt-ocorrencia-fim LIKE int_ds_log.dt_ocorrencia NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-c-hora-ini as character no-undo.
DEFINE INPUT-OUTPUT PARAM p-c-hora-fim as character no-undo.
DEFINE INPUT-OUTPUT PARAM p-situacao        as integer                   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-ultimosMov      as integer                   NO-UNDO.
DEFINE       OUTPUT PARAM p-l-open-query    AS   LOGICAL                 NO-UNDO.

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE i-cod-ocor AS INTEGER    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS c-origem-ini c-origem-fim ~
d-dt-ocorrencia-ini d-dt-ocorrencia-fim btOK btCancel btHelp rsSituacao ~
c-hora-ini c-hora-fim c-ultimosMov IMAGE-1 IMAGE-2 IMAGE-5 IMAGE-6 ~
rtToolBar IMAGE-7 IMAGE-8 
&Scoped-Define DISPLAYED-OBJECTS c-origem-ini c-origem-fim ~
d-dt-ocorrencia-ini d-dt-ocorrencia-fim rsSituacao c-hora-ini c-hora-fim ~
c-ultimosMov 

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

DEFINE VARIABLE c-hora-fim AS CHARACTER FORMAT "99:99:99" INITIAL "235959" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88.

DEFINE VARIABLE c-hora-ini AS CHARACTER FORMAT "99:99:99" INITIAL "000000" 
     LABEL "Hora":R16 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88.

DEFINE VARIABLE c-origem-fim AS CHARACTER FORMAT "x(10)" INITIAL "ZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 11.43 BY .88.

DEFINE VARIABLE c-origem-ini AS CHARACTER FORMAT "x(8)" 
     LABEL "Programa":R17 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE c-ultimosMov AS INTEGER FORMAT ">>>9" INITIAL 10 
     LABEL "Ult Movimentos":R16 
     VIEW-AS FILL-IN 
     SIZE 6.29 BY .88.

DEFINE VARIABLE d-dt-ocorrencia-fim AS DATE FORMAT "99/99/9999" INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE d-dt-ocorrencia-ini AS DATE FORMAT "99/99/9999" INITIAL 01/01/001 
     LABEL "Dt Execuá∆o":R15 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
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

DEFINE VARIABLE rsSituacao AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Pendentes", 1,
"Executados", 3,
"Ambos", 0
     SIZE 30.57 BY .54 NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 78 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     c-origem-ini AT ROW 1.75 COL 21 COLON-ALIGNED
     c-origem-fim AT ROW 1.75 COL 46.57 COLON-ALIGNED NO-LABEL
     d-dt-ocorrencia-ini AT ROW 2.75 COL 21 COLON-ALIGNED HELP
          "Data de emiss∆o da nota fiscal"
     d-dt-ocorrencia-fim AT ROW 2.75 COL 46.57 COLON-ALIGNED HELP
          "Data de emiss∆o da nota fiscal" NO-LABEL
     btOK AT ROW 6.29 COL 2
     btCancel AT ROW 6.29 COL 13
     btHelp AT ROW 6.29 COL 68.29
     rsSituacao AT ROW 5.04 COL 18.72 NO-LABEL WIDGET-ID 8
     c-hora-ini AT ROW 3.75 COL 24 COLON-ALIGNED HELP
          "Hora de Execuá∆o do Pedido de Execuá∆o" WIDGET-ID 16
     c-hora-fim AT ROW 3.75 COL 47 COLON-ALIGNED HELP
          "Hora de Execuá∆o do Pedido de Execuá∆o" NO-LABEL WIDGET-ID 18
     c-ultimosMov AT ROW 4.92 COL 62.72 COLON-ALIGNED HELP
          "Hora de Execuá∆o do Pedido de Execuá∆o" WIDGET-ID 26
     "Situaá∆o:" VIEW-AS TEXT
          SIZE 7 BY .54 AT ROW 5.04 COL 10.72 WIDGET-ID 14
     IMAGE-1 AT ROW 1.75 COL 36
     IMAGE-2 AT ROW 1.75 COL 44.72
     IMAGE-5 AT ROW 2.75 COL 36
     IMAGE-6 AT ROW 2.75 COL 44.72
     rtToolBar AT ROW 6.04 COL 1
     IMAGE-7 AT ROW 3.75 COL 36 WIDGET-ID 20
     IMAGE-8 AT ROW 3.75 COL 44.72 WIDGET-ID 22
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 78.57 BY 6.58
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
         HEIGHT             = 6.79
         WIDTH              = 79.14
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


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    ASSIGN p-l-open-query = NO.

    APPLY "CLOSE":U TO THIS-PROCEDURE.
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
    assign frame fPage0
            c-origem-ini 
            c-origem-fim 
            d-dt-ocorrencia-ini
            d-dt-ocorrencia-fim
            rsSituacao
            c-ultimosMov.

    assign  p-origem-ini  = c-origem-ini 
            p-origem-fim  = c-origem-fim 
            p-dt-ocorrencia-ini  = d-dt-ocorrencia-ini  
            p-dt-ocorrencia-fim  = d-dt-ocorrencia-fim  
            p-situacao         = rsSituacao
            p-ultimosMov       = c-ultimosMov
            .

    assign p-l-open-query = yes.

    APPLY "CLOSE":U TO THIS-PROCEDURE.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializaá∆o do programam ---*/
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

    assign  c-origem-ini:screen-value in frame fPage0           = p-origem-ini  
            c-origem-fim:screen-value in frame fPage0           = p-origem-fim 
            d-dt-ocorrencia-ini:screen-value in frame fPage0    = string(p-dt-ocorrencia-ini,"99/99/9999")
            d-dt-ocorrencia-fim:screen-value in frame fPage0    = string(p-dt-ocorrencia-fim,"99/99/9999")
            c-hora-ini:screen-value in frame fPage0             = p-c-hora-ini
            c-hora-fim:screen-value in frame fPage0             = p-c-hora-fim
            rsSituacao:screen-value in frame fPage0             = string(p-situacao)
            c-ultimosMov:SCREEN-VALUE IN FRAME fpage0           = string(p-ultimosMov).



RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

