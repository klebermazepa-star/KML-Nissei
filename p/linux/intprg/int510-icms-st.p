/*

re1001b2a
  btRecalc
    RUN recalculateImposto IN h-boin176
    RUN recalculateImpostoICMS IN h-boin176
      {inbo/boin176.m69} boin176.p
        run calculate_ICMS_SubsTrib_ICMSComp {inbo/boin176.m19}
          
   
            RUN calculaICMSSubstituto in h_bodi317im2bra ( input  1,
                                                           ( if avail emitente
                                                             then emitente.insc-subs-trib
                                                             else " " ),
                                                           output l-procedimento-ok) .

         assign RowObject.base-subs = tb-wt-it-imposto.vl-bsubs-it    when RowObject.nro-comp = " " or natur-oper.tipo-compra <> 3 /* Devol Cli */
                RowObject.vl-subs   = tb-wt-it-imposto.vl-icmsub-it   when RowObject.nro-comp = " " or natur-oper.tipo-compra <> 3. /* Devol Cli */

    run getDecField in h-boin176 ( input "vl-subs[1]":U, output c-desc-aux ).
    assign tt-item-doc-est.vl-subs[1]:screen-value in frame fPage0 = c-desc-aux.
    run getDecField in h-boin176 ( input "base-subs[1]":U, output c-desc-aux ).
    assign tt-item-doc-est.base-subs[1]:screen-value in frame fPage0 = c-desc-aux.


ASSIGN de-valor-pauta    = 0
       de-qtd-item       = 1      /* int_ds_it_docto_xml.?? */
       item-de-despesas  = 26.23
       de-base-icms-item = 112.66 /* int_ds_it_docto_xml.vbc-icms*/
       de-icms-item      = 19.15. /* int_ds_it_docto_xml.vicms*/

*/

DEF INPUT  PARAM p-cod-emitente  LIKE emitente.cod-emitente   NO-UNDO.
DEF INPUT  PARAM p-it-codigo     LIKE ITEM.it-codigo          NO-UNDO.
DEF INPUT  PARAM p-nat-operacao  LIKE natur-oper.nat-operacao NO-UNDO.
DEF INPUT  PARAM p-cod-estabel   LIKE estabelec.cod-estabel   NO-UNDO.
DEF INPUT  PARAM de-qtd-item       AS DECIMAL                 NO-UNDO.
DEF INPUT  PARAM de-valor-total    AS DECIMAL                 NO-UNDO.
DEF INPUT  PARAM de-desconto       AS DECIMAL                 NO-UNDO.
DEF INPUT  PARAM de-valor-ipi      AS DECIMAL                 NO-UNDO.
DEF OUTPUT PARAM de-base-st        AS DECIMAL                 NO-UNDO.
DEF OUTPUT PARAM de-vl-st          AS DECIMAL                 NO-UNDO.
DEF OUTPUT PARAM de-perc-st        AS DECIMAL                 NO-UNDO.
DEF OUTPUT PARAM c-tabela-pauta    AS CHARACTER               NO-UNDO.
DEF OUTPUT PARAM de-tabela-pauta   AS DECIMAL                 NO-UNDO.
DEF OUTPUT PARAM de-per-sub-tri    AS DECIMAL                 NO-UNDO.

DEFINE VARIABLE de-aliq-icms              AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-aliquota-icms-excessao AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-valor-pauta            AS DECIMAL     NO-UNDO.
DEFINE VARIABLE c-uf-orig                 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-uf-dest                 AS CHARACTER   NO-UNDO.

DEF BUFFER b-unid-feder-dest FOR unid-feder.
DEF BUFFER b-unid-feder-orig FOR unid-feder.

FOR FIRST para-fat NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
END.

FOR FIRST emitente NO-LOCK
    WHERE emitente.cod-emitente = p-cod-emitente QUERY-TUNING(NO-LOOKAHEAD):
END.

FOR FIRST ITEM NO-LOCK
    WHERE ITEM.it-codigo = p-it-codigo QUERY-TUNING(NO-LOOKAHEAD):
END.

FOR FIRST natur-oper NO-LOCK
    WHERE natur-oper.nat-operacao = p-nat-operacao QUERY-TUNING(NO-LOOKAHEAD):
END.

FOR FIRST estabelec no-lock
    WHERE estabelec.cod-estabel = p-cod-estabel QUERY-TUNING(NO-LOOKAHEAD):
END.

ASSIGN c-uf-orig = emitente.estado
       c-uf-dest = estabelec.estado.

IF  c-uf-orig <> "SP" AND
    c-uf-orig <> "PR" AND
    c-uf-orig <> "SC"
THEN
    ASSIGN c-uf-orig = "SP"
           c-uf-dest = "PR".

FOR FIRST b-unid-feder-orig NO-LOCK
    WHERE b-unid-feder-orig.pais   = emitente.pais  
      AND b-unid-feder-orig.estado = c-uf-orig QUERY-TUNING(NO-LOOKAHEAD):
END.

FOR FIRST b-unid-feder-dest NO-LOCK
    WHERE b-unid-feder-dest.pais   = estabelec.pais      
      AND b-unid-feder-dest.estado = c-uf-dest QUERY-TUNING(NO-LOOKAHEAD):
END.

RUN calculaValorPautaItem.

IF  c-tabela-pauta <> ""
THEN
    ASSIGN de-tabela-pauta = de-valor-pauta.

ASSIGN de-per-sub-tri = 0.

RUN calculaICMSSubstituto.


ASSIGN de-base-st       = ROUND(de-base-st,2)
       de-vl-st         = ROUND(de-vl-st,2)       
       de-perc-st       = ROUND(de-perc-st,2)     
       de-tabela-pauta  = ROUND(de-tabela-pauta,2)
       de-per-sub-tri   = ROUND(de-per-sub-tri,2). 

PROCEDURE calculaICMSSubstituto:
        
    DEFINE VARIABLE l-ind-icm-ret AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE i-cd-trib-icm AS INTEGER     NO-UNDO.
    DEFINE VARIABLE i-cont        AS INTEGER     NO-UNDO.
    
    ASSIGN l-ind-icm-ret = natur-oper.subs-trib
           i-cd-trib-icm = natur-oper.cd-trib-icm.

    if  i-cd-trib-icm <> 2 /* Isento */ and 
        i-cd-trib-icm <> 3 /* Outros */ 
    then
        if  item.cd-trib-icm = 1 /* tributado */ or  
            item.cd-trib-icm = 4 /* reduzido */ 
        then
            assign i-cd-trib-icm = item.cd-trib-icm.

    if  avail b-unid-feder-orig and 
        avail b-unid-feder-dest 
    then do  i-cont = 1 to 12:
        if  b-unid-feder-orig.est-exc[i-cont] = b-unid-feder-dest.estado 
        then
            assign de-aliquota-icms-excessao = b-unid-feder-orig.perc-exc[i-cont].
    end.

    RUN calculaAliquotaICMS (input  emitente.contrib-icms,
                             input  emitente.natureza,
                             input  c-uf-orig,
                             input  estabelec.pais,
                             input  c-uf-dest,
                             input  ITEM.it-codigo,
                             input  natur-oper.nat-operacao,
                             output de-aliq-icms).
                               
    /* Localiza o relacionamento Item X Cliente */
    for first item-cli
        where item-cli.it-codigo  = ITEM.it-codigo
        and   item-cli.nome-abrev = emitente.nome-abrev NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    end.

    /* Localizacao dos dados da relacao item X UF do item do documento */
    for first item-uf no-lock
        where item-uf.it-codigo       = ITEM.it-codigo
        and   item-uf.cod-estado-orig = c-uf-orig 
        and   item-uf.estado          = c-uf-dest QUERY-TUNING(NO-LOOKAHEAD):
    end.
                                                      
    if  natur-oper.subs-trib                 = YES AND      /* natur-oper.log-contrib-st-antec ICMS retido na fonte       */
        natur-oper.tp-base-icm              <> "D" AND      /* Formula para calculo ICMS  */
        b-unid-feder-dest.possui-subst-trib  = YES AND      /* Estado possui ST      */
        b-unid-feder-dest.ind-uf-subs        = YES AND      /* Estado possui ST           */
       (emitente.insc-subs-trib              = ""   OR      /* Inscricao auxiliar para ST */
        emitente.insc-subs-trib              = "Sem Pauta") 
    then do: 
        if  natur-oper.tp-base-icm  <> "D" 
        then do:
            assign de-base-st = de-valor-total - de-desconto + de-valor-ipi.

            if  (not avail item-cli  OR       /* Nao existe relacao Item X Cli */
                    (avail item-cli AND       /* Existe relacao Item X Cliente */
                     item-cli.vl-precon = 0)) /* Preco igual a 0   */
            THEN
                 assign /* Cacula a base de ST de acordo com percentual */
                        de-base-st =
                            if  avail item-cli
                            and item-cli.dec-1 > 0
                            then (de-base-st *
                                  (1 + item-cli.dec-1 / 100))
                            else if  avail item-uf
                                 and item-uf.per-sub-tri > 0
                                 then (de-base-st *
                                       (1 + item-uf.per-sub-tri / 100))
                                 else (de-base-st *
                                       (1 + b-unid-feder-dest.per-sub-tri / 100)).

                ASSIGN de-per-sub-tri = if  avail item-cli AND
                                                  item-cli.dec-1 > 0
                                        then item-cli.dec-1
                                        else 
                                            if  avail item-uf and 
                                                      item-uf.per-sub-tri > 0
                                            then item-uf.per-sub-tri
                                            else 
                                                b-unid-feder-dest.per-sub-tri.
        end.
    end.

    if  de-valor-pauta                      > 0              AND /* Possui valor de pauta  */
        b-unid-feder-dest.possui-subst-trib = YES            AND /* Estado possui ST pauta */
       (emitente.insc-subs-trib             = ""              OR /* Inscr. aux. para ST    */
        emitente.insc-subs-trib            <> "Sem Pauta":U) AND
        natur-oper.subs-trib                                     /* ICMS retido na fonte   */
    THEN
        assign /* Base do ICMS pela tabela de pauta. */
               de-base-st = de-qtd-item * de-valor-pauta.
               
           /* Calcula a reducao da base de ST, caso houver */
    if  avail item-uf 
    THEN DO:
        assign de-base-st = if  item-uf.perc-red-sub <> 0
                            then (de-base-st -
                                  (de-base-st *
                                  (item-uf.perc-red-sub / 100)))
                            else 
                               if  natur-oper.perc-red-icm <> 0 AND
                                   i-cd-trib-icm  = 4
                               then (de-base-st -
                                     de-base-st *
                                     (natur-oper.perc-red-icm / 100))
                               else de-base-st.
    END.


    if  i-cd-trib-icm = 1   OR
        i-cd-trib-icm = 4   OR
      ((i-cd-trib-icm = 2   OR
        i-cd-trib-icm = 3) AND
        de-base-st    > 0) 
    then do:
        /* Quando possuir aliquota de ICMS */
        if  de-aliq-icms  > 0 
        then do:
            if  l-ind-icm-ret                 = YES          AND  /* ICMS retido na fonte */
               (emitente.insc-subs-trib       = ""            OR  /* Inscr. aux. para ST  */
                emitente.insc-subs-trib       = "Sem Pauta") AND
                b-unid-feder-dest.ind-uf-subs = YES               /* Estado possui ST      */
            THEN DO:
                assign /* Calcula o valor de ICMS substituto                */
                       /* Base de ICMS Subst multiplicado pelo percentual   */
                       de-vl-st =
                           /* Trunca o valor */
                           if para-fat.arre-vlicmsub = 1 
                           then trunc(de-base-st *
                                      (if  avail item-uf
                                       and item-uf.dec-1 > 0 
                                       then item-uf.dec-1 / 100
                                       else if  b-unid-feder-dest.pc-icms-st > 0
                                            then b-unid-feder-dest.pc-icms-st / 100
                                            else natur-oper.icms-subs-trib /
                                                 100), 2)
                           /* Arredonda o valor */
                           else round(de-base-st *
                                      (if  avail item-uf
                                       and item-uf.dec-1 > 0 
                                       then item-uf.dec-1 / 100
                                       else if b-unid-feder-dest.pc-icms-st > 0
                                            then b-unid-feder-dest.pc-icms-st / 100
                                            else natur-oper.icms-subs-trib / 
                                                 100), 2).

               IF  AVAIL item-uf AND 
                         item-uf.dec-1 > 0 
               THEN 
                   ASSIGN de-perc-st = item-uf.dec-1.
               ELSE 
                   IF  b-unid-feder-dest.pc-icms-st > 0
                   THEN 
                       ASSIGN de-perc-st = b-unid-feder-dest.pc-icms-st.
                   ELSE 
                       ASSIGN de-perc-st = natur-oper.icms-subs-trib.
            END.

           /* Nao permite que o valor de ICMS ST fique negativo */
           de-vl-st = if   de-vl-st < 0
                      then 0
                      else de-vl-st.
        end.
    end.

    /* Caso vl do ICMS substituto for igual a zero, a base sera zerada. */
    assign de-base-st = if   de-vl-st = 0
                        then 0
                        else de-base-st.
END PROCEDURE.    


PROCEDURE calculaAliquotaICMS:
    /* Definiá∆o dos parÉmetros de Entrada/Sa°da */
    def input  param p-l-contrib-icms    like emitente.contrib-icms     no-undo.
    def input  param p-i-natureza-emit   like emitente.natureza         no-undo.
    def input  param p-c-estado-origem   like estabelec.estado          no-undo.
    def input  param p-c-pais-origem     like estabelec.pais            no-undo.
    def input  param p-c-estado-dest     like nota-fiscal.estado        no-undo.
    def input  param p-c-it-codigo       like item.it-codigo            no-undo.
    def input  param p-c-nat-operacao    like it-nota-fisc.nat-operacao no-undo.
    def output param p-de-aliquota       like natur-oper.aliquota-icm   no-undo.

    if  ((p-l-contrib-icms  = YES                      AND /* Emitente contribuinte        */
          p-c-estado-dest   = b-unid-feder-orig.estado) OR /* Nota interna                 */
          p-l-contrib-icms  = NO)                          /* Emitente nao contribuinte    */
    THEN
        /* Verifica aliquota diferenciada de ICMS a nivel Item/Unidade Federacao       */
        for first icms-it-uf
            fields (icms-it-uf.aliquota-icm)
            where icms-it-uf.it-codigo    = p-c-it-codigo
              and icms-it-uf.estado       = b-unid-feder-orig.estado
              and icms-it-uf.aliquota-icm > 0 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):

            /* Caso exista, utiliza a aliquota encontrada */
            assign p-de-aliquota = icms-it-uf.aliquota-icm.
        end.

    if  p-de-aliquota = 0 /* Nao existe aliquota diferenciada de ICMS        */
    then do:
        if  p-i-natureza-emit <> 3 AND /* Natureza do emitente diferente de Estrangeiro   */
            p-l-contrib-icms           /* Emitente contribuinte de ICMS                   */
        THEN
            if  p-c-estado-dest = b-unid-feder-orig.estado /* Aliquota interna    */
            THEN
                assign p-de-aliquota = b-unid-feder-orig.per-icms-int.
            else               /* Aliquota interestadual                          */
                assign p-de-aliquota = 
                           if  de-aliquota-icms-excessao > 0    /* Se houver al°quota exceá∆o */
                           then de-aliquota-icms-excessao       /* utiliza al°quota exceá∆o   */
                           else b-unid-feder-orig.per-icms-ext. /* Al°quota Externa           */

        else /* Emitente n∆o Ç contribuinte ou ele e estrangeiro                      */
            assign p-de-aliquota =
                       if  p-l-contrib-icms      = NO AND /* Emitente n∆o contribuinte     */
                           para-fat.aliq-icms-nc = 1      /* Al°quota da UF                */
                       then b-unid-feder-orig.per-icms-int
                       else 0.
    
        /* Caso for zero, utilizara a aliquota da natureza de operacao  */
        if  p-de-aliquota = 0 
        then
            assign p-de-aliquota = natur-oper.aliquota-icm.
    end.

END PROCEDURE.    


PROCEDURE calculaValorPautaItem:

    def var c-tab-pauta-dest like unid-feder.nr-tb-pauta no-undo.

    /* Inicializa a tabela de pauta destino */
    assign c-tab-pauta-dest = b-unid-feder-dest.nr-tb-pauta.

    if  substr(emitente.char-1,1,5) <> "":U 
    then
        for first tb-preco
            fields ()
            where tb-preco.nr-tabpre = substr(emitente.char-1,1,5) NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
            assign c-tab-pauta-dest = substr(emitente.char-1,1,5).
        end.

    assign de-valor-pauta = 0.

    if  (c-tab-pauta-dest              <> ""   AND /* Tab de pauta UF dest */
         natur-oper.subs-trib           = YES)  OR /* Possue ICMS retido   */
        (b-unid-feder-orig.nr-tb-pauta <> ""   AND /* Tab de pauta UF orig */
         natur-oper.subs-trib           = NO)      /* Nao possui ICMS ret  */
    THEN DO:
        /* Localiza o relacionamento Item X Cliente */
        for first item-cli
            fields (item-cli.vl-precon)
            where item-cli.it-codigo  = ITEM.it-codigo
            and   item-cli.nome-abrev = emitente.nome-abrev NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
        end.

        /* Caso exista Item X Cliente e tiver preco o vl da pauta Ç o preco do Item X Cliente */
        if  avail item-cli AND
            item-cli.vl-precon <> 0 
        then
            assign de-valor-pauta = item-cli.vl-precon.
        else 
            /* Localiza o item na tabela de pauta */
            for first preco-item
                fields (preco-item.situacao preco-item.preco-venda)
                where preco-item.it-codigo  = ITEM.it-codigo
                and   preco-item.nr-tabpre  = (if natur-oper.subs-trib
                                               then c-tab-pauta-dest
                                               else b-unid-feder-orig.nr-tb-pauta)
                and   preco-item.situacao   = 1 /* Ativo */
                and   preco-item.quant-min <= de-qtd-item NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
 
                /* Valor da pauta pelo preco do item na tabela de pauta */
                assign de-valor-pauta = preco-item.preco-venda
                       c-tabela-pauta = (if natur-oper.subs-trib           
                                         then c-tab-pauta-dest             
                                         else b-unid-feder-orig.nr-tb-pauta).
            end.
    end.
END PROCEDURE.    
