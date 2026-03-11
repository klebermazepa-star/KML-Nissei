/*
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         csbi001rpf
&SCOPED-DEFINE program_definition   "CSBI001 - APL"
&SCOPED-DEFINE program_version      1.00.00.001

{include/i-prgvrs.i {&program_name} {&program_version} }

{cstp/csbi001tt.i}

/*Parameters Definitions*/
DEFINE INPUT PARAMETER raw-param AS RAW NO-UNDO .
DEFINE INPUT PARAMETER TABLE FOR tt-raw-digita .

CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.

/* ***************************  MAIN BLOCK  ************************** */
DEF VAR h-acomp AS HANDLE NO-UNDO.
DEF VAR i-acomp AS INT NO-UNDO .
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

DEF BUFFER empresa FOR emsuni.empresa .

RUN pi-acompanhar IN h-acomp(INPUT "Eliminando...") .
DELETE FROM cst_ctbl_bi
    WHERE cst_ctbl_bi.cod_modul = "APL"
    AND   cst_ctbl_bi.dt_trans >= tt-param.dt_trans_ini
    AND   cst_ctbl_bi.dt_trans <= tt-param.dt_trans_fim
    AND   cst_ctbl_bi.cod_estab >= tt-param.cod_estab_ini
    AND   cst_ctbl_bi.cod_estab <= tt-param.cod_estab_fim
    AND   cst_ctbl_bi.cod_cta_ctbl >= tt-param.cod_cta_ctbl_ini
    AND   cst_ctbl_bi.cod_cta_ctbl <= tt-param.cod_cta_ctbl_fim
    .

ASSIGN i-acomp = 0 .
FOR FIRST plano_cta_ctbl NO-LOCK
    WHERE plano_cta_ctbl.cod_plano_cta_ctbl = "PADRAO" , 
    EACH empresa NO-LOCK
    :
    FOR EACH aprop_ctbl_apl NO-LOCK USE-INDEX aprpctbe_demo_ctbl
        WHERE aprop_ctbl_apl.cod_empresa = empresa.cod_empresa
        AND   aprop_ctbl_apl.dat_transacao >= tt-param.dt_trans_ini
        AND   aprop_ctbl_apl.dat_transacao <= tt-param.dt_trans_fim
        AND   aprop_ctbl_apl.cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl
        AND   aprop_ctbl_apl.cod_cta_ctbl >= tt-param.cod_cta_ctbl_ini
        AND   aprop_ctbl_apl.cod_cta_ctbl <= tt-param.cod_cta_ctbl_fim 
        AND   aprop_ctbl_apl.cod_estab_aprop_ctbl >= tt-param.cod_estab_ini
        AND   aprop_ctbl_apl.cod_estab_aprop_ctbl <= tt-param.cod_estab_fim ,
        FIRST movto_operac_financ FIELDS(num_id_movto_operac_financ des_histor_movto_apl) 
        NO-LOCK 
        WHERE movto_operac_financ.num_id_movto_operac_financ = aprop_ctbl_apl.num_id_movto_operac_financ
        :
        ASSIGN i-acomp = i-acomp + 1 .
        IF i-acomp MOD 100 = 0 THEN DO:
            RUN pi-acompanhar IN h-acomp(INPUT "APL: " + STRING(i-acomp) ) .
        END.
        /**/
        CREATE cst_ctbl_bi . ASSIGN
            cst_ctbl_bi.dt_trans        = aprop_ctbl_apl.dat_transacao
            cst_ctbl_bi.cod_estab       = aprop_ctbl_apl.cod_estab_aprop_ctbl
            cst_ctbl_bi.cod_cta_ctbl    = aprop_ctbl_apl.cod_cta_ctbl
            cst_ctbl_bi.cod_ccusto      = ""
            cst_ctbl_bi.ind_natur       = aprop_ctbl_apl.ind_natur_lancto_ctbl
            cst_ctbl_bi.val_lancto      = aprop_ctbl_apl.val_aprop_ctbl
            cst_ctbl_bi.cod_modul       = "APL"
            cst_ctbl_bi.des_historico   = SUBSTRING(movto_operac_financ.des_histor_movto_apl , 1 , 100)
            cst_ctbl_bi.cdn_emitente    = 0
            cst_ctbl_bi.cod_item        = ""
            .
    END.
END.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .


