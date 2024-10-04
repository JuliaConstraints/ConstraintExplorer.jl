constraint!(model::Optimizer, f, vars) = push!(model.explorer, (f, vars))

struct MOIIntention{F <: Function} <: MOI.AbstractVectorSet
    f::F
    dimension::Int

    MOIIntention(f, dim = 0) = new{typeof(f)}(f, dim)
end

function MOI.supports_constraint(
        ::Optimizer, ::Type{VOV}, ::Type{MOIIntention{F}},) where {F <: Function}
    return true
end

function MOI.add_constraint(optimizer::Optimizer, vars::MOI.VectorOfVariables,
        set::MOIIntention{F},) where {F <: Function}
    cidx = constraint!(optimizer, set.f, map(x -> x.value, vars.variables))
    return CI{VOV, MOIIntention{F}}(cidx)
end

Base.copy(set::MOIIntention) = MOIIntention(deepcopy(set.f), copy(set.dimension))

struct Intention{F <: Function} <: JuMP.AbstractVectorSet
    f::F
end

JuMP.moi_set(set::Intention, dim::Int) = MOIIntention(set.f, dim)
