struct MOIInstantiation{T <: Number, V <: Vector{T}} <:
       MOI.AbstractVectorSet
    pair_vars::V
    dimension::Int

    function MOIInstantiation(pair_vars, dim = 0)
        return new{eltype(pair_vars), typeof(pair_vars)}(pair_vars, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIInstantiation{T, V}},) where {
        T <: Number, V <: Vector{T},}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIInstantiation,)
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:pair_vars => set.pair_vars))
        return concept(USUAL_CONSTRAINTS[:instantiation])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOIInstantiation{eltype(set.pair_vars), typeof(set.pair_vars)}}(cidx)
end

function Base.copy(set::MOIInstantiation)
    return MOIInstantiation(copy(set.pair_vars), copy(set.dimension))
end

struct Instantiation{T <: Number, V <: Vector{T}} <: JuMP.AbstractVectorSet
    pair_vars::V

    function Instantiation(; pair_vars)
        return new{eltype(pair_vars), typeof(pair_vars)}(pair_vars)
    end
end

function JuMP.moi_set(set::Instantiation, dim::Int)
    return MOIInstantiation(set.pair_vars, dim)
end
