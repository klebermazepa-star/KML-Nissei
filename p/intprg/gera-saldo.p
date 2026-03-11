form with frame xxx.
pause 0 before-hide.
{cep/ceapi001.i}
{cdp/cd0666.i}
output to t:\itens.txt.
def var de-qtde as decimal no-undo.
for first estab-mat 
    fields (conta-transf cod-emitente conta-fornec cod-estabel)
    no-lock where 
    estab-mat.cod-estabel = "001". end.

for first estabelec 
    fields (cod-estabel ep-codigo)
    no-lock where
    estabelec.cod-estabel = "001". end.

for first conta-contab 
    fields (conta-contabil ep-codigo estoque 
            ct-codigo sc-codigo)
    no-lock where 
    conta-contab.conta-contabil = estab-mat.conta-transf and 
    conta-contab.ep-codigo      = estabelec.ep-codigo. end.
/*display estab-mat.conta-transf estab-mat.conta-fornec.*/

for each int-ds-nota-loja-item no-lock
    break by int-ds-nota-loja-item.lote
            by int-ds-nota-loja-item.produto:
    
    if first-of(int-ds-nota-loja-item.produto) then do:
        assign de-qtde = 0.
    end.

    assign de-qtde = de-qtde + int-ds-nota-loja-item.quantidade.

    if last-of(int-ds-nota-loja-item.produto) then do:
    
        for first item 
            fields (it-codigo un tipo-contr)
            no-lock where 
            item.it-codigo = trim(string(int(int-ds-nota-loja-item.produto))). 
            
            if not can-find (first movto-estoq no-lock where
                   movto-estoq.cod-estabel           = "001"           and
                   movto-estoq.dt-trans              = 01/01/2016      and
                   movto-estoq.esp-docto             = 5 /* dev */     and
                   movto-estoq.serie-docto           = ""              and
                   movto-estoq.it-codigo             = item.it-codigo  and
                   movto-estoq.cod-localiz           = ""              and
                   movto-estoq.lote                  = if trim(int-ds-nota-loja-item.lote) <> ? then trim(int-ds-nota-loja-item.lote) else "")
            then do:                   
            
               
                display int-ds-nota-loja-item.produto
                        de-qtde
                        item.it-codigo
                        lote
                        with down frame xxx.
                down with frame xxx. 
                for each tt-movto:
                    delete tt-movto.
                end.
            
                create tt-movto.
                assign tt-movto.cod-versao-integracao = 1
                       tt-movto.cod-prog-orig         = 'INT020'
                       tt-movto.cod-depos             = "LOJ"
                       tt-movto.cod-emitente          = 0
                       tt-movto.cod-estabel           = "001"
                       tt-movto.dt-trans              = 01/01/2016
                       tt-movto.esp-docto             = 5 /* dev */
                       tt-movto.serie-docto           = ""
                       tt-movto.nro-docto             = "2"
                       tt-movto.it-codigo             = item.it-codigo
                       tt-movto.cod-localiz           = ""
                       tt-movto.lote                  = if trim(int-ds-nota-loja-item.lote) <> ? then trim(int-ds-nota-loja-item.lote) else ""
                       tt-movto.quantidade            = de-qtde
                       tt-movto.tipo-trans            = 1
                       tt-movto.un                    = item.un
                       tt-movto.conta-contabil        = '91107002'
                       tt-movto.ct-codigo             = '91107002'
                       tt-movto.conta-db              = '91102040'
                       tt-movto.ct-db                 = '91102040'
                       tt-movto.sc-db                 = ''
                       tt-movto.sequen-nf             = 0
                       tt-movto.dt-vali-lote          = 12/31/2099
                       tt-movto.nat-operacao          = "".
         
                /*
                if  avail conta-contab then
                    assign tt-movto.ct-codigo = conta-contab.ct-codigo
                           tt-movto.sc-codigo = conta-contab.sc-codigo.
         
                if  item.tipo-contr = 1 or item.tipo-contr = 4 then do:
                    for first conta-contab 
                        fields (conta-contabil ep-codigo estoque 
                                ct-codigo sc-codigo)
                        no-lock where 
                        conta-contab.conta-contabil = estab-mat.conta-fornec and 
                        conta-contab.ep-codigo      = estabelec.ep-codigo. end.
                    if avail conta-contab then
                       assign tt-movto.ct-db    = conta-contab.ct-codigo
                              tt-movto.sc-db    = conta-contab.sc-codigo
                              tt-movto.conta-db = estab-mat.conta-fornec.
                end.   
                */
                
                run cep/ceapi001.p (input-output table tt-movto,
                                    input-output table tt-erro,
                                    input yes).
    
                for each tt-movto:
                    delete tt-movto.
                end.
                for each tt-erro:
                    display tt-erro with width 300. 
                end. 
            end.                                               
        end.
    end.
end.
output close.
