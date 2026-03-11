function fnTimeStamp returns char (input dDate as date,
                                   input iTime as integer):

    return substitute('&1-&2-&3 &4',
                      string(year(dDate), '9999'),
                      string(month(dDate), '99'),
                      string(day(dDate), '99'),
                      string(iTime, 'hh:mm:ss')).
end function.

