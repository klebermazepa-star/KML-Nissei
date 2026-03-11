/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i CDAPI1001 2.00.00.011 } /*** 010011 ***/
/*******************************************************************************
** Copyright TOTVS S.A. (2010)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i cdapi1001 MCD}
&ENDIF

{include/i_dbvers.i}
{cdp/cdcfgmat.i}
{cdp/cdcfgfin.i}
{cdp/cdcfgdis.i}
{include/verifica_program_name.i}
{utp/ut-glob.i}
/* {include/i-rpvar.i} */
{include/i-freeac.i}
{include/tt-edit.i}
{cdp/cdapi1001.i}

DEFINE VARIABLE rw-sit-relacto-icms AS ROWID NO-UNDO.
DEFINE VARIABLE c-lista-tributos    AS CHAR  NO-UNDO.
DEFINE VARIABLE l-estab             AS LOGICAL  NO-UNDO EXTENT 2.
DEFINE VARIABLE l-nat-operacao      AS LOGICAL  NO-UNDO EXTENT 2.
DEFINE VARIABLE l-ncm               AS LOGICAL  NO-UNDO EXTENT 2.
DEFINE VARIABLE l-it-codigo         AS LOGICAL  NO-UNDO EXTENT 2.
DEFINE VARIABLE l-cod-gr-cli        AS LOGICAL  NO-UNDO EXTENT 2.
DEFINE VARIABLE l-cod-emitente      AS LOGICAL  NO-UNDO EXTENT 2.

ASSIGN l-estab[2]           = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cod-estab = "*")           /* l-estab */
       l-nat-operacao[2]    = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cod-natur-operac = "*")    /* l-nat-operacao */
       l-ncm[2]             = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cod-ncm = "*")             /* l-ncm */
       l-it-codigo[2]       = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cod-item = "*")            /* l-it-codigo */
       l-cod-gr-cli[2]      = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cdn-grp-emit = 0)          /* l-cod-gr-cli */
       l-cod-emitente[2]    = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cdn-emitente = 0).         /* l-cod-emitente */

/********************* In¡cio Defini‡Æo Tabelas Tempor rias ********************/

DEF TEMP-TABLE tt-combinacao NO-UNDO
         FIELD seq          AS INT        
         FIELD cod-estabel  AS CHAR
         FIELD nat-operacao AS CHAR
         FIELD cod-item     AS CHAR
         FIELD cdn-grp-emit AS int
         FIELD cdn-emitente AS int
         FIELD cod-ncm      AS CHAR.

/********************* Fim Defini‡Æo Tabelas Tempor rias ***********************/

PROCEDURE pi-gera-tt-combinacao:

    def input  param p-cod-estabel  as CHAR FORMAT 'X(3)'        no-undo.  
    def input  param p-nat-oper     AS CHAR FORMAT 'X(6)'        no-undo.
    def input  param p-ncm          AS CHAR FORMAT "999.99.99"   no-undo.
    def input  param p-it-codigo    AS CHAR FORMAT 'X(16)'       no-undo.
    def input  param p-cod-gr-cli   AS INT  FORMAT ">9"          no-undo.
    def input  param p-cod-emitente AS INT  FORMAT ">>>>>>>>9"   no-undo.

    /*** Objetivo: gerar uma tabela de combinações possíveis para a busca do código
    de situação tributária (CST) na tabela sit-tribut-relacto a partir do tributo 
    (PIS, COFINS ou IPI) e tipo de nota (E-Entrada / S-Saída). Este método não sofrerá alterações
    se não for criado um novo campo de busca no programa CD9780 - Relacionamento do CST - Everton/Adonias/Leandro ***/

/****** Tabela a comentar ******
Seq	Estab	Nat Ope	NCM	Item	Grup Emit	Cod Emit
01   xxx	xxx    	xxx	xxx        	xxx       xxx
02   xxx	xxx    	xxx	xxx        	xxx        o
03   xxx	xxx    	xxx	xxx        	 o        xxx
04   xxx	xxx    	xxx	xxx        	 o         o
05   xxx	xxx    	xxx	 o          xxx       xxx
06   xxx	xxx    	xxx	 o          xxx        o
07   xxx	xxx    	xxx	 o           o        xxx
08   xxx	xxx    	xxx	 o           o         o
09   xxx	xxx      o	xxx        	xxx       xxx
10   xxx	xxx      o	xxx        	xxx        o
11   xxx	xxx      o	xxx        	 o        xxx
12   xxx	xxx      o	xxx        	 o         o
13   xxx	xxx      o	 o          xxx       xxx
14   xxx	xxx      o	 o          xxx        o
15   xxx	xxx      o	 o           o        xxx
16   xxx	xxx      o	 o           o         o
17   xxx     o      xxx	xxx        	xxx       xxx
18   xxx     o      xxx	xxx        	xxx        o
19   xxx     o      xxx	xxx        	 o        xxx
20   xxx     o      xxx	xxx        	 o         o
21   xxx     o      xxx	 o          xxx       xxx
22   xxx     o      xxx	 o          xxx        o
23   xxx     o      xxx	 o           o        xxx
24   xxx     o      xxx	 o           o         o
25   xxx     o       o	xxx        	xxx       xxx
26   xxx     o       o	xxx        	xxx        o
27   xxx     o       o	xxx        	 o        xxx
28   xxx     o       o	xxx        	 o         o
29   xxx     o       o	 o          xxx       xxx
30   xxx     o       o	 o          xxx        o
31   xxx     o       o	 o           o        xxx
32   xxx     o       o	 o           o         o
33    o 	xxx    	xxx	xxx        	xxx       xxx
34    o 	xxx    	xxx	xxx        	xxx        o
35    o 	xxx    	xxx	xxx        	 o        xxx
36    o 	xxx    	xxx	xxx        	 o         o
37    o 	xxx    	xxx	 o          xxx       xxx
38    o 	xxx    	xxx	 o          xxx        o
39    o 	xxx    	xxx	 o           o        xxx
40    o 	xxx    	xxx	 o           o         o
41    o 	xxx      o	xxx        	xxx       xxx
42    o 	xxx      o	xxx        	xxx        o
43    o 	xxx      o	xxx        	 o        xxx
44    o 	xxx      o	xxx        	 o         o
45    o 	xxx      o	 o          xxx       xxx
46    o 	xxx      o	 o          xxx        o
47    o 	xxx      o	 o           o        xxx
48    o 	xxx      o	 o           o         o
49    o      o      xxx	xxx        	xxx       xxx
50    o      o      xxx	xxx        	xxx        o
51    o      o      xxx	xxx        	 o        xxx
52    o      o      xxx	xxx        	 o         o
53    o      o      xxx	 o          xxx       xxx
54    o      o      xxx	 o          xxx        o
55    o      o      xxx	 o           o        xxx
56    o      o      xxx	 o           o         o
57    o      o       o	xxx        	xxx       xxx
58    o      o       o	xxx        	xxx        o
59    o      o       o	xxx        	 o        xxx
60    o      o       o	xxx        	 o         o
61    o      o       o	 o          xxx       xxx
62    o      o       o	 o          xxx        o
63    o      o       o	 o           o        xxx
64    o      o       o	 o           o         o
**********************/

    DISABLE TRIGGERS FOR LOAD OF tribut.
    DISABLE TRIGGERS FOR LOAD OF sit-tribut.
    DISABLE TRIGGERS FOR LOAD OF sit-tribut-relacto.

    DEF VAR i-cont AS INTE  NO-UNDO.
    
    ASSIGN l-estab[1]        = NO
           l-nat-operacao[1] = NO
           l-ncm[1]          = NO
           l-it-codigo[1]    = NO
           l-cod-gr-cli[1]   = NO
           l-cod-emitente[1] = NO.

    ASSIGN l-estab[1]           = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cod-estab          = p-cod-estabel)    /* l-estab */
           l-nat-operacao[1]    = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cod-natur-operac   = p-nat-oper)       /* l-nat-operacao */
           l-ncm[1]             = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cod-ncm            = p-ncm)            /* l-ncm */
           l-it-codigo[1]       = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cod-item           = p-it-codigo)      /* l-it-codigo */
           l-cod-gr-cli[1]      = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cdn-grp-emit       = p-cod-gr-cli)     /* l-cod-gr-cli */
           l-cod-emitente[1]    = CAN-FIND(FIRST sit-tribut-relacto NO-LOCK WHERE sit-tribut-relacto.cdn-emitente       = p-cod-emitente).  /* l-cod-emitente */

    
    /*** A tabela de combinações possíveis irá possuir seis campos de busca (Estab, Nat Ope NCM, Item, Grup Emit, Cod Emit). 
     Considerando essa informação, para criação dos registros na tabela, ao todos teremos 64 combinações. 
     Para cada campo duplica-se o número de combinações na tabela, ou seja, um Campo = duas cobinações,
     dois campos = quatro combinações, três campos = oito combinações, quatro campos = dezesseis combinações, cinco campos = trinda e duas combinações,
     seis campos = sessenta e quatro combinações, e assim sucessivamente. Por fim, teremos sesenta e quatro registros nessa tabela, que representam
     sessenta e quatro combinações. Obs: Everton/Adonias/Leandro ***/

    DO i-cont = 1 TO 64:
        
        IF  (    i-cont <= 32
             AND l-estab[1] = YES) 
        OR  (    i-cont >= 33
             AND l-estab[2] = YES) THEN DO:
            
            CREATE tt-combinacao.
            ASSIGN tt-combinacao.seq = i-cont.
            
            /* ESTABELECIMENTO */

            /* informado */
            IF  i-cont <= 32 
            AND l-estab[1] = YES THEN
                ASSIGN tt-combinacao.cod-estabel = p-cod-estabel.

            /* generico */
            IF  i-cont >= 33
            AND l-estab[2] = YES THEN
                ASSIGN tt-combinacao.cod-estabel = "*".

            /* NATUREZA DE OPERACAO */

            /* informado */
            IF (    i-cont >= 1
                AND i-cont <= 16)
            OR (    i-cont >= 33
                AND i-cont <= 48) THEN
                IF  l-nat-operacao[1] THEN
                    ASSIGN tt-combinacao.nat-operacao = p-nat-oper.
                ELSE DO:
                    DELETE tt-combinacao.
                    NEXT.
                END.

            /* generico */
            IF (    i-cont >= 17
                AND i-cont <= 32)
            OR (    i-cont >= 49
                AND i-cont <= 64) THEN
                IF  l-nat-operacao[2] THEN
                    ASSIGN tt-combinacao.nat-operacao = "*".
                ELSE DO:
                    DELETE tt-combinacao.
                    NEXT.
                END.

            /* NCM */

            /*informado*/
            IF (    i-cont >= 1
                AND i-cont <= 8)
            OR (    i-cont >= 17
                AND i-cont <= 24)
            OR (    i-cont >= 33
                AND i-cont <= 40)
            OR (    i-cont >= 49
                AND i-cont <= 56) THEN
                IF  l-ncm[1] THEN
                    ASSIGN tt-combinacao.cod-ncm = STRING(p-ncm).
                ELSE DO:
                    DELETE tt-combinacao.
                    NEXT.
                END.

            /* generico */
            IF (    i-cont >= 9                         
                AND i-cont <= 16)                        
            OR (    i-cont >= 25                        
                AND i-cont <= 32)                       
            OR (    i-cont >= 41                        
                AND i-cont <= 48)                       
            OR (    i-cont >= 57                        
                AND i-cont <= 64) THEN                  
                IF  l-ncm[2] THEN
                    ASSIGN tt-combinacao.cod-ncm = "*".
                ELSE DO:
                    DELETE tt-combinacao.
                    NEXT.
                END.

            /* ITEM */

            /*informado*/
            IF (    i-cont >= 1  
                AND i-cont <= 4) 
            OR (    i-cont >= 9 
                AND i-cont <= 12)
            OR (    i-cont >= 17 
                AND i-cont <= 20)
            OR (    i-cont >= 25 
                AND i-cont <= 28)
            OR (    i-cont >= 33   
                AND i-cont <= 36) 
            OR (    i-cont >= 41  
                AND i-cont <= 44) 
            OR (    i-cont >= 49  
                AND i-cont <= 52) 
            OR (    i-cont >= 57  
                AND i-cont <= 60) THEN
                IF  l-it-codigo[1] THEN
                    ASSIGN tt-combinacao.cod-item = p-it-codigo.
                ELSE DO:
                    DELETE tt-combinacao.
                    NEXT.
                END.

            /* generico */
            IF (    i-cont >= 5                                 
                AND i-cont <= 8)                                
            OR (    i-cont >= 13                                 
                AND i-cont <= 16)                               
            OR (    i-cont >= 21                                
                AND i-cont <= 24)                               
            OR (    i-cont >= 29                                
                AND i-cont <= 32)                               
            OR (    i-cont >= 37                                
                AND i-cont <= 40)                               
            OR (    i-cont >= 45                                
                AND i-cont <= 48)                               
            OR (    i-cont >= 53                                
                AND i-cont <= 56)                               
            OR (    i-cont >= 61                                
                AND i-cont <= 64) THEN                          
                IF  l-it-codigo[2] THEN
                    ASSIGN tt-combinacao.cod-item = "*". 
                ELSE DO:
                    DELETE tt-combinacao.
                    NEXT.
                END.

            /* GRUPO EMITENTE */

            /*informado*/
            IF (    i-cont >= 1  
                AND i-cont <= 2) 
            OR (    i-cont >= 5  
                AND i-cont <= 6)
            OR (    i-cont >= 9 
                AND i-cont <= 10)
            OR (    i-cont >= 13 
                AND i-cont <= 14)
            OR (    i-cont >= 17 
                AND i-cont <= 18)
            OR (    i-cont >= 21 
                AND i-cont <= 22)
            OR (    i-cont >= 25 
                AND i-cont <= 26)
            OR (    i-cont >= 29 
                AND i-cont <= 30)
            OR (    i-cont >= 33  
                AND i-cont <= 34) 
            OR (    i-cont >= 37  
                AND i-cont <= 38) 
            OR (    i-cont >= 41  
                AND i-cont <= 42)
            OR (    i-cont >= 45 
                AND i-cont <= 46)
            OR (    i-cont >= 49 
                AND i-cont <= 50)
            OR (    i-cont >= 53 
                AND i-cont <= 54)
            OR (    i-cont >= 57 
                AND i-cont <= 58)
            OR (    i-cont >= 61 
                AND i-cont <= 62) THEN
                IF  l-cod-gr-cli[1] THEN
                    ASSIGN tt-combinacao.cdn-grp-emit = p-cod-gr-cli.
                ELSE DO:
                    DELETE tt-combinacao.
                    NEXT.
                END.

            /* generico */
            IF (    i-cont >= 3  
                AND i-cont <= 4) 
            OR (    i-cont >= 7  
                AND i-cont <= 8)
            OR (    i-cont >= 11 
                AND i-cont <= 12)
            OR (    i-cont >= 15 
                AND i-cont <= 16)
            OR (    i-cont >= 19 
                AND i-cont <= 20)
            OR (    i-cont >= 23 
                AND i-cont <= 24)
            OR (    i-cont >= 27 
                AND i-cont <= 28)
            OR (    i-cont >= 31 
                AND i-cont <= 32)
            OR (    i-cont >= 35  
                AND i-cont <= 36) 
            OR (    i-cont >= 39  
                AND i-cont <= 40) 
            OR (    i-cont >= 43  
                AND i-cont <= 44)
            OR (    i-cont >= 47 
                AND i-cont <= 48)
            OR (    i-cont >= 51 
                AND i-cont <= 52)
            OR (    i-cont >= 55 
                AND i-cont <= 56)
            OR (    i-cont >= 59 
                AND i-cont <= 60)
            OR (    i-cont >= 63 
                AND i-cont <= 64) THEN
                IF  l-cod-gr-cli[2] THEN
                    ASSIGN tt-combinacao.cdn-grp-emit = 0.
                ELSE DO:
                    DELETE tt-combinacao.
                    NEXT.
                END.

            /* COD EMIT */

            IF (i-cont MOD 2) = 1 THEN DO:
                IF  l-cod-emitente[1] THEN
                    ASSIGN tt-combinacao.cdn-emitente = p-cod-emitente.
                ELSE DO:
                    DELETE tt-combinacao.
                    NEXT.
                END.
            END.
            ELSE DO:
                IF  l-cod-emitente[2] THEN
                    ASSIGN tt-combinacao.cdn-emitente = 0.
                ELSE DO:
                    DELETE tt-combinacao.
                    NEXT.
                END.
            END.
        END.
    END.

END PROCEDURE.

PROCEDURE pi-retorna-sit-tribut:

    DEF INPUT  PARAM p-tipo-nota    AS INT                       NO-UNDO.
    def input  param p-cod-estabel  as CHAR FORMAT 'X(3)'        no-undo.
    def input  param p-nat-oper     AS CHAR FORMAT 'X(6)'        no-undo.
    def input  param p-ncm          AS CHAR FORMAT "9999.99.99"  no-undo.
    def input  param p-it-codigo    AS CHAR FORMAT 'X(16)'       no-undo.
    def input  param p-cod-gr-cli   AS INT  FORMAT ">9"          no-undo.
    def input  param p-cod-emitente AS INT  FORMAT ">>>>>>>>9"   no-undo.
    def input  param p-dt-emis-nota as date FORMAT 99/99/9999    no-undo.

    def OUTPUT PARAM table FOR tt-sit-tribut. /*** A utilização de temp-table foi necessário porque futaramente esta api irá retornar situação de outros impostos (ex: icms), assim
							 será necessário apenas criar um novo registro na temp-table para o novo tributo. Como essa api será chamada por diversas funções, como
                                                         sped, nf-e, in86, conectores softteam, etC; dessa forma não será necessário alterar a passagem de parâmetros. Everton/Adonias/Leandro ***/

    /*** Cria tabela de combinações para busca do código da situação tributária ***/

    IF NOT CAN-FIND(FIRST sit-tribut-relacto) THEN
        RETURN.

    DISABLE TRIGGERS FOR LOAD OF tribut.
    DISABLE TRIGGERS FOR LOAD OF sit-tribut.
    DISABLE TRIGGERS FOR LOAD OF sit-tribut-relacto.

    EMPTY TEMP-TABLE tt-combinacao.
    EMPTY TEMP-TABLE tt-sit-tribut.
    EMPTY TEMP-TABLE tt-retorna-rowid.

    ASSIGN rw-sit-relacto-icms = ?.

    RUN pi-gera-tt-combinacao (INPUT p-cod-estabel, 
                               input p-nat-oper,    
                               input p-ncm,          
                               input p-it-codigo,            
                               input p-cod-gr-cli,   
                               input p-cod-emitente).

    /*** Cria tabela de tributos ***/
    IF  NOT CAN-FIND(FIRST tt-sit-tribut) THEN
        for each tribut WHERE 
            (LOOKUP(string(tribut.cdn-tribut), c-lista-tributos) > 0 OR
             c-lista-tributos = "") no-lock:
            create tt-sit-tribut.
            assign tt-sit-tribut.cdn-tribut     = tribut.cdn-tribut
                   tt-sit-tribut.cdn-sit-tribut = 0
                   tt-sit-tribut.seq-tab-comb   = 0. /*** Quando esse campo for diferente de zero indica que foi encontrado o código de situação tributária e portanto não é
                                                      mais necessário realizar a busca na tabela de combinação. Este campo armazena a sequencia da tabela de combinção, permitindo
                                                      saber de que combinação foi buscada o código de situação tributária. ***/
                
        end.

    Busca-cst:
    FOR EACH tt-combinacao:
        
        FOR EACH tt-sit-tribut
            WHERE tt-sit-tribut.seq-tab-comb = 0: /*** Se o código de situação tributária para o tributo já foi encontrado esse campo será diferente de zero, e portanto não é necessário continuar a busca ***/
            FIND LAST sit-tribut-relacto
                WHERE sit-tribut-relacto.cdn-tribut	      =  tt-sit-tribut.cdn-tribut             
	              AND sit-tribut-relacto.idi-tip-docto    =  p-tipo-nota /* 1-Entrada e 2-saída */   
	              AND sit-tribut-relacto.cod-estab        =  tt-combinacao.cod-estabel                
	              AND sit-tribut-relacto.cod-natur-operac =  tt-combinacao.nat-operacao               
	              AND sit-tribut-relacto.cod-ncm 	      =  tt-combinacao.cod-ncm
	              AND sit-tribut-relacto.cod-item   	  =  tt-combinacao.cod-item                   
	              AND sit-tribut-relacto.cdn-grp-emit     =  tt-combinacao.cdn-grp-emit               
	              AND sit-tribut-relacto.cdn-emitente 	  =  tt-combinacao.cdn-emitente               
	              AND sit-tribut-relacto.dat-valid-inic  <= p-dt-emis-nota NO-LOCK NO-ERROR. 
            IF AVAIL sit-tribut-relacto THEN DO:
            
                
                ASSIGN tt-sit-tribut.cdn-sit-tribut = sit-tribut-relacto.cdn-sit-tribut
                       tt-sit-tribut.seq-tab-comb   = tt-combinacao.seq.
                
                CREATE tt-retorna-rowid.
                ASSIGN tt-retorna-rowid.cdn-tribut            = tt-sit-tribut.cdn-tribut
                       tt-retorna-rowid.rw-sit-tribut-relacto = ROWID(sit-tribut-relacto).

                

            END.
        END.
        IF NOT CAN-FIND(FIRST tt-sit-tribut
            WHERE tt-sit-tribut.seq-tab-comb = 0) THEN
            LEAVE Busca-cst.
    END.

END PROCEDURE.

PROCEDURE pi-retorna-rowid:
    DEFINE OUTPUT PARAM TABLE FOR tt-retorna-rowid .
END PROCEDURE.

PROCEDURE pi-seta-tributos:
    DEFINE INPUT PARAM p-lista-tributos AS CHAR .
    ASSIGN c-lista-tributos = p-lista-tributos.
END PROCEDURE.

