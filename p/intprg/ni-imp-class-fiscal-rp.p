/********************************************************************************
**
**  Programa - NI-IMP-CLASS-FISCAL-RP.P - Importa‡Æo Classifica‡Æo Fiscal
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-CLASS-FISCAL-RP 2.00.00.000 } 

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

DEF TEMP-TABLE tt-class-fiscal
    FIELD it-codigo    LIKE ITEM.it-codigo
    FIELD class-fiscal LIKE ITEM.class-fiscal.

DEF TEMP-TABLE tt-erro
    FIELD chave     AS CHAR FORMAT "x(90)"
    FIELD desc-erro AS CHAR FORMAT "x(40)".

DEF VAR i-cont       AS INT FORMAT ">>>,>>9"   NO-UNDO.
DEF VAR h-acomp      AS HANDLE                 NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importa‡Æo Class. Fiscal").

EMPTY TEMP-TABLE tt-class-fiscal.
EMPTY TEMP-TABLE tt-erro.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".
 
ASSIGN i-cont = 0.

REPEAT:  
   CREATE tt-class-fiscal.
   IMPORT DELIMITER ";" tt-class-fiscal NO-ERROR.  

   assign i-cont = i-cont + 1.

   run pi-acompanhar in h-acomp (input "Criando tt-class-fiscal: " + string(tt-class-fiscal.it-codigo) + " - " + string(i-cont)).
END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.

for each tt-class-fiscal:

    assign i-cont = i-cont + 1.

    run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-class-fiscal.it-codigo) + " - " + string(i-cont)).

    FIND FIRST classif-fisc WHERE
               classif-fisc.class-fiscal = tt-class-fiscal.class-fiscal NO-LOCK NO-ERROR.
    IF NOT AVAIL classif-fisc THEN DO:
       FIND FIRST tt-erro WHERE
                  tt-erro.chave = "Class. Fiscal: " + tt-class-fiscal.class-fiscal NO-ERROR.
       IF NOT AVAIL tt-erro THEN DO:
          CREATE tt-erro.
          ASSIGN tt-erro.chave     = "Class. Fiscal: " + tt-class-fiscal.class-fiscal
                 tt-erro.desc-erro = "Classificacao Fiscal nao cadastrada".
       END.
       NEXT.
    END.

    FIND FIRST ITEM WHERE
               ITEM.it-codigo = tt-class-fiscal.it-codigo NO-ERROR.
    IF NOT AVAIL ITEM THEN DO:
       FIND FIRST tt-erro WHERE
                  tt-erro.chave = "Item: " + tt-class-fiscal.it-codigo NO-ERROR.
       IF NOT AVAIL tt-erro THEN DO:
          CREATE tt-erro.
          ASSIGN tt-erro.chave     = "Item: " + tt-class-fiscal.it-codigo
                 tt-erro.desc-erro = "Item nao cadastrado".
       END.
       NEXT.
    END.

    ASSIGN ITEM.class-fiscal = tt-class-fiscal.class-fiscal.

    CREATE int-ds-item.
    ASSIGN int-ds-item.tipo-movto                 = 2 /* Altera‡Æo */            
           int-ds-item.dt-geracao                 = TODAY
           int-ds-item.hr-geracao                 = STRING(TIME,"hh:mm:ss") 
           int-ds-item.cod-usuario                = "super"
           int-ds-item.situacao                   = 1 /* Pendente */
           int-ds-item.pro_codigo_n               = int(item.it-codigo) 
           int-ds-item.pro_descricaocupomfiscal_s = item.desc-item 
           int-ds-item.pro_datacadastro_d         = item.data-implant
           int-ds-item.pro_ncm_s                  = substr(tt-class-fiscal.class-fiscal,1,8)
           int-ds-item.pro_grupocomercial_n       = INT(item.fm-cod-com)
           int-ds-item.pro_ncmipi_n               = int(tt-class-fiscal.class-fiscal).

    FIND FIRST int-ds-ext-item WHERE
               int-ds-ext-item.it-codigo = item.it-codigo NO-ERROR.
    IF NOT AVAIL int-ds-ext-item THEN DO:
       CREATE int-ds-ext-item.
       ASSIGN int-ds-ext-item.it-codigo = ITEM.it-codigo.
    END.
    ASSIGN int-ds-ext-item.ncmipi = int(tt-class-fiscal.class-fiscal).
    
    /* Atualiza‡Æo da tabela de integra‡Æo Datasul -> Sysfarma */
    /*               C¢digos de Barra dos Itens - EAN              */  

    FOR EACH int-ds-ean-item WHERE
             int-ds-ean-item.it-codigo = item.it-codigo NO-LOCK:

        CREATE int-ds-item-compl.
        ASSIGN int-ds-item-compl.tipo-movto          = 2 /* Altera‡Æo */
               int-ds-item-compl.dt-geracao          = TODAY
               int-ds-item-compl.hr-geracao          = STRING(TIME,"hh:mm:ss") 
               int-ds-item-compl.cod-usuario         = "super"
               int-ds-item-compl.situacao            = 1 /* Pendente */
               int-ds-item-compl.cba-produto-n       = INT(int-ds-ean-item.it-codigo)        
               int-ds-item-compl.cba-ean-n           = int-ds-ean-item.codigo-ean          
               int-ds-item-compl.cba-lotemultiplo-n  = int-ds-ean-item.lote-multiplo       
               int-ds-item-compl.cba-altura-n        = int-ds-ean-item.altura              
               int-ds-item-compl.cba-largura-n       = int-ds-ean-item.largura             
               int-ds-item-compl.cba-profundidade-n  = int-ds-ean-item.profundidade        
               int-ds-item-compl.cba-peso-n          = int-ds-ean-item.peso                
               int-ds-item-compl.cba-data-cadastro-d = int-ds-ean-item.data-cadastro       
               int-ds-item-compl.cba-principal-s     = IF int-ds-ean-item.principal = YES THEN
                                                          "S"
                                                       ELSE 
                                                          "N".         
    END.

    FOR EACH it-carac-tec WHERE
             it-carac-tec.it-codigo = item.it-codigo AND
             it-carac-tec.cd-folha  = "CADITEM" NO-LOCK:
    
        IF it-carac-tec.cd-comp = "10" THEN
           ASSIGN int-ds-item.pro_descricaoetiqueta_s = substr(it-carac-tec.observacao,1,30).
    
        IF it-carac-tec.cd-comp = "20" THEN
           ASSIGN int-ds-item.pro_descricaoweb_s = it-carac-tec.observacao.
    
        IF it-carac-tec.cd-comp = "25" THEN
           ASSIGN int-ds-item.pro_divisao_n = INT(substr(it-carac-tec.observacao,1,3)).          
    
        IF it-carac-tec.cd-comp = "30" THEN
           ASSIGN int-ds-item.pro_tipoproduto_n = INT(substr(it-carac-tec.observacao,1,1)).
    
        IF it-carac-tec.cd-comp = "40" THEN
           ASSIGN int-ds-item.pro_categoriaconvenio_n = INT(substr(it-carac-tec.observacao,1,2)).
    
        IF it-carac-tec.cd-comp = "45" THEN
           ASSIGN int-ds-item.pro_sazonalidade_n = INT(substr(it-carac-tec.observacao,1,1)).                   
    
        IF it-carac-tec.cd-comp = "60" THEN
           ASSIGN int-ds-item.pro_subgrupocomercial_n = INT(substr(it-carac-tec.observacao,1,3)).
    
        IF it-carac-tec.cd-comp = "65" THEN
           ASSIGN int-ds-item.pro_sigla_pdv_s = substr(it-carac-tec.observacao,1,15). 
    
        IF it-carac-tec.cd-comp = "70" THEN
           ASSIGN int-ds-item.pro_gerapedido_s = substr(it-carac-tec.observacao,1,1). 
        
        IF item.cod-obsoleto = 1 THEN
           ASSIGN int-ds-item.pro_situacaoproduto_s = "A".
    
        IF item.cod-obsoleto = 2 OR item.cod-obsoleto = 3 THEN
           ASSIGN int-ds-item.pro_situacaoproduto_s = "E".
    
        IF item.cod-obsoleto = 4 THEN
           ASSIGN int-ds-item.pro_situacaoproduto_s = "I".
    
        IF it-carac-tec.cd-comp = "90" THEN
           ASSIGN int-ds-item.pro_lista_s = substr(it-carac-tec.observacao,1,1).                
    
        IF it-carac-tec.cd-comp = "100" THEN
           ASSIGN int-ds-item.pro_fracionado_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "110" THEN
           ASSIGN int-ds-item.pro_lastro_n = it-carac-tec.vl-result.
    
        IF it-carac-tec.cd-comp = "120" THEN
           ASSIGN int-ds-item.pro_camada_n = it-carac-tec.vl-result.         
    
        IF it-carac-tec.cd-comp = "140" THEN
           ASSIGN int-ds-item.pro_publicoalvo_n = INT(substr(it-carac-tec.observacao,1,1)).
    
        IF it-carac-tec.cd-comp = "150" THEN
           ASSIGN int-ds-item.pro_informaprescricao_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "170" THEN
           ASSIGN int-ds-item.pro_monitorado_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "180" THEN
           ASSIGN int-ds-item.pro_tarjado_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "190" THEN
           ASSIGN int-ds-item.pro_sngpc_n  = INT(substr(it-carac-tec.observacao,1,1)).
    
        IF it-carac-tec.cd-comp = "200" THEN DO:
           IF substr(it-carac-tec.observacao,1,2) = "  " THEN
              ASSIGN int-ds-item.pro_portaria_s = "".
           ELSE
              ASSIGN int-ds-item.pro_portaria_s = substr(it-carac-tec.observacao,1,2).
        END.
    
        IF it-carac-tec.cd-comp = "210" THEN
           ASSIGN int-ds-item.pro_apresentacao_n = it-carac-tec.vl-result.
    
        IF it-carac-tec.cd-comp = "225" THEN
           ASSIGN int-ds-item.pro_dosagemapresentacao_n = INT(substr(it-carac-tec.observacao,1,2)).
    
        IF it-carac-tec.cd-comp = "230" THEN
           ASSIGN int-ds-item.pro_concentracao_n = it-carac-tec.vl-result.
    
        IF it-carac-tec.cd-comp = "240" THEN
           ASSIGN int-ds-item.pro_dosagemconcentracao_n = INT(substr(it-carac-tec.observacao,1,2)).
    
        IF it-carac-tec.cd-comp = "250" THEN
           ASSIGN int-ds-item.pro_nomecomercial_s = it-carac-tec.observacao. 
    
        IF it-carac-tec.cd-comp = "255" THEN
           ASSIGN int-ds-item.pro_datasngpc_d = it-carac-tec.dt-result. 
    
        IF it-carac-tec.cd-comp = "260" THEN
           ASSIGN int-ds-item.pro_csta_n = INT(substr(it-carac-tec.observacao,1,1)).
    
        IF it-carac-tec.cd-comp = "270" THEN
           ASSIGN int-ds-item.pro_unidademedidamedicamento_n = INT(substr(it-carac-tec.observacao,1,1)).
    
        IF it-carac-tec.cd-comp = "280" THEN
           ASSIGN int-ds-item.pro_excecaopiscofinsncm_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "290" THEN
           ASSIGN int-ds-item.pro_tributapis_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "300" THEN
           ASSIGN int-ds-item.pro_tributacofins_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "310" THEN
           ASSIGN int-ds-item.pro_classificacaomedicamento_n = INT(substr(it-carac-tec.observacao,1,1)).
        
        IF it-carac-tec.cd-comp = "330" THEN
           ASSIGN int-ds-item.pro_utilizapautafiscal_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "340" THEN
           ASSIGN int-ds-item.pro_valorpautafiscal_n = it-carac-tec.vl-result.
    
        IF it-carac-tec.cd-comp = "350" THEN
           ASSIGN int-ds-item.pro_emiteetiqueta_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "360" THEN
           ASSIGN int-ds-item.pro_pbm_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "370" THEN
           ASSIGN int-ds-item.pro_cestabasica_s = substr(it-carac-tec.observacao,1,1).  
    
        IF it-carac-tec.cd-comp = "380" THEN
           ASSIGN int-ds-item.pro_reposicaopbm_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "390" THEN
           ASSIGN int-ds-item.pro_quantidadeembarque_n = DEC(it-carac-tec.observacao).          
    
        IF it-carac-tec.cd-comp = "400" THEN
           ASSIGN int-ds-item.pro_circuladeposito_s = substr(it-carac-tec.observacao,1,1).  
    
        IF it-carac-tec.cd-comp = "410" THEN
           ASSIGN int-ds-item.pro_aceitadevolucao_s = substr(it-carac-tec.observacao,1,1).     
    
        IF it-carac-tec.cd-comp = "420" THEN
           ASSIGN int-ds-item.pro_mercadologica_s = substr(it-carac-tec.observacao,1,2).          
    
        IF it-carac-tec.cd-comp = "430" THEN 
           ASSIGN int-ds-item.pro_registroms_n = DEC(it-carac-tec.observacao).
    END.
END.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importa‡Æo Classifica‡Æo Fiscal"
       c-programa     = "NI-IMP-CLASS-FISCAL-RP".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro:
    disp tt-erro.chave column-label "Chave"
         tt-erro.desc-erro column-label "Descri‡Æo"
         with width 132 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}





