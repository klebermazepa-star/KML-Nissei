/******************************************************************************************************
** KML
**
**   - 12/08/23 - Tratamento itens Cesta B†sica INT121 - Eduardo Barth.
*******************************************************************************************************/

define input  parameter c-tp_pedido      as char no-undo.
define input  parameter c-uf-destino     as char no-undo.
define input  parameter c-uf-origem      as char no-undo.
define input  parameter c-nat-origem     as char no-undo.
define input  parameter i-cod-emitente   as integer no-undo.
define input  parameter c-class-fiscal   as char no-undo.
define input  parameter c-it-codigo      as char no-undo.
DEFINE INPUT  PARAMETER c-estab          AS CHAR NO-UNDO.
define output parameter c-nat-saida      as char no-undo.
define output parameter c-nat-entrada    as char no-undo.
define output parameter r-rowid          as rowid.

c-nat-saida      = "".
c-nat-entrada    = "".
r-rowid          = ?.

DEFINE BUFFER b-item FOR ITEM.

DEFINE VARIABLE c-cd-trib-icm LIKE int_ds_classif_fisc.cd_trib_icm   NO-UNDO.


// Itens de Cesta B†sica cadastrados no INT121 possuem Natureza diferenciada. (Barth).
IF  c-it-codigo <> ?
AND c-it-codigo <> "" THEN DO:
    // Se item consta como Item de Cesta B†sica...
    IF  CAN-FIND(FIRST es-cesta-basica-item NO-LOCK
                 WHERE es-cesta-basica-item.uf-origem  = c-uf-origem
                 AND   es-cesta-basica-item.uf-destino = c-uf-destino
                 AND   es-cesta-basica-item.tp-pedido  = c-tp_pedido
                 AND   es-cesta-basica-item.it-codigo  = c-it-codigo) THEN DO:
        // Ent∆o pega a Natureza informada no INT121
        FIND FIRST es-cesta-basica
            WHERE es-cesta-basica.uf-origem  = c-uf-origem
            AND   es-cesta-basica.uf-destino = c-uf-destino
            AND   es-cesta-basica.tp-pedido  = c-tp_pedido
            NO-LOCK NO-ERROR.
        
        ASSIGN c-nat-saida = es-cesta-basica.nat-operacao
               c-nat-entrada = ""
               r-rowid = rowid(es-cesta-basica-item).

        RETURN "OK".
    END.
END.


for first emitente no-lock where 
    emitente.cod-emitente = i-cod-emitente: end.
if not avail emitente then return "NOK".



/* Exceá‰es por natureza origem */
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
/* Kleber Mazepa 15/02/2020 - Regra para NCM e UF origem cadastrada direto no int115, essa regra n∆o Ç mais necess†ria

/* exceá‰es cd-trib-ncm = 0 (Nenhum) */
if r-rowid = ? THEN DO:

    for each int_ds_tp_trib_natur_oper no-lock where 
        int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido    and
        int_ds_tp_trib_natur_oper.uf_origem    = c-uf-origem    and
        /* exceá∆o cd-trib-icm = 0 (Nenhum) permite preencher a classificaá∆o */
        int_ds_tp_trib_natur_oper.cd_trib_icm  = 0 /* nenhum */ and
        int_ds_tp_trib_natur_oper.class_fiscal = c-class-fiscal:

        r-rowid = rowid(int_ds_tp_trib_natur_oper).
        run pi-busca-natureza.
        return "OK".
    end.

END.

if r-rowid = ? THEN DO:

    for each int_ds_tp_trib_natur_oper no-lock where 
        int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido    and
        int_ds_tp_trib_natur_oper.uf_origem    = ""             and
        /* exceá∆o cd-trib-icm = 0 (Nenhum) permite preencher a classificaá∆o */
        int_ds_tp_trib_natur_oper.cd_trib_icm  = 0 /* nenhum */ and
        int_ds_tp_trib_natur_oper.class_fiscal = c-class-fiscal:

        r-rowid = rowid(int_ds_tp_trib_natur_oper).
        run pi-busca-natureza.
        return "OK".
    end.
END.
*/


/* cadastro normal de cd0603 */
if r-rowid = ? then
for each int_ds_classif_fisc no-lock where 
    int_ds_classif_fisc.class_fiscal = c-class-fiscal: 


    ASSIGN c-cd-trib-icm = int_ds_classif_fisc.cd_trib_icm.
    

    /*
    /* se for por UF, desconsidera cadastro cd0603 principal */
    if can-find (first int-ds-ncm-cd-trib-uf no-lock where 
        int-ds-ncm-cd-trib-uf.class-fiscal  = int_ds_classif_fisc.class-fiscal) then next.
    */

    /* Alteraá∆o kleber para ICMS de santa catarina - 15/04/2019 */

    IF     c-cd-trib-icm = 1 /* Tributado */ 
        OR c-cd-trib-icm = 9 /* ST */ 
        OR c-cd-trib-icm = 2 /* ISENTO */ 
        THEN DO:

        FIND FIRST b-ITEM NO-LOCK
            WHERE b-ITEM.it-codigo = trim(string(int(c-it-codigo))) NO-ERROR.

        IF AVAIL b-ITEM THEN DO:

            IF b-item.cd-trib-icm = 2 THEN c-cd-trib-icm = 2.
            ELSE DO:
            
                FIND FIRST item-uf NO-LOCK
                    WHERE item-uf.it-codigo         = b-item.it-codigo 
                      AND item-uf.cod-estado-orig   = c-uf-origem
                      AND item-uf.estado            = c-uf-destino NO-ERROR.
                

                IF AVAIL item-uf THEN DO:
                    ASSIGN c-cd-trib-icm = 9.    //Alterar de tributado para ST quando existir cadastro de ITEM-UF
                END.
                ELSE DO:
                    ASSIGN c-cd-trib-icm = 1.    //Alterar de ST para tributado quando n∆o existir cadastro de ITEM-UF
                END.

            END.
        END.

    END.

     /* FIM - Alteraá∆o kleber para ICMS de santa catarina */

    if r-rowid = ? THEN DO:

        /* por uf origem */
        for each int_ds_tp_trib_natur_oper no-lock where 
            int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido    and
            int_ds_tp_trib_natur_oper.cd_trib_icm  = c-cd-trib-icm  and
            int_ds_tp_trib_natur_oper.uf_origem    = c-uf-origem    and
            int_ds_tp_trib_natur_oper.class_fiscal = "":

            r-rowid = rowid(int_ds_tp_trib_natur_oper).
            run pi-busca-natureza.
            return "OK".
        end.
    END.
    if r-rowid = ? THEN DO:

        /* por cd trib icms */
        for each int_ds_tp_trib_natur_oper no-lock where 
            int_ds_tp_trib_natur_oper.tp_pedido    = c-tp_pedido    and
            int_ds_tp_trib_natur_oper.cd_trib_icm  = c-cd-trib-icm  and
            int_ds_tp_trib_natur_oper.uf_origem    = ""             and
            int_ds_tp_trib_natur_oper.class_fiscal = "":
            r-rowid = rowid(int_ds_tp_trib_natur_oper).
            run pi-busca-natureza.
            return "OK".
        end.

    END.

    return "NOK".
end.

if r-rowid = ? then return "NOK".

procedure pi-busca-natureza:


    DEFINE VARIABLE l-RegimeEspecial AS LOGICAL     NO-UNDO.
    
    if c-uf-origem = c-uf-destino then do:
        if emitente.contrib-icms then do:
            IF int_ds_tp_trib_natur_oper.cd_trib_icm = 9 THEN DO: //se for ICMS ST
            
                FOR FIRST b-ITEM NO-LOCK
                    WHERE b-ITEM.it-codigo = trim(string(int(c-it-codigo))),
                    FIRST item-uni-estab NO-LOCK
                    WHERE item-uni-estab.it-codigo = b-ITEM.it-codigo
                      AND item-uni-estab.cod-estabel = c-estab
                      AND SUBSTRING(item-uni-estab.char-2,60,1) = "S":
                      
                    ASSIGN l-RegimeEspecial = YES.     
                        
                END.                        
                   
                
                IF  l-RegimeEspecial  = YES THEN DO:  //Ç do regime especial
                
                    c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_EST.
                    c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_EST.
                END.
                ELSE DO: // sem regime especial
                    c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_sem_reg.
                    c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_EST.
                END.
            END.
            ELSE DO: // caso contr†rio continua como est†
                c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_EST.
                c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_EST.
            END.
            
        end.
        else do:
            c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_EST_nao_contrib.
            c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_EST_nao_contrib.
        end.
    end.
    else do:
        if emitente.contrib-icms then do:
            
            ASSIGN l-RegimeEspecial = NO. 
            IF int_ds_tp_trib_natur_oper.cd_trib_icm = 9 THEN DO: //se for ICMS ST
            
                FOR FIRST b-ITEM NO-LOCK
                    WHERE b-ITEM.it-codigo = trim(string(int(c-it-codigo))),
                    FIRST item-uni-estab NO-LOCK
                    WHERE item-uni-estab.it-codigo = b-ITEM.it-codigo
                      AND item-uni-estab.cod-estabel = c-estab
                      AND SUBSTRING(item-uni-estab.char-2,60,1) = "S":
                      
                    ASSIGN l-RegimeEspecial = YES.     
                        
                END.                        
                   
                
                IF  l-RegimeEspecial  = YES THEN DO:  //Ç do regime especial
                
                    c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_INTER.
                    c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_INTER.
                END.
                ELSE DO: // sem regime especial
                    c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg.
                    c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_INTER.
                END.

            END.
            ELSE DO: // caso contr†rio continua como est†
                c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_INTER.
                c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_INTER.
            END.

        end.
        else do:
            c-nat-saida      = int_ds_tp_trib_natur_oper.nat_saida_INTER_nao_contrib.
            c-nat-entrada    = int_ds_tp_trib_natur_oper.nat_entrada_INTER_nao_contrib.
        end.
    end.
end.
