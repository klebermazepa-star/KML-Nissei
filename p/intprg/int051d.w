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
{include/i-prgvrs.i INT051D 2.00.00.000}

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
&GLOBAL-DEFINE Program        INT051D
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Detail

&GLOBAL-DEFINE page0Widgets   i-pedido i-sit-ped ~
                              btCancela btOK  

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAM p-pedido AS INT  FORMAT ">>>>>>>>9"  NO-UNDO.

/* Local Variable Definitions ---                                       */

DEF BUFFER b-int_ds_pedido FOR int_ds_pedido.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS i-sit-ped btOK rtToolBar RECT-1 
&Scoped-Define DISPLAYED-OBJECTS i-sit-ped i-pedido 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancela 
     LABEL "&Cancela" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "&OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE i-pedido AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Nr. Pedido" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE i-sit-ped AS INTEGER FORMAT "9":U INITIAL 0 
     LABEL "Situa‡Æo Pedido" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 26.86 BY 3.17.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 26.86 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     i-sit-ped AT ROW 2.75 COL 13 COLON-ALIGNED WIDGET-ID 56
     btOK AT ROW 4.63 COL 2.29
     btCancela AT ROW 4.63 COL 17
     i-pedido AT ROW 1.75 COL 13 COLON-ALIGNED WIDGET-ID 54
     rtToolBar AT ROW 4.38 COL 1.14
     RECT-1 AT ROW 1.08 COL 1.14 WIDGET-ID 30
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 79.14 BY 12.46
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
         HEIGHT             = 4.92
         WIDTH              = 27.14
         MAX-HEIGHT         = 18.71
         MAX-WIDTH          = 101
         VIRTUAL-HEIGHT     = 18.71
         VIRTUAL-WIDTH      = 101
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
/* SETTINGS FOR BUTTON btCancela IN FRAME fpage0
   NO-ENABLE                                                            */
ASSIGN 
       btCancela:HIDDEN IN FRAME fpage0           = TRUE.

/* SETTINGS FOR FILL-IN i-pedido IN FRAME fpage0
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


&Scoped-define SELF-NAME btCancela
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancela wWindow
ON CHOOSE OF btCancela IN FRAME fpage0 /* Cancela */
DO:
   APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    IF  INPUT FRAME fPage0 i-sit-ped <> 1 
    AND INPUT FRAME fPage0 i-sit-ped <> 3 THEN DO:
        MESSAGE "Situa‡Æo somente pode ser alterada para 1 (Pendente) ou 3 (Cancelado)"
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        APPLY "ENTRY" TO i-sit-ped IN FRAME fPage0.
        RETURN NO-APPLY.
    END.

    DO TRANS:
       FOR FIRST b-int_ds_pedido WHERE
                 b-int_ds_pedido.ped_codigo_n = p-pedido:
       END.
       IF AVAIL b-int_ds_pedido THEN DO:
          IF  b-int_ds_pedido.situacao = 1 
          AND INPUT FRAME fPage0 i-sit-ped = 3 THEN DO:
             RUN utp/ut-msgs.p (INPUT "Show",                                                  
                                INPUT 27100,                                                   
                                INPUT "Confirma a altera‡Æo?" + "~~" +   
                                      "O Pedido ser  alterado para Cancelado (Situa‡Æo = 3).").
              IF RETURN-VALUE = "NO" THEN DO:                                                  
                 APPLY "ENTRY" TO i-sit-ped IN FRAME fPage0.
                 RETURN NO-APPLY.
             END. 
             ASSIGN b-int_ds_pedido.situacao = 3.
          END.
          IF  b-int_ds_pedido.situacao = 3 
          AND INPUT FRAME fPage0 i-sit-ped = 1 THEN DO:
             RUN utp/ut-msgs.p (INPUT "Show",                                                  
                                INPUT 27100,                                                   
                                INPUT "Confirma a altera‡Æo?" + "~~" +   
                                      "O Pedido ser  alterado para Pendente (Situa‡Æo = 1).").
              IF RETURN-VALUE = "NO" THEN DO:                                                  
                 APPLY "ENTRY" TO i-sit-ped IN FRAME fPage0.
                 RETURN NO-APPLY.
             END. 
             ASSIGN b-int_ds_pedido.situacao = INPUT FRAME fPage0 i-sit-ped.
             RELEASE b-int_ds_pedido.
          END.
       END.
    END.

    APPLY "CLOSE" TO THIS-PROCEDURE.

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

    assign i-pedido:screen-value in frame fPage0 = string(p-pedido).
    DISABLE i-pedido WITH FRAME fPage0.
    ASSIGN i-sit-ped = 0.
    FOR FIRST b-int_ds_pedido WHERE
              b-int_ds_pedido.ped_codigo_n = p-pedido:
    END.
    IF AVAIL b-int_ds_pedido THEN DO:
       ASSIGN i-sit-ped = b-int_ds_pedido.situacao.
    END.
    DISPLAY i-sit-ped WITH FRAME fPage0.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

