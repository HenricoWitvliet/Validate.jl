using Test
using Validate
using DataFrames

rules = Validate.validator()

df = DataFrame(x=[1, 2, -3, missing], y = [2, 20, 5, 10])

res = Validate.satisfying(df, rules)

@test isequal(df, res)

rules = Validate.validator(r1 = :(x >= 0), r2 = :(y < 10))

res = Validate.satisfying(df, rules)

@test isequal(res, DataFrame(x=[1], y=[2]))

res = Validate.satisfying(df, rules, true)

@test isequal(res, DataFrame(x=[1], y=[2]))

cf = Validate.confront(df, rules)

res2 = Validate.satisfying(df, cf)

@test isequal(res, DataFrame(x=[1], y=[2]))

