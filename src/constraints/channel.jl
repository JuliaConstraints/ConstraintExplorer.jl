struct MOIChannel{D <: Integer, I <: Integer} <: MOI.AbstractVectorSet
    dim::D
    id::I
    dimension::Int

    function MOIChannel(dim, id, dim_moi = 0)
        return new{typeof(dim), typeof(id)}(dim, id, dim_moi)
    end
end

function MOI.supports_constraint(::Optimizer,
        ::Type{VOV},
        ::Type{MOIChannel{D, I}},) where {D <: Integer, I <: Integer}
    return true
end

function MOI.add_constraint(
        optimizer::Optimizer, vars::MOI.VectorOfVariables, set::MOIChannel,)
    id = iszero(set.id) ? nothing : set.id
    function c(x; kwargs...)
        new_kwargs = merge(kwargs, Dict(:dim => set.dim, :id => id))
        return concept(USUAL_CONSTRAINTS[:channel])(x; new_kwargs...)
    end
    cidx = constraint!(optimizer, c, map(x -> x.value, vars.variables))
    return CI{VOV, MOIChannel{typeof(set.dim), typeof(set.id)}}(cidx)
end

function Base.copy(set::MOIChannel)
    return MOIChannel(copy(set.dim), copy(set.id), copy(set.dimension))
end

struct Channel{D <: Integer, I <: Integer} <: JuMP.AbstractVectorSet
    dim::D
    id::I

    function Channel(dim, id)
        return new{typeof(dim), typeof(id)}(dim, id)
    end
end

function Channel(; dim::D = 1, id::I = 0) where {D <: Integer, I <: Integer}
    return Channel(dim, id)
end

JuMP.moi_set(set::Channel, dim_moi::Int) = MOIChannel(set.dim, set.id, dim_moi)
