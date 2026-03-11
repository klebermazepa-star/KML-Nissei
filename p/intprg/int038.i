PROCEDURE pi-atualizaDocumento:

/*------------------------------------------------------------------------------
*     Notes: Faz a atualiza¯?o do documento com base no TT-DOCUM-EST
*
 ------------------------------------------------------------------------------*/
    EMPTY TEMP-TABLE tt-arquivo-erro.
    EMPTY TEMP-TABLE tt-erro-nota.
              
    for each tt-digita-re:
        delete tt-digita-re.
    end.

    for each tt-param-re:
        delete tt-param-re.
    end.
    
   find first usuar_mestre no-lock
        where usuar_mestre.cod_usuario = "" /* c-seg-usuario */ no-error.
    
     create tt-param-re.
     assign 
          tt-param-re.destino            = 3
          tt-param-re.arquivo            = SESSION:TEMP-DIRECTORY + "int038-re1005.txt"
          tt-param-re.usuario            = c-seg-usuario
          tt-param-re.data-exec          = today
          tt-param-re.hora-exec          = time
          tt-param-re.classifica         = 1
          tt-param-re.c-cod-estabel-ini  = docum-est.cod-estabel
          tt-param-re.c-cod-estabel-fim  = docum-est.cod-estabel
          tt-param-re.i-cod-emitente-ini = docum-est.cod-emitente
          tt-param-re.i-cod-emitente-fim = docum-est.cod-emitente
          tt-param-re.c-nro-docto-ini    = docum-est.nro-docto
          tt-param-re.c-nro-docto-fim    = docum-est.nro-docto
          tt-param-re.c-serie-docto-ini  = docum-est.serie-docto
          tt-param-re.c-serie-docto-fim  = docum-est.serie-docto
          tt-param-re.c-nat-operacao-ini = docum-est.nat-operacao
          tt-param-re.c-nat-operacao-fim = docum-est.nat-operacao
          tt-param-re.da-dt-trans-ini    = docum-est.dt-trans
          tt-param-re.da-dt-trans-fim    = docum-est.dt-trans.
    
                                      
    for each tt-raw-digita-re:
        delete tt-raw-digita-re.
    end.

    create tt-digita-re.
    assign tt-digita-re.r-docum-est = rowid(DOCUM-EST).
    
    raw-transfer tt-param-re  to raw-param.

    for each tt-digita-re:
        create tt-raw-digita-re.
        raw-transfer tt-digita-re to tt-raw-digita-re.raw-digita.
    end.
    
    if  session:set-wait-state("GENERAL":U) THEN
        run rep/re1005rp.p (input raw-param, input table tt-raw-digita-re). 
   
    INPUT FROM value(tt-param-re.arquivo) CONVERT TARGET "iso8859-1".
    
        REPEAT:
           IMPORT UNFORMATTED c-linha.
            
           CREATE tt-arquivo-erro.
           ASSIGN tt-arquivo-erro.c-linha = c-linha.
        
        END.

        FOR EACH tt-arquivo-erro WHERE
                 LENGTH(tt-arquivo-erro.c-linha) > 0:
        
            IF tt-arquivo-erro.c-linha BEGINS "-" THEN NEXT. 
        
            ASSIGN c-nr-nota  = "".
               
            DO i-cont = 1 TO 8:    
        
               DO i-pos-arq = 0 TO 10:
        
                  IF SUBSTRING(SUBSTRING(tt-arquivo-erro.c-linha,7,8),i-cont,1) = STRING(i-pos-arq) THEN 
                     ASSIGN c-nr-nota = c-nr-nota + STRING(i-pos-arq).
        
               END.
        
            END.
        
            IF c-nr-nota = "" AND 
               SUBSTRING(tt-arquivo-erro.c-linha,53,90) = "" THEN NEXT.
            
            FIND LAST tt-erro-nota NO-ERROR.

            IF c-nr-nota <> "" THEN DO:
               CREATE tt-erro-nota.
               ASSIGN tt-erro-nota.serie         = SUBSTRING(tt-arquivo-erro.c-linha,1,3)
                      tt-erro-nota.nro-docto     = c-nr-nota
                      tt-erro-nota.cod-emitente  = int(SUBSTRING(tt-arquivo-erro.c-linha,24,9)) 
                      tt-erro-nota.cod-erro      = int(SUBSTRING(tt-arquivo-erro.c-linha,44,6)).
            END.

            IF AVAIL tt-erro-nota THEN
               ASSIGN tt-erro-nota.descricao  = tt-erro-nota.descricao + SUBSTRING(tt-arquivo-erro.c-linha,53,90).
        END.

        FOR EACH tt-erro-nota WHERE
                 tt-erro-nota.serie         =  docum-est.serie        AND
                 tt-erro-nota.nro-docto     =  c-nr-nota              AND          
                 tt-erro-nota.cod-emitente  =  docum-est.cod-emitente AND                    
                 tt-erro-nota.cod-erro <> 4070  AND
                 tt-erro-nota.cod-erro <> 11010
            BREAK BY tt-erro-nota.cod-erro:
          
             assign i-erro = 41
                    c-informacao = "Docto.: " + tt-erro-nota.nro-docto + " - " + 
                                   "S‚rie: " + tt-erro-nota.serie + " - " + 
                                   "Cod. Erro: " + STRING(tt-erro-nota.cod-erro) + " - " +
                                   tt-erro-nota.descricao.

                   /* l-movto-com-erro = yes.
                      run gera-log. */

             IF LAST (tt-erro-nota.cod-erro) THEN RETURN.

        END.

 
END PROCEDURE.

PROCEDURE pi-atualizaEstoquePRS:

  DEF VAR i-ndd LIKE ndd_entryIntegration.entryintegrationId.
         
  FIND FIRST b-docum-est WHERE
             rowid(b-docum-est) = rowid(docum-est) NO-ERROR.
  IF AVAIL b-docum-est AND 
           b-docum-est.ce-atual = YES 
  THEN DO:
        
        FOR LAST ndd_entryIntegration USE-INDEX ID NO-LOCK: 
           ASSIGN i-ndd = ndd_entryIntegration.entryintegrationId + 1.
        END.
        FOR FIRST b-nota-fiscal NO-LOCK WHERE
                  b-nota-fiscal.cod-estabel      = b-docum-est.cod-estabel AND 
                  b-nota-fiscal.serie            = b-docum-est.serie    AND
              int(b-nota-fiscal.nr-nota-fis) = int(b-docum-est.nro-docto),
               FIRST natur-oper WHERE
                     natur-oper.nat-operacao = b-nota-fiscal.nat-operacao AND 
                     natur-oper.tipo         = 1  : /* Entrada */ 
                   
                   FOR FIRST int_ndd_envio WHERE
                             int_ndd_envio.cod_estabel = b-docum-est.cod-estabel    AND 
                             int(int_ndd_envio.nr_nota_fis) = int(b-docum-est.nro-docto) AND 
                             int_ndd_envio.serie       = b-docum-est.serie , 
                        FIRST estabelec NO-LOCK WHERE
                              estabelec.cod-estabel = int_ndd_envio.cod_estabel: 
                        

                        FIND FIRST ndd_entryIntegration NO-LOCK WHERE
                                   NDD_ENTRYINTEGRATION.DOCUMENTNUMBER     = int(int_ndd_envio.nr_nota_fis) AND 
                                   NDD_ENTRYINTEGRATION.SERIE              = int(int_ndd_envio.serie)       AND 
                                   NDD_ENTRYINTEGRATION.CNPJDEST           = dec(estabelec.cgc)             AND 
                                   NDD_ENTRYINTEGRATION.CNPJEMIT           = dec(estabelec.cgc) NO-ERROR.
                        IF NOT AVAIL NDD_ENTRYINTEGRATION  
                        THEN DO:
                        
                            CREATE ndd_entryIntegration.
                            ASSIGN ndd_entryIntegration.entryintegrationId = i-ndd
                                   ndd_entryIntegration.Kind               = 0 
                                   ndd_entryIntegration.STATUS_            = 0
                                   NDD_ENTRYINTEGRATION.CNPJDEST           = dec(estabelec.cgc)
                                   NDD_ENTRYINTEGRATION.CNPJEMIT           = dec(estabelec.cgc)
                                   NDD_ENTRYINTEGRATION.DOCUMENTDATA       = int_ndd_envio.documentdata
                                   NDD_ENTRYINTEGRATION.DOCUMENTNUMBER     = int(int_ndd_envio.nr_nota_fis)
                                   NDD_ENTRYINTEGRATION.EMISSIONDATE       = int_ndd_envio.dt_envio
                                   NDD_ENTRYINTEGRATION.SERIE              = int(int_ndd_envio.serie).  
            
                            RELEASE NDD_ENTRYINTEGRATION.

                        END.

                   END.  
        
        END.

  END.

END PROCEDURE.
