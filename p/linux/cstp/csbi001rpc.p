/*
Autor: JRA
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE pagesize             50
&SCOPED-DEFINE program_name         CSBI001RPC
&SCOPED-DEFINE program_definition   "CSBI001 - APB"
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
    WHERE cst_ctbl_bi.cod_modul = "APB"
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
        FOR EACH aprop_ctbl_ap NO-LOCK USE-INDEX aprpctbl_estab_cta_ctbl_data
            WHERE aprop_ctbl_ap.cod_estab = estabelecimento.cod_estab
            AND   aprop_ctbl_ap.cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl
            AND   aprop_ctbl_ap.cod_cta_ctbl = cta_ctbl.cod_cta_ctbl
            AND   aprop_ctbl_ap.dat_transacao >= tt-param.dt_trans_ini
            AND   aprop_ctbl_ap.dat_transacao <= tt-param.dt_trans_fim ,
            FIRST movto_tit_ap
            NO-LOCK
            WHERE movto_tit_ap.cod_estab = aprop_ctbl_ap.cod_estab
            AND   movto_tit_ap.num_id_movto_tit_ap = aprop_ctbl_ap.num_id_movto_tit_ap
            :
            IF movto_tit_ap.log_ctbz_aprop_ctbl = NO AND
               movto_tit_ap.log_aprop_ctbl_ctbzda = NO 
                THEN NEXT .

            ASSIGN i-acomp = i-acomp + 1 .
            IF i-acomp MOD 100 = 0 THEN DO:
                RUN pi-acompanhar IN h-acomp(INPUT "APB: " + STRING(i-acomp) ) .
            END.
            /**/
            CREATE cst_ctbl_bi . ASSIGN
                cst_ctbl_bi.dt_trans        = aprop_ctbl_ap.dat_transacao
                cst_ctbl_bi.cod_estab       = aprop_ctbl_ap.cod_estab
                cst_ctbl_bi.cod_cta_ctbl    = aprop_ctbl_ap.cod_cta_ctbl
                cst_ctbl_bi.cod_ccusto      = aprop_ctbl_ap.cod_ccusto
                cst_ctbl_bi.ind_natur       = aprop_ctbl_ap.ind_natur_lancto_ctbl
                cst_ctbl_bi.val_lancto      = aprop_ctbl_ap.val_aprop_ctbl
                cst_ctbl_bi.cod_modul       = "APB"
                cst_ctbl_bi.cdn_emitente    = movto_tit_ap.cdn_fornecedor
                cst_ctbl_bi.cod_item        = ""
                .
            IF movto_tit_ap.ind_trans_ap_abrev = "PGEF" OR
               movto_tit_ap.ind_trans_ap_abrev = "PECR" OR
               movto_tit_ap.ind_trans_ap_abrev = "EPEF" 
            THEN DO:
                ASSIGN cst_ctbl_bi.cdn_emitente = movto_tit_ap.cdn_fornec_pef .
                ASSIGN
                    cst_ctbl_bi.des_historico = 
                    movto_tit_ap.ind_trans_ap_abrev + "," + 
                    movto_tit_ap.cod_estab + "," + 
                    movto_tit_ap.cod_espec_docto + "," +
                    movto_tit_ap.cod_tit_ap
                    .
            END.
            ELSE DO:
                FOR FIRST tit_ap FIELDS(cod_estab cod_espec_docto cod_ser_docto cod_tit_ap cod_parcela 
                                     cdn_fornecedor num_id_tit_ap)
                    NO-LOCK
                    WHERE tit_ap.cod_estab = movto_tit_ap.cod_estab
                    AND   tit_ap.num_id_tit_ap = movto_tit_ap.num_id_tit_ap
                    :
                    ASSIGN cst_ctbl_bi.cdn_emitente = tit_ap.cdn_fornecedor .
                    ASSIGN cst_ctbl_bi.des_historico = 
                        movto_tit_ap.ind_trans_ap_abrev + "," +
                        tit_ap.cod_estab + "," + 
                        tit_ap.cod_espec_docto + "," +
                        tit_ap.cod_ser_docto + "," +
                        tit_ap.cod_tit_ap + "," +
                        tit_ap.cod_parcela
                        .
                END.
            END.
            /**/
        END.
    END.
END.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .


