/*******************************************************************************
**
**  CDAPI013.I - Defini‡Æo das temp-tables da Avalia‡Æo de Cr‚dito
**               Janeiro de 1999 - Andr‚ Peres
**
*******************************************************************************/

define temp-table tt-param-aval no-undo
    field nr-pedido     like ped-venda.nr-pedido
    field param-aval    as integer
    field cod-sit-aval  as integer
    field embarque      as logical
    field efetiva       as logical
    field retorna       as logical
    field reavalia-forc as logical
    field vl-a-avaliar  as decimal
    field saldo-lim     as decimal
    field usuario       as character
    field programa      as character
    index codigo is unique primary nr-pedido.

define temp-table tt-erros-aval no-undo
    field cod-emitente as integer
    field cd-erro      as integer
    index codigo is unique primary cod-emitente cd-erro.

/* Procedures e Funcoes Gerais */

Procedure pi-msg-aval.

   def input param i-cod-mensagem as integer no-undo.

   find  tt-erros-aval
         where tt-erros-aval.cod-emitente = emitente.cod-emitente
         and   tt-erros-aval.cd-erro      = i-cod-mensagem
         no-lock no-error.

   if  not avail tt-erros-aval then do:       
       create tt-erros-aval. 
       assign tt-erros-aval.cod-emitente = emitente.cod-emitente
              tt-erros-aval.cd-erro      = i-cod-mensagem.
   end.

End Procedure.


/** Documenta‡Æo das temp-tables

TT-PARAM-AVAL
   nr-pedido....: c¢digo do pedido em questÆo
   param-aval...: parametro de avaliacao (1 - Atraso, 2 - Limite, 3 - Ambos)
   cod-sit-aval.: situacao do pedido avaliado
   embarque.....: Avaliacao sendo feita no embarque (Faturamento) ou Imp.Pedido
   efetiva......: Efetiva a avaliacao de credito ou apenas faz simulacao
   retorna......: retorna logo apos a primeira ocorrencia encontrada ou nao
   reavalia-forc: Avalia Pedidos aprovados de maneira forcada
   vl-a-aval....: valor a ser abatido do credito do cliente
   saldo-lim....: Armazena o saldo do limite de credito sem o pedido em questao
   usuario......: Usuario corrente 
   programa.....: Programa que chamou a API
TT-ERROS-AVAL
   cd-erro...: Motivo para nao aprovacao do credito do cliente
               Hoje existem 14 testes listados abaixo (com numero da MSG EMS):
               01. 4084: nr meses inativo
               02. 4085: nr meses inativo (MP)
               03. 4086: Atraso de pagamento nos ultimos "x" meses
               04. 4087: Atraso de pagamento nos ultimos "x" meses (MP)
               05. 4088: Valor excedido para titulos de Aviso de Debito
               06. 4089: Valor excedido para titulos de Aviso de Debito (MP)
               07. 4090: Valor excedido para duplicatas normais
               08. 4091: Valor excedido para duplicatas normais (MP)
               09. 4092: Data do limite de credito vencida
               10. 4097: Valor do limite de credito nao pode ser 0 (Zero)
               11. 4093: Cliente excedeu seu LC sem considerar o pedido em questao
               12. 4094: Cliente excedeu seu LC sem considerar o pd. em questao (MP)
               13. 4095: Cliente excedeu seu LC com o pedido em questao
               14. 8464: Cliente possui cheque devolvido
**/

/* CDAPI013.I */
