using Test
using Validate
using DataFrames

rules = Validate.validator()

df = DataFrame(x=[1, 2, -3, missing], y = [2, 20, 5, 10])

res = Validate.violating(df, rules)

@test isequal(res, similar(df, 0))

rules = Validate.validator(r1 = :(x >= 0), r2 = :(y < 10))

res = Validate.violating(df, rules)

@test isequal(res, DataFrame(x=[2, -3, missing], y=[20, 5, 10]))

cf = Validate.confront(df, rules)

res2 = Validate.satisfying(df, cf)

@test isequal(res, DataFrame(x=[2, -3, missing], y=[20, 5, 10]))


