/********************************************************************************
** Programa: int122 - Envio notas fiscais p/ WebServer NDD
**
** Versao : 12 - 21/01/2019 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de versao */
{include/i-prgvrs.i int122rp 2.12.01.AVB}
{cdp/cdcfgdis.i}
{include/i-epc200.i} 
{utp/ut-glob.i}
{method/dbotterr.i}

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

def var h-acomp         as handle no-undo.

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
if tt-param.arquivo = "" then 
assign tt-param.arquivo = "int022.txt"
       tt-param.destino = 3
       tt-param.data-exec = TODAY
       tt-param.hora-exec = TIME.

/* include padrao para variáveis de relatório  */
{include/i-rpvar.i}

/* include com a definiçao da frame de cabeçalho e rodapé */
{include/i-rpcab.i}
/* bloco principal do programa */

form with frame f-rel down width 550 stream-io.

find first tt-param no-lock no-error.
assign c-programa       = "int122rp"
       c-versao         = "2.12"
       c-revisao        = ".01.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Envio de Notas Fiscais NDD".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

if tt-param.arquivo <> "" then do:
    {include/i-rpout.i}
                     
    view frame f-cabec.
    view frame f-rodape.
end.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Lendo Envios Pendentes").

/* Variaveis e procedures para tratamento de XML - NDD Web */
{xmlinc/xmlndd.i}

/* Carrega API auxiliar processamento de XML */
{xmlinc/xmlloadgenxml.i &GenXml="hGenXML" &GXReturnValue="cReturnValue"}

/* Enviar notas pedentes p/ NDD/SEFAZ - AVB 21/01/2019 - retirado envio do c lculo da nota */
for each bint_ndd_envio no-lock where 
    bint_ndd_envio.STATUSNUMBER = -1    and
    bint_ndd_envio.KIND         = 1     and
    bint_ndd_envio.protocolo    = ""    and
    bint_ndd_envio.dt_envio    >= today - 15
    break by bint_ndd_envio.cod_estabel 
            by bint_ndd_envio.serie
              by bint_ndd_envio.nr_nota_fis
                by bint_ndd_envio.dt_envio
                  by bint_ndd_envio.hr_envio:

 /* se nota for a £ltima, aguardar 5 minutos para garantir o t‚rmino da transa‡Æo do c lculo */
    if  not can-find (first nota-fiscal no-lock where 
                      nota-fiscal.cod-estabel  = bint_ndd_envio.cod_estabel and
                      nota-fiscal.serie        = bint_ndd_envio.serie and
                      nota-fiscal.nr-nota-fis  > bint_ndd_envio.nr_nota_fis) then do:

        IF bint_ndd_envio.serie <> "402" THEN DO:
            if  bint_ndd_envio.dt_envio = today and
            bint_ndd_envio.hr_envio > (time - 300) then next.
        END.

    end.

    run pi-acompanhar in h-acomp (input "Envio: " + string(bint_ndd_envio.ID)).

    c-job-ndd = bint_ndd_envio.JOB.
    find int_ndd_envio where 
        rowid(int_ndd_envio) = rowid(bint_ndd_envio) exclusive-lock no-error no-wait.
    if avail int_ndd_envio then do:
        /* enviar somente o promeiro envio pendente do dia caso seja clicado em enviar no ft0909 
           mais de uma vez antes da execu‡Æo do int022 */
        if first-of (bint_ndd_envio.dt_envio) then do:
            /* buscar nota bloqueando para evitar enviar notas ainda em c lculo */
            find nota-fiscal 
                exclusive-lock where
                nota-fiscal.cod-estabel = bint_ndd_envio.cod_estabel    and
                nota-fiscal.serie       = bint_ndd_envio.serie          and
                nota-fiscal.nr-nota-fis = bint_ndd_envio.nr_nota_fis    no-error no-wait.
            if avail nota-fiscal then do:

                run pi-inserirDocumento.
                display nota-fiscal.cod-estabel
                        nota-fiscal.serie
                        nota-fiscal.nr-nota-fis
                        nota-fiscal.dt-emis-nota
                        bint_ndd_envio.id
                        bint_ndd_envio.protocolo
                        bint_ndd_envio.statusnumber
                    with frame f-rel.
                down with frame f-rel.
            end.
            run pi-desconectaWebServer.
        end.
        /* ignorar demais envios duplicados */
        else do:
            assign int_ndd_envio.statusnumber = 9 /* ignorado */.
        end.
    end.
end.
pause 1 no-message.

run pi-finalizar in h-acomp.

if tt-param.arquivo <> "" then do:
    /* fechamento do output do relatorio  */
    {include/i-rpclo.i }
end.
if valid-handle(hGenXML) then delete object hGenXML no-error.

/* elimina BO's */
return "OK".

