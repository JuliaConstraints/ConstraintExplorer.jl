struct MOICount{F <: Function, T1 <: Number, T2 <: Number} <: MOI.AbstractVectorSet
    op::F
    val::T1
    vals::Vector{T2}
    dimension::Int

    function MOICount(op, val, vals, dim = 0)
        new{typeof(op), typeof(val), eltype(vals)}(op, val, vals, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOICount{F, T1, T2}},) where {F <: Function, T1 <: Number, T2 <: Number}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOICount,)
    s = if set.op == ==
        :exactly
    elseif set.op == ≥
        :at_least
    elseif set.op == ≤
        :at_most
    else
        :count
    end
    function c(x; kwargs...)
        d = Dict(:vals => set.vals, :val => set.val)
        s == :count && push!(d, :op => set.op)
        new_kwargs = merge(kwargs, d)
        return concept(USUAL_CONSTRAINTS[s])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOICount{typeof(set.op), typeof(set.val), eltype(set.vals)}}(cidx)
end

function Base.copy(set::MOICount)
    return MOICount(
        set.op, copy(set.val), copy(set.vals), copy(set.dimension),)
end

struct Count{F <: Function, T1 <: Number, T2 <: Number} <: JuMP.AbstractVectorSet
    op::F
    val::T1
    vals::Vector{T2}

    function Count(op, val, vals)
        return new{typeof(op), typeof(val), eltype(vals)}(op, val, vals)
    end
end

function Count(;
        op::F, val::T1, vals::Vector{T2},) where {
        F <: Function, T1 <: Number, T2 <: Number,}
    return Count(op, val, vals)
end

function JuMP.moi_set(set::Count, dim::Int)
    return MOICount(set.op, set.val, set.vals, dim)
end

struct AtLeast{T1 <: Number, T2 <: Number} <: JuMP.AbstractVectorSet
    val::T1
    vals::Vector{T2}

    function AtLeast(val, vals)
        return new{typeof(val), eltype(vals)}(val, vals)
    end
end

function AtLeast(;
        val::T1, vals::Vector{T2},) where {T1 <: Number, T2 <: Number}
    return AtLeast(val, vals)
end

function JuMP.moi_set(set::AtLeast, dim::Int)
    return MOICount(≥, set.val, set.vals, dim)
end

struct AtMost{T1 <: Number, T2 <: Number} <: JuMP.AbstractVectorSet
    val::T1
    vals::Vector{T2}

    function AtMost(val, vals)
        return new{typeof(val), eltype(vals)}(val, vals)
    end
end

function AtMost(;
        val::T1, vals::Vector{T2},) where {T1 <: Number, T2 <: Number}
    return AtMost(val, vals)
end

function JuMP.moi_set(set::AtMost, dim::Int)
    return MOICount(≤, set.val, set.vals, dim)
end

struct Exactly{T1 <: Number, T2 <: Number} <: JuMP.AbstractVectorSet
    val::T1
    vals::Vector{T2}

    function Exactly(val, vals)
        return new{typeof(val), eltype(vals)}(val, vals)
    end
end

function Exactly(;
        val::T1, vals::Vector{T2},) where {T1 <: Number, T2 <: Number}
    return Exactly(val, vals)
end

function JuMP.moi_set(set::Exactly, dim::Int)
    return MOICount(==, set.val, set.vals, dim)
end
