struct MOIDistDifferent <: MOI.AbstractVectorSet
    dimension::Int

    function MOIDistDifferent(dim = 4)
        return new(dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIDistDifferent},)
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, ::MOIDistDifferent,)
    function c(x; kwargs...)
        return concept(USUAL_CONSTRAINTS[:dist_different])(x)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOIDistDifferent}(cidx)
end

function Base.copy(set::MOIDistDifferent)
    return MOIDistDifferent(copy(set.dimension))
end

struct DistDifferent <: JuMP.AbstractVectorSet end

function JuMP.moi_set(::DistDifferent, dim::Int)
    return MOIDistDifferent(dim)
end
