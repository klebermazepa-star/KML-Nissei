/********************************************************************************
**
**  Programa - INT070RP.P - Importa‡Æo Caracter¡sticas T‚cnicas dos Itens 
**
********************************************************************************/ 

{include/i-prgvrs.i INT070RP 2.00.00.000 } 

{utp/ut-glob.i}

define temp-table tt-param
    field destino          as integer
    field arq-destino      as char
    field arq-entrada1     as char
    field todos            as integer
    field usuario          as char
    field data-exec        as date
    field hora-exec        as INTEGER
    FIELD acao             AS INTEGER
    FIELD arq-saida        AS CHAR
    FIELD item-ini         AS CHAR
    FIELD item-fim         AS CHAR
    FIELD ge-cod-ini       AS INT
    FIELD ge-cod-fim       AS INT
    FIELD fam-cod-ini      AS CHAR
    FIELD fam-cod-fim      AS CHAR
    FIELD fam-com-ini      AS CHAR
    FIELD fam-com-fim      AS CHAR.

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
    FIELD reg-min-saude   AS CHAR
    INDEX codigo
             it-codigo.

DEF TEMP-TABLE tt-erro
    FIELD it-codigo LIKE item.it-codigo
    FIELD desc-item AS CHAR FORMAT "x(60)" COLUMN-LABEL "Descri‡Æo Item"
    FIELD desc-erro AS CHAR FORMAT "x(80)" COLUMN-LABEL "Descri‡Æo Erro"
    INDEX codigo
            desc-erro
            it-codigo.

DEF VAR i-cont        AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp       AS HANDLE                   NO-UNDO.
DEF VAR c-sub-grupo   AS CHAR                     NO-UNDO.
DEF VAR c-lista       AS CHAR                     NO-UNDO.
DEF VAR de-valor      AS DECIMAL FORMAT "9999999999999,99" NO-UNDO.
DEF VAR de-lastro     AS DECIMAL FORMAT "999999999,9999"   NO-UNDO.
DEF VAR de-produto    AS DECIMAL FORMAT "9999999,99"       NO-UNDO. 
DEF VAR i-seq-int-ds-item AS INT                           NO-UNDO.
DEF VAR l-erro        AS LOGICAL                           NO-UNDO.
def var i-ind         as integer                           no-undo.
def var l-letra       AS LOG                               no-undo.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

IF tt-param.acao = 1 THEN
   run pi-inicializar in h-acomp (input "Exporta‡Æo Carac. Tec. Item").
ELSE
   run pi-inicializar in h-acomp (input "Atualiza‡Æo Carac. Tec. Item").

EMPTY TEMP-TABLE tt-item.
EMPTY TEMP-TABLE tt-erro.

IF tt-param.acao = 1 THEN DO: /* Exporta‡Æo */

   FOR EACH item WHERE 
            item.cd-folh-item = "CADITEM"            AND 
            item.it-codigo   >= tt-param.item-ini    AND 
            item.it-codigo   <= tt-param.item-fim    AND 
            ITEM.ge-codigo   >= tt-param.ge-cod-ini  AND
            ITEM.ge-codigo   <= tt-param.ge-cod-fim  AND
            ITEM.fm-codigo   >= tt-param.fam-cod-ini AND
            ITEM.fm-codigo   <= tt-param.fam-cod-fim AND
            ITEM.fm-cod-com  >= tt-param.fam-com-ini AND
            ITEM.fm-cod-com  <= tt-param.fam-com-fim NO-LOCK:    

       run pi-acompanhar in h-acomp (input "Processando Item: " + ITEM.it-codigo).

       CREATE tt-item.
       ASSIGN tt-item.it-codigo = ITEM.it-codigo
              tt-item.descricao = ITEM.desc-item.

       FOR EACH it-carac-tec WHERE
                it-carac-tec.it-codigo = item.it-codigo AND
                it-carac-tec.cd-folha = "CADITEM" NO-LOCK:

           IF it-carac-tec.cd-comp = "10" THEN
              ASSIGN tt-item.desc-etiq = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "20" THEN
              ASSIGN tt-item.desc-web = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "25" THEN
              ASSIGN tt-item.divisao = it-carac-tec.observacao.          

           IF it-carac-tec.cd-comp = "30" THEN
              ASSIGN tt-item.tp-produto = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "40" THEN
              ASSIGN tt-item.categ-conv = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "45" THEN
              ASSIGN tt-item.sazonalidade = it-carac-tec.observacao.                   

           IF it-carac-tec.cd-comp = "60" THEN
              ASSIGN tt-item.sub-gr-com = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "65" THEN
              ASSIGN tt-item.sigla-pdv = it-carac-tec.observacao. 

           IF it-carac-tec.cd-comp = "70" THEN
              ASSIGN tt-item.gera-pedido = it-carac-tec.observacao. 

           IF it-carac-tec.cd-comp = "90" THEN
              ASSIGN tt-item.lista-prod = substr(it-carac-tec.observacao,3,10).                

           IF it-carac-tec.cd-comp = "100" THEN
              ASSIGN tt-item.prod-fraciona = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "110" THEN
              ASSIGN tt-item.qtde-lastro = it-carac-tec.vl-result.

           IF it-carac-tec.cd-comp = "120" THEN
              ASSIGN tt-item.camada-lastro = it-carac-tec.vl-result.         

           IF it-carac-tec.cd-comp = "140" THEN
              ASSIGN tt-item.publico-alvo = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "150" THEN
              ASSIGN tt-item.crm-venda = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "170" THEN
              ASSIGN tt-item.prod-monit = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "180" THEN
              ASSIGN tt-item.tarjado = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "190" THEN
              ASSIGN tt-item.sngpc  = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "200" THEN 
              ASSIGN tt-item.portaria = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "210" THEN
              ASSIGN tt-item.apres-produto = it-carac-tec.vl-result.

           IF it-carac-tec.cd-comp = "225" THEN
              ASSIGN tt-item.dosagem-apres = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "230" THEN
              ASSIGN tt-item.concentracao = it-carac-tec.vl-result.

           IF it-carac-tec.cd-comp = "240" THEN
              ASSIGN tt-item.dosagem-conc = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "250" THEN
              ASSIGN tt-item.nome-comerc = it-carac-tec.observacao. 

           IF it-carac-tec.cd-comp = "255" THEN
              ASSIGN tt-item.data-sngpc = it-carac-tec.dt-result. 

           IF it-carac-tec.cd-comp = "260" THEN
              ASSIGN tt-item.csta = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "270" THEN
              ASSIGN tt-item.unid-medida = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "280" THEN
              ASSIGN tt-item.exc-pis-cof-ncm = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "290" THEN
              ASSIGN tt-item.tributa-pis = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "300" THEN
              ASSIGN tt-item.tributa-cofins = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "310" THEN
              ASSIGN tt-item.class-medic = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "330" THEN
              ASSIGN tt-item.utiliz-pauta = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "340" THEN
              ASSIGN tt-item.valor-pauta = string(it-carac-tec.vl-result,"->>>>>>>>,>>9.9999").

           IF it-carac-tec.cd-comp = "350" THEN
              ASSIGN tt-item.emite-etiq = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "360" THEN
              ASSIGN tt-item.pbm = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "370" THEN
              ASSIGN tt-item.cesta-basica = it-carac-tec.observacao.  

           IF it-carac-tec.cd-comp = "380" THEN
              ASSIGN tt-item.repos-pbm = it-carac-tec.observacao.

           IF it-carac-tec.cd-comp = "390" THEN
              ASSIGN tt-item.qtde-emb = it-carac-tec.observacao.          

           IF it-carac-tec.cd-comp = "400" THEN
              ASSIGN tt-item.circ-depos = it-carac-tec.observacao.  

           IF it-carac-tec.cd-comp = "410" THEN
              ASSIGN tt-item.ac-devol = it-carac-tec.observacao.     

           IF it-carac-tec.cd-comp = "420" THEN
              ASSIGN tt-item.mercadologica = it-carac-tec.observacao.          

           IF it-carac-tec.cd-comp = "430" THEN 
              ASSIGN tt-item.reg-min-saude = it-carac-tec.observacao.
       END.
   end.

   OUTPUT TO VALUE(tt-param.arq-saida) CONVERT TARGET "iso8859-1".

   PUT "Item;Descri‡Æo;Descri‡Æo Etiqueta;Descri‡Æo Web;DivisÆo;Tipo Produto;Categoria Convˆnio;Sazonalidade;Sub Grupo Comercial;Sigla PDV;Gera Pedido;Lista Produto;Produto Fracionado;Qtde. Lastro;Qtde. Camada Palet;P£blico Alvo;Informa CRM Venda;Produto Monitorado;Tarjado;SNGPC;Portaria;Apresenta‡Æo Produto;Dosagem Apresenta‡Æo;Concentra‡Æo;Dosagem Concentra‡Æo;Nome Comercial;Data SNGPC;CSTA;Unidade Medida;Exce‡Æo PIS COFINS NCM;Tributa PIS;Tributa COFINS;Classifica‡Æo;Utiliza Pauta;Valor Pauta;Emite Etiqueta;PBM;Cesta B sica;Reposi‡Æo PBM;Qtde. Embarque;Circula Dep¢sito;Aceita Devolu‡Æo;Mercadol¢gica;Reg. Min. Sa£de" skip.

   FOR EACH tt-item:

       run pi-acompanhar in h-acomp (input "Exportando Item: " + tt-item.it-codigo).

       EXPORT DELIMITER ";" tt-item.
   END.

   OUTPUT CLOSE.

END.

IF tt-param.acao = 2 THEN DO: /* Importa‡Æo */
        
    INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
     
    ASSIGN i-cont = 0.
    
    REPEAT:  
       CREATE tt-item.
       IMPORT DELIMITER ";" tt-item NO-ERROR.
    
       assign i-cont = i-cont + 1.
       run pi-acompanhar in h-acomp (input "Importando Planilha: " + string(i-cont,">>>,>>>,>>9")).
    
    END. 

    FOR FIRST tt-item WHERE 
              tt-item.it-codigo = "Item":
    END.
    IF AVAIL tt-item THEN 
       DELETE tt-item.
        
    INPUT CLOSE.
      
    ASSIGN i-cont = 0.
                                                                                                   
    for each tt-item WHERE tt-item.it-codigo <> "":
        FIND FIRST ITEM WHERE
                   ITEM.it-codigo = tt-item.it-codigo NO-ERROR.
        IF NOT AVAIL ITEM THEN DO:
           CREATE tt-erro.
           ASSIGN tt-erro.it-codigo = tt-item.it-codigo
                  tt-erro.desc-item = substr(tt-item.descricao,1,60)
                  tt-erro.desc-erro = "Item nÆo cadastrado no Datasul".
           DELETE tt-item.
           NEXT.
        END.
    
        ASSIGN ITEM.desc-item   = substr(tt-item.descricao,1,60)
               ITEM.descricao-1 = SUBSTR(tt-item.descricao,1,18)
               ITEM.descricao-2 = SUBSTR(tt-item.descricao,19,18)
               i-cont           = i-cont + 1.
    
        FOR EACH it-carac-tec WHERE 
                 it-carac-tec.it-codigo = ITEM.it-codigo AND
                 it-carac-tec.cd-folha  = "CADITEM":
    
            run pi-acompanhar in h-acomp (input "Atualizando Item: " + ITEM.it-codigo + " - " + string(i-cont,">>>,>>>,>>9")).
    
            IF it-carac-tec.cd-comp = "10" THEN
               ASSIGN it-carac-tec.observacao = substr(tt-item.desc-etiq,1,40).                     
    
            IF it-carac-tec.cd-comp = "20" THEN                                                                     
               ASSIGN it-carac-tec.observacao = substr(tt-item.desc-web,1,40).                                        
    
            IF it-carac-tec.cd-comp = "25" THEN DO:        
               FIND FIRST c-tab-res WHERE
                          c-tab-res.nr-tabela = 25 AND
                          c-tab-res.descricao BEGINS SUBSTR(tt-item.divisao,1,3) NO-LOCK NO-ERROR.
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
                          c-tab-res.descricao BEGINS SUBSTR(tt-item.tp-produto,1,1) NO-LOCK NO-ERROR.
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
               FIND FIRST c-tab-res WHERE
                          c-tab-res.nr-tabela = 60 AND
                          c-tab-res.descricao BEGINS SUBSTR(tt-item.sub-gr-com,1,3) NO-LOCK NO-ERROR.
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
               IF tt-item.lista-prod MATCHES "*NEUTR*" THEN
                  ASSIGN c-lista = "N".
               IF tt-item.lista-prod MATCHES "*NEGATIV*" THEN
                  ASSIGN c-lista = "-".
               IF tt-item.lista-prod MATCHES "*OUTR*" THEN
                  ASSIGN c-lista = "O".
               IF tt-item.lista-prod MATCHES "*POSIT*" THEN
                  ASSIGN c-lista = "+".
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
                          c-tab-res.descricao MATCHES "*" + substr(tt-item.portaria,1,3) + "*" NO-LOCK NO-ERROR.
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
    
    ASSIGN i-cont = 0.

    for each tt-item WHERE tt-item.it-codigo <> "":
    
        ASSIGN i-cont = i-cont + 1.

        run pi-acompanhar in h-acomp (input "Gerando Integra‡Æo: " + tt-item.it-codigo + " - " + string(i-cont,">>>,>>>,>>9")).
    
        ASSIGN l-letra = NO.
        do i-ind = 1 to 16:
           if LOOKUP(SUBSTRING(tt-item.it-codigo,i-ind,1),"A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,-,.") > 0 then
              ASSIGN l-letra = YES.
        end.
        IF l-letra = YES THEN DO:
           CREATE tt-erro.
           ASSIGN tt-erro.it-codigo = tt-item.it-codigo
                  tt-erro.desc-item = substr(tt-item.descricao,1,60)
                  tt-erro.desc-erro = "Item nÆo integrado no Sysfarma/PRS por possuir letras no c¢digo".
           DELETE tt-item.
           NEXT.
        END.

        FIND FIRST ITEM WHERE
                   ITEM.it-codigo = tt-item.it-codigo NO-LOCK NO-ERROR.
    
        ASSIGN i-seq-int-ds-item = NEXT-VALUE(seq-int-ds-item). /* Prepara‡Æo para integra‡Æo com Procfit */
    
        CREATE int-ds-item.
        ASSIGN int-ds-item.tipo-movto                 = 2 /* Altera‡Æo */                 
               int-ds-item.dt-geracao                 = TODAY
               int-ds-item.hr-geracao                 = STRING(TIME,"hh:mm:ss") 
               int-ds-item.cod-usuario                = c-seg-usuario
               int-ds-item.situacao                   = 1 /* Pendente */
               int-ds-item.pro_codigo_n               = int(item.it-codigo) 
               int-ds-item.pro_descricaocupomfiscal_s = item.desc-item 
               int-ds-item.pro_datacadastro_d         = item.data-implant
               int-ds-item.pro_ncm_s                  = substr(item.class-fiscal,1,8)
               int-ds-item.pro_grupocomercial_n       = INT(item.fm-cod-com)
               int-ds-item.id_sequencial              = i-seq-int-ds-item. /* Prepara‡Æo para integra‡Æo com Procfit */
        
        FIND FIRST int-ds-ext-item WHERE
                   int-ds-ext-item.it-codigo = item.it-codigo NO-LOCK NO-ERROR.
        IF AVAIL int-ds-ext-item THEN DO:
           ASSIGN int-ds-item.pro_ncmipi_n = int-ds-ext-item.ncmipi.
        END.
        
        /* Atualiza‡Æo da tabela de integra‡Æo Datasul -> Sysfarma */
        /*           C¢digos de Barra dos Itens - EAN              */  
        
        FOR EACH int-ds-ean-item WHERE
                 int-ds-ean-item.it-codigo = item.it-codigo NO-LOCK:
        
            CREATE int-ds-item-compl.
            ASSIGN int-ds-item-compl.tipo-movto          = 2 /* Altera‡Æo */
                   int-ds-item-compl.dt-geracao          = TODAY
                   int-ds-item-compl.hr-geracao          = STRING(TIME,"hh:mm:ss") 
                   int-ds-item-compl.cod-usuario         = c-seg-usuario
                   int-ds-item-compl.situacao            = 1 /* Pendente */
                   int-ds-item-compl.cba-produto-n       = INT(int-ds-ean-item.it-codigo)        
                   int-ds-item-compl.cba-ean-n           = int-ds-ean-item.codigo-ean          
                   int-ds-item-compl.cba-lotemultiplo-n  = int-ds-ean-item.lote-multiplo       
                   int-ds-item-compl.cba-altura-n        = int-ds-ean-item.altura              
                   int-ds-item-compl.cba-largura-n       = int-ds-ean-item.largura             
                   int-ds-item-compl.cba-profundidade-n  = int-ds-ean-item.profundidade        
                   int-ds-item-compl.cba-peso-n          = int-ds-ean-item.peso                
                   int-ds-item-compl.cba-data-cadastro-d = int-ds-ean-item.data-cadastro       
                   int-ds-item-compl.cba-principal-s     = IF int-ds-ean-item.principal = YES THEN
                                                              "S"
                                                           ELSE 
                                                              "N"
                   int-ds-item-compl.id_cabecalho        = i-seq-int-ds-item
                   int-ds-item-compl.id_sequencial       = NEXT-VALUE(seq-int-ds-item-compl). /* Prepara‡Æo para integra‡Æo com Procfit */
        END.
        
        IF item.cd-folh-item = "CADITEM" THEN DO:
           FOR EACH it-carac-tec WHERE
                    it-carac-tec.it-codigo = item.it-codigo AND
                    it-carac-tec.cd-folha = "CADITEM" NO-LOCK:
           
               IF it-carac-tec.cd-comp = "10" THEN
                  ASSIGN int-ds-item.pro_descricaoetiqueta_s = substr(it-carac-tec.observacao,1,30).
           
               IF it-carac-tec.cd-comp = "20" THEN
                  ASSIGN int-ds-item.pro_descricaoweb_s = it-carac-tec.observacao.
               
               IF it-carac-tec.cd-comp = "25" THEN
                  ASSIGN int-ds-item.pro_divisao_n = INT(substr(it-carac-tec.observacao,1,3)).          
           
               IF it-carac-tec.cd-comp = "30" THEN
                  ASSIGN int-ds-item.pro_tipoproduto_n = INT(substr(it-carac-tec.observacao,1,1)).
           
               IF it-carac-tec.cd-comp = "40" THEN
                  ASSIGN int-ds-item.pro_categoriaconvenio_n = INT(substr(it-carac-tec.observacao,1,2)).
               
               IF it-carac-tec.cd-comp = "45" THEN
                  ASSIGN int-ds-item.pro_sazonalidade_n = INT(substr(it-carac-tec.observacao,1,1)).                   
           
               IF it-carac-tec.cd-comp = "60" THEN
                  ASSIGN int-ds-item.pro_subgrupocomercial_n = INT(substr(it-carac-tec.observacao,1,3)).
           
               IF it-carac-tec.cd-comp = "65" THEN
                  ASSIGN int-ds-item.pro_sigla_pdv_s = substr(it-carac-tec.observacao,1,15). 
           
               IF it-carac-tec.cd-comp = "70" THEN
                  ASSIGN int-ds-item.pro_gerapedido_s = substr(it-carac-tec.observacao,1,1). 
           
               IF item.cod-obsoleto = 1 THEN
                  ASSIGN int-ds-item.pro_situacaoproduto_s = "A".
        
               IF item.cod-obsoleto = 2 OR item.cod-obsoleto = 3 THEN
                  ASSIGN int-ds-item.pro_situacaoproduto_s = "E".
        
               IF item.cod-obsoleto = 4 THEN
                  ASSIGN int-ds-item.pro_situacaoproduto_s = "I".
           
               IF it-carac-tec.cd-comp = "90" THEN
                  ASSIGN int-ds-item.pro_lista_s = substr(it-carac-tec.observacao,1,1).                
           
               IF it-carac-tec.cd-comp = "100" THEN
                  ASSIGN int-ds-item.pro_fracionado_s = substr(it-carac-tec.observacao,1,1).
           
               IF it-carac-tec.cd-comp = "110" THEN
                  ASSIGN int-ds-item.pro_lastro_n = it-carac-tec.vl-result.
           
               IF it-carac-tec.cd-comp = "120" THEN
                  ASSIGN int-ds-item.pro_camada_n = it-carac-tec.vl-result.         
           
               IF it-carac-tec.cd-comp = "140" THEN
                  ASSIGN int-ds-item.pro_publicoalvo_n = INT(substr(it-carac-tec.observacao,1,1)).
           
               IF it-carac-tec.cd-comp = "150" THEN
                  ASSIGN int-ds-item.pro_informaprescricao_s = substr(it-carac-tec.observacao,1,1).
               
               IF it-carac-tec.cd-comp = "170" THEN
                  ASSIGN int-ds-item.pro_monitorado_s = substr(it-carac-tec.observacao,1,1).
           
               IF it-carac-tec.cd-comp = "180" THEN
                  ASSIGN int-ds-item.pro_tarjado_s = substr(it-carac-tec.observacao,1,1).
           
               IF it-carac-tec.cd-comp = "190" THEN
                  ASSIGN int-ds-item.pro_sngpc_n  = INT(substr(it-carac-tec.observacao,1,1)).
           
               IF it-carac-tec.cd-comp = "200" THEN DO:
                  IF substr(it-carac-tec.observacao,1,2) = "  " THEN
                     ASSIGN int-ds-item.pro_portaria_s = "".
                  ELSE
                     ASSIGN int-ds-item.pro_portaria_s = substr(it-carac-tec.observacao,1,2).
               END.
        
               IF it-carac-tec.cd-comp = "210" THEN
                  ASSIGN int-ds-item.pro_apresentacao_n = it-carac-tec.vl-result.
           
               IF it-carac-tec.cd-comp = "225" THEN
                  ASSIGN int-ds-item.pro_dosagemapresentacao_n = INT(substr(it-carac-tec.observacao,1,2)).
           
               IF it-carac-tec.cd-comp = "230" THEN
                  ASSIGN int-ds-item.pro_concentracao_n = it-carac-tec.vl-result.
           
               IF it-carac-tec.cd-comp = "240" THEN
                  ASSIGN int-ds-item.pro_dosagemconcentracao_n = INT(substr(it-carac-tec.observacao,1,2)).
           
               IF it-carac-tec.cd-comp = "250" THEN
                  ASSIGN int-ds-item.pro_nomecomercial_s = it-carac-tec.observacao. 
           
               IF it-carac-tec.cd-comp = "255" THEN
                  ASSIGN int-ds-item.pro_datasngpc_d = it-carac-tec.dt-result. 
                          
               IF it-carac-tec.cd-comp = "260" THEN
                  ASSIGN int-ds-item.pro_csta_n = INT(substr(it-carac-tec.observacao,1,1)).
           
               IF it-carac-tec.cd-comp = "270" THEN
                  ASSIGN int-ds-item.pro_unidademedidamedicamento_n = INT(substr(it-carac-tec.observacao,1,1)).
                
               IF it-carac-tec.cd-comp = "280" THEN
                  ASSIGN int-ds-item.pro_excecaopiscofinsncm_s = substr(it-carac-tec.observacao,1,1).
           
               IF it-carac-tec.cd-comp = "290" THEN
                  ASSIGN int-ds-item.pro_tributapis_s = substr(it-carac-tec.observacao,1,1).
           
               IF it-carac-tec.cd-comp = "300" THEN
                  ASSIGN int-ds-item.pro_tributacofins_s = substr(it-carac-tec.observacao,1,1).
           
               IF it-carac-tec.cd-comp = "310" THEN
                  ASSIGN int-ds-item.pro_classificacaomedicamento_n = INT(substr(it-carac-tec.observacao,1,1)).
               
               IF it-carac-tec.cd-comp = "330" THEN
                  ASSIGN int-ds-item.pro_utilizapautafiscal_s = substr(it-carac-tec.observacao,1,1).
           
               IF it-carac-tec.cd-comp = "340" THEN
                  ASSIGN int-ds-item.pro_valorpautafiscal_n = it-carac-tec.vl-result.
           
               IF it-carac-tec.cd-comp = "350" THEN
                  ASSIGN int-ds-item.pro_emiteetiqueta_s = substr(it-carac-tec.observacao,1,1).
           
               IF it-carac-tec.cd-comp = "360" THEN
                  ASSIGN int-ds-item.pro_pbm_s = substr(it-carac-tec.observacao,1,1).
           
               IF it-carac-tec.cd-comp = "370" THEN
                  ASSIGN int-ds-item.pro_cestabasica_s = substr(it-carac-tec.observacao,1,1).  
           
               IF it-carac-tec.cd-comp = "380" THEN
                  ASSIGN int-ds-item.pro_reposicaopbm_s = substr(it-carac-tec.observacao,1,1).
                         
               IF it-carac-tec.cd-comp = "390" THEN
                  ASSIGN int-ds-item.pro_quantidadeembarque_n = DEC(it-carac-tec.observacao).          
               
               IF it-carac-tec.cd-comp = "400" THEN
                  ASSIGN int-ds-item.pro_circuladeposito_s = substr(it-carac-tec.observacao,1,1).  
           
               IF it-carac-tec.cd-comp = "410" THEN
                  ASSIGN int-ds-item.pro_aceitadevolucao_s = substr(it-carac-tec.observacao,1,1).     
               
               IF it-carac-tec.cd-comp = "420" THEN
                  ASSIGN int-ds-item.pro_mercadologica_s = substr(it-carac-tec.observacao,1,2).          
        
               IF it-carac-tec.cd-comp = "430" THEN 
                  ASSIGN int-ds-item.pro_registroms_n = DEC(it-carac-tec.observacao).
           END.
       END.
    END.   
END.

{include/i-rpvar.i}
    
{include/i-rpout.i &tofile=tt-param.arq-destino}
    
IF tt-param.acao = 1 THEN
   assign c-titulo-relat = "Exporta‡Æo Carac. T‚cnicas dos Itens"
          c-programa     = "INT070RP".
ELSE
   assign c-titulo-relat = "Atualiza‡Æo Carac. T‚cnicas dos Itens"
          c-programa     = "INT070RP".
              
{include/i-rpcab.i}

view frame f-cabec.
    
IF tt-param.acao = 1 THEN DO:
   PUT SKIP(3)
       "Arquivo Gerado: " tt-param.arq-saida FORMAT "X(60)".
END.
ELSE DO:
    ASSIGN l-erro = NO.
    for each tt-erro USE-INDEX codigo WHERE tt-erro.it-codigo <> "":
        disp tt-erro with width 300 no-box stream-io down frame f-erros.
        ASSIGN l-erro = YES.
    end.
    IF l-erro = NO THEN
       PUT "Caracter¡sticas T‚cnicas atualizadas com sucesso.".
END.

view frame f-rodape.    
    
{include/i-rpclo.i}

run pi-finalizar in h-acomp.



