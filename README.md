Validate.jl
===========

[![codecov](https://codecov.io/gh/HenricoWitvliet/Validate.jl/branch/master/graph/badge.svg?token=24VLOTY9M0)](https://codecov.io/gh/HenricoWitvliet/Validate.jl)
![GitHub CI](https://github.com/HenricoWitvliet/Validate.jl/actions/workflows/ci.yml/badge.svg)
[![][docs-dev-img]][docs-dev-url]

This package contains a subset of the R-package `Validate` (see
[Validate](https://github.com/data-cleaning/validate)) using pure Julia. The
exact functionality that is supported can be found in the [documentation](https://henricowitvliet.github.io/Validate.jl/dev/).


```julia
using DataFrames, Validator

df = DataFrame(speed=[1, 2, missing], distance=[10, 11, -100])
rules = Validate.read_rules("myrules.yaml")
cf = Validate.confront(df, rules)
Validate.summary(cf)
Validate.violating(df, cf)
```
