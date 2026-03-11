DEF TEMP-TABLE tt-dados-nota NO-UNDO SERIALIZE-NAME "nota"
    FIELD chave-nfe           AS CHAR SERIALIZE-NAME "chaveNFe"
    FIELD cnpj-fornec         AS CHAR SERIALIZE-NAME "cnpjFornec"
    FIELD cnpj-estab          AS CHAR SERIALIZE-NAME "cnpjEstab"
    FIELD dat-emis            AS DATE SERIALIZE-NAME "dataEmissao"
    FIELD fin-nfe             AS CHAR SERIALIZE-NAME "indFinalidade"
    FIELD obs                 AS CHAR SERIALIZE-NAME "observacao"
    .

DEF TEMP-TABLE tt-ordens NO-UNDO SERIALIZE-NAME "ordens"
    FIELD num-ordem     AS INTE SERIALIZE-NAME "numOrdem"
    FIELD nat-operacao  AS CHAR SERIALIZE-NAME "natOperacao"
    FIELD quantidade    AS DECI SERIALIZE-NAME "quantidade"
    FIELD preco-unit    AS DECI SERIALIZE-NAME "precoUnit"
    FIELD val-mercad    AS DECI SERIALIZE-NAME "valorMercad"
    .

DEFINE TEMP-TABLE tt-erros NO-UNDO SERIALIZE-NAME "erros" 
    FIELD identif-segment AS CHARACTER SERIALIZE-NAME "seqErro"               
    FIELD cd-erro         AS INTEGER   SERIALIZE-NAME "CodErro" 
    FIELD desc-erro       AS CHARACTER SERIALIZE-NAME "descErro" 
    .

DEFINE TEMP-TABLE tt-trace NO-UNDO SERIALIZE-NAME "trace" 
    FIElD seq           AS INTE      SERIALIZE-NAME "seq"               
    FIELD cod-programa  AS CHARACTER SERIALIZE-NAME "codPrograma"               
    FIELD mensagem      AS CHARACTER SERIALIZE-NAME "mensagem" 
    .

DEF BUFFER b-tt-trace FOR tt-trace.


PROCEDURE pi-cria-tt-trace:

    DEF INPUT PARAM p-c-cod-programa    AS CHAR NO-UNDO.
    DEF INPUT PARAM p-c-mensagem        AS CHAR NO-UNDO.

    for last b-tt-trace:
    end.

    create tt-trace.
    assign tt-trace.seq = if  avail b-tt-trace
                          then b-tt-trace.seq + 1
                          else 1
           tt-trace.cod-programa = p-c-cod-programa
           tt-trace.mensagem     = p-c-mensagem.                           
                          
END PROCEDURE.    
