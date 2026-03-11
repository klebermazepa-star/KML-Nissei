/*******************************************************
**
**  INT020RP.I2 - Include do programa INT020RP.P
**
*******************************************************/

/* defini‡ao de vari veis  */
def var h-acomp             as handle no-undo.
def var l-proc-ok-aux       as log    no-undo.
def var i-seq-wt-docto      as int    no-undo.
def var i-seq-wt-it-docto   as int    no-undo.
def var c-num-nota          like ped-venda.nr-pedcli.
def var i-cod-emitente       like emitente.cod-emitente.
def var i-cod-rep            as integer.
def var i-cod-cond-pag       as integer.
def var c-nr-cupom          as char.
def var c-it-codigo          as char.
def var de-quantidade        as decimal.
def var c-natur              like ped-venda.nat-operacao.
def var de-vl-uni            as dec format "999.999".
def var de-desconto          as decimal no-undo.
def var i-tab-finan          as integer.
def var i-indice             as integer.
def var de-aliquota-ipi      as decimal.
def var de-vl-tot-dup        like ped-venda.vl-tot-ped.
def var de-vl-tot-cup        like ped-venda.vl-tot-ped.
def var de-vl-liq-abe        like ped-venda.vl-tot-ped.
def var de-vl-liq            like ped-venda.vl-tot-ped.
def var i-canal-vendas       as integer.
def var i-nr-registro        as integer init 0.
def var c-informacao         as char format "x(256)".
def var i-erro               as integer init 0.
def var l-cupom-com-erro    as logical init no no-undo.
def var d-dt-emissao         as date.
def var d-dt-implantacao     as date.
def var i-nr-sequencia       as integer.
def var i-nr-seq-item        as integer.
def var c-nome-repres        as character.
def var c-numero-lote        as character.
def var tb-erro              as char format "x(50)" extent 59 init
                             ["01. Importado com Sucesso                         ",
                              "02. Cliente nao Cadastrado                        ",
                              "03. Tabela de preco nao Cadastrada                ",
                              "04. Tabela de preco fora do limite                ",
                              "05. Tabela de preco inativa                       ",
                              "06. Data Emissao invalida                         ",
                              "07. Data Entrega invalida                         ",
                              "08. Data Implantacao invalida                     ",
                              "09. Produto nao Cadastrado                        ",
                              "10. Produto esta obsoleto                         ",
                              "11. Produto nao disponivel para venda             ",
                              "12. Quantidade invalida                           ",
                              "13. Representante nao Cadastrado                  ",
                              "14. Cliente nao e do Representante                ",
                              "15. Condicao de Pagamento NAO Cadastrada INT018   ",
                              "16. Transportador Nao Cadastrado                  ",
                              "17. Numero do Pedido interno invalido             ",
                              "18. Documento a ser devolvido NAO existe          ",
                              "19. Serie deve ter tipo de emissao MANUAL         ",
                              "20. *** Cupom nao Importado ***                   ",
                              "21. Natureza de Operacao nao Cadastrada em INT115 ",
                              "22. ERRO BO de Calculo                            ",
                              "23. Transportador de redespachop NAO Cadastrado   ",
                              "24. Codigo do Cliente p/ Entrega NAO Existe       ",
                              "25. Quantidade de parcelas p/ pagto inconsistente ",
                              "26. Cliente so pode comprar A Vista               ",
                              "27. Cliente esta Suspenso                         ",
                              "28. Nat de Operacao de Devolucao exige nota origem",
                              "29. Nota Origem informada e Nat. Oper. Envio      ",
                              "30. Estabelecimento nao Cadastrado ou Inv lido    ",
                              "31. Canal de vendas nao Cadastrado                ",
                              "32. Nat.Operacao indicada esta inativa            ",
                              "33. Saldo estoque insuficiente p/ envio do lote   ",
                              "34. Portador nao Cadastrado                       ",
                              "35. Tabela de Financiamento NAO Cadastrada        ",
                              "36. Serie nao cadastrada p/ estabelecimento       ",
                              "37. Cupom inconsistente ou sem itens              ",
                              "38. Valor do item zerado                          ",
                              "39. Duplicatas do cupom nao encontradas           ",
                              "40. Valor duplicatas diferente do valor do CUPOM  ",
                              "41. Lote Informado e Item nÆo controla lote       ",
                              "42. Lote NAO informado para item que controla lote",
                              "43. Especie p/ titulos de INT018 nao cadastrada   ",
                              "44. CPF NAO informado para venda por convenio     ",
                              "45. Faixa Estabelecimentos nÆo cadastrada - NI0110",
                              "46. Cliente NAO cadastrado                        ",
                              "47. Vencimento duplicatas menor que emissao       ",
                              "48. Chave NFce NAO informada no cupom             ",
                              "49. Venda tributada ICMS e natureza NAO tributa   ",
                              "50. Natureza c/ ICMS e cupom sem valor de ICMS    ",
                              "51. Documento em per¡odo fechado ou em fechamento ",
                              "52. Baixa de estoque nÆo criada em tt-saldo-estoq ",
                              "53. Protocolo NFce NAO informado no cupom         ",
                              "54. Tipo transmissÆo NFce NAO informado no cupom  ",
                              "55. Condi‡Æo de pagamento nÆo informada no cupom  ",
                              "56. Total do cupom inconsistente                  ",
                              "57. Tributa‡Æo de ICMS inv lida                   ",
                              "58. Base de ICMS inv lida                         ",
                              "59. Campo valor convenio nÆo preenchido           "].

def var i-cont          as int init 0.
def var i-cont2         as int init 0.
def var de-red-base-icm as decimal no-undo.
def var de-red-base-ipi as decimal no-undo.
def var de-base-ipi     as decimal no-undo.
def var c-estado        as char no-undo. 
def var c-cidade        as char no-undo. 
def var c-cod-estabel   as char no-undo.
def var c-nome-abrev    as char no-undo.
def var c-class-fiscal  as char no-undo.
def var c-condipag      as char no-undo.
def var c-convenio      as char no-undo.
def var i-cod-portador  as integer no-undo.
def var i-modalidade    as integer no-undo.
def var i-cod-port-dinh as integer initial 99901 no-undo.
def var i-modalid-dinh  as integer initial 6 no-undo.
def var i-cond-pag-dinh as integer initial 1 no-undo.
def var c-serie         as char no-undo.
def var de-aliq-icms    as decimal no-undo.
def var de-base-icms    as decimal no-undo.
def var de-valor-icms   as decimal no-undo.
def var de-valor-dinh   as decimal no-undo.
def var de-valor-cartaod as decimal no-undo.
def var de-valor-cartaoc as decimal no-undo.
def var de-valor-vale    as decimal no-undo.
def var r-rowid          as rowid no-undo.
def var de-aux           as decimal no-undo.
def var l-saldo-neg      as logical no-undo.
def var i-seq-fat-duplic as integer no-undo.
def var c-cpf            as char no-undo.
def var i-tip-cob-desp   as integer no-undo.
def var c-cod-esp-princ  like fat-duplic.cod-esp no-undo.
def var i-cod-mensagem   like natur-oper.cod-mensagem no-undo.
def var i-tipo-contr     like item.tipo-contr no-undo.
def var i-cod-vencto     like cond-pagto.cod-vencto   no-undo.
def var i-prazos         like cond-pagto.prazos       no-undo.
def var de-per-pg-dup    like cond-pagto.per-pg-dup   no-undo.
def var i-num-parcelas   like cond-pagto.num-parcelas no-undo.
def var c-status         as char no-undo.
def var c-bairro         like estabelec.bairro no-undo.
def var c-pais           like estabelec.pais no-undo.
def var c-endereco       like estabelec.endereco no-undo.
def var i-ep-codigo      like estabelec.ep-codigo no-undo.
def var i-cep            like estabelec.cep no-undo.
DEF VAR i-cupom          AS INT FORMAT ">,>>>,>>9" NO-UNDO.
def var c-trib-icms      as char no-undo.
def var c-chave          like int_ds_log.chave no-undo.
def var l-servico        as logical no-undo.
def var c-aux            as char no-undo.
DEFINE VARIABLE v-row-loja-cond-pag AS ROWID       NO-UNDO.
DEFINE VARIABLE v-row-classif-fisc  AS ROWID       NO-UNDO.
DEF VAR c-uf-origem AS CHAR.
DEF VAR c-uf-destino AS CHAR.
def var c-natur-ent AS CHAR.
def var c-orgao AS CHAR.
def var c-categoria AS CHAR.
DEF VAR c-prog-log AS CHAR NO-UNDO.
DEF VAR c-sistema-lj AS CHAR NO-UNDO.

def var c-tp-pedido as char no-undo.
def var d-dt-procfit as date no-undo.

function TrataNuloChar returns char
    (input pc-string as char):

    if pc-string = ? then return "".
    else return trim(pc-string).
    
end.

function TrataNuloDec returns decimal
    (input pc-dec as decimal):

    if pc-dec = ? then return 0.
    else return pc-dec.
    
end.
