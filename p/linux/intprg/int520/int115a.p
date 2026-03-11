define input  parameter c-tp-pedido      as char no-undo.
define input  parameter c-uf-destino     as char no-undo.
define input  parameter c-uf-origem      as char no-undo.
define input  parameter i-cod-emitente   as integer no-undo.
define input  parameter c-class-fiscal   as char no-undo.
define output parameter c-nat-saida      as char no-undo.
define output parameter c-nat-entrada    as char no-undo.
define output parameter r-rowid          as rowid.


c-nat-saida      = "".
c-nat-entrada    = "".
r-rowid          = ?.

for first emitente no-lock where 
    emitente.cod-emitente = i-cod-emitente: end.
if not avail emitente then return "NOK".


if r-rowid = ? then
    for each int-ds-tp-trib-natur-oper no-lock where 
        int-ds-tp-trib-natur-oper.tp-pedido    = c-tp-pedido and
        int-ds-tp-trib-natur-oper.uf-origem    = c-uf-origem and
        int-ds-tp-trib-natur-oper.class-fiscal = c-class-fiscal:
        r-rowid = rowid(int-ds-tp-trib-natur-oper).
        run pi-busca-natureza.
        return "OK".
    end.

if r-rowid = ? then
    for each int-ds-tp-trib-natur-oper no-lock where 
        int-ds-tp-trib-natur-oper.tp-pedido    = c-tp-pedido and
        int-ds-tp-trib-natur-oper.uf-origem    = "" and
        int-ds-tp-trib-natur-oper.class-fiscal = c-class-fiscal:
        r-rowid = rowid(int-ds-tp-trib-natur-oper).
        run pi-busca-natureza.
        return "OK".
    end.


for each int-ds-classif-fisc no-lock where 
    int-ds-classif-fisc.class-fiscal = c-class-fiscal: 
    
    if r-rowid = ? then
        for each int-ds-tp-trib-natur-oper no-lock where 
            int-ds-tp-trib-natur-oper.tp-pedido   = c-tp-pedido and
            int-ds-tp-trib-natur-oper.cd-trib-icm = int-ds-classif-fisc.cd-trib-icm and
            int-ds-tp-trib-natur-oper.uf-origem   = c-uf-origem and
            int-ds-tp-trib-natur-oper.class-fiscal = "":
            r-rowid = rowid(int-ds-tp-trib-natur-oper).
            run pi-busca-natureza.
            return "OK".
        end.

    if r-rowid = ? then
        for each int-ds-tp-trib-natur-oper no-lock where 
            int-ds-tp-trib-natur-oper.tp-pedido   = c-tp-pedido and
            int-ds-tp-trib-natur-oper.cd-trib-icm = int-ds-classif-fisc.cd-trib-icm and
            int-ds-tp-trib-natur-oper.uf-origem   = "" and
            int-ds-tp-trib-natur-oper.class-fiscal = "":
            r-rowid = rowid(int-ds-tp-trib-natur-oper).
            run pi-busca-natureza.
            return "OK".
        end.

    return "NOK".
end.

if r-rowid = ? then return "NOK".

procedure pi-busca-natureza:
    if c-uf-origem = c-uf-destino then do:
        if emitente.contrib-icms then do:
            c-nat-saida      = int-ds-tp-trib-natur-oper.nat-saida-EST.
            c-nat-entrada    = int-ds-tp-trib-natur-oper.nat-entrada-EST.
        end.
        else do:
            c-nat-saida      = int-ds-tp-trib-natur-oper.nat-saida-EST-nao-contrib.
            c-nat-entrada    = int-ds-tp-trib-natur-oper.nat-entrada-EST-nao-contrib.
        end.
    end.
    else do:
        if emitente.contrib-icms then do:
            c-nat-saida      = int-ds-tp-trib-natur-oper.nat-saida-INTER.
            c-nat-entrada    = int-ds-tp-trib-natur-oper.nat-entrada-INTER.
        end.
        else do:
            c-nat-saida      = int-ds-tp-trib-natur-oper.nat-saida-INTER-nao-contrib.
            c-nat-entrada    = int-ds-tp-trib-natur-oper.nat-entrada-INTER-nao-contrib.
        end.
    end.
end.
