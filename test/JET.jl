@testset "Code linting (JET.jl)" begin
    JET.test_package(ConstraintExplorer; target_defined_modules = true)
end
