using Test
using Validate
using DataFrames

df = DataFrame(x=1:10, y=11:20)

@test nrow(df) == 10

@test isequal(is.na([true, false, missing, false, missing]), [false, false, true, false, true])
