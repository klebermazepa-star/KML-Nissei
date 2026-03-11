/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int037RP 2.12.00.001 } /* */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i int037RP MOF}
&ENDIF
 
{include/i_fnctrad.i}
{utp/ut-glob.i}
/********************************************************************************
** Copyright DATASUL S.A. (2004)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

/****************************************************************************
**
**  PROGRAMA: Lista notas-CD-ID-NDD
**
**       DATA....: 08/2016
**
**       OBJETIVO: Verifica o ID NDD com as Notas do CD
**
**       VERSAO..: 2.06.001
**
******************************************************************************/

/*** defini‡Æo de pre-processador ***/
{cdp/cdcfgdis.i} 

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    FIELD dt-periodo-ini   AS DATE FORMAT "99/99/9999"
    FIELD dt-periodo-fim   AS DATE FORMAT "99/99/9999"
    FIELD cod-estabel-ini  AS CHAR format "x(05)"
    FIELD cod-estabel-fim  AS CHAR FORMAT "x(03)"
    FIELD ndd-id-ini       AS DEC        
    FIELD ndd-id-fim       AS DEC
    FIELD rs-tipo          AS INTEGER.

DEFINE TEMP-TABLE tt-digita
    FIELD arquivo AS CHAR
    FIELD raiz    AS CHAR 
    FIELD node    AS CHAR
    FIELD campo   AS CHAR FORMAT "X(100)"
    FIELD valor   AS CHAR FORMAT "X(100)"
    FIELD linha   AS INTEGER.

DEFINE TEMP-TABLE tt-estab
FIELD cod-estabel LIKE estabelec.cod-estabel
FIELD cgc         LIKE estabelec.cgc. 

DEF BUFFER b-tt-digita             FOR tt-digita.

/*** defini‡Æo de vari veis locais ***/
DEF VAR h-acomp    AS HANDLE  NO-UNDO.
DEF VAR i-linha    AS INTEGER NO-UNDO.
DEF VAR l-transf   AS LOGICAL NO-UNDO.
DEF VAR l-prod     AS LOGICAL NO-UNDO.
DEF VAR i-seq-item AS INTEGER NO-UNDO.
DEF VAR c-lista    AS CHAR INITIAL "1,2,3,4,5,6,7,8,9,10".
DEF VAR c-data     AS CHAR    NO-UNDO.
DEF VAR i-cont     AS INTEGER.
DEF VAR i-pos      AS INTEGER.
DEF VAR h-niveis   AS HANDLE  NO-UNDO.
DEF VAR c-id-ndd     AS CHAR.
DEF VAR c-nome-emit   AS CHAR NO-UNDO.
def var c-saida       as char format "x(40)" no-undo.
def var c-estabel     like estabelec.nome    no-undo.
DEF VAR c-desc-docto   AS CHAR NO-UNDO.
DEF VAR c-item-do-forn AS CHAR     NO-UNDO.
DEF VAR r-row-item      AS ROWID   NO-UNDO.

def temp-table tt-raw-digita NO-UNDO
    field raw-digita as raw.

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

{include/i-rpvar.i}

form   
    skip (04)
    "SELE€ÇO"  at 10  skip(01)
    tt-param.dt-periodo-ini    label "Per¡odo."         at 30 "|<    >|" at 50
    tt-param.dt-periodo-fim    no-label                 at 63 skip(1)
    "PAR¶METROS" at 10 skip(1)
    tt-param.cod-estabel-ini label "Estabelecimento"  colon 34 "|<    >|" AT 50
    tt-param.cod-estabel-fim NO-LABEL                          SKIP
    tt-param.rs-tipo        label "Modo Execu‡Æo"     colon 34 skip
    skip(1)
    "IMPRESSÇO" at 10  skip(1)
    c-saida label "Destino"                        colon 34  
    tt-param.usuario  label "Usu rio"              colon 34 
    with side-labels stream-io frame f-resumo.


run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Int037 - Lista notas NDD").

FIND FIRST param-global NO-ERROR.

FIND FIRST mgcad.empresa NO-LOCK WHERE
                 empresa.ep-codigo = param-global.empresa-prin NO-ERROR.

if avail empresa then 
   assign c-empresa   = string(empresa.ep-codigo) 
          c-estabel   = empresa.razao-social.

{utp/ut-liter.i INTEGRA€ÇO NDD  * r }
assign c-sistema  = return-value.

/* {include/i-rpout.i &page-size = 0} */

/* {include/i-rpvar.i} */
/* {include/i-rpcab.i} */


DEF TEMP-TABLE tt-nota-proc NO-UNDO
FIELD tipo-nota  LIKE  int-ds-docto-xml.tipo-nota
FIELD CNPJ       LIKE  int-ds-docto-xml.CNPJ     
FIELD nNF        LIKE  int-ds-docto-xml.nNF   
FIELD serie      LIKE  int-ds-docto-xml.serie.    

DEF TEMP-TABLE tt-docto-xml  NO-UNDO LIKE int-ds-docto-xml
FIELD r-rowid AS ROWID
    INDEX tp-estab-emis
            tipo-estab  
            dEmi         
            NNF         
            cod-emitente.

DEF TEMP-TABLE tt-it-docto-xml NO-UNDO LIKE int-ds-it-docto-xml
field cEAN as dec format "99999999999999"
/*FIELD vicmsDeson  like  int-ds-it-docto-xml.vicmsstret*/
/*FIELD pRedBC      AS DEC FORMAT "zzz,zzz,zz9.9999"*/
FIELD r-rowid AS ROWID
    INDEX idx_it_docto_xml
       cod-emitente
       serie
       nnf
       tipo-nota
       sequencia.

DEF TEMP-TABLE tt-xml  NO-UNDO LIKE int-ds-docto-xml
FIELD tipo-reg AS CHAR
FIELD r-rowid  AS ROWID
    INDEX tp-estab-emis
            tipo-estab  
            dEmi         
            NNF         
            cod-emitente.

DEF TEMP-TABLE tt-it-xml NO-UNDO LIKE int-ds-it-docto-xml
FIELD tipo-reg    AS CHAR
field cEAN as dec format "99999999999999"
/*FIELD vicmsDeson  like  int-ds-it-docto-xml.vicmsstret*/
/*FIELD pRedBC      AS DEC FORMAT "zzz,zzz,zz9.9999"*/
FIELD r-rowid AS ROWID
    INDEX idx_it_docto_xml
       cod-emitente
       serie
       nnf
       tipo-nota
       sequencia.


{intprg/int500.i}

CREATE WIDGET-POOL.
    
DEFINE TEMP-TABLE tt-cfop NO-UNDO
FIELD cod-cfop LIKE int-ds-it-docto-xml.cfop
FIELD indice   AS INTEGER.


def var c-acompanha     as char    no-undo.

DEF VAR c-nom-arq  AS CHAR    NO-UNDO.
DEF VAR c-comando  AS CHAR    NO-UNDO.


DEF VAR i-orig-icms   like  int-ds-it-docto-xml.orig-icms. 
DEF VAR i-cst-icms    like  int-ds-it-docto-xml.cst-icms. 
DEF VAR i-modBC       like  int-ds-it-docto-xml.modBC.     
DEF VAR i-vbc-icms    like  int-ds-it-docto-xml.vbc-icms.  
DEF VAR i-picms       like  int-ds-it-docto-xml.picms.     
DEF VAR i-vicms       like  int-ds-it-docto-xml.vicms.     
DEF VAR i-modbcst     like  int-ds-it-docto-xml.modbcst.   
DEF VAR i-pmvast      like  int-ds-it-docto-xml.pmvast.    
DEF VAR i-vbcst       AS DEC format "zzzz,zzz,zzz,zz9.99".    
DEF VAR i-picmsst     like  int-ds-it-docto-xml.picmsst.   
DEF VAR i-vicmsst     like  int-ds-it-docto-xml.vicmsst.   
DEF VAR i-vbcstret    like  int-ds-it-docto-xml.vbcstret.  
DEF VAR i-vicmsstret  like  int-ds-it-docto-xml.vicmsstret.
DEF VAR i-vicmsdeson   AS DEC format "zzzz,zzz,zzz,zz9.99".
DEF VAR i-pRedBC      LIKE  int-ds-it-docto-xml.vicmsstret.

DEF VAR i-num-pedido  AS     INTEGER.
DEF VAR c-linha       AS     CHAR.
DEF VAR de-aliq-pis   LIKE int-ds-it-docto-xml.ppis.

DEF STREAM s-capa.
DEF STREAM s-item.


DEF BUFFER b-int-ds-it-docto-xml   FOR int-ds-it-docto-xml.
DEF BUFFER b-int-ds-docto-xml      FOR int-ds-docto-xml. 
DEF BUFFER b-NDD_ENTRYINTEGRATION  FOR NDD_ENTRYINTEGRATION. 
DEF BUFFER b-estab                 FOR estabelec.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first mgcad.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.


DEF TEMP-TABLE tt-ndd NO-UNDO 
FIELD numID        AS DECIMAL
FIELD tipo-reg     AS CHAR
FIELD documentdata LIKE ndd_ENTRYINTEGRATION.DOCUMENTDATA
FIELD STATUS_      LIKE ndd_ENTRYINTEGRATION.STATUS_
FIELD KIND         LIKE ndd_ENTRYINTEGRATION.kind.

FIND FIRST tt-param NO-ERROR.
                     
FOR EACH NDD_ENTRYINTEGRATION NO-LOCK WHERE 
        (NDD_ENTRYINTEGRATION.emissiondate        = DATETIME(?)OR  
         NDD_ENTRYINTEGRATION.emissiondate       >= DATETIME(tt-param.dt-periodo-ini)  AND 
         NDD_ENTRYINTEGRATION.emissiondate       <= DATETIME(tt-param.dt-periodo-fim)) AND  
         NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID >= tt-param.ndd-id-ini AND
         NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID <= tt-param.ndd-id-fim AND
         NDD_ENTRYINTEGRATION.kind     = 0 AND 
         NDD_ENTRYINTEGRATION.STATUS_  = 1 query-tuning(no-lookahead):

  IF NDD_ENTRYINTEGRATION.serie = 10 THEN NEXT.

   IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "ID NDD:" + STRING(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID)).

  CREATE tt-ndd.
  ASSIGN tt-ndd.numID         = NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID
         tt-ndd.tipo-reg      = "Novo" 
         tt-ndd.documentdata  = ndd_ENTRYINTEGRATION.DOCUMENTDATA
         tt-ndd.STATUS_       = NDD_ENTRYINTEGRATION.STATUS_
         tt-ndd.KIND          = NDD_ENTRYINTEGRATION.kind.
END.


FOR EACH NDD_ENRYINTEGRATION_new_leg NO-LOCK WHERE 
        (NDD_ENRYINTEGRATION_new_leg.emissiondate        = DATETIME(?)OR  
         NDD_ENRYINTEGRATION_new_leg.emissiondate       >= DATETIME(tt-param.dt-periodo-ini)  AND 
         NDD_ENRYINTEGRATION_new_leg.emissiondate       <= DATETIME(tt-param.dt-periodo-fim)) AND  
         NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATION_NEW_LEGID >= tt-param.ndd-id-ini        AND
         NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATION_NEW_LEGID <= tt-param.ndd-id-fim        AND
         NDD_ENRYINTEGRATION_new_leg.kind     = 0 AND 
         NDD_ENRYINTEGRATION_new_leg.STATUS_  = 1 query-tuning(no-lookahead):

  IF NDD_ENRYINTEGRATION_new_leg.serie = 10 THEN NEXT.

     IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "ID NDD:" + STRING(NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATION_NEW_LEGID)).

  CREATE tt-ndd.
  ASSIGN tt-ndd.numID         = NDD_ENRYINTEGRATION_NEW_LEG.ENTRYINTEGRATION_NEW_LEGID
         tt-ndd.tipo-reg      = "Legado" 
         tt-ndd.documentdata  = NDD_ENRYINTEGRATION_new_leg.DOCUMENTDATA
         tt-ndd.STATUS_       = NDD_ENRYINTEGRATION_new_leg.STATUS_
         tt-ndd.KIND          = NDD_ENRYINTEGRATION_new_leg.kind.
END.


output to value(tt-param.arquivo) page-size 0 convert target "iso8859-1".

DISP "Arquivos Gerados: " + "t:\Lista-notas-CD-ID-capa.txt" + " e " + "t:\Lista-notas-CD-ID-Itens.txt" SKIP(1) 
      WITH FRAME f-param STREAM-IO WIDTH 333.   

OUTPUT STREAM s-capa TO "t:\Lista-notas-CD-ID-capa.txt" CONVERT TARGET "iso8859-1"  PAGE-SIZE 0.

OUTPUT STREAM s-Item TO "t:\Lista-notas-CD-ID-Itens.txt" CONVERT TARGET "iso8859-1" PAGE-SIZE 0.

RUN pi-IntegracaoNDD.

OUTPUT STREAM s-capa CLOSE.
OUTPUT STREAM s-item CLOSE.

{include/i-rpclo.i}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U.
                      
PROCEDURE pi-IntegracaoNDD:

    DEF VAR c-doc       AS LONGCHAR NO-UNDO.
    DEF VAR c-xml       AS CHAR     NO-UNDO.
    DEF VAR c-arquivo   AS CHAR     NO-UNDO.
    DEF VAR h-documento AS HANDLE   NO-UNDO.
    DEF VAR h-raiz      AS HANDLE   NO-UNDO.
    DEF VAR c-arq-log   AS CHAR     NO-UNDO. 
    

    DEF VAR pXMLResult  AS LONGCHAR NO-UNDO. 

    FOR EACH tt-ndd NO-LOCK query-tuning(no-lookahead)  
          BY tt-ndd.numID :
        
        RUN pi-acompanhar IN h-acomp(INPUT "ID NDD:" + STRING(tt-ndd.numID)).

        empty temp-table tt-docto-xml.
        empty temp-table tt-it-docto-xml.
        EMPTY TEMP-TABLE tt-digita.

        COPY-LOB FROM tt-ndd.documentdata TO pXMLResult.

        ASSIGN c-doc = pXMLResult
               c-xml = SESSION:TEMP-DIRECTORY + "xml_temp" + string(tt-ndd.numID) +  ".xml".
                           
        IF SEARCH(c-xml) <> ? THEN
           os-delete value(c-xml) no-wait no-console.  
                           
        RUN SaveXML(INPUT c-doc, 
                    INPUT c-xml).
        
        ASSIGN i-linha = 0.

        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Integracao :" + STRING(tt-ndd.numID)).
                                
        run pi-gera-nota(INPUT STRING(tt-ndd.numID),
                         INPUT c-xml).

        FIND FIRST ttide no-error.
         
         IF AVAIL ttide THEN do:
             IF ttide.natop BEGINS "Transf" THEN ASSIGN l-transf = YES.
             ELSE 
                ASSIGN l-transf = NO.
         END.
         ELSE
            ASSIGN l-transf = YES.

        FIND FIRST tt-docto-xml WHERE
                   tt-docto-xml.valor-cofins > 0 AND   
                   (tt-docto-xml.tipo-estab = 1 OR 
                    tt-docto-xml.tipo-estab = 3)  NO-ERROR.  /* Apenas notas do CD */
        IF AVAIL tt-docto-xml 
        THEN DO: 
            
            RUN pi-acompanhar IN h-acomp(INPUT "Nota :" + STRING(tt-docto-xml.nnf)).

            IF l-transf = NO 
            THEN DO:
                          
                   CREATE tt-xml.
                   ASSIGN tt-xml.tipo-reg = "XML"
                          tt-xml.tipo-estab          =  tt-docto-xml.tipo-estab      
                          tt-xml.cod-emitente        =  tt-docto-xml.cod-emitente    
                          tt-xml.cnpj                =  tt-docto-xml.cnpj            
                          tt-xml.cod-estab           =  tt-docto-xml.cod-estab       
                          tt-xml.nnf                 =  tt-docto-xml.nnf             
                          tt-xml.serie               =  tt-docto-xml.serie           
                          tt-xml.nat-operacao        =  tt-docto-xml.nat-operacao    
                          tt-xml.demi                =  tt-docto-xml.demi            
                          tt-xml.VNF                 =  tt-docto-xml.VNF             
                          tt-xml.tot-desconto        =  tt-docto-xml.tot-desconto    
                          tt-xml.valor-outras        =  tt-docto-xml.valor-outras    
                          tt-xml.vbc                 =  tt-docto-xml.vbc             
                          tt-xml.valor-icms          =  tt-docto-xml.valor-icms      
                          tt-xml.vbc-cst             =  tt-docto-xml.vbc-cst         
                          tt-xml.valor-st            =  tt-docto-xml.valor-st        
                          tt-xml.valor-ipi           =  tt-docto-xml.valor-ipi       
                          tt-xml.valor-pis           =  tt-docto-xml.valor-pis       
                          tt-xml.valor-cofins        =  tt-docto-xml.valor-cofins.
                     
                   FOR FIRST int-ds-docto-xml NO-LOCK WHERE
                             int-ds-docto-xml.tipo-nota = tt-docto-xml.tipo-nota AND
                             int-ds-docto-xml.CNPJ      = tt-docto-xml.CNPJ      AND
                         int(int-ds-docto-xml.nNF)      = int(tt-docto-xml.nNF)  AND
                             int-ds-docto-xml.serie     = tt-docto-xml.serie :
                           
                          CREATE tt-xml.
                          ASSIGN tt-xml.tipo-reg = "Int02"
                                 tt-xml.tipo-estab         =  int-ds-docto-xml.tipo-estab     
                                 tt-xml.cod-emitente       =  int-ds-docto-xml.cod-emitente   
                                 tt-xml.cnpj               =  int-ds-docto-xml.cnpj           
                                 tt-xml.cod-estab          =  int-ds-docto-xml.cod-estab      
                                 tt-xml.nnf                =  int-ds-docto-xml.nnf            
                                 tt-xml.serie              =  int-ds-docto-xml.serie          
                                 tt-xml.nat-operacao       =  int-ds-docto-xml.nat-operacao   
                                 tt-xml.demi               =  int-ds-docto-xml.demi           
                                 tt-xml.VNF                =  int-ds-docto-xml.VNF            
                                 tt-xml.tot-desconto       =  int-ds-docto-xml.tot-desconto   
                                 tt-xml.valor-outras       =  int-ds-docto-xml.valor-outras   
                                 tt-xml.vbc                =  int-ds-docto-xml.vbc            
                                 tt-xml.valor-icms         =  int-ds-docto-xml.valor-icms     
                                 tt-xml.vbc-cst            =  int-ds-docto-xml.vbc-cst        
                                 tt-xml.valor-st           =  int-ds-docto-xml.valor-st       
                                 tt-xml.valor-ipi          =  int-ds-docto-xml.valor-ipi      
                                 tt-xml.valor-pis          =  int-ds-docto-xml.valor-pis      
                                 tt-xml.valor-cofins       =  int-ds-docto-xml.valor-cofins.
                   END. 

                   /* FOR EACH tt-xml:

                        DISP  STREAM s-capa
                            tt-xml.tipo-reg       COLUMN-LABEL "Tipo"          
                            tt-xml.tipo-estab     COLUMN-LABEL "Estab"
                            tt-xml.cod-emitente   COLUMN-LABEL "Emitente"
                            tt-xml.cnpj           COLUMN-LABEL "CNPJ"
                            tt-xml.cod-estab      COLUMN-LABEL "Dest."
                            tt-xml.nnf            COLUMN-LABEL "Documento" FORMAT "x(10)"
                            tt-xml.serie          COLUMN-LABEL "Serie"
                            tt-xml.nat-operacao   COLUMN-LABEL "Naturza"
                            tt-xml.demi           COLUMN-LABEL "EmissÆo"
                            tt-xml.VNF            COLUMN-LABEL "Vlr Total"
                            tt-xml.tot-desconto   COLUMN-LABEL "Desconto"
                            tt-xml.valor-outras   COLUMN-LABEL "Outros"
                            tt-xml.vbc            COLUMN-LABEL "BC ICMS"
                            tt-xml.valor-icms     COLUMN-LABEL "Vlr ICMS"
                            tt-xml.vbc-cst        COLUMN-LABEL "BC ICMS ST"
                            tt-xml.valor-st       COLUMN-LABEL "Vlr ST"
                            tt-xml.valor-ipi      COLUMN-LABEL "Vlr IPI"
                            tt-xml.valor-pis      COLUMN-LABEL "Vlr Pis"
                            tt-xml.valor-cofins   COLUMN-LABEL "Vlr Cofins"
                            0                               COLUMN-LABEL "Deson"
                            tt-ndd.numID    COLUMN-LABEL "NDD ID" FORMAT ">>>>>>>>9"
                            tt-ndd.status_  COLUMN-LABEL "Sit"    SKIP 
                            WITH WIDTH 640 DOWN STREAM-IO FRAME f-docto.
                           DOWN WITH FRAME f-docto.
                        
                   END. */

                   EMPTY TEMP-TABLE tt-xml.
                   EMPTY TEMP-TABLE tt-it-xml.

                   FOR EACH tt-it-docto-xml WHERE
                            tt-it-docto-xml.serie  = tt-docto-xml.serie  AND   
                            tt-it-docto-xml.nnf    = tt-docto-xml.nnf    AND 
                            tt-it-docto-xml.cnpj   = tt-docto-xml.cnpj   
                        BY  tt-it-docto-xml.sequencia:

                        ASSIGN c-item-do-forn = "".

                        FOR FIRST int-ds-it-docto-xml WHERE
                                  int-ds-it-docto-xml.tipo-nota     = tt-it-docto-xml.tipo-nota AND
                                  int-ds-it-docto-xml.CNPJ          = tt-it-docto-xml.CNPJ      AND
                               int(int-ds-it-docto-xml.nNF)         = int(tt-it-docto-xml.nNF)  AND
                                   int-ds-it-docto-xml.serie        = tt-it-docto-xml.serie     AND
                                   int-ds-it-docto-xml.item-do-forn   = trim(string(tt-it-docto-xml.item-do-forn)): 
                                   
                        END.
                    
                        IF NOT AVAIL int-ds-it-docto-xml THEN DO:

                            ASSIGN c-item-do-forn = TRIM(string(int(tt-it-docto-xml.item-do-forn))) NO-ERROR.

                           IF ERROR-STATUS:ERROR THEN
                             ASSIGN c-item-do-forn = STRING(tt-it-docto-xml.item-do-forn).

                           FOR FIRST int-ds-it-docto-xml WHERE
                                    int-ds-it-docto-xml.tipo-nota    = tt-it-docto-xml.tipo-nota AND
                                    int-ds-it-docto-xml.CNPJ         = tt-it-docto-xml.CNPJ      AND
                                   int(int-ds-it-docto-xml.nNF)      = int(tt-it-docto-xml.nNF)  AND
                                    int-ds-it-docto-xml.serie        = tt-it-docto-xml.serie     AND
                                    int-ds-it-docto-xml.item-do-forn = c-item-do-forn            :
                               
                            END.

                        END.
                        
                        CREATE tt-it-xml.
                        ASSIGN tt-it-xml.tipo-reg     =  "XML"
                               tt-it-xml.CNPJ         =  tt-it-docto-xml.CNPJ         
                               tt-it-xml.nNF          =  tt-it-docto-xml.nNF         
                               tt-it-xml.cEAN         =  tt-it-docto-xml.cEAN        
                               tt-it-xml.item-do-forn =  tt-it-docto-xml.item-do-forn
                               tt-it-xml.xprod        =  substring(tt-it-docto-xml.xprod,1,60)       
                               tt-it-xml.qCom         =  tt-it-docto-xml.qCom  
                               tt-it-xml.qCom-forn    =  tt-it-docto-xml.qCom-forn
                               tt-it-xml.vUnCom       =  tt-it-docto-xml.vUnCom      
                               tt-it-xml.vProd        =  tt-it-docto-xml.vProd       
                               tt-it-xml.CFOP         =  tt-it-docto-xml.CFOP        
                               tt-it-xml.pICMS        =  tt-it-docto-xml.pICMS       
                               tt-it-xml.vBC-icms     =  tt-it-docto-xml.vBC-icms       
                               tt-it-xml.vICMS        =  tt-it-docto-xml.vICMS       
                               tt-it-xml.vBCST        =  tt-it-docto-xml.vBCST       
                               tt-it-xml.vICMSST      =  tt-it-docto-xml.vICMSST     
                               tt-it-xml.pCOFINS      =  tt-it-docto-xml.pCOFINS     
                               tt-it-xml.vBC-cofins   =  tt-it-docto-xml.vBC-cofins         
                               tt-it-xml.vCOFINS      =  tt-it-docto-xml.vCOFINS     
                               tt-it-xml.pPIS         =  tt-it-docto-xml.pPIS        
                               tt-it-xml.vBC-pis      =  tt-it-docto-xml.vBC-pis         
                               tt-it-xml.vPIS         =  tt-it-docto-xml.vPIS        
                               tt-it-xml.pIPI         =  tt-it-docto-xml.pIPI          
                               tt-it-xml.vBC-ipi      =  tt-it-docto-xml.vBC-ipi         
                               tt-it-xml.vIPI         =  tt-it-docto-xml.vIPI        
                               tt-it-xml.vICMSDeson   =  tt-it-docto-xml.vICMSDeson  
                               tt-it-xml.pRedBC       =  tt-it-docto-xml.pRedBC.     
                           
                       /* IF AVAIL int-ds-it-docto-xml 
                       THEN DO: 

                           CREATE tt-it-xml.
                           ASSIGN tt-it-xml.tipo-reg     =  "Int02"
                                  tt-it-xml.CNPJ         =  int-ds-it-docto-xml.CNPJ         
                                  tt-it-xml.nNF          =  int-ds-it-docto-xml.nNF         
                                  tt-it-xml.cEAN         =  0        
                                  tt-it-xml.item-do-forn =  int-ds-it-docto-xml.item-do-forn
                                  tt-it-xml.xprod        =  int-ds-it-docto-xml.xprod       
                                  tt-it-xml.qCom         =  int-ds-it-docto-xml.qCom 
                                  tt-it-xml.qCom-forn    =  int-ds-it-docto-xml.qCom-forn 
                                  tt-it-xml.vUnCom       =  int-ds-it-docto-xml.vUnCom      
                                  tt-it-xml.vProd        =  int-ds-it-docto-xml.vProd       
                                  tt-it-xml.CFOP         =  int-ds-it-docto-xml.CFOP        
                                  tt-it-xml.pICMS        =  int-ds-it-docto-xml.pICMS       
                                  tt-it-xml.vBC-icms     =  int-ds-it-docto-xml.vBC-icms         
                                  tt-it-xml.vICMS        =  int-ds-it-docto-xml.vICMS       
                                  tt-it-xml.vBCST        =  int-ds-it-docto-xml.vBCST       
                                  tt-it-xml.vICMSST      =  int-ds-it-docto-xml.vICMSST     
                                  tt-it-xml.pCOFINS      =  int-ds-it-docto-xml.pCOFINS     
                                  tt-it-xml.vBC-cofins   =  int-ds-it-docto-xml.vBC-cofins         
                                  tt-it-xml.vCOFINS      =  int-ds-it-docto-xml.vCOFINS     
                                  tt-it-xml.pPIS         =  int-ds-it-docto-xml.pPIS        
                                  tt-it-xml.vBC-pis      =  int-ds-it-docto-xml.vBC-pis         
                                  tt-it-xml.vPIS         =  int-ds-it-docto-xml.vPIS        
                                  tt-it-xml.pIPI         =  int-ds-it-docto-xml.pIPI          
                                  tt-it-xml.vBC-ipi      =  int-ds-it-docto-xml.vBC-ipi         
                                  tt-it-xml.vIPI         =  int-ds-it-docto-xml.vIPI        
                                  tt-it-xml.vICMSDeson   =  0  
                                  tt-it-xml.pRedBC       =  0. 
                       END. */

                   END. /* TT-ITEM */

                   FOR EACH tt-it-xml:

                        DISP  STREAM s-item tt-it-xml.tipo-reg COLUMN-LABEL "Tipo"    FORMAT "X(05)"     AT 01
                                        tt-it-xml.CNPJ          COLUMN-LABEL "CNPJ"
                                        tt-it-xml.nNF           COLUMN-LABEL "Documento"  FORMAT "x(10)"
                                        tt-it-xml.cEAN          COLUMN-LABEL "CEAN"      
                                        tt-it-xml.item-do-forn  COLUMN-LABEL "CProd"      FORMAT "X(20)"
                                        tt-it-xml.xprod         COLUMN-LABEL "xProd"      FORMAT "X(20)"
                                        tt-it-xml.qCom-forn     COLUMN-LABEL "qCom-forn" FORMAT ">>>>,>>9.99"
                                        tt-it-xml.vUnCom        COLUMN-LABEL "vUnCom"    
                                        tt-it-xml.vProd         COLUMN-LABEL "vProd"	
                                        tt-it-xml.CFOP          COLUMN-LABEL "CFOP"
                                        tt-it-xml.pICMS         COLUMN-LABEL "pICMS"
                                        tt-it-xml.vBC-icms      COLUMN-LABEL "vBC"	     FORMAT ">>>>,>>9.99"  
                                        tt-it-xml.vICMS         COLUMN-LABEL "vICMS"	 FORMAT ">>>>,>>9.99"  
                                        tt-it-xml.vBCST         COLUMN-LABEL "vBCST"	 FORMAT ">>>>,>>9.99"  
                                        tt-it-xml.vICMSST       COLUMN-LABEL "vICMSST"   FORMAT ">>>>,>>9.99"
                                        tt-it-xml.pCOFINS       COLUMN-LABEL "pCOFINS"   
                                        tt-it-xml.vBC-cofins    COLUMN-LABEL "vBC"       FORMAT ">>>>,>>9.99"  
                                        tt-it-xml.vCOFINS       COLUMN-LABEL "vCOFINS"   FORMAT ">>>>,>>9.99"
                                        tt-it-xml.pPIS          COLUMN-LABEL "pPIS"	
                                        tt-it-xml.vBC-pis       COLUMN-LABEL "vBC"	     FORMAT ">>>>,>>9.99"  
                                        tt-it-xml.vPIS          COLUMN-LABEL "vPIS"	     FORMAT ">>>>,>>9.99"
                                        tt-it-xml.pIPI          COLUMN-LABEL "pIPI"	
                                        tt-it-xml.vBC-ipi       COLUMN-LABEL "vBC"	      FORMAT ">>>>,>>9.99"  
                                        tt-it-xml.vIPI          COLUMN-LABEL "vIPI"	      FORMAT ">>>>,>>9.99"
                                        tt-it-xml.vICMSDeson    COLUMN-LABEL "vICMSDeson" FORMAT ">>>>,>>9.99"	
                                        tt-it-xml.pRedBC        COLUMN-LABEL "pRedBC"     FORMAT ">>9.99"
                                        WITH WIDTH 640 DOWN STREAM-IO FRAME f-xml.
                                        DOWN WITH FRAME f-xml. 
                   END.

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
  EMPTY temp-table ttExporta.
 
  EMPTY TEMP-TABLE ttmed.
  EMPTY TEMP-TABLE ttInfprot.
  EMPTY TEMP-TABLE ttcompra.
  
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
    dataset dsChave:empty-dataset no-error.

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

    assign retOK = dataset dsChave:read-xml(cSourceType,
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
                  ASSIGN tt-docto-xml.tipo-estab   = 3 /* Documento j  cadastrado na base */
                         tt-docto-xml.nat-operacao = b-int-ds-docto-xml.nat-operacao
                         tt-docto-xml.situacao     = b-int-ds-docto-xml.situacao.
                   
               FIND FIRST tt-nota-proc WHERE 
                          tt-nota-proc.tipo-nota = tt-docto-xml.tipo-nota AND  
                          tt-nota-proc.CNPJ      = tt-docto-xml.CNPJ      AND
                          int(tt-nota-proc.nNF)  = int(tt-docto-xml.nNF)  AND
                          tt-nota-proc.serie     = tt-docto-xml.serie NO-ERROR.
               IF NOT AVAIL tt-nota-proc THEN DO:
                  CREATE tt-nota-proc.
                  ASSIGN tt-nota-proc.tipo-nota = tt-docto-xml.tipo-nota 
                         tt-nota-proc.CNPJ      = tt-docto-xml.CNPJ      
                         tt-nota-proc.nNF       = tt-docto-xml.nNF     
                         tt-nota-proc.serie     = tt-docto-xml.serie. 
               END.
               ELSE
                   ASSIGN tt-docto-xml.tipo-estab = 4.
                           
               IF tt-docto-xml.tipo-estab = 2
               THEN DO:
                     
                     FOR FIRST int-ds-nota-entrada NO-LOCK WHERE
                               int-ds-nota-entrada.nen-cnpj-origem-s = tt-docto-xml.CNPJ     AND 
                               int-ds-nota-entrada.nen-serie-s       = tt-docto-xml.serie    AND 
                               int-ds-nota-entrada.nen-notafiscal-n  = int(tt-docto-xml.nnf) AND 
                               int-ds-nota-entrada.nen-cfop-n        = tt-docto-xml.cfop:
                     END.

                     IF AVAIL int-ds-nota-entrada THEN
                        ASSIGN tt-docto-xml.tipo-estab = 4.
               END. 

          END.
           
        FOR FIRST ttinfprot :

        END.
        IF AVAIL ttinfprot 
        THEN DO:
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

          ASSIGN tt-docto-xml.num-pedido = i-num-pedido.

        END.
                          
        FOR EACH ttprod 
            BY ttprod.nitem :
                    
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
                      tt-it-docto-xml.cean          = ttprod.cean
                      tt-it-docto-xml.ncm           = INT(STRING(ttprod.ncm))             
                      tt-it-docto-xml.cfop          = INT(STRING(ttprod.cfop))                 
                      tt-it-docto-xml.uCom          = STRING(ttprod.uCom)                        
                      tt-it-docto-xml.uCom-forn     = STRING(ttprod.uCom)                    
                      tt-it-docto-xml.qCom          = dec(ttprod.qCom)                    
                      tt-it-docto-xml.qCom-forn     = ttprod.qCom             
                      tt-it-docto-xml.vUnCom        = dec(ttprod.vUnCom)   
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
                  i-vicmsstret  = 0
                  i-vicmsdeson  = 0
                  i-pRedBC      = 0.
    
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
                      i-vicmsstret  = ttICMS40.vicmsstret
                      i-vicmsdeson  = ttICMS40.vICMSDeson 
                      i-pRedBC      = ttICMS40.pRedBC.   
                      
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
                      i-vicmsstret  = ttICMS51.vicmsstret
                      i-vicmsdeson  = ttICMS51.vICMSDeson 
                      i-pRedBC     = ttICMS51.pRedBC. 
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
                      i-vicmsstret  = ttICMS70.vicmsstret
                      i-pRedBC     = ttICMS70.pRedBC.  
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
                      i-vicmsstret  = ttICMS90.vicmsstret
                      i-pRedBC     = ttICMS90.pRedBC.

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
                     i-vicmsst     = ttICMSSN201.vicmsst
                     i-pRedBC     = ttICMSSN201.pRedBC.
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
                     i-vicmsst     = ttICMSSN202.vicmsst
                     i-pRedBC     = ttICMSSN202.pRedBC.
           END.
    
           FIND FIRST ttICMSSN500 WHERE 
                      ttICMSSN500.nItem = ttprod.nitem NO-ERROR.
           IF AVAIL ttICMSSN500 
           THEN DO:
    
              ASSIGN i-orig-icms   = ttICMSSN500.orig
                     i-vbcstret    = ttICMSSN500.vbcstret   
                     i-vicmsstret  = ttICMSSN500.vicmsstret
                     i-pRedBC      = ttICMSSN500.pRedBC.
                      
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
                     i-vicmsst     = ttICMSSN900.vicmsst
                     i-pRedBC      = ttICMSSN900.pRedBC.
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
                  tt-it-docto-xml.vicmsstret    = i-vicmsstret
                  tt-it-docto-xml.vicmsdeson    = i-vICMSDeson 
                  tt-it-docto-xml.pRedBC        = i-pRedBC.


             
    
           FIND FIRST ttIPITrib WHERE
                      ttIPITrib.nItem = ttprod.nitem NO-ERROR.
    
           IF AVAIL ttIPITrib THEN DO:
    
               ASSIGN tt-it-docto-xml.cst-ipi = ttIPITrib.CST
                      tt-it-docto-xml.vbc-ipi = ttIPITrib.vBC
                      tt-it-docto-xml.pipi    = ttIPITrib.pIPI
                      tt-it-docto-xml.vipi    = ttIPITrib.vIPI.
           END.

           ASSIGN tt-it-docto-xml.cst-pis    = 0
                  tt-it-docto-xml.vbc-pis    = 0
                  tt-it-docto-xml.ppis       = 0
                  tt-it-docto-xml.vpis       = 0
                  tt-it-docto-xml.cst-cofins = 0 
                  tt-it-docto-xml.vbc-cofins = 0 
                  tt-it-docto-xml.pcofins    = 0 
                  tt-it-docto-xml.vcofins    = 0.

          FIND FIRST ttPISAliq WHERE
                     ttPISAliq.nItem = ttprod.nitem NO-ERROR.
          IF AVAIL ttPISAliq 
          THEN DO:
                  
              ASSIGN tt-it-docto-xml.cst-pis = ttPISAliq.CST
                     tt-it-docto-xml.vbc-pis = ttPISAliq.vBC
                     tt-it-docto-xml.ppis    = ttPISAliq.pPIS
                     tt-it-docto-xml.vpis    = ttPISAliq.vPIS.
                 
            
              FIND FIRST ttCOFINSAliq WHERE
                         ttCOFINSAliq.nItem = ttprod.nitem NO-ERROR.
              IF AVAIL ttCOFINSAliq 
              THEN DO:
                    ASSIGN tt-it-docto-xml.cst-cofins =  ttCOFINSAliq.CST  
                           tt-it-docto-xml.vbc-cofins =  ttCOFINSAliq.vBC    
                           tt-it-docto-xml.pcofins    =  ttCOFINSAliq.pCOFINS
                           tt-it-docto-xml.vcofins    =  ttCOFINSAliq.vCOFINS.
              END. 

           END.
            
        END. /* each tt-prod */
       
        FOR FIRST ttInfAdic :
        end. 
           IF AVAIL ttInfAdic THEN DO:
              ASSIGN tt-docto-xml.observacao = ttInfAdic.infCpl.
    
        END.
      
   END.

  
END PROCEDURE.


  

