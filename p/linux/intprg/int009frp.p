/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i int009frp 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: int009frp
**
**       DATA....: 03/2016
**
**       OBJETIVO: Relatorio Ajustes de estoques  - Visualizações e atualizações dos 
**                 Cenarios de estoque     
**
**       VERSAO..: 1.00.000
** 
******************************************************************************/
{include/i-rpvar.i}

{cep/ceapi001.i}    /* Definicao de temp-table do movto-estoq */
{cdp/cd0666.i}      /* Definicao da temp-table de erros */

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
    FIELD arq-modelo       AS CHAR
    FIELD cod-cenario-ini  LIKE int-ds-cenario.cod-cenario
    FIELD cod-cenario-fin  LIKE int-ds-cenario.cod-cenario
    FIELD cod-estab-ini    LIKE estabelec.cod-estabel 
    FIELD cod-estab-fin    LIKE estabelec.cod-estabel
    FIELD tipo-relat       AS INTEGER.

define temp-table tt-digita LIKE int-ds-cenar-estoq
FIELD r-rowid   AS ROWID.

DEFINE TEMP-TABLE tt-estab 
 FIELD cod-estabel LIKE estabelec.cod-estabel 
INDEX idx_estab IS PRIMARY cod-estabel.

DEFINE TEMP-TABLE tt-depos 
FIELD cod-depos LIKE deposito.cod-depos.

define temp-table tt-estab-depos
FIELD cod-estabel LIKE estabelec.cod-estabel 
FIELD cod-depos LIKE deposito.cod-depos.

DEFINE TEMP-TABLE tt-cenar-estoq LIKE int-ds-cenar-estoq
FIELD desc-item LIKE ITEM.desc-item
FIELD r-rowid   AS ROWID
FIELD mensagem  AS CHAR.
                   
def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

for each tt-raw-digita:
    create tt-digita.
    raw-transfer tt-raw-digita.raw-digita to tt-digita.
end.

DEF VAR c-nome-relat    AS CHAR NO-UNDO.
DEF VAR c-cabec         AS CHAR NO-UNDO.

DEF VAR c-estab-cd      LIKE estabelec.cod-estabel NO-UNDO.
DEF VAR d-tot-saldo     LIKE saldo-estoq.qtidade-atu NO-UNDO.
DEF VAR i-cont          AS INT           NO-UNDO.
DEF VAR c-depositos     AS CHAR          NO-UNDO.
DEF VAR l-tem-saldo     AS LOGICAL       NO-UNDO.

def var h-acomp            as handle     no-undo.
DEF VAR chExcelApplication AS COM-HANDLE NO-UNDO.
DEF VAR chexcel-modelo     AS COM-HANDLE NO-UNDO.
DEF VAR c-arq-xls          AS CHAR       NO-UNDO.
DEF VAR c-dir-modelo       AS CHAR       NO-UNDO.
DEF VAR i-empresa          LIKE conta-contab.ep-codigo       NO-UNDO.
DEF VAR d-vl-cmv           LIKE int-ds-saldo-estoq.valor-cmv NO-UNDO.

def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first mgcad.empresa where 
                 empresa.ep-codigo = param-global.empresa-prin no-lock no-error.
                    
find first tt-param no-lock no-error.

{include/i-rpc255.i}
{include/i-rpout.i}

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Ajustes_do_estoque  * L}
run pi-inicializar in h-acomp (input return-value).

EMPTY TEMP-TABLE tt-estab.

IF tt-param.tipo-relat = 1 /* Ultima conferˆncia */
THEN DO:

   ASSIGN c-titulo-relat =  "éltima Conferˆncia cen rio " +  tt-param.cod-cenario-ini
          c-nome-relat   =  "Int009f-Ultima-Conferˆncia". 
           
   FOR EACH int-ds-cenar-estoq NO-LOCK WHERE
            int-ds-cenar-estoq.cod-cenario  = tt-param.cod-cenario-ini AND
            int-ds-cenar-estoq.cod-estabel >= tt-param.cod-estab-ini   AND 
            int-ds-cenar-estoq.cod-estabel <= tt-param.cod-estab-fin   AND
            int-ds-cenar-estoq.situacao    = 1:   /* Pendente */ 
                                       
      RUN pi-gera-ultima-conferencia.                                        
                            
   END.
     
END.
ELSE IF tt-param.tipo-relat = 2 /* Verificar Diferen‡as */ 
THEN DO:

    ASSIGN c-titulo-relat =  "Verificar Diferen‡as cen rio " +  tt-param.cod-cenario-ini
           c-nome-relat   =  "Int009f-Verificar-Diferen‡as".


    FIND FIRST int-ds-cenario NO-LOCK WHERE 
               int-ds-cenario.cod-cenario = tt-param.cod-cenario-ini NO-ERROR.
    IF AVAIL int-ds-cenario 
    THEN DO:     
        
        RUN pi-verifica-diferenca.
       
    END.


END.    
ELSE IF tt-param.tipo-relat = 3 /* Atualizar Diferen‡as */ 
THEN DO:
      
    ASSIGN c-titulo-relat =  "Atualizar Diferen‡as cen rio " +  tt-param.cod-cenario-ini
           c-nome-relat   =  "Int009f-Atualizar-Diferen‡as".

    FIND FIRST int-ds-cenario NO-LOCK WHERE 
               int-ds-cenario.cod-cenario = tt-param.cod-cenario-ini NO-ERROR.
    IF AVAIL int-ds-cenario 
    THEN DO:  

        FOR EACH int-ds-cenar-estoq EXCLUSIVE-LOCK WHERE
                 int-ds-cenar-estoq.cod-cenario = int-ds-cenario.cod-cenario:

            DELETE int-ds-cenar-estoq.
                  
        END.

        RUN pi-verifica-diferenca.
        
        FOR EACH tt-cenar-estoq:

            CREATE int-ds-cenar-estoq.
            BUFFER-COPY  tt-cenar-estoq TO int-ds-cenar-estoq.
                  
        END.

    END.
        
END.
ELSE IF tt-param.tipo-relat = 4  /* Gerar movimentos de Estoque */
THEN DO:

    ASSIGN c-titulo-relat =  "Atualizar Estoque DATASUL"
           c-nome-relat   =  "Int009f-Atualizar-Estoque".
     
    for each tt-raw-digita:
       create tt-digita.
       raw-transfer tt-raw-digita.raw-digita to tt-digita.

       CREATE tt-cenar-estoq.
       BUFFER-COPY tt-digita TO tt-cenar-estoq.
       ASSIGN tt-cenar-estoq.r-rowid = tt-digita.r-rowid.
       
       FIND FIRST ITEM NO-LOCK WHERE
                  ITEM.it-codigo =  tt-digita.it-codigo NO-ERROR.
       IF AVAIL ITEM THEN
          ASSIGN tt-cenar-estoq.desc-item = ITEM.desc-item.


       RUN pi-gera-movto.
      
    end.

END.

VIEW FRAME f-cabec-255.
VIEW FRAME f-rodape-255.

FOR EACH tt-cenar-estoq
    BREAK BY tt-cenar-estoq.cod-estabel
          BY tt-cenar-estoq.fm-codigo
          BY tt-cenar-estoq.ge-codigo 
          BY tt-cenar-estoq.it-codigo:

    DISP tt-cenar-estoq.cod-estabel    column-label "Estab" 
         tt-cenar-estoq.fm-codigo      column-label "Fam¡lia"
         tt-cenar-estoq.ge-codigo      column-label "Gr. Estoq"
         tt-cenar-estoq.it-codigo      column-label "Item"
         tt-cenar-estoq.desc-item      column-label "Descri‡Æo"
         tt-cenar-estoq.lote           column-label "Lote"
         tt-cenar-estoq.valor-unit     column-label "Valor Unit rio"
         tt-cenar-estoq.qtd-loja       column-label "Quant. Loja"   FORMAT "->>>>,>>>,>>9.99"
         tt-cenar-estoq.qtd-datasul    column-label "Quant Datasul" FORMAT "->>>>,>>>,>>9.99"
         tt-cenar-estoq.qtd-diferenca  column-label "Quant Dif."    FORMAT "->>>>,>>>,>>9.99"
         tt-cenar-estoq.valor-dif      column-label "Valor Dif."    FORMAT "->>>>,>>>,>>9.99"
         tt-cenar-estoq.mensagem       column-label "OBS"
         WITH WIDTH 333 STREAM-IO DOWN FRAME f-cenar.
    DOWN WITH FRAME f-cenar.

END.

{include/i-rpclo.i} 
run pi-finalizar in h-acomp.

RUN cdp/cd0666.w(INPUT TABLE tt-erro).

ASSIGN c-arq-xls = SESSION:TEMP-DIRECTORY + c-nome-relat + STRING(TODAY,"999999") + "-" + STRING(TIME) + ".xls"
       c-dir-modelo = tt-param.arq-modelo
       c-dir-modelo = REPLACE(tt-param.arq-modelo,"int009f-modelo.xls","").


return "OK":U.

PROCEDURE pi-gera-ultima-conferencia:   

                  
   RUN pi-acompanhar IN h-acomp(INPUT "Estab:" + int-ds-cenar-estoq.cod-estabel + " Item: " + int-ds-cenar-estoq.it-codigo). 
              
   CREATE tt-cenar-estoq.
   BUFFER-COPY int-ds-cenar-estoq TO tt-cenar-estoq.
    
   FIND FIRST ITEM NO-LOCK WHERE
              ITEM.it-codigo = int-ds-cenar-estoq.it-codigo NO-ERROR.
   IF AVAIL ITEM THEN
       ASSIGN tt-cenar-estoq.desc-item = ITEM.desc-item.
                             

END PROCEDURE.


PROCEDURE pi-verifica-diferenca:

    FOR EACH int-ds-cenar-estab NO-LOCK WHERE
             int-ds-cenar-estab.cod-cenario = int-ds-cenario.cod-cenario AND 
             int-ds-cenar-estab.cod-estabel >= tt-param.cod-estab-ini    AND     
             int-ds-cenar-estab.cod-estabel <= tt-param.cod-estab-fin , 
        EACH int-ds-saldo-estoq NO-LOCK  WHERE
             int-ds-saldo-estoq.cod-estabel = int-ds-cenar-estab.cod-estab,
        FIRST ITEM NO-LOCK WHERE
              ITEM.it-codigo = int-ds-saldo-estoq.it-codigo, 
        FIRST int-ds-cenar-fam NO-LOCK WHERE
              int-ds-cenar-fam.cod-cenario = int-ds-cenar-estab.cod-cenario AND  
              int-ds-cenar-fam.fm-codigo   = ITEM.fm-codigo,
        FIRST int-ds-cenar-grupo NO-LOCK WHERE
              int-ds-cenar-grupo.cod-cenario = int-ds-cenar-estab.cod-cenario AND  
              int-ds-cenar-grupo.ge-codigo   = ITEM.ge-codigo: 

        RUN pi-acompanhar IN h-acomp (INPUT "Estab: " + int-ds-cenar-estab.cod-estabel + "  Item : " + int-ds-saldo-estoq.it-codigo).
                                                          
            /* Saldo estoque calculado no totvs */
               
            ASSIGN d-tot-saldo = 0
                   d-vl-cmv    = int-ds-saldo-estoq.valor-cmv.

            FIND FIRST int-ds-saldo-totvs NO-LOCK WHERE
                       int-ds-saldo-totvs.cod-estabel = int-ds-saldo-estoq.cod-estabel AND   
                       int-ds-saldo-totvs.it-codigo   = int-ds-saldo-estoq.it-codigo   AND
                       int-ds-saldo-totvs.lote        = int-ds-saldo-estoq.lote NO-ERROR.
            IF AVAIL int-ds-saldo-totvs THEN
                 ASSIGN d-tot-saldo = int-ds-saldo-totvs.qtd-atual
                        d-vl-cmv    = int-ds-saldo-totvs.valor-cmv.
                                           
            /* Saldo do cenario j  atualizado no estoque */

            FIND FIRST int-ds-cenar-estoq NO-LOCK WHERE
                       int-ds-cenar-estoq.cod-cenario = int-ds-cenario.cod-cenario     AND 
                       int-ds-cenar-estoq.cod-estabel = int-ds-saldo-estoq.cod-estabel AND   
                       int-ds-cenar-estoq.it-codigo   = int-ds-saldo-estoq.it-codigo   AND
                       int-ds-cenar-estoq.lote        = int-ds-saldo-estoq.lote        AND 
                       int-ds-cenar-estoq.situacao    = 2 /* Atualizado no estoque */  NO-ERROR.
            IF AVAIL int-ds-cenar-estoq THEN DO:

                ASSIGN d-tot-saldo = d-tot-saldo + int-ds-cenar-estoq.qtd-diferenca.

            END.
                                                                      
            IF d-tot-saldo <> int-ds-saldo-estoq.qtd-atual 
            THEN DO:

               CREATE tt-cenar-estoq.
               ASSIGN tt-cenar-estoq.cod-cenario   = int-ds-cenario.cod-cenario
                      tt-cenar-estoq.cod-estabel   = int-ds-saldo-estoq.cod-estabel  
                      tt-cenar-estoq.fm-codigo     = int-ds-cenar-fam.fm-codigo
                      tt-cenar-estoq.ge-codigo     = int-ds-cenar-grupo.ge-codigo
                      tt-cenar-estoq.it-codigo     = int-ds-saldo-estoq.it-codigo
                      tt-cenar-estoq.desc-item     = ITEM.desc-item   
                      tt-cenar-estoq.lote          = int-ds-saldo-estoq.lote
                      tt-cenar-estoq.valor-unit    = d-vl-cmv
                      tt-cenar-estoq.qtd-loja      = int-ds-saldo-estoq.qtd-atual
                      tt-cenar-estoq.qtd-datasul   = d-tot-saldo
                      tt-cenar-estoq.qtd-diferenca = int-ds-saldo-estoq.qtd-atual - d-tot-saldo.

               IF tt-cenar-estoq.qtd-diferenca < 0 THEN
                   ASSIGN tt-cenar-estoq.qtd-diferenca = tt-cenar-estoq.qtd-diferenca * -1.
                                               

               ASSIGN tt-cenar-estoq.valor-dif = tt-cenar-estoq.qtd-diferenca * tt-cenar-estoq.valor-unit.

            END. 
                  
    END.
        
END PROCEDURE.

PROCEDURE pi-gera-movto:

  for each tt-movto:
      delete tt-movto.
  end.

  EMPTY TEMP-TABLE tt-erro.
      
  DO TRANS:
    
    create tt-movto.
    assign tt-movto.cod-versao-integ  = 1
           tt-movto.cod-estabel       = string(tt-cenar-estoq.cod-estabel,"999")
           tt-movto.cod-localiz       = ""
           tt-movto.lote              = IF tt-cenar-estoq.lote = "0" THEN "" ELSE tt-cenar-estoq.lote
           tt-movto.dt-vali-lote      = TODAY + 180 /* Ver como vai ficar com o BeltrÆo */
           tt-movto.cod-refer         = ""
           tt-movto.conta-contabil    = "91107002"   
           tt-movto.ct-codigo         = "91107002"            
           tt-movto.sc-codigo         = "" 
           tt-movto.it-codigo         = string(tt-cenar-estoq.it-codigo)
           tt-movto.nro-docto         = string("Ajuste Estoque") 
           tt-movto.serie             = "S"  
           tt-movto.esp-docto         = 6 /* DIV */
           tt-movto.cod-prog-orig     = "int009f".
         
    if tt-movto.cod-estabel = "973" then
      assign tt-movto.cod-depos = tt-movto.cod-estabel.
    else    
     assign tt-movto.cod-depos = "LOJ".  /* "ALM"  de-para */ 
    
    assign i-empresa = param-global.empresa-prin.

    &if defined (bf_dis_consiste_conta) &then

       find estabelec where
            estabelec.cod-estabel = param-estoq.estabel-pad no-lock no-error.

       run cdp/cd9970.p (input rowid(estabelec),
                         output i-empresa).
    &ENDIF

    find conta-contab NO-LOCK where 
         conta-contab.ep-codigo = i-empresa and 
         conta-contab.conta-contabil = param-estoq.ct-acerto no-error.
    if avail conta-contab then
       assign tt-movto.conta-contabil = param-estoq.conta-acerto   
              tt-movto.ct-codigo      = conta-contab.ct-codigo            
              tt-movto.sc-codigo      = conta-contab.sc-codigo.

    /* Sempre ira atualizar com a data da transa‡Æo */

    IF tt-cenar-estoq.qtd-diferenca > 0 THEN
       ASSIGN tt-movto.tipo-trans = 1.
    ELSE 
       ASSIGN tt-movto.tipo-trans = 2. 

    assign tt-movto.dt-trans           = TODAY
           tt-movto.quantidade         = tt-cenar-estoq.qtd-diferenca
           tt-movto.valor-mat-o[1]     = 0
           tt-movto.un                 = item.un.
    
    run cep/ceapi001.p (input-output table tt-movto,
                        input-output table tt-erro,
                        input NO).

    IF CAN-FIND (FIRST tt-erro) 
    THEN DO:
    
        FOR FIRST tt-erro:
           
            DISP tt-cenar-estoq.cod-estab    
                 tt-cenar-estoq.lote         
                 tt-cenar-estoq.it-codigo    
                 tt-cenar-estoq.qtd-diferenca
                 tt-erro.cd-erro
                 tt-erro.mensagem
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro. 
         
        end. 

        UNDO , NEXT.

    END.
    ELSE DO:    

        FIND FIRST int-ds-cenar-estoq EXCLUSIVE-LOCK WHERE
                   rowid(int-ds-cenar-estoq) = tt-cenar-estoq.r-rowid  NO-ERROR.
        IF AVAIL int-ds-cenar-estoq THEN DO:
        
          assign int-ds-cenar-estoq.situacao = 2. /* Atualizado Datasul */
                
          RELEASE int-ds-inventario.
           
          /* DISP tt-cenar-estoq.cod-estab    
               tt-cenar-estoq.lote         
               tt-cenar-estoq.it-codigo    
               tt-cenar-estoq.qtd-diferenca
               WITH WIDTH 333 STREAM-IO DOWN FRAME f-inv.
             DOWN WITH FRAME f-inv.  
             */
        END. 

    END.

  END.

END PROCEDURE.




