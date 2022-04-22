push!(LOAD_PATH,"../src/")
using Documenter
using Validate

makedocs(
    sitename = "Validate",
    format = Documenter.HTML(),
    modules = [Validate]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/HenricoWitvliet/Validate.jl"
)

