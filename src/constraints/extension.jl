struct MOIExtension{
    T <: Number, V <: Union{Vector{Vector{T}}, Tuple{Vector{T}, Vector{T}}},} <:
       MOI.AbstractVectorSet
    pair_vars::V
    dimension::Int

    function MOIExtension(pair_vars, dim = 0)
        ET = eltype(first(typeof(pair_vars) <: Tuple ? first(pair_vars) : pair_vars))
        return new{ET, typeof(pair_vars)}(pair_vars, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIExtension{T, V}},) where {
        T <: Number, V <: Union{Vector{Vector{T}}, Tuple{Vector{T}, Vector{T}}},}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIExtension,)
    pair_vars = set.pair_vars
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:pair_vars => set.pair_vars))
        return concept(USUAL_CONSTRAINTS[:extension])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    ET = eltype(first(typeof(pair_vars) <: Tuple ? first(pair_vars) : pair_vars))
    return CI{VOV, MOIExtension{ET, typeof(pair_vars)}}(cidx)
end

function Base.copy(set::MOIExtension)
    return MOIExtension(copy(set.pair_vars), copy(set.dimension))
end

struct Extension{T <: Number, V <: Union{Vector{Vector{T}}, Tuple{Vector{T}, Vector{T}}}} <:
       JuMP.AbstractVectorSet
    pair_vars::V

    function Extension(pair_vars)
        ET = eltype(first(typeof(pair_vars) <: Tuple ? first(pair_vars) : pair_vars))
        return new{ET, typeof(pair_vars)}(pair_vars)
    end
end

Extension(; pair_vars) = Extension(pair_vars)

function JuMP.moi_set(set::Extension, dim::Int)
    return MOIExtension(set.pair_vars, dim)
end

struct MOISupports{T <: Number, V <: Vector{Vector{T}}} <: MOI.AbstractVectorSet
    pair_vars::V
    dimension::Int

    function MOISupports(pair_vars, dim = 0)
        ET = eltype(first(pair_vars))
        return new{ET, typeof(pair_vars)}(pair_vars, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOISupports{T, V}},) where {
        T <: Number, V <: Vector{Vector{T}},}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOISupports,)
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:pair_vars => set.pair_vars))
        return concept(USUAL_CONSTRAINTS[:supports])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    ET = eltype(first(set.pair_vars))
    return CI{VOV, MOISupports{ET, typeof(set.pair_vars)}}(cidx)
end

function Base.copy(set::MOISupports)
    return MOISupports(copy(set.pair_vars), copy(set.dimension))
end

struct Supports{T <: Number, V <: Vector{Vector{T}}} <: JuMP.AbstractVectorSet
    pair_vars::V

    function Supports(; pair_vars)
        ET = eltype(first(pair_vars))
        return new{ET, typeof(pair_vars)}(pair_vars)
    end
end

function JuMP.moi_set(set::Supports, dim::Int)
    return MOISupports(set.pair_vars, dim)
end

struct MOIConflicts{T <: Number, V <: Vector{Vector{T}}} <:
       MOI.AbstractVectorSet
    pair_vars::V
    dimension::Int

    function MOIConflicts(pair_vars, dim = 0)
        ET = eltype(first(pair_vars))
        return new{ET, typeof(pair_vars)}(pair_vars, dim)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIConflicts{T, V}},) where {
        T <: Number, V <: Vector{Vector{T}},}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIConflicts,)
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:pair_vars => set.pair_vars))
        return concept(USUAL_CONSTRAINTS[:conflicts])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    ET = eltype(first(set.pair_vars))
    return CI{VOV, MOIConflicts{ET, typeof(set.pair_vars)}}(cidx)
end

function Base.copy(set::MOIConflicts)
    return MOIConflicts(copy(set.pair_vars), copy(set.dimension))
end

struct Conflicts{T <: Number, V <: Vector{Vector{T}}} <: JuMP.AbstractVectorSet
    pair_vars::V

    function Conflicts(; pair_vars)
        ET = eltype(first(pair_vars))
        return new{ET, typeof(pair_vars)}(pair_vars)
    end
end

function JuMP.moi_set(set::Conflicts, dim::Int)
    return MOIConflicts(set.pair_vars, dim)
end
