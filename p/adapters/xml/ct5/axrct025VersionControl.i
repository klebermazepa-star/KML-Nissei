
     /* FAZER AQUI TRATAMENTO DE CONTROLE DE VERSÇO ADEQUADO! */

     /* ********* EXECU€ÇO DAS PI - BEGIN ********* */
     IF (cTranAction = "add") or (cTranAction = "upd") THEN DO:
          RUN PIUpsert.
     /* AQUI!! IMPLEMENTAR A CHAMADA A API DE EFETIVA€ÇO */
     END.
     IF (cTranAction = "del") THEN DO:
          RUN PIDelete.
     /* AQUI!! IMPLEMENTAR A CHAMADA A API DE EFETIVA€ÇO */
     END.


     /*ALIMENTA€ÇO DOS ERROS OCORRIDOS NA EFETIVA€ÇO*/
     FOR EACH tt_log_erro:
          /* INFORMA AO MESSAGE HANDLER UM ERRO QUE DEVE ESTAR PRESENTE NA MENSAGEM DE RETORNO */
          RUN setError IN hMessageHandler (INPUT tt_log_erro.ttv_num_cod_erro, INPUT "business_error", INPUT tt_log_erro.ttv_des_msg_erro + " Arquivo: " + v_nom_arquivo).
     END.


     /* OBTEM UMA MENSAGEM DE RETORNO - SENDO ELA DE ERRO OU DE CONFIRMA€ÇO */
     RUN getReturnMessage IN hMessageHandler (OUTPUT hOutputXML).
     /* ********* EXECU€ÇO DAS PI - END ********* */


