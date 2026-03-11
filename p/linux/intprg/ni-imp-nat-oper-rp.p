/********************************************************************************
**
**  Programa - NI-IMP-NAT-OPER-RP.P - Importa‡Æo Naturezas de Opera‡Æo
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-NAT-OPER-RP 2.00.00.000 } 

disable triggers for load of natur-oper.

def temp-table tt-natur-oper     like natur-oper.    
/*    field cod-maq-origem   as   integer format "9999"       initial 0
    field num-processo     as   integer format ">>>>>>>>9" initial 0
    field num-sequencia    as   integer format ">>>>>9"    initial 0
    field ind-tipo-movto   as   integer format "99"        initial 1
    INDEX ch-codigo IS PRIMARY  cod-maq-origem
                                num-processo
                                num-sequencia.*/
 
def temp-table tt-versao-integr no-undo
       field cod-versao-integracao as integer format "999"
       field ind-origem-msg        as integer format "99" /* i01mp900.i */.
             
def temp-table tt-erros-geral no-undo
       field identif-msg           as char    format "x(60)"
       field num-sequencia-erro    as integer format "999"
       field cod-erro              as integer format "99999"   
       field des-erro              as char    format "x(60)"
       field cod-maq-origem        as integer format "999"
       field num-processo          as integer format "999999999".                    

define temp-table tt-param
    field destino          as integer
    field arq-destino      as char
    field arq-entrada1     as char
    field todos            as integer
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer.

def temp-table tt-raw-digita                      
    field raw-digita      as raw.                 

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

def var c-denominacao as char format "x(35)".

CREATE tt-versao-integr.
ASSIGN tt-versao-integr.cod-versao-integracao = 001
       tt-versao-integr.ind-origem-msg        = 01.

create tt-param.
raw-transfer raw-param to tt-param.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
REPEAT:  
   CREATE tt-natur-oper.
   IMPORT DELIMITER ";" tt-natur-oper NO-ERROR.  
END. 
    
INPUT CLOSE.
  
for each tt-natur-oper where
         tt-natur-oper.nat-operacao <> "":

    /*find first natur-oper where
               natur-oper.nat-operacao = tt-natur-oper.nat-operacao no-error.
    if avail natur-oper then do:
       delete natur-oper.
    end.*/

    assign c-denominacao             = substr(tt-natur-oper.denominacao,1,35)
           tt-natur-oper.denominacao = c-denominacao.

    create natur-oper.
    buffer-copy tt-natur-oper to natur-oper.

    ASSIGN natur-oper.cod-model-nf-eletro  = "55"
           natur-oper.idi-tip-devol-consig = 1.

end.

/*OUTPUT TO c:/Nass/nat-oper.lst.

FOR EACH tt-natur-oper:
    DISP tt-natur-oper WITH 1 COL WIDTH 300 STREAM-IO NO-BOX FRAME f-nat.
END.

OUTPUT CLOSE. */

/*RUN cdp/cdapi304.p (INPUT  TABLE tt-versao-integr,
                    OUTPUT TABLE tt-erros-geral,
                    INPUT  TABLE tt-natur-oper).*/

/*run rep/reapi311.p (input  table tt-versao-integr,
                    output table tt-erros-geral,
                    input  table tt-natur-oper).*/

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importa‡Æo de Naturezas de Opera‡Æo"
       c-programa     = "NI-IMP-NAT-OPER-RP".

{include/i-rpcab.i}

view frame f-cabec.
view frame f-rodape.    

FOR EACH tt-erros-geral:
    DISP tt-erros-geral WITH STREAM-IO NO-BOX down WIDTH 132 FRAME f-erros.
END.

{include/i-rpclo.i}





