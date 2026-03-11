 /****************************************************************************************************
**   Programa: trg-w-cheque-acr.p - Trigger de write para a tabela cheque_acr
**             
**   Data....: Fevereiro/2016
*****************************************************************************************************/
DEF PARAM BUFFER b_chequ_acr     FOR cheq_acr.
DEF PARAM BUFFER b_old_chequ_acr FOR cheq_acr.

DEFINE BUFFER cliente  FOR ems5.cliente.
DEFINE VARIABLE idSeq AS INTEGER  INITIAL "0"  NO-UNDO.

/* Envio das informa‡äes de Cheque para o Sysfarma */
IF b_old_chequ_acr.log_cheq_acr_devolv = NO  AND 
   b_chequ_acr.log_cheq_acr_devolv     = YES THEN DO:

   FOR LAST int_ds_cheque_dev NO-LOCK:
       ASSIGN idSeq = int_ds_cheque_dev.id_seq + 1.
   END.

   IF idSeq = 0 THEN ASSIGN idSeq = 1.

   FIND FIRST int_ds_cheque_dev NO-LOCK
        WHERE int_ds_cheque_dev.id_seq = idSeq NO-ERROR.
   IF NOT AVAIL int_ds_cheque_dev THEN DO:
       CREATE int_ds_cheque_dev.
       ASSIGN int_ds_cheque_dev.id_seq = idSeq.

       ASSIGN int_ds_cheque_dev.cod_agenc_bcia = b_chequ_acr.cod_agenc_bcia 
              int_ds_cheque_dev.cod_banco      = b_chequ_acr.cod_banco
              int_ds_cheque_dev.cod_cta_corren = b_chequ_acr.cod_cta_corren_bco
              int_ds_cheque_dev.cod_estabel    = b_chequ_acr.cod_estab
              int_ds_cheque_dev.dat_compensa   = TODAY
              int_ds_cheque_dev.num_cheque     = b_chequ_acr.num_cheque
              int_ds_cheque_dev.situacao       = 1
              int_ds_cheque_dev.obs_devolucao  = b_chequ_acr.cod_motiv_devol_cheq.
           .    

       FIND FIRST cliente NO-LOCK
            WHERE cliente.num_pessoa = b_chequ_acr.num_pessoa NO-ERROR.
       IF AVAIL cliente THEN
           ASSIGN int_ds_cheque_dev.cpf_cliente = cliente.cod_id_feder.

       FIND FIRST estabelecimento NO-LOCK
            WHERE estabelecimento.cod_estab = b_chequ_acr.cod_estab NO-ERROR.
       IF AVAIL estabelecimento THEN
           ASSIGN int_ds_cheque_dev.cnpj_estab = estabelecimento.cod_id_feder.
   END.
END.

RETURN "OK".
