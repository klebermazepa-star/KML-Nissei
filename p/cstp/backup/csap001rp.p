&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*************************************************************************************************************
**                                                                                                          **
**     Programa.........: rpt_titulo_abertos_apb_nissei                                                     **
**     Descricao .......: Relatorio Titulos Abertos Pagar                                                   **
**     Versao...........: 1.00.001                                                                          **
**     Nome Externo.....: cstp/csap001rp.p                                                                  **
**                                                                                                          **
**************************************************************************************************************/

DEFINE BUFFER fornecedor FOR ems5.fornecedor.

{system/Error.i}

define input parameter janela as handle     no-undo.

define temp-table ttTitulo no-undo
    like tit_ap
    field nom_abrev      like fornecedor.nom_abrev
    field cod_estab_bord like item_bord_ap.cod_estab_bord 
    field num_bord_ap    like item_bord_ap.num_bord_ap
    field vinculado      as logical format "Sim/NÆo".

define temp-table ttFornecedor no-undo
    field cdn_fornecedor   like tit_ap.cdn_fornecedor
    field nom_abrev        like fornecedor.nom_abrev
    field val_desconto     like tit_ap.val_desconto    
    field val_juros        like tit_ap.val_juros       
    field val_multa_tit_ap like tit_ap.val_multa_tit_ap
    field val_sdo_tit_ap   like tit_ap.val_sdo_tit_ap
    index pk_fornecedor cdn_fornecedor.

define temp-table ttVencimento no-undo
    field dat_vencto_tit_ap like tit_ap.dat_vencto_tit_ap
    field val_desconto      like tit_ap.val_desconto    
    field val_juros         like tit_ap.val_juros       
    field val_multa_tit_ap  like tit_ap.val_multa_tit_ap
    field val_sdo_tit_ap    like tit_ap.val_sdo_tit_ap
    index pk_vencimento dat_vencto_tit_ap.

define temp-table ttNotas no-undo
    field cod_estab       like tit_ap.cod_estab     
    field cdn_fornecedor  like tit_ap.cdn_fornecedor
    field cod_espec_docto like tit_ap.cod_espec_docto
    field cod_ser_docto   like tit_ap.cod_ser_docto  
    field cod_tit_ap      like tit_ap.cod_tit_ap     
    field cod_parcela     like tit_ap.cod_parcela    
    field estab           like tit_ap.cod_estab      
    field especie         like tit_ap.cod_espec_docto
    field serie           like tit_ap.cod_ser_docto  
    field titulo          like tit_ap.cod_tit_ap     
    field parcela         like tit_ap.cod_parcela    
    field valor           like tit_ap.val_sdo_tit_ap
    index pk_titulo cod_estab 
                    cdn_fornecedor 
                    cod_espec_docto 
                    cod_ser_docto 
                    cod_tit_ap 
                    cod_parcela.

define buffer bTitulo for tit_ap.
define buffer bMovimento for movto_tit_ap.

/****************** Defini‡Æo de Tabelas Tempor rias do Relat¢rio **********************/

define new global shared variable v_cod_empres_usuar    like emsuni.empresa.cod_empresa    no-undo.
define new global shared variable v_cod_estab_usuar     as character                no-undo.
define new global shared variable v_cod_usuar_corren    as character format 'x(12)' no-undo.
define new global shared variable l-implanta            as logical    init no.
define new global shared variable c-seg-usuario         as char format 'x(12)' no-undo.

define new global shared variable i-num-ped-exec-rpw    as integer no-undo.
define new global shared variable i-pais-impto-usuario  as integer format '>>9' no-undo.
define new global shared variable l-rpc                 as logical no-undo.
define new global shared variable r-registro-atual      as rowid no-undo.
define new global shared variable c-arquivo-log         as char  format 'x(60)'no-undo.

/* Vari veis PadrÆo DWB */
define new global shared variable i-num-ped             as integer no-undo.
define new global shared variable h_prog_segur_estab    as handle  no-undo.
define new global shared variable v_cod_grp_usuar_lst   as char    no-undo.
define new global shared variable v_num_tip_aces_usuar  as int     no-undo.

def new global shared temp-table tt-servid-rpc-aplicat
    field tta-cod-aplicat-dtsul like aplicat_dtsul.cod_aplicat_dtsul
    field tta-hdl-servid-rpc     as   handle.

define variable rw-log-exec as rowid no-undo.
define variable c-erro-rpc  as character format 'x(60)' initial ' ' no-undo.
define variable c-erro-aux  as character format 'x(60)' initial ' ' no-undo.

/****************** Defini‡ao de Vari veis de Processamento do Relat¢rio *********************/

define new global shared variable v_cod_dwb_user     as char no-undo.

define variable v-vlbco              AS decimal FORMAT '>>>,>>>,>>9.99' COLUMN-LABEL 'Vl Docto' NO-UNDO.
define variable v-mensagem           AS CHARACTER FORMAT 'x(100)' NO-UNDO.
define variable v_cod_empresa        like emsuni.empresa.cod_empresa no-undo.
define variable v-num-teste          as integer format '9999' initial 1.
define variable i                    as integer no-undo.
define variable arquivo              like emsfnd.dwb_set_list_param.cod_dwb_file no-undo.
define variable v_cod_dwb_output     like emsfnd.dwb_set_list_param.cod_dwb_output no-undo.
define variable h-hacr440            as handle no-undo.
define variable v-cod-destino-impres as char   no-undo.
define variable v-num-reg-lidos      as int    no-undo.
define variable v-num-point          as int    no-undo.
define variable v-num-set            as int    no-undo.
define variable v-cod-arquivo        as char.
define variable v-num-tip-reg        as integer format '999'.
define variable c-empresa            as character format 'x(40)' no-undo.
define variable c-tit_acr-relat      as character format 'x(50)' no-undo.
define variable c-sistema            as character format 'x(25)' no-undo.
define variable ca-rodape            as char.
define variable i-numper-x           as integer   format 'ZZ'    no-undo.
define variable da-iniper-x          as date format '99/99/9999' no-undo.
define variable da-fimper-x          as date format '99/99/9999' no-undo.
define variable c-rodape             as character                no-undo.
define variable v_num_count          as integer                  no-undo.
define variable c-programa           as character format 'x(08)' no-undo.
define variable c-versao             as character format 'x(04)' no-undo.
define variable c-revisao            as character format '999'   no-undo.
define variable c-impressora         as char no-undo.
define variable c-layout             as char no-undo.
define variable v_num_pag            as integer init 1           no-undo.
define variable v_cod_sim            as char format 'x(03)'      no-undo.

define variable horaini              as integer initial 0        no-undo.
define variable horafin              as integer initial 0        no-undo.
define variable h-acomp              as handle                   no-undo.
define variable c-histor             as character format 'x(2000)' no-undo.

define new global shared variable c-dir-spool-servid-exec as char no-undo.
define new global shared variable i-num-ped-exec-rpw as int no-undo.
define new global shared variable v_num_ped_exec_corren as integer format '>>>>>9' no-undo.

/*    Vari veis espec¡ficas locais definidas    */
/* ============================================ */
define variable w-linha as character format 'x(132)' no-undo.
define variable w-data-aux as date init ? no-undo.

/* Vari veis a serem recuperados pela DWB - set list param */
/* ======================================================= */
define variable v_imp_parametro     as logical    no-undo.
define variable empresaIni         as character no-undo.
define variable empresaFim         as character no-undo.
define variable estabelecimentoIni as character no-undo.
define variable estabelecimentoFim as character no-undo.
define variable dataVencimentoIni  as date no-undo.
define variable dataVencimentoFim  as date no-undo.
define variable fornecedorIni      as integer no-undo.
define variable fornecedorFim      as integer no-undo.
define variable matrizIni          as integer no-undo.
define variable matrizFim          as integer no-undo.
define variable borderoIni         as integer no-undo.
define variable borderoFim         as integer no-undo.
define variable portadorIni        as character no-undo.
define variable portadorFim        as character no-undo.
define variable especieIni         as character no-undo.
define variable especieFim         as character no-undo.
define variable titulosVinculados  as integer no-undo.
define variable titulosBordero     as integer no-undo.
define variable notasRelacionadas  as logical   no-undo.

/* Defini‡Æo de Stream stream s_1.*/
/*================================*/
define stream s_1.

/*Define buffer*/
/*=============*/
def buffer b_ped_exec_style for emsfnd.ped_exec.
def buffer b_servid_exec_style for emsfnd.servid_exec.

define new shared variable v_rpt_s_1_lines as integer initial 66.
define new shared variable v_rpt_s_1_columns as integer initial 132.
define new shared variable v_rpt_s_1_bottom as integer initial 66.
define new shared variable v_rpt_s_1_page as integer.
define new shared variable v_rpt_s_1_name as character initial ''.

form
    with frame frm-titulo width 120 down stream-io.

form header
    fill('-', 117) format 'x(117)' skip
    c-empresa  format 'x(40)' c-tit_acr-relat at 47 format 'x(40)'
    'Folha:  ' at 105 page-number(s_1) format '>>>9' skip
    fill('-', 95) format 'x(95)' today format '99/99/9999'
    '-' string(time, 'HH:MM:SS') skip
    with no-labels no-box stream-io width 117 page-top frame fr-cabec.

form header 
    '------------------------------------------------------------------ Datasul Paranaense - EMS5 - csap001rp - V:5.06.001'
    with no-labels no-box stream-io width 117 page-bottom frame fr-rodape.

define variable desconto      like tit_ap.val_desconto      no-undo.
define variable juros         like tit_ap.val_juros         no-undo.
define variable multa         like tit_ap.val_multa_tit_ap  no-undo.
define variable saldo         like tit_ap.val_sdo_tit_ap    no-undo.

define variable descontoTotal like tit_ap.val_desconto      no-undo.
define variable jurosTotal    like tit_ap.val_juros         no-undo.
define variable multaTotal    like tit_ap.val_multa_tit_ap  no-undo.
define variable saldoTotal    like tit_ap.val_sdo_tit_ap    no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 23.25
         WIDTH              = 44.43.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

do {&try}:
    run startup.

    run setupParameters.

    case titulosBordero:
        when 1 then do:
            run searchTitulosComBordero.
            run printTitulosComBordero.
        end.
        when 2 then do:
            run searchTitulosSemBordero.
            run printTitulosSemBordero.
        end.
    end case.

    run printRodape.
end.

run dispose.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-accumulateLocalVariables) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE accumulateLocalVariables Procedure 
PROCEDURE accumulateLocalVariables :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if avail item_bord_ap then
            assign
                desconto = desconto + item_bord_ap.val_desc_tit_ap    
                juros    = juros    + item_bord_ap.val_juros       
                multa    = multa    + item_bord_ap.val_multa_tit_ap
                saldo    = saldo    + item_bord_ap.val_pagto 
                    + item_bord_ap.val_juros + item_bord_ap.val_multa_tit_ap - item_bord_ap.val_desc_tit_ap.
        else
            assign
                desconto = desconto + ttTitulo.val_desconto
                juros    = juros    + ttTitulo.val_juros
                multa    = multa    + ttTitulo.val_multa_tit_ap
                saldo    = saldo    + ttTitulo.val_sdo_tit_ap.
    end.
              
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-accumulateTotais) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE accumulateTotais Procedure 
PROCEDURE accumulateTotais :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if avail item_bord_ap then
            assign
                descontoTotal = descontoTotal + item_bord_ap.val_desc_tit_ap    
                jurosTotal    = jurosTotal    + item_bord_ap.val_juros       
                multaTotal    = multaTotal    + item_bord_ap.val_multa_tit_ap
                saldoTotal    = saldoTotal    + item_bord_ap.val_pagto
                    + item_bord_ap.val_juros + item_bord_ap.val_multa_tit_ap - item_bord_ap.val_desc_tit_ap.
        else
            assign
                descontoTotal = descontoTotal + ttTitulo.val_desconto
                jurosTotal    = jurosTotal    + ttTitulo.val_juros
                multaTotal    = multaTotal    + ttTitulo.val_multa_tit_ap
                saldoTotal    = saldoTotal    + ttTitulo.val_sdo_tit_ap.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearLocalVariables) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearLocalVariables Procedure 
PROCEDURE clearLocalVariables :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        assign
            desconto = 0
            juros    = 0
            multa    = 0
            saldo    = 0.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearTotais) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearTotais Procedure 
PROCEDURE clearTotais :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        assign
            descontoTotal = 0
            jurosTotal    = 0
            multaTotal    = 0
            saldoTotal    = 0.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-displayNotasRelacionadas) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE displayNotasRelacionadas Procedure 
PROCEDURE displayNotasRelacionadas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        for each ttNotas use-index pk_titulo
            where ttNotas.cod_estab       = ttTitulo.cod_estab      
              and ttNotas.cdn_fornecedor  = ttTitulo.cdn_fornecedor 
              and ttNotas.cod_espec_docto = ttTitulo.cod_espec_docto
              and ttNotas.cod_ser_docto   = ttTitulo.cod_ser_docto  
              and ttNotas.cod_tit_ap      = ttTitulo.cod_tit_ap     
              and ttNotas.cod_parcela     = ttTitulo.cod_parcela    
            no-lock:
            put stream s_1 unformatted skip substitute('    Nota Relacionada: '
                + 'estab &1, esp‚cie &2, s‚rie &3, t¡tulo &4, parcela &5, valor &6',
                ttNotas.estab, ttNotas.especie, ttNotas.serie, 
                ttNotas.titulo, ttNotas.parcela, ttNotas.valor).
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-displayTitulo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE displayTitulo Procedure 
PROCEDURE displayTitulo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        view stream s_1 frame fr-cabec.
        view stream s_1 frame fr-rodape.

        display stream s_1
                ttTitulo.cod_empresa        column-label 'Emp'         format 'x(3)'
                ttTitulo.dat_vencto_tit_ap  column-label 'Vencto'      format '99/99/99'
                ttTitulo.cod_estab          column-label 'Est'         format 'x(5)'
                ttTitulo.cdn_fornecedor     column-label 'Fornec'      format '>>>>>>>>9'
                ttTitulo.nom_abrev          column-label 'Nome Abrev'  format 'x(12)'
                ttTitulo.cod_espec_docto    column-label 'Esp'         format 'x(3)'
                ttTitulo.cod_ser_docto      column-label 'Ser'         format 'x(3)'
                ttTitulo.cod_tit_ap         column-label 'Titulo'      format 'x(10)'
                ttTitulo.cod_parcela        column-label 'Pa'          format 'x(2)'
                ttTitulo.vinculado          column-label 'Vin'         format 'Sim/NÆo'
                ttTitulo.val_desconto       column-label 'Vl Desconto' format '->>>,>>9.99'
                ttTitulo.val_juros          column-label 'Vl Juros'    format '->>>,>>9.99'
                ttTitulo.val_multa_tit_ap   column-label 'Vl Multa'    format '->>>,>>9.99'
                ttTitulo.val_sdo_tit_ap     column-label 'Vl Saldo'
                with frame frm-titulo WIDTH 320 .
            down with frame frm-titulo.

        if notasRelacionadas then
            run displayNotasRelacionadas.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-dispose) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dispose Procedure 
PROCEDURE dispose :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        output stream s_1 close.

/*         run pi-finalizar in h-acomp. */

        message 'Finalizando relat¢rio...' 
            in window janela.

        if session:set-wait-state('') then.

        if v_cod_dwb_output = 'Terminal' then
            run showReport.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateFornecedores) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateFornecedores Procedure 
PROCEDURE populateFornecedores :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        find first ttFornecedor
            where ttFornecedor.cdn_fornecedor = tit_ap.cdn_fornecedor
            no-lock no-error.

        if not avail ttFornecedor then do:
            create ttFornecedor.
            buffer-copy tit_ap 
                except val_desconto val_juros val_multa_tit_ap val_sdo_tit_ap 
                to ttFornecedor.
        end.

        if avail fornecedor then
            assign
                ttFornecedor.nom_abrev = fornecedor.nom_abrev.

        if avail item_bord_ap then
            assign
                ttFornecedor.val_desconto     = ttFornecedor.val_desconto     + item_bord_ap.val_desc_tit_ap    
                ttFornecedor.val_juros        = ttFornecedor.val_juros        + item_bord_ap.val_juros       
                ttFornecedor.val_multa_tit_ap = ttFornecedor.val_multa_tit_ap + item_bord_ap.val_multa_tit_ap
                ttFornecedor.val_sdo_tit_ap   = ttFornecedor.val_sdo_tit_ap   + item_bord_ap.val_pagto
                    + item_bord_ap.val_juros + item_bord_ap.val_multa_tit_ap - item_bord_ap.val_desc_tit_ap.
        else
            assign 
                ttFornecedor.val_desconto     = ttFornecedor.val_desconto     + tit_ap.val_desconto    
                ttFornecedor.val_juros        = ttFornecedor.val_juros        + tit_ap.val_juros       
                ttFornecedor.val_multa_tit_ap = ttFornecedor.val_multa_tit_ap + tit_ap.val_multa_tit_ap
                ttFornecedor.val_sdo_tit_ap   = ttFornecedor.val_sdo_tit_ap   + tit_ap.val_sdo_tit_ap.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateNotasRelacionadas) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateNotasRelacionadas Procedure 
PROCEDURE populateNotasRelacionadas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        find first movto_tit_ap use-index mvtttp_id
            where movto_tit_ap.cod_estab = tit_ap.cod_estab
              and movto_tit_ap.num_id_tit_ap = tit_ap.num_id_tit_ap
              and movto_tit_ap.num_id_movto_tit_ap = movto_tit_ap.num_id_movto_tit_ap
              and movto_tit_ap.ind_trans_ap_abrev = 'SBND'
            no-lock no-error.

        if avail movto_tit_ap then do:
            for each bMovimento fields(cod_estab num_id_tit_ap val_movto_ap)
                use-index mvtttp_refer
                where bMovimento.cod_estab = bMovimento.cod_estab
                  and bMovimento.cod_refer = movto_tit_ap.cod_refer
                  and bMovimento.ind_trans_ap_abrev = 'BXSB'
                no-lock
                ,
                each bTitulo fields(cod_estab cdn_fornecedor cod_espec_docto cod_ser_docto cod_tit_ap
                                    cod_parcela val_sdo_tit_ap)
                use-index titap_token
                where bTitulo.cod_estab = bMovimento.cod_estab
                  and bTitulo.num_id_tit_ap = bMovimento.num_id_tit_ap
                no-lock:
                create ttNotas.
                buffer-copy tit_ap
                    using cod_estab cdn_fornecedor cod_espec_docto cod_ser_docto cod_tit_ap cod_parcela
                    to ttNotas
                    assign
                        ttNotas.estab   = bTitulo.cod_estab
                        ttNotas.especie = bTitulo.cod_espec_docto
                        ttNotas.serie   = bTitulo.cod_ser_docto
                        ttNotas.titulo  = bTitulo.cod_tit_ap
                        ttNotas.parcela = bTitulo.cod_parcela
                        ttNotas.valor   = bMovimento.val_movto_ap.
            end.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateTempTables) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateTempTables Procedure 
PROCEDURE populateTempTables :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        create ttTitulo.
        buffer-copy tit_ap 
            using cod_empresa dat_vencto_tit_ap cod_estab cdn_fornecedor cod_espec_docto 
                  cod_ser_docto cod_tit_ap cod_parcela cb4_tit_ap_bco_cobdor num_id_tit_ap
            to ttTitulo
            assign
                ttTitulo.vinculado = ( trim(tit_ap.cb4_tit_ap_bco_cobdor) <> '' ).

        if avail item_bord_ap then
            assign 
                ttTitulo.cod_estab_bord   = item_bord_ap.cod_estab_bord
                ttTitulo.cod_portador     = item_bord_ap.cod_portador  
                ttTitulo.num_bord_ap      = item_bord_ap.num_bord_ap
                ttTitulo.val_desconto     = ttTitulo.val_desconto     + item_bord_ap.val_desc_tit_ap    
                ttTitulo.val_juros        = ttTitulo.val_juros        + item_bord_ap.val_juros       
                ttTitulo.val_multa_tit_ap = ttTitulo.val_multa_tit_ap + item_bord_ap.val_multa_tit_ap
                ttTitulo.val_sdo_tit_ap   = ttTitulo.val_sdo_tit_ap   + item_bord_ap.val_pagto
                    + item_bord_ap.val_juros + item_bord_ap.val_multa_tit_ap - item_bord_ap.val_desc_tit_ap.
        else
            assign 
                ttTitulo.val_desconto     = ttTitulo.val_desconto     + tit_ap.val_desconto    
                ttTitulo.val_juros        = ttTitulo.val_juros        + tit_ap.val_juros       
                ttTitulo.val_multa_tit_ap = ttTitulo.val_multa_tit_ap + tit_ap.val_multa_tit_ap
                ttTitulo.val_sdo_tit_ap   = ttTitulo.val_sdo_tit_ap   + tit_ap.val_sdo_tit_ap.

        if avail item_bord_ap then

        find first fornecedor
            where fornecedor.cdn_fornecedor = tit_ap.cdn_fornecedor
            no-lock no-error.

        if avail fornecedor then
            assign
                ttTitulo.nom_abrev = fornecedor.nom_abrev.

        run populateNotasRelacionadas.
        run populateFornecedores.  
        run populateVencimentos.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateVencimentos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateVencimentos Procedure 
PROCEDURE populateVencimentos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        find first ttVencimento
            where ttVencimento.dat_vencto_tit_ap = tit_ap.dat_vencto_tit_ap
            no-lock no-error.

        if not avail ttVencimento then do:
            create ttVencimento.
             buffer-copy tit_ap 
                except val_desconto val_juros val_multa_tit_ap val_sdo_tit_ap 
                to ttVencimento.
        end.

        if avail item_bord_ap then
            assign
                ttVencimento.val_desconto     = ttVencimento.val_desconto     + item_bord_ap.val_desc_tit_ap    
                ttVencimento.val_juros        = ttVencimento.val_juros        + item_bord_ap.val_juros       
                ttVencimento.val_multa_tit_ap = ttVencimento.val_multa_tit_ap + item_bord_ap.val_multa_tit_ap
                ttVencimento.val_sdo_tit_ap   = ttVencimento.val_sdo_tit_ap   + item_bord_ap.val_pagto
                    + item_bord_ap.val_juros + item_bord_ap.val_multa_tit_ap - item_bord_ap.val_desc_tit_ap.
        else
            assign 
                ttVencimento.val_desconto     = ttVencimento.val_desconto     + tit_ap.val_desconto    
                ttVencimento.val_juros        = ttVencimento.val_juros        + tit_ap.val_juros       
                ttVencimento.val_multa_tit_ap = ttVencimento.val_multa_tit_ap + tit_ap.val_multa_tit_ap
                ttVencimento.val_sdo_tit_ap   = ttVencimento.val_sdo_tit_ap   + tit_ap.val_sdo_tit_ap.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-printRodape) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE printRodape Procedure 
PROCEDURE printRodape :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:                          
        put stream s_1 unformatted skip(2) 'Totais por Fornecedor                        '
            + '                     Vl Desconto    Vl Juros    Vl Multa        Vl Saldo' 
            skip.
        put stream s_1 unformatted '-----------------------------------------------------'
            + '----------------------------------------------------------------'
            skip.
        for each ttFornecedor
            no-lock
            by ttFornecedor.cdn_fornecedor:
            put stream s_1 unformatted 
                ttFornecedor.cdn_fornecedor    at  18 format '>>>>>>>>9'
                ttFornecedor.nom_abrev         at  28 format 'x(12)'
                ttFornecedor.val_desconto      at  67 format '->>>,>>9.99'
                ttFornecedor.val_juros         at  79 format '->>>,>>9.99'
                ttFornecedor.val_multa_tit_ap  at  91 format '->>>,>>9.99'
                ttFornecedor.val_sdo_tit_ap    at 103 format '->>>,>>>,>>9.99' 
                skip.
        end.

        put stream s_1 unformatted skip(2) 'Totais por Vencimento                        '
            + '                     Vl Desconto    Vl Juros    Vl Multa        Vl Saldo' 
            skip.
        put stream s_1 unformatted '-----------------------------------------------------'
            + '----------------------------------------------------------------'
            skip.
        for each ttVencimento
            no-lock
            by ttVencimento.dat_vencto_tit_ap:
            put stream s_1 unformatted 
                ttVencimento.dat_vencto_tit_ap at   5 format '99/99/9999'
                ttVencimento.val_desconto      at  67 format '->>>,>>9.99'
                ttVencimento.val_juros         at  79 format '->>>,>>9.99'
                ttVencimento.val_multa_tit_ap  at  91 format '->>>,>>9.99'
                ttVencimento.val_sdo_tit_ap    at 103 format '->>>,>>>,>>9.99' 
                skip.
        end.

        if v_imp_parametro then do:
            page stream s_1.
            put stream s_1 unformatted
                    skip(2)
                    'Sele‡Æo'               at  2
                        'In¡cio'            to 42
                        'Fim'               to 73 skip
                    '-------------------------------------------------------------------------' skip
                    'Empresa:'              at  2
                        empresaIni          to 42
                        empresaFim          to 73 skip
                    'Estabel:'              at  2
                        estabelecimentoIni  to 42
                        estabelecimentoFim  to 73 skip
                    'Data Vencimento:'      at  2
                        dataVencimentoIni   to 42
                        dataVencimentoFim   to 73 skip
                    'C¢digo Fornecedor:'    at  2
                        fornecedorIni       to 42
                        fornecedorFim       to 73 skip
                    'C¢digo Matriz:'        at  2
                        matrizini           to 42
                        matrizFim           to 73 skip
                    'Border“'               at  2
                        borderoIni          to 42
                        borderoFim          to 73 skip
                    'Portador'              at  2
                        portadorIni         to 42
                        portadorFim         to 73 skip
                    'Esp‚cie'               at  2
                        especieIni          to 42
                        especieFim          to 73 skip
                    'Titulos Vinculados'    to  2
                        titulosVinculados   to 42 skip
                    'Titulos Bordero'       to  2
                        titulosBordero      to 42 skip
                    'Notas Relacionadas'    to  2
                        notasRelacionadas   to 42.
        end.

        run showTempo.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-printTitulosComBordero) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE printTitulosComBordero Procedure 
PROCEDURE printTitulosComBordero :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable doNext as logical   no-undo.

    do {&throws}:
        run clearTotais.

        for each ttTitulo
            no-lock
            break by ttTitulo.cod_estab_bord
                  by ttTitulo.cod_portador
                  by ttTitulo.num_bord_ap:

            if first-of(ttTitulo.num_bord_ap) then do:
                run putCabecalhoTitulosComBordero.
                run clearLocalVariables.
            end.
    
/*             run pi-acompanhar in h-acomp (input 'Imprimindo: ' + ttTitulo.cod_tit_ap */
/*                     + ' / ' + ttTitulo.cod_parcela).                                 */

            message 'Imprimindo: ' + ttTitulo.cod_tit_ap + ' / ' + ttTitulo.cod_parcela
                in window janela.

            run accumulateTotais.
            run accumulateLocalVariables.

            run displayTitulo.

            if last-of(ttTitulo.num_bord_ap) then do:
                run putLocalVariables.
                put stream s_1 unformatted skip(1).
            end.
        end.
    
        run putTotais.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-printTitulosSemBordero) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE printTitulosSemBordero Procedure 
PROCEDURE printTitulosSemBordero :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable doNext as logical   no-undo.

    do {&throws}:
        run clearTotais.

        for each ttTitulo
            no-lock
            break by ttTitulo.dat_vencto_tit_ap
                  by ttTitulo.cdn_fornecedor:
    
/*             run pi-acompanhar in h-acomp (input 'Imprimindo: ' + ttTitulo.cod_tit_ap */
/*                     + ' / ' + ttTitulo.cod_parcela).                                 */

            message 'Imprimindo: ' + ttTitulo.cod_tit_ap + ' / ' + ttTitulo.cod_parcela
                in window janela.

            run accumulateTotais.

            run displayTitulo.
        end.
    
        run putTotais.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-putCabecalhoTitulosComBordero) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE putCabecalhoTitulosComBordero Procedure 
PROCEDURE putCabecalhoTitulosComBordero :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        view stream s_1 frame fr-cabec.
        view stream s_1 frame fr-rodape.

        put stream s_1 unformatted skip(1).

        put stream s_1 unformatted '-----------------------------------------------------'
            + '----------------------------------------------------------------'
            skip.

        put stream s_1 unformatted  
            substitute('Border“: estab &1, portador &2, n£mero &3',
            ttTitulo.cod_estab_bord, ttTitulo.cod_portador, 
            ttTitulo.num_bord_ap) 
            skip.

        put stream s_1 unformatted '-----------------------------------------------------'
            + '----------------------------------------------------------------'
            skip.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-putLocalVariables) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE putLocalVariables Procedure 
PROCEDURE putLocalVariables :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        underline stream s_1 ttTitulo.val_desconto      with frame frm-titulo.
        underline stream s_1 ttTitulo.val_juros         with frame frm-titulo.
        underline stream s_1 ttTitulo.val_multa_tit_ap  with frame frm-titulo.
        underline stream s_1 ttTitulo.val_sdo_tit_ap    with frame frm-titulo.

        put stream s_1
            'TOTAL ....:' at  50
            desconto      at  67 format '->>>,>>9.99'    
            juros         at  79 format '->>>,>>9.99'    
            multa         at  91 format '->>>,>>9.99'    
            saldo         at 103 format '->>>,>>>,>>9.99'.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-putTotais) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE putTotais Procedure 
PROCEDURE putTotais :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        underline stream s_1 ttTitulo.val_desconto      with frame frm-titulo.
        underline stream s_1 ttTitulo.val_juros         with frame frm-titulo.
        underline stream s_1 ttTitulo.val_multa_tit_ap  with frame frm-titulo.
        underline stream s_1 ttTitulo.val_sdo_tit_ap    with frame frm-titulo.

        put stream s_1
            'TOTAL GERAL....:' at  50
            descontoTotal      at  67 format '->>>,>>9.99'    
            jurosTotal         at  79 format '->>>,>>9.99'    
            multaTotal         at  91 format '->>>,>>9.99'    
            saldoTotal         at 103 format '->>>,>>>,>>9.99'.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-searchTitulosComBordero) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE searchTitulosComBordero Procedure 
PROCEDURE searchTitulosComBordero :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable doNext as logical   no-undo.
      
    do {&throws}:
        for each bord_ap fields(cod_estab_bord cod_portador num_bord_ap)
            use-index brdrp_id
            where bord_ap.cod_estab_bord >= estabelecimentoIni
              and bord_ap.cod_estab_bord <= estabelecimentoFim
              and bord_ap.cod_portador   >= portadorIni
              and bord_ap.cod_portador   <= portadorFim
              and bord_ap.num_bord_ap    >= borderoIni
              and bord_ap.num_bord_ap    <= borderoFim
              and bord_ap.cod_empresa    >= empresaIni
              and bord_ap.cod_empresa    <= empresaFim
              and bord_ap.dat_transacao  >= dataVencimentoIni
              and bord_ap.dat_transacao  <= dataVencimentoFim
            no-lock
            ,
            each item_bord_ap fields(cod_estab cdn_fornecedor cod_espec_docto cod_ser_docto cod_tit_ap
                                     cod_parcela cod_estab_bord cod_portador num_bord_ap num_seq_bord
                                     cod_empresa val_desc_tit_ap val_juros val_multa_tit_ap val_pagto)
            use-index itmbrdp_id
            where item_bord_ap.cod_estab_bord  = bord_ap.cod_estab_bord
              and item_bord_ap.cod_portador    = bord_ap.cod_portador
              and item_bord_ap.num_bord_ap     = bord_ap.num_bord_ap
              and item_bord_ap.num_seq_bord    = item_bord_ap.num_seq_bord
            no-lock
            ,
            each tit_ap fields(cod_empresa dat_vencto_tit_ap cod_estab cdn_fornecedor cod_espec_docto
                               cod_ser_docto cod_tit_ap cod_parcela cb4_tit_ap_bco_cobdor val_desconto
                               val_juros val_multa_tit_ap val_sdo_tit_ap num_id_tit_ap)
            use-index titap_id
            where tit_ap.cod_estab       = item_bord_ap.cod_estab
              and tit_ap.cdn_fornecedor  = item_bord_ap.cdn_fornecedor
              and tit_ap.cod_espec_docto = item_bord_ap.cod_espec_docto
              and tit_ap.cod_ser_docto   = item_bord_ap.cod_ser_docto
              and tit_ap.cod_tit_ap      = item_bord_ap.cod_tit_ap
              and tit_ap.cod_parcela     = item_bord_ap.cod_parcela
              and tit_ap.cdn_fornecedor  >= fornecedorIni
              and tit_ap.cdn_fornecedor  <= fornecedorFim
              and tit_ap.cod_espec_docto >= especieIni
              and tit_ap.cod_espec_docto <= especieFim
              and tit_ap.val_sdo_tit_ap   > 0
            no-lock:

            run verifyMatriz(output doNext).
            if doNext then
                next.

            run verifyVinculados(output doNext).
            if doNext then
                next.
            /*Alterado para nao ignorar */
            if can-find(first movto_tit_ap
                        where movto_tit_ap.cod_estab = tit_ap.cod_estab
                          and movto_tit_ap.num_id_tit_ap = tit_ap.num_id_tit_ap
                          and movto_tit_ap.num_id_movto_tit_ap = movto_tit_ap.num_id_movto_tit_ap
                          and movto_tit_ap.ind_trans_ap begins 'Estorno de T¡tulo'
                        no-lock) then
                next. 

/*             run pi-acompanhar in h-acomp (input 'Varrendo Titulos: ' + tit_ap.cod_tit_ap */
/*                     + ' / ' + tit_ap.cod_parcela).                                       */

            message 'Varrendo Titulos: ' + tit_ap.cod_tit_ap + ' / ' + tit_ap.cod_parcela
                in window janela.

            run populateTempTables.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-searchTitulosSemBordero) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE searchTitulosSemBordero Procedure 
PROCEDURE searchTitulosSemBordero :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable doNext as logical   no-undo.

    do {&throws}:
        for each tit_ap fields(cod_empresa dat_vencto_tit_ap cod_estab cdn_fornecedor cod_espec_docto 
                               cod_ser_docto cod_tit_ap cod_parcela cb4_tit_ap_bco_cobdor val_desconto 
                               val_juros val_multa_tit_ap val_sdo_tit_ap num_id_tit_ap)
            use-index titap_fornec_financ
            where tit_ap.cod_empresa     >= empresaIni
              and tit_ap.cod_empresa     <= empresaFim
              and tit_ap.cdn_fornecedor  >= fornecedorIni
              and tit_ap.cdn_fornecedor  <= fornecedorFim
              and tit_ap.dat_prev_pagto  >= dataVencimentoIni
              and tit_ap.dat_prev_pagto  <= dataVencimentoFim
              and tit_ap.cod_estab       >= estabelecimentoIni
              and tit_ap.cod_estab       <= estabelecimentoFim
              and tit_ap.cod_espec_docto >= especieIni
              and tit_ap.cod_espec_docto <= especieFim
              and tit_ap.val_sdo_tit_ap   > 0
            no-lock:

            run verifyMatriz(output doNext).
            if doNext then
                next.

            run verifyBordero(output doNext).
            if doNext then
                next.
                               
            run verifyVinculados(output doNext).
            if doNext then
                next.

            if can-find(first movto_tit_ap
                        where movto_tit_ap.cod_estab = tit_ap.cod_estab
                          and movto_tit_ap.num_id_tit_ap = tit_ap.num_id_tit_ap
                          and movto_tit_ap.num_id_movto_tit_ap = movto_tit_ap.num_id_movto_tit_ap
                          and movto_tit_ap.ind_trans_ap begins 'Estorno de T¡tulo'
                        no-lock) then
                next.
    
/*             run pi-acompanhar in h-acomp (input 'Varrendo Titulos: ' + tit_ap.cod_tit_ap */
/*                     + ' / ' + tit_ap.cod_parcela).                                       */

            message 'Varrendo Titulos: ' + tit_ap.cod_tit_ap + ' / ' + tit_ap.cod_parcela 
                in window janela.

            run populateTempTables.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setupParameters) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setupParameters Procedure 
PROCEDURE setupParameters :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        assign
            c-empresa  = 'Datasul Paranaense'
            c-sistema  = 'EMS5'
            c-programa = 'csap001rp'
            c-versao   = '5.06.001'.

        assign
            ca-rodape = c-empresa 
                    + ' - ' 
                    + c-sistema 
                    + ' - '
                    + c-programa 
                    + ' - V:' 
                    + c-versao.

        assign 
            c-tit_acr-relat = 'APB - Titulos em Aberto'
            ca-rodape       = fill('-', 250 - length(ca-rodape)) + ca-rodape.
        
        find first emsuni.empresa 
            where empresa.cod_empresa = v_cod_empres_usuar 
            no-lock no-error.
        
        run showTempo.
        
        if avail empresa then
            assign 
                c-empresa = empresa.nom_razao_social.
        else
            assign 
                c-empresa = ''.
        
        if v_cod_dwb_user = '' then
            assign 
                v_cod_dwb_user = v_cod_usuar_corren.
        
        if v_cod_dwb_user begins 'es_' then
            assign 
                v_cod_dwb_user = entry(2,v_cod_dwb_user, '_').
        
        if v_num_ped_exec_corren > 0 then do:
            find emsfnd.ped_exec_param 
                where emsfnd.ped_exec_param.num_ped_exec = v_num_ped_exec_corren 
                no-lock no-error.
        
                run showTempo.
        
                assign 
                    empresaIni         = entry(1, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10))
                    empresaFim         = entry(2, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10))
                    estabelecimentoIni = entry(3, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10))
                    estabelecimentoFim = entry(4, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10))
                    dataVencimentoIni  = date(entry(5, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    dataVencimentoFim  = date(entry(6, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    fornecedorIni      = integer(entry(7, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    fornecedorFim      = integer(entry(8, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    matrizIni          = integer(entry(9, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    matrizFim          = integer(entry(10, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    borderoIni         = integer(entry(11, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    borderoFim         = integer(entry(12, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    portadorIni        = entry(13, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10))
                    portadorFim        = entry(14, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10))
                    especieIni         = entry(15, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10))
                    especieFim         = entry(16, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10))
                    titulosVinculados  = integer(entry(17, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    titulosBordero     = integer(entry(18, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    notasRelacionadas  = logical(entry(19, emsfnd.ped_exec_param.cod_dwb_parameters, chr(10)))
                    v_imp_parametro    = emsfnd.ped_exec_param.log_dwb_print_parameters
                    arquivo            = emsfnd.ped_exec_param.cod_dwb_file
                    v_cod_dwb_output   = emsfnd.ped_exec_param.cod_dwb_output
                    c-impressora       = emsfnd.ped_exec_param.nom_dwb_printer
                    c-layout           = emsfnd.ped_exec_param.cod_dwb_print_layout
                    v_cod_dwb_user     = emsfnd.ped_exec_param.cod_usuar.
        end.
        else do:
            find emsfnd.dwb_set_list_param
                where emsfnd.dwb_set_list_param.cod_dwb_program = 'rpt_titulo_abertos_apb_nissei'
                  and emsfnd.dwb_set_list_param.cod_dwb_user    = v_cod_dwb_user
                no-lock no-error.
        
            run showTempo.
        
            if avail emsfnd.dwb_set_list_param then do:
                assign 
                    empresaIni         = entry(1, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                    empresaFim         = entry(2, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                    estabelecimentoIni = entry(3, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                    estabelecimentoFim = entry(4, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                    dataVencimentoIni  = date(entry(5, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    dataVencimentoFim  = date(entry(6, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    fornecedorIni      = integer(entry(7, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    fornecedorFim      = integer(entry(8, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    matrizIni          = integer(entry(9, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    matrizFim          = integer(entry(10, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    borderoIni         = integer(entry(11, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    borderoFim         = integer(entry(12, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    portadorIni        = entry(13, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                    portadorFim        = entry(14, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                    especieIni         = entry(15, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                    especieFim         = entry(16, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10))
                    titulosVinculados  = integer(entry(17, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    titulosBordero     = integer(entry(18, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    notasRelacionadas  = logical(entry(19, emsfnd.dwb_set_list_param.cod_dwb_parameters, chr(10)))
                    v_imp_parametro    = emsfnd.dwb_set_list_param.log_dwb_print_parameters
                    arquivo            = emsfnd.dwb_set_list_param.cod_dwb_file
                    v_cod_dwb_output   = emsfnd.dwb_set_list_param.cod_dwb_output
                    c-impressora       = emsfnd.dwb_set_list_param.nom_dwb_printer
                    c-layout           = emsfnd.dwb_set_list_param.cod_dwb_print_layout
                    v_cod_dwb_user     = emsfnd.dwb_set_list_param.cod_dwb_user.
            end.
        end.
        
        run showTempo.
        
        do:  /* seta a saida da impressao */
            case v_cod_dwb_output:
                when 'Terminal' then do:
                    assign 
                        arquivo = session:temp-directory + 'csap001rp.txt'.
    
                    output stream s_1 to value(arquivo) 
                        paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
                end.
                when 'Impressora' then do:
                    find emsfnd.imprsor_usuar use-index imprsrsr_id
                        where emsfnd.imprsor_usuar.nom_impressora = c-impressora
                            and emsfnd.imprsor_usuar.cod_usuario     = v_cod_dwb_user
                        no-lock no-error.
        
                    find first emsfnd.layout_impres 
                        where emsfnd.layout_impres.nom_impressora    = c-impressora
                          and emsfnd.layout_impres.cod_layout_impres = c-layout
                        no-lock no-error.
        
                    assign 
                        v_rpt_s_1_bottom = emsfnd.layout_impres.num_lin_pag
                        v_rpt_s_1_lines = emsfnd.layout_impres.num_lin_pag.
        
                    run showTempo.
        
                    if opsys = 'UNIX' then do:
                        if v_num_ped_exec_corren <> 0 then do:
                            find emsfnd.ped_exec
                                where emsfnd.ped_exec.num_ped_exec = v_num_ped_exec_corren 
                                no-lock no-error.
    
                            if avail emsfnd.ped_exec then do:
                                find emsfnd.servid_exec_imprsor 
                                    where emsfnd.servid_exec_imprsor.cod_servid_exec = emsfnd.ped_exec.cod_servid_exec
                                      and emsfnd.servid_exec_imprsor.nom_impressora  = c-impressora
                                    no-lock no-error.
    
                                if avail servid_exec_imprsor then
                                    output stream s_1 through value(servid_exec_imprsor.nom_disposit_so)
                                           paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
                               else
                                    output stream s_1 through value(imprsor_usuar.nom_disposit_so)
                                        paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
                           end.
                        end.
                        else
                            output stream s_1 through value(imprsor_usuar.nom_disposit_so)
                                paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
                    end.
                    else
                        output stream s_1 to value(imprsor_usuar.nom_disposit_so)
                               paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
        
                    for each emsfnd.configur_layout_impres
                        where emsfnd.configur_layout_impres.num_id_layout_impres = emsfnd.layout_impres.num_id_layout_impres
                        no-lock
                        by emsfnd.configur_layout_impres.num_ord_funcao_imprsor:
        
                        find emsfnd.configur_tip_imprsor 
                            where emsfnd.configur_tip_imprsor.cod_tip_imprsor = layout_impres.cod_tip_imprsor
                              and emsfnd.configur_tip_imprsor.cod_funcao_imprsor = configur_layout_impres.cod_funcao_imprsor
                              and emsfnd.configur_tip_imprsor.cod_opc_funcao_imprsor = configur_layout_impres.cod_opc_funcao_imprsor
                            no-lock no-error.
        
                        put stream s_1 control configur_tip_imprsor.cod_comando_configur.
                        run showTempo.
                    end.
                end.
                when 'Arquivo' /*l_file*/  then do:
                    output stream s_1 to value(arquivo)
                           paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
                end.
            end.
        end.
        
        run showTempo.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-showReport) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE showReport Procedure 
PROCEDURE showReport :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable keyValue as character no-undo.
    
    get-key-value section 'EMS' key 'Show-Report-Program' value keyValue.

    if keyValue = '' or 
        keyValue = ? then do:

        assign 
            keyValue = 'notepad.exe'.

        put-key-value section 'EMS' key 'Show-Report-Program' value keyValue no-error.
    end.
    
    os-command no-wait value('notepad ' + arquivo).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-showTempo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE showTempo Procedure 
PROCEDURE showTempo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        assign 
            horafin = time - horaini.

/*         run pi-acompanhar IN h-acomp('Tempo de Execu‡Æo: ' + string(horafin,'HH:MM:SS')). */

/*         message 'Tempo de Execu‡Æo: ' + string(horafin,'HH:MM:SS'). */
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-startup) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup Procedure 
PROCEDURE startup :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if session:set-wait-state('general') then.

/*         run utp/ut-acomp.p persistent set h-acomp.   */
/*         run pi-inicializar in h-acomp('Gerando...'). */
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyBordero) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyBordero Procedure 
PROCEDURE verifyBordero :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter doNext as logical initial false no-undo.

    do {&throws}:
        find first item_bord_ap use-index itmbrdp_tit_ap
            where item_bord_ap.cod_estab        = tit_ap.cod_estab      
              and item_bord_ap.cod_espec_docto  = tit_ap.cod_espec_docto
              and item_bord_ap.cod_ser_docto    = tit_ap.cod_ser_docto  
              and item_bord_ap.cdn_fornecedor   = tit_ap.cdn_fornecedor 
              and item_bord_ap.cod_tit_ap       = tit_ap.cod_tit_ap     
              and item_bord_ap.cod_parcela      = tit_ap.cod_parcela 
            no-lock no-error.

        if avail item_bord_ap then
            assign
                doNext = true.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyMatriz) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyMatriz Procedure 
PROCEDURE verifyMatriz :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter doNext as logical initial false no-undo.

    do {&throws}:
        find first fornecedor
            where fornecedor.cdn_fornecedor = tit_ap.cdn_fornecedor
            no-lock no-error.

        if avail fornecedor then do:
            find first pessoa_jurid
                where pessoa_jurid.num_pessoa_jurid = fornecedor.num_pessoa
                no-lock no-error.

            if avail pessoa_jurid then do:
                find first fornecedor
                    where fornecedor.num_pessoa = pessoa_jurid.num_pessoa_jurid_matriz
                    no-lock no-error.
                IF AVAIL fornecedor AND
                   (fornecedor.cdn_fornecedor < matrizIni  OR
                    fornecedor.cdn_fornecedor > matrizFim) THEN
                    ASSIGN doNext = TRUE.
            end.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-verifyVinculados) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verifyVinculados Procedure 
PROCEDURE verifyVinculados :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter doNext as logical initial false no-undo.

    do {&throws}:
        case titulosVinculados:
            when 1 then
                if trim(tit_ap.cb4_tit_ap_bco_cobdor) = '' then
                    assign
                        doNext = true.
            when 2 then
                if trim(tit_ap.cb4_tit_ap_bco_cobdor) <> '' then
                    assign
                        doNext = true.
        end case.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

