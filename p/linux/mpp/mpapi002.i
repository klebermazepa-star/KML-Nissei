{include/i_dbvers.i}
/***************************************************************************
** Programa: MPAPI002.i 
** Defini‡Æo das temp-tables padräes utilizadas para envio das mensagens
** para o Multiplanta
**************************************************************************/

def temp-table tt-control-env no-undo
       field cod-maq-origem      as integer format "9999"
       field num-processo        as integer format "999999999"
       field cod-usuario         as char    format "x(12)"
&IF "{&mguni_version}" >= "2.071" &THEN
       field cod-estabelec-dest  as char    format "x(05)" 
&ELSE
       field cod-estabelec-dest  as char    format "x(3)" 
&ENDIF
       field cd-lista-destino    as char    format "x(8)".
       
def temp-table tt-dados-env no-undo
       field num-sequencia       as integer format "999999"
       field cod-tipo-reg        as integer format "9999"   /* i01mp023.i */
       field ind-tipo-movto      as integer format "99"     /* i03mp011.i */
       field identif-msg         as char    format "x(60)"
       field conteudo-msg        as raw .    

def temp-table tt-destino-env no-undo
       field cod-estabel-dest    as char 
       field cod-maquina-dest    as integer
       field ind-tipo-destino    as int  /* 1 - cod-estabel 2 - maquina */
       field livre-1             as char
       field livre-2             as char.
       
