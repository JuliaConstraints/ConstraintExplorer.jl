struct MOIRegular{L <: ConstraintCommons.AbstractAutomaton} <: MOI.AbstractVectorSet
    language::L
    dimension::Int

    function MOIRegular(language, dim = 0)
        return new{typeof(language)}(language, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIRegular{L}},) where {L <: ConstraintCommons.AbstractAutomaton}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIRegular,)
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:language => set.language))
        return concept(USUAL_CONSTRAINTS[:regular])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOIRegular{typeof(set.language)}}(cidx)
end

function Base.copy(set::MOIRegular)
    return MOIRegular(deepcopy(set.language), copy(set.dimension))
end

struct Regular{L <: ConstraintCommons.AbstractAutomaton} <: JuMP.AbstractVectorSet
    language::L

    function Regular(; language)
        return new{typeof(language)}(language)
    end
end

function JuMP.moi_set(set::Regular, dim::Int)
    return MOIRegular(set.language, dim)
end
