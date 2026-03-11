/*
Objetivo: Inserir num tit bancario para EDI nas renegociacoes geradas
Autor: JRA
*/

/*Extrato de Versao / Versionamento*/
{include/i-prgvrs.i UPC-ACR748ZE 1.00.00.003}

/*Parametros UPC - Programa sem Interface / API / BO*/
{include/i-epc200.i1}

DEF INPUT PARAM p-ind-event AS CHAR NO-UNDO .
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc .

/*{utils/events-epc.i "C:\temp\_eventos_acr748ze.txt"}*/
/* *********************************** MAIN BLOCK ************************* */
DEF VAR v-param-cod-estab           LIKE tit_acr.cod_estab NO-UNDO .
DEF VAR v-param-num-id-tit-acr      LIKE tit_acr.num_id_tit_acr NO-UNDO .

DEF VAR v-seqTitulo                 AS CHAR NO-UNDO .
DEF VAR v-digNossoNumero            AS CHAR NO-UNDO .
DEF VAR v-codTituloBco              AS CHAR NO-UNDO .

IF p-ind-event = "Substitui‡Æo" THEN DO:
    FIND FIRST tt-epc NO-LOCK WHERE
        tt-epc.cod-event = "Substitui‡Æo" AND
        tt-epc.cod-parameter = "C¢digo do Estabelecimento"
        NO-ERROR .
    ASSIGN v-param-cod-estab = tt-epc.val-parameter . 

    FIND FIRST tt-epc NO-LOCK WHERE
        tt-epc.cod-event = "Substitui‡Æo" AND
        tt-epc.cod-parameter = "Num Id Titulo"
        NO-ERROR .
    ASSIGN v-param-num-id-tit-acr = INT(tt-epc.val-parameter) .
    /*
    MESSAGE "DEBUG - TESTE - UPC-ACR748ZE - TAKE001" SKIP
        "v-param-cod-estab: " v-param-cod-estab SKIP
        "v-param-num-id-tit-acr: " v-param-num-id-tit-acr SKIP
        VIEW-AS ALERT-BOX .
    */
    /**/
    FOR FIRST tit_acr
        WHERE tit_acr.cod_estab         = v-param-cod-estab
        AND   tit_acr.num_id_tit_acr    = v-param-num-id-tit-acr
        AND   tit_acr.cod_portador      = "23704" /* Bradesco */
        AND   tit_acr.cod_cart_bcia     = "SIM"
        :
        ASSIGN v-seqTitulo = STRING(NEXT-VALUE(seq-num-fat-convenio),"9999999999") .
        ASSIGN v-digNossoNumero = "" .
        RUN pi-retorna-digito-verificador-bradesco
            (INPUT "02" ,
             INPUT "97" + STRING(INT(v-seqTitulo),"999999999") ,
             OUTPUT v-digNossoNumero)
            .
        ASSIGN v-codTituloBco = "97" + STRING(INT(v-seqTitulo),"999999999") + v-digNossoNumero .
        ASSIGN tit_acr.cod_tit_acr_bco = v-codTituloBco .
        /*
        MESSAGE "DEBUG - TESTE - UPC-ACR748ZE - TAKE002" SKIP
            "tit_acr.cod_estab: " tit_acr.cod_estab SKIP
            "tit_acr.num_id_tit_acr: " tit_acr.num_id_tit_acr SKIP
            "tit_acr.cod_tit_acr: " tit_acr.cod_tit_acr SKIP
            "tit_acr.cod_parcela: " tit_acr.cod_parcela SKIP
            "v-seqTitulo: " v-seqTitulo SKIP
            "tit_acr.cod_tit_acr_bco: " tit_acr.cod_tit_acr_bco SKIP
            VIEW-AS ALERT-BOX .
            */
    END.
    FOR FIRST tit_acr
        WHERE tit_acr.cod_estab         = v-param-cod-estab
        AND   tit_acr.num_id_tit_acr    = v-param-num-id-tit-acr
        AND   tit_acr.cod_portador      = "34103" /* ITAU */ 
        AND   tit_acr.cod_cart_bcia     = "SIM"
        :
        FOR FIRST portad_edi NO-LOCK
            WHERE portad_edi.cod_modul_dtsul = "ACR"
            AND   portad_edi.cod_estab = tit_acr.cod_estab
            AND   portad_edi.cod_portador = tit_acr.cod_portador
            AND   portad_edi.cod_cart_bcia = tit_acr.cod_cart_bcia
            AND   portad_edi.cod_finalid_econ = "CORRENTE" ,
            FIRST portad_finalid_econ NO-LOCK
            WHERE portad_finalid_econ.cod_estab = tit_acr.cod_estab
            AND   portad_finalid_econ.cod_portador = tit_acr.cod_portador
            AND   portad_finalid_econ.cod_cart_bcia = tit_acr.cod_cart_bcia
            AND   portad_finalid_econ.cod_finalid_econ = "CORRENTE" ,
            FIRST cta_corren NO-LOCK
            WHERE cta_corren.cod_cta_corren = portad_finalid_econ.cod_cta_corren
            :
            ASSIGN v-seqTitulo = STRING(NEXT-VALUE(seq-num-fat-convenio),"9999999999") .
            RUN pi-retorna-digito-verificador-itau(INPUT INT(v-seqTitulo) , OUTPUT v-digNossoNumero) .
            ASSIGN tit_acr.cod_tit_acr_bco = STRING(INT(v-seqTitulo) , "99999999") + v-digNossoNumero .
        END.
    END.
END.

/*Fim*/
RETURN "OK":U .

/* *********************************** PROCEDURES ************************* */
PROCEDURE pi-retorna-digito-verificador-bradesco:
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


