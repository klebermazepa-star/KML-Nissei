/* fnDecToTime.i : converte decimal 2,2 em time (segundos desde 00:00:00) 
   ex.: 18,30 = 18:18 = 65880 segundos
*/

function fnDecToTime returns integer (nHoraDec as decimal):

    return int(nHoraDec * 3600).

end.
