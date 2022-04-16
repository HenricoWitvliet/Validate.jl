module Validate

import YAML
using DataFramesMeta

export read_rules

df = DataFrame()
global dfI

function read_rules(filename)
    rules = YAML.load_file(filename)["rules"]
    for rule in rules
        rule["expr"] = Meta.parse(rule["expr"])
    end
    return rules
end

function transform_rule(rule, symbols)
    for (idx, arg) in enumerate(rule.args)
      if (typeof(arg) == Symbol) & (arg in symbols)
        rule.args[idx] = QuoteNode(arg)
      elseif typeof(arg) == Expr
        rule.args[idx] = transform_rule(arg, symbols)
      end
    end
    return rule
end

function confront(df, rules)
    global dfI
    dfI = df
    symbols = [Symbol(x) for x in names(df)]
    res = Dict()
    for rule in rules
        expr = transform_rule(rule["expr"], symbols)
        label = rule["label"]
        res[label] = eval(:(@with(dfI, @byrow $(expr))))
    end
    dfI = DataFrame()
    return res
end


end # module
