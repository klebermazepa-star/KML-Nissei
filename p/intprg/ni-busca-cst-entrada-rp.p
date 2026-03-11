/*********************************************************************************
**
**  Programa - ni-busca-cst-entrada-RP.P - Gera‡Æo dados SPED - CST Entrada
**
*********************************************************************************/ 

{include/i-prgvrs.i ni-busca-cst-entrada-RP 2.00.00.000 } 

define temp-table tt-param
    field destino          as integer
    field arq-destino      as char
    field todos            as integer
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer
    FIELD dt-inicio        AS DATE
    FIELD dt-fim           AS DATE
    FIELD c-arq-ncm        AS CHAR.

def temp-table tt-raw-digita                      
    field raw-digita      as raw.                 

DEF TEMP-TABLE tt-combinacao NO-UNDO
     FIELD seq          AS INT        
     FIELD cod-estabel  AS CHAR
     FIELD nat-operacao AS CHAR
     FIELD cod-item     AS CHAR
     FIELD cdn-grp-emit AS int
     FIELD cdn-emitente AS int
     FIELD cod-ncm      AS CHAR 
     FIELD c-chave      AS CHAR
     INDEX idx0 IS UNIQUE PRIMARY
             c-chave
             seq          
             cod-estabel 
             nat-operacao
             cod-item    
             cdn-grp-emit
             cdn-emitente
             cod-ncm.

DEF TEMP-TABLE tt-sit-tribut NO-UNDO
     FIELD cdn-tribut     AS INT
     FIELD cdn-sit-tribut AS INT
     FIELD seq-tab-comb   AS INT 
     FIELD c-chave        AS CHAR
     INDEX idx1 IS UNIQUE PRIMARY
             c-chave
             cdn-tribut
             cdn-sit-tribut 
             seq-tab-comb
     INDEX id-sit-trib
             seq-tab-comb
             c-chave.

DEF TEMP-TABLE tt-ncms-natur-item NO-UNDO
      FIELD ncm      LIKE  it-doc-fisc.class-fisc
      FIELD natureza LIKE  it-doc-fisc.nat-operacao 
      INDEX idx2 IS UNIQUE PRIMARY
              ncm 
              natureza.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

DEFINE VARIABLE h-acomp                     AS HANDLE      NO-UNDO.
DEFINE VARIABLE da-tmp                      AS DATE        NO-UNDO.
DEFINE VARIABLE c-cod-tributac-pis          AS CHAR        NO-UNDO.
DEFINE VARIABLE c-cod-tributac-cofins       AS CHAR        NO-UNDO.
DEFINE VARIABLE c-cod-sit-trib-ipi          AS CHAR        NO-UNDO.
DEFINE VARIABLE c-cod-sit-trib-pis          AS CHAR        NO-UNDO.
DEFINE VARIABLE c-cod-sit-trib-cofins       AS CHAR        NO-UNDO.
DEFINE VARIABLE c-chave-combinacao          AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-cont                      AS INTEGER     NO-UNDO.
DEFINE VARIABLE h-cdapi995                  AS HANDLE      NO-UNDO.
DEFINE VARIABLE de-aliq-pis                 AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-aliq-cofins              AS DECIMAL     NO-UNDO.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Gera‡Æo CST Sa¡da SPED").

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

EMPTY TEMP-TABLE tt-ncms-natur-item.
EMPTY TEMP-TABLE tt-combinacao.
EMPTY TEMP-TABLE tt-sit-tribut.

IF NOT VALID-HANDLE (h-cdapi995)  
THEN
    RUN cdp\cdapi995.p PERSISTENT SET h-cdapi995.

DO da-tmp = dt-inicio TO dt-fim:

    ASSIGN i-cont = 0.

    FOR EACH  doc-fiscal NO-LOCK 
        WHERE doc-fiscal.dt-docto  = da-tmp
          AND doc-fiscal.tipo-nat <> 2:

        ASSIGN i-cont = i-cont + 1.



        IF  i-cont = 100
        THEN
            LEAVE.



        run pi-acompanhar in h-acomp (input "SPED dia: " + string(da-tmp) +  " - Reg: " + string(i-cont)).


        FOR FIRST emitente NO-LOCK 
            WHERE emitente.cod-emitente = doc-fiscal.cod-emitente,
            FIRST gr-cli NO-LOCK 
            WHERE gr-cli.cod-gr-cli = emitente.cod-gr-cli:
        END.

        RUN pi-le-item-doc-fisc.
        RELEASE it-doc-fisc.
        RELEASE dwf-docto-item.
        RELEASE dwf-docto-item-impto.
    END.

END. /* DO da-tmp = dt-inicio TO dt-fim: */

IF  VALID-HANDLE(h-cdapi995) 
THEN DO:
    RUN pi-finalizar IN h-cdapi995.
    ASSIGN h-cdapi995 = ?.
END.

run pi-finalizar in h-acomp.

{include/i-rpclo.i}


{include/i-rpout.i &tofile=tt-param.c-arq-ncm}

PUT "NCM;Natureza" SKIP.

FOR EACH tt-ncms-natur-item NO-LOCK:
    PUT tt-ncms-natur-item.ncm ";" tt-ncms-natur-item.natureza SKIP.
END.

{include/i-rpclo.i}


PROCEDURE pi-le-item-doc-fisc:

   FOR EACH  it-doc-fisc OF doc-fiscal EXCLUSIVE-LOCK:

       ASSIGN c-cod-sit-trib-pis = ''
              c-cod-sit-trib-cofins = ''.

      FIND FIRST natur-oper NO-LOCK 
          WHERE  natur-oper.nat-operacao = it-doc-fisc.nat-operacao NO-ERROR.

      IF  it-doc-fisc.class-fiscal = "" OR
          it-doc-fisc.class-fiscal = ?
      THEN DO:
          FOR FIRST ITEM NO-LOCK
              WHERE ITEM.it-codigo = it-doc-fisc.it-codigo:
              ASSIGN it-doc-fisc.class-fiscal = ITEM.class-fiscal.
          END.
      END.

      RUN recupera-aliquotas IN h-cdapi995 (INPUT  "classif-fisc",
                                            INPUT  it-doc-fisc.class-fiscal,
                                            OUTPUT de-aliq-pis,
                                            OUTPUT de-aliq-cofins).
      IF  de-aliq-pis    = 0 OR
          de-aliq-cofins = 0
      THEN DO:
          FOR FIRST classif-fisc NO-LOCK
              WHERE classif-fisc.class-fiscal = it-doc-fisc.class-fiscal:

              IF  de-aliq-pis = 0
              THEN
                  ASSIGN de-aliq-pis = classif-fisc.dec-1.

              IF  de-aliq-cofins = 0
              THEN
                  ASSIGN de-aliq-cofins = classif-fisc.dec-2.
          END.
      END.

      IF  SUBSTRING(natur-oper.char-1,86,1) = '1' AND 
          de-aliq-pis                       > 0 
      THEN
          ASSIGN c-cod-tributac-pis = '1'.
      ELSE
         ASSIGN c-cod-tributac-pis = '2'. 

      IF  SUBSTRING(natur-oper.char-1,87,1) = '1' AND 
          de-aliq-cofins                    > 0 
      THEN
          ASSIGN c-cod-tributac-cofins = '1'.
      ELSE
         ASSIGN c-cod-tributac-cofins = '2'. 
                             
       IF  CAN-FIND(FIRST sit-tribut-relacto) 
       THEN DO:
           ASSIGN c-chave-combinacao = it-doc-fisc.cod-estabel                                 + 
                                       it-doc-fisc.nat-operacao                                + 
                                       it-doc-fisc.class-fiscal                                + 
                                       it-doc-fisc.it-codigo                                   + 
                                       IF AVAIL gr-cli THEN STRING(gr-cli.cod-gr-cli) ELSE "0" + 
                                       STRING(it-doc-fisc.cod-emitente).

           FOR FIRST tt-combinacao NO-LOCK
               WHERE tt-combinacao.c-chave = c-chave-combinacao:
           END.
         
           IF  NOT AVAIL tt-combinacao
           THEN
               RUN pi-retorna-sit-tribut  (INPUT 1, /*** 1-Entrada , 2 - Saida ***/
                                           INPUT it-doc-fisc.cod-estabel,  
                                           INPUT it-doc-fisc.nat-operacao, 
                                           INPUT it-doc-fisc.class-fiscal, 
                                           INPUT it-doc-fisc.it-codigo, 
                                           INPUT IF AVAIL gr-cli THEN gr-cli.cod-gr-cli ELSE 0, 
                                           INPUT it-doc-fisc.cod-emitente,  
                                           INPUT it-doc-fisc.dt-docto). 
    
          FOR EACH  tt-sit-tribut
              WHERE tt-sit-tribut.seq-tab-comb <> 0
                AND tt-sit-tribut.c-chave       = c-chave-combinacao:
          
               CASE tt-sit-tribut.cdn-tribut:
               /* NÊo pode ser verificado o codigo do tributo <> 0 pois existe relacionamento onde o codigo do tributo ? 00, e se verificado nÊo ? levado o relacionamento do cd0303 */
               WHEN 1 THEN ASSIGN c-cod-sit-trib-ipi     = STRING(tt-sit-tribut.cdn-sit-tribut,"99").
               WHEN 2 THEN ASSIGN c-cod-sit-trib-pis     = STRING(tt-sit-tribut.cdn-sit-tribut,"99").
               WHEN 3 THEN ASSIGN c-cod-sit-trib-cofins  = STRING(tt-sit-tribut.cdn-sit-tribut,"99").
               END CASE.
          END. 

          IF  Trim(c-cod-sit-trib-pis) = '' 
          THEN DO:
                FIND FIRST tt-ncms-natur-item NO-LOCK 
                    WHERE  tt-ncms-natur-item.ncm      = it-doc-fisc.class-fisc   
                      AND  tt-ncms-natur-item.natureza = it-doc-fisc.nat-operacao NO-ERROR.

                IF NOT AVAIL tt-ncms-natur-item 
                THEN DO:
                   CREATE tt-ncms-natur-item.
                   ASSIGN tt-ncms-natur-item.ncm      = it-doc-fisc.class-fisc
                          tt-ncms-natur-item.natureza = it-doc-fisc.nat-operacao.
                END.
          END.

          IF  Trim(c-cod-sit-trib-cofins) = '' 
          THEN DO:
               FIND FIRST tt-ncms-natur-item NO-LOCK 
                   WHERE  tt-ncms-natur-item.ncm      = it-doc-fisc.class-fisc  
                     AND  tt-ncms-natur-item.natureza = it-doc-fisc.nat-operacao NO-ERROR.

                IF NOT AVAIL tt-ncms-natur-item 
                THEN DO:
                   CREATE tt-ncms-natur-item.
                   ASSIGN tt-ncms-natur-item.ncm      = it-doc-fisc.class-fisc
                          tt-ncms-natur-item.natureza = it-doc-fisc.nat-operacao.
                END.
          END.  

          IF Trim(c-cod-sit-trib-pis) <> '' 
          THEN DO:  
              IF /*(Trim(c-cod-sit-trib-pis) = '50' OR Trim(c-cod-sit-trib-pis) = '01')*/
                   
                 SUBSTRING(natur-oper.char-1,86,1) = '1' AND de-aliq-pis > 0 THEN DO:
                  /*IF it-doc-fisc.val-base-calc-pis >= 0 THEN 
                     ASSIGN it-doc-fisc.val-base-calc-pis = it-doc-fisc.val-base-calc-pis.
                  ELSE
                      ASSIGN it-doc-fisc.val-base-calc-pis =  it-doc-fisc.vl-merc-liq .

                  IF it-doc-fisc.val-base-calc-pis <= 0 THEN
                      ASSIGN it-doc-fisc.val-base-calc-pis = it-doc-fisc.vl-merc-liq.

                  IF it-doc-fisc.val-base-calc-pis <= 0 THEN
                      ASSIGN it-doc-fisc.val-base-calc-pis = item-doc-est.preco-total[1].*/
                  ASSIGN it-doc-fisc.val-base-calc-pis = it-doc-fisc.vl-tot-item.    
                  
              END.  
              ELSE 
                  ASSIGN it-doc-fisc.val-base-calc-pis = 0.
          END.

          IF Trim(c-cod-sit-trib-cofins) <> '' 
          THEN DO:  
              IF /*(Trim(c-cod-sit-trib-cofins) = '50' OR Trim(c-cod-sit-trib-cofins) = '01')*/ 
                   SUBSTRING(natur-oper.char-1,87,1) = '1' AND de-aliq-cofins > 0   THEN DO:
                  /*IF it-doc-fisc.val-base-calc-cofins >= 0 THEN 
                      ASSIGN it-doc-fisc.val-base-calc-cofins = it-doc-fisc.val-base-calc-cofins.
                  ELSE
                      ASSIGN it-doc-fisc.val-base-calc-cofins =  it-doc-fisc.vl-merc-liq .

                  IF it-doc-fisc.val-base-calc-cofins <= 0 THEN
                      ASSIGN it-doc-fisc.val-base-calc-cofins = it-doc-fisc.vl-merc-liq.

                  IF it-doc-fisc.val-base-calc-cofins <= 0 THEN
                      ASSIGN it-doc-fisc.val-base-calc-cofins = item-doc-est.preco-total[1].*/
                  ASSIGN it-doc-fisc.val-base-calc-cofins = it-doc-fisc.vl-tot-item.    

              END.  
              ELSE 
                  ASSIGN it-doc-fisc.val-base-calc-cofins = 0.
          END.

          IF Trim(c-cod-sit-trib-pis) <> '' 
          THEN DO:
              ASSIGN /*it-doc-fisc.val-base-calc-pis = IF Trim(c-cod-sit-trib-pis) = '50' OR Trim(c-cod-sit-trib-pis) = '01' THEN 
                                                           IF it-doc-fisc.val-base-calc-pis >= 0 THEN 
                                                              it-doc-fisc.val-base-calc-pis  
                                                           ELSE it-doc-fisc.vl-merc-liq 
                                                    ELSE 0*/
                 it-doc-fisc.aliq-pis             = /*IF Trim(c-cod-sit-trib-pis) = '50' OR Trim(c-cod-sit-trib-pis) = '01' THEN  1.65 ELSE 0  */ 
                                                     IF SUBSTRING(natur-oper.char-1,86,1) = '1' THEN de-aliq-pis ELSE 0
                 it-doc-fisc.val-pis              = ROUND((it-doc-fisc.val-base-calc-pis * it-doc-fisc.aliq-pis) / 100,2)
                 it-doc-fisc.cd-trib-pis          =  IF it-doc-fisc.val-pis > 0 THEN 1 ELSE 2.
                        
          END.

          IF  it-doc-fisc.aliq-pis           > 0 AND 
              it-doc-fisc.val-pis           <= 0 AND 
              it-doc-fisc.val-base-calc-pis  > 0 
          THEN
              ASSIGN it-doc-fisc.val-pis = 0.01 it-doc-fisc.cd-trib-pis = 1.

          IF Trim(c-cod-sit-trib-cofins) <> '' 
          THEN DO:
              ASSIGN /*it-doc-fisc.val-base-calc-cofins = IF Trim(c-cod-sit-trib-cofins) = '50' OR Trim(c-cod-sit-trib-cofins) = '01' THEN 
                                                           IF it-doc-fisc.val-base-calc-cofins >= 0 THEN 
                                                              it-doc-fisc.val-base-calc-cofins  
                                                           ELSE it-doc-fisc.vl-merc-liq 
                                                    ELSE 0 */ 
                 it-doc-fisc.aliq-cofins          = /*IF Trim(c-cod-sit-trib-cofins) = '50' OR Trim(c-cod-sit-trib-cofins) = '01' THEN  7.60 ELSE 0  */ 
                                                    IF SUBSTRING(natur-oper.char-1,87,1) = '1' THEN de-aliq-cofins ELSE 0 
                 it-doc-fisc.val-cofins           = ROUND((it-doc-fisc.val-base-calc-cofins *  it-doc-fisc.aliq-cofins) / 100,2)
                 it-doc-fisc.cd-trib-cofins       =  IF it-doc-fisc.val-cofins > 0 THEN 1 ELSE 2. 
                 
          
          END. 
          
          IF  it-doc-fisc.aliq-cofins           > 0 AND 
              it-doc-fisc.val-cofins           <= 0 AND 
              it-doc-fisc.val-base-calc-cofins  > 0 
          THEN
              ASSIGN it-doc-fisc.val-cofins = 0.01 it-doc-fisc.cd-trib-cofins = 1.

          IF  it-doc-fisc.val-pis <= 0  
          THEN
              ASSIGN it-doc-fisc.val-base-calc-pis = 0
                     it-doc-fisc.val-pis           = 0
                     it-doc-fisc.aliq-pis          = 0
                     it-doc-fisc.cd-trib-pis       = 2.
                     /*c-cod-sit-trib-pis = '70'*/ 

          IF it-doc-fisc.val-cofins <= 0  
          THEN
              ASSIGN it-doc-fisc.val-base-calc-cofins = 0
                     it-doc-fisc.val-cofins           = 0
                     it-doc-fisc.aliq-cofins          = 0
                     it-doc-fisc.cd-trib-cofins       = 2.
                     /*c-cod-sit-trib-cofins = '70'*/

          IF natur-oper.especie-doc = 'NFT' 
          THEN
              ASSIGN it-doc-fisc.val-base-calc-cofins = 0
                     it-doc-fisc.aliq-cofins          = 0
                     it-doc-fisc.val-cofins           = 0
                     it-doc-fisc.cd-trib-cofins       = 2
                     it-doc-fisc.val-base-calc-pis    = 0
                     it-doc-fisc.val-pis              = 0
                     it-doc-fisc.aliq-pis             = 0
                     it-doc-fisc.cd-trib-pis          = 2.
                     /*c-cod-sit-trib-pis = '70'
                     c-cod-sit-trib-cofins =  '70'*/

          ASSIGN OVERLAY(it-doc-fisc.char-2,22,8) = STRING(it-doc-fisc.aliq-pis)
                 OVERLAY(it-doc-fisc.char-2,30,8) = STRING(it-doc-fisc.aliq-cofins).  
/*

Conforme validado com Rodrigo em 18/08 nÆo deve mais criar o registro na tabela sit-tribut-relacto, estas regras estÆo sendo importadas conforme definido pela Nissei

         FOR EACH  sit-tribut-relacto /**PIS**/
                WHERE sit-tribut-relacto.cdn-tribut   =  2
                  AND sit-tribut-relacto.cdn-sit-tribut   =  int(c-cod-sit-trib-pis)             
	              AND sit-tribut-relacto.idi-tip-docto    =  1 /* 1-Entrada e 2-sa¡da */   
	              AND sit-tribut-relacto.cod-estab        =  '*'                
	              AND sit-tribut-relacto.cod-natur-operac =  '*'               
	              AND sit-tribut-relacto.cod-ncm 	      =  '*'
	              AND sit-tribut-relacto.cod-item   	  =  it-doc-fisc.it-codigo                   
	              AND sit-tribut-relacto.cdn-grp-emit     =  0               
	              AND sit-tribut-relacto.cdn-emitente 	  =  0               
	              AND sit-tribut-relacto.dat-valid-inic  <= doc-fiscal.dt-docto EXCLUSIVE-LOCK:

               DELETE sit-tribut-relacto.
         END.

         FIND FIRST  sit-tribut-relacto  /**PIS**/
                WHERE sit-tribut-relacto.cdn-tribut   =  2
                  AND sit-tribut-relacto.cdn-sit-tribut   =  int(c-cod-sit-trib-pis)             
	              AND sit-tribut-relacto.idi-tip-docto    =  1 /* 1-Entrada e 2-sa¡da */   
	              AND sit-tribut-relacto.cod-estab        =  '*'                
	              AND sit-tribut-relacto.cod-natur-operac =  it-doc-fisc.nat-operacao               
	              AND sit-tribut-relacto.cod-ncm 	      =  '*'
	              AND sit-tribut-relacto.cod-item   	  =  it-doc-fisc.it-codigo                   
	              AND sit-tribut-relacto.cdn-grp-emit     =  0               
	              AND sit-tribut-relacto.cdn-emitente 	  =  0               
	              AND sit-tribut-relacto.dat-valid-inic  <= doc-fiscal.dt-docto NO-LOCK NO-ERROR.
         IF NOT AVAIL sit-tribut-relacto THEN DO: /**PIS**/
             CREATE sit-tribut-relacto.
             ASSIGN sit-tribut-relacto.cdn-tribut   =  2 
                    sit-tribut-relacto.cdn-sit-tribut  =  int(c-cod-sit-trib-pis)             
	               sit-tribut-relacto.idi-tip-docto    =  1 /* 1-Entrada e 2-sa¡da */   
	               sit-tribut-relacto.cod-estab        =  '*'                
	               sit-tribut-relacto.cod-natur-operac =  it-doc-fisc.nat-operacao               
	               sit-tribut-relacto.cod-ncm 	      =  '*'
	               sit-tribut-relacto.cod-item   	  =  it-doc-fisc.it-codigo                   
	               sit-tribut-relacto.cdn-grp-emit     =  0               
	               sit-tribut-relacto.cdn-emitente 	  =  0               
	               sit-tribut-relacto.dat-valid-inic  = 01/01/2011. 
            /*DISP sit-tribut-relacto EXCEPT cod-livre-1 cod-livre-2 WITH WIDTH 600 1 COL.   */
         END.
          FOR EACH  sit-tribut-relacto /**COFINS**/
                WHERE sit-tribut-relacto.cdn-tribut   =  3
                  AND sit-tribut-relacto.cdn-sit-tribut   =  int(c-cod-sit-trib-cofins)             
	              AND sit-tribut-relacto.idi-tip-docto    =  1 /* 1-Entrada e 2-sa¡da */   
	              AND sit-tribut-relacto.cod-estab        =  '*'                
	              AND sit-tribut-relacto.cod-natur-operac =  '*'               
	              AND sit-tribut-relacto.cod-ncm 	      =  '*'
	              AND sit-tribut-relacto.cod-item   	  =  it-doc-fisc.it-codigo                   
	              AND sit-tribut-relacto.cdn-grp-emit     =  0               
	              AND sit-tribut-relacto.cdn-emitente 	  =  0               
	              AND sit-tribut-relacto.dat-valid-inic  <= doc-fiscal.dt-docto EXCLUSIVE-LOCK:

               DELETE sit-tribut-relacto.
          END.
          FIND FIRST  sit-tribut-relacto  /*COFINS**/
                WHERE sit-tribut-relacto.cdn-tribut   =  3
                  AND sit-tribut-relacto.cdn-sit-tribut   =  int(c-cod-sit-trib-cofins)             
	              AND sit-tribut-relacto.idi-tip-docto    =  1 /* 1-Entrada e 2-sa¡da */   
	              AND sit-tribut-relacto.cod-estab        =  '*'                
	              AND sit-tribut-relacto.cod-natur-operac =  it-doc-fisc.nat-operacao               
	              AND sit-tribut-relacto.cod-ncm 	      =  '*'
	              AND sit-tribut-relacto.cod-item   	  =  it-doc-fisc.it-codigo                   
	              AND sit-tribut-relacto.cdn-grp-emit     =  0               
	              AND sit-tribut-relacto.cdn-emitente 	  =  0               
	              AND sit-tribut-relacto.dat-valid-inic  <= doc-fiscal.dt-docto NO-LOCK NO-ERROR.

         IF NOT AVAIL sit-tribut-relacto THEN DO:
             CREATE sit-tribut-relacto.
             ASSIGN sit-tribut-relacto.cdn-tribut   =  3 
                    sit-tribut-relacto.cdn-sit-tribut  =  int(c-cod-sit-trib-cofins)             
	               sit-tribut-relacto.idi-tip-docto    =  1 /* 1-Entrada e 2-sa¡da */   
	               sit-tribut-relacto.cod-estab        =  '*'                
	               sit-tribut-relacto.cod-natur-operac =  it-doc-fisc.nat-operacao               
	               sit-tribut-relacto.cod-ncm 	      =  '*'
	               sit-tribut-relacto.cod-item   	  =  it-doc-fisc.it-codigo                   
	               sit-tribut-relacto.cdn-grp-emit     =  0               
	               sit-tribut-relacto.cdn-emitente 	  =  0               
	               sit-tribut-relacto.dat-valid-inic  = 01/01/2011. 
            /*DISP sit-tribut-relacto EXCEPT cod-livre-1 cod-livre-2 WITH WIDTH 600 1 COL.   */
         END.
*/
          FOR FIRST dwf-docto-item USE-INDEX dwfdcttm-id
                WHERE dwf-docto-item.cod-estab         = it-doc-fisc.cod-estabel 
                AND   dwf-docto-item.cod-serie         = it-doc-fisc.serie	
                AND   dwf-docto-item.cod-docto         = it-doc-fisc.nr-doc-fis  
                AND   dwf-docto-item.cod-emitente      = STRING(it-doc-fisc.cod-emitente)
                AND   dwf-docto-item.cod-natur-operac  = it-doc-fisc.nat-operacao 
                AND   dwf-docto-item.num-seq-item      = it-doc-fisc.nr-seq-doc
                AND   dwf-docto-item.dat-fim-valid     = ? NO-LOCK:

                FOR FIRST dwf-docto-item-impto USE-INDEX dwfdctta-id
                    WHERE dwf-docto-item-impto.cod-estab         = it-doc-fisc.cod-estabel 
                    AND   dwf-docto-item-impto.cod-serie         = it-doc-fisc.serie	
                    AND   dwf-docto-item-impto.cod-docto         = it-doc-fisc.nr-doc-fis  
                    AND   dwf-docto-item-impto.cod-emitente      = STRING(it-doc-fisc.cod-emitente)
                    AND   dwf-docto-item-impto.cod-natur-operac  = it-doc-fisc.nat-operacao 
                    AND   dwf-docto-item-impto.num-seq-item      = it-doc-fisc.nr-seq-doc   
                    AND   dwf-docto-item-impto.cod-impto         = "PIS":U 
                    AND   dwf-docto-item-impto.dat-fim-valid     = ? EXCLUSIVE-LOCK:
                END.

                IF  NOT AVAIL dwf-docto-item-impto THEN DO:
                    CREATE dwf-docto-item-impto.
                    ASSIGN dwf-docto-item-impto.cod-estab         = it-doc-fisc.cod-estabel           
                           dwf-docto-item-impto.cod-serie         = it-doc-fisc.serie                 
                           dwf-docto-item-impto.cod-docto         = it-doc-fisc.nr-doc-fis            
                           dwf-docto-item-impto.cod-emitente      = STRING(it-doc-fisc.cod-emitente)  
                           dwf-docto-item-impto.cod-natur-operac  = it-doc-fisc.nat-operacao          
                           dwf-docto-item-impto.num-seq-item      = it-doc-fisc.nr-seq-doc            
                           dwf-docto-item-impto.cod-impto         = "PIS":U
                           dwf-docto-item-impto.cod-item          = IF it-doc-fisc.it-codigo = "" THEN "DD" ELSE it-doc-fisc.it-codigo
                           dwf-docto-item-impto.cod-livre-2       = "I".
                END.
                ELSE 
                    ASSIGN dwf-docto-item-impto.cod-livre-2       = "A".

                ASSIGN dwf-docto-item-impto.val-base-impto     = it-doc-fisc.val-base-calc-pis
                       dwf-docto-item-impto.val-aliq-impto     = it-doc-fisc.aliq-pis
                       dwf-docto-item-impto.val-impto-tributad = it-doc-fisc.val-pis
                       dwf-docto-item-impto.cod-tributac       = c-cod-sit-trib-pis.

                FOR FIRST dwf-docto-item-impto
                    WHERE dwf-docto-item-impto.cod-estab         = it-doc-fisc.cod-estabel 
                    AND   dwf-docto-item-impto.cod-serie         = it-doc-fisc.serie	
                    AND   dwf-docto-item-impto.cod-docto         = it-doc-fisc.nr-doc-fis  
                    AND   dwf-docto-item-impto.cod-emitente      = STRING(it-doc-fisc.cod-emitente)
                    AND   dwf-docto-item-impto.cod-natur-operac  = it-doc-fisc.nat-operacao 
                    AND   dwf-docto-item-impto.num-seq-item      = it-doc-fisc.nr-seq-doc   
                    AND   dwf-docto-item-impto.cod-impto         = "COFINS":U 
                    AND   dwf-docto-item-impto.dat-fim-valid     = ? EXCLUSIVE-LOCK:
                END.

                IF  NOT AVAIL dwf-docto-item-impto THEN DO:
                    CREATE dwf-docto-item-impto.
                    ASSIGN dwf-docto-item-impto.cod-estab         = it-doc-fisc.cod-estabel           
                           dwf-docto-item-impto.cod-serie         = it-doc-fisc.serie                 
                           dwf-docto-item-impto.cod-docto         = it-doc-fisc.nr-doc-fis            
                           dwf-docto-item-impto.cod-emitente      = STRING(it-doc-fisc.cod-emitente)  
                           dwf-docto-item-impto.cod-natur-operac  = it-doc-fisc.nat-operacao          
                           dwf-docto-item-impto.num-seq-item      = it-doc-fisc.nr-seq-doc            
                           dwf-docto-item-impto.cod-impto         = "COFINS":U
                           dwf-docto-item-impto.cod-item          = IF it-doc-fisc.it-codigo = "" THEN "DD" ELSE it-doc-fisc.it-codigo.
                           dwf-docto-item-impto.cod-livre-2       = "I".
                END.
                ELSE 
                    ASSIGN dwf-docto-item-impto.cod-livre-2       = "A".

                ASSIGN dwf-docto-item-impto.val-base-impto     = it-doc-fisc.val-base-calc-cofins
                       dwf-docto-item-impto.val-aliq-impto     = it-doc-fisc.aliq-cofins
                       dwf-docto-item-impto.val-impto-tributad = it-doc-fisc.val-cofins
                       dwf-docto-item-impto.cod-tributac       = c-cod-sit-trib-cofins.
            END.


            PUT doc-fiscal.dt-docto           ";" it-doc-fisc.cod-estabel          ";"
                it-doc-fisc.serie             ";" it-doc-fisc.nr-doc-fis           ";" 
                it-doc-fisc.cod-emitente      ";" it-doc-fisc.nat-operacao         ";" 
                it-doc-fisc.it-codigo         ";" it-doc-fisc.class-fisc           ";" 
                c-cod-sit-trib-pis            ";" c-cod-sit-trib-cofins            ";" 
                it-doc-fisc.val-base-calc-pis ";"  it-doc-fisc.aliq-pis            ";"  
                it-doc-fisc.val-pis           ";" it-doc-fisc.val-base-calc-cofins ";" 
                it-doc-fisc.aliq-cofins       ";" it-doc-fisc.val-cofins 
                /*";" dwf-docto-item-impto.cod-impto*/ 
                SKIP.
       END.
   END.

END PROCEDURE.


PROCEDURE pi-retorna-sit-tribut:

    DEF INPUT  PARAM p-tipo-nota    AS INT                       NO-UNDO.
    def input  param p-cod-estabel  as CHAR FORMAT 'X(3)'        no-undo.
    def input  param p-nat-oper     AS CHAR FORMAT 'X(6)'        no-undo.
    def input  param p-ncm          AS CHAR FORMAT "9999.99.99"  no-undo.
    def input  param p-it-codigo    AS CHAR FORMAT 'X(16)'       no-undo.
    def input  param p-cod-gr-cli   AS INT  FORMAT ">9"          no-undo.
    def input  param p-cod-emitente AS INT  FORMAT ">>>>>>>>9"   no-undo.
    def input  param p-dt-emis-nota as date FORMAT 99/99/9999    no-undo.

    /*** Cria tabela de combina¯´es para busca do c«digo da situa¯Êo tribut˜ria ***/
    RUN pi-gera-tt-combinacao (INPUT p-cod-estabel, 
                               input p-nat-oper,    
                               input p-ncm,          
                               input p-it-codigo,            
                               input p-cod-gr-cli,   
                               input p-cod-emitente).

    /*** Cria tabela de tributos ***/
    IF NOT CAN-FIND(FIRST tt-sit-tribut
                    WHERE tt-sit-tribut.c-chave = c-chave-combinacao) THEN
        for each tribut no-lock:
            create tt-sit-tribut.
            assign tt-sit-tribut.cdn-tribut     = tribut.cdn-tribut
                   tt-sit-tribut.c-chave        = c-chave-combinacao
                   tt-sit-tribut.cdn-sit-tribut = 0
                   tt-sit-tribut.seq-tab-comb   = 0. /*** Quando esse campo for diferente de zero indica que foi encontrado o c«digo de situa¯Êo tribut˜ria e portanto nÊo ý
                                                      mais necess˜rio realizar a busca na tabela de combina¯Êo. Este campo armazena a sequencia da tabela de combin¯Êo, permitindo
                                                      saber de que combina¯Êo foi buscada o c«digo de situa¯Êo tribut˜ria. ***/
        end.

    Busca-cst:
    FOR EACH tt-combinacao 
        WHERE tt-combinacao.c-chave = c-chave-combinacao NO-LOCK:
        
        FOR EACH  tt-sit-tribut
            WHERE tt-sit-tribut.seq-tab-comb = 0 /*** Se o c«digo de situa¯Êo tribut˜ria para o tributo j˜ foi encontrado esse campo ser˜ diferente de zero, e portanto nÊo ý necess˜rio continuar a busca ***/
              AND tt-sit-tribut.c-chave      = c-chave-combinacao:
            FIND LAST sit-tribut-relacto  USE-INDEX sttrbtrl-id
                WHERE sit-tribut-relacto.cdn-tribut	      =  tt-sit-tribut.cdn-tribut             
	              AND sit-tribut-relacto.idi-tip-docto    =  p-tipo-nota /* 1-Entrada e 2-saðda */   
	              AND sit-tribut-relacto.cod-estab        =  tt-combinacao.cod-estabel                
	              AND sit-tribut-relacto.cod-natur-operac =  tt-combinacao.nat-operacao               
	              AND sit-tribut-relacto.cod-ncm 	      =  tt-combinacao.cod-ncm
	              AND sit-tribut-relacto.cod-item   	  =  tt-combinacao.cod-item                   
	              AND sit-tribut-relacto.cdn-grp-emit     =  tt-combinacao.cdn-grp-emit               
	              AND sit-tribut-relacto.cdn-emitente 	  =  tt-combinacao.cdn-emitente               
	              AND sit-tribut-relacto.dat-valid-inic  <= p-dt-emis-nota NO-LOCK NO-ERROR. 
            IF AVAIL sit-tribut-relacto THEN
                ASSIGN tt-sit-tribut.cdn-sit-tribut = sit-tribut-relacto.cdn-sit-tribut
                       tt-sit-tribut.seq-tab-comb   = tt-combinacao.seq.
        END.
        IF NOT CAN-FIND(FIRST tt-sit-tribut
            WHERE tt-sit-tribut.seq-tab-comb = 0 
              AND tt-sit-tribut.c-chave      = c-chave-combinacao) 
        THEN
            LEAVE Busca-cst.
    END.

END PROCEDURE.


PROCEDURE pi-gera-tt-combinacao:

    def input  param p-cod-estabel  as CHAR FORMAT 'X(3)'        no-undo.  
    def input  param p-nat-oper     AS CHAR FORMAT 'X(6)'        no-undo.
    def input  param p-ncm          AS CHAR FORMAT "999.99.99"   no-undo.
    def input  param p-it-codigo    AS CHAR FORMAT 'X(16)'       no-undo.
    def input  param p-cod-gr-cli   AS INT  FORMAT ">9"          no-undo.
    def input  param p-cod-emitente AS INT  FORMAT ">>>>>>>>9"   no-undo.

    /*** Objetivo: gerar uma tabela de combina¯´es possðveis para a busca do c«digo
    de situa¯Êo tribut˜ria (CST) na tabela sit-tribut-relacto a partir do tributo 
    (PIS, COFINS ou IPI) e tipo de nota (E-Entrada / S-Saðda). Este mýtodo nÊo sofrer˜ altera¯´es
    se nÊo for criado um novo campo de busca no programa CD9780 - Relacionamento do CST - Everton/Adonias/Leandro ***/

/****** Tabela a comentar ******
Seq	Estab	Nat Ope	NCM	Item	Grup Emit	Cod Emit
01   xxx	xxx    	xxx	xxx        	xxx       xxx
02   xxx	xxx    	xxx	xxx        	xxx        o
03   xxx	xxx    	xxx	xxx        	 o        xxx
04   xxx	xxx    	xxx	xxx        	 o         o
05   xxx	xxx    	xxx	 o          xxx       xxx
06   xxx	xxx    	xxx	 o          xxx        o
07   xxx	xxx    	xxx	 o           o        xxx
08   xxx	xxx    	xxx	 o           o         o
09   xxx	xxx      o	xxx        	xxx       xxx
10   xxx	xxx      o	xxx        	xxx        o
11   xxx	xxx      o	xxx        	 o        xxx
12   xxx	xxx      o	xxx        	 o         o
13   xxx	xxx      o	 o          xxx       xxx
14   xxx	xxx      o	 o          xxx        o
15   xxx	xxx      o	 o           o        xxx
16   xxx	xxx      o	 o           o         o
17   xxx     o      xxx	xxx        	xxx       xxx
18   xxx     o      xxx	xxx        	xxx        o
19   xxx     o      xxx	xxx        	 o        xxx
20   xxx     o      xxx	xxx        	 o         o
21   xxx     o      xxx	 o          xxx       xxx
22   xxx     o      xxx	 o          xxx        o
23   xxx     o      xxx	 o           o        xxx
24   xxx     o      xxx	 o           o         o
25   xxx     o       o	xxx        	xxx       xxx
26   xxx     o       o	xxx        	xxx        o
27   xxx     o       o	xxx        	 o        xxx
28   xxx     o       o	xxx        	 o         o
29   xxx     o       o	 o          xxx       xxx
30   xxx     o       o	 o          xxx        o
31   xxx     o       o	 o           o        xxx
32   xxx     o       o	 o           o         o
33    o 	xxx    	xxx	xxx        	xxx       xxx
34    o 	xxx    	xxx	xxx        	xxx        o
35    o 	xxx    	xxx	xxx        	 o        xxx
36    o 	xxx    	xxx	xxx        	 o         o
37    o 	xxx    	xxx	 o          xxx       xxx
38    o 	xxx    	xxx	 o          xxx        o
39    o 	xxx    	xxx	 o           o        xxx
40    o 	xxx    	xxx	 o           o         o
41    o 	xxx      o	xxx        	xxx       xxx
42    o 	xxx      o	xxx        	xxx        o
43    o 	xxx      o	xxx        	 o        xxx
44    o 	xxx      o	xxx        	 o         o
45    o 	xxx      o	 o          xxx       xxx
46    o 	xxx      o	 o          xxx        o
47    o 	xxx      o	 o           o        xxx
48    o 	xxx      o	 o           o         o
49    o      o      xxx	xxx        	xxx       xxx
50    o      o      xxx	xxx        	xxx        o
51    o      o      xxx	xxx        	 o        xxx
52    o      o      xxx	xxx        	 o         o
53    o      o      xxx	 o          xxx       xxx
54    o      o      xxx	 o          xxx        o
55    o      o      xxx	 o           o        xxx
56    o      o      xxx	 o           o         o
57    o      o       o	xxx        	xxx       xxx
58    o      o       o	xxx        	xxx        o
59    o      o       o	xxx        	 o        xxx
60    o      o       o	xxx        	 o         o
61    o      o       o	 o          xxx       xxx
62    o      o       o	 o          xxx        o
63    o      o       o	 o           o        xxx
64    o      o       o	 o           o         o
**********************/

    DEF VAR i-cont AS INTE  NO-UNDO.
    DEF VAR l-estab AS LOGICAL  NO-UNDO EXTENT 2.

    ASSIGN l-estab = NO.

    FIND FIRST sit-tribut-relacto USE-INDEX sttrbtrl-estab
         WHERE sit-tribut-relacto.cod-estab = p-cod-estabel NO-LOCK NO-ERROR.
    IF  AVAIL sit-tribut-relacto THEN
        ASSIGN l-estab[1] = YES.

    FIND FIRST sit-tribut-relacto USE-INDEX sttrbtrl-estab
         WHERE sit-tribut-relacto.cod-estab = "*" NO-LOCK NO-ERROR.
    IF  AVAIL sit-tribut-relacto THEN
        ASSIGN l-estab[2] = YES.
    
    /*** A tabela de combina¯´es possðveis ir˜ possuir seis campos de busca (Estab, Nat Ope NCM, Item, Grup Emit, Cod Emit). 
     Considerando essa informa¯Êo, para cria¯Êo dos registros na tabela, ao todos teremos 64 combina¯´es. 
     Para cada campo duplica-se o nßmero de combina¯´es na tabela, ou seja, um Campo = duas cobina¯´es,
     dois campos = quatro combina¯´es, tr¬s campos = oito combina¯´es, quatro campos = dezesseis combina¯´es, cinco campos = trinda e duas combina¯´es,
     seis campos = sessenta e quatro combina¯´es, e assim sucessivamente. Por fim, teremos sesenta e quatro registros nessa tabela, que representam
     sessenta e quatro combina¯´es. Obs: Everton/Adonias/Leandro ***/

    DO i-cont = 1 TO 64:
        
        IF  (    i-cont <= 32
             AND l-estab[1] = YES) 
        OR  (    i-cont >= 33
             AND l-estab[2] = YES) THEN DO:
            
            CREATE tt-combinacao.
            ASSIGN tt-combinacao.seq     = i-cont
                   tt-combinacao.c-chave = c-chave-combinacao.
            
            /* ESTABELECIMENTO */

            /* informado */
            IF  i-cont <= 32 
            AND l-estab[1] = YES THEN
                ASSIGN tt-combinacao.cod-estabel = p-cod-estabel.

            /* generico */
            IF  i-cont >= 33
            AND l-estab[2] = YES THEN
                ASSIGN tt-combinacao.cod-estabel = "*".

            /* NATUREZA DE OPERACAO */

            /* informado */
            IF (    i-cont >= 1
                AND i-cont <= 16)
            OR (    i-cont >= 33
                AND i-cont <= 48) THEN
                ASSIGN tt-combinacao.nat-operacao = p-nat-oper.

            /* generico */
            IF (    i-cont >= 17
                AND i-cont <= 32)
            OR (    i-cont >= 49
                AND i-cont <= 64) THEN
                ASSIGN tt-combinacao.nat-operacao = "*".

            /* NCM */

            /*informado*/
            IF (    i-cont >= 1
                AND i-cont <= 8)
            OR (    i-cont >= 17
                AND i-cont <= 24)
            OR (    i-cont >= 33
                AND i-cont <= 40)
            OR (    i-cont >= 49
                AND i-cont <= 56) THEN
                ASSIGN tt-combinacao.cod-ncm = STRING(p-ncm).

            /* generico */
            IF (    i-cont >= 9                         
                AND i-cont <= 16)                        
            OR (    i-cont >= 25                        
                AND i-cont <= 32)                       
            OR (    i-cont >= 41                        
                AND i-cont <= 48)                       
            OR (    i-cont >= 57                        
                AND i-cont <= 64) THEN                  
                ASSIGN tt-combinacao.cod-ncm = "*".

            /* ITEM */

            /*informado*/
            IF (    i-cont >= 1  
                AND i-cont <= 4) 
            OR (    i-cont >= 9 
                AND i-cont <= 12)
            OR (    i-cont >= 17 
                AND i-cont <= 20)
            OR (    i-cont >= 25 
                AND i-cont <= 28)
            OR (    i-cont >= 33   
                AND i-cont <= 36) 
            OR (    i-cont >= 41  
                AND i-cont <= 44) 
            OR (    i-cont >= 49  
                AND i-cont <= 52) 
            OR (    i-cont >= 57  
                AND i-cont <= 60) THEN
                ASSIGN tt-combinacao.cod-item = p-it-codigo.

            /* generico */
            IF (    i-cont >= 5                                 
                AND i-cont <= 8)                                
            OR (    i-cont >= 13                                 
                AND i-cont <= 16)                               
            OR (    i-cont >= 21                                
                AND i-cont <= 24)                               
            OR (    i-cont >= 29                                
                AND i-cont <= 32)                               
            OR (    i-cont >= 37                                
                AND i-cont <= 40)                               
            OR (    i-cont >= 45                                
                AND i-cont <= 48)                               
            OR (    i-cont >= 53                                
                AND i-cont <= 56)                               
            OR (    i-cont >= 61                                
                AND i-cont <= 64) THEN                          
                ASSIGN tt-combinacao.cod-item = "*". 

            /* GRUPO EMITENTE */

            /*informado*/
            IF (    i-cont >= 1  
                AND i-cont <= 2) 
            OR (    i-cont >= 5  
                AND i-cont <= 6)
            OR (    i-cont >= 9 
                AND i-cont <= 10)
            OR (    i-cont >= 13 
                AND i-cont <= 14)
            OR (    i-cont >= 17 
                AND i-cont <= 18)
            OR (    i-cont >= 21 
                AND i-cont <= 22)
            OR (    i-cont >= 25 
                AND i-cont <= 26)
            OR (    i-cont >= 29 
                AND i-cont <= 30)
            OR (    i-cont >= 33  
                AND i-cont <= 34) 
            OR (    i-cont >= 37  
                AND i-cont <= 38) 
            OR (    i-cont >= 41  
                AND i-cont <= 42)
            OR (    i-cont >= 45 
                AND i-cont <= 46)
            OR (    i-cont >= 49 
                AND i-cont <= 50)
            OR (    i-cont >= 53 
                AND i-cont <= 54)
            OR (    i-cont >= 57 
                AND i-cont <= 58)
            OR (    i-cont >= 61 
                AND i-cont <= 62) THEN
                ASSIGN tt-combinacao.cdn-grp-emit = p-cod-gr-cli.

            /* generico */
            IF (    i-cont >= 3  
                AND i-cont <= 4) 
            OR (    i-cont >= 7  
                AND i-cont <= 8)
            OR (    i-cont >= 11 
                AND i-cont <= 12)
            OR (    i-cont >= 15 
                AND i-cont <= 16)
            OR (    i-cont >= 19 
                AND i-cont <= 20)
            OR (    i-cont >= 23 
                AND i-cont <= 24)
            OR (    i-cont >= 27 
                AND i-cont <= 28)
            OR (    i-cont >= 31 
                AND i-cont <= 32)
            OR (    i-cont >= 35  
                AND i-cont <= 36) 
            OR (    i-cont >= 39  
                AND i-cont <= 40) 
            OR (    i-cont >= 43  
                AND i-cont <= 44)
            OR (    i-cont >= 47 
                AND i-cont <= 48)
            OR (    i-cont >= 51 
                AND i-cont <= 52)
            OR (    i-cont >= 55 
                AND i-cont <= 56)
            OR (    i-cont >= 59 
                AND i-cont <= 60)
            OR (    i-cont >= 63 
                AND i-cont <= 64) THEN
                ASSIGN tt-combinacao.cdn-grp-emit = 0.

            /* COD EMIT */

            IF (i-cont MOD 2) = 1 THEN
                ASSIGN tt-combinacao.cdn-emitente = p-cod-emitente.
            ELSE
                ASSIGN tt-combinacao.cdn-emitente = 0.
        END.
    END.

END PROCEDURE.

