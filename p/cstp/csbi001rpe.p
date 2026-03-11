/*
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         csbi001rpe
&SCOPED-DEFINE program_definition   "CSBI001 - PAT" /* Ativo fixo */
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
    WHERE cst_ctbl_bi.cod_modul = "PAT"
    AND   cst_ctbl_bi.dt_trans >= tt-param.dt_trans_ini
    AND   cst_ctbl_bi.dt_trans <= tt-param.dt_trans_fim
    AND   cst_ctbl_bi.cod_estab >= tt-param.cod_estab_ini
    AND   cst_ctbl_bi.cod_estab <= tt-param.cod_estab_fim
    AND   cst_ctbl_bi.cod_cta_ctbl >= tt-param.cod_cta_ctbl_ini
    AND   cst_ctbl_bi.cod_cta_ctbl <= tt-param.cod_cta_ctbl_fim
    .

ASSIGN i-acomp = 0 .
FOR EACH empresa NO-LOCK
    :
    FOR EACH bem_pat NO-LOCK
        WHERE bem_pat.cod_empresa = empresa.cod_empresa
        AND   bem_pat.cod_estab >= tt-param.cod_estab_ini
        AND   bem_pat.cod_estab <= tt-param.cod_estab_fim
        :
        RUN pi-tratar-pat(INPUT 0) .
        FOR EACH incorp_bem_pat NO-LOCK
            WHERE incorp_bem_pat.num_id_bem_pat = bem_pat.num_id_bem_pat
            AND   incorp_bem_pat.num_seq_incorp_bem_pat <> 0
            :
            RUN pi-tratar-pat(INPUT incorp_bem_pat.num_seq_incorp_bem_pat) .
        END.
    END.
END.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .

/* ***************************  PROCEDURES ************************** */
PROCEDURE pi-tratar-pat:
    DEF INPUT PARAM p_num_seq_incorp_bem_pat    LIKE incorp_bem_pat.num_seq_incorp_bem_pat NO-UNDO .

    FOR EACH reg_calc_bem_pat NO-LOCK
        WHERE reg_calc_bem_pat.num_id_bem_pat = bem_pat.num_id_bem_pat
        AND   reg_calc_bem_pat.num_seq_incorp_bem_pat = p_num_seq_incorp_bem_pat
        AND   reg_calc_bem_pat.dat_calc_pat >= tt-param.dt_trans_ini
        AND   reg_calc_bem_pat.dat_calc_pat <= tt-param.dt_trans_fim
        AND   reg_calc_bem_pat.cod_cenar_ctbl = "FISCAL" ,
        EACH aprop_ctbl_pat NO-LOCK
        WHERE aprop_ctbl_pat.num_seq_reg_calc_bem_pat = reg_calc_bem_pat.num_seq_reg_calc_bem_pat
        AND   aprop_ctbl_pat.val_lancto_ctbl <> 0
        :
        IF i-acomp MOD 100 = 0 THEN DO:
            RUN pi-acompanhar IN h-acomp(INPUT "PAT: " + STRING(i-acomp) ) .
        END.
        /**/
        IF aprop_ctbl_pat.cod_cta_ctbl_db <> "" AND 
           aprop_ctbl_pat.cod_cta_ctbl_db >= tt-param.cod_cta_ctbl_ini AND
           aprop_ctbl_pat.cod_cta_ctbl_db <= tt-param.cod_cta_ctbl_fim
        THEN DO:
            ASSIGN i-acomp = i-acomp + 1 .
            CREATE cst_ctbl_bi . ASSIGN
                cst_ctbl_bi.dt_trans        = reg_calc_bem_pat.dat_calc_pat
                cst_ctbl_bi.cod_estab       = aprop_ctbl_pat.cod_estab
                cst_ctbl_bi.cod_cta_ctbl    = aprop_ctbl_pat.cod_cta_ctbl_db
                cst_ctbl_bi.cod_ccusto      = aprop_ctbl_pat.cod_ccusto_db
                cst_ctbl_bi.ind_natur       = "DB"
                cst_ctbl_bi.val_lancto      = aprop_ctbl_pat.val_lancto_ctbl
                cst_ctbl_bi.cod_modul       = "PAT"
                cst_ctbl_bi.des_historico   = SUBSTRING(aprop_ctbl_pat.des_histor_lancto_ctbl , 1 , 100)
                cst_ctbl_bi.cdn_emitente    = bem_pat.cdn_fornecedor
                cst_ctbl_bi.cod_item        = STRING(bem_pat.num_bem_pat) + "/" + STRING(bem_pat.num_seq_bem_pat)
                .
        END.
        IF aprop_ctbl_pat.cod_cta_ctbl_cr <> "" AND 
           aprop_ctbl_pat.cod_cta_ctbl_cr >= tt-param.cod_cta_ctbl_ini AND
           aprop_ctbl_pat.cod_cta_ctbl_cr <= tt-param.cod_cta_ctbl_fim
        THEN DO:
            ASSIGN i-acomp = i-acomp + 1 .
            CREATE cst_ctbl_bi . ASSIGN
                cst_ctbl_bi.dt_trans        = reg_calc_bem_pat.dat_calc_pat
                cst_ctbl_bi.cod_estab       = aprop_ctbl_pat.cod_estab
                cst_ctbl_bi.cod_cta_ctbl    = aprop_ctbl_pat.cod_cta_ctbl_cr
                cst_ctbl_bi.cod_ccusto      = aprop_ctbl_pat.cod_ccusto_cr
                cst_ctbl_bi.ind_natur       = "CR"
                cst_ctbl_bi.val_lancto      = aprop_ctbl_pat.val_lancto_ctbl
                cst_ctbl_bi.cod_modul       = "PAT"
                cst_ctbl_bi.des_historico   = SUBSTRING(aprop_ctbl_pat.des_histor_lancto_ctbl , 1 , 100)
                cst_ctbl_bi.cdn_emitente    = bem_pat.cdn_fornecedor
                cst_ctbl_bi.cod_item        = STRING(bem_pat.num_bem_pat) + "/" + STRING(bem_pat.num_seq_bem_pat)
                .
        END.
    END.
END PROCEDURE .
