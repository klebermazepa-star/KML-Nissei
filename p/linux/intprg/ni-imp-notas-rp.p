/********************************************************************************
**
**  Programa - NI-IMP-NOTAS-RP.P - Importa‡Æo Notas - Trocar a S‚rie
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-NOTAS 2.00.00.000 } 

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

DEF TEMP-TABLE tt-notas
    FIELD nr-nota  AS INT   
    FIELD serie    AS CHAR
    FIELD estab    AS CHAR.
                                             
DEF VAR i-cont      AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp     AS HANDLE                   NO-UNDO.
DEF VAR l-erro      AS LOGICAL                  NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo Notas").

EMPTY TEMP-TABLE tt-notas.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  

   CREATE tt-notas.
   IMPORT DELIMITER ";" tt-notas.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-notas: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                               
for each tt-notas:

    assign i-cont = i-cont + 1.

    run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-notas.nr-nota) + " - " + string(i-cont)).

    FOR EACH nota-fiscal WHERE
             int(nota-fiscal.nr-nota-fis) = tt-notas.nr-nota AND
             nota-fiscal.cod-estabel = tt-notas.estab   AND
             nota-fiscal.serie       = tt-notas.serie   query-tuning(no-lookahead):  
        FOR EACH fat-duplic WHERE
                 fat-duplic.nr-fatura   = nota-fiscal.nr-fatura   AND
                 fat-duplic.cod-estabel = nota-fiscal.cod-estabel AND
                 fat-duplic.serie       = nota-fiscal.serie query-tuning(no-lookahead):                                       
            ASSIGN fat-duplic.serie = "2".
        END.

        FOR EACH fat-repre WHERE
                 fat-repre.nr-fatura   = nota-fiscal.nr-fatura   AND
                 fat-repre.cod-estabel = nota-fiscal.cod-estabel AND
                 fat-repre.serie       = nota-fiscal.serie   query-tuning(no-lookahead):                                       
            ASSIGN fat-repre.serie = "2".
        END.

        ASSIGN nota-fiscal.serie = "2".
    END.

    FOR EACH it-nota-fisc WHERE
             int(it-nota-fisc.nr-nota-fis) = tt-notas.nr-nota AND
             it-nota-fisc.cod-estabel = tt-notas.estab   AND
             it-nota-fisc.serie       = tt-notas.serie   query-tuning(no-lookahead):                                       
        ASSIGN it-nota-fisc.serie = "2".
    END.

    for each cst-fat-duplic exclusive where 
             cst-fat-duplic.cod-estabel = tt-notas.estab and
             cst-fat-duplic.serie       = tt-notas.serie and
             int(cst-fat-duplic.nr-fatura)   = tt-notas.nr-nota query-tuning(no-lookahead):
        ASSIGN cst-fat-duplic.serie = "2".
    end.

    FOR EACH devol-cli WHERE
             int(devol-cli.nr-nota-fis) = tt-notas.nr-nota AND
             devol-cli.cod-estabel = tt-notas.estab   AND
             devol-cli.serie       = tt-notas.serie   query-tuning(no-lookahead):                                       
        ASSIGN devol-cli.serie = "2".
    END.

    FOR EACH nar-it-nota WHERE
             int(nar-it-nota.nr-nota-fis) = tt-notas.nr-nota AND
             nar-it-nota.cod-estabel = tt-notas.estab   AND
             nar-it-nota.serie       = tt-notas.serie   query-tuning(no-lookahead):                                       
        ASSIGN nar-it-nota.serie = "2".
    END.

    FOR EACH fat-ser-lote WHERE
             int(fat-ser-lote.nr-nota-fis) = tt-notas.nr-nota AND
             fat-ser-lote.cod-estabel = tt-notas.estab   AND
             fat-ser-lote.serie       = tt-notas.serie   query-tuning(no-lookahead):                                       
        ASSIGN fat-ser-lote.serie = "2".
    END.
end.

run pi-finalizar in h-acomp.
