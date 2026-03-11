function PrintChar returns char
    (input c-string as CHAR):

    assign c-string = replace(c-string,"∆","a").
    assign c-string = replace(c-string,"µ","A").
    assign c-string = replace(c-string,"«","A").
    assign c-string = replace(c-string,"∑","A").
    assign c-string = replace(c-string,"†","a").
    assign c-string = replace(c-string,"Ö","a").
    
    assign c-string = replace(c-string,"ê","E").
    assign c-string = replace(c-string,"‘","E").
    assign c-string = replace(c-string,"“","E").
    assign c-string = replace(c-string,"Ç","e").
    assign c-string = replace(c-string,"ä","e").
    assign c-string = replace(c-string,"à","e").

    assign c-string = replace(c-string,"÷","I").
    assign c-string = replace(c-string,"ﬁ","I").
    assign c-string = replace(c-string,"◊","I").
    assign c-string = replace(c-string,"°","i").
    assign c-string = replace(c-string,"ç","i").
    assign c-string = replace(c-string,"å","i").

    assign c-string = replace(c-string,"‡","O").
    assign c-string = replace(c-string,"„","O").
    assign c-string = replace(c-string,"Â","O").
    assign c-string = replace(c-string,"‚","O").
    assign c-string = replace(c-string,"¢","o").
    assign c-string = replace(c-string,"ï","o").
    assign c-string = replace(c-string,"‰","o").
    assign c-string = replace(c-string,"ì","o").

    assign c-string = replace(c-string,"£","u").
    assign c-string = replace(c-string,"ó","u").
    assign c-string = replace(c-string,"ñ","u").
    assign c-string = replace(c-string,"Å","u").
    assign c-string = replace(c-string,"È","U").
    assign c-string = replace(c-string,"Î","U").
    assign c-string = replace(c-string,"Í","U").
    assign c-string = replace(c-string,"ö","U").
    
    assign c-string = replace(c-string,"á","c").
    assign c-string = replace(c-string,"Ä","C").

    IF INDEX (c-string,CHR(13)) <> 0 THEN
        ASSIGN c-string = SUBSTRING (c-string,1,INDEX (c-string,CHR(13))).
    IF INDEX (c-string,CHR(10)) <> 0 THEN
        ASSIGN c-string = SUBSTRING (c-string,1,INDEX (c-string,CHR(10))). /* SEGUE A LINHA ATE O ENTER E IGNORA */

    ASSIGN c-string = REPLACE(c-string,CHR(13),"").
    ASSIGN c-string = REPLACE(c-string,CHR(10),"").
    
    assign c-string = trim(c-string).

    if c-string = "" then
        assign c-string = "N/CADASTRADO".

    return c-string.

end function.
