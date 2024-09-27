struct MOIAllEqual{F <: Function, T1 <: Number, T2 <: Union{Nothing, Number}} <:
       MOI.AbstractVectorSet
    op::F
    pair_vars::Vector{T1}
    val::T2
    dimension::Int

    function MOIAllEqual(op, pair_vars, val, dim = 0)
        return new{typeof(op), eltype(pair_vars), typeof(val)}(op, pair_vars, val, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIAllEqual{F, T1, T2}},) where {
        F <: Function, T1 <: Number, T2 <: Union{Nothing, Number},}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIAllEqual,)
    function c(x; kwargs...)
        new_kwargs = merge(
            kwargs, Dict(:op => set.op, :pair_vars => set.pair_vars, :val => set.val),)
        return concept(USUAL_CONSTRAINTS[:all_equal])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOIAllEqual{typeof(set.op), eltype(set.pair_vars), typeof(set.val)}}(cidx)
end

function Base.copy(set::MOIAllEqual)
    return MOIAllEqual(
        copy(set.op), copy(set.pair_vars), copy(set.val), copy(set.dimension),)
end

struct AllEqual{F <: Function, T1 <: Number, T2 <: Union{Nothing, Number}} <:
       JuMP.AbstractVectorSet
    op::F
    pair_vars::Vector{T1}
    val::T2

    function AllEqual(op, pair_vars, val)
        return new{typeof(op), eltype(pair_vars), typeof(val)}(op, pair_vars, val)
    end
end

function AllEqual(; op::F = +, pair_vars::Vector{T1} = Vector{Number}(),
        val::T2 = nothing,) where {
        F <: Function, T1 <: Number, T2 <: Union{Nothing, Number},}
    return AllEqual(op, pair_vars, val)
end

JuMP.moi_set(set::AllEqual, dim::Int) = MOIAllEqual(set.op, set.pair_vars, set.val, dim)
