/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i int002bRP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: int002bRP
**
**       DATA....: 11/2015
**
**       OBJETIVO: Integra‡Æo NDD - XML Recebimento  Notas Transferˆncias das 
**                 Lojas
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/

{include/i-rpvar.i}
{include/i-rpcab.i}
{utp/ut-glob.i}

{intprg/int002b.i}

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

FIND FIRST tt-param NO-ERROR.

IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "c:\temp\INT002crp.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME
           tt-param.dt-trans-ini    = 07/15/2016 
           tt-param.dt-trans-fin    = TODAY 
           tt-param.i-nro-docto-ini = "0"  
           tt-param.i-nro-docto-fin = "999999999" 
           tt-param.i-cod-emit-ini  = 0 
           tt-param.i-cod-emit-fin  = 999999999. 
ELSE 
    ASSIGN tt-param.arquivo = "c:\temp\INT002crp.txt".
 
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
DEF VAR de-fator       AS DECIMAL  NO-UNDO.
DEF VAR l-gera-nota    AS LOGICAL NO-UNDO. 
DEF VAR l-transf       AS LOGICAL NO-UNDO.
DEF VAR l-prod         AS LOGICAL NO-UNDO.
DEF VAR h-niveis       AS HANDLE  NO-UNDO.
DEF VAR c-item-do-forn AS CHAR    NO-UNDO.
DEF VAR c-nat-operacao AS CHAR    NO-UNDO.
DEF VAR c-cfop         AS CHAR    NO-UNDO.

DEF BUFFER b-tt-digita             FOR tt-digita.
DEF BUFFER b-int-ds-it-docto-xml   FOR int-ds-it-docto-xml.
DEF BUFFER b-int-ds-docto-xml      FOR int-ds-docto-xml. 
DEF BUFFER b-NDD_ENTRYINTEGRATION  FOR NDD_ENTRYINTEGRATION. 

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

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Integra‡Æo_Notas_Transf_Danf-e * L}
run pi-inicializar in h-acomp (input return-value).

IF l-altera = NO 
THEN DO:

   RUN pi-IntegracaoNDD.
    
   IF l-transf = YES THEN 
      RUN pi-valida-nota.

   empty temp-table tt-docto-xml.
   empty temp-table tt-it-docto-xml.

  
END.

DELETE WIDGET-POOL.
 
procedure pi-grava-nota:
          
    FOR EACH tt-docto-xml USE-INDEX tp-estab-emis WHERE    
             tt-docto-xml.tipo-estab    = 1                        AND  
             tt-docto-xml.dEmi         >= date(STRING(tt-param.dt-trans-ini,"99/99/9999"))  AND 
             tt-docto-xml.dEmi         <= DATE(STRING(tt-param.dt-trans-fin,"99/99/9999"))  AND 
             tt-docto-xml.NNF          >= tt-param.i-nro-docto-ini AND 
             tt-docto-xml.NNF          <= tt-param.i-nro-docto-fin AND
             tt-docto-xml.cod-emitente >= tt-param.i-cod-emit-ini  AND 
             tt-docto-xml.cod-emitente <= tt-param.i-cod-emit-fin 
        BREAK BY tt-docto-xml.arquivo :
    
        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Nota :" + STRING(tt-docto-xml.NNF)).
        
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
                 int-ds-doc-erro.sequencia    = 0:
           
            DELETE int-ds-doc-erro.
                 
        END.
        
        IF l-altera = NO THEN DO:
        
          CREATE int-ds-docto-xml.
          BUFFER-COPY tt-docto-xml TO int-ds-docto-xml.
          ASSIGN int-ds-docto-xml.id_sequencial = NEXT-VALUE(seq-int-ds-docto-xml).

        END.
        
        ASSIGN int-ds-docto-xml.situacao = 2
               int-ds-docto-xml.chnfe      = IF tt-docto-xml.chnfe      = ? then "" else tt-docto-xml.chnfe  
               int-ds-docto-xml.xnome      = IF tt-docto-xml.xnome      = ? then "" else tt-docto-xml.xnome
               int-ds-docto-xml.modFrete   = IF tt-docto-xml.modFrete   = ? then 0  else tt-docto-xml.modFrete
               int-ds-docto-xml.num-pedido = IF tt-docto-xml.num-pedido = ? then 0  else tt-docto-xml.num-pedido.     
                 
    
        FIND FIRST serie WHERE 
                   serie.serie = tt-docto-xml.serie NO-LOCK NO-ERROR.
        IF NOT AVAIL serie THEN DO:
    
            RUN pi-gera-erro(INPUT 1,    
                             INPUT "S‚rie NÆo cadastrada").   
    
        END.    

        FIND FIRST natur-oper NO-LOCK WHERE
                   natur-oper.nat-operacao = int-ds-docto-xml.nat-operacao NO-ERROR.
        IF NOT AVAIL natur-oper 
        THEN DO:

           RUN pi-gera-erro(INPUT 9,    
                            INPUT "Natureza de Opera‡Æo Nota" + string(int-ds-docto-xml.nat-operacao) + " nÆo cadastrada!"). 

        END.
    
        FIND FIRST emitente NO-LOCK WHERE
                   emitente.cgc = tt-docto-xml.CNPJ NO-ERROR.
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
        IF AVAIL estabelec THEN
           ASSIGN int-ds-docto-xml.cod-estab = estabelec.cod-estabel
                  int-ds-docto-xml.ep-codigo = int(estabelec.ep-codigo).
        ELSE DO:
           RUN pi-gera-erro(INPUT 3,    
                            INPUT "Estabelecimento nÆo cadastrado com o CNPJ " + STRING(tt-docto-xml.CNPJ-dest)).
    
        END. 
                                         
        FOR EACH tt-it-docto-xml WHERE
                 tt-it-docto-xml.tipo-nota  = tt-docto-xml.tipo-nota AND
                 tt-it-docto-xml.CNPJ       = tt-docto-xml.CNPJ      AND
                 tt-it-docto-xml.nNF        = tt-docto-xml.nNF       AND
                 tt-it-docto-xml.serie      = tt-docto-xml.serie
             by  tt-it-docto-xml.sequencia   :
    
            FOR EACH int-ds-doc-erro EXCLUSIVE-LOCK WHERE
                     int-ds-doc-erro.serie-docto  = tt-docto-xml.serie        AND 
                     int-ds-doc-erro.cod-emitente = tt-docto-xml.cod-emitente AND
                     int-ds-doc-erro.CNPJ         = tt-docto-xml.CNPJ         AND    
                     int-ds-doc-erro.nro-docto    = tt-docto-xml.NNF          AND 
                     int-ds-doc-erro.tipo-nota    = tt-docto-xml.tipo-nota    AND 
                     int-ds-doc-erro.sequencia    = tt-it-docto-xml.sequencia:
           
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
                   int-ds-it-docto-xml.xprod         = IF tt-it-docto-xml.xprod           = ? then ""   else  tt-it-docto-xml.xprod   
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
                   int-ds-it-docto-xml.item-do-forn  = if tt-it-docto-xml.item-do-forn    = ? then ""   else  tt-it-docto-xml.item-do-forn  
                   int-ds-it-docto-xml.uCom-forn     = if tt-it-docto-xml.uCom-forn       = ? then ""   else  tt-it-docto-xml.uCom-forn     
                   int-ds-it-docto-xml.qCom-forn     = if tt-it-docto-xml.qCom-forn       = ? then 0    else  tt-it-docto-xml.qCom-forn  
                   int-ds-it-docto-xml.narrativa     = if tt-it-docto-xml.narrativa       = "0" then "" else  tt-it-docto-xml.narrativa
                   int-ds-it-docto-xml.lote          = if tt-it-docto-xml.lote            = ?   then "" else  tt-it-docto-xml.lote.     
           

            FOR FIRST natur-oper NO-LOCK WHERE
                      natur-oper.nat-operacao = (tt-it-docto-xml.nat-operacao):

            END.

            IF NOT AVAIL natur-oper 
            THEN DO:

               RUN pi-gera-erro(INPUT 8,    
                                INPUT "Natureza de Opera‡Æo do item" + string(tt-it-docto-xml.nat-operacao) + " nÆo cadastrada!"). 

            END.
                         
            FOR FIRST ITEM NO-LOCK  where  
                      item.it-codigo = tt-it-docto-xml.it-codigo :

            END.

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
                        int-ds-it-docto-xml.xprod = item.desc-item
                        tt-it-docto-xml.xprod     = item.desc-item.  
            END.
            ELSE DO:
              RUN pi-gera-erro(INPUT 7,    
                               INPUT "Item NÆo cadastrado " + string(tt-it-docto-xml.it-codigo)). 
            END.

            RELEASE int-ds-it-docto-xml.
        END.
        
        IF LAST-OF(tt-docto-xml.arquivo) 
        THEN DO:
               FOR EACH int-ds-doc-erro NO-LOCK WHERE
                        int-ds-doc-erro.serie-docto  = tt-docto-xml.serie        AND 
                        int-ds-doc-erro.CNPJ         = tt-docto-xml.CNPJ         AND    
                        int(int-ds-doc-erro.nro-docto) = int(tt-docto-xml.NNF)   AND 
                        int-ds-doc-erro.tipo-nota    = tt-docto-xml.tipo-nota  
                   BY int-ds-doc-erro.CNPJ
                   BY int-ds-doc-erro.nro-docto
                   BY int-ds-doc-erro.cod-erro:
                                     
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
   
    
end.

{include/i-rpclo.i}   

IF VALID-HANDLE(h-acomp) THEN 
   run pi-finalizar in h-acomp.

return "OK":U.

    
PROCEDURE pi-gera-erro:

DEF INPUT PARAM p-cod-erro     LIKE int-ds-doc-erro.cod-erro.
DEF INPUT PARAM p-desc-erro    LIKE int-ds-doc-erro.descricao.
 
     FIND FIRST int-ds-doc-erro NO-LOCK WHERE
                int-ds-doc-erro.serie-docto  = tt-docto-xml.serie  AND 
                int-ds-doc-erro.cod-emitente = tt-docto-xml.cod-emitente AND
                int-ds-doc-erro.CNPJ         = tt-docto-xml.CNPJ  AND 
                int-ds-doc-erro.nro-docto    = tt-docto-xml.nNF   AND 
                int-ds-doc-erro.tipo-nota    = tt-docto-xml.tipo-nota  AND
                int-ds-doc-erro.descricao    = p-desc-erro  NO-ERROR.
     IF NOT AVAIL int-ds-doc-erro THEN DO:
    
        CREATE int-ds-doc-erro.
        ASSIGN int-ds-doc-erro.serie-docto  = tt-docto-xml.serie       
               int-ds-doc-erro.cod-emitente = tt-docto-xml.cod-emitente
               int-ds-doc-erro.CNPJ         = tt-docto-xml.CNPJ 
               int-ds-doc-erro.nro-docto    = tt-docto-xml.nNF   
               int-ds-doc-erro.tipo-nota    = tt-docto-xml.tipo-nota  
               int-ds-doc-erro.tipo-erro    = "ErroXML"   
               int-ds-doc-erro.cod-erro     = p-cod-erro       
               int-ds-doc-erro.descricao    = p-desc-erro.
    
        IF AVAIL int-ds-it-docto-xml THEN 
           ASSIGN int-ds-doc-erro.sequencia = int-ds-it-docto-xml.sequencia.
    
     END.
           
     IF AVAIL int-ds-docto-xml THEN
        ASSIGN int-ds-docto-xml.situacao = 1.
        
     if avail int-ds-it-docto-xml 
     then do:
          assign int-ds-it-docto-xml.situacao = 1.
     end.   
 
END PROCEDURE. 

PROCEDURE pi-notas-pepsico:
 
   FOR EACH int-ds-docto-xml NO-LOCK WHERE
            int-ds-docto-xml.tipo-docto = 4 AND 
            int-ds-docto-xml.tipo-estab = 1 AND 
            int-ds-docto-xml.chnfe      = ? :

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
                  int-ds-it-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota :   
                  
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
                      tt-it-docto-xml.item-do-forn  = if int-ds-it-docto-xml.item-do-forn    = ? then ""   else  int-ds-it-docto-xml.item-do-forn  
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

    DEF VAR pXMLResult  AS LONGCHAR NO-UNDO. 

    FOR EACH NDD_ENTRYINTEGRATION NO-LOCK WHERE     
             NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID > 0     AND
             NDD_ENTRYINTEGRATION.kind    = 0 /* Envio */    AND   
             NDD_ENTRYINTEGRATION.status_ = 0 /* campo status pendente */
        BY NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID DESCENDING:  

        /* FIND FIRST int-ds-docto-xml USE-INDEX idx_arquivo NO-LOCK WHERE
                   int(int-ds-docto-xml.arquivo) = NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID NO-ERROR.
        IF AVAIL int-ds-docto-xml THEN NEXT. 
        */

        empty temp-table tt-docto-xml.
        empty temp-table tt-it-docto-xml.
        EMPTY TEMP-TABLE tt-digita.


        COPY-LOB FROM NDD_ENTRYINTEGRATION.documentdata TO pXMLResult.

        ASSIGN c-doc = pXMLResult
               c-xml = SESSION:TEMP-DIRECTORY + "xml_temp" + string(ENTRYINTEGRATIONID) +  ".xml".
                           
        IF SEARCH(c-xml) <> ? THEN
           os-delete value(c-xml) no-wait no-console.  
                           
        RUN SaveXML(INPUT c-doc, 
                    INPUT c-xml).

        ASSIGN i-linha = 0.

        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Integracao :" + STRING(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID)).
                                
       /* Abertura para a leitura do arquivo XML */
        CREATE X-DOCUMENT h-documento.
        h-documento:LOAD("file",c-xml,FALSE) NO-ERROR.

        CREATE X-NODEREF h-raiz.
        h-documento:GET-DOCUMENT-ELEMENT(h-raiz).

        ASSIGN l-transf = YES
               l-prod   = NO.

        RUN pi-busca-subniveis(INPUT h-raiz).
        
        IF l-transf = YES 
        THEN DO:
        
            RUN pi-gera-nota (INPUT STRING(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID)).
           
            /* run pi-grava-nota. */
                  
        END.
       
        FIND FIRST tt-docto-xml NO-ERROR.

        IF AVAIL tt-docto-xml AND 
                 tt-docto-xml.tipo-estab <> 3 /* Valida se registro j  existe na base */
        THEN DO:
        
            IF l-transf = YES  
            THEN DO:
            
                /* FIND FIRST b-NDD_ENTRYINTEGRATION EXCLUSIVE-LOCK WHERE
                           b-NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID = NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID NO-ERROR.
                IF AVAIL b-NDD_ENTRYINTEGRATION 
                THEN DO:
                
                   ASSIGN b-NDD_ENTRYINTEGRATION.status_ = 1.     
                END.
    
                RELEASE b-NDD_ENTRYINTEGRATION. */

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


PROCEDURE pi-busca-subniveis :

DEFINE INPUT PARAMETER p-h-raiz AS HANDLE      NO-UNDO.
DEFINE VARIABLE i-qtd-niveis    AS INTEGER     NO-UNDO.

DEFINE VAR c-raiz AS char.
             
    CREATE X-NODEREF h-niveis.
                     
    DO i-qtd-niveis = 1 TO p-h-raiz:NUM-CHILDREN:

        p-h-raiz:GET-CHILD(h-niveis,i-qtd-niveis).

            ASSIGN i-linha = i-linha + 1.

            CREATE tt-digita.
            ASSIGN tt-digita.arquivo = STRING(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID) 
                   tt-digita.raiz    = h-niveis:HANDLE:NAME 
                   tt-digita.campo   = p-h-raiz:NAME
                   tt-digita.valor   = h-niveis:NODE-VALUE
                   tt-digita.linha   = i-linha.
                               
            IF tt-digita.campo = "natop" 
            THEN DO:
                
                IF tt-digita.valor BEGINS "Transf" THEN 
                    ASSIGN l-transf = YES.
                ELSE 
                    ASSIGN l-transf = NO. 

            END. 

            IF tt-digita.campo = "prod" 
            THEN DO:
                
                ASSIGN l-prod = YES.
                                         
            END. 

            IF tt-digita.campo = "dhEmi" /* Desconsiderar notas antes de 07/15/2016 */
            THEN DO:

               ASSIGN c-data = SUBSTRING(tt-digita.valor,1,10)
                      c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-").
              
               IF DATE(c-data) < 08/01/2016 THEN 
                  ASSIGN l-transf = NO.

            END.

            IF VALID-HANDLE(h-acomp) THEN
               RUN pi-acompanhar IN h-acomp(INPUT "Nota :" + STRING(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID) + " " + tt-digita.campo + " " + tt-digita.valor ).
                     
            FIND FIRST b-tt-digita WHERE
                       b-tt-digita.raiz = tt-digita.campo and
                       LENGTH(b-tt-digita.node) = 0 NO-ERROR.
            IF AVAIL b-tt-digita AND
                     index(tt-digita.raiz,"#") > 0  
            THEN DO:
               ASSIGN tt-digita.node   = b-tt-digita.campo
                      b-tt-digita.node = "achou".
            END.
        
        IF l-transf = YES AND  
           l-prod   = NO THEN
           RUN pi-busca-subniveis(INPUT h-niveis:HANDLE). 
    END.

END PROCEDURE.

PROCEDURE pi-valida-nota:
    
    
    FOR EACH tt-docto-xml WHERE    
             tt-docto-xml.tipo-estab    = 3                        
           BREAK BY tt-docto-xml.arquivo : 

        RUN intprg/int999.p (INPUT "NFENDD", 
                             INPUT string(tt-docto-xml.arquivo) + "-" + string(tt-docto-xml.NNF),
                             INPUT "Documento j  cadastrado",
                             INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                             INPUT c-seg-usuario).
    END.

END.

   
PROCEDURE pi-gera-nota:

DEF INPUT PARAMETER p-arquivo AS CHAR.
    
    FOR EACH tt-digita  WHERE
             tt-digita.arquivo = p-arquivo   AND
             LENGTH(tt-digita.valor) > 0  
        BREAK BY tt-digita.arquivo
              BY tt-digita.linha:

        /* DISP tt-digita.node 
             tt-digita.campo
            string(tt-digita.valor) FORMAT "x(60)"
           WITH WIDTH 333.
          */

       IF FIRST-OF(tt-digita.arquivo)
       THEN DO: 
          CREATE tt-docto-xml.
          ASSIGN tt-docto-xml.arquivo   = tt-digita.arquivo
                 tt-docto-xml.ep-codigo = int(i-ep-codigo-usuario).
    
          ASSIGN i-seq-item = 0.
          
       END.
       
       IF tt-digita.node = "ide" 
       THEN DO: 
          CASE tt-digita.campo:
                  WHEN "serie"  THEN DO: 
                      ASSIGN tt-docto-xml.serie  = string(tt-digita.valor).

                      IF tt-docto-xml.serie = "" THEN 
                         ASSIGN tt-docto-xml.serie = "1". 

                      ASSIGN tt-docto-xml.serie = STRING(INT(tt-digita.valor)) NO-ERROR.
    
                      IF ERROR-STATUS:ERROR = YES 
                      THEN DO:
                         DO i-cont = 1 TO LENGTH(tt-digita.valor):
                            IF LOOKUP(SUBSTRING(tt-digita.valor,i-cont,1),c-lista) = 0 THEN
                               ASSIGN tt-docto-xml.serie = tt-docto-xml.serie + SUBSTRING(tt-digita.valor,i-cont,1).  
                         END.
                      END.

                      IF LENGTH(tt-docto-xml.serie) > 3
                      THEN DO:
                         ASSIGN tt-docto-xml.serie = SUBSTRING(tt-docto-xml.serie,1,3).
                      END.
                              
                  END.
                  WHEN "nNF" THEN DO :
                      IF LENGTH(TRIM(tt-digita.valor)) < 8 THEN
                         ASSIGN tt-docto-xml.nNF = string(int(tt-digita.valor),"9999999").
                      ELSE 
                         ASSIGN tt-docto-xml.nNF = string(int(tt-digita.valor),"99999999").
                  END.
                  WHEN "dhEmi" THEN do:
                      
                      ASSIGN c-data = SUBSTRING(tt-digita.valor,1,10)
                             c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                             tt-docto-xml.dEmi       =  DATE(c-data)
                             tt-docto-xml.dt-trans   = TODAY
                             tt-docto-xml.tipo-docto = 1.
                  END.
          END CASE.
       END. 
       ELSE IF tt-digita.node = "emit"
       THEN DO:
           CASE tt-digita.campo:
             WHEN "CNPJ"   THEN DO: 
                 ASSIGN tt-docto-xml.CNPJ   = STRING(tt-digita.valor). 

                 FIND FIRST estabelec NO-LOCK WHERE
                            estabelec.cgc = tt-docto-xml.CNPJ NO-ERROR.
                 IF AVAIL estabelec THEN 
                    ASSIGN tt-docto-xml.tipo-nota = 3. /* NFT */
                
                 FIND FIRST emitente NO-LOCK WHERE 
                            emitente.cgc = trim(tt-docto-xml.cnpj) AND 
                            emitente.cod-emitente > 0  NO-ERROR.
                IF AVAIL emitente THEN 
                   ASSIGN tt-docto-xml.cod-emitente = emitente.cod-emitente.
                
             END.
             WHEN "xNome"  THEN ASSIGN tt-docto-xml.xNome  = STRING(tt-digita.valor).  


           END CASE.
       END.
       ELSE IF tt-digita.node = "dest" 
       THEN DO:
           CASE tt-digita.campo:
               WHEN "CNPJ" THEN DO:
                   ASSIGN tt-docto-xml.CNPJ-dest   = STRING(tt-digita.valor)
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
                             b-int-ds-docto-xml.cod-emitente = tt-docto-xml.cod-emitente AND  
                             int(b-int-ds-docto-xml.nNF)     = int(tt-docto-xml.nNF)     AND
                             b-int-ds-docto-xml.serie        = tt-docto-xml.serie:

                   END.
                           
                   IF AVAIL b-int-ds-docto-xml THEN
                      ASSIGN tt-docto-xml.tipo-estab = 3. /* Documento j  cadastrado na base */

               END.

           END CASE.
       END.
       ELSE IF tt-digita.node = "infprot"
       THEN DO:
           CASE tt-digita.campo:
             WHEN "chNfe" THEN ASSIGN tt-docto-xml.chNfe = STRING(tt-digita.valor).
           END CASE.
       END. 
       ELSE IF tt-digita.node = "ICMSTot" THEN DO:
           
           IF tt-digita.campo <> "" THEN
              ASSIGN tt-digita.valor = (REPLACE(tt-digita.valor,".",",")). 
                                
           CASE tt-digita.campo:
             WHEN "VNF"        THEN ASSIGN tt-docto-xml.VNF            = dec(STRING(tt-digita.valor)).   
             WHEN "vBC"        THEN ASSIGN tt-docto-xml.vbc            = dec(STRING(tt-digita.valor)).
             WHEN "vDesc"      THEN ASSIGN tt-docto-xml.tot-desconto   = dec(STRING(tt-digita.valor)).
             WHEN "vFrete"     THEN ASSIGN tt-docto-xml.valor-frete    = dec(STRING(tt-digita.valor)).
             WHEN "vProd"      THEN ASSIGN tt-docto-xml.valor-mercad   = dec(STRING(tt-digita.valor)).
             WHEN "vOutro"     THEN ASSIGN tt-docto-xml.valor-outras   = dec(STRING(tt-digita.valor)).
             WHEN "vSeg"       THEN ASSIGN tt-docto-xml.valor-seguro   = dec(STRING(tt-digita.valor)).
             WHEN "vICMS"      THEN ASSIGN tt-docto-xml.valor-icms     = dec(STRING(tt-digita.valor)).
             WHEN "vICMSDeson" THEN ASSIGN tt-docto-xml.valor-icms-des = dec(STRING(tt-digita.valor)). 
             WHEN "vBCST"      THEN ASSIGN tt-docto-xml.vbc-cst        = dec(STRING(tt-digita.valor)).
             WHEN "vST"        THEN ASSIGN tt-docto-xml.valor-st       = dec(STRING(tt-digita.valor)).
             WHEN "vII"        THEN ASSIGN tt-docto-xml.valor-ii       = dec(STRING(tt-digita.valor)).
             WHEN "vIPI"       THEN ASSIGN tt-docto-xml.valor-ipi      = dec(STRING(tt-digita.valor)).
             WHEN "vPIS"       THEN ASSIGN tt-docto-xml.valor-pis      = dec(STRING(tt-digita.valor)).
             WHEN "vCOFINS"    THEN ASSIGN tt-docto-xml.valor-cofins   = dec(STRING(tt-digita.valor)).

           END CASE.
       END.
       ELSE IF tt-digita.node = "transp"
       THEN DO:
           CASE tt-digita.campo:
             WHEN "modFrete" THEN ASSIGN tt-docto-xml.modFrete = int(STRING(tt-digita.valor)).
           END CASE.
       END.
       ELSE IF tt-digita.node = "prod" 
       THEN DO:
           FIND LAST  tt-it-docto-xml NO-ERROR.
    
           IF tt-digita.campo = "qCom"  OR 
              tt-digita.campo = "VProd" OR 
              tt-digita.campo = "Vdesc" THEN
              ASSIGN tt-digita.valor = (REPLACE(tt-digita.valor,".",",")). 
           
           CASE tt-digita.campo: 
               
              WHEN "cProd" THEN DO:
                 ASSIGN i-seq-item = i-seq-item + 10.
                
                 CREATE tt-it-docto-xml.
                 ASSIGN tt-it-docto-xml.arquivo      = tt-docto-xml.arquivo
                        tt-it-docto-xml.serie        = tt-docto-xml.serie  
                        tt-it-docto-xml.nNF          = tt-docto-xml.nNF    
                        tt-it-docto-xml.CNPJ         = tt-docto-xml.CNPJ
                        tt-it-docto-xml.tipo-nota    = tt-docto-xml.tipo-nota
                        tt-it-docto-xml.item-do-forn = STRING(tt-digita.valor)
                        tt-it-docto-xml.sequencia    = i-seq-item.
              END.
              
              WHEN "xProd"  THEN ASSIGN tt-it-docto-xml.xProd      = STRING(tt-digita.valor).
              WHEN "ncm"    THEN ASSIGN tt-it-docto-xml.ncm        = INT(STRING(tt-digita.valor)).
              WHEN "cfop"   THEN ASSIGN tt-it-docto-xml.cfop       = INT(STRING(tt-digita.valor)).     
              WHEN "uCom"   THEN ASSIGN tt-it-docto-xml.uCom       = STRING(tt-digita.valor)
                                        tt-it-docto-xml.uCom-forn  = STRING(tt-digita.valor).
              WHEN "qCom"   THEN ASSIGN tt-it-docto-xml.qCom       = dec(STRING(tt-digita.valor))
                                        tt-it-docto-xml.qCom-forn  = dec(STRING(tt-digita.valor)).
              WHEN "vUnCom" THEN ASSIGN tt-it-docto-xml.vUnCom     = dec(STRING(tt-digita.valor)) / 10000000000. 
              WHEN "vProd"  THEN ASSIGN tt-it-docto-xml.vProd      = dec(STRING(tt-digita.valor)).
              WHEN "vDesc"  THEN ASSIGN tt-it-docto-xml.vDesc      = dec(STRING(tt-digita.valor)).  
              WHEN "xPed"   THEN ASSIGN tt-it-docto-xml.num-pedido = INT(STRING(tt-digita.valor)).  
    
           END CASE.
    
       END. 
       ELSE IF tt-digita.node = "med" 
       THEN DO:

           CASE tt-digita.campo: 
                WHEN "nLote"    THEN ASSIGN tt-it-docto-xml.lote = STRING(tt-digita.valor).
                WHEN "dfab" THEN do :

                    ASSIGN c-data = SUBSTRING(tt-digita.valor,1,10)
                           c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                           tt-it-docto-xml.dFab  =  DATE(c-data).
                END.
                WHEN "dval" THEN do :

                    ASSIGN c-data = SUBSTRING(tt-digita.valor,1,10)
                           c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                           tt-it-docto-xml.dVal  =  DATE(c-data).
                END.

           END CASE.

       END.
       ELSE IF tt-digita.node = "imposto" 
       THEN DO:
          
           FIND LAST  tt-it-docto-xml NO-ERROR.

           if tt-digita.campo = "vtottrib" THEN
               ASSIGN  tt-digita.valor = (REPLACE(tt-digita.valor,".",",")).
                      tt-it-docto-xml.vtotTrib = dec(STRING(tt-digita.valor)).  

       END.
       ELSE IF tt-digita.node BEGINS "ICMS" 
       THEN DO:
          
           FIND LAST  tt-it-docto-xml NO-ERROR.

            if tt-digita.campo <> "orig"  AND
               tt-digita.campo <> "CST"   AND 
               tt-digita.campo <> "modBC" AND 
               tt-digita.campo <> "modBCST" 
            THEN
              ASSIGN tt-digita.valor = (REPLACE(tt-digita.valor,".",",")).

           CASE tt-digita.campo: 
                WHEN "orig"       THEN ASSIGN tt-it-docto-xml.orig-icms   = int(STRING(tt-digita.valor)).
                WHEN "CST"        THEN ASSIGN tt-it-docto-xml.cst-icms    = int(STRING(tt-digita.valor)).
                WHEN "modBC"      THEN ASSIGN tt-it-docto-xml.modBC       = int(STRING(tt-digita.valor)).
                WHEN "vBC"        THEN ASSIGN tt-it-docto-xml.vbc-icms    = dec(STRING(tt-digita.valor)). 
                WHEN "pICMS"      THEN ASSIGN tt-it-docto-xml.picms       = dec(STRING(tt-digita.valor)). 
                WHEN "vICMS"      THEN ASSIGN tt-it-docto-xml.vicms       = dec(STRING(tt-digita.valor)). 
                WHEN "modBCST"    THEN ASSIGN tt-it-docto-xml.modbcst     = int(STRING(tt-digita.valor)).  
                WHEN "pMVAST"     THEN ASSIGN tt-it-docto-xml.pmvast      = dec(STRING(tt-digita.valor)). 
                WHEN "vBCST"      THEN ASSIGN tt-it-docto-xml.vbcst       = dec(STRING(tt-digita.valor)). 
                WHEN "pICMSST"    THEN ASSIGN tt-it-docto-xml.picmsst     = dec(STRING(tt-digita.valor)).  
                WHEN "vICMSST"    THEN ASSIGN tt-it-docto-xml.vicmsst     = dec(STRING(tt-digita.valor)). 
                WHEN "vBCSTRet"   THEN ASSIGN tt-it-docto-xml.vbcstret    = dec(STRING(tt-digita.valor)). 
                WHEN "vICMSSTRet" THEN ASSIGN tt-it-docto-xml.vicmsstret  = dec(STRING(tt-digita.valor)). 
           END CASE.

       END.
       ELSE IF tt-digita.node BEGINS "IPI" 
       THEN DO:

            if tt-digita.campo <> "cEnq" AND 
               tt-digita.campo <> "CST"  AND 
               tt-digita.campo <> "vBC" 
            THEN
              ASSIGN tt-digita.valor = (REPLACE(tt-digita.valor,".",",")).
          
           FIND LAST  tt-it-docto-xml NO-ERROR.

            CASE tt-digita.campo: 
                WHEN "cEnq"        THEN ASSIGN tt-it-docto-xml.cenq     = int(STRING(tt-digita.valor,"99")).
                WHEN "CST"         THEN ASSIGN tt-it-docto-xml.cst-ipi  = int(STRING(tt-digita.valor)).
                WHEN "vBC"         THEN ASSIGN tt-it-docto-xml.vbc-ipi  = int(STRING(tt-digita.valor)).
                WHEN "pIPI"        THEN ASSIGN tt-it-docto-xml.pipi     = int(STRING(tt-digita.valor)).     
                WHEN "vIPI"        THEN ASSIGN tt-it-docto-xml.vipi     = int(STRING(tt-digita.valor)).
           END CASE.

       END.
       ELSE IF tt-digita.node BEGINS "PISAliq" 
       THEN DO:
          
           FIND LAST  tt-it-docto-xml NO-ERROR.

           if tt-digita.campo <> "CST" THEN
              ASSIGN tt-digita.valor = (REPLACE(tt-digita.valor,".",",")).

           CASE tt-digita.campo: 
                WHEN "CST"    THEN ASSIGN tt-it-docto-xml.cst-pis = int(STRING(tt-digita.valor)).
                WHEN "vBC"    THEN ASSIGN tt-it-docto-xml.vbc-pis = dec(STRING(tt-digita.valor)).
                WHEN "pPIS"   THEN ASSIGN tt-it-docto-xml.ppis    = dec(STRING(tt-digita.valor)).
                WHEN "vPIS"   THEN ASSIGN tt-it-docto-xml.vpis    = dec(STRING(tt-digita.valor)).
           END CASE.

       END.
       ELSE IF tt-digita.node BEGINS "COFINSAliq" 
       THEN DO:
          
           FIND LAST  tt-it-docto-xml NO-ERROR.

           if tt-digita.campo <> "CST" THEN
              ASSIGN tt-digita.valor = (REPLACE(tt-digita.valor,".",",")).

            CASE tt-digita.campo: 
                WHEN "CST"      THEN ASSIGN tt-it-docto-xml.cst-cofins = int(STRING(tt-digita.valor)).
                WHEN "vBC"      THEN ASSIGN tt-it-docto-xml.vbc-cofins = dec(STRING(tt-digita.valor)).
                WHEN "pCOFINS"  THEN ASSIGN tt-it-docto-xml.pcofins    = dec(STRING(tt-digita.valor)).
                WHEN "vCOFINS"  THEN ASSIGN tt-it-docto-xml.vcofins    = dec(STRING(tt-digita.valor)).
                
           END CASE.

       END. 
       ELSE IF tt-digita.node = "compra" THEN DO:

           CASE tt-digita.campo: 
               
              WHEN "xPed" THEN DO:

                 ASSIGN tt-docto-xml.num-pedido = INT(STRING(tt-digita.valor)). 
                      
                 FOR EACH tt-it-docto-xml WHERE
                          tt-it-docto-xml.arquivo    = tt-docto-xml.arquivo AND 
                          tt-it-docto-xml.serie      = tt-docto-xml.serie   AND 
                          tt-it-docto-xml.nNF        = tt-docto-xml.nNF     AND 
                          tt-it-docto-xml.CNPJ       = tt-docto-xml.CNPJ    AND 
                          tt-it-docto-xml.num-pedido = 0 :

                     ASSIGN tt-it-docto-xml.num-pedido = INT(STRING(tt-digita.valor)).
                          
                  END.  

              END.

           END.
       END.
       ELSE IF tt-digita.node = "infAdic" THEN DO:
            CASE tt-digita.campo: 
                WHEN "infCpl" THEN ASSIGN tt-docto-xml.observacao = STRING(tt-digita.valor).
            END CASE.

       END.

       IF LAST(tt-digita.arquivo)
       THEN DO:
           FIND FIRST tt-docto-xml NO-ERROR.

           IF AVAIL tt-docto-xml 
           THEN DO:   

              

             

           END.
            
       END.

    END.
    
END PROCEDURE.



