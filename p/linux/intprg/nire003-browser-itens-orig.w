&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          custom           ORACLE
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int_ds_it_docto_xml NO-UNDO LIKE int_ds_it_docto_xml
       FIELD cod-estab          AS CHAR
       FIELD c-nome-emit        AS CHAR
       FIELD c-uf-emit          AS CHAR
       FIELD chnfe              AS CHAR
       FIELD demi               AS DATE
       FIELD de-aliq-pis        AS DEC
       FIELD de-aliq-cofins     AS DEC
       FIELD de-aliq-ipi        AS DEC
       FIELD de-aliq-icms       AS DEC
       FIELD de-base-icm-calc   AS DEC
       FIELD de-base-st-calc    AS DEC
       FIELD de-valor-st-calc   AS DEC
       FIELD de-perc-st-calc    AS DEC
       FIELD c-tabela-pauta     AS CHAR
       FIELD de-tabela-pauta    AS DEC
       FIELD de-per-sub-tri     AS DEC
       FIELD de-per-red-bc-calc AS DEC
       FIELD de-perc-va-st      AS DEC
       FIELD l-divergente       AS LOG
       FIELD de-valor-pis-cad    AS DEC
       FIELD de-valor-cofins-cad AS DEC
       FIELD de-valor-ipi-cad    AS DEC
       FIELD i-class-fiscal      AS int
       FIELD de-base-pis-calc    AS DEC
       FIELD de-total-nf         AS DEC
       FIELD de-total-cad        AS DEC
       FIELD de-valor-icms-cad   AS DEC.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS B-table-Win 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int510-browser-itens 1.12.00.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/browserd.w

/* Parameters Definitions ---                                           */
 
/* Local Variable Definitions ---                                       */

/*:T Variaveis usadas internamente pelo estilo, favor nao elimina-las     */

/*:T v†ri†veis de uso globla */
def  var v-row-parent    as rowid no-undo.

/*:T vari†veis de uso local */
def var v-row-table  as rowid no-undo.

DEFINE VARIABLE de-valor-dif-aceita AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-base-pis-cad     AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-base-cofins-cad  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-base-ipi-cad     AS DECIMAL     NO-UNDO.
/*:T fim das variaveis utilizadas no estilo */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE BrowserCadastro2
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int_ds_it_docto_xml ~
int_ds_it_docto_xml_orig

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table tt-int_ds_it_docto_xml.sequencia ~
tt-int_ds_it_docto_xml.it_codigo tt-int_ds_it_docto_xml.item_do_forn ~
tt-int_ds_it_docto_xml.xProd int_ds_it_docto_xml_orig.nat_operacao ~
tt-int_ds_it_docto_xml.nat_operacao ~
tt-int_ds_it_docto_xml.l-divergente @ tt-int_ds_it_docto_xml.l-divergente ~
int_ds_it_docto_xml_orig.ncm tt-int_ds_it_docto_xml.ncm ~
tt-int_ds_it_docto_xml.i-class-fiscal @ tt-int_ds_it_docto_xml.i-class-fiscal ~
int_ds_it_docto_xml_orig.qCom tt-int_ds_it_docto_xml.qCom ~
int_ds_it_docto_xml_orig.vUnCom ~
tt-int_ds_it_docto_xml.vuncom @ tt-int_ds_it_docto_xml.vuncom ~
int_ds_it_docto_xml_orig.vDesc ~
tt-int_ds_it_docto_xml.vdesc @ tt-int_ds_it_docto_xml.vdesc ~
int_ds_it_docto_xml_orig.vOutro ~
tt-int_ds_it_docto_xml.voutro @ tt-int_ds_it_docto_xml.voutro ~
int_ds_it_docto_xml_orig.vProd tt-int_ds_it_docto_xml.vProd ~
int_ds_it_docto_xml_orig.vbc_icms tt-int_ds_it_docto_xml.vbc_icms ~
fn-base-icm() @ tt-int_ds_it_docto_xml.de-base-icm-calc ~
int_ds_it_docto_xml_orig.predBc tt-int_ds_it_docto_xml.predBc ~
tt-int_ds_it_docto_xml.de-per-red-bc-calc @ tt-int_ds_it_docto_xml.de-per-red-bc-calc ~
int_ds_it_docto_xml_orig.picms tt-int_ds_it_docto_xml.picms ~
tt-int_ds_it_docto_xml.de-aliq-icms @ tt-int_ds_it_docto_xml.de-aliq-icms ~
int_ds_it_docto_xml_orig.vicms tt-int_ds_it_docto_xml.vicms ~
int_ds_it_docto_xml_orig.vicmsdeson ~
tt-int_ds_it_docto_xml.vicmsdeson @ tt-int_ds_it_docto_xml.vicmsdeson ~
int_ds_it_docto_xml_orig.vbcst tt-int_ds_it_docto_xml.vbcst ~
tt-int_ds_it_docto_xml.de-base-st-calc @ tt-int_ds_it_docto_xml.de-base-st-calc ~
int_ds_it_docto_xml_orig.pmvast tt-int_ds_it_docto_xml.pmvast ~
tt-int_ds_it_docto_xml.de-per-sub-tri @ tt-int_ds_it_docto_xml.de-per-sub-tri ~
int_ds_it_docto_xml_orig.picmsst tt-int_ds_it_docto_xml.picmsst ~
tt-int_ds_it_docto_xml.de-perc-st-calc @ tt-int_ds_it_docto_xml.de-perc-st-calc ~
tt-int_ds_it_docto_xml.de-perc-va-st @ tt-int_ds_it_docto_xml.de-perc-va-st ~
int_ds_it_docto_xml_orig.vicmsst tt-int_ds_it_docto_xml.vicmsst ~
tt-int_ds_it_docto_xml.de-valor-st-calc @ tt-int_ds_it_docto_xml.de-valor-st-calc ~
int_ds_it_docto_xml_orig.vbc_pis tt-int_ds_it_docto_xml.vbc_pis ~
fn-base-pis() @ de-base-pis-cad int_ds_it_docto_xml_orig.ppis ~
tt-int_ds_it_docto_xml.ppis ~
tt-int_ds_it_docto_xml.de-aliq-pis @ tt-int_ds_it_docto_xml.de-aliq-pis ~
int_ds_it_docto_xml_orig.vpis tt-int_ds_it_docto_xml.vpis ~
tt-int_ds_it_docto_xml.de-valor-pis-cad @ tt-int_ds_it_docto_xml.de-valor-pis-cad ~
int_ds_it_docto_xml_orig.vbc_cofins tt-int_ds_it_docto_xml.vbc_cofins ~
fn-base-cofins() @ de-base-cofins-cad int_ds_it_docto_xml_orig.pcofins ~
tt-int_ds_it_docto_xml.pcofins ~
tt-int_ds_it_docto_xml.de-aliq-cofins @ tt-int_ds_it_docto_xml.de-aliq-cofins ~
int_ds_it_docto_xml_orig.vcofins tt-int_ds_it_docto_xml.vcofins ~
tt-int_ds_it_docto_xml.de-valor-cofins-cad @ tt-int_ds_it_docto_xml.de-valor-cofins-cad ~
int_ds_it_docto_xml_orig.vbc_ipi tt-int_ds_it_docto_xml.vbc_ipi ~
de-base-ipi-cad @ de-base-ipi-cad int_ds_it_docto_xml_orig.pipi ~
tt-int_ds_it_docto_xml.pipi ~
tt-int_ds_it_docto_xml.de-aliq-ipi @ tt-int_ds_it_docto_xml.de-aliq-ipi ~
int_ds_it_docto_xml_orig.vipi tt-int_ds_it_docto_xml.vipi ~
tt-int_ds_it_docto_xml.de-valor-ipi-cad @ tt-int_ds_it_docto_xml.de-valor-ipi-cad ~
tt-int_ds_it_docto_xml.demi @ tt-int_ds_it_docto_xml.demi ~
tt-int_ds_it_docto_xml.nNF tt-int_ds_it_docto_xml.serie ~
tt-int_ds_it_docto_xml.cod_emitente ~
tt-int_ds_it_docto_xml.c-nome-emit @ tt-int_ds_it_docto_xml.c-nome-emit ~
tt-int_ds_it_docto_xml.c-uf-emit @ tt-int_ds_it_docto_xml.c-uf-emit ~
tt-int_ds_it_docto_xml.chnfe @ tt-int_ds_it_docto_xml.chnfe 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table 
&Scoped-define QUERY-STRING-br-table FOR EACH tt-int_ds_it_docto_xml NO-LOCK, ~
      FIRST int_ds_it_docto_xml_orig WHERE int_ds_it_docto_xml_orig.cod_emitente = tt-int_ds_it_docto_xml.cod_emitente ~
  AND int_ds_it_docto_xml_orig.serie = tt-int_ds_it_docto_xml.serie ~
  AND int_ds_it_docto_xml_orig.nNF = tt-int_ds_it_docto_xml.nNF ~
  AND int_ds_it_docto_xml_orig.tipo_nota = tt-int_ds_it_docto_xml.tipo_nota ~
  AND int_ds_it_docto_xml_orig.sequencia = tt-int_ds_it_docto_xml.sequencia NO-LOCK
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH tt-int_ds_it_docto_xml NO-LOCK, ~
      FIRST int_ds_it_docto_xml_orig WHERE int_ds_it_docto_xml_orig.cod_emitente = tt-int_ds_it_docto_xml.cod_emitente ~
  AND int_ds_it_docto_xml_orig.serie = tt-int_ds_it_docto_xml.serie ~
  AND int_ds_it_docto_xml_orig.nNF = tt-int_ds_it_docto_xml.nNF ~
  AND int_ds_it_docto_xml_orig.tipo_nota = tt-int_ds_it_docto_xml.tipo_nota ~
  AND int_ds_it_docto_xml_orig.sequencia = tt-int_ds_it_docto_xml.sequencia NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-table tt-int_ds_it_docto_xml ~
int_ds_it_docto_xml_orig
&Scoped-define FIRST-TABLE-IN-QUERY-br-table tt-int_ds_it_docto_xml
&Scoped-define SECOND-TABLE-IN-QUERY-br-table int_ds_it_docto_xml_orig


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br-table 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" B-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS
><EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Advanced Query Options" B-table-Win _INLINE
/* Actions: ? adm/support/advqedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<SORTBY-OPTIONS>
</SORTBY-OPTIONS>
<SORTBY-RUN-CODE>
************************
* Set attributes related to SORTBY-OPTIONS */
RUN set-attribute-list (
    'SortBy-Options = ""':U).
/************************
</SORTBY-RUN-CODE>
<FILTER-ATTRIBUTES>
************************
* Initialize Filter Attributes */
RUN set-attribute-list IN THIS-PROCEDURE ('
  Filter-Value=':U).
/************************
</FILTER-ATTRIBUTES> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-base-cofins B-table-Win 
FUNCTION fn-base-cofins RETURNS DECIMAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-base-icm B-table-Win 
FUNCTION fn-base-icm RETURNS DECIMAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-base-ipi B-table-Win 
FUNCTION fn-base-ipi RETURNS DECIMAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-base-pis B-table-Win 
FUNCTION fn-base-pis RETURNS DECIMAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      tt-int_ds_it_docto_xml, 
      int_ds_it_docto_xml_orig SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      tt-int_ds_it_docto_xml.sequencia FORMAT ">>>,>>9":U WIDTH 6.43
      tt-int_ds_it_docto_xml.it_codigo FORMAT "x(16)":U WIDTH 6.43
      tt-int_ds_it_docto_xml.item_do_forn FORMAT "x(60)":U WIDTH 10.43
      tt-int_ds_it_docto_xml.xProd FORMAT "x(60)":U WIDTH 45.43
      int_ds_it_docto_xml_orig.nat_operacao COLUMN-LABEL "Nat Orig"
            WIDTH 7 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.nat_operacao COLUMN-LABEL "Nat Atu" FORMAT "x(6)":U
      tt-int_ds_it_docto_xml.l-divergente @ tt-int_ds_it_docto_xml.l-divergente COLUMN-LABEL "Divergente" FORMAT "Sim/N∆o":U
            WIDTH 8 LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.ncm COLUMN-LABEL "NCM Orig" WIDTH 8
            LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.ncm COLUMN-LABEL "NCM Atu" FORMAT ">>>>>>>9":U
            WIDTH 8
      tt-int_ds_it_docto_xml.i-class-fiscal @ tt-int_ds_it_docto_xml.i-class-fiscal COLUMN-LABEL "NCM Cad" FORMAT ">>>>>>>9":U
            WIDTH 8 LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.qCom COLUMN-LABEL "Qtd Orig" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 11.43 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.qCom COLUMN-LABEL "Qtd Atu" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 11.43
      int_ds_it_docto_xml_orig.vUnCom COLUMN-LABEL "Vlr Unit Orig" FORMAT ">>>,>>9.99999":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vuncom @ tt-int_ds_it_docto_xml.vuncom COLUMN-LABEL "Vlr Unit Atu" FORMAT ">>>,>>9.99999":U
            WIDTH 12
      int_ds_it_docto_xml_orig.vDesc COLUMN-LABEL "Vlr Desc Orig" FORMAT ">>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vdesc @ tt-int_ds_it_docto_xml.vdesc COLUMN-LABEL "Vlr Desc Atu" FORMAT ">>>,>>9.99":U
            WIDTH 12
      int_ds_it_docto_xml_orig.vOutro COLUMN-LABEL "Vlr Desp Orig" FORMAT ">>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.voutro @ tt-int_ds_it_docto_xml.voutro COLUMN-LABEL "Vlr Desp Atu" FORMAT ">>>,>>9.99":U
            WIDTH 12
      int_ds_it_docto_xml_orig.vProd COLUMN-LABEL "Vlr Total Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vProd COLUMN-LABEL "Vlr Total Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      int_ds_it_docto_xml_orig.vbc_icms COLUMN-LABEL "Base ICMS Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vbc_icms COLUMN-LABEL "Base ICMS Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      fn-base-icm() @ tt-int_ds_it_docto_xml.de-base-icm-calc COLUMN-LABEL "Base ICMS Cad" FORMAT ">>>,>>>,>>9.99":U
            LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.predBc COLUMN-LABEL "% Red BC Orig"
            WIDTH 9.29 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.predBc COLUMN-LABEL "% Red BC Atu" FORMAT ">>9.9999":U
      tt-int_ds_it_docto_xml.de-per-red-bc-calc @ tt-int_ds_it_docto_xml.de-per-red-bc-calc COLUMN-LABEL "% Red BC Cad" FORMAT ">>9.99":U
            LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.picms COLUMN-LABEL "% ICMS Orig"
            WIDTH 7.72 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.picms COLUMN-LABEL "% ICMS Atu" FORMAT ">>9.99":U
      tt-int_ds_it_docto_xml.de-aliq-icms @ tt-int_ds_it_docto_xml.de-aliq-icms COLUMN-LABEL "% ICMS Cad" FORMAT ">>9.99":U
            LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.vicms COLUMN-LABEL "Vl ICMS Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vicms COLUMN-LABEL "Vl ICMS Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      int_ds_it_docto_xml_orig.vicmsdeson COLUMN-LABEL "Vl ICMS Deson Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 14 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vicmsdeson @ tt-int_ds_it_docto_xml.vicmsdeson COLUMN-LABEL "Vl ICMS Deson Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      int_ds_it_docto_xml_orig.vbcst COLUMN-LABEL "Base ST Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vbcst COLUMN-LABEL "Base ST Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      tt-int_ds_it_docto_xml.de-base-st-calc @ tt-int_ds_it_docto_xml.de-base-st-calc COLUMN-LABEL "Base ST Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.pmvast COLUMN-LABEL "% MVA Orig"
            WIDTH 7.29 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.pmvast COLUMN-LABEL "% MVA Atu" FORMAT ">>>9.99":U
      tt-int_ds_it_docto_xml.de-per-sub-tri @ tt-int_ds_it_docto_xml.de-per-sub-tri COLUMN-LABEL "%MVA Cad" FORMAT ">>9.99":U
            WIDTH 8 LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.picmsst COLUMN-LABEL "% ST Orig"
            WIDTH 6 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.picmsst COLUMN-LABEL "% ST Atu" FORMAT ">>9.99":U
      tt-int_ds_it_docto_xml.de-perc-st-calc @ tt-int_ds_it_docto_xml.de-perc-st-calc COLUMN-LABEL "% ST Cad" FORMAT ">>9.99":U
            WIDTH 9 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.de-perc-va-st @ tt-int_ds_it_docto_xml.de-perc-va-st COLUMN-LABEL "% Red Cad" FORMAT ">>>9.99":U
            LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.vicmsst COLUMN-LABEL "Valor ST Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vicmsst COLUMN-LABEL "Valor ST Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      tt-int_ds_it_docto_xml.de-valor-st-calc @ tt-int_ds_it_docto_xml.de-valor-st-calc COLUMN-LABEL "Valor ST Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.vbc_pis COLUMN-LABEL "Base PIS Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vbc_pis COLUMN-LABEL "Base PIS Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      fn-base-pis() @ de-base-pis-cad COLUMN-LABEL "Base Pis Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.ppis COLUMN-LABEL "% PIS Orig" WIDTH 6.43
            LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.ppis COLUMN-LABEL "% PIS Atu" FORMAT ">>9.99":U
      tt-int_ds_it_docto_xml.de-aliq-pis @ tt-int_ds_it_docto_xml.de-aliq-pis COLUMN-LABEL "% PIS Cad" FORMAT ">>9.99":U
            LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.vpis COLUMN-LABEL "Valor PIS Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vpis COLUMN-LABEL "Valor PIS Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      tt-int_ds_it_docto_xml.de-valor-pis-cad @ tt-int_ds_it_docto_xml.de-valor-pis-cad COLUMN-LABEL "Valor PIS Cad" FORMAT ">>>,>>>,>>9.99":U
            LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.vbc_cofins COLUMN-LABEL "Base Cofins Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vbc_cofins COLUMN-LABEL "Base Cofins Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      fn-base-cofins() @ de-base-cofins-cad COLUMN-LABEL "Base Cofins Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.pcofins COLUMN-LABEL "% Cofins Orig"
            WIDTH 8.14 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.pcofins COLUMN-LABEL "% Cofins Atu" FORMAT ">>9.99":U
      tt-int_ds_it_docto_xml.de-aliq-cofins @ tt-int_ds_it_docto_xml.de-aliq-cofins COLUMN-LABEL "% COFINS Cad" FORMAT ">>9.99":U
            LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.vcofins COLUMN-LABEL "Valor Cofins Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vcofins COLUMN-LABEL "Valor Cofins Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      tt-int_ds_it_docto_xml.de-valor-cofins-cad @ tt-int_ds_it_docto_xml.de-valor-cofins-cad COLUMN-LABEL "Valor COFINS Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.vbc_ipi COLUMN-LABEL "Base IPI Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vbc_ipi COLUMN-LABEL "Base IPI Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      de-base-ipi-cad @ de-base-ipi-cad COLUMN-LABEL "Base IPI Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.pipi COLUMN-LABEL "% IPI Orig" WIDTH 5.86
            LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.pipi COLUMN-LABEL "% IPI Atu" FORMAT ">>9.99":U
      tt-int_ds_it_docto_xml.de-aliq-ipi @ tt-int_ds_it_docto_xml.de-aliq-ipi COLUMN-LABEL "% IPI Cad" FORMAT ">>9.99":U
            LABEL-FGCOLOR 2
      int_ds_it_docto_xml_orig.vipi COLUMN-LABEL "Valor IPI Orig" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vipi COLUMN-LABEL "Valor IPI Atu" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      tt-int_ds_it_docto_xml.de-valor-ipi-cad @ tt-int_ds_it_docto_xml.de-valor-ipi-cad COLUMN-LABEL "Valor IPI Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.demi @ tt-int_ds_it_docto_xml.demi COLUMN-LABEL "Emiss∆o" FORMAT "99/99/9999":U
      tt-int_ds_it_docto_xml.nNF COLUMN-LABEL "NF" FORMAT "x(16)":U
            WIDTH 10
      tt-int_ds_it_docto_xml.serie FORMAT "x(5)":U
      tt-int_ds_it_docto_xml.cod_emitente FORMAT ">>>>>>>>9":U
            WIDTH 9
      tt-int_ds_it_docto_xml.c-nome-emit @ tt-int_ds_it_docto_xml.c-nome-emit COLUMN-LABEL "Nome Fornecedor" FORMAT "x(60)":U
      tt-int_ds_it_docto_xml.c-uf-emit @ tt-int_ds_it_docto_xml.c-uf-emit COLUMN-LABEL "UF" FORMAT "x(03)":U
            WIDTH 4
      tt-int_ds_it_docto_xml.chnfe @ tt-int_ds_it_docto_xml.chnfe COLUMN-LABEL "Chave NFE" FORMAT "x(60)":U
            WIDTH 45
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 142.57 BY 10.75
         FONT 1 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     br-table AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: BrowserCadastro2
   Allow: Basic,Browse
   Frames: 1
   Add Fields to: External-Tables
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int_ds_it_docto_xml T "?" NO-UNDO custom int_ds_it_docto_xml
      ADDITIONAL-FIELDS:
          FIELD cod-estab          AS CHAR
          FIELD c-nome-emit        AS CHAR
          FIELD c-uf-emit          AS CHAR
          FIELD chnfe              AS CHAR
          FIELD demi               AS DATE
          FIELD de-aliq-pis        AS DEC
          FIELD de-aliq-cofins     AS DEC
          FIELD de-aliq-ipi        AS DEC
          FIELD de-aliq-icms       AS DEC
          FIELD de-base-icm-calc   AS DEC
          FIELD de-base-st-calc    AS DEC
          FIELD de-valor-st-calc   AS DEC
          FIELD de-perc-st-calc    AS DEC
          FIELD c-tabela-pauta     AS CHAR
          FIELD de-tabela-pauta    AS DEC
          FIELD de-per-sub-tri     AS DEC
          FIELD de-per-red-bc-calc AS DEC
          FIELD de-perc-va-st      AS DEC
          FIELD l-divergente       AS LOG
          FIELD de-valor-pis-cad    AS DEC
          FIELD de-valor-cofins-cad AS DEC
          FIELD de-valor-ipi-cad    AS DEC
          FIELD i-class-fiscal      AS int
          FIELD de-base-pis-calc    AS DEC
          FIELD de-total-nf         AS DEC
          FIELD de-total-cad        AS DEC
          FIELD de-valor-icms-cad   AS DEC
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW B-table-Win ASSIGN
         HEIGHT             = 10.75
         WIDTH              = 142.57.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB B-table-Win 
/* ************************* Included-Libraries *********************** */

{utp/ut-glob.i}
{src/adm/method/browser.i}
/* {include/c-brows3.i} */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW B-table-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit L-To-R                            */
/* BROWSE-TAB br-table 1 F-Main */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN 
       br-table:NUM-LOCKED-COLUMNS IN FRAME F-Main     = 6
       br-table:COLUMN-RESIZABLE IN FRAME F-Main       = TRUE
       br-table:COLUMN-MOVABLE IN FRAME F-Main         = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "Temp-Tables.tt-int_ds_it_docto_xml,int_ds_it_docto_xml_orig WHERE Temp-Tables.tt-int_ds_it_docto_xml ..."
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST"
     _JoinCode[2]      = "int_ds_it_docto_xml_orig.cod_emitente = Temp-Tables.tt-int_ds_it_docto_xml.cod_emitente
  AND int_ds_it_docto_xml_orig.serie = Temp-Tables.tt-int_ds_it_docto_xml.serie
  AND int_ds_it_docto_xml_orig.nNF = Temp-Tables.tt-int_ds_it_docto_xml.nNF
  AND int_ds_it_docto_xml_orig.tipo_nota = Temp-Tables.tt-int_ds_it_docto_xml.tipo_nota
  AND int_ds_it_docto_xml_orig.sequencia = Temp-Tables.tt-int_ds_it_docto_xml.sequencia"
     _FldNameList[1]   > Temp-Tables.tt-int_ds_it_docto_xml.sequencia
"tt-int_ds_it_docto_xml.sequencia" ? ? "integer" ? ? ? ? ? ? no ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-int_ds_it_docto_xml.it_codigo
"tt-int_ds_it_docto_xml.it_codigo" ? ? "character" ? ? ? ? ? ? no ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-int_ds_it_docto_xml.item_do_forn
"tt-int_ds_it_docto_xml.item_do_forn" ? ? "character" ? ? ? ? ? ? no ? no no "10.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-int_ds_it_docto_xml.xProd
"tt-int_ds_it_docto_xml.xProd" ? ? "character" ? ? ? ? ? ? no ? no no "45.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"int_ds_it_docto_xml_orig.nat_operacao" "Nat Orig" ? "character" ? ? ? ? 9 ? no ? no no "7" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.tt-int_ds_it_docto_xml.nat_operacao
"tt-int_ds_it_docto_xml.nat_operacao" "Nat Atu" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > "_<CALC>"
"tt-int_ds_it_docto_xml.l-divergente @ tt-int_ds_it_docto_xml.l-divergente" "Divergente" "Sim/N∆o" ? ? ? ? ? 2 ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > "_<CALC>"
"int_ds_it_docto_xml_orig.ncm" "NCM Orig" ? "integer" ? ? ? ? 9 ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > Temp-Tables.tt-int_ds_it_docto_xml.ncm
"tt-int_ds_it_docto_xml.ncm" "NCM Atu" ? "integer" ? ? ? ? ? ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > "_<CALC>"
"tt-int_ds_it_docto_xml.i-class-fiscal @ tt-int_ds_it_docto_xml.i-class-fiscal" "NCM Cad" ">>>>>>>9" ? ? ? ? ? 2 ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > "_<CALC>"
"int_ds_it_docto_xml_orig.qCom" "Qtd Orig" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "11.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > Temp-Tables.tt-int_ds_it_docto_xml.qCom
"tt-int_ds_it_docto_xml.qCom" "Qtd Atu" ">>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "11.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   > custom.int_ds_it_docto_xml_orig.vUnCom
"int_ds_it_docto_xml_orig.vUnCom" "Vlr Unit Orig" ">>>,>>9.99999" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[14]   > "_<CALC>"
"tt-int_ds_it_docto_xml.vuncom @ tt-int_ds_it_docto_xml.vuncom" "Vlr Unit Atu" ">>>,>>9.99999" ? ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[15]   > custom.int_ds_it_docto_xml_orig.vDesc
"int_ds_it_docto_xml_orig.vDesc" "Vlr Desc Orig" ">>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[16]   > "_<CALC>"
"tt-int_ds_it_docto_xml.vdesc @ tt-int_ds_it_docto_xml.vdesc" "Vlr Desc Atu" ">>>,>>9.99" ? ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[17]   > custom.int_ds_it_docto_xml_orig.vOutro
"int_ds_it_docto_xml_orig.vOutro" "Vlr Desp Orig" ">>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[18]   > "_<CALC>"
"tt-int_ds_it_docto_xml.voutro @ tt-int_ds_it_docto_xml.voutro" "Vlr Desp Atu" ">>>,>>9.99" ? ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[19]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vProd" "Vlr Total Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[20]   > Temp-Tables.tt-int_ds_it_docto_xml.vProd
"tt-int_ds_it_docto_xml.vProd" "Vlr Total Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[21]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vbc_icms" "Base ICMS Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[22]   > Temp-Tables.tt-int_ds_it_docto_xml.vbc_icms
"tt-int_ds_it_docto_xml.vbc_icms" "Base ICMS Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[23]   > "_<CALC>"
"fn-base-icm() @ tt-int_ds_it_docto_xml.de-base-icm-calc" "Base ICMS Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[24]   > "_<CALC>"
"int_ds_it_docto_xml_orig.predBc" "% Red BC Orig" ? "decimal" ? ? ? ? 9 ? no ? no no "9.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[25]   > Temp-Tables.tt-int_ds_it_docto_xml.predBc
"tt-int_ds_it_docto_xml.predBc" "% Red BC Atu" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[26]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-per-red-bc-calc @ tt-int_ds_it_docto_xml.de-per-red-bc-calc" "% Red BC Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[27]   > "_<CALC>"
"int_ds_it_docto_xml_orig.picms" "% ICMS Orig" ? "decimal" ? ? ? ? 9 ? no ? no no "7.72" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[28]   > Temp-Tables.tt-int_ds_it_docto_xml.picms
"tt-int_ds_it_docto_xml.picms" "% ICMS Atu" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[29]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-aliq-icms @ tt-int_ds_it_docto_xml.de-aliq-icms" "% ICMS Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[30]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vicms" "Vl ICMS Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[31]   > Temp-Tables.tt-int_ds_it_docto_xml.vicms
"tt-int_ds_it_docto_xml.vicms" "Vl ICMS Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[32]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vicmsdeson" "Vl ICMS Deson Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "14" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[33]   > "_<CALC>"
"tt-int_ds_it_docto_xml.vicmsdeson @ tt-int_ds_it_docto_xml.vicmsdeson" "Vl ICMS Deson Atu" ">>>,>>>,>>9.99" ? ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[34]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vbcst" "Base ST Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[35]   > Temp-Tables.tt-int_ds_it_docto_xml.vbcst
"tt-int_ds_it_docto_xml.vbcst" "Base ST Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[36]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-base-st-calc @ tt-int_ds_it_docto_xml.de-base-st-calc" "Base ST Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[37]   > "_<CALC>"
"int_ds_it_docto_xml_orig.pmvast" "% MVA Orig" ? "decimal" ? ? ? ? 9 ? no ? no no "7.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[38]   > Temp-Tables.tt-int_ds_it_docto_xml.pmvast
"tt-int_ds_it_docto_xml.pmvast" "% MVA Atu" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[39]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-per-sub-tri @ tt-int_ds_it_docto_xml.de-per-sub-tri" "%MVA Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[40]   > "_<CALC>"
"int_ds_it_docto_xml_orig.picmsst" "% ST Orig" ? "decimal" ? ? ? ? 9 ? no ? no no "6" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[41]   > Temp-Tables.tt-int_ds_it_docto_xml.picmsst
"tt-int_ds_it_docto_xml.picmsst" "% ST Atu" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[42]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-perc-st-calc @ tt-int_ds_it_docto_xml.de-perc-st-calc" "% ST Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[43]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-perc-va-st @ tt-int_ds_it_docto_xml.de-perc-va-st" "% Red Cad" ">>>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[44]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vicmsst" "Valor ST Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[45]   > Temp-Tables.tt-int_ds_it_docto_xml.vicmsst
"tt-int_ds_it_docto_xml.vicmsst" "Valor ST Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[46]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-valor-st-calc @ tt-int_ds_it_docto_xml.de-valor-st-calc" "Valor ST Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[47]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vbc_pis" "Base PIS Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[48]   > Temp-Tables.tt-int_ds_it_docto_xml.vbc_pis
"tt-int_ds_it_docto_xml.vbc_pis" "Base PIS Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[49]   > "_<CALC>"
"fn-base-pis() @ de-base-pis-cad" "Base Pis Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[50]   > "_<CALC>"
"int_ds_it_docto_xml_orig.ppis" "% PIS Orig" ? "decimal" ? ? ? ? 9 ? no ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[51]   > Temp-Tables.tt-int_ds_it_docto_xml.ppis
"tt-int_ds_it_docto_xml.ppis" "% PIS Atu" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[52]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-aliq-pis @ tt-int_ds_it_docto_xml.de-aliq-pis" "% PIS Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[53]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vpis" "Valor PIS Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[54]   > Temp-Tables.tt-int_ds_it_docto_xml.vpis
"tt-int_ds_it_docto_xml.vpis" "Valor PIS Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[55]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-valor-pis-cad @ tt-int_ds_it_docto_xml.de-valor-pis-cad" "Valor PIS Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[56]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vbc_cofins" "Base Cofins Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[57]   > Temp-Tables.tt-int_ds_it_docto_xml.vbc_cofins
"tt-int_ds_it_docto_xml.vbc_cofins" "Base Cofins Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[58]   > "_<CALC>"
"fn-base-cofins() @ de-base-cofins-cad" "Base Cofins Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[59]   > "_<CALC>"
"int_ds_it_docto_xml_orig.pcofins" "% Cofins Orig" ? "decimal" ? ? ? ? 9 ? no ? no no "8.14" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[60]   > Temp-Tables.tt-int_ds_it_docto_xml.pcofins
"tt-int_ds_it_docto_xml.pcofins" "% Cofins Atu" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[61]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-aliq-cofins @ tt-int_ds_it_docto_xml.de-aliq-cofins" "% COFINS Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[62]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vcofins" "Valor Cofins Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[63]   > Temp-Tables.tt-int_ds_it_docto_xml.vcofins
"tt-int_ds_it_docto_xml.vcofins" "Valor Cofins Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[64]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-valor-cofins-cad @ tt-int_ds_it_docto_xml.de-valor-cofins-cad" "Valor COFINS Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[65]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vbc_ipi" "Base IPI Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[66]   > Temp-Tables.tt-int_ds_it_docto_xml.vbc_ipi
"tt-int_ds_it_docto_xml.vbc_ipi" "Base IPI Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[67]   > "_<CALC>"
"de-base-ipi-cad @ de-base-ipi-cad" "Base IPI Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[68]   > "_<CALC>"
"int_ds_it_docto_xml_orig.pipi" "% IPI Orig" ? "decimal" ? ? ? ? 9 ? no ? no no "5.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[69]   > Temp-Tables.tt-int_ds_it_docto_xml.pipi
"tt-int_ds_it_docto_xml.pipi" "% IPI Atu" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[70]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-aliq-ipi @ tt-int_ds_it_docto_xml.de-aliq-ipi" "% IPI Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[71]   > "_<CALC>"
"int_ds_it_docto_xml_orig.vipi" "Valor IPI Orig" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[72]   > Temp-Tables.tt-int_ds_it_docto_xml.vipi
"tt-int_ds_it_docto_xml.vipi" "Valor IPI Atu" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[73]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-valor-ipi-cad @ tt-int_ds_it_docto_xml.de-valor-ipi-cad" "Valor IPI Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[74]   > "_<CALC>"
"tt-int_ds_it_docto_xml.demi @ tt-int_ds_it_docto_xml.demi" "Emiss∆o" "99/99/9999" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[75]   > Temp-Tables.tt-int_ds_it_docto_xml.nNF
"tt-int_ds_it_docto_xml.nNF" "NF" ? "character" ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[76]   = Temp-Tables.tt-int_ds_it_docto_xml.serie
     _FldNameList[77]   > Temp-Tables.tt-int_ds_it_docto_xml.cod_emitente
"tt-int_ds_it_docto_xml.cod_emitente" ? ? "integer" ? ? ? ? ? ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[78]   > "_<CALC>"
"tt-int_ds_it_docto_xml.c-nome-emit @ tt-int_ds_it_docto_xml.c-nome-emit" "Nome Fornecedor" "x(60)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[79]   > "_<CALC>"
"tt-int_ds_it_docto_xml.c-uf-emit @ tt-int_ds_it_docto_xml.c-uf-emit" "UF" "x(03)" ? ? ? ? ? ? ? no ? no no "4" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[80]   > "_<CALC>"
"tt-int_ds_it_docto_xml.chnfe @ tt-int_ds_it_docto_xml.chnfe" "Chave NFE" "x(60)" ? ? ? ? ? ? ? no ? no no "45" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-DISPLAY OF br-table IN FRAME F-Main
DO:
    ASSIGN de-base-ipi-cad = fn-base-ipi().

    IF  tt-int_ds_it_docto_xml.l-divergente = YES
    THEN
        ASSIGN tt-int_ds_it_docto_xml.l-divergente:BGCOLOR IN BROWSE br-table = 14.

    IF  tt-int_ds_it_docto_xml.ncm <> tt-int_ds_it_docto_xml.i-class-fiscal
    THEN
        ASSIGN tt-int_ds_it_docto_xml.ncm           :BGCOLOR IN BROWSE br-table = 14
               tt-int_ds_it_docto_xml.i-class-fiscal:BGCOLOR IN BROWSE br-table = 14.

    IF   tt-int_ds_it_docto_xml.de-aliq-icms                                      <> 0                    AND
        (tt-int_ds_it_docto_xml.vbc_icms - tt-int_ds_it_docto_xml.de-base-icm-calc >  de-valor-dif-aceita  OR
         tt-int_ds_it_docto_xml.vbc_icms - tt-int_ds_it_docto_xml.de-base-icm-calc < (de-valor-dif-aceita * -1))
    THEN
        ASSIGN tt-int_ds_it_docto_xml.vbc_icms        :BGCOLOR IN BROWSE br-table = 14
               tt-int_ds_it_docto_xml.de-base-icm-calc:BGCOLOR IN BROWSE br-table = 14.

    IF  tt-int_ds_it_docto_xml.picms <> tt-int_ds_it_docto_xml.de-aliq-icms  
    THEN
        ASSIGN tt-int_ds_it_docto_xml.picms       :BGCOLOR IN BROWSE br-table = 14
               tt-int_ds_it_docto_xml.de-aliq-icms:BGCOLOR IN BROWSE br-table = 14.

    IF  tt-int_ds_it_docto_xml.predBc <> tt-int_ds_it_docto_xml.de-per-red-bc-calc  
    THEN
        ASSIGN tt-int_ds_it_docto_xml.predBc            :BGCOLOR IN BROWSE br-table = 14 
               tt-int_ds_it_docto_xml.de-per-red-bc-calc:BGCOLOR IN BROWSE br-table = 14.

    IF  tt-int_ds_it_docto_xml.vbcst - tt-int_ds_it_docto_xml.de-base-st-calc >  de-valor-dif-aceita OR     
        tt-int_ds_it_docto_xml.vbcst - tt-int_ds_it_docto_xml.de-base-st-calc < (de-valor-dif-aceita * -1)
    THEN
        ASSIGN tt-int_ds_it_docto_xml.vbcst          :BGCOLOR IN BROWSE br-table = 14 
               tt-int_ds_it_docto_xml.de-base-st-calc:BGCOLOR IN BROWSE br-table = 14.

    IF  tt-int_ds_it_docto_xml.picmsst <> tt-int_ds_it_docto_xml.de-perc-st-calc  
    THEN
        ASSIGN tt-int_ds_it_docto_xml.picmsst        :BGCOLOR IN BROWSE br-table = 14 
               tt-int_ds_it_docto_xml.de-perc-st-calc:BGCOLOR IN BROWSE br-table = 14.

    IF  tt-int_ds_it_docto_xml.vicmsst - tt-int_ds_it_docto_xml.de-valor-st-calc >  de-valor-dif-aceita OR   
        tt-int_ds_it_docto_xml.vicmsst - tt-int_ds_it_docto_xml.de-valor-st-calc < (de-valor-dif-aceita * -1)
    THEN
        ASSIGN tt-int_ds_it_docto_xml.vicmsst         :BGCOLOR IN BROWSE br-table = 14 
               tt-int_ds_it_docto_xml.de-valor-st-calc:BGCOLOR IN BROWSE br-table = 14.

    IF  tt-int_ds_it_docto_xml.pmvast <> tt-int_ds_it_docto_xml.de-per-sub-tri     
    THEN
        ASSIGN tt-int_ds_it_docto_xml.pmvast        :BGCOLOR IN BROWSE br-table = 14 
               tt-int_ds_it_docto_xml.de-per-sub-tri:BGCOLOR IN BROWSE br-table = 14.


    IF  tt-int_ds_it_docto_xml.ppis <> 0
    THEN DO:
        IF  tt-int_ds_it_docto_xml.ppis <> tt-int_ds_it_docto_xml.de-aliq-pis
        THEN
            ASSIGN tt-int_ds_it_docto_xml.ppis       :BGCOLOR IN BROWSE br-table = 14 
                   tt-int_ds_it_docto_xml.de-aliq-pis:BGCOLOR IN BROWSE br-table = 14.

        IF  tt-int_ds_it_docto_xml.vbc_pis - tt-int_ds_it_docto_xml.de-base-pis-calc >  de-valor-dif-aceita OR
            tt-int_ds_it_docto_xml.vbc_pis - tt-int_ds_it_docto_xml.de-base-pis-calc < (de-valor-dif-aceita * -1)
        THEN
            ASSIGN tt-int_ds_it_docto_xml.vbc_pis:BGCOLOR IN BROWSE br-table = 14 
                   de-base-pis-cad               :BGCOLOR IN BROWSE br-table = 14.

        IF  tt-int_ds_it_docto_xml.vpis - tt-int_ds_it_docto_xml.de-valor-pis-cad >  de-valor-dif-aceita OR
            tt-int_ds_it_docto_xml.vpis - tt-int_ds_it_docto_xml.de-valor-pis-cad < (de-valor-dif-aceita * -1)
        THEN
            ASSIGN tt-int_ds_it_docto_xml.vpis            :BGCOLOR IN BROWSE br-table = 14 
                   tt-int_ds_it_docto_xml.de-valor-pis-cad:BGCOLOR IN BROWSE br-table = 14.
    END.


    IF  tt-int_ds_it_docto_xml.pcofins <> 0
    THEN DO:
        IF  tt-int_ds_it_docto_xml.pcofins <> tt-int_ds_it_docto_xml.de-aliq-cofins
        THEN
            ASSIGN tt-int_ds_it_docto_xml.pcofins       :BGCOLOR IN BROWSE br-table = 14 
                   tt-int_ds_it_docto_xml.de-aliq-cofins:BGCOLOR IN BROWSE br-table = 14.

        IF  tt-int_ds_it_docto_xml.vbc_cofins - tt-int_ds_it_docto_xml.de-base-pis-calc >  de-valor-dif-aceita OR
            tt-int_ds_it_docto_xml.vbc_cofins - tt-int_ds_it_docto_xml.de-base-pis-calc < (de-valor-dif-aceita * -1)
        THEN
            ASSIGN tt-int_ds_it_docto_xml.vbc_cofins:BGCOLOR IN BROWSE br-table = 14 
                   de-base-cofins-cad               :BGCOLOR IN BROWSE br-table = 14.

        IF  tt-int_ds_it_docto_xml.vcofins - tt-int_ds_it_docto_xml.de-valor-cofins-cad >  de-valor-dif-aceita OR
            tt-int_ds_it_docto_xml.vcofins - tt-int_ds_it_docto_xml.de-valor-cofins-cad < (de-valor-dif-aceita * -1)
        THEN
            ASSIGN tt-int_ds_it_docto_xml.vcofins            :BGCOLOR IN BROWSE br-table = 14 
                   tt-int_ds_it_docto_xml.de-valor-cofins-cad:BGCOLOR IN BROWSE br-table = 14.
    END.


    IF  tt-int_ds_it_docto_xml.pipi        <> 0 OR 
        tt-int_ds_it_docto_xml.de-aliq-ipi <> 0 
    THEN DO:
        IF  tt-int_ds_it_docto_xml.pipi <> tt-int_ds_it_docto_xml.de-aliq-ipi
        THEN
            ASSIGN tt-int_ds_it_docto_xml.pipi       :BGCOLOR IN BROWSE br-table = 14 
                   tt-int_ds_it_docto_xml.de-aliq-ipi:BGCOLOR IN BROWSE br-table = 14.

        IF  tt-int_ds_it_docto_xml.vbc_ipi - de-base-ipi-cad >  de-valor-dif-aceita OR
            tt-int_ds_it_docto_xml.vbc_ipi - de-base-ipi-cad < (de-valor-dif-aceita * -1)
        THEN
            ASSIGN tt-int_ds_it_docto_xml.vbc_ipi:BGCOLOR IN BROWSE br-table = 14 
                   de-base-ipi-cad               :BGCOLOR IN BROWSE br-table = 14.
    
        IF  tt-int_ds_it_docto_xml.vipi - tt-int_ds_it_docto_xml.de-valor-ipi-cad >  de-valor-dif-aceita OR
            tt-int_ds_it_docto_xml.vipi - tt-int_ds_it_docto_xml.de-valor-ipi-cad < (de-valor-dif-aceita * -1)
        THEN
            ASSIGN tt-int_ds_it_docto_xml.vipi            :BGCOLOR IN BROWSE br-table = 14 
                   tt-int_ds_it_docto_xml.de-valor-ipi-cad:BGCOLOR IN BROWSE br-table = 14.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-ENTRY OF br-table IN FRAME F-Main
DO:
  /* This code displays initial values for newly added or copied rows. */
/*   {src/adm/template/brsentry.i} */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON VALUE-CHANGED OF br-table IN FRAME F-Main
DO:
  /* This ADM trigger code must be preserved in order to notify other
     objects when the browser's current row changes. */
/*   {src/adm/template/brschnge.i} */
  /* run new-state('New-Line|':U + string(rowid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}))). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK B-table-Win 


/* ***************************  Main Block  *************************** */

ASSIGN de-valor-dif-aceita = 0.
FOR FIRST cst_param_estoq NO-LOCK:
    ASSIGN de-valor-dif-aceita = cst_param_estoq.de_valor_dif_aceita_impto.
END.

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN    
      
RUN dispatch IN THIS-PROCEDURE ('initialize':U). 


&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available B-table-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI B-table-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-row-available B-table-Win 
PROCEDURE local-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'row-available':U ) .

  apply "LEAVE":U to browse br-table.
  assign browse br-table:read-only = yes.
  RUN pi-refresh.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-view B-table-Win 
PROCEDURE local-view :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'view':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  apply 'value-changed':U to {&browse-name} in frame {&frame-name}.

  /* compras n∆o pode alterar documento */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-itens-nf B-table-Win 
PROCEDURE pi-itens-nf :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEF INPUT PARAM TABLE FOR tt-int_ds_it_docto_xml.

    {&OPEN-QUERY-br-table}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-refresh B-table-Win 
PROCEDURE pi-refresh :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    def var i-ind as integer no-undo.
    if br-table:num-entries in frame {&frame-name} > 0 then
    do i-ind = 1 to browse br-table:NUM-ENTRIES:
        browse br-table:SELECT-ROW(i-ind).
        browse br-table:FETCH-SELECTED-ROW(1).
        if avail tt-int_ds_it_docto_xml then do:
            assign 
                tt-int_ds_it_docto_xml.pcofins      :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.pcofins      )
                tt-int_ds_it_docto_xml.picms        :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.picms        )
                tt-int_ds_it_docto_xml.pipi         :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.pipi         )
                tt-int_ds_it_docto_xml.pmvast       :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.pmvast       ) 
                tt-int_ds_it_docto_xml.ppis         :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.ppis         ) 
                tt-int_ds_it_docto_xml.predBc       :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.predBc       ) 
                tt-int_ds_it_docto_xml.qCom         :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.qCom         ) 
                tt-int_ds_it_docto_xml.vProd        :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.vProd        ) 
                tt-int_ds_it_docto_xml.xProd        :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.xProd        ).
            apply "row-display" to br-table.
        end.
    end.
                              
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records B-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-int_ds_it_docto_xml"}
  {src/adm/template/snd-list.i "int_ds_it_docto_xml_orig"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed B-table-Win 
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
      {src/adm/template/bstates.i}
  END CASE.
/*   run pi-trata-state (p-issuer-hdl, p-state). */

  IF  p-state = "record-available"
  THEN
      RUN pi-refresh.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-base-cofins B-table-Win 
FUNCTION fn-base-cofins RETURNS DECIMAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    if  tt-int_ds_it_docto_xml.pcofins <> 0 
    then 
        RETURN tt-int_ds_it_docto_xml.de-base-pis-calc.

    RETURN 0.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-base-icm B-table-Win 
FUNCTION fn-base-icm RETURNS DECIMAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    if  tt-int_ds_it_docto_xml.de-aliq-icms <> 0 
    then 
        RETURN tt-int_ds_it_docto_xml.de-base-icm-calc.

    RETURN 0.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-base-ipi B-table-Win 
FUNCTION fn-base-ipi RETURNS DECIMAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    if  tt-int_ds_it_docto_xml.de-aliq-ipi <> 0 
    then 
        RETURN tt-int_ds_it_docto_xml.de-base-pis-calc.

    RETURN 0.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-base-pis B-table-Win 
FUNCTION fn-base-pis RETURNS DECIMAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    if  tt-int_ds_it_docto_xml.ppis <> 0 
    then 
        RETURN tt-int_ds_it_docto_xml.de-base-pis-calc.

    RETURN 0.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

