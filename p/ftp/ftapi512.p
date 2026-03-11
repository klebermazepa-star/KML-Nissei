/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i FTAPI512 2.00.00.003}  /*** 010003 ***/

{cdp/cdcfgdis.i}
//{ftp/ftapi512.i}

DEFINE INPUT  PARAMETER cProcessamento   AS CHAR  NO-UNDO.   
DEFINE INPUT  PARAMETER rwNotaFiscal     AS ROWID NO-UNDO.
DEFINE INPUT  PARAMETER cDescCancela     AS CHAR  NO-UNDO.
DEFINE OUTPUT PARAMETER iTipoTransacao   AS INTEGER NO-UNDO.

DEFINE VARIABLE h-TSSAPI              AS HANDLE      NO-UNDO.
DEFINE VARIABLE lEnvioXMLCancelaTSSOK AS LOGICAL     NO-UNDO.
DEFINE VARIABLE cReturnValueAPITSS    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cChaveAcesso          AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cMensagemErro         AS CHARACTER   NO-UNDO.

DEFINE VARIABLE h-axsep006            AS HANDLE      NO-UNDO.
DEFINE VARIABLE h-axsep002            AS HANDLE      NO-UNDO.
DEFINE VARIABLE h-axsep003            AS HANDLE      NO-UNDO.
DEFINE VARIABLE i-tipo-transacao      as integer     no-undo.

DEFINE VARIABLE c-motivo    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-opcao     AS INT NO-UNDO.
{int\wsinventti0000.i}

//DEFINE VARIABLE h-axsep006      AS HANDLE      NO-UNDO.
DEFINE VARIABLE c-xml           AS LONGCHAR NO-UNDO.  
DEFINE VARIABLE c-url           AS CHAR     NO-UNDO.

/*Defini‡Æo da temp-table utilizado pela include axrep012upsert.i (TSSSChemaRet)*/
DEFINE TEMP-TABLE tt_nfe_erro  NO-UNDO
    FIELD cStat      AS CHAR    /* C¢digo do Status da resposta */
    FIELD chNFe      AS CHAR   /* Chave de acesso da Nota Fiscal Eletr“nica */
    FIELD dhRecbto   AS CHAR   /* Data/Hora da homologacao do cancelamento */
    FIELD nProt      AS CHAR.  /* N£mero do protocolo de aprovacao */

ASSIGN iTipoTransacao = ?.
 
ASSIGN cDescCancela = fn-free-accent(cDescCancela).

FIND FIRST nota-fiscal NO-LOCK
    WHERE ROWID(nota-fiscal) = rwNotaFiscal NO-ERROR.


FOR FIRST ser-estab NO-LOCK WHERE 
    ser-estab.cod-estabel = nota-fiscal.cod-estabel AND
    ser-estab.serie = nota-fiscal.serie:
    IF ser-estab.forma-emis = 2 /* Manual */ THEN RETURN "NOK".
END.

IF  cProcessamento BEGINS "Inutiliza":U THEN DO:

END.
IF  cProcessamento = "Cancelamento":U THEN DO:

    FIND FIRST esp_integracao 
        WHERE  esp_integracao.id_integracao = 1 NO-ERROR.
         
    FIND FIRST esp_servico_integracao
                       WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao
                       AND  esp_servico_integracao.descricao = "CANCELAMENTO NFe"
                       NO-LOCK NO-ERROR.      

    ASSIGN c-url = trim(esp_integracao.URL) + trim(esp_servico_integracao.servico) . 
    ASSIGN i-opcao = 1. // Cancelar  
    
    RUN int\wsinventti0003.p  (input nota-fiscal.cod-estabel,
                               input nota-fiscal.serie,      
                               input nota-fiscal.nr-nota-fis,
                               INPUT cDescCancela,
                               INPUT 110111,
                               INPUT i-opcao, 
                               OUTPUT c-xml).
    IF c-xml <> "" THEN
    DO:   
        RUN int\wsinventti0001.p  (INPUT  c-url, 
                                   INPUT  c-xml,
                                   OUTPUT v-retonro-integracao).  
                                   
        IF string(v-retonro-integracao) <> "" THEN 
            RUN int\wsinventti0005.p  (INPUT v-retonro-integracao, 
                                       ROWID(nota-fiscal)).   

        RUN int\wsinventti0004.p  (input nota-fiscal.cod-estabel,
                                 input nota-fiscal.serie,      
                                 input nota-fiscal.nr-nota-fis).                              
     END.

END.

RETURN "OK":U.
