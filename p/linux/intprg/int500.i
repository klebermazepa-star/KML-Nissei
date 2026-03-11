    def temp-table ttInfNFe no-undo xml-node-name 'infNFe'
    field ttInfNFe as int xml-node-type "hidden"
    field Id as char format "x(44)" xml-node-type "attribute"
    field versao as char format "x(04)" xml-node-type "attribute"
    field nome as char initial "Informação NFe".

    def temp-table ttIde no-undo xml-node-name 'IDE'
    field ttInfNFe as int xml-node-type "hidden"
    field ttIde as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field cUF as dec format "99"
    field cNF as dec format "999999999"
    field natOP as char format "x(60)"
    field indPag as dec format "9"
    field mod as char format "x(02)"
    field serie as dec format "999"
    field nNF as dec format "999999999"
    field dhEmi as char format "x(25)"
    field dhSaiEnt as char format "x(25)"
    field tpNF as dec format "9"
    field cMunFG as dec format "9999999"
    field tpImp as dec format "9"
    field tpEmis as dec format "9"
    field cDV as dec format "9"
    field tpAmb as dec format "9"
    field finNFe as dec format "9"
    field procEmi as dec format "9"
    field verProc as char format "x(20)"
    field dhCont as char format "x(20)"
    field nome as char initial "Identifica‡Æo".

    def temp-table ttNFref no-undo xml-node-name 'NFREF'
    field ttIde as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field refNFe as char format "x(44)"
    field refCTe as char format "x(44)"
    field num_docto AS INTEGER
    field serie_docto AS CHARACTER
    field dt_movto AS DATE
    field dt_emissao AS DATE
    field nome as char initial "NFe Referenciada".

    def temp-table ttRefNF no-undo xml-node-name 'REFNF'
    field ttIde as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field cUF as dec format "99"
    field AAMM as char format "9999"
    field CNPJ as char format "x(14)"
    field CPF as char format "x(11)"
    field ie as char format "x(14)"
    field mod as dec format "99"
    field mod_cupom as char format "x(02)"
    field serie as dec format "999"
    field nNF as dec format "999999999"
    field nECF as dec format "999"
    field nCOO as dec format "999999"
    field num_docto AS INTEGER
    field serie_docto AS CHARACTER
    field dt_movto AS DATE
    field dt_emissao AS DATE
    field nome as char initial "Nota Fiscal Referenciada".

    def temp-table ttEmit no-undo xml-node-name 'EMIT'
    field ttInfNFe as int xml-node-type "hidden"
    field ttEmit as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CNPJ as char format "x(14)"
    field CPF as char format "x(11)"
    field xNome as char format "x(60)"
    field xFant as char format "x(60)"
    field ie as char format "x(14)"
    field iest as char format "x(14)"
    field im as char format "x(15)"
    field cnae as dec format "9999999"
    field CRT as dec format "9"
    field nome as char initial "Emitente".

    def temp-table ttEnderEmit no-undo xml-node-name 'ENDEREMIT'
    field ttEmit as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field xLgr as char format "x(60)"
    field nro as char format "x(60)"
    field xCpl as char format "x(60)"
    field xBairro as char format "x(60)"
    field cMun as dec format "9999999"
    field xMun as char format "x(60)"
    field UF as char format "x(02)"
    field CEP as dec format "99999999"
    field cPais as dec format "9999"
    field xPais as char format "x(60)"
    field fone as dec format "9999999999"
    field nome as char initial "Endereço Emitente".

    def temp-table ttDest no-undo xml-node-name 'DEST'
    field ttInfNFe as int xml-node-type "hidden"
    field ttDest as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CNPJ as char format "x(14)"
    field CPF as char format "x(11)"
    field xNome as char format "x(60)"
    field ie as char format "x(14)"
    field isuf as char format "x(09)"
    field email as char format "x(60)"
    field nome as char initial "Destinatário".

    def temp-table ttEnderDest no-undo xml-node-name 'ENDERDEST'
    field ttDest as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CNPJ as char format "x(14)"
    field xLgr as char format "x(60)"
    field nro as char format "x(60)"
    field xCpl as char format "x(60)"
    field xBairro as char format "x(60)"
    field cMun as dec format "9999999"
    field xMun as char format "x(60)"
    field UF as char format "x(02)"
    field CEP as dec format "99999999"
    field cPais as dec format "9999"
    field xPais as char format "x(60)"
    field fone as dec format "9999999999"
    field nome as char initial "Endereço Destinatário".

    def temp-table ttDet no-undo xml-node-name 'DET'
    field ttInfNFe as int xml-node-type "hidden"
    field ttDet as int xml-node-type "hidden"
    field nItem as dec format "999" xml-node-type "attribute"
    field tag as char format "x(20)"
    field nome as char initial "Detalhe"
    index ttDet as primary unique
    ttInfNFe ttDet nItem.

    def temp-table ttProd no-undo xml-node-name 'PROD'
    field ttDet as int xml-node-type "hidden"
    field nItem as dec format "999" xml-node-type "attribute"
    field cProd as char format "x(60)"
    field cEAN as CHAR format "X(14)"
    field xProd as char format "x(120)"
    field NCM as char format "x(08)"
    FIELD CEST AS CHAR FORMAT "X(08)"
    field EXTIPI as char format "x(03)"
    field CFOP as dec format "9999"
    field uCom as char format "x(06)"
    field qCom as dec format "zz,zzz,zz9.9999"
    field vUnCom as dec format "zzz,zzz,zzz,zz9.99999999"
    field vProd as dec format "zzzz,zzz,zzz,zz9.99"
    field cEANTrib as CHAR format "X(14)"
    field uTrib as char format "x(06)"
    field qTrib as dec format "zz,zzz,zz9.9999"
    field vUnTrib as dec format "zzz,zzz,zzz,zz9.99999999"
    field vFrete as dec format "zzzz,zzz,zzz,zz9.99"
    field vSeg as dec format "zzzz,zzz,zzz,zz9.99"
    field vDesc as dec format "zzzz,zzz,zzz,zz9.99"
    field indTot as dec format "9"
    field vOutro as dec format "zzzz,zzz,zzz,zz9.99"
    field xPed as char format "x(15)"
    field nItemPed as dec format "999999"
    field infAdProd as char format "x(500)"
    field cod_trib_nota as int format "99"
    field nome as char initial "Produto"
    index ttProd as primary unique
    ttDet nItem.

    def temp-table ttDI no-undo xml-node-name 'DI'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttDI as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field nDI as char format "x(10)"
    field dDI as char format "x(10)"
    field xLocDesemb as char format "x(60)"
    field UFDesemb as char format "x(02)"
    field dDesemb as char format "x(10)"
    field cExportador as char format "x(60)"
    field nAdicao as dec format "999"
    field nome as char initial "DI".

    def temp-table ttAdi no-undo xml-node-name 'ADI'
    field ttDI as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field nDI as char format "x(10)"
    field nAdicao as dec format "999"
    field nSeqAdic as dec format "999"
    field cFabricante as char format "x(60)"
    field vDescDI as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Adições da DI".

    def temp-table ttVeicProd no-undo xml-node-name 'VEICPROD'
    field nItem as dec format "999" xml-node-type "attribute"
    field tag as char format "x(20)"
    field tpOp as dec format "9"
    field chassi as char format "x(17)"
    field cCor as char format "x(04)"
    field xCor as char format "x(40)"
    field pot as char format "x(04)"
    field pesoL as char format "x(09)"
    field pesoB as char format "x(09)"
    field nSerie as char format "x(09)"
    field tpComb as char format "x(02)"
    field nMotor as char format "x(21)"
    field CMT as char format "x(09)"
    field dist as char format "x(04)"
    field anoMod as dec format "9999"
    field anoFab as dec format "9999"
    field tpPint as char format "x(01)"
    field tpVeic as dec format "99"
    field espVeic as dec format "9"
    field VIN as char format "x(01)"
    field condVeic as dec format "9"
    field cMod as dec format "999999"
    field cilin as char format "x(04)"
    field cCorDENATRAN as dec format "99"
    field lota as dec format "999"
    field tpRest as dec format "9"
    field nome as char initial "Veículo".

    def temp-table ttImposto no-undo xml-node-name 'IMPOSTO'
    field ttDet as int xml-node-type "hidden"
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field nome as char initial "Imposto"
    FIELD vtotTrib AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    index ttImposto as primary unique
    ttDet nItem ttImposto.

    def temp-table ttIcms no-undo xml-node-name 'ICMS'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field nome as char initial "ICMS"
    index ttIcms as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMS00 no-undo xml-node-name 'ICMS00'
    field nItem      as dec format "999" xml-node-type "attribute"
    field ttImposto  as int xml-node-type "hidden"
    field ttIcms     AS int xml-node-type "hidden"
    field tag        as char format "x(20)"
    field orig       as dec format "9"
    field CST        as dec format "99"
    field modBC      as dec format "9"
    field vBC        as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMS      as dec format "zz9.99"
    field vICMS      as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    FIELD modBCST    AS INT   
    FIELD pMVAST     AS DEC 
    FIELD vBCST      AS DEC format "zzzz,zzz,zzz,zz9.99"     
    FIELD pICMSST    AS DEC format "zz9.99"
    FIELD vICMSST    AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSTRet AS DEC format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "ICMS 00"
    index ttIcms00 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMS10 no-undo xml-node-name 'ICMS10'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig       as dec format "9"
    field CST        as dec format "99"
    field modBC      as dec format "9"
    field vBC        as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMS      as dec format "zz9.99"
    field vICMS      as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    FIELD modBCST    AS INT   
    FIELD pMVAST     AS DEC 
    FIELD vBCST      AS DEC format "zzzz,zzz,zzz,zz9.99"     
    FIELD pICMSST    AS DEC format "zz9.99"
    FIELD vICMSST    AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSTRet AS DEC format "zzzz,zzz,zzz,zz9.99" 
    field pRedBCST   as dec format "zz9.99"
    field nome as char initial "ICMS 10"
    index ttIcms10 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMS20 no-undo xml-node-name 'ICMS20'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig       as dec format "9"
    field CST        as dec format "99"
    field modBC      as dec format "9"
    field vBC        as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMS      as dec format "zz9.99"
    field vICMS      as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"  
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    FIELD modBCST    AS INT   
    FIELD pMVAST     AS DEC 
    FIELD vBCST      AS DEC format "zzzz,zzz,zzz,zz9.99"     
    FIELD pICMSST    AS DEC format "zz9.99"
    FIELD vICMSST    AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSTRet AS DEC format "zzzz,zzz,zzz,zz9.99"
    field pRedBCST   as dec format "zz9.99"
    field pRedBC     as dec format "zz9.99"
    field nome as char initial "ICMS 20"
    index ttIcms20 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMS30 no-undo xml-node-name 'ICMS30'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig       as dec format "9"
    field CST        as dec format "99"
    field modBC      as dec format "9"
    field vBC        as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMS      as dec format "zz9.99"
    field vICMS      as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    FIELD modBCST    AS INT   
    FIELD pMVAST     AS DEC 
    FIELD vBCST      AS DEC format "zzzz,zzz,zzz,zz9.99"     
    FIELD pICMSST    AS DEC format "zz9.99"
    FIELD vICMSST    AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSTRet AS DEC format "zzzz,zzz,zzz,zz9.99"
    field pRedBCST   as dec format "zz9.99"
    field pRedBC     as dec format "zz9.99"
    field nome as char initial "ICMS 30"
    index ttIcms30 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMS40 no-undo xml-node-name 'ICMS40'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig       as dec format "9"
    field CST        as dec format "99"
    field modBC      as dec format "9"
    field vBC        as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMS      as dec format "zz9.99"
    field vICMS      as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    FIELD modBCST    AS INT   
    FIELD pMVAST     AS DEC 
    FIELD vBCST      AS DEC format "zzzz,zzz,zzz,zz9.99"     
    FIELD pICMSST    AS DEC format "zz9.99"
    FIELD vICMSST    AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSTRet AS DEC format "zzzz,zzz,zzz,zz9.99"
    FIELD vICMSDeson AS DEC format "zzzz,zzz,zzz,zz9.99"
    field pRedBCST   as dec format "zz9.99"
    field pRedBC     as dec format "zz9.99"
    field motDesICMS as dec format "9"
    field nome as char initial "ICMS 40"
    index ttIcms40 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMS51 no-undo xml-node-name 'ICMS51'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig       as dec format "9"
    field CST        as dec format "99"
    field modBC      as dec format "9"
    field vBC        as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMS      as dec format "zz9.99"
    field vICMS      as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    FIELD modBCST    AS INT   
    FIELD pMVAST     AS DEC 
    FIELD vBCST      AS DEC format "zzzz,zzz,zzz,zz9.99"     
    FIELD pICMSST    AS DEC format "zz9.99"
    FIELD vICMSST    AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSTRet AS DEC format "zzzz,zzz,zzz,zz9.99"
    FIELD vICMSDeson AS DEC format "zzzz,zzz,zzz,zz9.99"
    field pRedBCST   as dec format "zz9.99"
    field pRedBC     as dec format "zz9.99"
    field nome as char initial "ICMS 51"
    index ttICMS51 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMS60 no-undo xml-node-name 'ICMS60'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig       as dec format "9"
    field CST        as dec format "99"
    field modBC      as dec format "9"
    field vBC        as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMS      as dec format "zz9.99"
    field vICMS      as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    FIELD modBCST    AS INT   
    FIELD pMVAST     AS DEC 
    FIELD vBCST      AS DEC format "zzzz,zzz,zzz,zz9.99"     
    FIELD pICMSST    AS DEC format "zz9.99"
    FIELD vICMSST    AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSTRet AS DEC format "zzzz,zzz,zzz,zz9.99"
    FIELD vICMSDeson AS DEC format "zzzz,zzz,zzz,zz9.99"
    field pRedBCST   as dec format "zz9.99"
    field pRedBC     as dec format "zz9.99"
    field nome as char initial "ICMS 60"
    index ttIcms60 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMS70 no-undo xml-node-name 'ICMS70'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig       as dec format "9"
    field CST        as dec format "99"
    field modBC      as dec format "9"
    field vBC        as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMS      as dec format "zz9.99"
    field vICMS      as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    FIELD modBCST    AS INT   
    FIELD pMVAST     AS DEC 
    FIELD vBCST      AS DEC format "zzzz,zzz,zzz,zz9.99"     
    FIELD pICMSST    AS DEC format "zz9.99"
    FIELD vICMSST    AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSTRet AS DEC format "zzzz,zzz,zzz,zz9.99"
    field pRedBCST   as dec format "zz9.99"
    field pRedBC     as dec format "zz9.99"
    field nome as char initial "ICMS 70"
    index ttIcms70 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMS90 no-undo xml-node-name 'ICMS90'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig       as dec format "9"
    field CST        as dec format "99"
    field modBC      as dec format "9"
    field vBC        as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMS      as dec format "zz9.99"
    field vICMS      as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    FIELD modBCST    AS INT   
    FIELD pMVAST     AS DEC 
    FIELD vBCST      AS DEC format "zzzz,zzz,zzz,zz9.99"     
    FIELD pICMSST    AS DEC format "zz9.99"
    FIELD vICMSST    AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSTRet AS DEC format "zzzz,zzz,zzz,zz9.99"
    field pRedBCST   as dec format "zz9.99"
    field pRedBC     as dec format "zz9.99"
    field nome as char initial "ICMS 90"
    index ttIcms90 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMSSN101 no-undo xml-node-name 'ICMSSN101'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig as dec format "9"
    field CSOSN as dec format "999"
    field pCredSN as dec format "zz9.99"
    field vCredICMSSN as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    field nome as char initial "ICMS 101"
    index ttIcmsSN101 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMSSN102 no-undo xml-node-name 'ICMSSN102'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig as dec format "9"
    field CSOSN as dec format "999"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    field nome as char initial "ICMS 102"
    index ttIcmsSN102 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMSSN201 no-undo xml-node-name 'ICMSSN201'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig as dec format "9"
    field CSOSN as dec format "999"
    field modBCST as dec format "9"
    field pMVAST as dec format "zz9.99"
    field pRedBCST as dec format "zz9.99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field vBCST as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMSST as dec format "zz9.99"
    field vICMSST as dec format "zzzz,zzz,zzz,zz9.99"
    field pCredSN as dec format "zz9.99"
    field vCredICMSSN as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    field nome as char initial "ICMS 201"
    index ttIcmsSN201 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMSSN202 no-undo xml-node-name 'ICMSSN202'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig as dec format "9"
    field CSOSN as dec format "999"
    field modBCST as dec format "9"
    field pMVAST as dec format "zz9.99"
    field pRedBCST as dec format "zz9.99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field vBCST as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMSST as dec format "zz9.99"
    field vICMSST as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    field nome as char initial "ICMS 202"
    index ttIcmsSN202 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMSSN500 no-undo xml-node-name 'ICMSSN500'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig as dec format "9"
    field CSOSN as dec format "999"
    field vBCSTRet as dec format "zzzz,zzz,zzz,zz9.99"
    field vICMSSTRet as dec format "zzzz,zzz,zzz,zz9.99"
    field pRedBC as dec format "zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    field nome as char initial "ICMS 500"
    index ttIcmsSN500 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttICMSSN900 no-undo xml-node-name 'ICMSSN900'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIcms as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig as dec format "9"
    FIELD cst  as dec format "99"
    field CSOSN as dec format "999"
    field modBC as dec format "9"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field pRedBC as dec format "zz9.99"
    field pICMS as dec format "zz9.99"
    field vICMS as dec format "zzzz,zzz,zzz,zz9.99"
    field modBCST as dec format "9"
    field pMVAST as dec format "zz9.99"
    field pRedBCST as dec format "zz9.99"
    field vBCST as dec format "zzzz,zzz,zzz,zz9.99"
    field pICMSST as dec format "zz9.99"
    field vICMSST as dec format "zzzz,zzz,zzz,zz9.99"
    field pCredSN as dec format "zz9.99"
    field vCredICMSSN as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"  
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    field nome as char initial "ICMS 900"
    index ttIcmsSN900 as primary unique
    nItem ttImposto ttIcms.

    def temp-table ttIPI no-undo xml-node-name 'IPI'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIpi as int xml-node-type "hidden"
    field nome as char initial "IPI".

    def temp-table ttIPITrib no-undo xml-node-name 'IPITRIB'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIpi as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field pIPI as dec format "zz9.99"
    field vIPI as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "IPI Tributado".

    def temp-table ttIPINT no-undo xml-node-name 'IPINT'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIpi as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field nome as char initial "IPI NT".

    def temp-table ttII no-undo xml-node-name 'II'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field vDespAdu as dec format "zzzz,zzz,zzz,zz9.99"
    field vII as dec format "zzzz,zzz,zzz,zz9.99"
    field vIOF as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "II".

    def temp-table ttPIS no-undo xml-node-name 'PIS'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttPis as int xml-node-type "hidden"
    field nome as char initial "PIS".

    def temp-table ttPISAliq no-undo xml-node-name 'PISALIQ'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttPis as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field vPIS as dec format "zzzz,zzz,zzz,zz9.99"
    field pPIS as dec format "zz9.99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Pis Aliquota".

    def temp-table ttPISNT no-undo xml-node-name 'PISNT'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttPis as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field nome as char initial "Pis NT".

    def temp-table ttPISOutr no-undo xml-node-name 'PISOUTR'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttPis as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field pPIS as dec format "zz9.99"
    field vPIS as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Pis Outros".

    def temp-table ttCOFINS no-undo xml-node-name 'COFINS'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttCofins as int xml-node-type "hidden"
    field nome as char initial "Cofins".

    def temp-table ttCOFINSAliq no-undo xml-node-name 'COFINSALIQ'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttCofins as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field vCOFINS as dec format "zzzz,zzz,zzz,zz9.99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field pCOFINS as dec format "zz9.99"
    field nome as char initial "Cofins Alíquota".

    def temp-table ttCOFINSNT no-undo xml-node-name 'COFINSNT'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttCofins as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field nome as char initial "Cofins NT".

    def temp-table ttCOFINSOutr no-undo xml-node-name 'COFINSOUTR'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttCofins as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field pCOFINS as dec format "zz9.99"
    field vCOFINS as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Cofins Outros".

    def temp-table ttISSQN no-undo xml-node-name 'ISSQN'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field vAliq as dec format "zz9.99"
    field vISSQN as dec format "zzzz,zzz,zzz,zz9.99"
    field cMunFG as dec format "9999999"
    field cListServ as dec format "9999"
    field cSitTrib as char format "x(1)"
    field nome as char initial "ISSQN". 

    def temp-table ttTotal no-undo xml-node-name 'TOTAL'
    field ttInfNFe as int xml-node-type "hidden"
    field ttTotal as int xml-node-type "hidden"
    field nome as char initial "Total".

    def temp-table ttICMSTot no-undo xml-node-name 'ICMSTOT'
    field ttTotal as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field vICMSDeson as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCP as dec format "zzzz,zzz,zzz,zz9.99"
    field vICMS as dec format "zzzz,zzz,zzz,zz9.99"
    field vBCST as dec format "zzzz,zzz,zzz,zz9.99"
    field vST as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet as dec format "zzzz,zzz,zzz,zz9.99"
    field vProd as dec format "zzzz,zzz,zzz,zz9.99"
    field vFrete as dec format "zzzz,zzz,zzz,zz9.99"
    field vSeg as dec format "zzzz,zzz,zzz,zz9.99"
    field vDesc as dec format "zzzz,zzz,zzz,zz9.99"
    field vII as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPI as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol as dec format "zzzz,zzz,zzz,zz9.99"
    field vPIS as dec format "zzzz,zzz,zzz,zz9.99"
    field vCOFINS as dec format "zzzz,zzz,zzz,zz9.99"
    field vOutro as dec format "zzzz,zzz,zzz,zz9.99"
    field vNF as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "ICMS Total".

    def temp-table ttISSQNtot no-undo xml-node-name 'ISSQNTOT'
    field ttTotal as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field vServ as dec format "zzzz,zzz,zzz,zz9.99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field vISS as dec format "zzzz,zzz,zzz,zz9.99"
    field vPIS as dec format "zzzz,zzz,zzz,zz9.99"
    field vCOFINS as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "ISSQN Total".

    def temp-table ttRetTrib no-undo xml-node-name 'RETTRIB'
    field ttTotal as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field vRetPIS as dec format "zzzz,zzz,zzz,zz9.99"
    field vRetCOFINS as dec format "zzzz,zzz,zzz,zz9.99"
    field vRetCSLL as dec format "zzzz,zzz,zzz,zz9.99"
    field vBCIRRF as dec format "zzzz,zzz,zzz,zz9.99"
    field vIRRF as dec format "zzzz,zzz,zzz,zz9.99"
    field vBCRetPrev as dec format "zzzz,zzz,zzz,zz9.99"
    field vRetPrev as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Retenção Tributação".

    def temp-table ttTransp no-undo xml-node-name 'TRANSP'
    field ttInfNFe as int xml-node-type "hidden"
    field ttTransp as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field modFrete as dec format "9"
    field nome as char initial "Transporte".

    def temp-table ttTransporta no-undo xml-node-name 'TRANSPORTA'
    field ttTransp as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CNPJ as char format "x(14)"
    field CPF as char format "x(11)"
    field xNome as char format "x(60)"
    field IE as char format "x(14)"
    field xEnder as char format "x(60)"
    field xMun as char format "x(60)"
    field UF as char format "x(02)"
    field nome as char initial "Trasportadora".

    def temp-table ttVeicTransp no-undo xml-node-name 'VEICTRANSP'
    field ttTransp as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field placa as char format "x(08)"
    field UF as char format "x(02)"
    field RNTC as char format "x(20)"
    field nome as char initial "Veículo da Transportadora".

    def temp-table ttReboque no-undo xml-node-name 'REBOQUE'
    field ttTransp as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field placa as char format "x(08)"
    field UF as char format "x(02)"
    field RNTC as char format "x(20)"
    field nome as char initial "Reboque".

    def temp-table ttVol no-undo xml-node-name 'VOL'
    field ttTransp as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field qVol as dec format "999999999999999"
    field esp as char format "x(60)"
    field marca as char format "x(60)"
    field nVol as char format "x(60)"
    field pesoL as dec format "zzz,zzz,zzz,zz9.999"
    field pesoB as dec format "zzz,zzz,zzz,zz9.999"
    field nome as char initial "Volume".

    def temp-table ttCobr no-undo xml-node-name 'COBR'
    field ttInfNFe as int xml-node-type "hidden"
    field ttCobr as int xml-node-type "hidden"
    field nome as char initial "Cobrança".

    def temp-table ttDup no-undo xml-node-name 'DUP'
    field ttInfNFe as int xml-node-type "hidden"
    field ttCobr as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field nDup as char format "x(60)"
    field dVenc as char format "x(10)"
    field vDup as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Duplicata".

    def temp-table ttpag no-undo xml-node-name 'PAG'
    field ttInfNFe as int xml-node-type "hidden"
    field ttpag as int xml-node-type "hidden"
    field nome as char initial "Pagamento".

    def temp-table ttdetPag no-undo xml-node-name 'DETPAG'
    field ttInfNFe as int xml-node-type "hidden"
    field ttpag as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field tPag as CHAR
    field vPag as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Detalhe Pagamento".

    def temp-table ttFat no-undo xml-node-name 'FAT'
    field ttCobr as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field nFat as char format "x(60)"
    field vOrig as dec format "zzzz,zzz,zzz,zz9.99"
    field vDesc as dec format "zzzz,zzz,zzz,zz9.99"
    field vLiq as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Fatura".

    def temp-table ttInfAdic no-undo xml-node-name 'INFADIC'
    field ttInfNFe as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field infAdFisco as char format "x(2000)"
    field infCpl as char format "x(5000)"
    field nome as char initial "Informações Adicionais".

    def temp-table ttExporta no-undo xml-node-name 'EXPORTA'
    field ttInfNFe as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field UFEmbarq as char format "x(02)"
    field xLocEmbarq as char format "x(60)"
    field nome as char initial "Exporta".

    def temp-table ttCompra no-undo xml-node-name 'Compra'
    field ttInfNFe as int xml-node-type "hidden"
    field xPed as char format "x(20)".
   
    def temp-table ttrastro no-undo xml-node-name 'rastro'
    field nItem   as dec format "999" xml-node-type "attribute"
    field nlote   as char 
    field dfab    as CHAR 
    field dval    as CHAR.

    def temp-table ttmed no-undo xml-node-name 'MED'
    field nItem       as dec format "999" xml-node-type "attribute"
    field nlote       as char 
    field dfab        as CHAR 
    field dval        as CHAR
    FIELD cProdANVISA AS CHAR format "X(14)".
     
    def temp-table ttInfProt no-undo xml-node-name 'INFProt'
    field ttInfProt as int xml-node-type "hidden"
    field ChNFe as char format "x(60)" xml-node-type "hidden".
    
    def dataset dsNFe xml-node-name 'NFe'
    for ttInfNFe, ttIde, ttNFref, ttRefNF, ttEmit, ttEnderEmit, ttDest, ttEnderDest, ttDet,
    ttProd, ttDI, ttAdi, ttVeicProd, ttImposto, ttIcms, ttICMS00, ttICMS10, ttICMS20,
    ttICMS30, ttICMS40, ttICMS51, ttICMS60, ttICMS70, ttICMS90, ttICMSSN101, ttICMSSN102, ttICMSSN201,
    ttICMSSN202, ttICMSSN500, ttICMSSN900, ttIPI, ttIPITrib, ttIPINT, ttII, ttPIS, ttPISAliq,
    ttPISNT, ttPISOutr, ttCOFINS, ttCOFINSAliq, ttCOFINSNT, ttCOFINSOutr, ttISSQN, ttTotal,
    ttICMSTot, ttISSQNtot, ttRetTrib, ttTransp, ttTransporta, ttVeicTransp, ttReboque, ttVol,
    ttCobr, ttFat, ttDup, ttpag, ttdetpag, ttInfAdic, ttCompra, ttrastro, ttmed, ttExporta   

    data-relation aa for ttInfNFe ,ttIde relation-fields(ttInfNFe,ttInfNFe) nested

    data-relation ab for ttIde ,ttNFref relation-fields(ttIde,ttIde) nested
    data-relation ac for ttIde ,ttRefNF relation-fields(ttIde,ttIde) nested

    data-relation ad for ttInfNFe ,ttEmit relation-fields(ttInfNFe,ttInfNFe) nested
    data-relation ae for ttEmit ,ttEnderEmit relation-fields(ttEmit,ttEmit) nested

    data-relation af for ttInfNFe ,ttDest relation-fields(ttInfNFe,ttInfNFe) nested
    data-relation ag for ttDest ,ttEnderDest relation-fields(ttDest,ttDest) nested

    data-relation ah for ttInfNFe ,ttDet relation-fields(ttInfNFe,ttInfNFe) nested
    data-relation ai for ttDet ,ttProd relation-fields(ttDet,ttDet, nItem,nItem) nested             /* foreign-key-hidden   */
    data-relation aj for ttDet ,ttImposto relation-fields(ttDet,ttDet, nItem,nItem) nested          /* foreign-key-hidden   */
    data-relation ak for ttImposto ,ttIcms relation-fields(nItem,nItem, ttImposto,ttImposto) nested /* foreign-key-hidden   */
    data-relation al for ttIcms ,ttICMS00 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested /* foreign-key-hidden  */
    data-relation am for ttIcms ,ttICMS10 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested /* foreign-key-hidden  */
    data-relation an for ttIcms ,ttICMS20 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested /* foreign-key-hidden  */
    data-relation ao for ttIcms ,ttICMS30 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested /* foreign-key-hidden  */
    data-relation ap for ttIcms ,ttICMS40 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested /* foreign-key-hidden  */
    data-relation aq for ttIcms ,ttICMS51 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested /* foreign-key-hidden  */
    data-relation ar for ttIcms ,ttICMS60 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested /* foreign-key-hidden  */
    data-relation ss for ttIcms ,ttICMS70 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested /* foreign-key-hidden  */
    data-relation tt for ttIcms ,ttICMS90 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested /* foreign-key-hidden  */
    data-relation au for ttIcms ,ttICMSSN101 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested  /* foreign-key-hidden     */
    data-relation av for ttIcms ,ttICMSSN102 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested  /* foreign-key-hidden     */
    data-relation aw for ttIcms ,ttICMSSN201 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested  /* foreign-key-hidden     */
    data-relation ax for ttIcms ,ttICMSSN202 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested  /* foreign-key-hidden     */
    data-relation ay for ttIcms ,ttICMSSN500 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested  /* foreign-key-hidden     */
    data-relation az for ttIcms ,ttICMSSN900 relation-fields(nItem,nItem, ttImposto,ttImposto, ttIcms,ttIcms) nested  /* foreign-key-hidden     */

    data-relation ba for ttProd ,ttDI relation-fields(nItem,nItem) nested
    data-relation bb for ttDI ,ttAdi relation-fields(ttDI,ttDI) nested

    data-relation bc for ttProd ,ttVeicProd relation-fields(nItem,nItem) nested
    data-relation xa for ttProd ,ttrastro relation-fields(nItem,nItem) NESTED
    data-relation bd for ttProd ,ttMed relation-fields(nItem,nItem) nested

    data-relation be for ttImposto ,ttIPI relation-fields(nItem,nItem, ttImposto,ttImposto) nested              /* foreign-key-hidden   */
    data-relation bf for ttIPI ,ttIPITrib relation-fields(nItem,nItem, ttImposto,ttImposto, ttIPI,ttIPI) nested /* foreign-key-hidden   */
    data-relation bg for ttIPI ,ttIPINT relation-fields(nItem,nItem, ttImposto,ttImposto, ttIPI,ttIPI) NESTED   /* foreign-key-hidden   */

    data-relation bh for ttImposto ,ttII relation-fields(nItem,nItem, ttImposto,ttImposto) nested

    data-relation bi for ttImposto ,ttPIS relation-fields(nItem,nItem, ttImposto,ttImposto) nested               /* foreign-key-hidden  */
    data-relation bj for ttPIS ,ttPISAliq relation-fields(nItem,nItem, ttImposto,ttImposto, ttPIS,ttPIS) nested  /* foreign-key-hidden  */
    data-relation bj for ttPIS ,ttPISNT relation-fields(nItem,nItem, ttImposto,ttImposto, ttPIS,ttPIS) nested    /* foreign-key-hidden  */
    data-relation bk for ttPIS ,ttPISOutr relation-fields(nItem,nItem, ttImposto,ttImposto, ttPIS,ttPIS) nested  /* foreign-key-hidden  */

    data-relation bl for ttImposto ,ttCOFINS relation-fields(nItem,nItem, ttImposto,ttImposto) nested                       /* foreign-key-hidden */
    data-relation bm for ttCOFINS ,ttCOFINSAliq relation-fields(nItem,nItem, ttImposto,ttImposto, ttCOFINS,ttCOFINS) nested /* foreign-key-hidden */
    data-relation bn for ttCOFINS ,ttCOFINSNT relation-fields(nItem,nItem, ttImposto,ttImposto, ttCOFINS,ttCOFINS)   nested /* foreign-key-hidden */
    data-relation bo for ttCOFINS ,ttCOFINSOutr relation-fields(nItem,nItem, ttImposto,ttImposto, ttCOFINS,ttCOFINS) nested /* foreign-key-hidden */

    data-relation bp for ttImposto ,ttISSQN relation-fields(nItem,nItem, ttImposto,ttImposto) nested

    data-relation bq for ttInfNFe ,ttTotal relation-fields(ttInfNFe ,ttInfNFe) nested
    data-relation br for ttTotal ,ttICMSTot relation-fields(ttTotal ,ttTotal) nested
    data-relation bs for ttTotal ,ttISSQNtot relation-fields(ttTotal ,ttTotal) nested
    data-relation bt for ttTotal ,ttRetTrib relation-fields(ttTotal ,ttTotal) nested

    data-relation bu for ttInfNFe ,ttTransp relation-fields(ttInfNFe ,ttInfNFe) nested
    data-relation bv for ttTransp ,ttTransporta relation-fields(ttTransp ,ttTransp) nested
    data-relation bw for ttTransp ,ttVeicTransp relation-fields(ttTransp ,ttTransp) nested
    data-relation bx for ttTransp ,ttReboque relation-fields(ttTransp ,ttTransp) nested
    data-relation bz for ttTransp ,ttVol relation-fields(ttTransp ,ttTransp) nested

    data-relation ca for ttInfNFe ,ttCobr relation-fields(ttInfNFe ,ttInfNFe) nested
    data-relation cb for ttCobr ,ttFat relation-fields(ttCobr ,ttCobr) nested
    data-relation cc for ttCobr ,ttDup relation-fields(ttCobr ,ttCobr) nested
    data-relation xb for ttpag ,ttdetpag relation-fields(ttpag ,ttpag) NESTED
    data-relation cd for ttInfNFe ,ttInfAdic relation-fields(ttInfNFe ,ttInfNFe) nested
    data-relation ce for ttInfNFe ,ttcompra relation-fields(ttInfNFe ,ttInfNFe) nested
    data-relation cf for ttInfNFe ,ttExporta relation-fields(ttInfNFe ,ttInfNFe) NESTED.

   def dataset dsChave xml-node-name 'ProtNFe'
   FOR ttInfProt.     
 
