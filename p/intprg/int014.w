&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int_ds_nota_entrada NO-UNDO LIKE int_ds_nota_entrada
       field cod-estabel like docum-est.cod-estabel
       field nome-estabel like estabelec.nome
       field cod-emitente like docum-est.cod-emitente
       field nome-abrev like emitente.nome-abrev
       field mensagem as char format "X(500)"
       .
DEFINE TEMP-TABLE tt-int_ds_nota_entrada_produt NO-UNDO LIKE int_ds_nota_entrada_produt.
DEFINE TEMP-TABLE tt-int_ds_nota_loja NO-UNDO LIKE int_ds_nota_loja
       field r-rowid as rowid
       field cod-estabel like docum-est.cod-estabel
       field nome-estabel like estabelec.nome
       field cod-emitente like docum-est.cod-emitente
       field nome-abrev like emitente.nome-abrev
       field mensagem as char format "X(500)".
DEFINE TEMP-TABLE tt-int_ds_nota_loja_item NO-UNDO LIKE int_ds_nota_loja_item
       field r-rowid as rowid.
DEFINE TEMP-TABLE tt-int_ds_nota_saida NO-UNDO LIKE int_ds_nota_saida
       field cod-estabel like docum-est.cod-estabel
       field nome-estabel like estabelec.nome
       field cod-emitente like docum-est.cod-emitente
       field nome-abrev like emitente.nome-abrev
       field mensagem as char format "X(500)"
       .
DEFINE TEMP-TABLE tt-int_ds_nota_saida_item NO-UNDO LIKE int_ds_nota_saida_item.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*************************f******************************************************/
/********************************************************************************
** Programa: int014 - Monitor de Integraá∆o de Notas Tutorial/PRS X Datasul
**
** Versao : 12 - 23/02/2016 - Alessandro V Baccin
**
********************************************************************************/
{include/i-prgvrs.i INT014 2.12.01.AVB}
current-language = current-language.
CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT014
&GLOBAL-DEFINE Version        2.12.01.AVB

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         YES
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Entradas, Sa°das, Cupons

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK btCancel BtConfer btReenvia btHelp2 btSelecao btAtualiza c-intervalo rs-consulta
&GLOBAL-DEFINE page1Widgets   
&GLOBAL-DEFINE page2Widgets   
&GLOBAL-DEFINE page3Widgets   

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEF VAR c-nome-ab-cli-ini                   LIKE nota-fiscal.nome-ab-cli     INITIAL "            " NO-UNDO.
DEF VAR c-nome-ab-cli-fim                   LIKE nota-fiscal.nome-ab-cli     INITIAL "ZZZZZZZZZZZZ" NO-UNDO.
DEF VAR c-cod-estabel-ini                   LIKE nota-fiscal.cod-estabel     INITIAL "     " NO-UNDO. 
DEF VAR c-cod-estabel-fim                   LIKE nota-fiscal.cod-estabel     INITIAL "ZZZZZ" NO-UNDO.
DEF VAR c-serie-ini                         LIKE nota-fiscal.serie           INITIAL "     " NO-UNDO.
DEF VAR c-serie-fim                         LIKE nota-fiscal.serie           INITIAL "ZZZZZ" NO-UNDO.
DEF VAR c-nr-nota-fis-ini                   LIKE nota-fiscal.nr-nota-fis     INITIAL "0" NO-UNDO.
DEF VAR c-nr-nota-fis-fim                   LIKE nota-fiscal.nr-nota-fis     INITIAL "9999999" format "9999999" NO-UNDO.
DEF VAR d-da-dt-emis-ini                    LIKE nota-fiscal.dt-emis-nota    INITIAL TODAY NO-UNDO.
DEF VAR d-da-dt-emis-fim                    LIKE nota-fiscal.dt-emis-nota    INITIAL TODAY NO-UNDO.
DEF VAR c-nr-embarque-ini                   LIKE nota-fiscal.nr-embarque     NO-UNDO.
DEF VAR c-nr-embarque-fim                   LIKE nota-fiscal.nr-embarque     INITIAL 99999999 NO-UNDO.
DEF VAR i-tipo_movto                        as integer initial 0 no-undo.
DEF VAR i-situacao                          as integer initial 0 no-undo.
DEF VAR i-tipo-docto                        as integer initial 0 no-undo.
def var c-desc-item                         as char no-undo.
def var h-acomp                             as handle no-undo.

DEF VAR c-mensagem-1                        as char NO-UNDO.
DEF VAR c-mensagem-2                        as char NO-UNDO.


DEFINE TEMP-TABLE tt2-int_ds_nota_entrada NO-UNDO LIKE int_ds_nota_entrada.
DEFINE BUFFER b-int_ds_nota_entrada         FOR int_ds_nota_entrada.
DEFINE BUFFER b-int_ds_nota_entrada_produt  FOR int_ds_nota_entrada_produt.
DEFINE BUFFER b-int_ds_nota_entrada_dup     FOR int_ds_nota_entrada_dup.
DEFINE BUFFER b-int_dp_nota_entrada_ret     FOR int_dp_nota_entrada_ret.
DEFINE BUFFER b-int_dp_nota_entrada_ret_it  FOR int_dp_nota_entrada_ret_it.

def new global shared var c-seg-usuario   as char no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brNotaEntrada

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int_ds_nota_entrada ~
tt-int_ds_nota_entrada_produt tt-int_ds_nota_loja tt-int_ds_nota_loja_item ~
tt-int_ds_nota_saida tt-int_ds_nota_saida_item

/* Definitions for BROWSE brNotaEntrada                                 */
&Scoped-define FIELDS-IN-QUERY-brNotaEntrada tt-int_ds_nota_entrada.dt_geracao tt-int_ds_nota_entrada.hr_geracao tt-int_ds_nota_entrada.tipo_movto tt-int_ds_nota_entrada.cod-estabel tt-int_ds_nota_entrada.cod-emitente tt-int_ds_nota_entrada.nome-abrev tt-int_ds_nota_entrada.nen_dataemissao tt-int_ds_nota_entrada.nen_serie_s tt-int_ds_nota_entrada.nen_notafiscal_n tt-int_ds_nota_entrada.situacao tt-int_ds_nota_entrada.nen_conferida_n tt-int_ds_nota_entrada.nen_datamovimentacao_d tt-int_ds_nota_entrada.mensagem   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brNotaEntrada   
&Scoped-define SELF-NAME brNotaEntrada
&Scoped-define QUERY-STRING-brNotaEntrada FOR EACH tt-int_ds_nota_entrada NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brNotaEntrada OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_nota_entrada NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brNotaEntrada tt-int_ds_nota_entrada
&Scoped-define FIRST-TABLE-IN-QUERY-brNotaEntrada tt-int_ds_nota_entrada


/* Definitions for BROWSE brNotaEntradaProduto                          */
&Scoped-define FIELDS-IN-QUERY-brNotaEntradaProduto ~
tt-int_ds_nota_entrada_produt.nep_sequencia_n ~
tt-int_ds_nota_entrada_produt.nep_produto_n ~
fnItem(tt-int_ds_nota_entrada_produt.nep_produto_n) @ c-desc-item ~
tt-int_ds_nota_entrada_produt.nep_quantidade_n ~
tt-int_ds_nota_entrada_produt.nep_valorbruto_n ~
tt-int_ds_nota_entrada_produt.nep_lote_s 
&Scoped-define ENABLED-FIELDS-IN-QUERY-brNotaEntradaProduto 
&Scoped-define QUERY-STRING-brNotaEntradaProduto FOR EACH tt-int_ds_nota_entrada_produt NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brNotaEntradaProduto OPEN QUERY brNotaEntradaProduto FOR EACH tt-int_ds_nota_entrada_produt NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brNotaEntradaProduto ~
tt-int_ds_nota_entrada_produt
&Scoped-define FIRST-TABLE-IN-QUERY-brNotaEntradaProduto tt-int_ds_nota_entrada_produt


/* Definitions for BROWSE brNotaLoja                                    */
&Scoped-define FIELDS-IN-QUERY-brNotaLoja tt-int_ds_nota_loja.dt_geracao tt-int_ds_nota_loja.hr_geracao tt-int_ds_nota_loja.tipo_movto tt-int_ds_nota_loja.cod-estabel tt-int_ds_nota_loja.cnpjcpf_imp_cup tt-int_ds_nota_loja.cod-emitente tt-int_ds_nota_loja.nome-abrev tt-int_ds_nota_loja.emissao tt-int_ds_nota_loja.serie tt-int_ds_nota_loja.num_nota tt-int_ds_nota_loja.situacao tt-int_ds_nota_loja.mensagem   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brNotaLoja   
&Scoped-define SELF-NAME brNotaLoja
&Scoped-define QUERY-STRING-brNotaLoja FOR EACH tt-int_ds_nota_loja NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brNotaLoja OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_nota_loja NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brNotaLoja tt-int_ds_nota_loja
&Scoped-define FIRST-TABLE-IN-QUERY-brNotaLoja tt-int_ds_nota_loja


/* Definitions for BROWSE brNotaLojaItem                                */
&Scoped-define FIELDS-IN-QUERY-brNotaLojaItem ~
tt-int_ds_nota_loja_item.sequencia tt-int_ds_nota_loja_item.produto ~
fnItem(int(tt-int_ds_nota_loja_item.produto)) @ c-desc-item ~
tt-int_ds_nota_loja_item.quantidade tt-int_ds_nota_loja_item.preco_unit ~
tt-int_ds_nota_loja_item.desconto tt-int_ds_nota_loja_item.preco_liqu ~
tt-int_ds_nota_loja_item.datavalidade ~
tt-int_ds_nota_loja_item.datafabricacao tt-int_ds_nota_loja_item.lote 
&Scoped-define ENABLED-FIELDS-IN-QUERY-brNotaLojaItem 
&Scoped-define QUERY-STRING-brNotaLojaItem FOR EACH tt-int_ds_nota_loja_item NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brNotaLojaItem OPEN QUERY brNotaLojaItem FOR EACH tt-int_ds_nota_loja_item NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brNotaLojaItem tt-int_ds_nota_loja_item
&Scoped-define FIRST-TABLE-IN-QUERY-brNotaLojaItem tt-int_ds_nota_loja_item


/* Definitions for BROWSE brNotaSaida                                   */
&Scoped-define FIELDS-IN-QUERY-brNotaSaida tt-int_ds_nota_saida.dt_geracao tt-int_ds_nota_saida.hr_geracao tt-int_ds_nota_saida.tipo_movto tt-int_ds_nota_saida.cod-estabel tt-int_ds_nota_saida.cod-emitente tt-int_ds_nota_saida.nome-abrev tt-int_ds_nota_saida.nsa_data tt-int_ds_nota_saida.nsa_serie_s tt-int_ds_nota_saida.nsa_notafiscal_n tt-int_ds_nota_saida.situacao tt-int_ds_nota_saida.mensagem   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brNotaSaida   
&Scoped-define SELF-NAME brNotaSaida
&Scoped-define QUERY-STRING-brNotaSaida FOR EACH tt-int_ds_nota_saida NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brNotaSaida OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_nota_saida NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brNotaSaida tt-int_ds_nota_saida
&Scoped-define FIRST-TABLE-IN-QUERY-brNotaSaida tt-int_ds_nota_saida


/* Definitions for BROWSE brNotaSaidaItem                               */
&Scoped-define FIELDS-IN-QUERY-brNotaSaidaItem ~
tt-int_ds_nota_saida_item.nsp_sequencia_n ~
tt-int_ds_nota_saida_item.nsp_produto_n ~
fnItem(tt-int_ds_nota_saida_item.nsp_produto_n) @ c-desc-item ~
tt-int_ds_nota_saida_item.nsp_quantidade_n ~
tt-int_ds_nota_saida_item.nsp_valorbruto_n ~
tt-int_ds_nota_saida_item.nsp_lote_s tt-int_ds_nota_saida_item.nsp_caixa_n ~
tt-int_ds_nota_saida_item.ped_codigo_n 
&Scoped-define ENABLED-FIELDS-IN-QUERY-brNotaSaidaItem 
&Scoped-define QUERY-STRING-brNotaSaidaItem FOR EACH tt-int_ds_nota_saida_item NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brNotaSaidaItem OPEN QUERY brNotaSaidaItem FOR EACH tt-int_ds_nota_saida_item NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brNotaSaidaItem tt-int_ds_nota_saida_item
&Scoped-define FIRST-TABLE-IN-QUERY-brNotaSaidaItem tt-int_ds_nota_saida_item


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brNotaEntrada}~
    ~{&OPEN-QUERY-brNotaEntradaProduto}

/* Definitions for FRAME fPage2                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage2 ~
    ~{&OPEN-QUERY-brNotaSaida}~
    ~{&OPEN-QUERY-brNotaSaidaItem}

/* Definitions for FRAME fPage3                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage3 ~
    ~{&OPEN-QUERY-brNotaLoja}~
    ~{&OPEN-QUERY-brNotaLojaItem}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 rtToolBar RECT-consulta RECT-1 ~
btSelecao btQueryJoins btReportsJoins btExit btHelp rs-consulta btAtualiza ~
btOK btCancel BtConfer btReenvia btHelp2 
&Scoped-Define DISPLAYED-OBJECTS rs-consulta c-intervalo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnCod-Emitente wWindow 
FUNCTION fnCod-Emitente RETURNS integer
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnCod-Estabel wWindow 
FUNCTION fnCod-Estabel RETURNS CHARACTER
  ( pcnpj as char,
    pdata as date )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnItem wWindow 
FUNCTION fnItem RETURNS CHARACTER
  ( pcod-produto as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnNome-Abrev wWindow 
FUNCTION fnNome-Abrev RETURNS CHARACTER
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnRefresh wWindow 
FUNCTION fnRefresh returns logical ( )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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


/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btAtualiza 
     IMAGE-UP FILE "image/im-relo.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-relo.bmp":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON BtConfer 
     LABEL "Excluir Conf." 
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

DEFINE BUTTON btReenvia 
     LABEL "Reenvia Proc" 
     SIZE 11 BY 1.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btSelecao 
     IMAGE-UP FILE "image\im-ran":U
     IMAGE-INSENSITIVE FILE "image\ii-ran":U
     LABEL "Seleá∆o" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE VARIABLE c-intervalo AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 60 
     VIEW-AS FILL-IN 
     SIZE 4.72 BY .79 NO-UNDO.

DEFINE VARIABLE rs-consulta AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Manual", 1,
"Autom†tico", 2
     SIZE 11.57 BY 1.5 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 16 BY 2.17.

DEFINE RECTANGLE RECT-consulta
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 32.72 BY 2.17.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 135 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 135 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brNotaEntrada FOR 
      tt-int_ds_nota_entrada SCROLLING.

DEFINE QUERY brNotaEntradaProduto FOR 
      tt-int_ds_nota_entrada_produt SCROLLING.

DEFINE QUERY brNotaLoja FOR 
      tt-int_ds_nota_loja SCROLLING.

DEFINE QUERY brNotaLojaItem FOR 
      tt-int_ds_nota_loja_item SCROLLING.

DEFINE QUERY brNotaSaida FOR 
      tt-int_ds_nota_saida SCROLLING.

DEFINE QUERY brNotaSaidaItem FOR 
      tt-int_ds_nota_saida_item SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brNotaEntrada
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brNotaEntrada wWindow _FREEFORM
  QUERY brNotaEntrada NO-LOCK DISPLAY
      tt-int_ds_nota_entrada.dt_geracao FORMAT "99/99/9999":U
      tt-int_ds_nota_entrada.hr_geracao FORMAT "x(8)":U
      tt-int_ds_nota_entrada.tipo_movto FORMAT "9":U
      tt-int_ds_nota_entrada.cod-estabel 
      tt-int_ds_nota_entrada.cod-emitente
      tt-int_ds_nota_entrada.nome-abrev format "X(14)"
      tt-int_ds_nota_entrada.nen_dataemissao FORMAT "99/99/9999"
      tt-int_ds_nota_entrada.nen_serie_s FORMAT "x(3)":U
      tt-int_ds_nota_entrada.nen_notafiscal_n FORMAT ">>>,>>>,>>9":U
      tt-int_ds_nota_entrada.situacao FORMAT "9":U
      tt-int_ds_nota_entrada.nen_conferida_n FORMAT "9":U COLUMN-LABEL "Conf"
      tt-int_ds_nota_entrada.nen_datamovimentacao_d column-label "Dt Conf."
      tt-int_ds_nota_entrada.mensagem column-label "Mensagem"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS NO-SCROLLBAR-VERTICAL SIZE 132.29 BY 11.21
         FONT 1.

DEFINE BROWSE brNotaEntradaProduto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brNotaEntradaProduto wWindow _STRUCTURED
  QUERY brNotaEntradaProduto NO-LOCK DISPLAY
      tt-int_ds_nota_entrada_produt.nep_sequencia_n COLUMN-LABEL "Seq"
            WIDTH 9.57
      tt-int_ds_nota_entrada_produt.nep_produto_n
      fnItem(tt-int_ds_nota_entrada_produt.nep_produto_n) @ c-desc-item COLUMN-LABEL "Descriá∆o" FORMAT "X(65)":U
            WIDTH 63.43
      tt-int_ds_nota_entrada_produt.nep_quantidade_n WIDTH 12
      tt-int_ds_nota_entrada_produt.nep_valorbruto_n WIDTH 13.57
      tt-int_ds_nota_entrada_produt.nep_lote_s
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 132.29 BY 6.33
         FONT 1.

DEFINE BROWSE brNotaLoja
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brNotaLoja wWindow _FREEFORM
  QUERY brNotaLoja NO-LOCK DISPLAY
      tt-int_ds_nota_loja.dt_geracao FORMAT "99/99/9999":U
      tt-int_ds_nota_loja.hr_geracao FORMAT "x(8)":U
      tt-int_ds_nota_loja.tipo_movto FORMAT "9":U
      tt-int_ds_nota_loja.cod-estabel 
      tt-int_ds_nota_loja.cnpjcpf_imp_cup column-label "CPF" FORMAT "X(14)"
      tt-int_ds_nota_loja.cod-emitente
      tt-int_ds_nota_loja.nome-abrev format "X(12)"
      tt-int_ds_nota_loja.emissao FORMAT "99/99/9999" column-label "Data"
      tt-int_ds_nota_loja.serie FORMAT "x(3)":U
      tt-int_ds_nota_loja.num_nota FORMAT "X(10)":U
      tt-int_ds_nota_loja.situacao FORMAT "9":U
      tt-int_ds_nota_loja.mensagem column-label "Mensagem" format "X(500)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS NO-SCROLLBAR-VERTICAL SIZE 132.29 BY 11.21
         FONT 1.

DEFINE BROWSE brNotaLojaItem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brNotaLojaItem wWindow _STRUCTURED
  QUERY brNotaLojaItem NO-LOCK DISPLAY
      tt-int_ds_nota_loja_item.sequencia
      tt-int_ds_nota_loja_item.produto
      fnItem(int(tt-int_ds_nota_loja_item.produto)) @ c-desc-item COLUMN-LABEL "Descriá∆o Item" FORMAT "X(65)":U
            WIDTH 42.86
      tt-int_ds_nota_loja_item.quantidade
      tt-int_ds_nota_loja_item.preco_unit
      tt-int_ds_nota_loja_item.desconto
      tt-int_ds_nota_loja_item.preco_liqu
      tt-int_ds_nota_loja_item.datavalidade
      tt-int_ds_nota_loja_item.datafabricacao
      tt-int_ds_nota_loja_item.lote
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 132.29 BY 6.33
         FONT 1.

DEFINE BROWSE brNotaSaida
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brNotaSaida wWindow _FREEFORM
  QUERY brNotaSaida NO-LOCK DISPLAY
      tt-int_ds_nota_saida.dt_geracao FORMAT "99/99/9999":U
      tt-int_ds_nota_saida.hr_geracao FORMAT "x(8)":U
      tt-int_ds_nota_saida.tipo_movto FORMAT "9":U
      tt-int_ds_nota_saida.cod-estabel 
      tt-int_ds_nota_saida.cod-emitente
      tt-int_ds_nota_saida.nome-abrev format "X(14)"
      tt-int_ds_nota_saida.nsa_data FORMAT "99/99/9999"
      tt-int_ds_nota_saida.nsa_serie_s FORMAT "x(3)":U
      tt-int_ds_nota_saida.nsa_notafiscal_n FORMAT ">>>,>>>,>>9":U
      tt-int_ds_nota_saida.situacao FORMAT "9":U
      tt-int_ds_nota_saida.mensagem column-label "Mensagem"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS NO-SCROLLBAR-VERTICAL SIZE 132.29 BY 11.21
         FONT 1.

DEFINE BROWSE brNotaSaidaItem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brNotaSaidaItem wWindow _STRUCTURED
  QUERY brNotaSaidaItem NO-LOCK DISPLAY
      tt-int_ds_nota_saida_item.nsp_sequencia_n COLUMN-LABEL "Seq"
            WIDTH 9.57
      tt-int_ds_nota_saida_item.nsp_produto_n
      fnItem(tt-int_ds_nota_saida_item.nsp_produto_n) @ c-desc-item COLUMN-LABEL "Descriá∆o" FORMAT "X(65)":U
            WIDTH 56.14
      tt-int_ds_nota_saida_item.nsp_quantidade_n WIDTH 8
      tt-int_ds_nota_saida_item.nsp_valorbruto_n WIDTH 12.57
      tt-int_ds_nota_saida_item.nsp_lote_s WIDTH 14
      tt-int_ds_nota_saida_item.nsp_caixa_n WIDTH 6.57
      tt-int_ds_nota_saida_item.ped_codigo_n
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 132.29 BY 6.33
         FONT 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btSelecao AT ROW 1.08 COL 1.57 HELP
          "Relat¢rios relacionados" WIDGET-ID 2
     btQueryJoins AT ROW 1.13 COL 119.43 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 123.43 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 127.43 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 131.43 HELP
          "Ajuda"
     rs-consulta AT ROW 3.42 COL 104 NO-LABEL WIDGET-ID 10
     btAtualiza AT ROW 3.58 COL 129 HELP
          "Consultas relacionadas" WIDGET-ID 4
     c-intervalo AT ROW 3.92 COL 115 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     btOK AT ROW 23.63 COL 2
     btCancel AT ROW 23.63 COL 13
     BtConfer AT ROW 23.63 COL 24 WIDGET-ID 28
     btReenvia AT ROW 23.63 COL 35 WIDGET-ID 30
     btHelp2 AT ROW 23.63 COL 125.43
     "Consulta" VIEW-AS TEXT
          SIZE 8 BY .54 AT ROW 2.58 COL 105 WIDGET-ID 14
     "seg" VIEW-AS TEXT
          SIZE 4.29 BY .54 AT ROW 4.08 COL 122.57 WIDGET-ID 16
     "1 - Pendente" VIEW-AS TEXT
          SIZE 10 BY .54 AT ROW 3.25 COL 89 WIDGET-ID 20
     "Situaá∆o" VIEW-AS TEXT
          SIZE 7 BY .54 AT ROW 2.63 COL 87 WIDGET-ID 26
     "2 - Integrado" VIEW-AS TEXT
          SIZE 10 BY .54 AT ROW 4 COL 89 WIDGET-ID 22
     rtToolBar-2 AT ROW 1 COL 1
     rtToolBar AT ROW 23.42 COL 1
     RECT-consulta AT ROW 2.88 COL 102.57 WIDGET-ID 8
     RECT-1 AT ROW 2.88 COL 86 WIDGET-ID 24
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 135.14 BY 23.83
         FONT 1.

DEFINE FRAME fPage2
     brNotaSaida AT ROW 1 COL 1 WIDGET-ID 300
     brNotaSaidaItem AT ROW 12.46 COL 1 WIDGET-ID 400
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.25 ROW 5.27
         SIZE 132.5 BY 17.87
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage3
     brNotaLoja AT ROW 1 COL 1 WIDGET-ID 200
     brNotaLojaItem AT ROW 12.46 COL 1 WIDGET-ID 500
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.25 ROW 5.27
         SIZE 132.5 BY 17.87
         FONT 1 WIDGET-ID 600.

DEFINE FRAME fPage1
     brNotaEntrada AT ROW 1 COL 1 WIDGET-ID 200
     brNotaEntradaProduto AT ROW 12.46 COL 1 WIDGET-ID 500
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.25 ROW 5.27
         SIZE 132.5 BY 17.87
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int_ds_nota_entrada T "?" NO-UNDO emsesp int_ds_nota_entrada
      ADDITIONAL-FIELDS:
          field cod-estabel like docum-est.cod-estabel
          field nome-estabel like estabelec.nome
          field cod-emitente like docum-est.cod-emitente
          field nome-abrev like emitente.nome-abrev
          field mensagem as char format "X(500)"
          
      END-FIELDS.
      TABLE: tt-int_ds_nota_entrada_produt T "?" NO-UNDO emsesp int_ds_nota_entrada_produt
      TABLE: tt-int_ds_nota_loja T "?" NO-UNDO emsesp int_ds_nota_loja
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
          field cod-estabel like docum-est.cod-estabel
          field nome-estabel like estabelec.nome
          field cod-emitente like docum-est.cod-emitente
          field nome-abrev like emitente.nome-abrev
          field mensagem as char format "X(500)"
      END-FIELDS.
      TABLE: tt-int_ds_nota_loja_item T "?" NO-UNDO emsesp int_ds_nota_loja_item
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
      TABLE: tt-int_ds_nota_saida T "?" NO-UNDO emsesp int_ds_nota_saida
      ADDITIONAL-FIELDS:
          field cod-estabel like docum-est.cod-estabel
          field nome-estabel like estabelec.nome
          field cod-emitente like docum-est.cod-emitente
          field nome-abrev like emitente.nome-abrev
          field mensagem as char format "X(500)"
          
      END-FIELDS.
      TABLE: tt-int_ds_nota_saida_item T "?" NO-UNDO emsesp int_ds_nota_saida_item
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 23.83
         WIDTH              = 135.14
         MAX-HEIGHT         = 24.04
         MAX-WIDTH          = 135.14
         VIRTUAL-HEIGHT     = 24.04
         VIRTUAL-WIDTH      = 135.14
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
       FRAME fPage2:FRAME = FRAME fpage0:HANDLE
       FRAME fPage3:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN c-intervalo IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brNotaEntrada 1 fPage1 */
/* BROWSE-TAB brNotaEntradaProduto brNotaEntrada fPage1 */
/* SETTINGS FOR FRAME fPage2
                                                                        */
/* BROWSE-TAB brNotaSaida 1 fPage2 */
/* BROWSE-TAB brNotaSaidaItem brNotaSaida fPage2 */
/* SETTINGS FOR FRAME fPage3
                                                                        */
/* BROWSE-TAB brNotaLoja 1 fPage3 */
/* BROWSE-TAB brNotaLojaItem brNotaLoja fPage3 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brNotaEntrada
/* Query rebuild information for BROWSE brNotaEntrada
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_nota_entrada NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE brNotaEntrada */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brNotaEntradaProduto
/* Query rebuild information for BROWSE brNotaEntradaProduto
     _TblList          = "Temp-Tables.tt-int_ds_nota_entrada_produt"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.tt-int_ds_nota_entrada_produt.nep_sequencia_n
"tt-int_ds_nota_entrada_produt.nep_sequencia_n" "Seq" ? "integer" ? ? ? ? ? ? no ? no no "9.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.tt-int_ds_nota_entrada_produt.nep_produto_n
     _FldNameList[3]   > "_<CALC>"
"fnItem(tt-int_ds_nota_entrada_produt.nep_produto_n) @ c-desc-item" "Descriá∆o" "X(65)" ? ? ? ? ? ? ? no ? no no "63.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-int_ds_nota_entrada_produt.nep_quantidade_n
"tt-int_ds_nota_entrada_produt.nep_quantidade_n" ? ? "decimal" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.tt-int_ds_nota_entrada_produt.nep_valorbruto_n
"tt-int_ds_nota_entrada_produt.nep_valorbruto_n" ? ? "decimal" ? ? ? ? ? ? no ? no no "13.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = Temp-Tables.tt-int_ds_nota_entrada_produt.nep_lote_s
     _Query            is OPENED
*/  /* BROWSE brNotaEntradaProduto */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brNotaLoja
/* Query rebuild information for BROWSE brNotaLoja
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_nota_loja NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE brNotaLoja */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brNotaLojaItem
/* Query rebuild information for BROWSE brNotaLojaItem
     _TblList          = "Temp-Tables.tt-int_ds_nota_loja_item"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = Temp-Tables.tt-int_ds_nota_loja_item.sequencia
     _FldNameList[2]   = Temp-Tables.tt-int_ds_nota_loja_item.produto
     _FldNameList[3]   > "_<CALC>"
"fnItem(int(tt-int_ds_nota_loja_item.produto)) @ c-desc-item" "Descriá∆o Item" "X(65)" ? ? ? ? ? ? ? no ? no no "42.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   = Temp-Tables.tt-int_ds_nota_loja_item.quantidade
     _FldNameList[5]   = Temp-Tables.tt-int_ds_nota_loja_item.preco_unit
     _FldNameList[6]   = Temp-Tables.tt-int_ds_nota_loja_item.desconto
     _FldNameList[7]   = Temp-Tables.tt-int_ds_nota_loja_item.preco_liqu
     _FldNameList[8]   = Temp-Tables.tt-int_ds_nota_loja_item.datavalidade
     _FldNameList[9]   = Temp-Tables.tt-int_ds_nota_loja_item.datafabricacao
     _FldNameList[10]   = Temp-Tables.tt-int_ds_nota_loja_item.lote
     _Query            is OPENED
*/  /* BROWSE brNotaLojaItem */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brNotaSaida
/* Query rebuild information for BROWSE brNotaSaida
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_nota_saida NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE brNotaSaida */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brNotaSaidaItem
/* Query rebuild information for BROWSE brNotaSaidaItem
     _TblList          = "Temp-Tables.tt-int_ds_nota_saida_item"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.tt-int_ds_nota_saida_item.nsp_sequencia_n
"tt-int_ds_nota_saida_item.nsp_sequencia_n" "Seq" ? "integer" ? ? ? ? ? ? no ? no no "9.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.tt-int_ds_nota_saida_item.nsp_produto_n
     _FldNameList[3]   > "_<CALC>"
"fnItem(tt-int_ds_nota_saida_item.nsp_produto_n) @ c-desc-item" "Descriá∆o" "X(65)" ? ? ? ? ? ? ? no ? no no "56.14" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-int_ds_nota_saida_item.nsp_quantidade_n
"tt-int_ds_nota_saida_item.nsp_quantidade_n" ? ? "decimal" ? ? ? ? ? ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.tt-int_ds_nota_saida_item.nsp_valorbruto_n
"tt-int_ds_nota_saida_item.nsp_valorbruto_n" ? ? "decimal" ? ? ? ? ? ? no ? no no "12.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.tt-int_ds_nota_saida_item.nsp_lote_s
"tt-int_ds_nota_saida_item.nsp_lote_s" ? ? "character" ? ? ? ? ? ? no ? no no "14" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > Temp-Tables.tt-int_ds_nota_saida_item.nsp_caixa_n
"tt-int_ds_nota_saida_item.nsp_caixa_n" ? ? "integer" ? ? ? ? ? ? no ? no no "6.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   = Temp-Tables.tt-int_ds_nota_saida_item.ped_codigo_n
     _Query            is OPENED
*/  /* BROWSE brNotaSaidaItem */
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

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage3
/* Query rebuild information for FRAME fPage3
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage3 */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME fpage0:HANDLE
       ROW             = 1
       COLUMN          = 112.57
       HEIGHT          = 1.5
       WIDTH           = 6
       WIDGET-ID       = 18
       HIDDEN          = yes
       SENSITIVE       = yes.
/* CtrlFrame OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: PSTimer */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


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


&Scoped-define BROWSE-NAME brNotaEntrada
&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME brNotaEntrada
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brNotaEntrada wWindow
ON VALUE-CHANGED OF brNotaEntrada IN FRAME fPage1
DO:
    OPEN query brNotaEntradaProduto for each tt-int_ds_nota_entrada_produt no-lock of tt-int_ds_nota_entrada.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brNotaEntradaProduto
&Scoped-define SELF-NAME brNotaEntradaProduto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brNotaEntradaProduto wWindow
ON VALUE-CHANGED OF brNotaEntradaProduto IN FRAME fPage1
DO:
    OPEN query brNotaEntradaProduto for each tt-int_ds_nota_entrada_produt no-lock of tt-int_ds_nota_entrada.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brNotaLoja
&Scoped-define FRAME-NAME fPage3
&Scoped-define SELF-NAME brNotaLoja
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brNotaLoja wWindow
ON VALUE-CHANGED OF brNotaLoja IN FRAME fPage3
DO:
    OPEN query brNotaLojaItem for each tt-int_ds_nota_loja_item no-lock of tt-int_ds_nota_loja.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brNotaSaida
&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME brNotaSaida
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brNotaSaida wWindow
ON VALUE-CHANGED OF brNotaSaida IN FRAME fPage2
DO:
    OPEN query brNotaSaidaItem for each tt-int_ds_nota_saida_item no-lock of tt-int_ds_nota_saida.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btAtualiza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAtualiza wWindow
ON CHOOSE OF btAtualiza IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF btAtualiza DO:
    fnRefresh().

    RUN pi-openQueryNotaEntrada.
    RUN pi-openQueryNotaSaida.
    RUN pi-openQueryNotaLoja.

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


&Scoped-define SELF-NAME BtConfer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtConfer wWindow
ON CHOOSE OF BtConfer IN FRAME fpage0 /* Excluir Conf. */
DO:
    RUN utp\ut-msgs.p (INPUT "SHOW",
                       INPUT 27100,
                       INPUT "Deseja Eliminar o Registro de Conferància? ").

    IF RETURN-VALUE = "YES" THEN DO:

        BROWSE brNotaEntrada:FETCH-SELECTED-ROW(1)no-error.   
            GET CURRENT brNotaEntrada.

        FOR FIRST b-int_ds_nota_entrada OF tt-int_ds_nota_entrada:

            IF b-int_ds_nota_entrada.situacao <> 1 THEN DO:

                ASSIGN b-int_ds_nota_entrada.situacao = 1
                       b-int_ds_nota_entrada.nen_conferida_n = 0.
            END.

            FIND FIRST b-int_dp_nota_entrada_ret EXCLUSIVE-LOCK
                WHERE  b-int_dp_nota_entrada_ret.nen_cnpj_origem_s  = b-int_ds_nota_entrada.nen_cnpj_origem_s 
                  AND  b-int_dp_nota_entrada_ret.nen_notafiscal_n   = b-int_ds_nota_entrada.nen_notafiscal_n  
                  AND  b-int_dp_nota_entrada_ret.nen_serie_s        = b-int_ds_nota_entrada.nen_serie_s   NO-ERROR.

            IF AVAIL b-int_dp_nota_entrada_ret THEN DO:

                FOR EACH b-int_dp_nota_entrada_ret_it EXCLUSIVE-LOCK
                    WHERE  b-int_dp_nota_entrada_ret_it.nen_cnpj_origem_s  = b-int_ds_nota_entrada.nen_cnpj_origem_s 
                      AND  b-int_dp_nota_entrada_ret_it.nen_notafiscal_n   = b-int_ds_nota_entrada.nen_notafiscal_n  
                      AND  b-int_dp_nota_entrada_ret_it.nen_serie_s        = b-int_ds_nota_entrada.nen_serie_s:

                    DELETE b-int_dp_nota_entrada_ret_it.

                END.

                RELEASE b-int_dp_nota_entrada_ret_it.

                DELETE b-int_dp_nota_entrada_ret.
                MESSAGE "Conferància da nota fiscal excluida com sucesso"
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

            END.
            ELSE DO:

                FOR EACH b-int_dp_nota_entrada_ret_it EXCLUSIVE-LOCK
                    WHERE  b-int_dp_nota_entrada_ret_it.nen_cnpj_origem_s  = b-int_ds_nota_entrada.nen_cnpj_origem_s 
                      AND  b-int_dp_nota_entrada_ret_it.nen_notafiscal_n   = b-int_ds_nota_entrada.nen_notafiscal_n  
                      AND  b-int_dp_nota_entrada_ret_it.nen_serie_s        = b-int_ds_nota_entrada.nen_serie_s:

                    DELETE b-int_dp_nota_entrada_ret_it.

                END.
                IF AVAIL b-int_dp_nota_entrada_ret_it THEN DO:
                    
                    MESSAGE "Conferància dos itens da nota fiscal excluidos com sucesso!"
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                END.
                ELSE DO:
                    MESSAGE "N∆o foi encontrado conferància para essa nota fiscal"
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                END.

                RELEASE b-int_dp_nota_entrada_ret_it.

            END.

            RELEASE b-int_dp_nota_entrada_ret.


        END.

        RUN pi-openQueryNotaEntrada.

    END.
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
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

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


&Scoped-define SELF-NAME btReenvia
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReenvia wWindow
ON CHOOSE OF btReenvia IN FRAME fpage0 /* Reenvia Proc */
DO:
  
    RUN utp\ut-msgs.p (INPUT "SHOW",
                       INPUT 27100,
                       INPUT "Deseja Reeviar o Registro para o Procfit? ").

    IF RETURN-VALUE = "YES" THEN DO:

        BROWSE brNotaEntrada:FETCH-SELECTED-ROW(1)no-error.   
            GET CURRENT brNotaEntrada.

        FOR FIRST b-int_ds_nota_entrada OF tt-int_ds_nota_entrada EXCLUSIVE-LOCK:

            ASSIGN b-int_ds_nota_entrada.situacao       = 1
                   b-int_ds_nota_entrada.ENVIO_STATUS   = 1
                   b-int_ds_nota_entrada.nen_conferida_n = 0
                   b-int_ds_nota_entrada.nen_datamovimentacao_d = ?.

            MESSAGE "Alterado para n∆o integrado Procfit" SKIP 
                    "A rotina Procfit que busca essa integraá∆o roda a cada 180 segundos" SKIP
                    "Favor aguardar"
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        END.

        FOR EACH b-int_ds_nota_entrada_produt OF tt-int_ds_nota_entrada :

            IF b-int_ds_nota_entrada_produt.nep_uComForn_s <> "UN" 
               AND b-int_ds_nota_entrada_produt.nep_uComForn_s <> "CX"   THEN DO:

                // nen_cnpj_origem_s nep_produto_n

                FIND FIRST emitente NO-LOCK
                    WHERE emitente.cgc = b-int_ds_nota_entrada_produt.nen_cnpj_origem_s NO-ERROR.

                FIND FIRST item-fornec NO-LOCK
                    WHERE item-fornec.item-do-forn   = TRIM(string(int(b-int_ds_nota_entrada_produt.alternativo_fornecedor)))
                      AND item-fornec.cod-emitente  = emitente.cod-emitente NO-ERROR.

                IF AVAIL item-fornec THEN DO:

                    IF item-fornec.unid-med-for  = b-int_ds_nota_entrada_produt.nep_uComForn_s THEN DO:

                        IF b-int_ds_nota_entrada_produt.nep_quantidade_n = b-int_ds_nota_entrada_produt.nep_qComForn_n THEN 
                            ASSIGN b-int_ds_nota_entrada_produt.nep_quantidade_n    = b-int_ds_nota_entrada_produt.nep_quantidade_n / (item-fornec.fator-conver / EXP(10, item-fornec.num-casa-dec))
                                   b-int_ds_nota_entrada_produt.nep_produto_n       = int(item-fornec.it-codigo).
                     //   ASSIGN b-int_ds_nota_entrada_produt.vnep_valorliquido_n = dec(de-vl-liquido-fri / b-int_ds_nota_entrada_produt.qcom).

                    END.

                END.

            END.



        END.



        RELEASE b-int_ds_nota_entrada.

    END.

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


&Scoped-define SELF-NAME btSelecao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSelecao wWindow
ON CHOOSE OF btSelecao IN FRAME fpage0 /* Seleá∆o */
OR CHOOSE OF btSelecao DO:
   fnRefresh().
   DEF VAR l-openquery AS LOG NO-UNDO.

   RUN intprg/int014a.w ( INPUT-OUTPUT c-nome-ab-cli-ini,
                          INPUT-OUTPUT c-nome-ab-cli-fim,
                          INPUT-OUTPUT c-cod-estabel-ini,
                          INPUT-OUTPUT c-cod-estabel-fim,
                          INPUT-OUTPUT c-serie-ini,      
                          INPUT-OUTPUT c-serie-fim,      
                          INPUT-OUTPUT c-nr-nota-fis-ini,
                          INPUT-OUTPUT c-nr-nota-fis-fim,
                          INPUT-OUTPUT d-da-dt-emis-ini, 
                          INPUT-OUTPUT d-da-dt-emis-fim, 
                          INPUT-OUTPUT c-nr-embarque-ini,
                          INPUT-OUTPUT c-nr-embarque-fim,
                          INPUT-OUTPUT c-mensagem-1,
                          INPUT-OUTPUT c-mensagem-2,
                          INPUT-OUTPUT i-tipo_movto,
                          INPUT-OUTPUT i-situacao,
                          INPUT-OUTPUT i-tipo-docto,
                          OUTPUT l-openquery ).

    if l-openquery and rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" then do:
      RUN pi-OpenQueryNotaEntrada.
      RUN pi-OpenQueryNotaSaida.
      RUN pi-OpenQueryNotaLoja.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-intervalo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-intervalo wWindow
ON LEAVE OF c-intervalo IN FRAME fpage0
DO: 
  IF INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) <> 0 THEN
      chCtrlFrame:PSTimer:interval = INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) * 1000.
  ELSE
      run utp/ut-msgs.p (input "show", 
                         input 17006, 
                         input "O intervalo de atualizaá∆o deve ser informado!").    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CtrlFrame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CtrlFrame wWindow OCX.Tick
PROCEDURE CtrlFrame.PSTimer.Tick .
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  None required for OCX.
  Notes:       
------------------------------------------------------------------------------*/
    APPLY "CHOOSE" TO btAtualiza IN FRAME fPage0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-consulta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-consulta wWindow
ON VALUE-CHANGED OF rs-consulta IN FRAME fpage0
DO:
  IF rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" THEN DO:
      ENABLE c-intervalo WITH FRAME fPage0.
      DISABLE btAtualiza WITH FRAME fPage0.
      display c-intervalo WITH FRAME fPage0.
      chCtrlFrame:PSTimer:interval = INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) * 1000.
  END.
  ELSE DO:
      DISABLE c-intervalo WITH FRAME fPage0. 
      ENABLE btAtualiza WITH FRAME fPage0.
      ASSIGN chCtrlFrame:PSTimer:interval = 0
             c-intervalo:SCREEN-VALUE IN FRAME fPage0 = "".
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brNotaEntrada
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*--- L¢gica para inicializaá∆o do programam ---*/
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
    apply "VALUE-CHANGED":U to rs-consulta in frame fPage0.

    FIND FIRST usuar_grp_usuar NO-LOCK
        WHERE usuar_grp_usuar.cod_grp_usuar = "I14"
          AND usuar_grp_usuar.cod_usuario   = c-seg-usuario NO-ERROR.

    IF AVAIL usuar_grp_usuar THEN DO:

        ASSIGN BtConfer:VISIBLE = YES
               BtReenvia:VISIBLE = YES.

    END.
    ELSE DO:
        ASSIGN BtConfer:VISIBLE = NO
               BtReenvia:VISIBLE = NO.
    END.



END PROCEDURE.

/*


Table: usuar_grp_usuar

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod_grp_usuar               char       im  x(3)
cod_usuario                 char       im  x(12)
cod_livre_1                 char           x(100)
cod_livre_2                 char           x(100)
val_livre_1                 deci-4         zzz,zzz,zz9.9999
val_livre_2                 deci-4         zzz,zzz,zz9.9999
num_livre_1                 inte           >>>>>9
num_livre_2                 inte           >>>>>9
log_livre_1                 logi           Sim/N∆o
log_livre_2                 logi           Sim/N∆o
dat_livre_1                 date           99/99/9999
dat_livre_2                 date           99/99/9999
des_checksum                char           x(20)


*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInitializeInterface wWindow 
PROCEDURE beforeInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    d-da-dt-emis-ini = today - 30.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load wWindow  _CONTROL-LOAD
PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs    
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the 
               OCXs in the interface.                        
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.

OCXFile = SEARCH( "int014.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame = CtrlFrame:COM-HANDLE
    UIB_S = chCtrlFrame:LoadControls( OCXFile, "CtrlFrame":U)
    CtrlFrame:NAME = "CtrlFrame":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "int014.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryNotaEntrada wWindow 
PROCEDURE pi-openQueryNotaEntrada :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def var c-cod-estabel as char no-undo.
def var i-cod-emitente as integer no-undo.
def var c-nome-abrev as char no-undo.

empty temp-table tt-int_ds_nota_entrada.
empty temp-table tt-int_ds_nota_entrada_produt.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Entradas").

if i-tipo-docto = 0 or i-tipo-docto = 1 then 
for each int_ds_nota_entrada no-lock where 
    (i-situacao = 0 or int_ds_nota_entrada.situacao = i-situacao) and
    int_ds_nota_entrada.nen_serie_s >= c-serie-ini and
    int_ds_nota_entrada.nen_serie_s <= c-serie-fim and
    int_ds_nota_entrada.nen_notafiscal_n >=  integer(c-nr-nota-fis-ini) and
    int_ds_nota_entrada.nen_notafiscal_n <= integer(c-nr-nota-fis-fim) and
    int_ds_nota_entrada.nen_dataemissao_d >= d-da-dt-emis-ini and
    int_ds_nota_entrada.nen_dataemissao_d <= d-da-dt-emis-fim
    query-tuning(no-lookahead)
    on stop undo, leave:

    if i-tipo_movto <> 0 and int_ds_nota_entrada.tipo_movto <> i-tipo_movto then next.
    if i-situacao <> 0 and int_ds_nota_entrada.situacao <> i-situacao then next.

    c-cod-estabel = fnCod-Estabel(int_ds_nota_entrada.nen_cnpj_destino_s, int_ds_nota_entrada.nen_dataemissao_d).

    if  c-cod-estabel <> "" and
       (c-cod-estabel < c-cod-estabel-ini or
        c-cod-estabel > c-cod-estabel-fim) then next.

    i-cod-emitente = ?.
    c-nome-abrev = "".
    for first emitente fields (cod-emitente nome-abrev)
        no-lock where emitente.cgc begins int_ds_nota_entrada.nen_cnpj_origem_s:
        i-cod-emitente = emitente.cod-emitente.
        c-nome-abrev = emitente.nome-abrev.
    end.    

    if  c-nome-abrev <> "" and
       (c-nome-abrev < c-nome-ab-cli-ini or 
        c-nome-abrev > c-nome-ab-cli-fim) then next.

    run pi-acompanhar in h-acomp (input "Entradas:" + string(int_ds_nota_entrada.nen_notafiscal_n)).



    for last int_ds_log no-lock where 
        int_ds_log.origem = "NFE" and
        int_ds_log.chave begins trim(int_ds_nota_entrada.nen_cnpj_origem_s) + "/" + 
                                trim(int_ds_nota_entrada.nen_serie_s) + "/" +
                                trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>>999999")) + "/" +
                                trim(string(int_ds_nota_entrada.nen_cfop_n)):
    end.
    if not avail int_ds_log then 
        for last int_ds_log no-lock where 
            int_ds_log.origem = "NFE" and
            int_ds_log.chave begins trim(int_ds_nota_entrada.nen_cnpj_origem_s) + "/" + 
                                    trim(int_ds_nota_entrada.nen_serie_s) + "/" +
                                    trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>>9999999")) + "/" +
                                    trim(string(int_ds_nota_entrada.nen_cfop_n)):
        end.
        if not avail int_ds_log then 
            for last int_ds_log no-lock where 
                int_ds_log.origem = "NFE" and
                int_ds_log.chave begins trim(int_ds_nota_entrada.nen_cnpj_origem_s) + "/" + 
                                        trim(int_ds_nota_entrada.nen_serie_s) + "/" and
                int_ds_log.chave matches "*" + trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>>>>>>>>>9")) + "/" +
                                        trim(string(int_ds_nota_entrada.nen_cfop_n)):
            end.
            if not avail int_ds_log then 
            for last int_ds_log no-lock where 
                int_ds_log.origem = "RETNFE" and
                int_ds_log.chave begins trim(int_ds_nota_entrada.nen_cnpj_origem_s) + "|" + 
                                        trim(int_ds_nota_entrada.nen_serie_s) + "|" +
                                        trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>>999999")):
            end.
            if not avail int_ds_log then 
                for last int_ds_log no-lock where 
                    int_ds_log.origem = "RETNFE" and
                    int_ds_log.chave begins trim(int_ds_nota_entrada.nen_cnpj_origem_s) + "|" + 
                                            trim(int_ds_nota_entrada.nen_serie_s) + "|" +
                                            trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>>9999999")):
                end.
                if not avail int_ds_log then 
                    for last int_ds_log no-lock where 
                        int_ds_log.origem = "RETNFE" and
                        int_ds_log.chave begins trim(int_ds_nota_entrada.nen_cnpj_origem_s) + "|" + 
                                                trim(int_ds_nota_entrada.nen_serie_s) + "|" and
                        int_ds_log.chave matches "*" + trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>>>>>>>>>9")):
                    end.
                    if not avail int_ds_log then 
                    for last int_ds_log no-lock where 
                        int_ds_log.origem = "RETNFE" and
                        int_ds_log.chave begins trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>>999999")) + "|" +
                                                trim(int_ds_nota_entrada.nen_serie_s):
                    end.
                    if not avail int_ds_log then 
                        for last int_ds_log no-lock where 
                            int_ds_log.origem = "RETNFE" and
                            int_ds_log.chave begins trim(int_ds_nota_entrada.nen_cnpj_origem_s) + "|" + 
                                                    trim(int_ds_nota_entrada.nen_serie_s) + "|" +
                                                    trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>>9999999")):
                        end.
                        if not avail int_ds_log then 
                            for last int_ds_log no-lock where 
                                int_ds_log.origem = "RETNFE" and
                                int_ds_log.chave begins trim(int_ds_nota_entrada.nen_cnpj_origem_s) + "|" + 
                                                        trim(int_ds_nota_entrada.nen_serie_s) + "|" and
                                int_ds_log.chave matches "*" + trim(string(int_ds_nota_entrada.nen_notafiscal_n,">>>>>>>>>>9")):
                            end.

    if (c-mensagem-1 <> "" or c-mensagem-2 <> "") and not avail int_ds_log then next.
    if avail int_ds_log then do:
       if c-mensagem-1 <> "" and 
          not int_ds_log.desc_ocorrencia matches trim(c-mensagem-1) + "*" then next.
       if c-mensagem-2 <> "" and 
          not int_ds_log.desc_ocorrencia matches "*" + trim(c-mensagem-2) + "*" then next.
    end.


    create tt-int_ds_nota_entrada.
    buffer-copy int_ds_nota_entrada to tt-int_ds_nota_entrada
        assign  tt-int_ds_nota_entrada.cod-estabel  = c-cod-estabel
                tt-int_ds_nota_entrada.cod-emitente = i-cod-emitente
                tt-int_ds_nota_entrada.nome-abrev   = c-nome-abrev.

    assign tt-int_ds_nota_entrada.dt_geracao   = int_ds_nota_entrada.dt_geracao
           tt-int_ds_nota_entrada.hr_geracao   = int_ds_nota_entrada.hr_geracao.

    if avail int_ds_log then do:
        if int_ds_log.origem = "RETNFE" then
            assign tt-int_ds_nota_entrada.mensagem = int_ds_log.cod_usuario + "-" + int_ds_log.desc_ocorrencia.
        else
            assign tt-int_ds_nota_entrada.mensagem = int_ds_log.desc_ocorrencia.
    end.
    for each int_ds_nota_entrada_produt no-lock of int_ds_nota_entrada
        query-tuning(no-lookahead):
        create tt-int_ds_nota_entrada_produt.
        buffer-copy int_ds_nota_entrada_produt to tt-int_ds_nota_entrada_produt.
    end.

end.
run pi-finalizar in h-acomp.

if can-find (first tt-int_ds_nota_entrada) then do:
    OPEN QUERY brNotaEntrada FOR EACH tt-int_ds_nota_entrada NO-LOCK INDEXED-REPOSITION.
    run setEnabled in hFolder (input 1, input true).
    enable all with frame fPage1.
    brNotaEntrada:SELECT-ROW(1) in frame fPage1.
    apply "VALUE-CHANGED":U to brNotaEntrada in frame fPage1.
end.
else do:
    run setEnabled in hFolder (input 1, input false).
    close query brNotaEntrada.
    close query brNotaEntradaProduto.
    disable all with frame fPage1.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryNotaLoja wWindow 
PROCEDURE pi-openQueryNotaLoja :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def var c-cod-estabel as char no-undo.
def var i-cod-emitente as integer no-undo.
def var c-nome-abrev as char no-undo.

empty temp-table tt-int_ds_nota_loja.
empty temp-table tt-int_ds_nota_loja_item.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Cupons").

if i-tipo-docto = 0 or i-tipo-docto = 3 then 
for each int_ds_nota_loja no-lock where 
    (i-situacao = 0 or int_ds_nota_loja.situacao = i-situacao) and
    int_ds_nota_loja.serie >= c-serie-ini and
    int_ds_nota_loja.serie <= c-serie-fim and
    int_ds_nota_loja.num_nota >= c-nr-nota-fis-ini and
    int_ds_nota_loja.num_nota <= c-nr-nota-fis-fim and
    int_ds_nota_loja.emissao >= d-da-dt-emis-ini and
    int_ds_nota_loja.emissao <= d-da-dt-emis-fim
    query-tuning(no-lookahead)
    on stop undo, leave:
    
    if i-tipo_movto <> 0 and int_ds_nota_loja.tipo_movto <> i-tipo_movto then next.
    if i-situacao <> 0 and int_ds_nota_loja.situacao <> i-situacao then next.

    c-cod-estabel = fnCod-Estabel(int_ds_nota_loja.cnpj_filial, int_ds_nota_loja.emissao).
    if  c-cod-estabel <> "" and
       (c-cod-estabel < c-cod-estabel-ini or
        c-cod-estabel > c-cod-estabel-fim) then next.
        
    if int_ds_nota_loja.num_nota = ? then next.
    i-cod-emitente = ?.
    c-nome-abrev = "".
    for last ser-estab fields (serie) no-lock where 
        ser-estab.cod-estabel = c-cod-estabel and
        ser-estab.forma-emis = 2 /* manual */: end.
    for first nota-fiscal fields (cod-emitente nome-ab-cli) no-lock where
        nota-fiscal.cod-estabel = c-cod-estabel and
        nota-fiscal.serie       = ser-estab.serie and
        nota-fiscal.nr-nota-fis = trim(string(int(int_ds_nota_loja.num_nota),">>9999999")):
        assign i-cod-emitente   = nota-fiscal.cod-emitente
               c-nome-abrev     = nota-fiscal.nome-ab-cli.
    end.
    
    if not avail nota-fiscal and int_ds_nota_loja.cnpjcpf_imp_cup <> ? then
    for first emitente fields (cod-emitente nome-abrev)
        no-lock where emitente.cgc begins trim(int_ds_nota_loja.cnpjcpf_imp_cup):
        i-cod-emitente = emitente.cod-emitente.
        c-nome-abrev = emitente.nome-abrev.
    end.    

    if  c-nome-abrev <> "" and
       (c-nome-abrev < c-nome-ab-cli-ini or 
        c-nome-abrev > c-nome-ab-cli-fim) then next.

    run pi-acompanhar in h-acomp (input "Cupons:" + string(int_ds_nota_loja.num_nota)).

    for last int_ds_log no-lock where 
        int_ds_log.origem = "CUPOM" and
        int_ds_log.chave begins (int_ds_nota_loja.cnpj_filial + "/" + int_ds_nota_loja.serie + "/" + trim(string(int(int_ds_nota_loja.num_nota),">>>9999999"))): end.
    if not avail int_ds_log then
        for last int_ds_log no-lock where 
            int_ds_log.origem = "CUPOM" and
            int_ds_log.chave begins (int_ds_nota_loja.cnpj_filial + "/" + ser-estab.serie + "/" + trim(string(int(int_ds_nota_loja.num_nota),">>>9999999"))): end.

    if (c-mensagem-1 <> "" or c-mensagem-2 <> "") and not avail int_ds_log then next.
    if avail int_ds_log then do:
       if c-mensagem-1 <> "" and 
          not int_ds_log.desc_ocorrencia matches trim(c-mensagem-1) + "*" then next.
       if c-mensagem-2 <> "" and 
          not int_ds_log.desc_ocorrencia matches "*" + trim(c-mensagem-2) + "*" then next.
    end.

    create tt-int_ds_nota_loja.
    assign tt-int_ds_nota_loja.base_icms         =   int_ds_nota_loja.base_icms             
           tt-int_ds_nota_loja.bordero           =   int_ds_nota_loja.bordero               
           tt-int_ds_nota_loja.cartao_manual     =   int_ds_nota_loja.cartao_manual         
           tt-int_ds_nota_loja.cnpjcpf_imp_cup   =   int_ds_nota_loja.cnpjcpf_imp_cup       
           tt-int_ds_nota_loja.cnpj_filial       =   int_ds_nota_loja.cnpj_filial           
           tt-int_ds_nota_loja.condipag          =   int_ds_nota_loja.condipag              
           tt-int_ds_nota_loja.convenio          =   int_ds_nota_loja.convenio              
           tt-int_ds_nota_loja.cpf_cliente       =   int_ds_nota_loja.cpf_cliente           
           tt-int_ds_nota_loja.cupom_ecf         =   int_ds_nota_loja.cupom_ecf             
           tt-int_ds_nota_loja.data_ecf          =   int_ds_nota_loja.data_ecf              
           tt-int_ds_nota_loja.data_movim        =   int_ds_nota_loja.data_movim            
           tt-int_ds_nota_loja.doc_fiscal_icms   =   int_ds_nota_loja.doc_fiscal_icms       
           tt-int_ds_nota_loja.dt_geracao        =   int_ds_nota_loja.dt_geracao            
           tt-int_ds_nota_loja.emissao           =   int_ds_nota_loja.emissao               
           tt-int_ds_nota_loja.end_imp_cup       =   int_ds_nota_loja.end_imp_cup           
           tt-int_ds_nota_loja.horainicio        =   int_ds_nota_loja.horainicio            
           tt-int_ds_nota_loja.hora_canc         =   int_ds_nota_loja.hora_canc             
           tt-int_ds_nota_loja.hora_ecf          =   int_ds_nota_loja.hora_ecf              
           tt-int_ds_nota_loja.hora_emiss        =   int_ds_nota_loja.hora_emiss            
           tt-int_ds_nota_loja.hora_final        =   int_ds_nota_loja.hora_final            
           tt-int_ds_nota_loja.hr_geracao        =   int_ds_nota_loja.hr_geracao            
           tt-int_ds_nota_loja.impcont           =   int_ds_nota_loja.impcont               
           tt-int_ds_nota_loja.impressora        =   int_ds_nota_loja.impressora            
           tt-int_ds_nota_loja.indterminal       =   int_ds_nota_loja.indterminal           
           tt-int_ds_nota_loja.istatus           =   int_ds_nota_loja.istatus               
           tt-int_ds_nota_loja.nfce_chave_s      =   int_ds_nota_loja.nfce_chave_s          
           tt-int_ds_nota_loja.nfce_protocolo_s  =   int_ds_nota_loja.nfce_protocolo_s      
           tt-int_ds_nota_loja.nfce_status_s     =   int_ds_nota_loja.nfce_status_s         
           tt-int_ds_nota_loja.nfce_transmissao_d =  int_ds_nota_loja.nfce_transmissao_d    
           tt-int_ds_nota_loja.nfce_transmissao_s =  int_ds_nota_loja.nfce_transmissao_s    
           tt-int_ds_nota_loja.nome_imp_cup       =  int_ds_nota_loja.nome_imp_cup          
           tt-int_ds_nota_loja.num_identi         =  int_ds_nota_loja.num_identi            
           tt-int_ds_nota_loja.num_nota           =  int_ds_nota_loja.num_nota              
           tt-int_ds_nota_loja.reducao            =  int_ds_nota_loja.reducao               
           tt-int_ds_nota_loja.serie              =  int_ds_nota_loja.serie                 
           tt-int_ds_nota_loja.situacao           =  int_ds_nota_loja.situacao              
           tt-int_ds_nota_loja.sit_doct_fiscal_icms = int_ds_nota_loja.sit_doct_fiscal_icms  
           tt-int_ds_nota_loja.televendas         =  int_ds_nota_loja.televendas            
           tt-int_ds_nota_loja.tipo_movto         =  int_ds_nota_loja.tipo_movto            
           tt-int_ds_nota_loja.tipo_clien         =  int_ds_nota_loja.tipo_clien            
           tt-int_ds_nota_loja.total_qtde         =  int_ds_nota_loja.total_qtde            
           tt-int_ds_nota_loja.valor_cartaoc      =  int_ds_nota_loja.valor_cartaoc         
           tt-int_ds_nota_loja.valor_cartaod      =  int_ds_nota_loja.valor_cartaod         
           tt-int_ds_nota_loja.valor_chq          =  int_ds_nota_loja.valor_chq             
           tt-int_ds_nota_loja.valor_chq_pre      =  int_ds_nota_loja.valor_chq_pre         
           tt-int_ds_nota_loja.valor_convenio     =  int_ds_nota_loja.valor_convenio        
           tt-int_ds_nota_loja.valor_desc_cupom   =  int_ds_nota_loja.valor_desc_cupom      
           tt-int_ds_nota_loja.valor_dinheiro     =  int_ds_nota_loja.valor_dinheiro        
           tt-int_ds_nota_loja.valor_din_mov      =  int_ds_nota_loja.valor_din_mov         
           tt-int_ds_nota_loja.valor_din_venda    =  int_ds_nota_loja.valor_din_venda       
           tt-int_ds_nota_loja.valor_icms         =  int_ds_nota_loja.valor_icms            
           tt-int_ds_nota_loja.valor_item         =  int_ds_nota_loja.valor_item            
           tt-int_ds_nota_loja.valor_ticket       =  int_ds_nota_loja.valor_ticket          
           tt-int_ds_nota_loja.valor_total        =  int_ds_nota_loja.valor_total           
           tt-int_ds_nota_loja.valor_troco        =  int_ds_nota_loja.valor_troco           
           tt-int_ds_nota_loja.valor_vale         =  int_ds_nota_loja.valor_vale            
           tt-int_ds_nota_loja.versaopdv          =  int_ds_nota_loja.versaopdv             
           tt-int_ds_nota_loja.cod-estabel        = c-cod-estabel
           tt-int_ds_nota_loja.cod-emitente       = i-cod-emitente
           tt-int_ds_nota_loja.nome-abrev         = c-nome-abrev.
    if avail int_ds_log then
        assign tt-int_ds_nota_loja.mensagem = int_ds_log.desc_ocorrencia.

    for each int_ds_nota_loja_item no-lock of int_ds_nota_loja
        query-tuning(no-lookahead):
        create tt-int_ds_nota_loja_item.
        assign 
            tt-int_ds_nota_loja_item.aliq_icms             = int_ds_nota_loja_item.aliq_icms           
            tt-int_ds_nota_loja_item.base_icms             = int_ds_nota_loja_item.base_icms           
            tt-int_ds_nota_loja_item.cfop                  = int_ds_nota_loja_item.cfop                
            tt-int_ds_nota_loja_item.cnpj_filial           = int_ds_nota_loja_item.cnpj_filial         
            tt-int_ds_nota_loja_item.comissao              = int_ds_nota_loja_item.comissao            
            tt-int_ds_nota_loja_item.datafabricacao        = int_ds_nota_loja_item.datafabricacao      
            tt-int_ds_nota_loja_item.datavalidade          = int_ds_nota_loja_item.datavalidade        
            tt-int_ds_nota_loja_item.desconto              = int_ds_nota_loja_item.desconto            
            tt-int_ds_nota_loja_item.lote                  = int_ds_nota_loja_item.lote                
            tt-int_ds_nota_loja_item.num_nota              = int_ds_nota_loja_item.num_nota            
            tt-int_ds_nota_loja_item.origem                = int_ds_nota_loja_item.origem              
            tt-int_ds_nota_loja_item.plantao               = int_ds_nota_loja_item.plantao             
            tt-int_ds_nota_loja_item.preco_desc            = int_ds_nota_loja_item.preco_desc          
            tt-int_ds_nota_loja_item.preco_desc_original   = int_ds_nota_loja_item.preco_desc_original 
            tt-int_ds_nota_loja_item.preco_liqu            = int_ds_nota_loja_item.preco_liqu          
            tt-int_ds_nota_loja_item.preco_rateio          = int_ds_nota_loja_item.preco_rateio        
            tt-int_ds_nota_loja_item.preco_unit            = int_ds_nota_loja_item.preco_unit          
            tt-int_ds_nota_loja_item.produto               = int_ds_nota_loja_item.produto             
            tt-int_ds_nota_loja_item.quantidade            = int_ds_nota_loja_item.quantidade          
            tt-int_ds_nota_loja_item.resumos               = int_ds_nota_loja_item.resumos             
            tt-int_ds_nota_loja_item.sequencia             = int_ds_nota_loja_item.sequencia           
            tt-int_ds_nota_loja_item.serie                 = int_ds_nota_loja_item.serie               
            tt-int_ds_nota_loja_item.tipo_desco            = int_ds_nota_loja_item.tipo_desco          
            tt-int_ds_nota_loja_item.trib_icms             = int_ds_nota_loja_item.trib_icms           
            tt-int_ds_nota_loja_item.valortrib             = int_ds_nota_loja_item.valortrib           
            tt-int_ds_nota_loja_item.valortribestadual     = int_ds_nota_loja_item.valortribestadual   
            tt-int_ds_nota_loja_item.vendedor              = int_ds_nota_loja_item.vendedor            
            .
    end.
end.
run pi-finalizar in h-acomp.
if can-find (first tt-int_ds_nota_loja) then do:
    OPEN QUERY brNotaloja FOR EACH tt-int_ds_nota_loja NO-LOCK INDEXED-REPOSITION.
    run setEnabled in hFolder (input 3, input true).
    enable all with frame fPage3.
    brNotaloja:SELECT-ROW(1) in frame fPage3.
    apply "VALUE-CHANGED":U to brNotaloja in frame fPage3.
end.
else do:
    run setEnabled in hFolder (input 3, input false).
    close query brNotaloja.
    close query brNotalojaItem.
    disable all with frame fPage3.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryNotaSaida wWindow 
PROCEDURE pi-openQueryNotaSaida :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def var c-cod-estabel as char no-undo.
def var i-cod-emitente as integer no-undo.
def var c-nome-abrev as char no-undo.

empty temp-table tt-int_ds_nota_saida.
empty temp-table tt-int_ds_nota_saida_item.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Sa°das").

if i-tipo-docto = 0 or i-tipo-docto = 2 then 
for each int_ds_nota_saida no-lock where 
    (i-tipo_movto = 0 or int_ds_nota_saida.tipo_movto = i-tipo_movto) and
    int_ds_nota_saida.nsa_serie_s >= c-serie-ini and
    int_ds_nota_saida.nsa_serie_s <= c-serie-fim and
    int_ds_nota_saida.nsa_notafiscal_n >= integer(c-nr-nota-fis-ini) and
    int_ds_nota_saida.nsa_notafiscal_n <= integer(c-nr-nota-fis-fim) and
    int_ds_nota_saida.nsa_dataemissao_d >= d-da-dt-emis-ini and
    int_ds_nota_saida.nsa_dataemissao_d <= d-da-dt-emis-fim
    query-tuning(no-lookahead)
    on stop undo, leave:

    if i-tipo_movto <> 0 and int_ds_nota_saida.tipo_movto <> i-tipo_movto then next.
    if i-situacao <> 0 and int_ds_nota_saida.situacao <> i-situacao then next.

    c-cod-estabel = fnCod-Estabel(int_ds_nota_saida.nsa_cnpj_origem_s, int_ds_nota_saida.nsa_dataemissao_d).
    if  c-cod-estabel <> "" and
       (c-cod-estabel < c-cod-estabel-ini or
        c-cod-estabel > c-cod-estabel-fim) then next.
    
    i-cod-emitente = ?.
    c-nome-abrev = "".
    for first nota-fiscal fields (cod-emitente nome-ab-cli) no-lock where
        nota-fiscal.cod-estabel = c-cod-estabel and
        nota-fiscal.serie       = int_ds_nota_saida.nsa_serie_s and
        nota-fiscal.nr-nota-fis = string(int_ds_nota_saida.nsa_notafiscal_n,"9999999"):
        assign i-cod-emitente   = nota-fiscal.cod-emitente
               c-nome-abrev     = nota-fiscal.nome-ab-cli.
    end.
    if not avail nota-fiscal then
    for first emitente fields (cod-emitente nome-abrev)
        no-lock where emitente.cgc begins int_ds_nota_saida.nsa_cnpj_destino_s:
        i-cod-emitente = emitente.cod-emitente.
        c-nome-abrev = emitente.nome-abrev.
    end.    

    if  c-nome-abrev <> "" and
       (c-nome-abrev < c-nome-ab-cli-ini or 
        c-nome-abrev > c-nome-ab-cli-fim) then next.
    run pi-acompanhar in h-acomp (input "Sa°das:" + string(int_ds_nota_saida.nsa_notafiscal_n)).

    for first nota-fiscal no-lock where 
        nota-fiscal.cod-estabel = c-cod-estabel and
        nota-fiscal.serie = int_ds_nota_saida.nsa_serie_s and
        nota-fiscal.nr-nota-fis = string(int_ds_nota_saida.nsa_notafiscal_n,"9999999"): end.
    if  avail nota-fiscal and
       (nota-fiscal.nr-embarque < c-nr-embarque-ini or
        nota-fiscal.nr-embarque > c-nr-embarque-fim) then next.

    for last int_ds_log no-lock where 
        int_ds_log.origem = "NFS" and
        int_ds_log.chave begins trim(int_ds_nota_saida.nsa_cnpj_origem_s) + "/" + 
                                trim(int_ds_nota_saida.nsa_serie_s) + "/" +
        trim(string(int_ds_nota_saida.nsa_notafiscal_n,">>9999999")): end.
    if not avail int_ds_log then
        for last int_ds_log no-lock where 
            int_ds_log.origem = "NFS" and
            int_ds_log.chave begins trim(int_ds_nota_saida.nsa_cnpj_origem_s) + "/" + 
                                    trim(int_ds_nota_saida.nsa_serie_s) + "/" +
            trim(string(int_ds_nota_saida.nsa_notafiscal_n,">>>999999")): end.
        if not avail int_ds_log then
            for last int_ds_log no-lock where 
                int_ds_log.origem = "NFS" and
                int_ds_log.chave begins trim(int_ds_nota_saida.nsa_cnpj_origem_s) + "/" + 
                                        trim(int_ds_nota_saida.nsa_serie_s) and
                int_ds_log.chave matches "*" + trim(string(int_ds_nota_saida.nsa_notafiscal_n,">>>>>>>>>>9")) + "*": end.

    if (c-mensagem-1 <> "" or c-mensagem-2 <> "") and not avail int_ds_log then next.
    if avail int_ds_log then do:
       if c-mensagem-1 <> "" and 
          not int_ds_log.desc_ocorrencia matches trim(c-mensagem-1) + "*" then next.
       if c-mensagem-2 <> "" and 
          not int_ds_log.desc_ocorrencia matches "*" + trim(c-mensagem-2) + "*" then next.
    end.

    create tt-int_ds_nota_saida.
    buffer-copy int_ds_nota_saida to tt-int_ds_nota_saida.

    assign  tt-int_ds_nota_saida.dt_geracao = int_ds_nota_saida.dt_geracao
            tt-int_ds_nota_saida.hr_geracao = int_ds_nota_saida.hr_geracao.
    assign  tt-int_ds_nota_saida.cod-estabel = c-cod-estabel
            tt-int_ds_nota_saida.cod-emitente = i-cod-emitente
            tt-int_ds_nota_saida.nome-abrev = c-nome-abrev.

    if avail int_ds_log then
        assign tt-int_ds_nota_saida.mensagem = int_ds_log.desc_ocorrencia.

    for each int_ds_nota_saida_item no-lock of int_ds_nota_saida
        query-tuning(no-lookahead):
        create tt-int_ds_nota_saida_item.
        buffer-copy int_ds_nota_saida_item to tt-int_ds_nota_saida_item.
    end.
end.
run pi-finalizar in h-acomp.
if can-find (first tt-int_ds_nota_saida) then do:
    OPEN QUERY brNotaSaida FOR EACH tt-int_ds_nota_saida NO-LOCK INDEXED-REPOSITION.
    run setEnabled in hFolder (input 2, input true).
    enable all with frame fPage2.
    brNotaSaida:SELECT-ROW(1) in frame fPage2.
    apply "VALUE-CHANGED":U to brNotaSaida in frame fPage2.
end.
else do:
    run setEnabled in hFolder (input 2, input false).
    close query brNotaSaida.
    close query brNotaSaidaItem.
    disable all with frame fPage2.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnCod-Emitente wWindow 
FUNCTION fnCod-Emitente RETURNS integer
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first emitente fields (cod-emitente)
        no-lock where emitente.cgc begins pcnpj:
        RETURN emitente.cod-emitente.
    end.

  RETURN 0.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnCod-Estabel wWindow 
FUNCTION fnCod-Estabel RETURNS CHARACTER
  ( pcnpj as char,
    pdata as date ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    for each estabelec fields (cod-estabel)
        no-lock where estabelec.cgc begins pcnpj,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= pdata:

        RETURN estabelec.cod-estabel.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnItem wWindow 
FUNCTION fnItem RETURNS CHARACTER
  ( pcod-produto as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first ITEM fields (desc-item)
        no-lock where item.it-codigo = string(pcod-produto):
        RETURN item.desc-item.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnNome-Abrev wWindow 
FUNCTION fnNome-Abrev RETURNS CHARACTER
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first emitente fields (nome-abrev)
        no-lock where emitente.cgc = pcnpj:
        RETURN emitente.nome-abrev.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnRefresh wWindow 
FUNCTION fnRefresh returns logical ( ) :
    IF rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" THEN DO:
        chCtrlFrame:PSTimer:interval = 0.
        APPLY "LEAVE" TO c-intervalo IN FRAME fPage0.
    END.

    RETURN FALSE.   

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

