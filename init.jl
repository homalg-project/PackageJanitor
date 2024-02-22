push!(ModulesForEvaluationStack, @__MODULE__)

CAP.IS_PRECOMPILING = true

include("init.g.autogen.jl")
include("read.g.autogen.jl")

CAP.IS_PRECOMPILING = false

CAP_STATE = SAVE_CAP_STATE()

function __init__()
	
	push!(ModulesForEvaluationStack, @__MODULE__)
	
	RESTORE_CAP_STATE(CAP_STATE)
	
	@init_CAP_package
	
end

# export all symbols
# many thanks to https://discourse.julialang.org/t/exportall/4970/16
for n in names(@__MODULE__; all=true)
    if (Base.isidentifier(n) || n in [:⥉]) && n ∉ (Symbol(@__MODULE__), :eval, :include, :__init__, :CAP_STATE)
        @eval export $n
    end
end
