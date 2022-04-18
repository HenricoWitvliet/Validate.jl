# set fileencoding=utf-8
module Validate

import YAML

export read_rules

OPERATORS = [Symbol(x) for x in ["<", "<=", "==", ">", ">=", "!=", "!", "&", "|", "+", "-", "*", "/", "%", "÷", "^"]]

function read_rules(filename)
    rules = YAML.load_file(filename)["rules"]
    for rule in rules
        rule["expr"] = Meta.parse(rule["expr"])
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


function confront(df, rules)
    symbols = [Symbol(x) for x in names(df)]
    res = Dict()
    for rule in rules
      rawrule = copy(rule["expr"])
        expr = transform_rule(rawrule, symbols)
        label = rule["label"]
        f = eval(expr)
        res[label] = @eval $f($df)
    end
    return res
end


end # module
