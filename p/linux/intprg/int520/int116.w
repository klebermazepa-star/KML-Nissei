&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
/*******************************************************************************
**
** Programa: INT116
** Objetivo: Painel Cadastros INT115
** 
** Parƒmetros:
** Especificidades:
** 
** Autor: AVB
** Data:  agosto/2017
**
*******************************************************************************/
{include/i-prgvrs.i INT116 2.12.02.AVB}
/*{include/wms.i}*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT116
&GLOBAL-DEFINE Version        2.12.02.AVB

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         YES
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Parƒmetros ,Tributado, Isento, Cesta B sica, ST, Outros,  Nenhum

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK btCancel btHelp2 tp-pedido

&GLOBAL-DEFINE page1Widgets btLeitura class-fiscal-fim class-fiscal-ini cd-trib-icm
                            
&GLOBAL-DEFINE page2Widgets   brTributado
&GLOBAL-DEFINE page3Widgets   brIsento
&GLOBAL-DEFINE page4Widgets   brCesta
&GLOBAL-DEFINE page5Widgets   brST
&GLOBAL-DEFINE page6Widgets   brOutros
&GLOBAL-DEFINE page7Widgets   brNenhum

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEF VAR h-acomp AS HANDLE.

/* ++++++++++++++++++ (Definicao Temp Tables) ++++++++++++++++++ */

/* totais de necessidades de itens */
define new shared temp-table tt-movtos like int-ds-tp-trib-natur-oper
    /*field class-fiscal like classif-fisc.class-fiscal*/
    field descricao    like classif-fisc.descricao
    field desc-trib    as char format "x(10)"
    field r-rowid       as rowid

  index movto is unique
     tp-pedido
     cd-trib-icm
     class-fiscal.

define temp-table tt-param
    field tp-pedido                     as char format "99"
    field cd-trib-icm                   as integer
    field class-fiscal-ini              like int-ds-classif-fisc.class-fiscal
    field class-fiscal-fim              like int-ds-classif-fisc.class-fiscal.

define var raw-param as raw.

define variable i-sequencia as integer.
def var i-color-aux as integer initial 1.
def var l-ok as logical no-undo.
def var c-arquivo as char no-undo.

define buffer btt-movtos for tt-movtos.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brCesta

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-movtos

/* Definitions for BROWSE brCesta                                       */
&Scoped-define FIELDS-IN-QUERY-brCesta tt-movtos.cd-trib-icm tt-movtos.desc-trib tt-movtos.tp-pedido tt-movtos.uf-origem tt-movtos.class-fiscal tt-movtos.descricao tt-movtos.nat-saida-est tt-movtos.nat-saida-inter tt-movtos.nat-entrada-est tt-movtos.nat-entrada-inter tt-movtos.nat-saida-est-nao-contrib tt-movtos.nat-saida-inter-nao-contrib tt-movtos.nat-entrada-est-nao-contrib tt-movtos.nat-entrada-inter-nao-contrib   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brCesta   
&Scoped-define SELF-NAME brCesta
&Scoped-define QUERY-STRING-brCesta FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 3 use-index movto
&Scoped-define OPEN-QUERY-brCesta OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 3 use-index movto.
&Scoped-define TABLES-IN-QUERY-brCesta tt-movtos
&Scoped-define FIRST-TABLE-IN-QUERY-brCesta tt-movtos


/* Definitions for BROWSE brIsento                                      */
&Scoped-define FIELDS-IN-QUERY-brIsento tt-movtos.cd-trib-icm tt-movtos.desc-trib tt-movtos.tp-pedido tt-movtos.uf-origem tt-movtos.class-fiscal tt-movtos.descricao tt-movtos.nat-saida-est tt-movtos.nat-saida-inter tt-movtos.nat-entrada-est tt-movtos.nat-entrada-inter tt-movtos.nat-saida-est-nao-contrib tt-movtos.nat-saida-inter-nao-contrib tt-movtos.nat-entrada-est-nao-contrib tt-movtos.nat-entrada-inter-nao-contrib   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brIsento   
&Scoped-define SELF-NAME brIsento
&Scoped-define QUERY-STRING-brIsento FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 2 use-index movto
&Scoped-define OPEN-QUERY-brIsento OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 2 use-index movto.
&Scoped-define TABLES-IN-QUERY-brIsento tt-movtos
&Scoped-define FIRST-TABLE-IN-QUERY-brIsento tt-movtos


/* Definitions for BROWSE brNenhum                                      */
&Scoped-define FIELDS-IN-QUERY-brNenhum tt-movtos.cd-trib-icm tt-movtos.desc-trib tt-movtos.tp-pedido tt-movtos.uf-origem tt-movtos.class-fiscal tt-movtos.descricao tt-movtos.nat-saida-est tt-movtos.nat-saida-inter tt-movtos.nat-entrada-est tt-movtos.nat-entrada-inter tt-movtos.nat-saida-est-nao-contrib tt-movtos.nat-saida-inter-nao-contrib tt-movtos.nat-entrada-est-nao-contrib tt-movtos.nat-entrada-inter-nao-contrib   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brNenhum   
&Scoped-define SELF-NAME brNenhum
&Scoped-define QUERY-STRING-brNenhum FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 0 use-index movto
&Scoped-define OPEN-QUERY-brNenhum OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 0 use-index movto.
&Scoped-define TABLES-IN-QUERY-brNenhum tt-movtos
&Scoped-define FIRST-TABLE-IN-QUERY-brNenhum tt-movtos


/* Definitions for BROWSE brOutros                                      */
&Scoped-define FIELDS-IN-QUERY-brOutros tt-movtos.cd-trib-icm tt-movtos.desc-trib tt-movtos.tp-pedido tt-movtos.uf-origem tt-movtos.class-fiscal tt-movtos.descricao tt-movtos.nat-saida-est tt-movtos.nat-saida-inter tt-movtos.nat-entrada-est tt-movtos.nat-entrada-inter tt-movtos.nat-saida-est-nao-contrib tt-movtos.nat-saida-inter-nao-contrib tt-movtos.nat-entrada-est-nao-contrib tt-movtos.nat-entrada-inter-nao-contrib   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brOutros   
&Scoped-define SELF-NAME brOutros
&Scoped-define QUERY-STRING-brOutros FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 4 use-index movto
&Scoped-define OPEN-QUERY-brOutros OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 4 use-index movto.
&Scoped-define TABLES-IN-QUERY-brOutros tt-movtos
&Scoped-define FIRST-TABLE-IN-QUERY-brOutros tt-movtos


/* Definitions for BROWSE brST                                          */
&Scoped-define FIELDS-IN-QUERY-brST tt-movtos.cd-trib-icm tt-movtos.desc-trib tt-movtos.tp-pedido tt-movtos.uf-origem tt-movtos.class-fiscal tt-movtos.descricao tt-movtos.nat-saida-est tt-movtos.nat-saida-inter tt-movtos.nat-entrada-est tt-movtos.nat-entrada-inter tt-movtos.nat-saida-est-nao-contrib tt-movtos.nat-saida-inter-nao-contrib tt-movtos.nat-entrada-est-nao-contrib tt-movtos.nat-entrada-inter-nao-contrib   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brST   
&Scoped-define SELF-NAME brST
&Scoped-define QUERY-STRING-brST FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 9 use-index movto
&Scoped-define OPEN-QUERY-brST OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 9 use-index movto.
&Scoped-define TABLES-IN-QUERY-brST tt-movtos
&Scoped-define FIRST-TABLE-IN-QUERY-brST tt-movtos


/* Definitions for BROWSE brTributado                                   */
&Scoped-define FIELDS-IN-QUERY-brTributado tt-movtos.cd-trib-icm tt-movtos.desc-trib tt-movtos.tp-pedido tt-movtos.uf-origem tt-movtos.class-fiscal tt-movtos.descricao tt-movtos.nat-saida-est tt-movtos.nat-saida-inter tt-movtos.nat-entrada-est tt-movtos.nat-entrada-inter tt-movtos.nat-saida-est-nao-contrib tt-movtos.nat-saida-inter-nao-contrib tt-movtos.nat-entrada-est-nao-contrib tt-movtos.nat-entrada-inter-nao-contrib   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTributado   
&Scoped-define SELF-NAME brTributado
&Scoped-define QUERY-STRING-brTributado FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 1 use-index movto
&Scoped-define OPEN-QUERY-brTributado OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 1 use-index movto.
&Scoped-define TABLES-IN-QUERY-brTributado tt-movtos
&Scoped-define FIRST-TABLE-IN-QUERY-brTributado tt-movtos


/* Definitions for FRAME fPage2                                         */

/* Definitions for FRAME fPage3                                         */

/* Definitions for FRAME fPage4                                         */

/* Definitions for FRAME fPage5                                         */

/* Definitions for FRAME fPage6                                         */

/* Definitions for FRAME fPage7                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar rtToolBar-2 btQueryJoins ~
btReportsJoins btExit btHelp tp-pedido btOK btCancel btHelp2 
&Scoped-Define DISPLAYED-OBJECTS tp-pedido 

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

DEFINE MENU POPUP-MENU-brIsento 
       MENU-ITEM m_Apaga_Somente_Este_De-Para LABEL "Apaga Somente Este De->Para" ACCELERATOR "CTRL-D".

DEFINE MENU POPUP-MENU-brIsento-2 
       MENU-ITEM m_Apaga_Somente_Este_De-Para-2 LABEL "Apaga Somente Este De->Para" ACCELERATOR "CTRL-D".

DEFINE MENU POPUP-MENU-brIsento-3 
       MENU-ITEM m_Apaga_Somente_Este_De-Para-3 LABEL "Apaga Somente Este De->Para" ACCELERATOR "CTRL-D".


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

DEFINE VARIABLE tp-pedido AS CHARACTER FORMAT "X(2)" INITIAL "1" 
     LABEL "Tipo Pedido" 
     VIEW-AS COMBO-BOX INNER-LINES 18
     LIST-ITEM-PAIRS "TRANSFERENCIA DEPOSITO - FILIAL","1",
                     "TRANSFERENCIA FILIAL - DEPOSITO","2",
                     "BALANCO MANUAL FILIAL","3",
                     "COMPRA FORNECEDOR - FILIAL","4",
                     "COMPRA FORNECEDOR - DEPOSITO","5",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO","6",
                     "ELETRONICO FORNECEDOR - FILIAL","7",
                     "ELETRONICO DEPOSITO - FILIAL","8",
                     "PBM FILIAL","9",
                     "PBM DEPOSITO","10",
                     "BALANCO MANUAL DEPOSITO","11",
                     "BALANCO COLETOR FILIAL","12",
                     "BALANCO COLETOR DEPOSITO","13",
                     "BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO","14",
                     "DEVOLUCAO FILIAL - FORNECEDOR","15",
                     "DEVOLUCAO DEPOSITO - FORNECEDOR","16",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO (COMERCIALIZAVEL)","17",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO (AVARIA)","18",
                     "TRANSFERENCIA FILIAL - FILIAL","19",
                     "BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO)","31",
                     "DEVOLUCAO FILIAL - FORNECEDOR (MED. CONTROLADO)","32",
                     "TRANSFERENCIA FILIAL - FORNECEDOR (MED. CONTROLADO)","33",
                     "BALAN€O GERAL CONTROLADOS DEPOSITO","35",
                     "BALAN€O GERAL CONTROLADOS FILIAL","36",
                     "ATIVO IMOBILIZADO DEPOSITO => FILIAL","37",
                     "ESTORNO","38",
                     "ATIVO IMOBILIZADO FILIAL => FILIAL","39",
                     "RETIRADA FILIAL => PROPRIA FILIAL","46",
                     "SUBSTITUI€ÇO DE CUPOM","48",
                     "ESTORNO","51",
                     "ESTORNO","52",
                     "ESTORNO","53"
     DROP-DOWN-LIST
     SIZE 72 BY 1.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 137 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 138 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON btLeitura DEFAULT 
     LABEL "Ler Cadastros" 
     SIZE 15 BY .96 TOOLTIP "Clique p/ buscar dados da consulta".

DEFINE VARIABLE class-fiscal-fim AS CHARACTER FORMAT "9999.99.99" INITIAL "99999999" 
     VIEW-AS FILL-IN 
     SIZE 10.57 BY .79.

DEFINE VARIABLE class-fiscal-ini AS CHARACTER FORMAT "9999.99.99" INITIAL "00000000" 
     LABEL "Classifica‡Æo Fiscal" 
     VIEW-AS FILL-IN 
     SIZE 10.57 BY .79.

DEFINE IMAGE IMAGE-42
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-43
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE VARIABLE cd-trib-icm AS INTEGER INITIAL 99 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Tributado":U, 1,
"Isento":U, 2,
"Cesta B sica":U, 3,
"ST":U, 9,
"Outros":U, 4,
"Nenhum":U, 0,
"Todos":U, 99
     SIZE 65 BY 1.04.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 68 BY 2.25.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brCesta FOR 
      tt-movtos SCROLLING.

DEFINE QUERY brIsento FOR 
      tt-movtos SCROLLING.

DEFINE QUERY brNenhum FOR 
      tt-movtos SCROLLING.

DEFINE QUERY brOutros FOR 
      tt-movtos SCROLLING.

DEFINE QUERY brST FOR 
      tt-movtos SCROLLING.

DEFINE QUERY brTributado FOR 
      tt-movtos SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brCesta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brCesta wWindow _FREEFORM
  QUERY brCesta DISPLAY
      tt-movtos.cd-trib-icm             column-label "Tp!Trib"
tt-movtos.desc-trib                     column-label "ICMS"
tt-movtos.tp-pedido                     column-label "Tp!Ped"
tt-movtos.uf-origem                     column-label "UF!Orig"
tt-movtos.class-fiscal                  column-label "Class. Fiscal"
tt-movtos.descricao                     
tt-movtos.nat-saida-est                 column-label "Sa¡da!Estadual"
tt-movtos.nat-saida-inter               column-label "Sa¡da!Inter"
tt-movtos.nat-entrada-est               column-label "Entrada!Estadual"
tt-movtos.nat-entrada-inter             column-label "Entrada!Inter"
tt-movtos.nat-saida-est-nao-contrib     column-label "Sa¡da!Est NCont"
tt-movtos.nat-saida-inter-nao-contrib   column-label "Sa¡da!Int NCont"
tt-movtos.nat-entrada-est-nao-contrib   column-label "Entr!Est NCont"
tt-movtos.nat-entrada-inter-nao-contrib column-label "Entr!NCont"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 135 BY 16
         FONT 1 ROW-HEIGHT-CHARS .46.

DEFINE BROWSE brIsento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brIsento wWindow _FREEFORM
  QUERY brIsento DISPLAY
      tt-movtos.cd-trib-icm             column-label "Tp!Trib"
tt-movtos.desc-trib                     column-label "ICMS"
tt-movtos.tp-pedido                     column-label "Tp!Ped"
tt-movtos.uf-origem                     column-label "UF!Orig"
tt-movtos.class-fiscal                  column-label "Class. Fiscal"
tt-movtos.descricao                     
tt-movtos.nat-saida-est                 column-label "Sa¡da!Estadual"
tt-movtos.nat-saida-inter               column-label "Sa¡da!Inter"
tt-movtos.nat-entrada-est               column-label "Entrada!Estadual"
tt-movtos.nat-entrada-inter             column-label "Entrada!Inter"
tt-movtos.nat-saida-est-nao-contrib     column-label "Sa¡da!Est NCont"
tt-movtos.nat-saida-inter-nao-contrib   column-label "Sa¡da!Int NCont"
tt-movtos.nat-entrada-est-nao-contrib   column-label "Entr!Est NCont"
tt-movtos.nat-entrada-inter-nao-contrib column-label "Entr!NCont"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 134 BY 16
         FONT 1 ROW-HEIGHT-CHARS .46.

DEFINE BROWSE brNenhum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brNenhum wWindow _FREEFORM
  QUERY brNenhum DISPLAY
      tt-movtos.cd-trib-icm             column-label "Tp!Trib"
tt-movtos.desc-trib                     column-label "ICMS"
tt-movtos.tp-pedido                     column-label "Tp!Ped"
tt-movtos.uf-origem                     column-label "UF!Orig"
tt-movtos.class-fiscal                  column-label "Class. Fiscal"
tt-movtos.descricao                     
tt-movtos.nat-saida-est                 column-label "Sa¡da!Estadual"
tt-movtos.nat-saida-inter               column-label "Sa¡da!Inter"
tt-movtos.nat-entrada-est               column-label "Entrada!Estadual"
tt-movtos.nat-entrada-inter             column-label "Entrada!Inter"
tt-movtos.nat-saida-est-nao-contrib     column-label "Sa¡da!Est NCont"
tt-movtos.nat-saida-inter-nao-contrib   column-label "Sa¡da!Int NCont"
tt-movtos.nat-entrada-est-nao-contrib   column-label "Entr!Est NCont"
tt-movtos.nat-entrada-inter-nao-contrib column-label "Entr!NCont"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 134 BY 16
         FONT 1 ROW-HEIGHT-CHARS .46.

DEFINE BROWSE brOutros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brOutros wWindow _FREEFORM
  QUERY brOutros DISPLAY
      tt-movtos.cd-trib-icm             column-label "Tp!Trib"
tt-movtos.desc-trib                     column-label "ICMS"
tt-movtos.tp-pedido                     column-label "Tp!Ped"
tt-movtos.uf-origem                     column-label "UF!Orig"
tt-movtos.class-fiscal                  column-label "Class. Fiscal"
tt-movtos.descricao                     
tt-movtos.nat-saida-est                 column-label "Sa¡da!Estadual"
tt-movtos.nat-saida-inter               column-label "Sa¡da!Inter"
tt-movtos.nat-entrada-est               column-label "Entrada!Estadual"
tt-movtos.nat-entrada-inter             column-label "Entrada!Inter"
tt-movtos.nat-saida-est-nao-contrib     column-label "Sa¡da!Est NCont"
tt-movtos.nat-saida-inter-nao-contrib   column-label "Sa¡da!Int NCont"
tt-movtos.nat-entrada-est-nao-contrib   column-label "Entr!Est NCont"
tt-movtos.nat-entrada-inter-nao-contrib column-label "Entr!NCont"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 134 BY 16
         FONT 1 ROW-HEIGHT-CHARS .46.

DEFINE BROWSE brST
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brST wWindow _FREEFORM
  QUERY brST DISPLAY
      tt-movtos.cd-trib-icm             column-label "Tp!Trib"
tt-movtos.desc-trib                     column-label "ICMS"
tt-movtos.tp-pedido                     column-label "Tp!Ped"
tt-movtos.uf-origem                     column-label "UF!Orig"
tt-movtos.class-fiscal                  column-label "Class. Fiscal"
tt-movtos.descricao                     
tt-movtos.nat-saida-est                 column-label "Sa¡da!Estadual"
tt-movtos.nat-saida-inter               column-label "Sa¡da!Inter"
tt-movtos.nat-entrada-est               column-label "Entrada!Estadual"
tt-movtos.nat-entrada-inter             column-label "Entrada!Inter"
tt-movtos.nat-saida-est-nao-contrib     column-label "Sa¡da!Est NCont"
tt-movtos.nat-saida-inter-nao-contrib   column-label "Sa¡da!Int NCont"
tt-movtos.nat-entrada-est-nao-contrib   column-label "Entr!Est NCont"
tt-movtos.nat-entrada-inter-nao-contrib column-label "Entr!NCont"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 135 BY 16
         FONT 1 ROW-HEIGHT-CHARS .46.

DEFINE BROWSE brTributado
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTributado wWindow _FREEFORM
  QUERY brTributado DISPLAY
      tt-movtos.cd-trib-icm             column-label "Tp!Trib"
tt-movtos.desc-trib                     column-label "ICMS"
tt-movtos.tp-pedido                     column-label "Tp!Ped"
tt-movtos.uf-origem                     column-label "UF!Orig"
tt-movtos.class-fiscal                  column-label "Class. Fiscal"
tt-movtos.descricao                     
tt-movtos.nat-saida-est                 column-label "Sa¡da!Estadual"
tt-movtos.nat-saida-inter               column-label "Sa¡da!Inter"
tt-movtos.nat-entrada-est               column-label "Entrada!Estadual"
tt-movtos.nat-entrada-inter             column-label "Entrada!Inter"
tt-movtos.nat-saida-est-nao-contrib     column-label "Sa¡da!Est NCont"
tt-movtos.nat-saida-inter-nao-contrib   column-label "Sa¡da!Int NCont"
tt-movtos.nat-entrada-est-nao-contrib   column-label "Entr!Est NCont"
tt-movtos.nat-entrada-inter-nao-contrib column-label "Entr!NCont"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 135 BY 16
         FONT 1 ROW-HEIGHT-CHARS .46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 121.29 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 125.29 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 129.29 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 133.29 HELP
          "Ajuda"
     tp-pedido AT ROW 1.25 COL 18 COLON-ALIGNED WIDGET-ID 110
     btOK AT ROW 20.25 COL 3
     btCancel AT ROW 20.25 COL 14
     btHelp2 AT ROW 20.25 COL 127.72
     rtToolBar AT ROW 20 COL 2
     rtToolBar-2 AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 139.57 BY 20.54
         FONT 1.

DEFINE FRAME fPage4
     brCesta AT ROW 1 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 3.5
         SIZE 135.43 BY 16.25
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     brTributado AT ROW 1 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 3.5
         SIZE 135.43 BY 16.25
         FONT 1.

DEFINE FRAME fPage7
     brNenhum AT ROW 1 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.86 ROW 3.5
         SIZE 135.14 BY 16.25 WIDGET-ID 300.

DEFINE FRAME fPage6
     brOutros AT ROW 1 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.86 ROW 3.5
         SIZE 135.14 BY 16.25 WIDGET-ID 400.

DEFINE FRAME fPage5
     brST AT ROW 1 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 3.5
         SIZE 135.43 BY 16.25
         FONT 1 WIDGET-ID 200.

DEFINE FRAME fPage3
     brIsento AT ROW 1 COL 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.86 ROW 3.5
         SIZE 135.14 BY 16.25.

DEFINE FRAME fPage1
     class-fiscal-ini AT ROW 2.25 COL 16 COLON-ALIGNED HELP
          "C¢digo da classifica‡Æo fiscal" WIDGET-ID 170
     class-fiscal-fim AT ROW 2.25 COL 41 COLON-ALIGNED HELP
          "C¢digo da classifica‡Æo fiscal" NO-LABEL WIDGET-ID 172
     cd-trib-icm AT ROW 4.5 COL 20 HELP
          "C¢digo de tributa‡Æo do ICMS" NO-LABEL WIDGET-ID 174
     btLeitura AT ROW 15 COL 109
     "Tributa‡Æo ICMS" VIEW-AS TEXT
          SIZE 13 BY .54 AT ROW 3.5 COL 19 WIDGET-ID 182
     IMAGE-42 AT ROW 2.25 COL 29 WIDGET-ID 166
     IMAGE-43 AT ROW 2.25 COL 40 WIDGET-ID 168
     RECT-1 AT ROW 3.75 COL 18 WIDGET-ID 180
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 3.5
         SIZE 135.43 BY 16.25
         FONT 1
         DEFAULT-BUTTON btLeitura.


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
         HEIGHT             = 20.46
         WIDTH              = 139.57
         MAX-HEIGHT         = 29.46
         MAX-WIDTH          = 182.86
         VIRTUAL-HEIGHT     = 29.46
         VIRTUAL-WIDTH      = 182.86
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
       FRAME fPage3:FRAME = FRAME fpage0:HANDLE
       FRAME fPage4:FRAME = FRAME fpage0:HANDLE
       FRAME fPage5:FRAME = FRAME fpage0:HANDLE
       FRAME fPage6:FRAME = FRAME fpage0:HANDLE
       FRAME fPage7:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* SETTINGS FOR FRAME fPage2
                                                                        */
/* BROWSE-TAB brTributado 1 fPage2 */
ASSIGN 
       brTributado:NUM-LOCKED-COLUMNS IN FRAME fPage2     = 5
       brTributado:COLUMN-RESIZABLE IN FRAME fPage2       = TRUE
       brTributado:COLUMN-MOVABLE IN FRAME fPage2         = TRUE.

/* SETTINGS FOR FRAME fPage3
                                                                        */
/* BROWSE-TAB brIsento 1 fPage3 */
ASSIGN 
       brIsento:POPUP-MENU IN FRAME fPage3             = MENU POPUP-MENU-brIsento:HANDLE
       brIsento:NUM-LOCKED-COLUMNS IN FRAME fPage3     = 7
       brIsento:MAX-DATA-GUESS IN FRAME fPage3         = 1500
       brIsento:COLUMN-RESIZABLE IN FRAME fPage3       = TRUE
       brIsento:COLUMN-MOVABLE IN FRAME fPage3         = TRUE.

/* SETTINGS FOR FRAME fPage4
                                                                        */
/* BROWSE-TAB brCesta 1 fPage4 */
ASSIGN 
       brCesta:NUM-LOCKED-COLUMNS IN FRAME fPage4     = 5
       brCesta:COLUMN-RESIZABLE IN FRAME fPage4       = TRUE
       brCesta:COLUMN-MOVABLE IN FRAME fPage4         = TRUE.

/* SETTINGS FOR FRAME fPage5
                                                                        */
/* BROWSE-TAB brST 1 fPage5 */
ASSIGN 
       brST:NUM-LOCKED-COLUMNS IN FRAME fPage5     = 5
       brST:COLUMN-RESIZABLE IN FRAME fPage5       = TRUE
       brST:COLUMN-MOVABLE IN FRAME fPage5         = TRUE.

/* SETTINGS FOR FRAME fPage6
                                                                        */
/* BROWSE-TAB brOutros 1 fPage6 */
ASSIGN 
       brOutros:POPUP-MENU IN FRAME fPage6             = MENU POPUP-MENU-brIsento-3:HANDLE
       brOutros:NUM-LOCKED-COLUMNS IN FRAME fPage6     = 7
       brOutros:MAX-DATA-GUESS IN FRAME fPage6         = 1500
       brOutros:COLUMN-RESIZABLE IN FRAME fPage6       = TRUE
       brOutros:COLUMN-MOVABLE IN FRAME fPage6         = TRUE.

/* SETTINGS FOR FRAME fPage7
                                                                        */
/* BROWSE-TAB brNenhum 1 fPage7 */
ASSIGN 
       brNenhum:POPUP-MENU IN FRAME fPage7             = MENU POPUP-MENU-brIsento-2:HANDLE
       brNenhum:NUM-LOCKED-COLUMNS IN FRAME fPage7     = 7
       brNenhum:MAX-DATA-GUESS IN FRAME fPage7         = 1500
       brNenhum:COLUMN-RESIZABLE IN FRAME fPage7       = TRUE
       brNenhum:COLUMN-MOVABLE IN FRAME fPage7         = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brCesta
/* Query rebuild information for BROWSE brCesta
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 3 use-index movto.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brCesta */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brIsento
/* Query rebuild information for BROWSE brIsento
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 2 use-index movto.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brIsento */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brNenhum
/* Query rebuild information for BROWSE brNenhum
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 0 use-index movto.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brNenhum */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brOutros
/* Query rebuild information for BROWSE brOutros
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 4 use-index movto.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brOutros */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brST
/* Query rebuild information for BROWSE brST
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 9 use-index movto.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brST */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTributado
/* Query rebuild information for BROWSE brTributado
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-movtos WHERE tt-movtos.cd-trib-icm = 1 use-index movto.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTributado */
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

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage4
/* Query rebuild information for FRAME fPage4
     _Query            is NOT OPENED
*/  /* FRAME fPage4 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage5
/* Query rebuild information for FRAME fPage5
     _Query            is NOT OPENED
*/  /* FRAME fPage5 */
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
  /* MESSAGE " vai rodar o programa"
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
    RUN men/men900za.p (INPUT SELF:FRAME, INPUT THIS-PROCEDURE:HANDLE).*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btLeitura
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btLeitura wWindow
ON CHOOSE OF btLeitura IN FRAME fPage1 /* Ler Cadastros */
DO:
    RUN gravaSelecao.
    if return-value = "NOK" then return no-apply.
    Run queryRefresh.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
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


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fpage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Apaga_Somente_Este_De-Para
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Apaga_Somente_Este_De-Para wWindow
ON CHOOSE OF MENU-ITEM m_Apaga_Somente_Este_De-Para /* Apaga Somente Este De->Para */
DO:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    RUN apaga1DePara.
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Apaga_Somente_Este_De-Para-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Apaga_Somente_Este_De-Para-2 wWindow
ON CHOOSE OF MENU-ITEM m_Apaga_Somente_Este_De-Para-2 /* Apaga Somente Este De->Para */
DO:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    RUN apaga1DePara.
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Apaga_Somente_Este_De-Para-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Apaga_Somente_Este_De-Para-3 wWindow
ON CHOOSE OF MENU-ITEM m_Apaga_Somente_Este_De-Para-3 /* Apaga Somente Este De->Para */
DO:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    RUN apaga1DePara.
      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tp-pedido
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tp-pedido wWindow
ON VALUE-CHANGED OF tp-pedido IN FRAME fpage0 /* Tipo Pedido */
DO:
    apply "Choose":U to btLeitura in frame fPage1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brCesta
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*--- L¢gica para inicializa‡Æo do programam ---*/
{window/MainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AddTTMovto wWindow 
PROCEDURE AddTTMovto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    create  tt-movtos.
    buffer-copy int-ds-tp-trib-natur-oper to tt-movtos
    assign  tt-movtos.r-rowid       = rowid(int-ds-tp-trib-natur-oper)
            tt-movtos.class-fiscal  = int-ds-classif-fisc.class-fiscal
            tt-movtos.desc-trib     = if int-ds-tp-trib-natur-oper.cd-trib-icm = 0 then "Nenhum" else
                                      if int-ds-tp-trib-natur-oper.cd-trib-icm = 1 then "Tributado" else
                                      if int-ds-tp-trib-natur-oper.cd-trib-icm = 2 then "Isento" else
                                      if int-ds-tp-trib-natur-oper.cd-trib-icm = 3 then "Cesta B sica" else
                                      if int-ds-tp-trib-natur-oper.cd-trib-icm = 4 then "Outros" else
                                      if int-ds-tp-trib-natur-oper.cd-trib-icm = 9 then "ST" else "".

    RUN buscaDescClassFiscal.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wWindow 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    /* desabilita folders de itens calculados */
    run setEnabled in hFolder (input 2, input false).
    run setEnabled in hFolder (input 3, input false).
    run setEnabled in hFolder (input 4, input false).
    run setEnabled in hFolder (input 5, input false).
    run setEnabled in hFolder (input 6, input false).
    run setEnabled in hFolder (input 7, input false).

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
  assign tp-pedido:list-item-pairs in frame fPage0 = "0,0".
  for each int-ds-tipo-pedido no-lock
      by int(int-ds-tipo-pedido.tp-pedido):
      tp-pedido:ADD-LAST(trim(string(int-ds-tipo-pedido.tp-pedido)) + "-" + int-ds-tipo-pedido.descricao,int-ds-tipo-pedido.tp-pedido).
  end.
  tp-pedido:DELETE("0,0") no-error.
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE buscaDescClassFiscal wWindow 
PROCEDURE buscaDescClassFiscal :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    for each classif-fisc no-lock where classif-fisc.class-fiscal = tt-movtos.class-fiscal:
        assign tt-movtos.descricao = classif-fisc.descricao.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gravaSelecao wWindow 
PROCEDURE gravaSelecao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

empty temp-table tt-param.
create  tt-param.
assign  tt-param.tp-pedido        = tp-pedido:input-value in frame fPage0
        tt-param.cd-trib-icm      = cd-trib-icm:input-value in frame fPage1
        tt-param.class-fiscal-ini = class-fiscal-ini:screen-value in frame fPage1
        tt-param.class-fiscal-fim = class-fiscal-fim:screen-value in frame fPage1.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE querybrCestaOpen wWindow 
PROCEDURE querybrCestaOpen :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    open query brCesta for each tt-movtos no-lock where
        tt-movtos.cd-trib-icm = 3 use-index movto.

    if num-results ("brCesta") <> 0 then
    do:
        enable brCesta with frame fPage4.
        run setEnabled in hFolder (input 4, input true).
    end.
    else do:
        disable brCesta with frame fPage4.
        run setEnabled in hFolder (input 4, input false).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE querybrIsentoOpen wWindow 
PROCEDURE querybrIsentoOpen :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    open query brIsento for each tt-movtos no-lock where
        tt-movtos.cd-trib-icm = 2 use-index movto.

    if num-results ("brIsento") <> 0 then
    do:
        enable brIsento with frame fPage3.
        run setEnabled in hFolder (input 3, input true).
    end.
    else do:
        disable brIsento with frame fPage3.
        run setEnabled in hFolder (input 3, input false).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE querybrNenhumOpen wWindow 
PROCEDURE querybrNenhumOpen :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    open query brNenhum for each tt-movtos no-lock where
        tt-movtos.cd-trib-icm = 0 use-index movto.

    if num-results ("brNenhum") <> 0 then
    do:
        enable brNenhum with frame fPage7.
        run setEnabled in hFolder (input 7, input true).
    end.
    else do:
        disable brNenhum with frame fPage7.
        run setEnabled in hFolder (input 7, input false).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE querybrOutrosOpen wWindow 
PROCEDURE querybrOutrosOpen :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    open query brOutros for each tt-movtos no-lock where
        tt-movtos.cd-trib-icm = 4 use-index movto.
    if num-results ("brOutros") <> 0 then
    do:
        enable brOutros with frame fPage6.
        run setEnabled in hFolder (input 6, input true).
    end.
    else do:
        disable brOutros with frame fPage6.
        run setEnabled in hFolder (input 6, input false).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE querybrSTOpen wWindow 
PROCEDURE querybrSTOpen :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    open query brST for each tt-movtos no-lock where
        tt-movtos.cd-trib-icm = 9 use-index movto.
    if num-results ("brST") <> 0 then
    do:
        enable brST with frame fPage5.
        run setEnabled in hFolder (input 5, input true).
    end.
    else do:
        disable brST with frame fPage5.
        run setEnabled in hFolder (input 5, input false).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE querybrTributadoOpen wWindow 
PROCEDURE querybrTributadoOpen :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    open query brTributado for each tt-movtos no-lock where
        tt-movtos.cd-trib-icm = 1 use-index movto.
    if num-results ("brTributado") <> 0 then
    do:
        enable brTributado with frame fPage2.
        run setEnabled in hFolder (input 2, input true).
    end.
    else do:
        disable brTributado with frame fPage2.
        run setEnabled in hFolder (input 2, input false).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE queryRefresh wWindow 
PROCEDURE queryRefresh :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Lendo Cadastros").

empty temp-table tt-movtos.
/* Desabilita folders de itens calculados */
run setEnabled in hFolder (input 2, input false).
run setEnabled in hFolder (input 3, input false).
run setEnabled in hFolder (input 4, input false).
run setEnabled in hFolder (input 5, input false).
run setEnabled in hFolder (input 6, input false).
run setEnabled in hFolder (input 7, input false).

for each int-ds-tp-trib-natur-oper no-lock where
    int-ds-tp-trib-natur-oper.tp-pedido    = tt-param.tp-pedido and
    int-ds-tp-trib-natur-oper.class-fiscal = "",
    each int-ds-classif-fisc no-lock where 
    int-ds-classif-fisc.cd-trib-icm   = int-ds-tp-trib-natur-oper.cd-trib-icm and
    int-ds-classif-fisc.class-fiscal >= tt-param.class-fiscal-ini and
    int-ds-classif-fisc.class-fiscal <= tt-param.class-fiscal-fim
    query-tuning(no-lookahead):

    if  tt-param.cd-trib-icm <> 99 /* todos */ and
        tt-param.cd-trib-icm <> int-ds-tp-trib-natur-oper.cd-trib-icm then next.

    RUN AddTTMovto.
end.
for each int-ds-tp-trib-natur-oper no-lock where
    int-ds-tp-trib-natur-oper.tp-pedido     = tt-param.tp-pedido and
    int-ds-tp-trib-natur-oper.class-fiscal <> "",
    each int-ds-classif-fisc no-lock where
    int-ds-classif-fisc.cd-trib-icm   = int-ds-tp-trib-natur-oper.cd-trib-icm  and
    int-ds-classif-fisc.class-fiscal  = int-ds-tp-trib-natur-oper.class-fiscal and
    int-ds-classif-fisc.class-fiscal >= tt-param.class-fiscal-ini and
    int-ds-classif-fisc.class-fiscal <= tt-param.class-fiscal-fim
    query-tuning(no-lookahead):

    if  tt-param.cd-trib-icm <> 99 /* todos */ and
        tt-param.cd-trib-icm <> int-ds-tp-trib-natur-oper.cd-trib-icm then next.

    RUN AddTTMovto.
end.

run pi-finalizar in h-acomp.

/* abre browses */
run querybrTributadoOpen.
run querybrIsentoOpen.
run querybrCestaOpen.
run querybrSTOpen.
run querybrOutrosOpen.
run querybrNenhumOpen.

if num-results ("brTributado") <> 0 then
do:
    enable brTributado with frame fPage2.
    run setEnabled in hFolder (input 2, input true).
end.
if num-results ("brIsento") <> 0 then
do:
    enable brIsento with frame fPage3.
    run setEnabled in hFolder (input 3, input true).
end.
if num-results ("brCesta") <> 0 then
do:
    enable brCEsta with frame fPage4.
    run setEnabled in hFolder (input 4, input true).
end.
if num-results ("brST") <> 0 then
do:
    enable brST with frame fPage5.
    run setEnabled in hFolder (input 5, input true).
end.
if num-results ("brOutros") <> 0 then
do:
    enable brOutros with frame fPage6.
    run setEnabled in hFolder (input 6, input true).
end.

if num-results ("brNenhum") <> 0 then
do:
    enable brNenhum with frame fPage7.
    run setEnabled in hFolder (input 7, input true).
end.

/* troca pagina */
if  num-results ("brTributado") <> 0 then 
    run SetFolder IN hFolder (INPUT 2).
else if num-results ("brIsento") <> 0  then
    run SetFolder IN hFolder (INPUT 3).
else if num-results ("brCesta") <> 0  then
    run SetFolder IN hFolder (INPUT 4).
else if num-results ("brST") <> 0  then
    run SetFolder IN hFolder (INPUT 5).
else if num-results ("brOutros") <> 0  then
    run SetFolder IN hFolder (INPUT 6).
else if num-results ("brNenhum") <> 0  then
    run SetFolder IN hFolder (INPUT 7).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

