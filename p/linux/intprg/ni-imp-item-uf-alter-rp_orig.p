/********************************************************************************
**
**  Programa - NI-IMP-ITEM-UF-RP.P - Importa‡Æo Item UF
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-ITEM-UF-RP 2.00.00.000 } 

DISABLE TRIGGERS FOR LOAD OF item-uf.

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

DEF TEMP-TABLE tt-item-uf
    FIELD it-codigo                LIKE item.class-fiscal 
    FIELD cod-estado-orig          LIKE item-uf.cod-estado-orig            
    FIELD estado                   LIKE item-uf.estado       
    FIELD per-sub-tri              LIKE item-uf.per-sub-tri
    FIELD perc-red-sub             LIKE item-uf.perc-red-sub   
    FIELD val-icms-est-subt        LIKE item-uf.val-icms-est-subt
    FIELD val-perc-reduc-tab-pauta LIKE item-uf.val-perc-reduc-tab-pauta.

DEF TEMP-TABLE tt-erro
    FIELD cod-erro  AS CHAR FORMAT "x(12)" 
    FIELD desc-erro AS CHAR FORMAT "x(50)".

DEF VAR i-cont        AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp       AS HANDLE                   NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo Item UF").

EMPTY TEMP-TABLE tt-item-uf.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-item-uf.
   IMPORT DELIMITER ";" tt-item-uf.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-item-uf: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                               
for each tt-item-uf:

    assign i-cont = i-cont + 1.

    run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-item-uf.it-codigo) + " - " + string(i-cont)).

    IF tt-item-uf.cod-estado-orig <> "UF" THEN DO:
       FIND FIRST item-uf WHERE 
                  item-uf.it-codigo       = tt-item-uf.it-codigo AND
                  item-uf.cod-estado-orig = tt-item-uf.cod-estado-orig AND
                  item-uf.estado          = tt-item-uf.estado AND
                  item-uf.cod-estab       = "973" NO-ERROR.
       IF NOT AVAIL item-uf THEN DO:
          CREATE item-uf.
          ASSIGN item-uf.cod-estab       = "973"
                 item-uf.it-codigo       = tt-item-uf.it-codigo
                 item-uf.cod-estado-orig = tt-item-uf.cod-estado-orig
                 item-uf.estado          = tt-item-uf.estado.
       END.
       ASSIGN item-uf.per-sub-tri              = tt-item-uf.per-sub-tri
              item-uf.perc-red-sub             = tt-item-uf.perc-red-sub
              item-uf.val-icms-est-subt        = tt-item-uf.val-icms-est-subt 
              item-uf.val-perc-reduc-tab-pauta = tt-item-uf.val-perc-reduc-tab-pauta
              item-uf.dec-1                    = tt-item-uf.val-icms-est-subt.
    END.
    ELSE DO:
       FOR EACH unid-feder WHERE
                unid-feder.pais = "Brasil" NO-LOCK:
           IF unid-feder.estado = tt-item-uf.estado THEN
              NEXT.
           FIND FIRST item-uf WHERE 
                      item-uf.it-codigo       = tt-item-uf.it-codigo AND
                      item-uf.cod-estado-orig = unid-feder.estado AND
                      item-uf.estado          = tt-item-uf.estado AND
                      item-uf.cod-estab       = "973" NO-ERROR.
           IF NOT AVAIL item-uf THEN DO:
              CREATE item-uf.
              ASSIGN item-uf.cod-estab       = "973" 
                     item-uf.it-codigo       = tt-item-uf.it-codigo
                     item-uf.cod-estado-orig = unid-feder.estado
                     item-uf.estado          = tt-item-uf.estado.
           END.
           ASSIGN item-uf.per-sub-tri              = tt-item-uf.per-sub-tri
                  item-uf.perc-red-sub             = tt-item-uf.perc-red-sub
                  item-uf.val-icms-est-subt        = tt-item-uf.val-icms-est-subt 
                  item-uf.val-perc-reduc-tab-pauta = tt-item-uf.val-perc-reduc-tab-pauta
                  item-uf.dec-1                    = tt-item-uf.val-icms-est-subt.
       END.
    END.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importa‡Æo Item UF"
       c-programa     = "NI-IMP-ITEM-UF-RP".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro BY tt-erro.cod-erro:
    disp tt-erro.cod-erro  COLUMN-LABEL "Codigo"
         tt-erro.desc-erro COLUMN-LABEL "Descri‡Æo Erro"
         with width 132 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}





