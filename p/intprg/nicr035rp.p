/* include de controle de versao */
{include/i-prgvrs.i NICR035RP.P 1.00.00.001KML}

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
    field Data_ini               as DATE format "99/99/9999":U
    field Data_fim               as DATE format "99/99/9999":U
    FIELD Estabelec_ini          as CHAR format "x(5)":U
    field Estabelec_fim          as CHAR format "x(5)":U
    
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
assign c-programa 	  = 'NICR035RP'
       c-versao	      = '1.00'
       c-revisao      = '.00.001KML'
       c-sistema      = 'Relatorio'
       c-titulo-relat = 'Relatorio Erastinho'. 

    
       
{include/i-rpout.i}

/* include padrao TOTVS-11 */
/*{include/comp.i}*/

/* include com a definicao da frame de cabecalho e rodape */
//{include/i-rpcab.i}

run utp/ut-acomp.p PERSISTENT set h-acomp.
{utp/ut-liter.i Atualizando *}
run pi-inicializar in h-acomp (input return-value).




output to value ("U:\NICR035.csv").


EXPORT DELIMITER ";" 
    "Data EmissÆo" "Nota fiscal" "Parcela" "Estabelecimento" "Especie" "serie" "Data vencimento" "Portador" "Emitente" "Nome Emitente" "Valor Parcela" "Total nota" .

FOR EACH estabelec NO-LOCK
    WHERE estabelec.cod-estabel  >= tt-param.Estabelec_ini
    AND   estabelec.cod-estabel  <= tt-param.Estabelec_fim:
    
    FOR EACH nota-fiscal NO-LOCK
        WHERE nota-fiscal.dt-emis-nota >= date(tt-param.Data_ini)
        AND   nota-fiscal.dt-emis-nota <= date(tt-param.Data_fim)
        AND   nota-fiscal.cod-estabel  = estabelec.cod-estabel
        AND   nota-fiscal.serie        = "901" :
        
        
        
        FIND FIRST ems2mult.emitente NO-LOCK
            WHERE emitente.nome-abrev = nota-fiscal.nome-ab-cli NO-ERROR.

        FOR EACH fat-duplic NO-LOCK
            WHERE fat-duplic.cod-estabel = nota-fiscal.cod-estabel 
              and fat-duplic.serie         = nota-fiscal.serie      
              and fat-duplic.nr-fatura     = nota-fiscal.nr-nota-fis  :
              
            
              
            EXPORT DELIMITER ";"
                 fat-duplic.dt-emissao  
                 fat-duplic.nr-fatura
                 fat-duplic.parcela
                 fat-duplic.cod-estabel
                 fat-duplic.cod-esp
                 fat-duplic.serie
                 fat-duplic.dt-venciment
                 fat-duplic.int-1
                 emitente.cod-emitente
                 emitente.nome-emit
                 fat-duplic.vl-parcela
                 nota-fiscal.vl-tot-nota .
              
        END.      
    END.   
END.  

OUTPUT CLOSE.



/* fechamento do output do relatorio */
{include/i-rpclo.i}
run pi-finalizar in h-acomp.

OS-COMMAND NO-WAIT VALUE("U:\NICR035.csv").
 
return "OK":U.
