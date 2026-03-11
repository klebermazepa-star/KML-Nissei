define input  parameter c-tp_pedido      as char no-undo.
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
for each int_ds_tipo_pedido no-lock 
    where int_ds_tipo_pedido.tp_pedido = c-tp_pedido:

    for each int_ds_mod_pedido no-lock
         where int_ds_mod_pedido.cod_mod_pedido = int_ds_tipo_pedido.cod_mod_pedido:

        if int_ds_mod_pedido.log_nat_origem then do:

            for first int_ds_tp_nat_origem no-lock where 
                int_ds_tp_nat_origem.tp_pedido  = c-tp_pedido and
                int_ds_tp_nat_origem.nat_origem = c-nat-origem:
                r-rowid = rowid(int_ds_tp_nat_origem).
                if emitente.contrib-icms then do:
                    c-nat-saida      = int_ds_tp_nat_origem.nat_saida.
                    c-nat-entrada    = int_ds_tp_nat_origem.nat_entrada.
                end.
                else do:
                    c-nat-saida      = int_ds_tp_nat_origem.nat_saida_nao_contrib.
                    c-nat-entrada    = int_ds_tp_nat_origem.nat_entrada_nao_contrib.
                end.
            end.
            if r-rowid = ? then return "NOK".
            else return "OK".
        end.
    end.
end.

/* exce‡äes cd-trib-ncm = 0 (Nenhum) */
if r-rowid = ? then
    for each int_ds_tp_trib_natur_oper no-lock where 
        int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido    and
        int_ds_tp_trib_natur_oper.uf_origem    = c-uf-origem    and
        /* exce‡Æo cd-trib-icm = 0 (Nenhum) permite preencher a classifica‡Æo */
        int_ds_tp_trib_natur_oper.cd_trib_icm  = 0 /* nenhum */ and
        int_ds_tp_trib_natur_oper.class_fiscal = c-class-fiscal:
        r-rowid = rowid(int_ds_tp_trib_natur_oper).
        run pi-busca-natureza.
        return "OK".
    end.

if r-rowid = ? then
    for each int_ds_tp_trib_natur_oper no-lock where 
        int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido    and
        int_ds_tp_trib_natur_oper.uf_origem    = ""             and
        /* exce‡Æo cd-trib-icm = 0 (Nenhum) permite preencher a classifica‡Æo */
        int_ds_tp_trib_natur_oper.cd_trib_icm  = 0 /* nenhum */ and
        int_ds_tp_trib_natur_oper.class_fiscal = c-class-fiscal:
        r-rowid = rowid(int_ds_tp_trib_natur_oper).
        run pi-busca-natureza.
        return "OK".
    end.

/*
if r-rowid = ? then
    for each int_ds_tp_trib_natur_oper no-lock where 
        int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido    and
        int_ds_tp_trib_natur_oper.uf-origem    = c-uf-origem    and
        int_ds_tp_trib_natur_oper.class-fiscal = c-class-fiscal:
        r-rowid = rowid(int_ds_tp_trib_natur_oper).
        run pi-busca-natureza.
        return "OK".
    end.

if r-rowid = ? then
    for each int_ds_tp_trib_natur_oper no-lock where 
        int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido    and
        int_ds_tp_trib_natur_oper.uf-origem    = ""             and
        int_ds_tp_trib_natur_oper.class-fiscal = c-class-fiscal:
        r-rowid = rowid(int_ds_tp_trib_natur_oper).
        run pi-busca-natureza.
        return "OK".
    end.
*/

/*
/* exce‡äes de c¢digo de tributa‡Æo por UF */
if r-rowid = ? then
for each int-ds-ncm-cd-trib-uf no-lock where 
    int-ds-ncm-cd-trib-uf.class-fiscal = c-class-fiscal and
    int-ds-ncm-cd-trib-uf.estado = c-uf-origem and
    int-ds-ncm-cd-trib-uf.pais = "Brasil":

    /* por cd trib icms */
    for each int_ds_tp_trib_natur_oper no-lock where 
        int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido                       and
        int_ds_tp_trib_natur_oper.cd-trib-icm  = int-ds-ncm-cd-trib-uf.cd-trib-icm and
        int_ds_tp_trib_natur_oper.uf-origem    = ""                                and
        int_ds_tp_trib_natur_oper.class-fiscal = "":
        r-rowid = rowid(int_ds_tp_trib_natur_oper).
        run pi-busca-natureza.
        return "OK".
    end.

    return "NOK".
end.
*/

/* cadastro normal de cd0603 */
if r-rowid = ? then
for each int_ds_classif_fisc no-lock where 
    int_ds_classif_fisc.class_fiscal = c-class-fiscal: 
    
    /*
    /* se for por UF, desconsidera cadastro cd0603 principal */
    if can-find (first int-ds-ncm-cd-trib-uf no-lock where 
        int-ds-ncm-cd-trib-uf.class-fiscal  = int_ds_classif_fisc.class-fiscal) then next.
    */

    if r-rowid = ? then
        /* por uf origem */
        for each int_ds_tp_trib_natur_oper no-lock where 
            int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido                     and
            int_ds_tp_trib_natur_oper.cd_trib_icm  = int_ds_classif_fisc.cd_trib_icm and
            int_ds_tp_trib_natur_oper.uf_origem    = c-uf-origem                     and
            int_ds_tp_trib_natur_oper.class_fiscal = "":

            r-rowid = rowid(int_ds_tp_trib_natur_oper).
            run pi-busca-natureza.
            return "OK".
        end.

    if r-rowid = ? then
        /* por cd trib icms */
        for each int_ds_tp_trib_natur_oper no-lock where 
            int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido                     and
            int_ds_tp_trib_natur_oper.cd_trib_icm  = int_ds_classif_fisc.cd_trib_icm and
            int_ds_tp_trib_natur_oper.uf_origem    = ""                              and
            int_ds_tp_trib_natur_oper.class_fiscal = "":
            r-rowid = rowid(int_ds_tp_trib_natur_oper).
            run pi-busca-natureza.
            return "OK".
        end.

    return "NOK".
end.

if r-rowid = ? then return "NOK".

procedure pi-busca-natureza:
    if c-uf-origem = c-uf-destino then do:
        if emitente.contrib-icms then do:
            c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_EST.
            c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_EST.
        end.
        else do:
            c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_EST_nao_contrib.
            c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_EST_nao_contrib.
        end.
    end.
    else do:
        if emitente.contrib-icms then do:
            c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_INTER.
            c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_INTER.
        end.
        else do:
            c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_INTER_nao_contrib.
            c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_INTER_nao_contrib.
        end.
    end.
end.
