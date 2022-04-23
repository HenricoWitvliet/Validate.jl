# julia -i -q --color=yes --project revise.jl example
push!(LOAD_PATH, "../")

push!(LOAD_PATH, "../")

using Revise, Jive
using Validate

trigger = function (path)
    printstyled("changed ", color=:cyan)
    println(path)
    revise()
    runtests(@__DIR__, skip=["revise.jl"])
end

watch(trigger, @__DIR__, sources=[pathof(Validate)])
trigger("")

Base.JLOptions().isinteractive==0 && wait()

