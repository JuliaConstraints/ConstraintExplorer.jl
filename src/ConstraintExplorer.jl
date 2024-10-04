module ConstraintExplorer

#SECTION - Imports
import ConstraintCommons
import ConstraintDomains: AbstractDomain, domain, RangeDomain, intersect_domains
import ConstraintDomains: Explorer, ExploreSettings, ExplorerState, explore!
import Constraints: concept
import JuMP
import MathOptInterface as MOI
import Intervals: Interval, Closed, Open

import TestItems: @testitem

#SECTION - Abbr
# Const
const MOIU = MOI.Utilities

# MOI functions
const VOV = MOI.VectorOfVariables
const OF = MOI.ObjectiveFunction

# MOI indices
const VI = MOI.VariableIndex
const CI = MOI.ConstraintIndex

# MOI types
const VAR_TYPES = Union{MOI.ZeroOne, MOI.Integer}

#SECTION - Exports
# Export: domain
export DiscreteSet

# Export: Constraints
export Error
export Intention, Predicate

export AllDifferent
export AllEqual
export Cardinality, CardinalityClosed, CardinalityOpen
export Channel
export Circuit
export Count, AtLeast, AtMost, Exactly
export Cumulative
export Element
export Extension, Supports, Conflicts
export Instantiation
export DistDifferent # Implementation of an intensional constraint
export Maximum
export MDDConstraint
export Minimum
export NValues
export NoOverlap#, NoOverlapNoZero, NoOverlapWithZero
export Ordered
export Regular
export Sum

#SECTION - Includes
include("MOI_wrapper.jl")
include("variables.jl")
include("constraints.jl")
include("constraints/all_different.jl")
include("constraints/all_equal.jl")
include("constraints/cardinality.jl")
include("constraints/channel.jl")
include("constraints/circuit.jl")
include("constraints/count.jl")
include("constraints/cumulative.jl")
include("constraints/element.jl")
include("constraints/extension.jl")
include("constraints/instantiation.jl")
include("constraints/intention.jl")
include("constraints/maximum.jl")
include("constraints/mdd.jl")
include("constraints/minimum.jl")
include("constraints/n_values.jl")
include("constraints/no_overlap.jl")
include("constraints/ordered.jl")
include("constraints/regular.jl")
include("constraints/sum.jl")

#SECTION - TestItems
@testitem "ConstraintExplorer" default_imports=false begin
    using ConstraintDomains
    using ConstraintExplorer
    using JuMP

    explorer = Model(ConstraintExplorer.Optimizer)

    @variable(explorer, 1≤X[1:4]≤4, Int)

    # @constraint(explorer, X in AllDifferent())

    optimize!(explorer)
end

#SECTION - Main function (optional)

end
