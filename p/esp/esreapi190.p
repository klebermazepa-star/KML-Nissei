
/****************************************************************************************

API gera‡Æo documento entrada


*********************************************************************************************/

{rep\reapi190.i}
{utp\ut-glob.i}

define temp-table tt-param-re1005 no-undo
    field destino            as integer
    field arquivo            as char
    field usuario            as char
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field c-cod-estabel-ini  as char
    field c-cod-estabel-fim  as char
    field i-cod-emitente-ini as integer
    field i-cod-emitente-fim as integer
    field c-nro-docto-ini    as char
    field c-nro-docto-fim    as char
    field c-serie-docto-ini  as char
    field c-serie-docto-fim  as char
    field c-nat-operacao-ini as char
    field c-nat-operacao-fim as char
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.
    
define temp-table tt-digita-re1005 no-undo
    field r-docum-est        as rowid.

def VAR raw-param as raw no-undo.
DEFINE VARIABLE vMsg AS CHARACTER   NO-UNDO.


/*

def temp-table tt-erro
   field i-sequen  as int  format "9999"                   initial 1 
   field cd-erro   as int  format "99999"  
   field mensagem  as char format "x(70)".
   
   */

def temp-table tt-erro-contrato
   FIELD sequencia AS INT
   field i-sequen  as int  format "9999"                   initial 1 
   field cd-erro   as int  format "99999"  
   field mensagem  as char format "x(70)".


DEF TEMP-TABLE tt-es-contrato-docum NO-UNDO
    LIKE es-contrato-docum
    FIELD r-rowid AS ROWID
    FIELD id-selecionado AS LOG
    .

DEF BUFFER bf-es-contrato-docum FOR es-contrato-docum.      


DEF STREAM s-log.

DEFINE VARIABLE c-arquivo-aux AS CHARACTER FORMAT "x(100)"   NO-UNDO.
DEFINE VARIABLE c-key-value   AS CHARACTER   NO-UNDO.


DEFINE VARIABLE h-boin567                AS   HANDLE                             NO-UNDO.
{inbo/boin567.i tt-dupli-imp-2}


{method/dbotterr.i}
      
/**********************************************************************************************/

DEF INPUT PARAM TABLE FOR tt-es-contrato-docum.
      


/**********************************************************************************************/


    /*
find first param-estoq no-lock no-error.


MESSAGE "param-estoq.ct-tr-fornec " param-estoq.ct-tr-fornec SKIP
        " param-estoq.sc-tr-fornec " param-estoq.sc-tr-fornec
    VIEW-AS ALERT-BOX INFO BUTTONS OK.   */



DEFINE VARIABLE c-cod-depos AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-conta-contabil AS CHARACTER FORMAT "x(30)"   NO-UNDO.
DEFINE VARIABLE c-centro-custo    AS CHARACTER   NO-UNDO.




blk_contrato:
FOR EACH tt-es-contrato-docum
   WHERE tt-es-contrato-docum.id-selecionado:

    FIND FIRST emitente NO-LOCK
         WHERE emitente.cod-emitente = tt-es-contrato-docum.cod-emitente NO-ERROR.


    find first estab-mat 
            no-lock where
            estab-mat.cod-estabel = tt-es-contrato-docum.cod-estabel NO-ERROR.

    EMPTY TEMP-TABLE tt-docum-est.

    CREATE tt-docum-est.

    ASSIGN tt-docum-est.registro          = 2
           tt-docum-est.serie-docto       = tt-es-contrato-docum.serie-docto
           tt-docum-est.nro-docto         = tt-es-contrato-docum.nro-docto
           tt-docum-est.cod-emitente      = tt-es-contrato-docum.cod-emitente
           tt-docum-est.nat-operacao      = tt-es-contrato-docum.nat-operacao
           tt-docum-est.cod-observa       = 4 /* servicos */

           tt-docum-est.cod-estabel       = tt-es-contrato-docum.cod-estabel
           tt-docum-est.estab-fisc        = tt-es-contrato-docum.cod-estabel
           tt-docum-est.dt-emissao        = TODAY
           tt-docum-est.dt-trans          = today

           tt-docum-est.usuario           = c-seg-usuario

           tt-docum-est.uf                = emitente.estado

           tt-docum-est.via-transp        = 1
           tt-docum-est.mod-frete         = 9

           tt-docum-est.tot-desconto      = 0
           tt-docum-est.valor-frete       = 0
           tt-docum-est.valor-seguro      = 0
           tt-docum-est.valor-embal       = 0
           tt-docum-est.valor-outras      = 0
           tt-docum-est.dt-venc-ipi       = today
           tt-docum-est.dt-venc-icm       = today

           tt-docum-est.efetua-calculo    = 2 /* efetua os cÿlculos */

           tt-docum-est.sequencia         = 1
           tt-docum-est.esp-docto         = 21

           tt-docum-est.rec-fisico        = no
           tt-docum-est.origem            = "" /* verificar*/
           tt-docum-est.pais-origem       = "Brasil"
           tt-docum-est.cotacao-dia       = 0
           tt-docum-est.embarque          = ""

           tt-docum-est.gera-unid-neg     = 0

           tt-docum-est.tot-valor         = tt-es-contrato-docum.preco-total
           tt-docum-est.valor-mercad      = tt-es-contrato-docum.preco-unit

           tt-docum-est.nff               = YES
           tt-docum-est.cotacao-dia       = 1

           tt-docum-est.cod-modalid-frete = ""


           /* tt-docum-est.mo-codigo  = "0" */
        
            /* overlay(tt-docum-est.char-2,269,1)      = "1"  */
           .


         assign /* tt-docum-est.conta-transit = (param-estoq.ct-tr-fornec + param-estoq.sc-tr-fornec) */
                tt-docum-est.ct-transit    = "91103005"      /*  IF AVAIL estab-mat THEN estab-mat.conta-fornec ELSE "" */
                tt-docum-est.sc-transit    = "".



       EMPTY TEMP-TABLE tt-item-doc-est.

       find first item where item.it-codigo = tt-es-contrato-docum.it-codigo no-lock no-error.

       FIND FIRST item-uni-estab NO-LOCK
            WHERE item-uni-estab.cod-estabel = tt-es-contrato-docum.cod-estabel
             AND  item-uni-estab.it-codigo =  tt-es-contrato-docum.it-codigo NO-ERROR.

       IF AVAIL item-uni-estab THEN DO:

           IF trim(item-uni-estab.deposito-pad) <> "" and trim(item-uni-estab.deposito-pad) <> ? THEN
               ASSIGN c-cod-depos = item-uni-estab.deposito-pad.
           ELSE
               ASSIGN c-cod-depos = "LOJ".
       END.
       ELSE ASSIGN c-cod-depos = "LOJ".


       ASSIGN c-conta-contabil = "".



       FOR LAST medicao-contrat NO-LOCK
            WHERE medicao-contrat.nr-contrato  = tt-es-contrato-docum.nr-contrato
            AND   medicao-contrat.numero-ordem = tt-es-contrato-docum.numero-ordem:


           FIND FIRST matriz-rat-med NO-LOCK
                WHERE  matriz-rat-med.nr-contrato      = medicao-contrat.nr-contrato               
                AND    matriz-rat-med.num-seq-item     = medicao-contrat.num-seq-item             
                AND    matriz-rat-med.numero-ordem     = medicao-contrat.numero-ordem             
                AND    matriz-rat-med.num-seq-event    = medicao-contrat.num-seq-event            
                AND    matriz-rat-med.num-seq-medicao  = medicao-contrat.num-seq-medicao  NO-ERROR.



            IF AVAIL matriz-rat-med THEN DO:


                ASSIGN c-conta-contabil = matriz-rat-med.ct-codigo
                       c-centro-custo   = matriz-rat-med.sc-codigo
                       .
            END.
                
       END.

       IF c-conta-contabil = "" THEN DO:

           CREATE tt-erro-contrato.
           ASSIGN tt-erro-contrato.sequencia    =  tt-es-contrato-docum.sequencia
                  tt-erro-contrato.i-sequen     =  1
                  tt-erro-contrato.cd-erro      =  10
                  tt-erro-contrato.mensagem     =  "Conta Contabil nao vinculada a matriz da medicao (CN0302)".

           NEXT blk_contrato.
       END.


       create tt-item-doc-est.

       tt-item-doc-est.registro           = 3.
       tt-item-doc-est.it-codigo          = tt-es-contrato-docum.it-codigo.
       tt-item-doc-est.cod-refer          = "".
       tt-item-doc-est.baixa-ce           = NO.

       tt-item-doc-est.qt-do-forn         = tt-es-contrato-docum.quantidade.
       tt-item-doc-est.quantidade         = tt-es-contrato-docum.quantidade.
       tt-item-doc-est.preco-total        = tt-es-contrato-docum.preco-total. 
       tt-item-doc-est.cod-depos          = c-cod-depos.
       tt-item-doc-est.class-fiscal       = ITEM.class-fiscal.
       tt-item-doc-est.cod-localiz        = "".

       tt-item-doc-est.numero-ordem       = tt-es-contrato-docum.numero-ordem.

       tt-item-doc-est.parcela            = 1.


       /*
       tt-item-doc-est.aliquota-iss       = tt-it-nota-fisc.aliquota-iss.
       tt-item-doc-est.cd-trib-iss        = tt-it-nota-fisc.cd-trib-iss.
       tt-item-doc-est.aliquota-icm       = tt-it-nota-fisc.aliquota-icm.
       tt-item-doc-est.cd-trib-icm        = tt-it-nota-fisc.cd-trib-icm.
       tt-item-doc-est.base-icm           = tt-it-nota-fisc.vl-bicms-it.
       tt-item-doc-est.valor-icm          = tt-it-nota-fisc.vl-icms-it.
       */


       tt-item-doc-est.ind-icm-ret        = NO.
       tt-item-doc-est.narrativa          = "".

       /*
       tt-item-doc-est.serie-comp         = tt-it-nota-fisc.serie-docum.
       tt-item-doc-est.nro-comp           = tt-it-nota-fisc.nr-docum.
       */

       tt-item-doc-est.serie-docto        = tt-docum-est.serie-docto.
       tt-item-doc-est.nro-docto          = tt-docum-est.nro-docto.
       tt-item-doc-est.cod-emitente       = tt-docum-est.cod-emitente.
       tt-item-doc-est.nat-operacao       = tt-docum-est.nat-operacao.

       tt-item-doc-est.sequencia          = 10.
       tt-item-doc-est.nr-proc-imp        = "".
       tt-item-doc-est.nr-ato-concessorio = "".
       /*
       tt-item-doc-est.cd-trib-ipi        = tt-it-nota-fisc.cd-trib-ipi.
       tt-item-doc-est.base-ipi           = tt-it-nota-fisc.vl-bipi-it.
       tt-item-doc-est.aliquota-ipi       = tt-it-nota-fisc.aliquota-ipi.
       tt-item-doc-est.valor-ipi          = tt-it-nota-fisc.vl-ipi-it.
       tt-item-doc-est.icm-outras         = tt-it-nota-fisc.vl-icmsou-it.
       */

       tt-item-doc-est.lote         = "".
       tt-item-doc-est.dt-vali-lote = 12/31/9999.

       //tt-item-doc-est.ct-codigo    = "41105020".

       tt-item-doc-est.ct-codigo    = c-conta-contabil.
       tt-item-doc-est.sc-codigo    = c-centro-custo.




  EMPTY TEMP-TABLE tt-dupli-apagar.
  EMPTY TEMP-TABLE tt-dupli-imp.


  FOR EACH es-contrato-docum-dup NO-LOCK
     WHERE es-contrato-docum-dup.sequencia = tt-es-contrato-docum.sequencia:


      CREATE tt-dupli-apagar.
      ASSIGN tt-dupli-apagar.registro = 4
                                       
        tt-dupli-apagar.parcela        = es-contrato-docum-dup.parcela
        tt-dupli-apagar.nr-duplic      = es-contrato-docum-dup.nr-duplic
        tt-dupli-apagar.cod-esp        = es-contrato-docum-dup.cod-esp
        tt-dupli-apagar.tp-despesa     = es-contrato-docum-dup.tp-despesa
        tt-dupli-apagar.dt-vencim      = es-contrato-docum-dup.dt-vencim
        tt-dupli-apagar.vl-a-pagar     = es-contrato-docum-dup.vl-a-pagar // - es-contrato-docum-dup.vl-desconto KML - 12/07/2023 retirado desconto por solici‡Æo da karine
        tt-dupli-apagar.vl-desconto    = 0
        tt-dupli-apagar.dt-venc-desc   = es-contrato-docum-dup.dt-venc-desc
        /* tt-dupli-apagar.cod-ret-irf    =   */

        tt-dupli-apagar.mo-codigo      =  0
        tt-dupli-apagar.vl-a-pagar-mo  = es-contrato-docum-dup.vl-a-pagar // - es-contrato-docum-dup.vl-desconto KML - 12/07/2023 retirado desconto por solici‡Æo da karine

        tt-dupli-apagar.serie-docto    = tt-docum-est.serie-docto   
        tt-dupli-apagar.nro-docto      = tt-docum-est.nro-docto     
        tt-dupli-apagar.cod-emitente   = tt-docum-est.cod-emitente  
        tt-dupli-apagar.nat-operacao   = tt-docum-est.nat-operacao. 


      /*
      
      FOR EACH es-contrato-docum-imp NO-LOCK
          WHERE es-contrato-docum-imp.sequencia = tt-es-contrato-docum.sequencia
          AND  es-contrato-docum-imp.seq-dup   = es-contrato-docum-dup.seq-dup:

          CREATE tt-dupli-imp.
          ASSIGN tt-dupli-imp.registro = 5.

          ASSIGN
              tt-dupli-imp.cod-imp       = es-contrato-docum-imp.cod-imposto
              tt-dupli-imp.cod-esp       = es-contrato-docum-imp.cod-esp
              tt-dupli-imp.dt-venc-imp   = es-contrato-docum-imp.dt-venc-imp
              tt-dupli-imp.rend-trib     = es-contrato-docum-imp.rend-trib
              tt-dupli-imp.aliquota      = es-contrato-docum-imp.aliquota
              tt-dupli-imp.vl-imposto    = es-contrato-docum-imp.vl-imposto
              tt-dupli-imp.tp-codigo     = es-contrato-docum-imp.tp-codigo
              tt-dupli-imp.cod-retencao  = es-contrato-docum-imp.cod-retencao


              //tt-dupli-imp.ind-tipo-imposto = ""

              tt-dupli-imp.serie-docto   = tt-docum-est.serie-docto   
              tt-dupli-imp.nro-docto     = tt-docum-est.nro-docto     
              tt-dupli-imp.cod-emitente  = tt-docum-est.cod-emitente  
              tt-dupli-imp.nat-operacao  = tt-docum-est.nat-operacao
              tt-dupli-imp.parcela       = es-contrato-docum-dup.parcela.

      END.
      
      */

  END.

  EMPTY TEMP-TABLE tt-versao-integr.
  CREATE tt-versao-integr.
  ASSIGN tt-versao-integr.registro               =  3
         tt-versao-integr.cod-versao-integracao  =  4.

  EMPTY TEMP-TABLE tt-erro.
      
  run rep/reapi190.p (input  table tt-versao-integr,
                      input  table tt-docum-est,
                      input  table tt-item-doc-est,
                      input  table tt-dupli-apagar,
                      input  table tt-dupli-imp,
                      input  table tt-unid-neg-nota,
                      output table tt-erro).


  IF CAN-FIND(FIRST tt-erro) THEN DO:

     FOR EACH tt-erro:
         CREATE tt-erro-contrato.
         ASSIGN tt-erro-contrato.sequencia     =  tt-es-contrato-docum.sequencia
                tt-erro-contrato.i-sequen     =  tt-erro.i-sequen
                tt-erro-contrato.cd-erro      =  tt-erro.cd-erro
                tt-erro-contrato.mensagem     =  tt-erro.mensagem.

     END.

  END.
  ELSE DO:

       for first docum-est no-lock of tt-docum-est:

            create tt-param-re1005.
            assign 
                tt-param-re1005.destino            = 3
                tt-param-re1005.arquivo            = "esre1001.txt"
                tt-param-re1005.usuario            = c-seg-usuario
                tt-param-re1005.data-exec          = today
                tt-param-re1005.hora-exec          = time
                tt-param-re1005.classifica         = 1
                tt-param-re1005.c-cod-estabel-ini  = docum-est.cod-estabel
                tt-param-re1005.c-cod-estabel-fim  = docum-est.cod-estabel
                tt-param-re1005.i-cod-emitente-ini = docum-est.cod-emitente
                tt-param-re1005.i-cod-emitente-fim = docum-est.cod-emitente
                tt-param-re1005.c-nro-docto-ini    = docum-est.nro-docto
                tt-param-re1005.c-nro-docto-fim    = docum-est.nro-docto
                tt-param-re1005.c-serie-docto-ini  = docum-est.serie-docto
                tt-param-re1005.c-serie-docto-fim  = docum-est.serie-docto
                tt-param-re1005.c-nat-operacao-ini = docum-est.nat-operacao
                tt-param-re1005.c-nat-operacao-fim = docum-est.nat-operacao
                tt-param-re1005.da-dt-trans-ini    = docum-est.dt-trans
                tt-param-re1005.da-dt-trans-fim    = docum-est.dt-trans.


            create tt-digita-re1005.
            assign tt-digita-re1005.r-docum-est  = rowid(docum-est).

            raw-transfer tt-param-re1005 to raw-param.
            run rep/re1005rp.p (input raw-param, input table tt-raw-digita).

            empty temp-table tt-digita-re1005.
            empty temp-table tt-param-re1005.

       END.

      /* marcar registro como integrado */
      FIND FIRST bf-es-contrato-docum EXCLUSIVE-LOCK
           WHERE ROWID(bf-es-contrato-docum) = tt-es-contrato-docum.r-rowid NO-ERROR.
      IF AVAIL bf-es-contrato-docum THEN
         ASSIGN bf-es-contrato-docum.dt-integracao = TODAY.


      /* criar impostos */
      IF NOT VALID-HANDLE(h-boin567) THEN DO:
          RUN inbo/boin567.p PERSISTENT SET h-boin567.
          RUN openQueryStatic IN h-boin567("main":U).
      END.	 

      FOR EACH es-contrato-docum-dup NO-LOCK
           WHERE es-contrato-docum-dup.sequencia = tt-es-contrato-docum.sequencia:

            FOR EACH es-contrato-docum-imp NO-LOCK
                WHERE es-contrato-docum-imp.sequencia = tt-es-contrato-docum.sequencia
                AND  es-contrato-docum-imp.seq-dup   = es-contrato-docum-dup.seq-dup:

                  CREATE tt-dupli-imp-2.
                  ASSIGN tt-dupli-imp-2.serie-docto        = tt-docum-est.serie-docto
                         tt-dupli-imp-2.nro-docto          = tt-docum-est.nro-docto
                         tt-dupli-imp-2.cod-emitente       = tt-docum-est.cod-emitente
                         tt-dupli-imp-2.nat-operacao       = tt-docum-est.nat-operacao
                         tt-dupli-imp-2.parcela            = es-contrato-docum-dup.parcela
        
        
                         tt-dupli-imp-2.int-1              = es-contrato-docum-imp.cod-imposto
                         tt-dupli-imp-2.cod-esp            = es-contrato-docum-imp.cod-esp
                         tt-dupli-imp-2.tp-codigo          = es-contrato-docum-imp.tp-codigo
                         tt-dupli-imp-2.dt-venc-imp        = es-contrato-docum-imp.dt-venc-imp
                         tt-dupli-imp-2.vl-imposto         = es-contrato-docum-imp.vl-imposto
                         tt-dupli-imp-2.rend-trib          = es-contrato-docum-imp.rend-trib
                         tt-dupli-imp-2.aliquota           = es-contrato-docum-imp.aliquota
                         tt-dupli-imp-2.cod-retencao       = es-contrato-docum-imp.cod-retencao


                       //  tt-dupli-imp-2.ind-tipo-imposto   = es-contrato-docum-imp.ind-tip-impto

                         tt-dupli-imp-2.nro-docto-imp      = tt-docum-est.nro-docto
                         tt-dupli-imp-2.parcela-imp        = es-contrato-docum-dup.parcela
                         substr(tt-dupli-imp-2.char-1,1,5) = tt-docum-est.serie-docto.
        
                  EMPTY TEMP-TABLE RowErrors.
        
                  RUN setRecord IN h-boin567 (INPUT TABLE tt-dupli-imp-2 ).						
        
                  RUN createRecord IN h-boin567.
        
                  IF RETURN-VALUE = "NOK":U THEN DO:
        
                      RUN getRowErrors IN h-boin567 (OUTPUT TABLE RowErrors ).
        
                      blk_errors:
                      FOR EACH RowErrors 
                         WHERE RowErrors.ErrorSubType = "ERROR":U:

                          IF RowErrors.ErrorNumber = 2 THEN NEXT blk_errors.

        
                          IF NOT(RowErrors.ErrorType = "INTERNAL":U 
                                AND (RowErrors.ErrorNumber = 8 
                                    OR RowErrors.ErrorNumber = 10 
                                    OR RowErrors.ErrorNumber = 3)) THEN DO:
        
        
        
                              CREATE tt-erro-contrato.
                              ASSIGN tt-erro-contrato.sequencia    =  tt-es-contrato-docum.sequencia
                                     tt-erro-contrato.i-sequen     =  1
                                     tt-erro-contrato.cd-erro      =  RowErrors.ErrorNumber
                                     tt-erro-contrato.mensagem     =  RowErrors.ErrorDescription.
                          END.
                      END.
                  END.	   
        
                  DELETE tt-dupli-imp-2.
        
            END. /* docum-imp */

      END. /* docum-dup */

      IF VALID-HANDLE(h-boin567) THEN DO:
          DELETE procedure h-boin567.
          ASSIGN h-boin567 = ?.
      END.

  END. /* tt-erro */


END.

   ASSIGN c-arquivo-aux = SESSION:TEMP-DIRECTORY + "esreapi190" + STRING(TIME) + ".tmp".

   OUTPUT STREAM s-log TO VALUE(c-arquivo-aux).

   PUT STREAM s-log "LOG DE Geracao" AT 50 SKIP(2).


   
   FOR EACH tt-es-contrato-docum:


       FOR FIRST es-contrato-docum-dup NO-LOCK
           WHERE es-contrato-docum-dup.sequencia = tt-es-contrato-docum.sequencia:


           DISP STREAM s-log  
    
               tt-es-contrato-docum.sequencia    
               tt-es-contrato-docum.dt-periodo   
               tt-es-contrato-docum.num-pedido   
               tt-es-contrato-docum.nr-contrato  
               tt-es-contrato-docum.cod-emitente 
               tt-es-contrato-docum.serie-docto  
               tt-es-contrato-docum.nat-operacao 
               tt-es-contrato-docum.cod-estabel  
               tt-es-contrato-docum.dt-inclusao  
               tt-es-contrato-docum.nro-docto    
               es-contrato-docum-dup.vl-a-pagar  COLUMN-LABEL "Valor"
               es-contrato-docum-dup.dt-vencim  COLUMN-LABEL "Data Vencto"
    
               WITH FRAME f-1 STREAM-IO DOWN WIDTH 300.
           DOWN STREAM s-log WITH FRAME f-1.
    
           FOR EACH tt-erro-contrato 
               WHERE tt-erro-contrato.sequencia = tt-es-contrato-docum.sequencia:
    

               run utp/ut-msgs.p (Input "msg":U,
                                Input tt-erro-contrato.cd-erro,
                                Input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).    
               ASSIGN vMsg = RETURN-VALUE.

               DISP STREAM s-log tt-erro-contrato.i-seq COLUMN-LABEL "Seq" 
                                 tt-erro-contrato.cd-erro COLUMN-LABEL "Codigo"
                                 vMsg  COLUMN-LABEL "Erro"  FORMAT "x(100)"
                   WITH FRAME f-2 STREAM-IO DOWN WIDTH 300.
               DOWN STREAM s-log WITH FRAME f-2.
           END.                                 

       END.

   END.
   OUTPUT STREAM s-log CLOSE.

   
   /* abrir arquivo */
     get-key-value section "Datasul_EMS2" key "Show-Report-Program" value c-key-value.

     if c-key-value = "":U or c-key-value = ?  then do:
         assign c-key-value = "Notepad.exe".
         put-key-value section "Datasul_EMS2" key "Show-Report-Program" value c-key-value no-error.
     end.

     run winexec (input c-key-value + chr(32) + c-arquivo-aux, input 1).




/***************************** procedures ***************************************************/
      
      
PROCEDURE WinExec external "kernel32.dll":
    def input param prg_name  as char.
    def input param prg_style as short.
end procedure.
      
      
      
      
      
      
      
      

