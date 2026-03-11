/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ni0302C 2.00.00.031 } /*** 010031 ***/
 
&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i ni0302c MFP}
&ENDIF

DEF INPUT-OUTPUT PARAM c-sepa         AS CHAR format "x"                    NO-UNDO.
DEF INPUT PARAM        i-tp-imposto   AS INTEGER                            NO-UNDO.
DEF OUTPUT PARAM       credito-1      as decimal                            NO-UNDO.
    
{intprg/ni0302.i4 SHARED}
{cdp/cdcfgdis.i}  /* pre-processadores */
/*
def shared var c-linha-branco as character format "x(132)"                NO-UNDO.
def shared var c-sep          as CHAR format "x"                          no-undo.
def shared var c-moeda        as character format "x(12)".
def shared var de-imp-deb     as decimal format ">>>>>>,>>>,>>>,>>9.99"   no-undo.
def shared var de-conv        as decimal                                  no-undo.
def shared var l-separadores  as logical format "Sim/Nao"                 no-undo.
def shared var de-imp-cre     as decimal format ">>>>>>,>>>,>>>,>>9.99"   no-undo. 
def shared var c-cod-est      like estabelec.cod-estabel                  no-undo.
def shared var i-num-pag      as int                                    no-undo.
def shared var i-terab        like termo.te-codigo                      no-undo.
def shared var i-teren        like termo.te-codigo                      no-undo.
def shared var da-iniper      like doc-fiscal.dt-docto                  no-undo.
def shared var da-fimper      like doc-fiscal.dt-docto                  no-undo.
def shared var i-moeda        like moeda.mo-codigo.

def VAR de-imposto     as decimal format ">>>>>>,>>>,>>>,>>9.99"   no-undo.
*/

def shared var h-acomp        as handle                                   no-undo.

def var l-impr-sep     as logical  init yes             no-undo. 
def var l-tem-funcao   as LOGICAL                       no-undo.
def var de-debito      as decimal                       no-undo.
def var de-credito     as decimal                       no-undo.
def var de-deducao     as decimal                       no-undo.
def var c-cpo          as char     extent 5             no-undo.
def var de-vlr         as decimal  extent 5             no-undo.
def var c-cpo2         as char     extent 5             no-undo.
def var de-vlr2        as decimal  extent 5             no-undo. 
def var de-vl-conv     as decimal  extent 43   init 0   no-undo.
def var c-descr-3      as character    extent 8         no-undo.  
def var de-valor-3     as decimal      extent 8         no-undo. 
def var l-primeiro     as logical                       no-undo.

def var de-vlr-1       as decimal.
def var de-vlr-2       as decimal.

def var total-1        as decimal.
def var total-2        as decimal.
def var total-3        as decimal.
def var debito-1       as decimal.
/*def var credito-1      as decimal.*/
def var i-pag-print    as integer                       no-undo. 
/*Variavel utilizada para controlar quebra de p†gina, esta variavel armazenarˇo número 
de linhas a ser impresso*/

{include/i-epc200.i} /*definicao tt-epc */
{include/tt-edit.i}  /** definiØ o da tabela p/ impress o do campo editor */

for first apur-imposto fields ( cod-estabel tp-imposto dt-apur-ini
                                    dt-apur-fim dt-entrega loc-entrega observacao )
         where apur-imposto.cod-estabel = c-estab-param
         and   apur-imposto.dt-apur-ini = da-iniper 
         and   apur-imposto.dt-apur-fim = da-fimper 
         and   apur-imposto.tp-imposto  = i-tp-imposto no-lock.
end.

assign c-cpo      = " "
       de-vlr     = 0 
       c-sepa     = if  c-sep <> "" 
                    then c-sep 
                    else "-"
       de-imposto = 0.

/*************************************************************/
for first estabelec fields ( ep-codigo nome cgc ins-estadual estado ) 
   where estabelec.cod-estabel = c-cod-est no-lock.
end.

IF NOT l-separadores THEN 
    PUT "" at 1.
/* Inicio -- Projeto Internacional */
DEFINE VARIABLE c-lbl-liter-debito-do-imposto AS CHARACTER FORMAT "X(19)" NO-UNDO.
{utp/ut-liter.i "DêBITO_DO_IMPOSTO" *}
ASSIGN c-lbl-liter-debito-do-imposto = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-valores-2 AS CHARACTER FORMAT "X(9)" NO-UNDO.
{utp/ut-liter.i "VALORES" *}
ASSIGN c-lbl-liter-valores-2 = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-coluna-auxiliar AS CHARACTER FORMAT "X(17)" NO-UNDO.
{utp/ut-liter.i "COLUNA_AUXILIAR" *}
ASSIGN c-lbl-liter-coluna-auxiliar = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-somas AS CHARACTER FORMAT "X(7)" NO-UNDO.
{utp/ut-liter.i "SOMAS" *}
ASSIGN c-lbl-liter-somas = TRIM(RETURN-VALUE).
put 
    c-sepa at 1 fill("-",130) format "x(130)" c-sepa SKIP
    c-sep at 1 
    c-sep at 4 
    c-lbl-liter-debito-do-imposto   
    c-sep at 82                                       
    c-lbl-liter-valores-2                                                
    at (if c-moeda <> "" then 90 else 104) 
    c-sep at 132 skip
    c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip                           
    c-sep at 1
    "|" at 4
    c-sep at (if c-moeda <> "" then 65 else 82) c-lbl-liter-coluna-auxiliar
    at (if c-moeda <> "" then 66 else 87)
    c-sep at (if c-moeda <> "" then 102 else 107)
    c-lbl-liter-somas      
    at (if c-moeda <> "" then 103 else 117).

if  c-moeda <> "" then    
    put c-moeda        format "x(12)"                            to 132 skip.
else
    put c-sep at 132 skip         
        c-sep at 1
        "|" at 4
        c-sep at 82
        fill("-",24) format "x(24)" 
        c-sep
        fill("-",24) format "x(24)"
        c-sep.

/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "|_001_-_POR_SA÷DAS/PRESTAÄÂES_COM_DêBITO_DO_IMPOSTO" *}
put c-sep at 1
    TRIM(RETURN-VALUE) FORMAT "X(53)" at 4
    c-sep at 82
    c-sep at (if c-moeda <> "" then 87 else 107)
    de-imp-deb              format ">>>>>,>>>,>>>,>>9.99"    
    at (if c-moeda <> "" then 88 else 112).

if  i-moeda <> 0 and de-vl-conv[1] > 0 then
    put "|" at 4 de-vl-conv[1]           format ">>>>,>>>,>>>,>>9.999" to 131.

assign i-pag-print = 1.

for each imp-valor fields ( cod-lanc descricao) of apur-imposto no-lock:
    if  imp-valor.cod-lanc = 2 then DO:
        assign i-pag-print = i-pag-print + 1.    

        run pi-print-editor (imp-valor.descricao, 76).
        find first tt-editor no-error.
        for each tt-editor where
                 tt-editor.linha > 1
            AND LINE-COUNTER >= PAGE-SIZE:
            assign i-pag-print = i-pag-print + 1.    
        end.
    END.
end.

{intprg/ni0302.i7}

/******************/
/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "|_002_-_OUTROS_DêBITOS_(DISCRIMINAR_ABAIXO)" *}
put c-sep at 132 skip
    c-sep at 1
    TRIM(RETURN-VALUE) FORMAT "X(45)" at 4            
    c-sep at 82
    c-sep at 107
    c-sep at 132.

if i-moeda <> 0  and (de-imp-deb + total-1) > 0  then
    put "|" at 4 round((de-imp-deb + total-1) / de-conv,3)
                                format ">>>>,>>>,>>>,>>9.999" to 131.

for each imp-valor fields ( cod-lanc vl-lancamento descricao ) of apur-imposto no-lock:
    if  imp-valor.cod-lanc = 2 then do:
        run pi-acompanhar in h-acomp ( input string(imp-valor.vl-lancamento)).

        if  line-counter >= PAGE-SIZE then do:      
            assign i-num-pag = i-num-pag + 1.
        end.

        put skip c-sep at 1 
            "  | ".
        run pi-print-editor (imp-valor.descricao, 76).
        find first tt-editor no-error.
        IF AVAIL tt-editor THEN DO:
           IF tt-editor.conteudo <> "" THEN
              put tt-editor.conteudo format "x(76)" AT 06.
           for each tt-editor where
                    tt-editor.linha > 1:
               IF tt-editor.conteudo <> "" THEN DO:
                  put c-sep at 82 c-sep at 107 c-sep at 132.
                  put skip c-sep at 1 
                      "  | " tt-editor.conteudo format "x(76)" at 06.
               END.
           end.
        END.
        put c-sep at 82 imp-valor.vl-lancamento  at 89  c-sep at 107 c-sep at 132.
        accumulate imp-valor.vl-lancamento (total).
    end.
end.

if i-moeda <> 0 then 
   put "|" at 4 round((accum total imp-valor.vl-lancamento) / de-conv,3) format ">>,>>>,>>>,>>9.999" to 107.
else
   put c-sep at 1   "|" at 4 c-sep at 82  c-sep at 107
       (accum total imp-valor.vl-lancamento) format ">>>>>,>>>,>>>,>>9.99" at 112 c-sep at 132.

assign total-1 = total-1 + (accum total imp-valor.vl-lancamento).


assign i-pag-print = 7.

for each imp-valor fields ( cod-lanc descricao) of apur-imposto no-lock:
    if  imp-valor.cod-lanc = 3 then DO:
        assign i-pag-print = i-pag-print + 1.    

        run pi-print-editor (imp-valor.descricao, 76).
        find first tt-editor no-error.
        for each tt-editor where
                 tt-editor.linha > 1
            AND LINE-COUNTER >= PAGE-SIZE:
            assign i-pag-print = i-pag-print + 1.    
        end.
    END.
end.

{intprg/ni0302.i7}

/****************************************************************************/

put c-sep at 1 "D|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "ê|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "B|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "I|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "T|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "O|" at 3 c-sep at 82  c-sep at 107 c-sep at 132.

/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "|_003_-_ESTORNO_DE_CRêDITOS_(DISCRIMINAR_ABAIXO)" *}
put c-sep at 1
    "  " + TRIM(RETURN-VALUE) FORMAT "X(54)"
    c-sep at 82
    c-sep at 107
    c-sep at 132 skip.

for each imp-valor fields ( cod-lanc vl-lancamento descricao ) of apur-imposto no-lock:
    if  imp-valor.cod-lanc = 3 then do:
        run pi-acompanhar in h-acomp ( input string(imp-valor.vl-lancamento)).

        if  line-counter >= PAGE-SIZE then do:         
            assign i-num-pag = i-num-pag + 1.
        end.

        put skip c-sep at 1 
            "  | "    .
        run pi-print-editor (imp-valor.descricao, 76).
        find first tt-editor no-error.
        IF AVAIL tt-editor THEN DO:
           IF tt-editor.conteudo <> "" THEN
              put tt-editor.conteudo format "x(76)" AT 06.
           for each tt-editor where
                    tt-editor.linha > 1:
               IF tt-editor.conteudo <> "" THEN DO:
                  put c-sep at 82 c-sep at 107 c-sep at 132.
                  put skip c-sep at 1 
                      "  | " tt-editor.conteudo format "x(76)" at 06.
               END.
           end.
        END.
        put c-sep at 82 imp-valor.vl-lancamento  at 89  c-sep at 107 c-sep at 132.
        accumulate imp-valor.vl-lancamento (total).
    end.
end.

assign total-1 = total-1 + (accum total imp-valor.vl-lancamento).

if i-moeda <> 0 then 
   put "|" at 4 round((accum total imp-valor.vl-lancamento) / de-conv,3) format ">>,>>>,>>>,>>9.999" to 107.
else
   put  c-sep at 1   "|" at 4 c-sep at 82  c-sep at 107
       (accum total imp-valor.vl-lancamento) format ">>>>>,>>>,>>>,>>9.99" at 112  c-sep at 132.

/****************************************************************************/

put c-sep at 1.

/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "|_004_-_SUBTOTAL" *}
put TRIM(RETURN-VALUE) FORMAT "X(18)" at 4.

put c-sep at 82
    c-sep at (if c-moeda <> "" then 87 else 107)  
    de-imp-deb + total-1    format ">>>>>,>>>,>>>,>>9.99" at 112  c-sep at 132.

assign de-vlr-1 = de-imp-deb + total-1. /* para calculo da diferenáa (010 - 004)*/

/*if i-moeda <> 0 then
    put round((de-imp-deb + total-1) / de-conv,3)
                                format ">>>>,>>>,>>>,>>9.999" to 89.*/

/****************************************************************************/
assign i-pag-print = 21.

for each imp-valor fields ( cod-lanc descricao) of apur-imposto no-lock:     
    if  imp-valor.cod-lanc = 6                                               
    or  imp-valor.cod-lanc = 7 then DO:                                         
        assign i-pag-print = i-pag-print + 1.                                
                                                                             
        run pi-print-editor (imp-valor.descricao, 76).                           
        find first tt-editor no-error.                                           
        for each tt-editor where                                                 
                 tt-editor.linha > 1                                             
            AND LINE-COUNTER >= PAGE-SIZE:                                       
            assign i-pag-print = i-pag-print + 1.                                
        end. 
    END.                                                                    
end.                                                                         
                                                                             
{intprg/ni0302.i7}.                                                             

/* Inicio -- Projeto Internacional */
DEFINE VARIABLE c-lbl-liter-credito-do-imposto AS CHARACTER FORMAT "X(20)" NO-UNDO.
{utp/ut-liter.i "CRêDITO_DO_IMPOSTO" *}
ASSIGN c-lbl-liter-credito-do-imposto = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-005-por-entradasaquisicoes AS CHARACTER FORMAT "X(56)" NO-UNDO.
{utp/ut-liter.i "|_005_-_POR_ENTRADAS/AQUISIÄÂES_COM_CRêDITO_DO_IMPOSTO" *}
ASSIGN c-lbl-liter-005-por-entradasaquisicoes = TRIM(RETURN-VALUE).
put c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip                           
    c-sep at 1  
    c-sep at 4
    c-lbl-liter-credito-do-imposto
    c-sep at 82                                       
    c-sep at 107
    c-sep at 132 skip
    c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip                           
    c-sep at 1
    c-lbl-liter-005-por-entradasaquisicoes at 4
    c-sep at 82
    c-sep at (if c-moeda <> "" then 87 else 107)       
    de-imp-cre                 format ">>>>>,>>>,>>>,>>9.99" 
    at (if c-moeda <> "" then 88 else 112) c-sep at 132.
 
if i-moeda <> 0 then
    put "|" at 4 round(de-imp-cre / de-conv,3) format ">>>>,>>>,>>>,>>9.999" to 131.

/****************************************************************************/

/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "|_006_-_OUTROS_CRêDITOS_(DISCRIMINAR_ABAIXO)" *}
put c-sep at 1
    TRIM(RETURN-VALUE) FORMAT "X(46)" at 4               
    c-sep at 82
    c-sep at 107
    c-sep at 132 skip.

for each imp-valor fields ( cod-lanc vl-lancamento descricao ) of apur-imposto no-lock:

    if  imp-valor.cod-lanc = 6 then do:
        run pi-acompanhar in h-acomp ( input string(imp-valor.vl-lancamento)).

        if  line-counter >= PAGE-SIZE then do:      
            assign i-num-pag = i-num-pag + 1.
        end.

        put skip c-sep at 1 
            "  | "    .
        run pi-print-editor (imp-valor.descricao, 76).
        find first tt-editor no-error.
        IF AVAIL tt-editor THEN DO:                        
           IF tt-editor.conteudo <> "" THEN                
              put tt-editor.conteudo format "x(76)" AT 06. 
           for each tt-editor where
                    tt-editor.linha > 1:
               IF tt-editor.conteudo <> "" THEN DO:
                  put c-sep at 82 c-sep at 107 c-sep at 132.
                  put skip c-sep at 1 
                      "  | " tt-editor.conteudo format "x(76)" at 06.
               END.
           end.
        END.
        put c-sep at 82 imp-valor.vl-lancamento  at 89  c-sep at 107 c-sep at 132.
        accumulate imp-valor.vl-lancamento (total).
    end.
end.

assign total-2 = (accum total imp-valor.vl-lancamento). 

if i-moeda <> 0 then 
   put "|" at 4 round((accum total imp-valor.vl-lancamento) / de-conv,3) format ">>,>>>,>>>,>>9.999" to 107.
else
   put  c-sep at 1   "|" at 4 c-sep at 82  c-sep at 107
       (accum total imp-valor.vl-lancamento) format ">>>>>,>>>,>>>,>>9.99" at 112  c-sep at 132.

/****************************************************************************/
assign i-pag-print = 9.

for each imp-valor fields ( cod-lanc vl-lancamento descricao ) of apur-imposto no-lock:
    if  imp-valor.cod-lanc = 7 then do:
        assign i-pag-print = i-pag-print + 1.    

        run pi-print-editor (imp-valor.descricao, 76).
        find first tt-editor no-error.
        for each tt-editor where
                 tt-editor.linha > 1
            AND LINE-COUNTER >= PAGE-SIZE:
            assign i-pag-print = i-pag-print + 1.    
        end.
    END.
end.

{intprg/ni0302.i7}


/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "|_007_-_ESTORNO_DE_DêBITOS_(DISCRIMINAR_ABAIXO)" *}
put c-sep at 1
    "  " + TRIM(RETURN-VALUE) FORMAT "X(53)"
    c-sep at 82
    c-sep at 107
    c-sep at 132 skip.

for each imp-valor fields ( cod-lanc vl-lancamento descricao ) of apur-imposto no-lock:
    if  imp-valor.cod-lanc = 7 then do:
        run pi-acompanhar in h-acomp ( input string(imp-valor.vl-lancamento)).

        if  line-counter >= PAGE-SIZE then do:         
            assign i-num-pag = i-num-pag + 1.
        end.

        put skip c-sep at 1 
            "  | "    .
        run pi-print-editor (imp-valor.descricao, 76).
        find first tt-editor no-error.
        IF AVAIL tt-editor THEN DO:
           IF tt-editor.conteudo <> "" THEN
              put tt-editor.conteudo format "x(76)" AT 06.
           for each tt-editor where
                    tt-editor.linha > 1:
               IF tt-editor.conteudo <> "" THEN DO:
                  put c-sep at 82 c-sep at 107 c-sep at 132.
                  put skip c-sep at 1 
                      "  | " tt-editor.conteudo format "x(76)" at 06.
               END.
           end.
        END.
        put c-sep at 82 imp-valor.vl-lancamento  at 89  c-sep at 107 c-sep at 132.
        accumulate imp-valor.vl-lancamento (total).
    end.
end.

assign total-2 = total-2 + (accum total imp-valor.vl-lancamento).

if  i-moeda <> 0 then 
    put "|" at 4 round((accum total imp-valor.vl-lancamento) / de-conv,3) format ">>,>>>,>>>,>>9.999" to 107.
else
    put  c-sep at 1   "|" at 4 c-sep at 82  c-sep at 107
        (accum total imp-valor.vl-lancamento) format ">>>>>,>>>,>>>,>>9.99" at 112  c-sep at 132.

put c-sep at 1 "C|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "R|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "ê|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "D|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "I|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "T|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "O|" at 3 c-sep at 82  c-sep at 107 c-sep at 132.

/****************************************************************************/

assign i-pag-print = 5.

{intprg/ni0302.i7}

/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "|_008_-_SUBTOTAL" *}
put c-sep at 1
    " " + TRIM(RETURN-VALUE) FORMAT "X(20)" at 3 
    c-sep at 82
    c-sep at (if c-moeda <> "" then 87 else 107)
    de-imp-cre + total-2  format ">>>>>,>>>,>>>,>>9.99" 
    at (if c-moeda <> "" then 88 else 112) c-sep at 132 SKIP.

if  i-moeda <> 0 then
    put "|" at 4 round((de-imp-cre + total-2) / de-conv,3)
                                 format ">>>>,>>>,>>>,>>9.999" to 131 .

/****************************************************************************/
/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "|_009_-_SALDO_CREDOR_DO_PER÷ODO_ANTERIOR" *}
put c-sep at 1
    "|" at 4                                                      
    c-sep at 82
    c-sep at 107
    c-sep at 132
    c-sep at 1  
    TRIM(RETURN-VALUE) FORMAT "X(42)" at 4
    c-sep at 82
    c-sep at (if c-moeda <> "" then 87 else 107) c-sep at 132 SKIP. 

for each imp-valor fields ( cod-lanc vl-lancamento ) of apur-imposto no-lock: 
    if  imp-valor.cod-lanc = 9 then do:
        run pi-acompanhar in h-acomp ( input string(imp-valor.vl-lancamento)).
        accumulate imp-valor.vl-lancamento (total).
    end.
end.

assign total-1 = total-1 + (accum total imp-valor.vl-lancamento).

if  i-moeda <> 0 then 
    put "|" at 4 round((accum total imp-valor.vl-lancamento) / de-conv,3) format ">>,>>>,>>>,>>9.999" to 107.
else
    put  c-sep at 1   "|" at 4 c-sep at 82  c-sep at 107
        (accum total imp-valor.vl-lancamento) format ">>>>>,>>>,>>>,>>9.99" at 112  c-sep at 132.

/****************************************************************************/

assign total-3 = (accum total imp-valor.vl-lancamento).

/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "|_010_-_TOTAL" *}
put c-sep at 1
    TRIM(RETURN-VALUE) FORMAT "X(15)" at 4            
    c-sep at 82
    c-sep at (if c-moeda <> "" then 87 else 107)
    de-imp-cre + total-2 + total-3  format ">>>>>,>>>,>>>,>>9.99" 
    at (if c-moeda <> "" then 88 else 112).

assign de-vlr-2 = de-imp-cre + total-2 + total-3. /* para calculo da diferenáa (010 - 004)*/

if  i-moeda <> 0 then
    put "|" at 4 round((de-imp-cre + total-2 + total-3) / de-conv,3)
                                    format ">>>>,>>>,>>>,>>9.999" to 131.
put c-sep at 132 skip.
  
assign de-debito  = de-vlr-1
       de-credito = de-vlr-2
       credito-1  = de-debito  - de-credito
       debito-1   = de-credito - de-debito.

if  debito-1 < 0 then 
    assign debito-1 = 0.

if  credito-1 < 0 then 
    assign credito-1 = 0.

/**************************************************/
if  de-debito > de-credito then
    assign debito-1  = de-debito - de-credito
           credito-1 = 0.
else
    assign debito-1  = 0.
          
assign i-pag-print = 14. 

for each imp-valor fields ( cod-lanc descricao) of apur-imposto no-lock:
    if  imp-valor.cod-lanc = 12 then
        assign i-pag-print = i-pag-print + 1.

    run pi-print-editor (imp-valor.descricao, 76).
    find first tt-editor no-error.
    for each tt-editor where
             tt-editor.linha > 1
        AND LINE-COUNTER >= PAGE-SIZE:
        assign i-pag-print = i-pag-print + 1.    
    end.
end.

if l-separadores then
   assign i-pag-print = i-pag-print - 1.

{intprg/ni0302.i7}.
                      
/* Inicio -- Projeto Internacional */
DEFINE VARIABLE c-lbl-liter-apuracao-do-saldo AS CHARACTER FORMAT "X(19)" NO-UNDO.
{utp/ut-liter.i "APURAÄ«O_DO_SALDO" *}
ASSIGN c-lbl-liter-apuracao-do-saldo = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-011-saldo-devedordebito-men AS CHARACTER FORMAT "X(45)" NO-UNDO.
{utp/ut-liter.i "|_011_-_SALDO_DEVEDOR(DêBITO_MENOS_CRêDITO)" *}
ASSIGN c-lbl-liter-011-saldo-devedordebito-men = TRIM(RETURN-VALUE).
put c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip  
    c-sep at 1 
    c-sep at 4 
    c-lbl-liter-apuracao-do-saldo
    c-sep at 82                                       
    c-sep at 107
    c-sep at 132 skip
    c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip
    c-sep at 1                           
    c-lbl-liter-011-saldo-devedordebito-men at 4
    c-sep at 82
    c-sep at (if c-moeda <> "" then 87 else 107)
    debito-1                  format ">>>>>,>>>,>>>,>>9.99"
    at (if c-moeda <> "" then 88 else 112) c-sep at 132 skip. 

if  i-moeda <> 0 then
    put "|" at 4 round(debito-1 / de-conv,3)
                              format ">>>>,>>>,>>>,>>9.999" to 131.

/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "|_012_-_DEDUÄÂES_(DISCRIMINAR_ABAIXO)" *}
put c-sep at 1
    "  " + TRIM(RETURN-VALUE) FORMAT "X(43)"                   
    c-sep at 82
    c-sep at 107
    c-sep at 132 SKIP.

for each imp-valor fields ( cod-lanc vl-lancamento descricao ) of apur-imposto no-lock: 
    if  imp-valor.cod-lanc = 12 then do:
        run pi-acompanhar in h-acomp ( input string(imp-valor.vl-lancamento)).

        put c-sep at 1 
            "  | "    .
        run pi-print-editor (imp-valor.descricao, 76).
        find first tt-editor no-error.
        IF AVAIL tt-editor THEN DO:
           IF tt-editor.conteudo <> "" THEN
              put tt-editor.conteudo format "x(76)" AT 06.
           for each tt-editor where
                    tt-editor.linha > 1:
               IF tt-editor.conteudo <> "" THEN DO:
                  put c-sep at 82 c-sep at 107 c-sep at 132.
                  put skip c-sep at 1 
                       "  | " tt-editor.conteudo format "x(76)" at 06.
               END.
           end.
        END.
        put c-sep at 82 imp-valor.vl-lancamento  at 89  c-sep at 107 c-sep at 132.
            de-deducao = de-deducao + imp-valor.vl-lancamento.
        accumulate imp-valor.vl-lancamento (total).
    end.
end.

assign total-1 = total-1 + (accum total imp-valor.vl-lancamento).

if  i-moeda <> 0 then 
    put "|" at 4 round((accum total imp-valor.vl-lancamento) / de-conv,3) format ">>,>>>,>>>,>>9.999" to 107.
else
    put  c-sep at 1   "|" at 4 c-sep at 82  c-sep at 107
        de-deducao format ">>>>>,>>>,>>>,>>9.99" at 112  c-sep at 132.

/****************************************************************************/
put c-sep at 1 "S|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "A|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "L|" at 3 c-sep at 82  c-sep at 107 c-sep at 132
    c-sep at 1 "D|" at 3 c-sep at 82  c-sep at 107 c-sep at 132.

if  de-debito > de-credito then
    assign de-imposto = debito-1 - de-deducao.

if de-imposto < 0 then
   assign credito-1  = 0 - de-imposto
          de-imposto = 0.
          
/* INICIO Chamada UPC */

&if '{&bf_dis_versao_ems}' >= '2.062' &then
   create tt-epc.
   assign tt-epc.cod-event     = "Value_of_de-imposto"
          tt-epc.cod-parameter = "cod-estabel"
          tt-epc.val-parameter = apur-imposto.cod-estabel.
   create tt-epc.
   assign tt-epc.cod-event     = "Value_of_de-imposto"
          tt-epc.cod-parameter = "dt-apur-ini"
          tt-epc.val-parameter = string(apur-imposto.dt-apur-ini,"99/99/9999").
   create tt-epc.
   assign tt-epc.cod-event     = "Value_of_de-imposto"
          tt-epc.cod-parameter = "dt-apur-fim"
          tt-epc.val-parameter = string(apur-imposto.dt-apur-fim,"99/99/9999").
   create tt-epc.
   assign tt-epc.cod-event     = "Value_of_de-imposto"
          tt-epc.cod-parameter = "tp-imposto"
          tt-epc.val-parameter = string(apur-imposto.tp-imposto).
   create tt-epc.
   assign tt-epc.cod-event     = "Value_of_de-imposto"
          tt-epc.cod-parameter = "de-imposto"
          tt-epc.val-parameter = string(de-imposto).

   {include/i-epc201.i "Value_of_de-imposto"}

   find first tt-epc 
        where tt-epc.cod-event     = "Value_of_de-imposto"
        and   tt-epc.cod-parameter = "de-imposto" no-error.

   if  avail tt-epc then
       assign de-imposto = decimal(tt-epc.val-parameter).

   for each tt-epc:
       delete tt-epc.
   end.
&endif

/* FIM Chamada UPC */
/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "O|_013_-_IMPOSTO_A_RECOLHER" *}
put c-sep at 1
    " " + TRIM(RETURN-VALUE) FORMAT "X(31)"
    c-sep at 82
    c-sep at (if c-moeda <> "" then 87 else 107)
    de-imposto                format ">>>>>,>>>,>>>,>>9.99" 
    at (if c-moeda <> "" then 88 else 112) c-sep at 132 SKIP.

/****************************************************************************/

if i-moeda <> 0 then
    put "|" at 4 round(credito-1 / de-conv,3)
                                  format ">>>>,>>>,>>>,>>9.999" to 131.

if  de-debito < de-credito then
    assign credito-1  = (de-credito - de-debito) + de-deducao.

/* INICIO Chamada UPC */

&if '{&bf_dis_versao_ems}' >= '2.062' &then
   create tt-epc.
   assign tt-epc.cod-event     = "Value_of_credito-1"
          tt-epc.cod-parameter = "cod-estabel"
          tt-epc.val-parameter = apur-imposto.cod-estabel.
   create tt-epc.
   assign tt-epc.cod-event     = "Value_of_credito-1"
          tt-epc.cod-parameter = "dt-apur-ini"
          tt-epc.val-parameter = string(apur-imposto.dt-apur-ini).
   create tt-epc.
   assign tt-epc.cod-event     = "Value_of_credito-1"
          tt-epc.cod-parameter = "dt-apur-fim"
          tt-epc.val-parameter = string(apur-imposto.dt-apur-fim).
   create tt-epc.
   assign tt-epc.cod-event     = "Value_of_credito-1"
          tt-epc.cod-parameter = "tp-imposto"
          tt-epc.val-parameter = string(apur-imposto.tp-imposto).
   create tt-epc.
   assign tt-epc.cod-event     = "Value_of_credito-1"
          tt-epc.cod-parameter = "credito-1"
          tt-epc.val-parameter = string(credito-1).

   {include/i-epc201.i "Value_of_credito-1"}

   find first tt-epc 
        where tt-epc.cod-event     = "Value_of_credito-1"
        and   tt-epc.cod-parameter = "credito-1" no-error.

   if  avail tt-epc then
       assign credito-1 = decimal(tt-epc.val-parameter).

   for each tt-epc:
       delete tt-epc.
   end.
&endif

/* FIM Chamada UPC */
/* Inicio -- Projeto Internacional */
DEFINE VARIABLE c-lbl-liter-014-saldo-credorcredito-men AS CHARACTER FORMAT "X(44)" NO-UNDO.
{utp/ut-liter.i "|_014_-_SALDO_CREDOR(CRêDITO_MENOS_DêBITO)" *}
ASSIGN c-lbl-liter-014-saldo-credorcredito-men = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-a-transportar-para-o-periodo AS CHARACTER FORMAT "X(47)" NO-UNDO.
{utp/ut-liter.i "|_______A_TRANSPORTAR_PARA_O_PER÷ODO_SEGUINTE" *}
ASSIGN c-lbl-liter-a-transportar-para-o-periodo = TRIM(RETURN-VALUE).
put c-sep at 1
    c-lbl-liter-014-saldo-credorcredito-men  at 4
    c-sep at 82            
    c-sep at 107
    c-sep at 132
    c-sep at 1
    c-lbl-liter-a-transportar-para-o-periodo at 4
    c-sep at 82
    c-sep at (if c-moeda <> "" then 87 else 107)
    credito-1                 format ">>>>>,>>>,>>>,>>9.99"
    at (if c-moeda <> "" then 88 else 112) c-sep at 132.  

/***************************/

assign i-pag-print = 11.

for each imposto-guia fields() of apur-imposto no-lock:
    assign i-pag-print = i-pag-print + 1.
end.

for each tt-editor where tt-editor.linha > 1
    AND LINE-COUNTER >= PAGE-SIZE:
    assign i-pag-print = i-pag-print + 1.
end.

{intprg/ni0302.i7}.

/* Inicio -- Projeto Internacional */
DEFINE VARIABLE c-lbl-liter-informacoes-complementares AS CHARACTER FORMAT "X(28)" NO-UNDO.
{utp/ut-liter.i "INFORMAÄÂES_COMPLEMENTARES" *}
ASSIGN c-lbl-liter-informacoes-complementares = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-guias-de-recolhimento AS CHARACTER FORMAT "X(23)" NO-UNDO.
{utp/ut-liter.i "GUIAS_DE_RECOLHIMENTO" *}
ASSIGN c-lbl-liter-guias-de-recolhimento = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-guia-de-informacao AS CHARACTER FORMAT "X(20)" NO-UNDO.
{utp/ut-liter.i "GUIA_DE_INFORMAÄ«O" *}
ASSIGN c-lbl-liter-guia-de-informacao = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-numero-data-valor-orgao-arreca AS CHARACTER FORMAT "X(126)" NO-UNDO.
{utp/ut-liter.i "NÈMERO__DATA_____________________VALOR___ORG«O_ARRECADADOR________________DATA_DA_ENTREGA____LOCAL_DA_ENTREGA" *}
ASSIGN c-lbl-liter-numero-data-valor-orgao-arreca = TRIM(RETURN-VALUE).
DEFINE VARIABLE c-lbl-liter-bancoreparticao AS CHARACTER FORMAT "X(119)" NO-UNDO.
{utp/ut-liter.i "BANCO/REPARTIÄ«O" *}
ASSIGN c-lbl-liter-bancoreparticao = TRIM(RETURN-VALUE).
put c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip                           
    c-sep at 1  
    c-lbl-liter-informacoes-complementares                            at 30 
    c-sep at 132 skip
    c-sepa at 1 fill("-",130) format "x(130)" c-sepa skip                           
    c-sep at 1 c-lbl-liter-guias-de-recolhimento                                 at 30 
    c-lbl-liter-guia-de-informacao at 90  
    c-sep at 132
    c-sep at 1
    c-sep at 132 
    c-sep at 1
    "               " + c-lbl-liter-numero-data-valor-orgao-arreca             
    c-sep at 132
    c-sep at 1
    "                                                                                                   (" + c-lbl-liter-bancoreparticao + ")"
    c-sep at 132 
    c-sep at 1
    c-sep at 132. 

assign l-primeiro = yes.

for each imposto-guia fields ( nr-guia dt-guia vl-guia org-arrecad )
         of apur-imposto no-lock:

    run pi-acompanhar in h-acomp ( input string(imposto-guia.nr-guia)).

    put c-sep at 1
        imposto-guia.nr-guia     at 3   format ">>>>>>>>>>>>>>>>>>>9"
        imposto-guia.dt-guia     at 25  format "99/99/9999" 
        imposto-guia.vl-guia     at 37  format ">>>,>>>,>>>,>>9.99"   
        imposto-guia.org-arrecad at 58  format "x(20)".
             
    if  l-primeiro then do:
        put apur-imposto.dt-entrega  at  83 format "99/99/9999"
            apur-imposto.loc-entrega at 102 format "x(30)" c-sep at 132.
        assign l-primeiro = no.
    end.
    
end.

run pi-print-editor (apur-imposto.observacao,80).

/* Inicio -- Projeto Internacional */
{utp/ut-liter.i "OBSERVAÄÂES" *}
put c-sep at 1
    c-sep at 132 skip
    c-sep at 1 TRIM(RETURN-VALUE) + ": " FORMAT "X(17)".

find first tt-editor no-error.

if avail tt-editor then 
   put tt-editor.conteudo at 15 c-sep at 132 skip.

for each tt-editor where tt-editor.linha > 1:
    run pi-imprime-termo ( line-counter, 1).
    if  l-separadores then view frame f-diag.
    else view frame f-cabec.
    put c-sep at 1 tt-editor.conteudo at 15 c-sep at 132 skip.
end.

if  l-separadores then
    assign c-linha-branco = c-sep + fill(" ",22) +
           c-sep + fill(" ",20) + c-sep + fill(" ",21) + c-sep + fill(" ",21) +
           c-sep + fill(" ",21) + c-sep + fill(" ",20) + c-sep
           c-sepa = if c-sep <> "" then c-sep else "-".
else
    assign c-linha-branco = " ".
 
assign l-impr-sep = yes. 

do  while l-impr-sep:
    
    put c-sep at 1.       
    
    if  l-separadores then 
        put c-sep at 132.
    else
        put c-sep at 132 .
    
    if  line-counter >= page-size then
        assign l-impr-sep = no.     
end.  

run pi-imprime-termo ( line-counter, 1 ).
{include/pi-edit.i}
{intprg/ni0302.i8}

          
/*  ni0302c.p  */                                          
