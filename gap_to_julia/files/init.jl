@IMPORT_THE_WORLD()

push!(ModulesForEvaluationStack, @__MODULE__)

include("init.g.autogen.jl")
include("read.g.autogen.jl")

for operation in Operations( CAP_INTERNAL_DERIVATION_GRAPH )
	
	for derivation in CAP_INTERNAL_DERIVATION_GRAPH.derivations_by_target[operation]
		
		precompile(CategoryFilter( derivation ), (IsCapCategory.abstract_type, ))
		
	end
	
end

for derivation in CAP_INTERNAL_FINAL_DERIVATION_LIST
	
	precompile(CategoryFilter( derivation.dummy_derivation ), (IsCapCategory.abstract_type, ))
	
end

@init_CAP_package

CAP_STATE = SAVE_CAP_STATE()

function __init__()
	
	# simulate importing symbols from CAP packages which are not direct dependencies of the current package
	# and hence are not imported during compilation by `@IMPORT_THE_WORLD()` above
	if !is_precompiling()
		for i in 1:length(ModulesForEvaluationStack)
			mod = ModulesForEvaluationStack[i]
			for name in names(mod)
				if !isdefined(@__MODULE__, name)
					eval(:(const $(Symbol(name)) = ModulesForEvaluationStack[$i].$(Symbol(name))))
				end
			end
		end
	end
	
	push!(ModulesForEvaluationStack, @__MODULE__)
	
	RESTORE_CAP_STATE(CAP_STATE)
	
end

# export all symbols
# many thanks to https://discourse.julialang.org/t/exportall/4970/16
for n in names(@__MODULE__; all=true)
    if Base.isidentifier(n) && n ∉ (Symbol(@__MODULE__), :eval, :include, :__init__, :CAP_STATE)
        @eval export $n
    end
end
