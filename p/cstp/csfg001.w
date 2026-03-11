&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

{system/Error.i}
{system/InstanceManagerDef.i}

/* Parameters Definitions ---                                           */
define input parameter numeroLote as integer no-undo.

define new shared variable v_rec_finalid_econ as recid    no-undo.

/* Local Variable Definitions ---                                       */

define variable lote as handle    no-undo.
define variable lancamento as handle    no-undo.
define variable item as handle    no-undo.
define variable apropriacao as handle    no-undo.

define variable dataLote as date      no-undo.
define variable situacao as character no-undo.
define variable ultimaClassificacao as character no-undo.

define temp-table ttItem no-undo
    like item_lancto_ctbl
    field nomeEstabelecimento as character.

define temp-table ttLancamento no-undo
    like item_lancto_ctbl
    field nomeEstabelecimento as character.

define temp-table ttRateio no-undo
    like cst_rateio_lojas
    field valor as decimal.

define temp-table ttAlterado no-undo
    field num_lote_ctbl       like item_lancto_ctbl.num_lote_ctbl
    field num_lancto_ctbl     like item_lancto_ctbl.num_lancto_ctbl
    field num_seq_lancto_ctbl like item_lancto_ctbl.num_seq_lancto_ctbl
    index id num_lote_ctbl      
             num_lancto_ctbl    
             num_seq_lancto_ctbl.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME brFiscal

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttLancamento ttItem

/* Definitions for BROWSE brFiscal                                      */
&Scoped-define FIELDS-IN-QUERY-brFiscal ttLancamento.num_lancto_ctbl ttLancamento.num_seq_lancto_ctbl ttLancamento.ind_natur_lancto_ctbl ttLancamento.cod_estab ttLancamento.nomeEstabelecimento ttLancamento.cod_plano_cta_ctbl ttLancamento.cod_cta_ctbl ttLancamento.cod_plano_ccusto ttLancamento.cod_ccusto ttLancamento.dat_lancto_ctbl ttLancamento.val_lancto_ctbl ttLancamento.des_histor_lancto_ctbl ttLancamento.ind_sit_lancto_ctbl   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brFiscal   
&Scoped-define SELF-NAME brFiscal
&Scoped-define QUERY-STRING-brFiscal FOR EACH ttLancamento       WHERE ttLancamento.num_lote_ctbl = 2 and ttLancamento.num_lancto_ctbl >= lancamentoIni:input-value and ttLancamento.num_lancto_ctbl <= lancamentoFim:input-value and ttLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value and ttLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value and ttLancamento.val_lancto_ctbl >= valorContabilIni:input-value and ttLancamento.val_lancto_ctbl <= valorContabilFim:input-value and ttLancamento.cod_cta_ctbl >= contaContabilIni:input-value and ttLancamento.cod_cta_ctbl <= contaContabilFim:input-value and ttLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value and ttLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value and ttLancamento.cod_ccusto >= centroCustoIni:input-value and ttLancamento.cod_ccusto <= centroCustoFim:input-value and ttLancamento.cod_estab >= estabelecimentoIni:input-value and ttLancamento.cod_estab <= estabelecimentoFim:input-value and (lookup(titulo:input-value, ~
       ttLancamento.des_histor_lancto_ctbl, ~
       ' ') > 0  or titulo:input-value = '') no-lock
&Scoped-define OPEN-QUERY-brFiscal OPEN QUERY {&SELF-NAME} FOR EACH ttLancamento       WHERE ttLancamento.num_lote_ctbl = 2 and ttLancamento.num_lancto_ctbl >= lancamentoIni:input-value and ttLancamento.num_lancto_ctbl <= lancamentoFim:input-value and ttLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value and ttLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value and ttLancamento.val_lancto_ctbl >= valorContabilIni:input-value and ttLancamento.val_lancto_ctbl <= valorContabilFim:input-value and ttLancamento.cod_cta_ctbl >= contaContabilIni:input-value and ttLancamento.cod_cta_ctbl <= contaContabilFim:input-value and ttLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value and ttLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value and ttLancamento.cod_ccusto >= centroCustoIni:input-value and ttLancamento.cod_ccusto <= centroCustoFim:input-value and ttLancamento.cod_estab >= estabelecimentoIni:input-value and ttLancamento.cod_estab <= estabelecimentoFim:input-value and (lookup(titulo:input-value, ~
       ttLancamento.des_histor_lancto_ctbl, ~
       ' ') > 0  or titulo:input-value = '') no-lock.
&Scoped-define TABLES-IN-QUERY-brFiscal ttLancamento
&Scoped-define FIRST-TABLE-IN-QUERY-brFiscal ttLancamento


/* Definitions for BROWSE brGerencial                                   */
&Scoped-define FIELDS-IN-QUERY-brGerencial ttLancamento.num_lancto_ctbl ttLancamento.num_seq_lancto_ctbl ttLancamento.ind_natur_lancto_ctbl ttLancamento.cod_estab ttLancamento.nomeEstabelecimento ttLancamento.cod_plano_cta_ctbl ttLancamento.cod_cta_ctbl ttLancamento.cod_plano_ccusto ttLancamento.cod_ccusto ttLancamento.dat_lancto_ctbl ttLancamento.val_lancto_ctbl ttLancamento.des_histor_lancto_ctbl ttLancamento.ind_sit_lancto_ctbl   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brGerencial   
&Scoped-define SELF-NAME brGerencial
&Scoped-define QUERY-STRING-brGerencial FOR EACH ttLancamento       WHERE ttLancamento.num_lote_ctbl = 1 and ttLancamento.num_lancto_ctbl >= lancamentoIni:input-value and ttLancamento.num_lancto_ctbl <= lancamentoFim:input-value and ttLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value and ttLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value and ttLancamento.val_lancto_ctbl >= valorContabilIni:input-value and ttLancamento.val_lancto_ctbl <= valorContabilFim:input-value and ttLancamento.cod_cta_ctbl >= contaContabilIni:input-value and ttLancamento.cod_cta_ctbl <= contaContabilFim:input-value and ttLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value and ttLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value and ttLancamento.cod_ccusto >= centroCustoIni:input-value and ttLancamento.cod_ccusto <= centroCustoFim:input-value and ttLancamento.cod_estab >= estabelecimentoIni:input-value and ttLancamento.cod_estab <= estabelecimentoFim:input-value and (lookup(titulo:input-value, ~
       ttLancamento.des_histor_lancto_ctbl, ~
       ' ') > 0  or titulo:input-value = '') no-lock
&Scoped-define OPEN-QUERY-brGerencial OPEN QUERY {&SELF-NAME} FOR EACH ttLancamento       WHERE ttLancamento.num_lote_ctbl = 1 and ttLancamento.num_lancto_ctbl >= lancamentoIni:input-value and ttLancamento.num_lancto_ctbl <= lancamentoFim:input-value and ttLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value and ttLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value and ttLancamento.val_lancto_ctbl >= valorContabilIni:input-value and ttLancamento.val_lancto_ctbl <= valorContabilFim:input-value and ttLancamento.cod_cta_ctbl >= contaContabilIni:input-value and ttLancamento.cod_cta_ctbl <= contaContabilFim:input-value and ttLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value and ttLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value and ttLancamento.cod_ccusto >= centroCustoIni:input-value and ttLancamento.cod_ccusto <= centroCustoFim:input-value and ttLancamento.cod_estab >= estabelecimentoIni:input-value and ttLancamento.cod_estab <= estabelecimentoFim:input-value and (lookup(titulo:input-value, ~
       ttLancamento.des_histor_lancto_ctbl, ~
       ' ') > 0  or titulo:input-value = '') no-lock.
&Scoped-define TABLES-IN-QUERY-brGerencial ttLancamento
&Scoped-define FIRST-TABLE-IN-QUERY-brGerencial ttLancamento


/* Definitions for BROWSE brLote                                        */
&Scoped-define FIELDS-IN-QUERY-brLote getSituacao(ttItem.num_lancto_ctbl, ttItem.num_seq_lancto_ctbl) @ situacao ttItem.num_lancto_ctbl ttItem.num_seq_lancto_ctbl ttItem.ind_natur_lancto_ctbl ttItem.cod_estab ttItem.nomeEstabelecimento ttItem.cod_plano_cta_ctbl ttItem.cod_cta_ctbl ttItem.cod_plano_ccusto ttItem.cod_ccusto ttItem.dat_lancto_ctbl ttItem.val_lancto_ctbl ttItem.des_histor_lancto_ctbl ttItem.ind_sit_lancto_ctbl   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brLote   
&Scoped-define SELF-NAME brLote
&Scoped-define QUERY-STRING-brLote FOR EACH ttItem       WHERE ttItem.num_lote_ctbl = numeroLote and ttItem.num_lancto_ctbl >= lancamentoIni:input-value and ttItem.num_lancto_ctbl <= lancamentoFim:input-value and ttItem.num_seq_lancto_ctbl >= sequenciaIni:input-value and ttItem.num_seq_lancto_ctbl <= sequenciaFim:input-value and ttItem.val_lancto_ctbl >= valorContabilIni:input-value and ttItem.val_lancto_ctbl <= valorContabilFim:input-value and ttItem.cod_cta_ctbl >= contaContabilIni:input-value and ttItem.cod_cta_ctbl <= contaContabilFim:input-value and ttItem.ind_natur_lancto_ctbl >= naturezaIni:input-value and ttItem.ind_natur_lancto_ctbl <= naturezaFim:input-value and ttItem.cod_ccusto >= centroCustoIni:input-value and ttItem.cod_ccusto <= centroCustoFim:input-value and ttItem.cod_estab >= estabelecimentoIni:input-value and ttItem.cod_estab <= estabelecimentoFim:input-value and (lookup(titulo:input-value, ~
       ttItem.des_histor_lancto_ctbl, ~
       ' ') > 0  or titulo:input-value = '') no-lock
&Scoped-define OPEN-QUERY-brLote OPEN QUERY {&SELF-NAME} FOR EACH ttItem       WHERE ttItem.num_lote_ctbl = numeroLote and ttItem.num_lancto_ctbl >= lancamentoIni:input-value and ttItem.num_lancto_ctbl <= lancamentoFim:input-value and ttItem.num_seq_lancto_ctbl >= sequenciaIni:input-value and ttItem.num_seq_lancto_ctbl <= sequenciaFim:input-value and ttItem.val_lancto_ctbl >= valorContabilIni:input-value and ttItem.val_lancto_ctbl <= valorContabilFim:input-value and ttItem.cod_cta_ctbl >= contaContabilIni:input-value and ttItem.cod_cta_ctbl <= contaContabilFim:input-value and ttItem.ind_natur_lancto_ctbl >= naturezaIni:input-value and ttItem.ind_natur_lancto_ctbl <= naturezaFim:input-value and ttItem.cod_ccusto >= centroCustoIni:input-value and ttItem.cod_ccusto <= centroCustoFim:input-value and ttItem.cod_estab >= estabelecimentoIni:input-value and ttItem.cod_estab <= estabelecimentoFim:input-value and (lookup(titulo:input-value, ~
       ttItem.des_histor_lancto_ctbl, ~
       ' ') > 0  or titulo:input-value = '') no-lock.
&Scoped-define TABLES-IN-QUERY-brLote ttItem
&Scoped-define FIRST-TABLE-IN-QUERY-brLote ttItem


/* Definitions for FRAME frFiscal                                       */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frFiscal ~
    ~{&OPEN-QUERY-brFiscal}

/* Definitions for FRAME frGerencial                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frGerencial ~
    ~{&OPEN-QUERY-brGerencial}

/* Definitions for FRAME frLote                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frLote ~
    ~{&OPEN-QUERY-brLote}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS lancamentoIni lancamentoFim sequenciaIni ~
sequenciaFim valorContabilIni finalidade valorContabilFim contaContabilIni ~
contaContabilFim naturezaIni descLote naturezaFim centroCustoIni ~
centroCustoFim estabelecimentoIni estabelecimentoFim titulo btOpen ~
cenarioAlteracao tableField brRateio btConfirmar bt_fechar RECT-16 RECT-39 ~
RECT-42 RECT-43 
&Scoped-Define DISPLAYED-OBJECTS lancamentoIni lancamentoFim sequenciaIni ~
sequenciaFim valorContabilIni finalidade valorContabilFim contaContabilIni ~
contaContabilFim naturezaIni descLote naturezaFim centroCustoIni ~
centroCustoFim estabelecimentoIni estabelecimentoFim titulo ~
cenarioAlteracao tableField newValue totalCredito totalDebito ~
totalDiferenca 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getSituacao C-Win 
FUNCTION getSituacao RETURNS CHARACTER
  (  input numeroLancamento as integer, input sequencia as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON brRateio AUTO-GO 
     LABEL "Rateio" 
     SIZE 10.57 BY 1 TOOLTIP "Cancela"
     FONT 1.

DEFINE BUTTON btAlterar AUTO-GO 
     LABEL "Alterar" 
     SIZE 10.57 BY 1 TOOLTIP "Cancela"
     FONT 1.

DEFINE BUTTON btConfirmar AUTO-GO 
     LABEL "Confirmar" 
     SIZE 10.57 BY 1 TOOLTIP "Cancela"
     FONT 1.

DEFINE BUTTON btOpen 
     IMAGE-UP FILE "image/toolbar/im-chck1.bmp":U
     LABEL "Button 2" 
     SIZE 5.14 BY 1.38.

DEFINE BUTTON bt_fechar AUTO-GO 
     LABEL "Fechar" 
     SIZE 10.57 BY 1 TOOLTIP "Cancela"
     FONT 1.

DEFINE VARIABLE tableField AS CHARACTER FORMAT "X(25)":U 
     LABEL "Campo" 
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEM-PAIRS "Conta cont†bil","ContaContabil",
                     "Centro de custo","CentroCusto",
                     "Valor","Valor",
                     "Estabelecimento","Estabelecimento",
                     "Unidade de neg¢cio","UnidadeNegocio",
                     "Hist¢rico","Historico",
                     "Plano Contas","PlanoContaContabil",
                     "Plano Centro Custo","PlanoCentroCusto"
     DROP-DOWN-LIST
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE centroCustoFim AS CHARACTER FORMAT "x(11)":U INITIAL "999999" 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE centroCustoIni AS CHARACTER FORMAT "X(11)":U 
     LABEL "Centro de Custo" 
     VIEW-AS FILL-IN 
     SIZE 11.86 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE contaContabilFim AS CHARACTER FORMAT "x(20)":U INITIAL "9999999999" 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE contaContabilIni AS CHARACTER FORMAT "X(20)":U 
     LABEL "Conta cont†bil" 
     VIEW-AS FILL-IN 
     SIZE 11.86 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE descLote AS CHARACTER FORMAT "X(256)":U 
     LABEL "Descriá∆o Lote" 
     VIEW-AS FILL-IN 
     SIZE 33 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE estabelecimentoFim AS CHARACTER FORMAT "X(3)":U INITIAL "ZZZ" 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE estabelecimentoIni AS CHARACTER FORMAT "X(3)":U 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 5.86 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE finalidade AS CHARACTER FORMAT "X(256)":U INITIAL "Corrente" 
     LABEL "Finalidade" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE lancamentoFim AS INTEGER FORMAT ">>>>>>>9":U INITIAL 99999999 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE lancamentoIni AS INTEGER FORMAT ">>>>>>>9":U INITIAL 0 
     LABEL "Lanáamento" 
     VIEW-AS FILL-IN 
     SIZE 9.86 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE naturezaFim AS CHARACTER FORMAT "X(2)":U INITIAL "ZZ" 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE naturezaIni AS CHARACTER FORMAT "X(2)":U 
     LABEL "Natureza" 
     VIEW-AS FILL-IN 
     SIZE 5.86 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE newValue AS CHARACTER FORMAT "X(256)":U 
     LABEL "alterar para" 
     VIEW-AS FILL-IN 
     SIZE 22.57 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE sequenciaFim AS INTEGER FORMAT ">>>>9":U INITIAL 99999 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE sequenciaIni AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "Sequencia" 
     VIEW-AS FILL-IN 
     SIZE 6.86 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE titulo AS CHARACTER FORMAT "X(10)":U 
     LABEL "Documento" 
     VIEW-AS FILL-IN 
     SIZE 11.86 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE totalCredito AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     LABEL "Total crÇditos" 
     VIEW-AS FILL-IN 
     SIZE 11.57 BY .79 NO-UNDO.

DEFINE VARIABLE totalDebito AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     LABEL "dÇbitos" 
     VIEW-AS FILL-IN 
     SIZE 12.14 BY .79 NO-UNDO.

DEFINE VARIABLE totalDiferenca AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     LABEL "diferenáa" 
     VIEW-AS FILL-IN 
     SIZE 12.29 BY .79 NO-UNDO.

DEFINE VARIABLE valorContabilFim AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 999999999.99 
     LABEL "atÇ" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE valorContabilIni AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     LABEL "Valor Cont†bil" 
     VIEW-AS FILL-IN 
     SIZE 14.86 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE cenarioAlteracao AS INTEGER INITIAL 3 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Gerencial", 1,
"Fiscal", 2,
"Ambos", 3
     SIZE 29 BY .75 NO-UNDO.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 1 GRAPHIC-EDGE    
     SIZE 116.29 BY 1.5
     BGCOLOR 18 FGCOLOR 19 .

DEFINE RECTANGLE RECT-39
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL   
     SIZE 69.29 BY 6.67
     BGCOLOR 18 FGCOLOR 19 .

DEFINE RECTANGLE RECT-42
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 4.25
     BGCOLOR 18 FGCOLOR 19 .

DEFINE RECTANGLE RECT-43
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL   
     SIZE 46 BY 2.17
     BGCOLOR 18 FGCOLOR 19 .

DEFINE VARIABLE cenarioFiscal AS CHARACTER FORMAT "X(8)":U INITIAL "FISCAL" 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .79 NO-UNDO.

DEFINE VARIABLE totalCreditoBrowse AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 12.29 BY .79 NO-UNDO.

DEFINE VARIABLE totalDebitoBrowse AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 12.29 BY .79 NO-UNDO.

DEFINE VARIABLE totalDiferencaBrowse AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 12.29 BY .79 NO-UNDO.

DEFINE VARIABLE cenarioGerencial AS CHARACTER FORMAT "X(8)":U INITIAL "GERENC" 
     LABEL "" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .79 NO-UNDO.

DEFINE BUTTON BUTTON-1 
     IMAGE-UP FILE "image/im-down2.bmp":U
     LABEL "Button 1" 
     SIZE 4 BY 1.13.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brFiscal FOR 
      ttLancamento SCROLLING.

DEFINE QUERY brGerencial FOR 
      ttLancamento SCROLLING.

DEFINE QUERY brLote FOR 
      ttItem SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brFiscal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brFiscal C-Win _FREEFORM
  QUERY brFiscal NO-LOCK DISPLAY
      ttLancamento.num_lancto_ctbl COLUMN-LABEL "Lanáto" FORMAT ">>>>>>>9":U
            WIDTH 4.72
      ttLancamento.num_seq_lancto_ctbl COLUMN-LABEL "Seq" FORMAT ">>>>9":U
            WIDTH 4.43
      ttLancamento.ind_natur_lancto_ctbl COLUMN-LABEL "Natur" FORMAT "X(02)":U
      ttLancamento.cod_estab COLUMN-LABEL "Est" FORMAT "x(3)":U
            WIDTH 3
      ttLancamento.nomeEstabelecimento FORMAT "x(15)":U WIDTH 11.86
      ttLancamento.cod_plano_cta_ctbl FORMAT "x(12)":U WIDTH 8
      ttLancamento.cod_cta_ctbl FORMAT "x(20)":U WIDTH 12
      ttLancamento.cod_plano_ccusto FORMAT "x(12)":U WIDTH 8
      ttLancamento.cod_ccusto FORMAT "x(11)":U WIDTH 9
      ttLancamento.dat_lancto_ctbl FORMAT "99/99/9999":U WIDTH 9
      ttLancamento.val_lancto_ctbl COLUMN-LABEL "Valor" FORMAT ">>>>>,>>>,>>9.99":U
            WIDTH 8
      ttLancamento.des_histor_lancto_ctbl FORMAT "x(2000)":U
            WIDTH 29
      ttLancamento.ind_sit_lancto_ctbl COLUMN-LABEL "Situaá∆o" FORMAT "X(4)":U
            WIDTH 4
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101 BY 5.54
         BGCOLOR 15 FONT 1 ROW-HEIGHT-CHARS .5 FIT-LAST-COLUMN.

DEFINE BROWSE brGerencial
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brGerencial C-Win _FREEFORM
  QUERY brGerencial NO-LOCK DISPLAY
      ttLancamento.num_lancto_ctbl COLUMN-LABEL "Lanáto" FORMAT ">>>>>>>9":U
            WIDTH 4.72
      ttLancamento.num_seq_lancto_ctbl COLUMN-LABEL "Seq" FORMAT ">>>>9":U
            WIDTH 4.43
      ttLancamento.ind_natur_lancto_ctbl COLUMN-LABEL "Natur" FORMAT "X(02)":U
      ttLancamento.cod_estab COLUMN-LABEL "Est" FORMAT "x(3)":U
            WIDTH 3
      ttLancamento.nomeEstabelecimento FORMAT "x(15)":U WIDTH 11.86
      ttLancamento.cod_plano_cta_ctbl FORMAT "x(12)":U WIDTH 8
      ttLancamento.cod_cta_ctbl FORMAT "x(20)":U WIDTH 12
      ttLancamento.cod_plano_ccusto FORMAT "x(12)":U WIDTH 8
      ttLancamento.cod_ccusto FORMAT "x(11)":U WIDTH 9
      ttLancamento.dat_lancto_ctbl FORMAT "99/99/9999":U WIDTH 9
      ttLancamento.val_lancto_ctbl COLUMN-LABEL "Valor" FORMAT ">>>>>,>>>,>>9.99":U
            WIDTH 8
      ttLancamento.des_histor_lancto_ctbl FORMAT "x(2000)":U
            WIDTH 29
      ttLancamento.ind_sit_lancto_ctbl COLUMN-LABEL "Situaá∆o" FORMAT "X(4)":U
            WIDTH 4
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101 BY 5.54
         BGCOLOR 15 FONT 1 ROW-HEIGHT-CHARS .5 FIT-LAST-COLUMN.

DEFINE BROWSE brLote
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brLote C-Win _FREEFORM
  QUERY brLote NO-LOCK DISPLAY
      getSituacao(ttItem.num_lancto_ctbl, 
            ttItem.num_seq_lancto_ctbl) @ situacao column-label 'Alt' format 'x(1)'
      ttItem.num_lancto_ctbl COLUMN-LABEL "Lanáto" FORMAT ">>>>>>>9":U
            WIDTH 4.72
      ttItem.num_seq_lancto_ctbl COLUMN-LABEL "Seq" FORMAT ">>>>9":U
            WIDTH 4.43
      ttItem.ind_natur_lancto_ctbl COLUMN-LABEL "Natur" FORMAT "X(02)":U
      ttItem.cod_estab COLUMN-LABEL "Est" FORMAT "x(3)":U
            WIDTH 3
      ttItem.nomeEstabelecimento FORMAT "x(15)":U WIDTH 11.86
      ttItem.cod_plano_cta_ctbl FORMAT "x(12)":U WIDTH 8
      ttItem.cod_cta_ctbl FORMAT "x(20)":U WIDTH 12
      ttItem.cod_plano_ccusto FORMAT "x(12)":U WIDTH 8
      ttItem.cod_ccusto FORMAT "x(11)":U WIDTH 9
      ttItem.dat_lancto_ctbl FORMAT "99/99/9999":U WIDTH 9
      ttItem.val_lancto_ctbl COLUMN-LABEL "Valor" FORMAT ">>>>>,>>>,>>9.99":U
            WIDTH 8
      ttItem.des_histor_lancto_ctbl FORMAT "x(2000)":U
            WIDTH 29
      ttItem.ind_sit_lancto_ctbl COLUMN-LABEL "Situaá∆o" FORMAT "X(4)":U
            WIDTH 4
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 101.14 BY 5.54
         BGCOLOR 15 FONT 1 ROW-HEIGHT-CHARS .5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     lancamentoIni AT ROW 1.25 COL 17.86 COLON-ALIGNED WIDGET-ID 76
     lancamentoFim AT ROW 1.25 COL 33.14 COLON-ALIGNED WIDGET-ID 78
     sequenciaIni AT ROW 2.17 COL 20.86 COLON-ALIGNED WIDGET-ID 84
     sequenciaFim AT ROW 2.17 COL 33.14 COLON-ALIGNED WIDGET-ID 82
     valorContabilIni AT ROW 3.08 COL 13 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" WIDGET-ID 8
     finalidade AT ROW 1.25 COL 82 COLON-ALIGNED WIDGET-ID 126 NO-TAB-STOP 
     valorContabilFim AT ROW 3.08 COL 33.14 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" WIDGET-ID 10
     contaContabilIni AT ROW 4 COL 15.86 COLON-ALIGNED WIDGET-ID 16
     contaContabilFim AT ROW 4 COL 33.14 COLON-ALIGNED WIDGET-ID 18
     naturezaIni AT ROW 4.92 COL 21.86 COLON-ALIGNED WIDGET-ID 20
     descLote AT ROW 2.25 COL 82 COLON-ALIGNED WIDGET-ID 128 NO-TAB-STOP 
     naturezaFim AT ROW 4.92 COL 33.14 COLON-ALIGNED WIDGET-ID 22
     centroCustoIni AT ROW 5.83 COL 15.86 COLON-ALIGNED WIDGET-ID 24
     centroCustoFim AT ROW 5.83 COL 33.14 COLON-ALIGNED WIDGET-ID 26
     estabelecimentoIni AT ROW 6.75 COL 21.86 COLON-ALIGNED WIDGET-ID 28
     estabelecimentoFim AT ROW 6.75 COL 33.14 COLON-ALIGNED WIDGET-ID 30
     titulo AT ROW 6.75 COL 49 COLON-ALIGNED WIDGET-ID 44
     btOpen AT ROW 6.25 COL 64 WIDGET-ID 130
     cenarioAlteracao AT ROW 3.75 COL 84 NO-LABEL WIDGET-ID 118
     tableField AT ROW 4.67 COL 82 COLON-ALIGNED WIDGET-ID 58
     newValue AT ROW 5.75 COL 82 COLON-ALIGNED WIDGET-ID 60
     btAlterar AT ROW 6.67 COL 84 WIDGET-ID 62
     brRateio AT ROW 6.67 COL 95 WIDGET-ID 80
     btConfirmar AT ROW 28.46 COL 93.86 WIDGET-ID 104
     bt_fechar AT ROW 28.46 COL 105 WIDGET-ID 4
     totalCredito AT ROW 28.54 COL 29 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" WIDGET-ID 106 NO-TAB-STOP 
     totalDebito AT ROW 28.54 COL 48.29 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" WIDGET-ID 108 NO-TAB-STOP 
     totalDiferenca AT ROW 28.54 COL 69.43 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" WIDGET-ID 110 NO-TAB-STOP 
     "Cenario:" VIEW-AS TEXT
          SIZE 5.86 BY .54 AT ROW 3.79 COL 78.14 WIDGET-ID 122
     RECT-16 AT ROW 28.21 COL 1.72 WIDGET-ID 6
     RECT-39 AT ROW 1.08 COL 1.72 WIDGET-ID 52
     RECT-42 AT ROW 3.5 COL 72 WIDGET-ID 64
     RECT-43 AT ROW 1.08 COL 72 WIDGET-ID 124
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 117.43 BY 28.71
         BGCOLOR 17 FONT 1 WIDGET-ID 100.

DEFINE FRAME frFiscal
     brFiscal AT ROW 1.08 COL 2 WIDGET-ID 200
     cenarioFiscal AT ROW 1.17 COL 102.14 COLON-ALIGNED WIDGET-ID 130 NO-TAB-STOP 
     totalCreditoBrowse AT ROW 2.71 COL 102 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" NO-LABEL WIDGET-ID 124 NO-TAB-STOP 
     totalDebitoBrowse AT ROW 4.21 COL 102 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" NO-LABEL WIDGET-ID 126 NO-TAB-STOP 
     totalDiferencaBrowse AT ROW 5.75 COL 102 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" NO-LABEL WIDGET-ID 128 NO-TAB-STOP 
     "Total crÇditos" VIEW-AS TEXT
          SIZE 11 BY .54 AT ROW 2.13 COL 104.43 WIDGET-ID 118
     "Total dÇbitos" VIEW-AS TEXT
          SIZE 10 BY .54 AT ROW 3.58 COL 104.43 WIDGET-ID 120
     "Diferenáa" VIEW-AS TEXT
          SIZE 8 BY .54 AT ROW 5.13 COL 104.43 WIDGET-ID 122
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.72 ROW 21.42
         SIZE 116.29 BY 6.63
         BGCOLOR 17 FONT 1
         TITLE BGCOLOR 18 "Cen†rio Fiscal" WIDGET-ID 500.

DEFINE FRAME frLote
     brLote AT ROW 1.08 COL 1.86 WIDGET-ID 200
     totalCreditoBrowse AT ROW 1.58 COL 102.14 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" NO-LABEL WIDGET-ID 124 FORMAT "->>>,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 12.29 BY .79 NO-TAB-STOP 
     totalDebitoBrowse AT ROW 3.08 COL 102.14 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" NO-LABEL WIDGET-ID 126 FORMAT "->>>,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 12.29 BY .79 NO-TAB-STOP 
     totalDiferencaBrowse AT ROW 4.63 COL 102.14 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" NO-LABEL WIDGET-ID 128 FORMAT "->>>,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 12.29 BY .79 NO-TAB-STOP 
     BUTTON-1 AT ROW 5.46 COL 104 WIDGET-ID 132
     "Total crÇditos" VIEW-AS TEXT
          SIZE 11 BY .54 AT ROW 1.04 COL 104.57 WIDGET-ID 118
     "Total dÇbitos" VIEW-AS TEXT
          SIZE 10 BY .54 AT ROW 2.5 COL 104.57 WIDGET-ID 120
     "Diferenáa" VIEW-AS TEXT
          SIZE 8 BY .54 AT ROW 4.04 COL 104.57 WIDGET-ID 122
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.72 ROW 7.92
         SIZE 116.29 BY 6.63
         BGCOLOR 17 FONT 1
         TITLE BGCOLOR 18 "Lote Original" WIDGET-ID 600.

DEFINE FRAME frGerencial
     brGerencial AT ROW 1.08 COL 2 WIDGET-ID 200
     cenarioGerencial AT ROW 1.17 COL 102.14 COLON-ALIGNED WIDGET-ID 130 NO-TAB-STOP 
     totalCreditoBrowse AT ROW 2.75 COL 102 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" NO-LABEL WIDGET-ID 124 FORMAT "->>>,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 12.29 BY .79 NO-TAB-STOP 
     totalDebitoBrowse AT ROW 4.25 COL 102 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" NO-LABEL WIDGET-ID 126 FORMAT "->>>,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 12.29 BY .79 NO-TAB-STOP 
     totalDiferencaBrowse AT ROW 5.79 COL 102 COLON-ALIGNED HELP
          "Valor do saldo do t°tulo" NO-LABEL WIDGET-ID 128 FORMAT "->>>,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 12.29 BY .79 NO-TAB-STOP 
     "Total crÇditos" VIEW-AS TEXT
          SIZE 11 BY .54 AT ROW 2.17 COL 104.43 WIDGET-ID 118
     "Total dÇbitos" VIEW-AS TEXT
          SIZE 10 BY .54 AT ROW 3.63 COL 104.43 WIDGET-ID 120
     "Diferenáa" VIEW-AS TEXT
          SIZE 8 BY .54 AT ROW 5.17 COL 104.43 WIDGET-ID 122
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.72 ROW 14.67
         SIZE 116.29 BY 6.63
         BGCOLOR 17 FONT 1
         TITLE BGCOLOR 18 "Cen†rio Gerencial" WIDGET-ID 400.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Rateio cont†bil"
         HEIGHT             = 28.71
         WIDTH              = 117.43
         MAX-HEIGHT         = 30.21
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 30.21
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



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* REPARENT FRAME */
ASSIGN FRAME frFiscal:FRAME = FRAME DEFAULT-FRAME:HANDLE
       FRAME frGerencial:FRAME = FRAME DEFAULT-FRAME:HANDLE
       FRAME frLote:FRAME = FRAME DEFAULT-FRAME:HANDLE.

/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME Custom                                                    */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME frGerencial:MOVE-BEFORE-TAB-ITEM (lancamentoIni:HANDLE IN FRAME DEFAULT-FRAME)
       XXTABVALXX = FRAME frLote:MOVE-BEFORE-TAB-ITEM (FRAME frGerencial:HANDLE)
       XXTABVALXX = FRAME frFiscal:MOVE-BEFORE-TAB-ITEM (FRAME frLote:HANDLE)
/* END-ASSIGN-TABS */.

/* SETTINGS FOR BUTTON btAlterar IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN newValue IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN totalCredito IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN totalDebito IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN totalDiferenca IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME frFiscal
                                                                        */
/* BROWSE-TAB brFiscal TEXT-10 frFiscal */
ASSIGN 
       brFiscal:COLUMN-RESIZABLE IN FRAME frFiscal       = TRUE
       brFiscal:COLUMN-MOVABLE IN FRAME frFiscal         = TRUE.

/* SETTINGS FOR FILL-IN totalCreditoBrowse IN FRAME frFiscal
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN totalDebitoBrowse IN FRAME frFiscal
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN totalDiferencaBrowse IN FRAME frFiscal
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME frGerencial
                                                                        */
/* BROWSE-TAB brGerencial TEXT-4 frGerencial */
ASSIGN 
       brGerencial:COLUMN-RESIZABLE IN FRAME frGerencial       = TRUE
       brGerencial:COLUMN-MOVABLE IN FRAME frGerencial         = TRUE.

/* SETTINGS FOR FILL-IN totalCreditoBrowse IN FRAME frGerencial
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN totalDebitoBrowse IN FRAME frGerencial
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN totalDiferencaBrowse IN FRAME frGerencial
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME frLote
                                                                        */
/* BROWSE-TAB brLote TEXT-7 frLote */
ASSIGN 
       brLote:COLUMN-RESIZABLE IN FRAME frLote       = TRUE
       brLote:COLUMN-MOVABLE IN FRAME frLote         = TRUE.

/* SETTINGS FOR FILL-IN totalCreditoBrowse IN FRAME frLote
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN totalDebitoBrowse IN FRAME frLote
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN totalDiferencaBrowse IN FRAME frLote
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brFiscal
/* Query rebuild information for BROWSE brFiscal
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttLancamento
      WHERE ttLancamento.num_lote_ctbl = 2
and ttLancamento.num_lancto_ctbl >= lancamentoIni:input-value
and ttLancamento.num_lancto_ctbl <= lancamentoFim:input-value
and ttLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value
and ttLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value
and ttLancamento.val_lancto_ctbl >= valorContabilIni:input-value
and ttLancamento.val_lancto_ctbl <= valorContabilFim:input-value
and ttLancamento.cod_cta_ctbl >= contaContabilIni:input-value
and ttLancamento.cod_cta_ctbl <= contaContabilFim:input-value
and ttLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value
and ttLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value
and ttLancamento.cod_ccusto >= centroCustoIni:input-value
and ttLancamento.cod_ccusto <= centroCustoFim:input-value
and ttLancamento.cod_estab >= estabelecimentoIni:input-value
and ttLancamento.cod_estab <= estabelecimentoFim:input-value
and (lookup(titulo:input-value, ttLancamento.des_histor_lancto_ctbl, ' ') > 0
 or titulo:input-value = '') no-lock.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "ttItemLancamento.num_lote_ctbl = lote
and ttItemLancamento.num_lancto_ctbl >= lancamentoIni:input-value
and ttItemLancamento.num_lancto_ctbl <= lancamentoFim:input-value
and ttItemLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value
and ttItemLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value
and ttItemLancamento.val_lancto_ctbl >= valorContabilIni:input-value
and ttItemLancamento.val_lancto_ctbl <= valorContabilFim:input-value
and ttItemLancamento.cod_cta_ctbl >= contaContabilIni:input-value
and ttItemLancamento.cod_cta_ctbl <= contaContabilFim:input-value
and ttItemLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value
and ttItemLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value
and ttItemLancamento.cod_ccusto >= centroCustoIni:input-value
and ttItemLancamento.cod_ccusto <= centroCustoFim:input-value
and ttItemLancamento.cod_estab >= estabelecimentoIni:input-value
and ttItemLancamento.cod_estab <= estabelecimentoFim:input-value
and (lookup(titulo:input-value, ttItemLancamento.des_histor_lancto_ctbl, ' ') > 0
 or titulo:input-value = '')"
     _Query            is OPENED
*/  /* BROWSE brFiscal */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brGerencial
/* Query rebuild information for BROWSE brGerencial
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttLancamento
      WHERE ttLancamento.num_lote_ctbl = 1
and ttLancamento.num_lancto_ctbl >= lancamentoIni:input-value
and ttLancamento.num_lancto_ctbl <= lancamentoFim:input-value
and ttLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value
and ttLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value
and ttLancamento.val_lancto_ctbl >= valorContabilIni:input-value
and ttLancamento.val_lancto_ctbl <= valorContabilFim:input-value
and ttLancamento.cod_cta_ctbl >= contaContabilIni:input-value
and ttLancamento.cod_cta_ctbl <= contaContabilFim:input-value
and ttLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value
and ttLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value
and ttLancamento.cod_ccusto >= centroCustoIni:input-value
and ttLancamento.cod_ccusto <= centroCustoFim:input-value
and ttLancamento.cod_estab >= estabelecimentoIni:input-value
and ttLancamento.cod_estab <= estabelecimentoFim:input-value
and (lookup(titulo:input-value, ttLancamento.des_histor_lancto_ctbl, ' ') > 0
 or titulo:input-value = '') no-lock
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "ttItemLancamento.num_lote_ctbl = lote
and ttItemLancamento.num_lancto_ctbl >= lancamentoIni:input-value
and ttItemLancamento.num_lancto_ctbl <= lancamentoFim:input-value
and ttItemLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value
and ttItemLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value
and ttItemLancamento.val_lancto_ctbl >= valorContabilIni:input-value
and ttItemLancamento.val_lancto_ctbl <= valorContabilFim:input-value
and ttItemLancamento.cod_cta_ctbl >= contaContabilIni:input-value
and ttItemLancamento.cod_cta_ctbl <= contaContabilFim:input-value
and ttItemLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value
and ttItemLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value
and ttItemLancamento.cod_ccusto >= centroCustoIni:input-value
and ttItemLancamento.cod_ccusto <= centroCustoFim:input-value
and ttItemLancamento.cod_estab >= estabelecimentoIni:input-value
and ttItemLancamento.cod_estab <= estabelecimentoFim:input-value
and (lookup(titulo:input-value, ttItemLancamento.des_histor_lancto_ctbl, ' ') > 0
 or titulo:input-value = '')"
     _Query            is OPENED
*/  /* BROWSE brGerencial */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brLote
/* Query rebuild information for BROWSE brLote
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttItem
      WHERE ttItem.num_lote_ctbl = numeroLote
and ttItem.num_lancto_ctbl >= lancamentoIni:input-value
and ttItem.num_lancto_ctbl <= lancamentoFim:input-value
and ttItem.num_seq_lancto_ctbl >= sequenciaIni:input-value
and ttItem.num_seq_lancto_ctbl <= sequenciaFim:input-value
and ttItem.val_lancto_ctbl >= valorContabilIni:input-value
and ttItem.val_lancto_ctbl <= valorContabilFim:input-value
and ttItem.cod_cta_ctbl >= contaContabilIni:input-value
and ttItem.cod_cta_ctbl <= contaContabilFim:input-value
and ttItem.ind_natur_lancto_ctbl >= naturezaIni:input-value
and ttItem.ind_natur_lancto_ctbl <= naturezaFim:input-value
and ttItem.cod_ccusto >= centroCustoIni:input-value
and ttItem.cod_ccusto <= centroCustoFim:input-value
and ttItem.cod_estab >= estabelecimentoIni:input-value
and ttItem.cod_estab <= estabelecimentoFim:input-value
and (lookup(titulo:input-value, ttItem.des_histor_lancto_ctbl, ' ') > 0
 or titulo:input-value = '') no-lock.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "ttItemLancamento.num_lote_ctbl = lote
and ttItemLancamento.num_lancto_ctbl >= lancamentoIni:input-value
and ttItemLancamento.num_lancto_ctbl <= lancamentoFim:input-value
and ttItemLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value
and ttItemLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value
and ttItemLancamento.val_lancto_ctbl >= valorContabilIni:input-value
and ttItemLancamento.val_lancto_ctbl <= valorContabilFim:input-value
and ttItemLancamento.cod_cta_ctbl >= contaContabilIni:input-value
and ttItemLancamento.cod_cta_ctbl <= contaContabilFim:input-value
and ttItemLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value
and ttItemLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value
and ttItemLancamento.cod_ccusto >= centroCustoIni:input-value
and ttItemLancamento.cod_ccusto <= centroCustoFim:input-value
and ttItemLancamento.cod_estab >= estabelecimentoIni:input-value
and ttItemLancamento.cod_estab <= estabelecimentoFim:input-value
and (lookup(titulo:input-value, ttItemLancamento.des_histor_lancto_ctbl, ' ') > 0
 or titulo:input-value = '')"
     _Query            is OPENED
*/  /* BROWSE brLote */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Rateio cont†bil */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Rateio cont†bil */
DO:
  run deleteInstance in ghInstanceManager(this-procedure).
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brLote
&Scoped-define FRAME-NAME frLote
&Scoped-define SELF-NAME brLote
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brLote C-Win
ON ROW-DISPLAY OF brLote IN FRAME frLote
DO:
    if avail ttItem then do:

        find first ttAlterado of ttItem no-lock no-error.
        if not avail ttAlterado then
            return.

        assign
            situacao:bgcolor in browse brLote                      = 14
            ttItem.num_lancto_ctbl:bgcolor in browse brLote        = 14
            ttItem.num_seq_lancto_ctbl:bgcolor in browse brLote    = 14
            ttItem.ind_natur_lancto_ctbl:bgcolor in browse brLote  = 14
            ttItem.cod_estab :bgcolor in browse brLote             = 14
            ttItem.nomeEstabelecimento:bgcolor in browse brLote    = 14
            ttItem.cod_plano_cta_ctbl:bgcolor in browse brLote     = 14
            ttItem.cod_cta_ctbl:bgcolor in browse brLote           = 14
            ttItem.cod_plano_ccusto:bgcolor in browse brLote       = 14
            ttItem.cod_ccusto:bgcolor in browse brLote             = 14
            ttItem.dat_lancto_ctbl:bgcolor in browse brLote        = 14
            ttItem.val_lancto_ctbl:bgcolor in browse brLote        = 14
            ttItem.des_histor_lancto_ctbl:bgcolor in browse brLote = 14
            ttItem.ind_sit_lancto_ctbl:bgcolor in browse brLote    = 14.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define SELF-NAME brRateio
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brRateio C-Win
ON CHOOSE OF brRateio IN FRAME DEFAULT-FRAME /* Rateio */
DO:
    run divide.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAlterar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAlterar C-Win
ON CHOOSE OF btAlterar IN FRAME DEFAULT-FRAME /* Alterar */
DO:
    run update.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btConfirmar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btConfirmar C-Win
ON CHOOSE OF btConfirmar IN FRAME DEFAULT-FRAME /* Confirmar */
DO:
    run generate.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOpen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOpen C-Win
ON CHOOSE OF btOpen IN FRAME DEFAULT-FRAME /* Button 2 */
DO:
    run openQueryBrowse.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt_fechar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt_fechar C-Win
ON CHOOSE OF bt_fechar IN FRAME DEFAULT-FRAME /* Fechar */
DO:
    apply "close" to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frLote
&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 C-Win
ON CHOOSE OF BUTTON-1 IN FRAME frLote /* Button 1 */
DO:
    run dragDown.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define SELF-NAME finalidade
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL finalidade C-Win
ON F5 OF finalidade IN FRAME DEFAULT-FRAME /* Finalidade */
DO:
    run prgint/utb/utb077ka.p.

    find first finalid_econ
        where recid(finalid_econ) = v_rec_finalid_econ
        no-lock no-error.

    if avail finalid_econ then
        assign 
            finalidade:screen-value in frame {&frame-name} = finalid_econ.cod_finalid_econ.
    else 
        assign 
            finalidade:screen-value in frame {&frame-name} = ''.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL finalidade C-Win
ON MOUSE-SELECT-DBLCLICK OF finalidade IN FRAME DEFAULT-FRAME /* Finalidade */
DO:
    apply 'f5':u to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tableField
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tableField C-Win
ON VALUE-CHANGED OF tableField IN FRAME DEFAULT-FRAME /* Campo */
DO:
    if trim(tableField:screen-value) <> '' then
        enable
            newValue
            btAlterar
            with frame {&frame-name}.
           
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brFiscal
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  assign
      C-Win:title = C-Win:title 
        + ' para o lote ' 
        + string(numeroLote)
      descLote:screen-value in frame {&frame-name} = 'Lote gerado a partir do ' 
        + string(numeroLote).

  do {&try}:
      run startup.
      run load.
      run openQueryBrowse.
  end.

  {cstp/csfg001.i}

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assignFrame C-Win 
PROCEDURE assignFrame :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    assign frame {&frame-name}
        lancamentoIni       lancamentoFim     
        sequenciaIni        sequenciaFim      
        valorContabilIni    valorContabilFim  
        contaContabilIni    contaContabilFim  
        naturezaIni         naturezaFim       
        centroCustoIni      centroCustoFim    
        estabelecimentoIni  estabelecimentoFim
        titulo.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calculateTotais C-Win 
PROCEDURE calculateTotais :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable credito as decimal   no-undo.
    define variable debito as decimal   no-undo.
    define variable diferenca as decimal   no-undo.

    do with frame {&frame-name}
        {&throws}:
        for each ttItem
            where ttItem.num_lote_ctbl =  numeroLote
            no-lock:

            find first ttAlterado of ttItem no-lock no-error.
            if avail ttAlterado then
                next.

            if ttItem.ind_natur_lancto_ctbl = 'CR' then
                assign
                    credito = credito + ttItem.val_lancto_ctbl
                    diferenca = diferenca + ttItem.val_lancto_ctbl.
            else
                assign
                    debito = debito + ttItem.val_lancto_ctbl
                    diferenca = diferenca - ttItem.val_lancto_ctbl.

        end.
        for each ttLancamento
            no-lock:
            if ttLancamento.ind_natur_lancto_ctbl = 'CR' then
                assign
                    credito = credito + ttLancamento.val_lancto_ctbl
                    diferenca = diferenca + ttLancamento.val_lancto_ctbl.
            else
                assign
                    debito = debito + ttLancamento.val_lancto_ctbl
                    diferenca = diferenca - ttLancamento.val_lancto_ctbl.
        end.

        assign
            totalCredito:screen-value = string(credito)
            totalDebito:screen-value = string(debito)
            totalDiferenca:screen-value = string(diferenca).

        if diferenca = 0 then
            assign
                totalDiferenca:bgcolor = 10.
        else
            assign
                totalDiferenca:bgcolor = 12.

        run calculateTotaisLote.
        run calculateTotaisGerencial.
        run calculateTotaisFiscal.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calculateTotaisFiscal C-Win 
PROCEDURE calculateTotaisFiscal :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable creditoBrowse as decimal   no-undo.
    define variable debitoBrowse as decimal   no-undo.
    define variable diferencaBrowse as decimal   no-undo.

    do with frame {&frame-name}
        {&throws}:
        for each ttLancamento
            where ttLancamento.num_lote_ctbl = 2
              and ttLancamento.num_lancto_ctbl >= lancamentoIni:input-value
              and ttLancamento.num_lancto_ctbl <= lancamentoFim:input-value
              and ttLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value
              and ttLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value
              and ttLancamento.val_lancto_ctbl >= valorContabilIni:input-value
              and ttLancamento.val_lancto_ctbl <= valorContabilFim:input-value
              and ttLancamento.cod_cta_ctbl >= contaContabilIni:input-value
              and ttLancamento.cod_cta_ctbl <= contaContabilFim:input-value
              and ttLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value
              and ttLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value
              and ttLancamento.cod_ccusto >= centroCustoIni:input-value
              and ttLancamento.cod_ccusto <= centroCustoFim:input-value
              and ttLancamento.cod_estab >= estabelecimentoIni:input-value
              and ttLancamento.cod_estab <= estabelecimentoFim:input-value
              and (lookup(titulo:input-value, ttLancamento.des_histor_lancto_ctbl, ' ') > 0
               or titulo:input-value = '')
            no-lock:
            if ttLancamento.ind_natur_lancto_ctbl = 'CR' then
                assign
                    creditoBrowse = creditoBrowse + ttLancamento.val_lancto_ctbl
                    diferencaBrowse = diferencaBrowse + ttLancamento.val_lancto_ctbl.
            else
                assign
                    debitoBrowse = debitoBrowse + ttLancamento.val_lancto_ctbl
                    diferencaBrowse = diferencaBrowse - ttLancamento.val_lancto_ctbl.
        end.

        assign
            totalCreditoBrowse:screen-value in frame frFiscal = string(creditoBrowse)
            totalDebitoBrowse:screen-value in frame frFiscal = string(debitoBrowse)
            totalDiferencaBrowse:screen-value in frame frFiscal = string(diferencaBrowse).

        if diferencaBrowse = 0 then
            assign
                totalDiferencaBrowse:bgcolor in frame frFiscal = 10.
        else
            assign
                totalDiferencaBrowse:bgcolor in frame frFiscal = 12.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calculateTotaisGerencial C-Win 
PROCEDURE calculateTotaisGerencial :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable creditoBrowse as decimal   no-undo.
    define variable debitoBrowse as decimal   no-undo.
    define variable diferencaBrowse as decimal   no-undo.

    do with frame {&frame-name}
        {&throws}:
        for each ttLancamento
            where ttLancamento.num_lote_ctbl = 1
              and ttLancamento.num_lancto_ctbl >= lancamentoIni:input-value
              and ttLancamento.num_lancto_ctbl <= lancamentoFim:input-value
              and ttLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value
              and ttLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value
              and ttLancamento.val_lancto_ctbl >= valorContabilIni:input-value
              and ttLancamento.val_lancto_ctbl <= valorContabilFim:input-value
              and ttLancamento.cod_cta_ctbl >= contaContabilIni:input-value
              and ttLancamento.cod_cta_ctbl <= contaContabilFim:input-value
              and ttLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value
              and ttLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value
              and ttLancamento.cod_ccusto >= centroCustoIni:input-value
              and ttLancamento.cod_ccusto <= centroCustoFim:input-value
              and ttLancamento.cod_estab >= estabelecimentoIni:input-value
              and ttLancamento.cod_estab <= estabelecimentoFim:input-value
              and (lookup(titulo:input-value, ttLancamento.des_histor_lancto_ctbl, ' ') > 0
               or titulo:input-value = '')
            no-lock:
            if ttLancamento.ind_natur_lancto_ctbl = 'CR' then
                assign
                    creditoBrowse = creditoBrowse + ttLancamento.val_lancto_ctbl
                    diferencaBrowse = diferencaBrowse + ttLancamento.val_lancto_ctbl.
            else
                assign
                    debitoBrowse = debitoBrowse + ttLancamento.val_lancto_ctbl
                    diferencaBrowse = diferencaBrowse - ttLancamento.val_lancto_ctbl.
        end.

        assign
            totalCreditoBrowse:screen-value in frame frGerencial = string(creditoBrowse)
            totalDebitoBrowse:screen-value in frame frGerencial = string(debitoBrowse)
            totalDiferencaBrowse:screen-value in frame frGerencial = string(diferencaBrowse).

        if diferencaBrowse = 0 then
            assign
                totalDiferencaBrowse:bgcolor in frame frGerencial = 10.
        else
            assign
                totalDiferencaBrowse:bgcolor in frame frGerencial = 12.
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calculateTotaisLote C-Win 
PROCEDURE calculateTotaisLote :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable creditoBrowse as decimal   no-undo.
    define variable debitoBrowse as decimal   no-undo.
    define variable diferencaBrowse as decimal   no-undo.

    do with frame {&frame-name}
        {&throws}:
        for each ttItem
            where ttItem.num_lote_ctbl =  numeroLote
              and ttItem.num_lancto_ctbl >= lancamentoIni:input-value
              and ttItem.num_lancto_ctbl <= lancamentoFim:input-value
              and ttItem.num_seq_lancto_ctbl >= sequenciaIni:input-value
              and ttItem.num_seq_lancto_ctbl <= sequenciaFim:input-value
              and ttItem.val_lancto_ctbl >= valorContabilIni:input-value
              and ttItem.val_lancto_ctbl <= valorContabilFim:input-value
              and ttItem.cod_cta_ctbl >= contaContabilIni:input-value
              and ttItem.cod_cta_ctbl <= contaContabilFim:input-value
              and ttItem.ind_natur_lancto_ctbl >= naturezaIni:input-value
              and ttItem.ind_natur_lancto_ctbl <= naturezaFim:input-value
              and ttItem.cod_ccusto >= centroCustoIni:input-value
              and ttItem.cod_ccusto <= centroCustoFim:input-value
              and ttItem.cod_estab >= estabelecimentoIni:input-value
              and ttItem.cod_estab <= estabelecimentoFim:input-value
              and (lookup(titulo:input-value, ttItem.des_histor_lancto_ctbl, ' ') > 0
               or titulo:input-value = '')
            no-lock:

            find first ttAlterado of ttItem no-lock no-error.
            if avail ttAlterado then
                next.

            if ttItem.ind_natur_lancto_ctbl = 'CR' then
                assign
                    creditoBrowse = creditoBrowse + ttItem.val_lancto_ctbl
                    diferencaBrowse = diferencaBrowse + ttItem.val_lancto_ctbl.
            else
                assign
                    debitoBrowse = debitoBrowse + ttItem.val_lancto_ctbl
                    diferencaBrowse = diferencaBrowse - ttItem.val_lancto_ctbl.
        end.

        assign
            totalCreditoBrowse:screen-value in frame frLote = string(creditoBrowse)
            totalDebitoBrowse:screen-value in frame frLote = string(debitoBrowse)
            totalDiferencaBrowse:screen-value in frame frLote = string(diferencaBrowse).

        if diferencaBrowse = 0 then
            assign
                totalDiferencaBrowse:bgcolor in frame frLote = 10.
        else
            assign
                totalDiferencaBrowse:bgcolor in frame frLote = 12.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete C-Win 
PROCEDURE delete :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    message 'Vocà deseja excluir o lanáamento selecionado no grid?'
        view-as alert-box question buttons yes-no
        title 'Exclus∆o Lancamento'
        update doDelete as logical.

    if doDelete then do 
        {&try}:
        run emptyErrors.

        run fetchSelectedRow.

        if avail ttLancamento then do:
            delete ttLancamento.
            run openQueryBrowse.
        end.
    end.

    run showErrors.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE divide C-Win 
PROCEDURE divide :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable doRateio as logical   no-undo.

    do {&try}:
        run emptyErrors.

        if avail ttItem then do:

            empty temp-table ttRateio.

            run cstp/csfg001a.w(ttItem.val_lancto_ctbl, output doRateio, 
                output table ttRateio).

            if not doRateio then
                return.

            run divideItens.
            run openQueryBrowse.
        end.
    end.

    run showErrors.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE divideItens C-Win 
PROCEDURE divideItens :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable nextSequence as integer   no-undo.
    define variable cenario as integer   no-undo.

    do with frame {&frame-name}
        transaction
        {&throws}:

        run validateDivide.

        run setLancamentoOriginalAlterado.

        run getNextSequence(output nextSequence).

        for each ttRateio
            no-lock
            {&throws}:

            create ttLancamento.
            buffer-copy ttItem to ttLancamento
                assign
                    ttLancamento.dat_lancto_ctbl =  ttItem.dat_lancto_ctbl
                    ttLancamento.num_lote_ctbl = if cenarioAlteracao:input-value < 3 then
                                                     cenarioAlteracao:input-value
                                                 else 1

                    ttLancamento.num_seq_lancto_ctbl = nextSequence
                    ttLancamento.cod_estab = ttRateio.cod_estab
                    ttLancamento.val_lancto_ctbl = ttRateio.valor
                    ttLancamento.cod_ccusto = string(integer(ttRateio.cod_estab), '99999').

            assign
                nextSequence = nextSequence + 1.

            if cenarioAlteracao:input-value = 3 then do:
                create ttLancamento.
                buffer-copy ttItem to ttLancamento
                    assign
                        ttLancamento.dat_lancto_ctbl =  ttItem.dat_lancto_ctbl
                        ttLancamento.num_lote_ctbl = 2
                        ttLancamento.num_seq_lancto_ctbl = nextSequence
                        ttLancamento.cod_estab = ttRateio.cod_estab
                        ttLancamento.val_lancto_ctbl = ttRateio.valor
                        ttLancamento.cod_ccusto = string(integer(ttRateio.cod_estab), '99999').
                assign
                    nextSequence = nextSequence + 1.
            end.
        end.

        if cenarioAlteracao:input-value < 3 then do:
            assign
                nextSequence = nextSequence + 1.

            create ttLancamento.
            buffer-copy ttItem to ttLancamento
                ASSIGN  ttLancamento.dat_lancto_ctbl =  ttItem.dat_lancto_ctbl
                        ttLancamento.num_lote_ctbl   = if cenarioAlteracao:input-value = 1 then 2
                                                 else 1.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dragDown C-Win 
PROCEDURE dragDown :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    message 'Vocà deseja arrastar para baixo os lanáamentos mostrados no grid Lote Original?'
        view-as alert-box question buttons yes-no
        title 'Arrastar para baixo os lancamentos'
        update doDragDown as logical.

    if doDragDown then do
        transaction
        {&try}:
        run emptyErrors.

        run dragDownItens.
        run openQueryBrowse.
    end.

    run showErrors.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dragDownItens C-Win 
PROCEDURE dragDownItens :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do with frame {&frame-name}
        {&throws}:
        for each ttItem
            where ttItem.num_lote_ctbl = numeroLote
              and ttItem.num_lancto_ctbl >= lancamentoIni:input-value
              and ttItem.num_lancto_ctbl <= lancamentoFim:input-value
              and ttItem.num_seq_lancto_ctbl >= sequenciaIni:input-value
              and ttItem.num_seq_lancto_ctbl <= sequenciaFim:input-value
              and ttItem.val_lancto_ctbl >= valorContabilIni:input-value
              and ttItem.val_lancto_ctbl <= valorContabilFim:input-value
              and ttItem.cod_cta_ctbl >= contaContabilIni:input-value
              and ttItem.cod_cta_ctbl <= contaContabilFim:input-value
              and ttItem.ind_natur_lancto_ctbl >= naturezaIni:input-value
              and ttItem.ind_natur_lancto_ctbl <= naturezaFim:input-value
              and ttItem.cod_ccusto >= centroCustoIni:input-value
              and ttItem.cod_ccusto <= centroCustoFim:input-value
              and ttItem.cod_estab >= estabelecimentoIni:input-value
              and ttItem.cod_estab <= estabelecimentoFim:input-value
              and ( lookup(titulo:input-value, ttItem.des_histor_lancto_ctbl, ' ') > 0 or
                    titulo:input-value = '' )
            no-lock
            {&throws}:

            run setLancamentoOriginalAlterado.

            create ttLancamento.
            buffer-copy ttItem to ttLancamento
                ASSIGN  ttLancamento.dat_lancto_ctbl =  ttItem.dat_lancto_ctbl
                    ttLancamento.num_lote_ctbl = 1.

            create ttLancamento.
            buffer-copy ttItem to ttLancamento
                ASSIGN  ttLancamento.dat_lancto_ctbl =  ttItem.dat_lancto_ctbl
                    ttLancamento.num_lote_ctbl = 2.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
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
  DISPLAY lancamentoIni lancamentoFim sequenciaIni sequenciaFim valorContabilIni 
          finalidade valorContabilFim contaContabilIni contaContabilFim 
          naturezaIni descLote naturezaFim centroCustoIni centroCustoFim 
          estabelecimentoIni estabelecimentoFim titulo cenarioAlteracao 
          tableField newValue totalCredito totalDebito totalDiferenca 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE lancamentoIni lancamentoFim sequenciaIni sequenciaFim valorContabilIni 
         finalidade valorContabilFim contaContabilIni contaContabilFim 
         naturezaIni descLote naturezaFim centroCustoIni centroCustoFim 
         estabelecimentoIni estabelecimentoFim titulo btOpen cenarioAlteracao 
         tableField brRateio btConfirmar bt_fechar RECT-16 RECT-39 RECT-42 
         RECT-43 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  DISPLAY totalCreditoBrowse totalDebitoBrowse totalDiferencaBrowse 
      WITH FRAME frLote IN WINDOW C-Win.
  ENABLE brLote BUTTON-1 
      WITH FRAME frLote IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frLote}
  DISPLAY cenarioGerencial totalCreditoBrowse totalDebitoBrowse 
          totalDiferencaBrowse 
      WITH FRAME frGerencial IN WINDOW C-Win.
  ENABLE brGerencial cenarioGerencial 
      WITH FRAME frGerencial IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frGerencial}
  DISPLAY cenarioFiscal totalCreditoBrowse totalDebitoBrowse 
          totalDiferencaBrowse 
      WITH FRAME frFiscal IN WINDOW C-Win.
  ENABLE brFiscal cenarioFiscal 
      WITH FRAME frFiscal IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frFiscal}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generate C-Win 
PROCEDURE generate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable codigoEmpresa as character no-undo.
    define variable moduloDatasul as character no-undo.
    define variable outputFile as character no-undo.
    define variable doGenerate as logical   no-undo.
    define variable hasError as logical   no-undo.

    do transaction
        {&try}:
        run emptyErrors.

        run verifyGenerate(output doGenerate).
        if not doGenerate then
            return.

        run validateGenerate.

        run find in lote(numeroLote).
        run getDataLote in lote(output dataLote).
        
/*         run setDescricaoLote in lote(descLote:input-value in frame {&frame-name}). */

        assign
            outputFile = string(dataLote,'99999999')
                + string(time)
                + '.txt'.

        run setOutputFile in lote(outputFile).

        run populateLancamento(1, cenarioGerencial:input-value in frame frGerencial).
        run populateLancamento(2, cenarioFiscal:input-value in frame frFiscal).

        run insert in lote.

        run updateLoteOriginal.
    end.

    run utils/showReport.p(session:temp-directory + outputFile).

    run hasError(output hasError).
    if hasError then do:
        run showErrors.
    end.
    else
        apply 'close' to this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNextSequence C-Win 
PROCEDURE getNextSequence :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter nextSequence as decimal    no-undo.

    define buffer buffLancamento for item_lancto_ctbl.

    do {&throws}:
        for each buffLancamento
            where buffLancamento.num_lote_ctbl = numeroLote
            no-lock
            {&throws}:
            if nextSequence < buffLancamento.num_seq_lancto_ctbl then
                assign
                    nextSequence = buffLancamento.num_seq_lancto_ctbl.
        end.
        assign
            nextSequence = nextSequence + 1.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load C-Win 
PROCEDURE load :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        empty temp-table ttItem.

        for each item_lancto_ctbl
            where item_lancto_ctbl.num_lote_ctbl = numeroLote
            no-lock
            {&throws}:

            create ttItem.
            buffer-copy item_lancto_ctbl to ttItem.

            find estabelecimento
                where estabelecimento.cod_estab = item_lancto_ctbl.cod_estab
                no-lock no-error.

            if avail estabelecimento then
                assign
                    ttItem.nomeEstabelecimento = estabelecimento.nom_abrev.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openQueryBrowse C-Win 
PROCEDURE openQueryBrowse :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    assign frame {&frame-name}
        lancamentoIni       lancamentoFim     
        sequenciaIni        sequenciaFim      
        valorContabilIni    valorContabilFim  
        contaContabilIni    contaContabilFim  
        naturezaIni         naturezaFim       
        centroCustoIni      centroCustoFim    
        estabelecimentoIni  estabelecimentoFim
        titulo.

    run calculateTotais.

    {&OPEN-QUERY-brLote}
    {&OPEN-QUERY-brGerencial}
    {&OPEN-QUERY-brFiscal}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateApropriacoes C-Win 
PROCEDURE populateApropriacoes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable unidadeNegocio as character no-undo.
    define variable planoCCusto as character no-undo.
    define variable quantidade as decimal no-undo.
    define variable valor as decimal   no-undo.
    define variable centroCusto as character no-undo.

    do {&throws}:
        run getUnidadeNegocio in item(output unidadeNegocio).
        run getPlanoCCusto in item(output planoCCusto).
        run getQuantidade in item(output quantidade).
        run getValor in item(output valor).
        run getCentroCusto in item(output centroCusto).

        run createInstance in ghInstanceManager (this-procedure,
            'dtsl/ems5/contabilidade/lancamentocontabil/LoteLancamentoItemApropriacao.p':u, 
            output apropriacao).

        run new in apropriacao.
        run setMoeda                   in apropriacao(finalidade:input-value in frame {&frame-name}).
        run setUnidadeNegocio          in apropriacao(unidadeNegocio).
        run setPlanoCCusto             in apropriacao(planoCCusto).
        run setQuantidade              in apropriacao(quantidade).
        run setValor                   in apropriacao(valor).
        run setCentroCusto             in apropriacao(centroCusto).

        run addApropriacao in item(apropriacao).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateItens C-Win 
PROCEDURE populateItens :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cenario as integer  no-undo.

    do {&throws}:
        for each ttLancamento
            where ttLancamento.num_lote_ctbl = cenario
            no-lock
            {&throws}:
            run createInstance in ghInstanceManager (this-procedure,
                'dtsl/ems5/contabilidade/lancamentocontabil/LoteLancamentoItem.p':u,
                output item).

            run new in item.
            run setNatureza                 in item(ttLancamento.ind_natur_lancto_ctbl).
            run setDataLancamento           in item(dataLote).
            run setPlanoContas              in item(ttLancamento.cod_plano_cta_ctbl).
            run setContaContabil            in item(ttLancamento.cod_cta_ctbl).
            run setPlanoCCusto              in item(ttLancamento.cod_plano_ccusto).
            run setEstabelecimento          in item(ttLancamento.cod_estab).
            run setUnidadeNegocio           in item(ttLancamento.cod_unid_negoc).
            run setHistoricoPadrao          in item(ttLancamento.cod_histor_padr).
            run setDescricaoHistorico       in item(ttLancamento.des_histor_lancto_ctbl).
            run setEspecie                  in item(ttLancamento.cod_espec_docto).
            run setDataDocumento            in item(ttLancamento.dat_docto).
            run setDescricaoDocumento       in item(ttLancamento.des_docto).
            run setImagem                   in item(ttLancamento.cod_imagem).
            run setMoeda                    in item(ttLancamento.cod_indic_econ).
            run setQuantidade               in item(ttLancamento.qtd_unid_lancto_ctbl).
            run setValor                    in item(ttLancamento.val_lancto_ctbl).
            run setSequenciaContraPartida   in item(0).
            run setCentroCusto              in item(ttLancamento.cod_ccusto).
            run setProjeto                  in item(ttLancamento.cod_proj_financ).
    
            run populateApropriacoes.
    
            run addItem in lancamento(item).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateLancamento C-Win 
PROCEDURE populateLancamento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cenario as integer no-undo.
    define input parameter nomeCenario as character  no-undo.

    do {&throws}:
        run createInstance in ghInstanceManager (this-procedure,
            'dtsl/ems5/contabilidade/lancamentocontabil/LoteLancamento.p':u, 
            output lancamento).

        run new in lancamento.
        run setDataLancamento   in lancamento(dataLote).
        run setCenarioContabil  in lancamento(nomeCenario).

        run populateItens(cenario).

        run addLancamento in lote(lancamento).  
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCentroCusto C-Win 
PROCEDURE setCentroCusto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cod_ccusto_ as character  no-undo.

    do {&throws}:
        assign
            ttLancamento.cod_ccusto = cod_ccusto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setContaContabil C-Win 
PROCEDURE setContaContabil :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cod_cta_ctbl_ as character  no-undo.

    do {&throws}:
        assign
            ttLancamento.cod_cta_ctbl = cod_cta_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setEstabelecimento C-Win 
PROCEDURE setEstabelecimento :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cod_estab_ as character  no-undo.

    do {&throws}:
        assign
            ttLancamento.cod_estab = cod_estab_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setHistorico C-Win 
PROCEDURE setHistorico :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter des_histor_lancto_ctbl_ as character  no-undo.

    do {&throws}:
        assign
            ttLancamento.des_histor_lancto_ctbl = des_histor_lancto_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLancamentoOriginalAlterado C-Win 
PROCEDURE setLancamentoOriginalAlterado :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        find first ttAlterado of ttItem no-lock no-error.
        if avail ttAlterado then do:
            run createError(17006, 'Lanáamento n∆o pode ser arrastado'
                + '~~':u
                + substitute('Lancamento &1, sequencia &2 ja foi alterado',
                ttItem.num_lancto_ctbl, ttItem.num_seq_lancto_ctbl)).
            return error.
        end.

        create ttAlterado.
        buffer-copy ttItem to ttAlterado.
        
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPlanoCentroCusto C-Win 
PROCEDURE setPlanoCentroCusto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cod_plano_ccusto_ as character  no-undo.

    do {&throws}:
        assign
            ttLancamento.cod_plano_ccusto = cod_plano_ccusto_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPlanoContaContabil C-Win 
PROCEDURE setPlanoContaContabil :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cod_plano_cta_ctbl_ as character  no-undo.

    do {&throws}:
        assign
            ttLancamento.cod_plano_cta_ctbl = cod_plano_cta_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUnidadeNegocio C-Win 
PROCEDURE setUnidadeNegocio :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter cod_unid_negoc_ as character  no-undo.

    do {&throws}:
        assign
            ttLancamento.cod_unid_negoc = cod_unid_negoc_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setValor C-Win 
PROCEDURE setValor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter val_lancto_ctbl_ as decimal  no-undo.

    do {&throws}:
        assign
            ttLancamento.val_lancto_ctbl = val_lancto_ctbl_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup C-Win 
PROCEDURE startup :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    {system/InstanceManager.i}

    do {&throws}:
        run createInstance in ghInstanceManager (this-procedure,
            'dtsl/ems5/contabilidade/lancamentocontabil/Lote.p':u, 
            output lote).
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update C-Win 
PROCEDURE update :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    message 'Vocà deseja alterar os lanáamentos mostrados no grid Lote Original?'
        view-as alert-box question buttons yes-no
        title 'Alteraá∆o Lancamentos'
        update doUpdate as logical.

    if doUpdate then do
        transaction
        {&try}:
        run emptyErrors.

        run updateItens.
        run openQueryBrowse.
    end.

    run showErrors.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE updateItens C-Win 
PROCEDURE updateItens :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do with frame {&frame-name}
        {&throws}:
        for each ttLancamento
            where ( ttLancamento.num_lote_ctbl = cenarioAlteracao:input-value or
                    cenarioAlteracao:input-value = 3)
              and ttLancamento.num_lancto_ctbl >= lancamentoIni:input-value
              and ttLancamento.num_lancto_ctbl <= lancamentoFim:input-value
              and ttLancamento.num_seq_lancto_ctbl >= sequenciaIni:input-value
              and ttLancamento.num_seq_lancto_ctbl <= sequenciaFim:input-value
              and ttLancamento.val_lancto_ctbl >= valorContabilIni:input-value
              and ttLancamento.val_lancto_ctbl <= valorContabilFim:input-value
              and ttLancamento.cod_cta_ctbl >= contaContabilIni:input-value
              and ttLancamento.cod_cta_ctbl <= contaContabilFim:input-value
              and ttLancamento.ind_natur_lancto_ctbl >= naturezaIni:input-value
              and ttLancamento.ind_natur_lancto_ctbl <= naturezaFim:input-value
              and ttLancamento.cod_ccusto >= centroCustoIni:input-value
              and ttLancamento.cod_ccusto <= centroCustoFim:input-value
              and ttLancamento.cod_estab >= estabelecimentoIni:input-value
              and ttLancamento.cod_estab <= estabelecimentoFim:input-value
              and ( lookup(titulo:input-value, ttLancamento.des_histor_lancto_ctbl, ' ') > 0 or
                    titulo:input-value = '' )
            no-lock
            {&throws}:

            run value('set' + tableField:screen-value)(newValue:screen-value).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE updateLoteOriginal C-Win 
PROCEDURE updateLoteOriginal :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    disable triggers for load of item_lancto_ctbl.
    disable triggers for load of aprop_lancto_ctbl.
    disable triggers for load of tot_lancto_ctbl.

    do {&throws}:
        for each ttAlterado
            no-lock
            ,
            first item_lancto_ctbl
            where item_lancto_ctbl.num_lote_ctbl = ttAlterado.num_lote_ctbl
              and item_lancto_ctbl.num_lancto_ctbl = ttAlterado.num_lancto_ctbl
              and item_lancto_ctbl.num_seq_lancto_ctbl = ttAlterado.num_seq_lancto_ctbl
            exclusive-lock
            {&throws}:

            for each aprop_lancto_ctbl
                where aprop_lancto_ctbl.num_lote_ctbl = item_lancto_ctbl.num_lote_ctbl
                  and aprop_lancto_ctbl.num_lancto_ctbl = item_lancto_ctbl.num_lancto_ctbl
                  and aprop_lancto_ctbl.num_seq_lancto_ctbl = item_lancto_ctbl.num_seq_lancto_ctbl
                exclusive-lock
                {&throws}:

                find first tot_lancto_ctbl
                    where tot_lancto_ctbl.num_lote_ctbl    = aprop_lancto_ctbl.num_lote_ctbl
                      and tot_lancto_ctbl.num_lancto_ctbl  = aprop_lancto_ctbl.num_lancto_ctbl
                      and tot_lancto_ctbl.cod_finalid_econ = aprop_lancto_ctbl.cod_finalid_econ 
                    exclusive-lock no-error.

                if avail tot_lancto_ctbl then
                    delete tot_lancto_ctbl.

                delete aprop_lancto_ctbl.
            end.

            delete item_lancto_ctbl.
        end.

        release item_lancto_ctbl no-error.

        for each item_lancto_ctbl
            where item_lancto_ctbl.num_lote_ctbl = numeroLote
            no-lock
            ,
            each aprop_lancto_ctbl
            where aprop_lancto_ctbl.num_lote_ctbl = item_lancto_ctbl.num_lote_ctbl
              and aprop_lancto_ctbl.num_lancto_ctbl = item_lancto_ctbl.num_lancto_ctbl
              and aprop_lancto_ctbl.num_seq_lancto_ctbl = item_lancto_ctbl.num_seq_lancto_ctbl
            no-lock
            by aprop_lancto_ctbl.cod_finalid_econ
            {&throws}:

            find first tot_lancto_ctbl
                where tot_lancto_ctbl.num_lote_ctbl    = aprop_lancto_ctbl.num_lote_ctbl
                  and tot_lancto_ctbl.num_lancto_ctbl  = aprop_lancto_ctbl.num_lancto_ctbl
                  and tot_lancto_ctbl.cod_finalid_econ = aprop_lancto_ctbl.cod_finalid_econ 
                exclusive-lock no-error.

            if not avail tot_lancto_ctbl then do:
                create tot_lancto_ctbl.
                assign
                    tot_lancto_ctbl.num_lote_ctbl = aprop_lancto_ctbl.num_lote_ctbl
                    tot_lancto_ctbl.num_lancto_ctbl = aprop_lancto_ctbl.num_lancto_ctbl
                    tot_lancto_ctbl.cod_finalid_econ = aprop_lancto_ctbl.cod_finalid_econ
                    tot_lancto_ctbl.qtd_aprop_lancto_ctbl = 1.

                if  item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" then do:
                    assign
                        tot_lancto_ctbl.val_lancto_ctbl_db = aprop_lancto_ctbl.val_lancto_ctbl.
                end.
                else do:
                    assign
                        tot_lancto_ctbl.val_lancto_ctbl_cr = aprop_lancto_ctbl.val_lancto_ctbl.
                end.
            end.
            else do:
                if  item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" then do:
                    assign
                        tot_lancto_ctbl.val_lancto_ctbl_db = tot_lancto_ctbl.val_lancto_ctbl_db
                            + aprop_lancto_ctbl.val_lancto_ctbl.
                end.
                else do:
                    assign
                        tot_lancto_ctbl.val_lancto_ctbl_cr = tot_lancto_ctbl.val_lancto_ctbl_cr
                            + aprop_lancto_ctbl.val_lancto_ctbl.
                end.
                assign
                    tot_lancto_ctbl.qtd_aprop_lancto_ctbl = tot_lancto_ctbl.qtd_aprop_lancto_ctbl + 1.
            end.
        end.

        release tot_lancto_ctbl no-error.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateDivide C-Win 
PROCEDURE validateDivide :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable valorTotal as decimal   no-undo.
    
    do {&throws}:
        for each ttRateio
            no-lock
            {&throws}:
            assign
                valorTotal = valorTotal + ttRateio.valor.
        end.

        if valorTotal <> ttItem.val_lancto_ctbl then do:
            run insertError(524, 'Valor total do rateio de diferente do valor do lanáamento',
                substitute('Valor total &1 do rateio de diferente do valor do lanáamento &2',
                valorTotal, item_lancto_ctbl.val_lancto_ctbl)).
            return error.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateGenerate C-Win 
PROCEDURE validateGenerate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable credito as decimal   no-undo.
    define variable debito as decimal   no-undo.

    do {&throws}:
        if trim(descLote:input-value in frame {&frame-name}) = '' then do:
            run insertError(524, 'Descriá∆o do Lote n∆o pode ficar em branco',
                'Descriá∆o do Lote n∆o pode ficar em branco').
            return error.
        end.

        for each ttItem
            where ttItem.num_lote_ctbl = numeroLote
            no-lock
            {&throws}:

            find ttAlterado of item_lancto_ctbl no-lock no-error.
            if avail ttAlterado then
                next.

            if ttItem.ind_natur_lancto_ctbl = 'CR' then
                assign
                    credito = credito + ttItem.val_lancto_ctbl.
            else
                assign
                    debito = debito + ttItem.val_lancto_ctbl.
        end.

        if credito <> debito then do:
            run insertError(524, 'Lote Original possui diferenáa',
                substitute('Lote Original possui diferenáa entre CR &1 e BD &2',
                credito, debito)).
            return error.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyGenerate C-Win 
PROCEDURE verifyGenerate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter doGenerate as logical    no-undo.

    do {&throws}:
        find first ttAlterado no-lock no-error.
        
        assign
            doGenerate = avail ttAlterado.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getSituacao C-Win 
FUNCTION getSituacao RETURNS CHARACTER
  (  input numeroLancamento as integer, input sequencia as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    if can-find(ttAlterado 
                where ttAlterado.num_lote_ctbl = numeroLote       
                  and ttAlterado.num_lancto_ctbl = numeroLancamento     
                  and ttAlterado.num_seq_lancto_ctbl = sequencia) then
        return '*'.
    else
        return ''.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

