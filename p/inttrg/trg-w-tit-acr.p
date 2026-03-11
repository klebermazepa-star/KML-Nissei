/***************************************************************************************
**   Programa: trg-w-tit-acr.p - Trigger de write para a tabela tit_acr
**   Data....: Julho/2016
***************************************************************************************/
DEF PARAM BUFFER b_tit_acr     FOR tit_acr.
DEF PARAM BUFFER b_old_tit_acr FOR tit_acr.

DEFINE BUFFER cliente          FOR ems5.cliente.
DEFINE BUFFER bf_tit_acr       FOR tit_acr .
DEFINE BUFFER b_estabelecimento FOR estabelecimento.

DEFINE NEW GLOBAL SHARED VARIABLE v_cod_empres_usuar AS CHARACTER FORMAT "x(3)":U NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE g-wgh-object       AS HANDLE                    NO-UNDO.

DEFINE NEW GLOBAL SHARED VARIABLE v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usu rio Corrente"
    column-label "Usu rio Corrente"
    no-undo.

DEFINE VARIABLE iSeq        AS INTEGER     NO-UNDO.
DEFINE VARIABLE codConvenio AS INTEGER   NO-UNDO.


DEF STREAM s_imp.
DEFINE VARIABLE c-cgc AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-cod-emitente AS INTEGER     NO-UNDO.


/* tratamento CPF Cupom */
IF NEW b_tit_acr THEN DO:

    IF b_tit_acr.cod_espec_docto           = "CV" THEN DO:

        ASSIGN c-cgc = ''
               i-cod-emitente = 0
           .

        FIND FIRST cst_nota_fiscal 
             WHERE cst_nota_fiscal.cod_estabel = b_tit_acr.cod_estab
               AND cst_nota_fiscal.serie       = b_tit_acr.cod_ser_docto
               AND cst_nota_fiscal.nr_nota_fis = b_tit_acr.cod_tit_acr NO-LOCK  NO-ERROR.
    
        IF AVAIL cst_nota_fiscal THEN DO:
    
            ASSIGN  c-cgc = replace(cst_nota_fiscal.cpf_cupom,".","").
                       c-cgc = replace(c-cgc,"/","").
                       c-cgc = replace(c-cgc,"-","").
    
           FIND FIRST emitente WHERE 
                      emitente.cgc =  c-cgc NO-LOCK NO-ERROR.
    
           IF AVAIL emitente THEN DO:
              ASSIGN i-cod-emitente = emitente.cod-emitente
                     b_tit_acr.cdn_cliente = i-cod-emitente
                     b_tit_Acr.nom_abrev   = emitente.nome-abrev
                     .

               FIND FIRST ems5.cliente
                   WHERE cliente.cdn_cliente = emitente.cod-emitente NO-ERROR.
               IF AVAIL cliente THEN DO:
                   ASSIGN b_tit_acr.num_pessoa = cliente.num_pessoa.
               END.
    
    
              FOR EACH movto_tit_acr EXCLUSIVE-LOCK
                 WHERE movto_tit_acr.cod_estab = b_tit_acr.cod_estab
                  AND  movto_tit_acr.num_id_tit_acr = b_tit_acr.num_id_tit_acr:
    
                       ASSIGN movto_tit_acr.cdn_cliente = i-cod-emitente.
                  
              END.
    
           END.
    
           OUTPUT STREAM s_imp TO VALUE(SESSION:TEMP-DIRECTORY + "titulos" + string(time) + ".txt").
    
           DISP STREAM s_imp b_tit_acr.cod_estab         
                             b_tit_acr.cod_espec_docto   
                             b_tit_acr.cod_ser_docto     
                             b_tit_acr.cod_tit_acr       
                             b_tit_acr.cod_parcela       
                             b_tit_acr.cod_empresa       
                             b_tit_acr.cdn_cliente     
                            i-cod-emitente
                WITH FRAME f-1 STREAM-IO WIDTH 132 DOWN.
                DOWN STREAM s_imp WITH FRAME f-1.
    
           OUTPUT STREAM s_imp CLOSE.
    
    
        END.


    END. /* cv */

END. /* new */




IF NOT NEW b_tit_acr THEN DO:
    IF b_tit_acr.cod_espec_docto           = "CF" AND
       b_tit_acr.log_tit_acr_cobr_bcia     = YES  AND 
       b_tit_acr.dat_vencto_tit_acr       <> b_old_tit_acr.dat_vencto_tit_acr 
THEN DO:
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
                            FIRST cst_nota_fiscal 
                            WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
                              AND cst_nota_fiscal.serie       = nota-fiscal.serie
                              AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK
                            query-tuning(no-lookahead):

                            /*PUT "27 " SKIP.*/


                            ASSIGN codConvenio = INT(cst_nota_fiscal.convenio).

                        END.                       
                    END.
                END.
            END.
        END.
        
        /* INICIO - Grava a tabela pai do convˆnio */
        FIND FIRST int_ds_fat_convenio
             WHERE int_ds_fat_convenio.cod_convenio = codConvenio
               AND int_ds_fat_convenio.nro_fatura   = b_tit_acr.cod_tit_acr  NO-ERROR.

        /*PUT "28 " SKIP.*/

        IF NOT AVAIL int_ds_fat_convenio THEN DO:

            /*PUT "29 " SKIP.*/

            FIND FIRST portad_edi NO-LOCK
                WHERE portad_edi.cod_modul_dtsul = "ACR"
                AND   portad_edi.cod_estab = b_tit_acr.cod_estab
                AND   portad_edi.cod_portador = b_tit_acr.cod_portador
                AND   portad_edi.cod_cart_bcia = b_tit_acr.cod_cart_bcia
                AND   portad_edi.cod_finalid_econ = "CORRENTE" 
                .
            FIND FIRST portad_finalid_econ NO-LOCK
                WHERE portad_finalid_econ.cod_estab = b_tit_acr.cod_estab
                AND   portad_finalid_econ.cod_portador = b_tit_acr.cod_portador
                AND   portad_finalid_econ.cod_cart_bcia = b_tit_acr.cod_cart_bcia
                AND   portad_finalid_econ.cod_finalid_econ = "CORRENTE"
                .
            FIND FIRST cta_corren NO-LOCK
                WHERE cta_corren.cod_cta_corren = portad_finalid_econ.cod_cta_corren
                .

            FIND FIRST b_estabelecimento
                 WHERE b_estabelecimento.cod_empresa = b_tit_acr.cod_empresa 
                   AND b_estabelecimento.cod_estab   = b_tit_acr.cod_estab   NO-LOCK NO-ERROR.

            CREATE int_ds_fat_convenio.
            ASSIGN int_ds_fat_convenio.cod_convenio       = codConvenio
                   int_ds_fat_convenio.cod_estabel        = b_tit_acr.cod_estab
                   int_ds_fat_convenio.dat_emissao        = b_tit_acr.dat_emis_docto 
                   int_ds_fat_convenio.dat_vencto         = b_tit_acr.dat_vencto_tit_acr
                   int_ds_fat_convenio.dig_nosso_num_banc = SUBSTRING(b_tit_acr.cod_tit_acr_bco,12,1)
                   int_ds_fat_convenio.nosso_numero_banc  = SUBSTRING(b_tit_acr.cod_tit_acr_bco,1,11)
                   int_ds_fat_convenio.nro_fatura         = b_tit_acr.cod_tit_acr
                   int_ds_fat_convenio.situacao           = 1
                   int_ds_fat_convenio.vl_original        = b_tit_acr.val_origin_tit_acr 
                   int_ds_fat_convenio.vl_saldo           = b_tit_acr.val_sdo_tit_acr  
                   int_ds_fat_convenio.tipo_movto         = 1
                   int_ds_fat_convenio.cnpj_filial        = b_estabelecimento.cod_id_feder
                   int_ds_fat_convenio.ENVIO_STATUS       = 1
                   int_ds_fat_convenio.id_sequencial      = NEXT-VALUE(SEQ-INT-DS-FAT-CONVENIO). /* Prepara‡Æo para integra‡Æo com Procfit */

            IF b_tit_acr.cod_portador = "34103" THEN DO:
                ASSIGN int_ds_fat_convenio.nosso_numero_banc = 
                    STRING(INT(cta_corren.cod_agenc_bcia), '9999') +
                    STRING(INT(cta_corren.cod_cta_corren_bco), '99999') +
                    STRING(INT(cta_corren.cod_digito_cta_corren), '9') +
                    STRING(INT(ENTRY(10,portad_edi.des_tip_var_portad_edi,'~n')), '999') +
                    STRING(INT(b_tit_acr.cod_tit_acr),'99999999')
                 .
                ASSIGN int_ds_fat_convenio.dig_nosso_num_banc = SUBSTRING(b_tit_acr.cod_tit_acr_bco , LENGTH(b_tit_acr.cod_tit_acr_bco) , 1) .
            END.
            ASSIGN int_ds_fat_convenio.cod_banco = cta_corren.cod_banco .

            FIND FIRST cliente
                 WHERE cliente.cdn_cliente = b_tit_acr.cdn_cliente NO-ERROR.
            /*PUT "30 " SKIP.*/

            IF AVAIL cliente THEN
                ASSIGN int_ds_fat_convenio.cnpj           = cliente.cod_id_feder.
        END.
        ELSE DO:

                /*PUT "31 " SKIP.*/

                ASSIGN int_ds_fat_convenio.dat_vencto         = b_tit_acr.dat_vencto_tit_acr 
                       int_ds_fat_convenio.vl_original        = b_tit_acr.val_origin_tit_acr    
                       int_ds_fat_convenio.vl_saldo           = b_tit_acr.val_sdo_tit_acr.
                       
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
        /* FIM    - Grava a tabela pai do convˆnio */        
   END.       
END.       
/* FIM - Rotina para a Atualiza‡Æo da Fatura SITE - SysFarma */

IF NOT NEW b_tit_acr AND
   b_tit_acr.cod_espec_docto     = "CF" AND
   b_tit_acr.cod_tit_acr_bco     = ""   AND 
   b_old_tit_acr.cod_tit_acr_bco <> ""  
THEN DO:
   OUTPUT TO VALUE("C:\TEMP\Jonas\NossoNumero\AcompanhamentoNossoNumero.CSV") APPEND NO-CONVERT.
   PUT UNFORMATTED 
        b_tit_acr.cod_tit_acr           ";"
        v_cod_usuar_corren              ";"
        STRING(PROGRAM-NAME(1))         ";"
        STRING(PROGRAM-NAME(2))         ";"
        STRING(PROGRAM-NAME(3))         ";"
        STRING(PROGRAM-NAME(4))         ";"
        STRING(TODAY,"99/99/9999")      ";"
        STRING(TIME,"HH:MM:SS")         ";" 
       SKIP .
   OUTPUT CLOSE.
END.

/**/
RETURN "OK":U.
