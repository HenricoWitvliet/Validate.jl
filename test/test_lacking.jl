using Test
using Validate
using DataFrames

rules = Validate.validator()

df = DataFrame(x=[1, 2, -3, missing], y=[2, 20, 5, 10])

res = Validate.lacking(df, rules)

@test isequal(res, df)

rules = Validate.validator(r1 = :(x >= 0), r2 = :(y < 10))

res = Validate.lacking(df, rules)

@test isequal(res, DataFrame(x=[missing], y=[10]))

cf = Validate.confront(df, rules)

res2 = Validate.lacking(df, cf)

@test isequal(res, DataFrame(x=[missing], y=[10]))

