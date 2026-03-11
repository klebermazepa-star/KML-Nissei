/* include de controle de versao */
{include/i-prgvrs.i INT705RP.P 1.00.00.001KML}



.MESSAGE "v1"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

DEFINE VARIABLE valor_credito_faturamento AS DECIMAL     NO-UNDO.
DEFINE VARIABLE valor_debito_faturamento AS DECIMAL     NO-UNDO.
DEFINE VARIABLE valor_debito_recebi AS DECIMAL     NO-UNDO.
DEFINE VARIABLE valor_credito_recebi AS DECIMAL     NO-UNDO.

    
define temp-table tt-param no-undo
    field destino                AS INTEGER
    field execucao               as INTEGER
    field arquivo                as char format "x(35)"
    field usuario                as char format "x(12)"
    field data-exec              as date
    field hora-exec              as integer
    field classifica             as integer
    field desc-classifica        as char format "x(40)"
    field modelo                 AS char format "x(35)"
    field l-habilitaRtf          as log
    field DtEmissaoIni              AS CHAR 
    field DtEmissaoFinal            as CHAR 
    field EstabelecOrigInicial      as char
    field EstabelecOrigFinal        as char 
    //field EstabelecDestinoInicial   as char 
    //field EstabelecDestinoFinal     as CHAR
    FIELD EspecieInicial            as char 
    field EspecieFinal              as char 
    field DtTransacaoIni            as char
    field DtTransacaoFinal          as char 
    FIELD rs-tipo                   as INT                                    
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
assign c-programa 	  = 'INT705RP.P'
       c-versao	      = '1.00'
       c-revisao      = '.00.001KML'
       c-sistema      = 'Relat¢rio'
       c-titulo-relat = 'Relat¢rio Contabil'. 

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

DEFINE TEMP-TABLE tt-nota 
    FIELD chave-nota                 LIKE nota-fiscal.cod-chave-aces-nf-eletro
    FIELD dt-emis-nota               LIKE nota-fiscal.dt-emis-nota
    FIELD dt-transicao               LIKE nota-fiscal.dt-atualiza
    FIELD situacao                   LIKE nota-fiscal.idi-sit-nf-eletro
    FIELD cod-estabel                LIKE nota-fiscal.cod-estabel
    FIELD nome-abrev                 LIKE nota-fiscal.nome-ab-cli
    FIELD nr-nota-fis                LIKE nota-fiscal.nr-nota-fis
    FIELD serie                      LIKE nota-fiscal.serie
    FIELD vl-total                   LIKE nota-fiscal.vl-tot-nota
    FIELD vl-credito-saida           LIKE movto-estoq.valor-nota      
    FIELD vl-debito-saida            LIKE movto-estoq.valor-nota
    FIELD cod-centro-saida           LIKE movto-estoq.ct-codigo
    FIELD vl-credito-entrada         LIKE movto-estoq.valor-nota      
    FIELD vl-debito-entrada          LIKE movto-estoq.valor-nota
    FIELD cod-centro-entrada         LIKE movto-estoq.ct-codigo
    FIELD cod-especie                LIKE docum-est.esp-docto
    FIELD cod-ct-saldo-entrada       LIKE movto-estoq.ct-saldo
    FIELD cod-ct-saldo-saida         LIKE movto-estoq.ct-saldo
    . 
    



IF tt-param.rs-tipo = 1 THEN
DO:

    FOR EACH nota-fiscal NO-LOCK
        WHERE nota-fiscal.dt-emis-nota >= DATE(tt-param.DtEmissaoIni)
          AND nota-fiscal.dt-emis-nota <= DATE(tt-param.DtEmissaoFinal)
          AND nota-fiscal.cod-estabel >=  tt-param.EstabelecOrigInicial
          AND nota-fiscal.cod-estabel <=  tt-param.EstabelecOrigFinal
          AND nota-fiscal.esp-docto   >=  int(tt-param.EspecieInicial)
          AND nota-fiscal.esp-docto   <=  int(tt-param.EspecieFinal)
          AND nota-fiscal.dt-atualiza >=  DATE(tt-param.DtTransacaoIni)
          AND nota-fiscal.dt-atualiza <=  DATE(tt-param.DtTransacaoFinal)
          :
  
        run pi-acompanhar IN h-acomp ( "Nota:" + string(nota-fiscal.nr-nota-fis)) .
      
        FOR EACH sumar-ft NO-LOCK
            WHERE   sumar-ft.nr-nota-fis =  nota-fiscal.nr-nota-fis
            AND     sumar-ft.serie       =  nota-fiscal.serie      
            AND     sumar-ft.cod-estabel =  nota-fiscal.cod-estabel
            :

            CREATE tt-nota.
            ASSIGN tt-nota.chave-nota     = nota-fiscal.cod-chave-aces-nf-eletro
                    tt-nota.dt-emis-nota  = nota-fiscal.dt-emis-nota
                    tt-nota.situacao      = nota-fiscal.idi-sit-nf-eletro
                    tt-nota.cod-estabel   = nota-fiscal.cod-estabel
                    tt-nota.nr-nota-fis   = nota-fiscal.nr-nota-fis
                    tt-nota.serie         = nota-fiscal.serie 
                    tt-nota.vl-total      = nota-fiscal.vl-tot-nota
                    tt-nota.dt-transicao  = nota-fiscal.dt-atualiza.
                
            ASSIGN tt-nota.cod-centro-saida =  sumar-ft.ct-conta .
                        
               
              
            IF sumar-ft.vl-contab   <= 0 THEN
            DO:

                ASSIGN tt-nota.vl-debito-saida = sumar-ft.vl-contab * (-1).

            END.
            ELSE DO:

                 ASSIGN tt-nota.vl-credito-saida = sumar-ft.vl-contab.

            END.

        END.
        
        FOR EACH movto-estoq NO-LOCK
            WHERE movto-estoq.cod-estabel = nota-fiscal.cod-estabel
            AND movto-estoq.nro-docto = nota-fiscal.nr-nota-fis
            AND movto-estoq.serie-docto = nota-fiscal.serie
            AND movto-estoq.dt-trans    =  nota-fiscal.dt-atualiza
            BREAK BY  movto-estoq.ct-saldo BY movto-estoq.ct-codigo
            :
            
            ASSIGN valor_credito_faturamento = movto-estoq.valor-mat-m[1] + valor_credito_faturamento.
      
            ASSIGN valor_debito_faturamento = movto-estoq.valor-mat-m[1] + valor_debito_faturamento.
            
            IF movto-estoq.ct-codigo <> " " THEN
            DO:
            
                IF LAST-OF (movto-estoq.ct-codigo) THEN
                DO:
                
                    CREATE tt-nota.
                    ASSIGN tt-nota.chave-nota     = nota-fiscal.cod-chave-aces-nf-eletro
                            tt-nota.dt-emis-nota  = nota-fiscal.dt-emis-nota
                            tt-nota.situacao      = nota-fiscal.idi-sit-nf-eletro
                            tt-nota.cod-estabel   = nota-fiscal.cod-estabel
                            tt-nota.nr-nota-fis   = nota-fiscal.nr-nota-fis
                            tt-nota.serie         = nota-fiscal.serie 
                            tt-nota.vl-total      = nota-fiscal.vl-tot-nota
                            tt-nota.dt-transicao  = nota-fiscal.dt-atualiza
                            tt-nota.nome-abrev    = STRING(nota-fiscal.cod-emitente)                       
                             .
                    
                    ASSIGN   
                            tt-nota.cod-centro-saida     = movto-estoq.ct-codigo
                            tt-nota.cod-ct-saldo-saida   = movto-estoq.ct-saldo
                            tt-nota.vl-debito-saida = valor_debito_faturamento.
                            
                    ASSIGN valor_debito_faturamento = 0. 
                    
                    
                END.       
                       
                IF LAST-OF (movto-estoq.ct-saldo) THEN
                DO:
                    CREATE tt-nota.
                    ASSIGN tt-nota.chave-nota     = nota-fiscal.cod-chave-aces-nf-eletro
                            tt-nota.dt-emis-nota  = nota-fiscal.dt-emis-nota
                            tt-nota.situacao      = nota-fiscal.idi-sit-nf-eletro
                            tt-nota.cod-estabel   = nota-fiscal.cod-estabel
                            tt-nota.nr-nota-fis   = nota-fiscal.nr-nota-fis
                            tt-nota.serie         = nota-fiscal.serie 
                            tt-nota.vl-total      = nota-fiscal.vl-tot-nota
                            tt-nota.dt-transicao  = nota-fiscal.dt-atualiza
                            tt-nota.nome-abrev    = STRING(nota-fiscal.cod-emitente)                       
                             .
                    
                    
                    ASSIGN  tt-nota.cod-centro-saida     = movto-estoq.ct-codigo
                            tt-nota.cod-ct-saldo-saida  = movto-estoq.ct-saldo
                            tt-nota.vl-credito-saida = valor_credito_faturamento.
                            
                    ASSIGN valor_credito_faturamento = 0.
                    
                    
                END.
                
            END.
            
            
        END. 
        
        //ASSIGN valor_credito_recebi = 0.
        //ASSIGN valor_debito_recebi = 0.

        FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cod-estabel =   nota-fiscal.cod-estabel NO-ERROR.

        FOR EACH docum-est NO-LOCK
        WHERE docum-est.cod-emitente     =   estabelec.cod-emitente
        AND   docum-est.nro-docto        =  nota-fiscal.nr-nota-fis
        AND   docum-est.serie-docto      =   nota-fiscal.serie:
        
        FOR EACH movto-estoq NO-LOCK
            WHERE movto-estoq.cod-estabel = docum-est.cod-estabel
            AND movto-estoq.nro-docto = docum-est.nro-docto
            AND movto-estoq.serie-docto = docum-est.serie-docto
            AND movto-estoq.dt-trans    =   docum-est.dt-trans
            BREAK BY  movto-estoq.ct-saldo BY movto-estoq.ct-codigo
            :
            
           /* CREATE tt-nota.
            ASSIGN tt-nota.chave-nota    = nota-fiscal.cod-chave-aces-nf-eletro
                    tt-nota.dt-emis-nota  = nota-fiscal.dt-emis-nota
                    tt-nota.situacao      = nota-fiscal.idi-sit-nf-eletro
                    tt-nota.cod-estabel   = nota-fiscal.cod-estabel
                    tt-nota.nr-nota-fis   = nota-fiscal.nr-nota-fis
                    tt-nota.serie         = nota-fiscal.serie
                    tt-nota.vl-total      = nota-fiscal.vl-tot-nota
                    tt-nota.dt-transicao  = nota-fiscal.dt-atualiza.  */

            ASSIGN valor_credito_recebi =  movto-estoq.valor-mat-m[1] + valor_credito_recebi.
            
            ASSIGN valor_debito_recebi  =  movto-estoq.valor-mat-m[1] + valor_debito_recebi.
            
            
            
            
            IF LAST-OF (movto-estoq.ct-saldo) THEN
            DO:
                CREATE tt-nota.
                ASSIGN tt-nota.chave-nota    = nota-fiscal.cod-chave-aces-nf-eletro
                        tt-nota.dt-emis-nota  = nota-fiscal.dt-emis-nota
                        tt-nota.situacao      = nota-fiscal.idi-sit-nf-eletro
                        tt-nota.cod-estabel   = nota-fiscal.cod-estabel
                        tt-nota.nr-nota-fis   = nota-fiscal.nr-nota-fis
                        tt-nota.serie         = nota-fiscal.serie
                        tt-nota.vl-total      = nota-fiscal.vl-tot-nota
                        tt-nota.dt-transicao  = nota-fiscal.dt-atualiza.
                
                
                IF movto-estoq.ct-saldo = "11204005" THEN
                DO:
                
                     ASSIGN tt-nota.vl-debito-entrada = valor_debito_recebi
                            tt-nota.vl-credito-entrada = valor_debito_recebi.
                
                    
                END.  
                
                ASSIGN tt-nota.cod-centro-entrada    = movto-estoq.ct-codigo
                 tt-nota.cod-ct-saldo-entrada  = movto-estoq.ct-saldo.
                 
                ASSIGN tt-nota.vl-credito-entrada =   valor_credito_recebi.

                ASSIGN valor_credito_recebi = 0.


            END.
            
            
            IF LAST-OF (movto-estoq.ct-codigo) THEN
            DO:
                
                
                CREATE tt-nota.
                ASSIGN tt-nota.chave-nota    = nota-fiscal.cod-chave-aces-nf-eletro
                        tt-nota.dt-emis-nota  = nota-fiscal.dt-emis-nota
                        tt-nota.situacao      = nota-fiscal.idi-sit-nf-eletro
                        tt-nota.cod-estabel   = nota-fiscal.cod-estabel
                        tt-nota.nr-nota-fis   = nota-fiscal.nr-nota-fis
                        tt-nota.serie         = nota-fiscal.serie
                        tt-nota.vl-total      = nota-fiscal.vl-tot-nota
                        tt-nota.dt-transicao  = nota-fiscal.dt-atualiza.

                
                ASSIGN tt-nota.vl-debito-entrada = valor_debito_recebi.
                                    

                ASSIGN tt-nota.cod-centro-entrada    = movto-estoq.ct-codigo
                 tt-nota.cod-ct-saldo-entrada  = movto-estoq.ct-saldo.
                
                ASSIGN valor_debito_recebi = 0.


            END.

            
            
                            
            ASSIGN tt-nota.nome-abrev    = STRING(nota-fiscal.cod-emitente)
                 tt-nota.cod-centro-entrada    = movto-estoq.ct-codigo
                 tt-nota.cod-ct-saldo-entrada  = movto-estoq.ct-saldo.


            END.
        END.
    END.
END.
ELSE DO:

    FOR EACH nota-fiscal NO-LOCK
        WHERE nota-fiscal.dt-emis-nota >= DATE(tt-param.DtEmissaoIni)
          AND nota-fiscal.dt-emis-nota <= DATE(tt-param.DtEmissaoFinal)
          AND nota-fiscal.cod-estabel >=  "973"
          AND nota-fiscal.esp-docto   >=  int(tt-param.EspecieInicial)
          AND nota-fiscal.esp-docto   <=  int(tt-param.EspecieFinal)
          AND nota-fiscal.dt-atualiza >=  DATE(tt-param.DtTransacaoIni)
          AND nota-fiscal.dt-atualiza <=  DATE(tt-param.DtTransacaoFinal)
          :
           
          run pi-acompanhar IN h-acomp ( "Nota:" + string(nota-fiscal.nr-nota-fis)) .
      
        FOR EACH sumar-ft NO-LOCK
            WHERE   sumar-ft.nr-nota-fis =  nota-fiscal.nr-nota-fis
            AND     sumar-ft.serie       =  nota-fiscal.serie      
            AND     sumar-ft.cod-estabel =  nota-fiscal.cod-estabel
            :

               CREATE tt-nota.
            ASSIGN tt-nota.chave-nota    = nota-fiscal.cod-chave-aces-nf-eletro
                    tt-nota.dt-emis-nota  = nota-fiscal.dt-emis-nota
                    tt-nota.situacao      = nota-fiscal.idi-sit-nf-eletro
                    tt-nota.cod-estabel   = nota-fiscal.cod-estabel
                    tt-nota.nr-nota-fis   = nota-fiscal.nr-nota-fis
                    tt-nota.serie         = nota-fiscal.serie 
                    tt-nota.vl-total      = nota-fiscal.vl-tot-nota
                    tt-nota.dt-transicao  = nota-fiscal.dt-atualiza.
                
            ASSIGN tt-nota.cod-centro-saida =  sumar-ft.ct-conta .
                        
               
              
                IF sumar-ft.vl-contab   <= 0 THEN
                DO:

                    ASSIGN tt-nota.vl-debito-saida = sumar-ft.vl-contab * (-1).

                END.
                ELSE DO:

                     ASSIGN tt-nota.vl-credito-saida = sumar-ft.vl-contab.

                END.

                
                
                . 
                

        END.
/*         FOR EACH movto-estoq NO-LOCK                                            */
/*             WHERE movto-estoq.cod-estabel = nota-fiscal.cod-estabel             */
/*               AND movto-estoq.nro-docto = nota-fiscal.nr-nota-fis               */
/*               AND movto-estoq.serie-docto = nota-fiscal.serie :                 */
/*                                                                                 */
/*             CREATE tt-nota.                                                     */
/*             ASSIGN tt-nota.chave-nota    = nota-fiscal.cod-chave-aces-nf-eletro */
/*                     tt-nota.dt-emis-nota  = nota-fiscal.dt-emis-nota            */
/*                     tt-nota.situacao      = nota-fiscal.idi-sit-nf-eletro       */
/*                     tt-nota.cod-estabel   = nota-fiscal.cod-estabel             */
/*                     tt-nota.nr-nota-fis   = nota-fiscal.nr-nota-fis             */
/*                     tt-nota.serie         = nota-fiscal.serie                   */
/*                     tt-nota.vl-total      = nota-fiscal.vl-tot-nota             */
/*                     tt-nota.dt-transicao  = nota-fiscal.dt-atualiza.            */
/*                                                                                 */
/*             ASSIGN tt-nota.cod-centro-saida =  sumar-ft.ct-conta                */
/*                tt-nota.nome-abrev    = STRING(nota-fiscal.cod-emitente).        */
/*                                                                                 */
/*            ASSIGN  tt-nota.vl-credito-saida    = movto-estoq.valor-mat-m[1]     */
/*                     tt-nota.vl-debito-saida     = movto-estoq.valor-mat-m[1]    */
/*                     tt-nota.cod-centro-saida    = movto-estoq.ct-codigo         */
/*                     tt-nota.cod-ct-saldo-saida  = movto-estoq.ct-saldo.         */
/*                                                                                 */
/*         END.                                                                    */
        
        FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cod-estabel =   nota-fiscal.cod-estabel NO-ERROR.

        FOR EACH docum-est NO-LOCK
            WHERE docum-est.cod-emitente     =   estabelec.cod-emitente
            AND   docum-est.nro-docto        =  nota-fiscal.nr-nota-fis
            AND   docum-est.serie-docto      =   nota-fiscal.serie:

            FOR EACH movto-estoq NO-LOCK
                WHERE movto-estoq.cod-estabel = docum-est.cod-estabel
                  AND movto-estoq.nro-docto = docum-est.nro-docto
                  AND movto-estoq.serie-docto = docum-est.serie-docto
                  :
                  CREATE tt-nota.
                    ASSIGN tt-nota.chave-nota    = nota-fiscal.cod-chave-aces-nf-eletro
                            tt-nota.dt-emis-nota  = nota-fiscal.dt-emis-nota
                            tt-nota.situacao      = nota-fiscal.idi-sit-nf-eletro
                            tt-nota.cod-estabel   = nota-fiscal.cod-estabel
                            tt-nota.nr-nota-fis   = nota-fiscal.nr-nota-fis
                            tt-nota.serie         = nota-fiscal.serie 
                            tt-nota.vl-total      = nota-fiscal.vl-tot-nota
                            tt-nota.dt-transicao  = nota-fiscal.dt-atualiza.
                  
                  
                  ASSIGN  tt-nota.vl-credito-saida    = movto-estoq.valor-mat-m[1]
                    tt-nota.vl-debito-saida     = movto-estoq.valor-mat-m[1]
                    tt-nota.cod-centro-saida    = movto-estoq.ct-codigo
                    tt-nota.cod-ct-saldo-saida  = movto-estoq.ct-saldo.
                  
                  
                  ASSIGN tt-nota.nome-abrev            = STRING(nota-fiscal.cod-emitente)
                         tt-nota.vl-credito-entrada    = movto-estoq.valor-mat-m[1]
                         tt-nota.vl-debito-entrada     = movto-estoq.valor-mat-m[1]
                         tt-nota.cod-centro-entrada    = movto-estoq.ct-codigo
                         tt-nota.cod-ct-saldo-entrada  = movto-estoq.ct-saldo.


            END.
        END.
    END.
END.

if tt-param.execucao <> 2 then do:

    output to value ("U:\int705.csv").
	
END.	
ELSE DO:

	output to value ("/mnt/shares/rpw/prod/rpw-fila2/int705.csv").
	
end.


PUT UNFORMATTED 
    "Chave Acesso;" 
    "Data Emissao Nota;"
    "Data de Trasicao;"
    "Situacao NF;" 
    "Filial Origem;"
    "Filial Destino;"
    "Especie;"
    "NR Nota fiscal;" 
    "Serie;" 
    "Valor Total NF;" 
    "Valor Contabil Credito (NF SAIDA);" 
    "Valor Contabil Debito (NF SAIDA);" 
    "Conta contabil (NF SAIDA);"
    "Conta Saldo (NF SAIDA);"
    "Valor Contabil Credito (NF Entrada);" 
    "Valor Contabil Debito (NF Entrada);" 
    "Conta contabil (NF Entrada);"
    "Conta Saldo (NF Entrada)"SKIP.
    

       
FOR EACH tt-nota:

        .MESSAGE  tt-nota.nr-nota-fis
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

           
            
        PUT UNFORMATTED
        tt-nota.chave-nota          + ";" +
        STRING(tt-nota.dt-emis-nota, "99/99/9999") + ";" +
        STRING(tt-nota.dt-transicao, "99/99/9999") + ";" +
        STRING(tt-nota.situacao)    + ";" +
        STRING(tt-nota.cod-estabel) + ";" +
        tt-nota.nome-abrev          + ";" +
        string(tt-nota.cod-especie)         + ";" +
        STRING(tt-nota.nr-nota-fis) + ";" +
        tt-nota.serie               + ";" +
        STRING(tt-nota.vl-total)    + ";" +
        STRING(tt-nota.vl-credito-saida) + ";" +
        STRING(tt-nota.vl-debito-saida)  + ";" +
        tt-nota.cod-centro-saida    + ";" +
        tt-nota.cod-ct-saldo-saida  + ";" +
        STRING(tt-nota.vl-credito-entrada) + ";" +
        STRING(tt-nota.vl-debito-entrada)  + ";" +
        tt-nota.cod-centro-entrada + ";" +
        tt-nota.cod-ct-saldo-entrada SKIP.
           

        run pi-acompanhar IN h-acomp ( "Nota:" + string(tt-nota.nr-nota-fis)) .


END.

if tt-param.execucao <> 2 then do:

	OS-COMMAND NO-WAIT VALUE("U:\int705.csv").

end.


/* fechamento do output do relatorio */
{include/i-rpclo.i}
run pi-finalizar in h-acomp.
 
return "OK":U.

