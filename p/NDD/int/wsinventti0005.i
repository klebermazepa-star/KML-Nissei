DEF TEMP-TABLE tt-evento-xml-retornado  NO-UNDO
    FIELD seq          AS INT
    FIELD nome-arquivo AS CHAR 
    FIELD arquivo      AS CHAR.
    

DEF TEMP-TABLE tt-protocolo NO-UNDO
   field nseqevento  as CHAR
   field descevento  as char 
   field nport       as char 
   field tpevento    AS CHAR.

def temp-table ide
    field cUF       as char
    field cNF       as char
    field natOp     as char
    field indPag    as char
    field mod       as char
    field serie     as char
    field nnf       as char
    field dEmi      as CHAR FORMAT 'x(10)'
    FIELD dhEmi     AS CHAR
    field dSaiEnt   as char
    field tpNF      as char
    field cMunFG    as char
    field tpImp     as char
    field tpEmis    as char
    field cDV       as char
    field tpAmb     as char
    field finNFe    as char
    field procEmi   as char
    field verProc   as char
    FIELD nct       AS CHAR
    FIELD cfop      AS CHAR
    FIELD tpCTe     AS CHAR.

def temp-table emit
    field CNPJ      as char
    field xNome     as char
    field xFant     as char
    field xLgr      as char
    field nro       as char
    field xCpl      as char
    field xBairro   as char
    field cMun      as char
    field xMun      as char
    field UF        as char
    field CEP       as char
    field cPais     as char
    field xPais     as char
    field fone      as char
    field IE        as char.

def temp-table dest
    field Cpf      as char
    field CNPJ      as char
    field xNome     as char
    field xFant     as char
    field xLgr      as char
    field nro       as char
    field xCpl      as char
    field xBairro   as char
    field cMun      as char
    field xMun      as char
    field UF        as char
    field CEP       as char
    field cPais     as char
    field xPais     as char
    field fone      as char
    field IE        as char.

def temp-table prod
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
    field nome as char initial "Produto".
    //index ttProd as primary UNIQUE ttDet nItem.

def temp-table icms
    field nItem     as int
    field orig      as char
    field CST       as char
    field modBC     as char
    field pRedBC    as char
    field vBC       as char
    field pICMS     as char
    field vICMS     as char
    field modBCST   as char
    field pMVAST    as char
    field pRedBCST  as char
    field vBCST     as char
    field pICMSST   as char
    field vICMSST   as char.


DEF TEMP-TABLE ICMSUFDest
    field nItem          as int
    field vBCUFDest      as char 
    field pFCPUFDest     as char 
    field pICMSUFDest    as char 
    field pICMSInter     as char 
    field pICMSInterPart as char 
    field vFCPUFDest     as char 
    field vICMSUFDest    as char 
    field vICMSUFRemet   as char .


def temp-table ipi
    field nItem     as int
    field CST       as char
    field vBC       as char
    field pIPI      as char
    field vIPI      as char.

def temp-table pis
    field nItem     as int
    field CST       as char
    field vBC       as char
    field pPIS      as char
    field vPIS      as char.

def temp-table cofins
    field nItem     as int
    field CST       as char
    field vBC       as char
    field pCOFINS   as char
    field vCOFINS   as char.

def temp-table total
    field vBC       as char
    field vICMS     as char
    field vBCST     as char
    field vST       as char
    field vProd     as char
    field vFrete    as char
    field vSeg      as char
    field vDesc     as char
    field vII       as char
    field vIPI      as char
    FIELD vpis      AS CHAR
    field vCofins   as char
    field vOutro    as char
    field vNF       as char
    FIELD vFCP       AS CHAR
    FIELD vFCPST     AS CHAR
    FIELD vFCPSTRet  AS CHAR.

DEF TEMP-TABLE infprot
    FIELD tbAmb    AS CHAR
    FIELD verAplic AS CHAR
    FIELD chNfe    AS CHAR
    FIELD chCte    AS CHAR
    FIELD dhRecbto AS CHAR
    FIELD nProt    AS CHAR
    FIELD digVal   AS CHAR
    FIELD cStat    AS CHAR
    FIELD xMotivo  AS CHAR.
    

DEF TEMP-TABLE vol
    FIELD qVol     AS CHAR
    FIELD esp      AS CHAR
    FIELD pesoL    AS CHAR
    FIELD pesoB    AS CHAR.

DEF TEMP-TABLE transporta
    FIELD cnpj     AS CHAR
    FIELD xnome    AS CHAR
    FIELD ie       AS CHAR
    FIELD xender   AS CHAR
    FIELD xMun     AS CHAR
    FIELD UF       AS CHAR.
    

DEF TEMP-TABLE transp
    FIELD modFrete AS CHAR .


def temp-table DI no-undo xml-node-name 'DI'
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

    def temp-table Adi no-undo xml-node-name 'ADI'
    field ttDI as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field nDI as char format "x(10)"
    field nAdicao as dec format "999"
    field nSeqAdic as dec format "999"
    field cFabricante as char format "x(60)"
    field vDescDI as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Adi‡äes da DI".

    def temp-table VeicProd no-undo xml-node-name 'VEICPROD'
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
    field nome as char initial "Ve¡culo".
//DEF TEMP-TABLE dup
//    FIELD nDup  AS CHAR
//    FIELD dVenc AS CHAR
//    FIELD vDup  AS CHAR.


//def TEMP-TABLE  infAdic NO-UNDO
//    field infCpl   as char
//    field xTexto   as char.
//
DEF TEMP-TABLE infnfe
    FIELD chave AS CHAR
    FIELD pin AS CHAR.

DEF TEMP-TABLE vPrest
    FIELD vTPrest AS CHAR.



def temp-table IPITrib no-undo xml-node-name 'IPITRIB'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIpi as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field pIPI as dec format "zz9.99"
    field vIPI as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "IPI Tributado".

def temp-table IPINT no-undo xml-node-name 'IPINT'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttIpi as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field nome as char initial "IPI NT".

def temp-table II no-undo xml-node-name 'II'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field vDespAdu as dec format "zzzz,zzz,zzz,zz9.99"
    field vII as dec format "zzzz,zzz,zzz,zz9.99"
    field vIOF as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "II".


def temp-table PISAliq no-undo xml-node-name 'PISALIQ'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttPis as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field vPIS as dec format "zzzz,zzz,zzz,zz9.99"
    field pPIS as dec format "zz9.99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Pis Aliquota".

def temp-table PISNT no-undo xml-node-name 'PISNT'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttPis as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field nome as char initial "Pis NT".

def temp-table PISOutr no-undo xml-node-name 'PISOUTR'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttPis as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field pPIS as dec format "zz9.99"
    field vPIS as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Pis Outros".



def temp-table COFINSAliq no-undo xml-node-name 'COFINSALIQ'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttCofins as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field vCOFINS as dec format "zzzz,zzz,zzz,zz9.99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field pCOFINS as dec format "zz9.99"
    field nome as char initial "Cofins Al¡quota".

    def TEMP-TABLE COFINSNT no-undo xml-node-name 'COFINSNT'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttCofins as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field nome as char initial "Cofins NT".

    def temp-table COFINSOutr no-undo xml-node-name 'COFINSOUTR'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ttCofins as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field CST as dec format "99"
    field vBC as dec format "zzzz,zzz,zzz,zz9.99"
    field pCOFINS as dec format "zz9.99"
    field vCOFINS as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Cofins Outros".

    def temp-table ISSQN no-undo xml-node-name 'ISSQN'
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


    def temp-table RetTrib no-undo xml-node-name 'RETTRIB'
    field ttTotal as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field vRetPIS as dec format "zzzz,zzz,zzz,zz9.99"
    field vRetCOFINS as dec format "zzzz,zzz,zzz,zz9.99"
    field vRetCSLL as dec format "zzzz,zzz,zzz,zz9.99"
    field vBCIRRF as dec format "zzzz,zzz,zzz,zz9.99"
    field vIRRF as dec format "zzzz,zzz,zzz,zz9.99"
    field vBCRetPrev as dec format "zzzz,zzz,zzz,zz9.99"
    field vRetPrev as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Reten‡Æo Tributa‡Æo".


def temp-table VeicTransp no-undo xml-node-name 'VEICTRANSP'
    field ttTransp as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field placa as char format "x(08)"
    field UF as char format "x(02)"
    field RNTC as char format "x(20)"
    field nome as char initial "Ve¡culo da Transportadora".

    def temp-table Reboque no-undo xml-node-name 'REBOQUE'
    field ttTransp as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field placa as char format "x(08)"
    field UF as char format "x(02)"
    field RNTC as char format "x(20)"
    field nome as char initial "Reboque".


def temp-table Cobr no-undo xml-node-name 'COBR'
    field ttInfNFe as int xml-node-type "hidden"
    field ttCobr as int xml-node-type "hidden"
    field nome as char initial "Cobran‡a".

DEF TEMP-TABLE ICMS00
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
    field nome as char initial "ICMS 00".
    //index ttIcms00 as primary UNIQUE nItem ttImposto ttIcms.


def temp-table ICMS10 no-undo xml-node-name 'ICMS10'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 10" .
    //index ICMS10 as primary unique nItem ttImposto ICMS.

    def temp-table ICMS20 no-undo xml-node-name 'ICMS20'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 20".
    //index ICMS20 as primary unique nItem ttImposto ICMS.

    def temp-table ICMS30 no-undo xml-node-name 'ICMS30'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 30".
    //index ICMS30 as primary UNIQUE nItem ttImposto ICMS.

    def temp-table ICMS40 no-undo xml-node-name 'ICMS40'
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 40".
    //index ICMS40 as primary UNIQUE nItem ttImposto ICMS.

    def temp-table ICMS51 no-undo xml-node-name 'ICMS51'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 51".
    //index ICMS51 as primary UNIQUE nItem ttImposto ICMS.

    def temp-table ICMS60 no-undo xml-node-name 'ICMS60'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    FIELD vBCFCPSTRet AS DEC
    FIELD pFCPSTRe AS DEC
    FIELD vBCST      AS DEC format "zzzz,zzz,zzz,zz9.99"   
    FIELD pST        AS DEC format "zz9.99"
    FIELD pICMSST    AS DEC format "zz9.99"
    FIELD vICMSST    AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSubstituto AS DEC format "zzzz,zzz,zzz,zz9.99"
    FIELD vICMSSTRet AS DEC format "zzzz,zzz,zzz,zz9.99"
    FIELD vICMSDeson AS DEC format "zzzz,zzz,zzz,zz9.99"
    field pRedBCST   as dec format "zz9.99"
    field pRedBC     as dec format "zz9.99"
    field nome as char initial "ICMS 60"
    FIELD pFCPSTRet AS DEC.
    //index ICMS60 as primary UNIQUE nItem ttImposto ICMS.

    def temp-table ICMS70 no-undo xml-node-name 'ICMS70'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 70".
    //index ICMS70 as primary UNIQUE nItem ttImposto ICMS.

def temp-table ICMS90 no-undo xml-node-name 'ICMS90'
    field nItem as dec /*format "999"*/ xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
    field tag        as char //format "x(20)"
    field orig       as dec  //format "9"
    field CST        as dec  //format "99"
    field modBC      as dec  //format "9"
    field vBC        as dec  //format "zzzz,zzz,zzz,zz9.99"
    field pICMS      as dec  //format "zz9.99"
    field vICMS      as dec  //format "zzzz,zzz,zzz,zz9.99"
    field vFCP       as dec  //format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec  //format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec  //format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec  //format "zzzz,zzz,zzz,zz9.99"   
    FIELD vBCFCPST   AS DEC  //FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC  //FORMAT "zz9.99"
    FIELD modBCST    AS INT   
    FIELD pMVAST     AS DEC 
    FIELD vBCST      AS DEC //format "zzzz,zzz,zzz,zz9.99"     
    FIELD pICMSST    AS DEC //format "zz9.99"
    FIELD vICMSST    AS DEC //format "zzzz,zzz,zzz,zz9.99" 
    FIELD vBCSTRet   AS DEC //format "zzzz,zzz,zzz,zz9.99" 
    FIELD vICMSSTRet AS DEC //format "zzzz,zzz,zzz,zz9.99"
    field pRedBCST   as dec //format "zz9.99"
    field pRedBC     as dec //format "zz9.9.9"
    field nome as char initial "ICMS 90".
    //index ICMS90 as primary UNIQUE nItem ttImposto ICMS.

    def temp-table ICMSSN101 no-undo xml-node-name 'ICMSSN101'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 101" .
    //index ICMSSN101 as primary unique nItem ttImposto ICMS.

    def temp-table ICMSSN102 no-undo xml-node-name 'ICMSSN102'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field orig as dec format "9"
    field CSOSN as dec format "999"
    field vFCP       as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPST     as dec format "zzzz,zzz,zzz,zz9.99"
    field vFCPSTRet  as dec format "zzzz,zzz,zzz,zz9.99"
    field vIPIDevol  as dec format "zzzz,zzz,zzz,zz9.99"
    FIELD vBCFCPST   AS DEC FORMAT "zzzz,zzz,zzz,zz9.99"
    FIELD pFCPST     AS DEC FORMAT "zz9.99"
    field nome as char initial "ICMS 102".
    //index ICMSSN102 as primary UNIQUE nItem ttImposto ICMS.

    def temp-table ICMSSN201 no-undo xml-node-name 'ICMSSN201'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 201".
    //index ICMSSN201 as primary UNIQUE nItem ttImposto ICMS.

    def temp-table ICMSSN202 no-undo xml-node-name 'ICMSSN202'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 202".
    //index ICMSSN202 as primary UNIQUE nItem ttImposto ICMS.

    def temp-table ICMSSN500 no-undo xml-node-name 'ICMSSN500'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 500".
    //index ICMSSN500 as primary UNIQUE nItem ttImposto ICMS.

    def temp-table ICMSSN900 no-undo xml-node-name 'ICMSSN900'
    field nItem as dec format "999" xml-node-name "nItem" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field ICMS as int xml-node-type "hidden"
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
    field nome as char initial "ICMS 900".
    //index ICMSSN900 as primary UNIQUE nItem ttImposto ICMS.

def temp-table Compra no-undo xml-node-name 'Compra'

    field xPed as char format "x(20)".


def temp-table rastro no-undo xml-node-name 'rastro'
    field nItem   as dec format "999" xml-node-type "attribute"
    field nlote   as char 
    field dfab    as CHAR 
    field dval    as CHAR.

def temp-table med no-undo xml-node-name 'MED'
    field nItem       as dec format "999" xml-node-type "attribute"
    field nlote       as char 
    field dfab        as CHAR 
    field dval        as CHAR
    FIELD cProdANVISA AS CHAR format "X(14)".


def temp-table Dup no-undo xml-node-name 'DUP'
    field ttInfNFe as int xml-node-type "hidden"
    field ttCobr as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field nDup as char format "x(60)"
    field dVenc as char format "x(10)"
    field vDup as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Duplicata".

    def temp-table pag no-undo xml-node-name 'PAG'
    field ttInfNFe as int xml-node-type "hidden"
    field ttpag as int xml-node-type "hidden"
    field nome as char initial "Pagamento".

    def temp-table detPag no-undo xml-node-name 'DETPAG'
    field ttInfNFe as int xml-node-type "hidden"
    field ttpag as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field tPag as CHAR
    field vPag as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Detalhe Pagamento".

    def temp-table Fat no-undo xml-node-name 'FAT'
    field ttCobr as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field nFat as char format "x(60)"
    field vOrig as dec format "zzzz,zzz,zzz,zz9.99"
    field vDesc as dec format "zzzz,zzz,zzz,zz9.99"
    field vLiq as dec format "zzzz,zzz,zzz,zz9.99"
    field nome as char initial "Fatura".

    def temp-table InfAdic no-undo xml-node-name 'INFADIC'
    field ttInfNFe as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field infAdFisco as char format "x(2000)"
    field infCpl as char format "x(5000)"
    field nome as char initial "Informa‡äes Adicionais".

    def temp-table Exporta no-undo xml-node-name 'EXPORTA'
    field ttInfNFe as int xml-node-type "hidden"
    field tag as char format "x(20)"
    field UFEmbarq as char format "x(02)"
    field xLocEmbarq as char format "x(60)"
    field nome as char initial "Exporta".

DEF TEMP-TABLE infEvento
    field  tpAmb       as char
    field  verAplic    as char
    field  cOrgao      as char
    field  cStat       as char
    field  xMotivo     as char
    field  chNFe       as char
    field  tpEvento    as char
    field  xEvento     as char
    field  nSeqEvento  as char
    field  dhRegEvento as char
    field  nProt       as char
    FIELD CNPJ         AS CHAR 
    FIELD dhEvento     AS CHAR
    FIELD verEvento    AS CHAR.

DEF TEMP-TABLE nota
    FIELD SituacaoOperacao AS CHAR
    FIELD situacao         AS CHAR SERIALIZE-NAME 'Status'
    FIELD Descricao        AS CHAR 
    FIELD ChaveDaNota      AS CHAR
    FIELD xmotivo          AS CHAR
    FIELD cstat            AS CHAR
    FIELD nProt            AS CHAR.


def temp-table EnderDest no-undo xml-node-name 'ENDERDEST'
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
    field nome as char initial "Endere‡o Destinat rio".

    def temp-table Det no-undo xml-node-name 'DET'
    field ttInfNFe as int xml-node-type "hidden"
    field ttDet as int xml-node-type "hidden"
    field nItem as dec format "999" xml-node-type "attribute"
    field tag as char format "x(20)"
    field nome as char initial "Detalhe".
    //index ttDet as primary UNIQUE ttInfNFe ttDet nItem.


    def temp-table ICMSTot no-undo xml-node-name 'ICMSTOT'
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

def temp-table EnderEmit no-undo xml-node-name 'ENDEREMIT'
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
    field nome as char initial "Endere‡o Emitente".

def temp-table Imposto no-undo xml-node-name 'IMPOSTO'
    field ttDet as int xml-node-type "hidden"
    field nItem as dec format "999" xml-node-type "attribute"
    field ttImposto as int xml-node-type "hidden"
    field nome as char initial "Imposto"
    FIELD vtotTrib AS DEC FORMAT "zzzz,zzz,zzz,zz9.99".
    //index ttImposto as primary UNIQUE ttDet nItem ttImposto.

DEF TEMP-TABLE sefaz
    FIELD cstat AS CHAR
    FIELD xmotivo AS CHAR.

DEF TEMP-TABLE tt-nota-aux NO-UNDO LIKE nota.


define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD dt-trans-ini     AS DATE FORMAT "99/99/9999" 
    FIELD dt-trans-fin     AS DATE FORMAT "99/99/9999" 
    FIELD i-nro-docto-ini  LIKE docum-est.nro-docto
    FIELD i-nro-docto-fim  LIKE docum-est.nro-docto
    FIELD i-cod-emit-ini   LIKE docum-est.cod-emitente
    FIELD i-cod-emit-fin   LIKE docum-est.cod-emitente.
