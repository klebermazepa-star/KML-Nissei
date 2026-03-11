/********************************************************************************
**
**  Programa: int091rp.p - Integraá∆o de clientes
**
********************************************************************************/                                                                

/* include de controle de vers∆o */
{include/i-prgvrs.i INT091RP 1.00.00.000}  /*** 010000 ***/

def new global shared var c-seg-usuario as char no-undo.

DEF VAR h-acomp    AS HANDLE  NO-UNDO.

/* definiá∆o das temp-tables para recebimento de parÉmetros */
define temp-table tt-param NO-UNDO
       FIELD DESTINO            AS INTEGER 
       FIELD ARQUIVO            AS CHAR FORMAT "x(35)"
       FIELD USUARIO            AS CHAR FORMAT "x(12)"
       FIELD DATA-EXEC          AS DATE 
       FIELD HORA-EXEC          AS INTEGER 
       FIELD L-IMP-PARAM        AS LOG 
       FIELD L-EXCEL            AS LOG 
       FIELD cod-emitente-ini   AS character FORMAT "x(15)"
       FIELD cod-emitente-fim   AS character FORMAT "x(15)"
       FIELD cod-cnpj-ini       AS character FORMAT "x(16)"
       FIELD cod-cnpj-fim       AS character FORMAT "x(16)".

def temp-table tt-raw-digita
    	field raw-digita	as raw.

/* recebimento de parÉmetros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param NO-ERROR.

IF tt-param.arquivo = "" THEN 
   ASSIGN tt-param.arquivo   = "int091.txt"
          tt-param.destino   = 3
          tt-param.data-exec = TODAY
          tt-param.hora-exec = TIME.

{include/i-rpvar.i}

FIND FIRST param-global NO-LOCK NO-ERROR.

assign  c-programa 	    = "INT091RP"
	    c-versao	    = "1.00"
	    c-revisao	    = ".00.000"
        c-empresa       = param-global.grupo
	    c-sistema	    = "Espec°fico"
	    c-titulo-relat  = "Atualizaá∆o de clientes".

{include/i-rpout.i}
{include/i-rpcab.i}

VIEW FRAME f-cabec.
VIEW FRAME f-rodape.

run utp/ut-acomp.p persistent set h-acomp.

DEFINE TEMP-TABLE tt-bo-erro NO-UNDO
    FIELD i-sequen     AS INT 
    FIELD cd-erro      AS INT
    FIELD mensagem     AS CHAR      FORMAT "x(255)"
    FIELD parametros   AS CHAR      FORMAT "x(255)" INIT ""
    FIELD errortype    AS CHAR      FORMAT "x(20)"
    FIELD errorhelp    AS CHAR      FORMAT "x(20)"
    FIELD errorsubtype AS CHARACTER.

DEFINE VARIABLE tth-emitente    AS HANDLE        NO-UNDO.
DEFINE VARIABLE bhtt-emitente   AS HANDLE        NO-UNDO.
DEF    VAR      h-bo            AS HANDLE        NO-UNDO.
DEFINE VARIABLE i-emitente      AS INTEGER     NO-UNDO.
DEF    VAR      r-chave         AS ROWID         NO-UNDO.
DEFINE VARIABLE i-identific     AS INTEGER NO-UNDO.
DEFINE VARIABLE hb-emitente     AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h-query         AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE l-movto-erro    AS LOGICAL     NO-UNDO.


DEFINE BUFFER b_int_ds_cliente FOR int_ds_cliente.
DEFINE BUFFER b_emitente FOR emitente.

DEFINE VARIABLE i-total-clientes AS INTEGER  INIT 0   NO-UNDO.
DEFINE VARIABLE i-cliente-atual AS INTEGER   INIT 0  NO-UNDO.

DEFINE VARIABLE c-nome-matriz AS CHARACTER   NO-UNDO.


run pi-inicializar in h-acomp (input "Integraá∆o de Clientes").   

FOR EACH int_ds_cliente NO-LOCK
    WHERE int_ds_cliente.situacao   = 1 /* Pendente */
      AND int_ds_cliente.cgc        >= tt-param.cod-cnpj-ini
      AND int_ds_cliente.cgc        <= tt-param.cod-cnpj-fim :

    ASSIGN i-total-clientes = i-total-clientes + 1.

END.

FOR EACH int_ds_cliente NO-LOCK
    WHERE int_ds_cliente.situacao   = 1 /* Pendente */
      AND int_ds_cliente.cgc        >= tt-param.cod-cnpj-ini
      AND int_ds_cliente.cgc        <= tt-param.cod-cnpj-fim :

    run pi-acompanhar in h-acomp (input "Executando cliente - " + STRING(i-cliente-atual) + " de " + string(i-total-clientes) ). 

    RUN p_valida_clientes( OUTPUT l-movto-erro ).

    IF l-movto-erro THEN DO:
        NEXT.
    END.

    ASSIGN i-cliente-atual = i-cliente-atual + 1.

    IF i-cliente-atual >= 2000 THEN NEXT.

/*     IF int_ds_cliente.tipo_movto = 1 THEN DO:  // Inclus∆o de clientes              */
/*                                                                                     */
/*         RUN p_cria_clientes.                                                        */
/*     END.                                                                            */
/*                                                                                     */
/*     IF int_ds_cliente.tipo_movto = 2 THEN DO: // Alteraá∆o de cliente j† cadastrado */
         
        FIND FIRST b_emitente NO-LOCK
        WHERE b_emitente.cgc =  INT_ds_cliente.cgc NO-ERROR.
            IF AVAIL b_emitente THEN 
                 
                RUN p_altera_clientes.
    
            ELSE 
                RUN p_cria_clientes.
            
    
     RUN pi-finaliza-bo.
       

END.

IF i-total-clientes = 0 THEN
    PUT "N∆o existe registros de clientes para integraá∆o" FORMAT "x(100)" SKIP.



PROCEDURE p_cria_clientes:

    CREATE BUFFER bhtt-emitente FOR TABLE "emitente".
    CREATE TEMP-TABLE tth-emitente.        
    tth-emitente:CREATE-LIKE(bhtt-emitente).        
    tth-emitente:ADD-NEW-FIELD("r-rowid","rowid").         
    tth-emitente:TEMP-TABLE-PREPARE("tt-emitente").        
    bhtt-emitente = tth-emitente:DEFAULT-BUFFER-HANDLE. 
    
    bhtt-emitente:BUFFER-CREATE.
    
    RUN cdp/cd9960.p (OUTPUT i-emitente).
    
    IF NOT VALID-HANDLE(h-bo) THEN
        RUN adbo/boad098.p PERSISTENT SET h-bo.

    ASSIGN bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE  = i-emitente
           bhtt-emitente:BUFFER-FIELD("end-cobranca"):BUFFER-VALUE  = i-emitente
           bhtt-emitente:BUFFER-FIELD("nome-abrev"):BUFFER-VALUE    = int_ds_cliente.nome_abrev
           bhtt-emitente:BUFFER-FIELD("nome-matriz"):BUFFER-VALUE   = c-nome-matriz
           bhtt-emitente:BUFFER-FIELD("cgc"):BUFFER-VALUE           = int_ds_cliente.cgc
           bhtt-emitente:BUFFER-FIELD("identific"):BUFFER-VALUE     = 1 /* sempre cliente/fornecedor */
           bhtt-emitente:BUFFER-FIELD("natureza"):BUFFER-VALUE      = int_ds_cliente.natureza 
           bhtt-emitente:BUFFER-FIELD("nome-emit"):BUFFER-VALUE     = int_ds_cliente.nome_emit
           bhtt-emitente:BUFFER-FIELD("endereco"):BUFFER-VALUE      = int_ds_cliente.endereco 
           bhtt-emitente:BUFFER-FIELD("bairro"):BUFFER-VALUE        = SUBSTRING(int_ds_cliente.bairro,1,30)
           bhtt-emitente:BUFFER-FIELD("cidade"):BUFFER-VALUE        = int_ds_cliente.cidade
           bhtt-emitente:BUFFER-FIELD("estado"):BUFFER-VALUE        = int_ds_cliente.estado
           bhtt-emitente:BUFFER-FIELD("cep"):BUFFER-VALUE           = int_ds_cliente.cep 
           bhtt-emitente:BUFFER-FIELD("pais"):BUFFER-VALUE          = int_ds_cliente.pais 
           bhtt-emitente:BUFFER-FIELD("cod-gr-cli"):BUFFER-VALUE    = IF int_ds_cliente.cod_gr_cli = 0 THEN 10 ELSE int_ds_cliente.cod_gr_cli
           bhtt-emitente:BUFFER-FIELD("portador"):BUFFER-VALUE      = 99999
           bhtt-emitente:BUFFER-FIELD("modalidade"):BUFFER-VALUE    = 6
           bhtt-emitente:BUFFER-FIELD("cod-rep"):BUFFER-VALUE       = 1
           bhtt-emitente:BUFFER-FIELD("cod-transp"):BUFFER-VALUE    = 99999
           bhtt-emitente:BUFFER-FIELD("tp-rec-padrao"):BUFFER-VALUE = 208
           bhtt-emitente:BUFFER-FIELD("endereco-cob"):BUFFER-VALUE  = int_ds_cliente.endereco 
           bhtt-emitente:BUFFER-FIELD("bairro-cob"):BUFFER-VALUE    = SUBSTRING(int_ds_cliente.bairro,1,30)
           bhtt-emitente:BUFFER-FIELD("cidade-cob"):BUFFER-VALUE    = int_ds_cliente.cidade
           bhtt-emitente:BUFFER-FIELD("estado-cob"):BUFFER-VALUE    = int_ds_cliente.estado
           bhtt-emitente:BUFFER-FIELD("cep-cob"):BUFFER-VALUE       = int_ds_cliente.cep 
           bhtt-emitente:BUFFER-FIELD("pais-cob"):BUFFER-VALUE      = int_ds_cliente.pais 
           bhtt-emitente:BUFFER-FIELD("cgc-cob"):BUFFER-VALUE       = int_ds_cliente.cgc
           bhtt-emitente:BUFFER-FIELD("ins-estadual"):BUFFER-VALUE  = int_ds_cliente.ins_estadual
           bhtt-emitente:BUFFER-FIELD("ins-est-cob"):BUFFER-VALUE   = int_ds_cliente.ins_estadual
           bhtt-emitente:BUFFER-FIELD("modalidade-ap"):BUFFER-VALUE = 6
           bhtt-emitente:BUFFER-FIELD("tp-desp-padrao"):BUFFER-VALUE = 407
           bhtt-emitente:BUFFER-FIELD("cod-gr-forn"):BUFFER-VALUE   = 10.

    RUN validateCreate IN h-bo (INPUT TABLE-HANDLE tth-emitente, OUTPUT TABLE tt-bo-erro, OUTPUT r-chave).


    FOR FIRST tt-bo-erro:

        RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT string(tt-bo-erro.mensagem) + " - CPF/CNPJ: " + string(int_ds_cliente.cgc) + ".",
                            INPUT 1, /* 2 - Integrado */
                            INPUT c-seg-usuario,
                            INPUT "int091.p").

        PUT string(tt-bo-erro.mensagem) + " - CPF/CNPJ: " + string(int_ds_cliente.cgc) + " - Nome abreviado: " + int_ds_cliente.nome_abrev
            FORMAT "x(100)".
        PUT SKIP.
        LEAVE.

    END.

    run cdp/cd1608.p (input bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE,
                  input bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE,
                  input i-identific,
                  input yes,
                  input 1,
                  input 0,
                  input session:temp-dir + "integracaoEMS5.txt",
                  input "Arquivo",
                  input "").
    
    FIND FIRST loc-entr 
        WHERE loc-entr.nome-abrev  = int_ds_cliente.nome_abrev 
          AND loc-entr.cod-entrega = "Padr∆o" NO-ERROR.

    IF NOT AVAIL loc-entr THEN DO:
        CREATE loc-entr.
        ASSIGN loc-entr.nome-abrev  = int_ds_cliente.nome_abrev  
                loc-entr.cod-entrega = "Padr∆o".            
    END.
    ASSIGN loc-entr.endereco     = int_ds_cliente.endereco
           loc-entr.bairro       = SUBSTRING(int_ds_cliente.bairro,1,30)
           loc-entr.cidade       = int_ds_cliente.cidade
           loc-entr.estado       = int_ds_cliente.estado
           loc-entr.pais         = int_ds_cliente.pais
           loc-entr.cep          = int_ds_cliente.cep
           loc-entr.ins-estadual = int_ds_cliente.ins_estadual
           loc-entr.cgc          = int_ds_cliente.cgc.

    FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
        WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.
    
    IF AVAIL b_int_ds_cliente THEN DO:
        ASSIGN b_int_ds_cliente.situacao = 2
               b_int_ds_cliente.envio_status = 8.

    END.
    RELEASE b_int_ds_cliente.

    RUN intprg/int999.p (INPUT "CLI", 
                        INPUT STRING(int_ds_cliente.cgc),
                        INPUT "Cliente integrado com sucesso - CPF/CNPJ: " + string(int_ds_cliente.cgc) + ".",
                        INPUT 2, /* 2 - Integrado */
                        INPUT c-seg-usuario,
                        INPUT "int091.p").

    PUT "Cliente integrado com sucesso - CPF/CNPJ: " + string(int_ds_cliente.cgc) + " - Nome abreviado: " + int_ds_cliente.nome_abrev
        FORMAT "x(100)".
    PUT SKIP.
    
END PROCEDURE.

PROCEDURE p_altera_clientes:


    FIND FIRST b_emitente NO-LOCK
        WHERE b_emitente.cgc =  INT_ds_cliente.cgc NO-ERROR.
    IF AVAIL b_emitente THEN DO:
        
    
        CREATE BUFFER bhtt-emitente FOR TABLE "emitente".
        CREATE TEMP-TABLE tth-emitente.        
        tth-emitente:CREATE-LIKE(bhtt-emitente).        
        tth-emitente:ADD-NEW-FIELD("r-rowid","rowid").         
        tth-emitente:TEMP-TABLE-PREPARE("tt-emitente").        
        bhtt-emitente = tth-emitente:DEFAULT-BUFFER-HANDLE. 
        
        bhtt-emitente:BUFFER-CREATE.
    
        ASSIGN i-emitente = b_emitente.cod-emitente.
        
        IF NOT VALID-HANDLE(h-bo) THEN
            RUN adbo/boad098.p PERSISTENT SET h-bo.
                
        ASSIGN bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE  = i-emitente
               bhtt-emitente:BUFFER-FIELD("end-cobranca"):BUFFER-VALUE  = i-emitente
               bhtt-emitente:BUFFER-FIELD("nome-abrev"):BUFFER-VALUE    = b_emitente.nome-abrev
               bhtt-emitente:BUFFER-FIELD("nome-matriz"):BUFFER-VALUE   = b_emitente.nome-matriz
               bhtt-emitente:BUFFER-FIELD("cgc"):BUFFER-VALUE           = b_emitente.cgc
               bhtt-emitente:BUFFER-FIELD("identific"):BUFFER-VALUE     = IF b_emitente.identif = 2 THEN 3 ELSE b_emitente.identif /* sempre cliente/fornecedor */
               bhtt-emitente:BUFFER-FIELD("natureza"):BUFFER-VALUE      = int_ds_cliente.natureza 
               bhtt-emitente:BUFFER-FIELD("nome-emit"):BUFFER-VALUE     = int_ds_cliente.nome_emit
               bhtt-emitente:BUFFER-FIELD("endereco"):BUFFER-VALUE      = int_ds_cliente.endereco 
               bhtt-emitente:BUFFER-FIELD("bairro"):BUFFER-VALUE        = SUBSTRING(int_ds_cliente.bairro,1,30)
               bhtt-emitente:BUFFER-FIELD("cidade"):BUFFER-VALUE        = int_ds_cliente.cidade
               bhtt-emitente:BUFFER-FIELD("estado"):BUFFER-VALUE        = int_ds_cliente.estado
               bhtt-emitente:BUFFER-FIELD("cep"):BUFFER-VALUE           = int_ds_cliente.cep 
               bhtt-emitente:BUFFER-FIELD("pais"):BUFFER-VALUE          = int_ds_cliente.pais 
               bhtt-emitente:BUFFER-FIELD("cod-gr-cli"):BUFFER-VALUE    = IF int_ds_cliente.cod_gr_cli = 0 THEN 10 ELSE int_ds_cliente.cod_gr_cli
               bhtt-emitente:BUFFER-FIELD("portador"):BUFFER-VALUE      = 99999
               bhtt-emitente:BUFFER-FIELD("portador-ap"):BUFFER-VALUE   = 99999
               bhtt-emitente:BUFFER-FIELD("modalidade"):BUFFER-VALUE    = 6
               bhtt-emitente:BUFFER-FIELD("cod-rep"):BUFFER-VALUE       = 1
               bhtt-emitente:BUFFER-FIELD("cod-transp"):BUFFER-VALUE    = 99999
               bhtt-emitente:BUFFER-FIELD("tp-rec-padrao"):BUFFER-VALUE = 208
               bhtt-emitente:BUFFER-FIELD("endereco-cob"):BUFFER-VALUE  = int_ds_cliente.endereco 
               bhtt-emitente:BUFFER-FIELD("bairro-cob"):BUFFER-VALUE    = SUBSTRING(int_ds_cliente.bairro,1,30)
               bhtt-emitente:BUFFER-FIELD("cidade-cob"):BUFFER-VALUE    = int_ds_cliente.cidade
               bhtt-emitente:BUFFER-FIELD("estado-cob"):BUFFER-VALUE    = int_ds_cliente.estado
               bhtt-emitente:BUFFER-FIELD("cep-cob"):BUFFER-VALUE       = int_ds_cliente.cep 
               bhtt-emitente:BUFFER-FIELD("pais-cob"):BUFFER-VALUE      = int_ds_cliente.pais 
               bhtt-emitente:BUFFER-FIELD("cgc-cob"):BUFFER-VALUE       = int_ds_cliente.cgc
               bhtt-emitente:BUFFER-FIELD("ins-estadual"):BUFFER-VALUE  = int_ds_cliente.ins_estadual
               bhtt-emitente:BUFFER-FIELD("ins-est-cob"):BUFFER-VALUE   = int_ds_cliente.ins_estadual
               bhtt-emitente:BUFFER-FIELD("modalidade-ap"):BUFFER-VALUE = 6  
               bhtt-emitente:BUFFER-FIELD("tp-desp-padrao"):BUFFER-VALUE = b_emitente.tp-desp-padrao              
               bhtt-emitente:BUFFER-FIELD("cod-gr-forn"):BUFFER-VALUE    = b_emitente.cod-gr-forn
               bhtt-emitente:BUFFER-FIELD("cod-cond-pag"):BUFFER-VALUE   = b_emitente.cod-cond-pag
               bhtt-emitente:BUFFER-FIELD("ins-municipal"):BUFFER-VALUE  = b_emitente.ins-municipal
               bhtt-emitente:BUFFER-FIELD("contrib-icms"):BUFFER-VALUE   = b_emitente.contrib-icms
               bhtt-emitente:BUFFER-FIELD("log-possui-nf-eletro"):BUFFER-VALUE = b_emitente.log-possui-nf-eletro
               bhtt-emitente:BUFFER-FIELD("log-nf-eletro"):BUFFER-VALUE  = b_emitente.log-nf-eletro
               bhtt-emitente:BUFFER-FIELD("vencto-dia-nao-util"):BUFFER-VALUE  = b_emitente.vencto-dia-nao-util
               .

        IF b_emitente.tp-desp-padrao = 0 THEN
            ASSIGN bhtt-emitente:BUFFER-FIELD("tp-desp-padrao"):BUFFER-VALUE = 407.

        IF b_emitente.cod-gr-forn = 0 THEN
            ASSIGN bhtt-emitente:BUFFER-FIELD("cod-gr-forn"):BUFFER-VALUE   = 10.

/*         IF b_emitente.cod-cond-pag = 0 THEN                                                                                   */
/*             ASSIGN b_emitente.cod-cond-pag = emitente.cod-cond-pag. // incluida linha para transmitir a condá∆o para procfit. */
                          
        RUN validateUpdate IN h-bo (INPUT TABLE-HANDLE tth-emitente, INPUT rowid(b_emitente), OUTPUT TABLE tt-bo-erro).
                 
        run cdp/cd1608.p (input bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE,
                      input bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE,
                      input 1,
                      input yes,
                      input 1,
                      input 0,
                      input session:temp-dir + "integracaoEMS5.txt",
                      input "Arquivo",
                      input "").

        FOR FIRST tt-bo-erro:
    
            RUN intprg/int999.p (INPUT "CLI", 
                                INPUT STRING(int_ds_cliente.cgc),
                                INPUT string(tt-bo-erro.mensagem) + " - CPF/CNPJ: " + string(int_ds_cliente.cgc) + ".",
                                INPUT 1, /* 2 - Integrado */
                                INPUT c-seg-usuario,
                                INPUT "int091.p").
    
            PUT string(tt-bo-erro.mensagem) + " - CPF/CNPJ: " + string(int_ds_cliente.cgc) + " - Nome abreviado: " + int_ds_cliente.nome_abrev
                FORMAT "x(100)".
            PUT SKIP.
            LEAVE.
    
        END.

        FIND FIRST loc-entr 
            WHERE loc-entr.nome-abrev  = int_ds_cliente.nome_abrev 
              AND loc-entr.cod-entrega = "Padr∆o" NO-ERROR.

        IF NOT AVAIL loc-entr THEN DO:
            CREATE loc-entr.
            ASSIGN loc-entr.nome-abrev  = int_ds_cliente.nome_abrev  
                    loc-entr.cod-entrega = "Padr∆o".            
        END.
        ASSIGN loc-entr.endereco     = int_ds_cliente.endereco
               loc-entr.bairro       = SUBSTRING(int_ds_cliente.bairro,1,30)
               loc-entr.cidade       = int_ds_cliente.cidade
               loc-entr.estado       = int_ds_cliente.estado
               loc-entr.pais         = int_ds_cliente.pais
               loc-entr.cep          = int_ds_cliente.cep
               loc-entr.ins-estadual = int_ds_cliente.ins_estadual
               loc-entr.cgc          = int_ds_cliente.cgc.

        FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
            WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.

        IF AVAIL b_int_ds_cliente THEN DO:
            ASSIGN b_int_ds_cliente.situacao = 2
                   b_int_ds_cliente.envio_status = 8.

        END.

        RELEASE b_int_ds_cliente.

        RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "Cliente alterado com sucesso - CPF/CNPJ: " + string(int_ds_cliente.cgc) + ".",
                            INPUT 2, /* 2 - Integrado */
                            INPUT c-seg-usuario,
                            INPUT "int091.p").

        PUT "Cliente alterado com sucesso - CPF/CNPJ: " + string(int_ds_cliente.cgc) + " - Nome abreviado: " + int_ds_cliente.nome_abrev
            FORMAT "x(100)".
        PUT SKIP.

    END.

END PROCEDURE.

PROCEDURE p_valida_clientes:

    DEFINE OUTPUT PARAMETER l-movto-erro AS LOGICAL NO-UNDO.

    ASSIGN l-movto-erro = NO.

    // Retornar erro se o CPF/CNPJ estiver em branco
    IF int_ds_cliente.cgc = ?
    OR int_ds_cliente.cgc = "?" 
    OR int_ds_cliente.cgc = "" THEN DO:
       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "CNPJ/CPF est† branco ou desconhecido. Nome Abrev.: " + int_ds_cliente.nome_abrev,
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int091.p").

       PUT "CNPJ/CPF est† branco ou desconhecido - CPF/CNPJ: " + string(int_ds_cliente.cgc) + " - Nome abreviado: " + int_ds_cliente.nome_abrev
           FORMAT "x(100)".
       PUT SKIP.
       ASSIGN l-movto-erro = YES.
       LEAVE.
    END.


    FIND FIRST emitente NO-LOCK
        WHERE emitente.cgc = int_ds_cliente.cgc NO-ERROR.
    
    /* Alterando registros que j† existes no datasul para o modo de alteraá∆o de clientes */
    IF AVAIL emitente THEN DO:

        FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
            WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.

        IF AVAIL b_int_ds_cliente THEN DO:
            ASSIGN b_int_ds_cliente.tipo_movto = 2.
        END.
        RELEASE b_int_ds_cliente.
        
    END.

    IF int_ds_cliente.tipo_movto = 2 THEN DO: /* Alteraá∆o */
       FIND FIRST b_emitente WHERE
                  b_emitente.cgc = int_ds_cliente.cgc NO-LOCK NO-ERROR.
       IF NOT AVAIL b_emitente THEN DO:
            FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
                WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.
    
            IF AVAIL b_int_ds_cliente THEN DO:
                ASSIGN b_int_ds_cliente.tipo_movto = 1.
            END.
            RELEASE b_int_ds_cliente.

       END.

    END.

    // Ajustando formato do CNPJ e CPF

    FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
        WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.

    
    IF int_ds_cliente.natureza = 1 /*Pessoa Fisica */ THEN DO:
    
        IF AVAIL b_int_ds_cliente THEN
            ASSIGN b_int_ds_cliente.cgc = string(int64(INT_ds_cliente.cgc), "99999999999").
    END.
    ELSE DO:
    
        IF AVAIL b_int_ds_cliente THEN
            ASSIGN b_int_ds_cliente.cgc = string(int64(INT_ds_cliente.cgc), "99999999999999").
    END.
    RELEASE b_int_ds_cliente.

    // Se o emitente for estabelecimento, ignora

    FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cgc = int_ds_cliente.cgc NO-ERROR.
    IF AVAIL estabelec THEN DO:

        FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
            WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.
        IF AVAIL b_int_ds_cliente THEN DO:

            ASSIGN b_int_ds_cliente.situacao = 2
                   b_int_ds_cliente.envio_status = 08. /* Integrado */
        END.
        RELEASE b_int_ds_cliente.
        ASSIGN l-movto-erro = YES.
        LEAVE.
    END.

    IF AVAIL emitente THEN DO:
       FIND FIRST estabelec WHERE 
                  estabelec.cod-emitente = emitente.cod-emitente NO-LOCK NO-ERROR.
       IF AVAIL estabelec THEN DO:
            
            FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
                WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.
            IF AVAIL b_int_ds_cliente THEN DO:

                ASSIGN b_int_ds_cliente.situacao = 2
                       b_int_ds_cliente.envio_status = 08. /* Integrado */
            END.
            RELEASE b_int_ds_cliente.
          
          LEAVE.
       END.
    END.

    // Busca de cidades do datasul pelo c¢digo IBGE
    
    IF int_ds_cliente.cod_mun_ibge <> ? THEN DO:

        FIND FIRST ems2dis.cidade NO-LOCK
            WHERE ems2dis.cidade.cdn-munpio-ibge = int_ds_cliente.cod_mun_ibge NO-ERROR.
        
        IF NOT AVAIL ems2dis.cidade THEN DO:

            RUN intprg/int999.p (INPUT "CLI", 
                                 INPUT STRING(int_ds_cliente.cgc),
                                 INPUT "C¢digo IBGE da Cidade n∆o cadastrado no Datasul: " + string(int_ds_cliente.cod_mun_ibge),
                                 INPUT 1, /* 1 - Pendente */
                                 INPUT c-seg-usuario,
                                 INPUT "int091.p").
            PUT "C¢digo IBGE da Cidade n∆o cadastrado no Datasul - CPF/CNPJ: " + string(int_ds_cliente.cgc) 
                + " - Nome abreviado: " + int_ds_cliente.nome_abrev
                + " - Cod IBGE: " + string(int_ds_cliente.cod_mun_ibge)
                FORMAT "x(100)".
            PUT SKIP.
            ASSIGN l-movto-erro = YES.
            LEAVE.
        END.
        ELSE DO:

            FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
                WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.

            IF AVAIL b_int_ds_cliente THEN DO:
                
                ASSIGN b_int_ds_cliente.cidade = ems2dis.cidade.cidade
                       b_int_ds_cliente.estado = ems2dis.cidade.estado
                       b_int_ds_cliente.pais   = ems2dis.cidade.pais.
            END.
            RELEASE b_int_ds_cliente.
            
        END.
        
    END.

    // Retornar erro se o nome do cliente inv†lido

    IF int_ds_cliente.nome_emit = ?
    OR int_ds_cliente.nome_emit = "?" 
    OR int_ds_cliente.nome_emit = "" THEN DO:
       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "Nome do Cliente est† branco ou desconhecido. CPF/CNPJ: " + int_ds_cliente.cgc + ".",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                        INPUT "int091.p").

        PUT "Nome do Cliente est† branco ou desconhecido - CPF/CNPJ: " + string(int_ds_cliente.cgc) 
            + " - Nome abreviado: " + int_ds_cliente.nome_abrev
            + " - Nome emitente: " + string(int_ds_cliente.nome_emit)
            FORMAT "x(100)".
        PUT SKIP.

       ASSIGN l-movto-erro = YES.
       LEAVE.
    END.

    // Retornar erro se o nome abreviado estiver em branco

    IF int_ds_cliente.nome_abrev = ?
    OR int_ds_cliente.nome_abrev = "?" 
    OR int_ds_cliente.nome_abrev = "" THEN DO:

        FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
            WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.

        IF AVAIL b_int_ds_cliente THEN DO:
            
            ASSIGN b_int_ds_cliente.nome_abrev = "CL" + SUBSTR(int_ds_cliente.cgc,1,10).
        END.
        RELEASE b_int_ds_cliente.

    END.

    // Retornar erro se o nome abreviado j† existe para outro cliente

    FIND FIRST b_emitente NO-LOCK 
        WHERE b_emitente.nome-abrev = int_ds_cliente.nome_abrev NO-ERROR.
    
    IF AVAIL b_emitente AND int_ds_cliente.tipo_movto = 1 THEN DO:

       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "Nome abreviado j† cadastrado para outro cliente. CPF/CNPJ: " + int_ds_cliente.cgc + ".",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int091.p").

       .MESSAGE string(int_ds_cliente.cgc)
           VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        PUT "Nome abreviado j† cadastrado para outro cliente - CPF/CNPJ: " + string(int_ds_cliente.cgc) 
            + " - Nome abreviado: " + int_ds_cliente.nome_abrev
            FORMAT "x(100)".
        PUT SKIP.

        FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
            WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.

        IF AVAIL b_int_ds_cliente THEN DO:
            
            ASSIGN b_int_ds_cliente.situacao = 2.
        END.
        RELEASE b_int_ds_cliente.

        ASSIGN l-movto-erro = YES.
        LEAVE.
    END.

    // Retornar erro se o CEP estiver em branco

    IF int_ds_cliente.cep = ?
    OR int_ds_cliente.cep = "?" 
    OR int_ds_cliente.cep = "" THEN DO:
       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "CEP do Cliente est† branco ou desconhecido. CPF/CNPJ: " + int_ds_cliente.cgc + ".",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int091.p").

        PUT "CEP do Cliente est† branco ou desconhecido - CPF/CNPJ: " + string(int_ds_cliente.cgc) 
            + " - Nome abreviado: " + int_ds_cliente.nome_abrev
            + " - CEP: " + string(int_ds_cliente.cep)
            FORMAT "x(100)".
        PUT SKIP.

       ASSIGN l-movto-erro = YES.
       LEAVE.
    END.

    // Ajustar cliente pessoa juridica com inscriá∆o estadual nula para ISENTO
    
    IF  int_ds_cliente.natureza = 2 /* Pessoa Jur°dica */
        AND (int_ds_cliente.ins_estadual = "?" 
             OR int_ds_cliente.ins_estadual = ?
             OR int_ds_cliente.ins_estadual = ""
             OR int_ds_cliente.ins_estadual = "I") THEN DO:

            FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
                WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.

            IF AVAIL b_int_ds_cliente THEN DO:
                
                ASSIGN b_int_ds_cliente.ins_estadual = "ISENTO".
            END.
            RELEASE b_int_ds_cliente.

    END.
    IF int_ds_cliente.natureza = 1 THEN DO:

        FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
            WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.

        IF AVAIL b_int_ds_cliente THEN DO:
            
            ASSIGN b_int_ds_cliente.ins_estadual = "ISENTO".
        END.
        RELEASE b_int_ds_cliente.

    END.

    // Se o grupo do cliente vier nulo ou 0 muda para padr∆o 5 (Consumidor)
    
    IF int_ds_cliente.cod_gr_cli = ? 
        OR int_ds_cliente.cod_gr_cli = 0 THEN DO:

        FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
            WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.

        IF AVAIL b_int_ds_cliente THEN DO:          
            ASSIGN b_int_ds_cliente.cod_gr_cli = 10.
        END.
        RELEASE b_int_ds_cliente.

    END.

    // Validar Grupo do cliente

    if not can-find (gr-cli where 
                   gr-cli.cod-gr-cli = int_ds_cliente.cod_gr_cli) then do:

       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "Grupo do Cliente est† branco ou desconhecido. CPF/CNPJ: " + int_ds_cliente.cgc + ".",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int091.p").

        PUT "Grupo do Cliente est† branco ou desconhecido - CPF/CNPJ: " + string(int_ds_cliente.cgc) 
            + " - Nome abreviado: " + int_ds_cliente.nome_abrev
            + " - Grupo cliente: " + string(int_ds_cliente.cod_gr_cli)
            FORMAT "x(100)".
        PUT SKIP.

       ASSIGN l-movto-erro = YES.
       RETURN "NOK".

    END.

    // Trata Matriz do cliente

    IF  int_ds_cliente.cnpj_emp_conv <> ?
       AND int_ds_cliente.cnpj_emp_conv <> "" 
       AND STRING(DEC(int_ds_cliente.cnpj_emp_conv),"99999999999999") <> ? THEN DO:
           
        FIND FIRST b_emitente NO-LOCK
            WHERE b_emitente.cgc = STRING(DEC(int_ds_cliente.cnpj_emp_conv),"99999999999999") NO-ERROR.
        IF AVAIL b_emitente THEN DO:
            ASSIGN c-nome-matriz = b_emitente.nome-abrev.
        END.
        ELSE DO:
            ASSIGN c-nome-matriz = int_ds_cliente.nome_abrev.
        END.

    END.
    ELSE DO:
        ASSIGN c-nome-matriz = int_ds_cliente.nome_abrev.
    END.

    //Ajustar bairro nulo para branco

    IF int_ds_cliente.bairro = ? 
        OR int_ds_cliente.bairro = "?" THEN DO:

        FIND FIRST b_int_ds_cliente EXCLUSIVE-LOCK
            WHERE ROWID(b_int_ds_cliente) = ROWID(int_ds_cliente) NO-ERROR.

        IF AVAIL b_int_ds_cliente THEN DO:
            
            ASSIGN b_int_ds_cliente.bairro = "".
        END.
        RELEASE b_int_ds_cliente.

    END.

END PROCEDURE.

PROCEDURE pi-finaliza-bo:

    IF VALID-HANDLE(h-bo) THEN
        DELETE PROCEDURE h-bo.
    IF VALID-HANDLE(tth-emitente) THEN
        DELETE PROCEDURE tth-emitente.
    IF VALID-HANDLE(bhtt-emitente) THEN
        DELETE PROCEDURE bhtt-emitente.
    FOR EACH tt-bo-erro :
        DELETE tt-bo-erro.
    END.

END PROCEDURE.


RUN pi-finalizar IN h-acomp.

{include/i-rpclo.i /*&STREAM="stream str-rp"*/}

RETURN "OK".
