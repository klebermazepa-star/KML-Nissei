 /****************************************************************************************************
**   Programa: trg-w-emitente.p - Trigger de write para a tabela emitente
**             Atualiza a tabela de integra‡Æo de Fornecedores entre Datasul e Sysfarma
**   Data....: Novembro/2015
*****************************************************************************************************/
  


def new global shared var v_cdn_empres_usuar  LIKE ems2log.empresa.ep-codigo no-undo.
def new global shared var c-seg-usuario as char no-undo.

/* Parameters Definitions ---                                           */

DEFINE TEMP-TABLE tt-param NO-UNDO
    FIELD destino            AS INTEGER
    FIELD arquivo            AS CHAR FORMAT "x(35)":U
    FIELD usuario            AS CHAR FORMAT "x(12)":U
    FIELD data-exec          AS DATE
    FIELD hora-exec          AS INTEGER
    FIELD classifica         AS INTEGER
    FIELD desc-classifica    AS CHAR FORMAT "x(40)":U
    FIELD modelo             AS CHAR FORMAT "x(35)":U
    FIELD l-habilitaRtf      as LOG
    FIELD Situacao           AS INTEGER //0 = Todos, 1 = Pendentes, 2 = Com Erro
    FIELD Tipo               AS INTEGER //0 = Todos, 1 = Cliente, 2 = Forncededor
    FIELD CodClienteFinal    AS INTEGER
    FIELD CodClienteInicial  AS INTEGER
    FIELD DocFinal           AS CHAR
    FIELD DocInicial         AS CHAR
    FIELD GrupoFinal         AS INTEGER
    FIELD GrupoInicial       AS INTEGER
    FIELD NomeAbrevFinal     AS CHAR
    FIELD NomeAbrevInicial   AS CHAR.
 
DEF PARAM BUFFER b-emitente     FOR ems2mult.emitente.
DEF PARAM BUFFER b-old-emitente FOR ems2mult.emitente.

/* Transfer Definitions */

def var raw-param        as raw no-undo.

def temp-table tt-raw-digita
   field raw-digita      as raw.

DEF VAR c-situacao AS CHAR NO-UNDO.
DEF VAR i-cont     AS INT  NO-UNDO.
DEF VAR i-prazo    AS INT  NO-UNDO.
DEF VAR i-pro_codigo_n LIKE int_ds_item_fornec.pro_codigo_n NO-UNDO.
DEF VAR i-alternativo  LIKE int_ds_item_fornec.alternativo  NO-UNDO.
DEF VAR i-tp-movto AS INT NO-UNDO.

/* KML Consultoria Guilherme Nichele - 13/06/2024 - Criar tabela de altera‡Æo para leitura do BI */

FIND FIRST b-emitente  NO-ERROR.

IF AVAIL b-emitente THEN DO:
 
    IF v_cdn_empres_usuar = "10" THEN DO:
    
        create tt-param.
        assign tt-param.usuario         = "RPW"                   
               tt-param.CodClienteFinal   = b-emitente.cod-emitente  
               tt-param.CodClienteInicial = b-emitente.cod-emitente
               tt-param.DocFinal          = b-emitente.cgc 
               tt-param.DocInicial        = b-emitente.cgc  
               tt-param.NomeAbrevFinal    = b-emitente.nome-abrev 
               tt-param.NomeAbrevInicial  = b-emitente.nome-abrev.
        
        FOR EACH integra-emitente WHERE integra-emitente.cod-emitente = b-emitente.cod-emitente EXCLUSIVE-LOCK:
            DELETE integra-emitente.
        END.
    
        CREATE integra-emitente.
        ASSIGN integra-emitente.cod-emitente = b-emitente.cod-emitente
               integra-emitente.dt-alteracao = NOW
               integra-emitente.situacao     = 1
               integra-emitente.retorno-integracao = "". 
               
         RUN custom/eswms002rp.p INPUT(tt-param).
        
    END.
    
    
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "emitente"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.cod-emitente = b-emitente.cod-emitente.
                          
         
 END.

IF  b-emitente.identific > 1 
AND PROGRAM-NAME(10) <> "cdp/cd0401h.w" 
AND PROGRAM-NAME(4) = "intprg/nicd0401.w" THEN DO: /* Fornecedor e Ambos */

    ASSIGN c-situacao = "A".
    FIND FIRST ems2mult.dist-emitente WHERE
               dist-emitente.cod-emitente = b-emitente.cod-emitente NO-LOCK NO-ERROR.
    IF AVAIL dist-emitente THEN DO:
       IF dist-emitente.idi-sit-fornec = 4 THEN
          ASSIGN c-situacao = "I".
    END.

    ASSIGN i-prazo = 0.

    FIND FIRST ems2mult.cond-pagto WHERE 
               cond-pagto.cod-cond-pag = b-emitente.cod-cond-pag NO-LOCK NO-ERROR.
    IF AVAIL cond-pagto THEN DO:
       DO i-cont = 1 TO 12:
          IF cond-pagto.prazos[i-cont] <> 0 THEN
             ASSIGN i-prazo = cond-pagto.prazos[i-cont].
       END.
    END.

    ASSIGN i-tp-movto = 1.
    FIND FIRST int_ds_fornecedor WHERE
               int_ds_fornecedor.codigo     = b-emitente.cod-emitente AND 
               int_ds_fornecedor.tipo_movto = 1 NO-LOCK NO-ERROR.
    IF AVAIL int_ds_fornecedor THEN
       ASSIGN i-tp-movto = 2.

    CREATE int_ds_fornecedor.
    ASSIGN int_ds_fornecedor.envio_status           = 0
           int_ds_fornecedor.tipo_movto             = i-tp-movto
           int_ds_fornecedor.dt_geracao             = TODAY
           int_ds_fornecedor.hr_geracao             = STRING(TIME,"hh:mm:ss") 
           int_ds_fornecedor.cod_usuario            = c-seg-usuario
           int_ds_fornecedor.situacao               = 1 /* Pendente */
           int_ds_fornecedor.codigo                 = b-emitente.cod-emitente
           int_ds_fornecedor.nome                   = substr(b-emitente.nome-emit,1,50)
           int_ds_fornecedor.endereco               = b-emitente.endereco
           int_ds_fornecedor.cidade                 = b-emitente.cidade
           int_ds_fornecedor.estado                 = substr(b-emitente.estado,1,2)
           int_ds_fornecedor.inscricao              = substr(b-emitente.ins-estadual,1,18)
           int_ds_fornecedor.telefone               = b-emitente.telefone[1]
           int_ds_fornecedor.fax                    = b-emitente.telefax
           int_ds_fornecedor.email                  = b-emitente.e-mail
           int_ds_fornecedor.url                    = b-emitente.home-page 
           int_ds_fornecedor.contato                = b-emitente.contato[1]
           int_ds_fornecedor.tipo                   = SUBSTR(b-emitente.atividade,1,1) /* M - Medicamentos / P - Perfumaria / C - Conveniˆncia / D - Diversos */
           int_ds_fornecedor.cep                    = substr(b-emitente.cep,1,9)
           int_ds_fornecedor.cnpj                   = substr(b-emitente.cgc,1,18)
           int_ds_fornecedor.prazo_pagto            = i-prazo
           int_ds_fornecedor.situacao_ativo         = c-situacao
           int_ds_fornecedor.nome_abrev             = b-emitente.nome-abrev
           int_ds_fornecedor.tipo_pessoa            = IF b-emitente.natureza = 1 THEN "F¡sica" ELSE "Jur¡dica"
           int_ds_fornecedor.equivaleds             = "?"
           int_ds_fornecedor.bairro                 = b-emitente.bairro
           int_ds_fornecedor.complemento            = b-emitente.inf-complementar
           int_ds_fornecedor.email_nfe              = b-emitente.e-mail           
           int_ds_fornecedor.importar               = "1"
           int_ds_fornecedor.fluxocaixads           = ""
           int_ds_fornecedor.forma_pgto             = ""    
           int_ds_fornecedor.grupo_desp             = SUBSTR(STRING(b-emitente.tp-desp-padrao),1,2)  
           int_ds_fornecedor.gera_prov              = "S" 
           int_ds_fornecedor.gera_lanc              = "S" 
           int_ds_fornecedor.aplicaredutorsn        = "N" 
           int_ds_fornecedor.perc_verba             = 0 
           int_ds_fornecedor.liberacaolab           = "N" 
           int_ds_fornecedor.calculostvalordesconto = "N"
           int_ds_fornecedor.cod_gr_forn            = b-emitente.cod-gr-forn
           int_ds_fornecedor.id_sequencial          = NEXT-VALUE(seq-int-ds-fornecedor). /* Prepara‡Æo para integra‡Æo com Procfit */

    FIND FIRST int_ds_ext_emitente WHERE
               int_ds_ext_emitente.cod_emitente = b-emitente.cod-emitente NO-LOCK NO-ERROR.
    IF AVAIL int_ds_ext_emitente THEN DO:
       ASSIGN int_ds_fornecedor.protocolodevolucao = IF int_ds_ext_emitente.protocolodevolucao = YES THEN "S" ELSE "N"
              int_ds_fornecedor.emitedanfe         = IF int_ds_ext_emitente.emitedanfe         = YES THEN "S" ELSE "N"
              int_ds_fornecedor.databloqueio       = int_ds_ext_emitente.databloqueio
              int_ds_fornecedor.biometriamotorista = IF int_ds_ext_emitente.biometriamotorista = YES THEN "S" ELSE "N"
              int_ds_fornecedor.microempresa       = IF int_ds_ext_emitente.microempresa       = YES THEN "S" ELSE "N"
              int_ds_fornecedor.prazo_entrega      = int_ds_ext_emitente.prazo_entrega
              int_ds_fornecedor.eancnpj            = substr(int_ds_ext_emitente.eancnpj,1,13)
              int_ds_fornecedor.tipo_trib          = IF int_ds_ext_emitente.tipo_trib          = 1 THEN "D" ELSE "T"
              int_ds_fornecedor.industria          = IF int_ds_ext_emitente.industria          = YES THEN "S" ELSE "N"
              int_ds_fornecedor.emitenotadevolucao = IF int_ds_ext_emitente.emitenotadevolucao = YES THEN "S" ELSE "N"
              int_ds_fornecedor.excecaoindustria   = IF int_ds_ext_emitente.excecaoindustria   = YES THEN "S" ELSE "N".
    END.

    ASSIGN int_ds_fornecedor.envio_status = 1.

    RELEASE int_ds_fornecedor.

END.

RETURN "OK".


