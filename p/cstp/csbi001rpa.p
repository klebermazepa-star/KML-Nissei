/*
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         csbi001rpa
&SCOPED-DEFINE program_definition   "CSBI001 - FGL"
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
    WHERE cst_ctbl_bi.cod_modul = "FGL"
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
    FOR EACH item_lancto_ctbl NO-LOCK
        WHERE item_lancto_ctbl.cod_empresa = empresa.cod_empresa
        AND   item_lancto_ctbl.dat_lancto_ctbl >= tt-param.dt_trans_ini
        AND   item_lancto_ctbl.dat_lancto_ctbl <= tt-param.dt_trans_fim
        AND   item_lancto_ctbl.cod_estab >= tt-param.cod_estab_ini
        AND   item_lancto_ctbl.cod_estab <= tt-param.cod_estab_fim
        AND   item_lancto_ctbl.cod_cta_ctbl >= tt-param.cod_cta_ctbl_ini
        AND   item_lancto_ctbl.cod_cta_ctbl <= tt-param.cod_cta_ctbl_fim , 
        FIRST lancto_ctbl FIELDS() NO-LOCK
        WHERE lancto_ctbl.num_lote_ctbl = item_lancto_ctbl.num_lote_ctbl
        AND   lancto_ctbl.num_lancto_ctbl = item_lancto_ctbl.num_lancto_ctbl
        AND   lancto_ctbl.cod_modul_dtsul = "FGL"
        :
        ASSIGN i-acomp = i-acomp + 1 .
        IF i-acomp MOD 100 = 0 THEN DO:
            RUN pi-acompanhar IN h-acomp(INPUT "FGL: " + STRING(i-acomp) ) .
        END.
        /**/
        CREATE cst_ctbl_bi . ASSIGN
            cst_ctbl_bi.dt_trans        = item_lancto_ctbl.dat_lancto_ctbl
            cst_ctbl_bi.cod_estab       = item_lancto_ctbl.cod_estab
            cst_ctbl_bi.cod_cta_ctbl    = item_lancto_ctbl.cod_cta_ctbl
            cst_ctbl_bi.cod_ccusto      = item_lancto_ctbl.cod_ccusto
            cst_ctbl_bi.ind_natur       = item_lancto_ctbl.ind_natur_lancto_ctbl
            cst_ctbl_bi.val_lancto      = item_lancto_ctbl.val_lancto_ctbl
            cst_ctbl_bi.cod_modul       = "FGL"
            cst_ctbl_bi.des_historico   = SUBSTRING(item_lancto_ctbl.des_histor_lancto_ctbl , 1 , 100)
            cst_ctbl_bi.cdn_emitente    = 0
            cst_ctbl_bi.cod_item        = ""
            .
    END.
END.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .


