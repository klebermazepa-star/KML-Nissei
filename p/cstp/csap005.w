&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
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

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

{cstp/i-var-imp.i}

def temp-table tt_tit_ap_alteracao_base_1 no-undo
    field ttv_cod_usuar_corren             as character format "x(12)" label "Usu†rio Corrente" column-label "Usu†rio Corrente"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_dat_transacao                as date format "99/99/9999" label "Data Transaá∆o" column-label "Data Transaá∆o"
    field ttv_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_val_sdo_tit_ap               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Saldo" column-label "Valor Saldo"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss∆o" column-label "Dt Emiss∆o"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_dat_prev_pagto               as date format "99/99/9999" initial today label "Data Prevista Pgto" column-label "Dt Prev Pagto"
    field tta_dat_ult_pagto                as date format "99/99/9999" initial ? label "Data £ltimo Pagto" column-label "Data £ltimo Pagto"
    field tta_num_dias_atraso              as integer format ">9" initial 0 label "Dias Atraso" column-label "Dias Atr"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_val_juros_dia_atraso         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juro" column-label "Vl Juro"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field ttv_cod_portador_mov             as character format "x(5)" label "Portador Movto" column-label "Portador Movto"
    field tta_log_pagto_bloqdo             as logical format "Sim/Nío" initial no label "Bloqueia Pagamento" column-label "Pagto Bloqdo"
    field tta_cod_seguradora               as character format "x(8)" label "Seguradora" column-label "Seguradora"
    field tta_cod_apol_seguro              as character format "x(12)" label "Ap¢lice Seguro" column-label "Apolice Seguro"
    field tta_cod_arrendador               as character format "x(6)" label "Arrendador" column-label "Arrendador"
    field tta_cod_contrat_leas             as character format "x(12)" label "Contrato Leasing" column-label "Contr Leas"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo EspÇcie" column-label "Tipo EspÇcie"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field ttv_ind_motiv_alter_val_tit_ap   as character format "X(09)" initial "Alteraá∆o" label "Motivo Alteraá∆o" column-label "Motivo Alteraá∆o"
    field ttv_wgh_lista                    as widget-handle extent 15 format ">>>>>>9"
    field ttv_log_gera_ocor_alter_valores  as logical format "Sim/N∆o" initial no
    field tta_cb4_tit_ap_bco_cobdor        as Character format "x(50)" label "Titulo Bco Cobrador" column-label "Titulo Bco Cobrador"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico Padr∆o" column-label "Hist¢rico Padr∆o"
    field tta_des_histor_padr              as character format "x(40)" label "Descriá∆o" column-label "Descriá∆o Hist¢rico Padr∆o"
    field tta_ind_sit_tit_ap               as character format "X(13)" label "Situaá∆o" column-label "Situaá∆o"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    index tt_titap_id                     
          tta_cod_estab                    ascending
          tta_cdn_fornecedor               ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending.

def new shared temp-table tt_tit_ap_alteracao_rateio no-undo
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "SeqÅància" column-label "Seq"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field ttv_ind_tip_rat                  as character format "X(08)"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field tta_num_id_aprop_ctbl_ap         as integer format "9999999999" initial 0 label "Id Aprop Ctbl AP" column-label "Id Aprop Ctbl AP"
    index tt_aprpctba_id                   is primary unique
          tta_cod_estab                    ascending
          tta_cod_refer                    ascending
          tta_num_seq_refer                ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_unid_negoc               ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
          tta_cod_tip_fluxo_financ         ascending
          ttv_rec_tit_ap                   ascending.

def new shared temp-table tt_log_erros_tit_ap_alteracao no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Número" column-label "N£mero Mensagem"
    field ttv_cod_tip_msg_dwb              as character format "x(12)" label "Tipo Mensagem" column-label "Tipo Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "inconsistància"
    field ttv_des_msg_ajuda_1              as character format "x(360)"
    field ttv_wgh_focus                    as widget-handle format ">>>>>>9".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-34 RECT-39 RECT-40 bt-ok v-cod-bar ~
fi-lin-dig fi-val_sdo_tit_ap bt_fechar 
&Scoped-Define DISPLAYED-OBJECTS v-cod-bar fi-lin-dig v_cod_estab ~
v_cdn_fornecedor v_cod_espec_docto v_cod_ser_docto v_cod_tit_ap ~
v_cod_parcela fi-val_sdo_tit_ap fi-dat_vencto_tit_ap 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-ok 
     IMAGE-UP FILE "image/im-chck1.bmp":U
     LABEL "Ok" 
     SIZE 4 BY 1.

DEFINE BUTTON bt_fechar AUTO-END-KEY 
     LABEL "Fechar" 
     SIZE 10.57 BY 1 TOOLTIP "Cancela"
     FONT 1.

DEFINE VARIABLE fi-dat_vencto_tit_ap AS DATE FORMAT "99/99/9999" INITIAL 01/16/04 
     LABEL "Data Vencimento" 
     VIEW-AS FILL-IN 
     SIZE 12.57 BY .88
     BGCOLOR 8 FONT 4.

DEFINE VARIABLE fi-lin-dig AS CHARACTER FORMAT "XXXXX.XXXXX XXXXX.XXXXXX XXXXX.XXXXXX X XXXXXXXXXXXXXX" 
     LABEL "Linha digit†vel" 
     VIEW-AS FILL-IN 
     SIZE 51.14 BY .88
     BGCOLOR 15 .

DEFINE VARIABLE fi-val_sdo_tit_ap AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     LABEL "Valor Saldo" 
     VIEW-AS FILL-IN 
     SIZE 18.29 BY .88
     BGCOLOR 8 FONT 4.

DEFINE VARIABLE v-cod-bar AS CHARACTER FORMAT "x(44)" 
     LABEL "C¢digo de Barras" 
     VIEW-AS FILL-IN 
     SIZE 51.14 BY .88
     BGCOLOR 15 .

DEFINE VARIABLE v_cdn_fornecedor AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Fornecedor" 
     VIEW-AS FILL-IN 
     SIZE 14.14 BY .88
     BGCOLOR 8 FONT 1 NO-UNDO.

DEFINE VARIABLE v_cod_espec_docto AS CHARACTER FORMAT "x(3)" 
     LABEL "EspÇcie" 
     VIEW-AS FILL-IN 
     SIZE 7.14 BY .88
     BGCOLOR 8 FONT 1 NO-UNDO.

DEFINE VARIABLE v_cod_estab AS CHARACTER FORMAT "x(3)" 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 7.14 BY .88
     BGCOLOR 8 FONT 1 NO-UNDO.

DEFINE VARIABLE v_cod_parcela AS CHARACTER FORMAT "x(02)" 
     LABEL "Parcela" 
     VIEW-AS FILL-IN 
     SIZE 5.14 BY .88
     BGCOLOR 8 FONT 1 NO-UNDO.

DEFINE VARIABLE v_cod_ser_docto AS CHARACTER FORMAT "x(3)" 
     LABEL "SÇrie Documento" 
     VIEW-AS FILL-IN 
     SIZE 7.14 BY .88
     BGCOLOR 8 FONT 1 NO-UNDO.

DEFINE VARIABLE v_cod_tit_ap AS CHARACTER FORMAT "x(10)" 
     LABEL "T°tulo" 
     VIEW-AS FILL-IN 
     SIZE 14.14 BY .88
     BGCOLOR 8 FONT 1 NO-UNDO.

DEFINE RECTANGLE RECT-34
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 70.57 BY 3.5.

DEFINE RECTANGLE RECT-39
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 70.43 BY 3.

DEFINE RECTANGLE RECT-40
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 70.57 BY 1.5
     BGCOLOR 18 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     bt-ok AT ROW 1.71 COL 67
     v-cod-bar AT ROW 1.75 COL 13.43 COLON-ALIGNED
     fi-lin-dig AT ROW 2.75 COL 13.43 COLON-ALIGNED
     v_cod_estab AT ROW 5 COL 13.43 COLON-ALIGNED HELP
          "C¢digo Estabelecimento"
     v_cdn_fornecedor AT ROW 5 COL 36.72 COLON-ALIGNED HELP
          "C¢digo Fornecedor"
     v_cod_espec_docto AT ROW 5 COL 61.72 COLON-ALIGNED HELP
          "C¢digo EspÇcie Documento"
     v_cod_ser_docto AT ROW 6 COL 13.43 COLON-ALIGNED HELP
          "C¢digo SÇrie Documento"
     v_cod_tit_ap AT ROW 6 COL 36.72 COLON-ALIGNED HELP
          "C¢digo T°tulo"
     v_cod_parcela AT ROW 6 COL 63.72 COLON-ALIGNED HELP
          "Parcela"
     fi-val_sdo_tit_ap AT ROW 7 COL 13.57 COLON-ALIGNED
     fi-dat_vencto_tit_ap AT ROW 7 COL 56.29 COLON-ALIGNED
     bt_fechar AT ROW 8.63 COL 60.29
     "T°tulo" VIEW-AS TEXT
          SIZE 4 BY .54 AT ROW 4.5 COL 3.43
     "Seleá∆o" VIEW-AS TEXT
          SIZE 6 BY .54 AT ROW 1 COL 3.43
     RECT-34 AT ROW 4.75 COL 1.43
     RECT-39 AT ROW 1.25 COL 1.57
     RECT-40 AT ROW 8.38 COL 1.43
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 72.43 BY 9
         BGCOLOR 17 FONT 1.


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
         TITLE              = "Desvinculaá∆o Boleto Banc†rio de T°tulo Pagar"
         HEIGHT             = 9
         WIDTH              = 71.29
         MAX-HEIGHT         = 22.33
         MAX-WIDTH          = 102.57
         VIRTUAL-HEIGHT     = 22.33
         VIRTUAL-WIDTH      = 102.57
         MAX-BUTTON         = no
         RESIZE             = no
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
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN fi-dat_vencto_tit_ap IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v_cdn_fornecedor IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
ASSIGN 
       v_cdn_fornecedor:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

/* SETTINGS FOR FILL-IN v_cod_espec_docto IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v_cod_estab IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v_cod_parcela IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v_cod_ser_docto IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v_cod_tit_ap IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Desvinculaá∆o Boleto Banc†rio de T°tulo Pagar */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Desvinculaá∆o Boleto Banc†rio de T°tulo Pagar */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok C-Win
ON CHOOSE OF bt-ok IN FRAME DEFAULT-FRAME /* Ok */
DO:
    DEFINE VARIABLE c-linha-digi    AS CHARACTER  NO-UNDO.
    define variable v-datavenctit   as date       no-undo.
    define variable v-valorlido     as decimal    no-undo.
    define variable r-titap         as recid      no-undo.

    ASSIGN c-linha-digi = replace(replace(input frame {&frame-name} fi-lin-dig:screen-value, " ", ""), ".", "").

    IF c-linha-digi = "" THEN DO:
        MESSAGE "Linha digit†vel n∆o informada." SKIP(1)
                "ê necess†rio informar ao menos a linha" SKIP
                "digit†vel para vincular um t°tulo."
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    if input frame {&frame-name} v-cod-bar  <> "" or
       input frame {&frame-name} fi-lin-dig <> "" then do:
       
        assign  v-datavenctit = 10/07/97 + int(substring(input frame {&frame-name} fi-lin-dig, 34, 4)).
                v-valorlido   = deci(substring(input frame {&frame-name} fi-lin-dig, 38, 10)) / 100.
    end.
    run busca-tit(input c-linha-digi, output r-titap).
    if return-value = "OK":U then
        run desvincula-tit(r-titap).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt_fechar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt_fechar C-Win
ON CHOOSE OF bt_fechar IN FRAME DEFAULT-FRAME /* Fechar */
DO:
    APPLY "close" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-lin-dig
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-lin-dig C-Win
ON RETURN OF fi-lin-dig IN FRAME DEFAULT-FRAME /* Linha digit†vel */
DO:
  apply "CHOOSE":U to bt-ok.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-cod-bar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-cod-bar C-Win
ON LEAVE OF v-cod-bar IN FRAME DEFAULT-FRAME /* C¢digo de Barras */
DO:
    def var c-campo1 as char no-undo.
    def var c-campo2 as char no-undo.
    def var c-campo3 as char no-undo.
    def var c-campo4 as char no-undo.
    def var c-campo5 as char no-undo.

    if length(v-cod-bar:screen-value in frame {&frame-name}) > 35 then do:
        run pi-calc-linha-digitavel (input v-cod-bar:screen-value in frame {&frame-name},
                                     output c-campo1,
                                     output c-campo2,
                                     output c-campo3,
                                     output c-campo4,
                                     output c-campo5).

        assign fi-lin-dig:screen-value in frame {&frame-name} = c-campo1 + c-campo2 + c-campo3 + c-campo4 + c-campo5.
/*         assign fi-lin-dig1:screen-value in frame {&frame-name} = c-campo1  */
/*                fi-lin-dig2:screen-value in frame {&frame-name} = c-campo2  */
/*                fi-lin-dig3:screen-value in frame {&frame-name} = c-campo3  */
/*                fi-lin-dig4:screen-value in frame {&frame-name} = c-campo4  */
/*                fi-lin-dig5:screen-value in frame {&frame-name} = c-campo5. */
    end.
    else
        assign fi-lin-dig:screen-value in frame {&frame-name} = "".
/*         assign fi-lin-dig1:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig2:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig3:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig4:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig5:screen-value in frame {&frame-name} = "". */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-cod-bar C-Win
ON RETURN OF v-cod-bar IN FRAME DEFAULT-FRAME /* C¢digo de Barras */
DO:
    apply "leave":u to self.
    apply "choose":u to bt-ok in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE busca-tit C-Win 
PROCEDURE busca-tit :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter  c-linha-digi     as char             no-undo.
    define output parameter r-titap          as recid            no-undo.
    define variable         l-temtit         as logical  init no no-undo.
    
    for each cst_tit_ap no-lock
        where cst_tit_ap.cb4_tit_ap_bco_cobdor = c-linha-digi
          and cst_tit_ap.dat_liquidac_tit_ap   = 12/31/9999,
        first tit_ap no-lock
        where tit_ap.cod_estab       = cst_tit_ap.cod_estab
          and tit_ap.cdn_fornec      = cst_tit_ap.cdn_fornec
          and tit_ap.cod_espec_docto = cst_tit_ap.cod_espec_docto
          and tit_ap.cod_ser_docto   = cst_tit_ap.cod_ser_docto
          and tit_ap.cod_tit_ap      = cst_tit_ap.cod_tit_ap
          and tit_ap.cod_parcela     = cst_tit_ap.cod_parcela:
    
        if tit_ap.cb4_tit_ap_bco_cobdor  <> c-linha-digi  then next.
    
        assign  fi-dat_vencto_tit_ap:screen-value in frame {&frame-name}    = string(tit_ap.dat_vencto_tit_ap)
                fi-val_sdo_tit_ap:screen-value in frame {&frame-name}    = string(tit_ap.val_sdo_tit_ap)
                v_cdn_fornecedor:screen-value in frame {&frame-name}        = string(tit_ap.cdn_fornecedor)
                v_cod_espec_docto:screen-value in frame {&frame-name}       = tit_ap.cod_espec_docto
                v_cod_estab:screen-value in frame {&frame-name}             = tit_ap.cod_estab
                v_cod_parcela:screen-value in frame {&frame-name}           = tit_ap.cod_parcela
                v_cod_ser_docto:screen-value in frame {&frame-name}         = tit_ap.cod_ser_docto
                v_cod_tit_ap:screen-value in frame {&frame-name}            = tit_ap.cod_tit_ap
                r-titap                                                     = recid(tit_ap)
                l-temtit                                                    = true.
    end.
    if not l-temtit then do:
        message "Nenhum t°tulo encontrado" view-as alert-box info.
        run pi-limpa-campos.
        return no-apply "NOK":U.
    end.
    
    return "OK":U.
    


end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE desvincula-tit C-Win 
PROCEDURE desvincula-tit :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    def input param r-titap as recid no-undo.

    find first tit_ap where recid(tit_ap) = r-titap no-error.

    message "Confirma desvinculaá∆o do boleto?"
        view-as alert-box question
        buttons yes-no
        update l-confirma as logical.
    
    if not l-confirma then do:
        run pi-limpa-campos.
        return no-apply.
    end.

    if avail tit_ap then do:

        find first cst_tit_ap_log 
            where   cst_tit_ap_log.cod_tit_ap        = tit_ap.cod_tit_ap     
              and   cst_tit_ap_log.cod_ser_docto     = tit_ap.cod_ser_docto  
              and   cst_tit_ap_log.cod_parcela       = tit_ap.cod_parcela    
              and   cst_tit_ap_log.cod_estab         = tit_ap.cod_estab      
              and   cst_tit_ap_log.cod_espec_docto   = tit_ap.cod_espec_docto
              and   cst_tit_ap_log.cdn_fornecedor    = tit_ap.cdn_fornecedor no-error.

        if not avail cst_tit_ap_log then 
            next.
    
        BLOCO-TRANS:
        do transaction on error undo, leave:
                
            if cst_tit_ap_log.val_desconto <> tit_ap.val_desconto then do:
                empty temp-table tt_tit_ap_alteracao_base_1.
                
                create tt_tit_ap_alteracao_base_1.
                assign tt_tit_ap_alteracao_base_1.ttv_cod_usuar_corren            = v_cod_usuar_corren
                       tt_tit_ap_alteracao_base_1.tta_cod_empresa                 = tit_ap.cod_empresa                              
                       tt_tit_ap_alteracao_base_1.tta_cod_estab                   = tit_ap.cod_estab                                
                       tt_tit_ap_alteracao_base_1.tta_num_id_tit_ap               = tit_ap.num_id_tit_ap                            
                       tt_tit_ap_alteracao_base_1.ttv_rec_tit_ap                  = recid(tit_ap)                                   
                       tt_tit_ap_alteracao_base_1.tta_cdn_fornecedor              = tit_ap.cdn_fornecedor                           
                       tt_tit_ap_alteracao_base_1.tta_cod_espec_docto             = tit_ap.cod_espec_docto                          
                       tt_tit_ap_alteracao_base_1.tta_cod_ser_docto               = tit_ap.cod_ser_docto                            
                       tt_tit_ap_alteracao_base_1.tta_cod_tit_ap                  = tit_ap.cod_tit_ap                               
                       tt_tit_ap_alteracao_base_1.tta_cod_parcela                 = tit_ap.cod_parcela                              
                       tt_tit_ap_alteracao_base_1.ttv_dat_transacao               = today
                       tt_tit_ap_alteracao_base_1.tta_val_sdo_tit_ap              = tit_ap.val_sdo_tit_ap                           
                       tt_tit_ap_alteracao_base_1.tta_dat_emis_docto              = tit_ap.dat_emis_docto
                       tt_tit_ap_alteracao_base_1.tta_dat_vencto_tit_ap           = tit_ap.dat_vencto_tit_ap
                       tt_tit_ap_alteracao_base_1.tta_dat_prev_pagto              = ?
                       tt_tit_ap_alteracao_base_1.tta_dat_ult_pagto               = ?
                       tt_tit_ap_alteracao_base_1.tta_dat_desconto                = tit_ap.dat_desconto
                       tt_tit_ap_alteracao_base_1.tta_cod_portador                = tit_ap.cod_portador 
                       tt_tit_ap_alteracao_base_1.tta_log_pagto_bloqdo            = tit_ap.log_pagto_bloqdo                             
                       tt_tit_ap_alteracao_base_1.tta_cod_seguradora              = tit_ap.cod_seguradora                           
                       tt_tit_ap_alteracao_base_1.tta_cod_apol_seguro             = tit_ap.cod_apol_seguro                 
                       tt_tit_ap_alteracao_base_1.tta_cod_arrendador              = tit_ap.cod_arrendador
                       tt_tit_ap_alteracao_base_1.tta_cod_contrat_leas            = tit_ap.cod_contrat_leas
                       tt_tit_ap_alteracao_base_1.tta_ind_tip_espec_docto         = tit_ap.ind_tip_espec_docto
                       tt_tit_ap_alteracao_base_1.tta_cod_indic_econ              = tit_ap.cod_indic_econ
                       tt_tit_ap_alteracao_base_1.tta_ind_sit_tit_ap              = tit_ap.ind_sit_tit_ap
                       tt_tit_ap_alteracao_base_1.tta_cod_forma_pagto             = tit_ap.cod_forma_pagto
                       tt_tit_ap_alteracao_base_1.tta_cb4_tit_ap_bco_cobdor       = ''
                       tt_tit_ap_alteracao_base_1.tta_val_desconto                = cst_tit_ap_log.val_desconto
                       tt_tit_ap_alteracao_base_1.ttv_ind_motiv_alter_val_tit_ap  = "Alteraá∆o".
                
                run prgfin/apb/apb767zc.py (input 1,
                                            input "APB",
                                            input "",
                                            input-output table tt_tit_ap_alteracao_base_1,
                                            input-output table tt_tit_ap_alteracao_rateio,
                                            output table tt_log_erros_tit_ap_alteracao).
                                            
                
                
                if can-find(first tt_log_erros_tit_ap_alteracao) then do:
                    for each tt_log_erros_tit_ap_alteracao:
                        message 
                            "tta_cod_estab:"       tt_log_erros_tit_ap_alteracao.tta_cod_estab       skip
                            "tta_cdn_fornecedor:"  tt_log_erros_tit_ap_alteracao.tta_cdn_fornecedor  skip
                            "tta_cod_espec_docto:" tt_log_erros_tit_ap_alteracao.tta_cod_espec_docto skip
                            "tta_cod_ser_docto:"   tt_log_erros_tit_ap_alteracao.tta_cod_ser_docto   skip
                            "tta_cod_tit_ap:"      tt_log_erros_tit_ap_alteracao.tta_cod_tit_ap      skip
                            "tta_cod_parcela:"     tt_log_erros_tit_ap_alteracao.tta_cod_parcela     skip
                            "tta_num_id_tit_ap:"   tt_log_erros_tit_ap_alteracao.tta_num_id_tit_ap   skip
                            "ttv_num_mensagem:"    tt_log_erros_tit_ap_alteracao.ttv_num_mensagem    skip
                            "ttv_cod_tip_msg_dwb:" tt_log_erros_tit_ap_alteracao.ttv_cod_tip_msg_dwb skip
                            "ttv_des_msg_erro:"    tt_log_erros_tit_ap_alteracao.ttv_des_msg_erro    
                        view-as alert-box info buttons ok.
                    end.
                
                    undo BLOCO-TRANS, leave BLOCO-TRANS.
                end.
            end.
            /*else*/
            /* Gustavo - Datasul Paranaense
                Sempre que desvincula deve limpar as informaá‰es de c¢digo de barra
               A rotina acima n∆o est† conseguindo atribuir "" para o c¢digo de barra */

            assign 
                tit_ap.cb4_tit_ap_bco_cobdor = ''.

            delete cst_tit_ap_log.
        end.
    end.

    message 'T°tulo desvinculado com sucesso.' 
        view-as alert-box info.

    run pi-limpa-campos.

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
  DISPLAY v-cod-bar fi-lin-dig v_cod_estab v_cdn_fornecedor v_cod_espec_docto 
          v_cod_ser_docto v_cod_tit_ap v_cod_parcela fi-val_sdo_tit_ap 
          fi-dat_vencto_tit_ap 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE RECT-34 RECT-39 RECT-40 bt-ok v-cod-bar fi-lin-dig fi-val_sdo_tit_ap 
         bt_fechar 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-calc-linha-digitavel C-Win 
PROCEDURE pi-calc-linha-digitavel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter c-codigo-barras as char no-undo.
    define output parameter c-campo-1       as char no-undo.
    define output parameter c-campo-2       as char no-undo.
    define output parameter c-campo-3       as char no-undo.
    define output parameter c-campo-4       as char no-undo.
    define output parameter c-campo-5       as char no-undo.

    define variable c-digito    as char     no-undo.
    define variable i-pos       as integer  no-undo.
    define variable i-tot       as integer  no-undo.
    define variable i-mult      as integer  no-undo.
    define variable i-cont      as integer  no-undo.
    define variable i-aux       as integer  no-undo.

    assign c-campo-1 = substr(c-codigo-barras, 01, 04) + substr(c-codigo-barras, 20, 5)
           c-campo-2 = substr(c-codigo-barras, 25, 10)
           c-campo-3 = substr(c-codigo-barras, 35, 10)
           c-campo-4 = substr(c-codigo-barras, 05, 01)
           c-campo-5 = substr(c-codigo-barras, 06, 14).

    /* digito do campo 1 */
    assign i-pos  = 10
           i-tot  = 0.

    do i-cont = 1 to 9:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 1.
       else
           assign i-mult = 2.

       assign i-aux = int(substr(c-campo-1,i-pos,1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux,"99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.
    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito = "0".
    else
        assign c-digito = string(i-aux,"9").

    assign c-campo-1 = c-campo-1 + c-digito.

    /* digito do campo 2 */
    assign i-pos  = 11
           i-tot  = 0.

    do i-cont = 1 to 10:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 2.
       else
           assign i-mult = 1.

       assign i-aux = int(substr(c-campo-2,i-pos,1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux, "99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.
    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito =  "0".
    else 
        assign c-digito = string(i-aux, "9").

    assign c-campo-2 = c-campo-2 + c-digito.

    /* digito do campo 3 */
    assign i-pos  = 11
           i-tot  = 0.

    do i-cont = 1 to 10:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 2.
       else
           assign i-mult = 1.

       assign i-aux = int(substr(c-campo-3, i-pos, 1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux, "99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.

    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito = "0".
    else
        assign c-digito = string(i-aux,"9").

    assign c-campo-3 = c-campo-3 + c-digito.

/*     /* montagem da linha digitavel */                                    */
/*     assign c-linha-digitavel = string(c-campo-1,"XXXXX.XXXXX")  + "  " + */
/*                                string(c-campo-2,"XXXXX.XXXXXX") + "  " + */
/*                                string(c-campo-3,"XXXXX.XXXXXX") + "  " + */
/*                                c-campo-4                        + "  " + */
/*                                c-campo-5.                                */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-limpa-campos C-Win 
PROCEDURE pi-limpa-campos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    assign  fi-lin-dig:screen-value in frame {&frame-name}              = ""  
            v-cod-bar:screen-value in frame {&frame-name}               = ""  
            fi-dat_vencto_tit_ap:screen-value in frame {&frame-name}    = ""  
            fi-val_sdo_tit_ap:screen-value in frame {&frame-name}    = ""  
            v_cdn_fornecedor:screen-value in frame {&frame-name}        = ""  
            v_cod_espec_docto:screen-value in frame {&frame-name}       = ""  
            v_cod_estab:screen-value in frame {&frame-name}             = ""  
            v_cod_parcela:screen-value in frame {&frame-name}           = ""  
            v_cod_ser_docto:screen-value in frame {&frame-name}         = ""  
            v_cod_tit_ap:screen-value in frame {&frame-name}            = "". 
                                                                              
    apply "entry":U to v-cod-bar in frame {&frame-name}.                      

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

