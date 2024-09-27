module ConstraintExplorer

#SECTION - Imports
import ConstraintCommons
import ConstraintDomains: AbstractDomain, ExploreSettings, explore
import Constraints: concept
import JuMP
import MathOptInterface as MOI

import TestItems: @testitem

#SECTION - Abbr
const VOV = MOI.VectorOfVariables

#SECTION - Exports

#SECTION - Includes
include("MOI_wrapper.jl")
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

#SECTION - Main function (optional)

end
