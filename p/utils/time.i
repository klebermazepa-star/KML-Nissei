/**
*
* INCLUDE:
*   utils/time.i
*
* FINALIDADE:
*   Rotinas para tratamento de tempo/horas.
*
* VERSOES:
*   28/05/2003, Leandro Johann, criacao
*   16/06/2003, Marcio Fuckner, fnDateTimeDiff e fnSecsToFracTime
*/

/***
*
* Converte uma string com formato 99:99:99 em um inteiro, com
* o total de segundos representado pela string.
*
*/
function fnCharToTime returns integer
    (input c-time as character):

    return ( integer(entry(1,c-time,":")) * 3600 ) + 
           ( integer(entry(2,c-time,":")) * 60 ) +
           ( if num-entries(c-time,":") = 3 then integer(entry(3,c-time,":")) else 0).
end function.

/***
*
* Converte um inteiro (de acordo com o valor retornado pela
* funcao Time()) em sua representacao de hora, no formato
* 99:99:99. 
*
*/
function fnTimeToChar returns character
    (input i-time as integer):

    define variable i-horas     as integer no-undo.
    define variable i-minutos   as integer no-undo.
    define variable i-segundos  as integer no-undo.

    assign i-horas    = trunc(i-time / 3600, 0)
           i-minutos  = trunc( ( i-time - i-horas * 3600 ) / 60, 0) 
           i-segundos = ( i-time - ( i-horas * 3600 ) ) - ( i-minutos * 60 ).

    return string(i-horas, if i-horas < 99 then "99:" else "999:") + string(i-minutos, "99:") + string(i-segundos, "99").
end function.

/***
*
* Retorna a diferen‡a em segundos entre uma data e hora inicial e final.
*
*/

function fnDateTimeDiff returns integer
    (input da-start as date,
     input hr-start as char,
     input da-end   as date,
     input hr-end   as char):

   def var i-dif as integer no-undo.

   assign i-dif = (da-end - da-start) * 24 * 3600
          i-dif = i-dif + fnCharToTime(hr-end) - fnCharToTime(hr-start).

   return i-dif.

end function.

/***
*
* Transforma o numero de segundos em hora fracionada
*
*/

function fnSecsToFracTime returns decimal
    (input i-secs as int):

   return decimal(i-secs / 3600).

end function.
