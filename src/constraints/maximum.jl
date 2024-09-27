struct MOIMaximum{F <: Function, T <: Number} <: MOI.AbstractVectorSet
    op::F
    val::T
    dimension::Int

    function MOIMaximum(op, val, dim = 0)
        return new{typeof(op), typeof(val)}(op, val, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIMaximum{F, T}},) where {
        F <: Function, T <: Number,}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIMaximum,)
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:op => set.op, :val => set.val))
        return concept(USUAL_CONSTRAINTS[:maximum])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOIMaximum{typeof(set.op), typeof(set.val)}}(cidx)
end

function Base.copy(set::MOIMaximum)
    return MOIMaximum(copy(set.op), copy(set.val), copy(set.dimension))
end

struct Maximum{F <: Function, T <: Number} <: JuMP.AbstractVectorSet
    op::F
    val::T

    function Maximum(op, val)
        return new{typeof(op), typeof(val)}(op, val)
    end
end

Maximum(; op::F = ==, val::T) where {F <: Function, T <: Number} = Maximum(op, val)

function JuMP.moi_set(set::Maximum, dim::Int)
    return MOIMaximum(set.op, set.val, dim)
end
