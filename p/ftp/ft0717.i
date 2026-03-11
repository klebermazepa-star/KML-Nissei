/******************************************************************************
**
**  Include.: FT0717.I - Rotina para Atualizar Contabilidade Internacional
**
******************************************************************************/
define variable de-fator-imp as decimal no-undo. 

assign r-nota = rowid(nota-fiscal).
assign l-erro         = no
       l-contabil-dup = no.

find first param-global no-lock no-error.
find estabelec where estabelec.cod-estabel = nota-fiscal.cod-estabel no-lock no-error.
find emitente where emitente.nome-abrev = nota-fiscal.nome-ab-cli no-lock no-error.
find natur-oper of nota-fiscal no-lock no-error.
assign i-empresa = param-global.empresa-prin.

&if defined (bf_dis_consiste_conta) &then
    find estabelec where estabelec.cod-estabel = nota-fiscal.cod-estabel no-lock no-error.
    run cdp/cd9970.p (input rowid(estabelec), output i-empresa).
&endif

assign c-especie = fat-duplic.cod-esp
       i-fatura  = nota-fiscal.nr-nota-fis.
if nota-fiscal.ind-tip-nota = 9 or
   nota-fiscal.ind-tip-nota = 10 then do:
    if nota-fiscal.nro-nota-orig <> "" then do:
        find first b-fatura where
                   b-fatura.cod-estabel = fat-duplic.cod-estabel and
                   b-fatura.serie       = nota-fiscal.serie-orig and
                   b-fatura.nr-fatura   = nota-fiscal.nro-nota-orig no-lock no-error.

         assign c-especie = b-fatura.cod-esp
                i-fatura  = nota-fiscal.nro-nota-orig.
    end.
    else do:
        find esp-doc where esp-doc.cod-esp = fat-duplic.cod-esp no-lock no-error.

        assign c-especie = esp-doc.esp-lig
               i-fatura  = nota-fiscal.nr-nota-fis.
    end.
end.

find first esp-doc where
           esp-doc.cod-esp = c-especie and
           esp-doc.contabiliza  no-lock no-error.
if not avail esp-doc then do trans:
    create tt-auxiliar.
    assign tt-auxiliar.cod-estabel  = nota-fiscal.cod-estabel
           tt-auxiliar.cod-gr-cli   = emitente.cod-gr-cli
           tt-auxiliar.nr-nota-fis  = nota-fiscal.nr-nota-fis
           tt-auxiliar.serie        = nota-fiscal.serie
           tt-auxiliar.cod-esp      = c-especie
           l-erro                   = yes
           tt-auxiliar.tipo         =  3.
end.
assign de-fator = if nota-fiscal.ind-tip-nota = 10 then -1
                  else 1.
if l-erro = no then
itens:
for each it-nota-fisc where
         it-nota-fisc.cod-estabel = nota-fiscal.cod-estabel and
         it-nota-fisc.serie       = nota-fiscal.serie       and
         it-nota-fisc.nr-nota-fis = nota-fiscal.nr-nota-fis no-lock:
    find item where item.it-codigo = it-nota-fisc.it-codigo no-lock no-error.
    find first fat-ser-lote where 
               fat-ser-lote.cod-estabel = nota-fiscal.cod-estabel and 
               fat-ser-lote.serie       = nota-fiscal.serie       and 
               fat-ser-lote.nr-nota-fis = nota-fiscal.nr-nota-fis and 
               fat-ser-lote.nr-seq-fat  = it-nota-fisc.nr-seq-fat and 
               fat-ser-lote.it-codigo   = it-nota-fisc.it-codigo no-lock no-error.
    assign de-tot-valor = 0 
           de-tot-fre   = 0 
           de-tot-desp  = 0.
    if  avail fat-ser-lote then do:
        for each fat-ser-lote  
            where fat-ser-lote.cod-estabel = nota-fiscal.cod-estabel   
            and   fat-ser-lote.serie         = nota-fiscal.serie       
            and   fat-ser-lote.nr-nota-fis   = nota-fiscal.nr-nota-fis 
            and   fat-ser-lote.nr-seq-fat    = it-nota-fisc.nr-seq-fat 
            and   fat-ser-lote.it-codigo     = it-nota-fisc.it-codigo  
            and   (   nota-fiscal.ind-tip-nota <> 10 
                   or fat-ser-lote.dec-1       <> 0) no-lock
            break by fat-ser-lote.nr-nota-fis:
/*------------------------------------------------------------------------------------+
            | - Para notas de credito, foi utilizado o campo(dec-1) para indicar qual quantidade |
            |   ser· creditada(dec-1 <> 0).                                                      |
            | - A quantidade que ser· devolvida para o estoque È a qt-baixada[1].                |
            | - A contabilizaÁ„o/CR/EST ser· feita sempre para notas de crÈdito pela  quantidade |
            |   creditada multiplicada pelo valor do item.                                       |
            +------------------------------------------------------------------------------------*/            
            run pi-cd9500 in h-cd9500(input  nota-fiscal.cod-estabel,
                                      input  emitente.cod-gr-cli,
                                      input  rowid(item),
                                      input  it-nota-fisc.nat-oper,
                                      input  (IF lContaFtPorCliente THEN string(nota-fiscal.cod-emitente) ELSE it-nota-fisc.serie),
                                      input  fat-ser-lote.cod-depos,
                                      input  nota-fiscal.cod-canal-venda,
                                      output r-conta-ft).
            find conta-ft 
                 where rowid(conta-ft) = r-conta-ft no-lock no-error.
            if  not avail conta-ft then do:
                create tt-auxiliar.
                assign tt-auxiliar.cod-estabel = nota-fiscal.cod-estabel
                       tt-auxiliar.cod-gr-cli  = emitente.cod-gr-cli
                       tt-auxiliar.familia     = if para-fat.ind-contab-ft = 1 then item.fm-codigo
                                                 else item.fm-cod-com
                       tt-auxiliar.nr-nota-fis = nota-fiscal.nr-nota-fis
                       tt-auxiliar.serie       = nota-fiscal.serie
                       tt-auxiliar.nat-oper    = it-nota-fisc.nat-oper
                       tt-auxiliar.it-codigo   = it-nota-fisc.it-codigo 
                       tt-auxiliar.cod-depos   = fat-ser-lote.cod-depos
                       l-erro                  = yes
                       tt-auxiliar.tipo        = 1.
            end.
            if  last-of(fat-ser-lote.nr-nota-fis) then
                assign de-valor    = it-nota-fisc.vl-merc-liq  - de-tot-valor
                       de-frete-it = it-nota-fisc.vl-frete-it  - de-tot-fre
                       de-desp-it  = it-nota-fisc.vl-despes-it - it-nota-fisc.vl-frete-it
                       de-desp-it  = de-desp-it - de-tot-desp.
            else do:
                if   nota-fiscal.ind-tip-nota = 10 or 
                     nota-fiscal.ind-tip-nota =  9 then do:
                     assign de-valor = fn_ajust_dec(fat-ser-lote.dec-1,fat-duplic.mo-negoc).
                     &if  defined(bf_dis_nota_credito) &then 
                          if   nota-fiscal.ind-tip-nota = 10 then 
                               assign de-valor = fn_ajust_dec(it-nota-fisc.vl-preuni * fat-ser-lote.dec-1, 
                                                    fat-duplic.mo-negoc).
/* o dec-1 passou a armazenar a quantidade creditada pelo ft2020 */                                  
                     &endif
                end.
                else
                     assign de-valor = fn_ajust_dec(it-nota-fisc.vl-preuni * 
                                                    (if item.ind-inf-qtf then fat-ser-lote.qt-baixada[2]
                                                     else fat-ser-lote.qt-baixada[1]),
                                                    fat-duplic.mo-negoc).
                assign de-frete-it = fn_ajust_dec((de-valor / it-nota-fisc.vl-merc-liq) * 
                                                  it-nota-fisc.vl-frete-it,
                                                  fat-duplic.mo-negoc).
                assign de-desp-it  = fn_ajust_dec((de-valor / it-nota-fisc.vl-merc-liq) * 
                                                  (it-nota-fisc.vl-despes-it - it-nota-fisc.vl-frete-it),
                                                  fat-duplic.mo-negoc).
                assign de-tot-valor = de-tot-valor + de-valor
                       de-tot-fre   = de-tot-fre   + de-frete-it
                       de-tot-desp  = de-tot-desp  + de-desp-it.
            end.
            if not l-erro then do trans:
                if  not l-contabil-dup and (l-fasb = yes or l-cmi = yes) then do:
                    run ftp/ft0717h.p.
                    assign l-contabil-dup = yes.
                end.                
                {ftp/ft0717.i1}
            end.
        end.
    end.
    else do:
        run pi-cd9500 in h-cd9500(nota-fiscal.cod-estabel, emitente.cod-gr-cli,
                                  rowid(item), it-nota-fisc.nat-oper,
                                  (IF lContaFtPorCliente THEN string(nota-fiscal.cod-emitente) ELSE it-nota-fisc.serie),
                                  item.deposito-pad,
                                  nota-fiscal.cod-canal-venda,
                                  output r-conta-ft).
        find conta-ft where rowid(conta-ft) = r-conta-ft no-lock no-error.
        if not avail conta-ft then do:
           create tt-auxiliar.
           assign tt-auxiliar.cod-estabel = nota-fiscal.cod-estabel
                  tt-auxiliar.cod-gr-cli  = emitente.cod-gr-cli
                  tt-auxiliar.familia     = if para-fat.ind-contab-ft = 1 then item.fm-codigo
                                            else item.fm-cod-com
                  tt-auxiliar.nr-nota-fis = nota-fiscal.nr-nota-fis
                  tt-auxiliar.serie       = nota-fiscal.serie
                  tt-auxiliar.nat-oper    = it-nota-fisc.nat-oper
                  tt-auxiliar.it-codigo   = it-nota-fisc.it-codigo 
                  tt-auxiliar.cod-depos   = item.deposito-pad
                  l-erro                  = yes
                  tt-auxiliar.tipo        = 1.
        end.
        assign de-valor    = it-nota-fisc.vl-merc-liq
               de-frete-it = it-nota-fisc.vl-frete-it
               de-desp-it  = it-nota-fisc.vl-despes-it - it-nota-fisc.vl-frete-it.
        if l-erro = no then do trans:
            if  not l-contabil-dup and (l-fasb = yes or l-cmi = yes) then do:
                run ftp/ft0717h.p.
                assign l-contabil-dup = yes.
            end.            
            {ftp/ft0717.i1}
        end.
    end.
/***IVA***/     
    if avail fat-duplic then do trans:
       for each it-nota-imp where
                it-nota-imp.cod-estabel = it-nota-fisc.cod-estabel and   
                it-nota-imp.serie       = it-nota-fisc.serie       and   
                it-nota-imp.nr-nota-fis = nota-fiscal.nr-nota-fis  and   
                it-nota-imp.nr-seq-fat  = it-nota-fisc.nr-seq-fat  and   
                it-nota-imp.it-codigo   = it-nota-fisc.it-codigo exclusive-lock:
           if  i-pais-impto-usuario = 4 /* Mexico */ OR i-pais-impto-usuario = 17 /*Colìmbia*/
           and can-find(first  tipo-tax 
                         where tipo-tax.cod-tax = it-nota-imp.cod-taxa
                         and   tipo-tax.tipo    = 1) then /* Imposto de Retencao */
               assign de-fator-imp = -1.
           else 
               assign de-fator-imp = 1.
           if it-nota-imp.vl-imposto > 0 then do:
               assign de-vl-contab = it-nota-imp.vl-imposto * de-fator * de-fator-imp.

               run pi-cria-sumar-ft (input it-nota-imp.ct-tax,
                                     INPUT it-nota-imp.sc-tax,
                                     input de-vl-contab,
                                     input 21).
               if l-indicador then do:
                   {ftp/ft0708a.i6 "it-nota-imp.vl-imposto" "yes"} 
               end.    
               assign de-vl-contab = it-nota-imp.vl-imposto * (-1) * de-fator * de-fator-imp.
               
               run pi-cria-sumar-ft (input estabelec.ct-recven,
                                     INPUT estabelec.sc-recven,
                                     input de-vl-contab,
                                     input 20).
               
               if l-indicador then do:
                   {ftp/ft0708a.i6 "it-nota-imp.vl-imposto" "no"}
               end.    
           end.
       end.
    end.
    if l-erro then do:
        run pi-cd9500 in h-cd9500(nota-fiscal.cod-estabel, emitente.cod-gr-cli,
                                  rowid(item), it-nota-fisc.nat-oper,
                                  (IF lContaFtPorCliente THEN string(nota-fiscal.cod-emitente) ELSE it-nota-fisc.serie),
                                  it-nota-fisc.cod-depos,
                                  nota-fiscal.cod-canal-venda,
                                  output r-conta-ft).

        find conta-ft where rowid(conta-ft) = r-conta-ft no-lock no-error.
        if not avail conta-ft then do trans:     
           create tt-auxiliar.
           assign tt-auxiliar.cod-estabel  = nota-fiscal.cod-estabel
                  tt-auxiliar.cod-gr-cli   = emitente.cod-gr-cli
                  tt-auxiliar.familia      = if para-fat.ind-contab-ft = 1 then item.fm-codigo
                                             else item.fm-cod-com
                  tt-auxiliar.nr-nota-fis  = nota-fiscal.nr-nota-fis
                  tt-auxiliar.serie        = nota-fiscal.serie
                  tt-auxiliar.nat-oper     = it-nota-fisc.nat-oper
                  tt-auxiliar.it-codigo    = it-nota-fisc.it-codigo 
                  tt-auxiliar.cod-depos    = it-nota-fisc.cod-depos
                  l-erro                   = yes
                  tt-auxiliar.tipo         = 1.   
        end.
        assign de-valor    = it-nota-fisc.vl-merc-liq
               de-frete-it = it-nota-fisc.vl-frete-it
               de-desp-it  = it-nota-fisc.vl-despes-it - it-nota-fisc.vl-frete-it.
    end.
end.
if  nota-fiscal.emite-duplic = yes and 
    natur-oper.emite-duplic  = yes then do:

    &IF "{&bf_dis_versao_ems}" >= "2.062" &THEN
        IF  l-unidade-negocio THEN DO:
            /* Para notas fiscais de exportaá∆o as despesas s∆o rateadas * 
             * conforme regra de exportaá∆o, os gastos do internacional  *
             * n∆o est∆o habilitados para serem informados na fatura.    */
            IF  i-pais-impto-usuario <> 1
            AND param-global.modulo-ex
            AND emitente.natureza > 2 THEN .
            ELSE
                RUN pi-rateio-despesas-unidade-negocio.
        END.
        ELSE DO:
    &ENDIF
            FOR each desp-nota-fisc no-lock
                where desp-nota-fisc.serie       = nota-fiscal.serie and
                      desp-nota-fisc.cod-estabel = nota-fiscal.cod-estabel and
                      desp-nota-fisc.nr-nota-fis = nota-fiscal.nr-nota-fis:                    
        
                find despesa
                    where despesa.cod-despesa = desp-nota-fisc.cod-despesa no-lock no-error.
        
                IF  avail despesa then do:    
        
                    assign de-vl-contab = desp-nota-fisc.val-despesa * de-fator.
        
                    if  de-vl-contab <> 0 then do:
                        {ftp/ft0717.i2 despesa.cdn-ctconta de-vl-contab 22 despesa.cdn-ccusto ''}
                    end.
        
                    /* cria sumar-ft e soma o valor padrao - debito  */
                    assign de-vl-contab = desp-nota-fisc.val-despesa * (-1) * de-fator.                      
        
                    
                    {ftp/ft0717.i2 estabelec.ct-recven de-vl-contab 20 estabelec.sc-recven ''}
                    
                end.
            end.
    &IF "{&bf_dis_versao_ems}" >= "2.062" &THEN
        END.
    &ENDIF
end.                     
for each w-sumar-rej:
  if l-erro then do:
     find sumar-ft exclusive-lock where rowid(sumar-ft) = w-sumar-rej.registro no-error.
     if avail sumar-ft then delete sumar-ft.
  end.
  delete w-sumar-rej.
end. 
/*ftp/ft0717.i*/  
