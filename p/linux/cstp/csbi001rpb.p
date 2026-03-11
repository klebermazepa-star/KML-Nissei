/*
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         CSBI001RPB
&SCOPED-DEFINE program_definition   "CSBI001 - ACR"
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
    WHERE cst_ctbl_bi.cod_modul = "ACR"
    AND   cst_ctbl_bi.dt_trans >= tt-param.dt_trans_ini
    AND   cst_ctbl_bi.dt_trans <= tt-param.dt_trans_fim
    AND   cst_ctbl_bi.cod_estab >= tt-param.cod_estab_ini
    AND   cst_ctbl_bi.cod_estab <= tt-param.cod_estab_fim
    AND   cst_ctbl_bi.cod_cta_ctbl >= tt-param.cod_cta_ctbl_ini
    AND   cst_ctbl_bi.cod_cta_ctbl <= tt-param.cod_cta_ctbl_fim
    .

ASSIGN i-acomp = 0 .

FOR FIRST plano_cta_ctbl NO-LOCK ,
    EACH estabelecimento NO-LOCK
    WHERE estabelecimento.cod_estab >= tt-param.cod_estab_ini
    AND   estabelecimento.cod_estab <= tt-param.cod_estab_fim
    :
    FOR EACH cta_ctbl FIELDS(cod_cta_ctbl) NO-LOCK
        WHERE cta_ctbl.cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl
        AND   cta_ctbl.cod_cta_ctbl >= tt-param.cod_cta_ctbl_ini
        AND   cta_ctbl.cod_cta_ctbl <= tt-param.cod_cta_ctbl_fim
        :
        FOR EACH aprop_ctbl_acr NO-LOCK USE-INDEX aprpctbd_estab_cta_ctbl_data
            WHERE aprop_ctbl_acr.cod_estab = estabelecimento.cod_estab
            AND   aprop_ctbl_acr.cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl
            AND   aprop_ctbl_acr.cod_cta_ctbl = cta_ctbl.cod_cta_ctbl
            AND   aprop_ctbl_acr.dat_transacao >= tt-param.dt_trans_ini
            AND   aprop_ctbl_acr.dat_transacao <= tt-param.dt_trans_fim ,
            FIRST movto_tit_acr FIELDS(cod_estab num_id_movto_tit_acr num_id_tit_acr)
            NO-LOCK
            WHERE movto_tit_acr.cod_estab = aprop_ctbl_acr.cod_estab
            AND   movto_tit_acr.num_id_movto_tit_acr = aprop_ctbl_acr.num_id_movto_tit_acr , 
            FIRST tit_acr FIELDS(cod_estab cod_espec_docto cod_ser_docto cod_tit_acr cod_parcela 
                                 cdn_cliente num_id_tit_acr)
            NO-LOCK
            WHERE tit_acr.cod_estab = movto_tit_acr.cod_estab
            AND   tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr
            :
            IF aprop_ctbl_acr.log_ctbz_aprop_ctbl = NO AND
               aprop_ctbl_acr.log_aprop_ctbl_ctbzda = NO 
                THEN NEXT .

            ASSIGN i-acomp = i-acomp + 1 .
            IF i-acomp MOD 100 = 0 THEN DO:
                RUN pi-acompanhar IN h-acomp(INPUT "ACR: " + STRING(i-acomp) ) .
            END.
            /**/
            CREATE cst_ctbl_bi . ASSIGN
                cst_ctbl_bi.dt_trans        = aprop_ctbl_acr.dat_transacao
                cst_ctbl_bi.cod_estab       = aprop_ctbl_acr.cod_estab
                cst_ctbl_bi.cod_cta_ctbl    = aprop_ctbl_acr.cod_cta_ctbl
                cst_ctbl_bi.cod_ccusto      = aprop_ctbl_acr.cod_ccusto
                cst_ctbl_bi.ind_natur       = aprop_ctbl_acr.ind_natur_lancto_ctbl
                cst_ctbl_bi.val_lancto      = aprop_ctbl_acr.val_aprop_ctbl
                cst_ctbl_bi.cod_modul       = "ACR"
                cst_ctbl_bi.cdn_emitente    = tit_acr.cdn_cliente
                cst_ctbl_bi.cod_item        = ""
                .
            ASSIGN cst_ctbl_bi.des_historico = 
                tit_acr.cod_estab + "," + 
                tit_acr.cod_espec_docto + "," +
                tit_acr.cod_ser_docto + "," +
                tit_acr.cod_tit_acr + "," +
                tit_acr.cod_parcela
                .
        END.
    END.
END.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .


