
function dateIniWeek returns date (input d-data as date,
                                   input i-weekday-ini as integer):

    do while (d-data > 01/01/0001) and (weekday(d-data) <> i-weekday-ini):
        assign d-data = d-data - 1.
    end.

    return d-data.

end function.

