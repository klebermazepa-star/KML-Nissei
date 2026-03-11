/********************************************************************************
**
**  Programa - NI-IMP-CLI-MATRIZ-RP.P - Importa‡Æo Cliente Matriz
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-CLI-MATRIZ-RP 2.00.00.000 } 

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

DEF TEMP-TABLE tt-cli-matriz
    FIELD cpf   AS CHAR FORMAT "x(19)"
    FIELD cnpj  AS CHAR FORMAT "x(19)" 
    FIELD email AS CHAR FORMAT "x(50)"
    FIELD nome  AS CHAR FORMAT "x(80)" 
    INDEX cpf cpf.

DEF TEMP-TABLE tt-erro
    FIELD tipo  AS INT 
    FIELD chave     AS CHAR FORMAT "x(50)"
    FIELD desc-erro AS CHAR FORMAT "x(80)"
    INDEX tipo tipo.

DEF VAR i-cont       AS INT FORMAT ">>>,>>9"   NO-UNDO.
DEF VAR h-acomp      AS HANDLE                 NO-UNDO.
DEF VAR i-tipo       AS INT FORMAT ">>>,>>9"   NO-UNDO.
DEF VAR c-matriz-ant LIKE emitente.nome-matriz NO-UNDO.
DEF VAR c-matriz-atu LIKE emitente.nome-matriz NO-UNDO.
DEF VAR i-cpf        AS INT                    NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo Cliente Matriz").

EMPTY TEMP-TABLE tt-cli-matriz.
EMPTY TEMP-TABLE tt-erro.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-cli-matriz.
   IMPORT DELIMITER ";" tt-cli-matriz NO-ERROR.  

   assign i-cont = i-cont + 1.

   run pi-acompanhar in h-acomp (input "Criando tt-cli-matriz: " + string(tt-cli-matriz.cpf) + " - " + string(i-cont)).

END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0
       i-cpf  = 0.

for each tt-cli-matriz BREAK BY tt-cli-matriz.cpf:

    /*assign i-cont = i-cont + 1.
    run pi-acompanhar in h-acomp (input "Validando: " + string(tt-cli-matriz.cpf) + " - " + string(i-cont)).

    ASSIGN i-cpf = i-cpf + 1.
                  
    IF LAST-OF(tt-cli-matriz.cpf) THEN DO:
       IF i-cpf > 1 THEN DO:
          CREATE tt-erro.
          ASSIGN tt-erro.tipo      = 2
                 tt-erro.chave     = tt-cli-matriz.cpf
                 tt-erro.desc-erro = "CPF duplicado".
       END.
       ASSIGN i-cpf  = 0.
    END.

    FIND FIRST emitente WHERE
               emitente.nome-emit = tt-cli-matriz.nome NO-LOCK NO-ERROR.
    IF AVAIL emitente THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.tipo      = 4
              tt-erro.chave     = tt-cli-matriz.nome
              tt-erro.desc-erro = "Nome cadastrado".
    END.*/

    /*FIND FIRST emitente WHERE
               emitente.cgc = tt-cli-matriz.cpf NO-LOCK NO-ERROR.
    IF NOT AVAIL emitente THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.tipo      = 1
              tt-erro.chave     = tt-cli-matriz.cpf
              tt-erro.desc-erro = "CPF nao cadastrado".
    END.

    FIND FIRST emitente WHERE
               emitente.cgc = tt-cli-matriz.cnpj NO-LOCK NO-ERROR.
    IF NOT AVAIL emitente THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.tipo      = 2
              tt-erro.chave     = tt-cli-matriz.cnpj
              tt-erro.desc-erro = "CNPJ nao cadastrado".
    END.*/

    FIND FIRST emitente WHERE
               emitente.cgc = tt-cli-matriz.cpf NO-LOCK NO-ERROR.
    IF AVAIL emitente THEN DO:
       ASSIGN c-matriz-ant = emitente.nome-matriz.
       FIND FIRST emitente WHERE
                  emitente.cgc = tt-cli-matriz.cnpj NO-LOCK NO-ERROR.
       IF AVAIL emitente THEN DO:
          ASSIGN c-matriz-atu = emitente.nome-matriz.
          FIND FIRST emitente WHERE
                     emitente.cgc = tt-cli-matriz.cpf NO-ERROR.
          ASSIGN emitente.nome-matriz = c-matriz-atu
                 emitente.e-mail      = substr(tt-cli-matriz.email,1,50)
                 emitente.cod-gr-cli  = 10.
          CREATE tt-erro.
          ASSIGN tt-erro.tipo      = 3
                 tt-erro.chave     = tt-cli-matriz.cpf + " / " + tt-cli-matriz.cnpj
                 tt-erro.desc-erro = "CPF e CNPJ cadastrados. Matriz Anterior: " + c-matriz-ant + ". Matriz Atual: " + c-matriz-atu.
          RELEASE emitente.

          assign i-cont = i-cont + 1.
          run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-cli-matriz.cpf) + " - " + string(i-cont)).

       END.
    END.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importa‡Æo Matriz Cliente"
       c-programa     = "NI-IMP-CLI-MATRIZ-RP".

{include/i-rpcab.i}

view frame f-cabec.

ASSIGN i-tipo = 0.

for each tt-erro BREAK BY tipo:

    ASSIGN i-tipo = i-tipo + 1.

    disp tt-erro.chave column-label "Chave"
         tt-erro.desc-erro column-label "Descri‡Æo"
         with width 132 no-box stream-io down frame f-erros.

    IF LAST-OF(tt-erro.tipo) THEN DO:
       PUT SKIP(1)
           "Total: " i-tipo.
       ASSIGN i-tipo = 0.
       PAGE.
    END.

end.         

view frame f-rodape.    

{include/i-rpclo.i}





