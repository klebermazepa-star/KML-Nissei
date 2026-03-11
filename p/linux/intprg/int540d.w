&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-Dialog 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i D99XX999 9.99.99.999}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-rowid as rowid.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME D-Dialog

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES int_ds_docto_xml

/* Definitions for DIALOG-BOX D-Dialog                                  */
&Scoped-define FIELDS-IN-QUERY-D-Dialog int_ds_docto_xml.cod_emitente ~
int_ds_docto_xml.serie int_ds_docto_xml.nNF 
&Scoped-define QUERY-STRING-D-Dialog FOR EACH int_ds_docto_xml SHARE-LOCK
&Scoped-define OPEN-QUERY-D-Dialog OPEN QUERY D-Dialog FOR EACH int_ds_docto_xml SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-D-Dialog int_ds_docto_xml
&Scoped-define FIRST-TABLE-IN-QUERY-D-Dialog int_ds_docto_xml


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rt-buttom RECT-25 RECT-26 c-nova-serie ~
c-novo-numero bt-ok bt-cancela bt-ajuda 
&Scoped-Define DISPLAYED-FIELDS int_ds_docto_xml.cod_emitente ~
int_ds_docto_xml.serie int_ds_docto_xml.nNF 
&Scoped-define DISPLAYED-TABLES int_ds_docto_xml
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_docto_xml
&Scoped-Define DISPLAYED-OBJECTS cFornecedor c-nova-serie c-novo-numero 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-ajuda 
     LABEL "&Ajuda" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-cancela AUTO-END-KEY 
     LABEL "&Cancelar" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-ok AUTO-GO 
     LABEL "&OK" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE c-nova-serie AS CHARACTER FORMAT "X(5)":U 
     LABEL "Nova S‚rie" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE c-novo-numero AS CHARACTER FORMAT "X(10)":U 
     LABEL "Novo N£mero" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE cFornecedor AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 53.86 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-25
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 78.86 BY 4.

DEFINE RECTANGLE RECT-26
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 78.86 BY 3.5.

DEFINE RECTANGLE rt-buttom
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 77 BY 1.42
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY D-Dialog FOR 
      int_ds_docto_xml SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     int_ds_docto_xml.cod_emitente AT ROW 2 COL 13 COLON-ALIGNED WIDGET-ID 2
          LABEL "Fornecedor":R10
          VIEW-AS FILL-IN 
          SIZE 10.14 BY .88
     cFornecedor AT ROW 2 COL 23.14 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     int_ds_docto_xml.serie AT ROW 3 COL 13.14 COLON-ALIGNED WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 9.14 BY .88
     int_ds_docto_xml.nNF AT ROW 4 COL 13.14 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 17.14 BY .88
     c-nova-serie AT ROW 6.5 COL 13.14 COLON-ALIGNED WIDGET-ID 14
     c-novo-numero AT ROW 7.5 COL 13.14 COLON-ALIGNED WIDGET-ID 20
     bt-ok AT ROW 9.5 COL 3
     bt-cancela AT ROW 9.5 COL 14
     bt-ajuda AT ROW 9.5 COL 68
     "Nova Numera‡Æo" VIEW-AS TEXT
          SIZE 16 BY .67 AT ROW 5.25 COL 2 WIDGET-ID 24
     "Numera‡Æo Atual" VIEW-AS TEXT
          SIZE 16 BY .67 AT ROW 1 COL 2 WIDGET-ID 18
     rt-buttom AT ROW 9.25 COL 2
     RECT-25 AT ROW 1.21 COL 1 WIDGET-ID 16
     RECT-26 AT ROW 5.5 COL 1 WIDGET-ID 22
     SPACE(0.00) SKIP(1.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Altera Chave Nota Fiscal"
         DEFAULT-BUTTON bt-ok WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/d-dialog.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
   FRAME-NAME L-To-R                                                    */
ASSIGN 
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN cFornecedor IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.cod_emitente IN FRAME D-Dialog
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.nNF IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.serie IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _TblList          = "custom.int_ds_docto_xml"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON GO OF FRAME D-Dialog /* Altera Chave Nota Fiscal */
DO:
    def var c-aux as character no-undo.

    assign  FRAME {&FRAME-NAME}
            c-nova-serie
            c-novo-numero.

    if c-nova-serie = "" then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("S‚rie inv lida!" + "~~" + "A s‚rie deve ser informada!")).
        return no-apply.
    end.
    for first serie no-lock where 
        serie.serie = c-nova-serie: end.
    if not avail serie then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("S‚rie inv lida!" + "~~" + "A s‚rie nÆo foi encontrada no cadastro de s‚ries cd0905!")).
        return no-apply.
    end.
    if c-novo-numero = "" then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("N£mero inv lido!" + "~~" + "O n£mero da nota deve ser informado!")).
        return no-apply.
    end.
    c-aux = trim(string(integer(c-novo-numero))) no-error.
    if c-aux = ? then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("N£mero inv lido!" + "~~" + "O n£mero da nota deve conter apenas n£meros!")).
        return no-apply.
    end.

    for first int_ds_docto_xml no-lock where 
        int_ds_docto_xml.serie = c-nova-serie and
        int_ds_docto_xml.nNF   = c-novo-numero: end.
    if avail int_ds_docto_xml then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Numera‡Æo inv lida!" + "~~" + "J  existe nota fiscal com a numera‡Æo informada: " + c-nova-serie + "/" + c-novo-numero)).
        return no-apply.                                                                                        
    end.

    do transaction:
                
        for each int_ds_docto_xml EXCLUSIVE where rowid(int_ds_docto_xml) = p-rowid
            query-tuning(no-lookahead):

            if  int_ds_docto_xml.situacao = 3 or 
                int_ds_docto_xml.situacao = 9 
            then do:
                run utp/ut-msgs.p(input "show",
                                  input 17006,
                                  input ("Situa‡Æo inv lida!" + "~~" + "A situa‡Æo da nota fiscal nÆo permite altera‡Æo: " + string(int_ds_docto_xml.situacao) + " (3-Integrada RE1001,9-Recusada)")).
                return no-apply.                                                                                        
            end.
            if  c-nova-serie  = int_ds_docto_xml.serie and
                c-novo-numero = int_ds_docto_xml.nNF
            then do:
                run utp/ut-msgs.p(input "show",
                                  input 17006,
                                  input ("Numera‡Æo inv lida!" + "~~" + "A numera‡Æo atual ‚ igual … nova numera‡Æo : " + c-nova-serie + "/" + c-novo-numero)).
                return no-apply.                                                                                        
            end.

            for each int_ds_it_docto_xml exclusive-lock where
                int_ds_it_docto_xml.tipo_nota  = int_ds_docto_xml.tipo_nota and 
                int_ds_it_docto_xml.CNPJ       = int_ds_docto_xml.CNPJ      and 
                int_ds_it_docto_xml.nNF        = int_ds_docto_xml.nNF       and 
                int_ds_it_docto_xml.serie      = int_ds_docto_xml.serie
                query-tuning(no-lookahead):
                assign  int_ds_it_docto_xml.serie = c-nova-serie
                        int_ds_it_docto_xml.nNF   = c-novo-numero.
            end.
            for each int_ds_docto_xml_dup exclusive-lock of int_ds_docto_xml
                query-tuning(no-lookahead):
                assign  int_ds_docto_xml_dup.serie = c-nova-serie
                        int_ds_docto_xml_dup.nNF   = c-novo-numero.
            end.
            /*
            for each int_ds_docto_xml-compras exclusive of int_ds_docto_xml_dup
                query-tuning(no-lookahead):

                /*
                for each int_ds_docto_xml-log-compras exclusive of int_ds_docto_xml-compras
                    query-tuning(no-lookahead):
                    assign  int_ds_docto_xml-log-compras.serie = c-nova-serie
                            int_ds_docto_xml-log-compras.nNF   = c-novo-numero.
                end.
                */
                assign  int_ds_docto_xml-compras.serie = c-nova-serie
                        int_ds_docto_xml-compras.nNF   = c-novo-numero.
            end.
            */
            for each int_ds_docto_wms exclusive where 
                int_ds_docto_wms.doc_numero_n = int(int_ds_docto_xml.nNF) and
                int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie and
                int_ds_docto_wms.cnpj_cpf     = int_ds_docto_xml.CNPJ
                query-tuning(no-lookahead):
                assign int_ds_docto_wms.doc_numero_n = int64(c-novo-numero)
                       int_ds_docto_wms.doc_serie_s  = c-nova-serie.
            end.
            for each int_ds_doc_erro exclusive-lock where
                int_ds_doc_erro.serie_docto  = int_ds_docto_xml.serie        and 
                int_ds_doc_erro.cod_emitente = int_ds_docto_xml.cod_emitente and 
                int_ds_doc_erro.CNPJ         = int_ds_docto_xml.CNPJ         and     
                int_ds_doc_erro.nro_docto    = int_ds_docto_xml.NNF          and  
                int_ds_doc_erro.tipo_nota    = int_ds_docto_xml.tipo_nota
                query-tuning(no-lookahead):
                assign  int_ds_doc_erro.serie_docto = c-nova-serie
                        int_ds_doc_erro.nro_docto   = c-novo-numero.
            end.

            assign  int_ds_docto_xml.serie = c-nova-serie
                    int_ds_docto_xml.nNF   = c-novo-numero.

            run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Altera‡Æo conclu¡da!" + "~~" + "Numera‡Æo do documento alterada para: " + c-nova-serie + "/" + c-novo-numero)).
        end.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Altera Chave Nota Fiscal */
DO:  
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ajuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ajuda D-Dialog
ON CHOOSE OF bt-ajuda IN FRAME D-Dialog /* Ajuda */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog 


/* ***************************  Main Block  *************************** */

{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME D-Dialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY cFornecedor c-nova-serie c-novo-numero 
      WITH FRAME D-Dialog.
  IF AVAILABLE int_ds_docto_xml THEN 
    DISPLAY int_ds_docto_xml.cod_emitente int_ds_docto_xml.serie 
          int_ds_docto_xml.nNF 
      WITH FRAME D-Dialog.
  ENABLE rt-buttom RECT-25 RECT-26 c-nova-serie c-novo-numero bt-ok bt-cancela 
         bt-ajuda 
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy D-Dialog 
PROCEDURE local-destroy :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'destroy':U ) .
  {include/i-logfin.i}

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize D-Dialog 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  {utp/ut9000.i "int540d" "1.12.15.AVB"}

    for first int_ds_docto_xml no-lock where 
        rowid(int_ds_docto_xml) = p-rowid:
        assign  int_ds_docto_xml.cod_emitente:screen-value in FRAME {&FRAME-NAME} = string(int_ds_docto_xml.cod_emitente)
                int_ds_docto_xml.nNF         :screen-value in FRAME {&FRAME-NAME} = int_ds_docto_xml.nNF         
                int_ds_docto_xml.serie       :screen-value in FRAME {&FRAME-NAME} = int_ds_docto_xml.serie.

        assign  c-novo-numero                :screen-value in FRAME {&FRAME-NAME} = int_ds_docto_xml.nNF
                c-nova-serie                 :screen-value in FRAME {&FRAME-NAME} = int_ds_docto_xml.serie.

        assign  c-novo-numero = int_ds_docto_xml.nNF
                c-nova-serie  = int_ds_docto_xml.serie.
    end.
    if not avail int_ds_docto_xml then do:
        run utp/ut-msgs.p(input "show",
                          input 17006,
                          input ("Documento inv lido!" + "~~" + "O docuento nÆo foi localizado!"))).
        disable all with FRAME {&FRAME-NAME}.
        return "ADM-ERROR".
    end.

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "int_ds_docto_xml"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed D-Dialog 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  
  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

