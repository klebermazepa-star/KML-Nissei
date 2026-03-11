/********************************************************************************        
*Programa.: wsinventti0000.i                                                    * 
*Descricao: Variaveis e temp-tables e rotinas usadas em mais de um  programa    * 
*Autor....: Raimundo                                                            * 
*Data.....: 12/2022                                                             * 
********************************************************************************/
{cdp/cdcfgdis.i}
{include/i-freeac.i}
DEFINE TEMP-TABLE nodes NO-UNDO
  FIELD NAME            AS CHARACTER
  FIELD nodevalue       AS CHARACTER
  FIELD PARENT          AS CHARACTER
  FIELD level           AS INTEGER
  FIELD name-temp-table AS CHAR
  FIELD seq-taq         AS INT.


DEF TEMP-TABLE tt-dados NO-UNDO
    FIELD protocolo AS CHAR 
    FIELD chave-nfe AS CHAR 
    FIELD situacao  AS CHAR SERIALIZE-NAME 'STATUS'
    FIELD Codigo    AS CHAR 
    FIELD descricao AS CHAR 
    FIELD cStat     AS CHAR
    FIELD xMotivo   AS CHAR .

DEF VAR iLevel               AS INT      NO-UNDO. 
DEF VAR Parentname           AS CHAR     NO-UNDO. 
DEF VAR i-sequencia          AS INT      NO-UNDO.
DEF VAR c-nome-temp-table    AS CHAR     NO-UNDO.
DEF var v-retonro-integracao AS LONGCHAR NO-UNDO.

DEFINE VAR XMLfilename AS CHARACTER NO-UNDO.
DEFINE VARIABLE hXML   AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot  AS HANDLE NO-UNDO.
DEF VAR c-arquivo AS CHAR NO-UNDO.
def var cCodigoErro as char no-undo.
def var cMensagem as char no-undo.
DEF VAR v-idi-sit-nf-eletro LIKE nota-fiscal.idi-sit-nf-eletro NO-UNDO.

DEFINE TEMP-TABLE tt_log_erro NO-UNDO
       field ttv_des_msg_ajuda as character initial ?
     field ttv_des_msg_erro  as character initial ?
     field ttv_num_cod_erro  as integer   initial ? .

procedure pi-cria-ret-nf-eletro:

    define input parameter pcod-estabel as char no-undo.
    define input parameter pserie       as char no-undo.
    define input parameter pnr-nota-fis as char no-undo.
    define input parameter pnProt       as char no-undo.

    .MESSAGE 'pnProt 'pnProt SKIP 
            'cCodigoErro ' cCodigoErro SKIP
            'cMensagem   ' cMensagem
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE "pi-cria-ret-nf-eletro ".

    for last ret-nf-eletro exclusive-lock where 
        ret-nf-eletro.cod-estabel = pcod-estabel and 
        ret-nf-eletro.cod-serie   = pserie       and 
        ret-nf-eletro.nr-nota-fis = pnr-nota-fis and 
        ret-nf-eletro.cod-msg     = cCodigoErro  and 
        ret-nf-eletro.dat-ret     = today        
        query-tuning(no-lookahead): end.

    if not avail ret-nf-eletro then do:
       IF cMensagem = "" THEN
          cMensagem = 'Enviado para processamento.'.
       create  ret-nf-eletro.
       assign  ret-nf-eletro.cod-estabel = pcod-estabel
               ret-nf-eletro.cod-serie   = pserie
               ret-nf-eletro.nr-nota-fis = pnr-nota-fis
               ret-nf-eletro.dat-ret     = today
               ret-nf-eletro.cod-msg     = cCodigoErro.
               
               .MESSAGE "protocolo" SKIP 
                        pnProt
                   VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    end.

    assign  ret-nf-eletro.hra-ret     = replace(string(time, "HH:MM:SS"),":","")
            ret-nf-eletro.cod-livre-2 = "Inventti - " + cMensagem
            ret-nf-eletro.log-ativo   = yes.
    &if "{&bf_dis_versao_ems}" >= "2.07" &then 
        ret-nf-eletro.cod-protoc  = pnProt.
    &else
        ret-nf-eletro.cod-livre-1 = pnProt.
    &endif

    release ret-nf-eletro.
end.


PROCEDURE pi-trata-retorno:
   def input parameter p-cod-estabel  like nota-fiscal.cod-estabel no-undo. 
   def input parameter p-serie        like nota-fiscal.serie       no-undo. 
   def input parameter p-nr-nota-fisc like nota-fiscal.nr-nota-fis no-undo. 

   FIND FIRST nota-fiscal 
        WHERE nota-fiscal.cod-estabel =  p-cod-estabel  //"017"
        AND   nota-fiscal.serie       =  p-serie        //'1'
        AND   nota-fiscal.nr-nota-fis =  p-nr-nota-fisc //'0004138'
        EXCLUSIVE-LOCK NO-ERROR.

   FOR EACH tt-dados:
       //DISP tt-dados WITH SCROLLABLE 1 COL.   //.descricao FORMAT "X(20)"
       ASSIGN cCodigoErro = tt-dados.codigo.

       CASE tt-dados.situacao:
           When "1"  then  assign v-idi-sit-nf-eletro = 2  cMensagem = "Recebida".
           When "2"  then  assign v-idi-sit-nf-eletro = 2  cMensagem = "Validada".
           When "3"  then  assign v-idi-sit-nf-eletro = 2  cMensagem = "Critica validacao".
           When "4"  then  assign v-idi-sit-nf-eletro = 9  cMensagem = "Enviada SEFAZ".
           When "6"  then  assign v-idi-sit-nf-eletro = 3  cMensagem = "100 - Autorizado o uso sa NFE".
           When "7"  then  assign v-idi-sit-nf-eletro = 4  cMensagem = 'Uso denegado'.  
           When "8"  then  assign v-idi-sit-nf-eletro = 5  cMensagem = "Documento Rejeitado".
           When "9"  then  assign v-idi-sit-nf-eletro = 6  cMensagem = "'Documento Cancelado".
           When "10" then  assign v-idi-sit-nf-eletro = 10 cMensagem = "Pendente Retorno Contingància".
           When "11" then  assign v-idi-sit-nf-eletro = 12 cMensagem = "NF-e em Processo de Cancelamento".
           When "12" then  assign v-idi-sit-nf-eletro = 13 cMensagem = "NF-e em Processo de Inutilizaá∆o".
           When "13" then  assign v-idi-sit-nf-eletro = 7  cMensagem = "Documento Inutilizado".
           When "40" then  assign v-idi-sit-nf-eletro = 10 cMensagem = "Enviada EPEC".
           When "41" then  assign v-idi-sit-nf-eletro = 15 cMensagem = "Registrada EPEC".
           When "90" then  assign v-idi-sit-nf-eletro = 14 cMensagem = "Pendente Retorno SEFAZ".
           When "91" then  assign v-idi-sit-nf-eletro = 1  cMensagem = "N∆o Localizada".
           When "92" then  assign v-idi-sit-nf-eletro = 8  cMensagem = "Pendente consulta SEFAZ".
           When "99" then  assign v-idi-sit-nf-eletro = 4  cMensagem = "Duplicada Emiss∆o".
       END CASE.

       //MESSAGE v-idi-sit-nf-eletro VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
       IF v-idi-sit-nf-eletro <> 3 THEN do:
          IF tt-dados.codigo <> " "  AND tt-dados.codigo <>  "0" THEN
             ASSIGN cMensagem = tt-dados.codigo + " - " + trim(cMensagem)  .
          
          IF trim(tt-dados.xmotivo) <> "" THEN 
             ASSIGN cMensagem = trim(cMensagem) + " " + trim(tt-dados.xmotivo).
       END.

       IF AVAIL nota-fiscal AND nota-fiscal.idi-sit-nf-eletro <> v-idi-sit-nf-eletro  THEN DO:

           .MESSAGE nota-fiscal.cod-chave-aces-nf-eletro SKIP
               "Chave TT-dados" SKIP
               tt-dados.chave-nfe SKIP
               "inventti0000"
               VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
          ASSIGN nota-fiscal.cod-protoc               = tt-dados.protocolo
                 nota-fiscal.idi-sit-nf-eletro        = v-idi-sit-nf-eletro.
                 //nota-fiscal.cod-chave-aces-nf-eletro = tt-dados.chave-nfe.

          .MESSAGE "Depois assign" SKIP
                nota-fiscal.cod-chave-aces-nf-eletro SKIP
              "inventti0000"
              VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                 
          
          RUN pi-cria-ret-nf-eletro(input p-cod-estabel,
                                    input p-serie,       
                                    input p-nr-nota-fisc,
                                    INPUT tt-dados.protocolo).
       END.
   END. /*FOR EACH tt-dados*/

END PROCEDURE.
