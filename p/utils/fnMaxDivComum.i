/* calcula o maximo divisor comum */
function fnMaxDivComum returns integer (iA as integer, iB as integer).
    if iB = 0 then
        return iA.
    else
        return fnMaxDivComum(iB, iA mod iB).
end function.

