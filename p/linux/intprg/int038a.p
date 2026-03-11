/********************************************************************************
** Programa : int038a
** Funá∆o   : gera nota no recebimento re1001.
** Data     : 12/2017
********************************************************************************/
{include/i-prgvrs.i int038a 2.06.00.001}  
{utp/ut-glob.i}

{inbo/boin090.i tt-docum-est}      /* Definiá∆o tt-docum-est       */
{inbo/boin366.i tt-rat-docum}      /* Definiá∆o TT-RAT-doCUM       */
{inbo/boin366.i tt2-rat-docum}     /* Definiá∆o TT-RAT-doCUM       */
{inbo/boin176.i tt-item-doc-est}   /* Definiá∆o TT-ITEM-doC-EST    */
{inbo/boin176.i tt2-item-doc-est}  /* Definiá∆o TT-ITEM-doC-EST    */
{inbo/boin092.i tt-dupli-apagar}   /* Definiá∆o TT-DUPLI-APAGAR    */
{inbo/boin092.i tt2-dupli-apagar}  /* Definiá∆o TT-DUPLI-APAGAR    */
{inbo/boin567.i tt-dupli-imp}      /* Definiá∆o TT-DUPLI-IMP       */
{inbo/boin567.i tt2-dupli-imp}     /* Definiá∆o TT-DUPLI-IMP       */
{inbo/boin366.i tt-imposto}        /* Definiá∆o TT-IMPOSTO         */
{inbo/boin176.i5 tt-item-terc }    /* Definiá∆o TT-ITEM-TERC       */
{inbo/boin404.i tt-saldo-terc}     /* TT-SALdo-TERC                */ 
{cdp/cdcfgmat.i}
{method/dbotterr.i }              /* Definiá∆o RowErrors          */
{cdp/cd0666.i}

def new global shared var i-nro-docto-int038 as integer format "9999999"  no-undo. /* Retorna a nota gerada */

def temp-table tt-valida-erro  no-undo like RowErrors.
def temp-table tt-valida-param no-undo like RowErrors.

def temp-table tt-nota no-undo
    field situacao     as   integer
    field nro-docto    like docum-est.nro-docto   
    field serie-nota   like docum-est.serie-docto
    field serie-docum  like docum-est.serie-docto        
    field cod-emitente like docum-est.cod-emitente
    field nat-operacao like docum-est.nat-operacao
    field tipo_nota    like int_ds_docto_xml.tipo_nota
    field valor-mercad like doc-fisico.valor-mercad.

def temp-table tt-erro-nota no-undo
    field serie        as char format "x(03)"
    field nro-docto    as char format "9999999"
    field cod-emitente as integer format ">>>>>>>>9"
    field cod-erro     as integer format ">>>>>9"
    field descricao    as char. 

def temp-table tt-arquivo-erro
    field c-linha as char.

def input  param table  for tt-nota.
def input  param table  for tt-docum-est.
def input  param table  for tt-item-doc-est.
def output param table  for tt-valida-erro.

DEF BUFFER b-docum-est for docum-est.

def var raw-param              as raw              no-undo.
def var h-boin090              as handle           no-undo.
def var h-boin366              as handle           no-undo.
def var h-boin176              as handle           no-undo.
def var h-boin092              as handle           no-undo.
def var h-boin567              as handle           no-undo.
def var h-boin404              as handle           no-undo.
def var h-boin404re            as handle           no-undo.
def var l-terceiros            as logical          no-undo.
def var de-tot-dup             as dec              no-undo.       
def var de-qtd-saldo           as dec              no-undo.       
def var de-qtd-saldo-menor     as dec              no-undo.
def var de-qtd-saldo-total     as dec              no-undo.
def var d-proporcao            as decimal          no-undo.
def var de-qt-componente       like componente.quantidade   no-undo.
def var i-dias                 as int                       no-undo. 
def var da-data                as date                      no-undo.
def var l-avail                as logical                   no-undo.
def var c-arquivo              as char format "x(200)"      no-undo.
def var r-docum-est-transf     as rowid                     no-undo.
def var c-mensagem-advertencia as char format "x(100)"      no-undo.
def var h-bodi515              as handle                    no-undo.
def var l-emite-nfe            as logical                   no-undo.
def var r-docum-est            as rowid                     no-undo.
def var l-erro-imp             as logical                   no-undo.
def var c-linha                as char                      no-undo.
def var c-nr-nota              as char format "x(07)"       no-undo.
def var i-cont                 as integer                   no-undo.
def var i-pos-arq              as integer                   no-undo.
def var c-dt-venc              as char    format "x(10)"    no-undo.
def var dt-vencto              as date                      no-undo.
def var d-tot-valor            like doc-fisico.valor-mercad no-undo.
def var h-acomp                as handle                     no-undo.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "").
run pi-seta-titulo in h-acomp (input "Processando nota de entrada.").


/**** elimina as tabelas *****/
for each tt2-rat-docum exclusive-lock:
    delete tt2-rat-docum.
end.

for each tt2-item-doc-est exclusive-lock:
    delete tt2-item-doc-est.
end.

for each tt2-dupli-apagar exclusive-lock:
    delete tt2-dupli-apagar.
end.

for each tt2-dupli-imp exclusive-lock:
    delete tt2-dupli-imp.
end.
/*****************************/

DEF BUFFER b7-docum-est for docum-est.

for each tt-nota where
         tt-nota.situacao = 2 /* Liberado */
   break by tt-nota.nro-docto
         by tt-nota.nat-operacao:
  
  if last-of(tt-nota.nat-operacao) 
  then do:   
     
     empty temp-table tt-valida-erro.

     bloco:
     do transaction on error undo, next:

         RUN pi-acompanhar IN h-acomp(input "nota :" + tt-nota.nro-docto).

         for each tt-docum-est where
                  int(tt-docum-est.nro-docto) = int(tt-nota.nro-docto) and
                  tt-docum-est.serie-docto    = tt-nota.serie-nota     and   
                  tt-docum-est.cod-emitente   = tt-nota.cod-emitente   and
                  tt-docum-est.nat-operacao   = tt-nota.nat-operacao: 
            
            run inbo/boin090.p persistent set h-boin090.
    
            for first natur-oper where 
                      natur-oper.nat-operacao = tt-docum-est.nat-operacao no-lock: end.        
            
            run pi-grava-docum-est.
            
            /* Fazer essa busca somente quando nota for de balanáo */ 
            if natur-oper.imp-nota /* Gera nota faturamento */
            then do:
               
               for first ser-estab no-lock where
                         ser-estab.serie = tt-nota.serie-nota and 
                         ser-estab.cod-estabel = tt-docum-est.cod-estabel:
                   assign i-nro-docto-int038 = int(ser-estab.nr-ult-nota) + 1.
               end.
            end.
            else  
               assign i-nro-docto-int038 = int(tt-nota.nro-docto).
                   
            for first docum-est no-lock where
                      int(docum-est.nro-docto)  =  i-nro-docto-int038     and   
                      docum-est.serie           =  tt-nota.serie-nota     and
                      docum-est.tipo-nota       =  tt-nota.tipo_nota      and
                      docum-est.nat-operacao    =  tt-nota.nat-operacao   and
                      docum-est.cod-emitente    =  tt-nota.cod-emitente  :
            end.
                       
            if not avail docum-est 
            then do:
                  
                 create tt-valida-param.
                 assign tt-valida-param.ErrorNumber      = 1 
                        tt-valida-param.ErrorDescription = "Documento n∆o gerado.".

                 RUN pi-tt-valida-erro(input table tt-valida-param).

                 undo bloco, leave bloco.

            end.    
            else do:

                for each tt-item-doc-est where
                      int(tt-item-doc-est.nro-docto)     = int(tt-nota.nro-docto)    and
                          tt-item-doc-est.serie-docto    = tt-docum-est.serie-docto  and
                          tt-item-doc-est.nat-operacao   = tt-docum-est.nat-operacao and
                          tt-item-doc-est.cod-emitente   = tt-nota.cod-emitente :
                      
                     assign tt-item-doc-est.nro-docto = docum-est.nro-docto.     
                end.
                    
                assign tt-nota.nro-docto       =  docum-est.nro-docto
                       tt-docum-est.nro-docto  =  docum-est.nro-docto.

            end.
            /* ---------- NOTA DE RATEIO ---------- */
            if  avail natur-oper
            and natur-oper.nota-rateio then do:    
                for each tt-rat-docum of tt-docum-est no-lock:
                    /* Estancia BO Rat-docum, caso o mesma nío esteja dispon≠vel */
                    if  not valid-handle(h-boin366) then do:
                        run inbo/boin366.p persistent set h-boin366.
                        run openQueryStatic in h-boin366 ( "Main":U ).
                    end.
                    
                    run pi-grava-rat-docum.
                    
                end.
                
                /* Geraªío dos itens da nota de rateio */
                
                run pi-grava-item-rateio.
                
                /* Elimina handle BO Rat-docum */
                if  valid-handle(h-boin366) then
                    run destroy in h-boin366.
            end.               
                  
            if  avail natur-oper and 
                      natur-oper.terceiros = NO  
            then do:
            
                if not can-find(first tt-item-doc-est where
                                      int(tt-item-doc-est.nro-docto) = int(tt-nota.nro-docto)    and
                                      tt-item-doc-est.serie-docto    = tt-docum-est.serie-docto  and
                                      tt-item-doc-est.nat-operacao   = tt-docum-est.nat-operacao and
                                      tt-item-doc-est.cod-emitente   = tt-nota.cod-emitente) then do:
                    
                    create tt-valida-param.
                    assign tt-valida-param.ErrorNumber      = 2 
                           tt-valida-param.ErrorDescription = "Documento nao possui itens.". 
    
                    RUN pi-tt-valida-erro(input table tt-valida-param).
                    
                end.
            end.

            /* ---------- ITENS DA NOTA FISCAL ---------- */
            
            if tt-docum-est.esp-docto <> 23 then do:
                for each tt-item-doc-est where 
                         int(tt-item-doc-est.nro-docto) = int(tt-nota.nro-docto)   and
                         tt-item-doc-est.serie-docto   = tt-docum-est.serie-docto  and  
                         tt-item-doc-est.nat-operacao  = tt-docum-est.nat-operacao and   
                         tt-item-doc-est.cod-emitente  = tt-nota.cod-emitente:
                    
                    /* Estancia BO Item-doc-Est, caso o mesma nío esteja dispon≠vel */
                            
                    RUN pi-acompanhar IN h-acomp(input "Nota/Item :" + tt-nota.nro-docto + " / " + tt-item-doc-est.it-codigo).

                    if  not valid-handle(h-boin176) then do:
                        run inbo/boin176.p persistent set h-boin176.
                        run openQueryStatic in h-boin176 ( "Main":U ).
                    end.
                                                    
                    run pi-grava-item-doc-est.
                    
                end.
            end.

            if  valid-handle(h-boin176) then do:
        
                if  l-terceiros = NO then do:
                 
                    run sethandledocumEst       in h-boin176 ( input h-boin090 ).
                    
                    run transferTotalItensnota  in h-boin176 ( input tt-docum-est.cod-emitente,
                                                               input tt-docum-est.serie-docto,
                                                               input tt-docum-est.nro-docto,
                                                               input tt-docum-est.nat-operacao ).
                end.
            
                /* Elimina handle BO Item-doc-Est, BO Saldo-Terc e BO Movto-Pend */                                                           
                if  valid-handle(h-boin176) then
                    run destroy in h-boin176.
                
                if  valid-handle(h-boin404) then
                    run destroy in h-boin404.
        
            end.            
            
            /*--- Procede com a atualizacao do documento ---*/
            if not valid-handle(h-boin090) then
                run inbo/boin090.p persistent set h-boin090.
            
            run openQueryStatic in h-boin090 ( "Main":U ).                       
    
            find first docum-est where
                       int(docum-est.nro-docto) = int(tt-docum-est.nro-docto)  and 
                       docum-est.nat-operacao   = tt-docum-est.nat-operacao and 
                       docum-est.serie-docto    = tt-docum-est.serie-docto  and
                       docum-est.cod-emitente   = tt-docum-est.cod-emitente  no-lock no-error.
                                     
            if not avail docum-est then do:
                create tt-valida-param.
                assign tt-valida-param.ErrorNumber      = 2 
                       tt-valida-param.ErrorDescription = "Documento n∆o gerado."
                       tt-valida-param.ErrorType        = 'Erro'.
                RUN pi-tt-valida-erro(input table tt-valida-param).
            end.
    
            assign tt-docum-est.r-rowid = rowid(docum-est).
    
            find first docum-est OF tt-docum-est no-lock no-error.
            if avail docum-est 
            then do:  
                 
                 find first b-docum-est exclusive-lock where
                            rowid(b-docum-est) = rowid(docum-est) NO-ERROR.
                 if avail b-docum-est then do:

                   find first int_ds_docto_xml no-lock where
                              int(int_ds_docto_xml.nNF)     = int(b-docum-est.nro-docto) and
                              int_ds_docto_xml.cod_emitente = b-docum-est.cod-emitente   and
                              int_ds_docto_xml.serie        = b-docum-est.serie NO-ERROR.
                   if avail int_ds_docto_xml then 
                      assign substring(b-docum-est.char-1,93,60) = if int_ds_docto_xml.chNfe = ? then "" else int_ds_docto_xml.chNfe. 
                       
                   release b-docum-est.
                 end.  

                 for each tt-item-doc-est  where
                          int(tt-item-doc-est.nro-docto) = int(tt-nota.nro-docto)   and
                          tt-item-doc-est.serie-docto   = tt-docum-est.serie-docto  and  
                          tt-item-doc-est.nat-operacao  = tt-docum-est.nat-operacao and   
                          tt-item-doc-est.cod-emitente  = tt-nota.cod-emitente:
                     
                     delete tt-item-doc-est.
                 end.
                 
                 /*
                 for each item-doc-est of docum-est ,
                       first item no-lock where
                             item.it-codigo = item-doc-est.it-codigo:
                      
                       find first item-uni-estab no-lock where
                                  item-uni-estab.cod-estabel = docum-est.cod-estabel and
                                  item-uni-estab.it-codigo   = item.it-codigo NO-ERROR.
                       if avail item-uni-estab if
                          assign item-doc-est.cod-depos   = item-uni-estab.deposito-pad
                                 item-doc-est.cod-localiz = item-uni-estab.cod-localiz. 
                       else 
                          assign item-doc-est.cod-depos   = item.deposito-pad
                                 item-doc-est.cod-localiz = item.cod-localiz.  
                 
                       for each rat-lote where
                                int(rat-lote.nro-docto) = int(docum-est.nro-docto) and
                                rat-lote.serie-docto  = docum-est.serie-docto  and
                                rat-lote.cod-emitente = docum-est.cod-emitente and
                                rat-lote.sequencia    = item-doc-est.sequencia and
                                rat-lote.it-codigo    = item-doc-est.it-codigo:
                                  
                            if avail item-uni-estab if
                               assign rat-lote.cod-depos   = item-uni-estab.deposito-pad
                                      rat-lote.cod-localiz = item-uni-estab.cod-localiz. 
                            else 
                               assign rat-lote.cod-depos   = item.deposito-pad
                                      rat-lote.cod-localiz = item.cod-localiz.
                       end.
                 end.
                 */

                 delete tt-docum-est.                    
            end.
    
            /**********************************************/
    
            /* Elimina handle BO Dupli-Apagar */
            if  valid-handle(h-boin092) then
                run destroy in h-boin092.
            
            /* Elimina handle BO Dupli-Imp */
            if  valid-handle(h-boin567) then 
                run destroy in h-boin567.
            
            if  valid-handle(h-boin090) then
                run destroy in h-boin090.
    
         end. /* tt-docum-est */
         
         if can-find(first tt-valida-erro where 
                           tt-valida-erro.ErrorSubType <> "warning":U) 
         then do:
                    
            undo bloco, next. 
            
         end.

     end. /* do transaction */

  end. /* last-of */

end. /* tt-nota */

run pi-finalizar in h-acomp.

procedure pi-grava-docum-est :

    /* Abertura de Query */       

    run openQueryStatic in h-boin090 ( "Main":U ).

    /* Transfere tt-docum-est para BO */
    run setRecord in h-boin090 ( input table tt-docum-est ).

    /* Determina Defaults da nota Fiscal */
    /*run setDefaultsnota in h-boin090.*/
    
    /* Cria doCUM-EST */    
    run createRecord in h-boin090.
    
    if return-value = "NOK":U then do:

        run pi-gera-erros ( input h-boin090 ).
    end.

end procedure.

/* --------------------------------- */

procedure pi-grava-rat-docum :

    /* Limpa temp-table de Itens */
    run emptyRowObject in h-boin366.
           
    for each tt2-rat-docum exclusive-lock:
        delete tt2-rat-docum.
    end.               

    /* Como a BO somente trabalha com 1 registro, o conteúdo da temp-table 
       ≤ transferido para outra temp-table idºntica */

    create tt2-rat-docum.
    buffer-copy tt-rat-docum to tt2-rat-docum.
    
    /* Transfere TT-RAT-doCUM para BO */
    run setRecord in h-boin366 ( input table tt2-rat-docum ).

    /* Cria RAT-doCUM */    
    run createRecord in h-boin366.

    if  return-value = "NOK":U then do:
        run pi-gera-erros ( input h-boin366 ).
    end.

end procedure.           

/* --------------------------------- */

procedure pi-grava-item-doc-est :
    
    /* Atualiza Funªío FifO nas Ordens de Compra */
    if  ( tt-item-doc-est.num-pedido <> 0 
    or    tt-item-doc-est.numero-ordem <> 0 )
    and tt-item-doc-est.parcela = 0 then
        assign tt-item-doc-est.log-1 = yes.
      
    /* Acessa Chave do documento */
    run linktodocumEst in h-boin176 ( input h-boin090 ).
    
    /* Limpa temp-table de Itens */
    run emptyRowObject in h-boin176.
           
    for each tt2-item-doc-est exclusive-lock:
        delete tt2-item-doc-est.
    end.               

    /* Como a BO somente trabalha com 1 registro, o conteúdo da temp-table 
       ≤ transferido para outra temp-table idºntica */
    
    create tt2-item-doc-est.
    buffer-copy tt-item-doc-est to tt2-item-doc-est.
    
    /*Se emite duplicata atualiza a conta cont†bil.*/
    /*if natur-oper.emite-duplic if
        assign tt2-item-doc-est.conta-contabil = gg-mov-contr.conta-fertilizante.    */     

    /* Transfere TT-ITEM-doC-EST para BO */
    run setRecord in h-boin176 ( input table tt2-item-doc-est ).    
      
    
    run goToKey IN h-boin176 (input tt2-item-doc-est.serie-docto  ,
                              input tt2-item-doc-est.nro-docto    ,
                              input tt2-item-doc-est.cod-emitente ,
                              input tt2-item-doc-est.nat-operacao ,
                              input tt2-item-doc-est.sequencia).  
    
    RUN validateRecord IN h-boin176(input "create").
    
    /* Cria ITEM-doC-EST */
    run createRecord in h-boin176.     

    run pi-gera-erros (input h-boin176).
    
    
end procedure.

/* --------------------------------- */

procedure pi-grava-item-rateio :

    /* Acessa Chave do documento */
    run linktodocumEst in h-boin366 ( input h-boin090 ).
    
    /* Acessa natureza de operacao */
    run findNaturOper in h-boin366 ( tt-docum-est.nat-operacao ).
    
    /* Cria tt-imposto */
    run getTTImposto in h-boin366 ( output table tt-imposto ).

    /* Cria itens da nota */
    run createRateio in h-boin366.

    MESSAGE "OK ou nok - " return-value
        VIEW-AS ALERT-BOX INFO BUTTONS OK.

    if  return-value = "NOK":U then do:
        run pi-gera-erros ( input h-boin366 ).
    end.

end procedure.

/* --------------------------------- */

procedure pi-gera-erros:
        
    def input param pihandle    as handle   no-undo.
            
    run getRowErrors in pihandle ( output table RowErrors ).
    
    for each RowErrors no-lock where 
             RowErrors.ErrorSubType = "ERROR":U OR 
            (RowErrors.ErrorSubType = "Warning":U and
             (RowErrors.ErrorNumber  = 18799 OR 
              RowErrors.ErrorNumber  = 18796)):
           
        MESSAGE "RowErrors.ErrorNumber - " RowErrors.ErrorNumber
            VIEW-AS ALERT-BOX INFO BUTTONS OK.

        find first tt-valida-erro
             where tt-valida-erro.ErrorNumber       = RowErrors.ErrorNumber
               and tt-valida-erro.ErrorDescription  = RowErrors.ErrorDescription no-lock no-error.
        if  not avail tt-valida-erro then do:

            create tt-valida-erro.
            buffer-copy RowErrors TO tt-valida-erro.
             
            if avail tt-item-doc-est then
               assign tt-valida-erro.ErrorDescription = tt-valida-erro.ErrorDescription + "."   + CHR(10) + 
                                                 "Seq:"    + string(tt-item-doc-est.sequencia)  + CHR(10) + 
                                                 "Item:"   + tt-item-doc-est.it-codigo          + CHR(10) +
                                                 "Pedido:" + string(tt-item-doc-est.num-pedido) + CHR(10) + 
                                                 "Ordem:"  + string(tt-item-doc-est.numero-ordem).
           else 
              assign tt-valida-erro.ErrorDescription = tt-valida-erro.ErrorDescription       + CHR(10) +  
                                                "Nota : "   + tt-nota.nro-docto    + CHR(10) +  
                                                "Serie: "   + tt-nota.serie-docum  + CHR(10) +
                                                "Natureza:" + tt-nota.nat-operacao + chr(10).
        end.    
    end.        

end procedure.

procedure pi-tt-valida-erro:
    def input param table for tt-valida-param.

    create tt-valida-erro.
    buffer-copy tt-valida-param TO tt-valida-erro.
    
    assign tt-valida-erro.ErrorDescription = tt-valida-erro.ErrorDescription           + CHR(10) +  
                                      "Nota : "   + tt-nota.nro-docto    + CHR(10) +  
                                      "Serie: "   + tt-nota.serie-docum  + CHR(10) +
                                      "Natureza:" + tt-nota.nat-operacao + chr(10).
end.



