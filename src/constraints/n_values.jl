struct MOINValues{F <: Function, T1 <: Number, T2 <: Number, V <: Vector{T2}} <:
       MOI.AbstractVectorSet
    op::F
    val::T1
    vals::V
    dimension::Int

    function MOINValues(op, val, vals, dim = 0)
        return new{typeof(op), typeof(val), eltype(vals), typeof(vals)}(op, val, vals, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOINValues{F, T1, T2, V}},) where {
        F <: Function, T1 <: Number, T2 <: Number, V <: Vector{T2},}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOINValues,)
    vals = isempty(set.vals) ? nothing : set.vals
    function c(x; kwargs...)
        d = Dict(:op => set.op, :val => set.val)
        isnothing(vals) && (d[:vals] = vals)
        new_kwargs = merge(kwargs, d)
        return concept(USUAL_CONSTRAINTS[:nvalues])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV,
        MOINValues{typeof(set.op), typeof(set.val), eltype(set.vals), typeof(set.vals)},}(cidx)
end

function Base.copy(set::MOINValues)
    return MOINValues(copy(set.op), copy(set.val), copy(set.vals), copy(set.dimension))
end

struct NValues{F <: Function, T1 <: Number, T2 <: Number, V <: Vector{T2}} <:
       JuMP.AbstractVectorSet
    op::F
    val::T1
    vals::V

    function NValues(op, val, vals)
        return new{typeof(op), typeof(val), eltype(vals), typeof(vals)}(op, val, vals)
    end
end

NValues(; op = ==, val, vals = Vector{Number}()) = NValues(op, val, vals)

function JuMP.moi_set(set::NValues, dim::Int)
    vals = isnothing(set.vals) ? Vector{Number}() : set.vals
    return MOINValues(set.op, set.val, vals, dim)
end
