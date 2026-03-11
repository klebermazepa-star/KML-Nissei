DEF TEMP-TABLE tt-param-nissei
    FIELD h-tela  AS HANDLE
    FIELD tipo-docto AS INT. /* 1 - Doc-fisico  2 - docum-est */

DEF TEMP-TABLE tt-nota-xml     LIKE int_ds_docto_xml
    FIELD marca        AS CHAR
    FIELD tipo-compra  AS INTEGER 
    FIELD tipo-contr   AS INTEGER
    FIELD r-rowid      AS ROWID
    INDEX idx_chave serie nNF cod_emitente tipo_nota tipo-contr.
    
DEF TEMP-TABLE tt-it-nota-xml LIKE int_ds_it_docto_xml
    FIELD marca        AS CHAR
    FIELD tipo-compra AS INTEGER /* 1 -  2- Compra Normal 3- Devolucao 4- Retorno */ 
    FIELD r-rowid AS ROWID.

DEF TEMP-TABLE tt-docto-xml    LIKE int_ds_docto_xml
    FIELD r-rowid AS ROWID.

DEF TEMP-TABLE tt-it-docto-xml LIKE int_ds_it_docto_xml
    FIELD r-rowid AS ROWID.

def temp-table tt-xml-dup like int_ds_docto_xml_dup
    FIELD r-rowid AS ROWID.
