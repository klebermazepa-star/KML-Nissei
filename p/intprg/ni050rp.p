/********************************************************************************
**
**  Programa - ni050rp.p - Importaá∆o Alternativo/Equivalància
**
********************************************************************************/ 

{include/i-prgvrs.i ni050rp 2.00.00.000 } 

DISABLE TRIGGERS FOR LOAD OF item-fornec.

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

DEF TEMP-TABLE tt-item-fornec
    FIELD cnpj         LIKE emitente.cgc
    FIELD it-codigo    LIKE ITEM.it-codigo
    FIELD cod-barras   AS CHAR
    FIELD item-do-forn LIKE item-fornec.item-do-forn
    FIELD fator-conver LIKE item-fornec.fator-conver
    FIELD num-casa-dec LIKE item-fornec.num-casa-dec
    FIELD unid-med-for LIKE item-fornec.unid-med-for
    FIELD tipo-item    AS   CHAR.

DEF TEMP-TABLE tt-erro
    FIELD cod-emitente LIKE emitente.cod-emitente
    FIELD cnpj         LIKE emitente.cgc
    FIELD it-codigo    LIKE item.it-codigo
    FIELD desc-erro    AS CHAR FORMAT "x(40)"
    INDEX codigo cnpj
    INDEX ITEM   it-codigo.

DEF VAR i-cont         AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cnpj         AS DEC                      NO-UNDO.
DEF VAR h-acomp        AS HANDLE                   NO-UNDO.
DEF VAR i-novos        AS INT FORMAT ">>>,>>9"     NO-UNDO.
DEF VAR i-alterados    AS INT FORMAT ">>>,>>9"     NO-UNDO.
DEF VAR c-item-do-forn AS CHAR FORMAT "x(60)"      NO-UNDO.
DEF VAR i-seq          AS INT                      NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importaá∆o Alternativo").

EMPTY TEMP-TABLE tt-item-fornec.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont      = 0
       i-novos     = 0
       i-alterados = 0.

REPEAT:  
   CREATE tt-item-fornec.
   IMPORT DELIMITER ";" tt-item-fornec.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando Arq. Tempor†rio: " + string(i-cont,">>>,>>>,>>9")).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                                
for each tt-item-fornec:

    assign i-cont = i-cont + 1.
    run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-item-fornec.cnpj) + " - " + string(i-cont)).

    FOR FIRST emitente USE-INDEX cgc WHERE
              emitente.cgc = tt-item-fornec.cnpj NO-LOCK:
    END.
    IF NOT AVAIL emitente THEN DO:
       FIND FIRST tt-erro USE-INDEX codigo WHERE
                  tt-erro.cnpj = tt-item-fornec.cnpj NO-LOCK NO-ERROR.
       IF NOT AVAIL tt-erro THEN DO:
          CREATE tt-erro.
          ASSIGN tt-erro.cnpj      = tt-item-fornec.cnpj
                 tt-erro.desc-erro = "CNPJ n∆o cadastrado no Datasul".
       END.
       NEXT.
    END.

    FOR FIRST ITEM WHERE
              ITEM.it-codigo = tt-item-fornec.it-codigo NO-LOCK:
    END.
    IF NOT AVAIL ITEM THEN DO:
       FIND FIRST tt-erro USE-INDEX ITEM WHERE
                  tt-erro.it-codigo = tt-item-fornec.it-codigo NO-LOCK NO-ERROR.
       IF NOT AVAIL tt-erro THEN DO:
          CREATE tt-erro.
          ASSIGN tt-erro.cnpj      = tt-item-fornec.it-codigo
                 tt-erro.desc-erro = "Item n∆o cadastrado no Datasul".
       END.
       NEXT.
    END.
      
    IF tt-item-fornec.tipo-item BEGINS "Pri" /* Prim†rio/Principal */
    THEN DO:

        FOR FIRST item-fornec USE-INDEX onde-compra WHERE
                  item-fornec.it-codigo    = tt-item-fornec.it-codigo AND
                  item-fornec.cod-emitente = emitente.cod-emitente:
        END.
        IF AVAIL item-fornec THEN DO:
           /*CREATE tt-erro.
           ASSIGN tt-erro.cod-emitente = emitente.cod-emitente
                  tt-erro.cnpj         = tt-item-fornec.cnpj
                  tt-erro.it-codigo    = tt-item-fornec.it-codigo
                  tt-erro.desc-erro    = "Item x Fornecedor j† cadastrado".*/
    
           ASSIGN item-fornec.item-do-forn = tt-item-fornec.item-do-forn
                  item-fornec.fator-conver = tt-item-fornec.fator-conver
                  item-fornec.num-casa-dec = tt-item-fornec.num-casa-dec
                  item-fornec.unid-med-for = tt-item-fornec.unid-med-for
                  item-fornec.narrativa    = IF tt-item-fornec.cod-barras <> "" THEN 
                                                "C¢digo de Barras: " + tt-item-fornec.cod-barras
                                             ELSE ""
                  i-alterados              = i-alterados + 1.
        END.
        ELSE DO:
           CREATE item-fornec.
           ASSIGN item-fornec.cod-emitente = emitente.cod-emitente
                  item-fornec.it-codigo    = tt-item-fornec.it-codigo
                  item-fornec.item-do-forn = tt-item-fornec.item-do-forn
                  item-fornec.fator-conver = tt-item-fornec.fator-conver
                  item-fornec.num-casa-dec = tt-item-fornec.num-casa-dec
                  item-fornec.unid-med-for = tt-item-fornec.unid-med-for
                  item-fornec.narrativa    = IF tt-item-fornec.cod-barras <> "" THEN 
                                                "C¢digo de Barras: " + tt-item-fornec.cod-barras
                                             ELSE ""
                  i-novos                  = i-novos + 1.
        END.
        RELEASE item-fornec.

    END.
    ELSE IF tt-item-fornec.tipo-item BEGINS "Sec" /* Secund†rio */ 
    THEN DO: 

            FOR FIRST item-fornec USE-INDEX onde-compra WHERE
                      item-fornec.it-codigo    = tt-item-fornec.it-codigo AND
                      item-fornec.cod-emitente = emitente.cod-emitente NO-LOCK:
            END.
            IF NOT AVAIL item-fornec THEN DO:
               CREATE tt-erro.
               ASSIGN tt-erro.cod-emitente = emitente.cod-emitente
                      tt-erro.cnpj         = tt-item-fornec.cnpj
                      tt-erro.it-codigo    = tt-item-fornec.it-codigo
                      tt-erro.desc-erro    = "Item x Fornecedor Prim†rio n∆o cadastrado".
               NEXT.
            END.
            ELSE DO:
                   FOR FIRST item-fornec-umd WHERE
                             item-fornec-umd.cod-emitente = emitente.cod-emitente    AND 
                             item-fornec-umd.it-codigo    = tt-item-fornec.it-codigo AND  
                             item-fornec-umd.cod-livre-1  = tt-item-fornec.item-do-forn:
                   END.
    
                   IF AVAIL item-fornec-umd 
                   THEN DO:
                      ASSIGN item-fornec-umd.fator-conver = tt-item-fornec.fator-conver
                             item-fornec-umd.num-casa-dec = tt-item-fornec.num-casa-dec
                             item-fornec-umd.log-ativo    = YES
                             i-alterados              = i-alterados + 1.
                   END.
                   ELSE DO:
    
                       ASSIGN i-seq = 1.
    
                       FOR EACH item-fornec-umd NO-LOCK WHERE
                                item-fornec-umd.cod-emitente = emitente.cod-emitente AND 
                                item-fornec-umd.it-codigo    = tt-item-fornec.it-codigo
                              BY item-fornec-umd.unid-med-for:   
    
                           ASSIGN i-seq = i-seq + 1.
    
                       END.
                                       
                       CREATE item-fornec-umd.
                       ASSIGN item-fornec-umd.cod-emitente = emitente.cod-emitente
                              item-fornec-umd.it-codigo    = tt-item-fornec.it-codigo
                              item-fornec-umd.cod-livre-1  = tt-item-fornec.item-do-forn
                              item-fornec-umd.fator-conver = tt-item-fornec.fator-conver
                              item-fornec-umd.num-casa-dec = tt-item-fornec.num-casa-dec
                              item-fornec-umd.unid-med-for = string(i-seq)
                              item-fornec-umd.log-ativo    = YES
                              i-novos                      = i-novos + 1.
    
                   END.
    
                   RELEASE item-fornec-umd.
            END.   

    END.

end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importaá∆o Alternativo/Equivalància"
       c-programa     = "ni050rp".

{include/i-rpcab.i}

view frame f-cabec.

PUT SKIP "Registros criados..: " i-novos
    SKIP(1)
         "Registros alterados: " i-alterados
    SKIP(1).
        
for each tt-erro BY tt-erro.desc-erro:
    disp tt-erro.cod-emitente COLUMN-LABEL "Fornecedor"
         tt-erro.cnpj         column-label "CNPJ"
         tt-erro.it-codigo    column-label "Item"
         tt-erro.desc-erro    COLUMN-LABEL "Descriá∆o Erro"
         with width 132 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}





