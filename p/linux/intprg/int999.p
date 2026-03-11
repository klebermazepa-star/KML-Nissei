/******************************************************************
**
**  Programa: int999.p - Atualizar a tabela de Logs de Integra‡Æo
**                       Datasul x PRS/Procfit
**
******************************************************************/

DEF INPUT PARAM p-origem          AS CHAR NO-UNDO.
DEF INPUT PARAM p-chave           AS CHAR NO-UNDO.
DEF INPUT PARAM p-desc-ocorrencia AS CHAR NO-UNDO.
DEF INPUT PARAM p-situacao        AS INT  NO-UNDO.
DEF INPUT PARAM p-cod-usuario     AS CHAR NO-UNDO.
DEF INPUT PARAM p-cod-programa    AS CHAR NO-UNDO.

def buffer b-int_ds_log for int_ds_log.

IF p-situacao = 2 THEN DO: /* Integrado */
   CREATE int_ds_log.
   ASSIGN int_ds_log.origem          = p-origem
          int_ds_log.chave           = p-chave
          int_ds_log.situacao        = p-situacao
          int_ds_log.desc_ocorrencia = p-desc-ocorrencia
          int_ds_log.dt_ocorrencia   = date(string(TODAY,"99/99/9999"))
          int_ds_log.hr_ocorrencia   = STRING(TIME,"HH:MM:SS")
          int_ds_log.cod_usuario     = p-cod-usuario
          int_ds_log.cod_programa    = p-cod-programa.
          
   release int_ds_log.

   if p-origem = "CLI" then do:
      for each int_ds_cliente use-index cgc where
               int_ds_cliente.cgc      = p-chave and
               int_ds_cliente.situacao = 1 QUERY-TUNING(NO-LOOKAHEAD):
          delete int_ds_cliente.
      end.
   end.
END.

IF p-situacao = 1 THEN DO: /* Pendente */
   for first int_ds_log_aux USE-INDEX orig_ch_sit_prog WHERE
             int_ds_log_aux.origem          = p-origem       AND 
             int_ds_log_aux.chave           = p-chave        AND 
             int_ds_log_aux.situacao        = p-situacao     AND 
             int_ds_log_aux.cod_programa    = p-cod-programa AND
             int_ds_log_aux.desc_ocorrencia = p-desc-ocorrencia QUERY-TUNING(NO-LOOKAHEAD):     
   end.

   IF NOT AVAIL int_ds_log_aux THEN DO:   
      CREATE int_ds_log_aux.
      ASSIGN int_ds_log_aux.origem          = p-origem
             int_ds_log_aux.chave           = p-chave
             int_ds_log_aux.situacao        = p-situacao
             int_ds_log_aux.cod_programa    = p-cod-programa
             int_ds_log_aux.desc_ocorrencia = p-desc-ocorrencia
             int_ds_log_aux.dt_ocorrencia   = date(string(TODAY,"99/99/9999"))
             int_ds_log_aux.hr_ocorrencia   = STRING(TIME,"HH:MM:SS")
             int_ds_log_aux.cod_usuario     = p-cod-usuario. 
             
      /* SM - Melhorias Mensagens de Integra‡äes - Relacionamento Usu rio Respons vel */
      FOR FIRST  int_ds_msg_usuario NO-LOCK
          WHERE  int_ds_msg_usuario.origem  = int_ds_log_aux.origem 
            AND (int_ds_log_aux.desc_ocorrencia MATCHES "*" + TRIM(int_ds_msg_usuario.mensagem) + "*" 
             OR  int_ds_log_aux.desc_ocorrencia BEGINS        TRIM(int_ds_msg_usuario.mensagem)) QUERY-TUNING(NO-LOOKAHEAD):

          ASSIGN int_ds_log_aux.cod_usuario_msg = int_ds_msg_usuario.cod_usuario.
      END.
      /* SM - Melhorias Mensagens de Integra‡äes - Relacionamento Usu rio Respons vel */

   END.
   ELSE DO:
      ASSIGN int_ds_log_aux.dt_ocorrencia = date(string(TODAY,"99/99/9999"))
             int_ds_log_aux.hr_ocorrencia = STRING(TIME,"HH:MM:SS")
             int_ds_log_aux.cod_usuario   = p-cod-usuario.

      /* SM - Melhorias Mensagens de Integra‡äes - Relacionamento Usu rio Respons vel */
      FOR FIRST  int_ds_msg_usuario NO-LOCK
          WHERE  int_ds_msg_usuario.origem  = int_ds_log_aux.origem 
            AND (int_ds_log_aux.desc_ocorrencia MATCHES "*" + TRIM(int_ds_msg_usuario.mensagem) + "*" 
             OR  int_ds_log_aux.desc_ocorrencia BEGINS        TRIM(int_ds_msg_usuario.mensagem)) QUERY-TUNING(NO-LOOKAHEAD):

          ASSIGN int_ds_log_aux.cod_usuario_msg = int_ds_msg_usuario.cod_usuario.
      END.
      /* SM - Melhorias Mensagens de Integra‡äes - Relacionamento Usu rio Respons vel */
   END.

   release int_ds_log_aux.
   
END.



