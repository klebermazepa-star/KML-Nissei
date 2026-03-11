/********************************************************************************
**
**  Programa: int083rp.p - API - Integra��o Clientes
**
********************************************************************************/                                                                

/* include de controle de versÆo */
{include/i-prgvrs.i INT083API 1.00.00.000}  /*** 010000 ***/

{utp/ut-glob.i}
{cdp/cdcfgdis.i}


def new global shared var c-seg-usuario as char no-undo.

DEFINE TEMP-TABLE tt-bo-erro NO-UNDO
    FIELD i-sequen     AS INT 
    FIELD cd-erro      AS INT
    FIELD mensagem     AS CHAR      FORMAT "x(255)"
    FIELD parametros   AS CHAR      FORMAT "x(255)" INIT ""
    FIELD errortype    AS CHAR      FORMAT "x(20)"
    FIELD errorhelp    AS CHAR      FORMAT "x(20)"
    FIELD errorsubtype AS CHARACTER.

DEFINE TEMP-TABLE tt-cliente NO-UNDO
    FIELD CNPJ          AS CHAR
    FIELD nome          AS CHAR
    FIELD nome-abrev    AS CHAR
    FIELD natureza      AS INT // 1 - Fisica ** 2 - Juridica
    FIELD ins-estadual  AS CHAR
    FIELD cep           AS CHAR
    FIELD tipo_endereco AS CHAR
    FIELD endereco      AS CHAR
    FIELD numero        AS CHAR
    FIELD complemento   AS CHAR
    FIELD bairro        AS CHAR
    FIELD cidade        AS CHAR
    FIELD cod-ibge      AS CHAR
    FIELD estado        AS CHAR
    FIELD pais          AS CHAR
    FIELD referencia    AS CHAR
    FIELD telefone      AS CHAR
    FIELD celular       AS CHAR.
    
        
DEFINE TEMP-TABLE tt-valida NO-UNDO
    FIELD desc-erro     AS CHAR
    FIELD Nome_abrev    AS CHAR
    FIELD l-erro        AS LOGICAL.

    
DEF INPUT PARAMETER TABLE FOR tt-cliente.
DEF OUTPUT PARAMETER TABLE FOR tt-valida.

DEF VAR h-acomp             AS HANDLE   NO-UNDO.
DEF VAR l-movto-com-erro    AS LOGICAL  NO-UNDO.
def var i-erro              as integer init 0 NO-UNDO.
def var c-informacao        as char format "x(256)" NO-UNDO.

DEFINE VARIABLE tth-emitente    AS HANDLE        NO-UNDO.
DEFINE VARIABLE bhtt-emitente   AS HANDLE        NO-UNDO.
DEF    VAR      h-bo            AS HANDLE        NO-UNDO.
DEFINE VARIABLE i-emitente      AS INTEGER     NO-UNDO.
DEF    VAR      r-chave         AS ROWID         NO-UNDO.
DEFINE VARIABLE i-identific     AS INTEGER NO-UNDO.
DEFINE VARIABLE hb-emitente     AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h-query         AS WIDGET-HANDLE NO-UNDO.

/* DefiniÆo da vari veis */
def var h-bodi317pr                   as handle no-undo.
def var h-bodi317sd                   as handle no-undo.
def var h-bodi317im1bra               as handle no-undo.
def var h-bodi317va                   as handle no-undo.
def var h-bodi317in                   as handle no-undo.
def var h-bodi317ef                   as handle no-undo.
def var l-proc-ok-aux                 as log    no-undo.
def var c-ultimo-metodo-exec          as char   no-undo.
def var c-cod-estabel                 as char   no-undo.
def var c-serie                       as char   no-undo.
def var da-dt-emis-nota               as date   no-undo.
def var da-dt-base-dup                as date   no-undo.
def var da-dt-prvenc                  as date   no-undo.
//def var c-seg-usuario                 as char   no-undo.
def var c-nome-abrev                  as char   no-undo.   
def var c-nr-pedcli                   as char   no-undo.
def var c-nat-operacao                as char   no-undo.
def var c-cod-canal-venda             as char   no-undo.
DEF VAR d-vl-frete                    AS DEC    NO-UNDO.
def var i-seq-wt-docto                as int    no-undo.
def var i-seq-wt-it-docto             as int    no-undo.
def var i-cont-itens                  as int    no-undo. 
def var c-it-codigo                   as char   no-undo.
def var c-cod-refer                   as char   no-undo.
def var de-quantidade                 as dec    no-undo.
def var de-vl-preori-ped              as dec    no-undo.
def var de-val-pct-desconto-tab-preco as dec    no-undo.
def var de-per-des-item               as dec    no-undo.
DEFINE VARIABLE c-tipo-pedido         AS INT   NO-UNDO.

/* Def temp-table de erros. Ela tbm est  definida na include dbotterr.i */
def temp-table rowerrors no-undo
    field errorsequence    as int
    field errornumber      as int
    field errordescription as char
    field errorparameters  as char
    field errortype        as char
    field errorhelp        as char
    field errorsubtype     as char.
    
DEFINE BUFFER b-emitente FOR emitente.
    
    
log-manager:write-message("dentro da API") no-error.
// CADASTRO DE CLIENTE

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Processando").
FOR EACH tt-cliente:


  //  ASSIGN tt-cliente.natureza = 1. // forando cliente pessoa fisica

    log-manager:write-message("encontrou tt-cliente") no-error.
    log-manager:write-message("KML - Dentro API - Nome - " + tt-cliente.nome) no-error.
    log-manager:write-message("encontrou" + tt-cliente.cnpj) no-error.

    RUN p_valida_cliente (OUTPUT l-movto-com-erro).

    FIND FIRST emitente NO-LOCK
        WHERE emitente.cgc = tt-cliente.cnpj NO-ERROR.

    IF AVAIL emitente THEN DO:         

        MESSAGE "ANTES ALTERAÇO CLIENTE"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        RUN p_altera_cliente ( INPUT emitente.cod-emitente,
                               OUTPUT l-movto-com-erro).
        log-manager:write-message("cliente ja existe") no-error.

        IF l-movto-com-erro = NO THEN DO:

            FIND FIRST emitente NO-LOCK
                WHERE emitente.cgc = tt-cliente.cnpj NO-ERROR.
            IF AVAIL emitente THEN
                //RUN p_gera_pedido(INPUT emitente.cod-emitente).
        END.
    END.
    ELSE DO:

        log-manager:write-message("cliente n�o existe, criar cliente") no-error.
        
        IF l-movto-com-erro = NO THEN DO:
            ASSIGN i-emitente = 0.
            RUN p_cria_cliente ( OUTPUT i-emitente).
            IF i-emitente <> 0 THEN DO:
                log-manager:write-message("criou cliente, antes gera pedido") no-error.
                //RUN p_gera_pedido(INPUT i-emitente).
            END.
        END.
    END.
END.

run pi-finalizar in h-acomp.

PROCEDURE p_cria_cliente:

    DEFINE OUTPUT PARAMETER i-cod-emitente AS INTEGER NO-UNDO.

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

    FIND FIRST ems2dis.cidade NO-LOCK
        WHERE cidade.cdn-munpio-ibge = int(tt-cliente.cod-ibge) NO-ERROR.
    IF AVAIL cidade THEN DO:
        ASSIGN tt-cliente.cidade = cidade.cidade.
    END.

    ASSIGN bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE  = i-emitente
           bhtt-emitente:BUFFER-FIELD("end-cobranca"):BUFFER-VALUE  = i-emitente
           bhtt-emitente:BUFFER-FIELD("nome-abrev"):BUFFER-VALUE    = tt-cliente.nome-abrev
           bhtt-emitente:BUFFER-FIELD("nome-matriz"):BUFFER-VALUE   = tt-cliente.nome-abrev
           bhtt-emitente:BUFFER-FIELD("cgc"):BUFFER-VALUE           = tt-cliente.cnpj
           bhtt-emitente:BUFFER-FIELD("identific"):BUFFER-VALUE     = 1 /* sempre cliente */
           bhtt-emitente:BUFFER-FIELD("natureza"):BUFFER-VALUE      = tt-cliente.natureza 
           bhtt-emitente:BUFFER-FIELD("nome-emit"):BUFFER-VALUE     = tt-cliente.nome
           bhtt-emitente:BUFFER-FIELD("endereco"):BUFFER-VALUE      = tt-cliente.endereco + "," + tt-cliente.numero
           bhtt-emitente:BUFFER-FIELD("bairro"):BUFFER-VALUE        = SUBSTRING(tt-cliente.bairro,1,30)
           bhtt-emitente:BUFFER-FIELD("cidade"):BUFFER-VALUE        = tt-cliente.cidade
           bhtt-emitente:BUFFER-FIELD("estado"):BUFFER-VALUE        = tt-cliente.estado
           bhtt-emitente:BUFFER-FIELD("cep"):BUFFER-VALUE           = tt-cliente.cep 
           bhtt-emitente:BUFFER-FIELD("pais"):BUFFER-VALUE          = tt-cliente.pais 
           bhtt-emitente:BUFFER-FIELD("cod-gr-cli"):BUFFER-VALUE    = 5 // fixo at que seja pensado cliente convenio para e-commerce
           bhtt-emitente:BUFFER-FIELD("portador"):BUFFER-VALUE      = 99999 
           bhtt-emitente:BUFFER-FIELD("modalidade"):BUFFER-VALUE    = 6
           bhtt-emitente:BUFFER-FIELD("cod-rep"):BUFFER-VALUE       = 1
           bhtt-emitente:BUFFER-FIELD("cod-transp"):BUFFER-VALUE    = 99999
           bhtt-emitente:BUFFER-FIELD("tp-rec-padrao"):BUFFER-VALUE = 208
           bhtt-emitente:BUFFER-FIELD("endereco-cob"):BUFFER-VALUE  = tt-cliente.endereco + "," + tt-cliente.numero
           bhtt-emitente:BUFFER-FIELD("bairro-cob"):BUFFER-VALUE    = SUBSTRING(tt-cliente.bairro,1,30)
           bhtt-emitente:BUFFER-FIELD("cidade-cob"):BUFFER-VALUE    = tt-cliente.cidade
           bhtt-emitente:BUFFER-FIELD("estado-cob"):BUFFER-VALUE    = tt-cliente.estado
           bhtt-emitente:BUFFER-FIELD("cep-cob"):BUFFER-VALUE       = tt-cliente.cep 
           bhtt-emitente:BUFFER-FIELD("pais-cob"):BUFFER-VALUE      = tt-cliente.pais 
           bhtt-emitente:BUFFER-FIELD("cgc-cob"):BUFFER-VALUE       = tt-cliente.cnpj
           bhtt-emitente:BUFFER-FIELD("ins-estadual"):BUFFER-VALUE  = IF tt-cliente.natureza = 1 THEN "ISENTO" ELSE tt-cliente.ins-estadual
           bhtt-emitente:BUFFER-FIELD("contrib-icms"):BUFFER-VALUE  = NO
           bhtt-emitente:BUFFER-FIELD("ins-est-cob"):BUFFER-VALUE   = IF tt-cliente.natureza = 1 THEN "ISENTO" ELSE tt-cliente.ins-estadual
           bhtt-emitente:BUFFER-FIELD("modalidade-ap"):BUFFER-VALUE = 6
           bhtt-emitente:BUFFER-FIELD("tp-desp-padrao"):BUFFER-VALUE = 407
           bhtt-emitente:BUFFER-FIELD("cod-gr-forn"):BUFFER-VALUE   = 10.

    RUN validateCreate IN h-bo (INPUT TABLE-HANDLE tth-emitente, OUTPUT TABLE tt-bo-erro, OUTPUT r-chave).


    FIND FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE NO-ERROR.

    IF AVAIL emitente THEN DO:
        
        run cdp/cd1608.p (input bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE,
                      input bhtt-emitente:BUFFER-FIELD("cod-emitente"):BUFFER-VALUE,
                      input 1,
                      input yes,
                      input 1,
                      input 0,
                      input session:temp-dir + "integracaoEMS5.txt",
                      input "Arquivo",
                      input "").
        ASSIGN i-cod-emitente = emitente.cod-emitente.

        RUN pi-cria-int-ds-cliente.
    END.
    FOR FIRST tt-bo-erro:

        RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(tt-cliente.cnpj),
                            INPUT string(tt-bo-erro.mensagem) + " - CPF/CNPJ: " + string(tt-cliente.cnpj) + ".",
                            INPUT 1, /* 2 - Integrado */
                            INPUT c-seg-usuario,
                            INPUT "int083api.p").

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
    
    FIND FIRST loc-entr EXCLUSIVE-LOCK
        WHERE loc-entr.nome-abrev  = emitente.nome-abrev 
          AND loc-entr.cod-entrega = "PadrÆo" NO-ERROR.

    IF AVAIL emitente THEN DO:
        
        IF NOT AVAIL loc-entr THEN DO:
            CREATE loc-entr.
            ASSIGN loc-entr.nome-abrev  = emitente.nome-abrev  
                    loc-entr.cod-entrega = "PadrÆo".            
        END.
        ASSIGN loc-entr.endereco     = emitente.endereco
               loc-entr.bairro       = emitente.bairro
               loc-entr.cidade       = emitente.cidade
               loc-entr.estado       = emitente.estado
               loc-entr.pais         = emitente.pais
               loc-entr.cep          = emitente.cep
               loc-entr.ins-estadual = emitente.ins-estadual
               loc-entr.cgc          = emitente.cgc.
    END.

    RELEASE loc-entr.

    RUN intprg/int999.p (INPUT "CLI", 
                        INPUT STRING(tt-cliente.cnpj),
                        INPUT "Cliente integrado com sucesso - CPF/CNPJ: " + string(tt-cliente.cnpj) + ".",
                        INPUT 2, /* 2 - Integrado */
                        INPUT c-seg-usuario,
                        INPUT "int083api.p").

    
    
END PROCEDURE.

PROCEDURE p_altera_cliente:

    DEFINE INPUT PARAMETER i-cod-emitente AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER l-movto-erro AS LOGICAL NO-UNDO.

    ASSIGN l-movto-erro = NO.


    FIND FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = i-cod-emitente NO-ERROR.
    IF AVAIL emitente THEN DO:
    
        FIND FIRST ems2dis.cidade NO-LOCK
            WHERE cidade.cdn-munpio-ibge = int(tt-cliente.cod-ibge) NO-ERROR.
        IF AVAIL cidade THEN DO:
            ASSIGN tt-cliente.cidade = cidade.cidade.
        END.
            // kml
        MESSAGE "ALTERANDO CLIENTE" SKIP
                "ENDERECO - " tt-cliente.endereco
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        FIND FIRST b-emitente EXCLUSIVE-LOCK
            WHERE b-emitente.cod-emitente = emitente.cod-emitente NO-ERROR.

        IF LOCKED b-emitente THEN DO:

           CREATE tt-valida.
           ASSIGN tt-valida.l-erro      = NO
                  tt-valida.desc-erro   = "Tabela emitente em lock NO banco".
    
    
           ASSIGN l-movto-erro = YES.

           undo, leave.

        END.
        
        log-manager:write-message("TESTE CIDADE - " + tt-cliente.cidade) no-error.
        IF AVAIL b-emitente THEN DO:
            
            CREATE tt-valida.
            ASSIGN b-emitente.natureza      = tt-cliente.natureza 
                   b-emitente.nome-emit     = tt-cliente.nome
                   b-emitente.endereco      = tt-cliente.endereco + "," + tt-cliente.numero
                   b-emitente.bairro        = SUBSTRING(tt-cliente.bairro,1,30)
                   //b-emitente.cod-gr-cli    = 05 // InclusÆo KML para corrigir erro na integraÆo com o Financeiro
                   b-emitente.cidade        = tt-cliente.cidade
                   b-emitente.estado        = tt-cliente.estado
                   b-emitente.cep           = tt-cliente.cep 
                   b-emitente.pais          = tt-cliente.pais 
                   b-emitente.endereco-cob  = tt-cliente.endereco + "," + tt-cliente.numero
                   b-emitente.bairro-cob    = SUBSTRING(tt-cliente.bairro,1,30)
                   b-emitente.cidade-cob    = tt-cliente.cidade
                   b-emitente.estado-cob    = tt-cliente.estado
                   b-emitente.cep-cob       = tt-cliente.cep 
                   b-emitente.pais-cob      = tt-cliente.pais
                   b-emitente.contrib-icms  = NO
                   tt-valida.l-erro         = YES
                   tt-valida.nome_abrev     = b-emitente.nome-abrev.
        END.
        RELEASE b-emitente.

        RUN pi-cria-int-ds-cliente.
                    
        FIND FIRST loc-entr EXCLUSIVE-LOCK
            WHERE loc-entr.nome-abrev  = emitente.nome-abrev 
              AND loc-entr.cod-entrega = "PadrÆo" NO-ERROR.

    
        IF NOT AVAIL loc-entr THEN DO:
            CREATE loc-entr.
            ASSIGN loc-entr.nome-abrev  = emitente.nome-abrev  
                    loc-entr.cod-entrega = "PadrÆo".            
        END.
        
        ASSIGN loc-entr.endereco     = emitente.endereco
               loc-entr.bairro       = emitente.bairro
               loc-entr.cidade       = emitente.cidade
               loc-entr.estado       = emitente.estado
               loc-entr.pais         = emitente.pais
               loc-entr.cep          = emitente.cep
               loc-entr.ins-estadual = emitente.ins-estadual
               loc-entr.cgc          = emitente.cgc.
            
    END.
    RELEASE emitente.
    RELEASE loc-entr.
    
END PROCEDURE.

PROCEDURE p_valida_cliente:

    DEFINE OUTPUT PARAMETER l-movto-erro AS LOGICAL NO-UNDO.

    ASSIGN l-movto-erro = NO.

    // Retornar erro se o CPF/CNPJ estiver em branco
    IF tt-cliente.cnpj = ?
    OR tt-cliente.cnpj = "?" 
    OR tt-cliente.cnpj = "" THEN DO:

       CREATE tt-valida.
       ASSIGN tt-valida.l-erro      = NO
              tt-valida.desc-erro   = "CNPJ/CPF est� branco ou desconhecido".


       ASSIGN l-movto-erro = YES.
      // LEAVE.
    END.
    
    // Ajustando formato do CNPJ e CPF

    IF tt-cliente.natureza = 1 /*Pessoa Fisica */ THEN DO:
        ASSIGN tt-cliente.cnpj = string(int64(tt-cliente.cnpj), "99999999999").
    END.
    ELSE DO:
        ASSIGN tt-cliente.cnpj = string(int64(tt-cliente.cnpj), "99999999999999").
    END.

    ASSIGN tt-cliente.nome-abrev = STRING( "CL" + substring(trim(string(DEC(tt-cliente.cnpj))),1,10)).

    /*
    FIND FIRST emitente NO-LOCK
        WHERE emitente.nome-abrev = tt-cliente.nome-abrev NO-ERROR.

    IF AVAIL emitente THEN DO:

        CREATE tt-nota-fiscal.
        ASSIGN tt-nota-fiscal.cod-estabel = ""
               tt-nota-fiscal.nr-nota-fis = ""
               tt-nota-fiscal.serie       = ""
               tt-nota-fiscal.l-gerada    = NO
               tt-nota-fiscal.desc-erro   = "Nome abreviado ja existe na base".


       ASSIGN l-movto-erro = YES.
       MESSAGE "nome abreviado ja existe"
           VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
       //LEAVE.
                                                     

    END.
      */
    // Retornar erro se o nome do cliente inv lido

    IF tt-cliente.nome = ?
    OR tt-cliente.nome = "?" 
    OR tt-cliente.nome = "" THEN DO:

       CREATE tt-valida.
       ASSIGN tt-valida.l-erro      = NO
              tt-valida.desc-erro   = "Nome do Cliente est� branco ou desconhecido".



       ASSIGN l-movto-erro = YES.
      // LEAVE.
    END.
  
    // Retornar erro se o CEP estiver em branco

    IF tt-cliente.cep = ?
    OR tt-cliente.cep = "?" 
    OR tt-cliente.cep = "" THEN DO:

        CREATE tt-valida.
           ASSIGN tt-valida.l-erro      = NO
                  tt-valida.desc-erro   = "CEP do Cliente est� branco ou desconhecido".
/*         ASSIGN tt-nota-fiscal.cod-estabel = ""  */
/*                tt-nota-fiscal.nr-nota-fis = ""  */
/*                tt-nota-fiscal.serie       = ""  */
/*                tt-nota-fiscal.chave-acesso = "" */
/*                tt-nota-fiscal.l-gerada    = NO  */
               

       ASSIGN l-movto-erro = YES.
      // LEAVE.
    END.

END PROCEDURE.

PROCEDURE pi-cria-int-ds-cliente:

    FOR FIRST ems2dis.cidade NO-LOCK
        WHERE cidade.cidade = emitente.cidade
        AND   cidade.estado = emitente.estado
        AND   cidade.pais   = emitente.pais  : END.


    CREATE INT_DS_CLIENTE.
    CREATE tt-valida.
    ASSIGN int_ds_cliente.bairro            = emitente.bairro
           int_ds_cliente.cep               = emitente.cep   
           int_ds_cliente.cgc               = emitente.cgc   
           int_ds_cliente.cidade            = emitente.cidade
           int_ds_cliente.estado            = emitente.estado
           int_ds_cliente.pais              = emitente.pais
           int_ds_cliente.cod_emitente      = emitente.cod-emitente
           int_ds_cliente.cod_gr_cli        = emitente.cod-gr-cli
           int_ds_cliente.cod_mun_ibge      = cidade.cdn-munpio-ibge
           int_ds_cliente.cod_usuario       = c-seg-usuario
           int_ds_cliente.dt_geracao        = TODAY
           int_ds_cliente.endereco          = emitente.endereco
           int_ds_cliente.hr_geracao        = ""
           int_ds_cliente.identific         = emitente.identific
           int_ds_cliente.ins_estadual      = emitente.ins-estadual
           int_ds_cliente.natureza          = emitente.natureza
           int_ds_cliente.nome_abrev        = emitente.nome-abrev
           int_ds_cliente.nome_emit         = emitente.nome-emit
           int_ds_cliente.origem_cli        = 3
           int_ds_cliente.cnpj_emp_conv     = ""
           int_ds_cliente.ENVIO_DATA_HORA   = NOW
           int_ds_cliente.ENVIO_ERRO        = ""
           int_ds_cliente.ENVIO_STATUS      = 1
           int_ds_cliente.ID_SEQUENCIAL     = NEXT-VALUE(seq_int_ds_cliente)
           int_ds_cliente.retorno_validacao = ""
           int_ds_cliente.situacao          = 2
           int_ds_cliente.tipo_movto        = 1
           tt-valida.l-erro                = YES
           tt-valida.nome_abrev            = int_ds_cliente.nome_abrev.

    RELEASE INT_DS_CLIENTE. 

END PROCEDURE.
