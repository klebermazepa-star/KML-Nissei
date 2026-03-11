/********************************************************************************
** Programa: INT022 - Retorno de Notas Fiscais NDD
**
** Versao : 12 - 01/04/2016 - Alessandro V Baccin
**
********************************************************************************/
/* KIND 
0 Œ Envio;
1 Œ Cancelamento;
2 Œ Inutilizaá∆o;
3 Œ Impress∆o;
4 Œ DPEC;
5 Œ Erros;
6 Œ Substituiá∆o;
7 Œ Evento;
8 Œ procEvento;
9 Œ Rejeiá∆o ADe;
10 Œ EPEC.
11 Œ Retorno auditoria Vaccine;
12 Œ Retorno da consulta de documentos MDF-e n∆o encerrados.
*/

/* include de controle de versao */
{include/i-prgvrs.i INT022RP 2.12.01.AVB}
{cdp/cdcfgdis.i}

/* definiÁao das temp-tables para recebimento de parametros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def temp-table tt-raw-digita
        field raw-digita	as raw.

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
ASSIGN tt-param.arquivo = "INT022.txt"
       tt-param.destino = 3
       tt-param.data-exec = TODAY
       tt-param.hora-exec = TIME.

/* include padrao para vari·veis de relatÛrio  */
{include/i-rpvar.i}


/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
def var h-acomp         as handle no-undo.
def var r-rowid         as rowid no-undo.
def var h-bodi135       as handle no-undo.
def var h-boin090       as handle no-undo.
def var cRetorno        as longchar no-undo.
def var c-mensagem      as char format "X(50)" no-undo.
def var c-informacao    as char format "X(100)" no-undo.

define temp-table tt-retorno-emissao
    field idMovto   as int64
    field infProt   as char
    field tpAmb     as char
    field verAplic  as char
    field chNFe     as char
    field dhRecbto  as char
    field nProt     as char
    field digVal    as char
    field cStat     as char
    field xMotivo   as char
    field tpEmis    as char
    field chNFe2    as char
    index chave idMovto.

define temp-table tt-retorno-cancelamento
    field idMovto   as int64
    field Id        as char 
    field cStat     as char 
    field xMotivo   as char 
    field chNFe     as char 
    field dhRecbto  as char 
    field nProt     as char 
    field chNFe2    as char 
    index chave idMovto.

define temp-table tt-retorno-inutilizacao
    field idMovto   as int64
    field Id        as char  
    field tpAmb     as char  
    field verAplic  as char  
    field cStat     as char  
    field xMotivo   as char  
    field cUF       as char  
    field ano       as char  
    field CNPJ      as char  
    field modelo    as char  
    field serie     as char  
    field nNFIni    as char  
    field nNFFin    as char  
    field dhRecbto  as char   
    field nProt     as char   
    index chave idMovto.

define temp-table tt-retorno-impressao
    field idMovto    as int64
    field chave      as char
    field statusnum  as char /* 1 -Imp / 2 Nao Imp */
    field statusDesc as char /* Impresso / Nao Impresso*/
    field tpImp      as char
    field tpImpDesc  as char
    field tpOp       as char
    field tpOpDesc   as char
    index chave idMovto.

DEFINE TEMP-TABLE ttReturnInvoiceDocument NO-UNDO
    FIELD chNFe     AS CHARACTER INITIAL ?  /* Chaves de acesso da NF-e, compostas por: UF do emitente, AAMM da emiss∆o da NFe, CNPJ do emitente, modelo, sÇrie e n£mero da NF-e e c¢digo numÇrico+DV. */
    FIELD cStat     AS CHARACTER INITIAL ?  /* C¢digo do status da mensagem enviada. */
    FIELD dhRecbto  AS CHARACTER INITIAL ?  /* Data e hora de processamento, no formato AAAA-MM-DDTHH:MM:SS. Deve ser preenchida com data e hora da gravaá∆o no Banco em caso de Confirmaá∆o. Em caso de Rejeiá∆o, com data e hora do recebimento do Lote de NF-e enviado. */
    FIELD digVal    AS CHARACTER INITIAL ?  /* Digest Value da NF-e processada. Utilizado para conferir a integridade da NF-e original. */
    FIELD id        AS CHARACTER INITIAL ?  
    FIELD nProt     AS CHARACTER            /* N£mero do Protocolo de Status da NF-e. 1 posiá∆o (1 Œ Secretaria de Fazenda Estadual 2 Œ Receita Federal); 2 - c¢diga da UF - 2 posiá‰es ano; 10 seqÅencial no ano. */
    FIELD Signature AS CHARACTER INITIAL ?  
    FIELD tpAmb     AS CHARACTER INITIAL ?  /* Identificaá∆o do Ambiente: 1 - Produá∆o 2 - Homologaá∆o */
    FIELD verAplic  AS CHARACTER INITIAL ?  /* Vers∆o do Aplicativo que processou a NF-e */
    FIELD versao    AS DECIMAL   INITIAL ?  /* Vers∆o do Layout */
    FIELD xMotivo   AS CHARACTER INITIAL ?  /* Descriá∆o literal do status do serviáo solicitado. */
    FIELD tpEmis    AS CHARACTER INITIAL ?  /* Tipo Emissao:  1- Normal, 2- Contingencia SCAN, 3- Contingencia Off-line */
    FIELD lDanfe    AS LOGICAL.             /* NO - "Danfe N∆o Impresso na Aplicaá∆o de Transmiss∆o" e YES - "Danfe Impresso na Aplicaá∆o de Transmiss∆o" */


def var i-ind as integer no-undo.

{utp/ut-glob.i}

/* definiÁao de frames do relatÛrio */
form c-mensagem       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 300
     down stream-io frame f-erro.

/* include com a definiÁao da frame de cabeÁalho e rodapÈ */
{include/i-rpcab.i}
/* bloco principal do programa */

{utp/utapi019.i}

find first tt-param no-lock no-error.
assign c-programa       = "INT022RP"
       c-versao         = "2.12"
       c-revisao        = ".01.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Retorno de Notas Fiscais NDD".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

if not valid-handle(h-boin090) then run inbo/boin090.p persistent set h-boin090.
if not valid-handle(h-bodi135) then run dibo/bodi135.p persistent set h-bodi135.

IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i}
                     
    view frame f-cabec.
    view frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Processando").

run pi-elimina-tabelas.
run pi-importa.
run pi-processa.
run pi-elimina-tabelas.
RUN pi-finaliza-bos.

run pi-finalizar in h-acomp.

IF tt-param.arquivo <> "" THEN DO:
    /* fechamento do output do relatorio  */
    {include/i-rpclo.i }
END.
/* elimina BO's */
return "OK".

/* procedures */
procedure pi-elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   /*empty temp-table RowErrors.   */
   empty temp-table tt-retorno-emissao.
   empty temp-table tt-retorno-cancelamento.
   empty temp-table tt-retorno-inutilizacao.
   empty temp-table tt-retorno-impressao.
   empty temp-table tt-envio2.
   empty temp-table tt-mensagem.
end.        

procedure pi-importa:
    run pi-acompanhar in h-acomp (input "Lendo Retornos").

    for each int-ndd-retorno no-lock where 
        /*int-ndd-retorno.STATUSNUMBER = 0 /* A PROCESAR */*/
        int-ndd-retorno.id = 1106
        query-tuning(no-lookahead)
        by int-ndd-retorno.id:

        copy-lob int-ndd-retorno.DOCUMENTDATA to cRetorno.
        run pi-acompanhar in h-acomp (input "Retorno: " + trim(string(int-ndd-retorno.ID))).

        case int-ndd-retorno.KIND:
            when 0 /* Envio */ then do:
                create  tt-retorno-emissao.
                assign  tt-retorno-emissao.idMovto   = int-ndd-retorno.ID.
                assign  tt-retorno-emissao.infProt   = entry(1,cRetorno,";") 
                        tt-retorno-emissao.tpAmb     = entry(2,cRetorno,";") 
                        tt-retorno-emissao.verAplic  = entry(3,cRetorno,";") 
                        tt-retorno-emissao.chNFe     = entry(4,cRetorno,";") 
                        tt-retorno-emissao.dhRecbto  = entry(5,cRetorno,";") 
                        tt-retorno-emissao.nProt     = entry(6,cRetorno,";") 
                        tt-retorno-emissao.digVal    = entry(7,cRetorno,";") 
                        tt-retorno-emissao.cStat     = entry(8,cRetorno,";") 
                        tt-retorno-emissao.xMotivo   = entry(9,cRetorno,";") 
                        tt-retorno-emissao.tpEmis    = entry(10,cRetorno,";")
                        tt-retorno-emissao.chNFe2    = entry(11,cRetorno,";").
                
            end.
            when 1 /* Cancelamento */ then do:
                create  tt-retorno-cancelamento.
                assign  tt-retorno-cancelamento.idMovto   = int-ndd-retorno.ID.
                assign  tt-retorno-cancelamento.Id        = entry(1,cRetorno,";") 
                        tt-retorno-cancelamento.cStat     = entry(2,cRetorno,";") 
                        tt-retorno-cancelamento.xMotivo   = entry(3,cRetorno,";") 
                        tt-retorno-cancelamento.chNFe     = entry(4,cRetorno,";") 
                        tt-retorno-cancelamento.dhRecbto  = entry(5,cRetorno,";") 
                        tt-retorno-cancelamento.nProt     = entry(6,cRetorno,";") 
                        tt-retorno-cancelamento.chNFe2    = entry(7,cRetorno,";").
            end.
            when 2 /* Inutilizacao */ then do:
                create  tt-retorno-inutilizacao.
                assign  tt-retorno-inutilizacao.idMovto   = int-ndd-retorno.ID.
                assign  tt-retorno-inutilizacao.Id        = entry(1,cRetorno,";")  
                        tt-retorno-inutilizacao.tpAmb     = entry(2,cRetorno,";")  
                        tt-retorno-inutilizacao.verAplic  = entry(3,cRetorno,";")  
                        tt-retorno-inutilizacao.cStat     = entry(4,cRetorno,";")  
                        tt-retorno-inutilizacao.xMotivo   = entry(5,cRetorno,";")  
                        tt-retorno-inutilizacao.cUF       = entry(6,cRetorno,";")  
                        tt-retorno-inutilizacao.ano       = entry(7,cRetorno,";")  
                        tt-retorno-inutilizacao.CNPJ      = entry(8,cRetorno,";")  
                        tt-retorno-inutilizacao.modelo    = entry(9,cRetorno,";")  
                        tt-retorno-inutilizacao.serie     = entry(10,cRetorno,";")  
                        tt-retorno-inutilizacao.nNFIni    = entry(11,cRetorno,";")  
                        tt-retorno-inutilizacao.nNFFin    = entry(12,cRetorno,";")  
                        tt-retorno-inutilizacao.dhRecbto  = entry(13,cRetorno,";")   
                        tt-retorno-inutilizacao.nProt     = entry(14,cRetorno,";").
            end.
            when 3 /* Impressao */ then do:
                create  tt-retorno-impressao.
                assign  tt-retorno-impressao.idMovto    = int-ndd-retorno.ID.
                assign  tt-retorno-impressao.chave      = entry(1,cRetorno,";")
                        tt-retorno-impressao.statusnum  = entry(2,cRetorno,";") 
                        tt-retorno-impressao.statusDesc = entry(3,cRetorno,";") 
                        tt-retorno-impressao.tpImp      = entry(4,cRetorno,";")
                        tt-retorno-impressao.tpImpDesc  = entry(5,cRetorno,";")
                        tt-retorno-impressao.tpOp       = entry(6,cRetorno,";")
                        tt-retorno-impressao.tpOpDesc   = entry(7,cRetorno,";").
            end.
        end.

    end.
end.

procedure pi-processa:

    for each tt-retorno-emissao:

        run pi-acompanhar in h-acomp (input "Emissao: " + trim(string(tt-retorno-emissao.ChNfe))).
        IF tt-param.arquivo <> "" THEN DO:
            DISPLAY "Emissao" FORMAT "X(12)"
                    tt-retorno-emissao.idMovto  
                    tt-retorno-emissao.infProt  FORMAT "X(20)"
                    tt-retorno-emissao.tpAmb    
                    tt-retorno-emissao.chNFe    FORMAT "X(44)"
                    tt-retorno-emissao.dhRecbto FORMAT "X(12)"
                    tt-retorno-emissao.nProt    FORMAT "X(20)"
                    tt-retorno-emissao.cStat    
                    tt-retorno-emissao.xMotivo  FORMAT "X(60)"
                    tt-retorno-emissao.chNFe2   
                    WITH WIDTH 300 STREAM-IO DOWN.
        END.

        for first nota-fiscal no-lock where 
            
            &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                trim(substring(nota-fiscal.char-2,3,60)) = tt-retorno-emissao.ChNfe:
            &elseif "{&bf_dis_versao_ems}" >= "2.07" &THEN
                nota-fiscal.cod-chave-aces-nf-eletro = tt-retorno-emissao.ChNfe:
            &endif

            run pi-trata-ret-nfe (
                input tt-retorno-emissao.idMovto ,
                input tt-retorno-emissao.Id      ,
                input tt-retorno-emissao.chNFe   ,
                input tt-retorno-emissao.cStat   ,
                input tt-retorno-emissao.nProt   ,
                input tt-retorno-emissao.tpEmis  ,
                input tt-retorno-emissao.tpAmb   , 
                input tt-retorno-emissao.verAplic,
                input tt-retorno-emissao.dhRecbto,
                input tt-retorno-emissao.digVal  ,
                input tt-retorno-emissao.xMotivo).
            RUN intprg/int999.p ("RETNFNDD", 
                                 tt-retorno-emissao.chNFe,
                                 "Retorno nota fiscal NDD realizado com sucesso!",
                                 2, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario).

            delete tt-retorno-emissao.
        end.
        IF NOT AVAIL nota-fiscal THEN DO:
            DISPLAY tt-retorno-emissao.chNFe " -> Nota Fiscal nao encontrada!".
            RUN intprg/int999.p ("RETNFNDD", 
                                 tt-retorno-emissao.chNFe,
                                 "Nota Fiscal nao encontrada!",
                                 2, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario).
        END.
    end.

    for each tt-retorno-cancelamento:

        run pi-acompanhar in h-acomp (input "Cancelamento: " + trim(string(tt-retorno-cancelamento.chNFe))).
        IF tt-param.arquivo <> "" THEN DO:
            DISPLAY "Cancelamento" FORMAT "X(12)"
                    tt-retorno-cancelamento.idMovto  
                    tt-retorno-cancelamento.id  
                    tt-retorno-cancelamento.chNFe    FORMAT "X(44)"
                    tt-retorno-cancelamento.nProt    FORMAT "X(20)"
                    tt-retorno-cancelamento.cStat    
                    tt-retorno-cancelamento.xMotivo  FORMAT "X(60)"
                    tt-retorno-cancelamento.chNFe2   
                    WITH WIDTH 300 STREAM-IO.
        END.
        for first nota-fiscal EXCLUSIVE-LOCK where 
            
            &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                trim(substring(nota-fiscal.char-2,3,60)) = tt-retorno-cancelamento.ChNfe:
            &elseif "{&bf_dis_versao_ems}" >= "2.07" &THEN 
                nota-fiscal.cod-chave-aces-nf-eletro = tt-retorno-cancelamento.chNFe:
           &endif
            
            /* marcar nota em processo de canelamento para notas canceladas na NDD */
            DO TRANSACTION:
                IF nota-fiscal.idi-sit-nf-eletro <> 12 THEN
                    ASSIGN nota-fiscal.idi-sit-nf-eletro = 12.
            END.
            run pi-trata-ret-nfe (
                input tt-retorno-cancelamento.idMovto ,
                input tt-retorno-cancelamento.Id      ,
                input tt-retorno-cancelamento.chNFe   ,
                input tt-retorno-cancelamento.cStat   ,
                input tt-retorno-cancelamento.nProt   ,
                input ""                              ,
                input ""                              , 
                input ""                              ,
                input tt-retorno-cancelamento.dhRecbto,
                input ""                              ,
                input tt-retorno-cancelamento.xMotivo).

             DO TRANSACTION:
                 IF nota-fiscal.idi-sit-nf-eletro <> 6 THEN
                    ASSIGN nota-fiscal.idi-sit-nf-eletro = 6.
                 ASSIGN nota-fiscal.dt-cancela = TODAY
                        nota-fiscal.ind-sit-nota = 4.
            END.

            RUN intprg/int999.p ("RETNFNDD", 
                     tt-retorno-cancelamento.chNFe,
                     "Cancelamento nota fiscal NDD realizado com sucesso!",
                     2, /* 1 - Pendente, 2 - Processado */ 
                     c-seg-usuario).
            delete tt-retorno-cancelamento.
        end.
        IF NOT AVAIL nota-fiscal THEN DO:
            DISPLAY tt-retorno-cancelamento.chNFe " -> Nota Fiscal nao encontrada!".
            RUN intprg/int999.p ("RETNFNDD", 
                                 tt-retorno-cancelamento.chNFe,
                                 "Nota Fiscal nao encontrada!",
                                 2, /* 1 - Pendente, 2 - Processado */ 
                                 c-seg-usuario).
        END.
    end.

    for each tt-retorno-inutilizacao:

        run pi-acompanhar in h-acomp (input "Inutilizaá∆o: " + trim(string(tt-retorno-inutilizacao.nNFIni))).
        IF tt-param.arquivo <> "" THEN DO:
            DISPLAY "Inutilizacao" FORMAT "X(12)"
                    tt-retorno-inutilizacao.idMovto  
                    tt-retorno-inutilizacao.tpAmb
                    tt-retorno-inutilizacao.CNPJ     FORMAT "X(16)"
                    tt-retorno-inutilizacao.serie
                    tt-retorno-inutilizacao.nNFIni   FORMAT "X(44)"
                    tt-retorno-inutilizacao.nNFFin   FORMAT "X(44)"
                    tt-retorno-inutilizacao.dhRecbto FORMAT "X(12)"
                    tt-retorno-inutilizacao.nProt    FORMAT "X(20)"
                    tt-retorno-inutilizacao.cStat    
                    tt-retorno-inutilizacao.xMotivo  FORMAT "X(60)"
                    WITH WIDTH 300 STREAM-IO.
        END.
        for first estabelec no-lock where 
            estabelec.cgc = trim(tt-retorno-inutilizacao.cnpj):
            for each nota-fiscal EXCLUSIVE-LOCK where 
                nota-fiscal.cod-estabel  = estabelec.cod-estabel and
                nota-fiscal.serie        = trim(tt-retorno-inutilizacao.serie) and
                nota-fiscal.nr-nota-fis >= trim(tt-retorno-inutilizacao.nNFIni) and
                nota-fiscal.nr-nota-fis <= trim(tt-retorno-inutilizacao.nNFFin):

                /* marcar nota em processo de inutilizacao para notas inutilizadas4 na NDD */
                DO TRANSACTION:
                    IF nota-fiscal.idi-sit-nf-eletro <> 13 THEN
                        ASSIGN nota-fiscal.idi-sit-nf-eletro = 13.
                END.

                run pi-trata-ret-nfe (
                    input tt-retorno-inutilizacao.idMovto ,
                    input tt-retorno-inutilizacao.Id      ,
                    input ""                              ,
                    input tt-retorno-inutilizacao.cStat   ,
                    input tt-retorno-inutilizacao.nProt   ,
                    input ""                              ,
                    input tt-retorno-inutilizacao.tpAmb   , 
                    input tt-retorno-inutilizacao.verAplic,
                    input tt-retorno-inutilizacao.dhRecbto,
                    input ""                              ,
                    input tt-retorno-inutilizacao.xMotivo).

                DO TRANSACTION:
                    IF nota-fiscal.idi-sit-nf-eletro <> 7 THEN
                        ASSIGN nota-fiscal.idi-sit-nf-eletro = 7.

                    ASSIGN nota-fiscal.dt-cancela = TODAY
                           nota-fiscal.ind-sit-nota = 4.
                END.
                RUN intprg/int999.p ("RETNFNDD", 
                         &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                            trim(substring(nota-fiscal.char-2,3,60)),
                         &else
                            nota-fiscal.cod-chave-aces-nf-eletro,
                         &endif
                         "Inutilizacao numero nota fiscal NDD realizado com sucesso!",
                         2, /* 1 - Pendente, 2 - Processado */ 
                         c-seg-usuario).
                delete tt-retorno-inutilizacao.
            end.
        end.
    end.
    for each tt-retorno-impressao:
        IF tt-param.arquivo <> "" THEN DO:
            DISPLAY "Impressao" FORMAT "X(12)"
                    tt-retorno-impressao.idMovto  
                    tt-retorno-impressao.id  
                    tt-retorno-impressao.chave    FORMAT "X(44)"
                    WITH WIDTH 300 STREAM-IO DOWN.
        END.
        run pi-acompanhar in h-acomp (input "Impress∆o: " + trim(string(tt-retorno-impressao.chave))).
        for first nota-fiscal exclusive where 
            
            &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                trim(substring(nota-fiscal.char-2,3,60)) = tt-retorno-impressao.chave:
            &elseif "{&bf_dis_versao_ems}" >= "2.07" &THEN 
                nota-fiscal.cod-chave-aces-nf-eletro = tt-retorno-impressao.chave:
            &endif
            if nota-fiscal.ind-sit-nota = 1 then
                assign nota-fiscal.ind-sit-nota = 3.
            /* marcando como processado */
            for first int-ndd-retorno EXCLUSIVE where int-ndd-retorno.ID = tt-retorno-impressao.idMovto:
                assign int-ndd-retorno.STATUSNUMBER = 1.
            end.
            RUN intprg/int999.p ("RETNFNDD", 
                     &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                        trim(substring(nota-fiscal.char-2,3,60)),
                     &else
                        nota-fiscal.cod-chave-aces-nf-eletro,
                     &endif
                     "Retorno impressao nota fiscal NDD realizado com sucesso!",
                     2, /* 1 - Pendente, 2 - Processado */ 
                     c-seg-usuario).
        end.
    end.
end.

procedure pi-finaliza-bos:
    if  valid-handle(h-bodi135) then delete procedure h-bodi135.
    if  valid-handle(h-boin090) then delete procedure h-boin090.
end.

/* FIM DO PROGRAMA */


procedure pi-trata-ret-nfe:

    define input param pIdMovto  as int64 no-undo.
    define input param pcChave   as char no-undo.
    define input param pcId      as char no-undo.
    define input param pcStat    as char no-undo.
    define input param pnProt    as char no-undo.
    define input param ptpEmis   as char no-undo.
    define input param PtpAmb    as char no-undo.
    define input param pverAplic as char no-undo.
    define input param pdhRecbto as char no-undo.
    define input param pdigVal   as char no-undo.
    define input param pxMotivo  as char no-undo.

    create  ttReturnInvoiceDocument.
    assign  ttReturnInvoiceDocument.Id        = pcId
            ttReturnInvoiceDocument.chNFe     = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                    trim(substring(nota-fiscal.char-2,3,60))
                                                &elseif "{&bf_dis_versao_ems}" >= "2.07" &THEN 
                                                    nota-fiscal.cod-chave-aces-nf-eletro
                                                &endif
            ttReturnInvoiceDocument.nProt     = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                    substr(nota-fiscal.char-1,97,15)
                                                &elseif "{&bf_dis_versao_ems}" >= "2.07" &THEN
                                                    nota-fiscal.cod-protoc 
                                                &endif
            ttReturnInvoiceDocument.versao    = 0
            ttReturnInvoiceDocument.lDanfe    = no
            ttReturnInvoiceDocument.tpAmb     = ptpAmb
            ttReturnInvoiceDocument.verAplic  = pverAplic
            ttReturnInvoiceDocument.dhRecbto  = pdhRecbto
            ttReturnInvoiceDocument.digVal    = pdigVal
            ttReturnInvoiceDocument.xMotivo   = pxMotivo
            ttReturnInvoiceDocument.tpEmis    = &if "{&bf_dis_versao_ems}" < "2.07" &then 
                                                    if int(substr(nota-fiscal.char-2,65,2)) > 0 then
                                                       trim(string(int(substr(nota-fiscal.char-2,65,2))))
                                                    else ""
                                                &elseif "{&bf_dis_versao_ems}" >= "2.07" &then
                                                    if int(nota-fiscal.idi-forma-emis-nf-eletro) > 0 then
                                                       trim(string(int(nota-fiscal.idi-forma-emis-nf-eletro)))
                                                    else ""
                                                &endif.
    create  ret-nf-eletro.
    assign  ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel
            ret-nf-eletro.cod-serie   = nota-fiscal.serie
            ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis
            ret-nf-eletro.cod-msg     = pcStat
            ret-nf-eletro.dat-ret     = today
            ret-nf-eletro.hra-ret     = replace(string(time, "HH:MM:SS"),":","")
            ret-nf-eletro.log-ativo   = yes
            &if "{&bf_dis_versao_ems}" >= "2.07" &then 
                ret-nf-eletro.cod-protoc  = pnProt.
            &else
                ret-nf-eletro.cod-livre-1 = pnProt.
            &endif
            .
    RELEASE ret-nf-eletro.

    FOR LAST ret-nf-eletro NO-LOCK WHERE
        ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel AND
        ret-nf-eletro.cod-serie   = nota-fiscal.serie AND
        ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis AND
        ret-nf-eletro.cod-msg     = pcStat AND
        ret-nf-eletro.log-ativo   = yes:
        /* Tratamento p/ Nota Propria gerada no Recebimento */
        if nota-fiscal.ind-tip-nota = 8 then
           run trataNotaFiscalEletronica in  h-boin090 (input rowid(ret-nf-eletro),
                                                        input table ttReturnInvoiceDocument).

        run trataNotaFiscalEletronica in  h-bodi135 (input rowid(ret-nf-eletro),
                                                     input table ttReturnInvoiceDocument).

        /* marcando como processado */
        for first int-ndd-retorno EXCLUSIVE where int-ndd-retorno.ID = pIdMovto:
            assign int-ndd-retorno.STATUSNUMBER = 1.
        end.
        RELEASE int-ndd-retorno.
    END.
    
end.

