
using ConstraintExplorer

using Aqua
using ExplicitImports
using JET
using Test
using TestItemRunner

@testset "Package tests: ConstraintExplorer" begin
    include("Aqua.jl")
    include("ExplicitImports.jl")
    include("JET.jl")
    include("TestItemRunner.jl")
end
