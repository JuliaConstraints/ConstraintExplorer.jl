struct MOIOrdered{F <: Function, T <: Number, V <: Vector{T}} <:
       MOI.AbstractVectorSet
    op::F
    pair_vars::V
    dimension::Int

    function MOIOrdered(op, pair_vars, moi_dim = 0)
        return new{typeof(op), eltype(pair_vars), typeof(pair_vars)}(
            op, pair_vars, moi_dim,)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIOrdered{F, T, V}},) where {
        F <: Function, T <: Number, V <: Vector{T},}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIOrdered,)
    function c(x; kwargs...)
        d = if isempty(set.pair_vars)
            Dict(:op => set.op)
        else
            Dict(:op => set.op, :pair_vars => set.pair_vars)
        end
        new_kwargs = merge(kwargs, d)
        return concept(USUAL_CONSTRAINTS[:ordered])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{
        VOV, MOIOrdered{typeof(set.op), eltype(set.pair_vars), typeof(set.pair_vars)},}(cidx)
end

function Base.copy(set::MOIOrdered)
    return MOIOrdered(copy(set.op), copy(set.pair_vars), copy(set.dimension))
end

struct Ordered{F <: Function, T <: Number, V <: Vector{T}} <:
       JuMP.AbstractVectorSet
    op::F
    pair_vars::V

    function Ordered(op, pair_vars)
        return new{typeof(op), eltype(pair_vars), typeof(pair_vars)}(op, pair_vars)
    end
end

function Ordered(; op = ≤, pair_vars = Vector{Number}())
    return Ordered(op, pair_vars)
end

function JuMP.moi_set(set::Ordered, dim::Int)
    return MOIOrdered(set.op, set.pair_vars, dim)
end
