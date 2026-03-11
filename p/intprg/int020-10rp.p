/********************************************************************************
** Programa: INT020-10RP - Geracao notas fiscais a partir de Cupom Fiscal PRS
**
** Versao : 12 - 20/03/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de versao */
{include/i-prgvrs.i INT020-10RP 2.12.01.AVB}
{cdp/cdcfgdis.i}

/* defini‡ao das temp-tables para recebimento de parametros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    FIELD altera-cupom     AS DATE
    FIELD altera-convenio  AS LOGICAL .

def temp-table tt-raw-digita
        field raw-digita	as raw.

def temp-table tt-cst_nota_fiscal like cst_nota_fiscal.
def temp-table tt-int_ds_nota_loja_cartao like int_ds_nota_loja_cartao
    field cod-esp       like fat-duplic.cod-esp
    field cod-vencto    like fat-duplic.cod-vencto
    field cod-cond-pag  like nota-fiscal.cod-cond-pag
    field cod-portador  like nota-fiscal.cod-portador
    field modalidade    like nota-fiscal.modalidade.

def temp-table tt-int_ds_nota_loja-10 like int_ds_nota_loja
    field rowid-nota-loja as rowid
    INDEX r-rowid IS UNIQUE rowid-nota-loja
    index data
          emissao.

{cdp/cd4305.i1}  /* Definicao da temp-table tt-docto e tt-it-doc            */
{cdp/cd4314.i2}  /* Definicao da temp-table tt-nota-trans                   */
{cdp/cd4401.i3}  /* Definicao da temp-table tt-saldo-estoq                  */
{cdp/cd4313.i1}  /* Def da temp-table tt-cond-pag e tt-fat-duplic           */
{cdp/cd4313.i4}  /* Def da temp-table tt-rateio-it-duplic                   */
{ftp/ft2070.i1}  /* Definicao da temp-table tt-fat-repre                    */
{ftp/ft2073.i1}  /* Definicao das temp-tables tt-nota-embal e tt-item-embal */
{ftp/ft2010.i1}  /* Definicao da temp-table tt-notas-geradas                */
{ftp/ft2015.i}   /* Temp-table tt-docto-bn e tt-it-docto-bn                 */
{cdp/cd4305.i2}  /* Temp-table tt-it-nota-doc                               */
{ftp/ft2015.i2}  /* Temp-table tt-desp-nota-fisc                            */

/* temp-tables das API's e BO's */
{method/dbotterr.i}

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "INT020-10.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

/* include padrao para vari veis de relat¢rio  */
{include/i-rpvar.i}

/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
define buffer bemitente for emitente.

{intprg/int020rp-1.i} /* Defini‡Æo de vari veis */

{utp/ut-glob.i}

/* defini‡ao de frames do relat¢rio */
form i-nr-registro    column-label "Sequencia"
     tb-erro[1]       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 300
     down stream-io frame f-erro.

/* include com a defini‡ao da frame de cabe‡alho e rodap‚ */
/*{include/i-rpcab.i &stream="str-rp"}*/
{include/i-rpcab.i}
/* bloco principal do programa */

function OnlyNumbers returns char
    (p-char as char):

    def var i-ind as integer no-undo.
    def var c-aux as char no-undo.
    do i-ind = 1 to length (p-char):
        if lookup (substring(p-char,i-ind,1),"1,2,3,4,5,6,7,8,9,0") > 0 then
            assign c-aux = c-aux + substring(p-char,i-ind,1).
    end.
    return c-aux.
end.

find first tt-param no-lock no-error.
assign c-programa       = "INT020-10RP"
       c-versao         = "2.12"
       c-revisao        = ".01.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Importa‡Æo de Notas Fiscais - Cupons - PRS"
       c-prog-log       = "INT020-10RP.P".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social
       i-cupom   = 0.

do:
   run utp/ut-acomp.p persistent set h-acomp.
   run pi-inicializar in h-acomp (input "Processando").

   IF tt-param.arquivo <> "" THEN DO:
       /*{include/i-rpout.i &stream = "stream str-rp"}*/
       {include/i-rpout.i}
                             
       view /*stream str-rp*/ frame f-cabec.
       view /*stream str-rp*/ frame f-rodape.
   END.
   FOR FIRST int_ds_ger_cupom NO-LOCK: END.
   IF NOT AVAIL int_ds_ger_cupom THEN DO:
       assign i-erro = 45
              c-informacao = "".
       run gera-log. 
       /* fechamento do output do relatorio  */
       IF tt-param.arquivo <> "" THEN DO:
           /*{include/i-rpclo.i &stream="stream str-rp"}*/
           {include/i-rpclo.i}
       END.
       /* elimina BO's */
       return "OK".
   END.
   run pi-importa.

   pause 3 no-message.
end.
/* ----- fim do programa -------- */
run pi-elimina-tabelas.

RUN intprg/int888.p (INPUT "CUPOM",
                     INPUT "INT020").

run pi-finalizar in h-acomp.

IF tt-param.arquivo <> "" THEN DO:
    /* fechamento do output do relatorio  */
    /*{include/i-rpclo.i &stream="stream str-rp"}*/
    {include/i-rpclo.i}
END.

/* elimina BO's */
return "OK".

/* procedures */

procedure pi-elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   empty temp-table tt-docto.
   empty temp-table tt-it-docto.
   empty temp-table tt-it-imposto.
   empty temp-table tt-saldo-estoq.
   empty temp-table tt-nota-trans.
   empty temp-table tt-fat-duplic.
   empty temp-table tt-fat-repre.
   empty temp-table tt-nota-embal.
   empty temp-table tt-item-embal.
   empty temp-table tt-cst_nota_fiscal. 
   empty temp-table tt-fat-duplic. 
   empty temp-table tt-int_ds_nota_loja_cartao. 
   empty temp-table tt-notas-geradas .
   empty temp-table RowErrors.   
end.        

procedure pi-importa:

    DEFINE BUFFER b_int_ds_nota_loja FOR int_ds_nota_loja.
    
    assign i-nr-registro  = 0
           i-nr-sequencia = 0.

    EMPTY TEMP-TABLE tt-int_ds_nota_loja-10.

    FOR EACH estabelec USE-INDEX codigo WHERE 
             estabelec.cod-estabel >= int_ds_ger_cupom.cod_estab_ini_10 AND
             estabelec.cod-estabel <= int_ds_ger_cupom.cod_estab_fim_10 NO-LOCK:

        for each int_ds_nota_loja no-lock USE-INDEX sit_cnpj_emiss where 
                 int_ds_nota_loja.situacao    = 1 AND
                 int_ds_nota_loja.cnpj_filial = estabelec.cgc
                 query-tuning(no-lookahead):
            
            run pi-acompanhar in h-acomp (input "Carregando informa‡äes: " + estabelec.cod-estabel + " - " + string(int_ds_nota_loja.emissao,"99/99/9999")).
            FOR FIRST tt-int_ds_nota_loja-10 WHERE 
                tt-int_ds_nota_loja-10.rowid-nota-loja = ROWID(int_ds_nota_loja): END.
            IF NOT AVAIL tt-int_ds_nota_loja-10 THEN DO:
                CREATE tt-int_ds_nota_loja-10.
                BUFFER-COPY int_ds_nota_loja TO tt-int_ds_nota_loja-10.
                ASSIGN tt-int_ds_nota_loja-10.rowid-nota-loja = ROWID(int_ds_nota_loja).
            END.
        end.
    END.

    FOR EACH tt-int_ds_nota_loja-10 USE-INDEX data:

        FIND FIRST int_ds_nota_loja NO-LOCK
            WHERE ROWID(int_ds_nota_loja) = tt-int_ds_nota_loja-10.rowid-nota-loja NO-ERROR. 
        IF AVAIL int_ds_nota_loja THEN DO:


            /* Ajuste de dados do cupom fiscal */
           IF tt-param.altera-Cupom <> ? THEN DO:

               if int(int_ds_nota_loja.convenio) > 0 
                   AND tt-param.altera-convenio = NO THEN NEXT.
               
               FIND first param-estoq NO-LOCK NO-ERROR. 

                IF MONTH (param-estoq.ult-fech-dia) = 12 THEN
                     ASSIGN c-aux = string(year(param-estoq.ult-fech-dia) + 1,"9999") + "01".
                 ELSE
                     ASSIGN c-aux = string(year(param-estoq.ult-fech-dia),"9999") + string(month(param-estoq.ult-fech-dia) + 1,"99").

                 IF (c-aux = string(year(int_ds_nota_loja.emissao),"9999") + string(month(int_ds_nota_loja.emissao),"99") and
                    (param-estoq.fase-medio <> 1 or param-estoq.pm-j -ini = yes)) or
                     param-estoq.ult-fech-dia >= int_ds_nota_loja.emissao then do:

                    IF int_ds_nota_loja.emissao < tt-param.altera-Cupom THEN DO:

                         FIND FIRST b_int_ds_nota_loja EXCLUSIVE-LOCK
                             WHERE ROWID(b_int_ds_nota_loja) = ROWID(int_ds_nota_loja) NO-ERROR.

                         ASSIGN b_int_ds_nota_loja.emissao = tt-param.altera-Cupom.  
                         RELEASE  b_int_ds_nota_loja.

                     END.
                END. 
            END.
             /* Fim do ajuste das datas */
           
           run pi-acompanhar in h-acomp (input "Processando dia: " + string(int_ds_nota_loja.emissao,"99/99/9999")).
           {intprg/int020rp-2.i}

        END.
    END.

    run importa-nota.
    run pi-elimina-tabelas.
end.

{intprg/int020rp-3.i}

