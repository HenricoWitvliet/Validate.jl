using Test
using Validate
using DataFrames

rules = Validate.validator(r1 = :(x >= 0), r2 = :(y < 10))

df = DataFrame(x=[1, 2, -3, missing], y = [2, 20, 5, 10])

cf = Validate.confront(df, rules)

@test length(cf.out) == 2
@test isequal(cf.out["r1"], [true, true, false, missing])
@test cf.out["r2"] == [true, false, true, false]

sm = Validate.summary(cf)

@test isequal(sm, DataFrame(name=["r1", "r2"], items=[4, 4], passes=[2, 2], fails=[1, 2], nNa=[1, 0], expression=[:(x >= 0), :(y < 10)]))

