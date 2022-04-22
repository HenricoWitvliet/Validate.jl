Validate.jl
===========

This package contains a subset of the R-package `Validate` (see
[Validate](https://github.com/data-cleaning/validate)) using pure Julia. The
exact functionality that is supported can be found in the documentation.


```julia
using DataFrames, Validator

df = df = DataFrame(speed=[1, 2, missing], distance=[10, 11, -100])
rules = Validate.read_rules("myrules.yaml")
cf = Validate.confront(df, rules)
Validate.summary(cf)
Validate.violating(df, cf)
```
