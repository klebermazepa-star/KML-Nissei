/*********************************************************************************
**
**  Programa - NI-IMP-IT-CARAC-TEC-RP.P - Importa‡Æo Carac. T‚cnicas do Item
**
*********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-IT-CARAC-TEC-RP 2.00.00.000 } 

disable triggers for load of it-carac-tec.
disable triggers for load of it-res-carac.

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

DEF TEMP-TABLE tt-erro
    FIELD chave     AS CHAR FORMAT "x(20)"
    FIELD desc-erro AS CHAR FORMAT "x(40)".

def temp-table tt-carac-tec
    field PRO_CODIGO_N as integer	
    field PRO_DESCRICAOETIQUETA_S as char	
    field PRO_DESCRICAOWEB_S as char	
    field PRO_DIVISAO_N as integer	
    field PRO_TIPOPRODUTO_N as integer	
    field PRO_CATEGORIACONVENIO_N as INTEGER 
    field PRO_SAZONALIDADE_N as integer	
    field PRO_SUBGRUPOCOMERCIAL_N as integer	
    field PRO_SIGLAPDV_S as char	
    field PRO_GERAPEDIDO_S as char	
    field PRO_SITUACAOPRODUTO_S as char	
    field PRO_LISTA_S as char	
    field PRO_FRACIONADO_S as char	
    field PRO_LASTRO_N as integer	
    field PRO_CAMADA_N as integer	
    field PRO_PUBLICOALVO_N as integer	
    field PRO_INFORMAPRESCRICAO_S as char	
    field PRO_REGISTROMS_N as DECIMAL DECIMALS 0  
    field PRO_MONITORADO_S as char	
    field PRO_TARJADO_S as char	
    field PRO_SNGPC_N as integer	
    field PRO_PORTARIA_S as char	
    field PRO_APRESENTACAO_N as decimal	
    field PRO_DOSAGEMAPRESENTACAO_N as integer	
    field PRO_CONCENTRACAO_N as decimal	
    field PRO_DOSAGEMCONCENTRACAO_N as integer	
    field PRO_NOMECOMERCIAL_S as char	
    field PRO_DATASNGPC_D as date format "99/99/9999"	
    field PRO_CSTA_N as integer	
    field PRO_UNIDADEMEDIDAMEDICAMENTO_N as integer	
    field PRO_EXCECAOPISCOFINSNCM_S as char	
    field PRO_TRIBUTAPIS_S as char	
    field PRO_TRIBUTACOFINS_S as char	
    field PRO_CLASSIFICACAOMEDICAMENTO_N as integer	
    field PRO_UTILIZAPAUTAFISCAL_S as char	
    field PRO_VALORPAUTAFISCAL_N as decimal	
    field PRO_EMITEETIQUETA_S as char	
    field PRO_PBM_S as char	
    field PRO_CESTABASICA_S as char	
    field PRO_REPOSICAOPBM_S as char	
    field PRO_QUANTIDADEEMBARQUE_N as integer	
    field PRO_CIRCULADEPOSITO_S as char	
    field PRO_ACEITADEVOLUCAO_S as CHAR
    FIELD PRO_MERCADOLOGICA_S AS CHAR.

DEF VAR i-dia AS INT FORMAT "99"   NO-UNDO.
DEF VAR i-mes AS INT FORMAT "99"   NO-UNDO.
DEF VAR i-ano AS INT FORMAT "9999" NO-UNDO.
DEF VAR h-acomp AS HANDLE          NO-UNDO.
def var i-cont as int format ">>>,>>>,>>9".
DEF VAR c-lista AS CHAR FORMAT "x(1)" NO-UNDO.
DEF VAR c-sub-grupo AS CHAR FORMAT "x(3)" NO-UNDO.
def new global shared var i-ep-codigo-usuario as char no-undo.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo Carac. Tec. Item").

EMPTY TEMP-TABLE tt-carac-tec.
EMPTY TEMP-TABLE tt-erro.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".

assign i-cont = 0.
 
REPEAT:  
   CREATE tt-carac-tec.
   IMPORT DELIMITER ";" tt-carac-tec.  

   assign i-cont = i-cont + 1.

   run pi-acompanhar in h-acomp (input "Criando tt-carac-tec: " + string(tt-carac-tec.PRO_CODIGO_N) + " - " + string(i-cont)).

END. 
    
INPUT CLOSE.

ASSIGN i-cont = 0.

FOR EACH it-res-carac:
    DELETE it-res-carac.
END.

FOR EACH tt-carac-tec:

    assign i-cont = i-cont + 1.

    run pi-acompanhar in h-acomp (input "Importando Carac. Tec.: " + string(tt-carac-tec.PRO_CODIGO_N) +  " - " + string(i-cont)).
    
    FOR EACH it-carac-tec WHERE 
             it-carac-tec.it-codigo = string(tt-carac-tec.PRO_CODIGO_N) AND
             it-carac-tec.cd-folha  = "CADITEM":

        IF it-carac-tec.cd-comp = "10" THEN
           ASSIGN it-carac-tec.observacao = substr(tt-carac-tec.PRO_DESCRICAOETIQUETA_S,1,40).                    
                                                                                                        
        IF it-carac-tec.cd-comp = "20" THEN                                                                     
           ASSIGN it-carac-tec.observacao = substr(tt-carac-tec.PRO_DESCRICAOWEB_S,1,40).                                        
                                                                                                                    
        IF it-carac-tec.cd-comp = "25" THEN DO:        
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 25 AND
                      c-tab-res.descricao BEGINS substr(string(tt-carac-tec.PRO_DIVISAO_N),1,3) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.                                                                                                                                                                                                    
                                                                                                        
        IF it-carac-tec.cd-comp = "30" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 30 AND
                      c-tab-res.descricao BEGINS substr(string(tt-carac-tec.PRO_TIPOPRODUTO_N),1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.                                                                                                                                                                                                    
                                                                                                        
        IF it-carac-tec.cd-comp = "40" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 40 AND
                      c-tab-res.descricao BEGINS SUBSTR(string(tt-carac-tec.PRO_CATEGORIACONVENIO_N),1,2) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.                                                                                                                                                                                                    

        IF it-carac-tec.cd-comp = "45" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 45 AND
                      c-tab-res.descricao BEGINS SUBSTR(string(tt-carac-tec.PRO_SAZONALIDADE_N),1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "60" THEN DO:   
           IF LENGTH(string(tt-carac-tec.PRO_SUBGRUPOCOMERCIAL_N)) = 1 THEN
              ASSIGN c-sub-grupo = "00" + string(tt-carac-tec.PRO_SUBGRUPOCOMERCIAL_N).
           IF LENGTH(string(tt-carac-tec.PRO_SUBGRUPOCOMERCIAL_N)) = 2 THEN
              ASSIGN c-sub-grupo = "0" + string(tt-carac-tec.PRO_SUBGRUPOCOMERCIAL_N).
           IF LENGTH(string(tt-carac-tec.PRO_SUBGRUPOCOMERCIAL_N)) = 3 THEN
              ASSIGN c-sub-grupo = string(tt-carac-tec.PRO_SUBGRUPOCOMERCIAL_N).

           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 60 AND
                      c-tab-res.descricao BEGINS c-sub-grupo NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.
                                                                                                        
        IF it-carac-tec.cd-comp = "65" THEN                                                             
           ASSIGN it-carac-tec.observacao = tt-carac-tec.PRO_SIGLAPDV_S.
                                                                                                        
        IF it-carac-tec.cd-comp = "70" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 70 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_GERAPEDIDO_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.
                                                                                                        
        IF it-carac-tec.cd-comp = "80" THEN DO:                                                             
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 80 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_SITUACAOPRODUTO_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.
                                                                                                        
        IF it-carac-tec.cd-comp = "90" THEN DO:
           ASSIGN c-lista = SUBSTR(tt-carac-tec.PRO_LISTA_S,1,1).
           IF c-lista = "" THEN
              ASSIGN c-lista = "-".
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 90 AND
                      c-tab-res.descricao BEGINS c-lista NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "100" THEN DO:                                                           
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 100 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_FRACIONADO_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.
           
        IF it-carac-tec.cd-comp = "110" THEN                                                            
           ASSIGN it-carac-tec.vl-result = tt-carac-tec.PRO_LASTRO_N.                                   
                                                                                                        
        IF it-carac-tec.cd-comp = "120" THEN                                                            
           ASSIGN it-carac-tec.vl-result = tt-carac-tec.PRO_CAMADA_N.                                    
                                                                                                        
        IF it-carac-tec.cd-comp = "140" THEN DO:                                                            
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 140 AND
                      c-tab-res.descricao BEGINS SUBSTR(string(tt-carac-tec.PRO_PUBLICOALVO_N),1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "150" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 150 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_INFORMAPRESCRICAO_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "160" THEN
           ASSIGN it-carac-tec.vl-result = tt-carac-tec.PRO_REGISTROMS_N.

        IF it-carac-tec.cd-comp = "170" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 170 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_MONITORADO_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "180" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 180 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_TARJADO_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "190" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 190 AND
                      c-tab-res.descricao BEGINS SUBSTR(string(tt-carac-tec.PRO_SNGPC_N),1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "200" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 200 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_PORTARIA_S,1,2) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "210" THEN
           ASSIGN it-carac-tec.vl-result = tt-carac-tec.PRO_APRESENTACAO_N.

        IF it-carac-tec.cd-comp = "225" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 240 AND
                      c-tab-res.descricao BEGINS SUBSTR(string(tt-carac-tec.PRO_DOSAGEMAPRESENTACAO_N),1,2) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "230" THEN
           ASSIGN it-carac-tec.vl-result = tt-carac-tec.PRO_CONCENTRACAO_N.

        IF it-carac-tec.cd-comp = "240" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 240 AND
                      c-tab-res.descricao BEGINS SUBSTR(string(tt-carac-tec.PRO_DOSAGEMCONCENTRACAO_N),1,2) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "250" THEN
           ASSIGN it-carac-tec.observacao = tt-carac-tec.PRO_NOMECOMERCIAL_S. 

        IF it-carac-tec.cd-comp = "255" THEN
           ASSIGN it-carac-tec.dt-result = tt-carac-tec.PRO_DATASNGPC_D.

        IF it-carac-tec.cd-comp = "260" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 260 AND
                      c-tab-res.descricao BEGINS SUBSTR(string(tt-carac-tec.PRO_CSTA_N),1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "270" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 270 AND
                      c-tab-res.descricao BEGINS SUBSTR(string(tt-carac-tec.PRO_UNIDADEMEDIDAMEDICAMENTO_N),1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "280" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 280 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_EXCECAOPISCOFINSNCM_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo 
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "290" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 290 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_TRIBUTAPIS_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "300" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 300 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_TRIBUTACOFINS_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "310" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 310 AND
                      c-tab-res.descricao BEGINS SUBSTR(string(tt-carac-tec.PRO_CLASSIFICACAOMEDICAMENTO_N),1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        /*IF it-carac-tec.cd-comp = "320" THEN
           ASSIGN int-ds-item.pro_aceitadevolucao_s = substr(it-carac-tec.observacao,1,1).*/

        IF it-carac-tec.cd-comp = "330" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 330 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_UTILIZAPAUTAFISCAL_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "340" THEN
           ASSIGN it-carac-tec.vl-result = tt-carac-tec.PRO_VALORPAUTAFISCAL_N.

        IF it-carac-tec.cd-comp = "350" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 350 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_EMITEETIQUETA_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "360" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 360 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_PBM_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "370" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 370 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_CESTABASICA_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "380" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 380 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_REPOSICAOPBM_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "390" THEN
           ASSIGN it-carac-tec.vl-result = tt-carac-tec.PRO_QUANTIDADEEMBARQUE_N.          

        IF it-carac-tec.cd-comp = "400" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 400 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_CIRCULADEPOSITO_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "410" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 410 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_ACEITADEVOLUCAO_S,1,1) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.

        IF it-carac-tec.cd-comp = "420" THEN DO:
           FIND FIRST c-tab-res WHERE
                      c-tab-res.nr-tabela = 420 AND
                      c-tab-res.descricao BEGINS SUBSTR(tt-carac-tec.PRO_MERCADOLOGICA_S,1,2) NO-LOCK NO-ERROR.
           IF AVAIL c-tab-res THEN DO:
              create it-res-carac.
              assign it-res-carac.cd-comp    = it-carac-tec.cd-comp
                     it-res-carac.cd-folha   = it-carac-tec.cd-folh
                     it-res-carac.it-codigo  = it-carac-tec.it-codigo
                     it-res-carac.nr-tabela  = it-carac-tec.nr-tabela
                     it-res-carac.sequencia  = c-tab-res.sequencia
                     it-carac-tec.observacao = c-tab-res.descricao.
           END.                                                                                         
        END.
    END.
END.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importa‡Æo de Carac. Tec. do Item"
       c-programa     = "NI-IMP-IT-CARAC-TEC-RP".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro:
    disp tt-erro.chave column-label "Chave"
         tt-erro.desc-erro column-label "Descri‡Æo"
         with width 132 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}
