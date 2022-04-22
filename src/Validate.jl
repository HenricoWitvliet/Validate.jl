# set fileencoding=utf-8
module Validate

import YAML
using DataFrames
using Dates
using Statistics

export read_rules, confront, summary, satisfying, violating, lacking, Validator, Validation


OPERATORS = [Symbol(x) for x in ["<", "<=", "==", ">", ">=", "!=", "!", "&", "|", "+", "-", "*", "/", "%", "÷", "^"]]

struct Rule
    name::String
    label::String
    expr::Expr
    meta::Dict
    created::DateTime
    description::String
end

"""
    Validator

    Vector of Dicts to hold validation rules.

    Rules have at least a `name` to uniquely identify a rule and an `expr`
    holding the definition of a rule as a Julia expression. 
    An expression is given in terms of equalities or inequalities between columns of a
    DataFrame.  The result of the expression must be a boolean vector. The collection of
    allowed operations is given in `OPERATORS`. Furthermore, the function `is.na` can be
    used. It returns true for any element which is Julia-missing.
"""
Validator = Vector{Rule}

"""
    Validation

    Struct to hold both the rules and the result of a confrontation.
    Fields are

    - rules: Validator-type holding all used rules
    - out: Dict containing the result of applying each rule to a DataFrame
"""
struct Validation
    rules::Validator
    out::Dict{Any, Any}
end


"""
    read_rules(filename::String)

Read a Validate rule-file in yaml-format.

Returns a list of dicts where each element is a rule. The key `expr` contains
the julia-ast of the rule

# Examples
```julia-repl
using Validate
myrules = Validate.read_rules("myrules.yaml")
```
"""
function read_rules(filename::String)::Validator
    rules = Validator()
    yaml = YAML.load_file(filename)["rules"]
    for rule in yaml
        rule["expr"] = Meta.parse(rule["expr"])
        push!(rules, Rule(rule["name"]
                   , rule["label"]
                   , rule["expr"]
                   , rule["meta"]
                   , rule["created"]
                   , rule["description"]))
    end
    return rules
end

function transform_expr(rule, symbols, vectorwise)
    for (idx, arg) in enumerate(rule.args)
      if (typeof(arg) == Symbol) & (arg in symbols)
        rule.args[idx] = :(df.$arg)
        vectorwise = true
      elseif typeof(arg) == Expr
        rule.args[idx], vw = transform_expr(arg, symbols, vectorwise)
        vectorwise = vectorwise | vw
      end
    end
    return rule, vectorwise
end

function transform_expr_ops(rule)
    for (idx, arg) in enumerate(rule.args)
      if (typeof(arg) == Symbol) & (arg in OPERATORS)
        rule.args[idx] = Symbol("." * string(arg))
      elseif typeof(arg) == Expr
        rule.args[idx] = transform_expr_ops(arg)
      end
    end
    return rule
end

function transform_rule(rule, symbols)
    res, vectorwise = transform_expr(rule, symbols, false)
    if vectorwise
      res = transform_expr_ops(res)
    end
    return :( df -> begin $res end)
end


"""
    confront(df::AbstractDataFrame, rules::Validator)

Apply the given rules to a DataFrame and return the result

Returns a Validation-object with `rules` and `out`. The first contains the
original rules, the second contains a dict with for every rule a vector with
the result. The `name` of the rule is used as the key in this dict

# Example
```julia-repl
using DataFrames, Validate
df = DataFrame(speed=[1, 2, 3], distance=[10, 11, 100])
rules = Validate.read_rules("myrules.yaml")
result = Validate.confront(rules, df)
```
"""
function confront(df::AbstractDataFrame, rules::Validator)
    symbols = [Symbol(x) for x in names(df)]
    res = Dict()
    for rule in rules
      rawrule = copy(rule.expr)
        expr = transform_rule(rawrule, symbols)
        name = rule.name
        f = eval(expr)
        res[name] = @eval $f($df)
    end
    return Validation(rules, res)
end

"""
    summary(confront_out::Validation)

Return a summary output of the validation as a DataFrame
"""
function summary(confront_out::Validation)
    rules = confront_out.rules
    out = confront_out.out
    names = [rule.name for rule in rules]
    res = DataFrame(
                    name = names,
                    items = [length(out[name]) for name in names],
                    passes = [sum(skipmissing(out[name])) for name in names],
                    fails = [sum(skipmissing(.!out[name])) for name in names],
                    nNa = [sum(ismissing.(out[name])) for name in names],
                    expression = [rule.expr for rule in rules]
                         )
    return res

end

function _satisfying(out, include_missing)
    names = collect(keys(out))
    select = out[names[1]]
    if (include_missing)
        select = select .| ismissing.(select)
    end
    for name in names[2:end]
        if (include_missing)
            select = select .& (out[name] .| ismissing.(out[name]))
        else
            select = select .& out[name]
        end
    end
    return select
end

"""
    satisfying(df::AbstractDataFrame, confront_out::Validation, include_missing=false)

Apply the validation results to the dataframe and only return rows that 
satisfy all validation rules.
If include_missing is true, then expressions that evaluate to missing are also counted as
satisfied.  If false, then any expression with value `missing` is counted as violating

Returns a DataFrame
"""
function satisfying(df::AbstractDataFrame, confront_out::Validation, include_missing = false)
    out = confront_out.out
    select = _satisfying(out, include_missing)
    return df[select, :]
end

"""
    satisfying(df::AbstractDataFrame, rules::Validator, include_missing=false)

Apply the rules to the dataframe and only return rows that satisfy all
validation rules.
If include_missing is true, then expressions that evaluate to missing are also counted as
satisfied.  If false, then any expression with value `missing` is counted as violating

Returns a DataFrame
"""
function satisfying(df::AbstractDataFrame, rules::Validator, include_missing=false)
    cf = confront(df, rules)
    return satisfying(df, cf, include_missing)
end

"""
    violating(df::AbstractDataFrame, confront_out::Validation, include_missing=false)

Apply the validation results to the dataframe and only return rows that 
violate one of more rules.
If include_missing is true, then expressions that evaluate to missing are also counted as
satisfied.  If false, then any expression with value `missing` is counted as violating

Returns a DataFrame
"""
function violating(df::AbstractDataFrame, confront_out::Validation, include_missing=false)
    out = confront_out.out
    select = _satisfying(out, include_missing)
    return df[.!select, :]
end

"""
    violating(df::AbstractDataFrame, rules::Validator, include_missing=false)

Apply the rules to the dataframe and only return rows that violate one of more
validation rules.
If include_missing is true, then expressions that evaluate to missing are also counted as
satisfied.  If false, then any expression with value `missing` is counted as violating

Returns a DataFrame
"""
function violating(df::AbstractDataFrame, rules::Validator, include_missing=false)
    cf = confront(df, rules)
    return violating(df, cf, include_missing)
end

"""
    lacking(df::AbstractDataFrame, confront_out::Validation)

Apply the validation results to the dataframe and only return rows that 
have one or more missing values for the rules
"""
function lacking(df::AbstractDataFrame, confront_out::Validation)
    out = confront_out.out
    names = collect(keys(out))
    select = ismissing.(out[names[1]])
    for name in names[2:end]
        select = select .| ismissing(out[name])
    end
    return df[select, :]
end

"""
    lacking(df::AbstractDataFrame, rules::Validator)

Apply the rules to the dataframe and only return rows that 
have one or more missing values for the rules
"""
function lacking(df::AbstractDataFrame, rules::Validator)
    cf = confront(df, rules)
    return lacking(df, cf)
end

# helper functions
#
nrow(df) = size(df)[1]
module is
na(vect) = ismissing.(vect)
character(vect) = (isa(vect, Vector{Union{String, Missing}})) | isa(vect, Vector{String}) | isa(vect, Vector{Missing})
end


end # module
