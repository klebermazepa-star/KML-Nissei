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
    field prod-fraciona   as char.

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

    FOR EACH int-ds-ean-item WHERE
             int-ds-ean-item.it-codigo = tt-item.it-codigo NO-LOCK:

        CREATE int-ds-item-compl.
        ASSIGN int-ds-item-compl.tipo-movto          = 2 /* Altera‡Æo */
               int-ds-item-compl.dt-geracao          = TODAY
               int-ds-item-compl.hr-geracao          = STRING(TIME,"hh:mm:ss") 
               int-ds-item-compl.cod-usuario         = "super"
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
                                                          "N".         
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





