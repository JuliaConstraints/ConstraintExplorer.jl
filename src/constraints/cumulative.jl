struct MOICumulative{F <: Function, T1 <: Number, T2 <: Number, V <: VecOrMat{T1}} <:
       MOI.AbstractVectorSet
    op::F
    pair_vars::V
    val::T2
    dimension::Int

    function MOICumulative(op, pair_vars, val, dim = 0)
        return new{typeof(op), eltype(pair_vars), typeof(val), typeof(pair_vars)}(
            op, pair_vars, val, dim,)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOICumulative{F, T1, T2, V}},) where {
        F <: Function, T1 <: Number, T2 <: Number, V <: VecOrMat{T1},}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOICumulative,)
    function c(x; kwargs...)
        d = Dict(:op => set.op, :val => set.val)
        !isempty(set.pair_vars) && push!(d, :pair_vars => set.pair_vars)
        new_kwargs = merge(kwargs, d)
        return concept(USUAL_CONSTRAINTS[:cumulative])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV,
        MOICumulative{
            typeof(set.op), eltype(set.pair_vars), typeof(set.val), typeof(set.pair_vars),},
    }(cidx)
end

function Base.copy(set::MOICumulative)
    return MOICumulative(
        copy(set.op), copy(set.pair_vars), copy(set.val), copy(set.dimension),)
end

struct Cumulative{F <: Function, T1 <: Number, T2 <: Number, V <: VecOrMat{T1}} <:
       JuMP.AbstractVectorSet
    op::F
    pair_vars::V
    val::T2

    function Cumulative(op, pair_vars, val)
        return new{typeof(op), eltype(pair_vars), typeof(val), typeof(pair_vars)}(
            op, pair_vars, val,)
    end
end

Cumulative(; op = ≤, pair_vars = Vector{Number}(), val) = Cumulative(op, pair_vars, val)

function JuMP.moi_set(set::Cumulative, dim::Int)
    return MOICumulative(set.op, set.pair_vars, set.val, dim)
end
