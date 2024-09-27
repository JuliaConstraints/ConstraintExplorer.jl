struct MOIAllDifferent{T <: Number} <: MOI.AbstractVectorSet
    vals::Vector{T}
    dimension::Int

    MOIAllDifferent(vals, dim = 0) = new{eltype(vals)}(vals, dim)
end

function MOI.supports_constraint(
        ::Optimizer, ::Type{VOV}, ::Type{MOIAllDifferent{T}},) where {T <: Number}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIAllDifferent,)
    vals = isempty(set.vals) ? nothing : set.vals
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:vals => vals))
        return concept(USUAL_CONSTRAINTS[:all_different])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOIAllDifferent{eltype(set.vals)}}(cidx)
end

Base.copy(set::MOIAllDifferent) = MOIAllDifferent(copy(set.vals), copy(set.dimension))

struct AllDifferent{T <: Number} <: JuMP.AbstractVectorSet
    vals::Vector{T}
    AllDifferent(vals) = new{eltype(vals)}(vals)
end

AllDifferent(; vals::Vector{T} = Vector{Number}()) where {T <: Number} = AllDifferent(vals)

JuMP.moi_set(set::AllDifferent, dim::Int) = MOIAllDifferent(set.vals, dim)
