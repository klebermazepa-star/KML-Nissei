/*
Objetivos: Gerar Nosso Numero nos Titulos - Destinacao
Autor: JRA
*/

/* Extrato de Versao / Versionamento */
{include/i-prgvrs.i UPC-ACR739AB 1.00.00.001}

/* Parametros UPC - Programa com Interface - EMS5 */
DEF INPUT PARAM p-ind-event        AS CHAR          NO-UNDO .
DEF INPUT PARAM p-ind-object       AS CHAR          NO-UNDO .
DEF INPUT PARAM p-wgh-object       AS HANDLE        NO-UNDO .
DEF INPUT PARAM p-wgh-frame        AS WIDGET-HANDLE NO-UNDO .
DEF INPUT PARAM p-cod-table        AS CHAR          NO-UNDO .
DEF INPUT PARAM p-row-table        AS RECID         NO-UNDO .

DEFINE BUFFER b_estabelecimento FOR ems5.estabelecimento.

{utils/events-upc.i "C:\temp\_eventos_acr739ab.txt"}
/* *********************************** MAIN BLOCK ************************* */
DEF VAR v-digNossoNumero    AS CHAR NO-UNDO .

IF p-ind-event = "altera_nosso_numero" THEN DO:
    FIND FIRST tit_acr WHERE RECID(tit_acr) = p-row-table .

    FIND FIRST portad_edi NO-LOCK
        WHERE portad_edi.cod_modul_dtsul = "ACR"
        AND   portad_edi.cod_estab = tit_acr.cod_estab
        AND   portad_edi.cod_portador = tit_acr.cod_portador
        AND   portad_edi.cod_cart_bcia = tit_acr.cod_cart_bcia
        AND   portad_edi.cod_finalid_econ = "CORRENTE" 
        NO-ERROR .
    IF AVAIL portad_edi THEN DO:
        FIND FIRST portad_finalid_econ NO-LOCK
            WHERE portad_finalid_econ.cod_estab = tit_acr.cod_estab
            AND   portad_finalid_econ.cod_portador = tit_acr.cod_portador
            AND   portad_finalid_econ.cod_cart_bcia = tit_acr.cod_cart_bcia
            AND   portad_finalid_econ.cod_finalid_econ = "CORRENTE"
            .
        FIND FIRST cta_corren NO-LOCK
            WHERE cta_corren.cod_cta_corren = portad_finalid_econ.cod_cta_corren
            .
    
        IF tit_acr.cod_portador = "23704" /* BRADESCO */ AND
           tit_acr.cod_cart_bcia = "SIM"
        THEN DO:
            RUN pi-retorna-digito-verificador-bradesco
                (INPUT "02" ,
                 INPUT "97" + STRING(INT(tit_acr.cod_tit_acr),"999999999") ,
                 OUTPUT v-digNossoNumero)
                .
            ASSIGN tit_acr.cod_tit_acr_bco = "97" + STRING(INT(tit_acr.cod_tit_acr),"999999999") + v-digNossoNumero .
        END.
        IF tit_acr.cod_portador = "34103" /* ITAU */ AND
           tit_acr.cod_cart_bcia = "SIM"
        THEN DO:
            RUN pi-retorna-digito-verificador-itau
                (INPUT INT(tit_acr.cod_tit_acr) , 
                 OUTPUT v-digNossoNumero) 
                .
            ASSIGN tit_acr.cod_tit_acr_bco = STRING(INT(tit_acr.cod_tit_acr) , "99999999") + v-digNossoNumero .
        END.
    END.

    IF tit_acr.cod_espec_docto = "CF" THEN DO:
        RUN pi-gera-fatura-site .
    END.
END.

/**/
RETURN "OK":U.

/* *********************************** PROCEDURES ************************* */
PROCEDURE pi-retorna-digito-verificador-bradesco
    :
    DEF INPUT  PARAM p-carteira           AS CHAR.
    DEF INPUT  PARAM p-nosso-numero       AS CHAR.
    DEF OUTPUT PARAM p-digito-verificador AS CHAR.

    DEF VAR i-valor01          AS INTEGER NO-UNDO.
    DEF VAR i-valor02          AS INTEGER NO-UNDO.
    DEF VAR i-valor03          AS INTEGER NO-UNDO.
    DEF VAR i-valor04          AS INTEGER NO-UNDO.
    DEF VAR i-valor05          AS INTEGER NO-UNDO.
    DEF VAR i-valor06          AS INTEGER NO-UNDO.
    DEF VAR i-valor07          AS INTEGER NO-UNDO.
    DEF VAR i-valor08          AS INTEGER NO-UNDO.
    DEF VAR i-valor09          AS INTEGER NO-UNDO.
    DEF VAR i-valor10          AS INTEGER NO-UNDO.
    DEF VAR i-valor11          AS INTEGER NO-UNDO.
    DEF VAR i-valor12          AS INTEGER NO-UNDO.
    DEF VAR i-valor13          AS INTEGER NO-UNDO.
    DEF VAR i-soma             AS INTEGER NO-UNDO.
    DEF VAR i-resto            AS INTEGER NO-UNDO.
    
    ASSIGN i-valor01 = 2 * INTEGER(SUBSTRING(p-carteira    ,01,1))
           i-valor02 = 7 * INTEGER(SUBSTRING(p-carteira    ,02,1))
           i-valor03 = 6 * INTEGER(SUBSTRING(p-nosso-numero,01,1))
           i-valor04 = 5 * INTEGER(SUBSTRING(p-nosso-numero,02,1))
           i-valor05 = 4 * INTEGER(SUBSTRING(p-nosso-numero,03,1))
           i-valor06 = 3 * INTEGER(SUBSTRING(p-nosso-numero,04,1))
           i-valor07 = 2 * INTEGER(SUBSTRING(p-nosso-numero,05,1))
           i-valor08 = 7 * INTEGER(SUBSTRING(p-nosso-numero,06,1))
           i-valor09 = 6 * INTEGER(SUBSTRING(p-nosso-numero,07,1))
           i-valor10 = 5 * INTEGER(SUBSTRING(p-nosso-numero,08,1))
           i-valor11 = 4 * INTEGER(SUBSTRING(p-nosso-numero,09,1))
           i-valor12 = 3 * INTEGER(SUBSTRING(p-nosso-numero,10,1))
           i-valor13 = 2 * INTEGER(SUBSTRING(p-nosso-numero,11,1)).

    ASSIGN i-soma = i-valor01 + i-valor02 + i-valor03 + i-valor04 + i-valor05 + i-valor06 + i-valor07 + 
                    i-valor08 + i-valor09 + i-valor10 + i-valor11 + i-valor12 + i-valor13.

    /* fut1074 - 08/06/2004 */
    /* Validar antes se resto da divisao for zero, entao considera 0 como digito */

    IF (i-soma MODULO 11) = 0 THEN DO:
        ASSIGN p-digito-verificador = "0".
    END.
    ELSE DO:
        ASSIGN i-resto = 11 - (i-soma MODULO 11).
        
        IF i-resto = 10 THEN
           ASSIGN p-digito-verificador = 'P'.
        ELSE
           ASSIGN p-digito-verificador = STRING(i-resto).
    END.

END PROCEDURE.

PROCEDURE pi-retorna-digito-verificador-itau
    :
    DEF INPUT PARAM p-nossoNumero       AS INT NO-UNDO .
    DEF OUTPUT PARAM digitoVerificador  as character  no-undo. 
    define variable i_cont              as integer   no-undo.
    define variable posicao             as integer   no-undo.
    define variable multiplicador       as integer   no-undo.
    define variable total               as integer   no-undo.
    define variable auxiliar            as integer   no-undo.
    define variable i_digito            as integer   no-undo.
    define variable c_digito            as character no-undo.
    define variable linha               as character no-undo.
    /*
    MESSAGE
        cta_corren.cod_agenc_bcia SKIP
        cta_corren.cod_cta_corren_bco SKIP
        ENTRY(10,portad_edi.des_tip_var_portad_edi,'~n') SKIP
        p-nossoNumero SKIP
        VIEW-AS ALERT-BOX .
    */
    assign linha = string(integer(cta_corren.cod_agenc_bcia), '9999') 
                 + string(integer(cta_corren.cod_cta_corren_bco), '99999')
                 + string(integer(ENTRY(10,portad_edi.des_tip_var_portad_edi,'~n')), '999') 
                 + string(integer(p-nossoNumero),'99999999')
        .

    assign 
        multiplicador = 3
        posicao = 21
        total  = 0.

    do i_cont = 1 to 20:
       assign posicao = posicao - 1.
       assign multiplicador = multiplicador - 1.
       assign auxiliar = int(substr(linha,posicao,1)) * multiplicador.

       if auxiliar >= 10 then 
           assign auxiliar = int(substr(string(auxiliar,"99"),1,1)) + int(substr(string(auxiliar,"99"),2,1)).

       assign total = total + auxiliar.

       if multiplicador = 1 then 
           assign multiplicador = 3.
    end.

    assign i_digito = total modulo 10
           c_digito = string(10 - i_digito)
           digitoVerificador = c_digito.

    /*Segundo o manual do itau - Considera o Digito como zero*/
    if digitoVerificador = '10' THEN DO:
        assign digitoVerificador = '0'.
    END.
    
END PROCEDURE .


DEFINE NEW GLOBAL SHARED VARIABLE v_cod_empres_usuar AS CHARACTER FORMAT "x(3)":U NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE g-wgh-object       AS HANDLE                    NO-UNDO.

DEFINE NEW GLOBAL SHARED VARIABLE v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usu rio Corrente"
    column-label "Usu rio Corrente"
    no-undo.

PROCEDURE pi-gera-fatura-site
    :
    DEF BUFFER bf_tit_acr FOR tit_acr .
    DEF BUFFER cliente FOR ems5.cliente .

    DEFINE VARIABLE iSeq        AS INTEGER   NO-UNDO.
    DEFINE VARIABLE codConvenio AS INTEGER   NO-UNDO.

    FOR FIRST renegoc_acr NO-LOCK
        WHERE renegoc_acr.num_renegoc_cobr_acr = tit_acr.num_renegoc_cobr_acr
        :
        FOR EACH estabelecimento NO-LOCK
            WHERE estabelecimento.cod_empresa = v_cod_empres_usuar
            :
            movto_tit_block:
            FOR EACH movto_tit_acr NO-LOCK USE-INDEX mvtttcr_refer
               WHERE movto_tit_acr.cod_estab           = estabelecimento.cod_estab
                 AND movto_tit_acr.cod_refer           = renegoc_acr.cod_refer
                 AND movto_tit_acr.ind_trans_acr_abrev = "LQRN"
                :
                IF movto_tit_acr.cod_estab_proces_bxa <> renegoc_acr.cod_estab THEN NEXT.

                FOR FIRST bf_tit_acr USE-INDEX titacr_token 
                 WHERE bf_tit_acr.cod_estab      = movto_tit_acr.cod_estab 
                   AND bf_tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr
                    :
                    ASSIGN iSeq = 0.
                    FOR LAST int_ds_fat_conv_site NO-LOCK
                          BY int_ds_fat_conv_site.id_fat_conv_site
                        :
                        ASSIGN iSeq = int_ds_fat_conv_site.id_fat_conv_site + 1.
                    END.
                    IF iSeq = 0 THEN ASSIGN iSeq = 1.

                    FIND FIRST int_ds_fat_conv_site NO-LOCK
                         WHERE int_ds_fat_conv_site.id_fat_conv_site = iSeq 
                        NO-ERROR.
                    IF NOT AVAIL int_ds_fat_conv_site THEN DO:
                        FIND FIRST cliente NO-LOCK
                             WHERE cliente.cdn_cliente = tit_acr.cdn_cliente 
                            NO-ERROR.
                        FOR FIRST cst_nota_fiscal NO-LOCK                                              
                            WHERE cst_nota_fiscal.cod_estabel = bf_tit_acr.cod_estab           
                              AND cst_nota_fiscal.serie       = bf_tit_acr.cod_ser_docto 
                              AND cst_nota_fiscal.nr_nota_fis = bf_tit_acr.cod_tit_acr
                            :
                            ASSIGN codConvenio = INT(cst_nota_fiscal.convenio).

                            FIND FIRST b_estabelecimento
                                 WHERE b_estabelecimento.cod_empresa = bf_tit_acr.cod_empresa 
                                   AND b_estabelecimento.cod_estab   = bf_tit_acr.cod_estab   NO-LOCK NO-ERROR.

                            CREATE int_ds_fat_conv_site.
                            ASSIGN int_ds_fat_conv_site.id_fat_conv_site = iSeq.
                            ASSIGN int_ds_fat_conv_site.cnpj               = IF AVAIL cliente THEN cliente.cod_id_feder ELSE ""
                                   int_ds_fat_conv_site.cod_convenio       = INT(cst_nota_fiscal.convenio)
                                   int_ds_fat_conv_site.cod_estabel        = bf_tit_acr.cod_estab 
                                   int_ds_fat_conv_site.dat_cupom          = bf_tit_acr.dat_emis_docto
                                   int_ds_fat_conv_site.nosso_numero_banc  = tit_acr.cod_tit_acr_bco
                                   int_ds_fat_conv_site.serie              = bf_tit_acr.cod_ser_docto
                                   int_ds_fat_conv_site.nro_cupom          = bf_tit_acr.cod_tit_acr
                                   int_ds_fat_conv_site.parcela            = bf_tit_acr.cod_parcela
                                   int_ds_fat_conv_site.nro_fatura         = tit_acr.cod_tit_acr
                                   int_ds_fat_conv_site.orgao              = cst_nota_fiscal.orgao
                                   int_ds_fat_conv_site.categoria          = cst_nota_fiscal.categoria
                                   int_ds_fat_conv_site.situacao           = 1
                                   int_ds_fat_conv_site.cod_banco          = ""
                                .

                            /* Integra‡Æo Procfit */
                            ASSIGN int_ds_fat_conv_site.indterminal        = cst_nota_fiscal.indterminal
                                   int_ds_fat_conv_site.serie              = bf_tit_acr.cod_ser_docto
                                   int_ds_fat_conv_site.cnpj_filial        = b_estabelecimento.cod_id_feder
                                   int_ds_fat_conv_site.num_cupom          = bf_tit_acr.cod_tit_acr
                                   int_ds_fat_conv_site.id_pedido_convenio = STRING(cst_nota_fiscal.id_pedido_convenio) .

                            IF cst_nota_fiscal.id_pedido_convenio <> 0 AND cst_nota_fiscal.id_pedido_convenio <> ?  THEN DO:
                                ASSIGN int_ds_fat_conv_site.nro_cupom = STRING(INT(cst_nota_fiscal.id_pedido_convenio),"9999999").
                            END.

                        END.
                    END.
                END.
            END.
        END.

        FIND FIRST int_ds_fat_convenio
             WHERE int_ds_fat_convenio.cod_convenio = codConvenio
               AND int_ds_fat_convenio.nro_fatura   = tit_acr.cod_tit_acr 
            NO-ERROR.
        IF NOT AVAIL int_ds_fat_convenio THEN DO:

            FIND FIRST b_estabelecimento
                 WHERE b_estabelecimento.cod_empresa = tit_acr.cod_empresa 
                   AND b_estabelecimento.cod_estab   = tit_acr.cod_estab   NO-LOCK NO-ERROR.

            CREATE int_ds_fat_convenio.
            ASSIGN int_ds_fat_convenio.cod_convenio       = codConvenio
                   int_ds_fat_convenio.cod_estabel        = tit_acr.cod_estab
                   int_ds_fat_convenio.dat_emissao        = tit_acr.dat_emis_docto 
                   int_ds_fat_convenio.dat_vencto         = tit_acr.dat_vencto_tit_acr
                   int_ds_fat_convenio.dig_nosso_num_banc = SUBSTRING(tit_acr.cod_tit_acr_bco,12,1)
                   int_ds_fat_convenio.nosso_numero_banc  = SUBSTRING(tit_acr.cod_tit_acr_bco,1,11)
                   int_ds_fat_convenio.nro_fatura         = tit_acr.cod_tit_acr
                   int_ds_fat_convenio.situacao           = 1
                   int_ds_fat_convenio.vl_original        = tit_acr.val_origin_tit_acr 
                   int_ds_fat_convenio.vl_saldo           = tit_acr.val_sdo_tit_acr  
                   int_ds_fat_convenio.tipo_movto         = 1
                   int_ds_fat_convenio.id_sequencial      = NEXT-VALUE(SEQ-INT-DS-FAT-CONVENIO) /* Prepara‡Æo para integra‡Æo com Procfit */
                .
            /* Integra‡Æo Procfit */
            ASSIGN int_ds_fat_convenio.cnpj_filial        = b_estabelecimento.cod_id_feder
                   int_ds_fat_convenio.ENVIO_STATUS       = 1.

            /* Tratativa para enviar todos os dados caso for banco ITAU */
            /* Inclusao do codigo do banco */
            IF tit_acr.cod_portador = "34103" AND
               AVAIL cta_corren
            THEN DO:
                ASSIGN int_ds_fat_convenio.nosso_numero_banc = 
                    STRING(INT(cta_corren.cod_agenc_bcia), '9999') +
                    STRING(INT(cta_corren.cod_cta_corren_bco), '99999') +
                    STRING(INT(cta_corren.cod_digito_cta_corren), '9') +
                    STRING(INT(ENTRY(10,portad_edi.des_tip_var_portad_edi,'~n')), '999') +
                    STRING(INT(tit_acr.cod_tit_acr),'99999999')
                 .
                ASSIGN int_ds_fat_convenio.dig_nosso_num_banc = v-digNossoNumero .
            END.
            IF AVAIL cta_corren THEN DO:
                ASSIGN int_ds_fat_convenio.cod_banco = cta_corren.cod_banco .
            END.
            /**/

            FIND FIRST cliente
                 WHERE cliente.cdn_cliente = tit_acr.cdn_cliente 
                NO-ERROR.
            IF AVAIL cliente THEN DO:
                ASSIGN int_ds_fat_convenio.cnpj           = cliente.cod_id_feder.
            END.
        END.
        ELSE DO:
            ASSIGN int_ds_fat_convenio.dat_vencto         = tit_acr.dat_vencto_tit_acr 
                   int_ds_fat_convenio.vl_original        = tit_acr.val_origin_tit_acr    
                   int_ds_fat_convenio.vl_saldo           = tit_acr.val_sdo_tit_acr.
                   
            IF int_ds_fat_convenio.situacao  = 1  THEN DO:
                ASSIGN int_ds_fat_convenio.tipo_movto         = 1 
                       int_ds_fat_convenio.situacao           = 1
                       int_ds_fat_convenio.ENVIO_STATUS       = 1. 
            END.
            ELSE DO:
                ASSIGN int_ds_fat_convenio.tipo_movto         = 2 
                       int_ds_fat_convenio.situacao           = 1
                       int_ds_fat_convenio.ENVIO_STATUS       = 1.
            END.
        END.
    END.
END PROCEDURE .
