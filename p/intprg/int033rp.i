assign de-acm-ct1   = 0
       de-acm-bsipi = 0
       de-acm-bcof  = 0
       de-acm-vlipi = 0
       de-acm-vlcof = 0
       n-val-pis    = 0
       n-val-cofins = 0
       d-vl-tot-item = 0
       d-vl-base-calc-pis = 0  
       d-vl-pis = 0           
       d-vl-base-calc-cofins = 0
       d-vl-cofins = 0  
       d-vl-tot-item-cfop = 0       
       d-vl-base-calc-pis-cfop = 0  
       d-vl-pis-cfop = 0             
       d-vl-base-calc-cofins-cfop = 0
       d-vl-cofins-cfop = 0
       d-vl-tot-item-bq = 0        
       d-vl-base-calc-pis-bq = 0   
       d-vl-pis-bq = 0             
       d-vl-base-calc-cofins-bq = 0
       d-vl-cofins-bq = 0.         

FOR EACH tt-doc-fiscal WHERE 
         tt-doc-fiscal.tipo-apuracao <= 2 AND  /* 1 = normal 2 = ambos */
         tt-doc-fiscal.tipo-nota      > 0 /* 1 Entrada  2 - Saida */,  
    first natur-oper where
          natur-oper.nat-operacao = tt-doc-fiscal.nat-operacao no-lock,
    each it-doc-fisc where 
         it-doc-fisc.cod-estabel  = tt-doc-fiscal.cod-estabel  and 
         it-doc-fisc.serie        = tt-doc-fiscal.serie        and 
         it-doc-fisc.nr-doc-fis   = tt-doc-fiscal.nr-doc-fis   and 
         it-doc-fisc.cod-emitente = tt-doc-fiscal.cod-emitente and 
         it-doc-fisc.nat-operacao = natur-oper.nat-operacao NO-LOCK
    break BY /*tt-doc-fiscal.cod-estabel
          BY*/ tt-doc-fiscal.tipo-nota
          BY {1}
          BY {2}
          BY {3} 
          BY {4}: 
    
    {utp/ut-liter.i "CFOP" *}
    run pi-acompanhar in h-acomp (input RETURN-VALUE + ": " + tt-doc-fiscal.cod-cfop).
    
    assign l-cabec = yes.

    if  tt-doc-fiscal.tipo-nota = 1
        then assign l-mostra = no.
    else
        assign l-mostra = yes.

    /*-------MOEDA-------*/
    assign de-cotacao = 1.
    {cdp/cd9600.i "0" "tt-doc-fiscal.dt-docto" "de-cotacao"}
    assign de-conv = 1 * de-cotacao.
    /*-----------------*/
   
    find first b-natur-oper 
        where  b-natur-oper.nat-operacao = it-doc-fisc.nat-operacao no-lock no-error. 
        
     IF tt-doc-fiscal.cd-trib-pis = "1" 
     OR tt-doc-fiscal.cd-trib-pis = "4" 
     OR tt-doc-fiscal.cd-trib-cofins = "1" 
     OR tt-doc-fiscal.cd-trib-cofins = "4"  
     THEN DO:  
         ASSIGN d-vl-base-calc-pis      = d-vl-base-calc-pis       +  (truncate(it-doc-fisc.val-base-calc-pis / de-conv, 2))
                d-vl-base-calc-pis-bq   = d-vl-base-calc-pis-bq    +  (truncate(it-doc-fisc.val-base-calc-pis / de-conv, 2))
                d-vl-pis                = d-vl-pis                 +  (truncate(it-doc-fisc.val-pis / de-conv, 2))
                d-vl-pis-bq             = d-vl-pis-bq              +  (truncate(it-doc-fisc.val-pis / de-conv, 2))
                d-vl-base-calc-pis-cfop = d-vl-base-calc-pis-cfop  +  (truncate(it-doc-fisc.val-base-calc-pis / de-conv, 2))
                d-vl-pis-cfop           = d-vl-pis-cfop            +  (truncate(it-doc-fisc.val-pis / de-conv, 2))
                d-vl-tot-item           = d-vl-tot-item      +  (truncate(it-doc-fisc.vl-tot-item / de-conv, 2))
                d-vl-tot-item-cfop      = d-vl-tot-item-cfop +  (truncate(it-doc-fisc.vl-tot-item / de-conv, 2))
                d-vl-tot-item-bq        = d-vl-tot-item-bq   + (truncate(it-doc-fisc.vl-tot-item / de-conv, 2)).
                   
     END.

     IF tt-doc-fiscal.cd-trib-pis = "1" 
     OR tt-doc-fiscal.cd-trib-pis = "4" 
     OR tt-doc-fiscal.cd-trib-cofins = "1" 
     OR tt-doc-fiscal.cd-trib-cofins = "4"  
     THEN DO:
         ASSIGN d-vl-base-calc-cofins      = d-vl-base-calc-cofins      + (truncate(it-doc-fisc.val-base-calc-cofins / de-conv, 2))
                d-vl-base-calc-cofins-bq   = d-vl-base-calc-cofins-bq   + (truncate(it-doc-fisc.val-base-calc-cofins / de-conv, 2))
                d-vl-cofins                = d-vl-cofins                + (truncate(it-doc-fisc.val-cofins / de-conv, 2))
                d-vl-base-calc-cofins-cfop = d-vl-base-calc-cofins-cfop + (truncate(it-doc-fisc.val-base-calc-cofins / de-conv, 2))
                d-vl-cofins-cfop           = d-vl-cofins-cfop           + (truncate(it-doc-fisc.val-cofins / de-conv, 2))
                d-vl-cofins-bq             = d-vl-cofins-bq             + (truncate(it-doc-fisc.val-cofins / de-conv, 2)).
     END.
    

     IF tt-param.rs-modo = 3 /* Documento Fiscal */ 
     THEN DO:

         ASSIGN de-vl-contab    = (truncate(it-doc-fisc.vl-tot-item / de-conv, 2))
                de-base-pis     = (truncate(it-doc-fisc.val-base-calc-pis / de-conv, 2))
                de-base-cofins  = (truncate(it-doc-fisc.val-base-calc-cofins / de-conv, 2))
                de-vl-pis       = (truncate(it-doc-fisc.val-pis / de-conv, 2))
                de-vl-cofins    = (truncate(it-doc-fisc.val-cofins / de-conv, 2)).

         DISP tt-doc-fiscal.cod-estabel
              tt-doc-fiscal.nr-doc-fis 
              tt-doc-fiscal.serie      
              tt-doc-fiscal.cod-emitente 
              de-vl-contab           
              de-base-pis        
              de-base-cofins    
              de-vl-pis               
              de-vl-cofins            
              with frame f-docto.
         DOWN WITH FRAME f-docto.

     END.
    
     IF tt-param.rs-modo = 4 /* Classificacao Fiscal */ 
     THEN DO:

         ASSIGN de-vl-contab    = (truncate(it-doc-fisc.vl-tot-item / de-conv, 2))
                de-base-pis     = (truncate(it-doc-fisc.val-base-calc-pis / de-conv, 2))
                de-base-cofins  = (truncate(it-doc-fisc.val-base-calc-cofins / de-conv, 2))
                de-vl-pis       = (truncate(it-doc-fisc.val-pis / de-conv, 2))
                de-vl-cofins    = (truncate(it-doc-fisc.val-cofins / de-conv, 2)).

         DISP tt-doc-fiscal.cod-estab  
              it-doc-fisc.class-fiscal
              it-doc-fisc.it-codigo       
              tt-doc-fiscal.nr-doc-fis
              de-vl-contab            
              de-base-pis            
              de-base-cofins          
              de-vl-pis             
              de-vl-cofins          
              with frame f-docto-item.
         DOWN WITH FRAME f-docto-item.

     END.

     IF tt-param.rs-modo > 1 THEN DO:
           
         if last-of({3}) 
         then do:

             disp /*tt-doc-fiscal.cod-estabel*/ b-natur-oper.nat-operacao @ c-cod-fisc        
                  d-vl-tot-item-bq @ de-vl-contab
                  d-vl-base-calc-pis-bq @ de-base-pis
                  d-vl-base-calc-cofins-bq @ de-base-cofins
                  d-vl-pis-bq @ de-vl-pis
                  d-vl-cofins-bq @ de-vl-cofins
                  b-natur-oper.denominacao @ c-desc-nat with frame f-form.
             down with frame f-form.

             /*** mostra cabecalho qdo pula pagina ***/
             if l-mostra = yes then do:
                 if line-counter + 4 > page-size then
                     view frame f-cabDoc.
             end.
                
             ASSIGN d-vl-tot-item-bq = 0 
                    d-vl-base-calc-pis-bq = 0 
                    d-vl-base-calc-cofins-bq = 0
                    d-vl-pis-bq = 0         
                    d-vl-cofins-bq = 0.


         END.

     END.

     if last-of({2}) 
     then do:

         run pi-desc-cfop(output da-dt-cfop,     
                          output c-desc-cfop-nat).
     
             disp  /*tt-doc-fiscal.cod-estabel*/ string(tt-doc-fiscal.cod-cfop,'9.999') + "   TOTAL" @ c-cod-fisc        
                   d-vl-tot-item @ de-vl-contab
                   d-vl-base-calc-pis @ de-base-pis
                   d-vl-base-calc-cofins @ de-base-cofins
                   d-vl-pis @ de-vl-pis
                   d-vl-cofins @ de-vl-cofins
                   c-desc-cfop-nat @ c-desc-nat with frame f-form.
             down with frame f-form.

         /*** mostra cabecalho qdo pula pagina ***/
         if l-mostra = yes then do:
             if line-counter + 4 > page-size then
                 view frame f-cabDoc.
         end.
            
         ASSIGN d-vl-tot-item = 0 
                d-vl-base-calc-pis = 0 
                d-vl-base-calc-cofins = 0
                d-vl-pis = 0         
                d-vl-cofins = 0.
     end. 
     
     /********************  ACUMULA PELO PRIMEIRO D÷GITO DO CFOP ********************/
    
        if LAST-OF({1}) 
        then do: 
             IF tt-doc-fiscal.cd-trib-pis = "1" 
             OR tt-doc-fiscal.cd-trib-pis = "4" 
             OR tt-doc-fiscal.cd-trib-cofins = "1" 
             OR tt-doc-fiscal.cd-trib-cofins = "4"  
             THEN DO:
                
                     /* Projeto Internacional -- Traducao de DISPLAY. Validar e verificar possibilidade de colocar em FRAME */
                     DO:
                         
                         {utp/ut-liter.i "TOTAL" *}
                         ASSIGN c-lbl-liter-total = RETURN-VALUE.

                         DISP /*tt-doc-fiscal.cod-estabel*/ string(substring(tt-doc-fiscal.cod-cfop,1,1),'9.000') + STRING('         ' + c-lbl-liter-total)                        @ c-cod-fisc
                                d-vl-tot-item-cfop         @ de-vl-contab
                                d-vl-base-calc-pis-cfop    @ de-base-pis
                                d-vl-base-calc-cofins-cfop @ de-base-cofins
                                d-vl-pis-cfop              @ de-vl-pis 
                                d-vl-cofins-cfop           @ de-vl-cofins
                              with frame f-form.
                     END. 

                     down with frame f-form.
                 
                 /*** mostra cabecalho qdo pula pagina ***/
                 if l-mostra = yes then do:
                     if line-counter + 4 > page-size then
                         view frame f-cabDoc.
                 END.
            end.  
            ELSE DO:
               
                    /* Projeto Internacional -- Traducao de DISPLAY. Validar e verificar possibilidade de colocar em FRAME */
                    DO:
                      
                        {utp/ut-liter.i "TOTAL" *}
                        ASSIGN c-lbl-liter-total-3 = RETURN-VALUE.

                         disp /*tt-doc-fiscal.cod-estabel*/ string(substring(tt-doc-fiscal.cod-cfop,1,1),'9.000') + STRING('         ' + c-lbl-liter-total)                        @ c-cod-fisc
                                d-vl-tot-item-cfop         @ de-vl-contab
                                d-vl-base-calc-pis-cfop    @ de-base-pis
                                d-vl-base-calc-cofins-cfop @ de-base-cofins
                                d-vl-pis-cfop              @ de-vl-pis 
                                d-vl-cofins-cfop           @ de-vl-cofins
                              with frame f-form.
                    END. 

                    down with frame f-form.
              
            END.

            ASSIGN d-vl-tot-item-cfop         = 0       
                   d-vl-base-calc-pis-cfop    = 0   
                   d-vl-base-calc-cofins-cfop = 0
                   d-vl-pis-cfop              = 0
                   d-vl-cofins-cfop           = 0.

        end.  
   
     /********************  ACUMULA PELO PRIMEIRO D÷GITO DO CFOP ********************/
       
     IF tt-doc-fiscal.cd-trib-pis = "1" 
     OR tt-doc-fiscal.cd-trib-pis = "4" 
     OR tt-doc-fiscal.cd-trib-cofins = "1" 
     OR tt-doc-fiscal.cd-trib-cofins = "4" 
     THEN DO:
         
             /*** acumula total geral das entradas/saidas ***/
             assign de-acm-bsipi  =  de-acm-bsipi + (truncate(it-doc-fisc.val-base-calc-pis                   / de-conv, 2)) 
                    de-acm-bcof   =  de-acm-bcof  + (truncate(it-doc-fisc.val-base-calc-cofins                / de-conv, 2)) 
                    de-acm-vlipi  =  de-acm-vlipi + (truncate(it-doc-fisc.val-pis                             / de-conv, 2)) 
                    de-acm-vlcof  =  de-acm-vlcof + (truncate(it-doc-fisc.val-cofins                          / de-conv, 2)). 
         
     END. 

     /* O valor contabil do documento deve ser somado mesmo que a natureza da nota n∆o seja tributada nem Reduzido, mas tenha valor de pis ou cofins */
     ASSIGN de-acm-ct1 =  de-acm-ct1 + (truncate(it-doc-fisc.vl-tot-item / de-conv, 2)).
      
     IF LAST-OF(tt-doc-fiscal.tipo-nota) /* Totaliza por notas de entrada/saida */
     then do:
               
        IF tt-doc-fiscal.tipo-nota = 1 /* Entrada */
        THEN DO:
         
            disp /*"Estab X" @ tt-doc-fiscal.cod-estabel*/
                 c-lb-tot-entradas   @ c-cod-fisc    
                 de-acm-ct1          @ de-vl-contab  
                 de-acm-bsipi        @ de-base-pis   
                 de-acm-bcof         @ de-base-cofins
                 de-acm-vlipi        @ de-vl-pis     
                 de-acm-vlcof        @ de-vl-cofins  
                with frame f-form.
            DOWN WITH FRAME f-form.
        
            assign de-acm-vlipi-ent = de-acm-vlipi
                   de-acm-vlcof-ent = de-acm-vlcof.

            ASSIGN de-acm-ct1   = 0    
                   de-acm-bsipi = 0  
                   de-acm-bcof  = 0  
                   de-acm-vlipi = 0  
                   de-acm-vlcof = 0.  
        END.
        else do:  /* Saida */
            disp  /*"Estab Y" @ tt-doc-fiscal.cod-estabel*/
                  c-lb-tot-saidas     @ c-cod-fisc    
                  de-acm-ct1          @ de-vl-contab  
                  de-acm-bsipi        @ de-base-pis   
                  de-acm-bcof         @ de-base-cofins
                  de-acm-vlipi        @ de-vl-pis     
                  de-acm-vlcof        @ de-vl-cofins  
                with frame f-form.
            DOWN WITH FRAME f-form.
        end.  

     END.

     if  last(tt-doc-fiscal.tipo-nota) 
     then do:
         hide frame f-cabDoc.
         hide frame f-cabDoc2.
     end.
   
end. /*** for each tt-doc-fiscal ***/ 
