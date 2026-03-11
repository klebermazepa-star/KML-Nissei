&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*:T*******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i EQ0513A 2.00.00.013 } /*** 010013 ***/

/* Chamada a include do gerenciador de licenáas. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i EQ0513A MEQ}
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        EQ0513A
&GLOBAL-DEFINE Version        2.00.00.013

&GLOBAL-DEFINE WindowType     Detail

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    0
&GLOBAL-DEFINE FolderLabels   

&GLOBAL-DEFINE page0Widgets   btOK btCancel btHelp2 ~
                              fi-cliente fi-entrega fi-seq fi-serie
&GLOBAL-DEFINE page1Widgets   
&GLOBAL-DEFINE page2Widgets   

/* Temp-table Definitions ---                                           */
{dibo/bodi102.i tt-loc-entr}
{dibo/bodi784.i tt-estab-rota-entreg}

DEFINE TEMP-TABLE tt-sequencia NO-UNDO
    FIELD nr-sequencia AS INTEGER 
    FIELD r-rowid      AS ROWID.

/* Parameters Definitions ---                                           */
DEFINE INPUT        PARAMETER p-rowid   AS ROWID     NO-UNDO.
DEFINE INPUT        PARAMETER p-estabel AS CHARACTER NO-UNDO.
DEFINE INPUT        PARAMETER p-rota    AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt-loc-entr.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt-estab-rota-entreg.
DEFINE OUTPUT       PARAMETER p-ok      AS LOGICAL   NO-UNDO.

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE wh-pesquisa                      AS HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.

DEFINE VARIABLE r-rowid-target AS ROWID     NO-UNDO.
DEFINE VARIABLE i-seq          AS INTEGER   NO-UNDO.
DEFINE VARIABLE i-ult          AS INTEGER   NO-UNDO.
DEFINE VARIABLE i-cont         AS INTEGER   NO-UNDO.
DEFINE VARIABLE cAux           AS CHARACTER NO-UNDO.
DEFINE VARIABLE cAux2          AS CHARACTER NO-UNDO.

DEFINE BUFFER bf-tt-estab-rota-entreg FOR tt-estab-rota-entreg.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar fi-cliente fi-entrega fi-seq ~
fi-serie btOK btCancel btHelp2 
&Scoped-Define DISPLAYED-OBJECTS fi-cliente fi-entrega fi-seq fi-serie 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp2 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE fi-cliente AS CHARACTER FORMAT "X(12)":U 
     LABEL "Cliente" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE fi-entrega AS CHARACTER FORMAT "X(12)":U 
     LABEL "Entrega" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE fi-seq AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Sequància" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE fi-serie AS CHARACTER FORMAT "X(5)":U 
     LABEL "SÇrie" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 40 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     fi-cliente AT ROW 1.38 COL 15 COLON-ALIGNED HELP
          "Nome Abreviado do Cliente"
     fi-entrega AT ROW 2.38 COL 15 COLON-ALIGNED HELP
          "Local de Entrega"
     fi-seq AT ROW 3.38 COL 15 COLON-ALIGNED HELP
          "Sequància da Entrega"
     fi-serie AT ROW 4.38 COL 15 COLON-ALIGNED WIDGET-ID 2
     btOK AT ROW 5.71 COL 2
     btCancel AT ROW 5.71 COL 13
     btHelp2 AT ROW 5.71 COL 30
     rtToolBar AT ROW 5.5 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 40.43 BY 6
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
         TITLE              = ""
         HEIGHT             = 6
         WIDTH              = 40.29
         MAX-HEIGHT         = 17
         MAX-WIDTH          = 92.43
         VIRTUAL-HEIGHT     = 17
         VIRTUAL-WIDTH      = 92.43
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
  ASSIGN p-ok = NO.
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    ASSIGN p-ok = NO.
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp2 wWindow
ON CHOOSE OF btHelp2 IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    RUN pi-validarCampos.
    IF RETURN-VALUE = "OK" THEN DO:
        RUN pi-salvarTT.
        ASSIGN p-ok = YES.
        APPLY "CLOSE":U TO THIS-PROCEDURE.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-cliente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-cliente wWindow
ON F5 OF fi-cliente IN FRAME fpage0 /* Cliente */
DO:
    assign l-implanta = no.
    {include/zoomvar.i &prog-zoom="adzoom/z02ad098.w"
                       &campo=fi-cliente
                       &campozoom=nome-abrev}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-cliente wWindow
ON LEAVE OF fi-cliente IN FRAME fpage0 /* Cliente */
DO:
    FIND FIRST emitente NO-LOCK 
         WHERE emitente.cod-emitente = INT(INPUT FRAME fPage0 fi-cliente) NO-ERROR.

    IF AVAIL emitente THEN
        ASSIGN fi-cliente:SCREEN-VALUE IN FRAME fPage0 = emitente.nome-abrev.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-cliente wWindow
ON MOUSE-SELECT-DBLCLICK OF fi-cliente IN FRAME fpage0 /* Cliente */
DO:
    APPLY "F5":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-entrega
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-entrega wWindow
ON F5 OF fi-entrega IN FRAME fpage0 /* Entrega */
DO:
    {include/zoomvar.i &prog-zoom="dizoom/z01di102.w"
                       &campo=fi-entrega
                       &campozoom=cod-entrega
                       &parametros="run pi-seta-inicial in wh-pesquisa (input frame {&frame-name} fi-cliente)."}   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-entrega wWindow
ON MOUSE-SELECT-DBLCLICK OF fi-entrega IN FRAME fpage0 /* Entrega */
DO:
    APPLY "F5":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-serie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-serie wWindow
ON F5 OF fi-serie IN FRAME fpage0 /* SÇrie */
DO:
    assign l-implanta = no.
    {include/zoomvar.i &prog-zoom="inzoom/z03in407.w"
                       &campo=fi-serie
                       &campozoom=serie}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-serie wWindow
ON MOUSE-SELECT-DBLCLICK OF fi-serie IN FRAME fpage0 /* SÇrie */
DO:
   APPLY "F5":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializaá∆o do programam ---*/
IF fi-cliente:LOAD-MOUSE-POINTER ("image/lupa.cur") THEN.
IF fi-entrega:LOAD-MOUSE-POINTER ("image/lupa.cur") THEN.
IF fi-serie:LOAD-MOUSE-POINTER ("image/lupa.cur") THEN.

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
    FIND FIRST tt-estab-rota-entreg
         WHERE tt-estab-rota-entreg.r-rowid = p-rowid NO-LOCK NO-ERROR.

    IF AVAIL tt-estab-rota-entreg THEN DO:
        ASSIGN fi-cliente:SCREEN-VALUE IN FRAME {&FRAME-NAME} = tt-estab-rota-entreg.nome-abrev
               fi-entrega:SCREEN-VALUE IN FRAME {&FRAME-NAME} = tt-estab-rota-entreg.cod-entrega
               fi-seq:SCREEN-VALUE     IN FRAME {&FRAME-NAME} = STRING(tt-estab-rota-entreg.nr-sequencia,">>9")
               fi-serie:SCREEN-VALUE   IN FRAME {&FRAME-NAME} = SUBSTR(tt-estab-rota-entreg.cod-livre-2,1,5).

        DISABLE fi-cliente fi-entrega fi-seq
            WITH FRAME {&FRAME-NAME}.
        APPLY "ENTRY" TO fi-serie IN FRAME {&FRAME-NAME}.

    END.
    ELSE DO:
        FOR LAST bf-tt-estab-rota-entreg NO-LOCK
              BY bf-tt-estab-rota-entreg.cod-estabel 
              BY bf-tt-estab-rota-entreg.cod-rota    
              BY bf-tt-estab-rota-entreg.nr-sequencia:
            ASSIGN fi-seq = bf-tt-estab-rota-entreg.nr-sequencia + 1.
        END.

        ENABLE fi-cliente fi-entrega
            WITH FRAME {&FRAME-NAME}.

        DISPLAY fi-seq
            WITH FRAME {&FRAME-NAME}.
    END.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-salvarTT wWindow 
PROCEDURE pi-salvarTT :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF AVAIL tt-estab-rota-entreg AND (tt-estab-rota-entreg.nr-sequencia = INPUT FRAME {&FRAME-NAME} fi-seq) THEN DO:
       ASSIGN tt-estab-rota-entreg.cod-livre-2 = INPUT FRAME {&FRAME-NAME} fi-serie.
       RETURN.
    END.

    /* Busca £ltima sequància */
    ASSIGN i-ult = 0.
    FOR LAST bf-tt-estab-rota-entreg NO-LOCK
          BY bf-tt-estab-rota-entreg.cod-estabel 
          BY bf-tt-estab-rota-entreg.cod-rota    
          BY bf-tt-estab-rota-entreg.nr-sequencia:
        ASSIGN i-ult = bf-tt-estab-rota-entreg.nr-sequencia.
    END.

    /* Modifica */
    IF AVAIL tt-estab-rota-entreg THEN DO:
        IF i-ult < INPUT FRAME {&FRAME-NAME} fi-seq THEN
            ASSIGN tt-estab-rota-entreg.nr-sequencia = i-ult.
        ELSE
            ASSIGN tt-estab-rota-entreg.nr-sequencia = INPUT FRAME {&FRAME-NAME} fi-seq.

        ASSIGN tt-estab-rota-entreg.cod-livre-2 = INPUT FRAME {&FRAME-NAME} fi-serie.
    END.
    /* Novo */
    ELSE DO:
        FIND FIRST tt-loc-entr
             WHERE tt-loc-entr.cod-rota    = p-rota   
               AND tt-loc-entr.nome-abrev  = INPUT FRAME {&FRAME-NAME} fi-cliente             
               AND tt-loc-entr.cod-entrega = INPUT FRAME {&FRAME-NAME} fi-entrega EXCLUSIVE-LOCK NO-ERROR.

        IF AVAIL tt-loc-entr THEN
            DELETE tt-loc-entr.

        CREATE tt-estab-rota-entreg.
        ASSIGN tt-estab-rota-entreg.r-rowid      = ROWID(tt-estab-rota-entreg)
               tt-estab-rota-entreg.cod-estabel  = p-estabel
               tt-estab-rota-entreg.cod-rota     = p-rota
               tt-estab-rota-entreg.nome-abrev   = INPUT FRAME {&FRAME-NAME} fi-cliente
               tt-estab-rota-entreg.cod-entrega  = INPUT FRAME {&FRAME-NAME} fi-entrega
               tt-estab-rota-entreg.cod-livre-2  = INPUT FRAME {&FRAME-NAME} fi-serie.

        /* Caso sequància informada seja MAIOR que a £ltima sequància,
           altera sequància informada para a pr¢xima sequància.*/
        IF i-ult < INPUT FRAME {&FRAME-NAME} fi-seq THEN
            ASSIGN tt-estab-rota-entreg.nr-sequencia = i-ult + 1.
        ELSE
            ASSIGN tt-estab-rota-entreg.nr-sequencia = INPUT FRAME {&FRAME-NAME} fi-seq.
    END.

    /* L¢gica abaixo ajusta as sequàncias. */
    IF AVAIL tt-estab-rota-entreg THEN DO:
        ASSIGN r-rowid-target = tt-estab-rota-entreg.r-rowid
               i-seq          = tt-estab-rota-entreg.nr-sequencia
               i-cont         = 0.

        /* Re-ordena Sequàncias SEM o registro alterado. */
        FOR EACH bf-tt-estab-rota-entreg NO-LOCK
              BY bf-tt-estab-rota-entreg.cod-estabel 
              BY bf-tt-estab-rota-entreg.cod-rota    
              BY bf-tt-estab-rota-entreg.nr-sequencia:

            /* Ignora registro alterado. */
            IF bf-tt-estab-rota-entreg.nr-sequencia = i-seq AND
               bf-tt-estab-rota-entreg.r-rowid      = r-rowid-target THEN
                NEXT.

            ASSIGN i-cont                               = i-cont + 1
                   bf-tt-estab-rota-entreg.nr-sequencia = i-cont.
        END.

        /* Re-ordena Sequàncias, caso a sequància informada seja menor ou igual que a £ltima sequància.  
           Neste caso existir† 2 sequàncias de mesmo valor, a l¢gica abaixo serve para ajustar. */
        IF i-ult >= INPUT FRAME {&FRAME-NAME} fi-seq THEN DO:
            
            EMPTY TEMP-TABLE tt-sequencia.

            ASSIGN i-cont = 0.        
            FOR EACH bf-tt-estab-rota-entreg NO-LOCK
                  BY bf-tt-estab-rota-entreg.cod-estabel 
                  BY bf-tt-estab-rota-entreg.cod-rota    
                  BY bf-tt-estab-rota-entreg.nr-sequencia:
    
                /* Ignora registro alterado. */
                IF bf-tt-estab-rota-entreg.nr-sequencia = i-seq AND
                   bf-tt-estab-rota-entreg.r-rowid      = r-rowid-target THEN
                    NEXT.
    
                /* Se a sequància corrente for igual ou maior que a sequància alterada (n∆o considera o registro alterado
                  (existe uma sequància igual a sequància informada)), soma +1 as demais sequàncias. */
                IF bf-tt-estab-rota-entreg.nr-sequencia >= i-seq THEN DO:
                    CREATE tt-sequencia.
                    ASSIGN tt-sequencia.r-rowid      = bf-tt-estab-rota-entreg.r-rowid
                           tt-sequencia.nr-sequencia = bf-tt-estab-rota-entreg.nr-sequencia + 1.
                END.           
            END.

            /* Efetiva grav∆o das novas sequàncias. */
            FOR EACH tt-sequencia:
                FIND FIRST bf-tt-estab-rota-entreg NO-LOCK
                     WHERE bf-tt-estab-rota-entreg.r-rowid = tt-sequencia.r-rowid NO-ERROR.
    
                IF AVAIL bf-tt-estab-rota-entreg THEN
                    ASSIGN bf-tt-estab-rota-entreg.nr-sequencia = tt-sequencia.nr-sequencia.
            END.
        END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-validarCampos wWindow 
PROCEDURE pi-validarCampos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF INPUT FRAME {&FRAME-NAME} fi-cliente = "" THEN DO:
        {utp/ut-liter.i "Cliente"}
        RUN utp/ut-msgs.p (INPUT "SHOW",
                           INPUT 5793,
                           INPUT RETURN-VALUE).
        RETURN "NOK":U.
    END.
    ELSE DO:
        FOR FIRST emitente NO-LOCK
            WHERE emitente.nome-abrev = INPUT FRAME {&FRAME-NAME} fi-cliente:
        END.

        IF NOT AVAIL emitente THEN DO:
            RUN utp/ut-msgs.p (INPUT "SHOW",
                               INPUT 895,
                               INPUT RETURN-VALUE).
            RETURN "NOK":U.
        END.
        ELSE DO:
            IF emitente.identific = 2 THEN DO:
                RUN utp/ut-msgs.p (INPUT "SHOW",
                                   INPUT 26241,
                                   INPUT RETURN-VALUE).
                RETURN "NOK":U.
            END.
        END.
    END.

    IF INPUT FRAME {&FRAME-NAME} fi-entrega = "" THEN DO:
        {utp/ut-liter.i "Entrega"}
        RUN utp/ut-msgs.p (INPUT "SHOW",
                           INPUT 5793,
                           INPUT RETURN-VALUE).
        RETURN "NOK":U.
    END.
    ELSE DO:
        IF NOT CAN-FIND (FIRST loc-entr 
                         WHERE loc-entr.nome-abrev  = INPUT FRAME {&FRAME-NAME} fi-cliente
                           AND loc-entr.cod-entrega = INPUT FRAME {&FRAME-NAME} fi-entrega) THEN DO:
            {utp/ut-liter.i "Local de Entrega"}
            ASSIGN cAux = RETURN-VALUE.
            {utp/ut-liter.i "Cliente"}
            ASSIGN cAux2 = RETURN-VALUE.

            RUN utp/ut-msgs.p (INPUT "SHOW",
                               INPUT 29181,
                               INPUT cAux + "~~" + 
                                     cAux2 + "~~" + 
                                     INPUT FRAME {&FRAME-NAME} fi-entrega + "~~" +
                                     INPUT FRAME {&FRAME-NAME} fi-cliente).
            RETURN "NOK":U.
        END.
    END.

    IF INT(INPUT FRAME {&FRAME-NAME} fi-seq) = 0 THEN DO:
        {utp/ut-liter.i "Sequància"}
        RUN utp/ut-msgs.p (INPUT "SHOW",
                           INPUT 7966,
                           INPUT RETURN-VALUE).
        RETURN "NOK":U.
    END.

    FIND FIRST serie WHERE 
               serie.serie = INPUT FRAME {&FRAME-NAME} fi-serie NO-LOCK NO-ERROR.
    IF NOT AVAIL serie THEN DO:
       RUN utp/ut-msgs.p (INPUT "SHOW",
                          INPUT 2,
                          INPUT "SÇrie").
       APPLY "entry" TO fi-serie IN FRAME {&FRAME-NAME}.
       RETURN "no-apply":U.
    END.

    IF p-rowid = ? AND 
        CAN-FIND(FIRST tt-estab-rota-entreg
                 WHERE tt-estab-rota-entreg.nome-abrev  = INPUT FRAME {&FRAME-NAME} fi-cliente
                   AND tt-estab-rota-entreg.cod-entrega = INPUT FRAME {&FRAME-NAME} fi-entrega) THEN DO:
        {utp/ut-liter.i "Cliente/Entrega"}
        ASSIGN cAux = RETURN-VALUE.
        {utp/ut-liter.i "Rota"}
        ASSIGN cAux2 = RETURN-VALUE.

        RUN utp/ut-msgs.p (INPUT "SHOW",
                           INPUT 428,
                           INPUT cAux + "~~" + cAux2).
        RETURN "NOK":U.
    END.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

