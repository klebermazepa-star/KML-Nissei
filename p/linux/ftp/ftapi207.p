/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i FTAPI207 2.00.00.004}  /*** 010004 ***/

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
{include/i-license-manager.i FTAPI207 MUT}
&ENDIF

/***************************************************************************
** 
** Programa: FTAPI207.P
** 
** Objetivo:  Respons vel por receber as temp-tables do Multiplanta 
**           (da MPAPI003) com as mensagens da transa‡Æo 
**           "Contas a Receber", gravando as temp-tables padräes 
**           da API de efetiva‡Æo das tabelas na base do Magnus
**
***************************************************************************/
          
{cdp/cd7302.i1}
{ftp/ftapi207.i} 

assign i-versao-integ = 001. 
       
{cdp/cd7302.i2 DIS018}

    for each tt-dados-rec no-lock where 
             tt-dados-rec.cod-maq-origem = tt-control-rec.cod-maq-origem and
             tt-dados-rec.num-processo   = tt-control-rec.num-processo: 
        if  tt-dados-rec.cod-tipo-reg <> 76 then do:
            run utp/ut-msgs.p (input "msg",
                               input 4472,
                               input "").
            create tt-erros-rec.
            assign tt-erros-rec.cod-maq-origem     = tt-control-rec.cod-maq-origem
                   tt-erros-rec.num-processo       = tt-control-rec.num-processo
                   tt-erros-rec.num-sequencia      = tt-dados-rec.num-sequencia
                   tt-erros-rec.num-sequencia-erro = 1
                   tt-erros-rec.cod-erro = 4472
                   tt-erros-rec.des-erro = return-value.
            next.                      
        end.
        else do:  
            create tt-parametros-aux.
            raw-transfer tt-dados-rec.conteudo-msg to tt-parametros-aux.
            create tt-parametros.
            buffer-copy tt-parametros-aux to tt-parametros
                assign tt-parametros.cod-maq-origem = tt-dados-rec.cod-maq-origem
                       tt-parametros.num-processo   = tt-dados-rec.num-processo
                       tt-parametros.num-sequencia  = tt-dados-rec.num-sequencia
                       tt-parametros.ind-tipo-movto = tt-dados-rec.ind-tipo-movto
                no-error.  
        end.    
    end.
    assign tt-control-rec.dat-atualiz-base     = today
           tt-control-rec.hra-atualiz-base     = string(time,"HH:MM:SS")
           tt-control-rec.ind-situacao-atualiz = 1
           tt-control-rec.ind-situacao-erro    = 1.      
end.   

create tt-versao-integr.
assign tt-versao-integr.cod-versao-integracao = 001
       tt-versao-integr.ind-origem-msg        = 01.

run ftp/ftapi307.p (input  table tt-versao-integr,
                    output table tt-erros-geral,
                    input  table tt-parametros).   

{cdp/cd7302.i3}

/********Fim Programa**********/
