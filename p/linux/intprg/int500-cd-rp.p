/******************************************************************************/
{include/i-prgvrs.i int500-cd-rp 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: INT500-CD-RP
**
**       DATA....: 11/2015
**
**       OBJETIVO: Integraá∆o NDD - XML Recebimento CD
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
FIELD cod-cfop LIKE int_ds_it_docto_xml.cfop
FIELD indice   AS INTEGER.

DEF TEMP-TABLE tt-dist-emitente NO-UNDO
FIELD cod-emitente LIKE emitente.cod-emitente
FIELD situacao     AS  INTEGER.

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
           
for each tt-raw-digita query-tuning(no-lookahead):
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
DEF VAR L-DESCARTA     AS LOGICAL NO-UNDO.
DEF VAR h-niveis       AS HANDLE  NO-UNDO.
DEF VAR c-item_do_forn AS CHAR    NO-UNDO.
DEF VAR c-nat-operacao AS CHAR    NO-UNDO.
DEF VAR c-cfop         AS CHAR    NO-UNDO.
DEF VAR l-estab        AS LOGICAL NO-UNDO.
DEF VAR l-ok              AS LOGICAL NO-UNDO.
DEF VAR i-ativo           AS INTEGER NO-UNDO.
DEF VAR c-valida-emitente AS CHAR NO-UNDO.

DEF VAR i-orig-icms    like  int_ds_it_docto_xml.orig_icms. 
DEF VAR i-cst-icms     like  int_ds_it_docto_xml.cst_icms. 
DEF VAR i-modBC        like  int_ds_it_docto_xml.modBC.     
DEF VAR i-modbcst      like  int_ds_it_docto_xml.modbcst.   
DEF VAR de-vbc-icms    like  int_ds_it_docto_xml.vbc_icms.  
DEF VAR de-picms       like  int_ds_it_docto_xml.picms.     
DEF VAR de-vicms       like  int_ds_it_docto_xml.vicms. 
DEF VAR de-valor_fcp         like int_ds_it_docto_xml.vicms.  
DEF VAR de-valor_fcp_st      like int_ds_it_docto_xml.vicms.
DEF VAR de-valor-base-fcp-st like int_ds_it_docto_xml.vicms.
DEF VAR de-perc-fcp-st       like int_ds_it_docto_xml.ppis.
DEF VAR de-valor_fcp_st_ret  like int_ds_it_docto_xml.vicms.
DEF VAR de-valor_ipi_devol   like int_ds_it_docto_xml.vicms.
DEF VAR de-vbc-cst-fcp       LIKE int_ds_it_docto_xml.vicms.
DEF VAR de-pmvast      like  int_ds_it_docto_xml.pmvast.    
DEF VAR de-vbcst       like  int_ds_it_docto_xml.vbcst.     
DEF VAR de-picmsst     like  int_ds_it_docto_xml.picmsst.   
DEF VAR de-vicmsst     like  int_ds_it_docto_xml.vicmsst.   
DEF VAR de-vbcstret    like  int_ds_it_docto_xml.vbcstret.  
DEF VAR de-vicmsstret  like  int_ds_it_docto_xml.vicmsstret.
DEF VAR de-vicmsDeson  like  int_ds_it_docto_xml.vicmsstret.
DEF VAR de-aliq-pis    LIKE  int_ds_it_docto_xml.ppis.
DEF VAR de-aliq-cofins LIKE int_ds_it_docto_xml.pcofins.
DEF VAR de-tot-bicms   LIKE it-nota-fisc.vl-bicms-it.
DEF VAR de-tot-icms    LIKE it-nota-fisc.vl-icms-it.
DEF VAR de-tot-bsubs   LIKE it-nota-fisc.vl-bsubs-it.
DEF VAR de-tot-icmst   LIKE it-nota-fisc.vl-icmsub-it.
DEF VAR de-predbc-icms LIKE it-nota-fisc.perc-red-icm no-undo.
DEF VAR de-pRedBCST    like it-nota-fisc.perc-red-icm no-undo.
DEF VAR de-tot-pis     LIKE int_ds_docto_xml.valor_pis no-undo.       
DEF VAR de-tot-cofins  LIKE int_ds_docto_xml.valor_cofins no-undo.
DEF VAR c-versao-xml   AS CHAR NO-UNDO.
DEF VAR c-anvisa       AS CHAR NO-UNDO.

DEFINE VARIABLE de-base-st-calc  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-perc-st-calc  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-valor-st-calc AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-valor-st-tmp  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE c-tabela-pauta   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE de-tabela-pauta  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-per-sub-tri   AS DECIMAL     NO-UNDO.

DEF VAR i-num-pedido  AS     INTEGER.
DEF VAR c-doc         AS     LONGCHAR NO-UNDO.
def var c-un-for      as     char.
DEF VAR i-cod-emitente AS INT NO-UNDO.

DEF BUFFER b-tt-digita             FOR tt-digita.
DEF BUFFER b-int_ds_it_docto_xml   FOR int_ds_it_docto_xml.
DEF BUFFER b-int_ds_docto_xml      FOR int_ds_docto_xml. 
DEF BUFFER b-NDD_ENTRYINTEGRATION  FOR NDD_ENTRYINTEGRATION. 
DEF BUFFER b-estab                 FOR estabelec.
DEF BUFFER b-tt-xml-dup            FOR tt-xml-dup.

find first param-global no-lock no-error.
find first mgadm.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "int500-cd-rp"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Integraá∆o_Notas_Danf-e * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Recebimento * L}
assign c-sistema = trim(return-value).

view frame f-cabec.
view frame f-rodape.

IF CAN-FIND(FIRST tt-digita) 
THEN DO:
    
   ASSIGN l-altera = YES.
   
   FIND FIRST tt-digita NO-ERROR.
   FIND FIRST int_ds_it_docto_xml NO-LOCK WHERE
              ROWID(int_ds_it_docto_xml) = TO-ROWID(tt-digita.valor) NO-ERROR.
   IF AVAIL int_ds_it_docto_xml THEN DO:

      FIND FIRST int_ds_docto_xml WHERE
                 int_ds_docto_xml.tipo_nota    = int_ds_it_docto_xml.tipo_nota    AND 
                 int_ds_docto_xml.CNPJ         = int_ds_it_docto_xml.CNPJ         AND
                 int_ds_docto_xml.cod_emitente = int_ds_it_docto_xml.cod_emitente AND  
                 int(int_ds_docto_xml.nNF)     = int(int_ds_it_docto_xml.nNF)     AND
                 int_ds_docto_xml.serie        = int_ds_it_docto_xml.serie NO-ERROR.
      IF AVAIL int_ds_docto_xml THEN DO: 
         
         CREATE tt-docto-xml.
         BUFFER-COPY int_ds_docto_xml TO tt-docto-xml.

      END.
      
      IF tt-digita.campo = "item" 
      THEN DO:
         CREATE tt-it-docto-xml.
         BUFFER-COPY int_ds_it_docto_xml TO tt-it-docto-xml.
      END.   
      ELSE DO:
          FOR EACH int_ds_it_docto_xml WHERE 
                    int_ds_it_docto_xml.serie         =  int_ds_docto_xml.serie         AND
                    int(int_ds_it_docto_xml.nNF)      =  int(int_ds_docto_xml.nNF)      AND
                    int_ds_it_docto_xml.cod_emitente  =  int_ds_docto_xml.cod_emitente  AND
                    int_ds_it_docto_xml.tipo_nota     =  int_ds_docto_xml.tipo_nota query-tuning(no-lookahead):   
              CREATE tt-it-docto-xml.
              BUFFER-COPY int_ds_it_docto_xml TO tt-it-docto-xml.
          END.
      END.
   END.

   RELEASE int_ds_it_docto_xml.

END.
ELSE DO:

  run utp/ut-acomp.p persistent set h-acomp.
  {utp/ut-liter.i Integraá∆o_Notas_Danf-e * L}
  run pi-inicializar in h-acomp (input return-value).
  
END.

DEF VAR h-boin176         AS HANDLE.
   
RUN inbo/boin176.p PERSISTENT SET h-boin176. /*  calcula fator de convers∆o */

IF l-altera = NO 
THEN DO:

    RUN pi-IntegracaoNDD.
    
    empty temp-table tt-docto-xml.
    empty temp-table tt-xml-dup.
    empty temp-table tt-it-docto-xml.
    
    ASSIGN l-altera = YES.
    
END.
else DO:

  run pi-grava-nota. 

END.
 
IF VALID-HANDLE(h-boin176) THEN
       DELETE PROCEDURE h-boin176.

DELETE WIDGET-POOL.

function PrintChar returns longchar
    (input pc-string as longchar):

    /* necess†rio para que a funá∆o seja case-sensitive */
    define variable c-string as longchar case-sensitive no-undo.
    define variable i-ind as integer no-undo.

    assign c-string = pc-string.

    assign c-string = replace(c-string,"†","a").
    assign c-string = replace(c-string,"Ö","a").
    assign c-string = replace(c-string,"∆","a").
    assign c-string = replace(c-string,"É","a").
    assign c-string = replace(c-string,"Ñ","a").

    assign c-string = replace(c-string,"Ç","e").
    assign c-string = replace(c-string,"ä","e").
    assign c-string = replace(c-string,"à","e").
    assign c-string = replace(c-string,"â","e").

    assign c-string = replace(c-string,"°","i").
    assign c-string = replace(c-string,"ç","i").
    assign c-string = replace(c-string,"å","i").
    assign c-string = replace(c-string,"ã","i").

    assign c-string = replace(c-string,"¢","o").
    assign c-string = replace(c-string,"ï","o").
    assign c-string = replace(c-string,"ì","o").
    assign c-string = replace(c-string,"î","o").
    assign c-string = replace(c-string,"‰","o").

    assign c-string = replace(c-string,"£","u").
    assign c-string = replace(c-string,"ó","u").
    assign c-string = replace(c-string,"ñ","u").
    assign c-string = replace(c-string,"Å","u").

    assign c-string = replace(c-string,"á","c").
    assign c-string = replace(c-string,"§","n").

    assign c-string = replace(c-string,"Ï","y").
    assign c-string = replace(c-string,"ò","y").

    assign c-string = replace(c-string,"µ","A").
    assign c-string = replace(c-string,"∑","A").
    assign c-string = replace(c-string,"«","A").
    assign c-string = replace(c-string,"∂","A").
    assign c-string = replace(c-string,"é","A").

    assign c-string = replace(c-string,"ê","E").
    assign c-string = replace(c-string,"‘","E").
    assign c-string = replace(c-string,"“","E").
    assign c-string = replace(c-string,"”","E").

    assign c-string = replace(c-string,"÷","I").
    assign c-string = replace(c-string,"ﬁ","I").
    assign c-string = replace(c-string,"◊","I").
    assign c-string = replace(c-string,"ÿ","I").

    assign c-string = replace(c-string,"‡","O").
    assign c-string = replace(c-string,"„","O").
    assign c-string = replace(c-string,"‚","O").
    assign c-string = replace(c-string,"ô","O").
    assign c-string = replace(c-string,"Â","O").

    assign c-string = replace(c-string,"È","U").
    assign c-string = replace(c-string,"Î","U").
    assign c-string = replace(c-string,"Í","U").
    assign c-string = replace(c-string,"ö","U").

    assign c-string = replace(c-string,"Ä","C").
    assign c-string = replace(c-string,"•","N").
                                        
    assign c-string = replace(c-string,"Ì","Y").

    assign c-string = replace(c-string,CHR(13),"").
    assign c-string = replace(c-string,CHR(10),"").

    assign c-string = replace(c-string,"˚","").
    assign c-string = replace(c-string,"≠","").
    assign c-string = replace(c-string,"˝","2").
    assign c-string = replace(c-string,"¸","3").
    assign c-string = replace(c-string,"œ","o").
    assign c-string = replace(c-string,"∞","E").
    assign c-string = replace(c-string,"¨","1/4").
    assign c-string = replace(c-string,"´","1/2").
    assign c-string = replace(c-string,"Û","3/4").
    assign c-string = replace(c-string,"æ","Y").
    assign c-string = replace(c-string,"û","x").
    assign c-string = replace(c-string,"Á","p").
    assign c-string = replace(c-string,"©","r").
    assign c-string = replace(c-string,"Ü","a").
    assign c-string = replace(c-string,"·","B").
    assign c-string = replace(c-string,"–","y").
    assign c-string = replace(c-string,"õ","o").
    assign c-string = replace(c-string,"Ù","").
    assign c-string = replace(c-string,"ë","ae").
    assign c-string = replace(c-string,"Ê","u").
    assign c-string = replace(c-string,"®","").
    assign c-string = replace(c-string,"∫","").
    assign c-string = replace(c-string,"ı","").
    assign c-string = replace(c-string,"è","A").
    assign c-string = replace(c-string,"©","").
    assign c-string = replace(c-string,"Ë","p").
    assign c-string = replace(c-string,"Æ","-").
    assign c-string = replace(c-string,"Ø","-").
    assign c-string = replace(c-string,"™","").
    assign c-string = replace(c-string,"™","").
    assign c-string = replace(c-string,"Ù","").
    assign c-string = replace(c-string,"ù","0").
    assign c-string = replace(c-string,"—","D").
    assign c-string = replace(c-string,"·","B").
    assign c-string = replace(c-string,"í","").
    assign c-string = replace(c-string,"∏","").
    assign c-string = replace(c-string,"ú","").
    assign c-string = replace(c-string,"ı","").

    assign c-string = replace(c-string,"ˆ","").
    assign c-string = replace(c-string,"›","").
    assign c-string = replace(c-string,"¯","o").
    assign c-string = replace(c-string,"Ω","c").

    do i-ind = 1 to 31:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 127 to 144:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 147 to 159:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 162 to 182:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 184 to 191:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 215 to 216:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 248 to 248:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.

    assign c-string = trim(c-string).

    return c-string.

end function.

procedure pi-grava-nota:       
    /* Procedure para gravar int_ds_docto_xml p/ CD e int_ds_nota_entrada p/ lojas */
    l-ok = NO.
    /* gravar int_ds_docto_xml p/ notas destino = CD */

    FOR EACH tt-docto-xml USE-INDEX tp-estab-emis WHERE    
             tt-docto-xml.tipo_estab    = 1 /* Destino CD */ AND  
             tt-docto-xml.dEmi         >= date(STRING(tt-param.dt-trans-ini,"99/99/9999")) AND 
             tt-docto-xml.dEmi         <= DATE(STRING(tt-param.dt-trans-fin,"99/99/9999")) AND 
             int(tt-docto-xml.NNF)     >= int(tt-param.i-nro-docto-ini) AND 
             int(tt-docto-xml.NNF)     <= int(tt-param.i-nro-docto-fin) AND
             tt-docto-xml.cod_emitente >= tt-param.i-cod-emit-ini  AND 
             tt-docto-xml.cod_emitente <= tt-param.i-cod-emit-fin AND
             tt-docto-xml.cod_estab     = "973"
        BREAK BY tt-docto-xml.arquivo query-tuning(no-lookahead):
    
        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Grava CD: " + tt-docto-xml.NNF).       

        FOR FIRST int_ds_docto_xml  WHERE
                  int_ds_docto_xml.tipo_nota = tt-docto-xml.tipo_nota  AND
                  int_ds_docto_xml.CNPJ      = tt-docto-xml.CNPJ       AND 
                  int(int_ds_docto_xml.nNF)  = int(tt-docto-xml.nNF)   AND
                  int_ds_docto_xml.serie     = tt-docto-xml.serie query-tuning(no-lookahead):
        END.
        IF AVAIL int_ds_docto_xml THEN DO:
            IF l-altera = NO then NEXT.
                
            IF l-altera = NO THEN 
               DELETE int_ds_docto_xml.
            
        END.

        FOR EACH int_ds_doc_erro EXCLUSIVE-LOCK WHERE
                 int_ds_doc_erro.serie_docto  = tt-docto-xml.serie        AND 
                 int_ds_doc_erro.cod_emitente = tt-docto-xml.cod_emitente AND
                 int_ds_doc_erro.CNPJ         = tt-docto-xml.CNPJ         AND    
                 int(int_ds_doc_erro.nro_docto) = int(tt-docto-xml.NNF)   AND 
                 int_ds_doc_erro.tipo_nota    = tt-docto-xml.tipo_nota    AND 
                 int_ds_doc_erro.sequencia    = 0 query-tuning(no-lookahead):
            DELETE int_ds_doc_erro.
        END.
        
        IF l-altera = NO THEN DO:
          CREATE int_ds_docto_xml.
          BUFFER-COPY tt-docto-xml TO int_ds_docto_xml
          /* Preparaá∆o para integraá∆o com Procfit */
          ASSIGN int_ds_docto_xml.id_sequencial = NEXT-VALUE(seq-int-ds-docto-xml)
                 int_ds_docto_xml.envio_status  = 1
                 int_ds_docto_xml.envio_data    = datetime(today).
        END.

        ASSIGN int_ds_docto_xml.situacao = 2.

        ASSIGN int_ds_docto_xml.chnfe      = IF tt-docto-xml.chnfe      = ? then "" else tt-docto-xml.chnfe 
               int_ds_docto_xml.chnft      = IF tt-docto-xml.chnft      = ? then "" else tt-docto-xml.chnft
               int_ds_docto_xml.xnome      = IF tt-docto-xml.xnome      = ? then "" else tt-docto-xml.xnome
               int_ds_docto_xml.modFrete   = IF tt-docto-xml.modFrete   = ? then 0  else tt-docto-xml.modFrete
               int_ds_docto_xml.num_pedido = /*IF tt-docto-xml.num-pedido = ? then 0  else*/ tt-docto-xml.num_pedido

               int_ds_docto_xml.valor_fcp        = IF tt-docto-xml.valor_fcp        = ? THEN 0 ELSE tt-docto-xml.valor_fcp         /* novo 4.0 */
               int_ds_docto_xml.valor_fcp_st     = IF tt-docto-xml.valor_fcp_st     = ? THEN 0 ELSE tt-docto-xml.valor_fcp_st      /* novo 4.0 */
               int_ds_docto_xml.valor_fcp_st_ret = IF tt-docto-xml.valor_fcp_st_ret = ? THEN 0 ELSE tt-docto-xml.valor_fcp_st_ret  /* novo 4.0 */
               int_ds_docto_xml.valor_ipi_devol  = IF tt-docto-xml.valor_ipi_devol  = ? THEN 0 ELSE tt-docto-xml.valor_ipi_devol   /* novo 4.0 */
               int_ds_docto_xml.vbc_cst_fcp      = IF tt-docto-xml.vbc_cst_fcp      = ? THEN 0 ELSE tt-docto-xml.vbc_cst_fcp       /* novo 4.0 */
               int_ds_docto_xml.tpag             = tt-docto-xml.tpag                                                               /* novo 4.0 */
               int_ds_docto_xml.vpag             = IF tt-docto-xml.vpag             = ? THEN 0 ELSE tt-docto-xml.vpag              /* novo 4.0 */
               int_ds_docto_xml.valor_st         = int_ds_docto_xml.valor_st + int_ds_docto_xml.valor_fcp_st.

        FIND FIRST serie WHERE 
                   serie.serie = tt-docto-xml.serie NO-LOCK NO-ERROR.
        IF NOT AVAIL serie THEN DO:
            RUN pi-gera-erro(INPUT 1,    
                             INPUT "SÇrie N∆o cadastrada").   
        END.    

        FOR FIRST natur-oper NO-LOCK WHERE
                  natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao
            query-tuning(no-lookahead) : 
        END.

        IF NOT AVAIL natur-oper 
        THEN DO:
           RUN pi-gera-erro(INPUT 9,    
                            INPUT "Natureza de Operaá∆o Nota" + string(int_ds_docto_xml.nat_operacao) + " n∆o cadastrada!"). 
        END.
    
        /*** Forncederos ativos ***/
        EMPTY TEMP-TABLE tt-dist-emitente. 

        ASSIGN i-ativo = 0
               c-valida-emitente = ""
               i-cod-emitente    = 0.

        FOR EACH emitente NO-LOCK WHERE 
                 emitente.identific > 1 AND 
                 emitente.cgc       = tt-docto-xml.cnpj query-tuning(no-lookahead):

            FIND FIRST tt-dist-emitente WHERE
                       tt-dist-emitente.cod-emitente = emitente.cod-emitente NO-ERROR.
            IF NOT AVAIL tt-dist-emitente 
            THEN DO:

               CREATE tt-dist-emitente.
               ASSIGN tt-dist-emitente.cod-emitente = emitente.cod-emitente.

               FIND FIRST dist-emitente WHERE
                          dist-emitente.cod-emitente = emitente.cod-emitente NO-ERROR.
               IF AVAIL dist-emitente THEN DO:
                  ASSIGN tt-dist-emitente.situacao = dist-emitente.idi-sit-fornec.
               END.                   
            END.       
        END.

        FOR EACH tt-dist-emitente query-tuning(no-lookahead):

           IF tt-dist-emitente.situacao = 1 THEN
              ASSIGN i-ativo = i-ativo + 1.        

        END.

        IF i-ativo <> 1 
        THEN DO:

            IF i-ativo = 0 THEN DO:
               RUN pi-gera-erro(INPUT 2,    
                                INPUT "Nenhum fornecedor ativo para o CNPJ: " + STRING(tt-docto-xml.CNPJ)).       
            END.

            IF i-ativo > 1 THEN DO:
               RUN pi-gera-erro(INPUT 2,    
                                INPUT "Mais de um Fornecedor ativo para o CNPJ: " + STRING(tt-docto-xml.CNPJ)).       
            END.
        END. 
        ELSE DO:
            FIND FIRST tt-dist-emitente WHERE
                       tt-dist-emitente.situacao = 1 NO-ERROR.
            IF AVAIL tt-dist-emitente THEN DO:
               ASSIGN i-cod-emitente = tt-dist-emitente.cod-emitente. /* Considera apenas o fornecedor ativo */
            END.
        END.

        FOR FIRST emitente NO-LOCK WHERE
                  emitente.cod-emitente = i-cod-emitente query-tuning(no-lookahead): 
        END.
        IF AVAIL emitente THEN DO:
           IF AVAIL int_ds_docto_xml THEN 
              ASSIGN int_ds_docto_xml.cod_emitente = emitente.cod-emitente
                     int_ds_docto_xml.cnpj         = emitente.cgc
                     tt-docto-xml.cod_emitente     = emitente.cod-emitente
                     tt-docto-xml.CNPJ             = emitente.cgc.
        END.     
        ELSE DO:
            RUN pi-gera-erro(INPUT 2,    
                             INPUT "Fornecedor " + tt-docto-xml.xNome + ".N∆o cadastrado com o CNPJ " + STRING(tt-docto-xml.CNPJ)).       
        END.
    
        FIND FIRST estabelec NO-LOCK WHERE
                   estabelec.cod-estabel = tt-docto-xml.cod_estab no-error. 
        IF AVAIL estabelec THEN DO:
            ASSIGN int_ds_docto_xml.cod_estab = estabelec.cod-estabel
                   int_ds_docto_xml.ep_codigo = int(estabelec.ep-codigo). 
        END.
        ELSE DO:
           RUN pi-gera-erro(INPUT 3,    
                            INPUT "Estabelecimento n∆o cadastrado com o CNPJ " + STRING(tt-docto-xml.CNPJ_dest)).
        END. 
        
        IF int_ds_docto_xml.tipo_docto   = 4 AND 
           int_ds_docto_xml.tot_desconto = 0  /* Notas Pepsico */  
        THEN DO:
           RUN pi-gera-erro(INPUT 11,    
                            INPUT "N∆o foi informado o desconto.").
        END.

        FOR EACH tt-it-docto-xml WHERE
                 tt-it-docto-xml.tipo_nota  = tt-docto-xml.tipo_nota AND
                 tt-it-docto-xml.CNPJ       = tt-docto-xml.CNPJ      AND
                 int(tt-it-docto-xml.nNF)   = int(tt-docto-xml.nNF)  AND
                 tt-it-docto-xml.serie      = tt-docto-xml.serie
             by  tt-it-docto-xml.sequencia query-tuning(no-lookahead):
    
            FOR EACH int_ds_doc_erro EXCLUSIVE-LOCK WHERE
                     int_ds_doc_erro.serie_docto  = tt-docto-xml.serie        AND 
                     int_ds_doc_erro.cod_emitente = tt-docto-xml.cod_emitente AND
                     int_ds_doc_erro.CNPJ         = tt-docto-xml.CNPJ         AND    
                     int(int_ds_doc_erro.nro_docto) = int(tt-docto-xml.NNF)   AND 
                     int_ds_doc_erro.tipo_nota    = tt-docto-xml.tipo_nota    AND 
                     int_ds_doc_erro.sequencia    = tt-it-docto-xml.sequencia query-tuning(no-lookahead):
              DELETE int_ds_doc_erro.
            END.

            FIND FIRST int_ds_it_docto_xml EXCLUSIVE-LOCK WHERE
                       int_ds_it_docto_xml.tipo_nota   = tt-it-docto-xml.tipo_nota AND
                       int_ds_it_docto_xml.CNPJ        = tt-it-docto-xml.CNPJ      AND
                       int(int_ds_it_docto_xml.nNF)    = int(tt-it-docto-xml.nNF)  AND
                       int_ds_it_docto_xml.serie       = tt-it-docto-xml.serie     AND
                       int_ds_it_docto_xml.sequencia   = tt-it-docto-xml.sequencia NO-ERROR.
            IF AVAIL int_ds_it_docto_xml THEN DO:
                IF l-altera = NO THEN 
                   DELETE int_ds_it_docto_xml.  
            END.
               
            IF l-altera = NO THEN DO:   
                CREATE int_ds_it_docto_xml.
                BUFFER-COPY tt-it-docto-xml TO int_ds_it_docto_xml.   

                IF AVAIL emitente THEN 
                ASSIGN int_ds_it_docto_xml.cod_emitente = emitente.cod-emitente. 
            END.  
            ASSIGN int_ds_it_docto_xml.situacao      = 2
                   int_ds_it_docto_xml.cod_emitente  = int_ds_docto_xml.cod_emitente
                   int_ds_it_docto_xml.cnpj          = int_ds_docto_xml.cnpj
                   int_ds_it_docto_xml.item_do_forn  = trim(tt-it-docto-xml.item_do_forn)
                   int_ds_it_docto_xml.xprod         = IF tt-it-docto-xml.xprod           = ? then ""   else  trim(substring(tt-it-docto-xml.xprod,1,60))
                   int_ds_it_docto_xml.uCom          = if tt-it-docto-xml.uCom            = ? then ""   else  tt-it-docto-xml.uCom           
                   int_ds_it_docto_xml.nat_operacao  = if tt-it-docto-xml.nat_operacao    = ? then ""   else  tt-it-docto-xml.nat_operacao
                   int_ds_it_docto_xml.qOrdem        = if tt-it-docto-xml.qOrdem          = ? then 0    else  tt-it-docto-xml.qOrdem        
                   int_ds_it_docto_xml.vtottrib      = if tt-it-docto-xml.vtottrib        = ? then 0    else  tt-it-docto-xml.vtottrib      
                   int_ds_it_docto_xml.vbc_icms      = if tt-it-docto-xml.vbc_icms        = ? then 0    else  tt-it-docto-xml.vbc_icms      
                   int_ds_it_docto_xml.picms         = if tt-it-docto-xml.picms           = ? then 0    else  tt-it-docto-xml.picms         
                   int_ds_it_docto_xml.pmvast        = if tt-it-docto-xml.pmvast          = ? then 0    else  tt-it-docto-xml.pmvast        
                   int_ds_it_docto_xml.vbcst         = if tt-it-docto-xml.vbcst           = ? then 0    else  tt-it-docto-xml.vbcst         
                   int_ds_it_docto_xml.picmsst       = if tt-it-docto-xml.picmsst         = ? then 0    else  tt-it-docto-xml.picmsst       
                   int_ds_it_docto_xml.vicmsst       = if tt-it-docto-xml.vicmsst         = ? then 0    else  tt-it-docto-xml.vicmsst       
                   int_ds_it_docto_xml.vbcstret      = if tt-it-docto-xml.vbcstret        = ? then 0    else  tt-it-docto-xml.vbcstret      
                   int_ds_it_docto_xml.vicmsstret    = if tt-it-docto-xml.vicmsstret      = ? then 0    else  tt-it-docto-xml.vicmsstret    
                   int_ds_it_docto_xml.ppis          = if tt-it-docto-xml.ppis            = ? then 0    else  tt-it-docto-xml.ppis          
                   int_ds_it_docto_xml.pipi          = if tt-it-docto-xml.pipi            = ? then 0    else  tt-it-docto-xml.pipi          
                   int_ds_it_docto_xml.pcofins       = if tt-it-docto-xml.pcofins         = ? then 0    else  tt-it-docto-xml.pcofins       
                   int_ds_it_docto_xml.orig_icms     = if tt-it-docto-xml.orig_icms       = ? then 0    else  tt-it-docto-xml.orig_icms     
                   int_ds_it_docto_xml.ncm           = if tt-it-docto-xml.ncm             = ? then 0    else  tt-it-docto-xml.ncm  
                   int_ds_it_docto_xml.item_do_forn  = if trim(tt-it-docto-xml.item_do_forn) = ? then "" else  trim(tt-it-docto-xml.item_do_forn)
                   int_ds_it_docto_xml.uCom_forn     = if tt-it-docto-xml.uCom_forn       = ? then ""   else  tt-it-docto-xml.uCom_forn     
                   int_ds_it_docto_xml.qCom_forn     = if tt-it-docto-xml.qCom_forn       = ? then 0    else  tt-it-docto-xml.qCom_forn  
                   int_ds_it_docto_xml.narrativa     = if tt-it-docto-xml.narrativa       = "0" then "" else  tt-it-docto-xml.narrativa.

            ASSIGN int_ds_it_docto_xml.lote          = if tt-it-docto-xml.lote            = ?   then "" else  tt-it-docto-xml.lote
                   int_ds_it_docto_xml.MODBCST       = if tt-it-docto-xml.MODBCST         = ?   then 0  else  tt-it-docto-xml.MODBCST
                   int_ds_it_docto_xml.CST_COFINS    = if tt-it-docto-xml.CST_COFINS      = ?   then 0  else  tt-it-docto-xml.CST_COFINS
                   int_ds_it_docto_xml.NARRATIVA     = if tt-it-docto-xml.NARRATIVA       = ?   then "" else  tt-it-docto-xml.NARRATIVA
                   int_ds_it_docto_xml.CST_PIS       = if tt-it-docto-xml.CST_PIS         = ?   then 0  else  tt-it-docto-xml.CST_PIS
                   int_ds_it_docto_xml.CENQ          = if tt-it-docto-xml.CENQ            = ?   then 0  else  tt-it-docto-xml.CENQ
                   int_ds_it_docto_xml.cst_icms      = if tt-it-docto-xml.cst_icms        = ?   then 0  else  tt-it-docto-xml.cst_icms    
                   int_ds_it_docto_xml.cst_ipi       = if tt-it-docto-xml.cst_ipi         = ?   then 0  else  tt-it-docto-xml.cst_ipi     
                   int_ds_it_docto_xml.it_codigo     = if tt-it-docto-xml.it_codigo       = ?   then "" else  tt-it-docto-xml.it_codigo   
                   int_ds_it_docto_xml.modbc         = if tt-it-docto-xml.modbc           = ?   then 0  else  tt-it-docto-xml.modbc       
                   int_ds_it_docto_xml.modbcst       = if tt-it-docto-xml.modbcst         = ?   then 0  else  tt-it-docto-xml.modbcst     
                   int_ds_it_docto_xml.numero_ordem  = if tt-it-docto-xml.numero_ordem    = ?   then 0  else  tt-it-docto-xml.numero_ordem
                   int_ds_it_docto_xml.CEST             = tt-it-docto-xml.CEST             /* novo 4.0 */
                   int_ds_it_docto_xml.EAN              = tt-it-docto-xml.EAN              /* novo 4.0 */
                   int_ds_it_docto_xml.EANTrib          = tt-it-docto-xml.EANTrib          /* novo 4.0 */
                   int_ds_it_docto_xml.anvisa           = tt-it-docto-xml.anvisa           /* novo 4.0 */
                   int_ds_it_docto_xml.valor_fcp        = IF tt-it-docto-xml.valor_fcp        = ? THEN 0 ELSE tt-it-docto-xml.valor_fcp        /* novo 4.0 */
                   int_ds_it_docto_xml.valor_fcp_st     = IF tt-it-docto-xml.valor_fcp_st     = ? THEN 0 ELSE tt-it-docto-xml.valor_fcp_st     /* novo 4.0 */
                   int_ds_it_docto_xml.valor_fcp_st_ret = IF tt-it-docto-xml.valor_fcp_st_ret = ? THEN 0 ELSE tt-it-docto-xml.valor_fcp_st_ret /* novo 4.0 */
                   int_ds_it_docto_xml.valor_ipi_devol  = IF tt-it-docto-xml.valor_ipi_devol  = ? THEN 0 ELSE tt-it-docto-xml.valor_ipi_devol  /* novo 4.0 */
                   int_ds_it_docto_xml.vbcst_fcp        = IF tt-it-docto-xml.vbcst_fcp        = ? THEN 0 ELSE tt-it-docto-xml.vbcst_fcp        /* novo 4.0 */
                   int_ds_it_docto_xml.picmsst_fcp      = IF tt-it-docto-xml.picmsst_fcp      = ? THEN 0 ELSE tt-it-docto-xml.picmsst_fcp      /* novo 4.0 */
                   int_ds_it_docto_xml.vicmsst          = int_ds_it_docto_xml.vicmsst + int_ds_it_docto_xml.valor_fcp_st.                                                   

            FOR FIRST natur-oper NO-LOCK 
                WHERE natur-oper.nat-operacao = int_ds_it_docto_xml.nat_operacao query-tuning(no-lookahead): 

                IF  natur-oper.log-contrib-st-antec
                THEN
                    ASSIGN int_ds_it_docto_xml.vicmsst    = int_ds_it_docto_xml.vicmsst    - int_ds_it_docto_xml.vicms
                           int_ds_docto_xml.base_guia_st  = int_ds_docto_xml.base_guia_st  + int_ds_it_docto_xml.vbcst 
                           int_ds_docto_xml.valor_guia_st = int_ds_docto_xml.valor_guia_st + int_ds_it_docto_xml.vicmsst
                           int_ds_docto_xml.vbc_cst       = int_ds_docto_xml.base_guia_st 
                           int_ds_docto_xml.valor_st      = int_ds_docto_xml.valor_guia_st.
            END.
            
            l-valida = yes.
            for first param-re no-lock where
                param-re.usuario = c-seg-usuario query-tuning(no-lookahead):
                assign l-valida = not param-re.sem-pedido.           
                if l-valida AND tt-it-docto-xml.num_pedido <> ? then do:
                    FIND FIRST pedido-compr NO-LOCK WHERE
                               pedido-compr.num-pedido = tt-it-docto-xml.num_pedido NO-ERROR.
                    IF NOT AVAIL pedido-compr THEN DO:
                           RUN pi-gera-erro(INPUT 4,    
                                            INPUT "Pedido " + string(int_ds_it_docto_xml.num_pedido) + " N∆o cadastrado").   
                    END.
                end.
            END.

            FOR FIRST natur-oper NO-LOCK WHERE
                      natur-oper.nat-operacao = (tt-it-docto-xml.nat_operacao)
                query-tuning(no-lookahead) : 
            END.

            IF NOT AVAIL natur-oper 
            THEN DO:
               RUN pi-gera-erro(INPUT 8,    
                                INPUT "Natureza de Operaá∆o do item" + string(int_ds_it_docto_xml.nat_operacao) + " n∆o cadastrada!"). 
            END. 
            ASSIGN l-gera-nota = NO.
                          
             /* Notas Pepsico , apenas atualizam no re1001 */
            FOR FIRST int_ds_ext_emitente NO-LOCK WHERE
                      int_ds_ext_emitente.cod_emitente = int_ds_it_docto_xml.cod_emitente
                query-tuning(no-lookahead) : 
            END.

            IF (AVAIL int_ds_ext_emitente AND  
                      int_ds_ext_emitente.gera_nota) OR 
                      int_ds_docto_xml.tipo_docto = 0
            THEN DO:

               FIND FIRST item-fornec NO-LOCK WHERE
                          item-fornec.cod-emitente = int_ds_it_docto_xml.cod_emitente AND 
                          ITEM-fornec.it-codigo    = tt-it-docto-xml.it_codigo        AND 
                          ITEM-fornec.ativo = YES NO-ERROR. 
               IF AVAIL ITEM-fornec THEN DO: 
                 assign c-un-for = item-fornec.unid-med-for.
                 ASSIGN int_ds_it_docto_xml.item_do_forn = trim(item-fornec.item-do-forn)
                        tt-it-docto-xml.item_do_forn     = trim(item-fornec.item-do-forn)
                        tt-it-docto-xml.ucom_forn        = tt-it-docto-xml.ucom. 

                 IF int_ds_docto_xml.tipo_docto = 0 THEN
                    ASSIGN tt-it-docto-xml.qCom_forn     = tt-it-docto-xml.qCom_forn
                           tt-it-docto-xml.uCom_forn     = tt-it-docto-xml.uCom_forn
                           int_ds_it_docto_xml.qCom_forn = tt-it-docto-xml.qCom_forn
                           int_ds_it_docto_xml.uCom_forn = tt-it-docto-xml.uCom_forn.
                            
                 ELSE 
                    ASSIGN tt-it-docto-xml.qCom_forn     = tt-it-docto-xml.qCom_forn 
                           tt-it-docto-xml.uCom_forn     = tt-it-docto-xml.uCom_forn
                           int_ds_it_docto_xml.qCom_forn = tt-it-docto-xml.qCom_forn
                           int_ds_it_docto_xml.uCom_forn = tt-it-docto-xml.uCom_forn
                           l-gera-nota = NO.
                   
               END.
               ELSE 
                   ASSIGN tt-it-docto-xml.item_do_forn  = "" 
                          tt-it-docto-xml.xprod         = ""
                          c-un-for                      = "".
            END.
            ELSE DO: 
                
                ASSIGN c-item_do_forn = tt-it-docto-xml.item_do_forn.
        
                FOR FIRST item-fornec NO-LOCK WHERE
                          item-fornec.cod-emitente = int_ds_it_docto_xml.cod_emitente AND 
                          item-fornec.item-do-forn = c-item_do_forn AND 
                          ITEM-fornec.ativo = YES query-tuning(no-lookahead): 
                    assign c-un-for = item-fornec.unid-med-for.
                end.

                IF NOT AVAIL ITEM-fornec 
                THEN DO:
                    ASSIGN c-item_do_forn = TRIM(tt-it-docto-xml.item_do_forn) NO-ERROR.
                    /*
                    IF ERROR-STATUS:ERROR THEN
                       ASSIGN c-item_do_forn = STRING(tt-it-docto-xml.item_do_forn).
                    */
                    FOR FIRST item-fornec NO-LOCK WHERE
                              item-fornec.cod-emitente = int_ds_it_docto_xml.cod_emitente AND 
                              item-fornec.item-do-forn = c-item_do_forn AND 
                              ITEM-fornec.ativo = YES query-tuning(no-lookahead):
                        assign c-un-for = item-fornec.unid-med-for.
                    end.
                END.

                if not avail item-fornec then do:

                    /* Utiliza multiplas unidades com o codigo alternativo cc0105 */
                    for first item-fornec-umd where
                              item-fornec-umd.cod-emitente = int_ds_it_docto_xml.cod_emitente   and
                              item-fornec-umd.cod-livre-1  = trim(tt-it-docto-xml.item_do_forn) and
                              item-fornec-umd.log-ativo NO-LOCK query-tuning(no-lookahead): 
                        assign c-un-for = item-fornec-umd.unid-med-for.                   
                    end.
                    
                    if avail item-fornec-umd then 
                    for first item-fornec no-lock where 
                              item-fornec.cod-emitente = int_ds_it_docto_xml.cod_emitente and
                              ITEM-fornec.it-codigo    = item-fornec-umd.it-codigo and
                              ITEM-fornec.ativo = yes query-tuning(no-lookahead): 
                    end.
                end. /* not avail item-fornec */
            end. /* else int_ds_ext_emitente */
                                     
            IF AVAIL ITEM-fornec OR 
               int_ds_it_docto_xml.tipo_nota = 3  
            THEN DO:
                 
                  ASSIGN de-fator = 0.
                  IF AVAIL item-fornec 
                  THEN DO: 
                      ASSIGN int_ds_it_docto_xml.it_codigo = item-fornec.it-codigo
                             tt-it-docto-xml.it_codigo     = ITEM-fornec.it-codigo. 

                  END.
                  ELSE DO:
                     ASSIGN  int_ds_it_docto_xml.it_codigo = tt-it-docto-xml.item_do_forn
                             tt-it-docto-xml.it_codigo     = int_ds_it_docto_xml.it_codigo 
                             int_ds_it_docto_xml.qCom_forn = tt-it-docto-xml.qCom
                             tt-it-docto-xml.qCom_forn     = tt-it-docto-xml.qCom  
                             de-fator                      =  1.                  
                  END.

                  find item where  
                       item.it-codigo = tt-it-docto-xml.it_codigo no-lock NO-ERROR.
                  if avail item then 
                      assign tt-it-docto-xml.xprod     = substring(ITEM.desc-item,1,60)
                             int_ds_it_docto_xml.xprod = substring(ITEM.desc-item,1,60).
                  
                  if avail item-fornec and
                           l-gera-nota = no and 
                           int_ds_docto_xml.tipo_nota <> 3
                  then do:
                     run retornaIndiceConversao in h-boin176 (input int_ds_it_docto_xml.it_codigo,
                                                              input int_ds_it_docto_xml.cod_emitente,
                                                              input /*item-fornec.unid-med-for*/ c-un-for,
                                                              output de-fator). 
                  end.
                               
                  if de-fator = 0 or de-fator = ? then assign de-fator = 1. 

                  assign int_ds_it_docto_xml.qCom = round(tt-it-docto-xml.qCom_forn / de-fator,0).

                  if int_ds_it_docto_xml.qCom <= 1 then 
                     assign int_ds_it_docto_xml.qCom = 1.
                  
                  assign int_ds_it_docto_xml.uCom   = if avail item then item.un else tt-it-docto-xml.uCom_forn  
                         int_ds_it_docto_xml.vUnCom = tt-it-docto-xml.vUnCom 
                         int_ds_it_docto_xml.vProd  = tt-it-docto-xml.vprod.
                  
                  IF AVAIL ITEM 
                  THEN DO:
                    
                      IF ITEM.tipo-contr < 3 THEN
                         ASSIGN int_ds_it_docto_xml.tipo_contr = 1.
    
                      IF ITEM.tipo-contr = 4 THEN
                         ASSIGN int_ds_it_docto_xml.tipo_contr = 4.
    
                      /* Notas Pepsico , apenas atualizam no re1001 */
                      FIND FIRST int_ds_ext_emitente NO-LOCK WHERE
                                 int_ds_ext_emitente.cod_emitente = int_ds_it_docto_xml.cod_emitente NO-ERROR.
                      IF AVAIL int_ds_ext_emitente AND  
                               int_ds_ext_emitente.gera_nota THEN 
                         ASSIGN int_ds_it_docto_xml.tipo_contr = 4
                                int_ds_it_docto_xml.xprod = substring(item.desc-item,1,60)
                                tt-it-docto-xml.xprod     = substring(item.desc-item,1,60).  

                      IF AVAIL pedido-compr AND 
                               l-valida = YES AND 
                               int_ds_it_docto_xml.tipo_nota = 1
                      THEN DO:
    
                           FIND FIRST ordem-compra WHERE
                                      ordem-compra.num-pedido = pedido-compr.num-pedido AND  
                                      ordem-compra.it-codigo  = ITEM.it-codigo NO-LOCK NO-ERROR.
                           IF AVAIL ordem-compra THEN
                              ASSIGN int_ds_it_docto_xml.numero_ordem = ordem-compra.numero-ordem. 
                           /* ELSE DO:
                                RUN pi-gera-erro(INPUT 6,    
                                                 INPUT "Numero de ordem n∆o encontrado para o pedido " + string(pedido-compr.num-pedido) + " Item:" + STRING(ITEM.it-codigo)).
                           END. */ 
                      END.
                  END.
                  ELSE DO:
                     RUN pi-gera-erro(INPUT 7,    
                                      INPUT "Item N∆o cadastrado " + string(tt-it-docto-xml.it_codigo)). 
                  END.
            END.
            ELSE DO:
                  RUN pi-gera-erro(INPUT 5,    
                                   INPUT "Relacionamento item x fornecedor n∆o cadastrado. Item: " + string(tt-it-docto-xml.item_do_forn) + " Fornecedor: " + STRING(int_ds_it_docto_xml.cod_emitente)). 
            END.

            IF tt-docto-xml.tipo_docto = 5  /* Balanáo */
            THEN DO:
               ASSIGN int_ds_it_docto_xml.situacao = 3. /* Atualizado */
            END.

            IF int_ds_it_docto_xml.lote = "" 
            OR int_ds_it_docto_xml.lote = ? THEN DO:

               FOR FIRST rat-lote WHERE
                         rat-lote.serie-docto  = int_ds_it_docto_xml.serie        AND
                         rat-lote.nro-docto    = int_ds_it_docto_xml.nnf          AND
                         rat-lote.cod-emitente = int_ds_it_docto_xml.cod_emitente AND
                         rat-lote.sequencia    = int_ds_it_docto_xml.sequencia    NO-LOCK query-tuning(no-lookahead):
               END.
               IF AVAIL rat-lote THEN DO:
                  FOR FIRST natur-oper WHERE
                            natur-oper.nat-operacao = rat-lote.nat-operacao NO-LOCK query-tuning(no-lookahead):
                  END.
                  IF AVAIL natur-oper THEN DO:
                     IF natur-oper.imp-nota THEN DO:
                        ASSIGN int_ds_it_docto_xml.lote = rat-lote.lote.
                     END.
                  END.
               END.
            END.

            RELEASE int_ds_it_docto_xml.

        END. /* each tt-it-docto-xml */
        
        IF LAST-OF(tt-docto-xml.arquivo) 
        THEN DO: 
               
           FOR EACH int_ds_doc_erro NO-LOCK WHERE
                    int_ds_doc_erro.serie_docto  = tt-docto-xml.serie        AND 
                    int_ds_doc_erro.CNPJ         = tt-docto-xml.CNPJ         AND    
                    int(int_ds_doc_erro.nro_docto) = INT(tt-docto-xml.NNF)   AND 
                    int_ds_doc_erro.tipo_nota    = tt-docto-xml.tipo_nota  
               BY int_ds_doc_erro.CNPJ
               BY int_ds_doc_erro.nro_docto
               BY int_ds_doc_erro.cod_erro query-tuning(no-lookahead):
                                 
               DISP int_ds_doc_erro.nro_docto
                    int_ds_doc_erro.serie_docto
                    int_ds_doc_erro.cod_emitente  
                    tt-docto-xml.cnpj
                    int_ds_doc_erro.cod_erro COLUMN-LABEL "Cod Erro"
                    int_ds_doc_erro.descricao FORMAT "X(100)"
                    WITH WIDTH 333 STREAM-IO FRAME f-erro DOWN.
               DOWN WITH FRAME f-erro. 
                  
           END.
        END.
          
        IF tt-docto-xml.tipo_docto = 5 THEN
            ASSIGN int_ds_docto_xml.situacao = 3. /* Atualizado */

        RELEASE int_ds_docto_xml.

        FIND FIRST emitente WHERE
                   emitente.cod-emitente = tt-docto-xml.cod_emitente NO-LOCK NO-ERROR.

        IF tt-docto-xml.tipo_docto = 5 /* Notas Balanáo atualiza o estoque automatico */ OR
           CAN-FIND(FIRST estabelec NO-LOCK WHERE estabelec.cgc = emitente.cgc) /* retiradas de loja p/ CD */
        THEN DO:
                     
           CREATE int_ds_docto_wms.
           ASSIGN int_ds_docto_wms.doc_numero_n   = INT(tt-docto-xml.nnf)
                  int_ds_docto_wms.doc_serie_s    = tt-docto-xml.serie   
                  int_ds_docto_wms.doc_origem_n   = tt-docto-xml.cod_emitente
                  int_ds_docto_wms.situacao       = /*1. /* Inclus∆o */*/ 10 /* novos status */
                  int_ds_docto_wms.tipo_nota      = tt-docto-xml.tipo_nota
                  int_ds_docto_wms.ENVIO_STATUS    = 1
                  int_ds_docto_wms.ENVIO_DATA_HORA = datetime(today).
                  int_ds_docto_wms.id_sequencial  = NEXT-VALUE(seq-int-ds-docto-wms). /* Preparaá∆o para integraá∆o com Procfit */
        
           IF AVAIL emitente THEN 
              ASSIGN int_ds_docto_wms.cnpj_cpf        = emitente.cgc 
                     int_ds_docto_wms.tipo_fornecedor = IF emitente.natureza = 1 THEN "F" ELSE "J".

        END.
        l-ok = YES.
    END. /* tt-docto-xml */
end.

{include/i-rpclo.i}   

RUN intprg/int888.p (INPUT "NFENDD",
                     INPUT "int500-cd-rp.p").

IF VALID-HANDLE(h-acomp) THEN 
   run pi-finalizar in h-acomp.

return "OK":U.

    
PROCEDURE pi-gera-erro:

     DEF INPUT PARAM p-cod-erro     LIKE int_ds_doc_erro.cod_erro.
     DEF INPUT PARAM p-desc-erro    LIKE int_ds_doc_erro.descricao.
      
     FOR  FIRST int_ds_doc_erro NO-LOCK WHERE
                int_ds_doc_erro.serie_docto  = tt-docto-xml.serie  AND 
                int_ds_doc_erro.cod_emitente = tt-docto-xml.cod_emitente AND
                int_ds_doc_erro.CNPJ         = tt-docto-xml.CNPJ  AND 
                int(int_ds_doc_erro.nro_docto) = int(tt-docto-xml.nNF)   AND 
                int_ds_doc_erro.tipo_nota    = tt-docto-xml.tipo_nota  AND
                int_ds_doc_erro.descricao    = p-desc-erro 
         query-tuning(no-lookahead) : END.

     IF NOT AVAIL int_ds_doc_erro 
     THEN DO:
        CREATE int_ds_doc_erro.
        ASSIGN int_ds_doc_erro.serie_docto  = tt-docto-xml.serie       
               int_ds_doc_erro.cod_emitente = tt-docto-xml.cod_emitente
               int_ds_doc_erro.CNPJ         = tt-docto-xml.CNPJ 
               int_ds_doc_erro.nro_docto    = tt-docto-xml.nNF   
               int_ds_doc_erro.tipo_nota    = tt-docto-xml.tipo_nota  
               int_ds_doc_erro.tipo_erro    = "ErroXML"   
               int_ds_doc_erro.cod_erro     = p-cod-erro       
               int_ds_doc_erro.descricao    = IF p-desc-erro = ? THEN "" ELSE p-desc-erro.
    
        IF AVAIL int_ds_it_docto_xml THEN 
           ASSIGN int_ds_doc_erro.sequencia = int_ds_it_docto_xml.sequencia.
    
     END.
     IF AVAIL int_ds_docto_xml THEN
        ASSIGN int_ds_docto_xml.situacao = 1.
        
     if avail int_ds_it_docto_xml then 
          assign int_ds_it_docto_xml.situacao = 1.

END PROCEDURE. 

PROCEDURE pi-IntegracaoNDD:

    DEF VAR c-xml       AS CHAR     NO-UNDO.
    DEF VAR c-arquivo   AS CHAR     NO-UNDO.
    DEF VAR h-documento AS HANDLE   NO-UNDO.
    DEF VAR h-raiz      AS HANDLE   NO-UNDO.
    DEF VAR c-arq-log   AS CHAR     NO-UNDO. 

    /*ASSIGN c-arq-log = session:TEMP-DIRECTORY + "log-int500.txt". 
              
    log-manager:logfile-name= c-arq-log.
    log-manager:log-entry-types= "4gltrace".*/
      
    DEF VAR pXMLResult  AS LONGCHAR NO-UNDO. 

    /* Chamada WebServices NDD*/
    run intprg/int500a-cd.p.

    FOR EACH NDD_ENTRYINTEGRATION NO-LOCK  WHERE    
             NDD_ENTRYINTEGRATION.kind            = 0 /* Envio */       AND   
             NDD_ENTRYINTEGRATION.status_         = 0 /* campo status pendente */ AND
             NDD_ENTRYINTEGRATION.documentnumber <> ?  
        BY NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID DESC
        query-tuning(no-lookahead)
        ON ERROR UNDO, NEXT:

        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Processando CD: " + string(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID)).
     
        /* NOTAS DO CD ENTRAM PELO int011 baseado em int_ds_nota_saida */
        if can-find (first estabelec no-lock where estabelec.cgc = STRING(NDD_ENTRYINTEGRATION.CNPJEMIT) and
                     estabelec.cod-estabel = "973") then do transaction:
                   
            IF NDD_ENTRYINTEGRATION.CNPJEMIT <> NDD_ENTRYINTEGRATION.CNPJDEST /* Notas de Balanáo tem o CNPJ iguais */ 
            THEN DO: 
                for first b-NDD_ENTRYINTEGRATION where 
                        rowid(b-NDD_ENTRYINTEGRATION) = rowid(NDD_ENTRYINTEGRATION) 
                    query-tuning(no-lookahead):
                    assign b-NDD_ENTRYINTEGRATION.status_ = 3.   
                    release b-NDD_ENTRYINTEGRATION.
                end.
                next.
            END.
        end.

        /* Desconsiderar os XMLS da PEPSICO - Retirado em 26/04/2017 p/ liberar recebimento XML da PEPSICO - Baccin
        FOR FIRST emitente NO-LOCK WHERE
                  emitente.cgc = string(NDD_ENTRYINTEGRATION.CNPJEMIT) :
        END.
        IF AVAIL emitente 
        THEN DO:
        
            FOR FIRST int_ds_ext_emitente NO-LOCK WHERE
                      int_ds_ext_emitente.cod-emitente = emitente.cod-emitente: END.

            IF (AVAIL int_ds_ext_emitente AND  
                      int_ds_ext_emitente.gera-nota)
            THEN DO:
                IF NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID <> 2716285 THEN DO: 
                    for first b-NDD_ENTRYINTEGRATION where 
                            rowid(b-NDD_ENTRYINTEGRATION) = rowid(NDD_ENTRYINTEGRATION) 
                        query-tuning(no-lookahead):
                        assign b-NDD_ENTRYINTEGRATION.status_ = 3.
                        release b-NDD_ENTRYINTEGRATION.
                    end.
                    next.  
                END.
            END.
        END.
        */

        empty temp-table tt-docto-xml.
        empty temp-table tt-it-docto-xml.
        empty temp-table tt-xml-dup.
        empty temp-table tt-digita.

        COPY-LOB FROM NDD_ENTRYINTEGRATION.documentdata TO pXMLResult.
        IF pXMLResult = "" OR
           pXMLResult = ?  THEN DO:
            for first b-NDD_ENTRYINTEGRATION where 
                    rowid(b-NDD_ENTRYINTEGRATION) = rowid(NDD_ENTRYINTEGRATION) 
                query-tuning(no-lookahead):
                assign b-NDD_ENTRYINTEGRATION.status_ = 2.     
                release b-NDD_ENTRYINTEGRATION.
            end.
            next.
        END.

        ASSIGN c-doc = PrintChar(pXMLResult)
               c-xml = SESSION:TEMP-DIRECTORY + "xml_temp" + string(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID) +  ".xml".
                           
        DO WHILE SEARCH(c-xml) <> ?:
           os-delete value(c-xml) no-wait no-console.  
        END.
                           
        RUN SaveXML(INPUT c-doc, 
                    INPUT c-xml).
        
        ASSIGN i-linha = 0.
               
        IF VALID-HANDLE(h-acomp) THEN
           RUN pi-acompanhar IN h-acomp(INPUT "Integracao CD: " + STRING(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID)).
             
        /* trata xml - gera tt-docto-xml */
        run pi-abre-xml(INPUT STRING(NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID),
                        INPUT c-xml).

        DO WHILE SEARCH(c-xml) <> ?:
           os-delete value(c-xml) no-wait no-console.
        END.
        
        /* Hoepers 05/04/2017 Incio Valida se nota j† processada, xml enviado mais de uma vez */
        FIND FIRST int_ds_nota_entrada NO-LOCK
            WHERE  int_ds_nota_entrada.nen_cnpj_origem_s = tt-docto-xml.CNPJ      
              AND  int_ds_nota_entrada.nen_serie_s       = tt-docto-xml.serie     
              AND  int_ds_nota_entrada.nen_notafiscal_n  = INT(tt-docto-xml.nnf) NO-ERROR.

        IF  AVAIL int_ds_nota_entrada OR
            tt-docto-xml.tipo_estab = 3
        THEN DO:
            FOR FIRST b-NDD_ENTRYINTEGRATION EXCLUSIVE-LOCK
                WHERE ROWID(b-NDD_ENTRYINTEGRATION) = ROWID(NDD_ENTRYINTEGRATION) query-tuning(no-lookahead):
                ASSIGN b-NDD_ENTRYINTEGRATION.status_ = 1.    
                RELEASE b-NDD_ENTRYINTEGRATION.
            END.
            NEXT.
        END.
        /* Hoepers 05/04/2017 Fim Valida se nota j† processada, xml enviado mais de uma vez */
        ASSIGN l-descarta = YES.
        ASSIGN L-GRAVA = NO.
        FOR FIRST tt-docto-xml query-tuning(no-lookahead): 
        END.
        FIND FIRST ttide no-error.
        IF AVAIL ttide AND 
           tt-docto-xml.dEmi >= 07/15/2016
        THEN do:
            ASSIGN L-GRAVA = YES. 
            ASSIGN L-DESCARTA = NO. 
            /* transferencia para o CD */
            IF ttide.natop BEGINS "Transf" 
            THEN do:
                l-grava = no.
                /* transferido para int011 03/04/2018 - Projeto Procfit - AVB
                IF tt-docto-xml.tipo_nota  = 3  AND  /* NFT */
                   tt-docto-xml.tipo_estab = 1   /* CD */
                THEN DO:
                    for first b-estab no-lock where
                              b-estab.cod-estabel = "973" query-tuning(no-lookahead):  /* destino */
                        for EACH estabelec no-lock where
                                 estabelec.cgc = tt-docto-xml.CNPJ,
                            EACH cst-estabelec NO-LOCK OF estabelec WHERE
                                 cst-estabelec.dt-fim-operacao >= tt-docto-xml.dEmi
                            query-tuning(no-lookahead):  /* Origem */
                            for first nota-fiscal no-lock where
                                      nota-fiscal.cod-estabel  = estabelec.cod-estabel                              and 
                                      nota-fiscal.serie        = trim(tt-docto-xml.serie)                           and 
                                      nota-fiscal.nr-nota-fis  = trim(string(int(tt-docto-xml.nnf),">>>9999999"))   and
                                      nota-fiscal.cgc          = b-estab.cgc query-tuning(no-lookahead): 
                                empty temp-table tt-it-docto-xml.
                                if substring(nota-fiscal.nat-operacao,1,4) <> "5605" /* Transferencia de saldo de ICMS */ and
                                   NOT nota-fiscal.nat-operacao begins "5929" /* outras */ then 
                                    run pi-gera-transf.
                                ELSE DO:
                                    ASSIGN l-descarta = YES.
                                END.
                            end. 
                        end.
                    end.
                END.
                */
            END. /* transferencia */

            IF L-GRAVA THEN run pi-grava-nota.
            RUN pi-valida-nota.

            for first b-NDD_ENTRYINTEGRATION EXCLUSIVE where 
                rowid(b-NDD_ENTRYINTEGRATION) = rowid(NDD_ENTRYINTEGRATION) 
                query-tuning(no-lookahead):

                /*
                DISPLAY 
                    l-grava l-ok i-ativo
                    WITH WIDTH 300 STREAM-IO.
                */

                if  int(tt-docto-xml.nNF)       <> ? and
                    int(tt-docto-xml.serie)     <> ? and
                    tt-docto-xml.dEmi           <> ? and
                    dec(tt-docto-xml.CNPJ)      <> ? and
                    dec(tt-docto-xml.CNPJ_dest) <> ? then do:
                    assign b-NDD_ENTRYINTEGRATION.documentnumber   = int(tt-docto-xml.nNF)
                           b-NDD_ENTRYINTEGRATION.SERIE            = int(tt-docto-xml.serie)  
                           b-NDD_ENTRYINTEGRATION.EMISSIONDATE     = tt-docto-xml.dEmi
                           b-NDD_ENTRYINTEGRATION.CNPJEMIT         = dec(tt-docto-xml.CNPJ)
                           b-NDD_ENTRYINTEGRATION.CNPJDEST         = dec(tt-docto-xml.CNPJ_dest)
                           no-error.
                end.
                if l-grava and l-ok and i-ativo = 1 then 
                    assign b-NDD_ENTRYINTEGRATION.status_ = 1.
                /*else if not l-grava  then
                    assign b-NDD_ENTRYINTEGRATION.status_ = 2.*/
                IF l-descarta THEN 
                    assign b-NDD_ENTRYINTEGRATION.status_ = 3.
                release b-NDD_ENTRYINTEGRATION.
            end.
        END.

        DO WHILE SEARCH(c-xml) <> ?:
           os-delete value(c-xml) no-wait no-console.
        END.

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
    
   FOR EACH tt-docto-xml WHERE    
            tt-docto-xml.tipo_estab = 4                        
           BREAK BY tt-docto-xml.arquivo query-tuning(no-lookahead): 
        RUN intprg/int999.p (INPUT "NFENDD", 
                             INPUT string(tt-docto-xml.arquivo) + "-" + string(tt-docto-xml.NNF),
                             INPUT tt-docto-xml.chnft,
                             INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                             INPUT c-seg-usuario,
                             INPUT "int500-cd-rp.p").
    END.
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
    EMPTY TEMP-TABLE ttpag.
    EMPTY TEMP-TABLE ttdetpag.
    EMPTY TEMP-TABLE ttInfAdic.
    EMPTY temp-table ttExporta.
    EMPTY TEMP-TABLE ttrastro.
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

    ASSIGN c-versao-xml = "3.1".

    FOR FIRST ttinfnfe query-tuning(no-lookahead):
    END.
    IF AVAIL ttinfnfe THEN
       ASSIGN c-versao-xml = ttinfnfe.versao.

    IF c-versao-xml = "4.00" 
    OR c-versao-xml = "4.0"
    OR c-versao-xml = "4" THEN DO:
       ASSIGN c-versao-xml = "4.0".
    END.

    /* AVB - Iniciar variavel para evitar pegar pedido da nota anterior quando n∆o tem tt-compra - 19/06/2017 */
    ASSIGN i-num-pedido = 0.
    
    /* inicio tratamento temp-tables geradas pelo XML */
    ASSIGN i-seq-item = 0.
    for first ttIde ON ERROR UNDO, RETURN ERROR query-tuning(no-lookahead):
    
        CREATE tt-docto-xml.
        ASSIGN tt-docto-xml.arquivo   = p-arquivo
               tt-docto-xml.ep_codigo = int(i-ep-codigo-usuario)
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
      
        ASSIGN tt-docto-xml.nNF = trim(STRING(ttIde.nnf,">>>9999999")).
        
        ASSIGN c-data = SUBSTRING(ttIde.dhEmi,1,10)
               c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
               tt-docto-xml.dEmi       = DATE(c-data)
               tt-docto-xml.dt_trans   = TODAY
               tt-docto-xml.tipo_docto = 1.
                
        /* emitente do documento */
        for first ttEmit query-tuning(no-lookahead):
           
           ASSIGN tt-docto-xml.CNPJ   = STRING(ttEmit.CNPJ). 
    
           FIND FIRST estabelec NO-LOCK WHERE
                      estabelec.cgc = tt-docto-xml.CNPJ NO-ERROR.
           IF AVAIL estabelec THEN 
              ASSIGN tt-docto-xml.tipo_nota = 3. /* NFT */
              
           /*** Forncederos ativos ***/
           EMPTY TEMP-TABLE tt-dist-emitente. 
    
           ASSIGN i-ativo = 0
                  c-valida-emitente = "".
    
           FOR EACH emitente NO-LOCK WHERE 
                    emitente.identific > 1 AND 
                    emitente.cgc       = tt-docto-xml.cnpj query-tuning(no-lookahead):
    
               FIND FIRST tt-dist-emitente WHERE
                          tt-dist-emitente.cod-emitente = emitente.cod-emitente NO-ERROR.
               IF NOT AVAIL tt-dist-emitente 
               THEN DO:
    
                  CREATE tt-dist-emitente.
                  ASSIGN tt-dist-emitente.cod-emitente = emitente.cod-emitente.
    
                  FIND FIRST dist-emitente WHERE
                             dist-emitente.cod-emitente = emitente.cod-emitente NO-ERROR.
                  IF AVAIL dist-emitente THEN
                     ASSIGN tt-dist-emitente.situacao = dist-emitente.idi-sit-fornec.
    
               END.
    
           END.
    
           FOR EACH tt-dist-emitente query-tuning(no-lookahead):
    
              IF tt-dist-emitente.situacao = 1 THEN
                 ASSIGN i-ativo = i-ativo + 1.        
    
           END.
    
           IF i-ativo <> 1 
           THEN DO:
    
               IF i-ativo = 0 THEN
                  ASSIGN c-valida-emitente = "Nenhum fornecedor ativo para o CNPJ: ".
    
               IF i-ativo > 1 THEN
                 ASSIGN c-valida-emitente = "Mais de um Fornecedor ativo para o CNPJ: ".  
    
               ASSIGN tt-docto-xml.tipo_estab = 4
                      tt-docto-xml.chnft      = c-valida-emitente + STRING(tt-docto-xml.cnpj). 
    
           END. 
           ELSE DO:
               FIND FIRST tt-dist-emitente WHERE
                          tt-dist-emitente.situacao = 1 NO-ERROR.
               IF AVAIL tt-dist-emitente THEN
                  ASSIGN tt-docto-xml.cod_emitente = tt-dist-emitente.cod-emitente. /* Considera apenas o fornecedor ativo */
           END.
    
           /*FIND FIRST emitente NO-LOCK WHERE 
                      emitente.cgc = trim(tt-docto-xml.cnpj) AND 
                      emitente.cod-emitente > 0  NO-ERROR.
           IF AVAIL emitente THEN 
              ASSIGN tt-docto-xml.cod-emitente = emitente.cod-emitente.*/
    
           ASSIGN tt-docto-xml.xNome  = STRING(ttEmit.xNome).
              
        end. /* ttEmit */
    
        /* destinatario */
        for first ttDest query-tuning(no-lookahead):
    
             ASSIGN tt-docto-xml.CNPJ_dest   = STRING(ttDest.CNPJ)
                    tt-docto-xml.tipo_estab  = 2.
    
             FIND FIRST estabelec NO-LOCK WHERE 
                        estabelec.cgc = trim(tt-docto-xml.CNPJ_dest) AND 
                        estabelec.cgc <> ""  NO-ERROR.
             IF AVAIL estabelec THEN DO:
                 
                 IF estabelec.cod-estabel = "973" THEN
                    ASSIGN tt-docto-xml.tipo_estab = 1. /* Principal/CD */
                 ELSE 
                    ASSIGN tt-docto-xml.tipo_estab = 2. /* Frente de Loja */
       
                 ASSIGN tt-docto-xml.cod_estab = estabelec.cod-estabel
                        tt-docto-xml.ep_codigo = int(estabelec.ep-codigo).
             END.  
             
             IF tt-docto-xml.CNPJ_dest = tt-docto-xml.cnpj  
             THEN DO:
    
                ASSIGN tt-docto-xml.tipo_estab = 0. /* Desconsiderar essas notas */  
                        
                    /* Verifica se a nota de balanáo */
                        
                    FOR FIRST nota-fiscal NO-LOCK WHERE
                              nota-fiscal.cod-estabel      = estabelec.cod-estabel AND 
                              nota-fiscal.serie            = tt-docto-xml.serie    AND
                              int(nota-fiscal.nr-nota-fis) = int(tt-docto-xml.nnf),
                        FIRST natur-oper WHERE
                              natur-oper.nat-operacao = nota-fiscal.nat-operacao AND 
                              natur-oper.tipo         = 1 query-tuning(no-lookahead): /* Entrada */  
                              
                        IF estabelec.cod-estabel = "973" THEN
                           ASSIGN tt-docto-xml.tipo_estab  = 1.
                        ELSE 
                           ASSIGN tt-docto-xml.tipo_estab  = 2. /* Considera como loja */
    
                         ASSIGN tt-docto-xml.tipo_docto   = 5 /* Nota Balanáo */
                                tt-docto-xml.nat_operacao = natur-oper.nat-operacao
                                tt-docto-xml.cfop         = INT(natur-oper.cod-cfop)
                                tt-docto-xml.num_pedido   = DEC(nota-fiscal.nr-pedcli).
                    end.
             END.
                        
             /*** Forncederos ativos ***/
             EMPTY TEMP-TABLE tt-dist-emitente. 
                   
             ASSIGN i-ativo = 0
                    c-valida-emitente = "".
    
             FOR EACH emitente NO-LOCK WHERE 
                      emitente.identific > 1 AND 
                      emitente.cgc       = tt-docto-xml.cnpj query-tuning(no-lookahead):
        
                 FIND FIRST tt-dist-emitente WHERE
                            tt-dist-emitente.cod-emitente = emitente.cod-emitente NO-ERROR.
                 IF NOT AVAIL tt-dist-emitente 
                 THEN DO:
                
                    CREATE tt-dist-emitente.
                    ASSIGN tt-dist-emitente.cod-emitente = emitente.cod-emitente.
                           
                    FIND FIRST dist-emitente WHERE
                               dist-emitente.cod-emitente = emitente.cod-emitente NO-ERROR.
                    IF AVAIL dist-emitente THEN
                       ASSIGN tt-dist-emitente.situacao = dist-emitente.idi-sit-fornec.
                   
                 END.
        
             END.
    
             FOR EACH tt-dist-emitente query-tuning(no-lookahead):
            
                IF tt-dist-emitente.situacao = 1 THEN
                   ASSIGN i-ativo = i-ativo + 1.        
                     
             END.
             
             IF i-ativo <> 1 
             THEN DO:
             
                 IF i-ativo = 0 THEN
                    ASSIGN c-valida-emitente = "Nenhum fornecedor ativo para o CNPJ: ".
                
                 IF i-ativo > 1 THEN
                   ASSIGN c-valida-emitente = "Mais de um Fornecedor ativo para o CNPJ: ".  
    
                 ASSIGN tt-docto-xml.tipo_estab = 4
                        tt-docto-xml.chnft      = c-valida-emitente + STRING(tt-docto-xml.cnpj). 
             
             END. 
             ELSE DO:
                 FIND FIRST tt-dist-emitente WHERE
                            tt-dist-emitente.situacao = 1 NO-ERROR.
                 IF AVAIL tt-dist-emitente THEN
                    ASSIGN tt-docto-xml.cod_emitente = tt-dist-emitente.cod-emitente. /* Considera apenas o fornecedor ativo */
             END.
    
             FOR FIRST b-int_ds_docto_xml NO-LOCK WHERE
                       b-int_ds_docto_xml.tipo_nota    = tt-docto-xml.tipo_nota    AND 
                       b-int_ds_docto_xml.CNPJ         = tt-docto-xml.CNPJ         AND                             
                       int(b-int_ds_docto_xml.nNF)     = int(tt-docto-xml.nNF)     AND
                       b-int_ds_docto_xml.serie        = tt-docto-xml.serie
                 query-tuning(no-lookahead):
    
             END.
                     
             IF AVAIL b-int_ds_docto_xml THEN
                ASSIGN tt-docto-xml.tipo_estab = 3. /* Documento j† cadastrado na base */
    
             IF tt-docto-xml.tipo_estab = 2 /* Lj */
             THEN DO:
                   FOR FIRST int_ds_nota_entrada NO-LOCK WHERE
                             int_ds_nota_entrada.nen_cnpj_origem_s = tt-docto-xml.CNPJ     AND 
                             int_ds_nota_entrada.nen_serie_s       = tt-docto-xml.serie    AND 
                             int_ds_nota_entrada.nen_notafiscal_n  = int(tt-docto-xml.nnf) AND 
                             int_ds_nota_entrada.nen_cfop_n        = tt-docto-xml.cfop
                       query-tuning(no-lookahead): END.
    
                   IF AVAIL int_ds_nota_entrada THEN
                      ASSIGN tt-docto-xml.tipo_estab = 3 /* transferencia j† gerada em loja */.
             END. 
        end. /* ttDest */
    
        /* chave da NFe */
        FOR FIRST ttinfprot query-tuning(no-lookahead): 
            ASSIGN tt-docto-xml.chNfe = ttinfprot.chNfe.
        END.
    
        /* totais de icms */
        for first ttICMSTot query-tuning(no-lookahead):
       
            ASSIGN tt-docto-xml.VNF              = dec(STRING(ttICMSTot.VNF       )).   
            ASSIGN tt-docto-xml.vbc              = dec(STRING(ttICMSTot.vBC       )).
            ASSIGN tt-docto-xml.tot_desconto     = dec(STRING(ttICMSTot.vDesc     )).
            ASSIGN tt-docto-xml.valor_frete      = dec(STRING(ttICMSTot.vFrete    )).
            ASSIGN tt-docto-xml.valor_mercad     = dec(STRING(ttICMSTot.vProd     )).
            ASSIGN tt-docto-xml.valor_outras     = dec(STRING(ttICMSTot.vOutro    )).
            ASSIGN tt-docto-xml.valor_seguro     = dec(STRING(ttICMSTot.vSeg      )).
            ASSIGN tt-docto-xml.valor_icms       = dec(STRING(ttICMSTot.vICMS     )).
            ASSIGN tt-docto-xml.vbc_cst          = dec(STRING(ttICMSTot.vBCST     )).
            ASSIGN tt-docto-xml.valor_st         = dec(STRING(ttICMSTot.vST       )).
            ASSIGN tt-docto-xml.valor_ii         = dec(STRING(ttICMSTot.vII       )).
            ASSIGN tt-docto-xml.valor_ipi        = dec(STRING(ttICMSTot.vIPI      )).
            ASSIGN tt-docto-xml.valor_pis        = dec(STRING(ttICMSTot.vPIS      )).
            ASSIGN tt-docto-xml.valor_cofins     = dec(STRING(ttICMSTot.vCOFINS   )).
            ASSIGN tt-docto-xml.valor_fcp        = dec(STRING(ttICMSTot.vFCP      )). /* novo 4.0 */
            ASSIGN tt-docto-xml.valor_fcp_st     = dec(STRING(ttICMSTot.vFCPST    )). /* novo 4.0 */
            ASSIGN tt-docto-xml.valor_fcp_st_ret = dec(STRING(ttICMSTot.vFCPSTRet )). /* novo 4.0 */
            ASSIGN tt-docto-xml.valor_ipi_devol  = dec(STRING(ttICMSTot.vIPIDevol )). /* novo 4.0 */
           
        end. /* ttICMSTot */
    
        for first ttTransp query-tuning(no-lookahead):
            ASSIGN tt-docto-xml.modFrete = ttTransp.modFrete.
        end.
    
        for first ttCompra query-tuning(no-lookahead):
          ASSIGN i-num-pedido = int(ttCompra.xped) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN
              ASSIGN i-num-pedido = 0.      
          if trim(ttCompra.xped) = "PBM" then
              ASSIGN i-num-pedido = ?.
        end.
        
        ASSIGN de-tot-pis       = 0 
               de-tot-cofins    = 0
               de-valor-st-calc = 0
               de-valor-st-tmp  = 0
               de-vbc-cst-fcp   = 0.
    
        /* itens da nota */
        FOR EACH ttprod 
            BY ttprod.nitem query-tuning(no-lookahead):
                    
           ASSIGN i-seq-item = i-seq-item + 10.
           IF i-num-pedido = 0 THEN DO:
               ASSIGN i-num-pedido = int(ttprod.xped) NO-ERROR.
               IF ERROR-STATUS:ERROR THEN
                  ASSIGN i-num-pedido = 0.
           END.
           if trim(ttprod.xped) = "PBM" then
               ASSIGN i-num-pedido = ?.
           
           IF ttprod.cEAN = "SEM GTIN" 
           OR ttprod.cEAN MATCHES "*SEM*" THEN
              ASSIGN ttprod.cEAN = "0".                                      

           IF ttprod.cEANTrib = "SEM GTIN" 
           OR ttprod.cEANTrib MATCHES "*SEM*" THEN
              ASSIGN ttprod.cEANTrib = "0".                                      

           CREATE tt-it-docto-xml.                                              
           ASSIGN tt-it-docto-xml.arquivo       = tt-docto-xml.arquivo           
                  tt-it-docto-xml.serie         = tt-docto-xml.serie             
                  tt-it-docto-xml.nNF           = tt-docto-xml.nNF               
                  tt-it-docto-xml.CNPJ          = tt-docto-xml.CNPJ              
                  tt-it-docto-xml.tipo_nota     = tt-docto-xml.tipo_nota         
                  tt-it-docto-xml.item_do_forn  = trim(STRING(ttprod.cProd))  
                  tt-it-docto-xml.sequencia     = i-seq-item
                  tt-it-docto-xml.xProd         = trim(SUBstring(ttprod.xProd,1,60))
                  tt-it-docto-xml.ncm           = INT(STRING(ttprod.ncm))             
                  tt-it-docto-xml.cfop          = INT(STRING(ttprod.cfop))                 
                  tt-it-docto-xml.uCom          = SUBstring(STRING(ttprod.uCom),1,2)                        
                  tt-it-docto-xml.uCom_forn     = SUBstring(STRING(ttprod.uCom),1,2)                    
                  tt-it-docto-xml.qCom          = dec(ttprod.qCom)                    
                  tt-it-docto-xml.qCom_forn     = dec(ttprod.qCom)                 
                  tt-it-docto-xml.vUnCom        = dec(ttprod.vUnCom) /* / 10000000000 */  
                  tt-it-docto-xml.vProd         = dec(ttprod.vProd)                 
                  tt-it-docto-xml.vDesc         = dec(ttprod.vDesc)                 
                  tt-it-docto-xml.num_pedido    = i-num-pedido
                  tt-it-docto-xml.EAN           = int64(ttprod.cEAN) /* novo 4.0 */
                  tt-it-docto-xml.CEST          = ttprod.CEST      /* novo 4.0 */ 
                  tt-it-docto-xml.EANTrib       = int64(ttprod.cEANTrib). /* novo 4.0 */
    
           assign tt-it-docto-xml.dEan          = DEC(ttprod.cEan) no-error.
                   
           ASSIGN c-data   = ""
                  c-anvisa = "".

           IF c-versao-xml MATCHES "*3*" THEN DO:
              for first ttmed WHERE
                  ttmed.nItem = ttprod.nitem query-tuning(no-lookahead):
                  ASSIGN tt-it-docto-xml.lote = if ttmed.nlote <> ? then ttmed.nlote else ""
                         c-data = SUBSTRING(ttmed.dfab,1,10)
                         c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                         tt-it-docto-xml.dFab  =  DATE(c-data).
                  ASSIGN c-data = SUBSTRING(ttmed.dval,1,10)
                         c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                         tt-it-docto-xml.dVal  =  DATE(c-data).
              END.
           END.
           ELSE DO:
              for first ttmed WHERE
                  ttmed.nItem = ttprod.nitem query-tuning(no-lookahead):
                  /*IF ttmed.cProdANVISA MATCHES "*ISENTO*" THEN*/
                     ASSIGN tt-it-docto-xml.anvisa = 0. 
                  /*ELSE 
                     ASSIGN tt-it-docto-xml.anvisa = int64(TTMED.cProdANVISA). /* novo 4.0 */*/
              END.

              /* ttrastro - tag nova nfe 4.0 */

              FOR FIRST ttrastro WHERE
                        ttrastro.nItem = ttprod.nitem query-tuning(no-lookahead):
                  ASSIGN tt-it-docto-xml.lote = if ttrastro.nlote <> ? then ttrastro.nlote else ""
                         c-data = SUBSTRING(ttrastro.dfab,1,10)
                         c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                         tt-it-docto-xml.dFab  =  DATE(c-data).
                  ASSIGN c-data = SUBSTRING(ttrastro.dval,1,10)
                         c-data = ENTRY(3,c-data,"-") + "/" + ENTRY(2,c-data,"-")  + "/" + ENTRY(1,c-data,"-")
                         tt-it-docto-xml.dVal  =  DATE(c-data).
              END.
           END.
    
           ASSIGN i-orig-icms          = 0
                  i-modBC              = 0
                  de-vbc-icms          = 0
                  de-picms             = 0
                  de-vicms             = 0
                  de-pmvast            = 0
                  de-vbcst             = 0
                  de-picmsst           = 0
                  de-vicmsst           = 0
                  de-vbcstret          = 0
                  de-vicmsstret        = 0
                  de-vicmsDeson        = 0
                  de-predbc-icms       = 0
                  de-valor_fcp         = 0
                  de-valor_fcp_st      = 0
                  de-valor-base-fcp-st = 0  
                  de-perc-fcp-st       = 0
                  de-valor_fcp_st_ret  = 0
                  de-valor_ipi_devol   = 0.

           for first ttICMS00 WHERE
               ttICMS00.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN  i-orig-icms         = ttICMS00.orig
                       i-cst-icms          = ttICMS00.cst  
                       i-modBC             = ttICMS00.modBC     
                       de-vbc-icms         = ttICMS00.vbc  
                       de-picms            = ttICMS00.picms     
                       de-vicms            = ttICMS00.vicms
                       de-pmvast           = ttICMS00.pmvast  
                       de-vbcst            = ttICMS00.vbcst
                       de-picmsst          = ttICMS00.picmsst
                       de-vicmsst          = ttICMS00.vicmsst     
                       de-vbcstret         = ttICMS00.vbcstret   
                       de-vicmsstret       = ttICMS00.vicmsstret
                       de-valor_fcp        = ttICMS00.vFCP 
                       de-valor_fcp_st     = ttICMS00.vFCPST 
                       de-valor_fcp_st_ret = ttICMS00.vFCPSTRet 
                       de-valor_ipi_devol  = ttICMS00.vIPIDevol
                       de-valor-base-fcp-st = ttICMS00.vBCFCPST
                       de-perc-fcp-st       = ttICMS00.pFCPST.  
           END. /* ttICMS00*/
    
           for FIRST ttICMS10 WHERE 
               ttICMS10.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN  i-orig-icms         = ttICMS10.orig
                       i-cst-icms          = ttICMS10.cst  
                       i-modBC             = ttICMS10.modBC     
                       de-vbc-icms         = ttICMS10.vbc  
                       de-picms            = ttICMS10.picms     
                       de-vicms            = ttICMS10.vicms
                       de-pmvast           = ttICMS10.pmvast  
                       de-vbcst            = ttICMS10.vbcst
                       de-picmsst          = ttICMS10.picmsst
                       de-vicmsst          = ttICMS10.vicmsst     
                       de-vbcstret         = ttICMS10.vbcstret   
                       de-vicmsstret       = ttICMS10.vicmsstret
                       de-valor_fcp        = ttICMS10.vFCP 
                       de-valor_fcp_st     = ttICMS10.vFCPST 
                       de-valor_fcp_st_ret = ttICMS10.vFCPSTRet 
                       de-valor_ipi_devol  = ttICMS10.vIPIDevol
                       de-valor-base-fcp-st = ttICMS10.vBCFCPST
                       de-perc-fcp-st       = ttICMS10.pFCPST.  
           end. /* ttICMS10 */
            
           for FIRST ttICMS20 where
               ttICMS20.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN  i-orig-icms         = ttICMS20.orig
                       i-cst-icms          = ttICMS20.cst  
                       i-modBC             = ttICMS20.modBC     
                       de-vbc-icms         = ttICMS20.vbc  
                       de-picms            = ttICMS20.picms     
                       de-vicms            = ttICMS20.vicms
                       de-pmvast           = ttICMS20.pmvast  
                       de-vbcst            = ttICMS20.vbcst
                       de-picmsst          = ttICMS20.picmsst
                       de-vicmsst          = ttICMS20.vicmsst     
                       de-vbcstret         = ttICMS20.vbcstret   
                       de-vicmsstret       = ttICMS20.vicmsstret
                       de-predbc-icms      = ttICMS20.pRedBC
                       de-valor_fcp        = ttICMS20.vFCP 
                       de-valor_fcp_st     = ttICMS20.vFCPST 
                       de-valor_fcp_st_ret = ttICMS20.vFCPSTRet 
                       de-valor_ipi_devol  = ttICMS20.vIPIDevol
                       de-valor-base-fcp-st = ttICMS20.vBCFCPST
                       de-perc-fcp-st       = ttICMS20.pFCPST.  
           end. /*ttICMS20 */
           
           for first ttICMS30  where
               ttICMS30.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN  i-orig-icms         = ttICMS30.orig
                       i-cst-icms          = ttICMS30.cst  
                       i-modBC             = ttICMS30.modBC     
                       de-vbc-icms         = ttICMS30.vbc  
                       de-picms            = ttICMS30.picms     
                       de-vicms            = ttICMS30.vicms
                       de-pmvast           = ttICMS30.pmvast  
                       de-vbcst            = ttICMS30.vbcst
                       de-picmsst          = ttICMS30.picmsst
                       de-vicmsst          = ttICMS30.vicmsst     
                       de-vbcstret         = ttICMS30.vbcstret   
                       de-vicmsstret       = ttICMS30.vicmsstret
                       de-predbc-icms      = ttICMS30.pRedBC
                       de-valor_fcp        = ttICMS30.vFCP 
                       de-valor_fcp_st     = ttICMS30.vFCPST 
                       de-valor_fcp_st_ret = ttICMS30.vFCPSTRet 
                       de-valor_ipi_devol  = ttICMS30.vIPIDevol
                       de-valor-base-fcp-st = ttICMS30.vBCFCPST
                       de-perc-fcp-st       = ttICMS30.pFCPST.  
           end. /* ttICMS30 */
    
           for first ttICMS40  WHERE
               ttICMS40.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN  i-orig-icms         = ttICMS40.orig
                       i-cst-icms          = ttICMS40.cst  
                       i-modBC             = ttICMS40.modBC     
                       de-vbc-icms         = ttICMS40.vbc  
                       de-picms            = ttICMS40.picms     
                       de-vicms            = ttICMS40.vicms
                       de-pmvast           = ttICMS40.pmvast  
                       de-vbcst            = ttICMS40.vbcst
                       de-picmsst          = ttICMS40.picmsst
                       de-vicmsst          = ttICMS40.vicmsst     
                       de-vbcstret         = ttICMS40.vbcstret   
                       de-vicmsstret       = ttICMS40.vicmsstret
                       de-vicmsDeson       = ttICMS40.vicmsDeson
                       de-predbc-icms      = ttICMS40.pRedBC
                       de-valor_fcp        = ttICMS40.vFCP 
                       de-valor_fcp_st     = ttICMS40.vFCPST 
                       de-valor_fcp_st_ret = ttICMS40.vFCPSTRet 
                       de-valor_ipi_devol  = ttICMS40.vIPIDevol
                       de-valor-base-fcp-st = ttICMS40.vBCFCPST
                       de-perc-fcp-st       = ttICMS40.pFCPST.  
           end. /* ttICMS40*/
             
           for first ttICMS51 WHERE 
               ttICMS51.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN  i-orig-icms         = ttICMS51.orig
                       i-cst-icms          = ttICMS51.cst  
                       i-modBC             = ttICMS51.modBC     
                       de-vbc-icms         = ttICMS51.vbc  
                       de-picms            = ttICMS51.picms     
                       de-vicms            = ttICMS51.vicms
                       de-pmvast           = ttICMS51.pmvast  
                       de-vbcst            = ttICMS51.vbcst
                       de-picmsst          = ttICMS51.picmsst
                       de-vicmsst          = ttICMS51.vicmsst     
                       de-vbcstret         = ttICMS51.vbcstret   
                       de-vicmsstret       = ttICMS51.vicmsstret
                       de-vicmsDeson       = ttICMS51.vicmsDeson
                       de-predbc-icms      = ttICMS51.pRedBC
                       de-valor_fcp        = ttICMS51.vFCP 
                       de-valor_fcp_st     = ttICMS51.vFCPST 
                       de-valor_fcp_st_ret = ttICMS51.vFCPSTRet 
                       de-valor_ipi_devol  = ttICMS51.vIPIDevol
                       de-valor-base-fcp-st = ttICMS51.vBCFCPST
                       de-perc-fcp-st       = ttICMS51.pFCPST.  
           end. /* ttICMS51 */
          
           /* n∆o estava trandao - AVB 31/08/2016 */
           for first ttICMS60 WHERE 
               ttICMS60.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN  i-orig-icms         = ttICMS60.orig
                       i-cst-icms          = ttICMS60.cst  
                       i-modBC             = ttICMS60.modBC     
                       de-vbc-icms         = ttICMS60.vbc  
                       de-picms            = ttICMS60.picms     
                       de-vicms            = ttICMS60.vicms
                       de-pmvast           = ttICMS60.pmvast  
                       de-vbcst            = ttICMS60.vbcst
                       de-picmsst          = ttICMS60.picmsst
                       de-vicmsst          = ttICMS60.vicmsst     
                       de-vbcstret         = ttICMS60.vbcstret   
                       de-vicmsstret       = ttICMS60.vicmsstret
                       de-predbc-icms      = ttICMS60.pRedBC
                       de-valor_fcp        = ttICMS60.vFCP 
                       de-valor_fcp_st     = ttICMS60.vFCPST 
                       de-valor_fcp_st_ret = ttICMS60.vFCPSTRet 
                       de-valor_ipi_devol  = ttICMS60.vIPIDevol
                       de-valor-base-fcp-st = ttICMS60.vBCFCPST
                       de-perc-fcp-st       = ttICMS60.pFCPST.  
           end. /* ttICMS60 */
    
           for first ttICMS70 WHERE 
               ttICMS70.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN  i-orig-icms         = ttICMS70.orig
                       i-cst-icms          = ttICMS70.cst  
                       i-modBC             = ttICMS70.modBC     
                       de-vbc-icms         = ttICMS70.vbc  
                       de-picms            = ttICMS70.picms     
                       de-vicms            = ttICMS70.vicms
                       de-pmvast           = ttICMS70.pmvast  
                       de-vbcst            = ttICMS70.vbcst
                       de-picmsst          = ttICMS70.picmsst
                       de-vicmsst          = ttICMS70.vicmsst     
                       de-vbcstret         = ttICMS70.vbcstret   
                       de-vicmsstret       = ttICMS70.vicmsstret
                       de-predbc-icms      = ttICMS70.pRedBC
                       de-valor_fcp        = ttICMS70.vFCP 
                       de-valor_fcp_st     = ttICMS70.vFCPST 
                       de-valor_fcp_st_ret = ttICMS70.vFCPSTRet 
                       de-valor_ipi_devol  = ttICMS70.vIPIDevol
                       de-valor-base-fcp-st = ttICMS70.vBCFCPST
                       de-perc-fcp-st       = ttICMS70.pFCPST.  
           end. /* ttICMS70 */
    
           for first ttICMS90 WHERE 
               ttICMS90.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN  i-orig-icms         = ttICMS90.orig
                       i-cst-icms          = ttICMS90.cst  
                       i-modBC             = ttICMS90.modBC     
                       de-vbc-icms         = ttICMS90.vbc  
                       de-picms            = ttICMS90.picms     
                       de-vicms            = ttICMS90.vicms
                       de-pmvast           = ttICMS90.pmvast  
                       de-vbcst            = ttICMS90.vbcst
                       de-picmsst          = ttICMS90.picmsst
                       de-vicmsst          = ttICMS90.vicmsst     
                       de-vbcstret         = ttICMS90.vbcstret   
                       de-vicmsstret       = ttICMS90.vicmsstret
                       de-predbc-icms      = ttICMS90.pRedBC
                       de-valor_fcp        = ttICMS90.vFCP 
                       de-valor_fcp_st     = ttICMS90.vFCPST 
                       de-valor_fcp_st_ret = ttICMS90.vFCPSTRet 
                       de-valor_ipi_devol  = ttICMS90.vIPIDevol
                       de-valor-base-fcp-st = ttICMS90.vBCFCPST
                       de-perc-fcp-st       = ttICMS90.pFCPST.  
           end. /* ttICMS90*/
    
           for first ttICMSSN101 WHERE 
               ttICMSSN101.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN i-orig-icms   = ttICMSSN101.orig.
           end.
    
           for first ttICMSSN102 WHERE 
               ttICMSSN102.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN i-orig-icms   = ttICMSSN102.orig.
           END.
           
           for first ttICMSSN201 WHERE 
               ttICMSSN201.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN i-orig-icms         = ttICMSSN201.orig
                      i-modBC             = ttICMSSN201.modBC     
                      de-vbc-icms         = ttICMSSN201.vbc  
                      de-picms            = ttICMSSN201.picms     
                      de-vicms            = ttICMSSN201.vicms
                      de-pmvast           = ttICMSSN201.pmvast  
                      de-vbcst            = ttICMSSN201.vbcst
                      de-picmsst          = ttICMSSN201.picmsst
                      de-vicmsst          = ttICMSSN201.vicmsst
                      de-valor_fcp        = ttICMSSN201.vFCP 
                      de-valor_fcp_st     = ttICMSSN201.vFCPST 
                      de-valor_fcp_st_ret = ttICMSSN201.vFCPSTRet 
                      de-valor_ipi_devol  = ttICMSSN201.vIPIDevol
                      de-valor-base-fcp-st = ttICMSSN201.vBCFCPST
                      de-perc-fcp-st       = ttICMSSN201.pFCPST.  
           end. /* ttICMSSN201 */
          
           for FIRST ttICMSSN202 WHERE 
               ttICMSSN202.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN i-orig-icms         = ttICMSSN202.orig
                      i-modBC             = ttICMSSN202.modBC     
                      de-vbc-icms         = ttICMSSN202.vbc  
                      de-picms            = ttICMSSN202.picms     
                      de-vicms            = ttICMSSN202.vicms
                      de-pmvast           = ttICMSSN202.pmvast  
                      de-vbcst            = ttICMSSN202.vbcst
                      de-picmsst          = ttICMSSN202.picmsst
                      de-vicmsst          = ttICMSSN202.vicmsst
                      de-valor_fcp        = ttICMSSN202.vFCP 
                      de-valor_fcp_st     = ttICMSSN202.vFCPST 
                      de-valor_fcp_st_ret = ttICMSSN202.vFCPSTRet 
                      de-valor_ipi_devol  = ttICMSSN202.vIPIDevol
                      de-valor-base-fcp-st = ttICMSSN202.vBCFCPST
                      de-perc-fcp-st       = ttICMSSN202.pFCPST.  
           end. /* ttICMSSN202 */
    
           for FIRST ttICMSSN500 WHERE 
               ttICMSSN500.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN i-orig-icms   = ttICMSSN500.orig
                      de-vbcstret   = ttICMSSN500.vbcstret   
                      de-vicmsstret = ttICMSSN500.vicmsstret.
                      /*de-predbc-icms = ttICMSSN500.pRedBC.*/
           end.
    
           for FIRST ttICMSSN900 WHERE 
               ttICMSSN900.nItem = ttprod.nitem query-tuning(no-lookahead):
               ASSIGN i-orig-icms         = ttICMSSN900.orig
                      i-cst-icms          = ttICMSSN900.cst  
                      i-modBC             = ttICMSSN900.modBC     
                      de-vbc-icms         = ttICMSSN900.vbc  
                      de-picms            = ttICMSSN900.picms     
                      de-vicms            = ttICMSSN900.vicms
                      de-pmvast           = ttICMSSN900.pmvast  
                      de-vbcst            = ttICMSSN900.vbcst
                      de-picmsst          = ttICMSSN900.picmsst
                      de-vicmsst          = ttICMSSN900.vicmsst
                      de-valor_fcp        = ttICMSSN900.vFCP 
                      de-valor_fcp_st     = ttICMSSN900.vFCPST 
                      de-valor_fcp_st_ret = ttICMSSN900.vFCPSTRet 
                      de-valor_ipi_devol  = ttICMSSN900.vIPIDevol
                      de-valor-base-fcp-st = ttICMSSN900.vBCFCPST
                      de-perc-fcp-st       = ttICMSSN900.pFCPST.  
           end.

           ASSIGN tt-it-docto-xml.orig_icms     = i-orig-icms 
                  tt-it-docto-xml.cst_icms      = i-cst-icms  
                  tt-it-docto-xml.modBC         = i-modBC
                  tt-it-docto-xml.vbc_icms      = de-vbc-icms  
                  tt-it-docto-xml.picms         = de-picms     
                  tt-it-docto-xml.vicms         = de-vicms     
                  tt-it-docto-xml.pmvast        = de-pmvast    
                  tt-it-docto-xml.vbcst         = de-vbcst     
                  tt-it-docto-xml.picmsst       = de-picmsst   
                  tt-it-docto-xml.vicmsst       = de-vicmsst   
                  tt-it-docto-xml.vbcstret      = de-vbcstret  
                  tt-it-docto-xml.vicmsstret    = de-vicmsstret
                  de-vbc-cst-fcp                = de-vbc-cst-fcp + de-valor-base-fcp-st.
    
           assign tt-it-docto-xml.vicmsDeson       = de-vicmsDeson
                  tt-it-docto-xml.predBc           = de-predbc-icms
                  tt-it-docto-xml.vOutro           = ttProd.vOutro       
                  tt-it-docto-xml.valor_fcp        = IF de-valor_fcp         = ? THEN 0 ELSE de-valor_fcp         /* novo 4.0 */
                  tt-it-docto-xml.valor_fcp_st     = IF de-valor_fcp_st      = ? THEN 0 ELSE de-valor_fcp_st      /* novo 4.0 */
                  tt-it-docto-xml.valor_fcp_st_ret = IF de-valor_fcp_st_ret  = ? THEN 0 ELSE de-valor_fcp_st_ret  /* novo 4.0 */
                  tt-it-docto-xml.valor_ipi_devol  = IF de-valor_ipi_devol   = ? THEN 0 ELSE de-valor_ipi_devol   /* novo 4.0 */
                  tt-it-docto-xml.vbcst_fcp        = IF de-valor-base-fcp-st = ? THEN 0 ELSE de-valor-base-fcp-st /* novo 4.0 */
                  tt-it-docto-xml.picmsst_fcp      = IF de-perc-fcp-st       = ? THEN 0 ELSE de-perc-fcp-st.      /* novo 4.0 */
    
           for FIRST ttIPITrib WHERE
               ttIPITrib.nItem = ttprod.nitem query-tuning(no-lookahead):
               assign tt-it-docto-xml.cst_ipi = ttIPITrib.CST
                      tt-it-docto-xml.vbc_ipi = ttIPITrib.vBC
                      tt-it-docto-xml.pipi    = ttIPITrib.pIPI
                      tt-it-docto-xml.vipi    = ttIPITrib.vIPI.
           end.
    
           ASSIGN tt-it-docto-xml.cst_pis    = 0
                  tt-it-docto-xml.vbc_pis    = 0
                  tt-it-docto-xml.ppis       = 0
                  tt-it-docto-xml.vpis       = 0
                  tt-it-docto-xml.cst_cofins = 0 
                  tt-it-docto-xml.vbc_cofins = 0 
                  tt-it-docto-xml.pcofins    = 0 
                  tt-it-docto-xml.vcofins    = 0.
    
            FOR FIRST natur-oper NO-LOCK 
                WHERE natur-oper.nat-operacao = tt-it-docto-xml.nat_operacao query-tuning(no-lookahead): 
    
                IF  natur-oper.log-contrib-st-antec
                THEN DO:
                    RUN intprg/int510-icms-st.p (INPUT tt-it-docto-xml.cod_emitente,
                                                 INPUT tt-it-docto-xml.it_codigo,   
                                                 INPUT tt-it-docto-xml.nat_operacao,
                                                 INPUT tt-docto-xml.cod_estab,        
                                                 INPUT tt-it-docto-xml.qCom,        
                                                 INPUT tt-it-docto-xml.vprod,    
                                                 INPUT tt-it-docto-xml.vdesc,
                                                 INPUT int_ds_it_docto_xml.vipi,
                                                 OUTPUT de-base-st-calc, 
                                                 OUTPUT de-valor-st-tmp, 
                                                 OUTPUT de-perc-st-calc,
                                                 OUTPUT c-tabela-pauta,
                                                 OUTPUT de-tabela-pauta,
                                                 OUTPUT de-per-sub-tri).
    
                    ASSIGN de-valor-st-calc = de-valor-st-calc + de-valor-st-tmp.
                END.
            END.
    
           ASSIGN c-item_do_forn = ""
                  de-aliq-pis    = 0
                  de-aliq-cofins = 0.
    
           ASSIGN c-item_do_forn = tt-it-docto-xml.item_do_forn.
    
           for first item-fornec no-lock where
               item-fornec.cod-emitente = tt-docto-xml.cod_emitente AND 
               item-fornec.item-do-forn = c-item_do_forn AND 
               ITEM-fornec.ativo = YES query-tuning(no-lookahead): end.
    
           if not avail ITEM-fornec 
           then do:
                ASSIGN c-item_do_forn = TRIM(tt-it-docto-xml.item_do_forn) NO-ERROR.
                /*
                IF ERROR-STATUS:ERROR THEN
                   ASSIGN c-item_do_forn = STRING (tt-it-docto-xml.item_do_forn).
                   */
                for first item-fornec no-lock where 
                    item-fornec.cod-emitente = tt-docto-xml.cod_emitente AND 
                    item-fornec.item-do-forn = c-item_do_forn AND 
                    ITEM-fornec.ativo = YES query-tuning(no-lookahead):
                end.
                if not avail item-fornec then do:
                    /* Utiliza multiplas unidades com o codigo alternativo cc0105 */
                    for first item-fornec-umd where
                              item-fornec-umd.cod-emitente = tt-docto-xml.cod_emitente   and
                              item-fornec-umd.cod-livre-1  = TRIM(tt-it-docto-xml.item_do_forn) and
                              item-fornec-umd.log-ativo NO-LOCK query-tuning(no-lookahead): end.
    
                    if avail item-fornec-umd then 
                    for first item-fornec no-lock where 
                              item-fornec.cod-emitente = int_ds_it_docto_xml.cod_emitente and
                              ITEM-fornec.it-codigo    = item-fornec-umd.it-codigo and
                              ITEM-fornec.ativo = yes query-tuning(no-lookahead): end.
    
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
                        ASSIGN tt-it-docto-xml.cst_pis = ttPISAliq.CST
                               tt-it-docto-xml.vbc_pis = ttPISAliq.vBC
                               tt-it-docto-xml.ppis    = de-aliq-pis
                               tt-it-docto-xml.vpis    = ttPISAliq.vBC * de-aliq-pis / 100.
                        ASSIGN de-tot-pis = de-tot-pis + tt-it-docto-xml.vpis.
                     END.   
                  END.
    
                  IF de-aliq-cofins > 0 THEN DO:
                     FIND FIRST ttCOFINSAliq WHERE
                                ttCOFINSAliq.nItem = ttprod.nitem NO-ERROR.
                     IF AVAIL ttCOFINSAliq 
                     THEN DO:
                        ASSIGN tt-it-docto-xml.cst_cofins =  ttCOFINSAliq.CST  
                               tt-it-docto-xml.vbc_cofins =  ttCOFINSAliq.vBC    
                               tt-it-docto-xml.pcofins    =  de-aliq-cofins
                               tt-it-docto-xml.vcofins    =  ttCOFINSAliq.vBC * de-aliq-cofins / 100.
                        ASSIGN de-tot-cofins = de-tot-cofins + tt-it-docto-xml.vcofins.
                     END. 
                  END.
              END. /* item */
           END. /* item-fornec */
        END. /* each ttprod */
    
        ASSIGN tt-docto-xml.valor_pis    = de-tot-pis
               tt-docto-xml.valor_cofins = de-tot-cofins
               tt-docto-xml.vbc_cst_fcp  = de-vbc-cst-fcp. /* novo 4.0 */
    
        ASSIGN tt-docto-xml.observacao = ".".
        for first ttInfAdic query-tuning(no-lookahead):
            ASSIGN tt-docto-xml.observacao = if trim(substring(ttInfAdic.infCpl,1,2000)) <> ? 
                                             then trim(substring(ttInfAdic.infCpl,1,2000))
                                             else ".".
        end.
      
        /* duplicatas da nota */
        for each ttDup query-tuning(no-lookahead):
            for first tt-xml-dup where 
                tt-xml-dup.serie        = tt-docto-xml.serie        and
                tt-xml-dup.nNF          = tt-docto-xml.nNF          and
                tt-xml-dup.cod_emitente = tt-docto-xml.cod_emitente and
                tt-xml-dup.tipo_nota    = tt-docto-xml.tipo_nota    and
                tt-xml-dup.nDup         = ttDup.nDup                and
                tt-xml-dup.dVenc        = ttDup.dVenc query-tuning(no-lookahead):              
            end.
            if not avail tt-xml-dup then do:
                create  tt-xml-dup.
                assign  tt-xml-dup.serie        = tt-docto-xml.serie        
                        tt-xml-dup.nNF          = tt-docto-xml.nNF          
                        tt-xml-dup.cod_emitente = tt-docto-xml.cod_emitente 
                        tt-xml-dup.tipo_nota    = tt-docto-xml.tipo_nota    
                        tt-xml-dup.nDup         = ttDup.nDup                
                        tt-xml-dup.dVenc        = ttDup.dVenc.
            end.
            assign  tt-xml-dup.InfNFe    = ttDup.ttInfNFe
                    tt-xml-dup.Cobr      = ttDup.ttCobr  
                    tt-xml-dup.vDup      = ttDup.vDup
                    tt-xml-dup.cnpj_cpf  = tt-docto-xml.CNPJ.
        end. /* ttDup */
    
        /* Gerar Duplicata GNFE - ICMS ST */
        IF  de-valor-st-calc <> 0
        THEN DO:
            FOR FIRST b-tt-xml-dup 
                WHERE b-tt-xml-dup.serie        = tt-docto-xml.serie        
                  AND b-tt-xml-dup.nNF          = tt-docto-xml.nNF          
                  AND b-tt-xml-dup.cod_emitente = tt-docto-xml.cod_emitente 
                  AND b-tt-xml-dup.tipo_nota    = tt-docto-xml.tipo_nota query-tuning(no-lookahead):
    
                CREATE tt-xml-dup.
                ASSIGN tt-xml-dup.serie        = tt-docto-xml.serie        
                       tt-xml-dup.nNF          = tt-docto-xml.nNF          
                       tt-xml-dup.cod_emitente = tt-docto-xml.cod_emitente 
                       tt-xml-dup.tipo_nota    = tt-docto-xml.tipo_nota    
                       tt-xml-dup.nDup         = "GNFE"                
                       tt-xml-dup.dVenc        = b-tt-xml-dup.dVenc
                       tt-xml-dup.InfNFe       = b-tt-xml-dup.InfNFe
                       tt-xml-dup.Cobr         = b-tt-xml-dup.Cobr  
                       tt-xml-dup.vDup         = de-valor-st-calc
                       tt-xml-dup.cnpj_cpf     = b-tt-xml-dup.CNPJ .
            END.
        END.
    
        /* notas de compra de loja - AVB 25/08/2016  - enviar para PRS */
        if  not can-find (first b-estab no-lock where b-estab.cgc = tt-docto-xml.CNPJ) and
            can-find (first estabelec no-lock where estabelec.cgc = tt-docto-xml.CNPJ_dest and
                      estabelec.cod-estabel <> "973") and 
            c-doc <> ? and c-doc <> ""
        then do:
            for first int_ds_xml_nfe where
                int_ds_xml_nfe.cnpj_origem = tt-docto-xml.CNPJ and
                int_ds_xml_nfe.serie       = tt-docto-xml.serie and
                int_ds_xml_nfe.notafiscal  = tt-docto-xml.nnf query-tuning(no-lookahead): 
            end.
            if not avail int_ds_xml_nfe then do transaction:
                create  int_ds_xml_nfe.
                /*
                DEF VAR c-temp AS CHAR.
                c-temp = "t:\temp.xml".*/
                /*copy-lob c-doc to file c-temp.*/
                c-doc = replace(c-doc,'<nfeProc versao="3.10" xmlns="http://www.portalfiscal.inf.br/nfe">','<nfeProc>').
                assign  int_ds_xml_nfe.id_nfe       = 'Nfe' + tt-docto-xml.chnfe
                        int_ds_xml_nfe.cnpj_origem  = tt-docto-xml.CNPJ
                        int_ds_xml_nfe.cnpj_destino = tt-docto-xml.CNPJ_dest
                        int_ds_xml_nfe.notafiscal   = tt-docto-xml.nnf
                        int_ds_xml_nfe.serie        = tt-docto-xml.serie
                        int_ds_xml_nfe.emissao      = tt-docto-xml.dEmi.
                copy-lob c-doc to int_ds_xml_nfe.xml.
            end.
            /* necess†rio transaá‰es separadas para tratamento na trigger de after-update no Oracle */
            do transaction:
                assign  int_ds_xml_nfe.tipo_movto   = 1
                        int_ds_xml_nfe.dt_geracao   = today
                        int_ds_xml_nfe.hr_geracao   = string(time,"HH:MM:SS")
                        int_ds_xml_nfe.situacao     = 1.
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

        IF c-versao-xml MATCHES "*4*" THEN DO:

           /* ttdetpag - tag nova nfe 4.0 */

           FOR EACH ttdetpag query-tuning(no-lookahead):
               ASSIGN tt-docto-xml.tpag = ttdetpag.tpag  /* novo 4.0 */
                      tt-docto-xml.vpag = ttdetpag.vpag. /* novo 4.0 */
           END.
        END.
    END. /* ttIde */
    
END PROCEDURE.

PROCEDURE pi-gera-transf:

      /* prepara int_ds_docto_xml p/ entrada no CD besado em int_ds_nota_saida */
      for first int_ds_nota_saida where 
                int_ds_nota_saida.nsa_cnpj_origem_s = estabelec.cgc and
                int_ds_nota_saida.nsa_serie_s       = nota-fiscal.serie AND
                int_ds_nota_saida.nsa_notafiscal_n  = int(nota-fiscal.nr-nota-fis)
          query-tuning(no-lookahead): 
      end.
      if not avail int_ds_nota_saida then next.
      assign de-tot-bicms = 0
             de-tot-icms  = 0
             de-tot-bsubs = 0
             de-tot-icmst = 0.
      for each it-nota-fisc of nota-fiscal no-lock query-tuning(no-lookahead):
                       
          IF VALID-HANDLE(h-acomp) THEN
              RUN pi-acompanhar IN h-acomp(INPUT "Nota CD: " + string(nota-fiscal.nr-nota-fis)).

          for first int_ds_nota_saida_item of int_ds_nota_saida NO-LOCK where
                    int_ds_nota_saida_item.nsp_sequencia_n = it-nota-fisc.nr-seq-fat     and
                    int_ds_nota_saida_item.nsp_produto_n   = int(it-nota-fisc.it-codigo) and
                    int_ds_nota_saida_item.nsp_sequencia_n = it-nota-fisc.nr-seq-fat     and
                    int_ds_nota_saida_item.nsp_produto_n   = int(it-nota-fisc.it-codigo)
              query-tuning(no-lookahead): 
          end.
          if not avail int_ds_nota_saida_item then NEXT.


          ASSIGN  de-tot-bicms   = de-tot-bicms   + it-nota-fisc.vl-bicms-it
                  de-tot-icms    = de-tot-icms    + it-nota-fisc.vl-icms-it
                  de-tot-bsubs   = de-tot-bsubs   + it-nota-fisc.vl-bsubs-it
                  de-tot-icmst   = de-tot-icmst   + it-nota-fisc.vl-icmsub-it.   
                                
          CREATE tt-it-docto-xml.
          ASSIGN tt-it-docto-xml.arquivo      = tt-docto-xml.arquivo
                 tt-it-docto-xml.tipo_nota    = tt-docto-xml.tipo_nota 
                 tt-it-docto-xml.CNPJ         = tt-docto-xml.CNPJ  
                 tt-it-docto-xml.cod_emitente = nota-fiscal.cod-emitente
                 tt-it-docto-xml.nNF          = tt-docto-xml.nNF      
                 tt-it-docto-xml.serie        = tt-docto-xml.serie
                 tt-it-docto-xml.sequencia    = it-nota-fisc.nr-seq-fat 
                 tt-it-docto-xml.item_do_forn = it-nota-fisc.it-codigo
                 tt-it-docto-xml.it_codigo    = it-nota-fisc.it-codigo
                 tt-it-docto-xml.cfop         = int_ds_nota_saida_item.nsp_cfop_n
                 tt-it-docto-xml.qCom         = it-nota-fisc.qt-faturada[1]                    
                 tt-it-docto-xml.vProd        = it-nota-fisc.vl-tot-item   
                 tt-it-docto-xml.vuncom       = it-nota-fisc.vl-preuni    
                 tt-it-docto-xml.vtottrib     = it-nota-fisc.vl-merc-liq                       
                 tt-it-docto-xml.vbc_icms     = it-nota-fisc.vl-bicms-it                       
                 tt-it-docto-xml.vDesc        = it-nota-fisc.vl-desconto                       
                 tt-it-docto-xml.vicms        = it-nota-fisc.vl-icms-it                        
                 tt-it-docto-xml.vbc_ipi      = it-nota-fisc.vl-bipi-it                        
                 tt-it-docto-xml.vipi         = it-nota-fisc.vl-ipi-it                         
                 tt-it-docto-xml.vicmsst      = it-nota-fisc.vl-icmsub-it                      
                 tt-it-docto-xml.vbcst        = it-nota-fisc.vl-bsubs-it                       
                 tt-it-docto-xml.picmsst      = it-nota-fisc.aliquota-icm                      
                 tt-it-docto-xml.pipi         = it-nota-fisc.aliquota-ipi                      
                 tt-it-docto-xml.ppis         = int_ds_nota_saida_item.nsp_percentualpis_n        
                 tt-it-docto-xml.pcofins      = int_ds_nota_saida_item.nsp_percentualcofins_n     
                 tt-it-docto-xml.vbc_pis      = int_ds_nota_saida_item.nsp_basepis_n              
                 tt-it-docto-xml.vpis         = it-nota-fisc.vl-pis                               
                 tt-it-docto-xml.vbc_cofins   = int_ds_nota_saida_item.nsp_basecofins_n           
                 tt-it-docto-xml.vcofins      = it-nota-fisc.vl-finsocial                         
                 tt-it-docto-xml.num_pedido   = int(int_ds_nota_saida_item.ped_codigo_n)          
                 tt-it-docto-xml.orig_icms    = int(int_ds_nota_saida_item.nsp_csta_n)     
                 tt-it-docto-xml.vbcst        = int_ds_nota_saida_item.nsp_cstb_n         
                 tt-it-docto-xml.vbc_ipi      = it-nota-fisc.vl-bipi-it                   
                 tt-it-docto-xml.vbcstret     = 0                                         
                 tt-it-docto-xml.item_do_forn = it-nota-fisc.it-codigo                  
                 tt-it-docto-xml.lote         = if int_ds_nota_saida_item.nsp_lote_s <> ? then int_ds_nota_saida_item.nsp_lote_s else ""
                 tt-it-docto-xml.dval         = int_ds_nota_saida_item.nsp_datavalidade_d
                 tt-it-docto-xml.vOutro       = int_ds_nota_saida_item.nsp_valordespesa_n.    

          if it-nota-fisc.cd-trib-icm = 2 then assign tt-it-docto-xml.cst_icms = 40.
          if it-nota-fisc.cd-trib-icm = 3 then assign tt-it-docto-xml.cst_icms = 41.
          else if it-nota-fisc.cd-trib-icm = 5 then assign tt-it-docto-xml.cst_icms = 51.
          assign L-GRAVA = yes.

      END.
          
      ASSIGN tt-docto-xml.tot_desconto = nota-fiscal.vl-desconto  /*  Desconto total da nota fiscal  */          
             tt-docto-xml.vbc          = de-tot-bicms              /*  Base ICMS total nota fiscal    */          
             tt-docto-xml.valor_icms   = de-tot-icms               /*  Valor total do ICMS da nota fiscal    */ 
             tt-docto-xml.vbc_cst      = de-tot-bsubs              /*  Base ICMS ST */                   
             tt-docto-xml.valor_st     = de-tot-icmst              /*  Valor do ICMS ST total da nota */ 
             tt-docto-xml.VNF          = nota-fiscal.vl-tot-nota  /* Valor total da nota fiscal */
             tt-docto-xml.observacao   = IF trim(nota-fiscal.observ-nota) <> ? THEN trim(nota-fiscal.observ-nota) + 
                                         IF trim(substring(tt-docto-xml.arquivo,1,16)) <> ? THEN
                                         chr(13) + "NDDID: " + trim(substring(tt-docto-xml.arquivo,1,16))  /* Observacao da nota fiscal */
                                         ELSE ""
                                         ELSE ""
             tt-docto-xml.chnfe        = nota-fiscal.cod-chave-aces-nf-eletro /* Chave de acesso NFe */               
             tt-docto-xml.valor_frete  = nota-fiscal.vl-frete                 /* Frete total da nota */
             tt-docto-xml.valor_seguro = nota-fiscal.vl-seguro                /* Seguro total da nota  */
             tt-docto-xml.valor_outras = nota-fiscal.val-desp-outros          /* Despesas total da nota */
             tt-docto-xml.modFrete     = nota-fiscal.ind-tp-frete.             /* Modalidade do frete (0-FOB 1-CIF) */
      
END PROCEDURE.




