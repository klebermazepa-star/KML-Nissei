
/* include de controle de versao */
{include/i-prgvrs.i NICR029RP.P 1.00.00.001}

define temp-table tt-param no-undo
    field destino               as integer
    field arquivo               as char format "x(35)"
    field usuario               as char format "x(12)"
    field data-exec             as date
    field hora-exec             as integer
    field classifica            as integer
    field desc-classifica       as char format "x(40)"
    field modelo                as char format "x(35)"
    field cod-estabel-ini       like nota-fiscal.cod-estabel
    field cod-estabel-fim       like nota-fiscal.cod-estabel
    field dt-emis-nota-ini      like nota-fiscal.dt-emis-nota
    field dt-emis-nota-fim      like nota-fiscal.dt-emis-nota
    FIELD tg-exporta            AS INTEGER
    .

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.

DEFINE BUFFER b_tit_acr FOR tit_acr.
DEFINE BUFFER b_fat-duplic FOR fat-duplic.

DEFINE VARIABLE c-arquivo AS CHARACTER   NO-UNDO.

DEFINE TEMP-TABLE tt-notas NO-UNDO
    FIELD nf-cod-estabel            like nota-fiscal.cod-estabel   
    FIELD nf-serie                  like nota-fiscal.serie         
    FIELD nf-nr-nota-fis            like nota-fiscal.nr-nota-fis 
    FIELD nf-nat-operacao           LIKE nota-fiscal.nat-operacao
    FIELD nf-dt-cancel              LIKE nota-fiscal.dt-cancel
    FIELD nf-dt-emis-nota           like nota-fiscal.dt-emis-nota  
    FIELD nf-cod-emitente           like nota-fiscal.cod-emitente  
    FIELD nf-vl-tot-nota            like nota-fiscal.vl-tot-nota   
    FIELD nf-dt-atual-cr            like nota-fiscal.dt-atual-cr   
    FIELD fat-cod-esp               like fat-duplic.cod-esp      
    FIELD fat-parcela               like fat-duplic.parcela      
    FIELD fat-vl-parcela            like fat-duplic.vl-parcela   
    FIELD fat-flag-atualiz          AS CHAR
    FIELD tit-cod_estab             like tit_acr.cod_estab           
    FIELD tit-cod_ser_docto         like tit_acr.cod_ser_docto  
    FIELD tit-cod_espec_docto       like tit_acr.cod_espec_docto 
    FIELD tit-cod_tit_acr           like tit_acr.cod_tit_acr         
    FIELD tit-cod_parcela           like tit_acr.cod_parcela         
    FIELD tit-dat_transacao         like tit_acr.dat_transacao       
    FIELD tit-cdn_cliente           like tit_acr.cdn_cliente         
    FIELD tit-val_origin_tit_acr    like tit_acr.val_origin_tit_acr
    FIELD tit-difer                 AS DECIMAL.

DEFINE BUFFER b-tt-notas FOR tt-notas.

DEFINE VARIABLE de-total-titulo AS DECIMAL     NO-UNDO.
    
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
assign c-programa 	  = 'NICR029RP'
       c-versao	      = '1.01'
       c-revisao      = '.00.001'
       c-empresa      = param-global.grupo
       c-sistema      = 'Notas Fiscais'
       c-titulo-relat = 'Concilia‡Æo transit¢ria de clientes'. 

{include/i-rpout.i}

/* include padrao TOTVS-11 */
/*{include/comp.i}*/

/* include com a definicao da frame de cabecalho e rodape */
{include/i-rpcab.i}

view frame f-cabec.
view frame f-rodape.

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Atualizando *}
run pi-inicializar in h-acomp (input return-value).



/*****************   MONTANDO TEMP-TABLE COM DADOS *****************/
    
FOR EACH nota-fiscal NO-LOCK // USE-INDEX nfftrm-23
    WHERE nota-fiscal.cod-estabel >= tt-param.cod-estabel-ini
      AND nota-fiscal.cod-estabel <= tt-param.cod-estabel-fim
      AND nota-fiscal.dt-emis-nota >= tt-param.dt-emis-nota-ini
      AND nota-fiscal.dt-emis-nota <= tt-param.dt-emis-nota-fim
    //  AND nota-fiscal.idi-sit-nf-eletro = 3 // Autorizado
    //  AND nota-fiscal.dt-cancel = ? // NÆo cancelada
    :


    RUN pi-acompanhar IN h-acomp (INPUT STRING("Carregando Notas: ") + 
                                    STRING(nota-fiscal.dt-emis-nota) + " | " +
                                    STRING(nota-fiscal.cod-estabel) + " | " +
                                    STRING(nota-fiscal.nr-nota-fis) ).

    FIND FIRST b_fat-duplic NO-LOCK
        WHERE b_fat-duplic.nr-fatura      = nota-fiscal.nr-fatura
          AND b_fat-duplic.cod-estabel    = nota-fiscal.cod-estabel
          AND b_fat-duplic.serie          = nota-fiscal.serie NO-ERROR.

    IF NOT AVAIL b_fat-duplic THEN DO:
        
        CREATE tt-notas.
        ASSIGN 
          nf-cod-estabel  = nota-fiscal.cod-estabel
          nf-serie        = nota-fiscal.serie
          nf-nr-nota-fis  = nota-fiscal.nr-nota-fis
          nf-nat-operacao = nota-fiscal.nat-operacao
          nf-dt-cancel    = nota-fiscal.dt-cancel
          nf-dt-emis-nota = nota-fiscal.dt-emis-nota
          nf-cod-emitente = nota-fiscal.cod-emitente
          nf-vl-tot-nota  = nota-fiscal.vl-tot-nota
          nf-dt-atual-cr  = nota-fiscal.dt-atual-cr.
    END.
    
    FOR EACH fat-duplic NO-LOCK
        WHERE fat-duplic.nr-fatura      = nota-fiscal.nr-fatura
          AND fat-duplic.cod-estabel    = nota-fiscal.cod-estabel
          AND fat-duplic.serie          = nota-fiscal.serie:

        CREATE tt-notas.
           ASSIGN 
              nf-cod-estabel  = nota-fiscal.cod-estabel
              nf-serie        = nota-fiscal.serie
              nf-nr-nota-fis  = nota-fiscal.nr-nota-fis
              nf-nat-operacao = nota-fiscal.nat-operacao
              nf-dt-emis-nota = nota-fiscal.dt-emis-nota
              nf-cod-emitente = nota-fiscal.cod-emitente
              nf-vl-tot-nota  = nota-fiscal.vl-tot-nota
              nf-dt-atual-cr  = nota-fiscal.dt-atual-cr.

        ASSIGN
           fat-cod-esp      = fat-duplic.cod-esp
           fat-parcela      = fat-duplic.parcela
           fat-vl-parcela   = fat-duplic.vl-parcela
           fat-flag-atualiz = IF fat-duplic.flag-atualiz THEN "Sim" ELSE "Nao".

        FIND FIRST tit_acr NO-LOCK
            WHERE tit_acr.cod_estab         = fat-duplic.cod-estabel
              AND tit_acr.cod_espec_docto   = fat-duplic.cod-esp
              AND tit_acr.cod_tit_acr       = fat-duplic.nr-fatura
              AND tit_acr.cod_parcela       = fat-duplic.parcela
              AND tit_acr.cod_ser_docto     = fat-duplic.serie 
             NO-ERROR.

        IF AVAIL tit_acr THEN DO:
                                                     
             ASSIGN
                tit-cod_estab             = tit_acr.cod_estab
                tit-cod_ser_docto         = tit_acr.cod_ser_docto
                tit-cod_espec_docto       = tit_acr.cod_espec_docto
                tit-cod_tit_acr           = tit_acr.cod_tit_acr
                tit-cod_parcela           = tit_acr.cod_parcela
                tit-dat_transacao         = tit_acr.dat_transacao
                tit-cdn_cliente           = tit_acr.cdn_cliente
                tit-val_origin_tit_acr    = tit_acr.val_origin_tit_acr.

        END.
        ELSE DO:

             FIND FIRST cst_fat_duplic NO-LOCK
                 WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
                   AND cst_fat_duplic.serie       = fat-duplic.serie
                   AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
                   AND cst_fat_duplic.parcela     = fat-duplic.parcela NO-ERROR.

             IF AVAIL cst_fat_duplic THEN DO:

                 FIND FIRST b_tit_acr NO-LOCK
                     WHERE b_tit_acr.cod_estab      = fat-duplic.cod-estabel
                       AND b_tit_acr.num_id_tit_acr = cst_fat_duplic.num_id_tit_acr NO-ERROR.

                 IF AVAIL b_tit_acr THEN DO:

                     ASSIGN
                         tit-cod_estab             = b_tit_acr.cod_estab             
                         tit-cod_ser_docto         = b_tit_acr.cod_ser_docto         
                         tit-cod_espec_docto       = b_tit_acr.cod_espec_docto
                         tit-cod_tit_acr           = b_tit_acr.cod_tit_acr           
                         tit-cod_parcela           = b_tit_acr.cod_parcela           
                         tit-dat_transacao         = b_tit_acr.dat_transacao         
                         tit-cdn_cliente           = b_tit_acr.cdn_cliente           
                         tit-val_origin_tit_acr    = b_tit_acr.val_origin_tit_acr.   
                 END.
    
             END.
        END.
    
    END.
    
END.

FOR EACH tt-notas
    BREAK BY tt-notas.tit-cod_estab    
          BY tt-notas.tit-cod_ser_docto
          BY tt-notas.tit-cod_espec_docto
          BY tt-notas.tit-cod_tit_acr  
          BY tt-notas.tit-cod_parcela :

    

    IF FIRST-OF(tit-cod_parcela) THEN DO:

        ASSIGN de-total-titulo = 0.

        FOR EACH b-tt-notas 
            WHERE b-tt-notas.tit-cod_estab     = tt-notas.tit-cod_estab      
              AND b-tt-notas.tit-cod_ser_docto = tt-notas.tit-cod_ser_docto  
              AND b-tt-notas.tit-cod_tit_acr   = tt-notas.tit-cod_tit_acr    
              AND b-tt-notas.tit-cod_parcela   = tt-notas.tit-cod_parcela 
              AND b-tt-notas.tit-cod_espec_docto = tt-notas.tit-cod_espec_docto
              AND b-tt-notas.nf-dt-cancel         = ? :

            ASSIGN de-total-titulo = de-total-titulo + b-tt-notas.fat-vl-parcela.


        END.

    END.

    ASSIGN tt-notas.tit-difer = tit-val_origin_tit_acr - de-total-titulo.


END.

/*****************   FIM MONTANDO TEMP-TABLE COM DADOS *****************/

IF tt-param.tg-exporta = 1 THEN DO:

    RUN pi-acompanhar IN h-acomp (INPUT STRING("Gerando CSV ") ).

    tt-param.arquivo = REPLACE(tt-param.arquivo , ".tmp" , ".csv" ).
    tt-param.arquivo = REPLACE(tt-param.arquivo , ".lst" , ".csv" ).

    c-arquivo = tt-param.arquivo.

    OUTPUT TO VALUE (c-arquivo).

    EXPORT DELIMITER ";"
        "NF - Estabel"
        "NF - Serie"
        "NF - Nota Fiscal"
        "NF - Natureza"
        "NF - Cancelada"
        "NF - Emissao"
        "NF - Cliente"
        "NF - Valor"
        "NF - Atualizado ACR"
        "DUP - Especie"
        "DUP - Parcela"
        "DUP - Valor Parc"
        "DUP - Atualizado ACR"
        "ACR - Estabel"
        "ACR - Serie"
        "ACR - Especie"
        "ACR - Titulo"
        "ACR - Parcela"
        "ACR - Data Trans"
        "ACR - Cliente"
        "ACR - Valor"
        "ACR - Diferenca Agrupamento".
    
    FOR EACH tt-notas:

        RUN pi-acompanhar IN h-acomp (INPUT STRING("Imprimindo Notas: ") + 
                                STRING(tt-notas.nf-dt-emis-nota) + " | " +
                                STRING(tt-notas.nf-cod-estabel) + " | " +
                                STRING(tt-notas.nf-nr-nota-fis) ).

    
         EXPORT DELIMITER ";"
             tt-notas.
    
    END.
    
    OUTPUT CLOSE.

    IF tt-param.destino = 3 THEN
        OS-COMMAND SILENT VALUE(c-arquivo) NO-ERROR.
    ELSE 
        MESSAGE "Arquivo salvo em: " SKIP
                 c-arquivo
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

END.
ELSE DO:  /***************   INICIANDO GERACAO DO EXCEL ******************/

    RUN pi-acompanhar IN h-acomp (INPUT STRING("Gerando arquivo excel ")).

    DEFINE VARIABLE i-linha     AS      INTEGER INIT 3                 NO-UNDO.    
    DEFINE VARIABLE c-planilha  AS      CHARACTER                      NO-UNDO.
    DEFINE VARIABLE chExcelAppl AS      COM-HANDLE                     NO-UNDO.
    DEFINE VARIABLE chWorkBook  AS      COM-HANDLE                     NO-UNDO.
    DEFINE VARIABLE chWorkSheet AS      COM-HANDLE                     NO-UNDO.
    DEFINE VARIABLE c-data      AS      CHARACTER FORMAT "x(16)"       NO-UNDO.
    ASSIGN c-data = STRING(TIME) 
           c-data = REPLACE(c-data,"/","-").



    ASSIGN c-planilha = SESSION:TEMP-DIRECTORY + "nicr029-" + string(TIME) + ".xlsx" .
    
    OS-COPY VALUE(SEARCH("intprg\nicr029.xlsx")) VALUE(c-planilha).
    CREATE 'Excel.Application':U chExcelAppl CONNECT NO-ERROR.
    IF  ERROR-STATUS:ERROR THEN
        CREATE 'Excel.Application':U chExcelAppl.

    
    chWorkBook  = chExcelAppl:WorkBooks:OPEN(c-planilha).
    chWorkBook:Activate().
    
    chExcelAppl:VISIBLE        = NO.
    chExcelAppl:ScreenUpdating = FALSE.    
    chWorkSheet = chExcelAppl:Sheets:Item(1). 

    /*************** FIM INCIIALICAO DO EXCEL ************************/
                                                        
    
    FOR EACH tt-notas:

        RUN pi-acompanhar IN h-acomp (INPUT STRING("Imprimindo Notas: ") + 
                        STRING(tt-notas.nf-dt-emis-nota) + " | " +
                        STRING(tt-notas.nf-cod-estabel) + " | " +
                        STRING(tt-notas.nf-nr-nota-fis) ).

        chWorkSheet:Range("A" + STRING (i-linha)) = tt-notas.nf-cod-estabel.
        chWorkSheet:Range("B" + STRING (i-linha)) = tt-notas.nf-nr-nota-fis.
        chWorkSheet:Range("C" + STRING (i-linha)) = tt-notas.nf-serie.
        chWorkSheet:Range("D" + STRING (i-linha)) = tt-notas.nf-nat-operacao.
        chWorkSheet:Range("E" + STRING (i-linha)) = tt-notas.nf-dt-cancel.
        chWorkSheet:Range("F" + STRING (i-linha)) = tt-notas.nf-dt-emis-nota.
        chWorkSheet:Range("G" + STRING (i-linha)) = tt-notas.nf-cod-emitente.
        chWorkSheet:Range("H" + STRING (i-linha)) = tt-notas.nf-vl-tot-nota.
        chWorkSheet:Range("I" + STRING (i-linha)) = tt-notas.nf-dt-atual-cr.
        chWorkSheet:Range("J" + STRING (i-linha)) = tt-notas.fat-cod-esp.
        chWorkSheet:Range("K" + STRING (i-linha)) = tt-notas.fat-parcela.
        chWorkSheet:Range("L" + STRING (i-linha)) = tt-notas.fat-vl-parcela.
        chWorkSheet:Range("M" + STRING (i-linha)) = tt-notas.fat-flag-atualiz.
        chWorkSheet:Range("N" + STRING (i-linha)) = tt-notas.tit-cod_estab.
        chWorkSheet:Range("O" + STRING (i-linha)) = tt-notas.tit-cod_tit_acr.
        chWorkSheet:Range("P" + STRING (i-linha)) = tt-notas.tit-cod_ser_docto.
        chWorkSheet:Range("Q" + STRING (i-linha)) = tt-notas.tit-cod_espec_docto.
        chWorkSheet:Range("R" + STRING (i-linha)) = tt-notas.tit-cod_parcela.
        chWorkSheet:Range("S" + STRING (i-linha)) = tt-notas.tit-dat_transacao.
        chWorkSheet:Range("T" + STRING (i-linha)) = tt-notas.tit-cdn_cliente.
        chWorkSheet:Range("U" + STRING (i-linha)) = tt-notas.tit-val_origin_tit_acr.
        chWorkSheet:Range("V" + STRING (i-linha)) = tt-notas.tit-difer.

        assign  i-linha = i-linha + 1. 
    
    END.

    
    /************** FECHAMENTO EXCEL ***************/
    
   NO-RETURN-VALUE chExcelAppl:SAVE  NO-ERROR.

    chExcelAppl:VISIBLE        = YES.
    chExcelAppl:ScreenUpdating = TRUE. 

    RELEASE OBJECT chExcelAppl NO-ERROR.
    RELEASE OBJECT chWorksheet NO-ERROR.
    RELEASE OBJECT chWorkbook  NO-ERROR.
    
     /************** FIM FECHAMENTO EXCEL ***********/    
END.


/* fechamento do output do relatorio */
{include/i-rpclo.i}
run pi-finalizar in h-acomp.

return "OK":U.


