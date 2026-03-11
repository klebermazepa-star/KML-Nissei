/* utils/fnSituacaoNotaSaida.i
 
   retorna situacao da nota fiscal de saida no formato IECFOAT
   
*/


function fnSituacaoNotaSaida returns char (buffer nota-fiscal for nota-fiscal):
    define variable situacao as character   no-undo.

    assign situacao = ''.
    assign situacao = if nota-fiscal.ind-sit-nota > 1            then 'S' else 'N'
           situacao = situacao + if nota-fiscal.dt-confirm <> ?  then 'S' else 'N'
           situacao = situacao + if nota-fiscal.dt-cancela <> ?  then 'S' else 'N'
           situacao = situacao + if nota-fiscal.dt-atual-cr <> ? then 'S' else 'N' 
           situacao = situacao + if nota-fiscal.dt-at-ofest <> ? then 'S' else 'N'
           situacao = situacao + if nota-fiscal.dt-at-est <> ?   then 'S' else 'N'
           situacao = situacao + if nota-fiscal.ind-contabil     then 'S' else 'N'. 

    return situacao.
end function.
