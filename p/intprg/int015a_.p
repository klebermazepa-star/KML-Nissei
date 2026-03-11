define input parameter c-cod-estabel as char.
define input parameter c-tp-pedido as char.
define input parameter c-estado as char.
define input parameter c-cidade as char.
define input parameter i-emitente as char.
define input parameter c-class-fiscal as char.
define input parameter c-fm-cod-com as char.
define input parameter c-it-codigo as char.
define output parameter c-natureza as char.
define output parameter i-cod-cond-pag as integer.
define output parameter r-rowid as rowid.

run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, i-emitente, c-class-fiscal, c-fm-cod-com, c-it-codigo,output r-rowid).

if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, i-emitente, c-class-fiscal, c-fm-cod-com, c-it-codigo,  output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, i-emitente, c-class-fiscal, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, 0, c-class-fiscal, c-fm-cod-com, c-it-codigo,  output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, i-emitente, "", c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, i-emitente, c-class-fiscal, "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, i-emitente, c-class-fiscal, c-fm-cod-com,"", output r-rowid).

if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "",  0, i-emitente, c-class-fiscal, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, 0, c-class-fiscal, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, i-emitente, "", c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, i-emitente, c-class-fiscal, "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, i-emitente, c-class-fiscal, c-fm-cod-com,"", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, 0, c-class-fiscal, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, i-emitente, "", c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, i-emitente, c-class-fiscal, "", c-it-codigo,output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, i-emitente, c-class-fiscal, c-fm-cod-com,"", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, 0, "", c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, 0, c-class-fiscal, c-fm-cod-com,"", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, 0, c-class-fiscal, "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, i-emitente, "", "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, i-emitente, "", c-fm-cod-com,"", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, i-emitente, c-class-fiscal, "","", output r-rowid).


if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, 0, c-class-fiscal, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, i-emitente, "", c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, i-emitente, c-class-fiscal, "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, i-emitente, c-class-fiscal, c-fm-cod-com,"", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, 0, "", c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, 0, c-class-fiscal, "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, 0, c-class-fiscal, c-fm-cod-com,"", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, i-emitente, "", c-fm-cod-com,"", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, i-emitente, c-class-fiscal, "","", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, 0, "", c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, 0, c-class-fiscal, "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, 0, c-class-fiscal, c-fm-cod-com,"", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, i-emitente, "", "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, i-emitente, "", c-fm-cod-com, "", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, i-emitente, c-class-fiscal, "", "", output r-rowid).

if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, 0, "", c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, 0, c-class-fiscal, "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, 0, c-class-fiscal, c-fm-cod-com, "", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, i-emitente, "", "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, i-emitente, "", c-fm-cod-com,"", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, i-emitente, c-class-fiscal, "","", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, 0, "", "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, 0, "", c-fm-cod-com, "", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, 0, c-class-fiscal, "", "", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, i-emitente, "", "", "", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, 0, "", "", c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, 0, "", c-fm-cod-com, "", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, 0, c-class-fiscal, "", "", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, 0, i-emitente, "", "", "", output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, c-cidade, 0, "", "", "", output r-rowid).

if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", "", "", "", "", c-it-codigo,output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", "", "", "", c-fm-cod-com, "",output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", "", "", c-class-fiscal, "", "",output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", "", i-emitente, "", "", "",output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", c-cidade, "", "", "", "",output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, c-estado, "", "", "", "", "",output r-rowid).
                                                                 
if r-rowid = ? then run pi-busca-int-ds-tp-natur-oper(c-cod-estabel,c-tp-pedido, "", 0, 0, "", "","", output r-rowid).


procedure pi-busca-int-ds-tp-natur-oper:
    define input parameter c-cod-estabel as char.
    define input parameter c-tp-pedido as char.
    define input parameter c-estado as char.
    define input parameter c-cidade as char.
    define input parameter i-emitente as integer.
    define input parameter c-class-fiscal as char.
    define input parameter c-fm-cod-com as char.
    define input parameter c-it-codigo as char.
    define output parameter r-rowid as rowid.

    for first int-ds-tp-natur-oper no-lock where 
        int-ds-tp-natur-oper.cod-estabel = c-cod-estabel and
        int-ds-tp-natur-oper.tp-pedido = c-tp-pedido and
        int-ds-tp-natur-oper.estado = c-estado and
        int-ds-tp-natur-oper.cidade = c-cidade and
        int-ds-tp-natur-oper.cod-emitente = i-emitente and
        int-ds-tp-natur-oper.class-fiscal = c-class-fiscal and
        int-ds-tp-natur-oper.fm-cod-com = c-fm-cod-com and
        int-ds-tp-natur-oper.it-codigo = c-it-codigo:
        
        assign r-rowid = rowid(int-ds-tp-natur-oper).
        assign c-natureza = int-ds-tp-natur-oper.nat-operacao
               i-cod-cond-pag = int-ds-tp-natur-oper.cod-cond-pag.
    end.

end.
