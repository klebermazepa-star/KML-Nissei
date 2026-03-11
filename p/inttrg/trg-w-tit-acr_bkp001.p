/***************************************************************************************
**   Programa: trg-w-tit-acr.p - Trigger de write para a tabela tit_acr
**   Data....: Julho/2016
***************************************************************************************/
DEF PARAM BUFFER b_tit_acr     FOR tit_acr.
DEF PARAM BUFFER b_old_tit_acr FOR tit_acr.

DEFINE BUFFER cliente          FOR emscad.cliente.
DEFINE BUFFER bf_tit_acr       FOR tit_acr .

DEFINE NEW GLOBAL SHARED VARIABLE v_cod_empres_usuar AS CHARACTER FORMAT "x(3)":U NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE g-wgh-object       AS HANDLE                    NO-UNDO.

DEFINE NEW GLOBAL SHARED VARIABLE v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usu rio Corrente"
    column-label "Usu rio Corrente"
    no-undo.



DEFINE VARIABLE digNossoNumero                       AS CHARACTER   NO-UNDO.

DEFINE VARIABLE iSeq        AS INTEGER     NO-UNDO.
DEFINE VARIABLE codConvenio AS INTEGER   NO-UNDO.


/*OUTPUT TO t:\trg-w-tit-acr.LOG.*/

/* INICIO - Rotina para a Atualiza‡Æo da Fatura SITE - SysFarma */
IF NOT NEW b_tit_acr THEN DO:
    IF b_tit_acr.cod_espec_docto           = "CF" AND
       b_tit_acr.log_tit_acr_cobr_bcia     = YES  AND 
       b_old_tit_acr.log_tit_acr_cobr_bcia = NO   THEN DO:

        /*PUT "1 " SKIP.*/                                

        FIND FIRST renegoc_acr NO-LOCK
             WHERE renegoc_acr.num_renegoc_cobr_acr = b_tit_acr.num_renegoc_cobr_acr NO-ERROR.
        IF AVAIL renegoc_acr THEN DO:

            /*PUT "2 " SKIP.*/


            FOR EACH estabelecimento NO-LOCK
               WHERE estabelecimento.cod_empresa = v_cod_empres_usuar
                query-tuning(no-lookahead):


                /*PUT "3 " SKIP.*/


                movto_tit_block:
                FOR EACH movto_tit_acr no-lock 
                   WHERE movto_tit_acr.cod_estab           = estabelecimento.cod_estab
                     AND movto_tit_acr.cod_refer           = renegoc_acr.cod_refer
                     AND movto_tit_acr.ind_trans_acr_abrev = "LQRN" /*l_lqrn*/ 
               USE-INDEX mvtttcr_refer
                    query-tuning(no-lookahead):


                    /*PUT "4 " SKIP.*/


                    IF movto_tit_acr.cod_estab_proces_bxa <> renegoc_acr.cod_estab THEN NEXT.

                    FIND FIRST bf_tit_acr USE-INDEX titacr_token 
                         WHERE bf_tit_acr.cod_estab      = movto_tit_acr.cod_estab 
                           AND bf_tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr NO-ERROR.

                    /*PUT "5 " SKIP.*/

                    IF AVAIL bf_tit_acr THEN DO:


                        /*PUT "6 " SKIP.*/

                        ASSIGN iSeq = 0.
                        FOR LAST int-ds-fat-conv-site NO-LOCK
                              BY int-ds-fat-conv-site.id-fat-conv-site
                            query-tuning(no-lookahead):
                            ASSIGN iSeq = int-ds-fat-conv-site.id-fat-conv-site + 1.


                            /*PUT "7 " SKIP.*/

                        END.

                        IF iSeq = 0 THEN ASSIGN iSeq = 1.

                        FIND FIRST int-ds-fat-conv-site NO-LOCK
                             WHERE int-ds-fat-conv-site.id-fat-conv-site = iSeq  NO-ERROR.

                        /*PUT "8 " SKIP.*/

                        IF NOT AVAIL int-ds-fat-conv-site THEN DO:


                            /*PUT "9 " SKIP.*/

                            FIND FIRST cliente NO-LOCK
                                 WHERE cliente.cdn_cliente = b_tit_acr.cdn_cliente NO-ERROR.

                            /*PUT "10 " SKIP.*/

                            FOR FIRST cst-nota-fiscal NO-LOCK                                              
                                WHERE cst-nota-fiscal.cod-estabel = bf_tit_acr.cod_estab           
                                  AND cst-nota-fiscal.serie       = bf_tit_acr.cod_ser_docto 
                                  AND cst-nota-fiscal.nr-nota-fis = bf_tit_acr.cod_tit_acr
                                query-tuning(no-lookahead):

                                /* PUT "11" SKIP. */

                                ASSIGN codConvenio = INT(cst-nota-fiscal.convenio).

                                CREATE int-ds-fat-conv-site.
                                ASSIGN int-ds-fat-conv-site.id-fat-conv-site = iSeq.
                                ASSIGN int-ds-fat-conv-site.cnpj               = IF AVAIL cliente THEN cliente.cod_id_feder ELSE ""
                                       int-ds-fat-conv-site.cod-convenio       = INT(cst-nota-fiscal.convenio)
                                       int-ds-fat-conv-site.cod-estabel        = bf_tit_acr.cod_estab 
                                       int-ds-fat-conv-site.dat-cupom          = bf_tit_acr.dat_emis_docto
                                       int-ds-fat-conv-site.nosso-numero-banc  = b_tit_acr.cod_tit_acr_bco
                                       int-ds-fat-conv-site.serie              = bf_tit_acr.cod_ser_docto
                                       int-ds-fat-conv-site.nro-cupom          = bf_tit_acr.cod_tit_acr
                                       int-ds-fat-conv-site.parcela            = bf_tit_acr.cod_parcela
                                       int-ds-fat-conv-site.nro-fatura         = b_tit_acr.cod_tit_acr
                                       int-ds-fat-conv-site.orgao              = cst-nota-fiscal.orgao
                                       int-ds-fat-conv-site.categoria          = cst-nota-fiscal.categoria
                                       int-ds-fat-conv-site.situacao           = 1.
                            END.
                        END.
                    END.
                END.
            END.

            /*PUT "12 " SKIP.*/

            /* INICIO - Grava a tabela pai do convˆnio */
            FIND FIRST int-ds-fat-convenio
                 WHERE int-ds-fat-convenio.cod-convenio = codConvenio
                   AND int-ds-fat-convenio.nro-fatura   = b_tit_acr.cod_tit_acr  NO-ERROR.

            /*PUT "13 " SKIP.*/

            IF NOT AVAIL int-ds-fat-convenio THEN DO:
                CREATE int-ds-fat-convenio.
                ASSIGN int-ds-fat-convenio.cod-convenio       = codConvenio
                       int-ds-fat-convenio.cod-estabel        = b_tit_acr.cod_estab
                       int-ds-fat-convenio.dat-emissao        = b_tit_acr.dat_emis_docto 
                       int-ds-fat-convenio.dat-vencto         = b_tit_acr.dat_vencto_tit_acr
                       int-ds-fat-convenio.dig-nosso-num-banc = SUBSTRING(b_tit_acr.cod_tit_acr_bco,12,1)
                       int-ds-fat-convenio.nosso-numero-banc  = SUBSTRING(b_tit_acr.cod_tit_acr_bco,1,11)
                       int-ds-fat-convenio.nro-fatura         = b_tit_acr.cod_tit_acr
                       int-ds-fat-convenio.situacao           = 1
                       int-ds-fat-convenio.vl-original        = b_tit_acr.val_origin_tit_acr 
                       int-ds-fat-convenio.vl-saldo           = b_tit_acr.val_sdo_tit_acr  
                       int-ds-fat-convenio.tipo-movto         = 1
                       int-ds-fat-convenio.id_sequencial      = NEXT-VALUE(seq-int-ds-fat-convenio). /* Prepara‡Æo para integra‡Æo com Procfit */


                FIND FIRST cliente
                     WHERE cliente.cdn_cliente = b_tit_acr.cdn_cliente NO-ERROR.
                
                /*PUT "14 " SKIP.*/

                IF AVAIL cliente THEN
                    ASSIGN int-ds-fat-convenio.cnpj           = cliente.cod_id_feder.
            END.
            ELSE DO:

                /*PUT "15 " SKIP.*/

                ASSIGN int-ds-fat-convenio.dat-vencto         = b_tit_acr.dat_vencto_tit_acr 
                       int-ds-fat-convenio.vl-original        = b_tit_acr.val_origin_tit_acr    
                       int-ds-fat-convenio.vl-saldo           = b_tit_acr.val_sdo_tit_acr.
                       
                IF int-ds-fat-convenio.situacao  = 1  THEN DO:
                    ASSIGN int-ds-fat-convenio.tipo-movto         = 1 
                           int-ds-fat-convenio.situacao           = 1. 
                END.
                ELSE DO:
                    ASSIGN int-ds-fat-convenio.tipo-movto         = 2 
                           int-ds-fat-convenio.situacao           = 1.
                END.
            END.
            /* FIM    - Grava a tabela pai do convˆnio */
        END.
    END.
END.


IF NOT NEW b_tit_acr THEN DO:
    IF b_tit_acr.cod_espec_docto           = "CF" AND
       b_tit_acr.log_tit_acr_cobr_bcia     = YES  AND 
       b_tit_acr.dat_vencto_tit_acr       <> b_old_tit_acr.dat_vencto_tit_acr THEN DO:
       
          
        /*PUT "20 " SKIP.*/

        FIND FIRST renegoc_acr NO-LOCK
             WHERE renegoc_acr.num_renegoc_cobr_acr = b_tit_acr.num_renegoc_cobr_acr NO-ERROR.

        /*PUT "21 " SKIP.*/

        IF AVAIL renegoc_acr THEN DO:

            /*PUT "22 " SKIP.*/

            FOR EACH estabelecimento NO-LOCK
               WHERE estabelecimento.cod_empresa = v_cod_empres_usuar
                query-tuning(no-lookahead):

                /*PUT "23 " SKIP.*/


               movto_tit_block:
               FOR FIRST movto_tit_acr no-lock 
                   WHERE movto_tit_acr.cod_estab           = estabelecimento.cod_estab
                     AND movto_tit_acr.cod_refer           = renegoc_acr.cod_refer
                     AND movto_tit_acr.ind_trans_acr_abrev = "LQRN" /*l_lqrn*/ 
               USE-INDEX mvtttcr_refer
                   query-tuning(no-lookahead):


                   /*PUT "24 " SKIP.*/

                    IF movto_tit_acr.cod_estab_proces_bxa <> renegoc_acr.cod_estab THEN NEXT.

                    FIND FIRST bf_tit_acr USE-INDEX titacr_token 
                         WHERE bf_tit_acr.cod_estab      = movto_tit_acr.cod_estab 
                           AND bf_tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr NO-ERROR.
                    
                    
                    /*PUT "25 " SKIP.*/

                    IF AVAIL bf_tit_acr THEN DO:

                        /*PUT "26 " SKIP.*/


                        FOR FIRST nota-fiscal NO-LOCK                                              
                            WHERE nota-fiscal.cod-estabel = bf_tit_acr.cod_estab           
                              AND nota-fiscal.serie       = bf_tit_acr.cod_ser_docto 
                              AND nota-fiscal.nr-nota-fis = bf_tit_acr.cod_tit_acr,
                            FIRST cst-nota-fiscal OF nota-fiscal NO-LOCK
                            query-tuning(no-lookahead):

                            /*PUT "27 " SKIP.*/


                            ASSIGN codConvenio = INT(cst-nota-fiscal.convenio).

                        END.                       
                    END.
                END.
            END.
        END.
        
        /* INICIO - Grava a tabela pai do convˆnio */
        FIND FIRST int-ds-fat-convenio
             WHERE int-ds-fat-convenio.cod-convenio = codConvenio
               AND int-ds-fat-convenio.nro-fatura   = b_tit_acr.cod_tit_acr  NO-ERROR.

        /*PUT "28 " SKIP.*/

        IF NOT AVAIL int-ds-fat-convenio THEN DO:

            /*PUT "29 " SKIP.*/

            CREATE int-ds-fat-convenio.
            ASSIGN int-ds-fat-convenio.cod-convenio       = codConvenio
                   int-ds-fat-convenio.cod-estabel        = b_tit_acr.cod_estab
                   int-ds-fat-convenio.dat-emissao        = b_tit_acr.dat_emis_docto 
                   int-ds-fat-convenio.dat-vencto         = b_tit_acr.dat_vencto_tit_acr
                   int-ds-fat-convenio.dig-nosso-num-banc = SUBSTRING(b_tit_acr.cod_tit_acr_bco,12,1)
                   int-ds-fat-convenio.nosso-numero-banc  = SUBSTRING(b_tit_acr.cod_tit_acr_bco,1,11)
                   int-ds-fat-convenio.nro-fatura         = b_tit_acr.cod_tit_acr
                   int-ds-fat-convenio.situacao           = 1
                   int-ds-fat-convenio.vl-original        = b_tit_acr.val_origin_tit_acr 
                   int-ds-fat-convenio.vl-saldo           = b_tit_acr.val_sdo_tit_acr  
                   int-ds-fat-convenio.tipo-movto         = 1
                   int-ds-fat-convenio.id_sequencial      = NEXT-VALUE(seq-int-ds-fat-convenio). /* Prepara‡Æo para integra‡Æo com Procfit */

            FIND FIRST cliente
                 WHERE cliente.cdn_cliente = b_tit_acr.cdn_cliente NO-ERROR.
            /*PUT "30 " SKIP.*/

            IF AVAIL cliente THEN
                ASSIGN int-ds-fat-convenio.cnpj           = cliente.cod_id_feder.
        END.
        ELSE DO:

                /*PUT "31 " SKIP.*/

                ASSIGN int-ds-fat-convenio.dat-vencto         = b_tit_acr.dat_vencto_tit_acr 
                       int-ds-fat-convenio.vl-original        = b_tit_acr.val_origin_tit_acr    
                       int-ds-fat-convenio.vl-saldo           = b_tit_acr.val_sdo_tit_acr.
                       
                IF int-ds-fat-convenio.situacao  = 1  THEN DO:
                    ASSIGN int-ds-fat-convenio.tipo-movto         = 1 
                           int-ds-fat-convenio.situacao           = 1. 
                END.
                ELSE DO:
                    ASSIGN int-ds-fat-convenio.tipo-movto         = 2 
                           int-ds-fat-convenio.situacao           = 1.
                END.
        END.
        /* FIM    - Grava a tabela pai do convˆnio */        
   END.       
END.       
/* FIM - Rotina para a Atualiza‡Æo da Fatura SITE - SysFarma */

IF NEW b_tit_acr THEN DO:
    IF b_tit_acr.cod_espec_docto   = "CF" AND
       b_tit_acr.cod_tit_acr_bco   = ""   AND 
       b_tit_acr.cod_tit_acr      <> ""   THEN DO:

        /*PUT "40 " SKIP.*/

       ASSIGN digNossoNumero = "".
       RUN pi-retorna-digito-verificador-bradesco(INPUT "02",
                                                  INPUT "97" + STRING(INT(b_tit_acr.cod_tit_acr),"999999999"),
                                                  OUTPUT digNossoNumero).
       ASSIGN b_tit_acr.cod_tit_acr_bco    = "97" + STRING(INT(b_tit_acr.cod_tit_acr),"999999999") + digNossoNumero .

       /*PUT "41 " SKIP.*/

    END.
END.

IF NOT NEW b_tit_acr THEN DO:
    IF b_tit_acr.cod_espec_docto     = "CF" AND
       b_tit_acr.cod_tit_acr_bco     = ""   AND 
       b_old_tit_acr.cod_tit_acr_bco <> ""  THEN DO:

       OUTPUT TO VALUE("C:\TEMP\Jonas\NossoNumero\AcompanhamentoNossoNumero.CSV") APPEND NO-CONVERT.
           PUT UNFORMATTED 
                b_tit_acr.cod_tit_acr           ";"
                v_cod_usuar_corren              ";"
                STRING(PROGRAM-NAME(1))         ";"
                STRING(PROGRAM-NAME(2))         ";"
                STRING(PROGRAM-NAME(3))         ";"
                STRING(PROGRAM-NAME(4))         ";"
                STRING(TODAY,"99/99/9999")      ";"
                STRING(TIME,"HH:MM:SS")         ";" SKIP .
       OUTPUT CLOSE.

    END.
END.

OUTPUT CLOSE.

RETURN "OK":U.

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


