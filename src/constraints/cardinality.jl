struct MOICardinality{T <: Number, V <: VecOrMat{T}} <: MOI.AbstractVectorSet
    bool::Bool
    vals::V
    dimension::Int

    MOICardinality(bool, vals, dim = 0) = new{eltype(vals), typeof(vals)}(bool, vals, dim)
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOICardinality{T, V}},) where {T <: Number, V <: VecOrMat{T}}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOICardinality,)
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:bool => set.bool, :vals => set.vals))
        return concept(USUAL_CONSTRAINTS[:cardinality])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOICardinality{eltype(set.vals), typeof(set.vals)}}(cidx)
end

function Base.copy(set::MOICardinality)
    return MOICardinality(copy(set.bool), copy(set.vals), copy(set.dimension))
end

struct Cardinality{T <: Number, V <: VecOrMat{T}} <: JuMP.AbstractVectorSet
    bool::Bool
    vals::V

    Cardinality(bool, vals) = new{eltype(vals), typeof(vals)}(bool, vals)
end

function Cardinality(; vals::VecOrMat{T}, bool::Bool = false) where {T <: Number}
    return Cardinality(bool, vals)
end

JuMP.moi_set(set::Cardinality, dim::Int) = MOICardinality(set.bool, set.vals, dim)

struct CardinalityOpen{T <: Number, V <: VecOrMat{T}} <: JuMP.AbstractVectorSet
    vals::V

    CardinalityOpen(vals) = new{eltype(vals), typeof(vals)}(vals)
end

function CardinalityOpen(; vals::VecOrMat{T}) where {T <: Number}
    return CardinalityOpen(vals)
end

JuMP.moi_set(set::CardinalityOpen, dim::Int) = MOICardinality(false, set.vals, dim)

struct CardinalityClosed{T <: Number, V <: VecOrMat{T}} <: JuMP.AbstractVectorSet
    vals::V

    CardinalityClosed(vals) = new{eltype(vals), typeof(vals)}(vals)
end

function CardinalityClosed(; vals::VecOrMat{T}) where {T <: Number}
    return CardinalityClosed(vals)
end

JuMP.moi_set(set::CardinalityClosed, dim::Int) = MOICardinality(true, set.vals, dim)
