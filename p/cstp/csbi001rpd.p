/*
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         csbi001rpd
&SCOPED-DEFINE program_definition   "CSBI001 - CMG"
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

RUN pi-acompanhar IN h-acomp(INPUT "Eliminando...") .
DELETE FROM cst_ctbl_bi
    WHERE cst_ctbl_bi.cod_modul = "CMG"
    AND   cst_ctbl_bi.dt_trans >= tt-param.dt_trans_ini
    AND   cst_ctbl_bi.dt_trans <= tt-param.dt_trans_fim
    AND   cst_ctbl_bi.cod_estab >= tt-param.cod_estab_ini
    AND   cst_ctbl_bi.cod_estab <= tt-param.cod_estab_fim
    AND   cst_ctbl_bi.cod_cta_ctbl >= tt-param.cod_cta_ctbl_ini
    AND   cst_ctbl_bi.cod_cta_ctbl <= tt-param.cod_cta_ctbl_fim
    .

ASSIGN i-acomp = 0 .

FOR FIRST plano_cta_ctbl NO-LOCK 
    WHERE plano_cta_ctbl.cod_plano_cta_ctbl = "PADRAO",
    EACH estabelecimento NO-LOCK
    WHERE estabelecimento.cod_estab >= tt-param.cod_estab_ini
    AND   estabelecimento.cod_estab <= tt-param.cod_estab_fim
    :
    FOR EACH cta_ctbl FIELDS(cod_cta_ctbl) NO-LOCK
        WHERE cta_ctbl.cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl
        AND   cta_ctbl.cod_cta_ctbl >= tt-param.cod_cta_ctbl_ini
        AND   cta_ctbl.cod_cta_ctbl <= tt-param.cod_cta_ctbl_fim
        :
        FOR EACH aprop_ctbl_cmg NO-LOCK USE-INDEX aprpctbk_ctbz_cta
            WHERE aprop_ctbl_cmg.cod_estab = estabelecimento.cod_estab
            AND   aprop_ctbl_cmg.cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl
            AND   aprop_ctbl_cmg.cod_cta_ctbl = cta_ctbl.cod_cta_ctbl
            AND   aprop_ctbl_cmg.dat_transacao >= tt-param.dt_trans_ini
            AND   aprop_ctbl_cmg.dat_transacao <= tt-param.dt_trans_fim
            :
            ASSIGN i-acomp = i-acomp + 1 .
            IF i-acomp MOD 100 = 0 THEN DO:
                RUN pi-acompanhar IN h-acomp(INPUT "CMG: " + STRING(i-acomp) ) .
            END.
            /**/
            CREATE cst_ctbl_bi . ASSIGN
                cst_ctbl_bi.dt_trans        = aprop_ctbl_cmg.dat_transacao
                cst_ctbl_bi.cod_estab       = aprop_ctbl_cmg.cod_estab
                cst_ctbl_bi.cod_cta_ctbl    = aprop_ctbl_cmg.cod_cta_ctbl
                cst_ctbl_bi.cod_ccusto      = aprop_ctbl_cmg.cod_ccusto
                cst_ctbl_bi.ind_natur       = aprop_ctbl_cmg.ind_natur_lancto_ctbl
                cst_ctbl_bi.val_lancto      = aprop_ctbl_cmg.val_movto_cta_corren
                cst_ctbl_bi.cod_modul       = "CMG"
                cst_ctbl_bi.cdn_emitente    = 0
                cst_ctbl_bi.cod_item        = ""
                .
            FOR FIRST movto_cta_corren FIELDS(num_id_movto_cta_corren cod_cta_corren cod_tip_trans_cx 
                                              des_histor_movto_cta_corren) 
                NO-LOCK
                WHERE movto_cta_corren.num_id_movto_cta_corren = aprop_ctbl_cmg.num_id_movto_cta_corren
                :
                ASSIGN cst_ctbl_bi.des_historico = 
                    movto_cta_corren.cod_cta_corren + "," + 
                    movto_cta_corren.cod_tip_trans_cx + "," +
                    SUBSTRING(movto_cta_corren.des_histor_movto_cta_corren , 1 , 80)
                    .
            END.
        END.
    END.
END.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .


