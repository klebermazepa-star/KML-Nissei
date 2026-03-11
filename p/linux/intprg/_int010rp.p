/********************************************************************************
** Programa: int010 - Importa‡Æo de Pedidos CD->Lojas do Tutorial/Sysfarma
**
** Versao : 12 - 30/01/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de versao */
{include/i-prgvrs.i INT010RP 2.12.01.AVB}

/* definiçao das temp-tables para recebimento de parametros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def temp-table tt-raw-digita
        field raw-digita	as raw.

def temp-table tt-ped-venda-imp         like ped-venda.
def temp-table tt-ped-item-imp          like ped-item  
    field numero-caixa like cst-ped-item.numero-caixa
    field numero-lote  like cst-ped-item.numero-lote.

def temp-table tt-ped-repre-imp         like ped-repre.

&global-define log-erro     "ERRO"
&global-define log-erro-api "ERRO API"
&global-define log-adv      "ADVERT"
&global-define log-info     "INFO"

/* temp-tables das API's e BO's */
{method/dbotterr.i}
{dibo/bodi159.i tt-ped-venda}
{dibo/bodi154.i tt-ped-item}
{dibo/bodi157.i tt-ped-repre}

def var h-bodi159       as handle no-undo.
def var h-bodi159com    as handle no-undo.
def var h-bodi159sus    as handle no-undo.
def var h-bodi159sdf    as handle no-undo.
/* itens dos pedidos */
def var h-bodi154       as handle no-undo.
/* representantes do pedido */
def var h-bodi157       as handle no-undo.

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param no-error. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "INT010.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

/* include padrao para variáveis de relatório  */
{include/i-rpvar.i}

/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
def buffer b-natur-oper for natur-oper.

/* definiçao de variáveis  */
def var h-acomp             as handle no-undo.

def var c-nr-pedcli          like ped-venda.nr-pedcli.
def var c-desc-padrao        like ped-venda.perc-desco1.           
def var c-observacao         as char.
def var c-cond-redespacho    as char.
def var i-cod-emitente       like emitente.cod-emitente.
def var i-cod-rep            as integer.
def var c-nr-tabpre          as char.
def var i-cod-cond-pag       as integer.
def var c-nr-pedido          as char.
def var c-desc-condicao      as char.
def var c-tp-transp          as char.
def var c-cod-transp         as char.
def var c-it-codigo          as char.
def var de-quantidade        as decimal.
def var c-natur              like ped-venda.nat-operacao.
def var de-vl-uni            as dec format "999.999".
def var de-desconto          as decimal no-undo.
def var i-tab-finan          as integer.
def var i-indice             as integer.
def var c-nome-transp        like transporte.nome-abrev.
def var de-aliquota-ipi      as decimal.
def var de-vl-tot-ped        like ped-venda.vl-tot-ped.
def var de-vl-liq-abe        like ped-venda.vl-tot-ped.
def var de-vl-liq            like ped-venda.vl-tot-ped.
def var de-vl-desc-total     like ped-venda.val-desconto-total.
def var de-preco             like preco-item.preco-venda.
def var de-preco-liq         like ped-item.vl-preuni.
def var c-cod-refer          as char.
def var c-cod-entrega        as char.
def var c-cidade-cif         as char.
def var c-redespacho         as char.
def var i-canal-vendas       as integer.
def var c-cod-rota           as char.
def var i-nr-registro        as integer init 0.
def var c-informacao         as char format "x(220)".
def var i-erro               as integer init 0.
def var l-pedido-com-erro    as logical init no no-undo.
def var r-registro           as recid no-undo.
def var l-confirma           as logical no-undo format "Sim/Nao".
def var d-dt-emissao         as date.
def var d-dt-entrega         as date.
def var d-dt-implantacao     as date.
def var i-nr-sequencia       as integer.
def var c-nome-repres        as character.
def var c-placa              as character.
def var c-uf-placa           as character.
def var c-numero-caixa       as character.
def var c-numero-lote        as character.
def var tb-erro              as char format "x(50)" extent 38 init
                             ["01. Importado com Sucesso                         ",
                              "02. Cliente nao Cadastrado                        ",
                              "03. Tabela de preco nao Cadastrada                ",
                              "04. Tabela de preco fora do limite                ",
                              "05. Tabela de preco Inativa                       ",
                              "06. Data Emissao Invalida                         ",
                              "07. Data Entrega Invalida                         ",
                              "08. Data Implantacao Invalida                     ",
                              "09. Produto nao Cadastrado                        ",
                              "10. Produto esta obsoleto                         ",
                              "11. Produto nao disponivel para venda             ",
                              "12. Quantidade Invalida                           ",
                              "13. Representante nao Cadastrado                  ",
                              "14. Cliente nao eh do Representante               ",
                              "15. Condicao de Pagamento Nao Cadastrada          ",
                              "16. Transportador Nao Cadastrado                  ",
                              "17. Numero do Pedido Interno Invalido             ",
                              "18. Numero do Pedido Interno Ja Cadastrado        ",
                              "19. Pedido de Venda ja Cadastrado                 ",
                              "20.*** Pedido de Venda nao Importado ***          ",
                              "21. Natureza de Operacao nao Cadastrada em INT015 ",
                              "22. ERRO BO de Implantacao                        ",
                              "23. Transportador de redespachop NAO Cadastrado   ",
                              "24. Codigo do Cliente p/ Entrega NAO Existe       ",
                              "25. Quantidade de parcelas p/ pagto inconsistente ",
                              "26. Cliente so pode comprar A Vista               ",
                              "27. Cliente esta Suspenso                         ",
                              "28. Emitente NAO cadastrado como cliente/ambos    ",
                              "29.                                               ",
                              "30. Estabelecimento nao Cadastrado/Fora de Operacao",
                              "31. Canal de vendas nao Cadastrado                ",
                              "32. Nat.Operacao indicada esta Inativa            ",
                              "33. Qtdes lidas # qtdes enviadas - reprocessando  ",
                              "34. Item exige conta aplica‡Æo em CD0138          ",
                              "35. Tabela de Financiamento NAO Cadastrada        ",
                              "36. Item com classificacao fiscal em branco       ",
                              "37. Pedido inconsistente ou sem itens             ",
                              "38. Valor do item zerado                          "].

def var i-qt-volumes    as integer  format ">>>>9" init 0.
def var i-qt-caixas     as integer.
def var d-pes-liq-tot   as decimal format ">>,>>9.99" no-undo.
def var de-peso-itens   as dec  format ">>>,>>9.99" init 0. 
def var i-cont          as int init 0.
def var de-red-base-ipi as decimal no-undo.
def var de-base-ipi     as decimal no-undo.

def var c-cod-estabel as char initial "1" no-undo.
def var c-nome-abrev as char no-undo.
def var l-ind-icm-ret as logical no-undo.
def var c-uf-destino as char no-undo.
def var c-uf-origem as char no-undo.
def var r-rowid as rowid no-undo.
def var i-cod-portador  as integer no-undo.
def var i-modalidade    as integer no-undo.
def var c-serie         as char no-undo.
def var c-class-fiscal  as char no-undo.
def var c-ct-codigo     as char no-undo.
def var c-sc-codigo     as char no-undo.
def new global shared var c-seg-usuario   as char no-undo.

define buffer bemitente for emitente.
define buffer bestabelec for estabelec.
define buffer btransporte for transporte.

/* definiçao de frames do relatório */
form i-nr-registro    column-label "Sequencia"
     tb-erro[1]       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 300
     down stream-io frame f-erro.

/* include com a definiçao da frame de cabeçalho e rodapé */
{include/i-rpcab.i &stream="str-rp"}
/* bloco principal do programa */

{utp/utapi019.i}

find first tt-param no-lock no-error.
assign c-programa       = "INT010RP"
       c-versao         = "2.12"
       c-revisao        = ".01.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Pedidos"
       c-titulo-relat   = "Importacao de Pedidos - Sysfarma".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

opcao: 
do:
   run utp/ut-acomp.p persistent set h-acomp.
   run pi-inicializar in h-acomp (input "Processando").

   if tt-param.arquivo <> "" then do:
       {include/i-rpout.i &stream = "stream str-rp"}

       view stream str-rp frame f-cabec.
       view stream str-rp frame f-rodape.
   end.
   run elimina-tabelas.
   run importa.

   pause 3 no-message.
   /*
   run envia-e-mail.
   */
end.
/* ----- fim do programa -------- */
run elimina-tabelas.

if tt-param.arquivo <> "" then do:
    /* fechamento do output do relatorio  */
    {include/i-rpclo.i &stream="stream str-rp"}
end.
run pi-finalizar in h-acomp.

/* elimina BO's */
if valid-handle(h-bodi159) then
   delete procedure h-bodi159.

if valid-handle(h-bodi159sus) then
   delete procedure h-bodi159sus.

if valid-handle(h-bodi159sdf) then
   delete procedure h-bodi159sdf.

if valid-handle(h-bodi159com) then
   delete procedure h-bodi159com.

if valid-handle(h-bodi154) then
   delete procedure h-bodi154.

if valid-handle(h-bodi157) then
   delete procedure h-bodi157.

return "OK".

/* procedures */

procedure elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   empty temp-table tt-ped-venda-imp.
   empty temp-table tt-ped-repre-imp. 
   empty temp-table tt-ped-item-imp. 
   empty temp-table tt-ped-venda.
   empty temp-table tt-ped-repre. 
   empty temp-table tt-ped-item. 
   empty temp-table RowErrors.   
   empty temp-table tt-envio2.
   empty temp-table tt-mensagem.
end.        

procedure importa:
    run pi-acompanhar in h-acomp (input "Lendo Pedidos").
    
    assign i-nr-registro    = 0.
    
     FOR EACH bestabelec NO-LOCK                                                                            
/*          WHERE bestabelec.cod-estabel = "232"                                                                        */
/*          or bestabelec.cod-estabel = "276" or bestabelec.cod-estabel = "093" or                                      */
/*          bestabelec.cod-estabel = "190" or bestabelec.cod-estabel = "216" or bestabelec.cod-estabel = "036" or       */
/*          bestabelec.cod-estabel = "092" or bestabelec.cod-estabel = "088" or bestabelec.cod-estabel = "219" or       */
/*          bestabelec.cod-estabel = "133" or bestabelec.cod-estabel = "075" or bestabelec.cod-estabel = "186" or       */
/*          bestabelec.cod-estabel = "258"                                                                              */
/* /*          or bestabelec.cod-estabel = "246" or bestabelec.cod-estabel = "262" or                                */ */
/* /*          bestabelec.cod-estabel = "260" or bestabelec.cod-estabel = "261" or bestabelec.cod-estabel = "267" or */ */
/* /*          bestabelec.cod-estabel = "283" OR bestabelec.cod-estabel = "268"                                      */ */
         /*
         WHERE                                                                                              
         bestabelec.cod-estabel = "165" OR                                                                   
         bestabelec.cod-estabel = "185" OR                                                                   
         bestabelec.cod-estabel = "245" OR                                                                   
         bestabelec.cod-estabel = "249" OR                                                                   
         bestabelec.cod-estabel = "223" OR                                                                   
         bestabelec.cod-estabel = "222" OR                                                                   
         bestabelec.cod-estabel = "187" OR                                                                   
         bestabelec.cod-estabel = "064" OR                                                                   
         bestabelec.cod-estabel = "243" OR                                                                   
         bestabelec.cod-estabel = "228" OR                                                                   
         bestabelec.cod-estabel = "206" OR                                                                   
         bestabelec.cod-estabel = "229" OR                                                                   
         bestabelec.cod-estabel = "242" OR                                                                   
         bestabelec.cod-estabel = "246" OR                                                                   
         bestabelec.cod-estabel = "262" OR                                                                   
         bestabelec.cod-estabel = "260" OR                                                                   
         bestabelec.cod-estabel = "261" OR                                                                   
         bestabelec.cod-estabel = "267" OR                                                                   
         bestabelec.cod-estabel = "268"*/
         by bestabelec.COD-ESTABEL :                                                                         
        for-ped:      
        for each int-ds-pedido no-lock where 
            int-ds-pedido.situacao = 1 and
           (int-ds-pedido.ped-tipopedido-n = 1 OR
            int-ds-pedido.ped-tipopedido-n = 8) and
            int-ds-pedido.ped-cnpj-destino = bestabelec.cgc
            query-tuning(no-lookahead)
            by int-ds-pedido.ped-cnpj-destino
            on error undo, next:

            run pi-acompanhar in h-acomp (input "Lendo Pedido: " + string(int-ds-pedido.ped-codigo-n)).
            assign  de-vl-tot-ped       = 0
                    de-preco            = 0 
                    de-vl-liq           = 0
                    de-vl-desc-total    = 0
                    l-pedido-com-erro   = no
                    c-observacao        = ""
                    c-placa             = ""
                    c-uf-placa          = "".

            assign  c-nr-pedcli         = trim(string(int-ds-pedido.ped-codigo-n))
                    d-dt-implantacao    = today
                    d-dt-entrega        = if int-ds-pedido.ped-dataentrega-d >= today 
                                          then int-ds-pedido.ped-dataentrega-d else today
                    d-dt-emissao        = int-ds-pedido.ped-data-d
                    c-observacao        = int-ds-pedido.ped-observacao-s
                    c-placa             = int-ds-pedido.ped-placaveiculo-s
                    c-uf-placa          = int-ds-pedido.ped-estadoveiculo-s.

            assign i-nr-registro = i-nr-registro + 1.
            /* processa pedido atual */
            run valida-registro-pedido.


            assign  c-it-codigo         = ""
                    de-quantidade       = 0
                    de-vl-uni           = 0
                    de-desconto         = 0
                    c-numero-caixa      = ""
                    c-numero-lote       = ""
                    c-class-fiscal      = ""
                    c-ct-codigo         = ""
                    c-sc-codigo         = ""
                    c-class-fiscal      = "".

                    /*c-desc-padrao       = int-ds-pedido-produto.ppr-valor-bruto-n - int-ds-pedido-produto.ppr-valor-liquido-n*/

            if not l-pedido-com-erro then
            for each int-ds-pedido-produto no-lock of int-ds-pedido,
                each int-ds-pedido-retorno no-lock of int-ds-pedido-produto
                query-tuning(no-lookahead)
                break by int-ds-pedido-retorno.ped-codigo-n
                        by int-ds-pedido-retorno.ppr-produto-n
                          by int-ds-pedido-retorno.rpp-lote-s
                on error undo for-ped, next for-ped:

                if first-of (int-ds-pedido-retorno.rpp-lote-s) then de-quantidade = 0.

                assign  c-it-codigo         = trim(string(int-ds-pedido-produto.ppr-produto-n))
                        de-quantidade       = de-quantidade + int-ds-pedido-retorno.rpp-quantidade-n
                        de-vl-uni           = int-ds-pedido-produto.ppr-valorbruto-n
                        de-desconto         = int-ds-pedido-produto.ppr-percentualdesconto-n
                        c-numero-caixa      = (if c-numero-caixa = ""
                                               then string(int-ds-pedido-retorno.rpp-caixa-n)
                                               else c-numero-caixa + "," + string(int-ds-pedido-retorno.rpp-caixa-n))
                        c-numero-lote       = int-ds-pedido-retorno.rpp-lote-s
                        /*c-desc-padrao       = int-ds-pedido-produto.ppr-valor-bruto-n - int-ds-pedido-produto.ppr-valor-liquido-n*/.

                run valida-registro-item.        
                if l-pedido-com-erro then next.
                find first tt-ped-venda-imp use-index ch-pedido where 
                    tt-ped-venda-imp.nome-abrev = c-nome-abrev and
                    tt-ped-venda-imp.nr-pedcli  = c-nr-pedcli no-error.
                if not avail tt-ped-venda-imp then do:
                    run cria-tt-ped-venda-imp.
                    assign i-nr-sequencia = 0.
                end.
                if last-of(int-ds-pedido-retorno.rpp-lote-s) then run cria-tt-ped-item-imp.
            end.
            for first tt-ped-item-imp: end.
            if not l-pedido-com-erro and not avail tt-ped-item-imp then do:
                assign i-erro = 37
                       c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " + string(int-ds-pedido.ped-cnpj-origem)
                                    + " - " + string(int-ds-pedido.ped-cnpj-destino)
                       l-pedido-com-erro = yes.
                run gera-log. 
            end.
            else if not l-pedido-com-erro then run verifica-quantidades.
            run finaliza-pedido.
        end.
    END.
END. 

procedure verifica-quantidades:
    def var i-qt-tt as integer no-undo.
    def var i-qt-ds as integer no-undo.

    for each tt-ped-item-imp no-lock:
        i-qt-tt = i-qt-tt + tt-ped-item-imp.qt-pedida.
    end.
    for each int-ds-pedido-produto fields (ped-codigo-n) no-lock of int-ds-pedido,
        each int-ds-pedido-retorno fields (rpp-quantidade-n) no-lock of int-ds-pedido-produto
        query-tuning(no-lookahead):
        i-qt-ds = i-qt-ds + int-ds-pedido-retorno.rpp-quantidade-n.
    end.
    if i-qt-tt <> i-qt-ds then do:
        assign i-erro       = 33
               c-informacao = c-nr-pedcli
                            + " "
                            + c-nome-abrev.
        assign l-pedido-com-erro = yes.
        run gera-log.
    end.
end.

procedure finaliza-pedido.
   run pi-acompanhar in h-acomp (input "Finalizando Pedido").

   if not l-pedido-com-erro then do:
      run grava-pedido.
      if not l-pedido-com-erro then do:
         assign i-erro       = 1
                c-informacao = c-nr-pedcli
                             + " "
                             + c-nome-abrev.
          do transaction:
              find current int-ds-pedido exclusive-lock no-error no-wait.
              if avail int-ds-pedido then 
                 assign int-ds-pedido.situacao = 2 /* integrado */.
         end.
         run gera-log.
         release int-ds-pedido.
      end.
   end.
   run elimina-tabelas.
end.

procedure valida-registro-pedido.
    
    run pi-acompanhar in h-acomp (input "Validando Pedido").
    
    assign c-cod-estabel = ""
           c-uf-origem   = "".

    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int-ds-pedido.ped-cnpj-origem-s,
        first cst-estabelec no-lock where 
        cst-estabelec.cod-estabel = estabelec.cod-estabel and
        cst-estabelec.dt-fim-operacao >= d-dt-emissao:
        assign c-cod-estabel = estabelec.cod-estabel.
               c-uf-origem   = estabelec.estado.
        leave.
    end.
    if c-cod-estabel = "" then
    do:
       assign i-erro = 30
              c-informacao = c-nr-pedcli + " - " + string(int-ds-pedido.ped-cnpj-origem)
              l-pedido-com-erro = yes.
       run gera-log. 
       return.
    end.
    
    assign  c-nome-abrev = ""
            i-cod-emitente = 0
            c-nr-tabpre    = ""
            i-canal-vendas = 0
            i-cod-rep      = 1
            i-cod-cond-pag = 0
            c-cod-transp   = ""
            c-natur        = ""
            c-nome-transp  = ""
            c-redespacho   = ""
            c-uf-destino   = "".

    for first emitente no-lock where
        emitente.cgc = trim(int-ds-pedido.ped-cnpj-destino-s):
        assign  c-nome-abrev   = emitente.nome-abrev
                i-cod-emitente = emitente.cod-emitente
                c-nr-tabpre    = if emitente.nr-tabpre <> "" then emitente.nr-tabpre else ""
                i-canal-vendas = emitente.cod-canal-venda
                i-cod-rep      = if emitente.cod-rep <> 0 
                                 then emitente.cod-rep
                                 else i-cod-rep
                i-cod-cond-pag = if emitente.cod-cond-pag <> 0 then emitente.cod-cond-pag else i-cod-cond-pag
                c-cod-transp   = int-ds-pedido.ped-cnpj-transportadora
                c-uf-destino   = emitente.estado
                c-cod-entrega  = emitente.cod-entrega.

        if c-cod-transp = "" then 
        for first transporte no-lock where 
            transporte.cod-transp = emitente.cod-transp:
            assign  c-nome-transp = transporte.nome-abrev.
        end.
        assign c-redespacho = emitente.nome-tr-red.

        if emitente.ind-cre-cli = 4 then do:
          assign i-erro = 27
                 c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " + string(i-cod-emitente)
                 l-pedido-com-erro = yes.
          run gera-log. 
          return.
        end. 

        if emitente.identific = 2 then do:
          assign i-erro = 28
                 c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " + string(i-cod-emitente)
                 l-pedido-com-erro = yes.
          run gera-log. 
          return.
        end. 
    end.
    if c-nome-abrev = "" then do:
        assign i-erro = 02
               c-informacao = c-nr-pedcli + " - " + string((int-ds-pedido.ped-cnpj-destino))
               l-pedido-com-erro = yes.
        run gera-log. 
        return.
    end.

    assign  c-cod-rota    = "".
    for first estab-cli no-lock where 
        estab-cli.cod-estabel = c-cod-estabel and
        estab-cli.nome-abrev = c-nome-abrev:
        assign  c-cod-rota    = estab-cli.cod-rota.
                c-nome-transp = if c-nome-transp = "" then estab-cli.nome-transp else "".
        if estab-cli.cod-entrega <> "" then c-cod-entrega = estab-cli.cod-entrega.
    end.        
    c-nome-repres  = "".
    if i-cod-rep <> 0 then do:
        for first repres no-lock where 
            repres.cod-rep = i-cod-rep:
            assign c-nome-repres = repres.nome-abrev.
        end.
    end.
    if c-nome-repres = "" then do:
        assign i-erro = 13
               c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " + string(i-cod-rep)
               l-pedido-com-erro = yes.
        run gera-log. 
        return.
    end.
    if i-tab-finan = 0 then
      assign i-tab-finan = 1
             i-indice    = 0.
            
    if not can-find (first tab-finan no-lock where 
                    tab-finan.nr-tab-finan = i-tab-finan) then do:
      assign i-erro = 35
             c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                            string(i-tab-finan)
             l-pedido-com-erro = yes.
      run gera-log. 
      return.
    end.                     
    
    if c-nr-tabpre <> "" then do:    
      find tb-preco where 
           tb-preco.nr-tabpre = c-nr-tabpre
           no-lock no-error.
      if not avail tb-preco then do:
         assign i-erro = 3
                c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                               c-nr-tabpre
                l-pedido-com-erro = yes.
         run gera-log. 
         return.
      end.
      if avail tb-preco then do:
         if tb-preco.dt-inival >= d-dt-emissao or 
            tb-preco.dt-fimval <= d-dt-emissao then do:
            assign i-erro = 4
                   c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                                  c-nr-tabpre
                   l-pedido-com-erro = yes.
            run gera-log. 
            return.
         end.     
         if tb-preco.dt-inival >= d-dt-entrega or 
            tb-preco.dt-fimval <= d-dt-entrega then do:
            assign i-erro = 4
                   c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                                  c-nr-tabpre
                   l-pedido-com-erro = yes.
            run gera-log. 
            return.
         end.     
         if tb-preco.dt-inival >= today or 
            tb-preco.dt-fimval <= today then do:
            assign i-erro = 4
                   c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                                  c-nr-tabpre
                   l-pedido-com-erro = yes.
            run gera-log. 
            return.
         end.     
         if not tb-preco.situacao = 1 then do:
            assign i-erro = 5
                   c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                                  c-nr-tabpre
                   l-pedido-com-erro = yes.
            run gera-log. 
            return.
         end.
      end.
    end.  
    
    if i-canal-vendas <> 0 then
    do:
       find first canal-venda no-lock where
           canal-venda.cod-canal-venda = i-canal-vendas
           no-error.
       if not avail canal-venda then
       do:
          assign i-erro = 31
                 c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                                string(i-canal-vendas) + " - " + string(i-cod-emitente)
                 l-pedido-com-erro = yes.
          run gera-log. 
          return.
       end.
    end.

    if i-cod-cond-pag <> 0
    then do:
      find cond-pagto where
           cond-pagto.cod-cond-pag = i-cod-cond-pag
           no-lock no-error.
      if not avail cond-pagto then do:
         assign i-erro = 15
                c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                               string(i-cod-cond-pag)
                l-pedido-com-erro = yes.
         run gera-log. 
         return.
      end.    
      else if cond-pagto.cod-vencto <> 2 /* a vista */ and 
           avail emitente and emitente.ind-cre-cli = 5 /* so a vista */ then
      do:
         assign i-erro = 26
                c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                               string(i-cod-cond-pag)
                l-pedido-com-erro = yes.
         run gera-log. 
         return.
      end.
    end.

    if c-cod-transp <> "" then do:
       find transporte where 
            transporte.cgc = c-cod-transp
            no-lock no-error.
       if not avail transporte then do:
       /*
          assign i-erro = 16
                 c-informacao = c-nr-pedcli + " - " + 
                                c-cod-transp
                 l-pedido-com-erro = yes.
          run gera-log. 
          return.
          */
       end.
       else do:
          assign c-nome-transp = transporte.nome-abrev.
       end.
    end.    
    
    find first ped-venda  where 
         ped-venda.nome-abrev = c-nome-abrev and
         ped-venda.nr-pedcli  =  c-nr-pedcli
       no-error.
    if avail ped-venda then do:     
         assign i-erro       = 19
                c-informacao = c-nr-pedcli
                             + " "
                             + c-nome-abrev.
         do transaction:        
             find current int-ds-pedido exclusive-lock no-error no-wait.
             if avail int-ds-pedido then
                 assign int-ds-pedido.situacao = 2 /* integrado */.
         end.
         run gera-log.
         return.
    end.
    /*
    if c-cod-entrega <> "" and
       c-cod-entrega <> "0"
    then do:
        for first bemitente no-lock where
            bemitente.cod-emitente = int(c-cod-entrega). end.
        if not avail bemitente then do:
           assign i-erro = 24
                  c-informacao = c-nr-pedcli + " - " + 
                                 c-nome-abrev + " - " +
                                 c-cod-entrega
                 l-pedido-com-erro = yes.
           run gera-log. 
           return.
        end.
    end.
    else do:
        for first bemitente no-lock where
            bemitente.cod-emitente = i-cod-emitente. end.
    end.
    */
    
    if c-redespacho <> "" and 
       c-redespacho <> "0" 
    then do:
        for first btransporte no-lock where
            btransporte.cod-transp = int(c-redespacho). end.
        if not avail btransporte then do:
           assign i-erro = 23
                  c-informacao = c-nr-pedcli + " - " + 
                                 c-nome-abrev + 
                                 " - " +
                                 c-redespacho
                  l-pedido-com-erro = yes.
           run gera-log. 
           return.
        end.
    end.
end.
      
procedure valida-registro-item.
   run pi-acompanhar in h-acomp (input "Validando Itens").
   for first item no-lock where
        item.it-codigo = c-it-codigo:
       c-class-fiscal = item.class-fiscal.
       if item.tipo-contr = 1 /* Fisico */ OR item.tipo-contr = 4 /* DDireto */ then
           assign c-ct-codigo = item.ct-codigo
                  c-sc-codigo = item.sc-codigo.
   end.
   if not avail item then do:
      assign i-erro = 9
             c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                            c-it-codigo 
             l-pedido-com-erro = yes.
      run gera-log. 
      return.
   end.
   if c-class-fiscal = "" then do:
       assign i-erro = 36
              c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                             c-it-codigo 
              l-pedido-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail item and item.cod-obsoleto = 4 then do:
      assign i-erro = 10
             c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                            c-it-codigo
             l-pedido-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if avail item and not item.ind-item-fat then do:
      assign i-erro = 11
             c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                            c-it-codigo
             l-pedido-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if avail item and 
     (item.tipo-contr = 1 /* Fisico */ OR item.tipo-contr = 4 /* DDireto */) and 
      c-ct-codigo = "" then do:
       assign i-erro = 34
              c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                             c-it-codigo
              l-pedido-com-erro = yes.
       run gera-log. 
       return.
   end.

   if dec(de-quantidade) <= 0 then do:
      assign i-erro = 12
             c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                            c-it-codigo + " - " + 
                            string(de-quantidade)
             l-pedido-com-erro = yes.
      run gera-log. 
      return.
   end. 
       
   /* determina natureza de operacao */
   run intprg/int015a.p ( input "1"              ,
                          input c-uf-destino         ,
                          input c-uf-origem         ,
                          input c-cod-estabel    ,
                          input i-cod-emitente   ,
                          input c-class-fiscal,
                          input 0, /* cst-icms devolucoes */
                          output c-natur         , 
                          output i-cod-cond-pag  , 
                          output i-cod-portador ,
                          output i-modalidade   ,
                          output c-serie        ,
                          output r-rowid).

   find natur-oper where
        natur-oper.nat-operacao = c-natur 
        no-lock no-error.
   if not avail natur-oper then do:
       assign i-erro = 21
           c-informacao = c-nr-pedcli + c-nome-abrev + " - " + "1"  
                          + " - " + 
                          c-uf-destino + " - " + 
                          c-uf-origem + " - " + 
                          C-COD-ESTABEL + " - " + 
                          STRING(I-COD-EMITENTE) + " - " +
                          c-class-fiscal
              l-pedido-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
      not natur-oper.nat-ativa then do:
       assign i-erro = 32  
              c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                          c-natur
           l-pedido-com-erro = yes.
       run gera-log. 
       return.
   end.
   if (avail natur-oper and not natur-oper.emite-duplic) or i-cod-cond-pag = ? then
       assign i-cod-cond-pag = 0.

   assign l-ind-icm-ret = no.
   if avail natur-oper and natur-oper.nat-operacao begins "6409" then
        assign l-ind-icm-ret = yes.

   /*
   if de-vl-uni
    = 0 and avail item then do:
        for last preco-item no-lock where 
            preco-item.nr-tabpre = c-nr-tabpre and
            preco-item.it-codigo = item.it-codigo and
            preco-item.situacao = 1 /* ativo */ and
            preco-item.dt-inival <= today:
          assign de-vl-uni = preco-item.preco-venda.
        end.
   end.
   */
   IF c-cod-estabel = "973" THEN DO:
       de-vl-uni = 0.
       for first item-uni-estab no-lock where 
           item-uni-estab.it-codigo   = item.it-codigo and
           item-uni-estab.cod-estabel = c-cod-estabel:
           if c-uf-origem = c-uf-destino then
               assign de-vl-uni = item-uni-estab.preco-base.
           else
               assign de-vl-uni = item-uni-estab.preco-ul-ent.
       end.
   END.
   if de-vl-uni = 0 then do:
        assign i-erro = 38
               c-informacao = c-nr-pedcli + "/" + c-nome-abrev + " - " +
                              c-nr-tabpre + " - " + 
                              c-it-codigo
               l-pedido-com-erro = yes.
        run gera-log. 
        return.
   end.

   assign de-aliquota-ipi = 0.
   if avail item and 
      item.cd-trib-ipi <> 2 and /* isento */
      item.cd-trib-ipi <> 3     /* outros */
   then 
       assign de-aliquota-ipi = item.aliquota-ipi.
   else 
       assign de-aliquota-ipi = 0.
end.
 
procedure cria-tt-ped-venda-imp.
   run pi-acompanhar in h-acomp (input "Criando Pedido").

   for first emitente no-lock where
       emitente.cod-emitente = i-cod-emitente: end.
   
   create tt-ped-venda-imp.
   assign tt-ped-venda-imp.cod-estabel    = c-cod-estabel
          tt-ped-venda-imp.nome-abrev     = emitente.nome-abrev
          tt-ped-venda-imp.nr-pedcli      = c-nr-pedcli
          tt-ped-venda-imp.nr-pedrep      = c-nr-pedcli
          tt-ped-venda-imp.cod-emitente   = emitente.cod-emitente
          tt-ped-venda-imp.nr-pedido      = next-value (seq-nr-pedido)
          tt-ped-venda-imp.dt-emissao     = d-dt-emissao
          tt-ped-venda-imp.dt-implant     = d-dt-implantacao
          tt-ped-venda-imp.dt-entrega     = d-dt-entrega
          tt-ped-venda-imp.dt-entorig     = d-dt-entrega
          tt-ped-venda-imp.nat-operacao   = c-natur
          tt-ped-venda-imp.cod-cond-pag   = int(i-cod-cond-pag)
          tt-ped-venda-imp.perc-desco1    = 0  
          tt-ped-venda-imp.perc-desco2    = 0
          tt-ped-venda-imp.no-ab-reppri   = c-nome-repres
          tt-ped-venda-imp.nr-tabpre      = c-nr-tabpre
          tt-ped-venda-imp.nr-tab-finan   = i-tab-finan 
          tt-ped-venda-imp.nr-ind-finan   = i-indice    
          tt-ped-venda-imp.tp-pedido      = "1"
          tt-ped-venda-imp.cod-priori     = 0
          tt-ped-venda-imp.local-entreg   = emitente.endereco
          tt-ped-venda-imp.bairro         = emitente.bairro
          tt-ped-venda-imp.cidade         = emitente.cidade
          tt-ped-venda-imp.nome-tr-red    = if avail btransporte 
                                            then btransporte.nome-abrev
                                            else ""
          tt-ped-venda-imp.cond-redespa   = c-cond-redespacho                                         
          tt-ped-venda-imp.inc-desc-txt   = no
          tt-ped-venda-imp.placa          = c-placa
          tt-ped-venda-imp.uf-placa       = c-uf-placa

          tt-ped-venda-imp.cod-canal-venda = if avail canal-venda
                                             then canal-venda.cod-canal-venda
                                             else 0.

   assign tt-ped-venda-imp.ind-tp-frete   = 2 /* FOB */.
   if emitente.cod-entrega <> "" then do:
        assign tt-ped-venda-imp.cod-entrega = emitente.cod-entrega.
   end.
   else do: 
        find first loc-entr no-lock 
            where loc-entr.nome-abrev = emitente.nome-abrev
            no-error.
        if avail loc-entr then
        do:
            assign tt-ped-venda-imp.cod-entrega  = loc-entr.cod-entrega.
            if loc-entr.nome-transp <> "" then assign tt-ped-venda-imp.nome-transp = loc-entr.nome-transp.
            if loc-entr.cod-rota <> "" then assign tt-ped-venda-imp.cod-rota = loc-entr.cod-rota.
            if loc-entr.nom-cidad-cif <> "" then assign c-cidade-cif = loc-entr.nom-cidad-cif
                                                        tt-ped-venda-imp.ind-tp-frete   = 1 /* CIF */.
        end.
        else do:
            assign tt-ped-venda-imp.cod-entrega  = "PadrÆo".
        end.
   end.

   if tt-ped-venda-imp.ind-tp-frete = 1 then /* CIF */
   do:
      assign tt-ped-venda-imp.cidade-cif = if c-cidade-cif <> "" and
                                              c-cidade-cif <> "0" and
                                              c-cidade-cif <> "." 
                                           then c-cidade-cif
                                           else emitente.cidade. 
   end.
                
   assign tt-ped-venda-imp.estado         = emitente.estado
          tt-ped-venda-imp.cep            = emitente.cep
          tt-ped-venda-imp.caixa-postal   = emitente.caixa-postal
          tt-ped-venda-imp.pais           = emitente.pais
          tt-ped-venda-imp.cgc            = emitente.cgc
          tt-ped-venda-imp.ins-estadual   = emitente.ins-estadual
          tt-ped-venda-imp.cod-sit-ped    = 1.
          
   assign tt-ped-venda-imp.cod-portador   = if i-cod-portador <> ? and i-cod-portador <> 0 
                                            then i-cod-portador else emitente.portador
          tt-ped-venda-imp.modalidade     = if i-cod-portador <> ? and i-cod-portador <> 0 
                                            then i-modalidade else emitente.modalidade
          tt-ped-venda-imp.cod-mensagem   = natur-oper.cod-mensagem
          tt-ped-venda-imp.user-impl      = c-seg-usuario
          tt-ped-venda-imp.dt-userimp     = today
          tt-ped-venda-imp.ind-aprov      = no
          tt-ped-venda-imp.quem-aprovou   = " "
          tt-ped-venda-imp.dt-apr-cred    = ?
          tt-ped-venda-imp.cod-des-merc   = if natur-oper.consum-final 
                                            then 2 else 1
          tt-ped-venda-imp.vl-tot-ped     = 0
          tt-ped-venda-imp.vl-liq-ped     = 0
          tt-ped-venda-imp.vl-liq-abe     = 0
          tt-ped-venda-imp.observacoes    = c-observacao
          tt-ped-venda-imp.nome-transp    = c-nome-transp  
          tt-ped-venda-imp.tp-preco       = 1
          tt-ped-venda-imp.tip-cob-desp   = 1
          tt-ped-venda-imp.per-max-canc   = emitente.per-max-canc
          tt-ped-venda-imp.ind-lib-nota   = yes
          tt-ped-venda-imp.completo       = yes
          tt-ped-venda-imp.ind-ent-completa = yes
          tt-ped-venda-imp.cod-sit-aval   = 1
          tt-ped-venda-imp.cod-sit-com    = 1
          tt-ped-venda-imp.cod-sit-ped    = 1
          tt-ped-venda-imp.ind-imp-ped    = 2  /* batch */
          tt-ped-venda-imp.cd-origem      = 3  /* Sistema */
          tt-ped-venda-imp.origem         = 4. /* batch */ 

end.
 
procedure cria-tt-ped-item-imp.
   run pi-acompanhar in h-acomp (input "Criando Itens do Pedido").
   /*
   find last preco-item where 
        preco-item.nr-tabpre   = c-nr-tabpre and
        preco-item.it-codigo   = c-it-codigo and
        preco-item.situacao = 1 /* ativo */ and
        preco-item.dt-inival <= today
        no-lock no-error. 
   if avail preco-item and de-vl-uni = 0 and 
      preco-item.preco-venda <> 0 then
        assign de-preco = preco-item.preco-venda.
   else*/
        assign de-preco = de-vl-uni. 

   assign i-nr-sequencia = i-nr-sequencia + 10.
   create tt-ped-item-imp.
   assign tt-ped-item-imp.nome-abrev   = tt-ped-venda-imp.nome-abrev
          tt-ped-item-imp.nr-pedcli    = tt-ped-venda-imp.nr-pedcli
          tt-ped-item-imp.nr-sequencia = i-nr-sequencia
          tt-ped-item-imp.it-codigo    = c-it-codigo
          tt-ped-item-imp.nat-operacao = c-natur
          tt-ped-item-imp.nr-tabpre    = "" /*c-nr-tabpre*/
          tt-ped-item-imp.qt-pedida    = dec(de-quantidade)
          tt-ped-item-imp.qt-un-fat    = tt-ped-item-imp.qt-pedida
          tt-ped-item-imp.vl-pretab    = de-preco /* preco-item.preco-venda */
          tt-ped-item-imp.vl-preori    = de-preco.
   assign tt-ped-item-imp.des-un-medida = item.un
          tt-ped-item-imp.cod-un        = item.un
          tt-ped-item-imp.ind-icm-ret   = l-ind-icm-ret.

   assign tt-ped-item-imp.ct-codigo     = c-ct-codigo
          tt-ped-item-imp.sc-codigo     = c-sc-codigo.

   assign tt-ped-item-imp.numero-lote   = c-numero-lote
          tt-ped-item-imp.numero-caixa  = substring(c-numero-caixa,1,20).

   assign tt-ped-item-imp.cod-refer    = c-cod-refer.

   assign de-preco-liq = de-preco.
   if de-desconto <> 0 then
   do:
      assign de-preco-liq = de-preco * (1 - (de-desconto / 100)).
      assign tt-ped-item-imp.val-pct-desconto-total = de-desconto
             tt-ped-item-imp.val-desconto-total = (dec(de-quantidade) * de-preco)
                                            * (de-desconto / 100).
      assign tt-ped-item-imp.des-pct-desconto-inform = string(de-desconto)
             tt-ped-item-imp.per-des-item = de-desconto
             tt-ped-item-imp.log-usa-tabela-desconto = no.
   end.
   assign de-red-base-ipi = 0 /* base normal */
          de-base-ipi = (de-preco-liq * tt-ped-item-imp.qt-pedida). 
   if avail natur-oper and /* IPI SOBRE O BRUTO */
     substring(natur-oper.char-2,11,1) = "1" then
   do:
      de-base-ipi = (de-preco * tt-ped-item-imp.qt-pedida). 
   end.
   
   /* Aliquota ISS */
   if avail natur-oper and
      natur-oper.tipo = 3 then 
      assign tt-ped-item-imp.dec-2 = item.aliquota-iss
             tt-ped-item-imp.val-aliq-iss = item.aliquota-iss.
   else 
      assign tt-ped-item-imp.dec-2 = 0
             tt-ped-item-imp.val-aliq-iss = 0.

       /* IPI Diferenciado */
   if item.ind-ipi-dife = no and 
      item.tipo-contr <> 4 then do:
      overlay(tt-ped-item-imp.char-2,01,08) = "".
      assign tt-ped-item-imp.cod-class-fis = "".
   end.       
   else do:
      overlay(tt-ped-item-imp.char-2,01,08) = c-class-fiscal. 
      assign tt-ped-item-imp.cod-class-fis = c-class-fiscal.
   end.       

   if avail natur-oper  and
      natur-oper.cd-trib-ipi <> 2 and    /* isento */
      natur-oper.cd-trib-ipi <> 3 then do: /* outros */ 
      if natur-oper.cd-trib-ipi = 4 and /* reduzido */
         item.cd-trib-ipi = 4 then     /* reduzido */
      do:
         assign de-red-base-ipi = natur-oper.perc-red-ipi.
                de-base-ipi = (de-preco-liq * tt-ped-item-imp.qt-pedida) * 
                               (1 - (de-red-base-ipi / 100)).
      end. 
   end.
   else do: /* somente tributa se natureza = T/R e item = T/R */
      assign de-aliquota-ipi = 0.
   end.
   
   assign tt-ped-item-imp.vl-preuni    = de-preco-liq
          tt-ped-item-imp.vl-merc-abe  = de-preco-liq * tt-ped-item-imp.qt-pedida 
          tt-ped-item-imp.vl-liq-it    = de-preco-liq * tt-ped-item-imp.qt-pedida
          tt-ped-item-imp.vl-liq-abe   = (de-preco-liq * tt-ped-item-imp.qt-pedida) + 
                                         de-base-ipi * (de-aliquota-ipi / 100)
          tt-ped-item-imp.vl-tot-it    = (de-preco-liq * tt-ped-item-imp.qt-pedida) +
                                         de-base-ipi * (de-aliquota-ipi / 100)
          tt-ped-item-imp.aliquota-ipi = de-aliquota-ipi
          tt-ped-item-imp.tipo-atend   = 1
          tt-ped-item-imp.dt-userimp   = today
          tt-ped-item-imp.user-impl    = c-seg-usuario
          tt-ped-item-imp.dt-entorig   = d-dt-entrega
          tt-ped-item-imp.dt-entrega   = d-dt-entrega
          tt-ped-item-imp.dt-userimp   = today
          tt-ped-item-imp.user-impl    = c-seg-usuario
          tt-ped-item-imp.esp-ped      = 1
          tt-ped-item-imp.ind-componen = 1
          tt-ped-item-imp.tipo-atend   = 02 /* Parcial */
          tt-ped-item-imp.cd-origem    = 3  /* Sistema */
          tt-ped-item-imp.cod-sit-com  = 1
          tt-ped-item-imp.cod-sit-item = 1.

   assign substring (tt-ped-item-imp.char-2,56 - length(string(de-base-ipi * (1 + (de-aliquota-ipi / 100)),">>>>>99.99")),10) = 
          string(de-base-ipi * (de-aliquota-ipi / 100) ,">>>>>99.99")
          tt-ped-item-imp.val-ipi = de-base-ipi * (de-aliquota-ipi / 100).

   assign tt-ped-item-imp.cod-sit-preco      = 2 /* aprovado */
          tt-ped-item-imp.dat-aprov-preco    = today
          tt-ped-item-imp.desc-lib-preco     = "Pedido Loja"
          tt-ped-item-imp.dat-aprov-preco    = today
          tt-ped-item-imp.cod-sit-com        = 2
          tt-ped-item-imp.dt-lib-cot         = today
          tt-ped-item-imp.motivo-alt-sit-quota = "Pedido Loja"
          tt-ped-item-imp.dt-aprov-cot       = today
          tt-ped-item-imp.user-aprov-cot     = c-seg-usuario
          tt-ped-item-imp.user-lib-cot       = c-seg-usuario.
       
   assign de-vl-liq         = de-vl-liq + tt-ped-item-imp.vl-liq-it
          de-vl-tot-ped     = de-vl-tot-ped + tt-ped-item-imp.vl-tot-it 
          de-vl-desc-total  = de-vl-desc-total + tt-ped-item-imp.val-desconto-total.

   /*
   for first item-cli no-lock where 
       item-cli.it-codigo  = tt-ped-item-imp.it-codigo and
       item-cli.nome-abrev = tt-ped-item-imp.nome-abrev and
       item-cli.unid-med-cli = item.un: end.
   if not avail item-cli then do:
      create item-cli.
      assign item-cli.it-codigo     = tt-ped-item-imp.it-codigo
             item-cli.nome-abrev    = tt-ped-item-imp.nome-abrev
             item-cli.cod-emitente  = i-cod-emitente
             item-cli.fat-conver    = 1
             item-cli.fator-conver  = 1
             item-cli.ind-sit-relac = 1
             item-cli.item-do-cli   = tt-ped-item-imp.it-codigo
             item-cli.tp-adm-lote   = 1
             item-cli.tp-aloc-lote  = 1
             item-cli.tp-inspecao   = 2
             item-cli.tp-moeda      = 0
             item-cli.unid-med-cli  = item.un.
   end.
   for first item-cli-estab no-lock where 
       item-cli-estab.cod-estabel = c-cod-estabel and
       item-cli-estab.it-codigo   = tt-ped-item-imp.it-codigo and
       item-cli-estab.nome-abrev  = tt-ped-item-imp.nome-abrev and
       item-cli-estab.unid-med-cli = item.un: end.
   if not avail item-cli-estab then do:
      create item-cli-estab.
      assign item-cli-estab.cod-estabel   = c-cod-estabel
             item-cli-estab.it-codigo     = tt-ped-item-imp.it-codigo
             item-cli-estab.nome-abrev    = tt-ped-item-imp.nome-abrev
             item-cli-estab.cod-emitente  = i-cod-emitente
             item-cli-estab.fat-conver    = 1
             item-cli-estab.fator-conver  = 1
             item-cli-estab.item-do-cli   = tt-ped-item-imp.it-codigo
             item-cli-estab.tp-adm-lote   = 1
             item-cli-estab.tp-aloc-lote  = 1
             item-cli-estab.tp-inspecao   = 2
             item-cli-estab.tp-moeda      = 0
             item-cli-estab.unid-med-cli  = item.un.
   end.
   */
end.
 
procedure grava-pedido.

   /* chamar BO' s */
   if not valid-handle (h-bodi159)    then run dibo/bodi159.p    persistent set h-bodi159.
   if not valid-handle (h-bodi159com) then run dibo/bodi159com.p persistent set h-bodi159com.
   if not valid-handle (h-bodi159sus) then run dibo/bodi159sus.p persistent set h-bodi159sus.
   if not valid-handle (h-bodi159sdf) then run dibo/bodi159sdf.p persistent set h-bodi159sdf.
   /* itens dos pedidos */
   if not valid-handle (h-bodi154)    then run dibo/bodi154.p    persistent set h-bodi154.
   /* representantes do pedido */
   if not valid-handle (h-bodi157)    then run dibo/bodi157.p    persistent set h-bodi157.

   run pi-acompanhar in h-acomp (input "Gerando Tabelas").

   trans-block:
   do transaction:
      for each tt-ped-venda-imp no-lock:
   
         if not can-find (first tt-ped-venda no-lock
                          where tt-ped-venda.nome-abrev = tt-ped-venda-imp.nome-abrev and
                                tt-ped-venda.nr-pedcli = tt-ped-venda-imp.nr-pedcli) 
         then do:

            for first emitente 
                no-lock where
                emitente.nome-abrev = tt-ped-venda-imp.nome-abrev. end.

            create tt-ped-venda.
            buffer-copy tt-ped-venda-imp to tt-ped-venda.
            assign tt-ped-venda.vl-tot-ped         = de-vl-tot-ped
                   tt-ped-venda.vl-liq-ped         = de-vl-liq
                   tt-ped-venda.vl-liq-abe         = de-vl-tot-ped
                   tt-ped-venda.val-desconto-total = de-vl-desc-total.
      
            if avail emitente and 
               emitente.ind-cre-cli = 2 /* automatico */ then
            do:
               /* aprovando credito do pesido */
               assign tt-ped-venda.cod-sit-aval = 3 /* Aprovado */
                      tt-ped-venda.dt-apr-cred = today
                      tt-ped-venda.quem-aprovou = c-seg-usuario
                      tt-ped-venda.user-aprov = c-seg-usuario
                      tt-ped-venda.aprov-forcado = c-seg-usuario
                      tt-ped-venda.desc-forc-cr = if ind-cre-cli <> 2 then "Pedido em garantia"
                                               else "Cliente c/ aprovacao automatica"
                      tt-ped-venda.ind-aprov = yes /* Aprovado */
                      tt-ped-venda.cod-sit-com = 2 /* Aprovado */
                      tt-ped-venda.ind-sit-desc = 2 /* Aprovado */
                      tt-ped-venda.cod-message-alerta = 0
                      tt-ped-venda.dt-mensagem = ?
                      tt-ped-venda.dsp-pre-fat = yes
                      tt-ped-venda.dt-aprov-cot = today
                      tt-ped-venda.dat-aprov-preco = today
                      tt-ped-venda.desc-lib-desconto = if emitente.ind-cre-cli <> 2 then "Pedido em garantia"
                                                    else "Loja c/ aprovacao automatica"
                      tt-ped-venda.desc-lib-preco = if emitente.ind-cre-cli <> 2 then "Pedido em garantia"
                                                 else "Loja c/ aprovacao automatica"
                      tt-ped-venda.dt-validade-cot = today + 90
                      tt-ped-venda.cod-sit-preco = 2 /* aprovado */
                      tt-ped-venda.dat-sit-desconto = today.
            end.
            find tt-ped-repre-imp where
                 tt-ped-repre-imp.nr-pedido    = tt-ped-venda-imp.nr-pedido and 
                 tt-ped-repre-imp.nome-ab-rep  = c-nome-repres
                 no-error.
      
            if not avail tt-ped-repre-imp then do:
               create tt-ped-repre-imp.
               assign tt-ped-repre-imp.nr-pedido    = tt-ped-venda-imp.nr-pedido
                      tt-ped-repre-imp.nome-ab-rep  = c-nome-repres
                      tt-ped-repre-imp.ind-repbase  = yes
                      tt-ped-repre-imp.perc-comis   = 0 /*repres.comis-direta*/
                      tt-ped-repre-imp.comis-emis   = 0 /*repres.comis-emis*/ .
               if avail tt-ped-venda then
                  assign tt-ped-venda.no-ab-reppri = c-nome-repres.
            end.
      
            /* Processar pedidos de venda */
            run inputTable in h-bodi159sdf (input table tt-ped-venda).
            /* carrega valores default pelo cliente */
            /*run setDefaultCustomerName in h-bodi159sdf.*/
            /* carrega valores default pela natureza */
            /*run setDefaultTransactionType in h-bodi159sdf.*/
            /*run outputTable  in h-bodi159sdf (output table tt-ped-venda).*/
            /*run getRowErrors in h-bodi159sdf (output table RowErrors).
            for each RowErrors where RowErrors.ErrorSubType = "Error":u:
                assign i-erro = 22
                       c-informacao =     tt-ped-venda-imp.nr-pedcli
                                          + " " +  
                                          string(tt-ped-venda-imp.cod-emitente) + "-" +  tt-ped-venda-imp.nat-operacao + "-" +
                                          string(RowErrors.ErrorNumber) + "-" +
                                          RowErrors.ErrorDescription.
                run gera-log.
                assign l-pedido-com-erro = yes.
            end.
            if l-pedido-com-erro then
            undo trans-block, leave trans-block.
            */

            run emptyRowErrors  in h-bodi159.
            if not can-find(first RowErrors where RowErrors.ErrorSubType = "Error":u) then do:
               run openQueryStatic in h-bodi159 (input "Main":u).
               run setRecord       in h-bodi159 (input table tt-ped-venda).
               run emptyRowErrors  in h-bodi159.
               run createRecord    in h-bodi159.
               run getRowErrors    in h-bodi159 (output table RowErrors).
               for each RowErrors where RowErrors.ErrorSubType = "Error":u:
                   assign i-erro = 22
                          c-informacao =     "di159 Create " +  tt-ped-venda-imp.nr-pedcli + "/" +
                                             string(tt-ped-venda-imp.nome-abrev) + "/" +  tt-ped-venda-imp.nat-operacao + "-" +  
                                             string(RowErrors.ErrorNumber) + "-" +
                                             RowErrors.ErrorDescription.
                   run gera-log.
                   assign l-pedido-com-erro = yes.
               end.
               if l-pedido-com-erro then
               undo trans-block, leave trans-block.
               /* posiciona na ped-venda */
               run emptyRowErrors in h-bodi159.
               run bringCurrent in h-bodi159.
               run getRowErrors in h-bodi159 (output table RowErrors).
               for each RowErrors where RowErrors.ErrorSubType = "Error":u:
                   assign i-erro = 22
                          c-informacao =     "di159 Bring " +  tt-ped-venda-imp.nr-pedcli + "/" +  
                                             string(tt-ped-venda-imp.nome-abrev) + "/" +  
                                             string(RowErrors.ErrorNumber) + "-" +
                                             RowErrors.ErrorDescription.
                   run gera-log.
                   assign l-pedido-com-erro = yes.
               end.
               if l-pedido-com-erro then
               undo trans-block, leave trans-block.

               if not can-find(first RowErrors where RowErrors.ErrorSubType = "Error":u) then do:
                  /* pega o row-id da ped-venda */
                  run emptyRowErrors in h-bodi159.
                  run getRecord      in h-bodi159 (output table tt-ped-venda).
                  run getRowErrors   in h-bodi159 (output table RowErrors).
                  for each RowErrors where RowErrors.ErrorSubType = "Error":u:
                     assign i-erro = 22
                            c-informacao =     "di159 Get " +  tt-ped-venda-imp.nr-pedcli + "/" +  
                                               string(tt-ped-venda-imp.nome-abrev) + "/" +  
                                               string(RowErrors.ErrorNumber) + "-" +
                                               RowErrors.ErrorDescription.
                     run gera-log.
                     assign l-pedido-com-erro = yes.
                  end.
                  if l-pedido-com-erro then
                  undo trans-block, leave trans-block.

                  for each tt-ped-item-imp no-lock of tt-ped-venda-imp:

                     if not can-find (first tt-ped-item no-lock
                                      where tt-ped-item.nome-abrev   = tt-ped-item-imp.nome-abrev and
                                            tt-ped-item.nr-pedcli    = tt-ped-item-imp.nr-pedcli and
                                            tt-ped-item.nr-sequencia = tt-ped-item-imp.nr-sequencia and
                                            tt-ped-item.it-codigo    = tt-ped-item-imp.it-codigo and
                                            tt-ped-item.cod-refer    = tt-ped-item-imp.cod-refer) then
                     do:
                        create tt-ped-item.
                        buffer-copy tt-ped-item-imp to tt-ped-item.
                        assign tt-ped-item.cod-entrega  = tt-ped-venda-imp.cod-entrega.

                        create cst-ped-item.
                        assign cst-ped-item.nome-abrev    = tt-ped-item-imp.nome-abrev
                               cst-ped-item.nr-sequencia  = tt-ped-item-imp.nr-sequencia
                               cst-ped-item.nr-pedcli     = tt-ped-item-imp.nr-pedcli
                               cst-ped-item.it-codigo     = tt-ped-item-imp.it-codigo
                               cst-ped-item.cod-refer     = tt-ped-item-imp.cod-refer.
                        assign cst-ped-item.numero-caixa  = tt-ped-item-imp.numero-caixa
                               cst-ped-item.numero-lote   = tt-ped-item-imp.numero-lote.

                        run emptyRowErrors  in h-bodi154.
                        run openQueryStatic in h-bodi154 (input "Main":u).
                        run setRecord       in h-bodi154 (input table tt-ped-item).
                        run createRecord    in h-bodi154.
                        run getRowErrors    in h-bodi154 (output table RowErrors).

                        for each RowErrors where RowErrors.ErrorSubType = "Error":u:
                            assign i-erro = 22
                                   c-informacao =     "di154 Create Ped: " +  tt-ped-venda-imp.nr-pedcli + " " +  
                                                      string(tt-ped-venda-imp.nome-abrev) + " It " +  
                                                      tt-ped-item.it-codigo + "/" +  
                                                      string(RowErrors.ErrorNumber) + "-" +
                                                      RowErrors.ErrorDescription.
                            run gera-log.
                            assign l-pedido-com-erro = yes.
                        end.
                        if l-pedido-com-erro then
                        undo trans-block, leave trans-block.
                        if avail tt-ped-item then delete tt-ped-item.
                     end.
                  end. /* tt-ped-item-imp */
               end. /* canpfind (RowErrors */
               /* processar representante */
               for each tt-ped-repre-imp
                   where tt-ped-repre-imp.nr-pedido = tt-ped-venda-imp.nr-pedido:

                  create tt-ped-repre.
                  buffer-copy tt-ped-repre-imp to tt-ped-repre.
                  run emptyRowErrors  in h-bodi157.
                  run openQueryStatic in h-bodi157 (input "Main":u).
                  run emptyRowErrors  in h-bodi157.
                  run setRecord       in h-bodi157 (input table tt-ped-repre).
                  run createRecord    in h-bodi157.
                  run getRowErrors    in h-bodi157 (output table RowErrors).

                  for each RowErrors where RowErrors.ErrorSubType = "Error":u:
                     assign i-erro = 22
                            c-informacao =     "di157 Create " +  tt-ped-venda-imp.nr-pedcli + "/" +  
                                               string(tt-ped-venda-imp.nome-abrev) + "/" +  
                                               tt-ped-repre-imp.nome-ab-rep + "-" +  
                                               string(RowErrors.ErrorNumber) + "-" +
                                               RowErrors.ErrorDescription.
                     run gera-log.
                     assign l-pedido-com-erro = yes.
                  end.
               end. /* tt-ped-repre-imp */
               /* completa o pedido */
               for first ped-venda where
                   ped-venda.nome-abrev = tt-ped-venda-imp.nome-abrev and
                   ped-venda.nr-pedcli  = tt-ped-venda-imp.nr-pedcli: end.

               if avail ped-venda then do:
                   /* gravando numero do pedido novamente para poder mostrar no log */
                   assign c-nr-pedcli = ped-venda.nr-pedcli.
                   create cst-ped-venda.
                   assign cst-ped-venda.nome-abrev = ped-venda.nome-abrev
                          cst-ped-venda.nr-pedcli  = ped-venda.nr-pedcli
                          cst-ped-venda.nr-pedido  = ped-venda.nr-pedido
                          cst-ped-venda.log-integrado-wms = yes
                          cst-ped-venda.log-liberado-wms = yes.

                  run completeOrder in h-bodi159com (input rowid(ped-venda),
                                                     output table rowErrors).
                                                     
               end.
            end.
         end. /* can find tt-ped-venda */
      end. /* tt-ped-venda-imp */
      if l-pedido-com-erro then undo trans-block, leave trans-block.
   end. /* transaction */

   assign de-vl-tot-ped = 0
          de-preco      = 0 
          de-vl-liq     = 0.

   run elimina-tabelas.
end.

procedure gera-log.

   run pi-acompanhar in h-acomp (input "Listando Erros").

   if tt-param.arquivo <> "" then do:
      display stream str-rp
              i-nr-registro
              with frame f-erro. 
           
       display stream str-rp
               tb-erro[i-erro] @ tb-erro[1]
               c-informacao
               with frame f-erro.
       down stream str-rp
            with frame f-erro.
   end.
   RUN intprg/int999.p ("PED", 
                        c-nr-pedcli,
                        (trim(tb-erro[i-erro]) + " - " + c-informacao),
                        int-ds-pedido.situacao, /* 1 - Pendente, 2 - Processado */ 
                        c-seg-usuario).

   assign c-informacao = " ".
end.
/* FIM DO PROGRAMA */




