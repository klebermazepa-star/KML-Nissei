&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
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
{include/i-prgvrs.i INT050M 1.00.00.001KML}

/* Chamada a include do gerenciador de licen‡as. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i INT050M ESP}
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT050M
&GLOBAL-DEFINE Version        1.00.00.001KML

&GLOBAL-DEFINE WindowType     Master/Detail

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   <Rotas>

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK btCancel btHelp2 
&GLOBAL-DEFINE page1Widgets   br-rotas
&GLOBAL-DEFINE page2Widgets   

/* Parameters Definitions ---                                           */


DEFINE TEMP-TABLE tt-int_ds_pedido NO-UNDO LIKE int_ds_pedido
       field cod-rota as char
       field cod-estabel as char format "x(4)"
       field qtde-itens as int format ">>,>>9"
       field transport as char format "x(12)"
       field placa as char format "x(10)"
       field uf-placa as char format "x(4)"
       field serie as char format "x(5)"
       field nr-nota-fis as char format "x(16)"
       field sit-ped as char format "x(20)"
       field dt-ger-ped as date format "99/99/9999"
       field hr-ger-ped as char format "x(10)"
       field dt-ger-nota as date format "99/99/9999"
       field hr-ger-nota as char format "x(10)"
       field ordem       as int
       field ndd-envio as char
       field sit-nfe as char
       FIELD nota-origem AS CHAR
       FIELD nota-destino AS CHAR
       FIELD nome-ab-cli AS CHAR
       FIELD motorista AS CHAR
       FIELD qtd-notas   AS INT
       index situacao 
                serie 
                ordem 
                dt-ger-ped 
                hr-ger-ped 
                ped_codigo_n
       INDEX hora-gera 
                hr-ger-nota
       INDEX sit-ped
                situacao.

DEFINE TEMP-TABLE tt-rotas NO-UNDO
    FIELD cod-rota      AS CHAR
    FIELD placa         AS CHAR
    FIELD uf-placa      AS CHAR
    FIELD qtd-notas     AS INT
    FIELD motorista     AS CHAR
    FIELD cpf-condut    AS CHAR.

 
def var h-acomp as handle no-undo.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.



def input parameter table for tt-int_ds_pedido.

/* Local Variable Definitions ---                                       */


DEFINE VARIABLE i-num-mdfe AS INTEGER     NO-UNDO.
DEFINE VARIABLE i-num-seq-mdfe AS INTEGER     NO-UNDO.

DEFINE BUFFER bfmdfe-docto FOR mdfe-docto.
DEFINE BUFFER bfcidade FOR ems2dis.cidade.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME br-rotas

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-rotas

/* Definitions for BROWSE br-rotas                                      */
&Scoped-define FIELDS-IN-QUERY-br-rotas tt-rotas.cod-rota tt-rotas.qtd-notas tt-rotas.placa tt-rotas.motorista   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rotas tt-rotas.placa   
&Scoped-define ENABLED-TABLES-IN-QUERY-br-rotas tt-rotas
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-rotas tt-rotas
&Scoped-define SELF-NAME br-rotas
&Scoped-define QUERY-STRING-br-rotas FOR EACH tt-rotas  NO-LOCK
&Scoped-define OPEN-QUERY-br-rotas OPEN QUERY {&SELF-NAME} FOR EACH tt-rotas  NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-rotas tt-rotas
&Scoped-define FIRST-TABLE-IN-QUERY-br-rotas tt-rotas


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-br-rotas}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 rtToolBar btQueryJoins ~
btReportsJoins btExit btHelp btOK btCancel btHelp2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miQueryJoins   LABEL "&Consultas"    
       MENU-ITEM miReportsJoins LABEL "&Relat¢rios"   
       RULE
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp2 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE BUTTON btQueryJoins 
     IMAGE-UP FILE "image\im-joi":U
     IMAGE-INSENSITIVE FILE "image\ii-joi":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rotas FOR 
      tt-rotas SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rotas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rotas wWindow _FREEFORM
  QUERY br-rotas DISPLAY
      tt-rotas.cod-rota                    COLUMN-LABEL "Rota" 
       tt-rotas.qtd-notas                   COLUMN-LABEL "Qtd Notas"
       tt-rotas.placa       FORMAT "X(12)"  COLUMN-LABEL "Placa"
       tt-rotas.motorista   FORMAT "X(60)"  COLUMN-LABEL "Motorista"


ENABLE 
       tt-rotas.placa
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 81 BY 11.25
         FONT 1 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     btOK AT ROW 16.88 COL 2
     btCancel AT ROW 16.88 COL 13
     btHelp2 AT ROW 16.88 COL 80
     rtToolBar-2 AT ROW 1 COL 1
     rtToolBar AT ROW 16.75 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90.14 BY 17.21
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     br-rotas AT ROW 1.5 COL 3 WIDGET-ID 200
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 4
         SIZE 85.43 BY 12.25
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 4
         SIZE 85.43 BY 12.25
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 17.29
         WIDTH              = 90.72
         MAX-HEIGHT         = 17.29
         MAX-WIDTH          = 90.72
         VIRTUAL-HEIGHT     = 17.29
         VIRTUAL-WIDTH      = 90.72
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

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU mbMain:HANDLE.
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
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE
       FRAME fPage2:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB br-rotas 1 fPage1 */
/* SETTINGS FOR FRAME fPage2
   NOT-VISIBLE                                                          */
ASSIGN 
       FRAME fPage2:HIDDEN           = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rotas
/* Query rebuild information for BROWSE br-rotas
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-rotas  NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-rotas */
&ANALYZE-RESUME

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

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage2
/* Query rebuild information for FRAME fPage2
     _Query            is NOT OPENED
*/  /* FRAME fPage2 */
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
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
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

      RUN pi-inicializar IN h-acomp (INPUT 'Processando...').

      FOR EACH tt-int_ds_pedido
        BREAK BY tt-int_ds_pedido.cod-rota:

        IF FIRST-OF(tt-int_ds_pedido.cod-rota) THEN DO:


            RUN pi-acompanhar IN h-acomp (INPUT 'Processando Rota - ' + tt-int_ds_pedido.cod-rota ).


            FIND FIRST tt-rotas 
                WHERE tt-rotas.cod-rota = tt-int_ds_pedido.cod-rota NO-ERROR.

            ASSIGN i-num-mdfe  = 0
                   i-num-seq-mdfe = 0.
            FOR LAST bfmdfe-docto NO-LOCK 
                BY bfmdfe-docto.cod-num-mdfe:
             
                ASSIGN i-num-mdfe = INT(bfmdfe-docto.cod-num-mdfe).
            END.

            FIND FIRST estabelec NO-LOCK
                WHERE estabelec.cod-estabel = tt-int_ds_pedido.cod-estabel NO-ERROR.

            FIND FIRST emitente NO-LOCK
                WHERE emitente.nome-abrev = tt-int_ds_pedido.nome-ab-cli NO-ERROR.

            FIND FIRST mdfe-veic NO-LOCK
                WHERE mdfe-veic.cod-placa = tt-rotas.placa NO-ERROR.

            FIND FIRST ems2dis.cidade NO-LOCK
                WHERE cidade.pais = emitente.pais
                  AND cidade.estado = emitente.estado
                  AND cidade.cidade = emitente.cidade NO-ERROR.

            FIND FIRST bfcidade NO-LOCK
                WHERE bfcidade.pais = estabelec.pais
                  AND bfcidade.estado = estabelec.estado
                  AND bfcidade.cidade = estabelec.cidade NO-ERROR.
             
            
            CREATE mdfe-docto.
            ASSIGN mdfe-docto.cod-estab         = "973"
                   mdfe-docto.cod-ser-mdfe      = "100"  // FIXO s‚rie 100, porem deve-se migrar para um cadastro
                   mdfe-docto.cod-num-mdfe      = IF i-num-mdfe > 0 THEN string(i-num-mdfe + 1, "999999999") ELSE "000000001"
                   mdfe-docto.dat-emis-mdfe     = TODAY
                   mdfe-docto.hra-emis-mdfe     = REPLACE(STRING(TIME,"hh:mm:ss"),":","")
                   mdfe-docto.idi-ambien-mdfe   = 1 // Ambiente produ‡Æo
                   mdfe-docto.cod-uf-orig       = estabelec.estado
                   mdfe-docto.cod-uf-dest       = emitente.estado
                   mdfe-docto.ind-tip-emit      = "1"
                   mdfe-docto.cod-un-medid      = "KG"
                   mdfe-docto.idi-tip-emis-mdfe = 1
                   mdfe-docto.cod-mod-frete     = "1"
                   mdfe-docto.idi-sit-mdfe      = 7.

            CREATE mdfe-condut.
            ASSIGN mdfe-condut.cod-estab        = mdfe-docto.cod-estab     
                   mdfe-condut.cod-ser-mdfe     = mdfe-docto.cod-ser-mdfe  
                   mdfe-condut.cod-num-mdfe     = mdfe-docto.cod-num-mdfe  
                   mdfe-condut.dat-emis-mdfe    = mdfe-docto.dat-emis-mdfe 
                   mdfe-condut.cod-num-modal    = mdfe-docto.cod-num-modal
                   mdfe-condut.cod-condut       = "1"
                   mdfe-condut.nom-condut       = tt-rotas.motorista
                   mdfe-condut.cod-cpf          = tt-rotas.cpf-condut .

            CREATE mdfe-rodov.
            ASSIGN mdfe-rodov.cod-estab         = mdfe-docto.cod-estab      
                   mdfe-rodov.cod-ser-mdfe      = mdfe-docto.cod-ser-mdfe  
                   mdfe-rodov.cod-num-mdfe      = mdfe-docto.cod-num-mdfe  
                   mdfe-rodov.dat-emis-mdfe     = mdfe-docto.dat-emis-mdfe 
                   mdfe-rodov.cod-num-modal     = mdfe-docto.cod-num-modal 
                   mdfe-rodov.cod-veic          = mdfe-veic.cod-inter-veic .


            FOR EACH mdfe-munic-carreg EXCLUSIVE-LOCK
                WHERE mdfe-munic-carreg.cod-estab          = mdfe-docto.cod-estab         
                  AND mdfe-munic-carreg.cod-ser-mdfe       = mdfe-docto.cod-ser-mdfe   
                  AND mdfe-munic-carreg.cod-num-mdfe       = mdfe-docto.cod-num-mdfe   
                  AND mdfe-munic-carreg.dat-emis-mdfe      = mdfe-docto.dat-emis-mdfe :

                DELETE mdfe-munic-carreg.
            END.

            FOR EACH mdfe-munic-descarreg EXCLUSIVE-LOCK
                WHERE mdfe-munic-descarreg.cod-estab          = mdfe-docto.cod-estab         
                  AND mdfe-munic-descarreg.cod-ser-mdfe       = mdfe-docto.cod-ser-mdfe   
                  AND mdfe-munic-descarreg.cod-num-mdfe       = mdfe-docto.cod-num-mdfe   
                  AND mdfe-munic-descarreg.dat-emis-mdfe      = mdfe-docto.dat-emis-mdfe  :

                DELETE mdfe-munic-descarreg.
            END.

            CREATE mdfe-munic-carreg.
            ASSIGN mdfe-munic-carreg.cod-estab          = mdfe-docto.cod-estab         
                   mdfe-munic-carreg.cod-ser-mdfe       = mdfe-docto.cod-ser-mdfe   
                   mdfe-munic-carreg.cod-num-mdfe       = mdfe-docto.cod-num-mdfe   
                   mdfe-munic-carreg.dat-emis-mdfe      = mdfe-docto.dat-emis-mdfe  
                   mdfe-munic-carreg.num-seq            = 1
                   mdfe-munic-carreg.cod-munpio-ibge    = string(cidade.cdn-munpio-ibge)
                   mdfe-munic-carreg.nom-munpio         = cidade.cidade.

            CREATE mdfe-munic-descarreg.
            ASSIGN mdfe-munic-descarreg.cod-estab          = mdfe-docto.cod-estab         
                   mdfe-munic-descarreg.cod-ser-mdfe       = mdfe-docto.cod-ser-mdfe   
                   mdfe-munic-descarreg.cod-num-mdfe       = mdfe-docto.cod-num-mdfe   
                   mdfe-munic-descarreg.dat-emis-mdfe      = mdfe-docto.dat-emis-mdfe  
                   mdfe-munic-descarreg.num-seq            = 1
                   mdfe-munic-descarreg.cod-munpio-ibge    = string(bfcidade.cdn-munpio-ibge)
                   mdfe-munic-descarreg.nom-munpio         = bfcidade.cidade.




             
        END.

        ASSIGN i-num-seq-mdfe = i-num-seq-mdfe + 1. 

        IF tt-int_ds_pedido.transport = "PADRAO" THEN DO:
        
            FIND FIRST nota-fiscal NO-LOCK
                WHERE nota-fiscal.cod-estabel   = "973" 
                  AND nota-fiscal.serie         = tt-int_ds_pedido.serie
                  AND nota-fiscal.nr-nota-fis   = tt-int_ds_pedido.nr-nota-fis 
                  AND nota-fiscal.idi-sit-nf-eletro = 3 NO-ERROR.
    
            IF AVAIL nota-fiscal THEN DO:
    
                CREATE mdfe-nfe.
                ASSIGN mdfe-nfe.cod-estab       = mdfe-docto.cod-estab        
                       mdfe-nfe.cod-ser-mdfe    = mdfe-docto.cod-ser-mdfe 
                       mdfe-nfe.cod-num-mdfe    = mdfe-docto.cod-num-mdfe 
                       mdfe-nfe.num-seq         = i-num-seq-mdfe
                       mdfe-nfe.dat-emis-mdfe   = nota-fiscal.dt-emis-nota
                       mdfe-nfe.cod-estab-nfe   = nota-fiscal.cod-estabel
                       mdfe-nfe.cod-ser-nfe     = nota-fiscal.serie
                       mdfe-nfe.cod-num-nfe     = nota-fiscal.nr-nota-fis
                       mdfe-nfe.cod-chave-nfe   = nota-fiscal.cod-chave-aces-nf-eletro
                       mdfe-nfe.val-tot-nfe     = nota-fiscal.vl-tot-nota.
    
            END.

            FIND FIRST it-nota-fisc OF nota-fiscal NO-LOCK.

            IF AVAIL it-nota-fisc THEN DO:

                FIND FIRST ITEM NO-LOCK
                    WHERE ITEM.it-codigo = it-nota-fisc.it-codigo NO-ERROR.

                FIND FIRST item-mat NO-LOCK 
                    WHERE item-mat.it-codigo = item.it-codigo NO-ERROR.

                FIND FIRST mdfe-produt-predom NO-LOCK
                    WHERE mdfe-produt-predom.cod-estab         = mdfe-docto.cod-estab        
                      AND mdfe-produt-predom.cod-ser-mdfe      = mdfe-docto.cod-ser-mdfe     
                      AND mdfe-produt-predom.cod-num-mdfe      = mdfe-docto.cod-num-mdfe  NO-ERROR.

                IF NOT AVAIL mdfe-produt-predom THEN DO:

                    CREATE mdfe-produt-predom.
                    ASSIGN mdfe-produt-predom.cod-estab         = mdfe-docto.cod-estab             
                           mdfe-produt-predom.cod-ser-mdfe      = mdfe-docto.cod-ser-mdfe 
                           mdfe-produt-predom.cod-num-mdfe      = mdfe-docto.cod-num-mdfe    
                           mdfe-produt-predom.cod-produt-predom = ITEM.it-codigo   
                           mdfe-produt-predom.idi-tip-carg      = 5 // Carga geral    
                           mdfe-produt-predom.des-produt        = ITEM.descricao-1   
                           mdfe-produt-predom.cod-gtin          = IF AVAIL ITEM-MAT THEN item-mat.cod-ean ELSE ""    
                           mdfe-produt-predom.cod-ncm           = ITEM.class-fiscal   .


                END.





            END.

        END.

        RELEASE mdfe-nfe.
        RELEASE mdfe-condut.
        RELEASE mdfe-rodov.
        RELEASE mdfe-munic-carreg.
        RELEASE mdfe-munic-descarreg.
        

    END.

    RUN pi-finalizar in h-acomp.

    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.


/*



Table: mdfe-produt-predom

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod-estab                   char       im  x(5)
cod-ser-mdfe                char       im  x(5)
cod-num-mdfe                char       im  x(20)
cod-produt-predom           char       im  x(20)
idi-tip-carg                inte           99
des-produt                  char           x(120)
cod-gtin                    char           x(20)
cod-ncm                     char           x(8)
cod-cep-carregto            char           x(8)
cod-latitude-carregto       char           x(10)
cod-longitude-carregto      char           x(10)
cod-cep-descarreg           char           x(8)
cod-latitude-descarreg      char           x(10)
cod-longitude-descarreg     char           x(10)
cod-livre-1                 char           x(1000)
cod-livre-2                 char           x(500)
cod-livre-3                 char           x(1000)
cod-livre-4                 char           x(2000)
num-livre-1                 inte           >>>>>>>>9
num-livre-2                 inte           >>>>>>>>9
num-livre-3                 inte           >>>>>>>>9
num-livre-4                 inte           >>>>>>>>9
val-livre-1                 deci-8         ->>>>>>>>>>>9.99999999
val-livre-2                 deci-8         ->>>>>>>>>>>9.99999999
val-livre-3                 deci-8         ->>>>>>>>>>>9.99999999
val-livre-4                 deci-8         ->>>>>>>>>>>9.99999999
log-livre-1                 logi           Sim/NÆo
log-livre-2                 logi           Sim/NÆo
log-livre-3                 logi           Sim/NÆo
log-livre-4                 logi           Sim/NÆo
dat-livre-1                 date           99/99/9999
dat-livre-2                 date           99/99/9999
dat-livre-3                 date           99/99/9999
dat-livre-4                 date           99/99/9999


*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wWindow
ON CHOOSE OF btQueryJoins IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fpage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME miAbout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL miAbout wWindow
ON CHOOSE OF MENU-ITEM miAbout /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rotas
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


ON 'LEAVE':U OF tt-rotas.placa IN BROWSE br-rotas  
    DO:

        FIND FIRST mdfe-veic NO-LOCK
            WHERE mdfe-veic.cod-placa = tt-rotas.placa:screen-value in browse br-rotas  NO-ERROR.

        ASSIGN tt-rotas.motorista:screen-value in browse br-rotas   = IF AVAIL mdfe-veic THEN SUBSTRING(mdfe-veic.cod-livre-1,21,100) ELSE "".
    END.

    /*:T--- L¢gica para inicializa‡Æo do programam ---*/
{window/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterinitializeinterface wWindow 
PROCEDURE afterinitializeinterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE VARIABLE qtd-notas AS INTEGER     NO-UNDO.
DEFINE VARIABLE c-placa AS CHARACTER   NO-UNDO.

FOR EACH  tt-int_ds_pedido
    WHERE tt-int_ds_pedido.transport = "PADRAO"
    BREAK BY  tt-int_ds_pedido.cod-rota:

    IF FIRST-OF( tt-int_ds_pedido.cod-rota) THEN DO:

        FIND FIRST mdfe-veic NO-LOCK
            WHERE mdfe-veic.cod-placa = tt-int_ds_pedido.placa NO-ERROR.

        IF AVAIL mdfe-veic THEN
            ASSIGN c-placa = replace(SUBSTRING(mdfe-veic.cod-livre-1,1,20), ".", "").

        ASSIGN c-placa = REPLACE(c-placa, "-", "").

        CREATE tt-rotas.
        ASSIGN tt-rotas.cod-rota    = tt-int_ds_pedido.cod-rota
               tt-rotas.placa       = tt-int_ds_pedido.placa
               tt-rotas.uf-placa    = tt-int_ds_pedido.uf-placa
               tt-rotas.motorista   = IF AVAIL mdfe-veic THEN SUBSTRING(mdfe-veic.cod-livre-1,21,100) ELSE "" 
               tt-rotas.cpf-condut  = c-placa.

    END.

    ASSIGN tt-rotas.qtd-notas = tt-rotas.qtd-notas + 1.

END.


   OPEN QUERY br-rotas FOR EACH tt-rotas  NO-LOCK 
       max-rows 100000 .
   enable all with frame fPage1.
 //  br-rotas:SELECT-ROW(1) in frame fPage1.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

