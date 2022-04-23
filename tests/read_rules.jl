using Test
using Validate
using DataFrames


rules = Validate.read_rules("../testdata/myrules.yaml")

@test length(rules) == 3
@test rules[1].name == "speed"
                    
