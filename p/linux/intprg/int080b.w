&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
/***********************************************************************************
**
** Programa: int080b - Altera‡Æo dos campos ped-cnpj-destino-s e ped-placaveiculo-s
**
***********************************************************************************/
{include/i-prgvrs.i INT080B 2.00.00.000}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT080B
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Itens

&GLOBAL-DEFINE page0Widgets   btOK  

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAM p-nr-pedido    AS INT  NO-UNDO.
DEFINE INPUT PARAM p-cod-emitente AS INT  NO-UNDO.
DEFINE INPUT PARAM p-placa        AS CHAR NO-UNDO.

/* Local Variable Definitions ---                                       */

def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def var raw-param          as raw no-undo.

def var h-acomp as handle no-undo.
DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.
DEFINE VARIABLE wh-pesquisa                      AS HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 i-nr-pedido i-cod-emitente ~
c-placa btOK btCancela 
&Scoped-Define DISPLAYED-OBJECTS i-nr-pedido i-cod-emitente c-nome-emit ~
c-placa 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancela 
     LABEL "Cancela" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-nome-emit AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 42 BY .88 NO-UNDO.

DEFINE VARIABLE c-placa AS CHARACTER FORMAT "X(10)":U 
     LABEL "Placa" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE i-cod-emitente AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Fornecedor" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE i-nr-pedido AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Nr. Pedido" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 70.29 BY 4.04.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 70.29 BY 1.54.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     i-nr-pedido AT ROW 1.75 COL 12.43 COLON-ALIGNED WIDGET-ID 2
     i-cod-emitente AT ROW 2.75 COL 12.43 COLON-ALIGNED WIDGET-ID 36
     c-nome-emit AT ROW 2.75 COL 22.72 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     c-placa AT ROW 3.75 COL 12.43 COLON-ALIGNED WIDGET-ID 40
     btOK AT ROW 5.54 COL 3
     btCancela AT ROW 5.54 COL 13.43 WIDGET-ID 42
     RECT-1 AT ROW 1.17 COL 1.57 WIDGET-ID 4
     RECT-2 AT ROW 5.29 COL 1.57 WIDGET-ID 34
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.14 ROW 1
         SIZE 74.43 BY 7.75
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 5.96
         WIDTH              = 71.57
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
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN c-nome-emit IN FRAME fpage0
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
    FOR FIRST emitente WHERE
              emitente.cod-emitente = INPUT FRAME fPage0 i-cod-emitente NO-LOCK:
    END.
    IF NOT AVAIL emitente THEN DO:
        run utp/ut-msgs.p (input "show",
                           input 2,
                           input "Fornecedor").
        apply "entry" to i-cod-emitente in frame fPage0.
        return "NO-APPLY".
    END.

    FOR FIRST int-ds-pedido WHERE
              int-ds-pedido.ped-codigo-n = INPUT FRAME fPage0 i-nr-pedido:
    END.
    IF AVAIL int-ds-pedido THEN DO:
       ASSIGN int-ds-pedido.ped-cnpj-destino-s = emitente.cgc
              int-ds-pedido.ped-placaveiculo-s = INPUT FRAME fPage0 c-placa.
    END.
    RELEASE int-ds-pedido.

    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-cod-emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emitente wWindow
ON F5 OF i-cod-emitente IN FRAME fpage0 /* Fornecedor */
DO:
    {include/zoomvar.i &prog-zoom=adzoom/z01ad098.w
                       &campo=i-cod-emitente
                       &campozoom=cod-emitente
                       &campo2=c-nome-emit
                       &campozoom2=nome-emit
                       &frame=fPage0}                      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emitente wWindow
ON LEAVE OF i-cod-emitente IN FRAME fpage0 /* Fornecedor */
DO:
  ASSIGN c-nome-emit = "".
  FIND FIRST emitente WHERE
             emitente.cod-emitente = INPUT frame fPage0 i-cod-emitente NO-LOCK NO-ERROR.
  IF AVAIL emitente THEN
     ASSIGN c-nome-emit = emitente.nome-emit.
  DISP c-nome-emit WITH frame fPage0.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emitente wWindow
ON MOUSE-SELECT-DBLCLICK OF i-cod-emitente IN FRAME fpage0 /* Fornecedor */
DO:
  apply "F5" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*--- L¢gica para inicializa‡Æo do programam ---*/

IF i-cod-emitente:load-mouse-pointer ("image~\lupa.cur":U) in frame fPage0 then.

{window/MainBlock.i}

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

   DISPLAY p-nr-pedido    @ i-nr-pedido 
           p-cod-emitente @ i-cod-emitente 
           p-placa        @ c-placa WITH FRAME fPage0.
   FOR FIRST emitente WHERE
             emitente.cod-emitente = p-cod-emitente NO-LOCK:
   END.
   ASSIGN c-nome-emit = "".
   IF AVAIL emitente THEN 
      ASSIGN c-nome-emit = emitente.nome-emit.

   DISP c-nome-emit WITH FRAME fPage0.

   ASSIGN i-cod-emitente:SENSITIVE IN FRAME fPage0 = YES
          c-placa:SENSITIVE IN FRAME fPage0 = YES.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

