&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME w-incmdp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-incmdp 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i INT510A 1.12.00.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

&global-define botao yes
/* Parameters Definitions ---                                           */
def input-output parameter v-row-table  as rowid.
def input        parameter estado       as char.
def input        parameter wh-query     as widget-handle.

/* Local Variable Definitions ---                                       */
define new global shared var v-row-docto as rowid no-undo.

/*** Variaveis usadas internamente pelo estilo, favor nao elimina-las   */

define buffer b-int_ds_docto_xml for int_ds_docto_xml.
define buffer b-int_ds_it_docto_xml for int_ds_it_docto_xml.

DEFINE NEW GLOBAL SHARED VARIABLE v_cod_empres_usuar AS CHARACTER FORMAT "x(3)":U NO-UNDO.

/*:T variaveis de uso global */
def var v-row-parent as rowid no-undo.
/*:T** Fim das variaveis utilizadas no estilo */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-incmdp
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

&Scoped-define ADM-SUPPORTED-LINKS TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-cad

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rt-button bt-ok bt-save bt-cancela bt-ajuda 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnTrataNuloDec w-incmdp 
FUNCTION fnTrataNuloDec RETURNS decimal (p-valor as decimal) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-incmdp AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-bt-ajuda 
       MENU-ITEM mi-sobre       LABEL "Sobre..."      .


/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_folder AS HANDLE NO-UNDO.
DEFINE VARIABLE h_int510a-query AS HANDLE NO-UNDO.
DEFINE VARIABLE h_int510a-viewer AS HANDLE NO-UNDO.

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

DEFINE BUTTON bt-save AUTO-GO 
     LABEL "&Salvar" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 146 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-cad
     bt-ok AT ROW 17 COL 3 HELP
          "Salva e sai"
     bt-save AT ROW 17 COL 14 HELP
          "Salva e cria novo registro"
     bt-cancela AT ROW 17 COL 25 HELP
          "Cancela"
     bt-ajuda AT ROW 17 COL 136.86
     rt-button AT ROW 16.75 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 148.29 BY 17.29 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-incmdp
   Allow: Basic,Browse,DB-Fields,Smart,Window,Query
   Container Links: 
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-incmdp ASSIGN
         HIDDEN             = YES
         TITLE              = "Inclui/Modifica Nota Fiscal"
         HEIGHT             = 17.29
         WIDTH              = 148.29
         MAX-HEIGHT         = 22
         MAX-WIDTH          = 160.14
         VIRTUAL-HEIGHT     = 22
         VIRTUAL-WIDTH      = 160.14
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-incmdp 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/w-incmdp.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-incmdp
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-cad
   FRAME-NAME L-To-R                                                    */
ASSIGN 
       bt-ajuda:POPUP-MENU IN FRAME f-cad       = MENU POPUP-MENU-bt-ajuda:HANDLE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-incmdp)
THEN w-incmdp:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-incmdp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-incmdp w-incmdp
ON END-ERROR OF w-incmdp /* Inclui/Modifica Nota Fiscal */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-incmdp w-incmdp
ON WINDOW-CLOSE OF w-incmdp /* Inclui/Modifica Nota Fiscal */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ajuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ajuda w-incmdp
ON CHOOSE OF bt-ajuda IN FRAME f-cad /* Ajuda */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cancela
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancela w-incmdp
ON CHOOSE OF bt-cancela IN FRAME f-cad /* Cancelar */
DO:
{include/cancepai.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok w-incmdp
ON CHOOSE OF bt-ok IN FRAME f-cad /* OK */
DO:

IF v_cod_empres_usuar = "10" THEN
DO:
    define variable c-nat-operacao as char no-undo.
    define variable de-aliq-pis as decimal decimals 2.
    define variable de-aliq-cofins as decimal decimals 2.
    define variable de-base-pis as decimal decimals 2.
    define variable de-base-cofins as decimal decimals 2.
    define variable de-valor-pis as decimal decimals 2.
    define variable de-valor-cofins as decimal decimals 2.
    define variable i-pis as integer.
    define variable i-cofins as integer.

    assign i-pis = 2.
    assign i-cofins = 2.
    assign de-base-pis = 0.
    assign de-base-cofins = 0.
    assign de-valor-pis = 0.
    assign de-valor-cofins = 0.
    assign de-aliq-pis = 0.
    assign de-aliq-cofins = 0.

   if avail int_ds_docto_xml and
      int_ds_docto_xml.situacao <> 3 then
   for each int_ds_it_docto_xml no-lock where
       int_ds_it_docto_xml.tipo_nota  = int_ds_docto_xml.tipo_nota and 
       int_ds_it_docto_xml.CNPJ       = int_ds_docto_xml.CNPJ      and 
       int_ds_it_docto_xml.nNF        = int_ds_docto_xml.nNF       and 
       int_ds_it_docto_xml.serie      = int_ds_docto_xml.serie:

       for first ITEM no-lock where ITEM.it-codigo = int_ds_it_docto_xml.it_codigo: end.

       if not can-find(first cfop-natur no-lock where 
           cfop-natur.cod-cfop = trim(string(int_ds_it_docto_xml.cfop,"9999"))) 
       then do:
           run pi-gera-erro(INPUT 31,
                            INPUT "CFOP " + trim(string(int_ds_it_docto_xml.cfop,"9999")) + " do item seq: " + trim(string(int_ds_it_docto_xml.sequencia,">>>>>>9")) + " n∆o cadastrada!"). 
           
           find b-int_ds_it_docto_xml exclusive-lock where 
               rowid(b-int_ds_it_docto_xml) = rowid(int_ds_it_docto_xml) no-error no-wait.
           if avail b-int_ds_it_docto_xml then do:
               assign b-int_ds_it_docto_xml.situacao = 1 /* Pendente */.
               release b-int_ds_it_docto_xml.
           end.
       end.

       if trim(string(int_ds_it_docto_xml.cfop,"9999")) begins "1" or
          trim(string(int_ds_it_docto_xml.cfop,"9999")) begins "2" or
          trim(string(int_ds_it_docto_xml.cfop,"9999")) begins "3" then do:
           run pi-gera-erro(INPUT 32,
                            INPUT "CFOP " + trim(string(int_ds_it_docto_xml.cfop,"9999")) + " do item seq: " + trim(string(int_ds_it_docto_xml.sequencia,">>>>>>9")) + " deve ser a de sa°da do fornecedor!"). 
           find b-int_ds_it_docto_xml exclusive-lock where 
               rowid(b-int_ds_it_docto_xml) = rowid(int_ds_it_docto_xml) no-error no-wait.
           if avail b-int_ds_it_docto_xml then do:
               assign b-int_ds_it_docto_xml.situacao = 1 /* Pendente */.
               release b-int_ds_it_docto_xml.
           end.
       end.

        /* tratar natur-oper */
        c-nat-operacao = "".
        IF  int_ds_it_docto_xml.nat_operacao <> "" AND
            CAN-FIND (natur-oper NO-LOCK WHERE natur-oper.nat-operacao = int_ds_it_docto_xml.nat_operacao) THEN
            ASSIGN c-nat-operacao = int_ds_it_docto_xml.nat_operacao.
        ELSE
            RUN intprg/int013a.p( input int_ds_it_docto_xml.cfop,
                                  input int_ds_it_docto_xml.cst_icms,
                                  input /*int_ds_it_docto_xml.nep-cstb-ipi-n*/ int(item.fm-codigo),
                                  input int_ds_docto_xml.cod_estab,
                                  input int_ds_docto_xml.cod_emitente,
                                  INPUT item.class-fiscal,
                                  input int_ds_docto_xml.dEmi,
                                  output c-nat-operacao).
        if c-nat-operacao = "" then do:
            run pi-gera-erro(INPUT 18,    
                             INPUT "N∆o encontrada natureza de operaá∆o para entrada. " + 
                                   "CFOP Nota: " + string(int_ds_it_docto_xml.cfop) + 
                                   " CSTB ICMS: " + string(int_ds_it_docto_xml.cst_icms) + 
                                   " Fam°lia: " + item.fm-codigo + " Estab.: " + int_ds_docto_xml.cod_estab). 
        end.
        for first natur-oper no-lock where
                  natur-oper.nat-operacao = c-nat-operacao
            query-tuning(no-lookahead) : end.

        if not avail natur-oper 
        then do:
            run pi-gera-erro(INPUT 8,
                             INPUT "Natureza de Operaá∆o " + int_ds_it_docto_xml.nat_operacao + " do item seq: " + trim(string(int_ds_it_docto_xml.sequencia,">>>>>>9"))
                             + " n∆o cadastrada!"). 
        end. 

        /* setando natureza principal do documento para a mais baixa evitendo erro de api quando ST na natureza principal 
           come itens sem st na nota */
        if avail natur-oper then do:

            if c-nat-operacao <> "" and int_ds_docto_xml.nat_operacao = "" 
               &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                then do:
               &else
                or NOT natur-oper.log-contrib-st-antec then do:
            &endif
            
                find b-int_ds_docto_xml exclusive-lock
                    where rowid(b-int_ds_docto_xml) = rowid(int_ds_docto_xml) no-error no-wait.
                if avail b-int_ds_docto_xml then do:
                    assign int_ds_docto_xml.cfop = int(natur-oper.cod-cfop)
                           .
                    assign b-int_ds_docto_xml.nat_operacao = c-nat-operacao.
                    
                    release b-int_ds_docto_xml.
                end.
            end.

            if int_ds_it_docto_xml.nat_operacao <> c-nat-operacao and c-nat-operacao <> "" then do:
                find b-int_ds_it_docto_xml exclusive-lock where 
                    rowid(b-int_ds_it_docto_xml) = rowid(int_ds_it_docto_xml) no-error no-wait.
                if avail b-int_ds_it_docto_xml then do:
                    assign b-int_ds_it_docto_xml.nat_operacao = c-nat-operacao.
                    release b-int_ds_it_docto_xml.
                end.
            end.
            if avail item then do: 
                assign i-pis     = int(substr(natur-oper.char-1,86,1)).
                if i-pis = 1 /* tributado */ then do:
                    de-aliq-pis       = if substr(item.char-2,52,1) = "1" 
                                        /* Al°quota do Item */
                                        then dec(substr(item.char-2,31,5))
                                        /* Al°quota da natureza */
                                        else natur-oper.perc-pis[1].
                    if de-aliq-pis <> 0 then do:
                        de-base-pis           = fnTrataNuloDec(int_ds_it_docto_xml.vProd)
                                              - fnTrataNuloDec(int_ds_it_docto_xml.vDesc)
                                              + fnTrataNuloDec(int_ds_it_docto_xml.vOutro).
                        de-valor-pis          = de-base-pis * de-aliq-pis / 100.
                    end.
                    else do:
                        i-pis = 2.
                        de-base-pis    = 0.
                        de-valor-pis   = 0.
                    end.
                end.
                assign i-cofins  = int(substr(natur-oper.char-1,87,1)).
                if i-cofins = 1 /* tributado */ then do:
                    de-aliq-cofins    = if substr(item.char-2,53,1) = "1"
                                          then dec(substr(item.char-2,36,5))
                                          else natur-oper.per-fin-soc[1].
                    if de-aliq-cofins <> 0 then do:
                        de-base-cofins        = fnTrataNuloDec(int_ds_it_docto_xml.vProd)
                                              - fnTrataNuloDec(int_ds_it_docto_xml.vDesc)
                                              + fnTrataNuloDec(int_ds_it_docto_xml.vOutro).                                                                        
                        de-valor-cofins       = de-aliq-cofins * de-base-cofins / 100.
                    end.
                    else do:
                        de-base-cofins        = 0.
                        de-valor-cofins       = 0.
                        i-cofins     = 2.
                    end.
                end.

                if  fnTrataNuloDec(int_ds_it_docto_xml.vbc_pis   ) <> de-base-pis    or
                    fnTrataNuloDec(int_ds_it_docto_xml.vpis      ) <> de-valor-pis   or
                    fnTrataNuloDec(int_ds_it_docto_xml.cst_pis   ) <> i-pis          or
                    fnTrataNuloDec(int_ds_it_docto_xml.ppis      ) <> de-aliq-pis    or
                    fnTrataNuloDec(int_ds_it_docto_xml.pcofins   ) <> de-aliq-cofins or
                    fnTrataNuloDec(int_ds_it_docto_xml.vbc_cofins) <> de-base-cofins or
                    fnTrataNuloDec(int_ds_it_docto_xml.vcofins   ) <> de-valor-cofins  or
                    fnTrataNuloDec(int_ds_it_docto_xml.cst_cofins) <> i-cofins then do:

                    find b-int_ds_it_docto_xml exclusive-lock where 
                        rowid(b-int_ds_it_docto_xml) = rowid(int_ds_it_docto_xml) no-error no-wait.
                    if avail b-int_ds_it_docto_xml then do:
                        if de-aliq-pis <> 0 and i-pis <> 2 then do:
                            assign b-int_ds_it_docto_xml.ppis    = de-aliq-pis
                                   b-int_ds_it_docto_xml.vbc_pis = de-base-pis.
                            assign b-int_ds_it_docto_xml.vpis    = de-valor-pis
                                   b-int_ds_it_docto_xml.cst_pis = i-pis.
                        end.
                        else do:
                            assign b-int_ds_it_docto_xml.vpis    = 0
                                   b-int_ds_it_docto_xml.ppis    = 0
                                   b-int_ds_it_docto_xml.vbc_pis = 0
                                   b-int_ds_it_docto_xml.cst_pis = 2.
                        end.

                        if de-aliq-cofins <> 0 and i-cofins <> 2 then do:
                            assign b-int_ds_it_docto_xml.pcofins    = de-aliq-cofins
                                   b-int_ds_it_docto_xml.vbc_cofins = de-base-cofins.
                            assign b-int_ds_it_docto_xml.vcofins    = de-valor-cofins
                                   b-int_ds_it_docto_xml.cst_cofins = 1.
                        end.
                        else do:
                            assign b-int_ds_it_docto_xml.pcofins    = 0
                                   b-int_ds_it_docto_xml.vbc_cofins = 0
                                   b-int_ds_it_docto_xml.vcofins    = 0
                                   b-int_ds_it_docto_xml.cst_cofins = 2.
                        end.
                        release b-int_ds_it_docto_xml.
                    end.


                end.
            end. /* avail item */
        end. /* avail natur-oper */
        if not can-find(first classif-fisc no-lock where 
            classif-fisc.class-fiscal = trim(string(int_ds_it_docto_xml.ncm,"99999999"))) then do:
            run pi-gera-erro(INPUT 27,
                             INPUT "NCM " + trim(string(int_ds_it_docto_xml.ncm,"99999999")) + " do item seq: " + trim(string(int_ds_it_docto_xml.sequencia,">>>>>>9")) + " n∆o cadastrada!"). 
        end.
        RUN new-state("RefreshData").
    end. /* avail int_ds_it_docto_xml */   
END.
    
{include/okpai.i h_int510a-viewer}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-save w-incmdp
ON CHOOSE OF bt-save IN FRAME f-cad /* Salvar */
DO:
{include/salvapai.i h_int510a-viewer}
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sobre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sobre w-incmdp
ON CHOOSE OF MENU-ITEM mi-sobre /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-incmdp 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-incmdp  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  CASE adm-current-page: 

    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'adm/objects/folder.w':U ,
             INPUT  FRAME f-cad:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_folder ).
       RUN set-position IN h_folder ( 1.33 , 1.00 ) NO-ERROR.
       RUN set-size IN h_folder ( 14.92 , 147.00 ) NO-ERROR.

       RUN init-object IN THIS-PROCEDURE (
             INPUT  'intprg/int510a-viewer.w':U ,
             INPUT  FRAME f-cad:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_int510a-viewer ).
       RUN set-position IN h_int510a-viewer ( 2.75 , 3.00 ) NO-ERROR.
       /* Size in UIB:  ( 12.83 , 143.00 ) */

       RUN init-object IN THIS-PROCEDURE (
             INPUT  'intprg/int510a-query.w':U ,
             INPUT  FRAME f-cad:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_int510a-query ).
       RUN set-position IN h_int510a-query ( 16.25 , 127.00 ) NO-ERROR.
       /* Size in UIB:  ( 2.00 , 7.00 ) */

       /* Links to SmartFolder h_folder. */
       RUN add-link IN adm-broker-hdl ( h_folder , 'Page':U , THIS-PROCEDURE ).

       /* Links to SmartViewer h_int510a-viewer. */
       RUN add-link IN adm-broker-hdl ( h_int510a-query , 'Record':U , h_int510a-viewer ).
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'TableIO':U , h_int510a-viewer ).

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_folder ,
             bt-ok:HANDLE IN FRAME f-cad , 'BEFORE':U ).
       RUN adjust-tab-order IN adm-broker-hdl ( h_int510a-viewer ,
             h_folder , 'AFTER':U ).
    END. /* Page 0 */

  END CASE.
  /* Select a Startup page. */
  IF adm-current-page eq 0 
  THEN RUN select-page IN THIS-PROCEDURE ( 1 ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-incmdp  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-incmdp  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-incmdp)
  THEN DELETE WIDGET w-incmdp.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-incmdp  _DEFAULT-ENABLE
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
  ENABLE rt-button bt-ok bt-save bt-cancela bt-ajuda 
      WITH FRAME f-cad IN WINDOW w-incmdp.
  {&OPEN-BROWSERS-IN-QUERY-f-cad}
  VIEW w-incmdp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy w-incmdp 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-incmdp 
PROCEDURE local-exit :
/* -----------------------------------------------------------
  Purpose:  Starts an "exit" by APPLYing CLOSE event, which starts "destroy".
  Parameters:  <none>
  Notes:    If activated, should APPLY CLOSE, *not* dispatch adm-exit.   
-------------------------------------------------------------*/
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  
  RETURN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize w-incmdp 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
  {include/win-size.i}

  assign v-row-docto = v-row-table.

  {utp/ut9000.i "INT510A" "1.12.00.AVB"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
    {include/i-inifld.i}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-reposiciona w-incmdp 
PROCEDURE pi-reposiciona :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  RUN pi-reposiciona-query IN h_int510a-query (INPUT v-row-table). 
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-incmdp  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this w-incmdp, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-incmdp 
PROCEDURE state-changed :
/*:T -----------------------------------------------------------
  Purpose:     Manuseia trocas de estado dos SmartObjects
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.

  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnTrataNuloDec w-incmdp 
FUNCTION fnTrataNuloDec RETURNS decimal (p-valor as decimal):

    if p-valor = ? then return 0.
    else return p-valor.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

