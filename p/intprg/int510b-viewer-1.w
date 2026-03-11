&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int510-viewer-1 1.12.00.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/viewerd.w

/* global variable definitions */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var v-row-parent as rowid no-undo.

DEF VAR de-fator       AS DECIMAL NO-UNDO.
DEF VAR h-boin176         AS HANDLE.

def var i-sit-re as integer no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-main

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int_ds_it_docto_xml
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_it_docto_xml


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_it_docto_xml.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_it_docto_xml.item_do_forn ~
int_ds_it_docto_xml.it_codigo int_ds_it_docto_xml.numero_ordem ~
int_ds_it_docto_xml.qCom_forn int_ds_it_docto_xml.vDesc ~
int_ds_it_docto_xml.vProd 
&Scoped-define ENABLED-TABLES int_ds_it_docto_xml
&Scoped-define FIRST-ENABLED-TABLE int_ds_it_docto_xml
&Scoped-Define ENABLED-OBJECTS rt-key 
&Scoped-Define DISPLAYED-FIELDS int_ds_it_docto_xml.sequencia ~
int_ds_it_docto_xml.item_do_forn int_ds_it_docto_xml.uCom_forn ~
int_ds_it_docto_xml.it_codigo int_ds_it_docto_xml.uCom ~
int_ds_it_docto_xml.num_pedido int_ds_it_docto_xml.numero_ordem ~
int_ds_it_docto_xml.qCom_forn int_ds_it_docto_xml.vUnCom ~
int_ds_it_docto_xml.qCom int_ds_it_docto_xml.vDesc ~
int_ds_it_docto_xml.vProd 
&Scoped-define DISPLAYED-TABLES int_ds_it_docto_xml
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_it_docto_xml
&Scoped-Define DISPLAYED-OBJECTS cItem cFm-Codigo cFamilia de-qtde-pedido ~
de-desc-pedido de-valor-pedido 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS int_ds_it_docto_xml.it_codigo 
&Scoped-define ADM-ASSIGN-FIELDS int_ds_it_docto_xml.sequencia ~
int_ds_it_docto_xml.uCom_forn int_ds_it_docto_xml.uCom ~
int_ds_it_docto_xml.vUnCom int_ds_it_docto_xml.qCom 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
sequencia||y|custom.int_ds_it_docto_xml.sequencia
</FOREIGN-KEYS> 
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = ,
     Keys-Supplied = "sequencia"':U).
/**************************
</EXECUTING-CODE> */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE cFamilia AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 55 BY .88 NO-UNDO.

DEFINE VARIABLE cFm-Codigo AS CHARACTER FORMAT "X(12)":U 
     LABEL "Fam°lia" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE cItem AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 52 BY .88 NO-UNDO.

DEFINE VARIABLE de-desc-pedido AS DECIMAL FORMAT "->>>>,>>>,>>9.999999":U INITIAL 0 
     LABEL "Desc  Ped" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE de-qtde-pedido AS DECIMAL FORMAT "->>>>,>>>,>>9.999999":U INITIAL 0 
     LABEL "Qtd Ped" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE de-valor-pedido AS DECIMAL FORMAT "->>>>,>>>,>>9.999999":U INITIAL 0 
     LABEL "Vlr Ped" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE RECTANGLE rt-key
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 8.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int_ds_it_docto_xml.sequencia AT ROW 1.25 COL 13 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 8.14 BY .88
     int_ds_it_docto_xml.item_do_forn AT ROW 1.25 COL 21 COLON-ALIGNED NO-LABEL WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 61.14 BY .88
     int_ds_it_docto_xml.uCom_forn AT ROW 1.25 COL 82 COLON-ALIGNED NO-LABEL WIDGET-ID 42
          VIEW-AS FILL-IN 
          SIZE 3 BY .88
     int_ds_it_docto_xml.it_codigo AT ROW 2.25 COL 13 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 17.14 BY .88
     cItem AT ROW 2.25 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     int_ds_it_docto_xml.uCom AT ROW 2.25 COL 82 COLON-ALIGNED NO-LABEL WIDGET-ID 14
          VIEW-AS FILL-IN 
          SIZE 3 BY .88
     cFm-Codigo AT ROW 3.25 COL 13 COLON-ALIGNED WIDGET-ID 16
     cFamilia AT ROW 3.25 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     int_ds_it_docto_xml.num_pedido AT ROW 4.25 COL 13 COLON-ALIGNED WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 14 BY .88
     int_ds_it_docto_xml.numero_ordem AT ROW 4.25 COL 46 COLON-ALIGNED WIDGET-ID 34
          LABEL "Ord Compra":R15
          VIEW-AS FILL-IN 
          SIZE 11 BY .88
     int_ds_it_docto_xml.qCom_forn AT ROW 5.25 COL 13 COLON-ALIGNED WIDGET-ID 32
          LABEL "Qtde Fornec"
          VIEW-AS FILL-IN 
          SIZE 16.14 BY .88
     int_ds_it_docto_xml.vUnCom AT ROW 5.25 COL 46 COLON-ALIGNED WIDGET-ID 20
          LABEL "Vlr Unit Forn"
          VIEW-AS FILL-IN 
          SIZE 14 BY .88
     int_ds_it_docto_xml.qCom AT ROW 6.25 COL 13 COLON-ALIGNED WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 16.14 BY .88
     de-qtde-pedido AT ROW 6.25 COL 46 COLON-ALIGNED WIDGET-ID 28
     int_ds_it_docto_xml.vDesc AT ROW 7.25 COL 13 COLON-ALIGNED WIDGET-ID 38
          VIEW-AS FILL-IN 
          SIZE 16.14 BY .88
     de-desc-pedido AT ROW 7.25 COL 46 COLON-ALIGNED WIDGET-ID 30
     int_ds_it_docto_xml.vProd AT ROW 8.25 COL 13 COLON-ALIGNED WIDGET-ID 40
          VIEW-AS FILL-IN 
          SIZE 16.14 BY .88
     de-valor-pedido AT ROW 8.25 COL 46 COLON-ALIGNED WIDGET-ID 26
     rt-key AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: custom.int_ds_it_docto_xml
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY COMPILE
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 8.63
         WIDTH              = 88.57.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}
{include/c-viewer.i}
{utp/ut-glob.i}
{include/i_dbtype.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME f-main:SCROLLABLE       = FALSE
       FRAME f-main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN cFamilia IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cFm-Codigo IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cItem IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN de-desc-pedido IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN de-qtde-pedido IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN de-valor-pedido IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_it_docto_xml.it_codigo IN FRAME f-main
   1                                                                    */
/* SETTINGS FOR FILL-IN int_ds_it_docto_xml.numero_ordem IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_it_docto_xml.num_pedido IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_it_docto_xml.qCom IN FRAME f-main
   NO-ENABLE 2                                                          */
/* SETTINGS FOR FILL-IN int_ds_it_docto_xml.qCom_forn IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_it_docto_xml.sequencia IN FRAME f-main
   NO-ENABLE 2                                                          */
/* SETTINGS FOR FILL-IN int_ds_it_docto_xml.uCom IN FRAME f-main
   NO-ENABLE 2                                                          */
/* SETTINGS FOR FILL-IN int_ds_it_docto_xml.uCom_forn IN FRAME f-main
   NO-ENABLE 2                                                          */
/* SETTINGS FOR FILL-IN int_ds_it_docto_xml.vUnCom IN FRAME f-main
   NO-ENABLE 2 EXP-LABEL                                                */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-main
/* Query rebuild information for FRAME f-main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME f-main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME int_ds_it_docto_xml.item_do_forn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_it_docto_xml.item_do_forn V-table-Win
ON LEAVE OF int_ds_it_docto_xml.item_do_forn IN FRAME f-main /* Item Fornec */
DO:
    def var c-item-do-forn as character no-undo.
    def var de-fator as decimal no-undo.

    /*
    cUnFor:screen-value in FRAME {&FRAME-NAME} = "".
    cUnFor = "".
    */
    for first int_ds_docto_xml no-lock where 
        rowid(int_ds_docto_xml) = v-row-parent
        query-tuning(no-lookahead): end.

    if avail int_ds_docto_xml and int_ds_docto_xml.tipo_nota <> 3 /* NFT */ then do:

        /* Pepsico */
        for first int_ds_ext_emitente no-lock where 
                  int_ds_ext_emitente.cod_emitente = int_ds_docto_xml.cod_emitente
            query-tuning(no-lookahead) : end.

        /* PEPSICO */
        if  int_ds_it_docto_xml.it_codigo:screen-value in FRAME {&FRAME-NAME} <> "" and
           (avail int_ds_ext_emitente and int_ds_ext_emitente.gera_nota) or
                  int_ds_docto_xml.tipo_docto = 0
        then do:
    
            c-item-do-forn = int_ds_it_docto_xml.it_codigo:screen-value in FRAME {&FRAME-NAME}.
            for first item-fornec no-lock where
                      item-fornec.cod-emitente = int_ds_docto_xml.cod_emitente and
                      item-fornec.it-codigo    = int_ds_it_docto_xml.it_codigo:screen-value in FRAME {&FRAME-NAME} and
                      item-fornec.ativo = yes
                      query-tuning(no-lookahead):
                assign int_ds_it_docto_xml.uCom_forn:screen-value in FRAME {&FRAME-NAME} = item-fornec.unid-med-for.
            end.
        end.
        /* demais fornecedores */
        else do:
            assign  c-item-do-forn = int_ds_it_docto_xml.item_do_forn:screen-value in FRAME {&FRAME-NAME}.
            assign int_ds_it_docto_xml.uCom_forn:screen-value in FRAME {&FRAME-NAME} = "".

            for first item-fornec no-lock where
                      item-fornec.cod-emitente = int_ds_docto_xml.cod_emitente and
                      item-fornec.item-do-forn = c-item-do-forn and 
                      item-fornec.ativo = yes
                      query-tuning(no-lookahead): 
                assign int_ds_it_docto_xml.uCom_forn:screen-value in FRAME {&FRAME-NAME} = item-fornec.unid-med-for.
            end.
            if not avail item-fornec then do:
                c-item-do-forn = trim(c-item-do-forn).
                for first item-fornec no-lock where
                          item-fornec.cod-emitente = int_ds_docto_xml.cod_emitente and
                          item-fornec.item-do-forn = c-item-do-forn and 
                          item-fornec.ativo = yes
                          query-tuning(no-lookahead): 
                    assign int_ds_it_docto_xml.uCom_forn:screen-value in FRAME {&FRAME-NAME} = item-fornec.unid-med-for.
                end.
    
                /* Utiliza multiplas unidades com o codigo alternativo cc0105 */
                for first item-fornec-umd where
                          item-fornec-umd.cod-emitente = int_ds_it_docto_xml.cod_emitente and
                          item-fornec-umd.cod-livre-1  = c-item-do-forn and  
                          item-fornec-umd.log-ativo no-lock
                          query-tuning(no-lookahead): 
                    assign int_ds_it_docto_xml.uCom_forn:screen-value in FRAME {&FRAME-NAME} = item-fornec-umd.unid-med-for.
                end.
                if avail item-fornec-umd 
                then do:
                   for first item-fornec no-lock where 
                             item-fornec.cod-emitente = int_ds_it_docto_xml.cod_emitente and
                             item-fornec.it-codigo    = item-fornec-umd.it-codigo and
                             item-fornec.ativo = YES query-tuning(no-lookahead): end.
    
                end.
            end.
            if avail item-fornec and int_ds_it_docto_xml.qCom_forn:input-value in FRAME {&FRAME-NAME} <> 0
            then do:
                if int_ds_it_docto_xml.it_codigo:screen-value in FRAME {&FRAME-NAME} = "" then
                    assign int_ds_it_docto_xml.it_codigo:screen-value in FRAME {&FRAME-NAME} = item-fornec.it-codigo.
    
                run retornaIndiceConversao in h-boin176 (input item-fornec.it-codigo,
                                                         input int_ds_docto_xml.cod_emitente,
                                                         input /*item-fornec.unid-med-for*/ int_ds_it_docto_xml.uCom_forn:screen-value in FRAME {&FRAME-NAME},
                                                         output de-fator). 
    
                /*run pi-retorna-indice-conversao (input item-fornec.it-codigo,
                                                 input int_ds_docto_xml.cod_emitente,
                                                 input /*item-fornec.unid-med-for*/ int_ds_it_docto_xml.uCom_forn:screen-value in FRAME {&FRAME-NAME},
                                                 output de-fator).*/ 

                if de-fator = 0 or de-fator = ? then assign de-fator = 1. 
    
                assign int_ds_it_docto_xml.qCom:screen-value in FRAME {&FRAME-NAME} = string(round(int_ds_it_docto_xml.qCom_forn:input-value in FRAME {&FRAME-NAME} / de-fator,0)).
    
                if int(int_ds_it_docto_xml.qCom:screen-value in FRAME {&FRAME-NAME}) <= 1 then 
                   assign int_ds_it_docto_xml.qCom:screen-value in FRAME {&FRAME-NAME} = "1".
    
            end.
        end. /* else */
    end. /* tipo_nota <> 3 */
    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_it_docto_xml.it_codigo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_it_docto_xml.it_codigo V-table-Win
ON F5 OF int_ds_it_docto_xml.it_codigo IN FRAME f-main /* Item */
DO:
    {include/zoomvar.i &prog-zoom="inzoom/z01in172.w"
                      &campo="int_ds_it_docto_xml.it_codigo"
                      &campozoom="it-codigo"
                      &frame="f-Main"
                      &campo2="cItem"
                      &campozoom2="desc-item"
                      &frame2="f-Main"
                      &campo3="int_ds_it_docto_xml.uCom"
                      &campozoom3="un"
                      &frame3="f-Main"
                      &campo4="cFm-codigo"  
                      &campozoom4="fm-codigo"
                      &frame4="f-Main"
                      }  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_it_docto_xml.it_codigo V-table-Win
ON LEAVE OF int_ds_it_docto_xml.it_codigo IN FRAME f-main /* Item */
DO:
  
   for first int_ds_docto_xml no-lock where rowid(int_ds_docto_xml) = v-row-parent
       query-tuning(no-lookahead): end.

   assign cItem     :screen-value in frame {&frame-name} = ""
          cFm-codigo:screen-value in frame {&frame-name} = ""
          cFamilia  :screen-value in frame {&frame-name} = "".
   assign int_ds_it_docto_xml.uCom:screen-value in frame {&frame-name} = "".

   for first item no-lock 
       where item.it-codigo = input frame {&frame-name} int_ds_it_docto_xml.it_codigo
       query-tuning(no-lookahead):
       assign cItem:screen-value in frame {&frame-name} = item.desc-item
              int_ds_it_docto_xml.uCom:screen-value in frame {&frame-name} = item.un
              cFm-codigo:screen-value in frame {&frame-name} = item.fm-codigo.

       for first familia fields (descricao) no-lock where 
                 familia.fm-codigo = item.fm-codigo
                 query-tuning(no-lookahead):
           assign cFamilia:screen-value in frame {&frame-name} = familia.descricao.
       end.
       if int_ds_it_docto_xml.tipo_nota <> 3 /* transferencia */ and
          not can-find (first estabelec no-lock where estabelec.cod-emitente = int_ds_it_docto_xml.cod_emitente) 
       then do:

           /* Pepsico */
           if avail int_ds_docto_xml then 
           for first int_ds_ext_emitente no-lock where 
                     int_ds_ext_emitente.cod_emitente = int_ds_docto_xml.cod_emitente
               query-tuning(no-lookahead) : 
               
               if  int_ds_it_docto_xml.it_codigo:screen-value in FRAME {&FRAME-NAME} <> "" and
                  (int_ds_ext_emitente.gera_nota) or int_ds_docto_xml.tipo_docto = 0
               then do:
                   assign int_ds_it_docto_xml.uCom_forn:screen-value in frame {&frame-name} = "".
                   for first item-fornec no-lock where 
                       item-fornec.cod-emitente = int_ds_docto_xml.cod_emitente and
                       item-fornec.it-codigo    = input frame {&frame-name} int_ds_it_docto_xml.it_codigo and
                       item-fornec.ativo        = yes
                       query-tuning(no-lookahead):
                       assign int_ds_it_docto_xml.item_do_forn:screen-value in FRAME {&frame-name} = item-fornec.item-do-forn
                              int_ds_it_docto_xml.uCom_forn:screen-value in frame {&frame-name} = item-fornec.unid-med-for.
                   end.
               end.
               
           end.

       end.
   end.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_it_docto_xml.it_codigo V-table-Win
ON MOUSE-SELECT-DBLCLICK OF int_ds_it_docto_xml.it_codigo IN FRAME f-main /* Item */
DO:
  apply "F5" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_it_docto_xml.numero_ordem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_it_docto_xml.numero_ordem V-table-Win
ON F5 OF int_ds_it_docto_xml.numero_ordem IN FRAME f-main /* Ord Compra */
or "mouse-select-dblclick" of int_ds_it_docto_xml.numero_ordem
DO:
     {include/zoomvar.i &prog-zoom=inzoom/z13in274.w
                       &campo=int_ds_it_docto_xml.numero_ordem
                       &campozoom=numero-ordem
                       &campo2=int_ds_it_docto_xml.num_pedido
                       &campozoom2=num-pedido
                       &parametros="run pi-recebe-parametros in wh-pesquisa
                                        (input int_ds_docto_xml.cod_emitente,
                                         input 1,
                                         input int_ds_it_docto_xml.it_codigo)."}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_it_docto_xml.numero_ordem V-table-Win
ON LEAVE OF int_ds_it_docto_xml.numero_ordem IN FRAME f-main /* Ord Compra */
DO:

    assign  de-qtde-pedido  :screen-value in frame {&frame-name} = string(0)
            de-valor-pedido :screen-value in frame {&frame-name} = string(0)
            de-desc-pedido  :screen-value in frame {&frame-name} = string(0).
    assign  de-qtde-pedido  :fgcolor in frame {&frame-name} = ?
            de-valor-pedido :fgcolor in frame {&frame-name} = ?
            de-desc-pedido  :fgcolor in frame {&frame-name} = ?
            int_ds_it_docto_xml.num_pedido   :fgcolor in frame {&frame-name} = ?
            int_ds_it_docto_xml.numero_ordem :fgcolor in frame {&frame-name} = ?.

    if int_ds_it_docto_xml.numero_ordem:screen-value in frame {&frame-name} <> "0" and
       int_ds_it_docto_xml.numero_ordem:screen-value in frame {&frame-name} <> "" then do:
        for first ordem-compra fields (num-pedido qt-solic pre-unit-for valor-descto)  no-lock where 
            ordem-compra.numero-ordem = input frame {&frame-name} int_ds_it_docto_xml.numero_ordem
            query-tuning(no-lookahead):

            assign  de-qtde-pedido  :screen-value in frame {&frame-name} = string(ordem-compra.qt-solic)
                    de-valor-pedido :screen-value in frame {&frame-name} = string(ordem-compra.pre-unit-for * ordem-compra.qt-solic)
                    de-desc-pedido  :screen-value in frame {&frame-name} = string(ordem-compra.valor-descto).
            assign  de-qtde-pedido  = ordem-compra.qt-solic
                    de-valor-pedido = ordem-compra.pre-unit-for * ordem-compra.qt-solic
                    de-desc-pedido  = ordem-compra.valor-descto.

            if ordem-compra.qt-solic < int_ds_it_docto_xml.qCom then assign de-qtde-pedido:fgcolor in frame {&frame-name} = 12.
            if de-valor-pedido < int_ds_it_docto_xml.vProd then assign de-valor-pedido:fgcolor in frame {&frame-name} = 12.
            if ordem-compra.valor-descto < int_ds_it_docto_xml.vDesc then assign de-desc-pedido:fgcolor in frame {&frame-name} = 12.

        end.
        if not avail ordem-compra then do:
            assign int_ds_it_docto_xml.numero_ordem :fgcolor in frame {&frame-name} = 12.
            assign int_ds_it_docto_xml.num_pedido :fgcolor in frame {&frame-name} = 12.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_it_docto_xml.num_pedido
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_it_docto_xml.num_pedido V-table-Win
ON LEAVE OF int_ds_it_docto_xml.num_pedido IN FRAME f-main /* Pedido */
DO:

    assign int_ds_it_docto_xml.numero_ordem:screen-value in FRAME f-Main = "".
    for first ordem-compra fields (num-pedido qt-solic pre-unit-for valor-descto numero-ordem) no-lock where 
        ordem-compra.num-pedido = input FRAME f-Main int_ds_it_docto_xml.num_pedido and
        ordem-compra.it-codigo = input FRAME f-Main int_ds_it_docto_xml.it_codigo
        query-tuning(no-lookahead):
        assign  int_ds_it_docto_xml.numero_ordem:screen-value in frame {&frame-name} = string(ordem-compra.numero-ordem).
    end.

  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_it_docto_xml.qCom_forn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_it_docto_xml.qCom_forn V-table-Win
ON LEAVE OF int_ds_it_docto_xml.qCom_forn IN FRAME f-main /* Qtde Fornec */
DO:
    for first int_ds_docto_xml no-lock where rowid(int_ds_docto_xml) = v-row-parent
        query-tuning(no-lookahead): 
        
        de-fator = 0.
        if int_ds_it_docto_xml.tipo_nota <> 3 /* transferencia */ and
           not can-find (first estabelec no-lock where estabelec.cod-emitente = int_ds_it_docto_xml.cod_emitente) then do:


            RUN retornaIndiceConversao in h-boin176 (input int_ds_it_docto_xml.it_codigo:screen-value in frame {&FRAME-NAME},
                                                     input int_ds_docto_xml.cod_emitente,
                                                     input int_ds_it_docto_xml.uCom_forn:screen-value in frame {&FRAME-NAME},
                                                     output de-fator). 

            /*RUN pi-retorna-Indice-Conversao (input int_ds_it_docto_xml.it_codigo:screen-value in frame {&FRAME-NAME},
                                             input int_ds_docto_xml.cod_emitente,
                                             input int_ds_it_docto_xml.uCom_forn:screen-value in frame {&FRAME-NAME},
                                             output de-fator).*/
        end.
        if de-fator = 0 or de-fator = ? then assign de-fator = 1. 
        
    end.

    ASSIGN int_ds_it_docto_xml.qCom:screen-value in frame {&FRAME-NAME} = string(ROUND(input frame {&frame-name} int_ds_it_docto_xml.qCom_forn / de-fator,0)).

    ASSIGN int_ds_it_docto_xml.vProd:screen-value in frame {&FRAME-NAME}  = 
        string((input FRAME {&FRAME-NAME} int_ds_it_docto_xml.vUnCom) * 
               (input FRAME {&FRAME-NAME} int_ds_it_docto_xml.qCom_forn)).
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_it_docto_xml.vProd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_it_docto_xml.vProd V-table-Win
ON LEAVE OF int_ds_it_docto_xml.vProd IN FRAME f-main /* Vlr Total */
DO:
    assign int_ds_it_docto_xml.vUnCom:screen-value in frame f-Main = 
        string(int_ds_it_docto_xml.vProd:input-value in frame f-Main /  
                int_ds_it_docto_xml.qCom_forn:input-value in frame f-Main).  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_it_docto_xml.vUnCom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_it_docto_xml.vUnCom V-table-Win
ON LEAVE OF int_ds_it_docto_xml.vUnCom IN FRAME f-main /* Vlr Unit Forn */
DO:
  /*
    assign int_ds_it_docto_xml.vProd:screen-value in frame f-Main = 
        string(int_ds_it_docto_xml.vUnCom:input-value in frame f-Main * 
                int_ds_it_docto_xml.qCom_forn:input-value in frame f-Main).
    */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
  &ENDIF         
  
  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-find-using-key V-table-Win  adm/support/_key-fnd.p
PROCEDURE adm-find-using-key :
/*------------------------------------------------------------------------------
  Purpose:     Finds the current record using the contents of
               the 'Key-Name' and 'Key-Value' attributes.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* No Foreign keys are accepted by this SmartObject. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
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

  /* Create a list of all the tables that we need to get.            */
  {src/adm/template/row-list.i "int_ds_it_docto_xml"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_it_docto_xml"}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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
  HIDE FRAME f-main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record V-table-Win 
PROCEDURE local-assign-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

    DEF VAR c-nat-operacao AS CHAR NO-UNDO.
    DEF VAR i-familia      AS INT  NO-UNDO.

    /* Code placed here will execute PRIOR to standard behavior. */
    {include/i-valid.i}
    
    /*:T Ponha na pi-validate todas as validaá‰es */
    /*:T N∆o gravar nada no registro antes do dispatch do assign-record e 
       nem na PI-validate. */
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .
    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.
    
    IF  AVAIL INT_ds_docto_xml
    AND AVAIL INT_ds_it_docto_xml THEN DO:

        ASSIGN c-nat-operacao = ""
               i-familia      = ?.

        FIND FIRST ITEM WHERE
                   ITEM.it-codigo = int_ds_it_docto_xml.it_codigo NO-LOCK NO-ERROR.
        IF AVAIL ITEM THEN
           ASSIGN i-familia = INT(ITEM.fm-codigo).

        RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                              input int_ds_it_docto_xml.cst_icms,
                              input i-familia,
                              input int_ds_docto_xml.cod_estab,
                              input int_ds_docto_xml.cod_emitente,
                              OUTPUT c-nat-operacao).

        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,   
                                 input ?,
                                 input i-familia,
                                 input int_ds_docto_xml.cod_estab,
                                 input int_ds_docto_xml.cod_emitente,
                                 OUTPUT c-nat-operacao).
                                       
        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input int_ds_it_docto_xml.cst_icms,
                                 input ?,
                                 input int_ds_docto_xml.cod_estab,
                                 input int_ds_docto_xml.cod_emitente,
                                 OUTPUT c-nat-operacao).
                                                        
        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input int_ds_it_docto_xml.cst_icms,
                                 input i-familia,
                                 input ?,
                                 input int_ds_docto_xml.cod_emitente,
                                 OUTPUT c-nat-operacao).

        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input int_ds_it_docto_xml.cst_icms,
                                 input i-familia,
                                 input int_ds_docto_xml.cod_estab,
                                 input ?,
                                 OUTPUT c-nat-operacao).                                                      

        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input ?,
                                 input ?,
                                 input int_ds_docto_xml.cod_estab,
                                 input int_ds_docto_xml.cod_emitente,
                                 OUTPUT c-nat-operacao).
        
        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input ?,
                                 input i-familia,
                                 input ?,
                                 input int_ds_docto_xml.cod_emitente,
                                 OUTPUT c-nat-operacao).

        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input int_ds_it_docto_xml.cst_icms,
                                 input ?,
                                 input ?,
                                 input int_ds_docto_xml.cod_emitente,
                                 OUTPUT c-nat-operacao).
                                                     
        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input ?,
                                 input i-familia,
                                 input int_ds_docto_xml.cod_estab,
                                 input ?,
                                 OUTPUT c-nat-operacao).
                                                      
        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input int_ds_it_docto_xml.cst_icms,
                                 input ?,
                                 input int_ds_docto_xml.cod_estab,
                                 input ?,
                                 OUTPUT c-nat-operacao).
                                                      
        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input int_ds_it_docto_xml.cst_icms,
                                 input i-familia,
                                 input ?,
                                 input ?,
                                 OUTPUT c-nat-operacao).                                                        

        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input ?,
                                 input ?,
                                 input ?,
                                 input int_ds_docto_xml.cod_emitente,
                                 OUTPUT c-nat-operacao).
 
        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input ?,
                                 input ?,
                                 input int_ds_docto_xml.cod_estab,
                                 input ?               ,
                                 OUTPUT c-nat-operacao).
                                                     
        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input ?,
                                 input i-familia,
                                 input ?,
                                 input ?,
                                 OUTPUT c-nat-operacao).
                                       
        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input int_ds_it_docto_xml.cst_icms,
                                 input ?,
                                 input ?,
                                 input ?,
                                 OUTPUT c-nat-operacao).

        if c-nat-operacao = "" then
           RUN pi-busca-natureza(input int_ds_it_docto_xml.cfop,
                                 input ?,
                                 input ?,
                                 input ?,
                                 input ?,
                                 OUTPUT c-nat-operacao).

        IF c-nat-operacao <> "" THEN DO:
           IF c-nat-operacao <> INT_ds_it_docto_xml.nat_operacao THEN DO:
              run utp/ut-msgs.p(input "show",
                                input 27979,
                                input ("Natureza de Operaá∆o divergente." + "~~" + "A Natureza de Operaá∆o do Item: " + INT_ds_it_docto_xml.nat_operacao + 
                                       " est† divergente do cadastro (INT013): " + c-nat-operacao)).
           END.
        END.
    END.
    /*:T Todos os assignÔs n∆o feitos pelo assign-record devem ser feitos aqui */  
    /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-create-record V-table-Win 
PROCEDURE local-create-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
    define buffer bint_ds_it_docto_xml for int_ds_it_docto_xml.

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'create-record':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  for first int_ds_docto_xml where rowid(int_ds_docto_xml) = v-row-parent
      query-tuning(no-lookahead):
      assign   int_ds_it_docto_xml.cod_emitente  = int_ds_docto_xml.cod_emitente
               int_ds_it_docto_xml.tipo_nota  = int_ds_docto_xml.tipo_nota
               int_ds_it_docto_xml.CNPJ       = int_ds_docto_xml.CNPJ     
               int_ds_it_docto_xml.nNF        = int_ds_docto_xml.nNF      
               int_ds_it_docto_xml.serie      = int_ds_docto_xml.serie.
      for last bint_ds_it_docto_xml no-lock where 
         bint_ds_it_docto_xml.tipo_nota  = int_ds_docto_xml.tipo_nota and 
         bint_ds_it_docto_xml.CNPJ       = int_ds_docto_xml.CNPJ      and 
         bint_ds_it_docto_xml.nNF        = int_ds_docto_xml.nNF       and 
         bint_ds_it_docto_xml.serie      = int_ds_docto_xml.serie
          query-tuning(no-lookahead):
          assign int_ds_it_docto_xml.sequencia:screen-value in frame f-Main = 
              trim(string(bint_ds_it_docto_xml.sequencia + 10,">>>>99")).
          assign int_ds_it_docto_xml.sequencia = bint_ds_it_docto_xml.sequencia + 10.
      end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-disable-fields V-table-Win 
PROCEDURE local-disable-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
    
    /* Code placed here will execute PRIOR to standard behavior. */
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'disable-fields':U ) .
    
    /* Code placed here will execute AFTER standard behavior.    */
    &if  defined(ADM-MODIFY-FIELDS) &then
    disable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
    &endif
    IF VALID-HANDLE(h-boin176) then DELETE PROCEDURE h-boin176.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-enable-fields V-table-Win 
PROCEDURE local-enable-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/


    /* Code placed here will execute PRIOR to standard behavior. */
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'enable-fields':U ) .
    
    /* Code placed here will execute AFTER standard behavior.    */
    &if  defined(ADM-MODIFY-FIELDS) &then
    if adm-new-record = yes then
        enable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
    &endif
    RUN inbo/boin176.p PERSISTENT SET h-boin176. /*  calcula fator de convers∆o */
    if avail int_ds_docto_xml and
       int_ds_it_docto_xml.num_pedido:screen-value in frame f-main = "" or
       int_ds_it_docto_xml.num_pedido:screen-value in frame f-main = "0" then do:
        assign int_ds_it_docto_xml.num_pedido:screen-value in frame f-main = string(int_ds_it_docto_xml.num_pedido).
    end.
    if int_ds_it_docto_xml.it_codigo:screen-value in FRAME {&FRAME-NAME} <> "" then do:
        apply "leave":u to int_ds_it_docto_xml.it_codigo in frame f-main.
        apply "leave":u to int_ds_it_docto_xml.num_pedido in frame f-main.
        apply "leave":u to int_ds_it_docto_xml.numero_ordem in frame f-main.
        /*apply "leave":u to int_ds_it_docto_xml.qCom_forn in frame f-main.*/
    end. 
    if not can-find (first usuar_grp_usuar no-lock where 
                     usuar_grp_usuar.cod_grp_usuar = "ZZZ":U and
                     usuar_grp_usuar.cod_usuario = c-seg-usuario) then do:
        RUN pi-busca-docto-wms.
        if i-sit-re >= 10 and i-sit-re <> 60 then do:
    
            assign  int_ds_it_docto_xml.qCom     :sensitive in frame f-Main = no 
                    int_ds_it_docto_xml.qCom_forn:sensitive in frame f-Main = no  
                    int_ds_it_docto_xml.uCom     :sensitive in frame f-Main = no
                    int_ds_it_docto_xml.uCom_forn:sensitive in frame f-Main = no.
            
            if i-sit-re = 40 then do:
                assign 
                    int_ds_it_docto_xml.vUnCom      :sensitive in frame f-Main = no
                    int_ds_it_docto_xml.vDesc       :sensitive in frame f-Main = no
                    int_ds_it_docto_xml.vProd       :sensitive in frame f-Main = no.
            end.                                    
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualiza-parent V-table-Win 
PROCEDURE pi-atualiza-parent :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter v-row-parent-externo as rowid no-undo.
    
    assign v-row-parent = v-row-parent-externo.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-busca-docto-wms V-table-Win 
PROCEDURE pi-busca-docto-wms :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
     if avail int_ds_docto_xml then do:
          i-sit-re = 0.
          for first int_ds_docto_wms fields (situacao datamovimentacao_d) no-lock where 
              int_ds_docto_wms.doc_numero_n = int_ds_docto_xml.nNF and
              int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie and
              int_ds_docto_wms.cnpj_cpf     = int_ds_docto_xml.CNPJ
              query-tuning(no-lookahead): 
              assign i-sit-re = int_ds_docto_wms.situacao.
          end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-busca-natureza V-table-Win 
PROCEDURE pi-busca-natureza :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define input  parameter i-cfop          LIKE int_ds_it_docto_xml.cfop      NO-UNDO.
    define input  parameter i-cst-icms      LIKE int_ds_it_docto_xml.cst_icms  NO-UNDO.
    define input  parameter i-familia       AS INT                             NO-UNDO.
    define input  parameter c-cod-estabel   LIKE int_ds_docto_xml.cod_estab    NO-UNDO.
    define input  parameter i-cod-emitente  LIKE int_ds_docto_xml.cod_emitente NO-UNDO.
    DEFINE OUTPUT PARAMETER c-nat-operacao  AS CHAR NO-UNDO.

    for LAST int_ds_cfop_natur_oper no-lock USE-INDEX cfop where 
             int_ds_cfop_natur_oper.nen_cfop_n     = i-cfop        and
             int_ds_cfop_natur_oper.nep_cstb_icm_n = i-cst-icms    and
             int_ds_cfop_natur_oper.nep_cstb_ipi_n = i-familia     and
             int_ds_cfop_natur_oper.cod_estabel    = c-cod-estabel and
             int_ds_cfop_natur_oper.cod_emitente   = i-cod-emitente:
    end.    
    IF AVAIL int_ds_cfop_natur_oper THEN
       assign c-nat-operacao = int_ds_cfop_natur_oper.nat_operacao.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-retorna-indice-conversao V-table-Win 
PROCEDURE pi-retorna-indice-conversao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define input  param pc-item         like item-doc-est.it-codigo  no-undo.
    define input  param pi-emitente     like emitente.cod-emitente   no-undo.
    define input  param p-un-fornec     like item-doc-est.un         no-undo.
    define output param p-de-indice     as decimal                   no-undo.

    define variable de-indice as decimal no-undo.
    if not avail item then
        find item no-lock where item.it-codigo = pc-item no-error.
    
    if not avail item then return.

    find first param-compra no-lock no-error.

    if  item.it-codigo <> "" and item.it-codigo <> ? then 
        find item-fornec 
            where item-fornec.it-codigo    = item.it-codigo 
              and item-fornec.cod-emitente = pi-emitente            
              and item-fornec.ativo        = yes
            no-lock no-error.

    if  available item-fornec then do:
        if avail param-compra 
             and param-compra.log-multi-unid-medid
             and item-fornec.unid-med-for <> p-un-fornec then do:
            /*Utiliza M£ltiplas Unidades de Medida
            Se unidade da item-fornec <> unidade da cotaá∆o, busca fator de convers∆o conforme a unidade da cotaá∆o*/
            FOR FIRST item-fornec-umd FIELDS(fator-conver num-casa-dec)
                WHERE item-fornec-umd.it-codigo = item-fornec.it-codigo
                  AND item-fornec-umd.cod-emitente = item-fornec.cod-emitente
                  AND item-fornec-umd.unid-med-for = p-un-fornec
                  AND item-fornec-umd.log-ativo no-lock query-tuning(no-lookahead): end.
            IF AVAIL item-fornec-umd THEN
                assign de-indice = item-fornec-umd.fator-conver / 
                                   if  item-fornec-umd.num-casa-dec = 0 then 1
                                   else exp(10,item-fornec-umd.num-casa-dec).
            else 
                assign de-indice = 1.
        end.
        else
            assign de-indice = item-fornec.fator-conver / 
                               if  item-fornec.num-casa-dec = 0 then 1
                               else exp(10,item-fornec.num-casa-dec).   
    end.
    else do:
        find tab-conv-un 
            where tab-conv-un.un           = item.un      
              and tab-conv-un.unid-med-for = ( if avail cotacao-item
                                               and p-un-fornec = " "   then
                                                  cotacao-item.un
                                               else p-un-fornec )
                 no-lock no-error.

        if available tab-conv-un then do:
            assign de-indice = tab-conv-un.fator-conver /
                               if tab-conv-un.num-casa-dec = 0 then 1
                               else exp(10,tab-conv-un.num-casa-dec). 
        end.
        else 
            assign de-indice = 1.

    end.
       
    assign p-de-indice = de-indice.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Pi-validate V-table-Win 
PROCEDURE Pi-validate :
/*:T------------------------------------------------------------------------------
  Purpose:Validar a viewer     
  Parameters:  <none>
  Notes: N∆o fazer assign aqui. Nesta procedure
  devem ser colocadas apenas validaá‰es, pois neste ponto do programa o registro 
  ainda n∆o foi criado.       
------------------------------------------------------------------------------*/
    {include/i-vldfrm.i} /*:T Validaá∆o de dicion†rio */
    
/*:T    Segue um exemplo de validaá∆o de programa */
/*       find tabela where tabela.campo1 = c-variavel and               */
/*                         tabela.campo2 > i-variavel no-lock no-error. */
      
      /*:T Este include deve ser colocado sempre antes do ut-msgs.p */
/*       {include/i-vldprg.i}                                             */
/*       run utp/ut-msgs.p (input "show":U, input 7, input return-value). */
/*       return 'ADM-ERROR':U.                                            */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-key V-table-Win  adm/support/_key-snd.p
PROCEDURE send-key :
/*------------------------------------------------------------------------------
  Purpose:     Sends a requested KEY value back to the calling
               SmartObject.
  Parameters:  <see adm/template/sndkytop.i>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/sndkytop.i}

  /* Return the key value associated with each key case.             */
  {src/adm/template/sndkycas.i "sequencia" "int_ds_it_docto_xml" "sequencia"}

  /* Close the CASE statement and end the procedure.                 */
  {src/adm/template/sndkyend.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "int_ds_it_docto_xml"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

