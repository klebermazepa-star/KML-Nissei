/******************************************************************************
**
**       PROGRAMA: int008a
**
**       DATA....: 05/2016
**
**       OBJETIVO: Gera Nota XML na integra‡Æo do pedido de compra
**                 
**       VERSAO..: 2.06.001
** 
******************************************************************************/

def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

def temp-table tt-raw-digita
    field raw-digita as raw.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD dt-trans-ini     AS DATE FORMAT "99/99/9999" 
    FIELD dt-trans-fin     AS DATE FORMAT "99/99/9999" 
    FIELD i-nro-docto-ini  LIKE docum-est.nro-docto
    FIELD i-nro-docto-fin  LIKE docum-est.nro-docto
    FIELD i-cod-emit-ini   LIKE docum-est.cod-emitente
    FIELD i-cod-emit-fin   LIKE docum-est.cod-emitente.

DEFINE TEMP-TABLE tt-digita
    FIELD arquivo AS CHAR
    FIELD raiz    AS CHAR 
    FIELD node    AS CHAR
    FIELD campo   AS CHAR FORMAT "X(100)"
    FIELD valor   AS CHAR FORMAT "X(100)"
    FIELD linha   AS INTEGER.

{intprg/int002b.i}

DEF INPUT PARAMETER p-num-pedido   LIKE pedido-compr.num-pedido.
DEF INPUT PARAMETER p-num-ped-orig LIKE int-ds-ped-compra.num-pedido-orig.

DEF VAR i-seq-item LIKE int-ds-it-docto-xml.sequencia NO-UNDO.  
DEF VAR d-vl-nf    LIKE int-ds-docto-xml.vNF          NO-UNDO.
DEF VAR raw-param  AS RAW.

EMPTY TEMP-TABLE tt-docto-xml.
EMPTY TEMP-TABLE tt-it-docto-xml.

FOR FIRST pedido-compr NO-LOCK WHERE
          pedido-compr.num-pedido =  p-num-pedido ,
    FIRST emitente NO-LOCK WHERE
          emitente.cod-emitente = pedido-compr.cod-emitente: 
   
   /*** Items da Nota fiscal ***/

   ASSIGN i-seq-item = 0
          d-vl-nf    = 0.

   FOR EACH ordem-compra NO-LOCK WHERE
            ordem-compra.num-pedido = pedido-compr.num-pedido:

       ASSIGN i-seq-item = i-seq-item + 10.

       FIND FIRST ITEM NO-LOCK WHERE
                  ITEM.it-codigo = ordem-compra.it-codigo NO-ERROR.
       
       CREATE int-ds-it-docto-xml.
       ASSIGN int-ds-it-docto-xml.arquivo      = ""        
              int-ds-it-docto-xml.CNPJ         = emitente.cgc
              int-ds-it-docto-xml.cod-emitente = emitente.cod-emitente
              int-ds-it-docto-xml.nNF          = STRING(pedido-compr.num-pedido,"9999999") 
              int-ds-it-docto-xml.serie        = "1"
              int-ds-it-docto-xml.tipo-nota    = 1 /* Compra */
              int-ds-it-docto-xml.sequencia    = i-seq-item
              int-ds-it-docto-xml.it-codigo    = ordem-compra.it-codigo
              int-ds-it-docto-xml.num-pedido   = pedido-compr.num-pedido
              int-ds-it-docto-xml.numero-ordem = ordem-compra.numero-ordem
              int-ds-it-docto-xml.qCom         = ordem-compra.qt-solic
              int-ds-it-docto-xml.qOrdem       = ordem-compra.qt-solic
              int-ds-it-docto-xml.situacao     = 2
              int-ds-it-docto-xml.uCom         = IF AVAIL ITEM THEN ITEM.un ELSE ""
              int-ds-it-docto-xml.vDesc        = 0
              int-ds-it-docto-xml.vProd        = ordem-compra.preco-unit * ordem-compra.qt-solic
              int-ds-it-docto-xml.vUnCom       = ordem-compra.preco-unit
              int-ds-it-docto-xml.xProd        = IF AVAIL ITEM THEN ITEM.desc-item ELSE "" 
              int-ds-it-docto-xml.narrativa    = ""
              int-ds-it-docto-xml.cfop         = 0
              int-ds-it-docto-xml.nat-operacao = ""
              d-vl-nf                          = d-vl-nf + int-ds-it-docto-xml.vProd.       

       find item-fornec where 
            item-fornec.it-codigo    = ordem-compra.it-codigo and
            item-fornec.cod-emitente = ordem-compra.cod-emitente no-lock no-error.
       IF AVAIL item-fornec 
       THEN DO:
          ASSIGN int-ds-it-docto-xml.item-do-forn = item-fornec.item-do-forn.
       END.

       CREATE tt-it-docto-xml.
       BUFFER-COPY int-ds-it-docto-xml TO tt-it-docto-xml.
       ASSIGN tt-it-docto-xml.r-rowid = ROWID(int-ds-it-docto-xml).
              
   END.
   
   /**** Cabecalho *****/

   CREATE int-ds-docto-xml.
   ASSIGN int-ds-docto-xml.arquivo      = ""
          int-ds-docto-xml.CNPJ         = emitente.cgc
          int-ds-docto-xml.cod-emitente = pedido-compr.cod-emitente
          int-ds-docto-xml.nNF          = STRING(pedido-compr.num-pedido,"9999999")
          int-ds-docto-xml.serie        = "1"
          int-ds-docto-xml.tipo-nota    = 1 /* Compra */  
          int-ds-docto-xml.cod-estab    = pedido-compr.cod-estabel
          int-ds-docto-xml.cod-usuario  = c-seg-usuario
          int-ds-docto-xml.dEmi         = TODAY 
          int-ds-docto-xml.dt-trans     = TODAY
          int-ds-docto-xml.observacao   = "Importado automaticamente pelo pedido de compra."
          int-ds-docto-xml.sit-re       = 1  /* Pendente de integra‡Æo no fiscal */
          int-ds-docto-xml.situacao     = 2  /* Inicia como liberado */
          int-ds-docto-xml.tipo-docto   = 3 /* Gerado automaticamente pelo pedido */
          int-ds-docto-xml.tot-desconto = 0
          int-ds-docto-xml.valor-mercad = d-vl-nf 
          int-ds-docto-xml.vNF          = d-vl-nf  
          int-ds-docto-xml.xNome        = emitente.nome-emit. 
          /*int-ds-docto-xml.id_sequencial = NEXT-VALUE(seq-int-ds-docto-xml)*/ /* Prepara‡Æo para integra‡Æo com Procfit */
                                             
   FIND FIRST estabelec NO-LOCK WHERE 
              estabelec.cod-estabel = pedido-compr.cod-estabel AND 
              estabelec.cgc <> ""  NO-ERROR.
   IF AVAIL estabelec THEN DO:
                           
       find first param-estoq no-lock no-error.

       FIND first estab-mat  no-lock where 
                  estab-mat.cod-estabel = estabelec.cod-estabel and 
                  estab-mat.cod-estabel = param-estoq.estabel-pad NO-ERROR.
       IF AVAIL estab-mat THEN
          ASSIGN int-ds-docto-xml.tipo-estab = 1. /* Principal/CD */
       ELSE 
          ASSIGN int-ds-docto-xml.tipo-estab = 2. /* Frente de Loja */

       ASSIGN int-ds-docto-xml.CNPJ-dest = estabelec.cgc
              int-ds-docto-xml.ep-codigo = int(estabelec.ep-codigo).
   END. 

   CREATE tt-docto-xml.
   BUFFER-COPY int-ds-docto-xml TO tt-docto-xml.

END.

/*** Faz valida‡Æo dos campos */

FOR FIRST tt-docto-xml,
    FIRST tt-it-docto-xml WHERE
          tt-it-docto-xml.tipo-nota  = tt-docto-xml.tipo-nota AND
          tt-it-docto-xml.CNPJ       = tt-docto-xml.CNPJ      AND
          tt-it-docto-xml.nNF        = tt-docto-xml.nNF       AND
          tt-it-docto-xml.serie      = tt-docto-xml.serie:
     
    for each tt-raw-digita:
        delete tt-raw-digita.
    end.
    
    CREATE tt-param.
    ASSIGN tt-param.destino         = 2                              
           tt-param.arquivo         = SESSION:TEMP-DIRECTORY + "\" + "int008a.txt"       
           tt-param.usuario         = c-seg-usuario       
           tt-param.data-exec       = TODAY  
           tt-param.hora-exec       = TIME      
           tt-param.dt-trans-ini    = tt-docto-xml.DEmi 
           tt-param.dt-trans-fin    = tt-docto-xml.DEmi
           tt-param.i-nro-docto-ini = tt-docto-xml.nNF 
           tt-param.i-nro-docto-fin = tt-docto-xml.nNF
           tt-param.i-cod-emit-ini  = tt-docto-xml.cod-emitente
           tt-param.i-cod-emit-fin  = tt-docto-xml.cod-emitente. 
       
    create tt-digita.
    assign tt-digita.campo = "Reenvio"
           tt-digita.valor = string(tt-it-docto-xml.r-rowid).
    raw-transfer tt-param  to raw-param.
        
    for each tt-digita:
        create tt-raw-digita.
         raw-transfer tt-digita to tt-raw-digita.raw-digita.
    end.
            
    run intprg/int002brp.p (input raw-param, 
                            input table tt-raw-digita).

END.
