TRIGGER PROCEDURE FOR WRITE OF int_ds_nota_saida OLD BUFFER b-int_ds_nota_saida.

if int_ds_nota_saida.envio_status = 3 then do:

   CREATE int_ds_log.
   ASSIGN int_ds_log.origem          = "ECOM Retor"
          int_ds_log.chave           = string(int_ds_nota_saida.nsa_cnpj_origem_s + "|" + int_ds_nota_saida.nsa_serie_s + "|" + string(int_ds_nota_saida.nsa_notafiscal_n))
          int_ds_log.situacao        = 1 /* Pendente */ 
          int_ds_log.desc_ocorrencia = string(int_ds_nota_saida.envio_erro)
          int_ds_log.dt_ocorrencia   = date(string(TODAY,"99/99/9999"))
          int_ds_log.hr_ocorrencia   = STRING(TIME,"HH:MM:SS")
          int_ds_log.cod_usuario     = "procfit"
          int_ds_log.cod_programa    = "Procfit"
          int_ds_log.ENVIO_STATUS    = 1
          int_ds_log.ENVIO_DATA_HORA = datetime(today).
          int_ds_log.id_sequencial   = NEXT-VALUE(seq-int-ds-log).

end.
