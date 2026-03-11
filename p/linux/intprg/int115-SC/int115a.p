define input  parameter c-tp-pedido      as char no-undo.
define input  parameter c-uf-destino     as char no-undo.
define input  parameter c-uf-origem      as char no-undo.
define input  parameter c-nat-origem     as char no-undo.
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

/* Exce‡äes por natureza origem */
for each int-ds-tipo-pedido no-lock where int-ds-tipo-pedido.tp-pedido = c-tp-pedido:
    for each int-ds-mod-pedido no-lock where int-ds-mod-pedido.cod-mod-pedido = int-ds-tipo-pedido.cod-mod-pedido:
        if int-ds-mod-pedido.log-nat-origem then do:
            for first int-ds-tp-nat-origem no-lock where 
                int-ds-tp-nat-origem.tp-pedido  = c-tp-pedido and
                int-ds-tp-nat-origem.nat-origem = c-nat-origem:
                r-rowid = rowid(int-ds-tp-nat-origem).
                if emitente.contrib-icms then do:
                    c-nat-saida      = int-ds-tp-nat-origem.nat-saida.
                    c-nat-entrada    = int-ds-tp-nat-origem.nat-entrada.
                end.
                else do:
                    c-nat-saida      = int-ds-tp-nat-origem.nat-saida-nao-contrib.
                    c-nat-entrada    = int-ds-tp-nat-origem.nat-entrada-nao-contrib.
                end.
            end.
            if r-rowid = ? then return "NOK".
            else return "OK".
        end.
    end.
end.

/* exce‡äes cd-trib-ncm = 0 (Nenhum) */
if r-rowid = ? then
    for each int-ds-tp-trib-natur-oper no-lock where 
        int-ds-tp-trib-natur-oper.tp-pedido    = c-tp-pedido    and
        int-ds-tp-trib-natur-oper.uf-origem    = c-uf-origem    and
        /* exce‡Æo cd-trib-icm = 0 (Nenhum) permite preencher a classifica‡Æo */
        int-ds-tp-trib-natur-oper.cd-trib-icm  = 0 /* nenhum */ and
        int-ds-tp-trib-natur-oper.class-fiscal = c-class-fiscal:
        r-rowid = rowid(int-ds-tp-trib-natur-oper).
        run pi-busca-natureza.
        return "OK".
    end.

if r-rowid = ? then
    for each int-ds-tp-trib-natur-oper no-lock where 
        int-ds-tp-trib-natur-oper.tp-pedido    = c-tp-pedido    and
        int-ds-tp-trib-natur-oper.uf-origem    = ""             and
        /* exce‡Æo cd-trib-icm = 0 (Nenhum) permite preencher a classifica‡Æo */
        int-ds-tp-trib-natur-oper.cd-trib-icm  = 0 /* nenhum */ and
        int-ds-tp-trib-natur-oper.class-fiscal = c-class-fiscal:
        r-rowid = rowid(int-ds-tp-trib-natur-oper).
        run pi-busca-natureza.
        return "OK".
    end.

/* exce‡äes de c¢digo de tributa‡Æo por UF */
if r-rowid = ? then
for each int-ds-ncm-cd-trib-uf no-lock where 
    int-ds-ncm-cd-trib-uf.class-fiscal = c-class-fiscal and
    int-ds-ncm-cd-trib-uf.estado = c-uf-origem and
    int-ds-ncm-cd-trib-uf.pais = "Brasil":

    /* por cd trib icms */
    for each int-ds-tp-trib-natur-oper no-lock where 
        int-ds-tp-trib-natur-oper.tp-pedido    = c-tp-pedido                       and
        int-ds-tp-trib-natur-oper.cd-trib-icm  = int-ds-ncm-cd-trib-uf.cd-trib-icm and
        int-ds-tp-trib-natur-oper.uf-origem    = ""                                and
        int-ds-tp-trib-natur-oper.class-fiscal = "":
        r-rowid = rowid(int-ds-tp-trib-natur-oper).
        run pi-busca-natureza.
        return "OK".
    end.

    return "NOK".
end.

/* cadastro normal de cd0603 */
if r-rowid = ? then
for each int-ds-classif-fisc no-lock where 
    int-ds-classif-fisc.class-fiscal = c-class-fiscal: 
    
    /* se for por UF, desconsidera cadastro cd0603 principal */
    if can-find (first int-ds-ncm-cd-trib-uf no-lock where 
        int-ds-ncm-cd-trib-uf.class-fiscal  = int-ds-classif-fisc.class-fiscal) then next.

    /* retirado - passa a utilizar cd-trib-icm X uf lido anteriormente 
    if r-rowid = ? then
        /* por uf origem */
        for each int-ds-tp-trib-natur-oper no-lock where 
            int-ds-tp-trib-natur-oper.tp-pedido    = c-tp-pedido                     and
            int-ds-tp-trib-natur-oper.cd-trib-icm  = int-ds-classif-fisc.cd-trib-icm and
            int-ds-tp-trib-natur-oper.uf-origem    = c-uf-origem                     and
            int-ds-tp-trib-natur-oper.class-fiscal = "":

            r-rowid = rowid(int-ds-tp-trib-natur-oper).
            run pi-busca-natureza.
            return "OK".
        end.
    */

    if r-rowid = ? then
        /* por cd trib icms */
        for each int-ds-tp-trib-natur-oper no-lock where 
            int-ds-tp-trib-natur-oper.tp-pedido    = c-tp-pedido                     and
            int-ds-tp-trib-natur-oper.cd-trib-icm  = int-ds-classif-fisc.cd-trib-icm and
            int-ds-tp-trib-natur-oper.uf-origem    = ""                              and
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
