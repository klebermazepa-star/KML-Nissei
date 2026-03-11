DEF VAR c-linha              AS CHAR                           NO-UNDO.
DEF VAR i-cont               AS INTEGER                        NO-UNDO.
DEF VAR i-pos                AS INTEGER                        NO-UNDO.
DEF VAR c-nro-docto          AS CHAR FORMAT "x(07)"            NO-UNDO.
DEF VAR i-nro-docto          AS INTEGER FORMAT "9999999"       NO-UNDO.
DEF VAR h-cdapi024           AS HANDLE                         NO-UNDO.
DEF VAR c-cod-unid-negoc-aux LIKE it-doc-fisico.cod-unid-negoc NO-UNDO.
DEF VAR d-tot-vl-mercad      LIKE doc-fisico.valor-mercad      NO-UNDO.
DEF VAR c-estab-entrada         LIKE ordem-compra.cod-estabel     NO-UNDO.

DEF VAR de-var-qtd-re       LIKE familia.var-qtd-perm          NO-UNDO.
DEF VAR de-var-val-re-maior LIKE familia.var-pre-perm          NO-UNDO.
DEF VAR de-lim-var-qtd      AS DECIMAL format ">>>>>,>>9.9999"    Label  "Limite Var Quantidade"  NO-UNDO.
DEF VAR de-lim-var-valor    AS DECIMAL format ">>>,>>>,>>9.99999" Label  "Limite Var Valor" nO-UNDO.
DEF VAR de-qtd-max          AS DECIMAL format ">>9.99"         NO-UNDO.
def var de-var-max-perc     as decimal no-undo.
DEF VAR de-var-max-lim      AS DECIMAL NO-UNDO.
def var de-qtd-max-perc     as decimal no-undo.
DEF VAR de-qtd-max-lim      AS DECIMAL NO-UNDO.
def var de-preco-cc         as decimal no-undo.
def var de-desconto-cc      as decimal no-undo.
def var de-taxa             as decimal no-undo.

{cdp/cdcfgmat.i}

def var de-vl-merc-liq      as decimal no-undo.
def var de-vl-merc-liq-aux  as decimal no-undo.
def var de-var-min         as decimal no-undo.
def var l-contrato         as logical no-undo.
DEF VAR de-var-max         AS DECIMAL NO-UNDO.
DEF VAR de-vl-aux          AS DECIMAL NO-UNDO.
DEF VAR l-erro             AS LOGICAL NO-UNDO.
def var l-erro-co          as logical no-undo.
DEF VAR i-mes-ant          AS INTEGER NO-UNDO.


DEF BUFFER b-int-ds-doc-erro FOR int-ds-doc-erro. 

/* {utp/ut-glob.i} */ def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{intprg/int002c.i}

 def var l-unidade-negocio as log no-undo.
def var l-dis-unid-negoc  as log no-undo.
def var l-mat-unid-negoc  as log no-undo.

if can-find (first funcao where
                   funcao.cd-funcao = "ems2-unidade-negocio":U and
                   funcao.ativo     = yes) then
    assign l-unidade-negocio = yes.

find first para-dis no-lock no-error.
if avail para-dis then
    assign l-dis-unid-negoc = para-dis.log-unid-neg.

find first param-mat no-lock no-error.
if avail param-mat then
    assign l-mat-unid-negoc = param-mat.ind-unid-neg.


IF  NOT VALID-HANDLE(h-cdapi024) THEN
        RUN cdp/cdapi024.p PERSISTENT SET h-cdapi024.


DEF INPUT-OUTPUT PARAMETER TABLE FOR tt-int-ds-doc.
DEF INPUT        PARAMETER TABLE FOR tt-int-ds-it-doc.

define temp-table tt-param
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
    field i-tipo-nota-ini    as int
    field i-tipo-nota-fim    as int
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.

define temp-table tt-digita
    field r-doc-fisico        as rowid.

define temp-table tt-raw-digita
    field raw-digita as raw.

def var raw-param as raw no-undo.

DEF TEMP-TABLE tt-erro
FIELD c-linha AS CHAR.

DEF TEMP-TABLE tt-erro-nota NO-UNDO
FIELD tipo-erro    AS CHAR
FIELD serie        AS CHAR FORMAT "x(03)"
FIELD nro-docto    AS CHAR FORMAT "9999999"
FIELD cod-emitente AS INTEGER FORMAT ">>>>>>>>9"
FIELD nat-operacao AS CHAR    FORMAT "x(06)"
FIELD tipo-nota    AS INT     FORMAT ">9"
FIELD cod-erro     AS INTEGER FORMAT ">>>>>9"
FIELD descricao    AS CHAR. 

DEF BUFFER b-it-doc-fisico FOR it-doc-fisico.

FIND FIRST param-estoq  NO-LOCK NO-ERROR.
FIND FIRST param-global NO-LOCK NO-ERROR.

find param-re where
     param-re.usuario = c-seg-usuario no-lock no-error.

EMPTY TEMP-TABLE tt-erro-nota.

         
FOR EACH tt-int-ds-doc WHERE
         tt-int-ds-doc.marca   = "*" AND
         tt-int-ds-doc.situacao = 2
    BREAK BY tt-int-ds-doc.nro-docto
          BY tt-int-ds-doc.cod-emitente :            
            
            
    IF LAST-OF(tt-int-ds-doc.cod-emitente) THEN DO:

       FOR EACH int-ds-doc-erro EXCLUSIVE-LOCK  WHERE
                int-ds-doc-erro.serie-docto  = tt-int-ds-doc.serie-docto  AND 
                int-ds-doc-erro.cod-emitente = tt-int-ds-doc.cod-emitente AND
                int-ds-doc-erro.nro-docto    = tt-int-ds-doc.nro-docto    AND
                int-ds-doc-erro.nat-operacao = tt-int-ds-doc.nat-operacao AND 
                int-ds-doc-erro.tipo-nota    = tt-int-ds-doc.tipo-nota:
         
           DELETE int-ds-doc-erro.
       END.

    END.
        
    FIND FIRST doc-fisico NO-LOCK WHERE
               doc-fisico.nro-docto     = trim(string(int(tt-int-ds-doc.nro-docto),">>>9999999")) AND
               doc-fisico.serie-docto   = tt-int-ds-doc.serie                            AND
               doc-fisico.cod-emitente  = tt-int-ds-doc.cod-emitente                     AND
               doc-fisico.tipo-nota     = tt-int-ds-doc.tipo-nota NO-ERROR.
    IF AVAIL doc-fisico THEN DO:

       CREATE tt-erro-nota.
       ASSIGN tt-erro-nota.serie         =  tt-int-ds-doc.serie
              tt-erro-nota.nro-docto     = tt-int-ds-doc.nro-docto
              tt-erro-nota.cod-emitente  = tt-int-ds-doc.cod-emitente 
              tt-erro-nota.nat-operacao  = tt-int-ds-doc.nat-operacao  
              tt-erro-nota.tipo-nota     = tt-int-ds-doc.tipo-nota
              tt-erro-nota.tipo-erro     = "Erro" 
              tt-erro-nota.cod-erro      = 9001
              tt-erro-nota.descricao     = "Documento recebimento f¡sico j  cadastrado".

    END.                                       
    
    FOR FIRST param-estoq NO-LOCK:
        IF  date(int(substring(param-estoq.ult-per-fech,5,2)),1,int(SUBSTRING(param-estoq.ult-per-fech,1,4))) >= tt-int-ds-doc.dt-trans THEN DO:
            CREATE tt-erro-nota.
            ASSIGN tt-erro-nota.serie         = tt-int-ds-doc.serie
                   tt-erro-nota.nro-docto     = tt-int-ds-doc.nro-docto
                   tt-erro-nota.cod-emitente  = tt-int-ds-doc.cod-emitente 
                   tt-erro-nota.nat-operacao  = tt-int-ds-doc.nat-operacao  
                   tt-erro-nota.tipo-nota     = tt-int-ds-doc.tipo-nota
                   tt-erro-nota.tipo-erro     = "Erro" 
                   tt-erro-nota.cod-erro      = 9003
                   tt-erro-nota.descricao     = "Per¡odo fechado. Imposs¡vel movimentar documentos para o mˆs " + STRING(MONTH(tt-int-ds-doc.dt-trans)).
        END.
        ELSE DO:
            i-mes-ant = MONTH(tt-int-ds-doc.dt-trans).
            IF i-mes-ant = 1 THEN i-mes-ant = 12. ELSE i-mes-ant = i-mes-ant - 1.
            IF  date(int(substring(param-estoq.ult-per-fech,5,2)),1,int(SUBSTRING(param-estoq.ult-per-fech,1,4))) < tt-int-ds-doc.dt-trans AND
                i-mes-ant = INT(substring(param-estoq.ult-per-fech,5,2)) AND
                param-estoq.fase-medio > 1 THEN DO:
                CREATE tt-erro-nota.
                ASSIGN tt-erro-nota.serie         = tt-int-ds-doc.serie
                       tt-erro-nota.nro-docto     = tt-int-ds-doc.nro-docto
                       tt-erro-nota.cod-emitente  = tt-int-ds-doc.cod-emitente 
                       tt-erro-nota.nat-operacao  = tt-int-ds-doc.nat-operacao  
                       tt-erro-nota.tipo-nota     = tt-int-ds-doc.tipo-nota
                       tt-erro-nota.tipo-erro     = "Erro" 
                       tt-erro-nota.cod-erro      = 9003
                       tt-erro-nota.descricao     = "M‚dio j  est  sendo calculado para o per¡odo. Imposs¡vel movimentar documentos para o mˆs " + STRING(MONTH(tt-int-ds-doc.dt-trans)).
            END.
        END.
    END.

    IF tt-int-ds-doc.dt-emissao < (today - param-re.var-emis) then do:
       
       CREATE tt-erro-nota.
       ASSIGN tt-erro-nota.serie         = tt-int-ds-doc.serie
              tt-erro-nota.nro-docto     = tt-int-ds-doc.nro-docto
              tt-erro-nota.cod-emitente  = tt-int-ds-doc.cod-emitente
              tt-erro-nota.nat-operacao  = tt-int-ds-doc.nat-operacao  
              tt-erro-nota.tipo-nota     = tt-int-ds-doc.tipo-nota
              tt-erro-nota.tipo-erro     = "Erro"
              tt-erro-nota.cod-erro      = 8824.
        
        run utp/ut-msgs.p (input "Msg":U, input 8824, input "EmissÆo").

        ASSIGN tt-erro-nota.descricao    = RETURN-VALUE.
    end.
    
    ASSIGN c-estab-entrada = param-estoq.estabel-pad.

    FOR FIRST tt-int-ds-it-doc OF tt-int-ds-doc,
         FIRST ordem-compra NO-LOCK WHERE
               ordem-compra.numero-ordem = tt-int-ds-it-doc.numero-ordem :
       
         ASSIGN c-estab-entrada = ordem-compra.cod-estabel.

    END.
    
    FIND FIRST estabelec NO-LOCK WHERE
               estabelec.cod-emitente = tt-int-ds-doc.cod-emitente NO-ERROR.
    IF AVAIL estabelec 
    THEN DO:   
       
       IF c-estab-entrada = estabelec.cod-estabel 
       THEN DO:
          CREATE tt-erro-nota.
          ASSIGN tt-erro-nota.serie         = tt-int-ds-doc.serie
                 tt-erro-nota.nro-docto     = tt-int-ds-doc.nro-docto
                 tt-erro-nota.cod-emitente  = tt-int-ds-doc.cod-emitente 
                 tt-erro-nota.nat-operacao  = tt-int-ds-doc.nat-operacao  
                 tt-erro-nota.tipo-nota     = tt-int-ds-doc.tipo-nota
                 tt-erro-nota.tipo-erro     = "Erro" 
                 tt-erro-nota.cod-erro      = 9002
                 tt-erro-nota.descricao     = "Documento de entrada ‚ uma transferˆncia entre estabelecimentos."  + chr(10) +  
                                              "O estabelecimento de origem " + c-estab-entrada + 
                                              " deve ser diferente do estabelecimento do documento " + estabelec.cod-estabel.
       END.

    END.     
    
    FIND FIRST tt-erro-nota WHERE
               tt-erro-nota.serie         = tt-int-ds-doc.serie        AND
               tt-erro-nota.nro-docto     = tt-int-ds-doc.nro-docto    and
               tt-erro-nota.cod-emitente  = tt-int-ds-doc.cod-emitente AND 
               tt-erro-nota.nat-operacao  = tt-int-ds-doc.nat-operacao AND 
               tt-erro-nota.tipo-nota     = tt-int-ds-doc.tipo-nota    AND   
               tt-erro-nota.tipo-erro     = "Erro" NO-ERROR.
    IF AVAIL tt-erro-nota THEN NEXT.
   
    /*** NÆo foi utilizado BO pois o produto tb‚m nao utiliza , na bo original nÆo existe nenhuma valida‡Æo ***/   
   
    bloco:
    do transaction on error undo , next : 
    
        CREATE doc-fisico.
        ASSIGN doc-fisico.nro-docto     = trim(string(int(tt-int-ds-doc.nro-docto),">>>9999999"))
               doc-fisico.serie-docto   = tt-int-ds-doc.serie
               doc-fisico.cod-emitente  = tt-int-ds-doc.cod-emitente
               doc-fisico.cod-estabel   = c-estab-entrada
               doc-fisico.dt-atualiza   = TODAY  
               doc-fisico.dt-emissao    = tt-int-ds-doc.dt-emissao
               doc-fisico.dt-trans      = tt-int-ds-doc.dt-trans 
               doc-fisico.mo-codigo     = 0    
               doc-fisico.situacao      = 1
               doc-fisico.tipo-nota     = 1 /* Compra */ 
               doc-fisico.usuario       = c-seg-usuario
               doc-fisico.observacao    = "Integra‡Æo automatica XML".
        
        FIND FIRST estabelec WHERE
                   estabelec.cod-emitente = doc-fisico.cod-emitente NO-ERROR.
        IF AVAIL estabelec THEN
           ASSIGN doc-fisico.tipo-nota    = 3 /* NFT */ 
                  doc-fisico.cod-estabel  = c-estab-entrada
                  doc-fisico.estab-de-or  = estabelec.cod-estabel.

        ASSIGN d-tot-vl-mercad  = 0.

        FOR EACH tt-int-ds-it-doc WHERE 
                 tt-int-ds-it-doc.nro-docto      = tt-int-ds-doc.nro-docto      and
                 tt-int-ds-it-doc.serie-docto    = tt-int-ds-doc.serie          and
                 tt-int-ds-it-doc.cod-emitente   = tt-int-ds-doc.cod-emitente   and
                 tt-int-ds-it-doc.tipo-nota      = tt-int-ds-doc.tipo-nota ,
             FIRST ITEM NO-LOCK WHERE  
                   ITEM.it-codigo =  tt-int-ds-it-doc.it-codigo:
            CREATE it-doc-fisico.
            ASSIGN it-doc-fisico.nro-docto      = doc-fisico.nro-docto   
                   it-doc-fisico.serie-docto    = doc-fisico.serie-docto 
                   it-doc-fisico.cod-emitente   = doc-fisico.cod-emitente
                   it-doc-fisico.tipo-nota      = doc-fisico.tipo-nota
                   it-doc-fisico.sequencia      = tt-int-ds-it-doc.sequencia
                   it-doc-fisico.it-codigo      = tt-int-ds-it-doc.it-codigo
                   it-doc-fisico.un             = /*ITEM.un*/ "CX"
                   it-doc-fisico.baixa-ce       = YES
                   it-doc-fisico.quantidade     = tt-int-ds-it-doc.quantidade
                   it-doc-fisico.qt-do-forn     = tt-int-ds-it-doc.qt-do-forn
                   it-doc-fisico.preco-total[1] = tt-int-ds-it-doc.preco-total[1]
                   it-doc-fisico.preco-unit[1]  = tt-int-ds-it-doc.preco-unit[1]  
                   it-doc-fisico.parcela        = tt-int-ds-it-doc.parcela
                   it-doc-fisico.char-2         = tt-int-ds-it-doc.nat-operacao. 
            if can-find (first pedido-compr no-lock where pedido-compr.num-pedido = tt-int-ds-it-doc.num-pedido) then
                assign it-doc-fisico.num-pedido     = tt-int-ds-it-doc.num-pedido.

            FIND FIRST ordem-compra NO-LOCK WHERE
                       ordem-compra.numero-ordem = tt-int-ds-it-doc.numero-ordem NO-ERROR.
            IF AVAIL ordem-compra THEN DO:
               assign it-doc-fisico.numero-ordem   = tt-int-ds-it-doc.numero-ordem.

               FIND FIRST cotacao-item NO-LOCK WHERE
                          cotacao-item.cod-emitente = it-doc-fisico.cod-emitente AND
                          cotacao-item.numero-ordem = ordem-compra.numero-ordem  AND
                          cotacao-item.it-codigo    = ordem-compra.it-codigo     AND
                          cotacao-item.cot-aprovada = YES NO-ERROR.
               IF AVAIL cotacao-item THEN
                  ASSIGN it-doc-fisico.preco-unit[1]  = cotacao-item.preco-fornec
                         it-doc-fisico.preco-total[1] = cotacao-item.preco-fornec * it-doc-fisico.quantidade
                         d-tot-vl-mercad              =  d-tot-vl-mercad + it-doc-fisico.preco-total[1].
               
               ASSIGN it-doc-fisico.conta-contabil = ordem-compra.conta-contabil
                      it-doc-fisico.ct-codigo      = ordem-compra.ct-codigo
                      it-doc-fisico.sc-codigo      = ordem-compra.sc-codigo 
                      it-doc-fisico.narrativa      = ordem-compra.narrativa. 

               FIND FIRST prazo-compra EXCLUSIVE-LOCK WHERE 
                          prazo-compra.numero-ordem = ordem-compra.numero-ordem and 
                          prazo-compra.parcela      = it-doc-fisico.parcela NO-ERROR.
               if AVAIL prazo-compra then
                  ASSIGN prazo-compra.dec-1  = prazo-compra.dec-1 + it-doc-fisico.quantidade
                         it-doc-fisico.dec-1 = prazo-compra.dec-1.

               RELEASE prazo-compra.
            End.
            ELSE DO:
                ASSIGN d-tot-vl-mercad    =  d-tot-vl-mercad + it-doc-fisico.preco-total[1].
            END.

            IF  VALID-HANDLE(h-cdapi024) THEN DO:
            
                RUN RetornaUnidadeNegocioExternaliz IN h-cdapi024 (INPUT doc-fisico.cod-estabel,
                                                                   INPUT it-doc-fisico.it-codigo,
                                                                   INPUT "",
                                                                   OUTPUT c-cod-unid-negoc-aux).

                 ASSIGN it-doc-fisico.cod-unid-negoc  = c-cod-unid-negoc-aux. 

            END.           
            
            CREATE rat-lote.
            ASSIGN rat-lote.nro-docto    = doc-fisico.nro-docto   
                   rat-lote.serie-docto  = doc-fisico.serie-docto 
                   rat-lote.cod-emitente = doc-fisico.cod-emitente
                   rat-lote.sequencia    = it-doc-fisico.sequencia
                   rat-lote.nat-operacao = " "
                   rat-lote.it-codigo    = it-doc-fisico.it-codigo
                   rat-lote.qtd-origin   = tt-int-ds-it-doc.quantidade
                   rat-lote.quantidade   = tt-int-ds-it-doc.quantidade
                   rat-lote.tipo-nota    = doc-fisico.tipo-nota.

           FIND FIRST item-uni-estab NO-LOCK WHERE
                      item-uni-estab.cod-estabel = doc-fisico.cod-estabel AND
                      item-uni-estab.it-codigo   = it-doc-fisico.it-codigo NO-ERROR.
           IF AVAIL item-uni-estab THEN
              ASSIGN rat-lote.cod-depos   = item-uni-estab.deposito-pad
                     rat-lote.cod-localiz = item-uni-estab.cod-localiz. 
           ELSE 
              ASSIGN rat-lote.cod-depos   = item.deposito-pad
                     rat-lote.cod-localiz = item.cod-localiz.
              
             IF l-unidade-negocio AND l-mat-unid-negoc AND 
                (doc-fisico.tipo-nota = 1 OR
                 doc-fisico.tipo-nota = 9) THEN DO:

                RUN cdp/cd9760.p (INPUT 4,
                                  it-doc-fisico.it-codigo,
                                  ROWID(it-doc-fisico)).
             END.
             ELSE DO:
                 IF  l-mat-unid-negoc  THEN DO:
                     RUN cdp/cd9760.p (INPUT 4,
                                  it-doc-fisico.it-codigo,
                                  ROWID(it-doc-fisico)).

                 END.
             END.
             
        END.
       
        ASSIGN doc-fisico.valor-mercad  = d-tot-vl-mercad.

        FOR EACH tt-erro-nota WHERE
                 tt-erro-nota.serie         =  tt-int-ds-doc.serie        AND
                 tt-erro-nota.nro-docto     =  tt-int-ds-doc.nro-docto    and
                 tt-erro-nota.cod-emitente  =  tt-int-ds-doc.cod-emitente AND   
                 tt-erro-nota.nat-operacao  = tt-int-ds-doc.nat-operacao  AND 
                 tt-erro-nota.tipo-nota     = tt-int-ds-doc.tipo-nota     AND
                 tt-erro-nota.cod-erro <> 4070                            AND
                 tt-erro-nota.tipo-erro     = "Erro"   
            BREAK BY tt-erro-nota.cod-erro:
            
            IF LAST(tt-erro-nota.cod-erro) THEN
               UNDO bloco , NEXT.
        END.

        IF NOT CAN-FIND(FIRST tt-erro-nota WHERE
                              tt-erro-nota.serie         = tt-int-ds-doc.serie        AND
                              tt-erro-nota.nro-docto     = tt-int-ds-doc.nro-docto    AND
                              tt-erro-nota.cod-emitente  = tt-int-ds-doc.cod-emitente AND 
                              tt-erro-nota.nat-operacao  = tt-int-ds-doc.nat-operacao AND 
                              tt-erro-nota.tipo-nota     = tt-int-ds-doc.tipo-nota)    
        THEN DO:  
           FIND FIRST int-ds-docto-xml EXCLUSIVE-LOCK WHERE
                rowid(int-ds-docto-xml) = tt-int-ds-doc.r-rowid NO-ERROR.
           IF AVAIL int-ds-docto-xml THEN DO:
              
              ASSIGN tt-int-ds-doc.situacao    = 3    /* Atualizado  */
                     int-ds-docto-xml.sit-re   = 4.  /* Pendente Integra‡Æo Fiscal */

              RUN pi-atualiza-docto-xml.

           END.
        END.
    END.

END.

FOR EACH tt-erro-nota
    BREAK BY tt-erro-nota.cod-emitente 
          BY tt-erro-nota.nro-docto
          BY tt-erro-nota.tipo-erro:

     FIND FIRST tt-int-ds-doc WHERE
               tt-int-ds-doc.nro-docto      = tt-erro-nota.nro-docto AND
               tt-int-ds-doc.serie          = tt-erro-nota.serie     AND
               tt-int-ds-doc.cod-emitente   = tt-erro-nota.cod-emitente AND
               tt-int-ds-doc.nat-operacao   = tt-erro-nota.nat-operacao AND
               tt-int-ds-doc.tipo-nota      = tt-erro-nota.tipo-nota  NO-ERROR.
    IF AVAIL tt-int-ds-doc 
    THEN DO:
        IF tt-erro-nota.cod-erro = 4070  /* Nota fiscal atualizada com exito */
        THEN DO: 
            FIND FIRST int-ds-docto-xml EXCLUSIVE-LOCK WHERE
                 rowid(int-ds-docto-xml) = tt-int-ds-doc.r-rowid NO-ERROR.
            IF AVAIL int-ds-docto-xml THEN DO:

            
              ASSIGN tt-int-ds-doc.situacao    = 3
                     int-ds-docto-xml.sit-re   = 4. /* Pendente integracao fiscal */

              RUN pi-atualiza-docto-xml.

            END.
        END.
        ELSE DO:
           FIND FIRST int-ds-doc-erro NO-LOCK WHERE
                      int-ds-doc-erro.serie-docto  = tt-erro-nota.serie        AND 
                      int-ds-doc-erro.cod-emitente = tt-erro-nota.cod-emitente AND
                      int-ds-doc-erro.nro-docto    = tt-erro-nota.nro-docto    AND 
                      int-ds-doc-erro.tipo-nota    = tt-erro-nota.tipo-nota    AND
                      int-ds-doc-erro.nat-operacao = tt-erro-nota.nat-operacao AND 
                      int-ds-doc-erro.descricao    = tt-erro-nota.descricao NO-ERROR.
           IF NOT AVAIL int-ds-doc-erro THEN DO:
              CREATE int-ds-doc-erro.
              ASSIGN int-ds-doc-erro.serie-docto  = tt-erro-nota.serie
                     int-ds-doc-erro.cod-emitente = tt-erro-nota.cod-emitente 
                     int-ds-doc-erro.nro-docto    = tt-erro-nota.nro-docto    
                     int-ds-doc-erro.tipo-nota    = tt-erro-nota.tipo-nota    
                     int-ds-doc-erro.nat-operacao = tt-erro-nota.nat-operacao 
                     int-ds-doc-erro.cod-erro     = tt-erro-nota.cod-erro       
                     int-ds-doc-erro.descricao    = tt-erro-nota.descricao.

              FIND FIRST int-ds-docto-xml EXCLUSIVE-LOCK WHERE
                        rowid(int-ds-docto-xml) = tt-int-ds-doc.r-rowid NO-ERROR.
              IF AVAIL int-ds-docto-xml THEN DO:
                 IF tt-erro-nota.tipo-erro = "Erro" THEN 
                   ASSIGN int-ds-docto-xml.sit-re = 2. /* Erro integracao fisico */
                 ELSE DO:
                    ASSIGN tt-int-ds-doc.situacao    = 3
                           int-ds-docto-xml.sit-re   = 7. /* Implantado Fisico pendente integracao fiscal */  

                    FIND FIRST b-int-ds-doc-erro NO-LOCK WHERE
                               b-int-ds-doc-erro.serie-docto  = tt-erro-nota.serie        AND 
                               b-int-ds-doc-erro.cod-emitente = tt-erro-nota.cod-emitente AND
                               b-int-ds-doc-erro.nro-docto    = tt-erro-nota.nro-docto    AND 
                               b-int-ds-doc-erro.tipo-nota    = tt-erro-nota.tipo-nota    AND  
                               b-int-ds-doc-erro.nat-operacao = tt-erro-nota.nat-operacao AND
                               b-int-ds-doc-erro.tipo-erro   <> tt-erro-nota.tipo-erro NO-ERROR.
                    IF NOT AVAIL b-int-ds-doc-erro THEN
                      ASSIGN int-ds-docto-xml.situacao = 2   /* Liberado */
                             int-ds-docto-xml.sit-re   = 2.  /* Erro integracao Fisico */
                    ELSE DO:
                        RUN pi-atualiza-docto-xml.
                    END.
                                 
                 END.
              END.

           END.

        END.

        RELEASE int-ds-docto-xml.
    END.
END.

PROCEDURE pi-atualiza-docto-xml:
    
    FOR EACH int-ds-it-docto-xml EXCLUSIVE-LOCK WHERE 
             int-ds-it-docto-xml.serie         =  int-ds-docto-xml.serie         AND
             int-ds-it-docto-xml.nNF           =  int-ds-docto-xml.nNF           AND
             int-ds-it-docto-xml.cod-emitente  =  int-ds-docto-xml.cod-emitente  AND
             int-ds-it-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota     AND
             int-ds-it-docto-xml.situacao      =  2 /* Liberado */               AND  
             int-ds-it-docto-xml.tipo-contr    =  1 /* Fisico   */ :                              
        
        ASSIGN int-ds-it-docto-xml.situacao = tt-int-ds-doc.situacao. 

    END.

  
    FOR EACH tt-int-ds-it-doc NO-LOCK WHERE
             tt-int-ds-it-doc.tipo-nota    = int-ds-doc.tipo-nota    AND 
             tt-int-ds-it-doc.nro-docto    = int-ds-doc.nro-docto    AND
             tt-int-ds-it-doc.cod-emitente = int-ds-doc.cod-emitente AND
             tt-int-ds-it-doc.serie-docto  = int-ds-doc.serie-docto  :
            
         for first int-ds-it-doc exclusive-lock where  
             int-ds-it-doc.cod-emitente = tt-int-ds-it-doc.cod-emitente and
             int-ds-it-doc.serie-docto  = tt-int-ds-it-doc.serie-docto  and
             int-ds-it-doc.nro-docto    = tt-int-ds-it-doc.nro-docto    and
             int-ds-it-doc.nat-operacao = tt-int-ds-it-doc.nat-operacao and
             int-ds-it-doc.tipo-nota    = tt-int-ds-it-doc.tipo-nota    and
             int-ds-it-doc.sequencia    = tt-int-ds-it-doc.sequencia:   end.
         if not avail int-ds-it-doc then do:
             CREATE  int-ds-it-doc.
             assign  int-ds-it-doc.cod-emitente = tt-int-ds-it-doc.cod-emitente 
                     int-ds-it-doc.serie-docto  = tt-int-ds-it-doc.serie-docto  
                     int-ds-it-doc.nro-docto    = tt-int-ds-it-doc.nro-docto    
                     int-ds-it-doc.nat-operacao = tt-int-ds-it-doc.nat-operacao 
                     int-ds-it-doc.tipo-nota    = tt-int-ds-it-doc.tipo-nota
                     int-ds-it-doc.sequencia    = tt-int-ds-it-doc.sequencia.   
         end.
         BUFFER-COPY tt-int-ds-it-doc TO int-ds-it-doc.
        
    END.
    for first int-ds-doc exclusive where 
        int-ds-doc.cod-emitente = tt-int-ds-doc.cod-emitente  and
        int-ds-doc.nro-docto    = tt-int-ds-doc.nro-docto     and
        int-ds-doc.serie-docto  = tt-int-ds-doc.serie-docto   and
        int-ds-doc.nat-operacao = tt-int-ds-doc.nat-operacao: end.
    if not avail int-ds-doc then do:
        CREATE  int-ds-doc.
        assign  int-ds-doc.cod-emitente = tt-int-ds-doc.cod-emitente
                int-ds-doc.nro-docto    = tt-int-ds-doc.nro-docto   
                int-ds-doc.serie-docto  = tt-int-ds-doc.serie-docto 
                int-ds-doc.nat-operacao = tt-int-ds-doc.nat-operacao.
    end.
    BUFFER-COPY tt-int-ds-doc TO int-ds-doc.

    IF NOT CAN-FIND(FIRST int-ds-it-docto-xml NO-LOCK WHERE 
                          int-ds-it-docto-xml.serie         =  int-ds-docto-xml.serie         AND
                          int-ds-it-docto-xml.nNF           =  int-ds-docto-xml.nNF           AND
                          int-ds-it-docto-xml.cod-emitente  =  int-ds-docto-xml.cod-emitente  AND
                          int-ds-it-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota     AND
                          int-ds-it-docto-xml.situacao      =  2 /* Liberado */)   
    THEN DO:
        ASSIGN int-ds-docto-xml.situacao = tt-int-ds-doc.situacao.
    END.

END PROCEDURE.

