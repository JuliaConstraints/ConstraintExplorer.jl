struct MOINoOverlap{I <: Integer, T <: Number, V <: Vector{T}} <:
       MOI.AbstractVectorSet
    bool::Bool
    dim::I
    pair_vars::V
    dimension::Int

    function MOINoOverlap(bool, dim, pair_vars, moi_dim = 0)
        return new{typeof(dim), eltype(pair_vars), typeof(pair_vars)}(
            bool, dim, pair_vars, moi_dim,)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOINoOverlap{I, T, V}},) where {
        I <: Integer, T <: Number, V <: Vector{T},}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOINoOverlap,)
    function c(x; kwargs...)
        d = if isempty(set.pair_vars)
            Dict(:dim => set.dim, :bool => set.bool)
        else
            Dict{Symbol, Any}(
                :dim => set.dim, :bool => set.bool, :pair_vars => set.pair_vars,)
        end
        new_kwargs = merge(kwargs, d)
        return concept(USUAL_CONSTRAINTS[:no_overlap])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{
        VOV, MOINoOverlap{typeof(set.dim), eltype(set.pair_vars), typeof(set.pair_vars)},}(cidx)
end

function Base.copy(set::MOINoOverlap)
    return MOINoOverlap(
        copy(set.bool), copy(set.dim), copy(set.pair_vars), copy(set.dimension),)
end

struct NoOverlap{I <: Integer, T <: Number, V <: Vector{T}} <:
       JuMP.AbstractVectorSet
    bool::Bool
    dim::I
    pair_vars::V

    function NoOverlap(; bool = true, dim = 1, pair_vars = Vector{Number}())
        return new{typeof(dim), eltype(pair_vars), typeof(pair_vars)}(bool, dim, pair_vars)
    end
end

function JuMP.moi_set(set::NoOverlap, dim::Int)
    return MOINoOverlap(set.bool, set.dim, set.pair_vars, dim)
end
