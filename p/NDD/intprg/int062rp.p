/********************************************************************************
** Programa: INT062 - Retorno de Notas Fiscais NDD
**
** Versao : 12 - 01/04/2016 - Alessandro V Baccin
**
********************************************************************************/
/* KIND 

*/

/* include de controle de versao */
{include/i-prgvrs.i INT062RP 2.12.02.AVB}
{cdp/cdcfgdis.i}

/* definiçao das temp-tables para recebimento de parametros */
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

FUNCTION funcDesMsg RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
ASSIGN tt-param.arquivo = "INT062.txt"
       tt-param.destino = 3
       tt-param.data-exec = TODAY
       tt-param.hora-exec = TIME.

/* include padrao para variáveis de relatório  */
{include/i-rpvar.i}


/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
def var h-acomp         as handle no-undo.
def var r-rowid         as rowid no-undo.
def var cRetorno        as longchar no-undo.
def var c-mensagem      as char format "X(50)" no-undo.
def var c-informacao    as char format "X(100)" no-undo.
def var i-sit-nfe-aux   as int no-undo.
def var c-sit-nfe-aux   as char format "x(50)" no-undo.
DEFINE VARIABLE c-des-msg                  LIKE carta-correc-eletro.dsl-msg NO-UNDO.

{dibo/bodi601.i tt-cce}

DEF TEMP-TABLE tt-cce-2 NO-UNDO LIKE tt-cce.

define temp-table tt-retorno-emissao
    field idMovto       as int64
    FIELD infEvento     AS CHAR
    field tpAmb         as char
    field verAplic      as char
    field cOrgao        as char
    field chNFe         as char
    field dhRegEvento   as char
    field nProt         as char
    field cStat         as char
    field xMotivo       as char
    field tpEvento      as char
    field xEvento       as char
    field nSeqEvento    as char
    field CNPJDest      as char
    field emailDest     as char
    field sequencial    as char
    index chave idMovto.

def var i-ind as integer no-undo.

{utp/ut-glob.i}

/* definiçao de frames do relatório */
form c-mensagem       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 300
     down stream-io frame f-erro.

/* include com a definiçao da frame de cabeçalho e rodapé */
{include/i-rpcab.i}
/* bloco principal do programa */

{utp/utapi019.i}

find first tt-param no-lock no-error.
assign c-programa       = "INT062RP"
       c-versao         = "2.12"
       c-revisao        = ".02.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Retorno de Cartas de Corre‡Æo NDD".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

DEFINE VARIABLE h-bodi601 AS HANDLE      NO-UNDO.

if not valid-handle(h-bodi601) then run dibo/bodi601.p persistent set h-bodi601.

IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i}
                     
    view frame f-cabec.
    view frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Processando").

empty temp-table tt-retorno-emissao.
run pi-importa.
run pi-processa.
RUN pi-finaliza-bos.
empty temp-table tt-retorno-emissao.

RUN intprg/int888.p (INPUT "RETNFNDD",
                     INPUT "INT062RP.P").

run pi-finalizar in h-acomp.

IF tt-param.arquivo <> "" THEN DO:
    /* fechamento do output do relatorio  */
    {include/i-rpclo.i }
END.
/* elimina BO's */
return "OK".

procedure pi-importa:
    run pi-acompanhar in h-acomp (input "Lendo Retornos").

    for each int_ndd_retorno NO-LOCK 
       where int_ndd_retorno.STATUSNUMBER = 0 /* A PROCESAR */
         and int_ndd_retorno.kind = 7
        query-tuning(no-lookahead)
        by int_ndd_retorno.id:

        copy-lob int_ndd_retorno.DOCUMENTDATA to cRetorno.
        run pi-acompanhar in h-acomp (input "Retorno: " + trim(string(int_ndd_retorno.ID))).

        IF  NUM-ENTRIES(cRetorno, ";") >= 14
        THEN DO:
            create  tt-retorno-emissao.
            assign  tt-retorno-emissao.idMovto      = int_ndd_retorno.ID.
            assign  tt-retorno-emissao.infEvento    = entry(1,cRetorno,";") 
                    tt-retorno-emissao.tpAmb        = entry(2,cRetorno,";") 
                    tt-retorno-emissao.verAplic     = entry(3,cRetorno,";") 
                    tt-retorno-emissao.cOrgao       = entry(4,cRetorno,";")
                    tt-retorno-emissao.cStat        = entry(5,cRetorno,";")
                    tt-retorno-emissao.xMotivo      = entry(6,cRetorno,";") 
                    tt-retorno-emissao.chNFe        = entry(7,cRetorno,";") 
                    tt-retorno-emissao.tpEvento     = entry(8,cRetorno,";")
                    tt-retorno-emissao.xEvento      = entry(9,cRetorno,";")
                    tt-retorno-emissao.nseqEvento   = entry(10,cRetorno,";")
                    tt-retorno-emissao.CNPJDest     = entry(11,cRetorno,";")
                    tt-retorno-emissao.emailDest    = entry(12,cRetorno,";")
                    tt-retorno-emissao.dhRegEvento  = substring(entry(13,cRetorno,";"),1,19) 
                    tt-retorno-emissao.nProt        = entry(14,cRetorno,";") 
                    tt-retorno-emissao.sequencial   = entry(15,cRetorno,";").
        END.
    end.
end.

procedure pi-processa:

    for each tt-retorno-emissao:

        run pi-acompanhar in h-acomp (input "Emissao: " + trim(string(tt-retorno-emissao.ChNfe))).
        IF tt-param.arquivo <> "" THEN DO:
            DISPLAY "Emissao" FORMAT "X(12)"
                    tt-retorno-emissao.idMovto  
                    tt-retorno-emissao.xEvento      FORMAT "X(20)"
                    tt-retorno-emissao.tpAmb    
                    tt-retorno-emissao.chNFe        FORMAT "X(44)"
                    tt-retorno-emissao.dhRegEvento  FORMAT "X(12)"
                    tt-retorno-emissao.nProt        FORMAT "X(20)"
                    tt-retorno-emissao.cStat    
                    tt-retorno-emissao.xMotivo      FORMAT "X(60)"
                    tt-retorno-emissao.sequencial
                    WITH WIDTH 300 STREAM-IO DOWN.
        END.

        for each estabelec no-lock where 
            estabelec.cgc = trim(substring(tt-retorno-emissao.chNFe,7,14)):
            
            for first nota-fiscal EXCLUSIVE-LOCK where
                nota-fiscal.cod-estabel = estabelec.cod-estabel and
                nota-fiscal.serie = trim(string(int(trim(substring(tt-retorno-emissao.chNFe,23,3))))) and
                nota-fiscal.nr-nota-fis = trim(string(int(trim(substring(tt-retorno-emissao.chNFe,26,9))),">>>9999999")):

                /*if  dec(nota-fiscal.cod-prot) = 0 or (
                    dec(tt-retorno-emissao.nProt) <> 0 and 
                    dec(nota-fiscal.cod-prot) <> 0 and
                    dec(tt-retorno-emissao.nProt) = dec(nota-fiscal.cod-prot))
                    then do:*/
                    run pi-trata-ret-nfe (
                        input tt-retorno-emissao.idMovto ,
                        input tt-retorno-emissao.Id      ,
                        input tt-retorno-emissao.chNFe   ,
                        input tt-retorno-emissao.cStat   ,
                        input tt-retorno-emissao.nProt   ,
                        input tt-retorno-emissao.tpEvento  ,
                        input tt-retorno-emissao.tpAmb   , 
                        input tt-retorno-emissao.verAplic,
                        input tt-retorno-emissao.dhRegEvento,
                        input tt-retorno-emissao.xMotivo,
                        input tt-retorno-emissao.Sequencial).

                IF tt-retorno-emissao.nProt <> "" THEN DO: 
                    ASSIGN nota-fiscal.cod-protoc = tt-retorno-emissao.nProt.
                END.
                RUN intprg/int999.p ("RETNFNDD", 
                                     tt-retorno-emissao.chNFe,
                                     "Retorno Carta Corre‡Æo NDD " + tt-retorno-emissao.chNFe + " realizado com sucesso!",
                                     2, /* 1 - Pendente, 2 - Processado */ 
                                     c-seg-usuario,
                                     "INT062RP.P").
    
                /*delete tt-retorno-emissao.*/
            end.
            IF NOT AVAIL nota-fiscal THEN DO:
                DISPLAY tt-retorno-emissao.chNFe FORMAT "X(44)" " -> Nota Fiscal nao encontrada!".
                RUN pi-marca-processado (tt-retorno-emissao.IdMovto).
                RUN intprg/int999.p ("RETNFNDD", 
                                     tt-retorno-emissao.chNFe,
                                     "Nota Fiscal " + tt-retorno-emissao.chNFe + " nÆo encontrada!",
                                     2, /* 1 - Pendente, 2 - Processado */ 
                                     c-seg-usuario,
                                     "INT062RP.P").
            END.
        end.
    end.
end.

procedure pi-finaliza-bos:
    if  valid-handle(h-bodi601) then delete procedure h-bodi601.
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
    define input param pxMotivo  as char no-undo.
    define input param psequencial as char no-undo.

    DEFINE VARIABLE i-num-registros AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-xml AS LONGCHAR     NO-UNDO.

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
    /*
    FOR LAST ret-nf-eletro NO-LOCK WHERE
        ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel AND
        ret-nf-eletro.cod-serie   = nota-fiscal.serie AND
        ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis AND
        ret-nf-eletro.cod-msg     = pcStat AND
        ret-nf-eletro.log-ativo   = yes:*/

        RUN setConstraintByNota IN h-bodi601 (INPUT nota-fiscal.cod-estabel, INPUT nota-fiscal.serie, INPUT nota-fiscal.nr-nota-fis).
        RUN openQueryStatic     IN h-bodi601 (INPUT "ByNota").
        RUN getBatchRecords     IN h-bodi601 (INPUT ?, INPUT NO, INPUT 1000, OUTPUT i-num-registros, OUTPUT TABLE tt-cce).
        
        /*RUN pi-salva-xml (OUTPUT c-xml).*/
        /*
        PUT UNFORMATTED nota-fiscal.cod-estabel " " nota-fiscal.serie " " nota-fiscal.nr-nota-fis " " "num registros: " i-num-registros SKIP.
        */
        FIND LAST tt-cce NO-LOCK where 
            tt-cce.num-seq = int(psequencial)
            NO-ERROR.
        IF  AVAIL tt-cce /*AND tt-cce.idi-sit-event <= 1*/ THEN DO:
            EMPTY TEMP-TABLE tt-cce-2.
            
            RUN goToKey         IN h-bodi601 (INPUT tt-cce.cod-estab, INPUT tt-cce.cod-serie, INPUT tt-cce.cod-nota-fisc, INPUT tt-cce.num-seq).
            RUN getRecord       IN h-bodi601 (OUTPUT TABLE tt-cce-2).

            FIND FIRST tt-cce-2 NO-ERROR.
            BUFFER-COPY tt-cce /*EXCEPT tt-cce.cod-estab 
                                      tt-cce.cod-serie 
                                      tt-cce.cod-nota-fisc 
                                      tt-cce.num-seq*/ TO tt-cce-2.

            ASSIGN tt-cce-2.cod-msg       = pcStat
                   tt-cce-2.cod-protoc    = pnProt
                   tt-cce-2.dsl-msg       = funcDesMsg().

            /*ASSIGN tt-cce-2.dsl-xml-armaz = c-Xml.  */   

            ASSIGN tt-cce-2.des-dat-hora-ret        = string(NOW).

            IF  pcStat <> "0" THEN DO:
                IF  pcStat = "128" THEN                   
                    ASSIGN tt-cce-2.idi-sit-event = 2. 
                ELSE IF  pcStat = "601" OR pcStat = "135" THEN              
                    ASSIGN tt-cce-2.idi-sit-event = 3. 
                ELSE IF  pcStat = "136" THEN              
                    ASSIGN tt-cce-2.idi-sit-event = 4. 
                ELSE                                                 
                    ASSIGN tt-cce-2.idi-sit-event = 5. 
            END.
            ELSE 
                ASSIGN tt-cce-2.idi-sit-event = 1.

            IF  pcStat = "0" THEN
                ASSIGN tt-cce-2.dsl-msg = pxmotivo.

            RUN setRecord       IN h-bodi601 (INPUT TABLE tt-cce-2).
            RUN emptyRowErrors  IN h-bodi601.
            RUN updateRecord    IN h-bodi601.
            /*RUN getRowErrors    IN h-bodi601 (OUTPUT TABLE rowErrors).*/

            /* marcando como processado */
            for first int_ndd_retorno EXCLUSIVE where int_ndd_retorno.ID = pIdMovto:
                assign int_ndd_retorno.STATUSNUMBER = 1.
                RELEASE int_ndd_retorno.
            end.

        end.
    /* END. */
end.

PROCEDURE pi-marca-processado:
    DEFINE INPUT PARAMETER pid AS INTEGER.
    do transaction: 
        /* marcando como processado */
        for first int_ndd_retorno EXCLUSIVE where int_ndd_retorno.ID = pid:
            assign int_ndd_retorno.STATUSNUMBER = 1.
            RELEASE int_ndd_retorno.
        end.
    end.
END.

PROCEDURE pi-salva-xml:
    DEFINE OUTPUT PARAM c-xml AS LONGCHAR   NO-UNDO.

    ASSIGN c-xml = ('<?xml version="1.0" encoding="UTF-8" ?>').
    
    /*Cabe‡alho pai procEventoNFe - abre  */
    ASSIGN c-xml = c-xml + ('<procEventoNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.00">').

    ASSIGN c-xml = c-xml + ('<infEvento Id="' + tt-retorno-emissao.infEvento + '">').
    ASSIGN c-xml = c-xml + ('<tpAmb>' + tt-retorno-emissao.tpAmb + '</tpAmb>').
    ASSIGN c-xml = c-xml + ('<verAplic>' + tt-retorno-emissao.verAplic + '</verAplic>').
    ASSIGN c-xml = c-xml + ('<cOrgao>' + tt-retorno-emissao.cOrgao + '</cOrgao>').
    ASSIGN c-xml = c-xml + ('<cStat>' + tt-retorno-emissao.cStat + '</cStat>').
    ASSIGN c-xml = c-xml + ('<xMotivo>' + tt-retorno-emissao.xMotivo + '</xMotivo>').
    ASSIGN c-xml = c-xml + ('<chNFe>' + tt-retorno-emissao.chNFe + '</chNFe>').
    ASSIGN c-xml = c-xml + ('<tpEvento>' + tt-retorno-emissao.tpEvento + '</tpEvento>').
    ASSIGN c-xml = c-xml + ('<xEvento>' + tt-retorno-emissao.xEvento + '</xEvento>').
    ASSIGN c-xml = c-xml + ('<nSeqEvento>' + tt-retorno-emissao.nSeqEvento + '</nSeqEvento>').
    ASSIGN c-xml = c-xml + ('<CNPJDest>' + tt-retorno-emissao.CNPJDest + '</CNPJDest>').
    ASSIGN c-xml = c-xml + ('<emailDest>' + tt-retorno-emissao.emailDest + '</emailDest>').
    ASSIGN c-xml = c-xml + ('<dhRegEvento>' + tt-retorno-emissao.dhRegEvento + '</dhRegEvento>').
    ASSIGN c-xml = c-xml + ('<nProt>' + tt-retorno-emissao.nProt + '</nProt>').
    ASSIGN c-xml = c-xml + ('</infEvento>').
    
    /*Cabe‡alho pai procEventoNFe - fecha  */
    ASSIGN c-xml = c-xml + ('</procEventoNFe>').

    OUTPUT CLOSE.

END.

FUNCTION funcDesMsg RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    IF  AVAIL tt-cce-2 THEN DO:
        FIND FIRST msg-ret-nf-eletro 
             WHERE msg-ret-nf-eletro.cod-msg = tt-cce-2.cod-msg NO-ERROR.
        IF AVAIL msg-ret-nf-eletro THEN
            ASSIGN c-des-msg = msg-ret-nf-eletro.dsl-msg.
        ELSE
            ASSIGN c-des-msg = tt-cce-2.dsl-msg.
      END.

  RETURN c-des-msg.   /* Function return value. */

END FUNCTION.
