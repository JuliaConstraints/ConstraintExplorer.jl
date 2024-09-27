struct MOICircuit{F <: Function, T <: Number} <: MOI.AbstractVectorSet
    op::F
    val::T
    dimension::Int

    function MOICircuit(op, val, dim_moi = 0)
        return new{typeof(op), typeof(val)}(op, val, dim_moi)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOICircuit{F, T}},) where {F <: Function, T <: Number}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOICircuit,)
    val = iszero(set.val) ? length(vars.variables) : set.val
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:op => set.op, :val => val))
        return concept(USUAL_CONSTRAINTS[:circuit])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOICircuit{typeof(set.op), typeof(set.val)}}(cidx)
end

function Base.copy(set::MOICircuit)
    return MOICircuit(copy(set.op), copy(set.val), copy(set.dimension))
end

struct Circuit{F <: Function, T <: Number} <: JuMP.AbstractVectorSet
    op::F
    val::T

    function Circuit(op, val)
        return new{typeof(op), typeof(val)}(op, val)
    end
end

function Circuit(; op::F = ≥, val::T = 0) where {F <: Function, T <: Number}
    return Circuit(op, val)
end

JuMP.moi_set(set::Circuit, dim_moi::Int) = MOICircuit(set.op, set.val, dim_moi)
