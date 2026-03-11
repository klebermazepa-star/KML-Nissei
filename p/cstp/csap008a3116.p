/*
Descri‡Æo: Prefeitura de Colombo
Autor: JRA

emitente.natureza - MESSAGE {adinc/i03ad098.i 7} VIEW-AS ALERT-BOX .
Pessoa F¡sica, 1,Pessoa Jur¡dica, 2,Estrangeiro, 3,Trading, 4
*/
/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE program_name         CSAP008A3116
&SCOPED-DEFINE program_version      1.00.00.001

{include/i-prgvrs.i {&program_name} {&program_version} }

{cstp/csap008i01.i}

/*Parameters Definitions*/
DEF INPUT PARAM TABLE FOR tt-param .
DEF INPUT PARAM TABLE FOR tt-docto .

FIND FIRST tt-param NO-LOCK .

/* ***************************  MAIN BLOCK  ************************** */
DEF VAR h-acomp AS HANDLE NO-UNDO.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Executando {&program_name} - {&program_version}') .
RUN pi-acompanhar IN h-acomp (INPUT 'Processando...') .

DEF BUFFER cidade FOR ems2dis.cidade .
DEF BUFFER bf-emitente FOR emitente .

DEF VAR v_linha             AS CHAR NO-UNDO .

DEF VAR v_local_prest_serv  AS INT NO-UNDO .

DEF VAR v_num_endereco      AS CHAR NO-UNDO .
DEF VAR v_num_endereco_int  AS INT NO-UNDO .

DEF VAR v_cep               AS CHAR NO-UNDO .
DEF VAR v_cep_int           AS INT NO-UNDO .

FIND FIRST bf-emitente NO-LOCK WHERE bf-emitente.cod-emitente = tt-param.cod-prefeitura .

FOR EACH tt-docto NO-LOCK
    BREAK BY tt-docto.cod-estabel
    :
    FIND FIRST estabelec NO-LOCK OF tt-docto .
    FIND FIRST cidade NO-LOCK OF estabelec .
    FIND FIRST emitente NO-LOCK OF tt-docto .

    IF FIRST-OF(tt-docto.cod-estabel) THEN DO:
        OUTPUT TO VALUE(tt-param.dir-arquivos + "/" +
                        estabelec.cidade + "_" + 
                        estabelec.estado + "_" +
                        STRING(tt-param.mes-transacao , "99") + "_" +
                        STRING(tt-param.ano-transacao , "9999") + "_" + 
                        SUBSTR(estabelec.cgc,9,6) +
                        ".txt" )
        NO-CONVERT .
    END.

    ASSIGN v_linha = "" .
    OVERLAY(v_linha , 001 , 002) = "10" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 004 , 001) = "2" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 006 , 002) = IF tt-docto.cod-esp = 'NF' THEN '01' ELSE '04'.
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 009 , 015) = STRING(INT(tt-docto.nro-docto),"999999999999999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 025 , 007) = STRING(MONTH(tt-docto.dt-emissao) , "99") + "/" + STRING(YEAR(tt-docto.dt-emissao) , "9999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 033 , 001) = IF emitente.natureza = 1 THEN "F" ELSE "J" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 035 , 014) = STRING(DECIMAL(emitente.cgc) , "99999999999999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 050 , 001) = "J" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 052 , 014) = STRING(DECIMAL(estabelec.cgc) , "99999999999999") . 
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 067 , 010) = STRING(tt-docto.dt-emissao , "99/99/9999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 078 , 018) = REPLACE(STRING(tt-docto.vl-docto , "999999999999999.99") , "," , ".") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 097 , 001) = "E" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 099 , 100) = "" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 200 , 001) = IF tt-docto.simples-nac THEN "S" ELSE "N" .
    ASSIGN v_linha = v_linha + ';' .
    PUT UNFORMATTED v_linha SKIP .

    ASSIGN v_local_prest_serv = INT(SUBSTRING(STRING(cidade.cdn-domic-fisc) , LENGTH(STRING(cidade.cdn-domic-fisc)) - 3 , 4)) .

    ASSIGN v_linha = "" .
    OVERLAY(v_linha , 001 , 002) = "20" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 004 , 001) = "2" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 006 , 002) = IF tt-docto.cod-esp = 'NF' THEN '01' ELSE '04'.
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 009 , 015) = STRING(INT(tt-docto.nro-docto),"999999999999999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 025 , 007) = STRING(MONTH(tt-docto.dt-emissao) , "99") + "/" + STRING(YEAR(tt-docto.dt-emissao) , "9999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 033 , 001) = IF emitente.natureza = 1 THEN "F" ELSE "J" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 035 , 014) = STRING(DECIMAL(emitente.cgc) , "99999999999999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 050 , 001) = "J" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 052 , 014) = STRING(DECIMAL(estabelec.cgc) , "99999999999999") . 
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 067 , 007) = STRING(INT(tt-docto.cod-retencao) , "9999999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 075 , 006) = REPLACE(STRING(tt-docto.aliquota , "999.99") , "," , ".") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 082 , 018) = REPLACE(STRING(tt-docto.vl-docto , "999999999999999.99") , "," , ".") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 101 , 018) = REPLACE(STRING(0 , "999999999999999.99") , "," , ".") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 120 , 018) = REPLACE(STRING(tt-docto.vl-imposto , "999999999999999.99") , "," , ".") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 139 , 007) = STRING(v_local_prest_serv , "9999999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 147 , 002) = IF tt-docto.vl-imposto <> 0 THEN "01" ELSE "13" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 150 , 001) = IF tt-docto.cod-retencao <> 0 THEN "N" ELSE "S" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 152 , 010) = FILL('0' , 10) .
    ASSIGN v_linha = v_linha + ';' .
    PUT UNFORMATTED v_linha SKIP .

    ASSIGN v_num_endereco = "S/N" .
    ASSIGN v_num_endereco_int = ? .
    IF NUM-ENTRIES(emitente.endereco, ",") >= 2 THEN DO:
        ASSIGN v_num_endereco_int = INT(ENTRY(2 , emitente.endereco , ",")) NO-ERROR .
        IF v_num_endereco_int <> ? THEN DO:
            ASSIGN v_num_endereco = STRING(v_num_endereco_int) .
        END.
    END.

    ASSIGN v_cep = "" .
    ASSIGN v_cep_int = INT(emitente.cep) NO-ERROR .
    IF v_cep_int <> ? THEN DO:
        ASSIGN v_cep = STRING(v_cep_int) . 
    END.

    ASSIGN v_linha = "" .
    OVERLAY(v_linha , 001 , 002) = "30" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 004 , 001) = IF emitente.natureza = 1 THEN "F" ELSE "J" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 006 , 014) = STRING(DECIMAL(emitente.cgc) , "99999999999999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 021 , 040) = emitente.nome-emit .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 062 , 040) = emitente.endereco .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 103 , 006) = v_num_endereco .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 110 , 020) = "".
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 131 , 020) = emitente.bairro .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 152 , 030) = emitente.cidade .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 183 , 002) = emitente.estado .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 186 , 008) = STRING(INT(v_cep) , "99999999") .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 195 , 012) = "" .
    ASSIGN v_linha = v_linha + ';' .
    OVERLAY(v_linha , 208 , 012) = "" .
    ASSIGN v_linha = v_linha + ';' .
    PUT UNFORMATTED v_linha SKIP .

    IF LAST-OF(tt-docto.cod-estabel) THEN DO:
        OUTPUT CLOSE .
    END.
END.

/*FIM*/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .


