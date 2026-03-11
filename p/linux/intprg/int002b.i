DEF TEMP-TABLE tt-param-gm
FIELD h-tela  AS HANDLE
FIELD dir-xml AS CHAR.

DEF TEMP-TABLE tt-nota-xml     LIKE int_ds_docto_xml
FIELD tipo-compra AS INTEGER /* 1 - Mbai 2- Compra Normal 3- Devolucao 4-Retorno */ 
FIELD r-rowid     AS ROWID
INDEX idx_ch_docto_xml
      tipo_estab
      dEmi         
      NNF         
      cod_emitente.    

DEF TEMP-TABLE tt-it-nota-xml  LIKE int_ds_it_docto_xml 
FIELD tipo-compra AS INTEGER /* 1 - Mbai 2- Compra Normal 3- Devolucao 4- Retorno */ 
FIELD r-rowid AS ROWID
INDEX idx_ch_it_docto_xml
       cod_emitente
       serie
       nnf
       tipo_nota
       sequencia.
                
DEF TEMP-TABLE tt-docto-xml  NO-UNDO LIKE int_ds_docto_xml
FIELD r-rowid AS ROWID
    INDEX tp-estab-emis
            tipo_estab  
            dEmi         
            NNF         
            cod_emitente.

DEF TEMP-TABLE tt-it-docto-xml NO-UNDO LIKE int_ds_it_docto_xml
FIELD r-rowid AS ROWID
field dEan as decimal format ">>>>>>>>>>>>>9"
    INDEX idx_it_docto_xml
       cod_emitente
       serie
       nnf
       tipo_nota
       sequencia.

def temp-table tt-xml-dup like int_ds_docto_xml_dup
    FIELD r-rowid AS ROWID.

