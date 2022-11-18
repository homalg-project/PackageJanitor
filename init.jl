include("init.g.autogen.jl")
include("read.g.autogen.jl")

# export all symbols
# many thanks to https://discourse.julialang.org/t/exportall/4970/16
for n in names(@__MODULE__; all=true)
    if Base.isidentifier(n) && n ∉ (Symbol(@__MODULE__), :eval, :include)
        @eval export $n
    end
end
