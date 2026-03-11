/******************************************************************************
**
**  Include.: CD9600.I
**
**  Objetivo: Buscar a Cotacao de Uma moeda em determinada data.
**  DP - O include passa a testar se a taxa a ser retornada e igual a zero, e
**       acusa o erro, dando a possibilidade de desfazer a transacao.
**     - Para desfazer, passar o parametro 4 como undo,retry.  
**     - Inclu¡do parƒmetro {5} que indicar  como ser  tratada a mensagem de 
**       erro. Se for informado "msg", o conte£do da mensagem de erro estar  no 
**       return-value. Caso o parƒmetro nÆo seja informado ou seja informado 
**       com "show" a mensagem ser  mostrada na tela.
**
******************************************************************************/

if  {1} <> 0 then do:
    find cotacao
        where cotacao.mo-codigo   = {1}
        and   cotacao.ano-periodo = string(year({2})) + string(month({2}),"99")
        and   cotacao.cotacao[int(day({2}))] <> 0 no-lock no-error.
    if  avail cotacao then
        assign {3} = cotacao.cotacao[int(day({2}))].
 
    if  {3} = 0 then do:
        &if  "{5}" <> "msg" 
             &then run utp/ut-msgs.p (input "show",
                                      input 1175,
                                      input string({1}) + "~~" + string({2},"99/99/9999")).
             &else run utp/ut-msgs.p (input "msg",
                                      input 1175,
                                      input string({1}) + "~~" + string({2},"99/99/9999")).
        &endif. 
        {4}
    end.
end.
else do:
    assign {3} = 1.
end.

/* CD9600.I */
