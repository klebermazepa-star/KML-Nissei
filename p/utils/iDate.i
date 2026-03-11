/***
*
* PROGRAMA:
*   iDate.i
*
* FINALIDADE:
*   Implementaá∆o das funá‰es para manipulaá∆o de datas.
*
* NOTAS:
*   Para ver a declaraá∆o dessas funá‰es, consulte a include pDate.i
*
* VERSOES:
*   12/07/2002, ljohann, criacao  
*
*/

/* soma i-meses a data passada */
function fnAddMonth returns date.
    define variable da-nova-data as date no-undo.
    define variable i-cont as integer initial 1 no-undo.

    if i-meses <> 0 then do:
        /* para trabalhar, monta a data em outra vari†vel. Usa o dia 20 para evitar
           que estoure para outro màs ao somar 30 dias. */
        assign da-nova-data = date("20/" + string(month(da-data)) + "/" + string(year(da-data))).

        /* soma os meses necess†rios */
        do while i-cont <= absolute(i-meses):
            assign i-cont = i-cont + 1.
            assign da-nova-data = da-nova-data + if i-meses > 0 then 30 else -30.

            /* por medida de seguranáa, assume novamente o dia 20, pois quando i-meses
               Ç muito grande, podem ocorrer oscilaá‰es grandes durante as somas repetidas
               de 30 dias */
            assign da-nova-data = date("20/" + string(month(da-nova-data)) + "/" + string(year(da-nova-data))).
        end.

        /* o dia da data original Ç £ltimo dia do màs? */
        if day(da-data) = day(fnLastDay(da-data)) then do:
            assign da-data = fnLastDay(da-nova-data).
        end.
        else do:
            if ( month(da-nova-data) = 2 ) and
               ( day(da-data) > day(fnLastDay(da-nova-data)) ) then do:
                /* màs de fevereiro e dia original maior do que 28 ou 29:
                   assume o £ltimo dia do màs de fevereiro */
                assign da-data = fnLastDay(da-nova-data).
            end.
            else do:
                /* como n∆o Ç o màs de fevereiro, assume o dia da data original */
                assign da-data = date(string(day(da-data)) + "/" +
                                      string(month(da-nova-data)) + "/" +
                                      string(year(da-nova-data))).
            end.
        end.
    end.

    return da-data.
end function.

/* Retorna o primeiro dia do màs da data passada */
function fnFirstDay returns date.
    return date("01/" + string(month(da-data)) + "/" + string(year(da-data))).
end function.

/* Retorna o £ltimo dia do màs da data passada */
function fnLastDay returns date.
    define variable da-nova-data as date no-undo.
    assign da-nova-data = date("20/" + string(month(da-data)) + "/" + 
                               string(year(da-data))).
    return date("01/" + string(month(da-nova-data + 30)) +
                "/" + string(year(da-nova-data + 30))) - 1.
end function.
