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
&Scoped-define INTERNAL-TABLES tt-int_ds_it_docto_xml

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table tt-int_ds_it_docto_xml.sequencia ~
tt-int_ds_it_docto_xml.it_codigo tt-int_ds_it_docto_xml.item_do_forn ~
tt-int_ds_it_docto_xml.xProd tt-int_ds_it_docto_xml.nat_operacao ~
tt-int_ds_it_docto_xml.l-divergente @ tt-int_ds_it_docto_xml.l-divergente ~
tt-int_ds_it_docto_xml.ncm ~
tt-int_ds_it_docto_xml.i-class-fiscal @ tt-int_ds_it_docto_xml.i-class-fiscal ~
tt-int_ds_it_docto_xml.qCom tt-int_ds_it_docto_xml.qCom_forn ~
tt-int_ds_it_docto_xml.uCom tt-int_ds_it_docto_xml.uCom_forn ~
tt-int_ds_it_docto_xml.vUnCom tt-int_ds_it_docto_xml.vDesc ~
tt-int_ds_it_docto_xml.vOutro tt-int_ds_it_docto_xml.vProd ~
tt-int_ds_it_docto_xml.vbc_icms ~
fn-base-icm() @ tt-int_ds_it_docto_xml.de-base-icm-calc ~
tt-int_ds_it_docto_xml.predBc ~
tt-int_ds_it_docto_xml.de-per-red-bc-calc @ tt-int_ds_it_docto_xml.de-per-red-bc-calc ~
tt-int_ds_it_docto_xml.picms ~
tt-int_ds_it_docto_xml.de-aliq-icms @ tt-int_ds_it_docto_xml.de-aliq-icms ~
tt-int_ds_it_docto_xml.vicms ~
tt-int_ds_it_docto_xml.de-valor-icms-cad @ tt-int_ds_it_docto_xml.de-valor-icms-cad ~
tt-int_ds_it_docto_xml.vicmsdeson tt-int_ds_it_docto_xml.vbcst ~
tt-int_ds_it_docto_xml.de-base-st-calc @ tt-int_ds_it_docto_xml.de-base-st-calc ~
tt-int_ds_it_docto_xml.pmvast ~
tt-int_ds_it_docto_xml.de-per-sub-tri @ tt-int_ds_it_docto_xml.de-per-sub-tri ~
tt-int_ds_it_docto_xml.vPMC ~
tt-int_ds_it_docto_xml.de-tabela-pauta @ tt-int_ds_it_docto_xml.de-tabela-pauta ~
tt-int_ds_it_docto_xml.picmsst ~
tt-int_ds_it_docto_xml.de-perc-st-calc @ tt-int_ds_it_docto_xml.de-perc-st-calc ~
tt-int_ds_it_docto_xml.de-perc-va-st @ tt-int_ds_it_docto_xml.de-perc-va-st ~
tt-int_ds_it_docto_xml.vicmsst ~
tt-int_ds_it_docto_xml.de-valor-st-calc @ tt-int_ds_it_docto_xml.de-valor-st-calc ~
tt-int_ds_it_docto_xml.vbc_pis fn-base-pis() @ de-base-pis-cad ~
tt-int_ds_it_docto_xml.ppis ~
tt-int_ds_it_docto_xml.de-aliq-pis @ tt-int_ds_it_docto_xml.de-aliq-pis ~
tt-int_ds_it_docto_xml.vpis ~
tt-int_ds_it_docto_xml.de-valor-pis-cad @ tt-int_ds_it_docto_xml.de-valor-pis-cad ~
tt-int_ds_it_docto_xml.vbc_cofins fn-base-cofins() @ de-base-cofins-cad ~
tt-int_ds_it_docto_xml.pcofins ~
tt-int_ds_it_docto_xml.de-aliq-cofins @ tt-int_ds_it_docto_xml.de-aliq-cofins ~
tt-int_ds_it_docto_xml.vcofins ~
tt-int_ds_it_docto_xml.de-valor-cofins-cad @ tt-int_ds_it_docto_xml.de-valor-cofins-cad ~
tt-int_ds_it_docto_xml.vbc_ipi de-base-ipi-cad @ de-base-ipi-cad ~
tt-int_ds_it_docto_xml.pipi ~
tt-int_ds_it_docto_xml.de-aliq-ipi @ tt-int_ds_it_docto_xml.de-aliq-ipi ~
tt-int_ds_it_docto_xml.vipi ~
tt-int_ds_it_docto_xml.de-valor-ipi-cad @ tt-int_ds_it_docto_xml.de-valor-ipi-cad ~
tt-int_ds_it_docto_xml.de-total-nf @ tt-int_ds_it_docto_xml.de-total-nf ~
tt-int_ds_it_docto_xml.de-total-cad @ tt-int_ds_it_docto_xml.de-total-cad ~
tt-int_ds_it_docto_xml.demi @ tt-int_ds_it_docto_xml.demi ~
tt-int_ds_it_docto_xml.nNF tt-int_ds_it_docto_xml.serie ~
tt-int_ds_it_docto_xml.cod_emitente ~
tt-int_ds_it_docto_xml.c-nome-emit @ tt-int_ds_it_docto_xml.c-nome-emit ~
tt-int_ds_it_docto_xml.c-uf-emit @ tt-int_ds_it_docto_xml.c-uf-emit ~
tt-int_ds_it_docto_xml.chnfe @ tt-int_ds_it_docto_xml.chnfe 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table 
&Scoped-define QUERY-STRING-br-table FOR EACH tt-int_ds_it_docto_xml NO-LOCK
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH tt-int_ds_it_docto_xml NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-table tt-int_ds_it_docto_xml
&Scoped-define FIRST-TABLE-IN-QUERY-br-table tt-int_ds_it_docto_xml


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
      tt-int_ds_it_docto_xml SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      tt-int_ds_it_docto_xml.sequencia FORMAT ">>>,>>9":U WIDTH 6.43
      tt-int_ds_it_docto_xml.it_codigo FORMAT "x(16)":U WIDTH 6.43
      tt-int_ds_it_docto_xml.item_do_forn FORMAT "x(60)":U WIDTH 10.43
      tt-int_ds_it_docto_xml.xProd FORMAT "x(60)":U WIDTH 45.43
      tt-int_ds_it_docto_xml.nat_operacao FORMAT "x(6)":U
      tt-int_ds_it_docto_xml.l-divergente @ tt-int_ds_it_docto_xml.l-divergente COLUMN-LABEL "Divergente" FORMAT "Sim/N∆o":U
            WIDTH 8 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.ncm COLUMN-LABEL "NCM NF" FORMAT ">>>>>>>9":U
            WIDTH 8
      tt-int_ds_it_docto_xml.i-class-fiscal @ tt-int_ds_it_docto_xml.i-class-fiscal COLUMN-LABEL "NCM Cad" FORMAT ">>>>>>>9":U
            WIDTH 8 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.qCom COLUMN-LABEL "Qtd" FORMAT ">>>>,>>>,>>9.99999":U
            WIDTH 11.43
      tt-int_ds_it_docto_xml.qCom_forn COLUMN-LABEL "Qtd For" FORMAT ">>>>,>>>,>>9.99":U
            WIDTH 9.43
      tt-int_ds_it_docto_xml.uCom FORMAT "x(03)":U
      tt-int_ds_it_docto_xml.uCom_forn COLUMN-LABEL "UN For" FORMAT "x(03)":U
      tt-int_ds_it_docto_xml.vUnCom FORMAT ">>>,>>9.99":U WIDTH 8
      tt-int_ds_it_docto_xml.vDesc COLUMN-LABEL "Vlr Desc" FORMAT ">>>,>>9.99":U
            WIDTH 8
      tt-int_ds_it_docto_xml.vOutro COLUMN-LABEL "Vlr Despesas" FORMAT ">>>,>>9.99":U
            WIDTH 9
      tt-int_ds_it_docto_xml.vProd COLUMN-LABEL "Vlr Total Prod" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12
      tt-int_ds_it_docto_xml.vbc_icms COLUMN-LABEL "Base ICMS NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      fn-base-icm() @ tt-int_ds_it_docto_xml.de-base-icm-calc COLUMN-LABEL "Base ICMS Cad" FORMAT ">>>,>>>,>>9.99":U
            LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.predBc COLUMN-LABEL "% Red BC NF" FORMAT ">>9.9999":U
            LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-per-red-bc-calc @ tt-int_ds_it_docto_xml.de-per-red-bc-calc COLUMN-LABEL "% Red BC Cad" FORMAT ">>9.99":U
            LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.picms COLUMN-LABEL "% ICMS NF" FORMAT ">>9.99":U
            LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-aliq-icms @ tt-int_ds_it_docto_xml.de-aliq-icms COLUMN-LABEL "% ICMS Cad" FORMAT ">>9.99":U
            LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.vicms COLUMN-LABEL "Vl ICMS NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-valor-icms-cad @ tt-int_ds_it_docto_xml.de-valor-icms-cad COLUMN-LABEL "Vl ICMS Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.vicmsdeson COLUMN-LABEL "Vl ICMS Deson NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.vbcst COLUMN-LABEL "Base ST NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-base-st-calc @ tt-int_ds_it_docto_xml.de-base-st-calc COLUMN-LABEL "Base ST Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.pmvast COLUMN-LABEL "% MVA NF" FORMAT ">>>9.99":U
            LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-per-sub-tri @ tt-int_ds_it_docto_xml.de-per-sub-tri COLUMN-LABEL "%MVA Cad" FORMAT ">>9.99":U
            WIDTH 8 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.vPMC COLUMN-LABEL "Vl PMC NF" FORMAT ">>>,>>9.99":U
      tt-int_ds_it_docto_xml.de-tabela-pauta @ tt-int_ds_it_docto_xml.de-tabela-pauta COLUMN-LABEL "Vl PMC Cad" FORMAT ">>>,>>9.99":U
            WIDTH 10.29 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.picmsst COLUMN-LABEL "% ST NF" FORMAT ">>9.99":U
            LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-perc-st-calc @ tt-int_ds_it_docto_xml.de-perc-st-calc COLUMN-LABEL "% ST Cad" FORMAT ">>9.99":U
            WIDTH 9 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.de-perc-va-st @ tt-int_ds_it_docto_xml.de-perc-va-st COLUMN-LABEL "% Red Cad" FORMAT ">>>9.99":U
            LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.vicmsst COLUMN-LABEL "Valor ST NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-valor-st-calc @ tt-int_ds_it_docto_xml.de-valor-st-calc COLUMN-LABEL "Valor ST Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.vbc_pis COLUMN-LABEL "Base PIS NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      fn-base-pis() @ de-base-pis-cad COLUMN-LABEL "Base Pis Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.ppis COLUMN-LABEL "% PIS NF" FORMAT ">>9.99":U
            LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-aliq-pis @ tt-int_ds_it_docto_xml.de-aliq-pis COLUMN-LABEL "% PIS Cad" FORMAT ">>9.99":U
            LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.vpis COLUMN-LABEL "Valor PIS NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-valor-pis-cad @ tt-int_ds_it_docto_xml.de-valor-pis-cad COLUMN-LABEL "Valor PIS Cad" FORMAT ">>>,>>>,>>9.99":U
            LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.vbc_cofins COLUMN-LABEL "Base Cofins NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      fn-base-cofins() @ de-base-cofins-cad COLUMN-LABEL "Base Cofins Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.pcofins COLUMN-LABEL "% Cofins NF" FORMAT ">>9.99":U
            LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-aliq-cofins @ tt-int_ds_it_docto_xml.de-aliq-cofins COLUMN-LABEL "% COFINS Cad" FORMAT ">>9.99":U
            LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.vcofins COLUMN-LABEL "Valor Cofins NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-valor-cofins-cad @ tt-int_ds_it_docto_xml.de-valor-cofins-cad COLUMN-LABEL "Valor COFINS Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.vbc_ipi COLUMN-LABEL "Base IPI NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      de-base-ipi-cad @ de-base-ipi-cad COLUMN-LABEL "Base IPI Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.pipi COLUMN-LABEL "% IPI NF" FORMAT ">>9.99":U
            LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-aliq-ipi @ tt-int_ds_it_docto_xml.de-aliq-ipi COLUMN-LABEL "% IPI Cad" FORMAT ">>9.99":U
            LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.vipi COLUMN-LABEL "Valor IPI NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-valor-ipi-cad @ tt-int_ds_it_docto_xml.de-valor-ipi-cad COLUMN-LABEL "Valor IPI Cad" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 2
      tt-int_ds_it_docto_xml.de-total-nf @ tt-int_ds_it_docto_xml.de-total-nf COLUMN-LABEL "Total NF" FORMAT ">>>,>>>,>>9.99":U
            WIDTH 12 LABEL-FGCOLOR 9
      tt-int_ds_it_docto_xml.de-total-cad @ tt-int_ds_it_docto_xml.de-total-cad COLUMN-LABEL "Total Cad" FORMAT ">>>,>>>,>>9.99":U
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
     _TblList          = "Temp-Tables.tt-int_ds_it_docto_xml"
     _Options          = "NO-LOCK"
     _FldNameList[1]   > Temp-Tables.tt-int_ds_it_docto_xml.sequencia
"tt-int_ds_it_docto_xml.sequencia" ? ? "integer" ? ? ? ? ? ? no ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-int_ds_it_docto_xml.it_codigo
"tt-int_ds_it_docto_xml.it_codigo" ? ? "character" ? ? ? ? ? ? no ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-int_ds_it_docto_xml.item_do_forn
"tt-int_ds_it_docto_xml.item_do_forn" ? ? "character" ? ? ? ? ? ? no ? no no "10.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-int_ds_it_docto_xml.xProd
"tt-int_ds_it_docto_xml.xProd" ? ? "character" ? ? ? ? ? ? no ? no no "45.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   = Temp-Tables.tt-int_ds_it_docto_xml.nat_operacao
     _FldNameList[6]   > "_<CALC>"
"tt-int_ds_it_docto_xml.l-divergente @ tt-int_ds_it_docto_xml.l-divergente" "Divergente" "Sim/N∆o" ? ? ? ? ? 2 ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > Temp-Tables.tt-int_ds_it_docto_xml.ncm
"tt-int_ds_it_docto_xml.ncm" "NCM NF" ? "integer" ? ? ? ? ? ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > "_<CALC>"
"tt-int_ds_it_docto_xml.i-class-fiscal @ tt-int_ds_it_docto_xml.i-class-fiscal" "NCM Cad" ">>>>>>>9" ? ? ? ? ? 2 ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > Temp-Tables.tt-int_ds_it_docto_xml.qCom
"tt-int_ds_it_docto_xml.qCom" "Qtd" ? "decimal" ? ? ? ? ? ? no ? no no "11.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > Temp-Tables.tt-int_ds_it_docto_xml.qCom_forn
"tt-int_ds_it_docto_xml.qCom_forn" "Qtd For" ? "decimal" ? ? ? ? ? ? no ? no no "9.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   = Temp-Tables.tt-int_ds_it_docto_xml.uCom
     _FldNameList[12]   > Temp-Tables.tt-int_ds_it_docto_xml.uCom_forn
"tt-int_ds_it_docto_xml.uCom_forn" "UN For" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[13]   > Temp-Tables.tt-int_ds_it_docto_xml.vUnCom
"tt-int_ds_it_docto_xml.vUnCom" ? ">>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[14]   > Temp-Tables.tt-int_ds_it_docto_xml.vDesc
"tt-int_ds_it_docto_xml.vDesc" "Vlr Desc" ">>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[15]   > Temp-Tables.tt-int_ds_it_docto_xml.vOutro
"tt-int_ds_it_docto_xml.vOutro" "Vlr Despesas" ">>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[16]   > Temp-Tables.tt-int_ds_it_docto_xml.vProd
"tt-int_ds_it_docto_xml.vProd" "Vlr Total Prod" ">>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[17]   > Temp-Tables.tt-int_ds_it_docto_xml.vbc_icms
"tt-int_ds_it_docto_xml.vbc_icms" "Base ICMS NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[18]   > "_<CALC>"
"fn-base-icm() @ tt-int_ds_it_docto_xml.de-base-icm-calc" "Base ICMS Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[19]   > Temp-Tables.tt-int_ds_it_docto_xml.predBc
"tt-int_ds_it_docto_xml.predBc" "% Red BC NF" ? "decimal" ? ? ? ? 9 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[20]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-per-red-bc-calc @ tt-int_ds_it_docto_xml.de-per-red-bc-calc" "% Red BC Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[21]   > Temp-Tables.tt-int_ds_it_docto_xml.picms
"tt-int_ds_it_docto_xml.picms" "% ICMS NF" ? "decimal" ? ? ? ? 9 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[22]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-aliq-icms @ tt-int_ds_it_docto_xml.de-aliq-icms" "% ICMS Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[23]   > Temp-Tables.tt-int_ds_it_docto_xml.vicms
"tt-int_ds_it_docto_xml.vicms" "Vl ICMS NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[24]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-valor-icms-cad @ tt-int_ds_it_docto_xml.de-valor-icms-cad" "Vl ICMS Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[25]   > Temp-Tables.tt-int_ds_it_docto_xml.vicmsdeson
"tt-int_ds_it_docto_xml.vicmsdeson" "Vl ICMS Deson NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[26]   > Temp-Tables.tt-int_ds_it_docto_xml.vbcst
"tt-int_ds_it_docto_xml.vbcst" "Base ST NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[27]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-base-st-calc @ tt-int_ds_it_docto_xml.de-base-st-calc" "Base ST Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[28]   > Temp-Tables.tt-int_ds_it_docto_xml.pmvast
"tt-int_ds_it_docto_xml.pmvast" "% MVA NF" ? "decimal" ? ? ? ? 9 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[29]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-per-sub-tri @ tt-int_ds_it_docto_xml.de-per-sub-tri" "%MVA Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[30]   > Temp-Tables.tt-int_ds_it_docto_xml.vPMC
"tt-int_ds_it_docto_xml.vPMC" "Vl PMC NF" ">>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[31]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-tabela-pauta @ tt-int_ds_it_docto_xml.de-tabela-pauta" "Vl PMC Cad" ">>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "10.29" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[32]   > Temp-Tables.tt-int_ds_it_docto_xml.picmsst
"tt-int_ds_it_docto_xml.picmsst" "% ST NF" ? "decimal" ? ? ? ? 9 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[33]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-perc-st-calc @ tt-int_ds_it_docto_xml.de-perc-st-calc" "% ST Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[34]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-perc-va-st @ tt-int_ds_it_docto_xml.de-perc-va-st" "% Red Cad" ">>>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[35]   > Temp-Tables.tt-int_ds_it_docto_xml.vicmsst
"tt-int_ds_it_docto_xml.vicmsst" "Valor ST NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[36]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-valor-st-calc @ tt-int_ds_it_docto_xml.de-valor-st-calc" "Valor ST Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[37]   > Temp-Tables.tt-int_ds_it_docto_xml.vbc_pis
"tt-int_ds_it_docto_xml.vbc_pis" "Base PIS NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[38]   > "_<CALC>"
"fn-base-pis() @ de-base-pis-cad" "Base Pis Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[39]   > Temp-Tables.tt-int_ds_it_docto_xml.ppis
"tt-int_ds_it_docto_xml.ppis" "% PIS NF" ? "decimal" ? ? ? ? 9 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[40]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-aliq-pis @ tt-int_ds_it_docto_xml.de-aliq-pis" "% PIS Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[41]   > Temp-Tables.tt-int_ds_it_docto_xml.vpis
"tt-int_ds_it_docto_xml.vpis" "Valor PIS NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[42]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-valor-pis-cad @ tt-int_ds_it_docto_xml.de-valor-pis-cad" "Valor PIS Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[43]   > Temp-Tables.tt-int_ds_it_docto_xml.vbc_cofins
"tt-int_ds_it_docto_xml.vbc_cofins" "Base Cofins NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[44]   > "_<CALC>"
"fn-base-cofins() @ de-base-cofins-cad" "Base Cofins Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[45]   > Temp-Tables.tt-int_ds_it_docto_xml.pcofins
"tt-int_ds_it_docto_xml.pcofins" "% Cofins NF" ? "decimal" ? ? ? ? 9 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[46]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-aliq-cofins @ tt-int_ds_it_docto_xml.de-aliq-cofins" "% COFINS Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[47]   > Temp-Tables.tt-int_ds_it_docto_xml.vcofins
"tt-int_ds_it_docto_xml.vcofins" "Valor Cofins NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[48]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-valor-cofins-cad @ tt-int_ds_it_docto_xml.de-valor-cofins-cad" "Valor COFINS Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[49]   > Temp-Tables.tt-int_ds_it_docto_xml.vbc_ipi
"tt-int_ds_it_docto_xml.vbc_ipi" "Base IPI NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[50]   > "_<CALC>"
"de-base-ipi-cad @ de-base-ipi-cad" "Base IPI Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[51]   > Temp-Tables.tt-int_ds_it_docto_xml.pipi
"tt-int_ds_it_docto_xml.pipi" "% IPI NF" ? "decimal" ? ? ? ? 9 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[52]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-aliq-ipi @ tt-int_ds_it_docto_xml.de-aliq-ipi" "% IPI Cad" ">>9.99" ? ? ? ? ? 2 ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[53]   > Temp-Tables.tt-int_ds_it_docto_xml.vipi
"tt-int_ds_it_docto_xml.vipi" "Valor IPI NF" ">>>,>>>,>>9.99" "decimal" ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[54]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-valor-ipi-cad @ tt-int_ds_it_docto_xml.de-valor-ipi-cad" "Valor IPI Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[55]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-total-nf @ tt-int_ds_it_docto_xml.de-total-nf" "Total NF" ">>>,>>>,>>9.99" ? ? ? ? ? 9 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[56]   > "_<CALC>"
"tt-int_ds_it_docto_xml.de-total-cad @ tt-int_ds_it_docto_xml.de-total-cad" "Total Cad" ">>>,>>>,>>9.99" ? ? ? ? ? 2 ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[57]   > "_<CALC>"
"tt-int_ds_it_docto_xml.demi @ tt-int_ds_it_docto_xml.demi" "Emiss∆o" "99/99/9999" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[58]   > Temp-Tables.tt-int_ds_it_docto_xml.nNF
"tt-int_ds_it_docto_xml.nNF" "NF" ? "character" ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[59]   = Temp-Tables.tt-int_ds_it_docto_xml.serie
     _FldNameList[60]   > Temp-Tables.tt-int_ds_it_docto_xml.cod_emitente
"tt-int_ds_it_docto_xml.cod_emitente" ? ? "integer" ? ? ? ? ? ? no ? no no "9" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[61]   > "_<CALC>"
"tt-int_ds_it_docto_xml.c-nome-emit @ tt-int_ds_it_docto_xml.c-nome-emit" "Nome Fornecedor" "x(60)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[62]   > "_<CALC>"
"tt-int_ds_it_docto_xml.c-uf-emit @ tt-int_ds_it_docto_xml.c-uf-emit" "UF" "x(03)" ? ? ? ? ? ? ? no ? no no "4" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[63]   > "_<CALC>"
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

    if tt-int_ds_it_docto_xml.uCom_forn = "" or
       tt-int_ds_it_docto_xml.uCom_forn = ? or
       trim(string(tt-int_ds_it_docto_xml.uCom_forn)) = "?" then
        tt-int_ds_it_docto_xml.uCom_forn:bgcolor in browse br-table = 14.
    else 
        tt-int_ds_it_docto_xml.uCom_forn:bgcolor in browse br-table = ?.

    if tt-int_ds_it_docto_xml.uCom = "" or
       tt-int_ds_it_docto_xml.uCom = ? or
       trim(string(tt-int_ds_it_docto_xml.uCom)) = "?" then
        tt-int_ds_it_docto_xml.uCom:bgcolor in browse br-table = 14.
    else 
        tt-int_ds_it_docto_xml.uCom:bgcolor in browse br-table = ?.

    IF  (tt-int_ds_it_docto_xml.vpmc - tt-int_ds_it_docto_xml.de-tabela-pauta >  de-valor-dif-aceita  OR
         tt-int_ds_it_docto_xml.vpmc - tt-int_ds_it_docto_xml.de-tabela-pauta < (de-valor-dif-aceita * -1))
    THEN
        ASSIGN tt-int_ds_it_docto_xml.vpmc           :BGCOLOR IN BROWSE br-table = 14
               tt-int_ds_it_docto_xml.de-tabela-pauta:BGCOLOR IN BROWSE br-table = 14.

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


    IF tt-int_ds_it_docto_xml.de-tabela-pauta > 0 THEN
        ASSIGN tt-int_ds_it_docto_xml.de-per-sub-tri = 0.        
    IF  tt-int_ds_it_docto_xml.pmvast <> tt-int_ds_it_docto_xml.de-per-sub-tri     
    THEN   /* kleber */
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

    IF  (tt-int_ds_it_docto_xml.de-total-nf - tt-int_ds_it_docto_xml.de-total-cad >  de-valor-dif-aceita  OR
         tt-int_ds_it_docto_xml.de-total-nf - tt-int_ds_it_docto_xml.de-total-cad < (de-valor-dif-aceita * -1))
    THEN
        ASSIGN tt-int_ds_it_docto_xml.de-total-nf :BGCOLOR IN BROWSE br-table = 14 
               tt-int_ds_it_docto_xml.de-total-cad:BGCOLOR IN BROWSE br-table = 14.
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
                tt-int_ds_it_docto_xml.qCom_forn    :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.qCom_forn    ) 
                tt-int_ds_it_docto_xml.uCom         :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.uCom         ) 
                tt-int_ds_it_docto_xml.uCom_forn    :screen-value in browse br-table = string(tt-int_ds_it_docto_xml.uCom_forn    ) 
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

