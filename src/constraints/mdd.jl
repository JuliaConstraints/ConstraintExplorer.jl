struct MOIMultivaluedDecisionDiagram{L <:
                                     ConstraintCommons.AbstractMultivaluedDecisionDiagram} <:
       MOI.AbstractVectorSet
    language::L
    dimension::Int

    function MOIMultivaluedDecisionDiagram(language, dim = 0)
        return new{typeof(language)}(language, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIMultivaluedDecisionDiagram{L}},) where {L <:
                                                          ConstraintCommons.AbstractMultivaluedDecisionDiagram}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIMultivaluedDecisionDiagram,)
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:language => set.language))
        return concept(USUAL_CONSTRAINTS[:mdd])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOIMultivaluedDecisionDiagram{typeof(set.language)}}(cidx)
end

function Base.copy(set::MOIMultivaluedDecisionDiagram)
    return MOIMultivaluedDecisionDiagram(deepcopy(set.language), copy(set.dimension))
end

struct MDDConstraint{L <: ConstraintCommons.AbstractMultivaluedDecisionDiagram} <:
       JuMP.AbstractVectorSet
    language::L

    function MDDConstraint(; language)
        return new{typeof(language)}(language)
    end
end

function JuMP.moi_set(set::MDDConstraint, dim::Int)
    return MOIMultivaluedDecisionDiagram(set.language, dim)
end
