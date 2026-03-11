/********************************************************************************
**
**  Programa ........: intprg/int002g.p
**  Data ............: Abril/2016
**  Objetivo ........: Integraá∆o com o PRS
*****************************************************************************************************/

{intprg/int002b.i}

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
FIELD dt-trans-ini     LIKE docum-est.dt-trans
FIELD dt-trans-fin     LIKE docum-est.dt-trans
FIELD i-nro-docto-ini  LIKE docum-est.nro-docto
FIELD i-nro-docto-fin  LIKE docum-est.nro-docto
FIELD i-cod-emit-ini   LIKE docum-est.cod-emitente
FIELD i-cod-emit-fin   LIKE docum-est.cod-emitente.


DEF INPUT  PARAMETER TABLE FOR tt-param.
DEF INPUT  PARAMETER TABLE FOR tt-docto-xml.
DEF INPUT  PARAMETER TABLE FOR tt-it-docto-xml.
def input  parameter table for TT-XML-DUP.
DEF OUTPUT PARAMETER p-log-ok AS LOG NO-UNDO.
                     
DEF VAR de-tot-quantidade         LIKE int-ds-it-docto-xml.qCom.
DEF VAR de-tot-base-ipi           LIKE int-ds-it-docto-xml.vbc-ipi.
DEF VAR de-tot-vlr-ipi            LIKE int-ds-it-docto-xml.vipi. 
DEF VAR de-tot-base-icms-isento   LIKE int-ds-it-docto-xml.vbc-icms.
DEF VAR de-tot-base-icms-diferido LIKE int-ds-it-docto-xml.vbc-icms.
def var de-tot-valor-produtos     like int-ds-nota-entrada.nen-valortotalprodutos-n.
DEF VAR de-vl-liquido             LIKE it-nota-fisc.vl-merc-liq.
DEF VAR i-cfop                    LIKE tt-it-docto-xml.cfop.
DEF VAR i-num-pedido              LIKE tt-it-docto-xml.num-pedido. 
DEF VAR c-item-do-forn            AS CHAR.
DEF VAR c-it-codigo               AS CHAR.
DEF VAR i-pos                     AS INTEGER.
DEF VAR c-num-pedido              AS CHAR.
def var l-sem-item                as logical no-undo.
def var l-vendavel                as logical no-undo.
find first tt-param no-error.      
/* tratar notas de entrada nas lojas */
FOR EACH tt-docto-xml WHERE
         tt-docto-xml.dEmi         >= tt-param.dt-trans-ini    AND 
         tt-docto-xml.dEmi         <= tt-param.dt-trans-fin    AND 
         tt-docto-xml.NNF          >= tt-param.i-nro-docto-ini AND 
         tt-docto-xml.NNF          <= tt-param.i-nro-docto-fin AND
         tt-docto-xml.cod-emitente >= tt-param.i-cod-emit-ini  AND 
         tt-docto-xml.cod-emitente <= tt-param.i-cod-emit-fin  AND 
         tt-docto-xml.tipo-estab    = 2 /* Loja */             and
         tt-docto-xml.tipo-docto   <> 5 /* balanco - vai pelo int011 */
        
    BREAK BY tt-docto-xml.arquivo :  
                
    ASSIGN de-tot-quantidade = 0
           de-tot-base-ipi   = 0
           de-tot-vlr-ipi    = 0
           de-tot-base-icms-isento   = 0
           de-tot-base-icms-diferido = 0
           i-num-pedido              = 0
           p-log-ok                  = NO.
                            
    for first int-ds-nota-entrada where 
        int-ds-nota-entrada.nen-cnpj-origem-s = tt-docto-xml.CNPJ      and
        int-ds-nota-entrada.nen-serie-s       = tt-docto-xml.serie     and  
        int-ds-nota-entrada.nen-notafiscal-n  = int(tt-docto-xml.nnf): end.
    if avail int-ds-nota-entrada then next.            
    
    /*
    IF tt-docto-xml.tipo-docto = 5    /* Notas de Balanáo Atualiza o Estoque autom†tico */
    THEN*/ DO:
       ASSIGN i-num-pedido = int(tt-docto-xml.num-pedido) NO-ERROR.
    END.

    /* notas j† integradas e processadas n∆o ser∆o alteradas 
    for first int-ds-nota-entrada where 
        int-ds-nota-entrada.nen-cnpj-origem-s = tt-docto-xml.CNPJ      and
        int-ds-nota-entrada.nen-serie-s       = tt-docto-xml.serie     and  
        int-ds-nota-entrada.nen-notafiscal-n  = int(tt-docto-xml.nnf)  and
        int-ds-nota-entrada.nen-datamovimentacao-d <> ?:               end.
    if avail int-ds-nota-entrada then next.            
    
    for first int-ds-nota-entrada where 
        int-ds-nota-entrada.nen-cnpj-origem-s = tt-docto-xml.CNPJ      and
        int-ds-nota-entrada.nen-serie-s       = tt-docto-xml.serie     and  
        int-ds-nota-entrada.nen-notafiscal-n  = int(tt-docto-xml.nnf): 
        assign int-ds-nota-entrada.situacao = 0. /* evitanto processamento paralelo pelo PRS */
        for each int-ds-nota-entrada-produto of int-ds-nota-entrada:
            delete int-ds-nota-entrada-produto.
        end.
    end.
    */
    i-cfop = 0.
    de-tot-valor-produtos = 0.
    for each tt-it-docto-xml where 
             tt-it-docto-xml.tipo-nota  = tt-docto-xml.tipo-nota AND
             tt-it-docto-xml.CNPJ       = tt-docto-xml.CNPJ      AND
             tt-it-docto-xml.nNF        = tt-docto-xml.nNF       AND
             tt-it-docto-xml.serie      = tt-docto-xml.serie     and
             tt-it-docto-xml.arquivo    = tt-docto-xml.arquivo
        break by tt-it-docto-xml.CNPJ       
              by tt-it-docto-xml.serie         
              by tt-it-docto-xml.nNF
              by tt-it-docto-xml.item-do-forn:

        assign l-vendavel = no
               l-sem-item = no.
        assign de-tot-quantidade = de-tot-quantidade + tt-it-docto-xml.qCom
               de-tot-base-ipi   = de-tot-base-ipi   + tt-it-docto-xml.vbc-ipi
               de-tot-vlr-ipi    = de-tot-vlr-ipi    + tt-it-docto-xml.vipi
               i-cfop            = tt-it-docto-xml.cfop.

        assign c-item-do-forn = trim(tt-it-docto-xml.item-do-forn).
        for first item-fornec fields (it-codigo)
            no-lock where
            item-fornec.cod-emitente = tt-docto-xml.cod-emitente and
            item-fornec.item-do-forn = c-item-do-forn and
            item-fornec.ativo = yes: end.

        if not avail item-fornec then do:
            assign c-item-do-forn = string(int(tt-it-docto-xml.item-do-forn)) no-error.
            if error-status:error then 
               assign c-item-do-forn = string(tt-it-docto-xml.item-do-forn).
            for first item-fornec fields (it-codigo)
                no-lock where
                item-fornec.cod-emitente = tt-docto-xml.cod-emitente and
                item-fornec.item-do-forn = c-item-do-forn and
                item-fornec.ativo = yes: end.
        end.
            
        if avail item-fornec then
           assign c-it-codigo = item-fornec.it-codigo.
        ELSE DO:
             IF tt-it-docto-xml.it-codigo <> "" THEN
                assign c-it-codigo = tt-it-docto-xml.it-codigo.
             /*
             ELSE 
                ASSIGN c-it-codigo = tt-it-docto-xml.item-do-forn.
                */
        END.

        if tt-it-docto-xml.lote = ? then tt-it-docto-xml.lote = "".
        for first int-ds-nota-entrada-produto where 
                  int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                  int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                  int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                  int-ds-nota-entrada-produto.nep-sequencia-n   = tt-it-docto-xml.sequencia      and 
                  int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and
                  int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and
                  int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:          end.

        IF i-num-pedido = 0 AND tt-it-docto-xml.num-pedido <> 0 THEN
             ASSIGN i-num-pedido = tt-it-docto-xml.num-pedido.

        if not avail int-ds-nota-entrada-produto 
        then do:

            create int-ds-nota-entrada-produto.
            assign int-ds-nota-entrada-produto.nen-cnpj-origem-s       = tt-it-docto-xml.CNPJ          
                   int-ds-nota-entrada-produto.nen-serie-s             = tt-docto-xml.serie            
                   int-ds-nota-entrada-produto.nen-notafiscal-n        = int(tt-it-docto-xml.nNF)      
                   int-ds-nota-entrada-produto.nen-cfop-n              = tt-it-docto-xml.cfop          
                   int-ds-nota-entrada-produto.nep-sequencia-n         = tt-it-docto-xml.sequencia     
                   int-ds-nota-entrada-produto.nep-produto-n           = int(c-it-codigo) 
                   int-ds-nota-entrada-produto.nep-lote-s              = tt-it-docto-xml.lote
                   int-ds-nota-entrada-produto.nep-quantidade-n        = tt-it-docto-xml.qcom 
                   int-ds-nota-entrada-produto.nep-redutorbaseicms-n   = tt-it-docto-xml.predBc
                   int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn
                   int-ds-nota-entrada-produto.ped-codigo-n            = /*IF tt-docto-xml.tipo-docto = 5 then */ i-num-pedido.

            assign int-ds-nota-entrada-produto.nep-ncm-n               = tt-it-docto-xml.ncm.
            assign int-ds-nota-entrada-produto.npx-descricaoproduto-s  = tt-it-docto-xml.xProd
                   int-ds-nota-entrada-produto.npx-ean-n               = tt-it-docto-xml.dEan.
            
            assign int-ds-nota-entrada-produto.nep-percentualicms-n   = tt-it-docto-xml.picms
                   int-ds-nota-entrada-produto.nep-percentualipi-n    = tt-it-docto-xml.pipi      
                   int-ds-nota-entrada-produto.nep-percentualpis-n    = tt-it-docto-xml.ppis 
                   int-ds-nota-entrada-produto.nep-percentualcofins-n = tt-it-docto-xml.pcofins 
                   int-ds-nota-entrada-produto.nep-datavalidade-d     = tt-it-docto-xml.dval
                   int-ds-nota-entrada-produto.nep-csta-n             = tt-it-docto-xml.orig-icms  /* nacional 0 importado 1 */ 
                   int-ds-nota-entrada-produto.nep-cstb-icm-n         = /*tt-it-docto-xml.vbcst*/ tt-it-docto-xml.cst-icm
                   int-ds-nota-entrada-produto.nep-cstb-ipi-n         = /*tt-it-docto-xml.vbc-ipi*/ tt-it-docto-xml.cst-ipi.

            DISPLAY " 002 "
                    int-ds-nota-entrada-produto.nep-produto-n
                    int-ds-nota-entrada-produto.nep-percentualicms-n.
        end. 
        if c-it-codigo <> "" then do:
            for first item no-lock where item.it-codigo = c-it-codigo: end.
            if avail item and item.ge-codigo <= 80 then do:
                assign l-vendavel = yes.
            end.
            else do:
                assign l-sem-item = yes.
            end.
        end.
        else do:
            assign l-sem-item = yes.
        end.

        if tt-it-docto-xml.cst-icms = 40 then
           assign de-tot-base-icms-isento = de-tot-base-icms-isento + tt-it-docto-xml.vbc-icms
                  int-ds-nota-entrada-produto.nep-baseisenta-n = /*int-ds-nota-entrada-produto.nep-baseisenta-n +*/ tt-it-docto-xml.vbc-icms.

        if tt-it-docto-xml.cst-icms = 51 then 
           assign de-tot-base-icms-diferido = de-tot-base-icms-diferido + tt-it-docto-xml.vbc-icms
                  int-ds-nota-entrada-produto.nep-basediferido-n = /*int-ds-nota-entrada-produto.nep-basediferido-n +*/ tt-it-docto-xml.vbc-icms.
        if tt-docto-xml.tipo-nota = 3 then 
           assign de-vl-liquido   = tt-it-docto-xml.vtottrib.
        else
           assign de-vl-liquido   = tt-it-docto-xml.vprod - tt-it-docto-xml.vDesc.  
        assign int-ds-nota-entrada-produto.nep-valorliquido-n     = /*int-ds-nota-entrada-produto.nep-valorliquido-n    +   */  de-vl-liquido.
        
        assign int-ds-nota-entrada-produto.nep-valorbruto-n       = /* int-ds-nota-entrada-produto.nep-valorbruto-n      +  */ tt-it-docto-xml.vProd
               int-ds-nota-entrada-produto.nep-valordesconto-n    = /* int-ds-nota-entrada-produto.nep-valordesconto-n   +  */ tt-it-docto-xml.vDesc
               int-ds-nota-entrada-produto.nep-baseicms-n         = /* int-ds-nota-entrada-produto.nep-baseicms-n        +  */ tt-it-docto-xml.vbc-icms
               int-ds-nota-entrada-produto.nep-valoricms-n        = /* int-ds-nota-entrada-produto.nep-valoricms-n       +  */ tt-it-docto-xml.vicms
               int-ds-nota-entrada-produto.nep-baseipi-n          = /* int-ds-nota-entrada-produto.nep-baseipi-n         +  */ tt-it-docto-xml.vbc-ipi
               int-ds-nota-entrada-produto.nep-valoripi-n         = /* int-ds-nota-entrada-produto.nep-valoripi-n        +  */ tt-it-docto-xml.vipi
               int-ds-nota-entrada-produto.nep-icmsst-n           = /* int-ds-nota-entrada-produto.nep-icmsst-n          +  */ tt-it-docto-xml.vicmsst
               int-ds-nota-entrada-produto.nep-basest-n           = /* int-ds-nota-entrada-produto.nep-basest-n          +  */ tt-it-docto-xml.vbcst
               int-ds-nota-entrada-produto.nep-valordespesa-n     = /* int-ds-nota-entrada-produto.nep-valordespesa-n    +  */ tt-it-docto-xml.vOutro
               int-ds-nota-entrada-produto.nep-basepis-n          = /* int-ds-nota-entrada-produto.nep-basepis-n         +  */ tt-it-docto-xml.vbc-pis
               int-ds-nota-entrada-produto.nep-valorpis-n         = /* int-ds-nota-entrada-produto.nep-valorpis-n        +  */ tt-it-docto-xml.vpis
               int-ds-nota-entrada-produto.nep-basecofins-n       = /* int-ds-nota-entrada-produto.nep-basecofins-n      +  */ tt-it-docto-xml.vbc-cofins
               int-ds-nota-entrada-produto.nep-valorcofins-n      = /* int-ds-nota-entrada-produto.nep-valorcofins-n     +  */ tt-it-docto-xml.vcofins
               int-ds-nota-entrada-produto.nep-valor-icms-des-n   = /* int-ds-nota-entrada-produto.nep-valor-icms-des-n  +  */ tt-it-docto-xml.vicmsdeson.

        assign i-cfop = tt-it-docto-xml.cfop.
        assign de-tot-valor-produtos = de-tot-valor-produtos + int-ds-nota-entrada-produto.nep-valorbruto-n.
        release int-ds-nota-entrada-produto.

    end. /* tt-it-docto-xml */

    /* duplicatas da nota se for de compra */
    def var dt-valida as date no-undo.
    def var l-valida as logical no-undo.
    l-valida = yes.
    for each tt-xml-dup:
        dt-valida = date(int(substring(tt-xml-dup.dVenc,6,2)),
                         int(substring(tt-xml-dup.dVenc,9,2)),
                         int(substring(tt-xml-dup.dVenc,1,4))) no-error.
        if error-status:error then l-valida = no.
    end.
    if l-valida then
    for each tt-xml-dup:
        for first int-ds-nota-entrada-dup where 
            int-ds-nota-entrada-dup.nen-cnpj-origem-s = tt-docto-xml.CNPJ       and
            int-ds-nota-entrada-dup.nen-serie-s       = tt-docto-xml.serie      and
            int-ds-nota-entrada-dup.nen-notafiscal-n  = int(tt-docto-xml.nnf)   and
            int-ds-nota-entrada-dup.nen-data-vencto-d = date(int(substring(tt-xml-dup.dVenc,6,2)),
                                                             int(substring(tt-xml-dup.dVenc,9,2)),
                                                             int(substring(tt-xml-dup.dVenc,1,4))): end.
        if not avail int-ds-nota-entrada-dup then do:
            create  int-ds-nota-entrada-dup.
            assign  int-ds-nota-entrada-dup.nen-cnpj-origem-s = tt-docto-xml.CNPJ    
                    int-ds-nota-entrada-dup.nen-serie-s       = tt-docto-xml.serie   
                    int-ds-nota-entrada-dup.nen-notafiscal-n  = int(tt-docto-xml.nnf)
                    int-ds-nota-entrada-dup.nen-cfop-n        = i-cfop               
                    int-ds-nota-entrada-dup.nen-data-vencto-d = date(int(substring(tt-xml-dup.dVenc,6,2)),
                                                                     int(substring(tt-xml-dup.dVenc,9,2)),
                                                                     int(substring(tt-xml-dup.dVenc,1,4))).
        end.
        assign  int-ds-nota-entrada-dup.nen-duplicata-s = trim(tt-xml-dup.nDup)
                int-ds-nota-entrada-dup.nen-valor-duplicata-n = tt-xml-dup.vDup.
            
    end.


    for first int-ds-nota-entrada where 
        int-ds-nota-entrada.nen-cnpj-origem-s = tt-docto-xml.CNPJ      and
        int-ds-nota-entrada.nen-serie-s       = tt-docto-xml.serie     and  
        int-ds-nota-entrada.nen-notafiscal-n  = int(tt-docto-xml.nnf): end.

    if not avail int-ds-nota-entrada 
    then do:

       create int-ds-nota-entrada.
       assign int-ds-nota-entrada.nen-cnpj-origem-s  =  tt-docto-xml.CNPJ          /* CNPJ fornecedor/estabelecimento origem */
              int-ds-nota-entrada.nen-serie-s        =  tt-docto-xml.serie         /*  Serie da nota fiscal */    
              int-ds-nota-entrada.nen-notafiscal-n   =  int(tt-docto-xml.nnf)      /*  Numero da nota fiscal  */
              int-ds-nota-entrada.nen-cfop-n         =  i-cfop                     /*  CFOP da nota fiscal Ç por item */
              int-ds-nota-entrada.tipo-movto         =  1.                         /* 1 - Inclus∆o 2 - Alteraá∆o 3 - Exclus∆o */ 

    end.
    else assign int-ds-nota-entrada.tipo-movto = 2.

    assign int-ds-nota-entrada.dt-geracao               =  today
           int-ds-nota-entrada.hr-geracao               =  string(time,"HH:MM:SS").
                                                           /* nao vendaveis n∆o passam por conferencia */
    assign int-ds-nota-entrada.situacao                 =  if not l-vendavel and not l-sem-item then 2 else 1 /* 1 - Pendente 2 - Integrado */     
           int-ds-nota-entrada.nen-conferida-n          =  if not l-vendavel and not l-sem-item then 1 else 0 /* 1 - Conferida, 0 - A conferir */
           int-ds-nota-entrada.nen-datamovimentacao-d   =  if not l-vendavel and not l-sem-item then tt-docto-xml.demi else ?
           int-ds-nota-entrada.nen-cnpj-destino-s       =  tt-docto-xml.cnpj-dest      /* CNPJ estabelecimento de destino */
           int-ds-nota-entrada.nen-dataemissao-d        =  tt-docto-xml.demi           /*  Data emissao da nota fiscal */   
           int-ds-nota-entrada.nen-quantidade-n         =  de-tot-quantidade            /*  Quantidde total da nota fiscal */
           int-ds-nota-entrada.nen-desconto-n           =  tt-docto-xml.tot-desconto   /*  Desconto total da nota fiscal  */
           int-ds-nota-entrada.nen-baseicms-n           =  tt-docto-xml.vbc            /*  Base ICMS total nota fiscal    */
           int-ds-nota-entrada.nen-valoricms-n          =  tt-docto-xml.valor-icms     /*  Valor total do ICMS da nota fiscal    */  
           int-ds-nota-entrada.nen-basediferido-n       =  de-tot-base-icms-diferido    /*  Base de icms diferido da nota fiscal  */
           int-ds-nota-entrada.nen-baseisenta-n         =  de-tot-base-icms-isento      /*  Base total ICMS isento da nota fiscal */
           int-ds-nota-entrada.nen-baseipi-n            =  de-tot-base-ipi              /*  Base IPI  */
           int-ds-nota-entrada.nen-valoripi-n           =  de-tot-vlr-ipi               /*  Valor total do IPI da nota fiscal */
           int-ds-nota-entrada.nen-basest-n             =  tt-docto-xml.vbc-cst        /*  Base ICMS ST */
           int-ds-nota-entrada.nen-icmsst-n             =  tt-docto-xml.valor-st       /*  Valor do ICMS ST total da nota */
           int-ds-nota-entrada.nen-chaveacesso-s        =  tt-docto-xml.chnfe          /* Chave de acesso NFe */ 
           int-ds-nota-entrada.nen-frete-n              =  tt-docto-xml.valor-frete    /* Frete total da nota */
           int-ds-nota-entrada.nen-seguro-n             =  tt-docto-xml.valor-seguro   /* Seguro total da nota  */
           int-ds-nota-entrada.nen-despesas-n           =  tt-docto-xml.valor-outras   /* Despesas total da nota */
           int-ds-nota-entrada.ped-codigo-n             =  i-num-pedido                 /* Num pedido dos itens */
           int-ds-nota-entrada.tipo-nota                =  tt-docto-xml.tipo-nota
           int-ds-nota-entrada.nen-observacao-s         =  tt-docto-xml.observacao  + chr(13) + "NDDID: " + trim(STRING(tt-docto-xml.arquivo))   /* Observacao da nota fiscal */
           int-ds-nota-entrada.nen-modalidade-frete-n   =  tt-docto-xml.modFrete    /* Modalidade do frete (0-FOB 1-CIF) */
           int-ds-nota-entrada.nen-valortotalprodutos-n =  /*tt-docto-xml.valor-mercad  /*  Valor total da mercadoria */.*/ de-tot-valor-produtos /* armazenando para comparar depois com o total terornado pelo Sisfarma. */.
   
    /* notas do estabelecimento 500 n∆o passam por conferencia */
    for first estabelec no-lock where estabelec.cgc = int-ds-nota-entrada.nen-cnpj-destino-s and
        estabelec.cod-estabel = "500":
        assign int-ds-nota-entrada.situacao                 =  2
               int-ds-nota-entrada.nen-conferida-n          =  1
               int-ds-nota-entrada.nen-datamovimentacao-d   =  tt-docto-xml.demi.
    end.
    /*
    IF int-ds-nota-entrada.tipo-movto = 1 AND 
       tt-docto-xml.tipo-docto = 5    /* Notas de Balanáo Atualiza o Estoque autom†tico */
    THEN DO:

       CREATE int-ds-docto-wms.
       ASSIGN int-ds-docto-wms.doc_numero_n   = INT(tt-docto-xml.nnf)
              int-ds-docto-wms.doc_serie_s    = tt-docto-xml.serie   
              int-ds-docto-wms.doc_origem_n   = tt-docto-xml.cod-emitente
              int-ds-docto-wms.situacao       = 1. /* Inclus∆o */
    
       FIND FIRST emitente WHERE
                  emitente.cod-emitente = tt-docto-xml.cod-emitente NO-LOCK NO-ERROR.
       IF AVAIL emitente THEN 
          ASSIGN int-ds-docto-wms.cnpj_cpf        = emitente.cgc 
                 int-ds-docto-wms.tipo_fornecedor = IF emitente.natureza = 1 THEN "F" ELSE "J".

    END.
    */

    release int-ds-nota-entrada.
    ASSIGN p-log-ok = YES.
    RETURN "OK".
end. /* TT-DOCTO-XML */

empty temp-table tt-xml-dup.
empty temp-table tt-docto-xml.
empty temp-table tt-it-docto-xml.



