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
{ftp/ftapi512.i}

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
/*
DEFINE TEMP-TABLE tt_log_erro NO-UNDO
     FIELD ttv_des_msg_ajuda AS CHARACTER INITIAL ?
     FIELD ttv_des_msg_erro  AS CHARACTER INITIAL ?
     FIELD ttv_num_cod_erro  AS INTEGER   INITIAL ? .
*/
/*Definiá∆o da temp-table utilizado pela include axrep012upsert.i (TSSSChemaRet)*/
DEFINE TEMP-TABLE tt_nfe_erro  NO-UNDO
    FIELD cStat      AS CHAR    /* C¢digo do Status da resposta */
    FIELD chNFe      AS CHAR   /* Chave de acesso da Nota Fiscal Eletrìnica */
    FIELD dhRecbto   AS CHAR   /* Data/Hora da homologacao do cancelamento */
    FIELD nProt      AS CHAR.  /* N£mero do protocolo de aprovacao */

DEFINE TEMP-TABLE tt_log_erro NO-UNDO
     FIELD ttv_num_cod_erro AS integer INITIAL ?
     FIELD ttv_des_msg_ajuda AS character INITIAL ?
     FIELD ttv_des_msg_erro AS character INITIAL ?.

function PrintChar returns longchar
    (input pc-string as longchar):

    /* necess†rio para que a funá∆o seja case-sensitive */
    define variable c-string as longchar case-sensitive no-undo.
    define variable i-ind as integer no-undo.

    assign c-string = pc-string.

    assign c-string = replace(c-string,"†","a").
    assign c-string = replace(c-string,"Ö","a").
    assign c-string = replace(c-string,"∆","a").
    assign c-string = replace(c-string,"É","a").
    assign c-string = replace(c-string,"Ñ","a").

    assign c-string = replace(c-string,"Ç","e").
    assign c-string = replace(c-string,"ä","e").
    assign c-string = replace(c-string,"à","e").
    assign c-string = replace(c-string,"â","e").

    assign c-string = replace(c-string,"°","i").
    assign c-string = replace(c-string,"ç","i").
    assign c-string = replace(c-string,"å","i").
    assign c-string = replace(c-string,"ã","i").

    assign c-string = replace(c-string,"¢","o").
    assign c-string = replace(c-string,"ï","o").
    assign c-string = replace(c-string,"ì","o").
    assign c-string = replace(c-string,"î","o").
    assign c-string = replace(c-string,"‰","o").

    assign c-string = replace(c-string,"£","u").
    assign c-string = replace(c-string,"ó","u").
    assign c-string = replace(c-string,"ñ","u").
    assign c-string = replace(c-string,"Å","u").

    assign c-string = replace(c-string,"á","c").
    assign c-string = replace(c-string,"§","n").

    assign c-string = replace(c-string,"Ï","y").
    assign c-string = replace(c-string,"ò","y").

    assign c-string = replace(c-string,"µ","A").
    assign c-string = replace(c-string,"∑","A").
    assign c-string = replace(c-string,"«","A").
    assign c-string = replace(c-string,"∂","A").
    assign c-string = replace(c-string,"é","A").

    assign c-string = replace(c-string,"ê","E").
    assign c-string = replace(c-string,"‘","E").
    assign c-string = replace(c-string,"“","E").
    assign c-string = replace(c-string,"”","E").

    assign c-string = replace(c-string,"÷","I").
    assign c-string = replace(c-string,"ﬁ","I").
    assign c-string = replace(c-string,"◊","I").
    assign c-string = replace(c-string,"ÿ","I").

    assign c-string = replace(c-string,"‡","O").
    assign c-string = replace(c-string,"„","O").
    assign c-string = replace(c-string,"‚","O").
    assign c-string = replace(c-string,"ô","O").
    assign c-string = replace(c-string,"Â","O").

    assign c-string = replace(c-string,"È","U").
    assign c-string = replace(c-string,"Î","U").
    assign c-string = replace(c-string,"Í","U").
    assign c-string = replace(c-string,"ö","U").

    assign c-string = replace(c-string,"Ä","C").
    assign c-string = replace(c-string,"•","N").
                                        
    assign c-string = replace(c-string,"Ì","Y").

    assign c-string = replace(c-string,CHR(13),"").
    assign c-string = replace(c-string,CHR(10),"").

    assign c-string = replace(c-string,"˚","").
    assign c-string = replace(c-string,"≠","").
    assign c-string = replace(c-string,"˝","2").
    assign c-string = replace(c-string,"¸","3").
    assign c-string = replace(c-string,"œ","o").
    assign c-string = replace(c-string,"∞","E").
    assign c-string = replace(c-string,"¨","1/4").
    assign c-string = replace(c-string,"´","1/2").
    assign c-string = replace(c-string,"Û","3/4").
    assign c-string = replace(c-string,"æ","Y").
    assign c-string = replace(c-string,"û","x").
    assign c-string = replace(c-string,"Á","p").
    assign c-string = replace(c-string,"©","r").
    assign c-string = replace(c-string,"Ü","a").
    assign c-string = replace(c-string,"·","B").
    assign c-string = replace(c-string,"–","y").
    assign c-string = replace(c-string,"õ","o").
    assign c-string = replace(c-string,"Ù","").
    assign c-string = replace(c-string,"ë","ae").
    assign c-string = replace(c-string,"Ê","u").
    assign c-string = replace(c-string,"®","").
    assign c-string = replace(c-string,"∫","").
    assign c-string = replace(c-string,"ı","").
    assign c-string = replace(c-string,"è","A").
    assign c-string = replace(c-string,"©","").
    assign c-string = replace(c-string,"Ë","p").
    assign c-string = replace(c-string,"Æ","-").
    assign c-string = replace(c-string,"Ø","-").
    assign c-string = replace(c-string,"™","").
    assign c-string = replace(c-string,"™","").
    assign c-string = replace(c-string,"Ù","").
    assign c-string = replace(c-string,"ù","0").
    assign c-string = replace(c-string,"—","D").
    assign c-string = replace(c-string,"·","B").
    assign c-string = replace(c-string,"í","").
    assign c-string = replace(c-string,"∏","").
    assign c-string = replace(c-string,"ú","").
    assign c-string = replace(c-string,"ı","").

    assign c-string = replace(c-string,"ˆ","").
    assign c-string = replace(c-string,"›","").
    assign c-string = replace(c-string,"¯","o").
    assign c-string = replace(c-string,"Ω","c").

    do i-ind = 1 to 31:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 127 to 144:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 147 to 159:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 162 to 182:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 184 to 191:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 215 to 216:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 248 to 248:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.

    assign c-string = trim(c-string).

    return c-string.

end function.

ASSIGN iTipoTransacao = ?.

ASSIGN cDescCancela = fn-free-accent(cDescCancela)                               /* substitui os acentos */
       cDescCancela = REPLACE(REPLACE(cDescCancela, CHR(13), " "), CHR(10), " ") /* substitui os break-lines por espaáo em branco */
       cDescCancela = fn-trata-caracteres(cDescCancela)                          /* retira qualquer caracter especial n∆o aceito pelo TSS/SEFAZ */
       cDescCancela = "Motivo ":U + fn-free-accent(cProcessamento) + ": ":U + cDescCancela. /* foi fixado esse texto pois a msg de cancelamento deve ter no minimo 15 caracteres */              

FOR FIRST nota-fiscal NO-LOCK
    WHERE ROWID(nota-fiscal) = rwNotaFiscal: END.

/*
IF  NOT AVAIL param-nf-estab THEN
    FOR FIRST param-nf-estab NO-LOCK
        WHERE param-nf-estab.cod-estabel = nota-fiscal.cod-estabel: END.

IF  NOT AVAIL param-nf-estab THEN
    RETURN "NOK":U.
*/

FOR FIRST ser-estab NO-LOCK WHERE 
    ser-estab.cod-estabel = nota-fiscal.cod-estabel AND
    ser-estab.serie = nota-fiscal.serie:
    IF ser-estab.forma-emis = 2 /* Manual */ THEN RETURN "NOK".
END.

IF  cProcessamento BEGINS "Inutiliza":U THEN DO:

    IF NOT VALID-HANDLE(h-axsep003) THEN 
       RUN adapters/xml/NDD/intndd003.p PERSISTENT SET h-axsep003.
       
    for first estabelec fields (cod-estabel cgc estado des-vers-layout char-1) 
                no-lock where estabelec.cod-estabel = nota-fiscal.cod-estabel: end.

    RUN PITransUpsert IN h-axsep003 (INPUT estabelec.estado,
                                     INPUT int(SUBSTRING(STRING(YEAR(TODAY),"9999"),3,2)),
                                     INPUT estabelec.cgc,
                                     INPUT "55",
                                     INPUT nota-fiscal.serie,
                                     INPUT string(int(nota-fiscal.nr-nota-fis)),
                                     INPUT string(int(nota-fiscal.nr-nota-fis)),
                                     INPUT PrintChar(cDescCancela),
                                     INPUT ROWID(nota-fiscal),
                                     OUTPUT TABLE tt_log_erro,
                                     OUTPUT TABLE tt_nfe_erro).

    IF VALID-HANDLE(h-axsep003) THEN DELETE PROCEDURE h-axsep003.

    /* OBTER XML DA NFE PARA ENVIO NA TRANSACAO CANCELANOTAS DO TSS 
    IF  NOT VALID-HANDLE(h-axsep006) THEN
        RUN adapters/xml/ep2/axsep006.p PERSISTENT SET h-axsep006.
    
    RUN pi-setaObtemXMLNFe IN h-axsep006 (INPUT YES). /* seta axsep006 para obter o XML da NFe */

    RUN PITransUpsert      IN h-axsep006 (INPUT  "upd":U,
                                          INPUT  "InvoiceNFe":U,
                                          INPUT  ROWID(nota-fiscal),
                                          OUTPUT TABLE tt_log_erro).

    RUN pi-retornaXMLNFe   IN h-axsep006 (OUTPUT lcXMLNFe).
    
    ASSIGN ttNFETSSCancel.XML = lcXMLNFe.

    IF  VALID-HANDLE(h-axsep006) THEN DO:
        DELETE procedure h-axsep006.
        ASSIGN h-axsep006 = ?.
    END.
    FIM - OBTER XML DA NFE PARA ENVIO NA TRANSACAO CANCELANOTAS DO TSS */
END.
IF  cProcessamento = "Cancelamento":U THEN DO:

   /* IF  NOT VALID-HANDLE(h-axsep002) THEN
        RUN adapters/xml/NDD/intndd002.p PERSISTENT SET h-axsep002.

    RUN PITransUpsert IN h-axsep002 (INPUT PrintChar(cDescCancela),
                                     INPUT ROWID(nota-fiscal),
                                     OUTPUT TABLE tt_log_erro,
                                     OUTPUT TABLE tt_nfe_erro).
    
    IF  VALID-HANDLE(h-axsep002) then delete procedure h-axsep002.*/

    /* OBTER XML DA NFE PARA ENVIO NA TRANSACAO CANCELANOTAS DO TSS 
    IF  NOT VALID-HANDLE(h-axsep006) THEN
        RUN adapters/xml/ep2/axsep006.p PERSISTENT SET h-axsep006.
    
    RUN pi-setaObtemXMLNFe IN h-axsep006 (INPUT YES). /* seta axsep006 para obter o XML da NFe */

    RUN PITransUpsert      IN h-axsep006 (INPUT  "upd":U,
                                          INPUT  "InvoiceNFe":U,
                                          INPUT  ROWID(nota-fiscal),
                                          OUTPUT TABLE tt_log_erro).

    RUN pi-retornaXMLNFe   IN h-axsep006 (OUTPUT lcXMLNFe).
    
    ASSIGN ttNFETSSCancel.XML = lcXMLNFe.

    IF  VALID-HANDLE(h-axsep006) THEN DO:
        DELETE procedure h-axsep006.
        ASSIGN h-axsep006 = ?.
    END.
    FIM - OBTER XML DA NFE PARA ENVIO NA TRANSACAO CANCELANOTAS DO TSS */
END.

RETURN "OK":U.
