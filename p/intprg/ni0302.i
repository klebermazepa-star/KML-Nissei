/******************************************************************************
**
**  Programa: OF0717.i - rotina de impressao
**
******************************************************************************/

assign de-acm-ct1   = 0 
       &if '{&bf_dis_versao_ems}' >= '2.04' &THEN
           de-acm-icmst = 0
           de-icms-sub-1= 0
           de-icms-dec-2= 0
           de-icms-sub-ent    = 0
           de-acm-icmst-dec-2 = 0
           de-acm-icmst-ent   = 0
       &endif
       de-acm-bs1   = 0   
       de-acm-ip1   = 0
       de-acm-tr1   = 0  
       de-acm-ou1   = 0
       i-cont       = 1
       de-contab-1  = 0
       de-base-1    = 0
       de-imposto-1 = 0
       de-trib-1    = 0
       de-outras-1  = 0
       c-titulo     = if  tp-natur then "SUBTOTAIS ENTRADAS"  else "SUBTOTAIS SAÖDAS"
       codigo-nat   = if  tp-natur then 1 else 2.

{cdp/cd0620.i1 c-cod-est}   /* novo formato CFOP */

if  no then find first doc-fiscal no-lock.  /* para evitar erro na include cd0620.i2 */
    

FOR EACH tt-natur-oper:
    DELETE tt-natur-oper.
END.

IF tt-param.dt-emissao-fim < da-dt-cfop THEN DO:
    for each  natur-oper  /* fields( nat-operacao char-2 cd-situacao tipo char-1 cod-cfop) */
        where natur-oper.tipo = codigo-nat no-lock:
    
        /* cfop antigo */
            create tt-natur-oper.
            assign tt-natur-oper.nat-operacao   = natur-oper.nat-operacao
                   tt-natur-oper.i-formato-cfop = if  substr(natur-oper.char-2,78,10) <> " "
                                                  then length(trim(replace(substr(natur-oper.char-2,78,10),".","")))
                                                  else 3
                   tt-natur-oper.c-formato-cfop = if  substr(natur-oper.char-2,78,10) <> " "
                                                  then trim(substring(natur-oper.char-2,78,10))
                                                  else "9.99"
                   tt-natur-oper.c-cfop         = string(substring(natur-oper.nat-operacao,1,tt-natur-oper.i-formato-cfop), 
                                                         tt-natur-oper.c-formato-cfop).
    end.
END.
ELSE  /* cfop novo */
    &IF DEFINED(bf_dis_formato_CFOP) &THEN
        for EACH cfop-natur no-lock:
            create tt-natur-oper.
            assign tt-natur-oper.nat-operacao   = string(cfop-natur.cod-cfop,"9.999XX")
                   tt-natur-oper.i-formato-cfop = 4
                   tt-natur-oper.c-formato-cfop = "9.999XX"
                   tt-natur-oper.c-cfop         = string(cfop-natur.cod-cfop,"9.999XX").
        end.
    &ELSE
        for EACH ped-curva where ped-curva.vl-aberto = 620 no-lock:
            create tt-natur-oper.
            assign tt-natur-oper.nat-operacao   = string(ped-curva.it-codigo,"9.999XX")
                   tt-natur-oper.i-formato-cfop = 4
                   tt-natur-oper.c-formato-cfop = "9.999XX"
                   tt-natur-oper.c-cfop         = string(ped-curva.it-codigo,"9.999XX").
        end.
    &ENDIF


EMPTY TEMP-TABLE tt-itens-validos.

.MESSAGE STRING(TIME,"HH:MM:SS")
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

for each tt-data,
    EACH tt-estab,
    each doc-fiscal fields ( cod-estabel serie nr-doc-fis cod-emitente vl-cont-doc    /* KML */ 
                             dt-docto nat-operacao tipo-nat estado char-1 
                             &if '{&bf_dis_versao_ems}' >= '2.05' &THEN cod-cfop &ENDIF )
    use-index ch-apuracao
    where doc-fiscal.cod-estabel = tt-estab.cod-estabel
    and  (          doc-fiscal.tipo-nat    = codigo-nat
           OR (     doc-fiscal.tipo-nat = 3 
    AND tt-param.l-considera-cfops
    &if '{&bf_dis_versao_ems}' >= '2.05' &THEN
    AND (    (    codigo-nat = 1
              AND (    doc-fiscal.cod-cfop = "1933"
                    OR doc-fiscal.cod-cfop = "2933") )
         OR  (    codigo-nat = 2
              AND (    doc-fiscal.cod-cfop = "5933"
                    OR doc-fiscal.cod-cfop = "6933") ) ) ) 
    &ELSE
    AND (    (    codigo-nat = 1
              AND (    trim(substr(doc-fiscal.char-1,1,10)) = "1933"
                    OR trim(substr(doc-fiscal.char-1,1,10)) = "2933") )
         OR  (    codigo-nat = 2
              AND (    trim(substr(doc-fiscal.char-1,1,10)) = "5933"
                    OR trim(substr(doc-fiscal.char-1,1,10)) = "6933") ) ) )
    &ENDIF 
) /* Se considera CFOPs, precisa ler tipo Servi‡o */
    and   doc-fiscal.ind-sit-doc = 1
    and   doc-fiscal.dt-docto    = tt-data.dt-docto 
    /** EPC ****************************/
    AND NOT CAN-FIND(FIRST tt-doctos-excluidos
                     WHERE tt-doctos-excluidos.rw-reg = ROWID(doc-fiscal))
    /** EPC ****************************/
    no-lock,
    FIRST tt-natur-oper
    where tt-natur-oper.nat-operacao = {cdp/cd0620.i2 "doc-fiscal" doc-fiscal.dt-docto "'9.999XX'" "''"},
    each  it-doc-fisc fields ( cod-estabel serie nr-doc-fis cod-emitente nr-seq-doc it-codigo nat-operacao vl-tot-item vl-bicms-it 
                               vl-icms-it vl-icmsnt-it vl-icmsou-it aliquota-icm vl-bsubs-it vl-icmsub-it dec-2 
                               &if '{&bf_dis_versao_ems}' >= '2.06' &THEN val-icms-subst-entr &endif) 
          of doc-fiscal no-lock,
    first item fields ( incentivado ) /* verifica se o item ‚ incentivado ou nÆo para PE */
          where item.it-codigo = it-doc-fisc.it-codigo
          and  (item.incentivado = l-incentivado 
                or l-incentivado = ? ) no-lock
   /* break by it-doc-fisc.cod-estabel
          by substr(it-doc-fisc.nat-operacao,1,1)
          by tt-natur-oper.c-cfop  */
          :
          
          run pi-acompanhar in h-acomp (INPUT "Docto: " + it-doc-fisc.nr-doc-fis).
          
          FIND FIRST tt-itens-excluidos WHERE tt-itens-excluidos.rw-reg = ROWID(it-doc-fisc) NO-LOCK NO-ERROR.

          IF NOT AVAIL tt-itens-excluidos THEN DO:
            
             FIND FIRST tt-itens-validos where
                        tt-itens-validos.cod-estabel  = it-doc-fisc.cod-estabel    AND         
                        tt-itens-validos.serie        = it-doc-fisc.serie          AND         
                        tt-itens-validos.nr-doc-fis   = it-doc-fisc.nr-doc-fis     AND         
                        tt-itens-validos.cod-emitente = it-doc-fisc.cod-emitente   AND         
                        tt-itens-validos.nat-operacao = it-doc-fisc.nat-operacao   AND          
                        tt-itens-validos.nr-seq-doc   = it-doc-fisc.nr-seq-doc     AND       
                        tt-itens-validos.c-cfop       = tt-natur-oper.c-cfop   NO-ERROR.
             IF NOT AVAIL tt-itens-validos 
             THEN DO:   

                 CREATE tt-itens-validos.                                   
                 ASSIGN tt-itens-validos.cod-estabel    = it-doc-fisc.cod-estabel
                        tt-itens-validos.serie          = it-doc-fisc.serie
                        tt-itens-validos.nr-doc-fis     = it-doc-fisc.nr-doc-fis
                        tt-itens-validos.cod-emitente   = it-doc-fisc.cod-emitente
                        tt-itens-validos.cod-estabel    = it-doc-fisc.cod-estabel
                        tt-itens-validos.nat-operacao   = it-doc-fisc.nat-operacao 
                        tt-itens-validos.natur          = substr(it-doc-fisc.nat-operacao,1,1)
                        tt-itens-validos.nr-seq-doc     = it-doc-fisc.nr-seq-doc
                        tt-itens-validos.c-formato-cfop = tt-natur-oper.c-formato-cfop
                        tt-itens-validos.c-cfop         = tt-natur-oper.c-cfop
                        tt-itens-validos.i-formato-cfop = tt-natur-oper.i-formato-cfop.
             END.

             /* Atualiza valor do ISS para notas de servi‡os.
                Tratamento necess rio para considerar o valor apenas uma vez por documento, e nÆo por item */
             IF  doc-fiscal.tipo-nat = 3 THEN DO:
                 FIND FIRST b-tt-itens-validos
                     WHERE b-tt-itens-validos.rw-doc-fisc = ROWID(doc-fisc) NO-LOCK NO-ERROR.
                 IF  NOT AVAIL b-tt-itens-validos THEN
                     ASSIGN tt-itens-validos.vl-cont-doc = doc-fisc.vl-cont-doc
                            tt-itens-validos.rw-doc-fisc = ROWID(doc-fisc).
             END.
          END.
END.


.MESSAGE "2 - " STRING(TIME, "HH:MM:SS")
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

FOR EACH tt-itens-validos NO-LOCK USE-INDEX natur
    break by tt-itens-validos.natur
          by tt-itens-validos.c-cfop:

    FIND FIRST doc-fiscal WHERE doc-fiscal.cod-estabel  = tt-itens-validos.cod-estabel
                            AND doc-fiscal.serie        = tt-itens-validos.serie
                            AND doc-fiscal.nr-doc-fis   = tt-itens-validos.nr-doc-fis
                            AND doc-fiscal.cod-emitente = tt-itens-validos.cod-emitente
                            AND doc-fiscal.nat-operacao = tt-itens-validos.nat-operacao NO-LOCK NO-ERROR.

    FIND FIRST it-doc-fisc WHERE it-doc-fisc.cod-estabel  = tt-itens-validos.cod-estabel
                             AND it-doc-fisc.serie        = tt-itens-validos.serie
                             AND it-doc-fisc.nr-doc-fis   = tt-itens-validos.nr-doc-fis
                             AND it-doc-fisc.cod-emitente = tt-itens-validos.cod-emitente
                             AND it-doc-fisc.nat-operacao = tt-itens-validos.nat-operacao 
                             AND it-doc-fisc.nr-seq-doc   = tt-itens-validos.nr-seq-doc NO-LOCK NO-ERROR.

            if  first-of(tt-itens-validos.c-cfop) THEN
                /* Inicio -- Projeto Internacional */
                DO:
                {utp/ut-liter.i "CFOP" *}
                run pi-acompanhar in h-acomp ( input RETURN-VALUE + ": " + string(tt-itens-validos.c-cfop)).
                END. 

           
            IF  FIRST-OF(tt-itens-validos.natur) THEN
                ASSIGN de-icmsnt-serv = 0
                       de-icmsou-serv = 0.

            /*-------MOEDA-------*/
            
            assign de-conv          = 1.
            &if '{&bf_dis_versao_ems}' >= '2.04' &THEN
                IF  l-icms-st THEN DO:
                    IF  codigo-nat = 1 THEN 
                        assign c-vl-tot-item-3  = c-vl-tot-item-3  + (round((it-doc-fisc.vl-tot-item) / de-conv,2)).
                    ELSE 
                        assign c-vl-tot-item-3  = c-vl-tot-item-3  + (round(it-doc-fisc.vl-tot-item / de-conv,2)).                           
                END.
                ELSE DO:
                    IF  codigo-nat = 1 THEN DO:
                        &if '{&bf_dis_versao_ems}' >= '2.06' &THEN
                            assign c-vl-tot-item-3  = c-vl-tot-item-3  + (round((it-doc-fisc.vl-tot-item - it-doc-fisc.val-icms-subst-entr)/ de-conv,2)).
                        &else
                            assign c-vl-tot-item-3  = c-vl-tot-item-3  + (round((it-doc-fisc.vl-tot-item - it-doc-fisc.dec-2)/ de-conv,2)).
                        &endif
                    END.
                    ELSE
                        assign c-vl-tot-item-3  = c-vl-tot-item-3  + (round((it-doc-fisc.vl-tot-item - it-doc-fisc.vl-icmsub-it)/ de-conv,2)).
                END.
            &else
                assign c-vl-tot-item-3  = c-vl-tot-item-3  + (round(it-doc-fisc.vl-tot-item / de-conv,2)).
            &endif
            
            IF  doc-fiscal.tipo-nat <> 3 THEN
                ASSIGN c-vl-bicms-it-3  = c-vl-bicms-it-3  + (round(it-doc-fisc.vl-bicms-it  / de-conv,2))
                       c-vl-icms-it-3   = c-vl-icms-it-3   + (round(it-doc-fisc.vl-icms-it   / de-conv,2))
                       c-vl-icmsnt-it-3 = c-vl-icmsnt-it-3 + (round(it-doc-fisc.vl-icmsnt-it / de-conv,2))
                       c-vl-icmsou-it-3 = c-vl-icmsou-it-3 + (round(it-doc-fisc.vl-icmsou-it / de-conv,2)).
            ELSE DO:
                FOR FIRST natur-oper FIELDS(cd-trib-icm nat-operacao) NO-LOCK
                    WHERE natur-oper.nat-operacao = it-doc-fisc.nat-operacao:
                END.

                IF  AVAIL natur-oper
                AND natur-oper.cd-trib-icm = 2 THEN
                    ASSIGN c-vl-icmsnt-it-3 = c-vl-icmsnt-it-3 + (round(tt-itens-validos.vl-cont-doc / de-conv,2))
                           de-icmsnt-serv   = de-icmsnt-serv   + (round(tt-itens-validos.vl-cont-doc / de-conv,2)).
                ELSE
                    ASSIGN c-vl-icmsou-it-3 = c-vl-icmsou-it-3 + (round(tt-itens-validos.vl-cont-doc / de-conv,2))
                           de-icmsou-serv   = de-icmsou-serv   + (round(tt-itens-validos.vl-cont-doc / de-conv,2)).
            END.

            accumulate (round(it-doc-fisc.vl-tot-item / de-conv,2))
                       (total by tt-itens-validos.natur)
                             
                       (ROUND(tt-itens-validos.vl-cont-doc / de-conv,2)) 
                       (TOTAL BY tt-itens-validos.natur).

            IF  doc-fiscal.tipo-nat <> 3 THEN
                ACCUMULATE (round(it-doc-fisc.vl-bicms-it / de-conv,2))
                           (total by tt-itens-validos.natur)
                 
                           (round(it-doc-fisc.vl-icms-it / de-conv,2))
                           (total by tt-itens-validos.natur)
                 
                           (round(it-doc-fisc.vl-icmsnt-it / de-conv,2))
                           (total by tt-itens-validos.natur)
                       
                           (round(it-doc-fisc.vl-icmsou-it / de-conv,2))
                           (total by tt-itens-validos.natur)
                           
                           (round(it-doc-fisc.vl-icmsub-it / de-conv,2))
                           (total by tt-itens-validos.natur)
    
                           &if '{&bf_dis_versao_ems}' >= '2.04' &THEN 
                               &if '{&bf_dis_versao_ems}' >= '2.06' &THEN
                                   (round(it-doc-fisc.val-icms-subst-entr / de-conv,2))
                                   (total by tt-itens-validos.natur) 
                               &else
                                   (round(it-doc-fisc.DEC-2 / de-conv,2))
                                   (total by tt-itens-validos.natur)
                               &endif
                           &endif.

            if  last-of(tt-itens-validos.c-cfop) then do:

                run pi-imprime-termo ( line-counter, 1 ).

                IF  l-separadores THEN DO:
                    put c-sep  at 1                                                           
                        c-sep  at 16                                                         
                        tt-itens-validos.c-cfop at 17 /* natureza de opera‡Æo com o formato */
                        c-sep  at 24
                        c-vl-tot-item-3  to 44  format ">>>,>>>,>>>,>>9.99" c-sep
                        c-vl-bicms-it-3  to 66  format ">>>,>>>,>>>,>>9.99" c-sep
                        c-vl-icms-it-3   to 88  format ">>>,>>>,>>>,>>9.99" c-sep
                        c-vl-icmsnt-it-3 to 110 format ">>>,>>>,>>>,>>9.99" c-sep
                        c-vl-icmsou-it-3 to 131 format ">>>,>>>,>>>,>>9.99" c-sep .

                     &IF '{&bf_dis_versao_ems}' >= '2.04' &THEN
                         IF LINE-COUNTER >= PAGE-SIZE THEN DO: 
                             ASSIGN i-num-pag = i-num-pag + 1.
                             RUN piTrataSeparadores.
                             DISPLAY c-tipo c-tit1 c-tit2 c-tit3 WITH FRAME f-sdiag.
                             VIEW FRAME f-bottom.
                             VIEW FRAME f-diag.
                         END.
                     &ENDIF
                END.
                else 
                    put " " AT 1
                        tt-itens-validos.c-cfop at 15  /* natureza de opera‡Æo com o formato */
                        c-vl-tot-item-3  to  44
                        c-vl-bicms-it-3  to  66
                        c-vl-icms-it-3   to  88
                        c-vl-icmsnt-it-3 to 110
                        c-vl-icmsou-it-3 to 132  format ">>>,>>>,>>>,>>9.99" .

                assign c-vl-tot-item-3  = 0      
                       c-vl-bicms-it-3  = 0
                       c-vl-icms-it-3   = 0
                       c-vl-icmsnt-it-3 = 0
                       c-vl-icmsou-it-3 = 0.
        
            end. /* if  last-of ... */
        
            if  last-of(tt-itens-validos.natur) then do:
                do  i-cont = 1 to 3:
                    if substr(it-doc-fisc.nat-operacao,1,1) = string(i-cont)
                    or substr(it-doc-fisc.nat-operacao,1,1) = string(i-cont + 4) then do:
                        assign de-contab-1[i-cont] =
                                  (accum total by tt-itens-validos.natur
                                  (round(it-doc-fisc.vl-tot-item / de-conv,2)))
                               de-base-1[i-cont]   =
                                  (accum total by tt-itens-validos.natur
                                  (round(it-doc-fisc.vl-bicms-it / de-conv,2)))
                               de-imposto-1[i-cont] =
                                  (accum total by tt-itens-validos.natur
                                  (round(it-doc-fisc.vl-icms-it  / de-conv,2)))
                               de-trib-1[i-cont]    =
                                  (accum total by tt-itens-validos.natur
                                  (round(it-doc-fisc.vl-icmsnt-it / de-conv,2))) + de-icmsnt-serv
                               de-outras-1[i-cont]  =                              
                                  (accum total by tt-itens-validos.natur
                                  (round(it-doc-fisc.vl-icmsou-it / de-conv,2))) + de-icmsou-serv
                               
                               &if '{&bf_dis_versao_ems}' >= '2.04' &THEN
                               de-icms-sub-1 [i-cont] =
                                    (accum total by tt-itens-validos.natur
                                    (round(it-doc-fisc.vl-icmsub-it / de-conv,2)))
                                   &if '{&bf_dis_versao_ems}' >= '2.06' &THEN
                                       de-icms-sub-ent [i-cont] =
                                           (accum total by tt-itens-validos.natur
                                           (round(it-doc-fisc.val-icms-subst-entr / de-conv,2)))
                                   &else
                                       de-icms-dec-2 [i-cont] =
                                           (accum total by tt-itens-validos.natur
                                           (round(it-doc-fisc.DEC-2 / de-conv,2)))
                                   &endif
                               &endif
                               de-icmsnt-serv-tot = de-icmsnt-serv-tot + de-icmsnt-serv
                               de-icmsou-serv-tot = de-icmsou-serv-tot + de-icmsou-serv.
        
                               &if '{&bf_dis_versao_ems}' >= '2.04' &THEN
                                   IF l-icms-st = NO THEN DO:
                                      IF  codigo-nat = 2 THEN 
                                          ASSIGN de-contab-1[i-cont] = de-contab-1[i-cont] - de-icms-sub-1 [i-cont]. /*Saida*/
                                      ELSE DO:
                                          &if '{&bf_dis_versao_ems}' >= '2.06' &THEN
                                               ASSIGN de-contab-1[i-cont] = de-contab-1[i-cont] - de-icms-sub-ent [i-cont]. /*Entrada a partir 206*/
                                          &else
                                               ASSIGN de-contab-1[i-cont] = de-contab-1[i-cont] - de-icms-dec-2 [i-cont]. /*Entrada*/
                                          &endif
                                      END.
                                   END.
                                   ELSE DO:
                                       IF  codigo-nat = 2 THEN 
                                           ASSIGN de-contab-1[i-cont] = de-contab-1[i-cont]. /*Saida*/
                                   END.
        
                               &endif
                               
                    end.
                end. /* do i-cont */
                ASSIGN de-icmsou-serv = 0
                       de-icmsnt-serv = 0.

            end. /* last-of */
        
            if  it-doc-fisc.vl-bicms-it + it-doc-fisc.vl-icms-it > 0 then do:
                /* CFOP antigo */
                IF doc-fiscal.dt-docto < da-dt-cfop THEN DO:
                    find first res-aliq
                         where res-aliq.nat-oper = substr(it-doc-fisc.nat-operacao,1,3)
                         and res-aliq.vl-aliq    = it-doc-fisc.aliquota-icm EXCLUSIVE-LOCK NO-ERROR .
            
                    if  not avail res-aliq then do:
                        create res-aliq.
                        assign res-aliq.nat-oper   = substr(it-doc-fisc.nat-operacao,1,3)
                               res-aliq.tp-natur   = doc-fiscal.tipo-nat
                               res-aliq.vl-aliq    = it-doc-fisc.aliquota-icm.  
                    end.
                END.
                ELSE DO:  /* CFOP novo */
                    find first res-aliq
                         where res-aliq.nat-oper = substr(it-doc-fisc.nat-operacao,1,4)
                         and res-aliq.vl-aliq    = it-doc-fisc.aliquota-icm EXCLUSIVE-LOCK NO-ERROR.
            
                    if  not avail res-aliq then do:
                        create res-aliq.
                        assign res-aliq.nat-oper   = substr(it-doc-fisc.nat-operacao,1,4)
                               res-aliq.tp-natur   = doc-fiscal.tipo-nat
                               res-aliq.vl-aliq    = it-doc-fisc.aliquota-icm.  
                    end.
                END.
        
                assign res-aliq.vl-bcalc  = res-aliq.vl-bcalc   + it-doc-fisc.vl-bicms-it
                       res-aliq.vl-impcred = res-aliq.vl-impcred + it-doc-fisc.vl-icms-it.
           
            end.  /* if  it-doc-fisc.vl-bicms-it.... */
        
            IF  doc-fiscal.tipo-nat <> 3 THEN
                run pi-gera-resumo-uf. /* gera resumo por estado */

end. /* for each doc-fiscal ... */

.MESSAGE "3 - " STRING(TIME, "HH:MM:SS")
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

IF (LINE-COUNTER + 11) > PAGE-SIZE THEN DO:

    IF  l-separadores THEN
    DO WHILE LINE-COUNTER < PAGE-SIZE:
        PUT c-sep  AT 1
            c-sep  AT 16
            c-sep  AT 24
            c-sep  AT 45
            c-sep  AT 67
            c-sep  AT 89
            c-sep  AT 111
            c-sep  AT 132.

        VIEW FRAME f-bottom.
    END.
    ELSE 
        DO WHILE LINE-COUNTER < PAGE-SIZE:
            PUT c-linha-branco AT 1 FORMAT "x(132)".
        END.

END.
.MESSAGE "4 - " STRING(TIME, "HH:MM:SS")
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
run pi-imprime-termo ( line-counter, 11 ).

if  l-separadores then do:
    
    put ("|" + fill("-",130) + "|") at 1 format "x(132)" skip
        c-sep at 1 c-titulo format "x(21)"
        substr(c-linha-branco,23,110) format "x(110)" skip
        c-linha-branco at 1.

    do  i-cont = 1 to 3:
        assign i-aux-nat = if i-aux-nat = 3
                           then 5
                           else if i-aux-nat = 7
                                then 1
                                else (i-aux-nat + 1).

         run pi-imprime-termo ( line-counter, 1 ).

         /* cfop antigo */
         IF tt-param.dt-emissao-fim < da-dt-cfop THEN DO:
             put c-sep at 1 string(i-aux-nat) format "9.00".

             case i-aux-nat:
                  when 1 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DO_ESTADO" *}
 put RETURN-VALUE         at 7.
END. 
                  when 2 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DE_OUTROS_ESTADOS" *}
 put RETURN-VALUE at 7.
END. 
                  when 3 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DO_EXTERIOR" *}
 put RETURN-VALUE       at 7.
END. 
                  when 5 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "PARA_O_ESTADO" *}
 put RETURN-VALUE     at 7.
END. 
                  when 6 then /* Inicio -- Projeto Internacional */
DO:
DEFINE VARIABLE c-lbl-liter-para-outros AS CHARACTER NO-UNDO.
{utp/ut-liter.i "PARA_OUTROS" *}
ASSIGN c-lbl-liter-para-outros = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-estados AS CHARACTER NO-UNDO.
{utp/ut-liter.i "ESTADOS" *}
ASSIGN c-lbl-liter-estados = TRIM(RETURN-VALUE).
 put c-lbl-liter-para-outros       at 7
                                  substr(c-linha-branco,23,110) at 23 format "x(110)"
                                  c-sep at 1 c-lbl-liter-estados at 7.
END. 
                  when 7 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "PARA_O_EXTERIOR" *}
 put RETURN-VALUE    at 7.
END. 
             end case.
         END.
         ELSE DO:
             put c-sep at 1 string(i-aux-nat) format "9.000".

             case i-aux-nat:
                  when 1 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DO_ESTADO" *}
 put RETURN-VALUE         at 8.
END. 
                  when 2 then /* Inicio -- Projeto Internacional */
DO:
DEFINE VARIABLE c-lbl-liter-de-outros AS CHARACTER NO-UNDO.
{utp/ut-liter.i "DE_OUTROS" *}
ASSIGN c-lbl-liter-de-outros = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-estados-2 AS CHARACTER NO-UNDO.
{utp/ut-liter.i "ESTADOS" *}
ASSIGN c-lbl-liter-estados-2 = TRIM(RETURN-VALUE).
 put c-lbl-liter-de-outros         AT 8
                                 substr(c-linha-branco,23,110) at 23 format "x(110)"
                                 c-sep at 1 c-lbl-liter-estados-2 at 8.
END. 
                  when 3 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DO_EXTERIOR" *}
 put RETURN-VALUE       at 8.
END. 
                  when 5 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "PARA_O_ESTADO" *}
 put RETURN-VALUE     at 8.
END. 
                  when 6 then /* Inicio -- Projeto Internacional */
DO:
DEFINE VARIABLE c-lbl-liter-para-outros-2 AS CHARACTER NO-UNDO.
{utp/ut-liter.i "PARA_OUTROS" *}
ASSIGN c-lbl-liter-para-outros-2 = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-estados-3 AS CHARACTER NO-UNDO.
{utp/ut-liter.i "ESTADOS" *}
ASSIGN c-lbl-liter-estados-3 = TRIM(RETURN-VALUE).
 put c-lbl-liter-para-outros-2       at 8
                                  substr(c-linha-branco,23,110) at 23 format "x(110)"
                                  c-sep at 1 c-lbl-liter-estados-3 at 8.
END. 
                  when 7 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "PARA_O_EXTERIOR" *}
 put RETURN-VALUE    at 8.
END. 
             end case.
         END.

         put c-sep at 24
             de-contab-1[i-cont]  to 44  format ">>>,>>>,>>>,>>9.99" c-sep
             de-base-1[i-cont]    to 66  format ">>>,>>>,>>>,>>9.99" c-sep
             de-imposto-1[i-cont] to 88  format ">>>,>>>,>>>,>>9.99" c-sep
             de-trib-1[i-cont]    to 110 format ">>>,>>>,>>>,>>9.99" c-sep
             de-outras-1[i-cont]  to 131 format ">>>,>>>,>>>,>>9.99" c-sep .

             run pi-imprime-termo ( line-counter, 2 ).

             if  line-counter = 1 then
                 put ("|" + fill("-",130) + "|") at 1 format "x(132)".

             put c-linha-branco at 1.
    end.
end.
else do:
    put skip(1) c-titulo at 7 format "x(30)"  skip.
    do  i-cont = 1 to 3:
        assign i-aux-nat = if i-aux-nat = 3 
                           then 5
                           else if i-aux-nat = 7
                                then 1
                                else (i-aux-nat + 1).
        run pi-imprime-termo ( line-counter, 2 ).

        IF tt-param.dt-emissao-fim < da-dt-cfop THEN DO:
           put i-aux-nat at 1 ".00"  at 2. 
        
           case i-aux-nat:
                 when 1 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DO_ESTADO" *}
 put RETURN-VALUE           at 6.
END. 
                 when 2 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DE_OUTROS_ESTADOS" *}
 put RETURN-VALUE   at 6.
END. 
                 when 3 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DO_EXTERIOR" *}
 put RETURN-VALUE         at 6. 
END. 
                 when 5 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "PARA_O_ESTADO" *}
 put RETURN-VALUE       at 6.
END. 
                 when 6 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "PARA_OUTROS_ESTADOS" *}
 put RETURN-VALUE at 6.
END. 
                 when 7 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "PARA_O_EXTERIOR" *}
 put RETURN-VALUE     at 6.
END. 
           end case.
        END.
        ELSE DO:
            put i-aux-nat at 1 ".000"  at 2. 
        
            case i-aux-nat:
                 when 1 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DO_ESTADO" *}
 put RETURN-VALUE           at 7.
END. 
                 when 2 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DE_OUTROS_ESTADOS" *}
 put RETURN-VALUE   at 7.
END. 
                 when 3 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "DO_EXTERIOR" *}
 put RETURN-VALUE         at 7. 
END. 
                 when 5 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "PARA_O_ESTADO" *}
 put RETURN-VALUE       at 7.
END. 
                 when 6 then /* Inicio -- Projeto Internacional */
DO:
DEFINE VARIABLE c-lbl-liter-para-outros-3 AS CHARACTER NO-UNDO.
{utp/ut-liter.i "PARA_OUTROS" *}
ASSIGN c-lbl-liter-para-outros-3 = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-estados-4 AS CHARACTER NO-UNDO.
{utp/ut-liter.i "ESTADOS" *}
ASSIGN c-lbl-liter-estados-4 = TRIM(RETURN-VALUE).
 put c-lbl-liter-para-outros-3         at 7 
                                 c-lbl-liter-estados-4             at 7.
END. 
                 when 7 then /* Inicio -- Projeto Internacional */
DO:
{utp/ut-liter.i "PARA_O_EXTERIOR" *}
 put RETURN-VALUE     at 7.
END. 
            end case.
        END.

        run pi-imprime-termo ( line-counter, 2 ).
    
        put de-contab-1[i-cont]  at 24
            de-base-1[i-cont]    at 46 
            de-imposto-1[i-cont] at 68
            de-trib-1[i-cont]    at 90
            " " 
            de-outras-1[i-cont] FORMAT ">>>>>>,>>>,>>>,>>9.99"
            skip(1).
    end. /* do i-cont ... */
end. /* else do: */

.MESSAGE "5 - " STRING(TIME, "HH:MM:SS")
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

assign de-acm-ct1         = de-acm-ct1 + accum total (round(it-doc-fisc.vl-tot-item  / de-conv,2)) 
       de-acm-bs1         = de-acm-bs1 + accum total (round(it-doc-fisc.vl-bicms-it  / de-conv,2))
       de-acm-ip1         = de-acm-ip1 + accum total (round(it-doc-fisc.vl-icms-it   / de-conv,2))
       de-acm-tr1         = de-acm-tr1 + de-icmsnt-serv-tot + accum total (round(it-doc-fisc.vl-icmsnt-it / de-conv,2)) 
       de-acm-ou1         = de-acm-ou1 + de-icmsou-serv-tot + accum total (round(it-doc-fisc.vl-icmsou-it / de-conv,2))
       de-icmsnt-serv-tot = 0 
       de-icmsou-serv-tot = 0.
       
      &if '{&bf_dis_versao_ems}' >= '2.06' &THEN
          ASSIGN de-acm-icmst-ent = de-acm-icmst-ent     + accum total (round(it-doc-fisc.val-icms-subst-entr / de-conv,2)). /*Entrada a partir 206*/
      &else
          ASSIGN de-acm-icmst-dec-2 = de-acm-icmst-dec-2 + accum total (round(it-doc-fisc.DEC-2 / de-conv,2)). /*Entrada*/
      &endif
           
      ASSIGN de-acm-icmst = de-acm-icmst + accum total (round(it-doc-fisc.vl-icmsub-it / de-conv,2)). /*Saida*/
      
      if  l-icms-st = NO THEN DO:
          IF  codigo-nat = 1 THEN DO:
              &if '{&bf_dis_versao_ems}' >= '2.06' &THEN
                  ASSIGN de-acm-ct1 = de-acm-ct1 - de-acm-icmst-ent.   /*Entrada*/
              &else
                  ASSIGN de-acm-ct1 = de-acm-ct1 - de-acm-icmst-dec-2. /*Entrada*/
              &endif
          END.
          ELSE DO:
              ASSIGN de-acm-ct1 = de-acm-ct1 - de-acm-icmst. /*Saida*/
          END.
      END.
       
if  l-separadores then 
    /* Inicio -- Projeto Internacional */
    DO:
    DEFINE VARIABLE c-lbl-liter-totais AS CHARACTER FORMAT "X(8)" NO-UNDO.
    {utp/ut-liter.i "TOTAIS" *}
    ASSIGN c-lbl-liter-totais = TRIM(RETURN-VALUE).
    put c-sep at 1 c-lbl-liter-totais at 8
        c-sep at 24
        de-acm-ct1 to 44  format ">>>,>>>,>>>,>>9.99" c-sep
        de-acm-bs1 to 66  format ">>>,>>>,>>>,>>9.99" c-sep
        de-acm-ip1 to 88  format ">>>,>>>,>>>,>>9.99" c-sep
        de-acm-tr1 to 110 format ">>>,>>>,>>>,>>9.99" c-sep
        de-acm-ou1 to 131 format ">>>,>>>,>>>,>>9.99" c-sep skip.
    END. 
else 
    /* Projeto Internacional -- Traducao de DISPLAY. Validar e verificar possibilidade de colocar em FRAME */
    DO:
    DEFINE VARIABLE c-lbl-liter-totais-2 AS CHARACTER FORMAT "X(14)" NO-UNDO.
    {utp/ut-liter.i "TOTAIS" *}
    ASSIGN c-lbl-liter-totais-2 = TRIM(RETURN-VALUE).
    disp STRING("      " + c-lbl-liter-totais-2) @ c-natur 
         de-acm-ct1              @ de-contab
         de-acm-bs1              @ de-base
         de-acm-ip1              @ de-imposto
         de-acm-tr1              @ de-trib
         de-acm-ou1              @ de-outras with frame f-linha.
    END. 

if l-separadores then
   assign c-linha-branco = c-sep + fill(" ",22) +
          c-sep + fill(" ",20) + c-sep + fill(" ",21) + c-sep + fill(" ",21) +
          c-sep + fill(" ",21) + c-sep + fill(" ",20) + c-sep
          c-sepa = if c-sep <> "" then c-sep else "-".
else
   assign c-linha-branco = " ".

do i-aux = line-counter to page-size:
  put c-linha-branco at 1 format "x(132)" skip.
end.  

assign da-inimes = date(month(da-iniper),1,year(da-iniper)).

/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "Gerando_Resumo_por_Estado" *}
run pi-acompanhar in h-acomp ( input RETURN-VALUE + "...").

/*  OF0717.I  */

.MESSAGE "6 - " STRING(TIME, "HH:MM:SS")
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
