/********************************************************************************
**
**  Programa: int098rp.p - API - Consulta Faturamento
    KML Consultoria - Kleber Mazepa - 14/12/2023
**
********************************************************************************/                                                                

DEFINE TEMP-TABLE tt-consulta-pedido NO-UNDO
    FIELD pedido            AS CHAR
    FIELD cnpj-cpf-cliente  AS CHAR.

DEFINE TEMP-TABLE tt-nota-fiscal NO-UNDO
    FIELD l-gerada      AS LOGICAL
    FIELD desc-erro     AS CHAR
    FIELD cod-estabel   LIKE nota-fiscal.cod-estabel
    FIELD serie         LIKE nota-fiscal.serie
    FIELD nr-nota-fis   LIKE nota-fiscal.nr-nota-fis
    FIELD chave-acesso  LIKE nota-fiscal.cod-chave-aces-nf-eletro.


DEF INPUT PARAMETER TABLE FOR tt-consulta-pedido.
DEF OUTPUT PARAMETER TABLE FOR tt-nota-fiscal.


FOR EACH tt-consulta-pedido:

    FIND FIRST emitente NO-LOCK
        WHERE emitente.cgc = tt-consulta-pedido.cnpj-cpf-cliente NO-ERROR.

    IF NOT AVAIL emitente THEN DO:

        CREATE tt-nota-fiscal.
        ASSIGN tt-nota-fiscal.cod-estabel = ""
               tt-nota-fiscal.nr-nota-fis = ""
               tt-nota-fiscal.serie       = ""
               tt-nota-fiscal.chave-acesso = ""
               tt-nota-fiscal.l-gerada    = NO
               tt-nota-fiscal.desc-erro   = "Emitente n∆o encontrado na base de dados".
        
        undo, leave.
    END.

    FIND FIRST nota-fiscal NO-LOCK
        WHERE nota-fiscal.nome-ab-cli = emitente.nome-abrev
          AND nota-fiscal.nr-pedcli  = tt-consulta-pedido.pedido NO-ERROR.

    IF AVAIL nota-fiscal THEN DO:

        CREATE tt-nota-fiscal.
        ASSIGN tt-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel
               tt-nota-fiscal.nr-nota-fis = nota-fiscal.nr-nota-fis
               tt-nota-fiscal.serie       = nota-fiscal.serie
               tt-nota-fiscal.chave-acesso = nota-fiscal.cod-chave-aces-nf-eletro
               tt-nota-fiscal.l-gerada    = YES
               tt-nota-fiscal.desc-erro   = "".

        
        undo, leave.

    END.
    ELSE DO:

         FIND first nota-fiscal EXCLUSIVE-LOCK NO-ERROR.

        IF LOCKED nota-fiscal THEN DO:
            CREATE tt-nota-fiscal.
            ASSIGN tt-nota-fiscal.cod-estabel = ""
                   tt-nota-fiscal.nr-nota-fis = ""
                   tt-nota-fiscal.serie       = ""
                   tt-nota-fiscal.chave-acesso = ""
                   tt-nota-fiscal.l-gerada    = NO
                   tt-nota-fiscal.desc-erro   = "Banco de dados em lock na tabela nota-fiscal".

        END.
        RELEASE nota-fiscal.

        CREATE tt-nota-fiscal.
        ASSIGN tt-nota-fiscal.cod-estabel = ""
               tt-nota-fiscal.nr-nota-fis = ""
               tt-nota-fiscal.serie       = ""
               tt-nota-fiscal.chave-acesso = ""
               tt-nota-fiscal.l-gerada    = NO
               tt-nota-fiscal.desc-erro   = "Nota fiscal n∆o encontrada".
        
        undo, leave.

    END.

END.
