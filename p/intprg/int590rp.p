/******************************************************************************/
{include/i-prgvrs.i int590rp 1.00.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: int590RP
**
**       DATA....: 01/2023
**
**       OBJETIVO: Integra‡Æo Inventti NFE
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/

{include/i-rpvar.i}
{include/i-rpcab.i}
{utp/ut-glob.i}
{cdp/cdcfgman.i}
/*
{intprg/int002b.i}
{intprg/int500.i}
*/
DISABLE TRIGGERS FOR LOAD OF int_ds_docto_xml.
/*{xmlinc/xmlndd.i}*/
CREATE WIDGET-POOL.
    
DEFINE TEMP-TABLE tt-cfop NO-UNDO
FIELD cod-cfop LIKE int_ds_it_docto_xml.cfop
FIELD indice   AS INTEGER.
DEF VAR c-movimento AS CHAR FORMAT "X(30)".
def var cCodigoErro as char NO-UNDO INIT "".
DEF VAR cMensagem AS CHAR NO-UNDO.
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
    FIELD i-qtd-notas      AS INT.

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


           
for each tt-raw-digita:
    create tt-digita.
    raw-transfer tt-raw-digita.raw-digita to tt-digita NO-ERROR.
end.

def var c-acompanha     as char    no-undo.
DEF VAR h-acomp    AS HANDLE  NO-UNDO.


find first param-global no-lock no-error.
find first mgadm.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "int590rp"
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

DEF VAR i-cont AS INT NO-UNDO.

DEFINE BUFFER bf-es-nota-fiscal-inventti FOR es-nota-fiscal-inventti   .

  run utp/ut-acomp.p persistent set h-acomp.
  {utp/ut-liter.i Integra‡Æo_NFe * L}
  run pi-inicializar in h-acomp (input return-value).
  
ASSIGN i-cont = 0.

//PUT "Notas enviadas para a Invetti" SKIP
FOR EACH es-nota-fiscal-inventti no-LOCK
    WHERE es-nota-fiscal-inventti.situacao-integracao =  0:

    IF VALID-HANDLE(h-acomp) THEN
        RUN pi-acompanhar IN h-acomp(INPUT "NFE: " + es-nota-fiscal-inventti.cod-estabel + '_' + es-nota-fiscal-inventti.serie + '_' + es-nota-fiscal-inventti.nr-nota-fiscal).  


    FIND FIRST nota-fiscal
         WHERE nota-fiscal.cod-estabel    = es-nota-fiscal-inventti.cod-estabel   
         AND   nota-fiscal.serie          = es-nota-fiscal-inventti.serie         
         AND   nota-fiscal.nr-nota-fis    = es-nota-fiscal-inventti.nr-nota-fiscal
         NO-LOCK NO-ERROR.

    IF NOT AVAIL nota-fiscal THEN do:
    
        FIND FIRST bf-es-nota-fiscal-inventti  EXCLUSIVE-LOCK
            WHERE ROWID(bf-es-nota-fiscal-inventti) = ROWID(es-nota-fiscal-inventti) NO-ERROR.
        IF AVAIL bf-es-nota-fiscal-inventti THEN
            ASSIGN bf-es-nota-fiscal-inventti.situacao-integracao = ?.
        RELEASE bf-es-nota-fiscal-inventti.
        
        NEXT.
    END.

    IF nota-fiscal.dt-cancela <> ? THEN DO:
        FIND FIRST bf-es-nota-fiscal-inventti  EXCLUSIVE-LOCK
            WHERE ROWID(bf-es-nota-fiscal-inventti) = ROWID(es-nota-fiscal-inventti) NO-ERROR.
        IF AVAIL bf-es-nota-fiscal-inventti THEN    
            ASSIGN bf-es-nota-fiscal-inventti.situacao-integracao = 1.
        RELEASE bf-es-nota-fiscal-inventti.
        NEXT.
    END.

    FIND FIRST es-param-integracao-estab
         WHERE es-param-integracao-estab.cod-estabel =  nota-fiscal.cod-estabel 
         AND   es-param-integracao-estab.empresa-integracao = 2
         NO-LOCK NO-ERROR.

    IF NOT AVAIL es-param-integracao-estab THEN DO:
    
        FIND FIRST bf-es-nota-fiscal-inventti  EXCLUSIVE-LOCK
            WHERE ROWID(bf-es-nota-fiscal-inventti) = ROWID(es-nota-fiscal-inventti) NO-ERROR.
        IF AVAIL bf-es-nota-fiscal-inventti THEN        
            ASSIGN bf-es-nota-fiscal-inventti.situacao-integracao = ?.
            
        RELEASE bf-es-nota-fiscal-inventti.
        NEXT.
    END.

    ASSIGN c-movimento = "Enviadas para a Invetti".
    DISP nota-fiscal.cod-estabel
         nota-fiscal.serie      
         nota-fiscal.nr-nota-fis
         c-movimento               COLUMN-LABEL "Movimento"
         WITH SCROLLABLE STREAM-IO.

    
    RUN int\wsinventti0002.p  (INPUT  ROWID(nota-fiscal)).

    run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                               nota-fiscal.serie,
                               nota-fiscal.nr-nota-fis,
                               "").
    ASSIGN cMensagem = "Nota fiscal enviada para integra‡Æo na Inventti".
    
    FIND FIRST bf-es-nota-fiscal-inventti  EXCLUSIVE-LOCK
        WHERE ROWID(bf-es-nota-fiscal-inventti) = ROWID(es-nota-fiscal-inventti) NO-ERROR.
    IF AVAIL bf-es-nota-fiscal-inventti THEN       
        ASSIGN i-cont = i-cont + 1
               bf-es-nota-fiscal-inventti.situacao-integracao = 1
               bf-es-nota-fiscal-inventti.dt-ultimo-envio     = TODAY
               bf-es-nota-fiscal-inventti.hr-ultimo-envio     = TIME.


    IF i-cont = tt-param.i-qtd-notas  THEN LEAVE.

END.
      
ASSIGN i-cont = 0.
FOR EACH es-nota-fiscal-inventti NO-LOCK
    WHERE es-nota-fiscal-inventti.situacao-integracao =  1
    BREAK BY es-nota-fiscal-inventti.dt-ultimo-envio
          BY es-nota-fiscal-inventti.hr-ultimo-envio:

    IF VALID-HANDLE(h-acomp) THEN
        RUN pi-acompanhar IN h-acomp(INPUT "NFE: " + es-nota-fiscal-inventti.cod-estabel + '_' + es-nota-fiscal-inventti.serie + '_' + es-nota-fiscal-inventti.nr-nota-fiscal).  


    FIND FIRST nota-fiscal
         WHERE nota-fiscal.cod-estabel    = es-nota-fiscal-inventti.cod-estabel   
         AND   nota-fiscal.serie          = es-nota-fiscal-inventti.serie         
         AND   nota-fiscal.nr-nota-fis    = es-nota-fiscal-inventti.nr-nota-fiscal
         NO-LOCK NO-ERROR.

    IF NOT AVAIL nota-fiscal THEN do:
    
        FIND FIRST bf-es-nota-fiscal-inventti  EXCLUSIVE-LOCK
            WHERE ROWID(bf-es-nota-fiscal-inventti) = ROWID(es-nota-fiscal-inventti) NO-ERROR.
        IF AVAIL bf-es-nota-fiscal-inventti THEN       
            ASSIGN bf-es-nota-fiscal-inventti.situacao-integracao = ?.
        
        RELEASE bf-es-nota-fiscal-inventti.
        NEXT.
    END.

    FIND FIRST es-param-integracao-estab
         WHERE es-param-integracao-estab.cod-estabel =  nota-fiscal.cod-estabel 
         AND   es-param-integracao-estab.empresa-integracao = 2
         NO-LOCK NO-ERROR.

    IF NOT AVAIL es-param-integracao-estab THEN DO:
    
        FIND FIRST bf-es-nota-fiscal-inventti  EXCLUSIVE-LOCK
            WHERE ROWID(bf-es-nota-fiscal-inventti) = ROWID(es-nota-fiscal-inventti) NO-ERROR.
        IF AVAIL bf-es-nota-fiscal-inventti THEN      
            ASSIGN bf-es-nota-fiscal-inventti.situacao-integracao = ?.
         
        RELEASE bf-es-nota-fiscal-inventti.
        NEXT.
    END.

    ASSIGN c-movimento = "Retorno da Invetti.".
    DISP nota-fiscal.cod-estabel
         nota-fiscal.serie      
         nota-fiscal.nr-nota-fis
         c-movimento               COLUMN-LABEL "Movimento"
         WITH SCROLLABLE STREAM-IO.

    RUN int\wsinventti0004.p  (input nota-fiscal.cod-estabel,
                               input nota-fiscal.serie,      
                               input nota-fiscal.nr-nota-fis).

    FIND FIRST bf-es-nota-fiscal-inventti  EXCLUSIVE-LOCK
        WHERE ROWID(bf-es-nota-fiscal-inventti) = ROWID(es-nota-fiscal-inventti) NO-ERROR.
    IF AVAIL bf-es-nota-fiscal-inventti THEN        
        ASSIGN i-cont = i-cont + 1.
               bf-es-nota-fiscal-inventti.situacao-integracao = 2.

    RELEASE bf-es-nota-fiscal-inventti.               
    IF i-cont = tt-param.i-qtd-notas  THEN LEAVE.

END.
RELEASE es-nota-fiscal-inventti.

{include/i-rpclo.i}   


IF VALID-HANDLE(h-acomp) THEN 
   run pi-finalizar in h-acomp.

return "OK":U.

    

procedure pi-cria-ret-nf-eletro:

    define input parameter pcod-estabel as char no-undo.
    define input parameter pserie       as char no-undo.
    define input parameter pnr-nota-fis as char no-undo.
    define input parameter pnProt       as char no-undo.

    for last ret-nf-eletro exclusive-lock where 
        ret-nf-eletro.cod-estabel = pcod-estabel and 
        ret-nf-eletro.cod-serie   = pserie       and 
        ret-nf-eletro.nr-nota-fis = pnr-nota-fis and 
        ret-nf-eletro.cod-msg     = cCodigoErro  and 
        ret-nf-eletro.dat-ret     = today        /*and
        ret-nf-eletro.cod-livre-2 = cMensagem*/
        query-tuning(no-lookahead): end.

    if not avail ret-nf-eletro then do:
        create  ret-nf-eletro.
        assign  ret-nf-eletro.cod-estabel = pcod-estabel
                ret-nf-eletro.cod-serie   = pserie
                ret-nf-eletro.nr-nota-fis = pnr-nota-fis
                ret-nf-eletro.dat-ret     = today
                ret-nf-eletro.cod-msg     = cCodigoErro.
    end.
    assign  ret-nf-eletro.hra-ret     = replace(string(time, "HH:MM:SS"),":","")
            ret-nf-eletro.cod-livre-2 = cMensagem
            ret-nf-eletro.log-ativo   = yes.
    &if "{&bf_dis_versao_ems}" >= "2.07" &then 
        ret-nf-eletro.cod-protoc  = pnProt.
    &else
        ret-nf-eletro.cod-livre-1 = pnProt.
    &endif

    release ret-nf-eletro.
end.
