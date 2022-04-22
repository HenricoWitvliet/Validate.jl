var documenterSearchIndex = {"docs":
[{"location":"#Validate.jl","page":"Validate.jl","title":"Validate.jl","text":"","category":"section"},{"location":"","page":"Validate.jl","title":"Validate.jl","text":"Documentation for Validate.jl","category":"page"},{"location":"","page":"Validate.jl","title":"Validate.jl","text":"Modules = [Validate]\r\nOrder   = [:type, :function]","category":"page"},{"location":"#Validate.Validation","page":"Validate.jl","title":"Validate.Validation","text":"Validation\n\nStruct to hold both the rules and the result of a confrontation.\nFields are\n\n- rules: Validator-type holding all used rules\n- out: Dict containing the result of applying each rule to a DataFrame\n\n\n\n\n\n","category":"type"},{"location":"#Validate.Validator","page":"Validate.jl","title":"Validate.Validator","text":"Validator\n\nVector of Dicts to hold validation rules.\n\nRules have at least a `name` to uniquely identify a rule and an `expr`\nholding the definition of a rule as a Julia expression. \nAn expression is given in terms of equalities or inequalities between columns of a\nDataFrame.  The result of the expression must be a boolean vector. The collection of\nallowed operations is given in `OPERATORS`. Furthermore, the function `is.na` can be\nused. It returns true for any element which is Julia-missing.\n\n\n\n\n\n","category":"type"},{"location":"#Validate.confront-Tuple{DataFrames.AbstractDataFrame, Vector{Validate.Rule}}","page":"Validate.jl","title":"Validate.confront","text":"confront(df::AbstractDataFrame, rules::Validator)\n\nApply the given rules to a DataFrame and return the result\n\nReturns a Validation-object with rules and out. The first contains the original rules, the second contains a dict with for every rule a vector with the result. The name of the rule is used as the key in this dict\n\nExample\n\nusing DataFrames, Validate\ndf = DataFrame(speed=[1, 2, 3], distance=[10, 11, 100])\nrules = Validate.read_rules(\"myrules.yaml\")\nresult = Validate.confront(rules, df)\n\n\n\n\n\n","category":"method"},{"location":"#Validate.lacking-Tuple{DataFrames.AbstractDataFrame, Validation}","page":"Validate.jl","title":"Validate.lacking","text":"lacking(df::AbstractDataFrame, confront_out::Validation)\n\nApply the validation results to the dataframe and only return rows that  have one or more missing values for the rules\n\n\n\n\n\n","category":"method"},{"location":"#Validate.lacking-Tuple{DataFrames.AbstractDataFrame, Vector{Validate.Rule}}","page":"Validate.jl","title":"Validate.lacking","text":"lacking(df::AbstractDataFrame, rules::Validator)\n\nApply the rules to the dataframe and only return rows that  have one or more missing values for the rules\n\n\n\n\n\n","category":"method"},{"location":"#Validate.read_rules-Tuple{String}","page":"Validate.jl","title":"Validate.read_rules","text":"read_rules(filename::String)\n\nRead a Validate rule-file in yaml-format.\n\nReturns a list of dicts where each element is a rule. The key expr contains the julia-ast of the rule\n\nExamples\n\nusing Validate\nmyrules = Validate.read_rules(\"myrules.yaml\")\n\n\n\n\n\n","category":"method"},{"location":"#Validate.satisfying","page":"Validate.jl","title":"Validate.satisfying","text":"satisfying(df::AbstractDataFrame, confront_out::Validation, include_missing=false)\n\nApply the validation results to the dataframe and only return rows that  satisfy all validation rules. If include_missing is true, then expressions that evaluate to missing are also counted as satisfied.  If false, then any expression with value missing is counted as violating\n\nReturns a DataFrame\n\n\n\n\n\n","category":"function"},{"location":"#Validate.satisfying-2","page":"Validate.jl","title":"Validate.satisfying","text":"satisfying(df::AbstractDataFrame, rules::Validator, include_missing=false)\n\nApply the rules to the dataframe and only return rows that satisfy all validation rules. If include_missing is true, then expressions that evaluate to missing are also counted as satisfied.  If false, then any expression with value missing is counted as violating\n\nReturns a DataFrame\n\n\n\n\n\n","category":"function"},{"location":"#Validate.summary-Tuple{Validation}","page":"Validate.jl","title":"Validate.summary","text":"summary(confront_out::Validation)\n\nReturn a summary output of the validation as a DataFrame\n\n\n\n\n\n","category":"method"},{"location":"#Validate.violating","page":"Validate.jl","title":"Validate.violating","text":"violating(df::AbstractDataFrame, confront_out::Validation, include_missing=false)\n\nApply the validation results to the dataframe and only return rows that  violate one of more rules. If include_missing is true, then expressions that evaluate to missing are also counted as satisfied.  If false, then any expression with value missing is counted as violating\n\nReturns a DataFrame\n\n\n\n\n\n","category":"function"},{"location":"#Validate.violating-2","page":"Validate.jl","title":"Validate.violating","text":"violating(df::AbstractDataFrame, rules::Validator, include_missing=false)\n\nApply the rules to the dataframe and only return rows that violate one of more validation rules. If include_missing is true, then expressions that evaluate to missing are also counted as satisfied.  If false, then any expression with value missing is counted as violating\n\nReturns a DataFrame\n\n\n\n\n\n","category":"function"}]
}
