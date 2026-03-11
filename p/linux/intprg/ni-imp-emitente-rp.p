/*********************************************************************************
**
**  Programa - NI-IMP-EMITENTE-RP.P - Importaá∆o Emitentes (Cliente e Fornecedor)
**
*********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-EMITENTE-RP 2.00.00.000 } 

disable triggers for load of emitente.
disable triggers for load of loc-entr.
disable triggers for load of dist-emitente.

DEF BUFFER b-emitente FOR emitente.

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
    FIELD chave     AS CHAR FORMAT "x(50)"
    FIELD desc-erro AS CHAR FORMAT "x(50)".

DEF TEMP-TABLE tt-emitente
    FIELD nome-abrev               like emitente.nome-abrev       
    FIELD cnpj-cpf                 like emitente.cgc              
    FIELD identific                like emitente.identific        
    FIELD natureza                 like emitente.natureza         
    FIELD endereco                 like emitente.endereco         
    FIELD bairro                   like emitente.bairro          
    FIELD cidade                   like emitente.cidade           
    FIELD estado                   like emitente.estado           
    FIELD cep                      like emitente.cep              
    FIELD caixa-postal             like emitente.caixa-postal     
    FIELD pais                     like emitente.pais             
    FIELD insc-estadual            like emitente.ins-estadual     
    FIELD taxa-financ              like emitente.taxa-financ      
    FIELD data-taxa-financ         AS CHAR FORMAT "x(8)"        
    FIELD cod-transp-pad           like emitente.cod-transp       
    FIELD cod-gr-fornec            like emitente.cod-gr-forn      
    FIELD linha-produto            like emitente.linha-produt     
    FIELD ramo-atividade           like emitente.atividade        
    FIELD telefax                  like emitente.telefax          
    FIELD ramal-telefax            like emitente.ramal-fax        
    FIELD telex                    like emitente.telex            
    FIELD data-implant             AS CHAR FORMAT "x(8)"     
    FIELD compras-periodo          LIKE emitente.compr-period   
    FIELD contribuinte-ICMS        AS INTEGER     
    FIELD categoria                like emitente.categoria        
    FIELD cod-repres               like emitente.cod-rep          
    FIELD bonificacao              like emitente.bonificacao      
    FIELD abr-aval-credito         like emitente.ind-abrange-aval 
    FIELD grupo-cli                like emitente.cod-gr-cli       
    FIELD limite-credito           like emitente.lim-credito      
    FIELD data-limite-credito      AS CHAR FORMAT "x(8)"      
    FIELD perc-max-fat-per         like emitente.perc-fat-ped     
    FIELD portador                 like emitente.portador         
    FIELD modalidade               like emitente.modalidade       
    FIELD ac-fat-parc              AS INTEGER      
    FIELD ind-credito              like emitente.ind-cre-cli      
    FIELD aval-cr-aprov-ped        AS INTEGER     
    FIELD natur-oper               like emitente.nat-operacao     
    FIELD observacao-1             like emitente.observacoes      
    FIELD perc-min-fat-parc        like emitente.per-minfat       
    FIELD meio-emiss-ped-compra    like emitente.emissao-ped      
    FIELD nome-fantasia-matriz-cli like emitente.nome-matriz      
    FIELD telefone-modem           like emitente.telef-modem      
    FIELD ramal-modem              like emitente.ramal-modem      
    FIELD telefax-1                like emitente.telef-fac        
    FIELD ramal-telefax-1          like emitente.ramal-fac        
    FIELD ag-cli-forn              like emitente.agencia          
    FIELD nr-titulos               like emitente.nr-titulo        
    FIELD nr-dias                  LIKE emitente.nr-dias      
    FIELD perc-max-can-aberto      like emitente.per-max-canc     
    FIELD dt-ult-nf-emitida        like emitente.dt-ult-venda     
    FIELD emite-bloqueto-tit       AS INTEGER       
    FIELD emite-etiq-corresp       as integer      
    FIELD val-receb                like emitente.tr-ar-valor      
    FIELD gera-aviso-deb           AS INTEGER          
    FIELD port-prefer              like emitente.port-prefer      
    FIELD modal-prefer             like emitente.mod-prefer       
    FIELD bx-nao-acatada           like emitente.bx-acatada       
    FIELD cc-cli-for               like emitente.conta-corren     
    FIELD digito-cc-cli-for        AS   CHAR
    FIELD cond-pagto               like emitente.cod-cond-pag    
    FIELD nr-copias-ped-compra     LIKE emitente.nr-copias-ped 
    FIELD cod-suframa              like emitente.cod-suframa     
    FIELD cod-cacex                like emitente.cod-cacex       
    FIELD gera-dif-preco           like emitente.gera-difer      
    FIELD tab-preco                like emitente.nr-tabpre       
    FIELD ind-aval                 like emitente.ind-aval        
    FIELD usu-lib-credito          like emitente.user-libcre     
    FIELD vencto-domingo           like emitente.ven-domingo     
    FIELD vencto-sabado            like emitente.ven-sabado      
    FIELD cnpj-cobr                like emitente.cgc-cob         
    FIELD cep-cobr                 like emitente.cep-cob         
    FIELD uf-cobr                  like emitente.estado-cob      
    FIELD cidade-cobr              like emitente.cidade-cob      
    FIELD bairro-cobr              like emitente.bairro-cob      
    FIELD end-cobr                 like emitente.endereco-cob    
    FIELD cx-postal-cobr           like emitente.cx-post-cob     
    FIELD insc-estadual-cobr       like emitente.ins-est-cob     
    FIELD banco-cli-for            like emitente.cod-banco       
    FIELD prox-aviso-deb           like emitente.prox-ad         
    FIELD tp-registro              AS   INT
    FIELD vencto-feriado           like emitente.ven-feriado      
    FIELD tp-pagto                 like emitente.tp-pagto         
    FIELD tp-cobr-desp             like emitente.tip-cob-desp     
    FIELD insc-municipal           like emitente.ins-municipal    
    FIELD tp-desp-padr             like emitente.tp-desp-padrao   
    FIELD tp-receita-padr          like emitente.tp-rec-padrao    
    FIELD cep-estrangeiro          AS   CHAR
    FIELD micro-regiao             like emitente.nome-mic-reg     
    FIELD telefone-1               like emitente.telefone[1]      
    FIELD telefone-2               like emitente.telefone[2]      
    FIELD nr-mes-inat              like emitente.nr-mesina        
    FIELD inst-bancaria-1          like emitente.ins-banc[1]      
    FIELD inst-bancaria-2          like emitente.ins-banc[2]      
    FIELD nat-interestadual        like emitente.nat-ope-ext      
    FIELD cod-emitente             like emitente.cod-emitente     
    FIELD cod-emitente-cobr        like emitente.end-cobranca     
    FIELD util-verba-public        AS CHAR    
    FIELD perc-verba-public        like emitente.percent-verba    
    FIELD e-mail                   like emitente.e-mail           
    FIELD ind-aval-embarque        like emitente.ind-aval-embarque
    FIELD canal-venda              like emitente.cod-canal-venda  
    FIELD end-cobr-completo        like emitente.endereco-cob-text
    FIELD end-completo             like emitente.endereco_text    
    FIELD pais-cobranca            like emitente.pais-cob         
    FIELD sit-fornecedor           like emitente.ind-sit-emitente 
    FIELD data-vig-inicial         AS CHAR FORMAT "x(8)"
    FIELD data-vig-final           AS CHAR FORMAT "x(8)"
    FIELD insc-INSS                like emitente.cod-inscr-inss    
    FIELD tributa-COFINS           like emitente.idi-tributac-cofins 
    FIELD tributa-PIS              like emitente.idi-tributac-pis    
    FIELD contr-val-max-INSS       AS CHAR
    FIELD calc-PIS-COFINS-unidade  AS CHAR
    FIELD retem-pagto              AS CHAR         
    FIELD portador-fornec          like emitente.portador-ap         
    FIELD modal-fornec             like emitente.modalidade-ap       
    FIELD contr-subst-intermed     AS CHAR
    FIELD nome-emitente            like emitente.nome-emit.           

def temp-table tt-aux
    field cod-emitente like tt-emitente.cod-emitente
    field nome-abrev   as char format "x(12)"
    index nome nome-abrev
    index codigo cod-emitente.

DEF VAR i-dia AS INT FORMAT "99"   NO-UNDO.
DEF VAR i-mes AS INT FORMAT "99"   NO-UNDO.
DEF VAR i-ano AS INT FORMAT "9999" NO-UNDO.
DEF VAR h-acomp AS HANDLE          NO-UNDO.
def var i-cont-emit as int format ">>>,>>>,>>9".
def new global shared var i-ep-codigo-usuario as char no-undo.

def var c-nome-abrev as char format "x(12)" no-undo.
DEF VAR l-erro AS LOGICAL INIT NO NO-UNDO.
def var c-dig-cgc as char no-undo.
def var i-digito    as integer  no-undo.
def var i-digito1   as integer  no-undo.
def var i-digito2   as integer  no-undo.
def var i-nr-digito as integer  no-undo.
def var de-soma     as decimal  no-undo.
def var de-total    as decimal  no-undo.
def var i-multiplic as integer  no-undo.
def var i-result    as integer  no-undo.
def var c-cgc       as char     no-undo.
def var de-result   as decimal  no-undo.
DEF VAR c-cgc-cli   LIKE emitente.cgc NO-UNDO.
DEF VAR i-cont      AS INT NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

FIND FIRST param-global NO-LOCK NO-ERROR.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importaá∆o Emitentes").

EMPTY TEMP-TABLE tt-emitente.
EMPTY TEMP-TABLE tt-erro.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".

assign i-cont-emit = 0.
 
REPEAT:  
   CREATE tt-emitente.
   IMPORT DELIMITER ";" tt-emitente.  

   assign i-cont-emit = i-cont-emit + 1.

   run pi-acompanhar in h-acomp (input "Criando tt-emitente: " + string(tt-emitente.cod-emitente) + " - " + string(i-cont-emit)).

END. 
    
INPUT CLOSE.

assign i-cont-emit = 0.

FOR EACH tt-emitente:
  
    find first emitente where
               emitente.cod-emitente = tt-emitente.cod-emitente no-error.
    if avail emitente then
       delete emitente.
  
    find first emitente where
               emitente.nome-abrev = tt-emitente.nome-abrev no-error.
    if avail emitente then
       delete emitente.

    FOR EACH loc-entr use-index ch-entrega WHERE
             loc-entr.nome-abrev  = tt-emitente.nome-abrev:
        DELETE loc-entr.
    END.

    FOR EACH dist-emitente WHERE
             dist-emitente.cod-emitente = tt-emitente.cod-emitente:
        DELETE dist-emitente.
    END.

    assign i-cont-emit = i-cont-emit + 1.

    run pi-acompanhar in h-acomp (input "Validando duplicados: " + string(tt-emitente.cod-emitente) + " - " + string(i-cont-emit)).

    assign c-nome-abrev           = substr(tt-emitente.nome-abrev,1,12)
           tt-emitente.nome-abrev = c-nome-abrev.    

end.       

assign i-cont-emit = 0.

empty temp-table tt-aux.

/*for each tt-emitente:
  
    assign i-cont-emit = i-cont-emit + 1.
  
    run pi-acompanhar in h-acomp (input "Validando nome-abrev/codigo: " + string(tt-emitente.cod-emitente) +  " - " + string(i-cont-emit)).
  
    find first tt-aux where
               tt-aux.nome-abrev = tt-emitente.nome-abrev no-error.
    if not avail tt-aux then do:
       create tt-aux.
       assign tt-aux.nome-abrev = tt-emitente.nome-abrev.
    end.
    else do:
       CREATE tt-erro.
       ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev)
              tt-erro.desc-erro = "Nome Abreviado j† cadastrado".
     end.
     
    find first tt-aux where
               tt-aux.cod-emitente = tt-emitente.cod-emitente no-error.
    if not avail tt-aux then do:
       create tt-aux.
       assign tt-aux.cod-emitente = tt-emitente.cod-emitente.
    end.
    else do:
       CREATE tt-erro.
       ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev)
              tt-erro.desc-erro = "C¢digo Emitente j† cadastrado".
     end.
     
     
end.*/

FOR EACH tt-emitente:
                           
   if tt-emitente.cod-emitente = 0 then
      next.
      
   if tt-emitente.nome-abrev = "" then
      next.
     
    assign i-cont-emit = i-cont-emit + 1.

    run pi-acompanhar in h-acomp (input "Importando Emitente: " + string(tt-emitente.cod-emitente) +  " - " + string(i-cont-emit)).

    /*FIND FIRST mgcad.pais WHERE 
               pais.nome-pais = tt-emitente.pais NO-LOCK NO-ERROR.
    IF NOT AVAIL pais THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.chave     = STRING(tt-emitente.pais)
              tt-erro.desc-erro = "Pa°s n∆o cadastrado".
       NEXT.
    END.

    find FIRST unid-feder
         where unid-feder.pais   = tt-emitente.pais
           and unid-feder.estado = tt-emitente.estado no-lock no-error.
    if not avail unid-feder then do:   
       CREATE tt-erro.
       ASSIGN tt-erro.chave     = STRING(tt-emitente.pais) + "/" + STRING(tt-emitente.estado)
              tt-erro.desc-erro = "Estado n∆o cadastrado para o Pa°s".
       NEXT.
    end.            

    FIND FIRST transporte WHERE
               transporte.cod-transp = tt-emitente.cod-transp NO-LOCK NO-ERROR.
    IF NOT AVAIL transporte THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.chave     = STRING(tt-emitente.cod-transp)
              tt-erro.desc-erro = "Transportador n∆o cadastrado".
       NEXT.
    END.

    if tt-emitente.identific = 1 then do:

        FIND FIRST repres WHERE
                   repres.cod-rep = tt-emitente.cod-rep NO-LOCK NO-ERROR.
        IF NOT AVAIL repres THEN DO:
           CREATE tt-erro.
           ASSIGN tt-erro.chave     = STRING(tt-emitente.cod-rep)
                  tt-erro.desc-erro = "Representante n∆o cadastrado".
           NEXT.
        END.
    
        find first mgcad.portador no-lock
             where portador.ep-codigo    = i-ep-codigo-usuario
             AND   portador.cod-portador = tt-emitente.portador
             and   portador.modalidade   = tt-emitente.modalidade no-error.
        IF NOT AVAIL portador THEN DO:
           CREATE tt-erro.
           ASSIGN tt-erro.chave     = STRING(tt-emitente.portador) + "/" + STRING(tt-emitente.modalidade)
                  tt-erro.desc-erro = "Portador n∆o cadastrado".
           NEXT.
        END.
    
        FIND FIRST cond-pagto where 
                   cond-pagto.cod-cond-pag = tt-emitente.cond-pag NO-LOCK NO-ERROR.
        IF NOT AVAIL cond-pagto THEN DO:
           CREATE tt-erro.
           ASSIGN tt-erro.chave     = STRING(tt-emitente.cond-pag)
                  tt-erro.desc-erro = "Condiá∆o de Pagamento n∆o cadastrada".
           NEXT.
        END.
    end.
    
    FIND FIRST emitente WHERE
               emitente.cod-emitente = tt-emitente.cod-emitente NO-ERROR.
    IF AVAIL emitente THEN DO:
       DELETE emitente VALIDATE(TRUE,"").
    END.*/

    ASSIGN l-erro = NO.

    find first b-emitente where
               b-emitente.cod-emitente = tt-emitente.cod-emitente no-lock no-error.
    IF AVAIL b-emitente THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev)
              tt-erro.desc-erro = "Emitente j† cadastrado"
              l-erro            = YES.
    END.

    find first b-emitente where
               b-emitente.nome-abrev = tt-emitente.nome-abrev no-lock no-error.
    IF AVAIL b-emitente THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev)
              tt-erro.desc-erro = "Nome Abreviado j† cadastrado"
              l-erro            = YES.
    END.

    IF tt-emitente.pais <> "Convenio" THEN DO:

       if  (tt-emitente.cnpj-cpf = "" OR tt-emitente.cnpj-cpf = ?) 
       AND tt-emitente.natureza < 3 then do:
           if param-global.bloqueio-cgc = 3 
           OR param-global.id-federal-obrigatorio = yes then do:
              CREATE tt-erro.
              ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                     tt-erro.desc-erro = "CNPJ/CPF deve ser informado"
                     l-erro            = YES.
           END.
       END.

       if  DEC(tt-emitente.cnpj-cpf) = 0 
       AND tt-emitente.natureza < 3 then do:
           if  param-global.bloqueio-cgc = 3 then do:
               CREATE tt-erro.
               ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                      tt-erro.desc-erro = "CNPJ/CPF deve conter d°gitos numÇricos"
                      l-erro            = YES.
           end.
           else do:
               if  param-global.bloqueio-cgc = 2 then do:            
                   CREATE tt-erro.
                   ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                          tt-erro.desc-erro = "CNPJ/CPF inv†lido"
                          l-erro            = YES.
               end.                                                  
           end.
       END.

       if  tt-emitente.cnpj-cpf <> "" 
       and tt-emitente.cnpj-cpf <> ? then do:
           assign c-cgc = "".
           do  i-cont = 1 to 18:
               if  can-do("0,1,2,3,4,5,6,7,8,9", substr(tt-emitente.cnpj-cpf,i-cont,1)) then do:
                   assign c-cgc     = c-cgc + substr(tt-emitente.cnpj-cpf,i-cont,1)
                          c-dig-cgc = c-cgc.
               end.
           end.
       END.

       find first b-emitente where b-emitente.cgc = c-cgc NO-LOCK no-error.

       if  avail b-emitente and param-global.bloqueio-cgc = 3 then do:
           CREATE tt-erro.
           ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                  tt-erro.desc-erro = "CNPJ/CPF j† existe para o Cliente/Fornecedor"
                  l-erro            = YES.
       end.            
       else DO:          
            if  right-trim(substr(tt-emitente.cnpj-cpf,1,1)) = "" then do:
                CREATE tt-erro.
                ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                       tt-erro.desc-erro = "Primeira posiá∆o do CNPJ/CPF igual a branco"
                       l-erro            = YES.
            end.
            else do:
                if  param-global.bloqueio-cgc <> 1 then do:                         
                    if  tt-emitente.natureza = 2 then do :                                                    
                        assign c-cgc = fill("0",20 - length(c-cgc)) + c-cgc
                               c-cgc = "00" + substr(c-cgc,1,18).

                        assign i-multiplic = 1.
                        do  i-cont = 1 to 18:
                            assign i-multiplic = i-multiplic + 1.
                            if  i-multiplic > 9 then i-multiplic = 2.
                            assign de-result = dec(substr(c-cgc,21 - i-cont ,1)) * i-multiplic
                                   de-soma   = de-soma + de-result.
                        end.

                        assign i-digito1 = de-soma - (truncate(de-soma / 11,0) * 11)
                               i-digito1   = if   i-digito1 < 2 then 0
                                             else 11 - (de-soma - (truncate(de-soma / 11,0) * 11))
                               c-cgc       = string(dec(c-cgc),"9999999999999999999")
                                           + string(i-digito1)
                               de-soma     = 0
                               de-result   = 0
                               i-multiplic = 1.

                        do  i-cont = 1 to 19:
                            assign i-multiplic = i-multiplic + 1.
                            if  i-multiplic > 9 then i-multiplic = 2.
                            assign de-result = dec(substr(c-cgc,21 - i-cont,1)) * i-multiplic
                                   de-soma   = de-soma + de-result.
                        end.

                        assign i-digito2   = 11 - (de-soma - (truncate(de-soma / 11,0) * 11))
                               i-digito2   = if  i-digito2 > 9 then 0
                                             else i-digito2
                               i-digito    = i-digito1 * 10 + i-digito2
                               de-soma     = 0.

                        if  param-global.bloqueio-cgc = 2 then do:
                            if  int(substring(c-cgc-cli,13,2)) <> i-digito then do:
                                CREATE tt-erro.
                                ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                                       tt-erro.desc-erro = "D°gito verificador incorreto"
                                       l-erro            = YES.
                            end.           
                        end.
                        else do:
                           if  int(substring(c-dig-cgc,13,2)) <> i-digito then do:
                               CREATE tt-erro.
                               ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                                      tt-erro.desc-erro = "D°gito verificador incorreto"
                                      l-erro            = YES.
                           end. 
                        end.       
                    end.

                    if tt-emitente.natureza = 1 then do:

                       do  i-nr-digito = 1 to 2 : /*faz o calculo para os dois digitos*/
        
                           assign de-total = 0.
         
                           /* se estiver calculando o primeiro digito comeca a multiplicar por 5 
                              senao por 6*/ 
            
                           assign i-multiplic = if  i-nr-digito = 1 THEN 10 ELSE 11.
         
                           do  i-cont = 1 to 9:
        
                               /* Pega as posicoes do cgc (uma a uma sem o digito e multiplica pelo numero correspondente*/
            
                               assign de-soma = dec(substring(c-cgc,i-cont,1)) * i-multiplic.
         
                               i-multiplic = i-multiplic - 1.
               
                               assign de-total = de-total + de-soma.
            
                               if  i-nr-digito = 2 and i-cont = 9 then do:
                                   assign de-total = de-total + (i-digito1 * i-multiplic).
                               end.     
                  
                           end.
         
                           assign i-result = (de-total - (truncate(de-total / 11,0) * 11)).
         
                           if  i-nr-digito = 1 then do:
                               if i-result < 2 then 
                                  assign i-digito1 = 0.
                               else 
                                  assign i-digito1 = 11 - i-result.
                           end.
                           else do:
                               assign i-digito2 =   11 - i-result
                                      i-digito2 =  if   i-digito2 > 9 then 0 else i-digito2.                                 
             
                           end.     
                       end.
      
                       assign i-digito= i-digito1 * 10 + i-digito2
                              de-soma     = 0
                              de-result   = 0
                              i-multiplic = 1.

                      if param-global.bloqueio-cgc = 2 then do:
                         if int(substring(c-cgc-cli,10,2)) <> i-digito then do:  
                            CREATE tt-erro.
                            ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                                   tt-erro.desc-erro = "D°gito verificador incorreto"
                                   l-erro            = YES.
                         end.         
                      end.
                      else DO:                                         
                             if int(substring(c-dig-cgc,10,2)) <> i-digito then do:
                             CREATE tt-erro.
                             ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                                    tt-erro.desc-erro = "D°gito verificador incorreto"
                                    l-erro            = YES.
                          end.    
                      END.
                    end.        
                end.                                           
                else do:                                         
                    if  tt-emitente.natureza <> 3
                    and tt-emitente.natureza <> 4 
                    and param-global.bloqueio-cgc = 3 then do:                                            
                        CREATE tt-erro.
                        ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                               tt-erro.desc-erro = "Emitente n∆o pode ter CNPJ/CPF desconhecido"
                               l-erro            = YES.
                    end. 
                    else do:                                      
                        CREATE tt-erro.
                        ASSIGN tt-erro.chave     = string(tt-emitente.cod-emitente) + "/" + STRING(tt-emitente.nome-abrev) + "/" + STRING(tt-emitente.cnpj-cpf)
                               tt-erro.desc-erro = "Emitente n∆o pode ter CNPJ/CPF desconhecido"
                               l-erro            = YES.
                    end.
                end.
            end.                                
       END.
    END.

    IF  l-erro = NO THEN DO:
        CREATE emitente.
        ASSIGN emitente.nome-abrev       = substr(tt-emitente.nome-abrev,1,12)              
               emitente.cgc              = tt-emitente.cnpj-cpf                
               emitente.identific        = tt-emitente.identific               
               emitente.natureza         = tt-emitente.natureza                
               emitente.endereco         = substr(tt-emitente.endereco,1,40)                
               emitente.bairro           = substr(tt-emitente.bairro,1,30)                  
               emitente.cidade           = substr(tt-emitente.cidade,1,25)                  
               emitente.estado           = tt-emitente.estado                  
               emitente.cep              = tt-emitente.cep                     
               emitente.caixa-postal     = tt-emitente.caixa-postal            
               emitente.pais             = substr(tt-emitente.pais,1,20)                    
               emitente.ins-estadual     = tt-emitente.insc-estadual           
               emitente.taxa-financ      = tt-emitente.taxa-financ.
               
        if tt-emitente.data-taxa-financ <> "" then do:
           assign i-mes = int(substr(tt-emitente.data-taxa-financ,3,2))
                  i-dia = int(substr(tt-emitente.data-taxa-financ,1,2))
                  i-ano = int(substr(tt-emitente.data-taxa-financ,5,4)).
                  emitente.data-taxa = date(i-mes,i-dia,i-ano).
        end.                           
               
        assign emitente.cod-transp       = tt-emitente.cod-transp-pad          
               emitente.cod-gr-forn      = tt-emitente.cod-gr-fornec           
               emitente.linha-produt     = tt-emitente.linha-produto           
               emitente.atividade        = tt-emitente.ramo-atividade          
               emitente.telefax          = tt-emitente.telefax                 
               emitente.ramal-fax        = tt-emitente.ramal-telefax           
               emitente.telex            = tt-emitente.telex.
               
        if tt-emitente.data-implant <> "" then do :
           assign i-mes = int(substr(tt-emitente.data-implant,3,2))
                  i-dia = int(substr(tt-emitente.data-implant,1,2))
                  i-ano = int(substr(tt-emitente.data-implant,5,4)).
                  emitente.data-implant = date(i-mes,i-dia,i-ano).
        end.                           
               
        assign emitente.compr-period     = tt-emitente.compras-periodo         
               emitente.contrib-icms     = if tt-emitente.contribuinte-ICMS = 1 then yes else no       
               emitente.categoria        = tt-emitente.categoria               
               emitente.cod-rep          = tt-emitente.cod-repres              
               emitente.bonificacao      = tt-emitente.bonificacao             
               emitente.ind-abrange-aval = tt-emitente.abr-aval-credito        
               emitente.cod-gr-cli       = tt-emitente.grupo-cli               
               emitente.lim-credito      = tt-emitente.limite-credito.
               
        if tt-emitente.data-limite-credito <> "" then do :
           assign i-mes = int(substr(tt-emitente.data-limite-credito,3,2))
                  i-dia = int(substr(tt-emitente.data-limite-credito,1,2))
                  i-ano = int(substr(tt-emitente.data-limite-credito,5,4)).
                  emitente.dt-lim-cred = date(i-mes,i-dia,i-ano).
        end.                           
               
        assign emitente.perc-fat-ped     = tt-emitente.perc-max-fat-per        
               emitente.portador         = tt-emitente.portador                
               emitente.modalidade       = tt-emitente.modalidade              
               emitente.ind-fat-par      = if tt-emitente.ac-fat-parc = 1 then yes else no             
               emitente.ind-cre-cli      = tt-emitente.ind-credito             
               emitente.ind-apr-cred     = if tt-emitente.aval-cr-aprov-ped = 1 then yes else no      
               emitente.nat-operacao     = tt-emitente.natur-oper              
               emitente.observacoes      = substr(tt-emitente.observacao-1,1,2000)            
               emitente.per-minfat       = tt-emitente.perc-min-fat-parc       
               emitente.emissao-ped      = tt-emitente.meio-emiss-ped-compra   
               emitente.nome-matriz      = tt-emitente.nome-fantasia-matriz-cli
               emitente.telef-modem      = tt-emitente.telefone-modem          
               emitente.ramal-modem      = tt-emitente.ramal-modem             
               emitente.telef-fac        = tt-emitente.telefax-1               
               emitente.ramal-fac        = tt-emitente.ramal-telefax-1         
               emitente.agencia          = tt-emitente.ag-cli-forn             
               emitente.nr-titulo        = tt-emitente.nr-titulos              
               emitente.nr-dias          = tt-emitente.nr-dias                 
               emitente.per-max-canc     = tt-emitente.perc-max-can-aberto     
               emitente.dt-ult-venda     = tt-emitente.dt-ult-nf-emitida       
               emitente.emite-bloq       = if tt-emitente.emite-bloqueto-tit = 1 then yes else no      
               emitente.emite-etiq       = if tt-emitente.emite-etiq-corresp = 1 then yes else no 
               emitente.tr-ar-valor      = tt-emitente.val-receb               
               emitente.gera-ad          = if tt-emitente.gera-aviso-deb = 1 then yes else no          
               emitente.port-prefer      = tt-emitente.port-prefer             
               emitente.mod-prefer       = tt-emitente.modal-prefer            
               emitente.bx-acatada       = tt-emitente.bx-nao-acatada          
               emitente.conta-corren     = tt-emitente.cc-cli-for              
               /*emitente. = tt-emitente.digito-cc-cli-for       */
               emitente.cod-cond-pag     = tt-emitente.cond-pagto              
               emitente.nr-copias-ped    = tt-emitente.nr-copias-ped-compra    
               emitente.cod-suframa      = tt-emitente.cod-suframa             
               emitente.cod-cacex        = tt-emitente.cod-cacex               
               emitente.gera-difer       = tt-emitente.gera-dif-preco          
               emitente.nr-tabpre        = tt-emitente.tab-preco               
               emitente.ind-aval         = tt-emitente.ind-aval                
               emitente.user-libcre      = tt-emitente.usu-lib-credito         
               emitente.ven-domingo      = tt-emitente.vencto-domingo          
               emitente.ven-sabado       = tt-emitente.vencto-sabado           
               emitente.cgc-cob          = tt-emitente.cnpj-cobr               
               emitente.cep-cob          = tt-emitente.cep-cobr                
               emitente.estado-cob       = tt-emitente.uf-cobr                 
               emitente.cidade-cob       = tt-emitente.cidade-cobr             
               emitente.bairro-cob       = tt-emitente.bairro-cobr             
               emitente.endereco-cob     = tt-emitente.end-cobr                
               emitente.cx-post-cob      = tt-emitente.cx-postal-cobr          
               emitente.ins-est-cob      = tt-emitente.insc-estadual-cobr      
               emitente.cod-banco        = tt-emitente.banco-cli-for           
               emitente.prox-ad          = tt-emitente.prox-aviso-deb          
               /*emitente. = tt-emitente.tp-registro*/             
               emitente.ven-feriado      = tt-emitente.vencto-feriado          
               emitente.tp-pagto         = tt-emitente.tp-pagto                
               emitente.tip-cob-desp     = tt-emitente.tp-cobr-desp            
               emitente.ins-municipal    = tt-emitente.insc-municipal          
               emitente.tp-desp-padrao   = tt-emitente.tp-desp-padr            
               emitente.tp-rec-padrao    = tt-emitente.tp-receita-padr         
               /*emitente. = tt-emitente.cep-estrangeiro*/        
               emitente.nome-mic-reg     = tt-emitente.micro-regiao            
               emitente.telefone[1]      = tt-emitente.telefone-1              
               emitente.telefone[2]      = tt-emitente.telefone-2              
               emitente.nr-mesina        = tt-emitente.nr-mes-inat             
               emitente.ins-banc[1]      = tt-emitente.inst-bancaria-1         
               emitente.ins-banc[2]      = tt-emitente.inst-bancaria-2         
               emitente.nat-ope-ext      = tt-emitente.nat-interestadual       
               emitente.cod-emitente     = tt-emitente.cod-emitente            
               emitente.end-cobranca     = tt-emitente.cod-emitente-cobr
               emitente.utiliza-verba    = if tt-emitente.util-verba-public = "S" then yes else no      
               emitente.percent-verba    = tt-emitente.perc-verba-public       
               emitente.e-mail           = tt-emitente.e-mail                  
               emitente.ind-aval-embarque = tt-emitente.ind-aval-embarque       
               emitente.cod-canal-venda   = tt-emitente.canal-venda             
               emitente.endereco-cob-text = tt-emitente.end-cobr-completo       
               emitente.endereco_text     = tt-emitente.end-completo            
               emitente.pais-cob          = tt-emitente.pais-cobranca           
               emitente.ind-sit-emitente  = tt-emitente.sit-fornecedor          
               emitente.cod-inscr-inss    = tt-emitente.insc-INSS     
               emitente.cod-entrega       = "Padr∆o"
               emitente.idi-tributac-cofins = tt-emitente.tributa-COFINS          
               emitente.idi-tributac-pis    = tt-emitente.tributa-PIS             
               emitente.log-controla-val-max-inss = if tt-emitente.contr-val-max-INSS = "S" then yes else no
               emitente.log-calcula-pis-cofins-unid = if tt-emitente.calc-PIS-COFINS-unidade = "S" then yes else no
               emitente.retem-pagto         = if tt-emitente.retem-pagto = "S" then yes else no             
               emitente.portador-ap         = tt-emitente.portador-fornec         
               emitente.modalidade-ap       = tt-emitente.modal-fornec            
               emitente.log-contribt-subst-interm = if tt-emitente.contr-subst-intermed = "S" then yes else no    
               emitente.nome-emit           = substr(tt-emitente.nome-emitente,1,80).       
    
        if emitente.identific <> 2 then do:
           create loc-entr.   
           assign loc-entr.nome-abrev   = emitente.nome-abrev
                  loc-entr.cod-entrega  = "Padr∆o"
                  loc-entr.endereco     = emitente.endereco
                  loc-entr.bairro       = emitente.bairro
                  loc-entr.cidade       = emitente.cidade
                  loc-entr.estado       = emitente.estado
                  loc-entr.cep          = emitente.cep
                  loc-entr.caixa-postal = emitente.caixa-postal
                  loc-entr.pais         = emitente.pais
                  loc-entr.cgc          = emitente.cgc
                  loc-entr.ins-estadual = emitente.ins-estadual
                  loc-entr.zip-code     = emitente.zip-code
                  loc-entr.e-mail       = emitente.e-mail.
        END.    
        
        if  tt-emitente.data-vig-inicial <> "" 
        and tt-emitente.data-vig-final   <> "" then do:            
            CREATE dist-emitente.
            ASSIGN dist-emitente.cod-emitente = emitente.cod-emitente.
        
            assign i-mes = int(substr(tt-emitente.data-vig-inicial,3,2))
                   i-dia = int(substr(tt-emitente.data-vig-inicial,1,2))
                   i-ano = int(substr(tt-emitente.data-vig-inicial,5,4)).
                   dist-emitente.dat-vigenc-inicial = date(i-mes,i-dia,i-ano).
                   
            assign i-mes = int(substr(tt-emitente.data-vig-final,3,2))
                   i-dia = int(substr(tt-emitente.data-vig-final,1,2))
                   i-ano = int(substr(tt-emitente.data-vig-final,5,4)).
                   dist-emitente.dat-vigenc-final = date(i-mes,i-dia,i-ano).                   
        end.                           
    end.
end.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importaá∆o de Emitentes (Cliente e Fornecedor)"
       c-programa     = "NI-IMP-EMITENTE-RP".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro:
    disp tt-erro.chave column-label "Chave"
         tt-erro.desc-erro column-label "Descriá∆o"
         with width 132 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}
