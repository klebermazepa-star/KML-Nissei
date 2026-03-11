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
{include/i-prgvrs.i INT022RP 2.12.02.AVB}
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

define temp-table tt-param-re1005
    field destino            as integer
    field arquivo            as char
    field usuario            as char
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field c-cod-estabel-ini  as char
    field c-cod-estabel-fim  as char
    field i-cod-emitente-ini as integer
    field i-cod-emitente-fim as integer
    field c-nro-docto-ini    as char
    field c-nro-docto-fim    as char
    field c-serie-docto-ini  as char
    field c-serie-docto-fim  as char
    field c-nat-operacao-ini as char
    field c-nat-operacao-fim as char
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.
define temp-table tt-digita-re1005
    field r-docum-est        as rowid.

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
def var h-boad107na     as handle no-undo.
def var h-bodi135na-sitnfe as handle no-undo.
def var i-sit-nfe-aux   as int no-undo.
def var c-sit-nfe-aux   as char format "x(50)" no-undo.
def var l-emite-danfe-estab as logical no-undo.
define buffer b-docum-est for docum-est.

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
       c-revisao        = ".02.AVB"
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
if not valid-handle(h-bodi135na-sitnfe) then run dibo/bodi135na.p persistent set h-bodi135na-sitnfe.

if not valid-handle(h-boad107na) then do:
    run adbo/boad107na.p persistent set h-boad107na.
    run openQueryStatic in h-boad107na(input 'Main':U).
end.

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
procedure pi-elimina-tabelas:
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
        int-ndd-retorno.STATUSNUMBER = 0 /* A PROCESAR */ and
        int-ndd-retorno.kind <= 3
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
                        tt-retorno-emissao.dhRecbto  = substring(entry(5,cRetorno,";"),1,19) 
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
                        tt-retorno-cancelamento.dhRecbto  = substring(entry(5,cRetorno,";"),1,19)
                        tt-retorno-cancelamento.nProt     = entry(6,cRetorno,";") 
                        tt-retorno-cancelamento.chNFe2    = entry(7,cRetorno,";").
            end.
            when 2 /* Inutilizacao */ then do:
                create  tt-retorno-inutilizacao.
                assign  tt-retorno-inutilizacao.idMovto   = int-ndd-retorno.ID.
                assign  tt-retorno-inutilizacao.Id        = replace(entry(1,cRetorno,";"),"ID","")
                        tt-retorno-inutilizacao.tpAmb     = entry(2,cRetorno,";")  
                        tt-retorno-inutilizacao.verAplic  = entry(3,cRetorno,";")  
                        tt-retorno-inutilizacao.cStat     = entry(4,cRetorno,";")  
                        tt-retorno-inutilizacao.xMotivo   = entry(5,cRetorno,";")  
                        tt-retorno-inutilizacao.cUF       = entry(6,cRetorno,";")  
                        tt-retorno-inutilizacao.ano       = entry(7,cRetorno,";")  
                        tt-retorno-inutilizacao.CNPJ      = entry(8,cRetorno,";")  
                        tt-retorno-inutilizacao.modelo    = entry(9,cRetorno,";")  
                        tt-retorno-inutilizacao.serie     = entry(10,cRetorno,";")  
                        tt-retorno-inutilizacao.nNFIni    = trim(string(dec(entry(11,cRetorno,";")),">>>>>>>9999999"))
                        tt-retorno-inutilizacao.nNFFin    = trim(string(dec(entry(12,cRetorno,";")),">>>>>>>9999999"))
                        tt-retorno-inutilizacao.dhRecbto  = substring(entry(13,cRetorno,";"),1,19)
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

        for each estabelec no-lock where 
            estabelec.cgc = trim(substring(tt-retorno-emissao.chNFe,7,14)):
            for first nota-fiscal EXCLUSIVE-LOCK where
                nota-fiscal.cod-estabel = estabelec.cod-estabel and
                nota-fiscal.serie = trim(string(int(trim(substring(tt-retorno-emissao.chNFe,23,3))))) and
                nota-fiscal.nr-nota-fis = trim(string(dec(trim(substring(tt-retorno-emissao.chNFe,26,9))),">>>>>>>9999999")):

                /*
                for first nota-fiscal no-lock where 
                    
                    &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                        trim(substring(nota-fiscal.char-2,3,60)) = tt-retorno-emissao.ChNfe:
                    &elseif "{&bf_dis_versao_ems}" >= "2.07" &THEN
                        nota-fiscal.cod-chave-aces-nf-eletro = tt-retorno-emissao.ChNfe:
                    &endif
                  */

                if  dec(nota-fiscal.cod-prot) = 0 or (
                    dec(tt-retorno-emissao.nProt) <> 0 and 
                    dec(nota-fiscal.cod-prot) <> 0 and
                    dec(tt-retorno-emissao.nProt) = dec(nota-fiscal.cod-prot))
                    then do:
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
                    IF tt-retorno-emissao.nProt <> "" THEN DO: 
                        ASSIGN nota-fiscal.cod-protoc = tt-retorno-emissao.nProt.
                    END.
                end.
                RUN intprg/int999.p ("RETNFNDD", 
                                     tt-retorno-emissao.chNFe,
                                     "Retorno nota fiscal NDD " + tt-retorno-emissao.chNFe + " realizado com sucesso!",
                                     2, /* 1 - Pendente, 2 - Processado */ 
                                     c-seg-usuario).
    
            end.
            IF NOT AVAIL nota-fiscal THEN DO:
                DISPLAY tt-retorno-emissao.chNFe FORMAT "X(44)" " -> Nota Fiscal nao encontrada!".
                RUN pi-marca-processado (tt-retorno-emissao.IdMovto).
                RUN intprg/int999.p ("RETNFNDD", 
                                     tt-retorno-emissao.chNFe,
                                     "Nota Fiscal " + tt-retorno-emissao.chNFe + " n∆o encontrada!",
                                     2, /* 1 - Pendente, 2 - Processado */ 
                                     c-seg-usuario).
            END.
        end.
        RUN pi-marca-processado (tt-retorno-emissao.IdMovto).
        delete tt-retorno-emissao.
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
                    WITH WIDTH 300 STREAM-IO DOWN.
        END.
        for each estabelec no-lock where 
            estabelec.cgc = trim(substring(tt-retorno-cancelamento.chNFe,7,14)):
            for first nota-fiscal exclusive-lock where
                nota-fiscal.cod-estabel = estabelec.cod-estabel and
                nota-fiscal.serie = trim(string(int(trim(substring(tt-retorno-cancelamento.chNFe,23,3))))) and
                nota-fiscal.nr-nota-fis = trim(string(dec(trim(substring(tt-retorno-cancelamento.chNFe,26,9))),">>>>>>>9999999")):

                /*
                for first nota-fiscal EXCLUSIVE-LOCK where 
                    
                    &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                        trim(substring(nota-fiscal.char-2,3,60)) = tt-retorno-cancelamento.ChNfe:
                    &elseif "{&bf_dis_versao_ems}" >= "2.07" &THEN 
                        nota-fiscal.cod-chave-aces-nf-eletro = tt-retorno-cancelamento.chNFe:
                   &endif
                */    
                /* marcar nota em processo de canelamento para notas canceladas na NDD */
                
                IF nota-fiscal.idi-sit-nf-eletro <> 12 THEN DO TRANSACTION:
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
    
                IF  tt-retorno-cancelamento.cStat = "101" or
                    tt-retorno-cancelamento.cStat = "135" or
                    tt-retorno-cancelamento.cStat = "151" or
                    tt-retorno-cancelamento.cStat = "155" THEN
                DO TRANSACTION:
                     IF nota-fiscal.idi-sit-nf-eletro <> 6 THEN
                        ASSIGN nota-fiscal.idi-sit-nf-eletro = 6.
                     ASSIGN nota-fiscal.dt-cancela = TODAY
                            nota-fiscal.ind-sit-nota = 4
                            nota-fiscal.cod-protoc = tt-retorno-cancelamento.nProt.
                     FOR EACH it-nota-fisc OF nota-fiscal:
                         ASSIGN it-nota-fisc.dt-cancela = nota-fiscal.dt-cancela.
                     END.
                     RUN intprg/int999.p ("RETNFNDD", 
                              tt-retorno-cancelamento.chNFe,
                              "Cancelamento nota fiscal NDD " + tt-retorno-cancelamento.chNFe + " realizado com sucesso!",
                              2, /* 1 - Pendente, 2 - Processado */ 
                              c-seg-usuario).
                END.
                ELSE DO:
                    RUN intprg/int999.p ("RETNFNDD", 
                             tt-retorno-cancelamento.chNFe,
                             "Cancelamento nota fiscal NDD " + tt-retorno-cancelamento.chNFe + " n∆o realizado. Cod: " +  tt-retorno-cancelamento.cStat + " - Motivo: " + tt-retorno-cancelamento.xMotivo,
                             1, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario).
                    RUN pi-marca-processado (tt-retorno-cancelamento.idMovto).
                END.
            end.
            IF NOT AVAIL nota-fiscal THEN DO:
                DISPLAY tt-retorno-cancelamento.chNFe FORMAT "X(44)" " -> Nota Fiscal nao encontrada!".
                RUN pi-marca-processado (tt-retorno-cancelamento.idMovto).
                RUN intprg/int999.p ("RETNFNDD", 
                                     tt-retorno-cancelamento.chNFe,
                                     "Nota Fiscal " + tt-retorno-cancelamento.chNFe + " n∆o encontrada!",
                                     2, /* 1 - Pendente, 2 - Processado */ 
                                     c-seg-usuario).
            END.
        end.
        RUN pi-marca-processado (tt-retorno-cancelamento.idMovto).
        delete tt-retorno-cancelamento.
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
                    WITH WIDTH 300 STREAM-IO DOWN.
        END.
        for each estabelec no-lock where 
            estabelec.cgc = trim(tt-retorno-inutilizacao.cnpj):
            for each nota-fiscal EXCLUSIVE-LOCK where 
                nota-fiscal.cod-estabel  = estabelec.cod-estabel and
                nota-fiscal.serie        = trim(tt-retorno-inutilizacao.serie) and
                nota-fiscal.nr-nota-fis >= trim(tt-retorno-inutilizacao.nNFIni) and
                nota-fiscal.nr-nota-fis <= trim(tt-retorno-inutilizacao.nNFFin):

                /* marcar nota em processo de inutilizacao para notas inutilizadas4 na NDD */
                IF nota-fiscal.idi-sit-nf-eletro <> 13 THEN DO TRANSACTION:
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

                IF tt-retorno-inutilizacao.cStat = "102" THEN 
                DO TRANSACTION:
                    IF nota-fiscal.idi-sit-nf-eletro <> 7 THEN
                        ASSIGN nota-fiscal.idi-sit-nf-eletro = 7.

                    ASSIGN nota-fiscal.dt-cancela = TODAY
                           nota-fiscal.ind-sit-nota = 4
                           nota-fiscal.cod-protoc = tt-retorno-inutilizacao.nProt.
                    FOR EACH it-nota-fisc OF nota-fiscal:
                        ASSIGN it-nota-fisc.dt-cancela = nota-fiscal.dt-cancela.
                    END.
                    RUN intprg/int999.p ("RETNFNDD", 
                             &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                trim(substring(nota-fiscal.char-2,3,44)),
                             &else
                                nota-fiscal.cod-chave-aces-nf-eletro,
                             &endif
                             "Inutilizaá∆o n£mero nota fiscal NDD " + nota-fiscal.cod-chave-aces-nf-eletro + " realizado com sucesso!",
                             2, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario).

                END.
                ELSE DO:
                    RUN intprg/int999.p ("RETNFNDD", 
                             &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                trim(substring(nota-fiscal.char-2,3,44))
                             &else
                                nota-fiscal.cod-chave-aces-nf-eletro
                             &endif
                             ,"Inutilizaá∆o n£mero nota fiscal NDD " + nota-fiscal.cod-chave-aces-nf-eletro + " n∆o realizado. Cod: " +  tt-retorno-inutilizacao.cStat + " - Motivo: " + tt-retorno-inutilizacao.xMotivo,
                             1, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario).
                END.
            end.
        end.
        RUN pi-marca-processado (tt-retorno-inutilizacao.idMovto).
        delete tt-retorno-inutilizacao.
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

        for each estabelec no-lock where 
            estabelec.cgc = trim(substring(tt-retorno-impressao.chave,7,14)):
            for first nota-fiscal exclusive-lock where
                nota-fiscal.cod-estabel = estabelec.cod-estabel and
                nota-fiscal.serie = trim(string(int(trim(substring(tt-retorno-impressao.chave,23,3))))) and
                nota-fiscal.nr-nota-fis = trim(string(dec(trim(substring(tt-retorno-impressao.chave,26,9))),">>>>>>>9999999")):

                /*
                for first nota-fiscal exclusive where 
                    
                    &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                        trim(substring(nota-fiscal.char-2,3,60)) = tt-retorno-impressao.chave:
                    &elseif "{&bf_dis_versao_ems}" >= "2.07" &THEN 
                        nota-fiscal.cod-chave-aces-nf-eletro = tt-retorno-impressao.chave:
                    &endif
                */
                if nota-fiscal.ind-sit-nota = 1 then
                    assign nota-fiscal.ind-sit-nota = 3.
                RUN intprg/int999.p ("RETNFNDD", 
                         &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                            trim(substring(nota-fiscal.char-2,3,44)),
                         &else
                            trim(substring(nota-fiscal.cod-chave-aces-nf-eletro,1,44)),
                         &endif
                         "Retorno impress∆o nota fiscal NDD " + nota-fiscal.cod-chave-aces-nf-eletro + " realizado com sucesso!",
                         2, /* 1 - Pendente, 2 - Processado */ 
                         c-seg-usuario).
                RUN pi-marca-processado (tt-retorno-impressao.idMovto).
            end.
            if not avail nota-fiscal then do:
                DISPLAY tt-retorno-impressao.chave FORMAT "X(44)" " -> Nota Fiscal nao encontrada!".
                RUN intprg/int999.p ("RETNFNDD", 
                                     tt-retorno-impressao.chave,
                                     "Nota Fiscal " + tt-retorno-impressao.chave + " n∆o encontrada!",
                                     2, /* 1 - Pendente, 2 - Processado */ 
                                     c-seg-usuario).
                RUN pi-marca-processado (tt-retorno-impressao.idMovto).
            end.
        end.
        RUN pi-marca-processado (tt-retorno-impressao.idMovto).
        delete tt-retorno-impressao.
    end.        
end.

procedure pi-finaliza-bos:
    if  valid-handle(h-bodi135) then delete procedure h-bodi135.
    if  valid-handle(h-boin090) then delete procedure h-boin090.
    if  valid-handle(h-bodi135na-sitnfe) then delete procedure h-bodi135na-sitnfe.
    if  valid-handle(h-boad107na) then delete procedure h-boad107na.
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

    empty   temp-table ttReturnInvoiceDocument.
    create  ttReturnInvoiceDocument.
    assign  ttReturnInvoiceDocument.Id        = pcId
            ttReturnInvoiceDocument.chNFe     = &if "{&bf_dis_versao_ems}" < "2.07" &THEN
                                                    trim(substring(nota-fiscal.char-2,3,44))
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
            ret-nf-eletro.cod-livre-2 = pxMotivo
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

        assign nota-fiscal.obs-gerada = trim(nota-fiscal.obs-gerada + "ID NDD: " + string(pIdMovto)).
        /* Tratamento p/ Nota Propria gerada no Recebimento */
        if nota-fiscal.ind-tip-nota = 8 then do:

            /*
            CASE pcStat:
                WHEN "101":U OR       /*101 - Cancelamento de NF-e homologado  */
                WHEN "151":U OR       /*151 - Cancelamento de NF-e homologado fora de prazo*/                                  
                WHEN "155":U OR       /*155 - Cancelamento homologado fora de prazo (para Evento de Cancelamento [NT2011.006]*/
                WHEN "102":U THEN DO: /*102 - Inutilizaá∆o de n£mero homologado*/
                /*
                    RUN ftp/ft0911.p (INPUT ROWID(nota-fiscal),
                                      INPUT pcStat,
                                      INPUT pnProt).
                                      */
                END.
                OTHERWISE DO:
                    RUN goToKey IN h-boad107na (INPUT nota-fiscal.cod-estabel).
                    IF RETURN-VALUE = "OK":U THEN
                       RUN getLogField IN h-boad107na (INPUT "log-emite-danfe":U, OUTPUT l-emite-danfe-estab).

                    RUN retornaSitNF-e IN h-bodi135na-sitnfe (INPUT nota-fiscal.cod-estabel,
                                                              INPUT nota-fiscal.serie,
                                                              INPUT nota-fiscal.nr-nota-fis,
                                                              INPUT nota-fiscal.dt-emis-nota,
                                                              OUTPUT i-sit-nfe-aux,
                                                              OUTPUT c-sit-nfe-aux).
                   if l-emite-danfe-estab then
                        run trataNotaFiscalEletronica in  h-boin090 (input rowid(ret-nf-eletro),
                                                                     input table ttReturnInvoiceDocument).

                   run trataNotaFiscalEletronica in  h-bodi135 (input rowid(ret-nf-eletro),
                                                                input table ttReturnInvoiceDocument).

                END.
            END CASE.
            */
            RUN goToKey IN h-boad107na (INPUT nota-fiscal.cod-estabel).
            IF RETURN-VALUE = "OK":U THEN
               RUN getLogField IN h-boad107na (INPUT "log-emite-danfe":U, OUTPUT l-emite-danfe-estab).

            RUN retornaSitNF-e IN h-bodi135na-sitnfe (INPUT nota-fiscal.cod-estabel,
                                                      INPUT nota-fiscal.serie,
                                                      INPUT nota-fiscal.nr-nota-fis,
                                                      INPUT nota-fiscal.dt-emis-nota,
                                                      OUTPUT i-sit-nfe-aux,
                                                      OUTPUT c-sit-nfe-aux).
           if l-emite-danfe-estab then
                run trataNotaFiscalEletronica in  h-boin090 (input rowid(ret-nf-eletro),
                                                             input table ttReturnInvoiceDocument).

           run trataNotaFiscalEletronica in  h-bodi135 (input rowid(ret-nf-eletro),
                                                        input table ttReturnInvoiceDocument).

           find current nota-fiscal no-error.
           for first docum-est where 
               docum-est.serie-docto  = nota-fiscal.serie and
               docum-est.nro-docto    = nota-fiscal.nr-nota-fis and
               docum-est.cod-emitente = nota-fiscal.cod-emitente and
               docum-est.nat-operacao = nota-fiscal.nat-operacao:

               assign docum-est.idi-sit-nf-eletro = nota-fiscal.idi-sit-nf-eletro
                      docum-est.log-1 = if nota-fiscal.dt-cancela <> ? then no else yes
                      docum-est.cod-chave-aces-nf-eletro = nota-fiscal.cod-chave-aces-nf-eletro.

               if nota-fiscal.dt-cancela <> ? then do:
                   for each devol-cli of docum-est:
                       delete devol-cli.
                   end.
                   /*assign docum-est.log-1 = no. /* liberando eliminaá∆o do documento */*/
                       for each cst-fat-devol of docum-est:
                           for each int-ds-devolucao-cupom where
                               int-ds-devolucao-cupom.numero_dev = cst-fat-devol.numero-dev and
                               int-ds-devolucao-cupom.cnpj_filial_dev = estabelec.cgc:
                               assign int-ds-devolucao-cupom.situacao = 1.                                
                           end.
                           delete cst-fat-devol.
                       end.
                       for first item-doc-est no-lock:
                       if item-doc-est.nr-pedcli <> "" then do:
                           for each cst-fat-devol where 
                               cst-fat-devol.cod-estabel = docum-est.cod-estabel   and
                               cst-fat-devol.serie-docto = item-doc-est.serie-docto and
                               cst-fat-devol.nro-docto   = item-doc-est.nr-pedcli:

                               if not can-find(first b-docum-est no-lock where
                                               b-docum-est.cod-estabel = cst-fat-devol.cod-estabel and
                                               b-docum-est.serie-docto = cst-fat-devol.serie-docto and
                                               b-docum-est.nro-docto   = cst-fat-devol.nro-docto   and
                                               b-docum-est.nro-docto  <> docum-est.nro-docto) then do:
                                   for each int-ds-devolucao-cupom where
                                       int-ds-devolucao-cupom.numero_dev = cst-fat-devol.numero-dev and
                                       int-ds-devolucao-cupom.cnpj_filial_dev = estabelec.cgc:
                                       assign int-ds-devolucao-cupom.situacao = 1.                                
                                   end.
                                   delete cst-fat-devol.
                               end.
                           end.
                       end.
                       else do:
                           if item-doc-est.nro-comp <> "" then
                           for each cst-fat-devol where 
                               cst-fat-devol.cod-estabel = docum-est.cod-estabel   and
                               cst-fat-devol.serie-comp  = item-doc-est.serie-comp and
                               cst-fat-devol.nro-comp    = item-doc-est.nro-comp:

                               if not can-find(first b-docum-est no-lock where
                                               b-docum-est.cod-estabel = cst-fat-devol.cod-estabel and
                                               b-docum-est.serie-docto = cst-fat-devol.serie-docto and
                                               b-docum-est.nro-docto   = cst-fat-devol.nro-docto   and
                                               b-docum-est.nro-docto  <> docum-est.nro-docto) then do:
    
                                   for each int-ds-devolucao-cupom where
                                       int-ds-devolucao-cupom.numero_dev = cst-fat-devol.numero-dev and
                                       int-ds-devolucao-cupom.cnpj_filial_dev = estabelec.cgc:
                                       assign int-ds-devolucao-cupom.situacao = 1.                                
                                   end.
                                   delete cst-fat-devol.
                               end.
                           end.
                       end.
                   end.
               end. /* nota-fiscal.dt-cancale */
               else do:
                   empty temp-table tt-digita-re1005.
                   empty temp-table tt-param-re1005.

                   create tt-param-re1005.
                   assign 
                       tt-param-re1005.destino            = 3
                       tt-param-re1005.arquivo            = "re1005_INT022_.txt"
                       tt-param-re1005.usuario            = c-seg-usuario
                       tt-param-re1005.data-exec          = today
                       tt-param-re1005.hora-exec          = time
                       tt-param-re1005.classifica         = 1
                       tt-param-re1005.c-cod-estabel-ini  = docum-est.cod-estabel
                       tt-param-re1005.c-cod-estabel-fim  = docum-est.cod-estabel
                       tt-param-re1005.i-cod-emitente-ini = docum-est.cod-emitente
                       tt-param-re1005.i-cod-emitente-fim = docum-est.cod-emitente
                       tt-param-re1005.c-nro-docto-ini    = docum-est.nro-docto
                       tt-param-re1005.c-nro-docto-fim    = docum-est.nro-docto
                       tt-param-re1005.c-serie-docto-ini  = docum-est.serie-docto
                       tt-param-re1005.c-serie-docto-fim  = docum-est.serie-docto
                       tt-param-re1005.c-nat-operacao-ini = docum-est.nat-operacao
                       tt-param-re1005.c-nat-operacao-fim = docum-est.nat-operacao
                       tt-param-re1005.da-dt-trans-ini    = docum-est.dt-trans
                       tt-param-re1005.da-dt-trans-fim    = docum-est.dt-trans.

                   /*
                   create tt-digita-re1005.
                   assign tt-digita-re1005.r-docum-est  = rowid(docum-est).
                   create tt-raw-digita.
                   raw-transfer tt-digita-re1005 to tt-raw-digita.raw-param.
                   */

                   release docum-est.

                   raw-transfer tt-param-re1005 to raw-param.
                   run rep/re1005rp.p (input raw-param, input table tt-raw-digita).

                   empty temp-table tt-digita-re1005.
                   empty temp-table tt-param-re1005.
               end.
           end.
        end.
        ELSE DO:
            run trataNotaFiscalEletronica in  h-bodi135 (input rowid(ret-nf-eletro),
                                                         input table ttReturnInvoiceDocument).
        END.
        /* marcando como processado */
        for first int-ndd-retorno EXCLUSIVE where int-ndd-retorno.ID = pIdMovto:
            assign int-ndd-retorno.STATUSNUMBER = 1.
        end.
        RELEASE int-ndd-retorno.
    END.
    
end.

PROCEDURE pi-marca-processado:
    DEFINE INPUT PARAMETER pid AS INTEGER.
    do transaction: 
        /* marcando como processado */
        for first int-ndd-retorno EXCLUSIVE where int-ndd-retorno.ID = pid:
            assign int-ndd-retorno.STATUSNUMBER = 1.
        end.
        RELEASE int-ndd-retorno.
    end.
END.


