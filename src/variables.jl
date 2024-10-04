function variable!(model::Optimizer)
    model.d_max += 1
    v = model.d_max
    push!(model.explorer.domains, v => domain())
    return v
end

function update_domain!(model::Optimizer, vidx, d)
    if haskey(model.explorer.domains, vidx)
        d₁ = model.explorer.domains[vidx]
        d₂ = isempty(d₁) ? d : intersect_domains(d₁, d)
        @info "debug 3" d d₁ d₂
        model.explorer.domains[vidx] = d₂
    else
        push!(model.explorer.domains, vidx => d)
    end
    return nothing
end

struct DiscreteSet{T <: Number} <: MOI.AbstractScalarSet
    values::Vector{T}
end
DiscreteSet(values) = DiscreteSet(collect(values))
DiscreteSet(values::T...) where {T <: Number} = DiscreteSet(collect(values))

Base.copy(set::DiscreteSet) = DiscreteSet(copy(set.values))

MOI.add_variable(model::Optimizer) = VI(variable!(model))
MOI.add_variables(model::Optimizer, n::Int) = [MOI.add_variable(model) for _ in 1:n]

MOI.supports_constraint(::Optimizer, ::Type{VI}) = true

function MOI.supports_constraint(::Optimizer, ::Type{VI}, ::Type{MOI.EqualTo{T}},
) where {T <: Real}
    return true
end

function MOI.supports_constraint(::Optimizer, ::Type{VI}, ::Type{MOI.Interval{T}},
) where {T <: Real}
    return true
end

function MOI.supports_constraint(::Optimizer, ::Type{VI}, ::Type{MOI.LessThan{T}},
) where {T <: Real}
    return true
end

function MOI.supports_constraint(::Optimizer, ::Type{VI}, ::Type{MOI.GreaterThan{T}},
) where {T <: Real}
    return true
end

function MOI.supports_constraint(
        ::Optimizer, ::Type{VI}, ::Type{DiscreteSet{T}},) where {T <: Number}
    true
end

function MOI.add_constraint(model::Optimizer, v::VI, set::DiscreteSet{T},
) where {T <: Number}
    vidx = v.value
    model.explorer.domains[vidx] = domain(set.values)
    return CI{VI, DiscreteSet{T}}(vidx)
end

function MOI.add_constraint(optimizer::Optimizer, v::VI, lt::MOI.LessThan{T},
) where {T <: AbstractFloat}
    @info "Entering LessThan" v.value
    vidx = v.value
    push!(optimizer.compare_vars, vidx)
    if vidx ∈ optimizer.int_vars
        d = domain(Int(typemin(Int)), Int(lt.upper))
    else
        a = Float64(floatmin(Float32))
        d = domain(Interval{Open, Closed}(a, lt.upper))
    end
    @info "debug" d
    update_domain!(optimizer, vidx, d)
    return CI{VI, MOI.LessThan{T}}(vidx)
end

function MOI.add_constraint(optimizer::Optimizer, v::VI, gt::MOI.GreaterThan{T},
) where {T <: AbstractFloat}
    @info "Entering GreaterThan" v.value
    vidx = v.value
    push!(optimizer.compare_vars, vidx)
    if vidx ∈ optimizer.int_vars
        d = domain(Int(gt.lower):typemax(Int))
    else
        b = Float64(floatmax(Float32))
        d = domain(Interval{Closed, Open}(gt.lower, b))
    end
    update_domain!(optimizer, vidx, d)
    return CI{VI, MOI.GreaterThan{T}}(vidx)
end

function MOI.add_constraint(optimizer::Optimizer, v::VI, i::MOI.Interval{T},
) where {T <: Real}
    vidx = v.value
    is_int = MOI.is_valid(optimizer, CI{VI, MOI.Integer}(vidx))
    d = make_domain(i.lower, i.upper, Val(is_int ? :range : :inter))
    _set_domain!(optimizer, vidx, d)
    return CI{VI, MOI.Interval{T}}(vidx)
end

function MOI.add_constraint(optimizer::Optimizer, v::VI, et::MOI.EqualTo{T},
) where {T <: Number}
    vidx = v.value
    _set_domain!(optimizer, vidx, et.value)
    return CI{VI, MOI.EqualTo{T}}(vidx)
end

MOI.supports_constraint(::Optimizer, ::Type{VI}, ::Type{<:MOI.Integer}) = true

function MOI.add_constraint(model::Optimizer, v::VI, ::MOI.Integer)
    vidx = v.value
    push!(model.int_vars, vidx)
    if vidx ∈ model.compare_vars
        x = model.explorer.domains[vidx]
        @info x.domain model.compare_vars model.int_vars
        model.explorer.domains[vidx] = convert(RangeDomain, x)
    end
    return MOI.ConstraintIndex{VI, MOI.Integer}(vidx)
end
