struct MOIMinimum{F <: Function, T <: Number} <: MOI.AbstractVectorSet
    op::F
    val::T
    dimension::Int

    function MOIMinimum(op, val, dim = 0)
        return new{typeof(op), typeof(val)}(op, val, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIMinimum{F, T}},) where {
        F <: Function, T <: Number,}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIMinimum,)
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:op => set.op, :val => set.val))
        return concept(USUAL_CONSTRAINTS[:minimum])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOIMinimum{typeof(set.op), typeof(set.val)}}(cidx)
end

function Base.copy(set::MOIMinimum)
    return MOIMinimum(set.op, copy(set.val), copy(set.dimension))
end

struct Minimum{F <: Function, T <: Number} <: JuMP.AbstractVectorSet
    op::F
    val::T

    function Minimum(op, val)
        return new{typeof(op), typeof(val)}(op, val)
    end
end

Minimum(; op::F = ==, val::T) where {F <: Function, T <: Number} = Minimum(op, val)

function JuMP.moi_set(set::Minimum, dim::Int)
    return MOIMinimum(set.op, set.val, dim)
end
