using Test
using Dates
using Fundamentus


testsets = Dict{String, String}(
   "Utils" => "test_utils.jl",
)

for (setname, test_file) in testsets
    @testset "$setname" begin
        include(test_file)
    end
end
