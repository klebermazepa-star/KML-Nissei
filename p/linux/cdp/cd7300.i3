{include/i_dbvers.i}
/*******************************************************************************
**
**   cd7300.i3: Prepara chamada da MPAPI001 que verifica se a transacao
**              deve ser replicada para alguma maquina remota, alem de
**              obter o codigo da maquina local.    
**              DEVE SER USADO SOMENTE QUANDO OS ERROS FOREM EMITIDOS EM 
**              RELATORIO.
**
**              {1} - Vers∆o de Integraá∆o
**              {2} - C¢digo da Transaá∆o
**              {3} - Diferenciaá∆o das Temp-Tables
**                    Exemplo:  tt-replica-msg{-aux1}
**                              tt-dados-env{-aux1}
**                              tt-integracao{-aux1}
**                              tt-control-env{-aux1}
**                              tt-destino-env{-aux1}
*********************************************************************************/

find first param-global no-lock no-error.
&IF "{&mguni_version} " < "2.08" &THEN 
        if  param-global.modulo-mp
        then do:
            assign i-seq = 1.
            create tt-integracao{3}.
            assign tt-integracao{3}.cod-versao-integracao = {1}
                   tt-integracao{3}.cod-transacao         = {2}.
        
            run mpp/mpapi001.p (output       table tt-replica-msg{3},
                                input-output table tt-integracao{3}).
        
            find first tt-replica-msg{3} no-lock no-error.
            assign i-maq-local = if   avail tt-replica-msg{3}
                                 then tt-replica-msg{3}.cd-maquina-local
                                 else 0.
            
            find first tt-integracao{3} no-lock no-error.
            if  return-value = "NOK" then do:
                disp tt-integracao{3}.cod-erro      @ i-erro
                     tt-integracao{3}.desc-erro     @ c-desc-erro
                     tt-integracao{3}.conteudo-erro @ c-conteudo
                     with stream-io frame f-cabec-erro.
                return error.
            end. 
        end.    
        else assign i-maq-local = 0.
        
/**** Descontinuaá∆o do m¢dulo multiplanta ****/ 
&else
   create   tt-replica-msg{3}.
   assign   tt-replica-msg{3}.log-replica-msg  = false
            tt-replica-msg{3}.cd-maquina-local =  0.         
&ENDIF
/*** Fim do Include ***/
