/********************************************************************************
**
**  Programa - NI-IMP-BCO-CTA-AG-RP.P - Importaá∆o Banco, Conta e Agencia
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-BCO-CTA-AG-RP 2.00.00.000 } 

DISABLE TRIGGERS FOR LOAD OF cta-emitente.

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

DEF TEMP-TABLE tt-cta-emitente
    FIELD cdn_fornecedor         LIKE cta_corren_fornec.cdn_fornecedor       
    FIELD cod_banco              LIKE cta_corren_fornec.cod_banco            
    FIELD cod_agenc_bcia         LIKE cta_corren_fornec.cod_agenc_bcia       
    FIELD cod_digito_agenc_bcia  LIKE cta_corren_fornec.cod_digito_agenc_bcia
    FIELD cod_cta_corren_bco     LIKE cta_corren_fornec.cod_cta_corren_bco   
    FIELD cod_digito_cta_corren  LIKE cta_corren_fornec.cod_digito_cta_corren
    FIELD des_cta_corren         LIKE cta_corren_fornec.des_cta_corren 
    FIELD log_cta_corren         LIKE cta_corren_fornec.log_cta_corren.     

DEF TEMP-TABLE tt-erro
    FIELD cod-emitente LIKE emitente.cod-emitente
    FIELD desc-erro    AS CHAR FORMAT "x(50)"
    INDEX codigo cod-emitente.

def var c-agencia-aux as char format "x(9)"  no-undo.
def var c-conta-aux   as char format "x(12)" no-undo.
DEF VAR i-cont        AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp       AS HANDLE                   NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importaá∆o Banco, Conta e Agencia").

EMPTY TEMP-TABLE tt-cta-emitente.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

FOR EACH cta-emitente:
    DELETE cta-emitente.
END.

REPEAT:  
   CREATE tt-cta-emitente.
   IMPORT DELIMITER ";" tt-cta-emitente.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-cta-emitente: " + string(i-cont,">>>,>>>,>>9")).
END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                                
for each tt-cta-emitente:

    assign i-cont = i-cont + 1.
    run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-cta-emitente.cdn_fornecedor) + " - " + string(i-cont)).

    FOR FIRST emitente WHERE
              emitente.cod-emitente = tt-cta-emitente.cdn_fornecedor:
    END.
    IF NOT AVAIL emitente THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.cod-emitente = tt-cta-emitente.cdn_fornecedor
              tt-erro.desc-erro    = "Fornecedor n∆o cadastrado no EMS2 (emitente)".
       NEXT.
    END.

    IF AVAIL emitente AND emitente.identific = 3 THEN DO:
       ASSIGN emitente.identific      = 3 /* Ambos */
              emitente.cod-gr-forn    = 5
              emitente.portador       = 99999
              emitente.modalidade     = 6
              emitente.portador-ap    = 99999
              emitente.modalidade-ap  = 6
              emitente.tp-desp-padrao = 399.
    END.

    assign c-agencia-aux = trim(substring(tt-cta-emitente.cod_agenc_bcia, 1,6)) 
           c-conta-aux   = trim(substring(tt-cta-emitente.cod_cta_corren_bco, 1,10)).

    CREATE cta-emitente.
    ASSIGN cta-emitente.cod-emitente   = emitente.cod-emitente 
           cta-emitente.cod-banco      = int(tt-cta-emitente.cod_banco)
           cta-emitente.agencia        = (fill("0",6  - length(c-agencia-aux)) + c-agencia-aux) + STRING(tt-cta-emitente.cod_digito_agenc_bcia,"XX")
           cta-emitente.conta-corrente = (fill("0",10 - length(c-conta-aux))   + c-conta-aux)   + STRING(tt-cta-emitente.cod_digito_cta_corren,"XX")
           cta-emitente.descricao      = tt-cta-emitente.des_cta_corren
           cta-emitente.preferencial   = tt-cta-emitente.log_cta_corren.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importaá∆o Item x Fornecedor"
       c-programa     = "NI-IMP-ITEM-FORNEC-RP".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro BY tt-erro.desc-erro BY tt-erro.cod-emitente:
    disp tt-erro.cod-emitente COLUMN-LABEL "Fornecedor"
         tt-erro.desc-erro    COLUMN-LABEL "Descriá∆o Erro"
         with width 132 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}





