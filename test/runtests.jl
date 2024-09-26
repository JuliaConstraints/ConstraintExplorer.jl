using ConstraintExplorer
using Test
using Aqua
using JET

@testset "ConstraintExplorer.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ConstraintExplorer)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(ConstraintExplorer; target_defined_modules = true)
    end
    # Write your tests here.
end
