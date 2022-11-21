include("init.g.autogen.jl")
include("read.g.autogen.jl")

function __init__()
	symbol = Symbol("init_" * string(@__MODULE__))
	if isdefined(@__MODULE__, symbol)
		eval(symbol)()
	end
end

# export all symbols
# many thanks to https://discourse.julialang.org/t/exportall/4970/16
for n in names(@__MODULE__; all=true)
    if Base.isidentifier(n) && n ∉ (Symbol(@__MODULE__), :eval, :include, :__init__)
        @eval export $n
    end
end
