    /********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser  feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i tgr-d-tit-acr 2.06.00.001}  
/****************************************************************************************************
**  Programa ........: intprg/tgr-d-tit-acr.p
**  Data ............: Janeiro/2016
*****************************************************************************************************/
DEFINE PARAMETER BUFFER b_tit_acr FOR tit_acr.

DEFINE BUFFER cliente          FOR ems5.cliente.
DEFINE BUFFER bf_tit_acr       FOR tit_acr .

DEFINE NEW GLOBAL SHARED VARIABLE v_cod_empres_usuar AS CHARACTER FORMAT "x(3)":U NO-UNDO.

DEFINE VARIABLE iSeq AS INTEGER     NO-UNDO.


/* INICIO - Rotina para Desvincular o Titulo com as Duplicadas do Cart∆o/Loja */
FOR EACH cst_fat_duplic EXCLUSIVE-LOCK
   WHERE cst_fat_duplic.cod_estabel    = b_tit_acr.cod_estab
     AND cst_fat_duplic.num_id_tit_acr = b_tit_acr.num_id_tit_acr:

       ASSIGN cst_fat_duplic.num_id_tit_acr = ?.

       FIND FIRST fat-duplic 
            WHERE fat-duplic.cod-estabel  = cst_fat_duplic.cod_estabel
              AND fat-duplic.serie        = cst_fat_duplic.serie
              AND fat-duplic.nr-fatura    = cst_fat_duplic.nr_fatura
              AND fat-duplic.parcela      = cst_fat_duplic.parcela  EXCLUSIVE-LOCK NO-ERROR.
       IF AVAIL fat-duplic THEN DO:
           ASSIGN fat-duplic.flag-atualiz = NO.

           FIND FIRST nota-fiscal EXCLUSIVE-LOCK
                WHERE nota-fiscal.cod-estabel = fat-duplic.cod-estabel
                  AND nota-fiscal.serie       = fat-duplic.serie
                  AND nota-fiscal.nr-nota-fis = fat-duplic.nr-fatura   NO-ERROR.
           IF AVAIL nota-fiscal THEN DO:
               ASSIGN nota-fiscal.dt-atual-cr = ?.
           END.
       END.
END.

FOR EACH tit_acr_cartao
  WHERE tit_acr_cartao.cod_estab      = b_tit_acr.cod_estab      
    AND tit_acr_cartao.num_id_tit_acr = b_tit_acr.num_id_tit_acr EXCLUSIVE-LOCK:

   DELETE tit_acr_cartao.
END.

RELEASE fat-duplic.
RELEASE nota-fiscal.
RELEASE cst_fat_duplic.  
RELEASE tit_acr_cartao. 
/* FIM - Rotina para Desvincular o Titulo com as Duplicadas do Cart∆o/Loja */

/* INICIO - Envia o cancelamento da Fatura para o Sysfarma - Site */
IF b_tit_acr.cod_espec_docto           = "CF" THEN DO:
    /* INICIO - Grava a tabela pai do convànio */
    FIND FIRST int_ds_fat_convenio EXCLUSIVE-LOCK
         WHERE int_ds_fat_convenio.nro_fatura   = b_tit_acr.cod_tit_acr  NO-ERROR.
    IF  AVAIL int_ds_fat_convenio THEN DO:
        ASSIGN int_ds_fat_convenio.tipo_movto         = 3 
               int_ds_fat_convenio.situacao           = 1
               int_ds_fat_convenio.ENVIO_STATUS       = 1.
    END.
    /* FIM    - Grava a tabela pai do convànio */

/*     FIND FIRST renegoc_acr NO-LOCK                                                                                                    */
/*          WHERE renegoc_acr.num_renegoc_cobr_acr = b_tit_acr.num_renegoc_cobr_acr NO-ERROR.                                            */
/*     IF AVAIL renegoc_acr THEN DO:                                                                                                     */
/*                                                                                                                                       */
/*         FOR EACH estabelecimento NO-LOCK                                                                                              */
/*            WHERE estabelecimento.cod_empresa = v_cod_empres_usuar:                                                                    */
/*             movto_tit_block:                                                                                                          */
/*             for each movto_tit_acr no-lock                                                                                            */
/*                where movto_tit_acr.cod_estab           = estabelecimento.cod_estab                                                    */
/*                  and movto_tit_acr.cod_refer           = renegoc_acr.cod_refer                                                        */
/*                  and movto_tit_acr.ind_trans_acr_abrev = "LQRN" /*l_lqrn*/                                                            */
/*                 use-index mvtttcr_refer:                                                                                              */
/*                                                                                                                                       */
/*                 if movto_tit_acr.cod_estab_proces_bxa <> renegoc_acr.cod_estab then                                                   */
/*                     next movto_tit_block.                                                                                             */
/*                                                                                                                                       */
/*                 FIND FIRST bf_tit_acr use-index titacr_token                                                                          */
/*                      WHERE bf_tit_acr.cod_estab      = movto_tit_acr.cod_estab                                                        */
/*                        AND bf_tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr NO-ERROR.                                         */
/*                 IF AVAIL bf_tit_acr THEN DO:                                                                                          */
/*                                                                                                                                       */
/*                     ASSIGN iSeq = 0.                                                                                                  */
/*                     FOR LAST int-ds-canc-fat-conv-site NO-LOCK                                                                        */
/*                           BY int-ds-canc-fat-conv-site.id-canc-fat-conv-site:                                                         */
/*                         ASSIGN iSeq = int-ds-canc-fat-conv-site.id-canc-fat-conv-site + 1.                                            */
/*                     END.                                                                                                              */
/*                                                                                                                                       */
/*                     IF iSeq = 0 THEN ASSIGN iSeq = 1.                                                                                 */
/*                                                                                                                                       */
/*                     FIND FIRST int-ds-canc-fat-conv-site NO-LOCK                                                                      */
/*                          WHERE int-ds-canc-fat-conv-site.id-canc-fat-conv-site = iSeq  NO-ERROR.                                      */
/*                     IF NOT AVAIL int-ds-canc-fat-conv-site  THEN DO:                                                                  */
/*                                                                                                                                       */
/*                         FIND FIRST cliente NO-LOCK                                                                                    */
/*                              WHERE cliente.cdn_cliente = b_tit_acr.cdn_cliente NO-ERROR.                                              */
/*                                                                                                                                       */
/*                         FOR FIRST nota-fiscal NO-LOCK                                                                                 */
/*                             WHERE nota-fiscal.cod-estabel = bf_tit_acr.cod_estab                                                      */
/*                               AND nota-fiscal.serie       = bf_tit_acr.cod_ser_docto                                                  */
/*                               AND nota-fiscal.nr-nota-fis = bf_tit_acr.cod_tit_acr,                                                   */
/*                             FIRST cst-nota-fiscal OF nota-fiscal NO-LOCK:                                                             */
/*                                                                                                                                       */
/*                             CREATE int-ds-canc-fat-conv-site.                                                                         */
/*                             ASSIGN int-ds-canc-fat-conv-site.id-canc-fat-conv-site = iSeq.                                            */
/*                             ASSIGN int-ds-canc-fat-conv-site.cnpj               = IF AVAIL cliente THEN cliente.cod_id_feder ELSE ""  */
/*                                    int-ds-canc-fat-conv-site.cod-convenio       = INT(cst-nota-fiscal.convenio)                       */
/*                                    int-ds-canc-fat-conv-site.cod-estabel        = bf_tit_acr.cod_estab                                */
/*                                    int-ds-canc-fat-conv-site.dat-estorno        = TODAY                                               */
/*                                    int-ds-canc-fat-conv-site.nro-cupom          = bf_tit_acr.cod_tit_acr                              */
/*                                    int-ds-canc-fat-conv-site.parcela            = bf_tit_acr.cod_parcela                              */
/*                                    int-ds-canc-fat-conv-site.nro-fatura         = b_tit_acr.cod_tit_acr                               */
/*                                    int-ds-canc-fat-conv-site.situacao           = 1.                                                  */
/*                         END.                                                                                                          */
/*                     END.                                                                                                              */
/*                 END.                                                                                                                  */
/*             END.                                                                                                                      */
/*         END.                                                                                                                          */
/*     END.                                                                                                                              */
END.
/* FIM - Envia o cancelamento da Fatura para o Sysfarma - Site */





RETURN "OK":U.

