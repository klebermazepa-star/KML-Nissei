/*******************/
/* Para banco ems5 */
/*******************/
// Cliente COFCO
// Cliente Nissei
/*********************/
&glob ems5_db  YES


/*********************/
/* Para banco emscad */
/*********************/
// Cliente MRN
// Cliente Valgroup
// Cliente CMNP
/*********************/
//&glob emscad_db = yes


/*********************/
/* Para banco emscad */
/*********************/
// Cliente Lepper
// Cliente Minuano
/*********************/
//&glob ems5cad_db = YES


//DEFINIÄ«O ABAIXO ê VALIDA PARA LEITURA DAS TABELAS, PARA DEFINIÄ«O DE TT ê NECESSµRIO ADICIONAR TRATATIVA PARA CADA BANCO

&if DEFINED(ems5_db) &then   
    DEFINE BUFFER empresa                FOR ems5.empresa             .
    DEFINE BUFFER fornecedor             FOR ems5.fornecedor          .
    DEFINE BUFFER espec_docto            FOR ems5.espec_docto         .
    DEFINE BUFFER portador               FOR ems5.portador            .
    DEFINE BUFFER forma_pagto            FOR ems5.forma_pagto         .
    DEFINE BUFFER histor_exec_especial   FOR ems5.histor_exec_especial.
    DEFINE BUFFER pais                   FOR ems5.pais.
    DEFINE BUFFER banco                  FOR ems5.banco.

    DEFINE BUFFER b_empresa              FOR ems5.empresa             .
    DEFINE BUFFER b_fornecedor           FOR ems5.fornecedor          .
    DEFINE BUFFER b_espec_docto          FOR ems5.espec_docto         .
    DEFINE BUFFER b_portador             FOR ems5.portador            .
    DEFINE BUFFER b_forma_pagto          FOR ems5.forma_pagto         .
    DEFINE BUFFER b_histor_exec_especial FOR ems5.histor_exec_especial.
    DEFINE BUFFER b_pais                 FOR ems5.pais.
    DEFINE BUFFER b_banco                FOR ems5.banco.

&ELSEIF DEFINED(emscad_db) &then 
    DEFINE BUFFER empresa                FOR emscad.empresa             .
    DEFINE BUFFER fornecedor             FOR emscad.fornecedor          .
    DEFINE BUFFER espec_docto            FOR emscad.espec_docto         .
    DEFINE BUFFER portador               FOR emscad.portador            .
    DEFINE BUFFER forma_pagto            FOR emscad.forma_pagto         .
    DEFINE BUFFER histor_exec_especial   FOR emscad.histor_exec_especial.
    DEFINE BUFFER pais                   FOR emscad.pais.
    DEFINE BUFFER banco                  FOR emscad.banco.

    DEFINE BUFFER b_empresa              FOR emscad.empresa             .
    DEFINE BUFFER b_fornecedor           FOR emscad.fornecedor          .
    DEFINE BUFFER b_espec_docto          FOR emscad.espec_docto         .
    DEFINE BUFFER b_portador             FOR emscad.portador            .
    DEFINE BUFFER b_forma_pagto          FOR emscad.forma_pagto         .
    DEFINE BUFFER b_histor_exec_especial FOR emscad.histor_exec_especial.
    DEFINE BUFFER b_pais                 FOR emscad.pais.
    DEFINE BUFFER b_banco                FOR emscad.banco.
&ELSEIF DEFINED(ems5cad_db) &then
    DEFINE BUFFER empresa                FOR ems5cad.empresa             .
    DEFINE BUFFER fornecedor             FOR ems5cad.fornecedor          .
    DEFINE BUFFER espec_docto            FOR ems5cad.espec_docto         .
    DEFINE BUFFER portador               FOR ems5cad.portador            .
    DEFINE BUFFER forma_pagto            FOR ems5cad.forma_pagto         .
    DEFINE BUFFER histor_exec_especial   FOR ems5cad.histor_exec_especial.
    DEFINE BUFFER pais                   FOR ems5cad.pais.
    DEFINE BUFFER banco                  FOR ems5cad.banco.

    DEFINE BUFFER b_empresa              FOR ems5cad.empresa             .
    DEFINE BUFFER b_fornecedor           FOR ems5cad.fornecedor          .
    DEFINE BUFFER b_espec_docto          FOR ems5cad.espec_docto         .
    DEFINE BUFFER b_portador             FOR ems5cad.portador            .
    DEFINE BUFFER b_forma_pagto          FOR ems5cad.forma_pagto         .
    DEFINE BUFFER b_histor_exec_especial FOR ems5cad.histor_exec_especial.
    DEFINE BUFFER b_pais                 FOR ems5cad.pais.
    DEFINE BUFFER b_banco                FOR ems5cad.banco.
&ENDIF





