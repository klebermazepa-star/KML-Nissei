/********************************************************************************
*******************************************************************************/
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

DEFINE VARIABLE l-int002g-ok AS LOGICAL     NO-UNDO.

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
DEF VAR l-transf       AS LOGICAL NO-UNDO.
DEF VAR h-niveis       AS HANDLE  NO-UNDO.
DEF VAR c-item-do-forn AS CHAR    NO-UNDO.
DEF VAR c-nat-operacao AS CHAR    NO-UNDO.
DEF VAR c-cfop         AS CHAR    NO-UNDO.
DEF VAR l-estab        AS LOGICAL NO-UNDO.

DEF VAR i-orig-icms   like  int-ds-it-docto-xml.orig-icms. 
DEF VAR i-cst-icms    like  int-ds-it-docto-xml.cst-icms. 
DEF VAR i-modBC       like  int-ds-it-docto-xml.modBC.     
DEF VAR i-vbc-icms    like  int-ds-it-docto-xml.vbc-icms.  
DEF VAR i-picms       like  int-ds-it-docto-xml.picms.     
DEF VAR i-vicms       like  int-ds-it-docto-xml.vicms.     
DEF VAR i-modbcst     like  int-ds-it-docto-xml.modbcst.   
DEF VAR i-pmvast      like  int-ds-it-docto-xml.pmvast.    
DEF VAR i-vbcst       like  int-ds-it-docto-xml.vbcst.     
DEF VAR i-picmsst     like  int-ds-it-docto-xml.picmsst.   
DEF VAR i-vicmsst     like  int-ds-it-docto-xml.vicmsst.   
DEF VAR i-vbcstret    like  int-ds-it-docto-xml.vbcstret.  
DEF VAR i-vicmsstret  like  int-ds-it-docto-xml.vicmsstret.
DEF VAR i-num-pedido  AS     INTEGER.

DEF BUFFER b-tt-digita             FOR tt-digita.
DEF BUFFER b-int-ds-it-docto-xml   FOR int-ds-it-docto-xml.
DEF BUFFER b-int-ds-docto-xml      FOR int-ds-docto-xml. 
DEF BUFFER b-NDD_ENRYINTEGRATION   FOR NDD_enryintegration. 
DEF BUFFER b-estab                 FOR estabelec.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first mgcad.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "Int002brp"
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
   empty temp-table tt-it-docto-xml.

   ASSIGN l-altera = YES.

   RUN pi-notas-pepsico. /* Fazer a valida‡Æo das notas geradas da Pepsico */
   
   run pi-grava-nota. 

END.
else DO:

  run pi-grava-nota. 

END.
 
IF VALID-HANDLE(h-boin176) THEN
       DELETE PROCEDURE h-boin176.

DELETE WIDGET-POOL.

procedure pi-grava-nota:       
    
    FOR EACH tt-docto-xml USE-INDEX tp-estab-emis WHERE    
             tt-docto-xml.tipo-estab    = 1                        AND  
             tt-docto-xml.dEmi         >= date(STRING(tt-param.dt-trans-ini,"99/99/9999"))  AND 
             tt-docto-xml.dEmi         <= DATE(STRING(tt-param.dt-trans-fin,"99/99/9999"))  AND 
             int(tt-docto-xml.NNF)     >= int(tt-param.i-nro-docto-ini) AND 
             int(tt-docto-xml.NNF)     <= int(tt-param.i-nro-docto-fin) AND
             tt-docto-xml.cod-emitente >= tt-param.i-cod-emit-ini  AND 
             tt-docto-xml.cod-emitente <= tt-param.i-cod-emit-fin 
        BREAK BY tt-docto-xml.arquivo query-tuning(no-lookahead):
    
        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Processando: " + string(NDD_enryintegration.ENTRYINTEGRATION_new_legid)).
        
        FIND FIRST int-ds-docto-xml EXCLUSIVE-LOCK WHERE
                   int-ds-docto-xml.tipo-nota = tt-docto-xml.tipo-nota AND
                   int-ds-docto-xml.CNPJ      = tt-docto-xml.CNPJ      AND
                   int-ds-docto-xml.nNF       = tt-docto-xml.nNF       AND
                   int-ds-docto-xml.serie     = tt-docto-xml.serie  NO-ERROR.
        IF AVAIL int-ds-docto-xml THEN DO:
            IF l-altera = NO THEN
               DELETE int-ds-docto-xml.
        END.    
    
        FOR EACH int-ds-doc-erro EXCLUSIVE-LOCK WHERE
                 int-ds-doc-erro.serie-docto  = tt-docto-xml.serie        AND 
                 int-ds-doc-erro.cod-emitente = tt-docto-xml.cod-emitente AND
                 int-ds-doc-erro.CNPJ         = tt-docto-xml.CNPJ         AND    
                 int-ds-doc-erro.nro-docto    = tt-docto-xml.NNF          AND 
                 int-ds-doc-erro.tipo-nota    = tt-docto-xml.tipo-nota    AND 
                 int-ds-doc-erro.sequencia    = 0 query-tuning(no-lookahead):
           
            DELETE int-ds-doc-erro.
                 
        END.
        
        IF l-altera = NO THEN DO:
        
          CREATE int-ds-docto-xml.
          BUFFER-COPY tt-docto-xml TO int-ds-docto-xml.
    
        END.
                
        ASSIGN int-ds-docto-xml.situacao = 2.

        ASSIGN int-ds-docto-xml.chnfe      = IF tt-docto-xml.chnfe      = ? then "" else tt-docto-xml.chnfe  
               int-ds-docto-xml.xnome      = IF tt-docto-xml.xnome      = ? then "" else tt-docto-xml.xnome
               int-ds-docto-xml.modFrete   = IF tt-docto-xml.modFrete   = ? then 0  else tt-docto-xml.modFrete
               int-ds-docto-xml.num-pedido = IF tt-docto-xml.num-pedido = ? then 0  else tt-docto-xml.num-pedido.     

        FIND FIRST serie WHERE 
                   serie.serie = tt-docto-xml.serie NO-LOCK NO-ERROR.
        IF NOT AVAIL serie THEN DO:
    
            RUN pi-gera-erro(INPUT 1,    
                             INPUT "S‚rie NÆo cadastrada").   
    
        END.    

        FOR FIRST natur-oper NO-LOCK WHERE
                  natur-oper.nat-operacao = int-ds-docto-xml.nat-operacao :
        END.

        IF NOT AVAIL natur-oper 
        THEN DO:

           RUN pi-gera-erro(INPUT 9,    
                            INPUT "Natureza de Opera‡Æo Nota" + string(int-ds-docto-xml.nat-operacao) + " nÆo cadastrada!"). 

        END.
    
        FOR FIRST emitente NO-LOCK WHERE
                  emitente.cgc = tt-docto-xml.CNPJ :
        END.
        IF AVAIL emitente THEN DO:
              IF AVAIL int-ds-docto-xml THEN 
                 ASSIGN int-ds-docto-xml.cod-emitente = emitente.cod-emitente
                        int-ds-docto-xml.cnpj         = emitente.cgc
                        tt-docto-xml.cod-emitente     = emitente.cod-emitente
                        tt-docto-xml.CNPJ             = emitente.cgc.
        END.     

        ELSE DO:
            RUN pi-gera-erro(INPUT 2,    
                             INPUT "Fornecedor " + tt-docto-xml.xNome + ".NÆo cadastrado com o CNPJ " + STRING(tt-docto-xml.CNPJ)).       
    
        END.
    
        FIND FIRST estabelec NO-LOCK WHERE
                   estabelec.cod-estabel = tt-docto-xml.cod-estab no-error. 
        IF AVAIL estabelec THEN DO:

            ASSIGN int-ds-docto-xml.cod-estab = estabelec.cod-estabel
                   int-ds-docto-xml.ep-codigo = int(estabelec.ep-codigo). 

        END.
        ELSE DO:
           RUN pi-gera-erro(INPUT 3,    
                            INPUT "Estabelecimento nÆo cadastrado com o CNPJ " + STRING(tt-docto-xml.CNPJ-dest)).
    
        END. 
        
              
        IF int-ds-docto-xml.tipo-docto   = 4 AND 
           int-ds-docto-xml.tot-desconto = 0  /* Notas Pepsico */  
        THEN DO:

           RUN pi-gera-erro(INPUT 11,    
                            INPUT "NÆo foi informado o desconto.").
        END.

                                         
        FOR EACH tt-it-docto-xml WHERE
                 tt-it-docto-xml.tipo-nota  = tt-docto-xml.tipo-nota AND
                 tt-it-docto-xml.CNPJ       = tt-docto-xml.CNPJ      AND
                 tt-it-docto-xml.nNF        = tt-docto-xml.nNF       AND
                 tt-it-docto-xml.serie      = tt-docto-xml.serie
             by  tt-it-docto-xml.sequencia query-tuning(no-lookahead):
    
            FOR EACH int-ds-doc-erro EXCLUSIVE-LOCK WHERE
                     int-ds-doc-erro.serie-docto  = tt-docto-xml.serie        AND 
                     int-ds-doc-erro.cod-emitente = tt-docto-xml.cod-emitente AND
                     int-ds-doc-erro.CNPJ         = tt-docto-xml.CNPJ         AND    
                     int-ds-doc-erro.nro-docto    = tt-docto-xml.NNF          AND 
                     int-ds-doc-erro.tipo-nota    = tt-docto-xml.tipo-nota    AND 
                     int-ds-doc-erro.sequencia    = tt-it-docto-xml.sequencia query-tuning(no-lookahead):
           
              DELETE int-ds-doc-erro.
                 
            END.
    
            FIND FIRST int-ds-it-docto-xml EXCLUSIVE-LOCK WHERE
                       int-ds-it-docto-xml.tipo-nota   = tt-it-docto-xml.tipo-nota AND
                       int-ds-it-docto-xml.CNPJ        = tt-it-docto-xml.CNPJ      AND
                       int-ds-it-docto-xml.nNF         = tt-it-docto-xml.nNF       AND
                       int-ds-it-docto-xml.serie       = tt-it-docto-xml.serie     AND
                       int-ds-it-docto-xml.sequencia   = tt-it-docto-xml.sequencia NO-ERROR.
            IF AVAIL int-ds-it-docto-xml THEN DO:
                IF l-altera = NO THEN 
                   DELETE int-ds-it-docto-xml.  
            END.
               
            IF l-altera = NO THEN DO:              
                CREATE int-ds-it-docto-xml.
                BUFFER-COPY tt-it-docto-xml TO int-ds-it-docto-xml.   

                IF AVAIL emitente THEN 
                ASSIGN int-ds-it-docto-xml.cod-emitente = emitente.cod-emitente. 
            END.    
          
            ASSIGN int-ds-it-docto-xml.situacao      = 2
                   int-ds-it-docto-xml.cod-emitente  = int-ds-docto-xml.cod-emitente
                   int-ds-it-docto-xml.cnpj          = int-ds-docto-xml.cnpj
                   int-ds-it-docto-xml.item-do-forn  = trim(tt-it-docto-xml.item-do-forn).
                   /*

            MESSAGE  LENGTH(tt-it-docto-xml.xprod)  skip 
                     LENGTH(tt-it-docto-xml.uCom)           skip 
                     LENGTH(tt-it-docto-xml.nat-operacao)   skip 
                    
                     
                     LENGTH(tt-it-docto-xml.item-do-forn)   skip 
                     LENGTH(tt-it-docto-xml.uCom-forn)      skip 
                     LENGTH(tt-it-docto-xml.narrativa)      skip 
                     LENGTH(int-ds-docto-xml.cnpj)          SKIP
                     LENGTH(tt-it-docto-xml.lote)      VIEW-AS ALERT-BOX. 
                         */

                ASSIGN int-ds-it-docto-xml.xprod         = IF tt-it-docto-xml.xprod           = ? then ""   else  tt-it-docto-xml.xprod   
                       int-ds-it-docto-xml.uCom          = if tt-it-docto-xml.uCom            = ? then ""   else  tt-it-docto-xml.uCom           
                       int-ds-it-docto-xml.nat-operacao  = if tt-it-docto-xml.nat-operacao    = ? then ""   else  tt-it-docto-xml.nat-operacao
                       int-ds-it-docto-xml.qOrdem        = if tt-it-docto-xml.qOrdem          = ? then 0    else  tt-it-docto-xml.qOrdem        
                       int-ds-it-docto-xml.vtottrib      = if tt-it-docto-xml.vtottrib        = ? then 0    else  tt-it-docto-xml.vtottrib      
                       int-ds-it-docto-xml.vbc-icms      = if tt-it-docto-xml.vbc-icms        = ? then 0    else  tt-it-docto-xml.vbc-icms      
                       int-ds-it-docto-xml.picms         = if tt-it-docto-xml.picms           = ? then 0    else  tt-it-docto-xml.picms         
                       int-ds-it-docto-xml.pmvast        = if tt-it-docto-xml.pmvast          = ? then 0    else  tt-it-docto-xml.pmvast        
                       int-ds-it-docto-xml.vbcst         = if tt-it-docto-xml.vbcst           = ? then 0    else  tt-it-docto-xml.vbcst         
                       int-ds-it-docto-xml.picmsst       = if tt-it-docto-xml.picmsst         = ? then 0    else  tt-it-docto-xml.picmsst       
                       int-ds-it-docto-xml.vicmsst       = if tt-it-docto-xml.vicmsst         = ? then 0    else  tt-it-docto-xml.vicmsst       
                       int-ds-it-docto-xml.vbcstret      = if tt-it-docto-xml.vbcstret        = ? then 0    else  tt-it-docto-xml.vbcstret      
                       int-ds-it-docto-xml.vicmsstret    = if tt-it-docto-xml.vicmsstret      = ? then 0    else  tt-it-docto-xml.vicmsstret    
                       int-ds-it-docto-xml.ppis          = if tt-it-docto-xml.ppis            = ? then 0    else  tt-it-docto-xml.ppis          
                       int-ds-it-docto-xml.pipi          = if tt-it-docto-xml.pipi            = ? then 0    else  tt-it-docto-xml.pipi          
                       int-ds-it-docto-xml.pcofins       = if tt-it-docto-xml.pcofins         = ? then 0    else  tt-it-docto-xml.pcofins       
                       int-ds-it-docto-xml.orig-icms     = if tt-it-docto-xml.orig-icms       = ? then 0    else  tt-it-docto-xml.orig-icms     
                       int-ds-it-docto-xml.ncm           = if tt-it-docto-xml.ncm             = ? then 0    else  tt-it-docto-xml.ncm  
                       int-ds-it-docto-xml.item-do-forn  = if trim(tt-it-docto-xml.item-do-forn) = ? then "" else  trim(tt-it-docto-xml.item-do-forn)
                       int-ds-it-docto-xml.uCom-forn     = if tt-it-docto-xml.uCom-forn       = ? then ""   else  tt-it-docto-xml.uCom-forn     
                       int-ds-it-docto-xml.qCom-forn     = if tt-it-docto-xml.qCom-forn       = ? then 0    else  tt-it-docto-xml.qCom-forn  
                       int-ds-it-docto-xml.narrativa     = if tt-it-docto-xml.narrativa       = "0" then "" else  tt-it-docto-xml.narrativa.

                ASSIGN int-ds-it-docto-xml.lote          = if tt-it-docto-xml.lote            = ?   then "" else  tt-it-docto-xml.lote
                       int-ds-it-docto-xml.MODBCST       = if tt-it-docto-xml.MODBCST         = ?   then 0  else  tt-it-docto-xml.MODBCST
                       int-ds-it-docto-xml.CST-COFINS    = if tt-it-docto-xml.CST-COFINS      = ?   then 0  else  tt-it-docto-xml.CST-COFINS
                       int-ds-it-docto-xml.NARRATIVA     = if tt-it-docto-xml.NARRATIVA       = ?   then "" else  tt-it-docto-xml.NARRATIVA
                       int-ds-it-docto-xml.CST-PIS       = if tt-it-docto-xml.CST-PIS         = ?   then 0  else  tt-it-docto-xml.CST-PIS
                       int-ds-it-docto-xml.CENQ          = if tt-it-docto-xml.CENQ            = ?   then 0  else  tt-it-docto-xml.CENQ
                       int-ds-it-docto-xml.cst-icms      = if tt-it-docto-xml.cst-icms        = ?   then 0  else  tt-it-docto-xml.cst-icms    
                       int-ds-it-docto-xml.cst-ipi       = if tt-it-docto-xml.cst-ipi         = ?   then 0  else  tt-it-docto-xml.cst-ipi     
                       int-ds-it-docto-xml.it-codigo     = if tt-it-docto-xml.it-codigo       = ?   then "" else  tt-it-docto-xml.it-codigo   
                       int-ds-it-docto-xml.modbc         = if tt-it-docto-xml.modbc           = ?   then 0  else  tt-it-docto-xml.modbc       
                       int-ds-it-docto-xml.modbcst       = if tt-it-docto-xml.modbcst         = ?   then 0  else  tt-it-docto-xml.modbcst     
                       int-ds-it-docto-xml.numero-ordem  = if tt-it-docto-xml.numero-ordem    = ?   then 0  else  tt-it-docto-xml.numero-ordem.

            assign l-valida = yes.
           
            find first param-re no-lock where
                       param-re.usuario = c-seg-usuario no-error.
            if avail param-re then 
               assign l-valida = not param-re.sem-pedido.           
                      
            if l-valida = yes 
            then do:

                FIND FIRST pedido-compr NO-LOCK WHERE
                           pedido-compr.num-pedido = tt-it-docto-xml.num-pedido NO-ERROR.
                IF NOT AVAIL pedido-compr THEN DO:
        
                       RUN pi-gera-erro(INPUT 4,    
                                        INPUT "Pedido " + string(int-ds-it-docto-xml.num-pedido) + " NÆo cadastrado").   
        
                END.
            END.

            FOR FIRST natur-oper NO-LOCK WHERE
                      natur-oper.nat-operacao = (tt-it-docto-xml.nat-operacao) :
            
            END.

            IF NOT AVAIL natur-oper 
            THEN DO:

               RUN pi-gera-erro(INPUT 8,    
                                INPUT "Natureza de Opera‡Æo do item" + string(int-ds-it-docto-xml.nat-operacao) + " nÆo cadastrada!"). 

            END. 
           
            ASSIGN l-gera-nota = NO.
                          

             /* Notas Pepsico , apenas atualizam no re1001 */
            FOR FIRST int-ds-ext-emitente NO-LOCK WHERE
                      int-ds-ext-emitente.cod-emitente = int-ds-it-docto-xml.cod-emitente :
            END.

            IF (AVAIL int-ds-ext-emitente AND  
                      int-ds-ext-emitente.gera-nota) OR 
                      int-ds-docto-xml.tipo-docto = 0
            THEN DO:

               FIND FIRST item-fornec NO-LOCK WHERE
                          item-fornec.cod-emitente = int-ds-it-docto-xml.cod-emitente AND 
                          ITEM-fornec.it-codigo    = tt-it-docto-xml.it-codigo        AND 
                          ITEM-fornec.ativo = YES NO-ERROR. 
               IF AVAIL ITEM-fornec THEN DO: 
                 ASSIGN int-ds-it-docto-xml.item-do-forn = trim(item-fornec.item-do-forn)
                        tt-it-docto-xml.item-do-forn     = trim(item-fornec.item-do-forn)
                        tt-it-docto-xml.ucom-forn        = tt-it-docto-xml.ucom. 

                 IF int-ds-docto-xml.tipo-docto = 0 THEN
                    ASSIGN tt-it-docto-xml.qCom-forn     = tt-it-docto-xml.qCom-forn
                           tt-it-docto-xml.uCom-forn     = tt-it-docto-xml.ucom-forn
                           int-ds-it-docto-xml.qCom-forn = tt-it-docto-xml.qCom-forn
                           int-ds-it-docto-xml.uCom-forn = tt-it-docto-xml.ucom-forn.
                            
                 ELSE 
                    ASSIGN tt-it-docto-xml.qCom-forn     = tt-it-docto-xml.qCom 
                           tt-it-docto-xml.uCom-forn     = tt-it-docto-xml.ucom
                           int-ds-it-docto-xml.qCom-forn = tt-it-docto-xml.qCom
                           int-ds-it-docto-xml.uCom-forn = tt-it-docto-xml.ucom
                           l-gera-nota = NO.
                   
               END.
               ELSE 
                   ASSIGN tt-it-docto-xml.item-do-forn  = "" 
                          tt-it-docto-xml.xprod         = "".
            END.
            ELSE DO: 

                ASSIGN c-item-do-forn = "".
               
                ASSIGN c-item-do-forn = tt-it-docto-xml.item-do-forn.
        
                FOR FIRST item-fornec NO-LOCK WHERE
                          item-fornec.cod-emitente = int-ds-it-docto-xml.cod-emitente AND 
                          ITEM-fornec.item-do-forn = c-item-do-forn AND 
                          ITEM-fornec.ativo = YES :
                end.

                IF NOT AVAIL ITEM-fornec 
                THEN DO:
                
                    ASSIGN c-item-do-forn = TRIM(tt-it-docto-xml.item-do-forn) NO-ERROR.
    
                    IF ERROR-STATUS:ERROR THEN
                       ASSIGN c-item-do-forn = STRING(tt-it-docto-xml.item-do-forn).
                  
                    FOR FIRST item-fornec NO-LOCK WHERE
                              item-fornec.cod-emitente = int-ds-it-docto-xml.cod-emitente AND 
                              ITEM-fornec.item-do-forn = c-item-do-forn AND 
                              ITEM-fornec.ativo = YES :
                    end.

                END.

            END.
                                     
            IF AVAIL ITEM-fornec OR 
               int-ds-it-docto-xml.tipo-nota = 3  
            THEN DO:
                 
                  ASSIGN de-fator = 0.

                  /* MESSAGE AVAIL item-fornec             SKIP 
                          tt-it-docto-xml.item-do-forn  SKIP
                          tt-it-docto-xml.it-codigo     SKIP  
                          item-fornec.it-codigo         SKIP 
                          int-ds-docto-xml.tipo-docto   SKIP 
                          tt-it-docto-xml.ucom          SKIP 
                          tt-docto-xml.tipo-estab       SKIP
                          ERROR-STATUS:ERROR            SKIP
                          ERROR-STATUS:NUM-MESSAGES     SKIP 
                          VIEW-AS ALERT-BOX. 

                  IF ERROR-STATUS:ERROR THEN DO:
                  
                     DO i-cont = 1 TO ERROR-STATUS:NUM-MESSAGES: 

                         MESSAGE ERROR-STATUS:GET-NUMBER(i-cont) 
                                 ERROR-STATUS:GET-MESSAGE(i-cont)
                                VIEW-AS ALERT-BOX.  
                     END.

                  END.
                   */

                  IF AVAIL item-fornec 
                  THEN DO: 
                      ASSIGN int-ds-it-docto-xml.it-codigo = item-fornec.it-codigo
                             tt-it-docto-xml.it-codigo     = ITEM-fornec.it-codigo. 

                  END.
                  ELSE DO:
                  
                     ASSIGN  int-ds-it-docto-xml.it-codigo = tt-it-docto-xml.item-do-forn
                             tt-it-docto-xml.it-codigo     = int-ds-it-docto-xml.it-codigo 
                             int-ds-it-docto-xml.qCom-forn = tt-it-docto-xml.qCom
                             tt-it-docto-xml.qcom-forn     = tt-it-docto-xml.qCom  
                             de-fator                      =  1.                  
                  END.

                  find item where  
                       item.it-codigo = tt-it-docto-xml.it-codigo no-lock no-error.
                  IF AVAIL ITEM THEN
                      ASSIGN tt-it-docto-xml.xprod     = substring(ITEM.desc-item,1,60)
                             int-ds-it-docto-xml.xprod = substring(ITEM.desc-item,1,60).
                  
                 if avail item-fornec AND 
                          l-gera-nota = NO AND
                          int-ds-docto-xml.tipo-nota <> 3
                 then DO:
                     
                    RUN retornaIndiceConversao in h-boin176 (input int-ds-it-docto-xml.it-codigo,
                                                             input int-ds-it-docto-xml.cod-emitente,
                                                             input item-fornec.unid-med-for,
                                                             output de-fator). 
                                                                      
                  END.
                               
                  if de-fator = 0 or de-fator = ? then assign de-fator = 1.      
                         
                  ASSIGN int-ds-it-docto-xml.qCom   = tt-it-docto-xml.qCom-forn / de-fator
                         int-ds-it-docto-xml.uCom   = IF AVAIL ITEM THEN item.un ELSE tt-it-docto-xml.uCom-forn  
                         int-ds-it-docto-xml.vUnCom = tt-it-docto-xml.vUnCom 
                         int-ds-it-docto-xml.vProd  = tt-it-docto-xml.vprod.
                  
                  IF AVAIL ITEM 
                  THEN DO:
                    
                      IF ITEM.tipo-contr < 3 THEN
                         ASSIGN int-ds-it-docto-xml.tipo-contr = 1.
    
                      IF ITEM.tipo-contr = 4 THEN
                         ASSIGN int-ds-it-docto-xml.tipo-contr = 4.
    
                      /* Notas Pepsico , apenas atualizam no re1001 */
                      FIND FIRST int-ds-ext-emitente NO-LOCK WHERE
                                 int-ds-ext-emitente.cod-emitente = int-ds-it-docto-xml.cod-emitente NO-ERROR.
                      IF AVAIL int-ds-ext-emitente AND  
                               int-ds-ext-emitente.gera-nota THEN 
                         ASSIGN int-ds-it-docto-xml.tipo-contr = 4
                                int-ds-it-docto-xml.xprod = substring(item.desc-item,1,60)
                                tt-it-docto-xml.xprod     = substring(item.desc-item,1,60).  

                      IF AVAIL pedido-compr AND 
                               l-valida = YES AND 
                          int-ds-it-docto-xml.tipo-nota = 1
                      THEN DO:
    
                           FIND FIRST ordem-compra WHERE
                                      ordem-compra.num-pedido = pedido-compr.num-pedido AND  
                                      ordem-compra.it-codigo  = ITEM.it-codigo NO-LOCK NO-ERROR.
                           IF AVAIL ordem-compra THEN
                              ASSIGN int-ds-it-docto-xml.numero-ordem = ordem-compra.numero-ordem. 
                           ELSE DO:
                                RUN pi-gera-erro(INPUT 6,    
                                                 INPUT "Numero de ordem nÆo encontrado para o pedido " + string(pedido-compr.num-pedido) + " Item:" + STRING(ITEM.it-codigo)).
                           END.
                      END.
                      
                  END.
                  ELSE DO:
                     RUN pi-gera-erro(INPUT 7,    
                                      INPUT "Item NÆo cadastrado " + string(tt-it-docto-xml.it-codigo)). 
                  END.
            END.
            ELSE DO:
                  RUN pi-gera-erro(INPUT 5,    
                                   INPUT "Relacionamento item x fornecedor nÆo cadastrado. Item: " + string(tt-it-docto-xml.item-do-forn) + " Fornecedor: " + STRING(int-ds-it-docto-xml.cod-emitente)). 
            END.
            RELEASE int-ds-it-docto-xml.
        END.
        
        IF LAST-OF(tt-docto-xml.arquivo) 
        THEN DO: 
               
           FOR EACH int-ds-doc-erro NO-LOCK WHERE
                    int-ds-doc-erro.serie-docto  = tt-docto-xml.serie        AND 
                    int-ds-doc-erro.CNPJ         = tt-docto-xml.CNPJ         AND    
                    int(int-ds-doc-erro.nro-docto) = INT(tt-docto-xml.NNF)      AND 
                    int-ds-doc-erro.tipo-nota    = tt-docto-xml.tipo-nota  
               BY int-ds-doc-erro.CNPJ
               BY int-ds-doc-erro.nro-docto
               BY int-ds-doc-erro.cod-erro query-tuning(no-lookahead):
                                 
               DISP int-ds-doc-erro.nro-docto
                    int-ds-doc-erro.serie-docto
                    int-ds-doc-erro.cod-emitente  
                    tt-docto-xml.cnpj
                    int-ds-doc-erro.cod-erro COLUMN-LABEL "Cod Erro"
                    int-ds-doc-erro.descricao FORMAT "X(100)"
                    WITH WIDTH 333 STREAM-IO FRAME f-erro DOWN.
               DOWN WITH FRAME f-erro. 
                  
           END.
        END.
    END. 
    
    /* Integrar notas direto com o PRS */
    RUN intprg/int002g.p (INPUT TABLE tt-param,
                          INPUT TABLE tt-docto-xml,
                          INPUT TABLE tt-it-docto-xml,
                          OUTPUT l-int002g-ok). 
    
end.

{include/i-rpclo.i}   

IF VALID-HANDLE(h-acomp) THEN 
   run pi-finalizar in h-acomp.

return "OK":U.

    
PROCEDURE pi-gera-erro:

DEF INPUT PARAM p-cod-erro     LIKE int-ds-doc-erro.cod-erro.
DEF INPUT PARAM p-desc-erro    LIKE int-ds-doc-erro.descricao.
      
     FOR  FIRST int-ds-doc-erro NO-LOCK WHERE
                int-ds-doc-erro.serie-docto  = tt-docto-xml.serie  AND 
                int-ds-doc-erro.cod-emitente = tt-docto-xml.cod-emitente AND
                int-ds-doc-erro.CNPJ         = tt-docto-xml.CNPJ  AND 
                int(int-ds-doc-erro.nro-docto) = int(tt-docto-xml.nNF)   AND 
                int-ds-doc-erro.tipo-nota    = tt-docto-xml.tipo-nota  AND
                int-ds-doc-erro.descricao    = p-desc-erro  : END.

     IF NOT AVAIL int-ds-doc-erro 
     THEN DO:
        CREATE int-ds-doc-erro.
        ASSIGN int-ds-doc-erro.serie-docto  = tt-docto-xml.serie       
               int-ds-doc-erro.cod-emitente = tt-docto-xml.cod-emitente
               int-ds-doc-erro.CNPJ         = tt-docto-xml.CNPJ 
               int-ds-doc-erro.nro-docto    = tt-docto-xml.nNF   
               int-ds-doc-erro.tipo-nota    = tt-docto-xml.tipo-nota  
               int-ds-doc-erro.tipo-erro    = "ErroXML"   
               int-ds-doc-erro.cod-erro     = p-cod-erro       
               int-ds-doc-erro.descricao    = IF p-desc-erro = ? THEN "" ELSE p-desc-erro.
    
        IF AVAIL int-ds-it-docto-xml THEN 
           ASSIGN int-ds-doc-erro.sequencia = int-ds-it-docto-xml.sequencia.
    
     END.
     IF AVAIL int-ds-docto-xml THEN
        ASSIGN int-ds-docto-xml.situacao = 1.
        
     if avail int-ds-it-docto-xml then 
          assign int-ds-it-docto-xml.situacao = 1.

END PROCEDURE. 

PROCEDURE pi-notas-pepsico:
 
   FOR EACH int-ds-docto-xml NO-LOCK WHERE
            int-ds-docto-xml.tipo-docto = 4 AND 
            int-ds-docto-xml.tipo-estab = 1 AND 
            int-ds-docto-xml.chnfe      = ? query-tuning(no-lookahead):

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
          
   END.

END.

PROCEDURE pi-IntegracaoNDD:

    DEF VAR c-doc       AS LONGCHAR NO-UNDO.
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

    FOR EACH NDD_ENRYINTEGRATION NO-LOCK WHERE       
             NDD_enryintegration.kind    = 0 /* Envio */  AND   
             NDD_enryintegration.status_ = 0 /* campo status pendente */
             query-tuning(no-lookahead)
        BY NDD_enryintegration.ENTRYINTEGRATION_new_legid DESC:  
     
        IF NDD_enryintegration.serie = 10 THEN 
           NEXT.

        /*IF NDD_enryintegration.emissiondate <> DATETIME(?) 
        THEN DO:
        
            ASSIGN l-estab = NO.

            FOR FIRST b-estab NO-LOCK WHERE 
                      b-estab.cgc = trim(string(NDD_enryintegration.cnpjemit)) , 
                FIRST estabelec NO-LOCK WHERE
                      estabelec.cgc = trim(string(NDD_enryintegration.cnpjdest)):
        
                 ASSIGN l-estab = YES.  
                           
            END.
    
            IF l-estab = YES THEN NEXT.
        END.*/

           
        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Processando: " + string(NDD_enryintegration.ENTRYINTEGRATION_new_legid)).


        /* FIND FIRST int-ds-docto-xml USE-INDEX idx_arquivo NO-LOCK WHERE
                   int(int-ds-docto-xml.arquivo) = NDD_enryintegration.ENTRYINTEGRATIONID NO-ERROR.
        IF AVAIL int-ds-docto-xml THEN NEXT. 
        */

        empty temp-table tt-docto-xml.
        empty temp-table tt-it-docto-xml.
        EMPTY TEMP-TABLE tt-digita.

        COPY-LOB FROM NDD_enryintegration.documentdata TO pXMLResult.

        ASSIGN c-doc = pXMLResult
               c-xml = SESSION:TEMP-DIRECTORY + "xml_temp" + string(ENTRYINTEGRATION_new_legid) +  ".xml".
                           
        IF SEARCH(c-xml) <> ? THEN
           os-delete value(c-xml) no-wait no-console.  
                           
        RUN SaveXML(INPUT c-doc, 
                    INPUT c-xml).
        
        ASSIGN i-linha = 0.

        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Integracao :" + STRING(NDD_enryintegration.ENTRYINTEGRATION_new_legid)).
                                
       /* Abertura para a leitura do arquivo XML 
        CREATE X-DOCUMENT h-documento.
        h-documento:LOAD("file",c-xml,FALSE) NO-ERROR.

        CREATE X-NODEREF h-raiz.
        h-documento:GET-DOCUMENT-ELEMENT(h-raiz).
        */               

        run pi-gera-nota(INPUT STRING(NDD_enryintegration.ENTRYINTEGRATION_new_legid),
                         INPUT c-xml).
    

         FIND FIRST ttide no-error.
         
                     
         IF AVAIL ttide THEN do:
             IF ttide.natop BEGINS "Transf" THEN ASSIGN l-transf = YES.
             ELSE 
                ASSIGN l-transf = NO.
         END.
         ELSE
            ASSIGN l-transf = YES.
            

        IF l-transf = NO 
        THEN DO:
           
            run pi-grava-nota.
                  
        END.
        
        FIND FIRST tt-docto-xml NO-ERROR.  
       
        /* DISP tt-docto-xml.tipo-estab WHEN AVAIL tt-docto-xml
             tt-docto-xml.nnf WHEN AVAIL tt-docto-xml.
           */

        IF AVAIL tt-docto-xml 
        THEN DO:
        
            /* DISP tt-docto-xml.tipo-estab
                 tt-docto-xml.nnf
                 tt-docto-xml.serie
                 tt-docto-xml.cod-emitente
                 tt-docto-xml.demi
                 WITH WIDTH 333 STREAM-IO.   */
                 
            IF l-transf = NO 
            THEN DO:
            
                FOR FIRST b-NDD_ENRYINTEGRATION WHERE
                        rowid(b-NDD_ENRYINTEGRATION) = rowid(NDD_ENRYINTEGRATION) :
                END.

                IF AVAIL b-NDD_ENRYINTEGRATION 
                THEN DO:
                
                    /*DISP "atualiza".*/ 

                   ASSIGN b-NDD_enryintegration.status_ = 1.     
                END.
    
                RELEASE b-NDD_enryintegration.

            END.
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

   
PROCEDURE pi-gera-nota:

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
  EMPTY  temp-table ttExporta .
  
    /*------------------------------------------------------------------------------
    Purpose:
    Parameters: <none>
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

    dataset dsNfe:empty-dataset no-error.

    assign cSourceType = "FILE"
    cFile = p-xml /* arquivo da nfe - Realiza a leitura do procNFe */
    cReadMode = "empty"
    cSchemaLocation = ?
    lOverrideDefaultMapping = ?
    cFieldTypeMapping = ?
    cVerifySchemaMode = "IGNORE".

    assign retOK = dataset dsNfe:read-xml(cSourceType,
    cFile,
    cReadMode,
    cSchemaLocation,
    lOverrideDefaultMapping,
    cFieldTypeMapping,
    cVerifySchemaMode) no-error.

    
   FIND FIRST ttIde NO-ERROR.
    
   ASSIGN i-seq-item = 0.

   IF AVAIL ttIde 
   THEN DO:

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
                 tt-docto-xml.dEmi       =  DATE(c-data)
                 tt-docto-xml.dt-trans   = TODAY
                 tt-docto-xml.tipo-docto = 1.
                  
          FIND FIRST ttEmit NO-ERROR.
          IF AVAIL ttEmit THEN DO:
             
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
                
          END.

          FIND FIRST ttDest NO-ERROR.
          IF AVAIL ttDest 
          THEN DO:

               ASSIGN tt-docto-xml.CNPJ-dest   = STRING(ttDest.CNPJ)
                      tt-docto-xml.tipo-estab  = 2.
    
               FIND FIRST estabelec NO-LOCK WHERE 
                          estabelec.cgc = trim(tt-docto-xml.CNPJ-dest) AND 
                          estabelec.cgc <> ""  NO-ERROR.
               IF AVAIL estabelec THEN DO:
                   
                   find first param-estoq no-lock no-error.
         
                   FIND first estab-mat  no-lock where 
                              estab-mat.cod-estabel = estabelec.cod-estabel and 
                              estab-mat.cod-estabel = param-estoq.estabel-pad NO-ERROR.
                   IF AVAIL estab-mat THEN
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
                         b-int-ds-docto-xml.serie        = tt-docto-xml.serie:
    
               END.
                       
               IF AVAIL b-int-ds-docto-xml THEN
                  ASSIGN tt-docto-xml.tipo-estab = 3. /* Documento j  cadastrado na base */


               IF tt-docto-xml.tipo-estab = 2
               THEN DO:
                     
                     FOR FIRST int-ds-nota-entrada NO-LOCK WHERE
                               int-ds-nota-entrada.nen-cnpj-origem-s = tt-docto-xml.CNPJ     AND 
                               int-ds-nota-entrada.nen-serie-s       = tt-docto-xml.serie    AND 
                               int-ds-nota-entrada.nen-notafiscal-n  = int(tt-docto-xml.nnf) AND 
                               int-ds-nota-entrada.nen-cfop-n        = tt-docto-xml.cfop:
                     END.

                     IF AVAIL int-ds-nota-entrada THEN
                        ASSIGN tt-docto-xml.tipo-estab = 3.
               END. 

          END.
    
        FIND FIRST ttinfprot NO-ERROR.
        IF AVAIL ttinfprot THEN DO:
             ASSIGN tt-docto-xml.chNfe = ttinfprot.chNfe.
        END.
                   

       FIND FIRST ttICMSTot NO-ERROR.
       IF AVAIL ttICMSTot 
       THEN DO:
       
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
        
           
       END.

       FIND FIRST ttTransp NO-ERROR.
       IF AVAIL ttTransp THEN DO:
         
          ASSIGN tt-docto-xml.modFrete = ttTransp.modFrete.

       END.

      FIND FIRST ttCompra  NO-ERROR.
      IF AVAIL ttCompra THEN DO:

          ASSIGN i-num-pedido = int(ttCompra.xped) NO-ERROR.

          IF ERROR-STATUS:ERROR THEN
              ASSIGN i-num-pedido = 0.      

      END.

    FIND FIRST ttprod  NO-ERROR.
               
    FOR EACH ttprod:
                
           ASSIGN i-seq-item = i-seq-item + 10.                     
          
                                       
           IF i-num-pedido = 0 THEN DO:
           
               ASSIGN i-num-pedido = int(ttprod.xped) NO-ERROR.
    
               IF ERROR-STATUS:ERROR THEN
                  ASSIGN i-num-pedido = 0.
           END.

           CREATE tt-it-docto-xml.                                              
           ASSIGN tt-it-docto-xml.arquivo      = tt-docto-xml.arquivo           
                  tt-it-docto-xml.serie        = tt-docto-xml.serie             
                  tt-it-docto-xml.nNF          = tt-docto-xml.nNF               
                  tt-it-docto-xml.CNPJ         = tt-docto-xml.CNPJ              
                  tt-it-docto-xml.tipo-nota    = tt-docto-xml.tipo-nota         
                  tt-it-docto-xml.item-do-forn = trim(STRING(ttprod.cProd))  
                  tt-it-docto-xml.sequencia    = i-seq-item
                  tt-it-docto-xml.xProd         = STRING(ttprod.xProd)                     
                  tt-it-docto-xml.ncm           = INT(STRING(ttprod.ncm))             
                  tt-it-docto-xml.cfop          = INT(STRING(ttprod.cfop))                 
                  tt-it-docto-xml.uCom          = STRING(ttprod.uCom)                        
                  tt-it-docto-xml.uCom-forn     = STRING(ttprod.uCom)                    
                  tt-it-docto-xml.qCom          = dec(ttprod.qCom)                    
                  tt-it-docto-xml.qCom-forn     = dec(ttprod.qCom)                 
                  tt-it-docto-xml.vUnCom        = dec(ttprod.vUnCom) /* / 10000000000 */  
                  tt-it-docto-xml.vProd         = dec(ttprod.vProd)                 
                  tt-it-docto-xml.vDesc         = dec(ttprod.vDesc)                 
                  tt-it-docto-xml.num-pedido    = INT(i-num-pedido). 
               
       FIND FIRST ttmed WHERE
                  ttmed.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttmed THEN DO:
             
              ASSIGN tt-it-docto-xml.lote = ttmed.nlote
                     c-data = SUBSTRING(ttmed.dfab,1,10)
                     c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                     tt-it-docto-xml.dFab  =  DATE(c-data).
                     
              ASSIGN c-data = SUBSTRING(ttmed.dval,1,10)
                     c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                           tt-it-docto-xml.dVal  =  DATE(c-data).
       END.

       ASSIGN i-orig-icms   = 0
              i-modBC       = 0
              i-vbc-icms    = 0
              i-picms       = 0
              i-vicms       = 0
              i-pmvast      = 0
              i-vbcst       = 0
              i-picmsst     = 0
              i-vicmsst     = 0
              i-vbcstret    = 0
              i-vicmsstret  = 0.

       FIND FIRST ttICMS00 WHERE
                  ttICMS00.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMS00 THEN DO:

         ASSIGN  i-orig-icms   = ttICMS00.orig
                 i-cst-icms    = ttICMS00.cst  
                 i-modBC       = ttICMS00.modBC     
                 i-vbc-icms    = ttICMS00.vbc  
                 i-picms       = ttICMS00.picms     
                 i-vicms       = ttICMS00.vicms
                 i-pmvast      = ttICMS00.pmvast  
                 i-vbcst       = ttICMS00.vbcst
                 i-picmsst     = ttICMS00.picmsst
                 i-vicmsst     = ttICMS00.vicmsst     
                 i-vbcstret    = ttICMS00.vbcstret   
                 i-vicmsstret  = ttICMS00.vicmsstret.

       END.

       FIND FIRST ttICMS10 WHERE 
                  ttICMS10.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMS10 THEN DO:

         ASSIGN  i-orig-icms   = ttICMS10.orig
                 i-cst-icms    = ttICMS10.cst  
                 i-modBC       = ttICMS10.modBC     
                 i-vbc-icms    = ttICMS10.vbc  
                 i-picms       = ttICMS10.picms     
                 i-vicms       = ttICMS10.vicms
                 i-pmvast      = ttICMS10.pmvast  
                 i-vbcst       = ttICMS10.vbcst
                 i-picmsst     = ttICMS10.picmsst
                 i-vicmsst     = ttICMS10.vicmsst     
                 i-vbcstret    = ttICMS10.vbcstret   
                 i-vicmsstret  = ttICMS10.vicmsstret.
       END.
        
       FIND FIRST ttICMS20 where
                  ttICMS20.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMS20 
       THEN DO:

         ASSIGN  i-orig-icms   = ttICMS20.orig
                 i-cst-icms    = ttICMS20.cst  
                 i-modBC       = ttICMS20.modBC     
                 i-vbc-icms    = ttICMS20.vbc  
                 i-picms       = ttICMS20.picms     
                 i-vicms       = ttICMS20.vicms
                 i-pmvast      = ttICMS20.pmvast  
                 i-vbcst       = ttICMS20.vbcst
                 i-picmsst     = ttICMS20.picmsst
                 i-vicmsst     = ttICMS20.vicmsst     
                 i-vbcstret    = ttICMS20.vbcstret   
                 i-vicmsstret  = ttICMS20.vicmsstret.
       END.
      
       
       FIND FIRST ttICMS30  where
                  ttICMS30.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMS30 THEN DO:   

          ASSIGN  i-orig-icms   = ttICMS30.orig
                  i-cst-icms    = ttICMS30.cst  
                  i-modBC       = ttICMS30.modBC     
                  i-vbc-icms    = ttICMS30.vbc  
                  i-picms       = ttICMS30.picms     
                  i-vicms       = ttICMS30.vicms
                  i-pmvast      = ttICMS30.pmvast  
                  i-vbcst       = ttICMS30.vbcst
                  i-picmsst     = ttICMS30.picmsst
                  i-vicmsst     = ttICMS30.vicmsst     
                  i-vbcstret    = ttICMS30.vbcstret   
                  i-vicmsstret  = ttICMS30.vicmsstret.
       END.

       FIND FIRST ttICMS40  WHERE
                  ttICMS40.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMS40 THEN DO:

          ASSIGN  i-orig-icms   = ttICMS40.orig
                  i-cst-icms    = ttICMS40.cst  
                  i-modBC       = ttICMS40.modBC     
                  i-vbc-icms    = ttICMS40.vbc  
                  i-picms       = ttICMS40.picms     
                  i-vicms       = ttICMS40.vicms
                  i-pmvast      = ttICMS40.pmvast  
                  i-vbcst       = ttICMS40.vbcst
                  i-picmsst     = ttICMS40.picmsst
                  i-vicmsst     = ttICMS40.vicmsst     
                  i-vbcstret    = ttICMS40.vbcstret   
                  i-vicmsstret  = ttICMS40.vicmsstret.
       END.
         
        FIND FIRST ttICMS51 WHERE 
                   ttICMS51.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMS51 
       THEN DO:

          ASSIGN  i-orig-icms   = ttICMS51.orig
                  i-cst-icms    = ttICMS51.cst  
                  i-modBC       = ttICMS51.modBC     
                  i-vbc-icms    = ttICMS51.vbc  
                  i-picms       = ttICMS51.picms     
                  i-vicms       = ttICMS51.vicms
                  i-pmvast      = ttICMS51.pmvast  
                  i-vbcst       = ttICMS51.vbcst
                  i-picmsst     = ttICMS51.picmsst
                  i-vicmsst     = ttICMS51.vicmsst     
                  i-vbcstret    = ttICMS51.vbcstret   
                  i-vicmsstret  = ttICMS51.vicmsstret.
       END.
      
        FIND FIRST ttICMS70 WHERE 
                   ttICMS70.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMS70 
       THEN DO:
         
           ASSIGN i-orig-icms   = ttICMS70.orig
                  i-cst-icms    = ttICMS70.cst  
                  i-modBC       = ttICMS70.modBC     
                  i-vbc-icms    = ttICMS70.vbc  
                  i-picms       = ttICMS70.picms     
                  i-vicms       = ttICMS70.vicms
                  i-pmvast      = ttICMS70.pmvast  
                  i-vbcst       = ttICMS70.vbcst
                  i-picmsst     = ttICMS70.picmsst
                  i-vicmsst     = ttICMS70.vicmsst     
                  i-vbcstret    = ttICMS70.vbcstret   
                  i-vicmsstret  = ttICMS70.vicmsstret.

       END.


       FIND FIRST ttICMS90 WHERE 
                   ttICMS90.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMS90 
       THEN DO:
       
           ASSIGN i-orig-icms   = ttICMS90.orig
                  i-cst-icms    = ttICMS90.cst  
                  i-modBC       = ttICMS90.modBC     
                  i-vbc-icms    = ttICMS90.vbc  
                  i-picms       = ttICMS90.picms     
                  i-vicms       = ttICMS90.vicms
                  i-pmvast      = ttICMS90.pmvast  
                  i-vbcst       = ttICMS90.vbcst
                  i-picmsst     = ttICMS90.picmsst
                  i-vicmsst     = ttICMS90.vicmsst     
                  i-vbcstret    = ttICMS90.vbcstret   
                  i-vicmsstret  = ttICMS90.vicmsstret.

       END.

       FIND FIRST ttICMSSN101 WHERE 
                  ttICMSSN101.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMSSN101 
       THEN DO:
          ASSIGN i-orig-icms   = ttICMSSN101.orig.
       END.

       FIND FIRST ttICMSSN102 WHERE 
                  ttICMSSN102.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMSSN102 
       THEN DO:

          ASSIGN i-orig-icms   = ttICMSSN102.orig.
       END.
       
       FIND FIRST ttICMSSN201 WHERE 
                  ttICMSSN201.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMSSN201 
       THEN DO:

          ASSIGN i-orig-icms   = ttICMSSN201.orig
                 i-modBC       = ttICMSSN201.modBC     
                 i-vbc-icms    = ttICMSSN201.vbc  
                 i-picms       = ttICMSSN201.picms     
                 i-vicms       = ttICMSSN201.vicms
                 i-pmvast      = ttICMSSN201.pmvast  
                 i-vbcst       = ttICMSSN201.vbcst
                 i-picmsst     = ttICMSSN201.picmsst
                 i-vicmsst     = ttICMSSN201.vicmsst.
       END.
      
       FIND FIRST ttICMSSN202 WHERE 
                  ttICMSSN202.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMSSN202 
       THEN DO:

          ASSIGN i-orig-icms   = ttICMSSN202.orig
                 i-modBC       = ttICMSSN202.modBC     
                 i-vbc-icms    = ttICMSSN202.vbc  
                 i-picms       = ttICMSSN202.picms     
                 i-vicms       = ttICMSSN202.vicms
                 i-pmvast      = ttICMSSN202.pmvast  
                 i-vbcst       = ttICMSSN202.vbcst
                 i-picmsst     = ttICMSSN202.picmsst
                 i-vicmsst     = ttICMSSN202.vicmsst.
       END.

       FIND FIRST ttICMSSN500 WHERE 
                  ttICMSSN500.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMSSN500 
       THEN DO:

          ASSIGN i-orig-icms   = ttICMSSN500.orig
                 i-vbcstret    = ttICMSSN500.vbcstret   
                 i-vicmsstret  = ttICMSSN500.vicmsstret.
       END.

       FIND FIRST ttICMSSN900 WHERE 
                  ttICMSSN900.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttICMSSN900 
       THEN DO:

          ASSIGN i-orig-icms   = ttICMSSN900.orig
                 i-cst-icms    = ttICMSSN900.cst  
                 i-modBC       = ttICMSSN900.modBC     
                 i-vbc-icms    = ttICMSSN900.vbc  
                 i-picms       = ttICMSSN900.picms     
                 i-vicms       = ttICMSSN900.vicms
                 i-pmvast      = ttICMSSN900.pmvast  
                 i-vbcst       = ttICMSSN900.vbcst
                 i-picmsst     = ttICMSSN900.picmsst
                 i-vicmsst     = ttICMSSN900.vicmsst.
       END.

       ASSIGN tt-it-docto-xml.orig-icms     = i-orig-icms 
              tt-it-docto-xml.cst-icms      = i-cst-icms  
              tt-it-docto-xml.modBC         = i-modBC
              tt-it-docto-xml.vbc-icms      = i-vbc-icms  
              tt-it-docto-xml.picms         = i-picms     
              tt-it-docto-xml.vicms         = i-vicms     
              tt-it-docto-xml.pmvast        = i-pmvast    
              tt-it-docto-xml.vbcst         = i-vbcst     
              tt-it-docto-xml.picmsst       = i-picmsst   
              tt-it-docto-xml.vicmsst       = i-vicmsst   
              tt-it-docto-xml.vbcstret      = i-vbcstret  
              tt-it-docto-xml.vicmsstret    = i-vicmsstret.

       FIND FIRST ttIPITrib WHERE
                  ttIPITrib.nItem = ttprod.nitem NO-ERROR.

       IF AVAIL ttIPITrib THEN DO:

           ASSIGN tt-it-docto-xml.cst-ipi = ttIPITrib.CST
                  tt-it-docto-xml.vbc-ipi = ttIPITrib.vBC
                  tt-it-docto-xml.pipi    = ttIPITrib.pIPI
                  tt-it-docto-xml.vipi    = ttIPITrib.vIPI.
       END.

       FIND FIRST ttPISAliq WHERE
                  ttPISAliq.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttPISAliq 
       THEN DO:
          ASSIGN tt-it-docto-xml.cst-pis = ttPISAliq.CST
                 tt-it-docto-xml.vbc-pis = ttPISAliq.vBC
                 tt-it-docto-xml.ppis    = ttPISAliq.pPIS
                 tt-it-docto-xml.vpis    = ttPISAliq.vPIS.
       END.

       FIND FIRST ttCOFINSAliq WHERE
                  ttCOFINSAliq.nItem = ttprod.nitem NO-ERROR.
       IF AVAIL ttCOFINSAliq 
       THEN DO:
          ASSIGN tt-it-docto-xml.cst-cofins =  ttCOFINSAliq.CST  
                 tt-it-docto-xml.vbc-cofins =  ttCOFINSAliq.vBC    
                 tt-it-docto-xml.pcofins    =  ttCOFINSAliq.pCOFINS
                 tt-it-docto-xml.vcofins    =  ttCOFINSAliq.vCOFINS.
       END. 

       FIND FIRST ttInfAdic  NO-ERROR.
       IF AVAIL ttInfAdic THEN
          ASSIGN tt-docto-xml.observacao = ttInfAdic.infCpl.
       
    END.
      
   END.

   /*** Baccin pediu para retirar o CFOP de saida 
   FIND FIRST tt-docto-xml NO-ERROR.

   IF AVAIL tt-docto-xml 
   THEN DO:   

           FOR EACH tt-it-docto-xml WHERE
                    tt-it-docto-xml.arquivo    = tt-docto-xml.arquivo AND 
                    tt-it-docto-xml.serie      = tt-docto-xml.serie   AND 
                    tt-it-docto-xml.nNF        = tt-docto-xml.nNF     AND 
                    tt-it-docto-xml.CNPJ       = tt-docto-xml.CNPJ query-tuning(no-lookahead):

                    /* tratar natur-oper */
                    ASSIGN c-nat-operacao = "".
                                   
                    RUN intprg/int013a.p( input tt-it-docto-xml.cfop,
                                          input tt-it-docto-xml.cst-icms,
                                          input tt-it-docto-xml.cst-ipi,
                                          input tt-docto-xml.cod-estab,
                                          input tt-it-docto-xml.cod-emitente,
                                          input tt-docto-xml.demi,
                                          output c-nat-operacao ).
                        
                    for first natur-oper no-lock where 
                             natur-oper.nat-operacao = c-nat-operacao: 
                    end.
                    if avail natur-oper AND 
                         int(natur-oper.cod-cfop) > 0 
                    then do:
                        ASSIGN c-cfop = string(int(natur-oper.cod-cfop)). 
                     END.
                    ELSE DO:
                       ASSIGN c-cfop = SUBstring(STRING(tt-it-docto-xml.cfop),2,LENGTH(string(tt-it-docto-xml.cfop))). 
                
                       CASE substring(string(tt-it-docto-xml.cfop),1,1):
                                WHEN  "7" THEN ASSIGN c-cfop = "3" + c-cfop.
                                WHEN  "6" THEN ASSIGN c-cfop = "2" + c-cfop.
                                WHEN  "5" THEN ASSIGN c-cfop = "1" + c-cfop.
                       END CASE.

                    END.

                    ASSIGN tt-it-docto-xml.cfop = int(c-cfop).
           END.

           ASSIGN tt-docto-xml.cfop = int(c-cfop). 

    END. ******/

    
END PROCEDURE.



