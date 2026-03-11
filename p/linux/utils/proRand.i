function rand returns integer (input maxNumber as int):
     return (random(0,maxNumber) + int(replace(string(time,"HH:MM:SS"),":","")) + etime) mod (maxNumber + 1).
end.
