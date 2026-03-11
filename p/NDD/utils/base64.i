/*------------------------------------------------------------------------
File : binaire.i
Purpose : Ajouter ce qu'il manque Ö Progress
 
Syntax :
 
Description : Outils de traitements binaires sur les nombres
Sources :
* http://code.google.com/p/autoedgethefactory/source/browse/trunk/referencecomponents/support/src/OpenEdge/Core/Util/BinaryOperationsHelper.cls?r=154
 
Author(s) : Gabriel Hautclocq, et voir sources 
Created : Thu Sep 26 11:20:38 CEST 2013
Notes :
----------------------------------------------------------------------*/
 
/* *************************** Definitions ************************** */
FUNCTION BIN_LSHIFT RETURNS INTEGER ( INPUT a AS INTEGER, INPUT b AS INTEGER) FORWARDS.
FUNCTION BIN_RSHIFT RETURNS INTEGER ( INPUT a AS INTEGER, INPUT b AS INTEGER) FORWARDS.
FUNCTION BIN_AND RETURNS INTEGER ( a AS INTEGER, b AS INTEGER) FORWARDS.
FUNCTION BIN_OR RETURNS INTEGER ( a AS INTEGER, b AS INTEGER ) FORWARDS.
FUNCTION BIN_XOR RETURNS INTEGER ( a AS INTEGER, b AS INTEGER ) FORWARDS.
FUNCTION BIN_NOT RETURNS INTEGER ( a AS INTEGER ) FORWARDS.
 
/* ******************** Preprocessor Definitions ******************** */
 
/* *************************** Main Block *************************** */
 
/*
Bit shifting Ö gauche
*/
FUNCTION BIN_LSHIFT RETURNS INTEGER ( INPUT a AS INTEGER, INPUT b AS INTEGER) :
    RETURN INT( a * EXP( 2, b ) ).
END FUNCTION.
 
/*
Bit shifting Ö droite
*/
FUNCTION BIN_RSHIFT RETURNS INTEGER ( INPUT a AS INTEGER, INPUT b AS INTEGER) :
    RETURN INT( TRUNCATE( a / EXP( 2, b ), 0 ) ).
END FUNCTION.
 
/* BIN_AND - returns the bitwise AND of two INTEGERs as an INT
INPUT a AS INTEGER - first operand to AND operation
INPUT b AS INTEGER - second operand to AND operation
note : (myval & 255) est pareil que (myval mod 256) */
FUNCTION BIN_AND RETURNS INTEGER ( a AS INTEGER, b AS INTEGER):
    DEFINE VARIABLE res AS INTEGER NO-UNDO INITIAL 0.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
 
    DO i = 1 TO 32:
        IF GET-BITS(a, i, 1) + GET-BITS(b, i, 1) >= 2 THEN
        DO :
            PUT-BITS( res, i, 1 ) = 1.
        END.
    END.
 
    RETURN res.
END FUNCTION.
 
/* BIN_OR - returns the bitwise OR of two INTEGERs as an INT
INPUT a AS INTEGER - first operand to OR operation
INPUT b AS INTEGER - second operand to OR operation */
FUNCTION BIN_OR RETURNS INTEGER( a AS INTEGER, b AS INTEGER ):
    DEFINE VARIABLE res AS INTEGER NO-UNDO INITIAL 0.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
 
    DO i = 1 TO 32:
        IF GET-BITS( a, i, 1 ) + GET-BITS( b, i, 1 ) >= 1 THEN
        DO :
            PUT-BITS( res, i, 1 ) = 1.
        END.
    END.
 
    RETURN res.
END FUNCTION.
 
/* BIN_XOR - returns the bitwise Xor of two INTEGERs as an INT
INPUT a AS INTEGER - first operand to Xor operation
INPUT b AS INTEGER - second operand to Xor operation
Derivations:
BinXor - same operation, provided for consistent naming */
FUNCTION BIN_XOR RETURNS INTEGER ( a AS INTEGER, b AS INTEGER ) :
    DEFINE VARIABLE res AS INTEGER NO-UNDO INITIAL 0.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
 
    DO i = 1 TO 32:
        IF GET-BITS( a, i, 1) + GET-BITS( b, i, 1 ) = 1 THEN
        DO :
            PUT-BITS( res, i, 1 ) = 1.
        END.
    END.
 
    RETURN res.
END FUNCTION.
 
/* BIN_NOT - returns the bitwise NOT of an INTEGER as an INT
INPUT a AS INTEGER - the operand to the NOT operation
Note that this is performed on ALL 32 bits of the int.
This is also the same as the following arithmetic:
-1 (ipiOp1 + 1) */
FUNCTION BIN_NOT RETURNS INTEGER ( a AS INTEGER ) :
    DEFINE VARIABLE res AS INTEGER NO-UNDO INITIAL 0.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
 
    DO i = 1 TO 32:
        IF GET-BITS( a, i, 1) = 0 THEN
        DO :
            PUT-BITS( res, i, 1 ) = 1.
        END.
    END.
 
    RETURN res.
END FUNCTION.

/*------------------------------------------------------------------------
File : base64.i
Purpose :
 
Syntax :
 
Description :
Sources :
* http://en.wikibooks.org/wiki/Algorithm_Implementation/Miscellaneous/Base64
 
Author(s) : Gabriel Hautclocq, et voir sources
Created : Wed Sep 25 15:25:01 CEST 2013
Notes :
----------------------------------------------------------------------*/
 
/* *************************** Definitions ************************** */
FUNCTION BASE64_ENCODE RETURNS LONGCHAR(
    INPUT s AS CHARACTER,  /* chaine Ö encoder */
    INPUT w AS LOGICAL  )  /* mettre Ö vrai pour activer le wordwrap Ö 76 */
    FORWARDS.
FUNCTION BASE64_DECODE  RETURNS LONGCHAR(
    INPUT s  AS LONGCHAR ) /* chaine Ö dÇcoder */
    FORWARDS.
 
/* nÇcessite les outils binaires pour fonctionner */
/*{ binaire.i }*/
 
/* ******************** Preprocessor Definitions ******************** */
 
/* *************************** Main Block *************************** */
 
/* Encode une chaine en base 64 */
FUNCTION BASE64_ENCODE RETURNS LONGCHAR(
    INPUT s AS CHARACTER,  /* chaine Ö encoder */
    INPUT w AS LOGICAL  ): /* mettre Ö vrai pour activer le wordwrap Ö 76 */
 
    /* caractäres valides en base64 */
    DEFINE VARIABLE ch_base64chars AS CHARACTER NO-UNDO
    INITIAL "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    CASE-SENSITIVE.
 
    /* rÇsultat */
    DEFINE VARIABLE r AS LONGCHAR NO-UNDO INITIAL "".
 
    /* chaine de padding */
    DEFINE VARIABLE p AS LONGCHAR NO-UNDO INITIAL "".
 
    /* pad count */
    DEFINE VARIABLE c AS INTEGER   NO-UNDO.
 
    /* nombre de 24 bits */
    DEFINE VARIABLE n AS INTEGER   NO-UNDO.
 
    /* 4 indexs de 6 bits */
    DEFINE VARIABLE n0 AS INTEGER  NO-UNDO.
    DEFINE VARIABLE n1 AS INTEGER  NO-UNDO.
    DEFINE VARIABLE n2 AS INTEGER  NO-UNDO.
    DEFINE VARIABLE n3 AS INTEGER  NO-UNDO.
 
    /* variables temporaires */
    DEFINE VARIABLE t1 AS CHAR NO-UNDO.
    DEFINE VARIABLE t2 AS CHAR NO-UNDO.
    DEFINE VARIABLE t3 AS CHAR NO-UNDO.
    DEFINE VARIABLE b2 AS LOGICAL   NO-UNDO INITIAL FALSE.
    DEFINE VARIABLE b3 AS LOGICAL   NO-UNDO INITIAL FALSE.
    DEFINE VARIABLE ls AS INTEGER   NO-UNDO.
 
    /* compte le nombre de caractäres de padding */
    ASSIGN c = LENGTH( s ) MODULO 3.
 
    /* ajoute un zÇro Ö droite pour que la longueur de la chaine soit un multiple de 3 */
    IF c > 0 THEN
    DO :
        DO WHILE c < 3 :
            IF c = 1 THEN ASSIGN b2 = TRUE.
            IF c = 2 THEN ASSIGN b3 = TRUE.
            ASSIGN
                p = p + "="
                s = s + CHR( 61 ) /* En Progress, CHR(0) n'ajoute en fait aucun caractäre... */
                c = c + 1
            .
        END.
    END.
 
    /* pour chaque groupe de 3 caractäres */
    ASSIGN
        c = 0
        ls = LENGTH( s )
    .
    DO WHILE c < ls : /* on ajoute une nouvelle ligne tous les 76 caractäres si demandÇ */ IF w THEN DO : IF c > 0 AND ( INT( TRUNCATE( c / 3 * 4, 0 ) ) ) MODULO 76 = 0
            THEN DO :
                ASSIGN r = r + CHR( 13 ) + CHR( 10 ).
            END.
        END.
 
 
        /* transformation des 3 caractäres en nombre 24 bits */
        ASSIGN
            t1 = SUBSTRING( s, c + 1, 1 )
            t2 = SUBSTRING( s, c + 2, 1 )
            t3 = SUBSTRING( s, c + 3, 1 )
 
            n = BIN_LSHIFT( ASC( t1 ), 16 )
 
              + BIN_LSHIFT( IF c + 3 >= ls AND t2 = CHR( 61 ) AND b2
                            THEN 0
                            ELSE ASC( t2 ),  8 )
 
              +             IF c + 3 >= ls AND t3 = CHR( 61 ) AND b3
                            THEN 0
                            ELSE ASC( t3 )
        .
 
        /* sÇparation en 4 indexs de 6 bits */
        ASSIGN
            n0 = BIN_AND( BIN_RSHIFT( n, 18 ), 63 )
            n1 = BIN_AND( BIN_RSHIFT( n, 12 ), 63 )
            n2 = BIN_AND( BIN_RSHIFT( n,  6 ), 63 )
            n3 = BIN_AND(             n      , 63 )
        .
 
        /* rÇcupÇration des caractäres correspondants Ö chaque index */
        ASSIGN
            r = r + SUBSTRING( ch_base64chars, n0 + 1, 1 )
                  + SUBSTRING( ch_base64chars, n1 + 1, 1 )
                  + SUBSTRING( ch_base64chars, n2 + 1, 1 )
                  + SUBSTRING( ch_base64chars, n3 + 1, 1 )
        .
 
        /* les 3 caractäres suivants */
        ASSIGN c = c + 3.
    END.
 
    /* remplace les caractäres de padding et renvoie le rÇsultat */
    ASSIGN r = SUBSTRING( r, 1, LENGTH( r ) - LENGTH( p ) ) + p.
    RETURN r.
 
END FUNCTION.
 
 
 
 
/* DÇcode une chaine encodÇe en base64 */
FUNCTION BASE64_DECODE RETURNS LONGCHAR ( INPUT s AS LONGCHAR ) :
 
    /* caractäres valides en base64 */
    DEFINE VARIABLE ch_base64chars AS CHARACTER NO-UNDO
    INITIAL "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    CASE-SENSITIVE.
 
    /* rÇsultat */
    DEFINE VARIABLE r AS LONGCHAR NO-UNDO INITIAL "".
 
    /* chaine de padding */
    DEFINE VARIABLE p AS LONGCHAR NO-UNDO INITIAL "".
 
    /* pad count */
    DEFINE VARIABLE c AS INTEGER NO-UNDO.
 
    /* nombre de 24 bits */
    DEFINE VARIABLE n AS INTEGER NO-UNDO.
 
    /* remplace tous les caractäres qui ne sont pas dans la liste + "=" */
    DO n = 1 TO LENGTH( s ) :
        IF INDEX( ch_base64chars + "=", SUBSTRING( s, n, 1 ) ) > 0 THEN DO :
            ASSIGN r = r + SUBSTRING( s, n, 1 ).
        END.
    END.
    ASSIGN s = r.
 
    /* remplace les Çventuels caractäres de padding par zero (zero = A) */
    ASSIGN
        p = IF SUBSTRING( s, LENGTH( s ), 1 ) = "="
            THEN
                IF SUBSTRING( s, LENGTH( s ) - 1, 1 ) = "="
                THEN "AA"
                ELSE "A"
            ELSE ""
        r = ""
        s = SUBSTRING( s, 1, LENGTH( s ) - LENGTH( p ) ) + p
    .
 
    /* On parcourt la chaine encodÇe quatre caractäres Ö la fois */
    ASSIGN c = 0.
    DO WHILE c < LENGTH( s ) :
 
        /*
        Chaque groupe de 4 caractäre reprÇsente un index sur 6 bits dans la liste
        des caractäres valides en base64, et qui, une fois concatÇnÇs, nous donne
        un nombre 24 bits qui nous sert Ö retrouver les 3 caractäres d'origine
        */
        ASSIGN
            n = BIN_LSHIFT( INDEX( ch_base64chars, SUBSTRING( s, c + 1, 1 ) ) - 1, 18 )
              + BIN_LSHIFT( INDEX( ch_base64chars, SUBSTRING( s, c + 2, 1 ) ) - 1, 12 )
              + BIN_LSHIFT( INDEX( ch_base64chars, SUBSTRING( s, c + 3, 1 ) ) - 1, 6 )
              + ( INDEX( ch_base64chars, SUBSTRING( s, c + 4, 1 ) ) - 1 )
        .
 
        /* On sÇpare le nombre de 24 bits en 3 caractäres de 8 bits (ASCII) */
        ASSIGN
            r = r + CHR( BIN_AND( BIN_RSHIFT( n, 16 ), 255 ) )
              + CHR( BIN_AND( BIN_RSHIFT( n, 8 ), 255 ) )
              + CHR( BIN_AND( n, 255 ) )
        .
 
        /* les 4 caractäres suivants */
        ASSIGN c = c + 4.
    END.
 
    /* Renvoie le rÇsultat */
    RETURN r.
 
END FUNCTION.
