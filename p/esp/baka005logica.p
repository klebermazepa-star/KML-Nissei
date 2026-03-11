{inbo/boin090.i tt-docum-est} 
{inbo/boin366.i tt-rat-docum}
{inbo/boin176.i tt-item-doc-est}
{inbo/boin092.i tt-dupli-apagar}
{inbo/boin567.i tt-dupli-imp}
{method/dbotterr.i}

def temp-table tt-erro no-undo
	field identif-segment as char
	field cd-erro         as integer
	field desc-erro       as char format "x(80)".

def temp-table tt-erro-aux no-undo
        field identif-segment as char
        field cd-erro         as integer
        field desc-erro       as char format "x(80)"
        FIELD help-erro       AS CHAR FORMAT "x(100)".
        
DEFINE TEMP-TABLE tt-notas NO-UNDO
    FIELD cnpj-emitente AS CHAR
    FIELD nota         AS CHAR
    FIELD serie        AS CHAR
    .  
    
def buffer b-docum-est for docum-est.  
def buffer b-docum     for docum-est.
    
        
        
def var h-boin090      as handle      no-undo.
DEF INPUT PARAMETER r-rowid-nota AS ROWID NO-UNDO.


/* INPUT FROM VALUE ("\\10.0.1.3\cjem8f\KML\KLEBER\reprocessa_equivalencia\Equivalencia.csv"). */
/*                                                                                             */
/* REPEAT :                                                                                    */
/*                                                                                             */
/*     CREATE tt-notas.                                                                        */
/*     IMPORT DELIMITER ";"  tt-notas.                                                         */
/*                                                                                             */
/* END.                                                                                        */

for each tt-erro:
    delete tt-erro.
end.

run pi-inicializa-handle.


FOR LAST int_ds_nota_entrada
    WHERE rowid(int_ds_nota_entrada) = r-rowid-nota:
      
    //  MESSAGE int_ds_nota_entrada.nen_notafiscal_n VIEW-AS ALERT-BOX.
    ASSIGN int_ds_nota_entrada.nen_conferida_n = 0.

    FIND FIRST emitente NO-LOCK
        WHERE emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s NO-ERROR.

    IF AVAIL emitente THEN DO:
    
        find first docum-est 
            where docum-est.serie-docto  = int_ds_nota_entrada.nen_serie_s 
            and   docum-est.nro-docto    = string(int_ds_nota_entrada.nen_notafiscal_n)
            and   docum-est.cod-emitente = emitente.cod-emitente no-lock no-error. 

        IF avail docum-est THEN DO:
        
            /* Inicio -- Projeto Internacional */
        
            
            //{utp/ut-liter.i "Documento_inexistente" *}
/*             run pi-cria-erro (input '',                  */
/*                               input 952,                 */
/*                               input RETURN-VALUE + '.'). */
/*             END.                                         */
       
            run pi-del-registro(input docum-est.serie-docto,
                                input docum-est.nro-docto,
                                input docum-est.cod-emitente,
                                input docum-est.nat-operacao,
                                input docum-est.ce-atual).
        
        END.
    end.
   
END.   



procedure pi-del-registro:
    def input param p-serie-docto  like docum-est.serie-docto no-undo.
    def input param p-nro-docto    like docum-est.nro-docto no-undo.
    def input param p-cod-emitente like docum-est.cod-emitente no-undo.
    def input param p-nat-operacao like docum-est.nat-operacao no-undo.
    def input param p-ce-atual     like docum-est.ce-atual no-undo.
    def var r-docum-est as rowid no-undo.

    if p-ce-atual then do:
        /* Inicio -- Projeto Internacional */
        {utp/ut-liter.i "Documento_jÿ_atualizado" *}
        run pi-cria-erro (input '',
                          input 7183,
                          input RETURN-VALUE + '.').
        undo, return no-apply.
    end.
    else do transaction:
        /*valida»„es nas triggers de delete das tabelas*/
        run pi-valida-tabelas (input p-serie-docto, 
                               input p-nro-docto,   
                               input p-cod-emitente,
                               input p-nat-operacao).
        if not can-find(FIRST tt-erro) then do:
            run gotoKey      IN h-boin090(input p-serie-docto,  
                                          input p-nro-docto,    
                                          input p-cod-emitente, 
                                          input p-nat-operacao).
            if return-value = "OK":U then do:
                run DeleteRecord in h-boin090.
                if return-value = "NOK" then do:
                    run getRowErrors in h-boin090 (output table RowErrors).
                    for each RowErrors:
                        if not (RowErrors.ErrorType = "INTERNAL":U and 
                                (RowErrors.ErrorNumber = 8 or RowErrors.ErrorNumber = 10 or 
                                 RowErrors.ErrorNumber = 3)) then
                            run pi-cria-erro(input '',
                                             input RowErrors.ErrorNumber,
                                             input RowErrors.ErrorDescription).
                    end.
                end.
            end.
        end.
        
        //RUN pi-elimina-tt.
        
        if can-find(first tt-erro) then
            undo, return no-apply.
    end.
end procedure.

procedure pi-inicializa-handle:
    if  not valid-handle(h-boin090) then do:
        run inbo/boin090.p persistent set h-boin090.
        run openQueryStatic in h-boin090 ( input "Main":U ).
    end.
end procedure.

procedure pi-valida-tabelas:
    def input param p-serie-docto  like docum-est.serie-docto no-undo.
    def input param p-nro-docto    like docum-est.nro-docto no-undo.
    def input param p-cod-emitente like docum-est.cod-emitente no-undo.
    def input param p-nat-operacao like docum-est.nat-operacao no-undo.

    find first b-docum-est where b-docum-est.cod-emitente = p-cod-emitente
                             and b-docum-est.nat-operacao = p-nat-operacao
                             and b-docum-est.serie-docto  = p-serie-docto
                             and b-docum-est.nro-docto    = p-nro-docto no-lock no-error.


    if avail b-docum-est then do:
        if b-docum-est.log-1 then 
            /* Inicio -- Projeto Internacional */
            DO:
            {utp/ut-liter.i "Nota_Fiscal_jÿ_atualizada_no_Faturamento" *}
            run pi-cria-erro (input '',
                              input 15950,
                              input RETURN-VALUE + '.').
            END. 
        /*dupli-apagar*******************************************************/
        for each dupli-apagar where dupli-apagar.cod-emitente = b-docum-est.cod-emitente 
                                and dupli-apagar.nat-operacao = b-docum-est.nat-operacao 
                                and dupli-apagar.serie-docto  = b-docum-est.serie-docto  
                                and dupli-apagar.nro-docto    = b-docum-est.nro-docto exclusive-lock:   

            for each consist-nota
               where consist-nota.cod-emitente = dupli-apagar.cod-emitente
                 and consist-nota.nat-operacao = dupli-apagar.nat-operacao
                 and consist-nota.serie-docto  = dupli-apagar.serie-docto
                 and consist-nota.nro-docto    = dupli-apagar.nro-docto
                 and consist-nota.mensagem     = 6252
                 and (   consist-nota.int-1    = int(string(dupli-apagar.parcela))
                      or consist-nota.int-1    = 0 ) exclusive-lock:
                delete consist-nota.
            end.

            /** Inicio da elimina»’o em cascata **/
            for each dupli-imp
               where dupli-imp.cod-emitente = dupli-apagar.cod-emitente
                 and dupli-imp.serie-docto  = dupli-apagar.serie-docto
                 and dupli-imp.nro-docto    = dupli-apagar.nro-docto
                 and dupli-imp.cod-emitente = dupli-apagar.cod-emitente
                 and dupli-imp.parcela      = dupli-apagar.parcela exclusive-lock:
                delete dupli-imp.
            end.
            delete dupli-apagar.
        end. /*for each dupli-apagar*/

        find first param-global no-lock no-error.
        /*item-doc-est**************************************************************/
        for each item-doc-est where item-doc-est.cod-emitente = b-docum-est.cod-emitente
                                and item-doc-est.nat-operacao = b-docum-est.nat-operacao
                                and item-doc-est.serie-docto  = b-docum-est.serie-docto 
                                and item-doc-est.nro-docto    = b-docum-est.nro-docto exclusive-lock:   

            if can-find(first pd-cc-it-nfe use-index documento where
                              pd-cc-it-nfe.nro-docto = item-doc-est.nro-docto        and
                              pd-cc-it-nfe.serie-docto = item-doc-est.serie-docto    and
                              pd-cc-it-nfe.nat-operacao = item-doc-est.nat-operacao  and
                              pd-cc-it-nfe.cod-emitente = item-doc-est.cod-emitente) or
            can-find(first pd-pd-it-nfe use-index documento where
                              pd-pd-it-nfe.nro-docto = item-doc-est.nro-docto        and
                              pd-pd-it-nfe.serie-docto = item-doc-est.serie-docto    and
                              pd-pd-it-nfe.nat-operacao = item-doc-est.nat-operacao  and
                              pd-pd-it-nfe.cod-emitente = item-doc-est.cod-emitente) then do:
                /* Inicio -- Projeto Internacional */
                {utp/ut-liter.i "Item_da_nota_possui_relacionamentos_ativos" *}
                run pi-cria-erro (input '',
                                  input 6718,
                                  input RETURN-VALUE + '.').
                undo, return no-apply.
            end.

            for each rat-ordem exclusive-lock
               where rat-ordem.cod-emitente = item-doc-est.cod-emitente
                 and rat-ordem.nro-docto    = item-doc-est.nro-docto
                 and rat-ordem.nat-operacao = item-doc-est.nat-operacao
                 and rat-ordem.serie-docto  = item-doc-est.serie-docto
                 and rat-ordem.sequencia    = item-doc-est.sequencia:
                if  b-docum-est.rec-fisico then 
                    assign rat-ordem.nat-operacao = " " .
                else 
                    delete rat-ordem.
            end.
            for each rat-lote 
               where rat-lote.cod-emitente = item-doc-est.cod-emitente
                 and rat-lote.nro-docto    = item-doc-est.nro-docto
                 and rat-lote.nat-operacao = item-doc-est.nat-operacao
                 and rat-lote.serie-docto  = item-doc-est.serie-docto
                 and rat-lote.sequencia    = item-doc-est.sequencia exclusive-lock:

                if  b-docum-est.rec-fisico then 
                    assign rat-lote.nat-operacao = " ".
                else  
                    delete rat-lote.
            end.
            find first prazo-compra
                 where prazo-compra.numero-ordem = item-doc-est.numero-ordem
                   and prazo-compra.parcela      = item-doc-est.parcela exclusive-lock no-error.
            if  avail prazo-compra then do:
                if  not b-docum-est.rec-fisico then do:
                    assign prazo-compra.dec-1 = prazo-compra.dec-1 
                                              - item-doc-est.quantidade.
                    if prazo-compra.dec-1 < 0 then
                        assign prazo-compra.dec-1 = 0.                              
                end.            
            end.
            find saldo-terc where 
                saldo-terc.cod-emitente = item-doc-est.cod-emitente and 
                saldo-terc.nro-docto    = item-doc-est.nro-comp and 
                saldo-terc.serie-docto  = item-doc-est.serie-comp and 
                saldo-terc.nat-operacao = item-doc-est.nat-comp and 
                saldo-terc.it-codigo    = item-doc-est.it-codigo and 
                saldo-terc.cod-refer    = item-doc-est.cod-refer and 
                saldo-terc.sequencia    = item-doc-est.seq-comp
                exclusive-lock no-error.

            if  available saldo-terc then do: 
                if  not b-docum-est.rec-fisico then 
                    assign saldo-terc.dec-1 = saldo-terc.dec-1 - item-doc-est.quantidade
                           saldo-terc.dec-1 = if saldo-terc.dec-1 < 0 then 0
                                              else saldo-terc.dec-1.
            end.

            /* Unidade de Negocio */
            &if  defined(bf_mat_unidade_negocio) &then
                for each unid-neg-nota
                   where unid-neg-nota.cod-emitente = item-doc-est.cod-emitente
                     and unid-neg-nota.serie-docto  = item-doc-est.serie-docto 
                     and unid-neg-nota.nro-docto    = item-doc-est.nro-docto 
                     and unid-neg-nota.nat-operacao = item-doc-est.nat-operacao
                     and unid-neg-nota.sequencia    = item-doc-est.sequencia exclusive-lock:

                    if  b-docum-est.rec-fisico then 
                        assign unid-neg-nota.nat-operacao = " ".
                    else 
                        delete unid-neg-nota.
                end.                
            &endif

            if  b-docum-est.esp-docto    = 23  /* "NFT" */
            and b-docum-est.tipo-docto   = 1   /* Entrada */
            and param-global.modulo-mp = yes then do:

                if  b-docum-est.pais-origem = "RE1001" then 
                    find nota-fiscal where
                         nota-fiscal.serie        = item-doc-est.serie-docto  and
                         nota-fiscal.nr-nota-fis  = item-doc-est.nro-docto    and 
                         nota-fiscal.cod-estabel  = b-docum-est.estab-de-or     no-lock no-error.
                else 
                    find b-docum where
                         b-docum.serie-docto  = item-doc-est.serie-docto  and
                         b-docum.nro-docto    = item-doc-est.nro-docto    and 
                         b-docum.cod-emitente = item-doc-est.cod-emitente and 
                         b-docum.nat-operacao = item-doc-est.nat-comp no-lock no-error.

                if  not avail nota-fiscal and not avail b-docum then do:
                    for each saldo-terc 
                       where saldo-terc.serie-docto  = item-doc-est.serie-docto
                         and saldo-terc.nro-docto    = item-doc-est.nro-docto
                         and saldo-terc.cod-emitente = item-doc-est.cod-emitente
                         and saldo-terc.nat-operacao = item-doc-est.nat-comp exclusive-lock:
                        find componente exclusive-lock where
                             componente.serie-docto  = saldo-terc.serie-docto  and
                             componente.nro-docto    = saldo-terc.nro-docto    and
                             componente.cod-emitente = saldo-terc.cod-emitente and
                             componente.nat-operacao = saldo-terc.nat-operacao and
                             componente.it-codigo    = saldo-terc.it-codigo    and
                             componente.cod-refer    = saldo-terc.cod-refer    and
                             componente.sequencia    = saldo-terc.sequencia no-error.
                        if  avail componente then 
                            delete componente.
                        delete saldo-terc validate(true, "").
                    end.
                end.
            end.
            delete item-doc-est.
        end. /*for each item-doc-est*/

        /*docume-est**********************************************************/
        find first rat-docum
             where rat-docum.nf-emitente = b-docum-est.cod-emitente
               and rat-docum.nf-nat-oper = b-docum-est.nat-operacao
               and rat-docum.nf-serie    = b-docum-est.serie-docto
               and rat-docum.nf-nro      = b-docum-est.nro-docto no-lock no-error.
        if avail rat-docum then do:
            /* Inicio -- Projeto Internacional */
            {utp/ut-liter.i "Exclus’o_n’o_permitida._Nota_relacionada_a_Nota_de_Rateio" *}
            run pi-cria-erro (input '',
                              input 18401,
                              input RETURN-VALUE).
            undo, return no-apply.
        end.

        for each despesa-aces 
           where despesa-aces.cod-emitente = b-docum-est.cod-emitente
             and despesa-aces.nat-operacao = b-docum-est.nat-operacao
             and despesa-aces.serie-docto  = b-docum-est.serie-docto
             and despesa-aces.nro-docto    = b-docum-est.nro-docto exclusive-lock: 
            delete despesa-aces.
        end.

        &if defined(bf_mat_reporte_autom) &then
            /* Elimina»’o do Agregado */
            for each movto-pend
               where movto-pend.cod-emitente = b-docum-est.cod-emitente
                 and movto-pend.serie-comp   = b-docum-est.serie-docto
                 and movto-pend.nro-comp     = b-docum-est.nro-docto
                 and movto-pend.nat-comp     = b-docum-est.nat-operacao exclusive-lock:
                 delete movto-pend.
            end.         
            /* Elimina»’o do Acabado */
            for each movto-pend
               where movto-pend.cod-emitente = b-docum-est.cod-emitente
                 and movto-pend.serie-docto  = b-docum-est.serie-docto
                 and movto-pend.nro-docto    = b-docum-est.nro-docto
                 and movto-pend.nat-operacao = b-docum-est.nat-operacao exclusive-lock:
                 delete movto-pend.
            end.
        &else  
            for each movto-pend 
               where movto-pend.cod-emitente = b-docum-est.cod-emitente
                 and movto-pend.serie-docto  = b-docum-est.serie-docto 
                 and movto-pend.nro-docto    = b-docum-est.nro-docto exclusive-lock: 

                if  movto-pend.nat-operacao = b-docum-est.nat-operacao 
                or  movto-pend.char-1       = b-docum-est.nat-operacao then 
                    delete movto-pend.
            end.
        &endif


        if  b-docum-est.rec-fisico then do:
            &IF defined(bf_mat_receb_fisico) &THEN
                find doc-fisico exclusive-lock 
               where doc-fisico.nro-docto    = b-docum-est.nro-docto    
                 and doc-fisico.serie-docto  = b-docum-est.serie-docto  
                 and doc-fisico.cod-emitente = b-docum-est.cod-emitente 
                 and doc-fisico.tipo-nota    = b-docum-est.tipo-nota no-error.
            &ELSE
                find doc-fisico exclusive-lock 
               where doc-fisico.nro-docto    = b-docum-est.nro-docto    
                 and doc-fisico.serie-docto  = b-docum-est.serie-docto  
                 and doc-fisico.cod-emitente = b-docum-est.cod-emitente 
                 and doc-fisico.tipo-nota    = b-docum-est.int-1 no-error.
            &ENDIF    
            if  avail doc-fisico then 
                assign doc-fisico.situacao = 2.
        end.

        for each rat-docum
           where rat-docum.cod-emitente = b-docum-est.cod-emitente
             and rat-docum.nat-operacao = b-docum-est.nat-operacao
             and rat-docum.serie-docto  = b-docum-est.serie-docto
             and rat-docum.nro-docto    = b-docum-est.nro-docto exclusive-lock: 

           if  b-docum-est.rec-fisico then 
               assign rat-docum.nat-operacao = " ".
           else do:
                find b-docum
                      where b-docum.serie-docto  = rat-docum.nf-serie
                      and   b-docum.nro-docto    = rat-docum.nf-nro
                      and   b-docum.cod-emitente = rat-docum.nf-emitente
                      and   b-docum.nat-operacao = rat-docum.nf-nat-oper  
                      exclusive-lock no-error.
                if  avail b-docum then      
                    assign b-docum.ind-rateio = no.

                delete rat-docum.
            end.     
        end.

        find first movto-estoq 
             where movto-estoq.serie-docto  = b-docum-est.serie-docto  
               and movto-estoq.nro-docto    = b-docum-est.nro-docto    
               and movto-estoq.cod-emitente = b-docum-est.cod-emitente 
               and movto-estoq.nat-operacao = b-docum-est.nat-operacao
               and movto-estoq.origem-valor = " " no-lock no-error.
        if  avail movto-estoq then 
            /* Inicio -- Projeto Internacional */
            DO:
            {utp/ut-liter.i "Documento_n’o_pode_ser_exclu­do,_jÿ_existe_movimento_de_estoque" *}
            run pi-cria-erro (input '',
                              input 1,
                              input RETURN-VALUE + '.').
            END.  
    end. /*avail b-docum-est*/
end procedure.

procedure pi-cria-erro:
    def input param p-identif-segment like tt-erro.identif-segment no-undo.
    def input param p-cd-erro like tt-erro.cd-erro no-undo.
    def input param p-desc-erro like tt-erro.desc-erro no-undo.

    create tt-erro.
    assign tt-erro.identif-segment = p-identif-segment
           tt-erro.cd-erro         = p-cd-erro
           tt-erro.desc-erro       = p-desc-erro.

end procedure.

procedure pi-elimina-tt:
    empty TEMP-TABLE tt-docum-est.     
    empty temp-table tt-rat-docum.
    empty temp-table tt-item-doc-est.
    empty temp-table tt-dupli-apagar.
    empty temp-table tt-dupli-imp.
    
    //DELETE HANDLE h-boin090.
end.
