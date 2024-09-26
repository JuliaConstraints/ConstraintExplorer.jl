@testset "Aqua.jl" begin
    # TODO: Fix the broken tests and remove the `broken = true` flag
    Aqua.test_all(
        ConstraintExplorer;
        ambiguities = (broken = true,),
        deps_compat = true,
        piracies = (broken = false,),
    )

    @testset "Ambiguities: ConstraintExplorer" begin
        Aqua.test_ambiguities(ConstraintExplorer;)
    end

    @testset "Piracies: ConstraintExplorer" begin
        Aqua.test_piracies(ConstraintExplorer;)
    end

    @testset "Dependencies compatibility" begin
        Aqua.test_deps_compat(
            ConstraintExplorer;
            check_extras = true,            # ignore = [:Random]
        )
    end
end
