/* utils/getTipoAcrTransacao.p

   Verifica o movimento do titulo a receber:
   retorna 1 se for para manter o valor do movimento (CR),
          -1 se for para inverter (DB) e
           0 quando nao interfere no saldo
*/           

def input param c-trans-acr-abrev like movto_tit_acr.ind_trans_acr_abrev no-undo.
def output param i-retorno as integer no-undo init 0.

if lookup(c-trans-acr-abrev,
          'AVCR,AVMN,DEV,EREN,ESTT,EVDB,EVMA,LIQ,LQEC,LQRN,LQTE') > 0 then
    assign i-retorno = -1.
else
if lookup(c-trans-acr-abrev,
          'AVDB,AVMA,ELIQ,ELQR,ELQT,ETRE,EVCR,EVMN,IMCR,IMDB,' +
          'IMPL,REN,TRES,CVAL,CVLL,ECLQ,ECVL') > 0 then
    assign i-retorno = 1.

/* end */

/* tipos de transacoes 

+  AVDB    "Acerto Valor a D‚bito",
+  AVMA    "Acerto Valor a Maior",
+  ELIQ    "Estorno de Liquidacao",
+  ELQR    "Estorno Liquid Renegociac",
+  ELQT    "Estorno Liquid Transf Estab",
+  ETRE    "Estorno Transf Estab",
+  EVCR    "Estorno Acerto Val Cr‚dito",
+  EVMN    "Estorno Acerto Val Menor",
+  IMCR    "Implanta‡Æo a Cr‚dito",
+  IMDB    "Implanta‡Æo a Debito",
+  IMPL    "Implanta‡Æo",
+  REN    "Renegocia‡Æo",
+  TRES    "Transf Estabelecimento",
+- CVAL    "Corre‡Æo de Valor", 
+- CVLL    "Corre‡Æo Valor na Liquidac",
+- ECLQ    "Estorno Corre‡Æo Val Liquidac",
+- ECVL    "Estorno Corre‡Æo Valor",
-  AVCR    "Acerto Valor a Cr‚dito",
-  AVMN    "Acerto Valor a Menor",
-  DEV     "Devolu‡Æo",
-  EREN    "Estorno Renegocia‡Æo",
-  ESTT    "Estorno de T¡tulo",
-  EVDB    "Estorno Acerto Val D‚bito",
-  EVMA    "Estorno Acerto Val Maior",
-  LIQ    "Liquida‡Æo",
-  LQEC    "Liquida‡Æo Enctro Ctas",
-  LQRN    "Liquida‡Æo Renegociac",
-  LQTE    "Liquida‡Æo Transf Estab",
=  ADEM    "Altera‡Æo Data EmissÆo",
=  ADVN    "Altera‡Æo Data Vencimento",
=  ALNC    "Altera‡Æo nÆo Cont bil",
=  DCTO    "Desconto Banc rio",
=  DESF    "Despesa Financeira",
=  EDCT    "Estorno Desconto Banc rio",
=  EDES    "Estorno Desp Financeira"
=  ETUN    "Estorno Transf Unid Negoc",
=  LQPD    "Liquida‡Æo Perda Dedut¡vel",
=  TRUN    "Transf Unidade Neg¢cio"

  
    >> nao identificados (na consultoria nao constava esses tipos)
    "Liquida‡Æo Subst",
    "Estorno Liquidacao Subst",
    "Devolu‡Æo de Cheque",
    "Reintegra‡Æo Perda Dedut¡vel",
    "Subst Nota por Duplicata",
    "Estorno Subst Nota Dupl",
*/
