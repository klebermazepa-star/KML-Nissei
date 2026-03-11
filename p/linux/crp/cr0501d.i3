/*---------------------------------------------------------
 *  Include para verificar valores de juros/multa
 *
 *  1 - Data de transaá∆o ou data base quando consulta
 *  2 - Vari†vel percentual de juros
 *  3 - Vari†vel carencia de juros
 *  4 - Vari†vel de valor m°nimo
 *  5 - Vari†vel l¢gica se gera ou n∆o Aviso de DÇbito
 *  6 - Vari†vel percentual de multa
 *  7 - Vari†vel carencia de multa
 *  8 - Vari†vel que define de Emite DP ou Remessa Banco 
 *  9 - Vari†vel de moeda do valor m°nimo
 ----------------------------------------------------------*/

for each juros-empresa-cr no-lock
    where juros-empresa-cr.ep-codigo = i-ep-codigo-usuario:

    if  {1} < juros-empresa-cr.dt-valid-inic
    or  {1} > juros-empresa-cr.dt-valid-fin then do:
        assign {2}                = 0
               {3}                = 0
               {4}                = 0
               {5}                = yes
               {6}                = 0
               {7}                = 0
               {8}                = 1
               {9}                = 0
               l-existe-tab-juros = no.
        next.
    end.    
    else do:
        assign {2}                = juros-empresa-cr.perc-juros 
               {3}                = juros-empresa-cr.car-juros
               {4}                = juros-empresa-cr.dec-1
               {5}                = juros-empresa-cr.gera-ad
               {6}                = juros-empresa-cr.perc-multa
               {7}                = juros-empresa-cr.dias-carencia-multa
               {8}                = juros-empresa-cr.tp-juros-mora
               {9}                = juros-empresa-cr.mo-vl-min
               l-existe-tab-juros = yes.
        leave.
    end.           
end.

