/*************************************************************************
**
**  Programa: int004.p - Integraá∆o de Clientes - Oblak   -> Datasul
**                                                Procfit -> Datasul 
**
*************************************************************************/                                                        
  
DISABLE TRIGGERS FOR LOAD OF tab-ocor.
DISABLE TRIGGERS FOR LOAD OF emitente.

{intprg/int-rpw.i}  
  
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR FORMAT "x(12)" NO-UNDO.

DEF BUFFER b-emitente FOR emitente.

def var i-emitente     as int no-undo.    
def var i-identific    AS INT no-undo.  
DEF VAR i-cod-emitente LIKE emitente.cod-emitente NO-UNDO.
DEF VAR c-cidade       LIKE int_ds_cliente.cidade NO-UNDO.
DEF VAR c-estado       LIKE int_ds_cliente.estado NO-UNDO.
DEF VAR c-ins-estadual LIKE emitente.ins-estadual NO-UNDO. 
DEF VAR c-sistema-orig AS CHAR NO-UNDO.

function PrintChar returns longchar
    (input pc-string as longchar):

    /* necess†rio para que a funá∆o seja case-sensitive */
    define variable c-string as longchar case-sensitive no-undo.
    define variable i-ind as integer no-undo.

    assign c-string = pc-string.

    assign c-string = replace(c-string,"†","a").
    assign c-string = replace(c-string,"Ö","a").
    assign c-string = replace(c-string,"∆","a").
    assign c-string = replace(c-string,"É","a").
    assign c-string = replace(c-string,"Ñ","a").

    assign c-string = replace(c-string,"Ç","e").
    assign c-string = replace(c-string,"ä","e").
    assign c-string = replace(c-string,"à","e").
    assign c-string = replace(c-string,"â","e").

    assign c-string = replace(c-string,"°","i").
    assign c-string = replace(c-string,"ç","i").
    assign c-string = replace(c-string,"å","i").
    assign c-string = replace(c-string,"ã","i").

    assign c-string = replace(c-string,"¢","o").
    assign c-string = replace(c-string,"ï","o").
    assign c-string = replace(c-string,"ì","o").
    assign c-string = replace(c-string,"î","o").
    assign c-string = replace(c-string,"‰","o").

    assign c-string = replace(c-string,"£","u").
    assign c-string = replace(c-string,"ó","u").
    assign c-string = replace(c-string,"ñ","u").
    assign c-string = replace(c-string,"Å","u").

    assign c-string = replace(c-string,"á","c").
    assign c-string = replace(c-string,"§","n").

    assign c-string = replace(c-string,"Ï","y").
    assign c-string = replace(c-string,"ò","y").

    assign c-string = replace(c-string,"µ","A").
    assign c-string = replace(c-string,"∑","A").
    assign c-string = replace(c-string,"«","A").
    assign c-string = replace(c-string,"∂","A").
    assign c-string = replace(c-string,"é","A").

    assign c-string = replace(c-string,"ê","E").
    assign c-string = replace(c-string,"‘","E").
    assign c-string = replace(c-string,"“","E").
    assign c-string = replace(c-string,"”","E").

    assign c-string = replace(c-string,"÷","I").
    assign c-string = replace(c-string,"ﬁ","I").
    assign c-string = replace(c-string,"◊","I").
    assign c-string = replace(c-string,"ÿ","I").

    assign c-string = replace(c-string,"‡","O").
    assign c-string = replace(c-string,"„","O").
    assign c-string = replace(c-string,"‚","O").
    assign c-string = replace(c-string,"ô","O").
    assign c-string = replace(c-string,"Â","O").

    assign c-string = replace(c-string,"È","U").
    assign c-string = replace(c-string,"Î","U").
    assign c-string = replace(c-string,"Í","U").
    assign c-string = replace(c-string,"ö","U").

    assign c-string = replace(c-string,"Ä","C").
    assign c-string = replace(c-string,"•","N").
                                        
    assign c-string = replace(c-string,"Ì","Y").

    assign c-string = replace(c-string,CHR(13),"").
    assign c-string = replace(c-string,CHR(10),"").

    assign c-string = replace(c-string,"˚","").
    assign c-string = replace(c-string,"≠","").
    assign c-string = replace(c-string,"˝","2").
    assign c-string = replace(c-string,"¸","3").
    assign c-string = replace(c-string,"œ","o").
    assign c-string = replace(c-string,"∞","E").
    assign c-string = replace(c-string,"¨","1/4").
    assign c-string = replace(c-string,"´","1/2").
    assign c-string = replace(c-string,"Û","3/4").
    assign c-string = replace(c-string,"æ","Y").
    assign c-string = replace(c-string,"û","x").
    assign c-string = replace(c-string,"Á","p").
    assign c-string = replace(c-string,"©","r").
    assign c-string = replace(c-string,"Ü","a").
    assign c-string = replace(c-string,"·","B").
    assign c-string = replace(c-string,"–","y").
    assign c-string = replace(c-string,"õ","o").
    assign c-string = replace(c-string,"Ù","").
    assign c-string = replace(c-string,"ë","ae").
    assign c-string = replace(c-string,"Ê","u").
    assign c-string = replace(c-string,"®","").
    assign c-string = replace(c-string,"∫","").
    assign c-string = replace(c-string,"ı","").
    assign c-string = replace(c-string,"è","A").
    assign c-string = replace(c-string,"©","").
    assign c-string = replace(c-string,"Ë","p").
    assign c-string = replace(c-string,"Æ","-").
    assign c-string = replace(c-string,"Ø","-").
    assign c-string = replace(c-string,"™","").
    assign c-string = replace(c-string,"™","").
    assign c-string = replace(c-string,"Ù","").
    assign c-string = replace(c-string,"ù","0").
    assign c-string = replace(c-string,"—","D").
    assign c-string = replace(c-string,"·","B").
    assign c-string = replace(c-string,"í","").
    assign c-string = replace(c-string,"∏","").
    assign c-string = replace(c-string,"ú","").
    assign c-string = replace(c-string,"ı","").

    assign c-string = replace(c-string,"ˆ","").
    assign c-string = replace(c-string,"›","").
    assign c-string = replace(c-string,"¯","o").
    assign c-string = replace(c-string,"Ω","c").

    do i-ind = 1 to 31:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 127 to 144:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 147 to 159:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 162 to 182:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 184 to 191:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 215 to 216:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.
    do i-ind = 248 to 248:
        assign c-string = replace(c-string,chr(i-ind),".").
    end.

    assign c-string = trim(c-string).

    return c-string.

end function.

FOR EACH int_ds_cliente 
   WHERE int_ds_cliente.situacao = 1 /* Pendente */
    /*AND int_ds_cliente.cgc = "39688569968" */
    QUERY-TUNING(NO-LOOKAHEAD)
    BY int_ds_cliente.dt_geracao 
    BY int_ds_cliente.tipo_movto: 

    IF int_ds_cliente.cgc BEGINS "79430682" 
    OR int_ds_cliente.cgc = "13495487000172" THEN DO:
       ASSIGN int_ds_cliente.situacao = 2. /* Integrado */
       NEXT.
    END.

    FIND FIRST emitente WHERE
               emitente.cgc = int_ds_cliente.cgc NO-LOCK NO-ERROR.
    IF AVAIL emitente THEN DO:
       FIND FIRST estabelec WHERE 
                  estabelec.cod-emitente = emitente.cod-emitente NO-LOCK NO-ERROR.
       IF AVAIL estabelec THEN DO:
          ASSIGN int_ds_cliente.situacao = 2. /* Integrado */
          NEXT.
       END.
    END.

    ASSIGN c-sistema-orig = "Oblak".
    IF int_ds_cliente.origem_cli = 2 THEN
       ASSIGN c-sistema-orig = "Procfit".

    ASSIGN i-identific    = 1
           c-cidade       = IF int_ds_cliente.cidade = ? THEN "" ELSE PrintChar(int_ds_cliente.cidade)
           c-estado       = IF int_ds_cliente.estado = ? THEN "" ELSE int_ds_cliente.estado
           c-ins-estadual = int_ds_cliente.ins_estadual.

    IF  c-sistema-orig = "Procfit" 
    AND int_ds_cliente.cod_mun_ibge <> ? THEN DO:
        FOR FIRST ems2dis.cidade WHERE
                  ems2dis.cidade.cdn-munpio-ibge = int_ds_cliente.cod_mun_ibge NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
        END.
        IF NOT AVAIL ems2dis.cidade THEN DO:
           RUN intprg/int999.p (INPUT "CLI", 
                                INPUT STRING(int_ds_cliente.cgc),
                                INPUT "C¢digo IBGE da Cidade n∆o cadastrado no Datasul: " + string(int_ds_cliente.cod_mun_ibge) + ". Origem: " + c-sistema-orig + ".",
                                INPUT 1, /* 1 - Pendente */
                                INPUT c-seg-usuario,
                                INPUT "int004.p").
            NEXT.
        END.
        ASSIGN c-cidade              = ems2dis.cidade.cidade
               int_ds_cliente.cidade = ems2dis.cidade.cidade.

    END.

    IF int_ds_cliente.nome_emit = ?
    OR int_ds_cliente.nome_emit = "?" 
    OR int_ds_cliente.nome_emit = "" THEN DO:
       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "Nome do Cliente est† branco ou desconhecido. CPF/CNPJ: " + int_ds_cliente.cgc + ". Verificar no sistema" + c-sistema-orig + ".",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int004.p").
       NEXT.
    END.
    
    IF int_ds_cliente.nome_abrev = ?
    OR int_ds_cliente.nome_abrev = "?" 
    OR int_ds_cliente.nome_abrev = "" THEN DO:
       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "Nome Abreviado est† branco ou desconhecido. CPF/CNPJ: " + int_ds_cliente.cgc + ". Verificar no sistema" + c-sistema-orig + ".",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int004.p").
       NEXT.
    END.

    IF int_ds_cliente.cgc = ?
    OR int_ds_cliente.cgc = "?" 
    OR int_ds_cliente.cgc = "" THEN DO:
       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "CNPJ/CPF est† branco ou desconhecido. Nome Abrev.: " + int_ds_cliente.nome_abrev + ". Verificar no sistema" + c-sistema-orig + ".",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int004.p").
       NEXT.
    END.

    IF int_ds_cliente.cep = ?
    OR int_ds_cliente.cep = "?" 
    OR int_ds_cliente.cep = "" THEN DO:
       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "CEP do Cliente est† branco ou desconhecido. CPF/CNPJ: " + int_ds_cliente.cgc + ". Verificar no sistema " + c-sistema-orig + ".",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int004.p").
       NEXT.
    END.

    IF  int_ds_cliente.natureza = 2 /* Pessoa Jur°dica */
    AND (int_ds_cliente.ins_estadual = "?" OR int_ds_cliente.ins_estadual = ?) THEN DO:
        RUN intprg/int999.p (INPUT "CLI", 
                             INPUT STRING(int_ds_cliente.cgc),
                             INPUT "Cliente Ç Pessoa Jur°dica e possui Inscriá∆o Estadual inv†lida. CPF/CNPJ: " + int_ds_cliente.cgc + ". Verificar no sistema " + c-sistema-orig + ".",
                             INPUT 1, /* 1 - Pendente */
                             INPUT c-seg-usuario,
                             INPUT "int004.p").
         NEXT.
    END.

    IF  int_ds_cliente.natureza = 2 /* Pessoa Jur°dica */ 
    AND c-ins-estadual          = "" THEN
        ASSIGN c-ins-estadual = "ISENTO".        

    IF c-ins-estadual BEGINS "I" THEN
       ASSIGN c-ins-estadual = "ISENTO".

    IF int_ds_cliente.natureza = 1 THEN /* Pessoa F°sica */
       ASSIGN c-ins-estadual = "ISENTO".

    IF int_ds_cliente.cidade = ? 
    OR int_ds_cliente.cidade = "?" THEN
       ASSIGN int_ds_cliente.cidade = "".
    IF int_ds_cliente.pais = ? OR
       int_ds_cliente.pais = "?" OR
       int_ds_cliente.pais = " "   THEN
        ASSIGN int_ds_cliente.pais = "BRASIL".

    FIND FIRST ems2dis.cidade WHERE
               ems2dis.cidade.cidade = /*int_ds_cliente.cidade*/ c-cidade NO-LOCK NO-ERROR.
    IF NOT AVAIL ems2dis.cidade THEN DO:

       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "Cidade do Cliente n∆o cadastrada no Datasul: " + c-cidade + ". Origem: " + c-sistema-orig + ".",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int004.p").
        NEXT.
    END.

    FIND FIRST ems2dis.cidade WHERE
               ems2dis.cidade.cidade = /*int_ds_cliente.cidade*/ c-cidade AND 
               ems2dis.cidade.estado = int_ds_cliente.estado AND 
               ems2dis.cidade.pais   = "Brasil" NO-LOCK NO-ERROR.
    IF NOT AVAIL ems2dis.cidade THEN DO:
       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(int_ds_cliente.cgc),
                            INPUT "Cidade/Estado do Cliente n∆o cadastrado no Datasul: " + c-cidade + "/" + c-estado + ". Origem: " + c-sistema-orig + ".",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int004.p").
        NEXT.
    END.

    IF int_ds_cliente.cod_gr_cli = ? THEN
       ASSIGN int_ds_cliente.cod_gr_cli = 0.

    IF int_ds_cliente.bairro = ? 
    OR int_ds_cliente.bairro = "?" THEN
       ASSIGN int_ds_cliente.bairro = "".

    IF int_ds_cliente.tipo_movto = 1 THEN DO: /* Inclus∆o */
       FIND FIRST emitente WHERE
                  emitente.nome-abrev = int_ds_cliente.nome_abrev NO-LOCK NO-ERROR.
       IF AVAIL emitente THEN DO:

          IF emitente.natureza = 1 THEN DO: /* F°sica */
             IF emitente.nome-abrev = int_ds_cliente.cgc THEN DO: 
                ASSIGN int_ds_cliente.situacao = 2. /* Integrado */
                RUN intprg/int999.p (INPUT "CLI", 
                                     INPUT STRING(emitente.cgc),
                                     INPUT "Cliente integrado com sucesso no Datasul - CPF/CNPJ: " + string(emitente.cgc) + ". Origem: " + c-sistema-orig + ".",
                                     INPUT 2, /* 2 - Integrado */
                                     INPUT c-seg-usuario,
                                     INPUT "int004.p").
                NEXT.
             END.
          END.
          IF emitente.natureza = 2 THEN DO: /* Jur°dica */
             IF emitente.nome-abrev = substr(int_ds_cliente.cgc,1,12) THEN DO: 
                ASSIGN int_ds_cliente.situacao = 2. /* Integrado */
                RUN intprg/int999.p (INPUT "CLI", 
                                     INPUT STRING(emitente.cgc),
                                     INPUT "Cliente integrado com sucesso no Datasul - CPF/CNPJ: " + string(emitente.cgc) + ". Origem: " + c-sistema-orig + ".",
                                     INPUT 2, /* 2 - Integrado */
                                     INPUT c-seg-usuario,
                                     INPUT "int004.p").
                NEXT.
             END.
          END.
       END.
       
       FIND FIRST emitente WHERE
                  emitente.cgc = int_ds_cliente.cgc NO-LOCK NO-ERROR.
       IF AVAIL emitente THEN DO:
          if emitente.identific <> int_ds_cliente.identific THEN
             ASSIGN i-identific = 3.
          
          ASSIGN i-cod-emitente = emitente.cod-emitente.
       END.       
       else do:
          /* AVB 12/06/2018 - verificar nome-abrev j† utilizado */
          for first emitente fields (cgc nome-emit cod-emitente) no-lock where 
                    emitente.nome-abrev = int_ds_cliente.nome_abrev: 
          end.
          if avail emitente then do:
             IF emitente.cgc = int_ds_cliente.cgc THEN
                ASSIGN int_ds_cliente.situacao = 2. /* Integrado */
             /*RUN intprg/int999.p (INPUT "CLI", 
                                  INPUT STRING(emitente.cgc),
                                  INPUT "Nome Abreviado " + int_ds_cliente.nome-abrev + " j† utilizado no cliente - CPF/CNPJ: " + string(emitente.cgc) + ". Origem: " + c-sistema-orig + ".",
                                  INPUT 1, /* 1 - Pendente */
                                  INPUT c-seg-usuario,
                                  INPUT "int004.p").*/
             NEXT.
          end.
          run intprg/int004a.p (OUTPUT i-emitente).
          CREATE emitente.
          ASSIGN emitente.cod-emitente = i-emitente
                 emitente.nome-abrev   = int_ds_cliente.nome_abrev
                 emitente.cgc          = int_ds_cliente.cgc
                 i-cod-emitente        = i-emitente.
       end.
    END.

    IF int_ds_cliente.tipo_movto = 2 THEN DO: /* Alteraá∆o */
       FIND FIRST emitente WHERE
                  emitente.cgc = int_ds_cliente.cgc NO-LOCK NO-ERROR.
       IF NOT AVAIL emitente THEN DO:
          ASSIGN int_ds_cliente.tipo_movto = 1. 
          NEXT.
       END.

       assign i-identific    = emitente.identific
              i-cod-emitente = emitente.cod-emitente.
    END.

    RELEASE emitente.

    FIND FIRST emitente WHERE
               emitente.cod-emitente = i-cod-emitente EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL emitente THEN DO:

       IF  int_ds_cliente.cnpj_emp_conv <> ?
       AND int_ds_cliente.cnpj_emp_conv <> "" 
       AND STRING(DEC(int_ds_cliente.cnpj_emp_conv),"99999999999999") <> ? THEN DO:
           FIND FIRST b-emitente 
                WHERE b-emitente.cgc = STRING(DEC(int_ds_cliente.cnpj_emp_conv),"99999999999999") NO-LOCK NO-ERROR.
           IF AVAIL b-emitente THEN
              ASSIGN emitente.nome-matriz = b-emitente.nome-abrev.
           ELSE 
              ASSIGN emitente.nome-matriz = int_ds_cliente.nome_abrev.
       END.
       ELSE 
           ASSIGN emitente.nome-matriz = int_ds_cliente.nome_abrev.

       ASSIGN emitente.identific      = i-identific
              emitente.natureza       = int_ds_cliente.natureza 
              emitente.nome-emit      = int_ds_cliente.nome_emit
              emitente.endereco       = int_ds_cliente.endereco 
              emitente.bairro         = SUBSTRING(int_ds_cliente.bairro,1,30)
              emitente.cidade         = /*int_ds_cliente.cidade*/ c-cidade   
              emitente.estado         = int_ds_cliente.estado   
              emitente.cep            = int_ds_cliente.cep      
              emitente.pais           = int_ds_cliente.pais    
              emitente.cod-gr-cli     = int_ds_cliente.cod_gr_cli
              emitente.portador       = 99999
              emitente.modalidade     = 6
              emitente.cod-rep        = 1
              emitente.cod-transp     = 99999
              emitente.tp-rec-padrao  = 208
              emitente.end-cobranca   = i-cod-emitente
              emitente.endereco-cob   = int_ds_cliente.endereco
              emitente.bairro-cob     = SUBSTRING(int_ds_cliente.bairro,1,30)   
              emitente.cidade-cob     = /*int_ds_cliente.cidade*/ c-cidade   
              emitente.estado-cob     = int_ds_cliente.estado   
              emitente.cep-cob        = int_ds_cliente.cep      
              emitente.pais-cob       = int_ds_cliente.pais 
              emitente.cgc-cob        = emitente.cgc-cob 
              emitente.ins-estadual   = c-ins-estadual
              emitente.ins-est-cob    = c-ins-estadual
              int_ds_cliente.situacao = 2. /* Integrado */

       FIND FIRST loc-entr WHERE
                  loc-entr.nome-abrev  = int_ds_cliente.nome_abrev AND 
                  loc-entr.cod-entrega = "Padr∆o" NO-ERROR.
       IF NOT AVAIL loc-entr THEN DO:
          CREATE loc-entr.
          ASSIGN loc-entr.nome-abrev  = int_ds_cliente.nome_abrev  
                 loc-entr.cod-entrega = "Padr∆o".            
       END.
       ASSIGN loc-entr.endereco     = int_ds_cliente.endereco
              loc-entr.bairro       = SUBSTRING(int_ds_cliente.bairro,1,30)
              loc-entr.cidade       = /*int_ds_cliente.cidade*/ c-cidade
              loc-entr.estado       = int_ds_cliente.estado
              loc-entr.pais         = int_ds_cliente.pais
              loc-entr.cep          = int_ds_cliente.cep
              loc-entr.ins-estadual = c-ins-estadual
              loc-entr.cgc          = int_ds_cliente.cgc.

       RUN intprg/int999.p (INPUT "CLI", 
                            INPUT STRING(emitente.cgc),
                            INPUT "Cliente integrado com sucesso - CPF/CNPJ: " + string(emitente.cgc) + ".Origem: " + c-sistema-orig + ".",
                            INPUT 2, /* 2 - Integrado */
                            INPUT c-seg-usuario,
                            INPUT "int004.p").

       /************* Integracao 2.00 X 5.00 *****************/
       IF  can-find(funcao where funcao.cd-funcao = "adm-cdc-ems-5.00"
       and funcao.ativo = yes
       and funcao.log-1 = yes) then do:
           find first param-global NO-LOCK no-error.
           if  param-global.log-2 = yes THEN DO: 
               validate emitente no-error.
               run cdp/cd1608.p (input emitente.cod-emitente,
                                 input emitente.cod-emitente,
                                 input emitente.identific,
                                 input yes,
                                 input 1,
                                 input 0,
                                 input "",
                                 input "Arquivo",
                                 input "").
           END.
       end.  
       /*********** Fim Integracao 2.00 X 5.00 ****************/        
    END.

    RELEASE emitente.
END.

RUN intprg/int888.p (INPUT "CLI",
                     INPUT "int004.p").

RETURN "OK".                                                                                                                             

