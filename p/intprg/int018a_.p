define input parameter c-cod-estabel as char.
define input parameter c-estado as char.
define input parameter c-cidade as char.
define input parameter c-condipag as char.
define input parameter c-convenio as char.
define input parameter c-class-fiscal as char.
define input parameter c-fm-cod-com as char.
define input parameter c-it-codigo as char.
define output parameter c-natureza as char.
define output parameter i-cod-cond-pag as integer.
define output parameter i-cod-portador as integer.
define output parameter i-modalidade as integer.
define output parameter r-rowid as rowid.

run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, c-convenio, c-class-fiscal, c-fm-cod-com, c-it-codigo,output r-rowid).

if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, c-convenio, c-class-fiscal, c-fm-cod-com, c-it-codigo,  output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, c-convenio, c-class-fiscal, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, ?, c-class-fiscal, c-fm-cod-com, c-it-codigo,  output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, c-convenio, ?, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, c-convenio, c-class-fiscal, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, c-convenio, c-class-fiscal, c-fm-cod-com,?, output r-rowid).

if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?,  ?, c-convenio, c-class-fiscal, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, ?, c-class-fiscal, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, c-convenio, ?, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, c-convenio, c-class-fiscal, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, c-convenio, c-class-fiscal, c-fm-cod-com,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, ?, c-class-fiscal, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, c-convenio, ?, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, c-convenio, c-class-fiscal, ?, c-it-codigo,output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, c-convenio, c-class-fiscal, c-fm-cod-com,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, ?, ?, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, ?, c-class-fiscal, c-fm-cod-com,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, ?, c-class-fiscal, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, c-convenio, ?, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, c-convenio, ?, c-fm-cod-com,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, c-convenio, c-class-fiscal, ?,?, output r-rowid).


if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, ?, c-class-fiscal, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, c-convenio, ?, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, c-convenio, c-class-fiscal, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, c-convenio, c-class-fiscal, c-fm-cod-com,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, ?, ?, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, ?, c-class-fiscal, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, ?, c-class-fiscal, c-fm-cod-com,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, c-convenio, ?, c-fm-cod-com,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, c-convenio, c-class-fiscal, ?,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, ?, ?, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, ?, c-class-fiscal, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, ?, c-class-fiscal, c-fm-cod-com,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, c-convenio, ?, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, c-convenio, ?, c-fm-cod-com, ?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, c-convenio, c-class-fiscal, ?, ?, output r-rowid).

if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, ?, ?, c-fm-cod-com, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, ?, c-class-fiscal, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, ?, c-class-fiscal, c-fm-cod-com, ?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, c-convenio, ?, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, c-convenio, ?, c-fm-cod-com,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, c-convenio, c-class-fiscal, ?,?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, ?, ?, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, ?, ?, c-fm-cod-com, ?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, ?, c-class-fiscal, ?, ?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, c-convenio, ?, ?, ?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, ?, ?, ?, c-it-codigo, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, ?, ?, c-fm-cod-com, ?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, ?, c-class-fiscal, ?, ?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, c-convenio, ?, ?, ?, output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, c-cidade, ?, ?, ?, ?, output r-rowid).

if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, ?, ?, ?, c-it-codigo,output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, ?, ?, c-fm-cod-com, ?,output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, ?, c-class-fiscal, ?, ?,output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, c-convenio, ?, ?, ?,output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, c-cidade, ?, ?, ?, ?,output r-rowid).
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, c-estado, ?, ?, ?, ?, ?,output r-rowid).
                                                                 
if r-rowid = ? then run pi-busca-int-ds-loja-natur-oper(c-cod-estabel,c-condipag, ?, ?, ?, ?, ?,?, output r-rowid).


procedure pi-busca-int-ds-loja-natur-oper:
    define input parameter c-cod-estabel as char.
    define input parameter c-condipag as char.
    define input parameter c-estado as char.
    define input parameter c-cidade as char.
    define input parameter c-convenio as char.
    define input parameter c-class-fiscal as char.
    define input parameter c-fm-cod-com as char.
    define input parameter c-it-codigo as char.
    define output parameter r-rowid as rowid.

    for first int-ds-loja-natur-oper no-lock where 
        int-ds-loja-natur-oper.cod-estabel = c-cod-estabel and
        int-ds-loja-natur-oper.condipag = c-condipag and
        int-ds-loja-natur-oper.estado = c-estado and
        int-ds-loja-natur-oper.cidade = c-cidade and
        int-ds-loja-natur-oper.convenio = c-convenio and
        int-ds-loja-natur-oper.class-fiscal = c-class-fiscal and
        int-ds-loja-natur-oper.fm-cod-com = c-fm-cod-com and
        int-ds-loja-natur-oper.it-codigo = c-it-codigo:
        
        assign r-rowid = rowid(int-ds-loja-natur-oper).
        assign c-natureza = int-ds-loja-natur-oper.nat-operacao
               i-cod-cond-pag = int-ds-loja-natur-oper.cod-cond-pag
               i-cod-portador = int-ds-loja-natur-oper.cod-portador
               i-modalidade = int-ds-loja-natur-oper.modalidade.
    end.

end.
