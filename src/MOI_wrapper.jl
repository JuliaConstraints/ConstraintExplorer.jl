"""
    JuMP.build_variable(::Function, info::JuMP.VariableInfo, set::T) where T <: MOI.AbstractScalarSet

Create a variable constrained by a scalar set.

# Arguments
- `info::JuMP.VariableInfo`: Information about the variable to be created.
- `set::T where T <: MOI.AbstractScalarSet`: The set defining the constraints on the variable.

# Returns
- `JuMP.VariableConstrainedOnCreation`: A variable constrained by the specified set.
"""
function JuMP.build_variable(
        ::Function,
        info::JuMP.VariableInfo,
        set::T,
) where {T <: MOI.AbstractScalarSet}
    return JuMP.VariableConstrainedOnCreation(JuMP.ScalarVariable(info), set)
end

"""
    Optimizer <: MOI.AbstractOptimizer

Defines an optimizer for CBLS.

# Fields
- `solver::LS.MainSolver`: The main solver used for local search.
- `int_vars::Set{Int}`: Set of integer variables.
- `compare_vars::Set{Int}`: Set of variables to compare.
"""
mutable struct Optimizer <: MOI.AbstractOptimizer
    concepts::Dict{Int, Tuple{Function, Vector{Int}}}
    configurations::Tuple{Set{Vector{Number}}, Set{Vector{Number}}}
    domains::Dict{Int, AbstractDomain}
    settings::Union{Nothing, ExploreSettings}

    c_max::Int
    d_max::Int
end

function Optimizer(;
        concepts = Dict{Int, Function}(),
        configurations = (Set{Vector{Number}}(), Set{Vector{Number}}()),
        domains = Dict{Int, AbstractDomain}(),
        settings = nothing,
)
    c_max = maximum(keys(concepts); init = 0)
    d_max = maximum(keys(domains); init = 0)
    return Optimizer(concepts, configurations, domains, parameters, settings, c_max, d_max)
end

MOI.get(::Optimizer, ::MOI.SolverName) = "Constraint Explorer"

function MOI.empty!(explorer::Optimizer)
    empty!(explorer.concepts)
    empty!(explorer.configurations)
    empty!(explorer.domains)
    explorer.settings = nothing

    explorer.c_max = 0
    explorer.d_max = 0
    return
end

function MOI.is_empty(explorer::Optimizer)
    return isempty(explorer.concepts) && isempty(explorer.configurations) &&
           isempty(explorer.domains) && explorer.settings === nothing
end

struct CompleteSearchLimit <: MOI.AbstractModelAttribute end

function MOI.set(model::Optimizer, ::CompleteSearchLimit, n::Integer)
    settings = ExploreSettings(
        n,
        model.settings.max_samplings,
        model.settings.search,
        model.settings.solutions_limit,
    )
    model.settings = settings
    return
end

function MOI.get(model::Optimizer, ::CompleteSearchLimit)
    return model.settings.complete_search_limit
end

struct MaxSamplings <: MOI.AbstractModelAttribute end

function MOI.set(model::Optimizer, ::MaxSamplings, n::Integer)
    settings = ExploreSettings(
        model.settings.complete_search_limit,
        n,
        model.settings.search,
        model.settings.solutions_limit,
    )
    model.settings = settings
    return
end

function MOI.get(model::Optimizer, ::MaxSamplings)
    return model.settings.max_samplings
end

struct Search <: MOI.AbstractModelAttribute end

function MOI.set(model::Optimizer, ::Search, s::Symbol)
    settings = ExploreSettings(
        model.settings.complete_search_limit,
        model.settings.max_samplings,
        s,
        model.settings.solutions_limit,
    )
    model.settings = settings
    return
end

function MOI.get(model::Optimizer, ::Search)
    return model.settings.search
end

struct NumberOfSolutions <: MOI.AbstractModelAttribute end

function MOI.set(model::Optimizer, ::NumberOfSolutions, n::Integer)
    settings = ExploreSettings(
        model.settings.complete_search_limit,
        model.settings.max_samplings,
        model.settings.search,
        n,
    )
    model.settings = settings
    return
end

function MOI.get(model::Optimizer, ::NumberOfSolutions)
    return model.settings.solutions_limit
end

struct Configurations <: MOI.AbstractModelAttribute end

MOI.get(model::Optimizer, ::Configurations) = model.configurations

MOI.supports_incremental_interface(::Optimizer) = true

function MOI.copy_to(model::Optimizer, src::MOI.ModelLike)
    return MOIU.default_copy_to(model, src)
end

function optimize!(model::Optimizer)
    c = reduce(&, model.concepts; init = true)
    return explore(model.domains, c; settings = model.settings)
end

function MOI.get(::Optimizer, ::MOI.SolverVersion)
    deps = Pkg.dependencies()
    _uuid = Base.UUID("5800fd60-8556-4464-8d61-84ebf7a0bedb")
    return "v" * string(deps[_uuid].version)
end
