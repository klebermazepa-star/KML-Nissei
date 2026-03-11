/********************************************************************************
**
**  Programa - int040RP.P - Importa‡Æo Notas Pepsico
**
********************************************************************************/ 

{include/i-prgvrs.i int040RP 2.00.00.000 } 

{rep/reapi191.i1}
{rep/reapi190b.i}

define temp-table tt-param
    field destino          as INTEGER
    field arq-destino      as char
    field arq-entrada      as char
    field todos            as integer
    field usuario          as char
    field data-exec        as date
    field hora-exec        as INTEGER
    FIELD dt-periodo-ini   AS DATE FORMAT "99/99/9999"
    FIELD dt-periodo-fim   AS DATE FORMAT "99/99/9999"
    FIELD cod-estabel-ini  AS CHAR format "x(05)"
    FIELD cod-estabel-fim  AS CHAR FORMAT "x(03)".

DEF TEMP-TABLE tt-docto-xml  NO-UNDO LIKE int-ds-docto-xml 
FIELD cont AS INTEGER
INDEX idx_chave cnpj serie nnf  
INDEX idx_ch_cont cont.

DEF TEMP-TABLE tt-it-docto-xml NO-UNDO LIKE int-ds-it-docto-xml 
FIELD cont AS INTEGER 
INDEX idx_ch_item cnpj serie nnf sequencia it-codigo
INDEX idx_ch_cont cont.

DEF TEMP-TABLE tt-dist-emitente NO-UNDO
FIELD cod-emitente LIKE emitente.cod-emitente
FIELD situacao     AS  INTEGER.

DEFINE TEMP-TABLE tt-estab NO-UNDO
FIELD cod-estabel LIKE estabelec.cod-estabel
FIELD cgc         LIKE estabelec.cgc. 

DEF TEMP-TABLE tt-nota no-undo
    FIELD situacao     AS INTEGER
    FIELD nro-docto    LIKE docum-est.nro-docto   
    FIELD serie-nota   LIKE docum-est.serie-docto
    FIELD serie-docum  LIKE docum-est.serie-docto        
    FIELD cod-emitente LIKE docum-est.cod-emitente
    FIELD nat-operacao LIKE docum-est.nat-operacao
    FIELD tipo-nota    LIKE int-ds-docto-xml.tipo-nota
    FIELD valor-mercad LIKE doc-fisico.valor-mercad.

define temp-table tt-param-re NO-UNDO
    field destino            as integer
    field arquivo            as char
    field usuario            as char
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field c-cod-estabel-ini  as char
    field c-cod-estabel-fim  as char
    field i-cod-emitente-ini as integer
    field i-cod-emitente-fim as integer
    field c-nro-docto-ini    as char
    field c-nro-docto-fim    as char
    field c-serie-docto-ini  as char
    field c-serie-docto-fim  as char
    field c-nat-operacao-ini as char
    field c-nat-operacao-fim as char
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.

define temp-table tt-digita-re NO-UNDO
    field r-docum-est        as rowid.

def temp-table tt-raw-digita-re NO-UNDO
   field raw-digita   as raw.

DEF TEMP-TABLE tt-arquivo-erro NO-UNDO
    FIELD c-linha AS CHAR.

DEF TEMP-TABLE tt-erro-nota NO-UNDO
    FIELD serie        AS CHAR FORMAT "x(03)"
    FIELD nro-docto    AS CHAR FORMAT "9999999"
    FIELD cod-emitente AS INTEGER FORMAT ">>>>>>>>9"
    FIELD cod-erro     AS INTEGER FORMAT ">>>>>9"
    FIELD descricao    AS CHAR.

{utp/ut-glob.i}

/* DEFINE TEMP-TABLE tt-docum-est NO-UNDO like docum-est
    field r-rowid  as ROWID
    index documento is primary 
          serie-docto
          nro-docto
          cod-emitente
          nat-operacao.  

DEFINE TEMP-TABLE tt-item-doc-est NO-UNDO like item-doc-est 
    field r-rowid  as ROWID
    index item-docto is primary 
          serie-docto
          nro-docto
          cod-emitente
          nat-operacao
          sequencia. 
*/

DEF TEMP-TABLE tt-nota-ent          NO-UNDO LIKE tt-nota.
DEF TEMP-TABLE tt-docum-est-ent     NO-UNDO LIKE tt-docum-est-nova.
DEF TEMP-TABLE tt-item-doc-est-ent  NO-UNDO LIKE tt-item-doc-est-nova.

DEF BUFFER b-tt-docto-xml FOR tt-docto-xml.
DEF BUFFER b-docum-est    FOR docum-est.

DEF TEMP-TABLE tt-natur-oper NO-UNDO
FIELD nat-operacao  LIKE natur-oper.nat-operacao
FIELD situacao      AS INTEGER. 

DEF TEMP-TABLE tt-erro-docto NO-UNDO
    FIELD situacao     AS INTEGER  /* 1 - Com Erro   2 - Integrada */ 
    FIELD nnf          LIKE int-ds-it-docto-xml.nnf
    FIELD serie        LIKE int-ds-it-docto-xml.serie  
    FIELD cod-emitente LIKE emitente.cod-emitente
    FIELD cnpj         LIKE emitente.cgc
    FIELD nat-operacao LIKE natur-oper.nat-operacao
    FIELD cod-estab    LIKE estabelec.cod-estabel 
    FIELD sequencia    LIKE int-ds-it-docto-xml.sequencia
    FIELD it-codigo    LIKE item.it-codigo
    FIELD desc-erro    AS CHAR FORMAT "x(60)"
    FIELD cont         AS INTEGER
    INDEX codigo cnpj nnf serie.

DEF VAR h-api        AS HANDLE                   NO-UNDO.
DEF VAR c-linha      AS CHAR                     NO-UNDO.
DEF VAR i-cont       AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cnpj       AS DEC                      NO-UNDO.
DEF VAR h-acomp      AS HANDLE                   NO-UNDO.
DEF VAR i-novos      AS INT FORMAT ">>>,>>9"     NO-UNDO.
DEF VAR i-ativo      AS INT                      NO-UNDO.
DEF VAR c-valida-emitente AS CHAR                NO-UNDO.
DEF VAR c-serie        LIKE serie.serie          NO-UNDO.
DEF VAR c-item-do-forn LIKE item-fornec.item-do-forn NO-UNDO.
DEF VAR c-perc-pis           AS CHAR             NO-UNDO.
DEF VAR i-pos                AS INTEGER          NO-UNDO.
DEF VAR l-movto-entrada-erro AS LOGICAL          NO-UNDO.
DEF VAR l-movto-com-erro     AS LOGICAL          NO-UNDO.
DEF VAR c-serie-ent          AS CHAR             NO-UNDO.
DEF VAR c-natur-ent          AS CHAR             NO-UNDO.
DEF VAR c-cod-depos          LIKE ITEM.deposito-pad NO-UNDO.
DEF VAR c-nr-nota            AS CHAR FORMAT "x(09)" NO-UNDO.
DEF VAR i-pos-arq            AS INTEGER             NO-UNDO.
DEF VAR c-estado-estab       AS CHAR                NO-UNDO.
DEF VAR c-estado-emit        AS CHAR                NO-UNDO.
DEF VAR i-cst-cms            LIKE int-ds-tp-natur-oper.cst-icms NO-UNDO.
DEF VAR c-natureza           LIKE natur-oper.nat-operacao       NO-UNDO.
DEF VAR dt-trans-movto       AS DATE   FORMAT "99/99/9999"      NO-UNDO.
DEF VAR de-fator             AS DECIMAL                         NO-UNDO.
DEF VAR h-boin176            AS HANDLE.
DEF VAR i-seq-item           AS INTEGER NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

RUN inbo/boin176.p PERSISTENT SET h-boin176. /*  calcula fator de conversÆo */
run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo Notas Pepsico").

EMPTY TEMP-TABLE tt-docto-xml.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}


assign c-titulo-relat = "Importa‡Æo Notas Pepsico"
       c-programa     = "Int040".

{include/i-rpcab.i}

/* view frame f-cabec. */


INPUT FROM VALUE(tt-param.arq-entrada) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
    
   IMPORT UNFORMATTED c-linha. 

   ASSIGN c-linha = REPLACE(c-linha,CHR(13),"")
          c-linha = REPLACE(c-linha,CHR(10),"")
          c-linha = REPLACE(c-linha,'	',"").     

   IF c-linha BEGINS "cabe" OR 
      c-linha BEGINS "Tipo" OR  
      c-linha BEGINS "Itens da" THEN NEXT.
   
   /* IF c-linha BEGINS "1" /* Itens da Nota */
   THEN DO:

        ASSIGN c-linha = c-linha + ";".

        PUT c-linha FORMAT "x(600)" SKIP.
      
        DISP ENTRY(1,c-linha,";")           
            ENTRY(2,c-linha,";")                
            ENTRY(3,c-linha,";")                
            ENTRY(4,c-linha,";")
            ENTRY(5,c-linha,";")
            ENTRY(6,c-linha,";")            
            ENTRY(7,c-linha,";")     
            ENTRY(8,c-linha,";")            
            ENTRY(9,c-linha,";")             
            ENTRY(10,c-linha,";")         
            ENTRY(11,c-linha,";")         
            ENTRY(12,c-linha,";")       
            ENTRY(13,c-linha,";")       
            ENTRY(14,c-linha,";")       
            ENTRY(15,c-linha,";")       
            ENTRY(16,c-linha,";")       
            ENTRY(17,c-linha,";")       
            ENTRY(18,c-linha,";")       
            ENTRY(19,c-linha,";")       
            ENTRY(20,c-linha,";")       
            ENTRY(21,c-linha,";")       
            ENTRY(22,c-linha,";")       
            ENTRY(23,c-linha,";")  
            ENTRY(24,c-linha,";")
            ENTRY(25,c-linha,";")
            ENTRY(26,c-linha,";")
            ENTRY(27,c-linha,";")
            ENTRY(28,c-linha,";")
            ENTRY(29,c-linha,";")
            ENTRY(30,c-linha,";") 
            ENTRY(31,c-linha,";")
            ENTRY(41,c-linha,";") 
            ENTRY(44,c-linha,";")
            ENTRY(45,c-linha,";") 
            WITH WIDTH 333 STREAM-IO. 
   END. */
   

   IF c-linha BEGINS "1"   /* Cabe‡alho da nota */
   THEN DO:
   
      assign i-cont     = i-cont + 1 
             i-seq-item = 0.

      CREATE tt-docto-xml.
       
      ASSIGN tt-docto-xml.cnpj  =  string(dec(ENTRY(2,c-linha,";")))         /* B */
             tt-docto-xml.serie =  string(ENTRY(3,c-linha,";"))              /* C */
             tt-docto-xml.nnf   =  string(ENTRY(4,c-linha,";"))              /* D */
             tt-docto-xml.cfop  =  int(ENTRY(5,c-linha,";"))                 /* E */
             tt-docto-xml.num-pedido   = 0  /* ENTRY(6,c-linha,";") */       /* F */
             tt-docto-xml.dt-trans     = DATE(string(ENTRY(7,c-linha,";"))) /* G */
             
             tt-docto-xml.Demi	       = DATE(string(ENTRY(9,c-linha,";"))) /* I */
             tt-docto-xml.tot-desconto   = IF ENTRY(10,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(10,c-linha,";")) /* J */  
             tt-docto-xml.valor-cofins   = IF ENTRY(11,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(11,c-linha,";")) /* K */  
             tt-docto-xml.valor-icms     = IF ENTRY(12,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(12,c-linha,";")) /* L */	
             tt-docto-xml.valor-icms-des = IF ENTRY(13,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(13,c-linha,";")) /* M */	
             tt-docto-xml.valor-ipi	     = IF ENTRY(14,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(14,c-linha,";")) /* N */
             tt-docto-xml.valor-outras	 = IF ENTRY(15,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(15,c-linha,";")) /* O */
             tt-docto-xml.valor-pis	     = IF ENTRY(16,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(16,c-linha,";")) /* P */
             tt-docto-xml.valor-mercad	 = IF ENTRY(17,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(17,c-linha,";")) /* Q */
             tt-docto-xml.valor-st	     = IF ENTRY(18,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(18,c-linha,";")) /* R */
             tt-docto-xml.vbc	         = IF ENTRY(19,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(19,c-linha,";")) /* S */
             tt-docto-xml.vbc-cst	     = IF ENTRY(20,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(20,c-linha,";")) /* T */
             tt-docto-xml.vNF	         = IF ENTRY(21,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(21,c-linha,";")) /* U */
             tt-docto-xml.valor-seguro	 = IF ENTRY(22,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(22,c-linha,";")) /* V */
             tt-docto-xml.valor-frete	 = IF ENTRY(23,c-linha,";")  = "?" THEN 0 ELSE dec(ENTRY(23,c-linha,";")) /* W */
             tt-docto-xml.obs        	 = string(ENTRY(24,c-linha,";")) /* X */
             tt-docto-xml.chnfe          = string(ENTRY(25,c-linha,";")) /* Y */
             tt-docto-xml.chnft          = string(ENTRY(3,c-linha,";")) /* serie original */
             tt-docto-xml.cont           = i-cont
             tt-docto-xml.cnpj-dest      = string(dec(ENTRY(41,c-linha,";"))).  /* AO */

       /* tt-docto-xml.cod-emitente   = int(ENTRY(45,c-linha,";")).  /* AS */
                                               
      FIND FIRST emitente NO-LOCK WHERE
                 emitente.cod-emitente = tt-docto-xml.cod-emitente /* AS */  NO-ERROR.
      IF AVAIL emitente THEN
         ASSIGN tt-docto-xml.cnpj = emitente.cgc. 
                */

      IF LENGTH(TRIM(string(tt-docto-xml.nnf))) < 8 THEN
           ASSIGN tt-docto-xml.nNF = STRING(int(tt-docto-xml.nnf),"9999999").
      
      FOR FIRST serie NO-LOCK WHERE
                serie.serie = tt-docto-xml.serie :
      END.
      IF NOT AVAIL serie 
      THEN DO:
          ASSIGN c-serie = string(int(tt-docto-xml.serie),"999") NO-ERROR.
                                         
          if error-status:error then
              ASSIGN c-serie = string(tt-docto-xml.serie) NO-ERROR.

          FOR FIRST serie NO-LOCK WHERE
                    serie.serie =  c-serie :
          END.
          IF AVAIL serie  THEN
             ASSIGN tt-docto-xml.serie = c-serie.
      END.


      ASSIGN tt-docto-xml.nat-operacao = "1403A5"
             tt-docto-xml.valor-mercad = 0.

   END.
   
   IF c-linha BEGINS "2"  /* Itens da Nota */
   THEN DO:
   
      /* ASSIGN c-perc-pis = string(ENTRY(31,c-linha,";")). */
        
      ASSIGN c-perc-pis = "".
                      
      DO i-pos = 1 TO LENGTH(ENTRY(34,c-linha,";")):
           
          IF ASC(SUBSTRING(ENTRY(34,c-linha,";"),i-pos,1)) = 9 THEN NEXT.

          IF SUBSTRING(ENTRY(34,c-linha,";"),i-pos,1) = "?" THEN NEXT.

          IF i-pos > 2 THEN NEXT.

          ASSIGN c-perc-pis = c-perc-pis + SUBSTRING(ENTRY(34,c-linha,";"),i-pos,1).
                  
      END.
      
      ASSIGN i-seq-item = i-seq-item + 10.     

      CREATE tt-it-docto-xml.
                     
      ASSIGN tt-it-docto-xml.cnpj           =  string(dec(ENTRY(2,c-linha,";")))   /* B */ 
             tt-it-docto-xml.serie          =  string(ENTRY(3,c-linha,";"))        /* C */ 
             tt-it-docto-xml.nnf            =  string(ENTRY(4,c-linha,";"))        /* D */ 
             tt-it-docto-xml.cfop           =  int(ENTRY(5,c-linha,";"))           /* F */ 
             tt-it-docto-xml.num-pedido     = 0  /* ENTRY(6,c-linha,";") */        /* E */
             /* tt-it-docto-xml.dt-trans       = DATE(ENTRY(7,c-linha,";"))        /* G */  */
             tt-it-docto-xml.vDesc          = IF ENTRY(10,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(10,c-linha,";"))	/* J */
             tt-it-docto-xml.vcofins        = IF ENTRY(11,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(11,c-linha,";")) /* K */  
             tt-it-docto-xml.vicms          = IF ENTRY(12,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(12,c-linha,";"))	/* L */
             tt-it-docto-xml.vicmsdeson     = IF ENTRY(13,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(13,c-linha,";"))	/* M */
             tt-it-docto-xml.vipi           = IF ENTRY(14,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(14,c-linha,";")) /* N */
             tt-it-docto-xml.vOutro         = IF ENTRY(15,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(15,c-linha,";")) /* O */
             tt-it-docto-xml.vpis           = IF ENTRY(16,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(16,c-linha,";")) /* P */
             tt-it-docto-xml.vUnCom         = IF ENTRY(17,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(17,c-linha,";")) /* Q */
             tt-it-docto-xml.vicmsst        = IF ENTRY(18,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(18,c-linha,";")) /* R */
             tt-it-docto-xml.vbc-icms       = IF ENTRY(19,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(19,c-linha,";")) /* S */
             tt-it-docto-xml.vbcst          = IF ENTRY(20,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(20,c-linha,";")) /* T */
             tt-it-docto-xml.vProd          = IF ENTRY(21,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(21,c-linha,";")) /* U */
             tt-it-docto-xml.vicmsst        = IF ENTRY(22,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(22,c-linha,";")) /* V */
             tt-it-docto-xml.vbc-cofins     = IF ENTRY(23,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(23,c-linha,";")) /* W */
          /* tt-it-docto-xml.narrativa      = string(ENTRY(24,c-linha,";")) /* X */ 
             tt-it-docto-xml.Lote           = string(ENTRY(25,c-linha,";")) /* Y */  */ 
             tt-it-docto-xml.sequencia      = int(ENTRY(27,c-linha,";"))    /* AA */
             tt-it-docto-xml.qCom-forn      = dec(ENTRY(28,c-linha,";"))    /* AB */
             tt-it-docto-xml.uCom-forn      = string(ENTRY(29,c-linha,";")) /* AC */
             tt-it-docto-xml.vbc-ipi        = IF ENTRY(30,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(30,c-linha,";")) /* AD */
             tt-it-docto-xml.vbc-pis        = IF ENTRY(31,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(31,c-linha,";")) /* AE */
             tt-it-docto-xml.vbcstret       = IF ENTRY(32,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(32,c-linha,";")) /* AF */
             tt-it-docto-xml.vicmsstret     = IF dec(string(ENTRY(33,c-linha,";"))) = ? THEN 0 ELSE dec(string(ENTRY(33,c-linha,";"))) /* AG */
             tt-it-docto-xml.picms          = IF c-perc-pis = "?" THEN 0 ELSE dec(c-perc-pis) /* AH */
             tt-it-docto-xml.item-do-forn   = string(ENTRY(41,c-linha,";"))            /* AO */  
             tt-it-docto-xml.it-codigo      = string(ENTRY(44,c-linha,";"))            /* AR */
             /* tt-it-docto-xml.cod-emitente   = int(ENTRY(45,c-linha,";"))                   /* AS */     
             tt-it-docto-xml.ppis         = IF ENTRY(34,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(32,c-linha,";"))
             tt-it-docto-xml.pcofins        = IF ENTRY(35,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(33,c-linha,";"))
             tt-it-docto-xml.predBc         = IF ENTRY(34,c-linha,";") = "?" THEN 0 ELSE dec(ENTRY(34,c-linha,";")) */   
             tt-it-docto-xml.cont           = i-cont
             tt-it-docto-xml.sequencia      = i-seq-item.   
                                               
      /* FIND FIRST emitente NO-LOCK WHERE
                 emitente.cod-emitente = tt-it-docto-xml.cod-emitente NO-ERROR.
      IF AVAIL emitente THEN
         ASSIGN tt-it-docto-xml.cnpj = emitente.cgc. */

      IF LENGTH(TRIM(string(tt-it-docto-xml.nnf))) < 8 THEN
         ASSIGN tt-it-docto-xml.nNF = STRING(int(tt-it-docto-xml.nnf),"9999999").
     
      FOR FIRST serie NO-LOCK WHERE
                serie.serie = tt-it-docto-xml.serie :
      END.
      IF NOT AVAIL serie 
      THEN DO:
          ASSIGN c-serie = string(int(tt-it-docto-xml.serie),"999") NO-ERROR.
                                         
          if error-status:error then
              ASSIGN c-serie = string(tt-it-docto-xml.serie) NO-ERROR.

          FOR FIRST serie NO-LOCK WHERE
                    serie.serie =  c-serie :
          END.
          IF AVAIL serie  THEN
             ASSIGN tt-it-docto-xml.serie = c-serie.
      END.
   
   END.    
   
   run pi-acompanhar in h-acomp (input "Criando Notas: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.

EMPTY TEMP-TABLE tt-estab.

FOR EACH estabelec NO-LOCK WHERE
         estabelec.cod-estabel >= tt-param.cod-estabel-ini AND 
         estabelec.cod-estabel <= tt-param.cod-estabel-fim :

    CREATE tt-estab.
    ASSIGN tt-estab.cod-estabel = estabelec.cod-estabel
           tt-estab.cgc         = estabelec.cgc. 

END.

for each tt-docto-xml WHERE
         tt-docto-xml.demi >= tt-param.dt-periodo-ini AND
         tt-docto-xml.demi <= tt-param.dt-periodo-fim :
    
    FOR EACH b-tt-docto-xml NO-LOCK WHERE
             rowid(b-tt-docto-xml) <> ROWID(tt-docto-xml) AND 
             b-tt-docto-xml.nnf     = tt-docto-xml.nnf    AND
             b-tt-docto-xml.serie   = tt-docto-xml.serie  AND
             b-tt-docto-xml.cnpj    = tt-docto-xml.cnpj
        BY b-tt-docto-xml.cont :
           
        DELETE b-tt-docto-xml. 
                               
    END.

END.

for each tt-docto-xml WHERE  
     INT(tt-docto-xml.nnf)   = 0039015                AND  
         tt-docto-xml.demi >= tt-param.dt-periodo-ini AND
         tt-docto-xml.demi <= tt-param.dt-periodo-fim  :

    assign i-cont = i-cont + 1.

    RELEASE tt-it-docto-xml.

    run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-docto-xml.cnpj) + " - " + string(i-cont)).
    
    FOR FIRST estabelec WHERE
              estabelec.cgc = tt-docto-xml.cnpj-dest NO-LOCK:
    END.
    IF NOT AVAIL estabelec 
    THEN DO:
          
        RUN pi-gera-erro (INPUT "Estabelecimento nÆo cadastrado no Totvs. (CNPJ Destino)"). 
       
    END.  
    ELSE DO:

         FIND FIRST tt-estab WHERE
                    tt-estab.cgc = tt-docto-xml.cnpj-dest NO-ERROR.
         IF NOT AVAIL tt-estab THEN NEXT.
          
         IF AVAIL tt-estab THEN
            ASSIGN tt-docto-xml.cod-estab = tt-estab.cod-estab
                   c-estado-estab         = estabelec.estado.
    END.

    FOR FIRST serie WHERE
              serie.serie = tt-docto-xml.serie NO-LOCK:
    END.
    IF NOT AVAIL serie 
    THEN DO:
       
       RUN pi-gera-erro (INPUT "S‚rie nÆo cadastrda").
         
    END.

    FOR FIRST emitente USE-INDEX cgc WHERE
              emitente.cgc = tt-docto-xml.cnpj NO-LOCK:
    END.
    IF NOT AVAIL emitente 
    THEN DO:
         
        RUN pi-gera-erro (INPUT "Fornecedor nÆo cadastrado no Totvs. (CNPJ)").
       
    END.
    ELSE DO:
             /*** Forncederos ativos ***/
             EMPTY TEMP-TABLE tt-dist-emitente. 
                   
             ASSIGN i-ativo = 0
                    c-valida-emitente = "".

             FOR EACH emitente NO-LOCK WHERE 
                      emitente.identific > 1 AND 
                      emitente.cgc       = tt-docto-xml.cnpj :
        
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

             FOR EACH tt-dist-emitente:
            
                IF tt-dist-emitente.situacao = 1 THEN
                   ASSIGN i-ativo = i-ativo + 1.        
                     
             END.
             
             IF i-ativo <> 1 
             THEN DO:
             
                 IF i-ativo = 0 THEN
                    ASSIGN c-valida-emitente = "Nenhum fornecedor ativo para o CNPJ: ".
                
                 IF i-ativo > 1 THEN
                   ASSIGN c-valida-emitente = "Mais de um Fornecedor ativo para o CNPJ: ".  
             
             END. 
             ELSE DO:
                 FIND FIRST tt-dist-emitente WHERE
                            tt-dist-emitente.situacao = 1 NO-ERROR.
                 IF AVAIL tt-dist-emitente THEN
                    ASSIGN tt-docto-xml.cod-emitente = tt-dist-emitente.cod-emitente. /* Considera apenas o fornecedor ativo */
             END.
             
        IF i-ativo <> 1 
        THEN DO:
               RUN pi-gera-erro (INPUT c-valida-emitente + STRING(tt-docto-xml.cnpj)).
        END.
        ELSE DO:
       
            FOR FIRST int-ds-ext-emitente NO-LOCK WHERE
                      int-ds-ext-emitente.cod-emitente = tt-docto-xml.cod-emitente
                    query-tuning(no-lookahead) : 
            END.
    
            IF (AVAIL int-ds-ext-emitente AND  
                      int-ds-ext-emitente.gera-nota) 
            THEN DO: 
                
                FOR FIRST emitente NO-LOCK WHERE
                          emitente.cod-emitente = int-ds-ext-emitente.cod-emitente:  
                END.

                ASSIGN c-estado-emit = emitente.estado.
                 
            END.
            ELSE DO:
                RUN pi-gera-erro (INPUT "Fornecedor NÆo ‚ Pepsico.").
            END.

        END.

    END. /* avail emitente */
    
    FOR FIRST tt-it-docto-xml WHERE
              tt-it-docto-xml.cont = tt-docto-xml.cont :
    END.
    IF NOT AVAIL tt-it-docto-xml 
    THEN DO:

       RUN pi-gera-erro (INPUT "Nenhum item informado para a nota.").

    END.     
    
    FOR FIRST int-ds-docto-xml NO-LOCK WHERE
              int-ds-docto-xml.cnpj     = tt-docto-xml.cnpj     AND
              int-ds-docto-xml.serie    = tt-docto-xml.serie    AND
              int(int-ds-docto-xml.nnf) = int(tt-docto-xml.nnf) AND 
              int-ds-docto-xml.tipo-nota = 1 :

    END.

    IF AVAIL int-ds-docto-xml 
    THEN DO:
        
        RUN pi-gera-erro (INPUT "Nota Fiscal j  cadastrada.").
        
    END.

    FOR LAST b-tt-docto-xml NO-LOCK WHERE
             rowid(b-tt-docto-xml) <> ROWID(tt-docto-xml) AND 
             b-tt-docto-xml.nnf     = tt-docto-xml.nnf    AND
             b-tt-docto-xml.serie   = tt-docto-xml.serie  AND
             b-tt-docto-xml.cnpj    = tt-docto-xml.cnpj
        BY b-tt-docto-xml.cont :
           
        RUN pi-gera-erro (INPUT "Nota Duplicada no arquivo.").
                               
    END.
    
    FOR EACH tt-it-docto-xml WHERE
             tt-it-docto-xml.cont = tt-docto-xml.cont:

            EMPTY TEMP-TABLE tt-natur-oper. 

            ASSIGN tt-it-docto-xml.cod-emitente = tt-docto-xml.cod-emitente 
                   tt-docto-xml.valor-mercad    = tt-docto-xml.valor-mercad + tt-it-docto-xml.vprod. 

            FOR FIRST b-tt-docto-xml WHERE
                      b-tt-docto-xml.cnpj      = tt-docto-xml.cnpj  AND 
                      b-tt-docto-xml.serie     = tt-docto-xml.serie AND
                      b-tt-docto-xml.nnf       = tt-docto-xml.nnf :
                        
            END.
        
            IF NOT AVAIL b-tt-docto-xml 
            THEN DO: 
        
               RUN pi-gera-erro (INPUT "NÆo encontrada nota fiscal para o item").
                
            END.

            /* 
            ASSIGN c-item-do-forn = tt-it-docto-xml.it-codigo.
        
            FOR FIRST item-fornec NO-LOCK WHERE
                      item-fornec.cod-emitente =  tt-it-docto-xml.cod-emitente AND 
                      ITEM-fornec.item-do-forn = c-item-do-forn AND 
                      ITEM-fornec.ativo = YES 
                query-tuning(no-lookahead): 
            end.

            IF NOT AVAIL item-fornec 
            THEN DO:
                FOR FIRST item-fornec-umd WHERE 
                          item-fornec-umd.cod-emitente = tt-it-docto-xml.cod-emitente AND 
                          item-fornec-umd.cod-livre-1  = c-item-do-forn and  
                          item-fornec-umd.log-ativo NO-LOCK: 
                END.
        
                IF AVAIL item-fornec-umd 
                THEN DO:    
                                   
                   FOR FIRST item-fornec NO-LOCK WHERE
                             item-fornec.cod-emitente = tt-it-docto-xml.cod-emitente AND 
                             ITEM-fornec.it-codigo    = item-fornec-umd.it-codigo AND 
                             ITEM-fornec.ativo = YES query-tuning(no-lookahead):
                   end.
              
                end.   
            END.

            IF NOT AVAIL ITEM-fornec 
            THEN DO:
                ASSIGN c-item-do-forn = STRING(int(tt-it-docto-xml.it-codigo)) NO-ERROR.

                IF ERROR-STATUS:ERROR THEN
                   ASSIGN c-item-do-forn = STRING(tt-it-docto-xml.it-codigo).
              
                FOR FIRST item-fornec NO-LOCK WHERE
                          item-fornec.cod-emitente =  tt-it-docto-xml.cod-emitente AND 
                          index(ITEM-fornec.item-do-forn,c-item-do-forn) > 0 AND 
                          ITEM-fornec.ativo = YES 
                    query-tuning(no-lookahead):
                end.

            END.    
            */
            
            FOR FIRST ITEM WHERE
                      ITEM.it-codigo = tt-it-docto-xml.it-codigo NO-LOCK:
            END.  
            IF NOT AVAIL ITEM THEN DO:

               RUN pi-gera-erro (INPUT "Item nÆo cadastrado no Totvs.").
               
            END.
              
            ASSIGN tt-it-docto-xml.uCom  = IF AVAIL ITEM THEN item.un ELSE tt-it-docto-xml.uCom-forn 
                   tt-it-docto-xml.qCom = tt-it-docto-xml.qCom-forn. 

            IF tt-it-docto-xml.qcom-forn <= 0  /* qcom qcom-forn */
            THEN DO:

               RUN pi-gera-erro (INPUT "Quantidade deve ser maior que zero.").

            END.
                
            /***** tt-it-docto-xml.nat-operacao defnir natureza de operacao do item ***/
             
            assign i-cst-cms = 0.
                 
            IF AVAIL ITEM 
            THEN DO:

                                                                  
                /* if avail item-fornec
                then DO:

                   RUN retornaIndiceConversao in h-boin176 (input tt-it-docto-xml.it-codigo,
                                                            input tt-it-docto-xml.cod-emitente,
                                                            input item-fornec.unid-med-for,
                                                            output de-fator). 
                  
                   if de-fator = 0 or de-fator = ? then assign de-fator = 1. 

                   ASSIGN tt-it-docto-xml.qCom = ROUND(tt-it-docto-xml.qCom-forn / de-fator,0).

                   IF tt-it-docto-xml.qCom <= 1 THEN
                      ASSIGN tt-it-docto-xml.qCom = 1.

                END. */

                for first int-ds-tp-natur-oper NO-LOCK where
                          int-ds-tp-natur-oper.tp-pedido    = "1"               and
                          int-ds-tp-natur-oper.uf-origem    = c-estado-estab    and 
                          int-ds-tp-natur-oper.uf-destino   = c-estado-emit     and 
                          int-ds-tp-natur-oper.class-fiscal = ITEM.class-fiscal :
                end.
    
                if avail int-ds-tp-natur-oper then do:
                   assign i-cst-cms = int-ds-tp-natur-oper.cst-icms.  
                end.
                else do:
                   for first int-ds-tp-natur-oper NO-LOCK where
                             int-ds-tp-natur-oper.tp-pedido    = "1"               and
                             int-ds-tp-natur-oper.uf-origem    = c-estado-estab    and 
                             int-ds-tp-natur-oper.uf-destino   = c-estado-emit     and 
                             int-ds-tp-natur-oper.class-fiscal = ? :
                     end.
                     if avail int-ds-tp-natur-oper then do:
                        assign i-cst-cms = int-ds-tp-natur-oper.cst-icms.  
                     end.
                end.
    
                IF tt-it-docto-xml.cfop < 5000 THEN
                   ASSIGN tt-it-docto-xml.cfop = 5403.
                      
                IF tt-it-docto-xml.cfop = 5104 THEN
                   ASSIGN tt-it-docto-xml.cfop = 5401.

                RUN intprg/int013a.p( input tt-it-docto-xml.cfop, 
                                      input i-cst-cms  ,              /* cst-icms */
                                      INPUT int(ITEM.fm-codigo),      /* cst-ipi = FAMILIA */
                                      input tt-docto-xml.cod-estab ,  /* tt-docto-xml.cod-estab */
                                      input tt-docto-xml.cod-emitente,
                                      input tt-docto-xml.demi,
                                      OUTPUT c-natureza).

                IF c-natureza = "" 
                THEN DO:

                   RUN intprg/int013a.p( input tt-it-docto-xml.cfop, 
                                         input i-cst-cms  ,              /* cst-icms */
                                         INPUT ?,                        /* cst-ipi = FAMILIA */
                                         input ? ,                      /* tt-docto-xml.cod-estab */
                                         input ?,
                                         input tt-docto-xml.demi,
                                         OUTPUT c-natureza). 
                END.
    
                /* IF c-natureza = "" THEN 
                DISP tt-docto-xml.cod-estab
                     tt-docto-xml.nnf
                     tt-docto-xml.serie
                     tt-docto-xml.cod-emitente
                     tt-docto-xml.demi
                     c-estado-estab
                     c-estado-emit 
                     tt-it-docto-xml.cfop      
                     i-cst-cms    
                     ITEM.it-codigo
                     ITEM.fm-codigo
                     ITEM.class-fiscal
                     c-natureza
                     WITH WIDTH 333 STREAM-IO.
                   */

                ASSIGN tt-it-docto-xml.nat-operacao = c-natureza.
    
                FIND FIRST tt-natur-oper WHERE
                           tt-natur-oper.nat-operacao = c-natureza NO-ERROR.
                IF NOT AVAIL tt-natur-oper 
                THEN DO:
                    CREATE tt-natur-oper.
                    ASSIGN tt-natur-oper.nat-operacao = c-natureza.
                           tt-natur-oper.situacao     = 0. 
                END.
                
                ASSIGN tt-natur-oper.situacao = tt-natur-oper.situacao + 1.

                FIND FIRST natur-oper NO-LOCK WHERE
                           natur-oper.nat-operacao = tt-it-docto-xml.nat-operacao NO-ERROR.
                IF NOT AVAIL natur-oper THEN DO:
                   
                     RUN pi-gera-erro (INPUT "Natureza de Operacao : " +  STRING(tt-it-docto-xml.nat-operacao) + " nÆo cadastrada.").
                END.

            END.

            IF AVAIL ITEM AND AVAIL natur-oper THEN
               RUN pi-calculapiscofins.

    END. /* tt-it-docto-xml */
    
    FOR LAST tt-natur-oper 
        BY tt-natur-oper.situacao:
          
        ASSIGN tt-docto-xml.nat-operacao = tt-natur-oper.nat-operacao. 
               
    END.

    FIND FIRST tt-erro-docto WHERE
               tt-erro-docto.cnpj  = tt-docto-xml.cnpj AND
               tt-erro-docto.nnf   = tt-docto-xml.nnf  AND  
               tt-erro-docto.serie = tt-docto-xml.serie NO-ERROR.
    IF NOT AVAIL tt-erro-docto 
    THEN DO:

        FOR EACH tt-docum-est-nova:
             DELETE  tt-docum-est-nova.
        END.
                  
        FOR EACH tt-item-doc-est-nova:
            DELETE tt-item-doc-est-nova.
        END.

        FOR EACH tt-nota-ent:
            DELETE tt-nota-ent.
        END.

        FOR EACH tt-docum-est-ent:
            DELETE tt-docum-est-ent.
        END.

        FOR EACH tt-item-doc-est-ent:
           DELETE tt-item-doc-est-ent.               
        END.
                
        /*
        trans-block:
        do transaction:
                 
                 FOR FIRST int-ds-docto-xml NO-LOCK WHERE 
                           int-ds-docto-xml.cnpj         = tt-docto-xml.cnpj     AND
                           int-ds-docto-xml.serie        = tt-docto-xml.serie    AND
                           int-ds-docto-xml.tipo-nota    = 1                     AND 
                       int(int-ds-docto-xml.nnf)         = int(tt-docto-xml.nnf) :
                            
                 END.
                 IF NOT AVAIL int-ds-docto-xml 
                 THEN DO:
                     CREATE int-ds-docto-xml.
                     BUFFER-COPY tt-docto-xml TO int-ds-docto-xml.
                     assign int-ds-docto-xml.id_sequencial = next-value(seq-int-ds-docto-xml).
        
                     ASSIGN int-ds-docto-xml.tipo-nota  = 1
                            int-ds-docto-xml.tipo-docto = 4
                            int-ds-docto-xml.tipo-estab = 1
                            int-ds-docto-xml.situacao   = 3.
                 END.
                       
                 FOR EACH tt-it-docto-xml WHERE
                          tt-it-docto-xml.cont = tt-docto-xml.cont,
                     FIRST ITEM NO-LOCK WHERE
                           ITEM.it-codigo = tt-it-docto-xml.it-codigo:
                                               
                     FOR FIRST int-ds-it-docto-xml NO-LOCK WHERE 
                           int-ds-it-docto-xml.cnpj         = tt-it-docto-xml.cnpj     AND
                           int-ds-it-docto-xml.serie        = tt-it-docto-xml.serie    AND
                           int-ds-it-docto-xml.tipo-nota    = 1                        AND 
                       int(int-ds-it-docto-xml.nnf)         = int(tt-it-docto-xml.nnf) AND 
                           int-ds-it-docto-xml.it-codigo    = tt-it-docto-xml.it-codigo:
                            
                     END.
                     IF NOT AVAIL int-ds-it-docto-xml 
                     THEN DO:
                         CREATE int-ds-it-docto-xml.
                         BUFFER-COPY tt-it-docto-xml TO int-ds-it-docto-xml.
            
                         ASSIGN int-ds-it-docto-xml.tipo-nota  = 1
                                int-ds-it-docto-xml.tipo-contr = 4
                                int-ds-it-docto-xml.xprod      = substring(item.desc-item,1,60)
                                int-ds-it-docto-xml.situacao   = 3.
                     END. 
        
                 END.
                    
                 FOR EACH tt-docum-est-nova:
                      DELETE  tt-docum-est-nova.
                 END.
                           
                 FOR EACH tt-item-doc-est-nova:
                     DELETE tt-item-doc-est-nova.
                 END.

                 FOR EACH tt-nota-ent:
                     DELETE tt-nota-ent.
                 END.

                 FOR EACH tt-docum-est-ent:
                     DELETE tt-docum-est-ent.
                 END.

                 FOR EACH tt-item-doc-est-ent:
                    DELETE tt-item-doc-est-ent.               
                 END.
                 
                 RUN pi-cria-tt-docum-est.   
                     
                 RUN pi-emite-nota-entrada.

                 IF l-movto-entrada-erro = NO 
                 THEN DO:
                 
                     CREATE tt-erro-docto.
                     ASSIGN tt-erro-docto.cnpj      = tt-docto-xml.cnpj
                            tt-erro-docto.nnf       = tt-docto-xml.nnf
                            tt-erro-docto.serie     = tt-docto-xml.serie
                            tt-erro-docto.cod-emitente = tt-docto-xml.cod-emitente
                            tt-erro-docto.nat-operacao = tt-docto-xml.nat-operacao
                            tt-erro-docto.cod-estab    = tt-docto-xml.cod-estab
                            tt-erro-docto.situacao  = 2
                            tt-erro-docto.cont      = tt-docto-xml.cont 
                            tt-erro-docto.desc-erro = "Documento Atualizado".
                 END.
                 
                 IF l-movto-entrada-erro = YES THEN UNDO , LEAVE TRANS-block.

        END. /* do trans */
          */

    END. /* tt-erro-docto */

end.

IF VALID-HANDLE(h-boin176) THEN
       DELETE PROCEDURE h-boin176.

run pi-finalizar in h-acomp.

for each tt-erro-docto 
    BREAK BY tt-erro-docto.situacao:

    IF FIRST-OF(tt-erro-docto.situacao)
    THEN DO:

       IF tt-erro-docto.situacao = 1 THEN
          PUT SKIP "Registros com erros: " AT 05 SKIP(1).
       ELSE DO:
        
          PUT SKIP(1) "Registros Atualizados: " AT 05 SKIP(1).
            
       END.

    END.

    disp tt-erro-docto.cod-emitente COLUMN-LABEL "Fornecedor"
         tt-erro-docto.cnpj         column-label "CNPJ"
         tt-erro-docto.nnf          COLUMN-LABEL "Nota"
         tt-erro-docto.serie        COLUMN-LABEL "Serie"
         tt-erro-docto.nat-operacao COLUMN-LABEL "Natureza"
         tt-erro-docto.cod-estab    COLUMN-LABEL "Estab"
         tt-erro-docto.it-codigo    column-label "Item"
         tt-erro-docto.sequencia    COLUMN-LABEL "Sequencia" 
         tt-erro-docto.desc-erro  FORMAT "x(50)"  COLUMN-LABEL "Descri‡Æo"
         with width 160 no-box stream-io down frame f-erros.
end.         


/* view frame f-rodape.    
   */

{include/i-rpclo.i}


PROCEDURE pi-gera-erro:
DEF INPUT PARAMETER p-desc-erro AS CHAR.    

 CREATE tt-erro-docto.
 ASSIGN tt-erro-docto.cnpj         = tt-docto-xml.cnpj
        tt-erro-docto.nnf          = tt-docto-xml.nnf
        tt-erro-docto.serie        = tt-docto-xml.serie
        tt-erro-docto.cod-emitente = tt-docto-xml.cod-emitente
        tt-erro-docto.nat-operacao = tt-docto-xml.nat-operacao
        tt-erro-docto.cod-estab    = tt-docto-xml.cod-estab
        tt-erro-docto.situacao     = 1
        tt-erro-docto.cont         = tt-docto-xml.cont 
        tt-erro-docto.desc-erro    = p-desc-erro.

 IF AVAIL tt-it-docto-xml THEN
    ASSIGN tt-erro-docto.sequencia = tt-it-docto-xml.sequencia
           tt-erro-docto.it-codigo = tt-it-docto-xml.it-codigo.

END PROCEDURE.


PROCEDURE pi-cria-tt-docum-est:
   
        run pi-acompanhar in h-acomp (input "Criando Nota de Entrada :" + STRING(tt-docto-xml.nnf)).
    
        FIND FIRST param-estoq NO-LOCK NO-ERROR.
     
        CREATE tt-nota-ent.
        ASSIGN tt-nota-ent.nro-docto    = tt-docto-xml.nnf  
               tt-nota-ent.serie-nota   = tt-docto-xml.serie
               tt-nota-ent.serie-docum  = tt-docto-xml.serie
               tt-nota-ent.nat-operacao = tt-docto-xml.nat-operacao                                   
               tt-nota-ent.cod-emitente = tt-docto-xml.cod-emitente 
               tt-nota-ent.tipo-nota    = 1
               tt-nota-ent.situacao     = 2.
        
        FIND FIRST emitente NO-LOCK WHERE
                   emitente.cod-emitente = tt-docto-xml.cod-emitente NO-ERROR.
        
        FIND FIRST natur-oper WHERE 
                   natur-oper.nat-operacao = tt-docto-xml.nat-operacao NO-ERROR.

        IF tt-docto-xml.demi < 10/01/2016 THEN
           ASSIGN dt-trans-movto = 10/01/2016.
        ELSE 
           ASSIGN dt-trans-movto = tt-docto-xml.demi.
             
         find first estab-mat no-lock where
                    estab-mat.cod-estabel = tt-docto-xml.cod-estab NO-ERROR. 

        CREATE tt-docum-est-ent.
        assign tt-docum-est-ent.registro     = 2
               tt-docum-est-ent.nro-docto    = tt-nota-ent.nro-docto
               tt-docum-est-ent.cod-emitente = tt-nota-ent.cod-emitente
               tt-docum-est-ent.serie-docto  = tt-nota-ent.serie-nota 
               /* tt-docum-est-ent.char-2       = tt-nota-ent.serie-docum /* Serie documento principal */       */
               tt-docum-est-ent.nat-operacao = tt-docto-xml.nat-operacao                              
               tt-docum-est-ent.cod-observa  = if natur-oper.log-2 then 2 /* Comercio */ else 1  /* Industria*/
               tt-docum-est-ent.cod-estabel  = tt-docto-xml.cod-estab
               tt-docum-est-ent.estab-fisc   = tt-docto-xml.cod-estab
               tt-docum-est-ent.usuario      = c-seg-usuario
               tt-docum-est-ent.uf           = emitente.estado 
               tt-docum-est-ent.via-transp   = 1
               tt-docum-est-ent.dt-emis      = tt-docto-xml.demi  
               tt-docum-est-ent.dt-trans     = dt-trans-movto                         
               tt-docum-est-ent.nff          = no                              
               tt-docum-est-ent.observacao   = "Importacao Docpar"
               tt-docum-est-ent.valor-mercad = 0 
               tt-docum-est-ent.tot-valor    = 0
               tt-docum-est-ent.ct-transit   = IF AVAIL estab-mat THEN estab-mat.cod-cta-fornec-unif ELSE ""
               tt-docum-est-ent.sc-transit   = ""     
               OVERLAY(tt-docum-est-ent.char-1,93,60)  = ""
               OVERLAY(tt-docum-est-ent.char-1,192,16) = "" /* Aviso de recolhimento */     
               tt-docum-est-ent.esp-docto     = 21.
     
     RELEASE tt-docum-est-ent.

     FOR FIRST tt-docum-est-ent where
               tt-docum-est-ent.nro-docto = tt-nota-ent.nro-docto :

     end.   
       
     
     FOR EACH tt-it-docto-xml WHERE
              tt-it-docto-xml.nnf          = tt-docto-xml.nnf          AND
              tt-it-docto-xml.cod-emitente = tt-docto-xml.cod-emitente AND 
              tt-it-docto-xml.serie        = tt-docto-xml.serie :
              
              for first item no-lock where 
                        item.it-codigo = tt-it-docto-xml.it-codigo: 
              end.

                 CREATE tt-item-doc-est-ent.
                 ASSIGN tt-item-doc-est-ent.registro       = 3
                        tt-item-doc-est-ent.serie-docto    = tt-docum-est-ent.serie-docto
                        tt-item-doc-est-ent.nro-docto      = tt-nota-ent.nro-docto
                        tt-item-doc-est-ent.cod-emitente   = tt-nota-ent.cod-emitente
                        tt-item-doc-est-ent.nat-operacao   = tt-it-docto-xml.nat-operacao
                        tt-item-doc-est-ent.sequencia      = tt-it-docto-xml.sequencia
                        tt-item-doc-est-ent.it-codigo      = tt-it-docto-xml.it-codigo
                        tt-item-doc-est-ent.lote           = ""
                        tt-item-doc-est-ent.num-pedido     = 0    
                        tt-item-doc-est-ent.numero-ordem   = 0
                        tt-item-doc-est-ent.parcela        = 0.
                 
                 FIND FIRST item-uni-estab NO-LOCK WHERE
                            item-uni-estab.cod-estabel = tt-docto-xml.cod-estab AND
                            item-uni-estab.it-codigo   = tt-it-docto-xml.it-codigo NO-ERROR.
                 IF AVAIL item-uni-estab THEN
                    ASSIGN c-cod-depos = item-uni-estab.deposito-pad.
                 ELSE 
                    ASSIGN c-cod-depos = item.deposito-pad.

                 IF c-cod-depos = "" THEN
                    ASSIGN c-cod-depos = "LOJ".  
                                
                 assign tt-item-doc-est-ent.encerra-pa     = no
                        tt-item-doc-est-ent.nr-ord-prod    = 0
                        tt-item-doc-est-ent.cod-roteiro    = ""
                        tt-item-doc-est-ent.op-codigo      = 0
                        tt-item-doc-est-ent.item-pai       = ""
                        tt-item-doc-est-ent.baixa-ce       = YES 
                        tt-item-doc-est-ent.quantidade     = tt-it-docto-xml.qcom
                        tt-item-doc-est-ent.qt-do-forn     = tt-it-docto-xml.qcom-forn
                        tt-item-doc-est-ent.preco-unit-me  = tt-it-docto-xml.vUnCom 
                        tt-item-doc-est-ent.desconto       = tt-it-docto-xml.vdesc
                        tt-item-doc-est-ent.cod-depos      = c-cod-depos
                        tt-item-doc-est-ent.class-fiscal   = item.class-fiscal
                        tt-item-doc-est-ent.preco-total    = tt-it-docto-xml.vprod.    

                 IF item.tipo-contr = 1 OR 
                    ITEM.tipo-contr = 4 
                 THEN DO:
                    IF AVAIL item-uni-estab THEN
                       ASSIGN tt-item-doc-est-ent.ct-codigo      = item-uni-estab.ct-codigo
                              tt-item-doc-est-ent.sc-codigo      = item-uni-estab.sc-codigo.
                    ELSE 
                       ASSIGN tt-item-doc-est-ent.ct-codigo      = ITEM.ct-codigo                                
                              tt-item-doc-est-ent.sc-codigo      = item.sc-codigo.  
                 END.
                 ELSE 
                   ASSIGN tt-item-doc-est-ent.ct-codigo = ""
                          tt-item-doc-est-ent.sc-codigo = "".

                 ASSIGN tt-docum-est-ent.valor-mercad = tt-docum-est-ent.valor-mercad + tt-it-docto-xml.vprod 
                        tt-docum-est-ent.tot-valor    = tt-docum-est-ent.tot-valor    + tt-it-docto-xml.vprod. 
     END.

     FOR EACH int-ds-doc-erro WHERE
              int-ds-doc-erro.serie-docto  = tt-nota-ent.serie-nota   AND 
              int-ds-doc-erro.cod-emitente = tt-nota-ent.cod-emitente AND
              int-ds-doc-erro.nro-docto    = tt-nota-ent.nro-docto    AND
              int-ds-doc-erro.tipo-nota    = tt-nota-ent.tipo-nota   :
          
            DELETE int-ds-doc-erro.

     END.


END PROCEDURE.

procedure pi-emite-nota-entrada:

         run pi-acompanhar in h-acomp (input "Gerando Nota Entrada ").
              
         ASSIGN l-movto-entrada-erro = NO.
               
         FOR EACH tt-nota-ent:
                 
                   FOR EACH tt-nota:
                        DELETE tt-nota.
                   END.
                    
                   FOR EACH tt-docum-est-nova:
                        DELETE tt-docum-est-nova.
                   END.

                   FOR EACH tt-item-doc-est-nova:
                       DELETE tt-item-doc-est-nova.
                   END.
                   
                   FOR FIRST tt-docum-est-ent WHERE
                             tt-docum-est-ent.nro-docto = tt-nota-ent.nro-docto:

                   END. 
                  
                   CREATE tt-nota.
                   BUFFER-COPY tt-nota-ent TO tt-nota.
                        
                   FOR EACH tt-docum-est-ent WHERE
                            tt-docum-est-ent.nro-docto = tt-nota-ent.nro-docto:

                        CREATE tt-docum-est-nova.
                        BUFFER-COPY tt-docum-est-ent TO tt-docum-est-nova.

                   END.

                   FOR EACH tt-item-doc-est-ent WHERE
                            tt-item-doc-est-ent.nro-docto = tt-nota-ent.nro-docto :

                        CREATE tt-item-doc-est-nova.
                        BUFFER-COPY tt-item-doc-est-ent TO tt-item-doc-est-nova.
                       
                   END. 

                    FIND FIRST docum-est NO-LOCK WHERE
                               docum-est.nro-docto    =  tt-nota.nro-docto    AND
                               docum-est.serie        =  tt-nota.serie-docum  AND
                               docum-est.tipo-nota    =  tt-nota.tipo-nota    AND
                               docum-est.nat-operacao =  tt-nota.nat-operacao AND
                               docum-est.cod-emitente =  tt-nota.cod-emitente NO-ERROR.
                    IF NOT AVAIL docum-est 
                    THEN DO: 
            
                        /* RUN intprg/int002e.p(INPUT TABLE tt-nota,
                                             INPUT TABLE tt-docum-est,
                                             INPUT TABLE tt-item-doc-est).
                         */

                         EMPTY TEMP-TABLE tt-erro.
                         EMPTY TEMP-TABLE tt-versao-integr.

                         create tt-versao-integr.
                         assign tt-versao-integr.registro              = 1
                                tt-versao-integr.cod-versao-integracao = 004.

                         run rep/reapi190b.p persistent set h-api.
                         run execute in h-api (input  table tt-versao-integr,
                                               input  table tt-docum-est-nova,
                                               input  table tt-item-doc-est-nova,
                                               input  table tt-dupli-apagar,
                                               input  table tt-dupli-imp,
                                               input  table tt-unid-neg-nota,
                                               output table tt-erro).
                         if valid-handle(h-api) then delete procedure h-api no-error.

                         find first tt-erro no-error.
                         if avail tt-erro then do:

                            FOR EACH tt-erro WHERE
                                     tt-erro.cd-erro <> 6506 :
                                                   
                                 RUN pi-gera-erro (INPUT tt-erro.mensagem). 
    
                                 DISP tt-erro.cd-erro
                                      tt-erro.mensagem
                                      tt-nota.nro-docto
                                      tt-nota.serie-docum   
                                      tt-nota.tipo-nota     
                                      tt-nota.nat-operacao  
                                      tt-nota.cod-emitente
                                      WITH WIDTH 333 STREAM-IO.

                                 ASSIGN l-movto-entrada-erro = YES.  

                            END.

                         END.
                    END.
            
                    IF l-movto-entrada-erro = NO 
                    THEN DO:
                    
                        FIND FIRST tt-nota NO-ERROR. 
                                                                                          
                        FIND FIRST docum-est NO-LOCK WHERE
                                   int(docum-est.nro-docto) =  int(tt-nota.nro-docto) AND
                                   docum-est.serie          =  tt-nota.serie-docum    AND
                                   docum-est.tipo-nota      =  tt-nota.tipo-nota      AND
                                   docum-est.nat-operacao   =  tt-nota.nat-operacao   AND
                                   docum-est.cod-emitente   =  tt-nota.cod-emitente NO-ERROR.
                        IF AVAIL docum-est 
                        THEN DO:

                           IF docum-est.ce-atual = NO 
                           THEN DO:

                                RUN pi-atualiza-impostos.

                                IF NOT CAN-FIND(FIRST dupli-apagar OF docum-est) 
                                THEN DO:
                                   RUN rep/re9341.p (input rowid(docum-est), input no).
                                END.
.
                                /* FOR EACH dupli-apagar OF docum-est NO-LOCK:

                                      MESSAGE dupli-apagar.parcela SKIP
                                              dupli-apagar.vl-a-pagar SKIP
                                              docum-est.tot-valor VIEW-AS ALERT-BOX.
                                      
                                END. */
                                           
                                for FIRST dupli-apagar  where 
                                          dupli-apagar.serie-docto  = docum-est.serie-docto  and
                                          dupli-apagar.nro-docto    = docum-est.nro-docto    and     
                                          dupli-apagar.cod-emitente = docum-est.cod-emitente and 
                                          dupli-apagar.nat-operacao = docum-est.nat-operacao : 
                                    
                                    ASSIGN dupli-apagar.vl-a-pagar  = docum-est.tot-valor.

                                    /* dupli-apagar.vl-desconto = docum-est.tot-desconto.
                                    
                                    IF dupli-apagar.vl-desconto > 0 THEN
                                       ASSIGN dupli-apagar.dt-venc-desc = TODAY + 365.
                                       
                                       */
                                END. 

                                /* RUN pi-atualizaDocumento.  */

                           END.
            
                        END.
            
                    END. /* l-movto com erro */

         END. /* each tt-nota */

END.

PROCEDURE pi-atualiza-impostos:

   FIND FIRST b-docum-est WHERE
              rowid(b-docum-est) = rowid(docum-est) NO-ERROR.

   IF AVAIL b-docum-est 
   THEN DO:

      FOR FIRST int-ds-docto-xml WHERE
                int-ds-docto-xml.serie        = b-docum-est.serie-docto    AND
                int(int-ds-docto-xml.nNF)     = int(b-docum-est.nro-docto) AND
                int-ds-docto-xml.cod-emitente = b-docum-est.cod-emitente   AND 
                int-ds-docto-xml.tipo-nota    = b-docum-est.tipo-nota      NO-LOCK:
      END.
      IF AVAIL int-ds-docto-xml THEN DO:
         ASSIGN b-docum-est.valor-frete  = int-ds-docto-xml.valor-frete            
                b-docum-est.valor-seguro = int-ds-docto-xml.valor-seguro           
                b-docum-est.despesa-nota = int-ds-docto-xml.despesa-nota           
                b-docum-est.valor-outras = int-ds-docto-xml.valor-outras                 
                b-docum-est.tot-desconto = int-ds-docto-xml.tot-desconto           
                b-docum-est.valor-mercad = int-ds-docto-xml.valor-mercad           
                b-docum-est.icm-deb-cre  = int-ds-docto-xml.valor-icms             
                b-docum-est.ipi-deb-cre  = int-ds-docto-xml.valor-ipi             
                b-docum-est.base-icm     = int-ds-docto-xml.vbc                    
                b-docum-est.base-subs    = int-ds-docto-xml.vbc-cst
                b-docum-est.tot-valor    = int-ds-docto-xml.vNF
                /*b-docum-est.val-cofins = int-ds-docto-xml.valor-cofins*/
                /*b-docum-est.valor-pis  = int-ds-docto-xml.valor-pis*/
                b-docum-est.vl-subs      = int-ds-docto-xml.valor-st
                b-docum-est.base-ipi     = 0 /* busca nos itens */
                b-docum-est.cod-chave-aces-nf-eletro = int-ds-docto-xml.chnfe.
                /* b-docum-est.icm-nao-trib  = int-ds-docto-xml.valor-icms-des. */

         FOR EACH int-ds-it-docto-xml WHERE 
                  int-ds-it-docto-xml.cod-emitente = int-ds-docto-xml.cod-emitente AND
                  int-ds-it-docto-xml.serie        = int-ds-docto-xml.serie        AND
                  int-ds-it-docto-xml.nNF          = int-ds-docto-xml.nNF          AND
                  int-ds-it-docto-xml.tipo-nota    = int-ds-docto-xml.tipo-nota    NO-LOCK:
             FOR FIRST item-doc-est WHERE
                       item-doc-est.cod-emitente   = int-ds-it-docto-xml.cod-emitente AND
                       item-doc-est.serie-docto    = int-ds-it-docto-xml.serie        AND
                       int(item-doc-est.nro-docto) = int(int-ds-it-docto-xml.nNF)     AND
                       item-doc-est.sequencia      = int-ds-it-docto-xml.sequencia    AND
                       item-doc-est.it-codigo      = int-ds-it-docto-xml.it-codigo:
             END.
             IF AVAIL item-doc-est THEN DO:

                FIND FIRST ITEM NO-LOCK
                     WHERE ITEM.it-codigo = item-doc-est.it-codigo NO-ERROR.

                IF AVAIL ITEM THEN DO:

                    IF ITEM.tipo-contr <> 2 THEN DO:

                        IF item-doc-est.num-pedido > 0 AND item-doc-est.numero-ordem > 0 THEN DO:
                            FIND FIRST ordem-compra NO-LOCK
                                 WHERE ordem-compra.num-pedido   = item-doc-est.num-pedido
                                   AND ordem-compra.numero-ordem = item-doc-est.numero-ordem NO-ERROR.

                            IF AVAIL ordem-compra THEN
                                ASSIGN item-doc-est.ct-codigo = ordem-compra.ct-codigo
                                       item-doc-est.sc-codigo = ordem-compra.sc-codigo.         
                        END.
                        ELSE IF item-doc-est.num-pedido > 0 AND item-doc-est.numero-ordem = 0 THEN DO:
                            FIND FIRST ordem-compra NO-LOCK
                                 WHERE ordem-compra.num-pedido   = item-doc-est.num-pedido
                                   AND ordem-compra.it-codigo    = item-doc-est.it-codigo NO-ERROR.

                              IF AVAIL ordem-compra THEN
                                  ASSIGN item-doc-est.ct-codigo = ordem-compra.ct-codigo
                                         item-doc-est.sc-codigo = ordem-compra.sc-codigo.   
                        END.
                        ELSE DO:
                               ASSIGN item-doc-est.ct-codigo = ITEM.ct-codigo
                                      item-doc-est.sc-codigo = ITEM.sc-codigo.   
                        END.

                        IF item-doc-est.ct-codigo = "" THEN DO:
                           IF AVAIL ordem-compra THEN
                               ASSIGN item-doc-est.ct-codigo = ordem-compra.ct-codigo
                                      item-doc-est.sc-codigo = ordem-compra.sc-codigo.   
                        END.
                    END.
                END.

                ASSIGN item-doc-est.num-pedido           = int-ds-it-docto-xml.num-pedido
                       item-doc-est.numero-ordem         = int-ds-it-docto-xml.numero-ordem 
                       item-doc-est.desconto             = int-ds-it-docto-xml.vDEsc                   
                       /*item-doc-est.nat-operacao       = int-ds-it-docto-xml.nat-operacao*/
                       item-doc-est.nat-of               = int-ds-it-docto-xml.nat-operacao
                       item-doc-est.aliquota-icm         = int-ds-it-docto-xml.picms   
                       item-doc-est.base-ipi[1]          = int-ds-it-docto-xml.vbc-ipi
                       item-doc-est.valor-ipi[1]         = 0
                       item-doc-est.ipi-outras           = int-ds-it-docto-xml.vipi /*int-ds-it-docto-xml.vbc-ipi*/
                       item-doc-est.valor-pis            = int-ds-it-docto-xml.vpis   
                       item-doc-est.preco-unit-me        = int-ds-it-docto-xml.vuncom
                       item-doc-est.preco-unit           = int-ds-it-docto-xml.vuncom
                       item-doc-est.preco-total[1]       = int-ds-it-docto-xml.vprod
                       item-doc-est.val-cofins           = int-ds-it-docto-xml.vcofins
                       item-doc-est.val-aliq-cofins      = int-ds-it-docto-xml.pcofins
                       item-doc-est.val-aliq-pis         = int-ds-it-docto-xml.ppis
                       item-doc-est.base-pis             = int-ds-it-docto-xml.vbc-pis
                       item-doc-est.idi-tributac-pis     = IF int-ds-it-docto-xml.ppis > 0 THEN 1 ELSE 3
                       item-doc-est.idi-tributac-cofins  = IF int-ds-it-docto-xml.pcofins > 0 THEN 1 ELSE 3
                       item-doc-est.val-base-calc-cofins = int-ds-it-docto-xml.vbc-cofins
                       item-doc-est.base-icm[1]          = int-ds-it-docto-xml.vbc-icms
                       item-doc-est.icm-outras[1]        = int-ds-it-docto-xml.vbc-icms
                       item-doc-est.valor-icm            = int-ds-it-docto-xml.vicms
                       item-doc-est.base-subs[1]         = int-ds-it-docto-xml.vbcst
                       item-doc-est.vl-subs[1]           = int-ds-it-docto-xml.vicmsst.
                       /* item-doc-est.icm-ntrib            = int-ds-it-docto-xml.vicmsdeson. */

                for first natur-oper fields (subs-trib)
                    no-lock where natur-oper.nat-operacao = item-doc-est.nat-of:
                end.
                IF AVAIL natur-oper THEN DO:
                   assign item-doc-est.log-2 = natur-oper.subs-trib.
                   /* retirado a pedido do Michel
                   IF int-ds-it-docto-xml.vicmsst > 0 THEN DO:
                      ASSIGN item-doc-est.log-icm-retido = natur-oper.subs-trib. 
                   END.
                   */
                END.
                /* retirado a pedido do Michel
                if int-ds-it-docto-xml.vicmsstret <> 0 then do:
                    assign item-doc-est.vl-subs[1]   = int-ds-it-docto-xml.vicmsstret.
                           /* item-doc-est.base-subs[1] = int-ds-it-docto-xml.vbcstret */
                END.
                */
               /* = int-ds-it-docto-xml.vbcst */   
               /* Verificar qual o campo no Datasul = int-ds-it-docto-xml.picmsst    */             
               /* Verificar qual o campo no Datasul = int-ds-it-docto-xml.pmvast     */
               /* Verificar qual o campo no Datasul = int-ds-it-docto-xml.vicmsst    */           

             END.

             assign b-docum-est.base-ipi = b-docum-est.base-ipi + int-ds-it-docto-xml.vbc-ipi.

         END.
      END.
   END.

END PROCEDURE.


PROCEDURE pi-atualizaDocumento:

/*------------------------------------------------------------------------------
*     Notes: Faz a atualiza¯?o do documento com base no TT-DOCUM-EST
*
 -----------------------------------------------------------------------------*/
    FOR EACH tt-arquivo-erro:
        DELETE tt-arquivo-erro.
    END.
            
    FOR EACH tt-erro-nota:  
        DELETE tt-erro-nota.
    END.    
              
    for each tt-digita-re:
        delete tt-digita-re.
    end.

    for each tt-param-re:
        delete tt-param-re.
    end.
    
   find first usuar_mestre no-lock
        where usuar_mestre.cod_usuario = "" /* c-seg-usuario */ no-error.
    
    create tt-param-re.
    assign tt-param-re.usuario         =  c-seg-usuario 
           tt-param-re.destino         = 2
           tt-param-re.data-exec       = today
           tt-param-re.hora-exec       = time
           tt-param-re.arquivo         = if avail usuar_mestre and usuar_mestre.nom_dir_spool <> "" then 
                                      (usuar_mestre.nom_dir_spool + "/")
                                      else session:temp-directory
           tt-param-re.arquivo         = tt-param-re.arquivo + "RE1005" + ".txt":U.
    
                                      
    for each tt-raw-digita-re:
        delete tt-raw-digita-re.
    end.

    create tt-digita-re.
    assign tt-digita-re.r-docum-est = rowid(DOCUM-EST).
    
    raw-transfer tt-param-re  to raw-param.

    for each tt-digita-re:
        create tt-raw-digita-re.
        raw-transfer tt-digita-re to tt-raw-digita-re.raw-digita.
    end.
    
    if  session:set-wait-state("GENERAL":U) THEN
        run rep/re1005rp.p (input raw-param, input table tt-raw-digita-re). 

    FOR EACH tt-raw-digita-re:
        DELETE tt-raw-digita-re.
    END.
   
    for each tt-digita-re:
        delete tt-digita-re.
    end.
    
    INPUT FROM value(tt-param-re.arquivo) CONVERT TARGET "iso8859-1".
    
        REPEAT:
           IMPORT UNFORMATTED c-linha.
            
           CREATE tt-arquivo-erro.
           ASSIGN tt-arquivo-erro.c-linha = c-linha.
        
        END.

        FOR EACH tt-arquivo-erro WHERE
                 LENGTH(tt-arquivo-erro.c-linha) > 0:
        
            IF tt-arquivo-erro.c-linha BEGINS "-" THEN NEXT. 
        
            ASSIGN c-nr-nota  = "".
               
            DO i-cont = 1 TO 8:    
        
               DO i-pos-arq = 0 TO 10:
        
                  IF SUBSTRING(SUBSTRING(tt-arquivo-erro.c-linha,7,8),i-cont,1) = STRING(i-pos-arq) THEN 
                     ASSIGN c-nr-nota = c-nr-nota + STRING(i-pos-arq).
        
               END.
        
            END.
        
            IF c-nr-nota = "" AND 
               SUBSTRING(tt-arquivo-erro.c-linha,53,90) = "" THEN NEXT.
            
            FIND LAST tt-erro-nota NO-ERROR.

            IF c-nr-nota <> "" THEN DO:
               CREATE tt-erro-nota.
               ASSIGN tt-erro-nota.serie         = SUBSTRING(tt-arquivo-erro.c-linha,1,3)
                      tt-erro-nota.nro-docto     = c-nr-nota
                      tt-erro-nota.cod-emitente  = int(SUBSTRING(tt-arquivo-erro.c-linha,24,9)) 
                      tt-erro-nota.cod-erro      = int(SUBSTRING(tt-arquivo-erro.c-linha,44,6)).
            END.

            IF AVAIL tt-erro-nota THEN
               ASSIGN tt-erro-nota.descricao  = tt-erro-nota.descricao + SUBSTRING(tt-arquivo-erro.c-linha,53,90).
        END.

        FOR EACH tt-erro-nota WHERE
                 tt-erro-nota.serie         =  docum-est.serie        AND
                 tt-erro-nota.nro-docto     =  c-nr-nota              AND          
                 tt-erro-nota.cod-emitente  =  docum-est.cod-emitente AND
                 tt-erro-nota.cod-erro   <> 6506  AND
                 tt-erro-nota.cod-erro   <> 4070  AND
                 tt-erro-nota.cod-erro   <> 11010
            BREAK BY tt-erro-nota.cod-erro:
          
            RUN pi-gera-erro (INPUT "Cod. Erro: " + STRING(tt-erro-nota.cod-erro) + " - " + tt-erro-nota.descricao). 

            ASSIGN l-movto-entrada-erro = YES.

        END.

    INPUT CLOSE.
     
    for each tt-param-re:
        delete tt-param-re.
    end.

    FOR EACH tt-arquivo-erro:
         DELETE tt-arquivo-erro.
    END.
 
END PROCEDURE.


PROCEDURE pi-calculapiscofins:
       
    DEF VAR vl-aliquotaPIS    AS DEC.
    DEF VAR vl-BasePIS        AS DEC.
    DEF VAR vl-PIS            AS DEC.
    DEF VAR TribPIS           AS INT.
    DEF VAR vl-aliquotaCOFINS AS DEC.
    DEF VAR vl-BaseCOFINS     AS DEC.
    DEF VAR vl-COFINS         AS DEC.
    DEF VAR TribCOFINS        AS INT.
                                         
    IF SUBSTRING(natur-oper.char-1,86,1) = '1'
    THEN do: /*PIS*/

       assign vl-aliquotaPIS = IF SUBSTR(item.char-2,52,1) = "1" THEN dec(substring(item.char-2,31,5))
                               ELSE if natur-oper.mercado = 1  then dec(substring(natur-oper.char-1,76,5))  
                               else if natur-oper.mercado = 2  then natur-oper.perc-pis[2] else 0
              vl-BasePIS     =  tt-it-docto-xml.vprod -  tt-it-docto-xml.vdesc  /*Para Entrada deverÿ ser utilizado essa f½rmula. Para OF jÿ recebemos esse valor calculado**/
              vl-PIS         = (vl-BasePIS * vl-aliquotaPIS) / 100
              TribPIS        = 1.
    END.
    ELSE DO: 

       ASSIGN vl-aliquotaPIS = 0
              vl-BasePIS     = 0
              vl-PIS         = 0
              TribPIS        = 2.

    END.

    if vl-aliquotaPIS <= 0 then do:
       assign vl-BasePIS = 0
              vl-PIS     = 0
              TribPIS    = 2.
    end.

    IF SUBSTRING(natur-oper.char-1,87,1) = '1' 
    THEN do: /*COFINS*/

       assign vl-aliquotaCOFINS = IF SUBSTR(item.char-2,53,1) = "1" THEN dec(substring(item.char-2,36,5))
                                  ELSE if natur-oper.mercado = 1 then dec(substring(natur-oper.char-1,81,5)) 
                                  else if natur-oper.mercado = 2 then natur-oper.perc-pis[2] else 0
              vl-BaseCOFINS     = tt-it-docto-xml.vprod - tt-it-docto-xml.vdesc  /*Para Entrada deverÿ ser utilizado essa f½rmula. Para OF jÿ recebemos esse valor calculado**/
              vl-COFINS         = (vl-BaseCOFINS * vl-aliquotaCOFINS) / 100
              TribCOFINS        = 1.  
    END. 
    ELSE DO:
        ASSIGN vl-aliquotaCOFINS = 0
               vl-BaseCOFINS = 0
               vl-COFINS     = 0
               TribCOFINS    = 2.
    END.

    if vl-aliquotaCOFINS <= 0 
    then do:
       assign vl-BaseCOFINS = 0
              vl-COFINS     = 0
              TribCOFINS    = 2.
    end.

    ASSIGN tt-it-docto-xml.vbc-pis    = vl-BasePIS 
           tt-it-docto-xml.vpis       = vl-PIS 
           tt-it-docto-xml.ppis       = vl-aliquotaPIS 
           tt-it-docto-xml.vbc-cofins = vl-BaseCOFINS
           tt-it-docto-xml.vcofins    = vl-COFINS 
           tt-it-docto-xml.pcofins    = vl-aliquotaCOFINS.


    /* <Atualiza Base, Valor, Al­quota e tipo de Trib de PIS e COFINS NO ITEM da nota de entrada>
       */


END PROCEDURE.


