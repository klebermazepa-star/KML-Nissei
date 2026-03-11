/* include de controle de versao */
{include/i-prgvrs.i ESPDOC003RP 1.00.00.001KML}

define temp-table tt-param no-undo
    field destino                as integer
    field arquivo                as char format "x(35)"
    field usuario                as char format "x(12)"
    field data-exec              as date
    field hora-exec              as integer
    field classifica             as integer
    field desc-classifica        as char format "x(40)"
    field modelo                 AS char format "x(35)"
    field l-habilitaRtf          as LOG
    FIELD ClienteInicial  as character 
    FIELD ClienteFinal    as character 
    FIELD DataIni         AS DATE 
    FIELD DataFinal       as DATE 
    FIELD TipoIni         as character 
    FIELD TipoFinal       as character
    
    .
    


define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.


/* Transfer Definitions */
def temp-table tt-raw-digita
   field raw-digita      as raw.
   


/* Recebimentro de Parametros */   
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

 

create tt-param.
raw-transfer raw-param to tt-param.



{include/i-rpvar.i}

def var h-acomp          as handle    no-undo.
def var i-aux            as int       no-undo.
def var c-linha          as char      no-undo.
def var c-fator          as char      no-undo.



find first param-global no-lock no-error.
assign c-programa 	  = 'ESPDOC003RP'
       c-versao	      = '1.00'
       c-revisao      = '.00.001KML'
       c-sistema      = 'Relatorio'
       c-titulo-relat = 'Relatorio Tipo Documentos'. 

    
       
{include/i-rpout.i}

/* include padrao TOTVS-11 */
/*{include/comp.i}*/

/* include com a definicao da frame de cabecalho e rodape */
//{include/i-rpcab.i}

run utp/ut-acomp.p PERSISTENT set h-acomp.
{utp/ut-liter.i Atualizando *}
run pi-inicializar in h-acomp (input return-value).




output to value ("U:\ESPDOC003.csv").


EXPORT DELIMITER ";" 
    "Codigo Cliente" "Nome abreviado" "CNPJ/CPF" "Tipo documento" "Data atualizacao" "Data Vencimento" "Obrigatorio" "Bloqueia faturamento" .



FOR EACH esp-tipo-doc-emitente NO-LOCK
    WHERE esp-tipo-doc-emitente.cod-emitente >= tt-param.ClienteInicial
    AND   esp-tipo-doc-emitente.cod-emitente  <= tt-param.ClienteFinal:
    
    FOR EACH esp-tipo-doc NO-LOCK
        WHERE esp-tipo-doc.cod-emitente =   esp-tipo-doc-emitente.cod-emitente:
        
        
        FIND FIRST ems2mult.emitente NO-LOCK
            WHERE  emitente.cod-emitente = int(esp-tipo-doc.cod-emitente) NO-ERROR.
        
        EXPORT DELIMITER ";"
                 esp-tipo-doc.cod-emitente  
                 emitente.nome-abrev
                 emitente.cgc
                 esp-tipo-doc.tipo-documento
                 esp-tipo-doc.Data-documento
                 esp-tipo-doc.Data-validade 
                 esp-tipo-doc.obrigatorio    
                 esp-tipo-doc.bloqueia-vendas .
    
    
    END.

END.
              
OUTPUT CLOSE.

/*Table: esp-tipo-doc

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
tipo-documento              char       i   x(50)
Descricao                   char           x(150)
obrigatorio                 logi           sim/nao
bloqueia-vendas             logi           sim/nao
cod-emitente                char       i   x(25)
Data-documento              date           99/99/9999
Data-validade               date           99/99/9999
caminho-documento           char           x(150)*/



/* fechamento do output do relatorio */
{include/i-rpclo.i}
run pi-finalizar in h-acomp.

OS-COMMAND NO-WAIT VALUE("U:\ESPDOC003.csv").
 
return "OK":U.
  
