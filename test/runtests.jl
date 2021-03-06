using Base.Test

# Tutorials
for f in [
        "passthrough",
        "global_hypothesis_verification",
        "voxel_grid",
        "correspondence_grouping",
        "planar_segmentation",
        "statistical_removal",
        "region_growing_rgb_segmentation",
        "extract_indices",
        "tilt_compensation",
        "cluster_extraction",
        ]
    @testset "$f" begin
        include(joinpath(string(f, ".jl")))
    end
end

if parse(Int, get(ENV, "PCLJL_RUN_VISUALIZATION_TESTS", "1")) != 0
    @testset "offscreen_rendering" begin
        include("offscreen_rendering.jl")
    end
end
