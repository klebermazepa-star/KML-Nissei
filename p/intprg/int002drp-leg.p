/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i int002drp-leg 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: int002dRP
**
**       DATA....: 11/2015
**
**       OBJETIVO: Integra‡Æo NDD - XML Recebimento - Notas de Transferencia
                   buscando nota fiscal de origem 
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

DEFINE VARIABLE l-int002g-ok AS LOGICAL     NO-UNDO.

create tt-param.
raw-transfer raw-param to tt-param NO-ERROR.

FIND FIRST tt-param NO-ERROR.

IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "c:\temp\INT00drp.txt"
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
DEF VAR de-fator       AS DECIMAL  NO-UNDO.
DEF VAR l-gera-nota    AS LOGICAL NO-UNDO. 
DEF VAR l-transf       AS LOGICAL NO-UNDO.
DEF VAR l-prod         AS LOGICAL NO-UNDO.
DEF VAR h-niveis       AS HANDLE  NO-UNDO.
DEF VAR c-item-do-forn AS CHAR    NO-UNDO.
DEF VAR c-nat-operacao AS CHAR    NO-UNDO.
DEF VAR c-cfop         AS CHAR    NO-UNDO.
DEF VAR c-estab-orig   AS CHAR    NO-UNDO.
DEF VAR c-estab-dest   AS CHAR    NO-UNDO.
DEF VAR d-tot-bicms    LIKE it-nota-fisc.vl-bicms-it NO-UNDO.
DEF VAR d-tot-icms     LIKE it-nota-fisc.vl-icms-it  NO-UNDO.
        
DEF BUFFER b-tt-digita             FOR tt-digita.
DEF BUFFER b-int-ds-it-docto-xml   FOR int-ds-it-docto-xml.
DEF BUFFER b-int-ds-docto-xml      FOR int-ds-docto-xml. 
DEF BUFFER b-NDD_ENRYINTEGRATION_NEW_LEG  FOR NDD_ENRYINTEGRATION_NEW_LEG. 
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


run utp/ut-acomp.p persistent set h-acomp.
    {utp/ut-liter.i Integra‡Æo_Notas_Danf-e * L}
run pi-inicializar in h-acomp (input return-value).

RUN pi-IntegracaoNDD.
    
RUN pi-valida-nota.

DELETE WIDGET-POOL.
 

{include/i-rpclo.i}   

IF VALID-HANDLE(h-acomp) THEN 
   run pi-finalizar in h-acomp.

return "OK":U.


PROCEDURE pi-IntegracaoNDD:

    DEF VAR c-doc       AS LONGCHAR NO-UNDO.
    DEF VAR c-xml       AS CHAR     NO-UNDO.
    DEF VAR c-arquivo   AS CHAR     NO-UNDO.
    DEF VAR h-documento AS HANDLE   NO-UNDO.
    DEF VAR h-raiz      AS HANDLE   NO-UNDO.

    DEF VAR pXMLResult  AS LONGCHAR NO-UNDO. 

    FOR EACH NDD_ENRYINTEGRATION_NEW_LEG NO-LOCK WHERE     
             /*NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATION_NEW_LEGID > 0 AND*/
             NDD_ENRYINTEGRATION_NEW_LEG.emissiondate       >= datetime(08/01/2016) AND
             NDD_ENRYINTEGRATION_NEW_LEG.kind                = 0 /* Envio */    AND   
             NDD_ENRYINTEGRATION_NEW_LEG.status_             = 0 /* campo status pendente */ /*AND
             NDD_ENRYINTEGRATION_NEW_LEG.emissiondate        = DATETIME(08/08/2016)*/
        BY NDD_ENRYINTEGRATION_NEW_LEG.emissiondate:  

        /* FIND FIRST int-ds-docto-xml USE-INDEX idx_arquivo NO-LOCK WHERE
                   int(int-ds-docto-xml.arquivo) = NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATIONID NO-ERROR.
        IF AVAIL int-ds-docto-xml THEN NEXT. 
        */

        empty temp-table tt-docto-xml.
        empty temp-table tt-it-docto-xml.
        EMPTY TEMP-TABLE tt-digita.
                 
        COPY-LOB FROM NDD_ENRYINTEGRATION_NEW_LEG.documentdata TO pXMLResult.

        ASSIGN c-doc = pXMLResult
               c-xml = SESSION:TEMP-DIRECTORY + "xml_temp" + string(ENTRYINTEGRATION_NEW_LEGID) +  ".xml".
                           
        IF SEARCH(c-xml) <> ? THEN
           os-delete value(c-xml) no-wait no-console.  
                           
        RUN SaveXML(INPUT c-doc, 
                    INPUT c-xml).
                 
        ASSIGN i-linha = 0.

        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Integracao :" + STRING(NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATION_NEW_LEGID)).
                                
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
        
            RUN pi-gera-nota (INPUT STRING(NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATION_NEW_LEGID)).
            
                        
            /* Integrar notas direto com o PRS */
    
            RUN intprg/int002g.p (INPUT TABLE tt-param,
                                  INPUT TABLE tt-docto-xml,
                                  INPUT TABLE tt-it-docto-xml,
                                  OUTPUT l-int002g-ok). 
        END.
       
        FIND FIRST tt-docto-xml NO-ERROR.

        IF AVAIL tt-docto-xml AND 
                 tt-docto-xml.tipo-estab <> 3 /* Valida se registro j  existe na base */
        THEN DO:
        
            IF l-transf = YES  
            THEN DO:
            
                FIND FIRST b-NDD_ENRYINTEGRATION_NEW_LEG EXCLUSIVE-LOCK WHERE
                           b-NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATION_NEW_LEGID = NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATION_NEW_LEGID NO-ERROR.
                IF AVAIL b-NDD_ENRYINTEGRATION_NEW_LEG
                THEN DO:

                   ASSIGN b-NDD_ENRYINTEGRATION_NEW_LEG.status_ = 1.
                END.

                RELEASE b-NDD_ENRYINTEGRATION_NEW_LEG.

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
            ASSIGN tt-digita.arquivo = STRING(NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATION_NEW_LEGID) 
                   tt-digita.raiz    = h-niveis:HANDLE:NAME 
                   tt-digita.campo   = p-h-raiz:NAME
                   tt-digita.valor   = h-niveis:NODE-VALUE
                   tt-digita.linha   = i-linha.
                               
            IF tt-digita.campo = "natop" 
            THEN DO:
                
                /* DISP tt-digita.valor 
                     NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATIONID 
                     WITH STREAM-IO FRAME f-natureza WITH WIDTH 333.
                   */

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
              
               IF DATE(c-data) < 07/15/2016 THEN 
                  ASSIGN l-transf = NO.

            END.

            IF VALID-HANDLE(h-acomp) THEN
               RUN pi-acompanhar IN h-acomp(INPUT "Dia: " + string(datetime(NDD_ENRYINTEGRATION_NEW_LEG.emissiondate))).
                     
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
             tt-docto-xml.tipo-estab  = 3 AND 
             tt-docto-xml.observacao  <> "" 
           BREAK BY tt-docto-xml.arquivo : 

        RUN intprg/int999.p (INPUT "NFENDD", 
                             INPUT string(tt-docto-xml.arquivo) + "-" + string(tt-docto-xml.NNF),
                             INPUT tt-docto-xml.observacao,
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
                      ASSIGN tt-docto-xml.tipo-estab = 3 /* Documento j  cadastrado na base */
                             tt-docto-xml.observacao = "Documento j  cadastrado.". 

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
           FIND FIRST param-estoq  NO-ERROR.

           IF AVAIL tt-docto-xml AND 
                    tt-docto-xml.tipo-nota = 3
           THEN DO:   

              EMPTY TEMP-TABLE tt-it-docto-xml.

              ASSIGN c-estab-orig = ""
                     c-estab-dest = "".

              FOR FIRST b-estab NO-LOCK WHERE 
                        b-estab.cgc = tt-docto-xml.CNPJ :  /* Origem */
              END.
              IF AVAIL b-estab THEN
                 ASSIGN c-estab-orig = b-estab.cod-estabel.
                        
              FOR first estab-mat  no-lock where 
                        estab-mat.cod-estabel = c-estab-orig and 
                        estab-mat.cod-estabel = param-estoq.estabel-pad :
              END.

              IF NOT AVAIL estab-mat 
              THEN DO :
                 ASSIGN tt-docto-xml.tipo-estab = 3 
                        tt-docto-xml.observacao = "".  

                 NEXT.

              END.

              FOR FIRST estabelec NO-LOCK WHERE
                        estabelec.cgc = tt-docto-xml.CNPJ-dest :
              END.

              IF AVAIL estabelec THEN
                 ASSIGN c-estab-dest = estabelec.cod-estabel.
              
              FIND FIRST nota-fiscal NO-LOCK WHERE
                         nota-fiscal.cod-estabel      = c-estab-orig          AND
                         nota-fiscal.serie            = tt-docto-xml.serie    AND
                         int(nota-fiscal.nr-nota-fis) = INT(tt-docto-xml.nnf) NO-ERROR.
              IF AVAIL nota-fiscal 
              THEN DO:
                  
                  ASSIGN d-tot-bicms = 0
                         d-tot-icms  = 0.

                  FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK ,
                      FIRST natur-oper NO-LOCK WHERE
                            natur-oper.nat-operacao = it-nota-fisc.nat-operacao :
                               
                      IF VALID-HANDLE(h-acomp) THEN
                          RUN pi-acompanhar IN h-acomp(INPUT "Dia: " + string(datetime(NDD_ENRYINTEGRATION_NEW_LEG.emissiondate))).

                      ASSIGN  d-tot-bicms  = d-tot-bicms  + it-nota-fisc.vl-bicms-it
                              d-tot-icms   = d-tot-icms   + it-nota-fisc.vl-icms-it.
                                            
                      CREATE tt-it-docto-xml.
                      ASSIGN tt-it-docto-xml.arquivo      = tt-docto-xml.arquivo
                             tt-it-docto-xml.tipo-nota    = tt-docto-xml.tipo-nota 
                             tt-it-docto-xml.CNPJ         = tt-docto-xml.CNPJ  
                             tt-it-docto-xml.cod-emitente = nota-fiscal.cod-emitente
                             tt-it-docto-xml.nNF          = tt-docto-xml.nNF      
                             tt-it-docto-xml.serie        = tt-docto-xml.serie
                             tt-it-docto-xml.sequencia    = it-nota-fisc.nr-seq-fat 
                             tt-it-docto-xml.item-do-forn = it-nota-fisc.it-codigo
                             tt-it-docto-xml.it-codigo    = it-nota-fisc.it-codigo
                             tt-it-docto-xml.cfop         = INT(natur-oper.cod-cfop)
                             tt-it-docto-xml.qCom         = it-nota-fisc.qt-faturada[1]   /* int-ds-nota-entrada-produto.nep-quantidade-n               */ 
                             tt-it-docto-xml.vProd        = it-nota-fisc.vl-tot-item      /* int-ds-nota-entrada-produto.nep-valorbruto-n               */
                             tt-it-docto-xml.vtottrib     = it-nota-fisc.vl-merc-liq      /* Vl mercadoria liquida  trocar campo no int002g             */
                             tt-it-docto-xml.vbc-icms     = it-nota-fisc.vl-bicms-it      /* int-ds-nota-entrada-produto.nep-baseicms-n                 */
                             tt-it-docto-xml.vDesc        = it-nota-fisc.vl-desconto      /* int-ds-nota-entrada-produto.nep-valordesconto-n            */
                             tt-it-docto-xml.vicms        = it-nota-fisc.vl-icms-it       /* int-ds-nota-entrada-produto.nep-valoricms-n                */
                             tt-it-docto-xml.vbc-ipi      = it-nota-fisc.vl-bipi-it       /* int-ds-nota-entrada-produto.nep-baseipi-n                  */
                             tt-it-docto-xml.vipi         = it-nota-fisc.vl-ipi-it        /* int-ds-nota-entrada-produto.nep-valoripi-n                 */
                             tt-it-docto-xml.vicmsst      = 0                             /* int-ds-nota-entrada-produto.nep-icmsst-n                   */
                             tt-it-docto-xml.vbcst        = 0                             /* int-ds-nota-entrada-produto.nep-basest-n                   */
                             tt-it-docto-xml.picmsst      = it-nota-fisc.aliquota-icm     /* int-ds-nota-entrada-produto.nep-percentualicms-n           */
                             tt-it-docto-xml.pipi         = it-nota-fisc.aliquota-ipi     /* int-ds-nota-entrada-produto.nep-percentualipi-n            */
                             tt-it-docto-xml.ppis         = natur-oper.perc-pis[1]        /* int-ds-nota-entrada-produto.nep-percentualpis-n            */
                             tt-it-docto-xml.pcofins      = natur-oper.per-fin-soc[1]     /* int-ds-nota-entrada-produto.nep-percentualcofins-n         */
                             tt-it-docto-xml.vbc-pis      = 0                             /* int-ds-nota-entrada-produto.nep-basepis-n                  */
                             tt-it-docto-xml.vpis         = it-nota-fisc.vl-pis           /* int-ds-nota-entrada-produto.nep-valorpis-n                 */
                             tt-it-docto-xml.vbc-cofins   = 0                             /* int-ds-nota-entrada-produto.nep-basecofins-n               */
                             tt-it-docto-xml.vcofins      = it-nota-fisc.vl-finsocial     /* int-ds-nota-entrada-produto.nep-valorcofins-n              */
                             tt-it-docto-xml.num-pedido   = int(nota-fiscal.nr-pedcli)    /* int-ds-nota-entrada-produto.ped-codigo-n                   */
                             tt-it-docto-xml.orig-icms    = 0                             /* nacional 0 importado 1 */  /* int-ds-nota-entrada-produto.nep-csta-n */
                             tt-it-docto-xml.vbcst        = 0                             /* int-ds-nota-entrada-produto.nep-cstb-icm-n                  */
                             tt-it-docto-xml.vbc-ipi      = it-nota-fisc.vl-bipi-it       /* int-ds-nota-entrada-produto.nep-cstb-ipi-n                  */
                             tt-it-docto-xml.vbcstret     = 0                             /* int-ds-nota-entrada-produto.nep-redutorbaseicms-n           */
                             tt-it-docto-xml.item-do-forn = it-nota-fisc.it-codigo.       /* int-ds-nota-entrada-produto.alternativo-fornecedor          */
                             
                            IF it-nota-fisc.cd-trib-icm = 2 THEN
                               ASSIGN tt-it-docto-xml.cst-icms = 40.
                            IF it-nota-fisc.cd-trib-icm = 3 THEN
                               ASSIGN tt-it-docto-xml.cst-icms = 41.
                            ELSE IF it-nota-fisc.cd-trib-icm = 5 THEN
                               ASSIGN tt-it-docto-xml.cst-icms = 51.

                            FOR FIRST fat-ser-lote NO-LOCK WHERE
                                      fat-ser-lote.cod-estabel  = nota-fiscal.cod-estabel and 
                                      fat-ser-lote.serie        = it-nota-fisc.serie      AND
                                      fat-ser-lote.nr-nota-fis  = nota-fiscal.nr-nota-fis AND
                                      fat-ser-lote.nr-seq-fat   = it-nota-fisc.nr-seq-fat :
                            END.

                            IF AVAIL fat-ser-lote THEN
                               ASSIGN tt-it-docto-xml.lote = fat-ser-lote.nr-serlote
                                      tt-it-docto-xml.dval = fat-ser-lote.dt-vali-lote. /* int-ds-nota-entrada-produto.nep-datavalidade-d */ 
                  END.
                  
                  ASSIGN tt-docto-xml.tot-desconto = nota-fiscal.vl-desconto  /*  Desconto total da nota fiscal  */          
                         tt-docto-xml.vbc          = d-tot-bicms              /*  Base ICMS total nota fiscal    */          
                         tt-docto-xml.valor-icms   = d-tot-icms               /*  Valor total do ICMS da nota fiscal    */ 
                         tt-docto-xml.vbc-cst      = 0                         /*  Base ICMS ST */                   
                         tt-docto-xml.valor-st     = 0                         /*  Valor do ICMS ST total da nota */ 
                         tt-docto-xml.VNF          = nota-fiscal.vl-tot-nota  /* Valor total da nota fiscal */
                         tt-docto-xml.observacao   = nota-fiscal.observ-nota + chr(13) + "NDDID: " + STRING(tt-docto-xml.arquivo)  /* Observacao da nota fiscal */
                         tt-docto-xml.chnfe        = nota-fiscal.cod-chave-aces-nf-eletro /* Chave de acesso NFe */               
                         tt-docto-xml.valor-frete  = nota-fiscal.vl-frete                 /* Frete total da nota */
                         tt-docto-xml.valor-seguro = nota-fiscal.vl-seguro                /* Seguro total da nota  */
                         tt-docto-xml.valor-outras = nota-fiscal.val-desp-outros          /* Despesas total da nota */
                         tt-docto-xml.modFrete     = nota-fiscal.ind-tp-frete.             /* Modalidade do frete (0-FOB 1-CIF) */

              END.
              ELSE DO:
                    ASSIGN tt-docto-xml.tipo-estab = 3 
                           tt-docto-xml.observacao = "Nota Fiscal de Sa¡da NÆo cadastrada.". 
              END.
             

              FOR EACH tt-it-docto-xml WHERE
                       tt-it-docto-xml.arquivo    = tt-docto-xml.arquivo AND 
                       tt-it-docto-xml.serie      = tt-docto-xml.serie   AND 
                       tt-it-docto-xml.nNF        = tt-docto-xml.nNF     AND 
                       tt-it-docto-xml.CNPJ       = tt-docto-xml.CNPJ:

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

                         /* DISP tt-it-docto-xml EXCEPT r-rowid arquivo
                       WITH WIDTH 333 1 COL FRAME f-item STREAM-IO DOWN. 
                      DOWN WITH FRAME f-item.
                            */
               END.

               ASSIGN tt-docto-xml.cfop = int(c-cfop). 

           END.

           DISP tt-docto-xml.arquivo FORMAT "X(12)" COLUMN-LABEL "ID NDD"
                tt-docto-xml.nnf
                tt-docto-xml.serie
                c-estab-dest COLUMN-LABEL "Estab"
                tt-docto-xml.demi
                WITH WIDTH 333 STREAM-IO DOWN FRAME f-docto.
            DOWN WITH FRAME f-docto.
       END.

    END.
    
END PROCEDURE.



