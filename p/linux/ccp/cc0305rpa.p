/*********************************************************************************/
/**  -------------------------------------------------------------------------  **/
/**                                                                             **/
/**  Funcionalidade: cc0305rpa.p - Emissor de Pedidos de Compra em PDF          **/
/**                                                                             **/
/**  Produto.......: ERP TOTVS 12 - Compras                                     **/
/**  Cliente.......: DROGARIA NISSEI                                            **/
/**  Solicitante...: ResultPro                                                  **/
/**                                                                             **/
/**  Fonte.........: cc0305rpa.p                                                **/
/**  Fun‡Æo........: ImpressÆo do Pedido de Compra                              **/
/**                                                                             **/
/**  Versäes.......: 2.00.00.001 -                                              **/
/**                                                                             **/
/*********************************************************************************/
{intprg/intpdf001.i01}

{utp/ut-glob.i}
{include/tt-edit.i}
{include/pi-edit.i}

&GLOBAL-DEFINE              TamLinha                011.00

DEFINE TEMP-TABLE           tt-empresa              NO-UNDO
       FIELD                linha                   AS   CHARACTER      EXTENT 07.

DEF TEMP-TABLE tt-pedido 
FIELD num-pedido   LIKE pedido-compr.num-pedido
FIELD cod-emitente LIKE pedido-compr.cod-emitente
FIELD natureza      AS CHAR
FIELD desc-frete    AS CHAR
FIELD desc-cond-pag AS CHAR EXTENT 2
FIELD cnpj-estab    LIKE estabelec.cgc
FIELD cnpj-emit     LIKE emitente.cgc
FIELD desc-contrato AS CHAR
FIELD tipo-compra   AS CHAR
FIELD nome-ass      AS CHAR EXTENT 2
FIELD cargo-ass     AS CHAR EXTENT 2
FIELD incoterm      AS CHAR
FIELD arquivo       AS CHAR
FIELD comprador     AS CHAR
FIELD contato       LIKE cotacao-item.contato
FIELD observacao    LIKE pedido-compr.comentarios
field vlr-frete     LIKE cotacao-item.valor-descto
INDEX ind-pedido 
      num-pedido    ASCENDING. 

     
DEF TEMP-TABLE tt-it-pedido
FIELD num-pedido   LIKE pedido-compr.num-pedido
FIELD cod-ean      LIKE ITEM.it-codigo
FIELD it-codigo    LIKE ordem-compra.it-codigo
FIELD descricao    LIKE item.desc-item     
field un           LIKE prazo-compra.un
field qtd-forn     LIKE prazo-compra.qtd-sal-forn
field preco-un     LIKE cotacao-item.valor-descto
field vlr-liquido  LIKE cotacao-item.valor-descto
field aliquota-ipi LIKE ordem-compra.aliquota-ipi
field vlr-ipi      LIKE cotacao-item.valor-descto
field vlr-st       LIKE cotacao-item.valor-descto
field vlr-total    LIKE cotacao-item.valor-descto
FIELD data-entrega LIKE prazo-compra.data-entrega.
   

DEFINE TEMP-TABLE tt-cond-pagto NO-UNDO 
FIELD num-pedido              AS   INTEGER 
FIELD descricao               AS   CHARACTER 
INDEX ind-condped
      num-pedido              ASCENDING 
      descricao               ASCENDING. 

DEFINE TEMP-TABLE           tt-texto                NO-UNDO 
       FIELD                sequencia               AS   INTEGER
       FIELD                texto                   AS   CHARACTER 
       INDEX                ind-texto 
                            sequencia               ASCENDING. 

DEFINE VARIABLE  c-linha            AS   CHARACTER   NO-UNDO.
DEFINE VARIABLE  c-campo            AS   CHARACTER   NO-UNDO.
DEFINE VARIABLE  c-letra            AS   CHARACTER   NO-UNDO.
DEFINE VARIABLE  c-palavra          AS   CHARACTER   NO-UNDO.
DEFINE VARIABLE  c-frase            AS   CHARACTER   NO-UNDO.
DEFINE VARIABLE  de-linha           AS   DECIMAL     NO-UNDO. 
DEFINE VARIABLE  de-lin-1           AS   DECIMAL     NO-UNDO. 
DEFINE VARIABLE  de-lin-2           AS   DECIMAL     NO-UNDO. 
DEFINE VARIABLE  de-box-linha       AS   DECIMAL     NO-UNDO. 
DEFINE VARIABLE  de-box-altura      AS   DECIMAL     NO-UNDO. 
DEFINE VARIABLE  de-box-alt-1       AS   DECIMAL     NO-UNDO. 
DEFINE VARIABLE  de-box-alt-2       AS   DECIMAL     NO-UNDO. 
DEFINE VARIABLE  de-box-ini         AS   DECIMAL     NO-UNDO. 
DEFINE VARIABLE  de-fol-up          AS   DECIMAL     NO-UNDO. 
DEFINE VARIABLE  de-calc            AS   DECIMAL     NO-UNDO. 
DEFINE VARIABLE  i-pagina           AS   INTEGER     NO-UNDO.
DEFINE VARIABLE  i-linha-aux        AS   INTEGER     NO-UNDO.
DEFINE VARIABLE  i-linha            AS   INTEGER     NO-UNDO.
DEFINE VARIABLE  i-cont             AS   INTEGER     NO-UNDO.
DEFINE VARIABLE  i-letra            AS   INTEGER     NO-UNDO. 
DEFINE VARIABLE  h-acomp            AS   HANDLE      NO-UNDO.
DEFINE VARIABLE  de-box-altura-1    AS   DECIMAL     NO-UNDO.
DEFINE VARIABLE  c-endereco         AS   CHAR        NO-UNDO.
DEFINE VARIABLE  c-nome-transp      AS   CHAR        NO-UNDO.
DEFINE VARIABLE  c-end-transp       AS   CHAR        NO-UNDO.
DEFINE VARIABLE  c-fone-transp      AS   CHAR        NO-UNDO.
DEFINE VARIABLE  c-cidade-transp    AS   CHAR        NO-UNDO.
DEFINE VARIABLE  c-contato-transp   AS   CHAR        NO-UNDO.
DEFINE VARIABLE  de-tot-vlr-liq   LIKE cotacao-item.valor-descto NO-UNDO. 
DEFINE VARIABLE  de-tot-vlr-ipi   LIKE cotacao-item.valor-descto NO-UNDO.
DEFINE VARIABLE  de-tot-vlr-st    LIKE cotacao-item.valor-descto NO-UNDO.
DEFINE VARIABLE  de-tot-vlr-total LIKE cotacao-item.valor-descto NO-UNDO.

DEFINE STREAM               s-pedido. 

DEFINE INPUT  PARAMETER     TABLE FOR tt-pedido. 
DEFINE INPUT  PARAMETER     TABLE FOR tt-cond-pagto. 
DEFINE INPUT  PARAMETER     TABLE FOR tt-it-pedido. 
 
find first mgcad.empresa no-lock where
           empresa.ep-codigo = i-ep-codigo-usuario no-error.

ASSIGN c-endereco = trim(empresa.endereco) + " " + trim(empresa.bairro).

CREATE tt-empresa.
ASSIGN tt-empresa.linha [1] = SUBSTRING(empresa.razao-social,1,36) 
       tt-empresa.linha [2] = substring(c-endereco, 1,40)
       tt-empresa.linha [3] = "CEP: "   + trim(empresa.cep) + " - " + trim(empresa.cidade) +  " - " + trim(empresa.uf)
       tt-empresa.linha [4] = "Fone: "  + trim(empresa.telefone[1])
       tt-empresa.linha [5] = "CNPJ: "  + trim(empresa.cgc)
       tt-empresa.linha [6] = "I.E.: "  + trim(empresa.inscr-estad)
       tt-empresa.linha [7] = "E-mail:" + TRIM(empresa.e-mail).    

FOR FIRST tt-empresa
    NO-LOCK: 
END.

FIND FIRST tt-pedido NO-ERROR.

FOR EACH  tt-pedido NO-LOCK,
    FIRST pedido-compr WHERE
          pedido-compr.num-pedido = tt-pedido.num-pedido ,
    FIRST emitente NO-LOCK WHERE
          emitente.cod-emitente = tt-pedido.cod-emitente:
   
    FIND FIRST transporte NO-LOCK
         WHERE transporte.cod-transp = pedido-compr.cod-transp    NO-ERROR.
    IF AVAIL transporte THEN
       ASSIGN c-nome-transp    = transporte.nome
              c-end-transp     = transporte.endereco
              c-fone-transp    = transporte.telefone
              c-cidade-transp  = transporte.cidade
              c-contato-transp = transporte.contato.
    ELSE
        ASSIGN c-nome-transp    = ""
               c-end-transp     = ""
               c-fone-transp    = ""
               c-cidade-transp  = ""
               c-contato-transp = "".

    ASSIGN i-pagina = 00. 


    /** Abrir Documento **/ 

    OUTPUT STREAM s-pedido TO VALUE (SESSION:TEMP-DIRECTORY + 'Pedido.txt').
    PUT    STREAM s-pedido ' ' SKIP.
    OUTPUT STREAM s-pedido CLOSE. 
    
    RUN pdf_new ('Pedido', tt-pedido.arquivo). 

    RUN pdf_load_font('Pedido', 'Times', SEARCH ('intprg\intpdf-arial.ttf':U), SEARCH ('intprg\intpdf-arial.afm':U), '').
    
    RUN pdf_load_image ('Pedido', 'Logotipo', SEARCH ('image/marca-nissei.jpg':U)). 
     
    RUN PI-Imprime-Cabecalho. 
    
    RUN PI-Imprime-Item.   
    
    /** FECHAR DOCUMENTO **/
    
    RUN pdf_close  ("Pedido").
    
    
               
END.

PROCEDURE PI-Imprime-Cabecalho:

    ASSIGN i-pagina = i-pagina + 01.

    RUN pdf_new_page2  ('Pedido',"LANDSCAPE"). 
    
    /** QUADRO 01 - PEDIDO / DATA / PAGINA **/ 

    RUN pdf_rect2         ('Pedido', 030.00, 574 , 750.00, 035.00, 0.50). 
    RUN pdf_place_image   ('Pedido', 'Logotipo', 035.00, 34.00, 180.00, 030.00).
    
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 12).

    RUN pdf_text_align  ('Pedido', 'PEDIDO DE COMPRA', 'Left'   , 395.00, 596.00).
    RUN pdf_text_align  ('Pedido', 'FARMµCIAS NISSEI', 'Left'   , 399.00, 585.00).
                                                     
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 14).
    RUN pdf_text_align  ('Pedido', 'Nro Pedido:  '    + TRIM (STRING (tt-pedido.num-pedido,  '>>>,>>>,>>9':U)) , 'Right'   , 775.00, 596.00).
    
    RUN pdf_set_font      ('Pedido', 'Times', 10).
    RUN pdf_text_align    ('Pedido', 'Data: ' + STRING (TODAY, '99/99/9999':U),'Right',740.00,585.00).
    RUN pdf_text_align    ('Pedido', 'P gina: ':U + TRIM (STRING (i-pagina, '>>>,>>>,>>9':U)) , 'Right'  , 790.00, 585.00).
     
    /*RUN pdf_rect2         ('Pedido', 030.00, 470.50 , 700.00, 030.00, 0.50).*/

    RUN pdf_line('Pedido',30 ,590,30 ,524,0.5).     /*  Linha Esquerda vertical   */
    
    RUN pdf_line('Pedido',780 ,590,780 ,524,0.5).     /*  Linha direita vertical   */

    RUN pdf_text_align    ('Pedido', tt-empresa.linha [2] + " " + tt-empresa.linha [3] , 'Left' , 40.00, 563.00).
    RUN pdf_text_align    ('Pedido', tt-empresa.linha [4] , 'Right' , 700, 563.00).
    RUN pdf_text_align    ('Pedido', tt-empresa.linha [5] + "  " + tt-empresa.linha [6], 'Left' , 40.00, 552.00).
    RUN pdf_text_align    ('Pedido', tt-empresa.linha [7] , 'Right' , 700.00, 552.00).

    RUN pdf_rect2        ('Pedido', 030.00, 447.50 , 750.00, 100.00, 0.50).
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Fornecedor:" , 'Left' , 35.00, 541.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', string(tt-pedido.cod-emitente) + "-" + substring(emitente.nome-emit,1,40) , 'Left' , 90.00, 541.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Comprador:" , 'Right' ,560.00, 541.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', string(tt-pedido.comprador), 'Right' , 625.00, 541.00).
      
    RUN pdf_set_font      ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align    ('Pedido', "Endere‡o:" , 'Left' ,35.00, 530.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', substring(emitente.endereco,1,40) , 'Left' , 90.00, 530.00).
   
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Condi‡Æo Pagto:" , 'Right' ,568.00, 530.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    
    FIND FIRST tt-cond-pagto WHERE 
               tt-cond-pagto.num-pedido = tt-pedido.num-pedido NO-ERROR.

    RUN pdf_text_align   ('Pedido', STRING (tt-cond-pagto.descricao , 'X(40)':U) , 'Right' , 670.00, 530.00).
    
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Cidade/CEP:" , 'Left' ,35.00, 519.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', emitente.cidade + "/" + STRING(emitente.cep) , 'Left' , 90.00, 519.00).
   
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Validade por: " , 'Right' ,568.00, 519.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', 'Conforme Itens' , 'Right' , 640.00, 519.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Estado:" , 'Left' ,35.00, 508.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', emitente.estado, 'Left' , 90.00, 508.00).  
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Contato:" , 'Left' ,110.00, 508.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', tt-pedido.contato, 'Left' , 150.00, 508.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Fone:" , 'Left' ,200.00, 508.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', STRING(emitente.telefone[1],"X(20)"), 'Left' , 230.00, 508.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Tipo de Pedido:" , 'Right' ,570.00, 508.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', "Bonificado", 'Right' , 626.00, 508.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "CNPJ: " , 'Left' ,35.00, 497.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', emitente.cgc, 'Left' , 70.00, 497.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Insc. Estadual:" , 'Left' ,165.00, 497.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', emitente.ins-estad, 'Left' , 230.00, 497.00).
     
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "EmissÆo:" , 'Right' ,560.00, 497.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', string(pedido-compr.data-pedido,"99/99/9999"), 'Right' , 636.00, 497.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Entrega Em:" , 'Right' ,570.00, 486.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', "", 'Right' , 626.00, 486.00).
   
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Transportadora: " , 'Left' ,35.00, 475).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', substring(c-nome-transp,1,30), 'Left' , 120.00, 475).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Frete:" , 'Right' ,570.00, 475.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', tt-pedido.desc-frete, 'Right' , 616.00, 475.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "End. Transp.:" , 'Left' ,35.00, 464).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', substring(c-end-transp,1,30), 'Left' , 120.00, 464).
                                                     
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Banco:" , 'Right' ,565.00, 464.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', emitente.portador, 'Right' , 605.00, 464.00).
     
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Ag.:" , 'Right' ,617.00, 464.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', emitente.agencia, 'Right' , 675.00, 464.00).
    
    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Conta:" , 'Right' ,690.00, 464.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', emitente.conta-corren, 'Right' , 765.00, 464.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Fone: " , 'Left' ,35.00, 453.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', c-fone-transp, 'Left' , 70.00, 453.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Cidade:" , 'Left' ,165.00, 453.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', c-cidade-transp, 'Left' , 230.00, 453.00).

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align   ('Pedido', "Contato:" , 'Right' ,314.00, 453.00).
    RUN pdf_set_font     ('Pedido', 'Times', 10).
    RUN pdf_text_align   ('Pedido', c-contato-transp, 'Right' , 350.00, 453.00). 

    RUN pdf_set_font     ('Pedido', 'Times-Bold', 10).

    RUN pdf_text_align    ('Pedido', 'EAN'                , 'Left'   , 035.00,435).   
    RUN pdf_text_align    ('Pedido', 'C¢digo Interno'     , 'Left'   , 075.00,435). 
    RUN pdf_text_align    ('Pedido', 'Descri‡Æo Material' , 'Left'   , 150.00,435). 
    RUN pdf_text_align    ('Pedido', 'Un'                 , 'Right'  , 445.00,435). 
    RUN pdf_text_align    ('Pedido', 'Qtde'               , 'Right'  , 475.00,435). 
    RUN pdf_text_align    ('Pedido', 'Pre‡o UN'           , 'Right'  , 545.00,435). 
    RUN pdf_text_align    ('Pedido', 'Vlr Total'          , 'Right'  , 600.00,435). 
    RUN pdf_text_align    ('Pedido', '% IPI'              , 'Right'  , 635.00,435). 
    RUN pdf_text_align    ('Pedido', 'Vlr IPI'            , 'Right'  , 670.00,435). 
    RUN pdf_text_align    ('Pedido', 'Total Item'         , 'Right'  , 725.00,435). 
    RUN pdf_text_align    ('Pedido', 'Dt.Entrega'         , 'Right'  , 780.00,435). 
                         
    RUN pdf_line('Pedido', 35,430,70,430,0.5).
    RUN pdf_line('Pedido', 75,430,145,430,0.5).
    RUN pdf_line('Pedido',150,430,425,430,0.5). /* Descri‡Æo */
    RUN pdf_line('Pedido',430,430,450,430,0.5). /* Un */
    RUN pdf_line('Pedido',455,430,490,430,0.5). /* Qtde */
    RUN pdf_line('Pedido',495,430,550,430,0.5). /* Preco un */
    RUN pdf_line('Pedido',555,430,600,430,0.5).
    RUN pdf_line('Pedido',605,430,635,430,0.5).
    RUN pdf_line('Pedido',640,430,670,430,0.5).
    RUN pdf_line('Pedido',675,430,730,430,0.5).
    RUN pdf_line('Pedido',735,430,780,430,0.5). 

    ASSIGN de-linha = 430.

    /*
       
    RUN pdf_rect2         ('Pedido', 275.00, 723.50 , 160.00, 014.00, 0.50).
    RUN pdf_rect2         ('Pedido', 435.00, 723.50 , 140.00, 014.00, 0.50).
      
    

    RUN pdf_set_font      ('Pedido', 'Times-Bold', 12).
    

    /** QUADRO 02 - LOGOTIPO / COMPRADOR **/

    RUN pdf_rect2         ('Pedido', 040.00, 669.50 - de-fol-up, 235.00, 054.00, 0.50).
    RUN pdf_rect2         ('Pedido', 275.00, 669.50 - de-fol-up, 300.00, 054.00, 0.50).

    RUN pdf_set_font      ('Pedido', 'Times', 10).
    RUN pdf_text_align    ('Pedido', 'Comprador:'                                               , 'Left'   , 280.00, 711.00 - de-fol-up).
    RUN pdf_text_align    ('Pedido', 'E-mail:'                                                  , 'Left'   , 280.00, 700.00 - de-fol-up).
    RUN pdf_text_align    ('Pedido', 'Fone:'                                                    , 'Left'   , 280.00, 689.00 - de-fol-up).
    RUN pdf_text_align    ('Pedido', 'Fax:'                                                     , 'Left'   , 280.00, 678.00 - de-fol-up).
     
    RUN pdf_set_font      ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align    ('Pedido', STRING (tt-pedido.comprador[01]  , 'X(50)':U)             , 'Left'   , 330.00, 711.00 - de-fol-up).
    RUN pdf_text_align    ('Pedido', STRING (tt-pedido.comprador[02]  , 'X(50)':U)             , 'Left'   , 305.00, 689.00 - de-fol-up).
    RUN pdf_text_align    ('Pedido', STRING (tt-pedido.comprador[03]  , 'X(50)':U)             , 'Left'   , 300.00, 678.00 - de-fol-up).

    RUN pdf_text_color    ('Pedido', 0.00, 0.00, 1.00). 
    RUN pdf_text_align    ('Pedido', STRING (tt-pedido.comprador [04]  , 'X(50)':U)             , 'Left'   , 313.00, 700.00 - de-fol-up).
    RUN pdf_text_color    ('Pedido', 0.00, 0.00, 0.00). 

    RUN pdf_stroke_color  ('Pedido', 0.00, 0.00, 1.00). 
    /* RUN pdf_line_dec      ('Pedido', 313.00, 699.00 - de-fol-up, 308.00 + pdf_text_widthdec  ('Pedido', tt-pedido.comprador [04]), 699.00 - de-fol-up, 0.50). */
    RUN pdf_stroke_color  ('Pedido', 0.00, 0.00, 0.00). 

    /** QUADRO 03 - EMPRESA / CONDI€åES GERAIS PEDIDO **/

    RUN pdf_set_font      ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align    ('Pedido', tt-empresa.linha [01]                                      , 'Left'   , 045.00, 658.00 - de-fol-up).
    
    RUN pdf_set_font      ('Pedido', 'Times', 10).
    RUN pdf_text_align    ('Pedido', tt-empresa.linha [02]                                      , 'Left'   , 045.00, 647.00 - de-fol-up).
    RUN pdf_text_align    ('Pedido', tt-empresa.linha [03]                                      , 'Left'   , 045.00, 636.00 - de-fol-up).
    RUN pdf_text_align    ('Pedido', tt-empresa.linha [04]                                      , 'Left'   , 045.00, 625.00 - de-fol-up).
    RUN pdf_text_align    ('Pedido', tt-empresa.linha [05]                                      , 'Left'   , 045.00, 614.00 - de-fol-up).

    ASSIGN de-linha      = 668.00 - de-fol-up
           de-box-linha  = 614.50 - de-fol-up
           de-box-altura = 055.00. 
     
        RUN pdf_set_font      ('Pedido', 'Times', 10).
        RUN pdf_text_align    ('Pedido', 'Condicäes de Pagamento:'                              , 'Left'   , 280.00, de-linha - {&TamLinha}).

        FOR EACH  tt-cond-pagto
            WHERE tt-cond-pagto.num-pedido = tt-pedido.num-pedido
            NO-LOCK: 
    
            ASSIGN de-linha      = de-linha      - {&TamLinha} 
                   de-box-linha  = de-box-linha  - {&TamLinha} 
                   de-box-altura = de-box-altura + {&TamLinha}. 
            
            RUN pdf_set_font      ('Pedido', 'Times-Bold', 10).
            RUN pdf_text_align    ('Pedido', STRING (tt-cond-pagto.descricao , 'X(40)':U)       , 'Left'   , 387.00, de-linha).
    
        END.
   
        MESSAGE "6" VIEW-AS ALERT-BOX.

        RUN pdf_set_font      ('Pedido', 'Times', 10).
        RUN pdf_text_align    ('Pedido', 'Aliquota ICMS:'                                       , 'Left'   , 280.00, de-linha - ({&TamLinha} * 1.00)).
        RUN pdf_text_align    ('Pedido', 'Moeda:'                                               , 'Left'   , 280.00, de-linha - ({&TamLinha} * 2.00)).
        RUN pdf_text_align    ('Pedido', 'Incoterm:'                                            , 'Left'   , 280.00, de-linha - ({&TamLinha} * 3.00)).
        RUN pdf_text_align    ('Pedido', 'Transportador:'                                       , 'Left'   , 280.00, de-linha - ({&TamLinha} * 4.00)).
    
        RUN pdf_set_font      ('Pedido', 'Times-Bold', 10).
        RUN pdf_text_align    ('Pedido', TRIM (STRING (0, '>9.99':U)) + '%':U , 'Left'   , 347.00, de-linha - ({&TamLinha} * 1.00)).   /* aliquota-icm */
        RUN pdf_text_align    ('Pedido', 0 /* tt-pedido.moeda */                                        , 'Left'   , 313.00, de-linha - ({&TamLinha} * 2.00)).
        RUN pdf_text_align    ('Pedido', tt-pedido.incoterm                                     , 'Left'   , 321.00, de-linha - ({&TamLinha} * 3.00)).
        RUN pdf_text_align    ('Pedido', STRING ("",  'X(40)':U)          , 'Left'   , 342.00, de-linha - ({&TamLinha} * 4.00)).   /* tt-pedido.transportadora */

        RUN pdf_rect2         ('Pedido', 040.00, de-box-linha, 235.00, de-box-altura, 0.50).
        RUN pdf_rect2         ('Pedido', 275.00, de-box-linha, 300.00, de-box-altura, 0.50).

    /** QUADRO 04 - FORNECEDOR / ESTABELECIMENTO DE ENTREGA E COBRAN€A **/

    ASSIGN de-lin-1      = de-linha - ({&TamLinha} * 5.00)
           de-lin-2      = de-lin-1
           de-box-altura = de-lin-1
           de-box-linha  = de-lin-1 - {&TamLinha}. 

    ASSIGN de-lin-1      = de-lin-1 - {&TamLinha}.
    RUN pdf_set_font      ('Pedido', 'Times', 10).
    RUN pdf_text_align    ('Pedido', 'Fornecedor:'                                              , 'Left'   , 045.00, de-lin-1).
    RUN pdf_set_font      ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align    ('Pedido', STRING (tt-pedido.fornecedor [01] , 'X(50)':U)             , 'Left'   , 097.00, de-lin-1). 
    
    /**
    ASSIGN de-lin-1      = de-lin-1 - {&TamLinha}. 
    RUN pdf_set_font      ('Pedido', 'Times-Bold', 11).
    RUN pdf_text_align    ('Pedido', STRING (tt-pedido.fornecedor [02] , 'X(50)':U)             , 'Left'   , 045.00, de-lin-1).
    **/ 
    
    RUN PI-Texto (INPUT  tt-pedido.fornecedor [02],
                  INPUT  210.00).

    FOR EACH  tt-texto
        NO-LOCK: 

        ASSIGN de-lin-1 = de-lin-1 - {&TamLinha}. 
        RUN pdf_text_align    ('Pedido', tt-texto.texto                                         , 'Left'   , 045.00, de-lin-1).

    END. 
    
    RUN pdf_set_font      ('Pedido', 'Times', 10).

    DO  i-cont = 03 TO 15: 

        IF  tt-pedido.fornecedor [i-cont] <> '' THEN DO:

            ASSIGN de-lin-1 = de-lin-1 - {&TamLinha}. 
            RUN pdf_text_align    ('Pedido', STRING (tt-pedido.fornecedor [i-cont] , 'X(50)':U) , 'Left'   , 045.00, de-lin-1).

        END.

    END.
    
    DO  i-cont = 01 TO 05: 

        ASSIGN de-lin-2 = de-lin-2 - {&TamLinha}. 
        RUN pdf_text_align    ('Pedido', STRING (tt-pedido.estab-entrega [i-cont] , 'X(50)':U)  , 'Left'   , 280.00, de-lin-2).

    END.

    ASSIGN de-lin-2 = de-lin-2 - {&TamLinha}. 
    
    DO  i-cont = 01 TO 05: 

        ASSIGN de-lin-2 = de-lin-2 - {&TamLinha}. 
        RUN pdf_text_align    ('Pedido', STRING (tt-pedido.estab-cobranca [i-cont] , 'X(50)':U) , 'Left'   , 280.00, de-lin-2).

    END.

    ASSIGN de-lin-2 = de-lin-2 - {&TamLinha}. 
    
    RUN pdf_set_font      ('Pedido', 'Times-Bold', 11).

    RUN PI-Texto (INPUT  tt-pedido.mensagem,
                  INPUT  280.00).

    FOR EACH  tt-texto
        NO-LOCK: 

        ASSIGN de-lin-2 = de-lin-2 - {&TamLinha}. 
        RUN pdf_text_align    ('Pedido', tt-texto.texto                                         , 'Left'   , 280.00, de-lin-2).

    END.

    ASSIGN de-box-linha  = MINIMUM (de-lin-1, de-lin-2) - 006.50
           de-box-altura = de-box-altura - de-box-linha + 001.50.

    RUN pdf_rect2         ('Pedido', 040.00, de-box-linha, 235.00, de-box-altura, 0.50).
    RUN pdf_rect2         ('Pedido', 275.00, de-box-linha, 300.00, de-box-altura, 0.50).

    /** QUADRO 05 - CABECALHO DOS ITENS DO PEDIDO DE COMPRAS **/ 

    RUN pdf_set_font      ('Pedido', 'Times-Bold', 08).

    ASSIGN de-box-linha  = de-box-linha - ({&TamLinha} * 03)
           de-box-altura = {&TamLinha}  * 002.10
           de-linha      = de-box-linha + 003.50. 

    RUN pdf_rect2         ('Pedido', 040.00, de-box-linha, 045.00, de-box-altura, 0.50). /*040.00    045.00*/  
    RUN pdf_rect2         ('Pedido', 085.00, de-box-linha, 148.00, de-box-altura, 0.50). /*085.00    150.00*/
    RUN pdf_rect2         ('Pedido', 233.00, de-box-linha, 047.00, de-box-altura, 0.50). /*235.00    050.00*/
    RUN pdf_rect2         ('Pedido', 280.00, de-box-linha, 045.00, de-box-altura, 0.50). /*285.00    045.00*/
    RUN pdf_rect2         ('Pedido', 325.00, de-box-linha, 015.00, de-box-altura, 0.50). /*330.00    015.00*/
    RUN pdf_rect2         ('Pedido', 340.00, de-box-linha, 053.00, de-box-altura, 0.50). /*345.00    048.00*/
    RUN pdf_rect2         ('Pedido', 393.00, de-box-linha, 030.00, de-box-altura, 0.50). /*393.00    030.00*/
    RUN pdf_rect2         ('Pedido', 423.00, de-box-linha, 035.00, de-box-altura, 0.50). /*423.00    035.00*/
    RUN pdf_rect2         ('Pedido', 458.00, de-box-linha, 065.00, de-box-altura, 0.50). /*458.00    065.00*/
    RUN pdf_rect2         ('Pedido', 523.00, de-box-linha, 052.00, de-box-altura, 0.50). /*523.00    052.00*/

        
    ASSIGN de-linha   = de-linha - {&TamLinha}
           de-box-ini = 001.00.

    */

    RETURN 'OK':U. 

END.

PROCEDURE PI-Imprime-Item: 
    
    DEF VAR i-tot-item AS INTEGER.

    RUN pdf_set_font ('Pedido', 'Courier', 07).
       
    FOR EACH tt-it-pedido WHERE 
             tt-it-pedido.num-pedido = tt-pedido.num-pedido 
        BREAK BY tt-it-pedido.it-codigo :
    
        ASSIGN de-linha = de-linha - 11
               i-tot-item = i-tot-item + 1.
        
        IF i-tot-item = 26 THEN DO:

            RUN PI-Imprime-Cabecalho.
           
            ASSIGN i-tot-item = 1
                   de-linha = de-linha - 11.
        END.

        RUN pdf_set_font      ('Pedido', 'Courier', 07).
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.cod-ean,       'X(16)')                    , 'Left'   , 035.00, de-linha). 
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.it-codigo,     'X(16)')                    , 'Left'   , 075.00, de-linha). 
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.descricao,     'X(80)')                    , 'Left'   , 150.00, de-linha).
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.un,            'X(02)')                    , 'Right'  , 445.00, de-linha).
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.qtd-forn,      '>>>>>,>>9.99')             , 'Right'  , 485.00, de-linha).
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.preco-un,      '>>>>>,>>9.99')             , 'Right'  , 550.00, de-linha).                                                                                  
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.vlr-liquido,   '>>>>>,>>9.99')             , 'Right'  , 600.00, de-linha).                                                
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.aliquota-ipi,  '>9.99')                    , 'Right'  , 635.00, de-linha).
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.vlr-ipi,       '>>>9.99')                  , 'Right'  , 670.00, de-linha).
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.vlr-total,     '>>>>>,>>9.99')             , 'Right'  , 725.00, de-linha).
        RUN pdf_text_align    ('Pedido', STRING (tt-it-pedido.data-entrega,  '99/99/9999')               , 'Right'  , 780.00, de-linha).
           
        ASSIGN de-tot-vlr-liq   =   de-tot-vlr-liq   + tt-it-pedido.vlr-liquido
               de-tot-vlr-ipi   =   de-tot-vlr-ipi   + tt-it-pedido.vlr-ipi
               de-tot-vlr-st    =   de-tot-vlr-st    + tt-it-pedido.vlr-st
               de-tot-vlr-total =   de-tot-vlr-total + tt-it-pedido.vlr-total.
                               
        IF LAST(tt-it-pedido.it-codigo) 
        THEN DO:

            ASSIGN de-tot-vlr-total =  de-tot-vlr-total + tt-pedido.vlr-frete.

            RUN pi-imprime-rodape(INPUT YES).

            ASSIGN de-tot-vlr-liq   = 0  
                   de-tot-vlr-ipi   = 0 
                   de-tot-vlr-st    = 0 
                   de-tot-vlr-total = 0.
        END.

    END.


    RETURN 'OK':U. 


END. 

PROCEDURE PI-Imprime-Rodape: 
DEF INPUT PARAMETER p-ultimo AS LOGICAL.

   /* IF  de-linha <= 70.00 THEN  
        RUN PI-Imprime-Cabecalho. */
   
    IF p-ultimo THEN DO:
    
        ASSIGN de-linha = de-linha - 22.
        
        RUN pdf_set_font  ('Pedido', 'Times-Bold', 10).
    
        RUN pdf_text_align    ('Pedido', 'Total do Pedido:'                                      , 'Right'  , 540.00, de-linha). 
        RUN pdf_text_align    ('Pedido', STRING (de-tot-vlr-liq,     '>>>,>>>,>>9.99')           , 'Right'  , 600.00, de-linha). 
        RUN pdf_text_align    ('Pedido', STRING (de-tot-vlr-ipi,     '>,>>>,>>9.99')             , 'Right'  , 670.00, de-linha).
        RUN pdf_text_align    ('Pedido', STRING (de-tot-vlr-total,   '>,>>>,>>>,>>9.99')         , 'Right'  , 725.00, de-linha).

        ASSIGN de-linha = de-linha - 11.
      
    END. 

    ASSIGN de-lin-2 = de-linha.

    DO WHILE de-lin-2 > 155:
        ASSIGN de-lin-2 = de-lin-2 - 11.
    END.

    FIND FIRST mensagem NO-LOCK WHERE
               mensagem.cod-mensagem = pedido-compr.cod-mensagem NO-ERROR.
    IF AVAIL mensagem  THEN
       ASSIGN tt-pedido.observacao = mensagem.texto-mensag + tt-pedido.observacao.

    run pi-print-editor (tt-pedido.observacao, 60).

    RUN pdf_rect2        ('Pedido', 030.00,78, 350.00, 075.00, 0.50).

    RUN pdf_set_font      ('Pedido', 'Times-Bold', 10).
    RUN pdf_text_align    ('Pedido', 'Observa‡äes:' , 'Left'   , 042.00, de-lin-2).

    RUN pdf_set_font      ('Pedido', 'Times', 10).
    
    for each tt-editor WHERE
             tt-editor.linha < 6 :

        ASSIGN de-lin-2 = de-lin-2 - 11.

        RUN pdf_text_align    ('Pedido', tt-editor.conteudo  , 'Left'  , 042.00, de-lin-2).
        
    end.
      
    RUN pdf_rect2      ('Pedido', 030.00, 15 , 350.00, 045.00, 0.50).


    RUN pdf_set_font   ('Pedido', 'Times', 10).
    RUN pdf_text_align ('Pedido', '' /* A T E N € Ç O, OBRIGATORIAMENTE MENCIONAR NA NOTA FISCAL:'*/ , 'Left', 045.00, 44).
    RUN pdf_text_align ('Pedido', '' /* 1 - O NéMERO DO PEDIDO DE COMPRAS' */ , 'Left', 055.00, 33).
    RUN pdf_text_align ('Pedido', '' /* 2 - O CàDIGO INTERNO (REI) DO ITEM'*/ , 'Left', 055.00, 22).

    RUN pdf_text_align ('Pedido', 'Aprovado em:  ______/______/____________ ' , 'Left', 405.00, 122).

    RUN pdf_rect2      ('Pedido', 405.00, 15 , 370.00, 085.00, 0.50).
    
    RUN pdf_text_align ('Pedido', '________________________________	' , 'Left', 435.00, 44).
    RUN pdf_text_align ('Pedido', '________________________________	' , 'Left', 605.00, 44).

    RUN pdf_text_align ('Pedido', tt-pedido.nome-ass[1], 'Left', 465.00, 33).
    RUN pdf_text_align ('Pedido', tt-pedido.cargo-ass[1],'Left', 465.00, 22).

    RUN pdf_text_align ('Pedido', tt-pedido.nome-ass[2], 'Left', 635.00, 33).
    RUN pdf_text_align ('Pedido', tt-pedido.cargo-ass[2],'Left', 635.00, 22).

    
    RETURN 'OK':U. 

END. 


/** Final **/ 
