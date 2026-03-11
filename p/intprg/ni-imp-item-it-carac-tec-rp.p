/********************************************************************************
**
**  Programa - NI-IMP-ITEM-IT-CARAC-TEC-RP.P 
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-ITEM-IT-CARAC-TEC-RP 2.00.00.000 } 

define temp-table tt-param
    field destino          as integer
    field arq-destino      as char
    field arq-entrada1     as char
    field todos            as integer
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer.

def temp-table tt-raw-digita                      
    field raw-digita      as raw.                 

DEF TEMP-TABLE tt-item
    FIELD it-codigo       AS CHAR
    FIELD descricao       AS CHAR
    FIELD desc-etiq       AS CHAR
    FIELD desc-web        AS CHAR
    FIELD divisao         as char 
    FIELD tp-produto      AS CHAR 
    field categ-conv      as char 
    FIELD sazonalidade    AS CHAR
    FIELD sub-gr-com      AS CHAR
    FIELD sigla-pdv       AS CHAR
    FIELD gera-pedido     AS CHAR
    FIELD lista-prod      AS CHAR
    field prod-fraciona   as char
    field qtde-lastro     as INTEGER
    field camada-lastro   as INTEGER    
    FIELD publico-alvo    AS CHAR
    FIELD crm-venda       AS CHAR
    FIELD prod-monit      AS CHAR
    FIELD tarjado         AS CHAR
    FIELD sngpc           AS CHAR
    FIELD portaria        AS CHAR
    field apres-produto   as INTEGER
    field dosagem-apres   as char
    field concentracao    as INT
    field dosagem-conc    as char
    FIELD nome-comerc     AS CHAR
    field data-sngpc      as DATE
    field csta            as char
    FIELD unid-medida     AS CHAR
    field exc-pis-cof-ncm as char
    field tributa-pis     as char
    field tributa-cofins  as char
    FIELD class-medic     AS CHAR
    FIELD utiliz-pauta    AS CHAR
    FIELD valor-pauta     AS CHAR
    field emite-etiq      as char
    FIELD pbm             AS CHAR
    FIELD cesta-basica    AS CHAR
    FIELD repos-pbm       AS CHAR
    FIELD qtde-emb        AS CHAR
    FIELD circ-depos      AS CHAR
    FIELD ac-devol        AS CHAR
    field mercadologica   as char
    FIELD reg-min-saude   AS CHAR.

DEF TEMP-TABLE tt-erro
    FIELD it-codigo LIKE item.it-codigo
    FIELD descricao AS CHAR FORMAT "x(60)" COLUMN-LABEL "Descri‡Æo".

DEF VAR i-cont        AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp       AS HANDLE                   NO-UNDO.
DEF VAR c-sub-grupo   AS CHAR                     NO-UNDO.
DEF VAR c-lista       AS CHAR                     NO-UNDO.
DEF VAR de-valor      AS DECIMAL FORMAT "9999999999999,99" NO-UNDO.
DEF VAR de-lastro     AS DECIMAL FORMAT "999999999,9999"   NO-UNDO.
DEF VAR de-produto    AS DECIMAL FORMAT "9999999,99"       NO-UNDO. 

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Atualiza‡Æo Item e Item Carac. Tec.").

EMPTY TEMP-TABLE tt-item.
EMPTY TEMP-TABLE tt-erro.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-item.
   IMPORT DELIMITER ";" tt-item.

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-item: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                               
for each tt-item WHERE tt-item.it-codigo <> "":
    FIND FIRST ITEM WHERE
               ITEM.it-codigo = tt-item.it-codigo NO-ERROR.
    IF NOT AVAIL ITEM THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.it-codigo = tt-item.it-codigo
              tt-erro.descricao = "Item nÆo cadastrado no Datasul".
       NEXT.
    END.

    ASSIGN ITEM.desc-item   = substr(tt-item.descricao,1,60)
           ITEM.descricao-1 = SUBSTR(tt-item.descricao,1,18)
           ITEM.descricao-2 = SUBSTR(tt-item.descricao,19,18)
           i-cont           = i-cont + 1.

    FOR EACH it-carac-tec WHERE 
             it-carac-tec.it-codigo = ITEM.it-codigo AND
             it-carac-tec.cd-folha  = "CADITEM":

        run pi-acompanhar in h-acomp (input "Atualizando Item: " + string(i-cont,">>>,>>>,>>9")).

        IF it-carac-tec.cd-comp = "10" THEN
           ASSIGN it-carac-tec.observacao = substr(tt-item.desc-etiq,1,40).                     

        IF it-carac-tec.cd-comp = "20" THEN                                                                     
           ASSIGN it-carac-tec.observacao = substr(tt-item.desc-web,1,40).                                        

        IF it-carac-tec.cd-comp = "25" THEN DO:        
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 25 AND
                      c-tab-res.descricao BEGINS substr(tt-item.divisao,1,3) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.                                                                                                                                                                                                    

        IF it-carac-tec.cd-comp = "30" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 30 AND
                      c-tab-res.descricao BEGINS substr(tt-item.tp-produto,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "40" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 40 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.categ-conv,1,2) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.                                                                                                                                                                                                    

        IF it-carac-tec.cd-comp = "45" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 45 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.sazonalidade,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.      

        IF it-carac-tec.cd-comp = "60" THEN DO:   
           ASSIGN c-sub-grupo = "".
           IF LENGTH(tt-item.sub-gr-com) = 1 THEN
              ASSIGN c-sub-grupo = "00" + tt-item.sub-gr-com.
           IF LENGTH(tt-item.sub-gr-com) = 2 THEN
              ASSIGN c-sub-grupo = "0" + tt-item.sub-gr-com.
           IF LENGTH(tt-item.sub-gr-com) = 3 THEN
              ASSIGN c-sub-grupo = tt-item.sub-gr-com.

           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 60 AND
                      c-tab-res.descricao BEGINS c-sub-grupo NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "65" THEN                                                             
           ASSIGN it-carac-tec.observacao = substr(tt-item.sigla-pdv,1,40).

        IF it-carac-tec.cd-comp = "70" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 70 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.gera-ped,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "90" THEN DO:
           ASSIGN c-lista = "".
           IF tt-item.lista-prod MATCHES "*NEUTRA*" THEN
              ASSIGN c-lista = "N".
           IF tt-item.lista-prod MATCHES "*NEGATIVA*" THEN
              ASSIGN c-lista = "-".
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 90 AND
                      c-tab-res.descricao BEGINS c-lista NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "100" THEN DO:                                                           
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 100 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.prod-fraciona,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.
           
        IF it-carac-tec.cd-comp = "110" THEN                                                            
           ASSIGN de-lastro              = DEC(tt-item.qtde-lastro)
                  it-carac-tec.vl-result = de-lastro.                                   
                                                                                                        
        IF it-carac-tec.cd-comp = "120" THEN                                                            
           ASSIGN de-lastro              = DEC(tt-item.camada-lastro)
                  it-carac-tec.vl-result = de-lastro.                                    

        IF it-carac-tec.cd-comp = "140" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 140 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.publico-alvo,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "150" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 150 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.crm-venda,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "170" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 170 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.prod-monit,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "180" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 180 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.tarjado,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "190" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 190 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.sngpc,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.
        
        IF it-carac-tec.cd-comp = "200" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 200 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.portaria,1,2) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "210" THEN
           ASSIGN de-produto             = DEC(tt-item.apres-produto)
                  it-carac-tec.vl-result = de-produto.

        IF it-carac-tec.cd-comp = "225" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 240 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.dosagem-apres,1,2) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "230" THEN
           ASSIGN de-produto             = DEC(tt-item.concentracao)
                  it-carac-tec.vl-result = de-produto.

        IF it-carac-tec.cd-comp = "240" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 240 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.dosagem-conc,1,2) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "250" THEN
           ASSIGN it-carac-tec.observacao = substr(tt-item.nome-comerc,1,40). 
 
        IF it-carac-tec.cd-comp = "255" THEN
           ASSIGN it-carac-tec.dt-result = tt-item.data-sngpc.

        IF it-carac-tec.cd-comp = "260" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 260 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.csta,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "270" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 270 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.unid-medida,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "280" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 280 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.exc-pis-cof-ncm,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "290" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 290 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.tributa-pis,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "300" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 300 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.tributa-cofins,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "310" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 310 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.class-medic,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "330" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 330 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.utiliz-pauta,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "340" THEN
           ASSIGN de-valor               = DEC(tt-item.valor-pauta)
                  it-carac-tec.vl-result = de-valor.

        IF it-carac-tec.cd-comp = "350" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 350 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.emite-etiq,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "360" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 360 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.pbm,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "370" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 370 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.cesta-basica,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "380" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 380 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.repos-pbm,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.
        
        IF it-carac-tec.cd-comp = "390" THEN 
            ASSIGN it-carac-tec.vl-result  = DEC(tt-item.qtde-emb)
                   it-carac-tec.observacao = STRING(tt-item.qtde-emb).

        IF it-carac-tec.cd-comp = "400" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 400 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.circ-depos,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "410" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 410 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.ac-devol,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "420" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 420 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-item.mercadologica,1,2) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              FIND FIRST it-res-carac WHERE
                         it-res-carac.cd-comp    = it-carac-tec.cd-comp   AND
                         it-res-carac.cd-folha   = it-carac-tec.cd-folh   AND
                         it-res-carac.it-codigo  = it-carac-tec.it-codigo AND
                         it-res-carac.nr-tabela  = it-carac-tec.nr-tabela NO-ERROR.
              IF NOT AVAIL it-res-carac THEN DO:
                 create it-res-carac.
                 assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                        it-res-carac.cd-folha   = it-carac-tec.cd-folh
                        it-res-carac.it-codigo  = it-carac-tec.it-codigo
                        it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                        it-res-carac.sequencia  = c-tab-res.sequencia.
              END.
              ELSE
                 ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

              ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).

           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "430" THEN
           ASSIGN it-carac-tec.vl-result  = DEC(tt-item.reg-min-saude)
                  it-carac-tec.observacao = STRING(tt-item.reg-min-saude).

   END.                                                                                         
END.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Atualiza‡Æo Item e Item Carac. Tec."
       c-programa     = "NI-IMP-ITEM-IT-CARAC-TEC-RP".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro WHERE tt-erro.it-codigo <> "" BY tt-erro.it-codigo:
    disp tt-erro with width 300 no-box stream-io down frame f-erros.
end.

view frame f-rodape.    

{include/i-rpclo.i}





