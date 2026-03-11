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
                              d-dt_ocorrencia-fim d-dt_ocorrencia-ini ~
                              d-dt_movto-fim d-dt_movto-ini ~
                              c-chave ~
                              rsSituacao ~
                              tgNotasemFornec ~
                              c-cod-usuario fi-nome-usuario ~
                              btHelp btOK btCancel 

/* Parameters Definitions ---                                           */
DEFINE INPUT-OUTPUT PARAM p-origem-ini LIKE int_ds_log.origem NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-origem-fim LIKE int_ds_log.origem NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-dt_ocorrencia-ini LIKE int_ds_log.dt_ocorrencia NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-dt_ocorrencia-fim LIKE int_ds_log.dt_ocorrencia NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-dt_movto-ini LIKE int_ds_log.dt_movto NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-dt_movto-fim LIKE int_ds_log.dt_movto NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-chave   LIKE int_ds_log.chave NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-usuario LIKE usuar_mestre.cod_usuario NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-nota-semFornec AS LOGICAL NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-situacao        as integer                   NO-UNDO.
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
&Scoped-Define ENABLED-OBJECTS tgNotasemFornec c-cod-usuario c-origem-ini ~
d-dt_ocorrencia-ini d-dt_ocorrencia-fim d-dt_movto-ini d-dt_movto-fim btOK ~
btCancel btHelp rsSituacao c-origem-fim c-chave IMAGE-1 IMAGE-2 IMAGE-5 ~
IMAGE-6 rtToolBar IMAGE-7 IMAGE-8 RECT-1 
&Scoped-Define DISPLAYED-OBJECTS tgNotasemFornec c-cod-usuario ~
fi-nome-usuario c-origem-ini d-dt_ocorrencia-ini d-dt_ocorrencia-fim ~
d-dt_movto-ini d-dt_movto-fim rsSituacao c-origem-fim c-chave 

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

DEFINE VARIABLE c-origem-fim AS CHARACTER FORMAT "X(256)":U INITIAL "ZZZZZZZZ" 
     VIEW-AS COMBO-BOX INNER-LINES 20
     LIST-ITEMS "ZZZZZZZZ" 
     DROP-DOWN-LIST
     SIZE 13.43 BY 1 NO-UNDO.

DEFINE VARIABLE c-origem-ini AS CHARACTER FORMAT "X(256)":U 
     LABEL "Origem" 
     VIEW-AS COMBO-BOX INNER-LINES 20
     DROP-DOWN-LIST
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE c-chave AS CHARACTER FORMAT "x(50)" 
     LABEL "Chave" 
     VIEW-AS FILL-IN 
     SIZE 39 BY .79.

DEFINE VARIABLE c-cod-usuario AS CHARACTER FORMAT "X(256)":U 
     LABEL "Usu†rio" 
     VIEW-AS FILL-IN 
     SIZE 10.29 BY .79 NO-UNDO.

DEFINE VARIABLE d-dt_movto-fim AS DATE FORMAT "99/99/9999" INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE d-dt_movto-ini AS DATE FORMAT "99/99/9999" INITIAL 01/01/00 
     LABEL "Dt Movimento":R15 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE d-dt_ocorrencia-fim AS DATE FORMAT "99/99/9999" INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE d-dt_ocorrencia-ini AS DATE FORMAT "99/99/9999" INITIAL 01/01/00 
     LABEL "Dt Ocorrància":R15 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE fi-nome-usuario AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 30.86 BY .79 NO-UNDO.

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
"Atualizados", 2,
"Todos", 0
     SIZE 30.57 BY .54 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 78 BY 8.71.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 78 BY 1.42
     BGCOLOR 7 .

DEFINE VARIABLE tgNotasemFornec AS LOGICAL INITIAL no 
     LABEL "Listar notas sem fornecedor cadastrado" 
     VIEW-AS TOGGLE-BOX
     SIZE 33 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     tgNotasemFornec AT ROW 7 COL 22 WIDGET-ID 42
     c-cod-usuario AT ROW 8.04 COL 19.86 COLON-ALIGNED WIDGET-ID 38
     fi-nome-usuario AT ROW 8.04 COL 30.29 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     c-origem-ini AT ROW 1.75 COL 20 COLON-ALIGNED WIDGET-ID 18
     d-dt_ocorrencia-ini AT ROW 2.75 COL 20 COLON-ALIGNED HELP
          "Data da Integraá∆o"
     d-dt_ocorrencia-fim AT ROW 2.75 COL 46.57 COLON-ALIGNED HELP
          "Data da Integraá∆o" NO-LABEL
     d-dt_movto-ini AT ROW 3.75 COL 20 COLON-ALIGNED HELP
          "Data de Emiss∆o" WIDGET-ID 24
     d-dt_movto-fim AT ROW 3.75 COL 46.57 COLON-ALIGNED HELP
          "Data de Emiss∆o" NO-LABEL WIDGET-ID 22
     btOK AT ROW 10.08 COL 2
     btCancel AT ROW 10.08 COL 13
     btHelp AT ROW 10.08 COL 68.29
     rsSituacao AT ROW 6.25 COL 23 NO-LABEL WIDGET-ID 8
     c-origem-fim AT ROW 1.75 COL 46.57 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     c-chave AT ROW 5 COL 20 COLON-ALIGNED WIDGET-ID 36
     "Situaá∆o:" VIEW-AS TEXT
          SIZE 6.86 BY .54 AT ROW 6.25 COL 15 WIDGET-ID 14
     IMAGE-1 AT ROW 1.75 COL 36
     IMAGE-2 AT ROW 1.75 COL 44.72
     IMAGE-5 AT ROW 2.75 COL 36
     IMAGE-6 AT ROW 2.75 COL 44.72
     rtToolBar AT ROW 9.83 COL 1
     IMAGE-7 AT ROW 3.75 COL 36 WIDGET-ID 26
     IMAGE-8 AT ROW 3.75 COL 44.72 WIDGET-ID 28
     RECT-1 AT ROW 1.04 COL 1 WIDGET-ID 30
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 79.14 BY 10.29
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
         HEIGHT             = 10.46
         WIDTH              = 78.14
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
/* SETTINGS FOR FILL-IN fi-nome-usuario IN FRAME fpage0
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


    IF TRIM(INPUT FRAME fPage0 c-cod-usuario) = "" OR 
       TRIM(INPUT FRAME fPage0 c-cod-usuario) = "*" THEN DO:
        RUN utp/ut-msgs.p (input "show":U, 
                           input 27702, 
                           input "Usu†rio n∆o informado~~ Deseja continuar sem informar o usu†rio assim todas as mensagens ser∆o carregadas, independente de usu†rio?").
        IF RETURN-VALUE = "YES" THEN DO: 
            assign frame fPage0
                    c-origem-ini 
                    c-origem-fim 
                    d-dt_ocorrencia-ini
                    d-dt_ocorrencia-fim
                    d-dt_movto-ini
                    d-dt_movto-fim
                    c-chave
                    rsSituacao
                    tgNotasemFornec
                    c-cod-usuario.

            assign  p-origem-ini        = c-origem-ini 
                    p-origem-fim        = c-origem-fim 
                    p-dt_ocorrencia-ini = d-dt_ocorrencia-ini  
                    p-dt_ocorrencia-fim = d-dt_ocorrencia-fim  
                    p-dt_movto-ini      = d-dt_movto-ini  
                    p-dt_movto-fim      = d-dt_movto-fim  
                    p-chave             = c-chave
                    p-situacao          = rsSituacao
                    p-nota-semFornec    = tgNotasemFornec
                    p-usuario           = c-cod-usuario.

            assign p-l-open-query = yes.

            APPLY "CLOSE":U TO THIS-PROCEDURE. 
        END.
    END.
    ELSE DO:

        assign frame fPage0
                c-origem-ini 
                c-origem-fim 
                d-dt_ocorrencia-ini
                d-dt_ocorrencia-fim
                d-dt_movto-ini
                d-dt_movto-fim
                c-chave
                rsSituacao
                tgNotasemFornec
                c-cod-usuario.
    
        assign  p-origem-ini        = c-origem-ini 
                p-origem-fim        = c-origem-fim 
                p-dt_ocorrencia-ini = d-dt_ocorrencia-ini  
                p-dt_ocorrencia-fim = d-dt_ocorrencia-fim  
                p-dt_movto-ini      = d-dt_movto-ini  
                p-dt_movto-fim      = d-dt_movto-fim  
                p-chave             = c-chave
                p-situacao          = rsSituacao
                p-nota-semFornec    = tgNotasemFornec
                p-usuario           = c-cod-usuario.
    
        assign p-l-open-query = yes.
    
        APPLY "CLOSE":U TO THIS-PROCEDURE. 
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-cod-usuario
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-usuario wWindow
ON LEAVE OF c-cod-usuario IN FRAME fpage0 /* Usu†rio */
DO:
  IF TRIM(INPUT FRAME fPage0 c-cod-usuario) <> "" THEN DO:
      FIND FIRST usuar_mestre
           WHERE usuar_mestre.cod_usuario = INPUT FRAME fPage0 c-cod-usuario NO-ERROR.
      IF AVAIL usuar_mestre THEN DO:
           ASSIGN fi-nome-usuario:SCREEN-VALUE IN FRAME fPage0 = usuar_mestre.nom_usuario.
      END.
      ELSE DO:
          IF TRIM(INPUT FRAME fPage0 c-cod-usuario) <> "*" THEN
               ASSIGN fi-nome-usuario:SCREEN-VALUE IN FRAME fPage0 = "Todos os usu†rios".
          ELSE ASSIGN fi-nome-usuario:SCREEN-VALUE IN FRAME fPage0 = "Usu†rio N∆o encontrado".
      END.
  END.
  ELSE DO:
      ASSIGN fi-nome-usuario:SCREEN-VALUE IN FRAME fPage0 = "Usu†rio n∆o informado".
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-origem-fim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-origem-fim wWindow
ON VALUE-CHANGED OF c-origem-fim IN FRAME fpage0
DO:
    IF (INPUT c-origem-ini = "CUPOM" 
    OR INPUT c-origem-fim = "CUPOM")
    OR (INPUT c-origem-ini = "" AND c-origem-fim = "ZZZZZZZZ") THEN
       ENABLE d-dt_movto-ini
              d-dt_movto-fim
              WITH FRAME {&FRAME-NAME}.
    ELSE 
       DISABLE d-dt_movto-ini
               d-dt_movto-fim
               WITH FRAME {&FRAME-NAME}.

    IF  INPUT c-origem-ini = "" 
    AND INPUT c-origem-fim <> "CUPOM"
    AND INPUT c-origem-fim <> "ZZZZZZZZ" THEN
        DISABLE d-dt_movto-ini
                d-dt_movto-fim
                WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-origem-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-origem-ini wWindow
ON VALUE-CHANGED OF c-origem-ini IN FRAME fpage0 /* Origem */
DO:
  IF (INPUT c-origem-ini = "CUPOM" 
  OR INPUT c-origem-fim = "CUPOM")
  OR (INPUT c-origem-ini = "" AND c-origem-fim = "ZZZZZZZZ") THEN
     ENABLE d-dt_movto-ini
            d-dt_movto-fim
            WITH FRAME {&FRAME-NAME}.
  ELSE 
     DISABLE d-dt_movto-ini
             d-dt_movto-fim
             WITH FRAME {&FRAME-NAME}.
     
  IF  INPUT c-origem-ini = "" 
  AND INPUT c-origem-fim <> "CUPOM"
  AND INPUT c-origem-fim <> "ZZZZZZZZ" THEN
      DISABLE d-dt_movto-ini
              d-dt_movto-fim
              WITH FRAME {&FRAME-NAME}.
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

    assign  c-origem-ini :screen-value in frame fPage0 = p-origem-ini  
            c-origem-fim :screen-value in frame fPage0 = p-origem-fim 
            d-dt_ocorrencia-ini :screen-value in frame fPage0 = string(p-dt_ocorrencia-ini,"99/99/9999")
            d-dt_ocorrencia-fim :screen-value in frame fPage0 = string(p-dt_ocorrencia-fim,"99/99/9999")
            d-dt_movto-ini :screen-value in frame fPage0 = string(p-dt_movto-ini,"99/99/9999")
            d-dt_movto-fim :screen-value in frame fPage0 = string(p-dt_movto-fim,"99/99/9999")
            c-chave:screen-value in frame fPage0 = p-chave
            rsSituacao        :screen-value in frame fPage0 = string(p-situacao)
            tgNotasemFornec:SCREEN-VALUE IN FRAME fPage0 = string(p-nota-semFornec)
            c-cod-usuario:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(p-usuario).

    APPLY "value-changed":u TO c-origem-ini IN FRAME fPage0.
    APPLY "value-changed":u TO c-origem-fim IN FRAME fPage0.
    APPLY "LEAVE":U         TO c-cod-usuario IN FRAME fPage0.

    DISABLE fi-nome-usuario WITH FRAME fPage0.
        
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInitializeInterface wWindow 
PROCEDURE beforeInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

/*     assign  c-origem-ini:list-items in frame fPage0 = ",CLI,CUPOM,FFIXO,FISC,FLoja,FORN,FuroCX,ITEMFORN,NF Balanco,NFDCUP,NFE,NFENDD,PCOMPR,NF DEVOL,NF PED,PED,RETNFNDD,WMS"          */
/*             c-origem-FIM:list-items in frame fPage0 = "CLI,CUPOM,FFIXO,FISC,FLoja,FORN,FuroCX,ITEMFORN,NF Balanco,NFDCUP,NFE,NFENDD,PCOMPR,NF DEVOL,NF PED,PED,RETNFNDD,WMS,ZZZZZZZZ". */
/*             c-origem-FIM = "ZZZZZZZZ".                                                                                                                                        */

    assign  c-origem-ini:list-items in frame fPage0 = ",ABCFARMA,CLI,CUPOM,DEV PROC,FFIXO,FISC,FuroCX,ITEMFORN,NF Balan,NF CANC,NF PED,NF PROC,NF Retor,NFDCUP,NFE,NFENDD,PCOMPR,PED,RETNFE,RETNFNDD,WMS"
            c-origem-FIM:list-items in frame fPage0 = "ABCFARMA,CLI,CUPOM,DEV PROC,FFIXO,FISC,FuroCX,ITEMFORN,NF Balan,NF CANC,NF PED,NF PROC,NF Retor,NFDCUP,NFE,NFENDD,PCOMPR,PED,RETNFE,RETNFNDD,WMS,ZZZZZZZZ"
            c-origem-FIM = "ZZZZZZZZ".


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

