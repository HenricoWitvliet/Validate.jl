using Test
using Validate

rule = Validate.validator(:(speed > 0))

@test rule[1].name == "V1"
@test rule[1].expr == :(speed > 0)

rules = Validate.validator(r1 = :(speed >= 0), r2 = :(distance >= 0))

@test length(rules) == 2
@test rules[2].name == "r2"

complexrule = Validate.validator(:(speed < (distance / time)))
transformed = Validate.transform_rule(complexrule[1].expr, [:speed, :distance, :time])

@test isequal(transformed.args[2].args[end], :(df.speed .< df.distance ./ df.time))

