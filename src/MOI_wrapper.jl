mutable struct Optimizer <: MOI.AbstractOptimizer
    explorer::Explorer

    c_max::Int
    d_max::Int

    int_vars::Set{Int}
    compare_vars::Set{Int}
end

function Optimizer(;
        concepts = Vector{Function}(),
        domains = Vector{AbstractDomain}(),
        objective = nothing,
        settings = ExploreSettings(domains),
)
    explorer = Explorer(concepts, domains, objective; settings)
    return Optimizer(explorer, 0, 0, Set{Int}(), Set{Int}())
end

MOI.get(::Optimizer, ::MOI.SolverName) = "Constraint Explorer"

function MOI.empty!(model::Optimizer)
    model.explorer.concepts = Dict{Int, Function}()
    model.explorer.domains = Dict{Int, AbstractDomain}()
    model.explorer.objective = nothing
    model.explorer.state = ExplorerState{Real}()
    model.c_max = 0
    model.d_max = 0
    model.int_vars = Set{Int}()
    model.compare_vars = Set{Int}()
    return nothing
end

MOI.is_empty(model::Optimizer) = model.c_max == 0 && model.d_max == 0

struct CompleteSearchLimit <: MOI.AbstractOptimizerAttribute end

function MOI.set(model::Optimizer, ::CompleteSearchLimit, n::Integer)
    settings = ExploreSettings(
        n,
        model.explorer.settings.max_samplings,
        model.explorer.settings.search,
        model.explorer.settings.solutions_limit,
    )
    model.explorer.settings = settings
    return nothing
end

function MOI.get(model::Optimizer, ::CompleteSearchLimit)
    return model.explorer.settings.complete_search_limit
end

struct MaxSamplings <: MOI.AbstractOptimizerAttribute end

function MOI.set(model::Optimizer, ::MaxSamplings, n::Integer)
    settings = ExploreSettings(
        model.explorer.settings.complete_search_limit,
        n,
        model.explorer.settings.search,
        model.explorer.settings.solutions_limit,
    )
    model.explorer.settings = settings
    return nothing
end

function MOI.get(model::Optimizer, ::MaxSamplings)
    return model.explorer.settings.max_samplings
end

struct Search <: MOI.AbstractOptimizerAttribute end

function MOI.set(model::Optimizer, ::Search, s::Symbol)
    settings = ExploreSettings(
        model.explorer.settings.complete_search_limit,
        model.explorer.settings.max_samplings,
        s,
        model.explorer.settings.solutions_limit,
    )
    model.explorer.settings = settings
    return nothing
end

function MOI.get(model::Optimizer, ::Search)
    return model.explorer.settings.search
end

struct NumberOfSolutions <: MOI.AbstractOptimizerAttribute end

function MOI.set(model::Optimizer, ::NumberOfSolutions, n::Integer)
    settings = ExploreSettings(
        model.explorer.settings.complete_search_limit,
        model.explorer.settings.max_samplings,
        model.explorer.settings.search,
        n,
    )
    model.explorer.settings = settings
    return nothing
end

function MOI.get(model::Optimizer, ::NumberOfSolutions)
    return model.explorer.settings.solutions_limit
end

MOI.supports_incremental_interface(::Optimizer) = true

function MOI.copy_to(dest::Optimizer, src::MOI.ModelLike)
    return MOI.Utilities.default_copy_to(dest, src)
end

MOI.optimize!(model::Optimizer) = explore!(model.explorer)

function MOI.get(::Optimizer, ::MOI.SolverVersion)
    deps = Pkg.dependencies()
    _uuid = Base.UUID("5800fd60-8556-4464-8d61-84ebf7a0bedb")
    return "v" * string(deps[_uuid].version)
end

solutions(model) = model.moi_backend.optimizer.model.explorer.state.solutions

non_solutions(model) = model.moi_backend.optimizer.model.explorer.state.non_solutions

configurations(model) = solutions(model), non_solutions(model)

function check!(model, configurations)
    checker = model.moi_backend.optimizer.model.explorer
    return _check!(checker, configurations)
end
