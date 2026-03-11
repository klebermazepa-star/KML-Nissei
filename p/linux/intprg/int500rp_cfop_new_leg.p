/******************************************************************************/
{include/i-prgvrs.i int500RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: int500RP
**
**       DATA....: 11/2015
**
**       OBJETIVO: Integra‡Æo NDD - XML Recebimento 
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/

{include/i-rpvar.i}
{include/i-rpcab.i}
{utp/ut-glob.i}

{intprg/int002b.i}
{intprg/int500.i}

CREATE WIDGET-POOL.
    
DEFINE TEMP-TABLE tt-cfop NO-UNDO
FIELD cod-cfop LIKE int-ds-it-docto-xml.cfop
FIELD indice   AS INTEGER.

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

DEFINE TEMP-TABLE tt-digita NO-UNDO
    FIELD arquivo AS CHAR
    FIELD raiz    AS CHAR 
    FIELD node    AS CHAR
    FIELD campo   AS CHAR FORMAT "X(100)"
    FIELD valor   AS CHAR FORMAT "X(100)"
    FIELD linha   AS INTEGER.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param NO-ERROR.

IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "INT002brp.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME
           tt-param.dt-trans-ini    = 07/15/2016 
           tt-param.dt-trans-fin    = TODAY 
           tt-param.i-nro-docto-ini = "0"  
           tt-param.i-nro-docto-fin = "999999999" 
           tt-param.i-cod-emit-ini  = 0 
           tt-param.i-cod-emit-fin  = 999999999. 
           

for each tt-raw-digita:
    create tt-digita.
    raw-transfer tt-raw-digita.raw-digita to tt-digita NO-ERROR.
end.

def var c-acompanha     as char    no-undo.
DEF VAR h-acomp    AS HANDLE  NO-UNDO.
DEF VAR c-nom-arq  AS CHAR    NO-UNDO.
DEF VAR c-data     AS CHAR    NO-UNDO.
DEF VAR i-seq-item AS INTEGER NO-UNDO.
DEF VAR c-comando  AS CHAR    NO-UNDO.
DEF VAR c-lista    AS CHAR INITIAL "1,2,3,4,5,6,7,8,9,10".
DEF VAR i-cont     AS INTEGER.
DEF VAR i-linha    AS INTEGER.
DEF VAR l-altera   AS LOGICAL INITIAL NO.
DEF VAR l-valida   AS LOGICAL INITIAL NO.
DEF VAR dt-ini         AS DATE FORMAT "99/99/9999".
DEF VAR de-fator       AS DECIMAL NO-UNDO.
DEF VAR l-gera-nota    AS LOGICAL NO-UNDO. 
DEF VAR L-GRAVA        AS LOGICAL NO-UNDO.
DEF VAR h-niveis       AS HANDLE  NO-UNDO.
DEF VAR c-item-do-forn AS CHAR    NO-UNDO.
DEF VAR c-nat-operacao AS CHAR    NO-UNDO.
DEF VAR c-cfop         AS CHAR    NO-UNDO.
DEF VAR l-estab        AS LOGICAL NO-UNDO.
DEF VAR c-estab-orig   LIKE estabelec.cod-estabel.
DEF VAR c-estab-dest   LIKE estabelec.cod-estabel.

DEF VAR i-orig-icms    like  int-ds-it-docto-xml.orig-icms. 
DEF VAR i-cst-icms     like  int-ds-it-docto-xml.cst-icms. 
DEF VAR i-modBC        like  int-ds-it-docto-xml.modBC.     
DEF VAR i-modbcst      like  int-ds-it-docto-xml.modbcst.   
DEF VAR de-vbc-icms    like  int-ds-it-docto-xml.vbc-icms.  
DEF VAR de-picms       like  int-ds-it-docto-xml.picms.     
DEF VAR de-vicms       like  int-ds-it-docto-xml.vicms.     
DEF VAR de-pmvast      like  int-ds-it-docto-xml.pmvast.    
DEF VAR de-vbcst       like  int-ds-it-docto-xml.vbcst.     
DEF VAR de-picmsst     like  int-ds-it-docto-xml.picmsst.   
DEF VAR de-vicmsst     like  int-ds-it-docto-xml.vicmsst.   
DEF VAR de-vbcstret    like  int-ds-it-docto-xml.vbcstret.  
DEF VAR de-vicmsstret  like  int-ds-it-docto-xml.vicmsstret.
DEF VAR de-vicmsDeson  like  int-ds-it-docto-xml.vicmsstret.
DEF VAR de-aliq-pis    LIKE  int-ds-it-docto-xml.ppis.
DEF VAR de-aliq-cofins LIKE int-ds-it-docto-xml.pcofins.
DEF VAR de-tot-bicms   LIKE it-nota-fisc.vl-bicms-it.
DEF VAR de-tot-icms    LIKE it-nota-fisc.vl-icms-it.
DEF VAR de-tot-bsubs   LIKE it-nota-fisc.vl-bsubs-it.
DEF VAR de-tot-icmst   LIKE it-nota-fisc.vl-icmsub-it.
DEF VAR de-predbc-icms LIKE it-nota-fisc.perc-red-icm no-undo.
DEF VAR de-pRedBCST    like it-nota-fisc.perc-red-icm no-undo.
DEF VAR de-tot-pis     LIKE  int-ds-docto-xml.valor-pis no-undo.       
DEF VAR de-tot-cofins  LIKE  int-ds-docto-xml.valor-cofins no-undo.
     
DEF VAR i-num-pedido  AS     INTEGER.
DEF VAR c-doc         AS     LONGCHAR NO-UNDO.


DEF BUFFER b-tt-digita             FOR tt-digita.
DEF BUFFER b-int-ds-it-docto-xml   FOR int-ds-it-docto-xml.
DEF BUFFER b-int-ds-docto-xml      FOR int-ds-docto-xml. 
DEF BUFFER b-NDD_ENRYINTEGRATION_new_leg  FOR NDD_ENRYINTEGRATION_new_leg. 
DEF BUFFER b-estab                 FOR estabelec.

find first param-global no-lock no-error.
find first mgadm.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "INT500rp"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Integra‡Æo_Notas_Danf-e * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Recebimento * L}
assign c-sistema = trim(return-value).

view frame f-cabec.
view frame f-rodape.

/* FIND FIRST int-ds-param-xml NO-LOCK where
           int-ds-param-xml.ep-codigo = int(i-ep-codigo-usuario) NO-ERROR.
IF NOT AVAIL int-ds-param-xml THEN NEXT.
*/

IF CAN-FIND(FIRST tt-digita) 
THEN DO:
    
   ASSIGN l-altera = YES.
   
   FIND FIRST tt-digita NO-ERROR.
   FIND FIRST int-ds-it-docto-xml NO-LOCK WHERE
              ROWID(int-ds-it-docto-xml) = TO-ROWID(tt-digita.valor) NO-ERROR.
   IF AVAIL int-ds-it-docto-xml THEN DO:

      FIND FIRST int-ds-docto-xml WHERE
                 int-ds-docto-xml.tipo-nota    = int-ds-it-docto-xml.tipo-nota    AND 
                 int-ds-docto-xml.CNPJ         = int-ds-it-docto-xml.CNPJ         AND
                 int-ds-docto-xml.cod-emitente = int-ds-it-docto-xml.cod-emitente AND  
                 int(int-ds-docto-xml.nNF)     = int(int-ds-it-docto-xml.nNF)     AND
                 int-ds-docto-xml.serie        = int-ds-it-docto-xml.serie NO-ERROR.
      IF AVAIL int-ds-docto-xml THEN DO: 
         
         CREATE tt-docto-xml.
         BUFFER-COPY int-ds-docto-xml TO tt-docto-xml.

      END.
      
      IF tt-digita.campo = "item" 
      THEN DO:
         CREATE tt-it-docto-xml.
         BUFFER-COPY int-ds-it-docto-xml TO tt-it-docto-xml.
      END.   
      ELSE DO:
          FOR EACH int-ds-it-docto-xml WHERE 
                    int-ds-it-docto-xml.serie         =  int-ds-docto-xml.serie         AND
                    int(int-ds-it-docto-xml.nNF)      =  int(int-ds-docto-xml.nNF)      AND
                    int-ds-it-docto-xml.cod-emitente  =  int-ds-docto-xml.cod-emitente  AND
                    int-ds-it-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota query-tuning(no-lookahead):   
              CREATE tt-it-docto-xml.
              BUFFER-COPY int-ds-it-docto-xml TO tt-it-docto-xml.
          END.
      END.
   END.

   RELEASE int-ds-it-docto-xml.

END.
ELSE DO:

  run utp/ut-acomp.p persistent set h-acomp.
  {utp/ut-liter.i Integra‡Æo_Notas_Danf-e * L}
  run pi-inicializar in h-acomp (input return-value).
    
END.

DEF VAR h-boin176         AS HANDLE.
   
RUN inbo/boin176.p PERSISTENT SET h-boin176. /*  calcula fator de conversÆo */

IF l-altera = NO 
THEN DO:

   RUN pi-IntegracaoNDD.
   RUN pi-valida-nota.

   empty temp-table tt-docto-xml.
   empty temp-table tt-xml-dup.
   empty temp-table tt-it-docto-xml.

   ASSIGN l-altera = YES.
   RUN pi-notas-pepsico. /* Fazer a valida‡Æo das notas geradas da Pepsico */

END.
else DO:

  run pi-grava-nota. 

END.
 
IF VALID-HANDLE(h-boin176) THEN
       DELETE PROCEDURE h-boin176.

DELETE WIDGET-POOL.

procedure pi-grava-nota:       
    /* Procedure para gravar intds-docto-xml p/ CD e int-ds-nota-entrada p/ lojas */
    DEF VAR de-tot-quantidade         LIKE int-ds-it-docto-xml.qCom.
    DEF VAR de-tot-base-ipi           LIKE int-ds-it-docto-xml.vbc-ipi.
    DEF VAR de-tot-vlr-ipi            LIKE int-ds-it-docto-xml.vipi. 
    DEF VAR de-tot-base-icms-isento   LIKE int-ds-it-docto-xml.vbc-icms.
    DEF VAR de-tot-base-icms-diferido LIKE int-ds-it-docto-xml.vbc-icms.
    DEF VAR de-vl-liquido             LIKE it-nota-fisc.vl-merc-liq.
    DEF VAR i-cfop                    LIKE tt-it-docto-xml.cfop.
    DEF VAR i-num-pedido              LIKE tt-it-docto-xml.num-pedido. 
    DEF VAR c-item-do-forn            AS CHAR.
    DEF VAR c-it-codigo               AS CHAR.

    find first tt-param no-error.      
    /* tratar notas de entrada nas lojas */
    FOR EACH tt-docto-xml WHERE
             tt-docto-xml.dEmi         >= tt-param.dt-trans-ini    AND 
             tt-docto-xml.dEmi         <= tt-param.dt-trans-fin    AND 
             tt-docto-xml.NNF          >= tt-param.i-nro-docto-ini AND 
             tt-docto-xml.NNF          <= tt-param.i-nro-docto-fin AND
             tt-docto-xml.cod-emitente >= tt-param.i-cod-emit-ini  AND 
             tt-docto-xml.cod-emitente <= tt-param.i-cod-emit-fin  AND 
             tt-docto-xml.tipo-estab    = 2 /* Loja */    
        BREAK BY tt-docto-xml.arquivo :  

        ASSIGN de-tot-quantidade = 0
               de-tot-base-ipi   = 0
               de-tot-vlr-ipi    = 0
               de-tot-base-icms-isento   = 0
               de-tot-base-icms-diferido = 0
               i-num-pedido             = 0.


        DISPLAY tt-docto-xml.CNPJ
                tt-docto-xml.serie
                tt-docto-xml.NNF
                tt-docto-xml.cod-emitente
            WITH WIDTH 300 STREAM-IO.
                

        for first int-ds-nota-entrada where 
            int-ds-nota-entrada.nen-cnpj-origem-s = tt-docto-xml.CNPJ      and
            int-ds-nota-entrada.nen-serie-s       = tt-docto-xml.serie     and  
            int-ds-nota-entrada.nen-notafiscal-n  = int(tt-docto-xml.nnf): end.
        if NOT avail int-ds-nota-entrada then next.
        if int-ds-nota-entrada.nen-conferida-n = 2 then next.

        i-cfop = 0.
        for each tt-it-docto-xml where 
                 tt-it-docto-xml.tipo-nota  = tt-docto-xml.tipo-nota AND
                 tt-it-docto-xml.CNPJ       = tt-docto-xml.CNPJ      AND
                 tt-it-docto-xml.nNF        = tt-docto-xml.nNF       AND
                 tt-it-docto-xml.serie      = tt-docto-xml.serie
            break by tt-it-docto-xml.CNPJ       
                  by tt-it-docto-xml.serie         
                  by tt-it-docto-xml.nNF
                  by tt-it-docto-xml.item-do-forn:

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
            else
               assign c-it-codigo = tt-it-docto-xml.it-codigo.

            if tt-it-docto-xml.lote = ? then tt-it-docto-xml.lote = "".
            for first int-ds-nota-entrada-produto where 
                      int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                      int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                      int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                      int-ds-nota-entrada-produto.nep-sequencia-n   = tt-it-docto-xml.sequencia      and 
                      int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and
                      int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and
                      int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:          END.

            if not avail int-ds-nota-entrada-produto 
            then 
                for first int-ds-nota-entrada-produto where 
                          int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                          int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                          int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                          /*int-ds-nota-entrada-produto.nep-sequencia-n   = tt-it-docto-xml.sequencia      and */
                          int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and
                          int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and
                          int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:          end.
          if not avail int-ds-nota-entrada-produto 
          then 
              for first int-ds-nota-entrada-produto where 
                        int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                        int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                        int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                        /*int-ds-nota-entrada-produto.nep-sequencia-n   = tt-it-docto-xml.sequencia      and */
                        /*int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and*/
                        int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and
                        int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:          end.

            if not avail int-ds-nota-entrada-produto 
            then 
                for first int-ds-nota-entrada-produto where 
                          int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                          int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                          int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                          /*int-ds-nota-entrada-produto.nep-sequencia-n   = tt-it-docto-xml.sequencia      and */
                          /*int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and*/
                          int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and
                          /*int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:       and*/          
                          int-ds-nota-entrada-produto.nep-valorbruto-n          = tt-it-docto-xml.vProd:         END.

              if not avail int-ds-nota-entrada-produto 
              then 
                  for first int-ds-nota-entrada-produto where 
                            int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                            int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                            int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                            int-ds-nota-entrada-produto.nep-sequencia-n   = tt-it-docto-xml.sequencia      and 
                            /*int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and*/
                            /*int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and*/
                            /*int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:       and*/          
                            int-ds-nota-entrada-produto.nep-valorbruto-n          = tt-it-docto-xml.vProd:         END.
              if not avail int-ds-nota-entrada-produto 
              then 
                 for first int-ds-nota-entrada-produto where 
                           int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                           int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                           int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                           int-ds-nota-entrada-produto.nep-sequencia-n   = (tt-it-docto-xml.sequencia / 10)   and 
                           int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and
                           int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and
                           int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:          END.
          
              if not avail int-ds-nota-entrada-produto 
              then 
                  for first int-ds-nota-entrada-produto where 
                            int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                            int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                            int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                            int-ds-nota-entrada-produto.nep-sequencia-n   = (tt-it-docto-xml.sequencia / 10)      and 
                            /*int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and*/
                            /*int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and*/
                            /*int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:       and*/          
                            int-ds-nota-entrada-produto.nep-valorbruto-n          = tt-it-docto-xml.vProd:         END.

            if not avail int-ds-nota-entrada-produto 
            then 
                for first int-ds-nota-entrada-produto where 
                          int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                          int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                          int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                          /*int-ds-nota-entrada-produto.nep-sequencia-n   = tt-it-docto-xml.sequencia      and */
                          /*int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and*/
                          int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and
                          /*int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:       and*/          
                          int-ds-nota-entrada-produto.nep-valorliquido-n          = (tt-it-docto-xml.vprod - tt-it-docto-xml.vDesc):         END.

              if not avail int-ds-nota-entrada-produto 
              then 
                  for first int-ds-nota-entrada-produto where 
                            int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                            int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                            int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                            int-ds-nota-entrada-produto.nep-sequencia-n   = tt-it-docto-xml.sequencia      and 
                            /*int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and*/
                            /*int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and*/
                            /*int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:       and*/          
                            int-ds-nota-entrada-produto.nep-valorliquido-n          = (tt-it-docto-xml.vprod - tt-it-docto-xml.vDesc):         END.

              if not avail int-ds-nota-entrada-produto 
              then 
                  for first int-ds-nota-entrada-produto where 
                            int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                            int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                            int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                            int-ds-nota-entrada-produto.nep-sequencia-n   = (tt-it-docto-xml.sequencia / 10)      and 
                            /*int-ds-nota-entrada-produto.nep-produto-n     = int(c-it-codigo)               and*/
                            /*int-ds-nota-entrada-produto.alternativo-fornecedor  = tt-it-docto-xml.item-do-forn and*/
                            /*int-ds-nota-entrada-produto.nep-lote-s        = tt-it-docto-xml.lote:       and*/          
                            int-ds-nota-entrada-produto.nep-valorliquido-n          = (tt-it-docto-xml.vprod - tt-it-docto-xml.vDesc):         END.

            IF AVAIL int-ds-nota-entrada-produto THEN
            ASSIGN int-ds-nota-entrada-produto.nen-cfop-n             = tt-it-docto-xml.cfop          
                   int-ds-nota-entrada-produto.nep-csta-n             = tt-it-docto-xml.orig-icms  /* nacional 0 importado 1 */ 
                   int-ds-nota-entrada-produto.nep-cstb-icm-n         = /*tt-it-docto-xml.vbcst*/ tt-it-docto-xml.cst-icm
                   int-ds-nota-entrada-produto.nep-cstb-ipi-n         = /*tt-it-docto-xml.vbc-ipi*/ tt-it-docto-xml.cst-ipi
                   int-ds-nota-entrada-produto.nep-valordespesa-n     = int-ds-nota-entrada-produto.nep-valordespesa-n    +  tt-it-docto-xml.vOutro
                   int-ds-nota-entrada-produto.nep-basepis-n          = int-ds-nota-entrada-produto.nep-basepis-n         +  tt-it-docto-xml.vbc-pis
                   int-ds-nota-entrada-produto.nep-valorpis-n         = int-ds-nota-entrada-produto.nep-valorpis-n        +  tt-it-docto-xml.vpis  
                   int-ds-nota-entrada-produto.nep-basecofins-n       = int-ds-nota-entrada-produto.nep-basecofins-n      +  tt-it-docto-xml.vbc-cofins       
                   int-ds-nota-entrada-produto.nep-valorcofins-n      = int-ds-nota-entrada-produto.nep-valorcofins-n     +  tt-it-docto-xml.vcofins
                   int-ds-nota-entrada-produto.nep-valor-icms-des-n   = int-ds-nota-entrada-produto.nep-valor-icms-des-n  +  tt-it-docto-xml.vicmsdeson.

            ELSE DO:
                for FIRST int-ds-nota-entrada-produto where 
                          int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                          int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                          int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                          int-ds-nota-entrada-produto.nep-sequencia-n   = (tt-it-docto-xml.sequencia / 10): END.
                IF NOT AVAIL int-ds-nota-entrada-produto THEN
                    for FIRST int-ds-nota-entrada-produto where 
                              int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                              int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                              int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF)       and 
                              int-ds-nota-entrada-produto.nep-sequencia-n   = tt-it-docto-xml.sequencia: END.


                IF AVAIL int-ds-nota-entrada-produto THEN
                    ASSIGN int-ds-nota-entrada-produto.nen-cfop-n             = tt-it-docto-xml.cfop          
                           int-ds-nota-entrada-produto.nep-csta-n             = tt-it-docto-xml.orig-icms  /* nacional 0 importado 1 */ 
                           int-ds-nota-entrada-produto.nep-cstb-icm-n         = /*tt-it-docto-xml.vbcst*/ tt-it-docto-xml.cst-icm
                           int-ds-nota-entrada-produto.nep-cstb-ipi-n         = /*tt-it-docto-xml.vbc-ipi*/ tt-it-docto-xml.cst-ipi.
                ELSE DO:
                    for EACH int-ds-nota-entrada-produto where 
                             int-ds-nota-entrada-produto.nen-cnpj-origem-s = tt-it-docto-xml.CNPJ           and 
                             int-ds-nota-entrada-produto.nen-serie-s       = tt-docto-xml.serie             and 
                             int-ds-nota-entrada-produto.nen-notafiscal-n  = int(tt-it-docto-xml.nNF): 
                        ASSIGN int-ds-nota-entrada-produto.nen-cfop-n             = tt-it-docto-xml.cfop          
                               int-ds-nota-entrada-produto.nep-csta-n             = tt-it-docto-xml.orig-icms  /* nacional 0 importado 1 */ 
                               int-ds-nota-entrada-produto.nep-cstb-icm-n         = /*tt-it-docto-xml.vbcst*/ tt-it-docto-xml.cst-icm
                               int-ds-nota-entrada-produto.nep-cstb-ipi-n         = /*tt-it-docto-xml.vbc-ipi*/ tt-it-docto-xml.cst-ipi.
                    END.
                END.

            END.
  
            release int-ds-nota-entrada-produto.

        end. /* tt-it-docto-xml */

    end. /* TT-DOCTO-XML */
end.

{include/i-rpclo.i}   

IF VALID-HANDLE(h-acomp) THEN 
   run pi-finalizar in h-acomp.

return "OK":U.

    

PROCEDURE pi-notas-pepsico:
 
   FOR EACH int-ds-docto-xml NO-LOCK WHERE
            int-ds-docto-xml.tipo-docto = 4 AND 
            int-ds-docto-xml.tipo-estab = 1 AND 
            int-ds-docto-xml.chnfe      = ? query-tuning(no-lookahead):

       /*
         put int-ds-docto-xml.serie        " - "
             int-ds-docto-xml.nNF          " - "
             int-ds-docto-xml.cod-emitente " - "
             int-ds-docto-xml.tipo-nota    " - "
             int-ds-docto-xml.chnfe        " - "
             int-ds-docto-xml.dEmi         skip.
         */
         CREATE tt-docto-xml.
         BUFFER-COPY int-ds-docto-xml TO tt-docto-xml.
         ASSIGN tt-docto-xml.chnfe    = IF int-ds-docto-xml.chnfe    = ? then "" else int-ds-docto-xml.chnfe  
                tt-docto-xml.xnome    = IF int-ds-docto-xml.xnome    = ? then "" else int-ds-docto-xml.xnome
                tt-docto-xml.modFrete = IF int-ds-docto-xml.modFrete = ? then 0 else int-ds-docto-xml.modFrete
                tt-docto-xml.arquivo  = STRING(int-ds-docto-xml.nnf).
                 
         FOR EACH int-ds-it-docto-xml WHERE 
                  int-ds-it-docto-xml.serie         =  int-ds-docto-xml.serie         AND
                  int-ds-it-docto-xml.nNF           =  int-ds-docto-xml.nNF           AND
                  int-ds-it-docto-xml.cod-emitente  =  int-ds-docto-xml.cod-emitente  AND
                  int-ds-it-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota query-tuning(no-lookahead):   
                  
               CREATE tt-it-docto-xml.
               BUFFER-COPY int-ds-it-docto-xml TO tt-it-docto-xml.
               ASSIGN tt-it-docto-xml.arquivo       = STRING(int-ds-docto-xml.nnf)
                      tt-it-docto-xml.xprod         = IF int-ds-it-docto-xml.xprod           = ? then ""   else  int-ds-it-docto-xml.xprod   
                      tt-it-docto-xml.uCom          = if int-ds-it-docto-xml.uCom            = ? then ""   else  int-ds-it-docto-xml.uCom           
                      tt-it-docto-xml.nat-operacao  = if int-ds-it-docto-xml.nat-operacao    = ? then ""   else  int-ds-it-docto-xml.nat-operacao
                      tt-it-docto-xml.qOrdem        = if int-ds-it-docto-xml.qOrdem          = ? then 0    else  int-ds-it-docto-xml.qOrdem        
                      tt-it-docto-xml.vtottrib      = if int-ds-it-docto-xml.vtottrib        = ? then 0    else  int-ds-it-docto-xml.vtottrib      
                      tt-it-docto-xml.vbc-icms      = if int-ds-it-docto-xml.vbc-icms        = ? then 0    else  int-ds-it-docto-xml.vbc-icms      
                      tt-it-docto-xml.picms         = if int-ds-it-docto-xml.picms           = ? then 0    else  int-ds-it-docto-xml.picms         
                      tt-it-docto-xml.pmvast        = if int-ds-it-docto-xml.pmvast          = ? then 0    else  int-ds-it-docto-xml.pmvast        
                      tt-it-docto-xml.vbcst         = if int-ds-it-docto-xml.vbcst           = ? then 0    else  int-ds-it-docto-xml.vbcst         
                      tt-it-docto-xml.picmsst       = if int-ds-it-docto-xml.picmsst         = ? then 0    else  int-ds-it-docto-xml.picmsst       
                      tt-it-docto-xml.vicmsst       = if int-ds-it-docto-xml.vicmsst         = ? then 0    else  int-ds-it-docto-xml.vicmsst       
                      tt-it-docto-xml.vbcstret      = if int-ds-it-docto-xml.vbcstret        = ? then 0    else  int-ds-it-docto-xml.vbcstret      
                      tt-it-docto-xml.vicmsstret    = if int-ds-it-docto-xml.vicmsstret      = ? then 0    else  int-ds-it-docto-xml.vicmsstret    
                      tt-it-docto-xml.ppis          = if int-ds-it-docto-xml.ppis            = ? then 0    else  int-ds-it-docto-xml.ppis          
                      tt-it-docto-xml.pipi          = if int-ds-it-docto-xml.pipi            = ? then 0    else  int-ds-it-docto-xml.pipi          
                      tt-it-docto-xml.pcofins       = if int-ds-it-docto-xml.pcofins         = ? then 0    else  int-ds-it-docto-xml.pcofins       
                      tt-it-docto-xml.orig-icms     = if int-ds-it-docto-xml.orig-icms       = ? then 0    else  int-ds-it-docto-xml.orig-icms     
                      tt-it-docto-xml.ncm           = if int-ds-it-docto-xml.ncm             = ? then 0    else  int-ds-it-docto-xml.ncm           
                      tt-it-docto-xml.item-do-forn  = if TRIM(int-ds-it-docto-xml.item-do-forn)    = ? then ""   else  trim(int-ds-it-docto-xml.item-do-forn)
                      tt-it-docto-xml.uCom-forn     = if int-ds-it-docto-xml.uCom-forn       = ? then ""   else  int-ds-it-docto-xml.uCom-forn     
                      tt-it-docto-xml.qCom-forn     = if int-ds-it-docto-xml.qCom-forn       = ? then 0    else  int-ds-it-docto-xml.qCom-forn  
                      tt-it-docto-xml.narrativa     = if int-ds-it-docto-xml.narrativa       = "0" then "" else  int-ds-it-docto-xml.narrativa
                      tt-it-docto-xml.lote          = if int-ds-it-docto-xml.lote            = ? then ""   else  int-ds-it-docto-xml.lote.      
                                            
         END. 
         /* gravar int-ds-docto-xml e int-ds-nota-entrada */
         run pi-grava-nota. 
   END. /* int-ds-docto-xml */
END.

PROCEDURE pi-IntegracaoNDD:

    DEF VAR c-xml       AS CHAR     NO-UNDO.
    DEF VAR c-arquivo   AS CHAR     NO-UNDO.
    DEF VAR h-documento AS HANDLE   NO-UNDO.
    DEF VAR h-raiz      AS HANDLE   NO-UNDO.
    DEF VAR c-arq-log   AS CHAR     NO-UNDO. 

    /* ASSIGN c-arq-log = session:TEMP-DIRECTORY + "log-int002rpb-nfe-normal-nfe.txt". 
              
    log-manager:logfile-name= c-arq-log.
    log-manager:log-entry-types= "4gltrace".
      */

    DEF VAR pXMLResult  AS LONGCHAR NO-UNDO. 

    FOR EACH NDD_ENRYINTEGRATION_new_leg NO-LOCK  WHERE  
             NDD_ENRYINTEGRATION_new_leg.kind    = 0 /* Envio */  AND
             NDD_ENRYINTEGRATION_new_leg.STATUS_ = 5
        BY NDD_ENRYINTEGRATION_new_leg.ENTRYINTEGRATION_new_legID DESC
        query-tuning(no-lookahead)
        ON ERROR UNDO, NEXT:

        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Processando: " + string(NDD_ENRYINTEGRATION_new_leg.ENTRYINTEGRATION_new_legID)).
     
        /*IF NDD_ENRYINTEGRATION_new_leg.serie = 10 THEN NEXT. - e OS FORNECEDORES COM SRIE 10???*/
        /* NOTAS DO CD ENTRAM PELO int011 baseado em int-ds-nota-saida */
        if can-find (first estabelec no-lock where estabelec.cgc = STRING(NDD_ENRYINTEGRATION_new_leg.CNPJEMIT) and
                     estabelec.cod-estabel = "973") then do transaction:
            for first b-NDD_ENRYINTEGRATION_new_leg where 
                    rowid(b-NDD_ENRYINTEGRATION_new_leg) = rowid(NDD_ENRYINTEGRATION_new_leg) 
                query-tuning(no-lookahead):
                assign b-NDD_ENRYINTEGRATION_new_leg.status_ = 1.     
                release b-NDD_ENRYINTEGRATION_new_leg.
            end.
            next.
        end.

        empty temp-table tt-docto-xml.
        empty temp-table tt-it-docto-xml.
        empty temp-table tt-xml-dup.
        EMPTY TEMP-TABLE tt-digita.

        COPY-LOB FROM NDD_ENRYINTEGRATION_new_leg.documentdata TO pXMLResult.
        IF pXMLResult = "" OR
           pXMLResult = ?  THEN DO:
            for first b-NDD_ENRYINTEGRATION_new_leg where 
                    rowid(b-NDD_ENRYINTEGRATION_new_leg) = rowid(NDD_ENRYINTEGRATION_new_leg) 
                query-tuning(no-lookahead):
                assign b-NDD_ENRYINTEGRATION_new_leg.status_ = 1.     
                release b-NDD_ENRYINTEGRATION_new_leg.
            end.
            next.
        END.

        ASSIGN c-doc = pXMLResult
               c-xml = SESSION:TEMP-DIRECTORY + "xml_temp" + string(NDD_ENRYINTEGRATION_new_leg.ENTRYINTEGRATION_new_legID) +  ".xml".
                           
        IF SEARCH(c-xml) <> ? THEN
           os-delete value(c-xml) no-wait no-console.  
                           
        RUN SaveXML(INPUT c-doc, 
                    INPUT c-xml).
        
        ASSIGN i-linha = 0.

        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Integracao :" + STRING(NDD_ENRYINTEGRATION_new_leg.ENTRYINTEGRATION_new_legID)).
             
        /* trata xml - gera tt-docto-xml */
        run pi-abre-xml(INPUT STRING(NDD_ENRYINTEGRATION_new_leg.ENTRYINTEGRATION_new_legID),
                         INPUT c-xml).
        
        ASSIGN L-GRAVA = NO.
        FOR FIRST tt-docto-xml: END.
        FIND FIRST ttide no-error.
        IF AVAIL ttide AND 
           tt-docto-xml.dEmi >= 07/15/2016
        THEN do:
            ASSIGN L-GRAVA = YES. 
            /* transferencia para o CD */
            IF ttide.natop BEGINS "Transf" 
            THEN do:
                l-grava = no.
            END. /* transferencia */
            IF L-GRAVA THEN run pi-grava-nota.
            for first b-NDD_ENRYINTEGRATION_new_leg EXCLUSIVE where 
                rowid(b-NDD_ENRYINTEGRATION_new_leg) = rowid(NDD_ENRYINTEGRATION_new_leg) 
                query-tuning(no-lookahead):
                if  int(tt-docto-xml.nNF)       <> ? and
                    int(tt-docto-xml.serie)     <> ? and
                    tt-docto-xml.dEmi           <> ? and
                    dec(tt-docto-xml.CNPJ)      <> ? and
                    dec(tt-docto-xml.CNPJ-dest) <> ? then do:
                    assign b-NDD_ENRYINTEGRATION_new_leg.documentnumber   = int(tt-docto-xml.nNF)
                           b-NDD_ENRYINTEGRATION_new_leg.SERIE            = int(tt-docto-xml.serie)  
                           b-NDD_ENRYINTEGRATION_new_leg.EMISSIONDATE     = tt-docto-xml.dEmi
                           b-NDD_ENRYINTEGRATION_new_leg.CNPJEMIT         = dec(tt-docto-xml.CNPJ)
                           b-NDD_ENRYINTEGRATION_new_leg.CNPJDEST         = dec(tt-docto-xml.CNPJ-dest)
                           no-error.
                end.
                assign b-NDD_ENRYINTEGRATION_new_leg.status_ = 1.     
                release b-NDD_ENRYINTEGRATION_new_leg.
            end.
        END.

        IF SEARCH(c-xml) <> ? THEN
           os-delete value(c-xml) no-wait no-console.
           
        IF VALID-HANDLE(h-documento) THEN
            DELETE OBJECT h-documento.

        IF VALID-HANDLE(h-raiz) THEN
            DELETE OBJECT h-raiz.

        IF VALID-HANDLE(h-niveis) THEN
            DELETE OBJECT h-niveis.
    END. 
    
    /* log-manager:close-log(). */

END PROCEDURE.

PROCEDURE SaveXML:
    DEFINE INPUT PARAMETER pXML  AS LONGCHAR NO-UNDO.
    DEFINE INPUT PARAMETER pFile AS CHAR NO-UNDO.

    DEF VAR hDoc AS HANDLE NO-UNDO.

    CREATE X-DOCUMENT hDoc.
    hDoc:LOAD("LONGCHAR", pXML, FALSE).
    hDoc:SAVE("FILE", pFile).
    DELETE OBJECT hDoc.


END PROCEDURE.

PROCEDURE pi-valida-nota:
    

    /* FOR EACH tt-docto-xml WHERE    
             tt-docto-xml.tipo-estab    = 3                        
           BREAK BY tt-docto-xml.arquivo query-tuning(no-lookahead): 

        RUN intprg/int999.p (INPUT "NFENDD", 
                             INPUT string(tt-docto-xml.arquivo) + "-" + string(tt-docto-xml.NNF),
                             INPUT "Documento j  cadastrado",
                             INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                             INPUT c-seg-usuario).
    END. */

END.

   
PROCEDURE pi-abre-xml:

    DEF INPUT PARAMETER p-arquivo AS CHAR.
    DEF INPUT PARAMETER p-xml     AS CHAR.

    EMPTY TEMP-TABLE ttIde.
    EMPTY temp-table ttInfNFe. 
    EMPTY temp-table ttIde.
    EMPTY temp-table ttNFref .
    EMPTY temp-table ttRefNF .
    EMPTY temp-table ttEmit .
    EMPTY temp-table ttEnderEmit .
    EMPTY temp-table ttDest .
    EMPTY temp-table ttEnderDest .
    EMPTY temp-table ttDet .
    EMPTY temp-table ttProd .
    EMPTY temp-table ttDI .
    EMPTY temp-table ttAdi .
    EMPTY temp-table ttVeicProd .
    EMPTY temp-table ttImposto .
    EMPTY temp-table ttIcms .
    EMPTY temp-table ttICMS00. 
    EMPTY temp-table ttICMS10 .
    EMPTY temp-table ttICMS20 .
    EMPTY temp-table ttICMS30 .
    EMPTY temp-table ttICMS40.
    EMPTY temp-table ttICMS51 .
    EMPTY temp-table ttICMS60.
    EMPTY temp-table ttICMS70 .
    EMPTY temp-table ttICMS90.
    EMPTY temp-table ttICMSSN101.
    EMPTY temp-table ttICMSSN102. 
    EMPTY temp-table ttICMSSN201.
    EMPTY temp-table ttICMSSN202.
    EMPTY temp-table ttICMSSN500.
    EMPTY temp-table ttICMSSN900.
    EMPTY temp-table ttIPI.
    EMPTY temp-table ttIPITrib.
    EMPTY temp-table ttIPINT.
    EMPTY temp-table ttII.
    EMPTY temp-table ttPIS.
    EMPTY temp-table ttPISAliq.
    EMPTY temp-table ttPISNT.
    EMPTY temp-table ttPISOutr.
    EMPTY temp-table ttCOFINS.
    EMPTY temp-table ttCOFINSAliq.
    EMPTY temp-table ttCOFINSNT.
    EMPTY temp-table ttCOFINSOutr.
    EMPTY temp-table ttISSQN.
    EMPTY temp-table ttTotal.
    EMPTY temp-table ttICMSTot.
    EMPTY temp-table ttISSQNtot.
    EMPTY temp-table ttRetTrib.
    EMPTY temp-table ttTransp.
    EMPTY temp-table ttTransporta.
    EMPTY temp-table ttVeicTransp.
    EMPTY temp-table ttReboque.
    EMPTY temp-table ttVol.
    EMPTY temp-table ttCobr. 
    EMPTY temp-table ttFat.
    EMPTY temp-table ttDup.
    EMPTY TEMP-TABLE ttInfAdic.
    EMPTY  temp-table ttExporta.
    EMPTY TEMP-TABLE ttmed.
    EMPTY TEMP-TABLE ttinfprot.
    EMPTY TEMP-TABLE ttcompra.

     /*------------------------------------------------------------------------------
     Notes: Ler XML e carregar Dataset
    ------------------------------------------------------------------------------*/
    DEF var cSourceType as char no-undo.
    def var cReadMode as char no-undo.
    def var lOverrideDefaultMapping as log no-undo.
    def var cFile as char no-undo.
    def var cEncoding as char no-undo.
    def var cSchemaLocation as char no-undo.
    def var cFieldTypeMapping as char no-undo.
    def var cVerifySchemaMode as char no-undo.
    def var retOK as log no-undo.
    
    /* inicio processamento XML */
    dataset dsNfe:empty-dataset no-error.
    dataset dsChave:empty-dataset no-error.
    
    assign cSourceType = "FILE"
    cFile = p-xml /* arquivo da nfe - Realiza a leitura do procNFe */
    cReadMode = "empty"
    cSchemaLocation = ?
    lOverrideDefaultMapping = ?
    cFieldTypeMapping = ?
    cVerifySchemaMode = "IGNORE"
    no-error.
    
    assign retOK = dataset dsNfe:read-xml(cSourceType,
    cFile,
    cReadMode,
    cSchemaLocation,
    lOverrideDefaultMapping,
    cFieldTypeMapping,
    cVerifySchemaMode) no-error.
    
    assign retOK = dataset dsChave:read-xml(cSourceType,
    cFile,
    cReadMode,
    cSchemaLocation,
    lOverrideDefaultMapping,
    cFieldTypeMapping,
    cVerifySchemaMode) no-error.
    /* inicio processamento XML */

    /* inicio tratamento tmp-tables geradas pelo XML */
    ASSIGN i-seq-item = 0.
    for first ttIde ON ERROR UNDO, RETURN ERROR:

        CREATE tt-docto-xml.
        ASSIGN tt-docto-xml.arquivo   = p-arquivo
               tt-docto-xml.ep-codigo = int(i-ep-codigo-usuario)
               tt-docto-xml.serie     = string(ttIde.serie).

        IF tt-docto-xml.serie = "" THEN 
           ASSIGN tt-docto-xml.serie = "1". 

        ASSIGN tt-docto-xml.serie = STRING(INT(ttIde.serie)) NO-ERROR.

        IF ERROR-STATUS:ERROR = YES 
        THEN DO:
           DO i-cont = 1 TO LENGTH(string(ttIde.serie)):
              IF LOOKUP(SUBSTRING(string(ttIde.serie),i-cont,1),c-lista) = 0 THEN
                 ASSIGN tt-docto-xml.serie = tt-docto-xml.serie + SUBSTRING(string(ttIde.serie),i-cont,1).  
           END.
        END.

        IF LENGTH(tt-docto-xml.serie) > 3
        THEN DO:
           ASSIGN tt-docto-xml.serie = SUBSTRING(tt-docto-xml.serie,1,3).
        END.
      
        IF LENGTH(TRIM(string(ttIde.nnf))) < 8 THEN
           ASSIGN tt-docto-xml.nNF = STRING(ttIde.nnf,"9999999").
        ELSE 
           ASSIGN tt-docto-xml.nNF = string(ttIde.nnf,"99999999").
      
        
        ASSIGN c-data = SUBSTRING(ttIde.dhEmi,1,10)
               c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
               tt-docto-xml.dEmi       = DATE(c-data)
               tt-docto-xml.dt-trans   = TODAY
               tt-docto-xml.tipo-docto = 1.
                
        /* emitente do documento */
        for first ttEmit:
           
           ASSIGN tt-docto-xml.CNPJ   = STRING(ttEmit.CNPJ). 

           FIND FIRST estabelec NO-LOCK WHERE
                      estabelec.cgc = tt-docto-xml.CNPJ NO-ERROR.
           IF AVAIL estabelec THEN 
              ASSIGN tt-docto-xml.tipo-nota = 3. /* NFT */
              
           FIND FIRST emitente NO-LOCK WHERE 
                      emitente.cgc = trim(tt-docto-xml.cnpj) AND 
                      emitente.cod-emitente > 0  NO-ERROR.
           IF AVAIL emitente THEN 
              ASSIGN tt-docto-xml.cod-emitente = emitente.cod-emitente.

           ASSIGN tt-docto-xml.xNome  = STRING(ttEmit.xNome).
              
        end. /* ttEmit */

        /* destinatario */
        for first ttDest:

             ASSIGN tt-docto-xml.CNPJ-dest   = STRING(ttDest.CNPJ)
                    tt-docto-xml.tipo-estab  = 2.
    
             FIND FIRST estabelec NO-LOCK WHERE 
                        estabelec.cgc = trim(tt-docto-xml.CNPJ-dest) AND 
                        estabelec.cgc <> ""  NO-ERROR.
             IF AVAIL estabelec THEN DO:
                 
                 IF estabelec.cod-estabel = "973" THEN
                    ASSIGN tt-docto-xml.tipo-estab = 1. /* Principal/CD */
                 ELSE 
                    ASSIGN tt-docto-xml.tipo-estab = 2. /* Frente de Loja */
       
                 ASSIGN tt-docto-xml.cod-estab = estabelec.cod-estab
                        tt-docto-xml.ep-codigo = int(estabelec.ep-codigo).
             END.  
             
             IF tt-docto-xml.CNPJ-dest = tt-docto-xml.cnpj  THEN
                ASSIGN tt-docto-xml.tipo-estab = 0. /* Desconsiderar essas notas */  
                        
             FOR FIRST b-int-ds-docto-xml NO-LOCK WHERE
                       b-int-ds-docto-xml.tipo-nota    = tt-docto-xml.tipo-nota    AND 
                       b-int-ds-docto-xml.CNPJ         = tt-docto-xml.CNPJ         AND                             
                       int(b-int-ds-docto-xml.nNF)     = int(tt-docto-xml.nNF)     AND
                       b-int-ds-docto-xml.serie        = tt-docto-xml.serie
                 query-tuning(no-lookahead):
    
             END.
                     
             IF AVAIL b-int-ds-docto-xml THEN
                ASSIGN tt-docto-xml.tipo-estab = 3. /* Documento j  cadastrado na base */

             IF tt-docto-xml.tipo-estab = 2 /* Lj */
             THEN DO:
                   FOR FIRST int-ds-nota-entrada NO-LOCK WHERE
                             int-ds-nota-entrada.nen-cnpj-origem-s = tt-docto-xml.CNPJ     AND 
                             int-ds-nota-entrada.nen-serie-s       = tt-docto-xml.serie    AND 
                             int-ds-nota-entrada.nen-notafiscal-n  = int(tt-docto-xml.nnf) AND 
                             int-ds-nota-entrada.nen-cfop-n        = tt-docto-xml.cfop
                       query-tuning(no-lookahead): END.

                   IF AVAIL int-ds-nota-entrada THEN
                      ASSIGN tt-docto-xml.tipo-estab = 3 /* transferencia j  gerada em loja */.
             END. 
        end. /* ttDest */
    
        /* chave da NFe */
        FOR FIRST ttinfprot : 
            ASSIGN tt-docto-xml.chNfe = ttinfprot.chNfe.
        END.

        /* totais de icms */
        for first ttICMSTot :
       
            ASSIGN tt-docto-xml.VNF            = dec(STRING(ttICMSTot.VNF       )).   
            ASSIGN tt-docto-xml.vbc            = dec(STRING(ttICMSTot.vBC       )).
            ASSIGN tt-docto-xml.tot-desconto   = dec(STRING(ttICMSTot.vDesc     )).
            ASSIGN tt-docto-xml.valor-frete    = dec(STRING(ttICMSTot.vFrete    )).
            ASSIGN tt-docto-xml.valor-mercad   = dec(STRING(ttICMSTot.vProd     )).
            ASSIGN tt-docto-xml.valor-outras   = dec(STRING(ttICMSTot.vOutro    )).
            ASSIGN tt-docto-xml.valor-seguro   = dec(STRING(ttICMSTot.vSeg      )).
            ASSIGN tt-docto-xml.valor-icms     = dec(STRING(ttICMSTot.vICMS     )).
            ASSIGN tt-docto-xml.vbc-cst        = dec(STRING(ttICMSTot.vBCST     )).
            ASSIGN tt-docto-xml.valor-st       = dec(STRING(ttICMSTot.vST       )).
            ASSIGN tt-docto-xml.valor-ii       = dec(STRING(ttICMSTot.vII       )).
            ASSIGN tt-docto-xml.valor-ipi      = dec(STRING(ttICMSTot.vIPI      )).
            ASSIGN tt-docto-xml.valor-pis      = dec(STRING(ttICMSTot.vPIS      )).
            ASSIGN tt-docto-xml.valor-cofins   = dec(STRING(ttICMSTot.vCOFINS   )).
           
        end. /* ttICMSTot */

        for first ttTransp:
            ASSIGN tt-docto-xml.modFrete = ttTransp.modFrete.
        end.

        for first ttCompra:
          ASSIGN i-num-pedido = int(ttCompra.xped) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN
              ASSIGN i-num-pedido = 0.      
        end.
        ASSIGN de-tot-pis     = 0 
               de-tot-cofins  = 0.

        /* itens da nota */
        FOR EACH ttprod 
            BY ttprod.nitem:
                    
           ASSIGN i-seq-item = i-seq-item + 10.
           IF i-num-pedido = 0 THEN DO:
               ASSIGN i-num-pedido = int(ttprod.xped) NO-ERROR.
               IF ERROR-STATUS:ERROR THEN
                  ASSIGN i-num-pedido = 0.
           END.
           
           CREATE tt-it-docto-xml.                                              
           ASSIGN tt-it-docto-xml.arquivo       = tt-docto-xml.arquivo           
                  tt-it-docto-xml.serie         = tt-docto-xml.serie             
                  tt-it-docto-xml.nNF           = tt-docto-xml.nNF               
                  tt-it-docto-xml.CNPJ          = tt-docto-xml.CNPJ              
                  tt-it-docto-xml.tipo-nota     = tt-docto-xml.tipo-nota         
                  tt-it-docto-xml.item-do-forn  = trim(STRING(ttprod.cProd))  
                  tt-it-docto-xml.sequencia     = i-seq-item
                  tt-it-docto-xml.xProd         = SUBstring(STRING(ttprod.xProd),1,60)                     
                  tt-it-docto-xml.ncm           = INT(STRING(ttprod.ncm))             
                  tt-it-docto-xml.cfop          = INT(STRING(ttprod.cfop))                 
                  tt-it-docto-xml.uCom          = SUBstring(STRING(ttprod.uCom),1,2)                        
                  tt-it-docto-xml.uCom-forn     = SUBstring(STRING(ttprod.uCom),1,2)                    
                  tt-it-docto-xml.qCom          = dec(ttprod.qCom)                    
                  tt-it-docto-xml.qCom-forn     = dec(ttprod.qCom)                 
                  tt-it-docto-xml.vUnCom        = dec(ttprod.vUnCom) /* / 10000000000 */  
                  tt-it-docto-xml.vProd         = dec(ttprod.vProd)                 
                  tt-it-docto-xml.vDesc         = dec(ttprod.vDesc)                 
                  tt-it-docto-xml.num-pedido    = INT(i-num-pedido). 
                   
           for first ttmed WHERE
               ttmed.nItem = ttprod.nitem:
               ASSIGN tt-it-docto-xml.lote = if ttmed.nlote <> ? then ttmed.nlote else ""
                      c-data = SUBSTRING(ttmed.dfab,1,10)
                      c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                      tt-it-docto-xml.dFab  =  DATE(c-data).
               ASSIGN c-data = SUBSTRING(ttmed.dval,1,10)
                      c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                            tt-it-docto-xml.dVal  =  DATE(c-data).
           END.
    
           ASSIGN i-orig-icms   = 0
                  i-modBC       = 0
                  de-vbc-icms    = 0
                  de-picms       = 0
                  de-vicms       = 0
                  de-pmvast      = 0
                  de-vbcst       = 0
                  de-picmsst     = 0
                  de-vicmsst     = 0
                  de-vbcstret    = 0
                  de-vicmsstret  = 0
                  de-vicmsDeson  = 0
                  de-predbc-icms = 0 .
    
           for first ttICMS00 WHERE
               ttICMS00.nItem = ttprod.nitem:
               ASSIGN  i-orig-icms   = ttICMS00.orig
                       i-cst-icms    = ttICMS00.cst  
                       i-modBC       = ttICMS00.modBC     
                       de-vbc-icms    = ttICMS00.vbc  
                       de-picms       = ttICMS00.picms     
                       de-vicms       = ttICMS00.vicms
                       de-pmvast      = ttICMS00.pmvast  
                       de-vbcst       = ttICMS00.vbcst
                       de-picmsst     = ttICMS00.picmsst
                       de-vicmsst     = ttICMS00.vicmsst     
                       de-vbcstret    = ttICMS00.vbcstret   
                       de-vicmsstret  = ttICMS00.vicmsstret.
           END. /* ttICMS00*/
    
           for FIRST ttICMS10 WHERE 
               ttICMS10.nItem = ttprod.nitem :
               ASSIGN  i-orig-icms   = ttICMS10.orig
                       i-cst-icms    = ttICMS10.cst  
                       i-modBC       = ttICMS10.modBC     
                       de-vbc-icms    = ttICMS10.vbc  
                       de-picms       = ttICMS10.picms     
                       de-vicms       = ttICMS10.vicms
                       de-pmvast      = ttICMS10.pmvast  
                       de-vbcst       = ttICMS10.vbcst
                       de-picmsst     = ttICMS10.picmsst
                       de-vicmsst     = ttICMS10.vicmsst     
                       de-vbcstret    = ttICMS10.vbcstret   
                       de-vicmsstret  = ttICMS10.vicmsstret.
           end. /* ttICMS10 */
            
           for FIRST ttICMS20 where
               ttICMS20.nItem = ttprod.nitem :
               ASSIGN  i-orig-icms   = ttICMS20.orig
                       i-cst-icms    = ttICMS20.cst  
                       i-modBC       = ttICMS20.modBC     
                       de-vbc-icms    = ttICMS20.vbc  
                       de-picms       = ttICMS20.picms     
                       de-vicms       = ttICMS20.vicms
                       de-pmvast      = ttICMS20.pmvast  
                       de-vbcst       = ttICMS20.vbcst
                       de-picmsst     = ttICMS20.picmsst
                       de-vicmsst     = ttICMS20.vicmsst     
                       de-vbcstret    = ttICMS20.vbcstret   
                       de-vicmsstret  = ttICMS20.vicmsstret
                       de-predbc-icms = ttICMS20.pRedBC.
           end. /*ttICMS20 */
           
           for first ttICMS30  where
               ttICMS30.nItem = ttprod.nitem :
               ASSIGN  i-orig-icms   = ttICMS30.orig
                       i-cst-icms    = ttICMS30.cst  
                       i-modBC       = ttICMS30.modBC     
                       de-vbc-icms    = ttICMS30.vbc  
                       de-picms       = ttICMS30.picms     
                       de-vicms       = ttICMS30.vicms
                       de-pmvast      = ttICMS30.pmvast  
                       de-vbcst       = ttICMS30.vbcst
                       de-picmsst     = ttICMS30.picmsst
                       de-vicmsst     = ttICMS30.vicmsst     
                       de-vbcstret    = ttICMS30.vbcstret   
                       de-vicmsstret  = ttICMS30.vicmsstret
                       de-predbc-icms = ttICMS30.pRedBC.
           end. /* ttICMS30 */
    
           for first ttICMS40  WHERE
               ttICMS40.nItem = ttprod.nitem :
               ASSIGN  i-orig-icms   = ttICMS40.orig
                       i-cst-icms    = ttICMS40.cst  
                       i-modBC       = ttICMS40.modBC     
                       de-vbc-icms    = ttICMS40.vbc  
                       de-picms       = ttICMS40.picms     
                       de-vicms       = ttICMS40.vicms
                       de-pmvast      = ttICMS40.pmvast  
                       de-vbcst       = ttICMS40.vbcst
                       de-picmsst     = ttICMS40.picmsst
                       de-vicmsst     = ttICMS40.vicmsst     
                       de-vbcstret    = ttICMS40.vbcstret   
                       de-vicmsstret  = ttICMS40.vicmsstret
                       de-vicmsDeson  = ttICMS40.vicmsDeson
                       de-predbc-icms = ttICMS40.pRedBC.
           end. /* ttICMS40*/
             
           for first ttICMS51 WHERE 
               ttICMS51.nItem = ttprod.nitem :
               ASSIGN  i-orig-icms   = ttICMS51.orig
                       i-cst-icms    = ttICMS51.cst  
                       i-modBC       = ttICMS51.modBC     
                       de-vbc-icms    = ttICMS51.vbc  
                       de-picms       = ttICMS51.picms     
                       de-vicms       = ttICMS51.vicms
                       de-pmvast      = ttICMS51.pmvast  
                       de-vbcst       = ttICMS51.vbcst
                       de-picmsst     = ttICMS51.picmsst
                       de-vicmsst     = ttICMS51.vicmsst     
                       de-vbcstret    = ttICMS51.vbcstret   
                       de-vicmsstret  = ttICMS51.vicmsstret
                       de-vicmsDeson  = ttICMS51.vicmsDeson
                       de-predbc-icms = ttICMS51.pRedBC.
           end. /* ttICMS51 */
          
           /* nÆo estava trandao - AVB 31/08/2016 */
           for first ttICMS60 WHERE 
               ttICMS60.nItem = ttprod.nitem :
               ASSIGN  i-orig-icms   = ttICMS60.orig
                       i-cst-icms    = ttICMS60.cst  
                       i-modBC       = ttICMS60.modBC     
                       de-vbc-icms    = ttICMS60.vbc  
                       de-picms       = ttICMS60.picms     
                       de-vicms       = ttICMS60.vicms
                       de-pmvast      = ttICMS60.pmvast  
                       de-vbcst       = ttICMS60.vbcst
                       de-picmsst     = ttICMS60.picmsst
                       de-vicmsst     = ttICMS60.vicmsst     
                       de-vbcstret    = ttICMS60.vbcstret   
                       de-vicmsstret  = ttICMS60.vicmsstret
                       de-predbc-icms = ttICMS60.pRedBC.
           end. /* ttICMS60 */

           for first ttICMS70 WHERE 
               ttICMS70.nItem = ttprod.nitem :
               ASSIGN  i-orig-icms   = ttICMS70.orig
                       i-cst-icms    = ttICMS70.cst  
                       i-modBC       = ttICMS70.modBC     
                       de-vbc-icms    = ttICMS70.vbc  
                       de-picms       = ttICMS70.picms     
                       de-vicms       = ttICMS70.vicms
                       de-pmvast      = ttICMS70.pmvast  
                       de-vbcst       = ttICMS70.vbcst
                       de-picmsst     = ttICMS70.picmsst
                       de-vicmsst     = ttICMS70.vicmsst     
                       de-vbcstret    = ttICMS70.vbcstret   
                       de-vicmsstret  = ttICMS70.vicmsstret
                       de-predbc-icms = ttICMS70.pRedBC.
           end. /* ttICMS70 */
    
           for first ttICMS90 WHERE 
               ttICMS90.nItem = ttprod.nitem :
               ASSIGN  i-orig-icms   = ttICMS90.orig
                       i-cst-icms    = ttICMS90.cst  
                       i-modBC       = ttICMS90.modBC     
                       de-vbc-icms    = ttICMS90.vbc  
                       de-picms       = ttICMS90.picms     
                       de-vicms       = ttICMS90.vicms
                       de-pmvast      = ttICMS90.pmvast  
                       de-vbcst       = ttICMS90.vbcst
                       de-picmsst     = ttICMS90.picmsst
                       de-vicmsst     = ttICMS90.vicmsst     
                       de-vbcstret    = ttICMS90.vbcstret   
                       de-vicmsstret  = ttICMS90.vicmsstret
                       de-predbc-icms = ttICMS90.pRedBC.
           end. /* ttICMS90*/
    
           for first ttICMSSN101 WHERE 
               ttICMSSN101.nItem = ttprod.nitem :
               ASSIGN i-orig-icms   = ttICMSSN101.orig.
           end.
    
           for first ttICMSSN102 WHERE 
               ttICMSSN102.nItem = ttprod.nitem :
               ASSIGN i-orig-icms   = ttICMSSN102.orig.
           END.
           
           for first ttICMSSN201 WHERE 
               ttICMSSN201.nItem = ttprod.nitem :
               ASSIGN i-orig-icms   = ttICMSSN201.orig
                      i-modBC       = ttICMSSN201.modBC     
                      de-vbc-icms    = ttICMSSN201.vbc  
                      de-picms       = ttICMSSN201.picms     
                      de-vicms       = ttICMSSN201.vicms
                      de-pmvast      = ttICMSSN201.pmvast  
                      de-vbcst       = ttICMSSN201.vbcst
                      de-picmsst     = ttICMSSN201.picmsst
                      de-vicmsst     = ttICMSSN201.vicmsst.
           end. /* ttICMSSN201 */
          
           for FIRST ttICMSSN202 WHERE 
               ttICMSSN202.nItem = ttprod.nitem :
               ASSIGN i-orig-icms   = ttICMSSN202.orig
                      i-modBC       = ttICMSSN202.modBC     
                      de-vbc-icms    = ttICMSSN202.vbc  
                      de-picms       = ttICMSSN202.picms     
                      de-vicms       = ttICMSSN202.vicms
                      de-pmvast      = ttICMSSN202.pmvast  
                      de-vbcst       = ttICMSSN202.vbcst
                      de-picmsst     = ttICMSSN202.picmsst
                      de-vicmsst     = ttICMSSN202.vicmsst.
           end. /* ttICMSSN202 */
    
           for FIRST ttICMSSN500 WHERE 
               ttICMSSN500.nItem = ttprod.nitem :
               ASSIGN i-orig-icms   = ttICMSSN500.orig
                      de-vbcstret    = ttICMSSN500.vbcstret   
                      de-vicmsstret  = ttICMSSN500.vicmsstret.
                      /*de-predbc-icms = ttICMSSN500.pRedBC.*/
           end.
    
           for FIRST ttICMSSN900 WHERE 
               ttICMSSN900.nItem = ttprod.nitem:
               ASSIGN i-orig-icms   = ttICMSSN900.orig
                      i-cst-icms    = ttICMSSN900.cst  
                      i-modBC       = ttICMSSN900.modBC     
                      de-vbc-icms    = ttICMSSN900.vbc  
                      de-picms       = ttICMSSN900.picms     
                      de-vicms       = ttICMSSN900.vicms
                      de-pmvast      = ttICMSSN900.pmvast  
                      de-vbcst       = ttICMSSN900.vbcst
                      de-picmsst     = ttICMSSN900.picmsst
                      de-vicmsst     = ttICMSSN900.vicmsst.
           end.
           ASSIGN tt-it-docto-xml.orig-icms     = i-orig-icms 
                  tt-it-docto-xml.cst-icms      = i-cst-icms  
                  tt-it-docto-xml.modBC         = i-modBC
                  tt-it-docto-xml.vbc-icms      = de-vbc-icms  
                  tt-it-docto-xml.picms         = de-picms     
                  tt-it-docto-xml.vicms         = de-vicms     
                  tt-it-docto-xml.pmvast        = de-pmvast    
                  tt-it-docto-xml.vbcst         = de-vbcst     
                  tt-it-docto-xml.picmsst       = de-picmsst   
                  tt-it-docto-xml.vicmsst       = de-vicmsst   
                  tt-it-docto-xml.vbcstret      = de-vbcstret  
                  tt-it-docto-xml.vicmsstret    = de-vicmsstret.
    
           assign tt-it-docto-xml.vicmsDeson    = de-vicmsDeson
                  tt-it-docto-xml.predBc        = de-predbc-icms
                  tt-it-docto-xml.vOutro        = ttProd.vOutro.
    
           for FIRST ttIPITrib WHERE
               ttIPITrib.nItem = ttprod.nitem :
               assign tt-it-docto-xml.cst-ipi = ttIPITrib.CST
                      tt-it-docto-xml.vbc-ipi = ttIPITrib.vBC
                      tt-it-docto-xml.pipi    = ttIPITrib.pIPI
                      tt-it-docto-xml.vipi    = ttIPITrib.vIPI.
           end.
    
           ASSIGN tt-it-docto-xml.cst-pis    = 0
                  tt-it-docto-xml.vbc-pis    = 0
                  tt-it-docto-xml.ppis       = 0
                  tt-it-docto-xml.vpis       = 0
                  tt-it-docto-xml.cst-cofins = 0 
                  tt-it-docto-xml.vbc-cofins = 0 
                  tt-it-docto-xml.pcofins    = 0 
                  tt-it-docto-xml.vcofins    = 0.

    
           ASSIGN c-item-do-forn = ""
                  de-aliq-pis    = 0
                  de-aliq-cofins = 0.
    
           ASSIGN c-item-do-forn = tt-it-docto-xml.item-do-forn.
    
           for first item-fornec no-lock where
               item-fornec.cod-emitente = tt-docto-xml.cod-emitente AND 
               ITEM-fornec.item-do-forn = c-item-do-forn AND 
               ITEM-fornec.ativo = YES query-tuning(no-lookahead): end.

           if not avail ITEM-fornec 
           then do:
                ASSIGN c-item-do-forn = TRIM(tt-it-docto-xml.item-do-forn) NO-ERROR.
                IF ERROR-STATUS:ERROR THEN
                   ASSIGN c-item-do-forn = STRING (tt-it-docto-xml.item-do-forn).
                for first item-fornec no-lock where 
                    item-fornec.cod-emitente = tt-docto-xml.cod-emitente AND 
                    ITEM-fornec.item-do-forn = c-item-do-forn AND 
                    ITEM-fornec.ativo = YES query-tuning(no-lookahead):
                end.
           end.
    
           IF AVAIL item-fornec 
           THEN DO:
              for first ITEM no-lock where 
                  ITEM.it-codigo  = item-fornec.it-codigo query-tuning(no-lookahead):

                  ASSIGN de-aliq-pis = dec(substr(item.char-2,31,5)).
                  ASSIGN de-aliq-cofins = dec(substr(item.char-2,36,5)).
    
                  IF de-aliq-pis > 0 THEN DO:
                     FIND FIRST ttPISAliq WHERE
                                ttPISAliq.nItem = ttprod.nitem NO-ERROR.
                     IF AVAIL ttPISAliq THEN DO:
                        ASSIGN tt-it-docto-xml.cst-pis = ttPISAliq.CST
                               tt-it-docto-xml.vbc-pis = ttPISAliq.vBC
                               tt-it-docto-xml.ppis    = de-aliq-pis
                               tt-it-docto-xml.vpis    = ttPISAliq.vBC / de-aliq-pis.
                        ASSIGN de-tot-pis = de-tot-pis + tt-it-docto-xml.vpis.
                     END.   
                  END.

                  IF de-aliq-cofins > 0 THEN DO:
                     FIND FIRST ttCOFINSAliq WHERE
                                ttCOFINSAliq.nItem = ttprod.nitem NO-ERROR.
                     IF AVAIL ttCOFINSAliq 
                     THEN DO:
                        ASSIGN tt-it-docto-xml.cst-cofins =  ttCOFINSAliq.CST  
                               tt-it-docto-xml.vbc-cofins =  ttCOFINSAliq.vBC    
                               tt-it-docto-xml.pcofins    =  de-aliq-cofins
                               tt-it-docto-xml.vcofins    =  ttCOFINSAliq.vBC / de-aliq-cofins.
                        ASSIGN de-tot-cofins = de-tot-cofins + tt-it-docto-xml.vcofins.
                     END. 
                  END.
              END. /* item */
           END. /* item-fornec */
        END. /* each ttprod */

        ASSIGN tt-docto-xml.valor-pis     = de-tot-pis. 
               tt-docto-xml.valor-cofins  = de-tot-cofins.
    
        ASSIGN tt-docto-xml.observacao = ".".
        for first ttInfAdic:
            ASSIGN tt-docto-xml.observacao = if trim(substring(ttInfAdic.infCpl,1,2000)) <> ? 
                                             then trim(substring(ttInfAdic.infCpl,1,2000))
                                             else ".".
        end.
      
        /* duplicatas da nota */
        for each ttDup:
            for first tt-xml-dup where 
                tt-xml-dup.serie        = tt-docto-xml.serie        and
                tt-xml-dup.nNF          = tt-docto-xml.nNF          and
                tt-xml-dup.cod-emitente = tt-docto-xml.cod-emitente and
                tt-xml-dup.tipo-nota    = tt-docto-xml.tipo-nota    and
                tt-xml-dup.nDup         = ttDup.nDup                and
                tt-xml-dup.dVenc        = ttDup.dVenc:              end.
            if not avail tt-xml-dup then do:
                create  tt-xml-dup.
                assign  tt-xml-dup.serie        = tt-docto-xml.serie        
                        tt-xml-dup.nNF          = tt-docto-xml.nNF          
                        tt-xml-dup.cod-emitente = tt-docto-xml.cod-emitente 
                        tt-xml-dup.tipo-nota    = tt-docto-xml.tipo-nota    
                        tt-xml-dup.nDup         = ttDup.nDup                
                        tt-xml-dup.dVenc        = ttDup.dVenc.
            end.
            assign  tt-xml-dup.InfNFe = ttDup.ttInfNFe
                    tt-xml-dup.Cobr   = ttDup.ttCobr  
                    tt-xml-dup.vDup   = ttDup.vDup.
        end. /* ttDup */

        /* notas de compra de loja - AVB 25/08/2016  - enviar para PRS */
        if  not can-find (first b-estab no-lock where b-estab.cgc = tt-docto-xml.CNPJ) and
            can-find (first estabelec no-lock where estabelec.cgc = tt-docto-xml.CNPJ-dest and
                      estabelec.cod-estabel <> "973") and 
            c-doc <> ? and c-doc <> ""
        then do:
            for first int-ds-xml-nfe where
                int-ds-xml-nfe.cnpj_origem = tt-docto-xml.CNPJ and
                int-ds-xml-nfe.serie       = tt-docto-xml.serie and
                int-ds-xml-nfe.notafiscal  = tt-docto-xml.nnf: end.
            if not avail int-ds-xml-nfe then do transaction:
                create  int-ds-xml-nfe.
                /*
                DEF VAR c-temp AS CHAR.
                c-temp = "t:\temp.xml".*/
                /*copy-lob c-doc to file c-temp.*/
                c-doc = replace(c-doc,'<nfeProc versao="3.10" xmlns="http://www.portalfiscal.inf.br/nfe">','<nfeProc>').
                assign  int-ds-xml-nfe.id_nfe       = 'Nfe' + tt-docto-xml.chnfe
                        int-ds-xml-nfe.cnpj_origem  = tt-docto-xml.CNPJ
                        int-ds-xml-nfe.cnpj_destino = tt-docto-xml.CNPJ-dest
                        int-ds-xml-nfe.notafiscal   = tt-docto-xml.nnf
                        int-ds-xml-nfe.serie        = tt-docto-xml.serie
                        int-ds-xml-nfe.emissao      = tt-docto-xml.dEmi.
                copy-lob c-doc to int-ds-xml-nfe.xml.
            end.
            /* necess rio transa‡äes separadas para tratamento na trigger de after-update no Orale */
            do transaction:
                assign  int-ds-xml-nfe.tipo-movto   = 1
                        int-ds-xml-nfe.dt-geracao   = today
                        int-ds-xml-nfe.hr-geracao   = string(time,"HH:MM:SS")
                        int-ds-xml-nfe.situacao     = 1.
                /*
                DISPLAY tt-docto-xml.chnfe     
                        tt-docto-xml.CNPJ      
                        tt-docto-xml.CNPJ-dest 
                        tt-docto-xml.nnf       
                        tt-docto-xml.serie     
                        tt-docto-xml.dEmi
                    WITH WIDTH 300 STREAM-IO.
                    */
            end.
        end.
    END. /* ttIde */
    
END PROCEDURE.

