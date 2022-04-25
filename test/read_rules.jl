using Test
using Validate
using DataFrames
using Dates


rules = Validate.read_rules("../testdata/myrules.yaml")

@test length(rules) == 3
@test rules[1].name == "speed"
@test rules[2].label == "distance positivity"
@test rules[2].description == "distance cannot be negative.\n"
@test rules[2].created == Dates.DateTime(2020, 11, 2, 11, 15, 11)
@test rules[2].meta["language"] == "validate 0.9.3.36"
@test rules[2].meta["severity"] == "error"
